--------------------------------------------------------
--  DDL for Package Body HR_ASSESSMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSESSMENTS_API" as
/* $Header: peasnapi.pkb 115.8 2003/02/11 10:05:34 raranjan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_assessments_api.';
--
-- ---------------------------------------------------------------------------
-- |---------------------< <create_assessment> >-----------------------|
-- ---------------------------------------------------------------------------
--
procedure create_assessment
 (
  p_assessment_id                out nocopy number,
  p_assessment_type_id           in 	number,
  p_business_group_id            in 	number,
  p_person_id                    in 	number,
  p_assessment_group_id          in 	number           default null,
  p_assessment_period_start_date in 	date             default null,
  p_assessment_period_end_date   in 	date             default null,
  p_assessment_date              in 	date,
  p_assessor_person_id           in 	number,
  p_appraisal_id                 in 	number           default null,
  p_group_date                   in 	date	     	 default null,
  p_group_initiator_id           in 	number           default null,
  p_comments                     in 	varchar2         default null,
  p_total_score                  in 	number           default null,
  p_status                       in 	varchar2         default null,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_object_version_number        out nocopy 	number,
  p_validate                     in 	boolean   default false,
  p_effective_date               in 	date
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc               	varchar2(72) := g_package||'create_assessment';
  l_assessment_id 		per_assessments.assessment_id%TYPE;
  l_object_version_number	per_assessments.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_assess;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_assessments_bk1.create_assessment_b	(
         p_assessment_type_id           =>   p_assessment_type_id
        ,p_business_group_id            =>   p_business_group_id
        ,p_person_id                    =>   p_person_id
        ,p_assessment_group_id          =>   p_assessment_group_id
        ,p_assessment_period_start_date =>   p_assessment_period_start_date
        ,p_assessment_period_end_date   =>   p_assessment_period_end_date
        ,p_assessment_date              =>   p_assessment_date
        ,p_assessor_person_id           =>   p_assessor_person_id
        ,p_appraisal_id                 =>   p_appraisal_id
        ,p_group_date                   =>   p_group_date
        ,p_group_initiator_id           =>   p_group_initiator_id
        ,p_comments                     =>   p_comments
        ,p_total_score                  =>   p_total_score
        ,p_status                       =>   p_status
        ,p_attribute_category           =>   p_attribute_category
        ,p_attribute1                   =>   p_attribute1
        ,p_attribute2                   =>   p_attribute2
        ,p_attribute3                   =>   p_attribute3
        ,p_attribute4                   =>   p_attribute4
        ,p_attribute5                   =>   p_attribute5
        ,p_attribute6                   =>   p_attribute6
        ,p_attribute7                   =>   p_attribute7
        ,p_attribute8                   =>   p_attribute8
        ,p_attribute9                   =>   p_attribute9
        ,p_attribute10                  =>   p_attribute10
        ,p_attribute11                  =>   p_attribute11
        ,p_attribute12                  =>   p_attribute12
        ,p_attribute13                  =>   p_attribute13
        ,p_attribute14                  =>   p_attribute14
        ,p_attribute15                  =>   p_attribute14
        ,p_attribute16                  =>   p_attribute16
        ,p_attribute17                  =>   p_attribute17
        ,p_attribute18                  =>   p_attribute18
        ,p_attribute19                  =>   p_attribute19
        ,p_attribute20                  =>   p_attribute20
        ,p_effective_date               =>   p_effective_date  );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_assessment',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_asn_ins.ins (
         p_assessment_id                =>   l_assessment_id
        ,p_assessment_type_id           =>   p_assessment_type_id
        ,p_business_group_id            =>   p_business_group_id
        ,p_person_id                    =>   p_person_id
        ,p_assessment_group_id          =>   p_assessment_group_id
        ,p_assessment_period_start_date =>   p_assessment_period_start_date
        ,p_assessment_period_end_date   =>   p_assessment_period_end_date
        ,p_assessment_date              =>   p_assessment_date
        ,p_assessor_person_id           =>   p_assessor_person_id
        ,p_appraisal_id                 =>   p_appraisal_id
        ,p_group_date                   =>   p_group_date
        ,p_group_initiator_id           =>   p_group_initiator_id
        ,p_comments                     =>   p_comments
        ,p_total_score                  =>   p_total_score
        ,p_status                       =>   p_status
        ,p_attribute_category           =>   p_attribute_category
        ,p_attribute1                   =>   p_attribute1
        ,p_attribute2                   =>   p_attribute2
        ,p_attribute3                   =>   p_attribute3
        ,p_attribute4                   =>   p_attribute4
        ,p_attribute5                   =>   p_attribute5
        ,p_attribute6                   =>   p_attribute6
        ,p_attribute7                   =>   p_attribute7
        ,p_attribute8                   =>   p_attribute8
        ,p_attribute9                   =>   p_attribute9
        ,p_attribute10                  =>   p_attribute10
        ,p_attribute11                  =>   p_attribute11
        ,p_attribute12                  =>   p_attribute12
        ,p_attribute13                  =>   p_attribute13
        ,p_attribute14                  =>   p_attribute14
        ,p_attribute15                  =>   p_attribute14
        ,p_attribute16                  =>   p_attribute16
        ,p_attribute17                  =>   p_attribute17
        ,p_attribute18                  =>   p_attribute18
        ,p_attribute19                  =>   p_attribute19
        ,p_attribute20                  =>   p_attribute20
        ,p_object_version_number        =>   l_object_version_number
        ,p_validate                     =>   p_validate
        ,p_effective_date               =>   p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_assessments_bk1.create_assessment_a	(
         p_assessment_id                =>   l_assessment_id
        ,p_object_version_number        =>   l_object_version_number
        ,p_assessment_type_id           =>   p_assessment_type_id
        ,p_business_group_id            =>   p_business_group_id
        ,p_person_id                    =>   p_person_id
        ,p_assessment_group_id          =>   p_assessment_group_id
        ,p_assessment_period_start_date =>   p_assessment_period_start_date
        ,p_assessment_period_end_date   =>   p_assessment_period_end_date
        ,p_assessment_date              =>   p_assessment_date
        ,p_assessor_person_id           =>   p_assessor_person_id
        ,p_appraisal_id                 =>   p_appraisal_id
        ,p_group_date                   =>   p_group_date
        ,p_group_initiator_id           =>   p_group_initiator_id
        ,p_comments                     =>   p_comments
        ,p_total_score                  =>   p_total_score
        ,p_status                       =>   p_status
        ,p_attribute_category           =>   p_attribute_category
        ,p_attribute1                   =>   p_attribute1
        ,p_attribute2                   =>   p_attribute2
        ,p_attribute3                   =>   p_attribute3
        ,p_attribute4                   =>   p_attribute4
        ,p_attribute5                   =>   p_attribute5
        ,p_attribute6                   =>   p_attribute6
        ,p_attribute7                   =>   p_attribute7
        ,p_attribute8                   =>   p_attribute8
        ,p_attribute9                   =>   p_attribute9
        ,p_attribute10                  =>   p_attribute10
        ,p_attribute11                  =>   p_attribute11
        ,p_attribute12                  =>   p_attribute12
        ,p_attribute13                  =>   p_attribute13
        ,p_attribute14                  =>   p_attribute14
        ,p_attribute15                  =>   p_attribute14
        ,p_attribute16                  =>   p_attribute16
        ,p_attribute17                  =>   p_attribute17
        ,p_attribute18                  =>   p_attribute18
        ,p_attribute19                  =>   p_attribute19
        ,p_attribute20                  =>   p_attribute20
        ,p_effective_date               =>   p_effective_date  );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_assessment',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After process user hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_assessment_id          := l_assessment_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_assess;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assessment_id          := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_assess;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_assessment;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< <update_assessment> >------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_assessment
 (
  p_assessment_id                in number,
  p_assessment_type_id           in number           default hr_api.g_number,
  p_assessment_group_id          in number           default hr_api.g_number,
  p_assessment_period_start_date in date             default hr_api.g_date,
  p_assessment_period_end_date   in date             default hr_api.g_date,
  p_assessment_date              in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_total_score                  in number           default hr_api.g_number,
  p_status                       in varchar2         default hr_api.g_varchar2,
  --
  p_attribute_category           in varchar2    default hr_api.g_varchar2,
  p_attribute1                   in varchar2    default hr_api.g_varchar2,
  p_attribute2                   in varchar2    default hr_api.g_varchar2,
  p_attribute3                   in varchar2    default hr_api.g_varchar2,
  p_attribute4                   in varchar2    default hr_api.g_varchar2,
  p_attribute5                   in varchar2    default hr_api.g_varchar2,
  p_attribute6                   in varchar2    default hr_api.g_varchar2,
  p_attribute7                   in varchar2    default hr_api.g_varchar2,
  p_attribute8                   in varchar2    default hr_api.g_varchar2,
  p_attribute9                   in varchar2    default hr_api.g_varchar2,
  p_attribute10                  in varchar2    default hr_api.g_varchar2,
  p_attribute11                  in varchar2    default hr_api.g_varchar2,
  p_attribute12                  in varchar2    default hr_api.g_varchar2,
  p_attribute13                  in varchar2    default hr_api.g_varchar2,
  p_attribute14                  in varchar2    default hr_api.g_varchar2,
  p_attribute15                  in varchar2    default hr_api.g_varchar2,
  p_attribute16                  in varchar2    default hr_api.g_varchar2,
  p_attribute17                  in varchar2    default hr_api.g_varchar2,
  p_attribute18                  in varchar2    default hr_api.g_varchar2,
  p_attribute19                  in varchar2    default hr_api.g_varchar2,
  p_attribute20                  in varchar2    default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean      default false,
  p_effective_date               in date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               	varchar2(72) := g_package||'update_assessment';
  l_object_version_number      per_assessments.object_version_number%TYPE;
  --
  lv_object_version_number     per_assessments.object_version_number%TYPE := p_object_version_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_assess;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_assessments_bk2.update_assessment_b	(
         p_assessment_id                => p_assessment_id,
         p_assessment_type_id           => p_assessment_type_id,
         p_assessment_group_id          => p_assessment_group_id,
         p_assessment_period_start_date => p_assessment_period_start_date,
         p_assessment_period_end_date   => p_assessment_period_end_date,
         p_assessment_date              => p_assessment_date,
         p_comments                     => p_comments,
         p_total_score                  => p_total_score,
         p_status                       => p_status,
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
         p_object_version_number        => p_object_version_number,
         p_effective_date               => p_effective_date
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_assessment',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_asn_upd.upd
  (
     p_assessment_id                => p_assessment_id,
     p_assessment_type_id           => p_assessment_type_id,
     p_assessment_group_id          => p_assessment_group_id,
     p_assessment_period_start_date => p_assessment_period_start_date,
     p_assessment_period_end_date   => p_assessment_period_end_date,
     p_assessment_date              => p_assessment_date,
     p_comments                     => p_comments,
     p_total_score                  => p_total_score,
     p_status                       => p_status,
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
     p_object_version_number        => l_object_version_number,
     p_validate                     => p_validate,
     p_effective_date               => p_effective_date
  );
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_assessments_bk2.update_assessment_a	(
         p_assessment_id                => p_assessment_id,
         p_assessment_type_id           => p_assessment_type_id,
         p_assessment_group_id          => p_assessment_group_id,
         p_assessment_period_start_date => p_assessment_period_start_date,
         p_assessment_period_end_date   => p_assessment_period_end_date,
         p_assessment_date              => p_assessment_date,
         p_comments                     => p_comments,
         p_total_score                  => p_total_score,
         p_status                       => p_status,
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
         p_object_version_number        => l_object_version_number,
         p_effective_date               => p_effective_date
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_assessment',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_assess;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
     p_object_version_number  := lv_object_version_number;

    ROLLBACK TO update_assess;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_assessment;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< delete_assessment >-----------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_assessment
(p_validate                   in boolean default false,
 p_assessment_id 		      in number,
 p_object_version_number      in number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_assessment';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_assess;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_assessments_bk3.delete_assessment_b
		(
                p_assessment_id              => p_assessment_id
               ,p_object_version_number      => p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_assessment',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --  The check to see whether the assessment_type is being used by an
  --  assessment is done in the row handler
  --
  per_asn_del.del
     (p_validate                   => FALSE
     ,p_assessment_id              => p_assessment_id
     ,p_object_version_number      => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_assessments_bk3.delete_assessment_a	(
                p_assessment_id              => p_assessment_id
               ,p_object_version_number      => p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_assessment',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
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
    ROLLBACK TO delete_assess;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_assess;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_assessment;
--
end hr_assessments_api;

/
