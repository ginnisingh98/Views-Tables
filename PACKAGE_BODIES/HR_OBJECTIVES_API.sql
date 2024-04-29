--------------------------------------------------------
--  DDL for Package Body HR_OBJECTIVES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OBJECTIVES_API" as
/* $Header: peobjapi.pkb 120.4.12010000.3 2008/08/28 07:52:24 arumukhe ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_objectives_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_objective> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_objective
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_name                         in     varchar2,
  p_start_date                   in 	date,
  p_owning_person_id             in 	number,
  p_target_date                  in 	date             default null,
  p_achievement_date             in 	date             default null,
  p_detail                       in 	varchar2         default null,
  p_comments                     in 	varchar2         default null,
  p_success_criteria             in 	varchar2         default null,
  p_appraisal_id                 in 	number           default null,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,

  p_attribute21                  in 	varchar2         default null,
  p_attribute22                  in 	varchar2         default null,
  p_attribute23                  in 	varchar2         default null,
  p_attribute24                  in 	varchar2         default null,
  p_attribute25                  in 	varchar2         default null,
  p_attribute26                  in 	varchar2         default null,
  p_attribute27                  in 	varchar2         default null,
  p_attribute28                  in 	varchar2         default null,
  p_attribute29                  in 	varchar2         default null,
  p_attribute30                  in 	varchar2         default null,

  p_scorecard_id                 in     number           default null,
  p_copied_from_library_id       in     number           default null,
  p_copied_from_objective_id     in     number           default null,
  p_aligned_with_objective_id    in     number           default null,

  p_next_review_date             in     date             default null,
  p_group_code                   in     varchar2         default null,
  p_priority_code                in     varchar2         default null,
  p_appraise_flag                in     varchar2         default null,
  p_verified_flag                in     varchar2         default null,

  p_target_value                 in     number           default null,
  p_actual_value                 in     number           default null,
  p_weighting_percent            in     number           default null,
  p_complete_percent             in     number           default null,
  p_uom_code                     in     varchar2         default null,

  p_measurement_style_code       in     varchar2         default null,
  p_measure_name                 in     varchar2         default null,
  p_measure_type_code            in     varchar2         default null,
  p_measure_comments             in     varchar2         default null,
  p_sharing_access_code          in     varchar2         default null,

  p_weighting_over_100_warning	   out nocopy	boolean,
  p_weighting_appraisal_warning   out nocopy	boolean,

  p_objective_id                 out nocopy    number,
  p_object_version_number        out nocopy 	number
 )
 is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'create_objective';
  l_objective_id		per_objectives.objective_id%TYPE;
  l_object_version_number	per_objectives.object_version_number%TYPE;
  l_effective_date              date;
  l_start_date                  per_objectives.start_date%TYPE;
  l_target_date                 per_objectives.target_date%TYPE;
  l_achievement_date            per_objectives.achievement_date%TYPE;

    l_weighting_over_100_warning  boolean := false;
    l_weighting_appraisal_warning boolean := false;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_objective;
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validation in addition to Table Handlers
  --
  l_effective_date    := trunc(p_effective_date);
  l_start_date        := trunc(p_start_date);
  l_target_date       := trunc(p_target_date);
  l_achievement_date  := trunc(p_achievement_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_objective
  --
  hr_objectives_bk1.create_objective_b
    (
     p_effective_date               => l_effective_date,
     p_business_group_id            => p_business_group_id,
     p_name                         => p_name,
     p_start_date                   => l_start_date,
     p_owning_person_id             => p_owning_person_id,
     p_target_date                  => l_target_date,
     p_achievement_date             => l_achievement_date,
     p_detail                       => p_detail,
     p_comments                     => p_comments,
     p_success_criteria             => p_success_criteria,
     p_appraisal_id                 => p_appraisal_id,
     p_attribute_category           => p_attribute_category,
     p_attribute1                   => p_attribute1,
     p_attribute2                   => p_attribute2,
     p_attribute3                   => p_attribute3,
     p_attribute4                   => p_attribute4,
     p_attribute5                   => p_attribute5,
     p_attribute6                   => p_attribute6,
     p_attribute7                   => p_attribute7,
     p_attribute8                   => p_attribute8,
     p_attribute9                   => p_attribute9,
     p_attribute10                  => p_attribute10,
     p_attribute11                  => p_attribute11,
     p_attribute12                  => p_attribute12,
     p_attribute13                  => p_attribute13,
     p_attribute14                  => p_attribute14,
     p_attribute15                  => p_attribute15,
     p_attribute16                  => p_attribute16,
     p_attribute17                  => p_attribute17,
     p_attribute18                  => p_attribute18,
     p_attribute19                  => p_attribute19,
     p_attribute20                  => p_attribute20,

     p_attribute21                   => p_attribute21,
     p_attribute22                   => p_attribute22,
     p_attribute23                   => p_attribute23,
     p_attribute24                   => p_attribute24,
     p_attribute25                   => p_attribute25,
     p_attribute26                   => p_attribute26,
     p_attribute27                   => p_attribute27,
     p_attribute28                   => p_attribute28,
     p_attribute29                   => p_attribute29,
     p_attribute30                   => p_attribute30,

     p_scorecard_id                     => p_scorecard_id,
     p_copied_from_library_id		=> p_copied_from_library_id,
     p_copied_from_objective_id		=> p_copied_from_objective_id,
     p_aligned_with_objective_id	=> p_aligned_with_objective_id,

     p_next_review_date			=> p_next_review_date,
     p_group_code			=> p_group_code,
     p_priority_code			=> p_priority_code,
     p_appraise_flag			=> p_appraise_flag,
     p_verified_flag			=> p_verified_flag,

     p_target_value			=> p_target_value,
     p_actual_value			=> p_actual_value,
     p_weighting_percent		=> p_weighting_percent,
     p_complete_percent			=> p_complete_percent,
     p_uom_code				=> p_uom_code,

     p_measurement_style_code		=> p_measurement_style_code,
     p_measure_name			=> p_measure_name,
     p_measure_type_code		=> p_measure_type_code,
     p_measure_comments 		=> p_measure_comments ,
     p_sharing_access_code		=> p_sharing_access_code

    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OBJECTIVE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_objective
    --
  end;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_obj_ins.ins
 (p_effective_date              => l_effective_date,
  p_business_group_id		=> p_business_group_id,
  p_name                        => p_name,
  p_target_date                 => l_target_date,
  p_start_date                  => l_start_date,
  p_owning_person_id            => p_owning_person_id,
  p_achievement_date            => l_achievement_date,
  p_detail                      => p_detail,
  p_comments                    => p_comments,
  p_success_criteria            => p_success_criteria,
  p_appraisal_id                => p_appraisal_id,
  p_attribute_category          => p_attribute_category,
  p_attribute1                  => p_attribute1,
  p_attribute2                  => p_attribute2,
  p_attribute3                  => p_attribute3,
  p_attribute4                  => p_attribute4,
  p_attribute5                  => p_attribute5,
  p_attribute6                  => p_attribute6,
  p_attribute7                  => p_attribute7,
  p_attribute8                  => p_attribute8,
  p_attribute9                  => p_attribute9,
  p_attribute10                 => p_attribute10,
  p_attribute11                 => p_attribute11,
  p_attribute12                 => p_attribute12,
  p_attribute13                 => p_attribute13,
  p_attribute14                 => p_attribute14,
  p_attribute15                 => p_attribute15,
  p_attribute16                 => p_attribute16,
  p_attribute17                 => p_attribute17,
  p_attribute18                 => p_attribute18,
  p_attribute19                 => p_attribute19,
  p_attribute20                 => p_attribute20,

     p_attribute21                   => p_attribute21,
     p_attribute22                   => p_attribute22,
     p_attribute23                   => p_attribute23,
     p_attribute24                   => p_attribute24,
     p_attribute25                   => p_attribute25,
     p_attribute26                   => p_attribute26,
     p_attribute27                   => p_attribute27,
     p_attribute28                   => p_attribute28,
     p_attribute29                   => p_attribute29,
     p_attribute30                   => p_attribute30,

     p_scorecard_id                     => p_scorecard_id,
     p_copied_from_library_id		=> p_copied_from_library_id,
     p_copied_from_objective_id		=> p_copied_from_objective_id,
     p_aligned_with_objective_id	=> p_aligned_with_objective_id,

     p_next_review_date			=> p_next_review_date,
     p_group_code			=> p_group_code,
     p_priority_code			=> p_priority_code,
     p_appraise_flag			=> p_appraise_flag,
     p_verified_flag			=> p_verified_flag,

     p_target_value			=> p_target_value,
     p_actual_value			=> p_actual_value,
     p_weighting_percent		=> p_weighting_percent,
     p_complete_percent			=> p_complete_percent,
     p_uom_code				=> p_uom_code,

     p_measurement_style_code		=> p_measurement_style_code,
     p_measure_name			=> p_measure_name,
     p_measure_type_code		=> p_measure_type_code,
     p_measure_comments 		=> p_measure_comments ,
     p_sharing_access_code		=> p_sharing_access_code,

     p_weighting_over_100_warning    => l_weighting_over_100_warning,
     p_weighting_appraisal_warning   => l_weighting_appraisal_warning,

  p_objective_id                => l_objective_id,
  p_object_version_number       => l_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_objective
    --
  hr_objectives_bk1.create_objective_a
    (
     p_effective_date               => l_effective_date,
     p_business_group_id            => p_business_group_id,
     p_name                         => p_name,
     p_start_date                   => l_start_date,
     p_owning_person_id             => p_owning_person_id,
     p_target_date                  => l_target_date,
     p_achievement_date             => l_achievement_date,
     p_detail                       => p_detail,
     p_comments                     => p_comments,
     p_success_criteria             => p_success_criteria,
     p_appraisal_id                 => p_appraisal_id,
     p_attribute_category           => p_attribute_category,
     p_attribute1                   => p_attribute1,
     p_attribute2                   => p_attribute2,
     p_attribute3                   => p_attribute3,
     p_attribute4                   => p_attribute4,
     p_attribute5                   => p_attribute5,
     p_attribute6                   => p_attribute6,
     p_attribute7                   => p_attribute7,
     p_attribute8                   => p_attribute8,
     p_attribute9                   => p_attribute9,
     p_attribute10                  => p_attribute10,
     p_attribute11                  => p_attribute11,
     p_attribute12                  => p_attribute12,
     p_attribute13                  => p_attribute13,
     p_attribute14                  => p_attribute14,
     p_attribute15                  => p_attribute15,
     p_attribute16                  => p_attribute16,
     p_attribute17                  => p_attribute17,
     p_attribute18                  => p_attribute18,
     p_attribute19                  => p_attribute19,
     p_attribute20                  => p_attribute20,

     p_attribute21                   => p_attribute21,
     p_attribute22                   => p_attribute22,
     p_attribute23                   => p_attribute23,
     p_attribute24                   => p_attribute24,
     p_attribute25                   => p_attribute25,
     p_attribute26                   => p_attribute26,
     p_attribute27                   => p_attribute27,
     p_attribute28                   => p_attribute28,
     p_attribute29                   => p_attribute29,
     p_attribute30                   => p_attribute30,

     p_scorecard_id                     => p_scorecard_id,
     p_copied_from_library_id		=> p_copied_from_library_id,
     p_copied_from_objective_id		=> p_copied_from_objective_id,
     p_aligned_with_objective_id	=> p_aligned_with_objective_id,

     p_next_review_date			=> p_next_review_date,
     p_group_code			=> p_group_code,
     p_priority_code			=> p_priority_code,
     p_appraise_flag			=> p_appraise_flag,
     p_verified_flag			=> p_verified_flag,

     p_target_value			=> p_target_value,
     p_actual_value			=> p_actual_value,
     p_weighting_percent		=> p_weighting_percent,
     p_complete_percent			=> p_complete_percent,
     p_uom_code				=> p_uom_code,

     p_measurement_style_code		=> p_measurement_style_code,
     p_measure_name			=> p_measure_name,
     p_measure_type_code		=> p_measure_type_code,
     p_measure_comments 		=> p_measure_comments ,
     p_sharing_access_code		=> p_sharing_access_code,

     p_weighting_over_100_warning    => l_weighting_over_100_warning,
     p_weighting_appraisal_warning   => l_weighting_appraisal_warning,

     p_objective_id                 => l_objective_id,
     p_object_version_number        => l_object_version_number
    );
 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OBJECTIVE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_objective
    --
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
  p_objective_id           := l_objective_id;
  p_object_version_number  := l_object_version_number;
  p_weighting_over_100_warning  := l_weighting_over_100_warning;
  p_weighting_appraisal_warning := l_weighting_appraisal_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_objective;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_objective_id           := null;
    p_object_version_number  := null;
    p_weighting_over_100_warning  := l_weighting_over_100_warning;
    p_weighting_appraisal_warning := l_weighting_appraisal_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO create_objective;
    --
    -- set in out parameters and set out parameters
    --
    p_objective_id           := null;
    p_object_version_number  := null;
    p_weighting_over_100_warning  := null;
    p_weighting_appraisal_warning := null;
  --
  raise;
  --
end create_objective;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< update_objective >-----------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_objective
 (p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_objective_id                 in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_target_date                  in date             default hr_api.g_date,
  p_start_date                   in date             default hr_api.g_date,
  p_achievement_date             in date             default hr_api.g_date,
  p_detail                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_success_criteria             in varchar2         default hr_api.g_varchar2,
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

  p_scorecard_id                 in number           default hr_api.g_number,
  p_copied_from_library_id       in number           default hr_api.g_number,
  p_copied_from_objective_id     in number           default hr_api.g_number,
  p_aligned_with_objective_id    in number           default hr_api.g_number,

  p_next_review_date             in date             default hr_api.g_date,
  p_group_code                   in varchar2         default hr_api.g_varchar2,
  p_priority_code                in varchar2         default hr_api.g_varchar2,
  p_appraise_flag                in varchar2         default hr_api.g_varchar2,
  p_verified_flag                in varchar2         default hr_api.g_varchar2,

  p_target_value                 in number           default hr_api.g_number,
  p_actual_value                 in number           default hr_api.g_number,
  p_weighting_percent            in number           default hr_api.g_number,
  p_complete_percent             in number           default hr_api.g_number,
  p_uom_code                     in varchar2         default hr_api.g_varchar2,

  p_measurement_style_code       in varchar2         default hr_api.g_varchar2,
  p_measure_name                 in varchar2         default hr_api.g_varchar2,
  p_measure_type_code            in varchar2         default hr_api.g_varchar2,
  p_measure_comments             in varchar2         default hr_api.g_varchar2,
  p_sharing_access_code          in varchar2         default hr_api.g_varchar2,

  p_weighting_over_100_warning       out nocopy   boolean,
  p_weighting_appraisal_warning      out nocopy   boolean,
  p_appraisal_id                 in number           default hr_api.g_number

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                	varchar2(72) := g_package||'update_objective';
  l_object_version_number	per_objectives.object_version_number%TYPE;
  l_ovn per_objectives.object_version_number%TYPE := p_object_version_number;
  l_effective_date              date;
  l_start_date                  per_objectives.start_date%TYPE;
  l_target_date                 per_objectives.target_date%TYPE;
  l_achievement_date            per_objectives.achievement_date%TYPE;
  l_weighting_over_100_warning  boolean := false;
  l_weighting_appraisal_warning boolean := false;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_objective;
  --
  -- Process Logic
  --
  -- Initialise local variables as appropriate
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date
  --
  l_effective_date        := trunc(p_effective_date);
  l_start_date            := trunc(p_start_date);
  l_target_date           := trunc(p_target_date);
  l_achievement_date      := trunc(p_achievement_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_objective
    --
  hr_objectives_bk2.update_objective_b
    (
     p_effective_date               => l_effective_date,
     p_objective_id                 => p_objective_id,
     p_object_version_number        => p_object_version_number,
     p_name                         => p_name,
     p_target_date                  => l_target_date,
     p_start_date                   => l_start_date,
     p_achievement_date             => l_achievement_date,
     p_detail                       => p_detail,
     p_comments                     => p_comments,
     p_success_criteria             => p_success_criteria,
     p_attribute_category           => p_attribute_category,
     p_attribute1                   => p_attribute1,
     p_attribute2                   => p_attribute2,
     p_attribute3                   => p_attribute3,
     p_attribute4                   => p_attribute4,
     p_attribute5                   => p_attribute5,
     p_attribute6                   => p_attribute6,
     p_attribute7                   => p_attribute7,
     p_attribute8                   => p_attribute8,
     p_attribute9                   => p_attribute9,
     p_attribute10                  => p_attribute10,
     p_attribute11                  => p_attribute11,
     p_attribute12                  => p_attribute12,
     p_attribute13                  => p_attribute13,
     p_attribute14                  => p_attribute14,
     p_attribute15                  => p_attribute15,
     p_attribute16                  => p_attribute16,
     p_attribute17                  => p_attribute17,
     p_attribute18                  => p_attribute18,
     p_attribute19                  => p_attribute19,
     p_attribute20                  => p_attribute20,

     p_attribute21                   => p_attribute21,
     p_attribute22                   => p_attribute22,
     p_attribute23                   => p_attribute23,
     p_attribute24                   => p_attribute24,
     p_attribute25                   => p_attribute25,
     p_attribute26                   => p_attribute26,
     p_attribute27                   => p_attribute27,
     p_attribute28                   => p_attribute28,
     p_attribute29                   => p_attribute29,
     p_attribute30                   => p_attribute30,

     p_scorecard_id                     => p_scorecard_id,
     p_copied_from_library_id		=> p_copied_from_library_id,
     p_copied_from_objective_id		=> p_copied_from_objective_id,
     p_aligned_with_objective_id	=> p_aligned_with_objective_id,

     p_next_review_date			=> p_next_review_date,
     p_group_code			=> p_group_code,
     p_priority_code			=> p_priority_code,
     p_appraise_flag			=> p_appraise_flag,
     p_verified_flag			=> p_verified_flag,

     p_target_value			=> p_target_value,
     p_actual_value			=> p_actual_value,
     p_weighting_percent		=> p_weighting_percent,
     p_complete_percent			=> p_complete_percent,
     p_uom_code				=> p_uom_code,

     p_measurement_style_code		=> p_measurement_style_code,
     p_measure_name			=> p_measure_name,
     p_measure_type_code		=> p_measure_type_code,
     p_measure_comments 		=> p_measure_comments ,
     p_sharing_access_code		=> p_sharing_access_code ,
     p_appraisal_id                     => p_appraisal_id

    );
--
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OBJECTIVE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_objective
    --
  end;
--
  hr_utility.set_location(l_proc, 6);
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  per_obj_upd.upd
 (p_effective_date              => l_effective_date,
  p_objective_id		=> p_objective_id,
  p_object_version_number	=> l_object_version_number,
  p_name                        => p_name,
  p_target_date                 => l_target_date,
  p_start_date                  => l_start_date,
  p_achievement_date            => l_achievement_date,
  p_detail                      => p_detail,
  p_comments                    => p_comments,
  p_success_criteria            => p_success_criteria,
  p_attribute_category          => p_attribute_category,
  p_attribute1                  => p_attribute1,
  p_attribute2                  => p_attribute2,
  p_attribute3                  => p_attribute3,
  p_attribute4                  => p_attribute4,
  p_attribute5                  => p_attribute5,
  p_attribute6                  => p_attribute6,
  p_attribute7                  => p_attribute7,
  p_attribute8                  => p_attribute8,
  p_attribute9                  => p_attribute9,
  p_attribute10                 => p_attribute10,
  p_attribute11                 => p_attribute11,
  p_attribute12                 => p_attribute12,
  p_attribute13                 => p_attribute13,
  p_attribute14                 => p_attribute14,
  p_attribute15                 => p_attribute15,
  p_attribute16                 => p_attribute16,
  p_attribute17                 => p_attribute17,
  p_attribute18                 => p_attribute18,
  p_attribute19                 => p_attribute19,
  p_attribute20                 => p_attribute20,

     p_attribute21                   => p_attribute21,
     p_attribute22                   => p_attribute22,
     p_attribute23                   => p_attribute23,
     p_attribute24                   => p_attribute24,
     p_attribute25                   => p_attribute25,
     p_attribute26                   => p_attribute26,
     p_attribute27                   => p_attribute27,
     p_attribute28                   => p_attribute28,
     p_attribute29                   => p_attribute29,
     p_attribute30                   => p_attribute30,

     p_scorecard_id                     => p_scorecard_id,
     p_copied_from_library_id		=> p_copied_from_library_id,
     p_copied_from_objective_id		=> p_copied_from_objective_id,
     p_aligned_with_objective_id	=> p_aligned_with_objective_id,

     p_next_review_date			=> p_next_review_date,
     p_group_code			=> p_group_code,
     p_priority_code			=> p_priority_code,
     p_appraise_flag			=> p_appraise_flag,
     p_verified_flag			=> p_verified_flag,

     p_target_value			=> p_target_value,
     p_actual_value			=> p_actual_value,
     p_weighting_percent		=> p_weighting_percent,
     p_complete_percent			=> p_complete_percent,
     p_uom_code				=> p_uom_code,

     p_measurement_style_code		=> p_measurement_style_code,
     p_measure_name			=> p_measure_name,
     p_measure_type_code		=> p_measure_type_code,
     p_measure_comments 		=> p_measure_comments ,
     p_sharing_access_code		=> p_sharing_access_code,

     p_weighting_over_100_warning    => l_weighting_over_100_warning,
     p_weighting_appraisal_warning   => l_weighting_appraisal_warning,
     p_appraisal_id                  => p_appraisal_id

  );
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_objective
    --
  hr_objectives_bk2.update_objective_a
    (p_effective_date               => l_effective_date,
     p_objective_id                 => p_objective_id,
     p_object_version_number        => l_object_version_number,
     p_name                         => p_name,
     p_target_date                  => l_target_date,
     p_start_date                   => l_start_date,
     p_achievement_date             => l_achievement_date,
     p_detail                       => p_detail,
     p_comments                     => p_comments,
     p_success_criteria             => p_success_criteria,
     p_attribute_category           => p_attribute_category,
     p_attribute1                   => p_attribute1,
     p_attribute2                   => p_attribute2,
     p_attribute3                   => p_attribute3,
     p_attribute4                   => p_attribute4,
     p_attribute5                   => p_attribute5,
     p_attribute6                   => p_attribute6,
     p_attribute7                   => p_attribute7,
     p_attribute8                   => p_attribute8,
     p_attribute9                   => p_attribute9,
     p_attribute10                  => p_attribute10,
     p_attribute11                  => p_attribute11,
     p_attribute12                  => p_attribute12,
     p_attribute13                  => p_attribute13,
     p_attribute14                  => p_attribute14,
     p_attribute15                  => p_attribute15,
     p_attribute16                  => p_attribute16,
     p_attribute17                  => p_attribute17,
     p_attribute18                  => p_attribute18,
     p_attribute19                  => p_attribute19,
     p_attribute20                  => p_attribute20,

     p_attribute21                   => p_attribute21,
     p_attribute22                   => p_attribute22,
     p_attribute23                   => p_attribute23,
     p_attribute24                   => p_attribute24,
     p_attribute25                   => p_attribute25,
     p_attribute26                   => p_attribute26,
     p_attribute27                   => p_attribute27,
     p_attribute28                   => p_attribute28,
     p_attribute29                   => p_attribute29,
     p_attribute30                   => p_attribute30,

     p_scorecard_id                     => p_scorecard_id,
     p_copied_from_library_id		=> p_copied_from_library_id,
     p_copied_from_objective_id		=> p_copied_from_objective_id,
     p_aligned_with_objective_id	=> p_aligned_with_objective_id,

     p_next_review_date			=> p_next_review_date,
     p_group_code			=> p_group_code,
     p_priority_code			=> p_priority_code,
     p_appraise_flag			=> p_appraise_flag,
     p_verified_flag			=> p_verified_flag,

     p_target_value			=> p_target_value,
     p_actual_value			=> p_actual_value,
     p_weighting_percent		=> p_weighting_percent,
     p_complete_percent			=> p_complete_percent,
     p_uom_code				=> p_uom_code,

     p_measurement_style_code		=> p_measurement_style_code,
     p_measure_name			=> p_measure_name,
     p_measure_type_code		=> p_measure_type_code,
     p_measure_comments 		=> p_measure_comments ,
     p_sharing_access_code		=> p_sharing_access_code,

     p_weighting_over_100_warning    => l_weighting_over_100_warning,
     p_weighting_appraisal_warning   => l_weighting_appraisal_warning,
     p_appraisal_id                  => p_appraisal_id

     );
--
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OBJECTIVE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_objective
    --
  end;
--
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments. l_object_version_number now has the new
  -- object version number as the update was successful
  --
  p_object_version_number  := l_object_version_number;
  p_weighting_over_100_warning    := l_weighting_over_100_warning;
  p_weighting_appraisal_warning   := l_weighting_appraisal_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_objective;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_ovn;
    p_weighting_over_100_warning    := l_weighting_over_100_warning;
    p_weighting_appraisal_warning   := l_weighting_appraisal_warning;

    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_objective;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    p_weighting_over_100_warning    := l_weighting_over_100_warning;
    p_weighting_appraisal_warning   := l_weighting_appraisal_warning;
    --
    raise;
--
end update_objective;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< delete_objective> ----------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_objective
(p_validate                           in boolean default false,
 p_objective_id                       in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --

  l_objpr       per_prt_bus.r_objpr_rec;
--bug 7339854
CURSOR csr_objpr
           ( p_objective_id per_objectives.objective_id%TYPE
           )
    IS
    SELECT performance_rating_id, object_version_number
    FROM   per_performance_ratings
    WHERE  objective_id    = p_objective_id;

  --
  --
  l_proc        varchar2(72) := g_package||'delete_objective';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_objective;
  --
  begin
    --
    -- Start of API User Hook for the before hook delete_objective
    --
    hr_objectives_bk3.delete_objective_b
      (p_objective_id                       => p_objective_id,
       p_object_version_number              => p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
	(p_module_name	=> 'DELETE_OBJECTIVE',
	 p_hook_type	=> 'BP'
	);
  end;
    --
    -- End of API User Hook for the before hook of delete_objective
    --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  -- flemonni added cascade delete of obj performance rating
  --
  -- get an associated pr for the given obj id
  -- supply this to the pr api (p_validate = TRUE)
  -- delete it so that obj delete succeeds
  -- allow this rollback to undo the delete if necessary
  --
  /*l_objpr :=
    per_prt_bus.Get_PR_Data
      ( p_objective_id => p_objective_ID
      );
  IF l_objpr.performance_rating_id IS NOT NULL THEN*/

--bug 7339854
 FOR i in csr_objpr(p_objective_id)
  LOOP
    -- delete the performance rating
    hr_performance_ratings_api.delete_performance_rating
      ( p_validate => FALSE
      , p_performance_rating_id => i.performance_rating_id
      , p_object_version_number => i.object_version_number
      );

END LOOP;
--bug 7339854
 /* ELSE
    -- objective does not have a performance rating
    NULL;
  END IF;*/
  --
  -- now delete the objective itself
  --
     per_obj_del.del
     (p_objective_id			=> p_objective_id
     ,p_object_version_number 		=> p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  begin
    --
    -- Start of API User Hook for the after hook delete_objective
    --
    hr_objectives_bk3.delete_objective_a
      (p_objective_id                       => p_objective_id,
       p_object_version_number              => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
	(p_module_name	=> 'DELETE_OBJECTIVE',
	 p_hook_type	=> 'AP'
	);
  end;
    --
    -- End of API User Hook for the after hook delete_objective
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
    ROLLBACK TO delete_objective;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
  ROLLBACK TO delete_objective;
    --
  raise;
    --
end delete_objective;
--
end hr_objectives_api;

/
