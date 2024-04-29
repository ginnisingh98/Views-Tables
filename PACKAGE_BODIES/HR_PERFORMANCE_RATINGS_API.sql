--------------------------------------------------------
--  DDL for Package Body HR_PERFORMANCE_RATINGS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERFORMANCE_RATINGS_API" as
/* $Header: peprtapi.pkb 120.1 2006/02/13 14:12:56 vbala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_performance_ratings_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< <create_performance_rating> >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_performance_rating
  (p_validate                      in     boolean     default false
  ,p_effective_date                in     date
  ,p_appraisal_id                  in     number
  ,p_person_id                     in     number default null
  ,p_objective_id                  in     number
  ,p_performance_level_id          in     number      default null
  ,p_comments                      in     varchar2    default null
  ,p_attribute_category            in     varchar2    default null
  ,p_attribute1                    in     varchar2    default null
  ,p_attribute2                    in     varchar2    default null
  ,p_attribute3                    in     varchar2    default null
  ,p_attribute4                    in     varchar2    default null
  ,p_attribute5                    in     varchar2    default null
  ,p_attribute6                    in     varchar2    default null
  ,p_attribute7                    in     varchar2    default null
  ,p_attribute8                    in     varchar2    default null
  ,p_attribute9                    in     varchar2    default null
  ,p_attribute10                   in     varchar2    default null
  ,p_attribute11                   in     varchar2    default null
  ,p_attribute12                   in     varchar2    default null
  ,p_attribute13                   in     varchar2    default null
  ,p_attribute14                   in     varchar2    default null
  ,p_attribute15                   in     varchar2    default null
  ,p_attribute16                   in     varchar2    default null
  ,p_attribute17                   in     varchar2    default null
  ,p_attribute18                   in     varchar2    default null
  ,p_attribute19                   in     varchar2    default null
  ,p_attribute20                   in     varchar2    default null
  ,p_performance_rating_id            out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_appr_line_score               in     number      default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                     varchar2(72) := g_package||'create_performance_rating';
  l_performance_rating_id    per_performance_ratings.performance_rating_id%TYPE;
  l_object_version_number    per_performance_ratings.object_version_number%TYPE;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint create_performance_rating;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_performance_ratings_bk1.create_performance_rating_b	(
         p_effective_date         => p_effective_date
        ,p_appraisal_id           => p_appraisal_id
        ,p_objective_id           => p_objective_id
        ,p_performance_level_id   => p_performance_level_id
        ,p_person_id              => p_person_id
        ,p_comments               => p_comments
        ,p_attribute_category     => p_attribute_category
        ,p_attribute1             => p_attribute1
        ,p_attribute2             => p_attribute2
        ,p_attribute3             => p_attribute3
        ,p_attribute4             => p_attribute4
        ,p_attribute5             => p_attribute5
        ,p_attribute6             => p_attribute6
        ,p_attribute7             => p_attribute7
        ,p_attribute8             => p_attribute8
        ,p_attribute9             => p_attribute9
        ,p_attribute10            => p_attribute10
        ,p_attribute11            => p_attribute11
        ,p_attribute12            => p_attribute12
        ,p_attribute13            => p_attribute13
        ,p_attribute14            => p_attribute14
        ,p_attribute15            => p_attribute15
        ,p_attribute16            => p_attribute16
        ,p_attribute17            => p_attribute17
        ,p_attribute18            => p_attribute18
        ,p_attribute19            => p_attribute19
        ,p_attribute20            => p_attribute20
	,p_appr_line_score        => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_performance_rating',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  per_prt_ins.ins
     (p_validate               => p_validate
     ,p_effective_date         => p_effective_date
     ,p_appraisal_id           => p_appraisal_id
     ,p_person_id              => p_person_id
     ,p_objective_id           => p_objective_id
     ,p_performance_level_id   => p_performance_level_id
     ,p_comments               => p_comments
     ,p_attribute_category     => p_attribute_category
     ,p_attribute1             => p_attribute1
     ,p_attribute2             => p_attribute2
     ,p_attribute3             => p_attribute3
     ,p_attribute4             => p_attribute4
     ,p_attribute5             => p_attribute5
     ,p_attribute6             => p_attribute6
     ,p_attribute7             => p_attribute7
     ,p_attribute8             => p_attribute8
     ,p_attribute9             => p_attribute9
     ,p_attribute10            => p_attribute10
     ,p_attribute11            => p_attribute11
     ,p_attribute12            => p_attribute12
     ,p_attribute13            => p_attribute13
     ,p_attribute14            => p_attribute14
     ,p_attribute15            => p_attribute15
     ,p_attribute16            => p_attribute16
     ,p_attribute17            => p_attribute17
     ,p_attribute18            => p_attribute18
     ,p_attribute19            => p_attribute19
     ,p_attribute20            => p_attribute20
     ,p_performance_rating_id  => l_performance_rating_id
     ,p_object_version_number  => l_object_version_number
     ,p_appr_line_score        => p_appr_line_score
  );

  hr_utility.set_location(l_proc, 40);
  --
  -- Call After Process User Hook
  --
  begin
	hr_performance_ratings_bk1.create_performance_rating_a	(
         p_performance_rating_id  => l_performance_rating_id
        ,p_object_version_number  => l_object_version_number
        ,p_effective_date         => p_effective_date
        ,p_appraisal_id           => p_appraisal_id
        ,p_person_id              => p_person_id
        ,p_objective_id           => p_objective_id
        ,p_performance_level_id   => p_performance_level_id
        ,p_comments               => p_comments
        ,p_attribute_category     => p_attribute_category
        ,p_attribute1             => p_attribute1
        ,p_attribute2             => p_attribute2
        ,p_attribute3             => p_attribute3
        ,p_attribute4             => p_attribute4
        ,p_attribute5             => p_attribute5
        ,p_attribute6             => p_attribute6
        ,p_attribute7             => p_attribute7
        ,p_attribute8             => p_attribute8
        ,p_attribute9             => p_attribute9
        ,p_attribute10            => p_attribute10
        ,p_attribute11            => p_attribute11
        ,p_attribute12            => p_attribute12
        ,p_attribute13            => p_attribute13
        ,p_attribute14            => p_attribute14
        ,p_attribute15            => p_attribute15
        ,p_attribute16            => p_attribute16
        ,p_attribute17            => p_attribute17
        ,p_attribute18            => p_attribute18
        ,p_attribute19            => p_attribute19
        ,p_attribute20            => p_attribute20
	,p_appr_line_score        => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_performance_rating',
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
  p_performance_rating_id  := l_performance_rating_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_performance_rating;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_performance_rating_id  := null;
    p_object_version_number  := null;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_performance_rating_id  := null;
    p_object_version_number  := null;
    ROLLBACK TO create_performance_rating;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
end create_performance_rating;
--
-- ----------------------------------------------------------------------------
-- |---------------------< <delete_performance_rating> >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_performance_rating
  (p_validate                      in     boolean  default false
  ,p_performance_rating_id         in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_performance_rating';
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint delete_performance_rating;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_performance_ratings_bk3.delete_performance_rating_b
		(
		p_performance_rating_id   =>	p_performance_rating_id,
		p_object_version_number   =>	p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_performance_rating',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Delete the performance_rating
  --
  per_prt_del.del
  (p_validate			=> p_validate
  ,p_performance_rating_id	=> p_performance_rating_id
  ,p_object_version_number	=> p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
	hr_performance_ratings_bk3.delete_performance_rating_a	(
		p_performance_rating_id   =>	p_performance_rating_id,
		p_object_version_number   =>	p_object_version_number
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_performance_rating',
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
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_performance_rating;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_performance_rating;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
--
end delete_performance_rating;
--
-- ----------------------------------------------------------------------------
-- |---------------------< <update_performance_rating> >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_performance_rating
  (p_validate                      in     boolean     default false
  ,p_effective_date                in     date
  ,p_performance_rating_id         in     number
  ,p_person_id                     in     number default null
  ,p_object_version_number         in out nocopy number
  ,p_appraisal_id                  in     number      default hr_api.g_number
  ,p_objective_id                  in     number      default hr_api.g_number
  ,p_performance_level_id          in     number      default hr_api.g_number
  ,p_comments                      in     varchar2    default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2    default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2    default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2    default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2    default hr_api.g_varchar2
  ,p_appr_line_score               in     number      default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'update_performance_rating';
  l_object_version_number    per_performance_ratings.object_version_number%TYPE;
  l_temp_ovn                 number       := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_performance_rating;
  --
  -- Call Before Process User Hook
  --
  begin
	hr_performance_ratings_bk2.update_performance_rating_b	(
         p_effective_date           => p_effective_date
        ,p_performance_rating_id    => p_performance_rating_id
        ,p_object_version_number    => p_object_version_number
        ,p_appraisal_id             => p_appraisal_id
        ,p_person_id                => p_person_id
        ,p_objective_id             => p_objective_id
        ,p_performance_level_id     => p_performance_level_id
        ,p_comments                 => p_comments
        ,p_attribute_category       => p_attribute_category
        ,p_attribute1               => p_attribute1
        ,p_attribute2               => p_attribute2
        ,p_attribute3               => p_attribute3
        ,p_attribute4               => p_attribute4
        ,p_attribute5               => p_attribute5
        ,p_attribute6               => p_attribute6
        ,p_attribute7               => p_attribute7
        ,p_attribute8               => p_attribute8
        ,p_attribute9               => p_attribute9
        ,p_attribute10              => p_attribute10
        ,p_attribute11              => p_attribute11
        ,p_attribute12              => p_attribute12
        ,p_attribute13              => p_attribute13
        ,p_attribute14              => p_attribute14
        ,p_attribute15              => p_attribute15
        ,p_attribute16              => p_attribute16
        ,p_attribute17              => p_attribute17
        ,p_attribute18              => p_attribute18
        ,p_attribute19              => p_attribute19
        ,p_attribute20              => p_attribute20
	,p_appr_line_score          => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_performance_rating',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_prt_upd.upd
     (p_validate                 => p_validate
     ,p_effective_date           => p_effective_date
     ,p_performance_rating_id    => p_performance_rating_id
     ,p_object_version_number    => l_object_version_number
     ,p_performance_level_id     => p_performance_level_id
     ,p_person_id                => p_person_id
     ,p_comments                 => p_comments
     ,p_attribute_category       => p_attribute_category
     ,p_attribute1               => p_attribute1
     ,p_attribute2               => p_attribute2
     ,p_attribute3               => p_attribute3
     ,p_attribute4               => p_attribute4
     ,p_attribute5               => p_attribute5
     ,p_attribute6               => p_attribute6
     ,p_attribute7               => p_attribute7
     ,p_attribute8               => p_attribute8
     ,p_attribute9               => p_attribute9
     ,p_attribute10              => p_attribute10
     ,p_attribute11              => p_attribute11
     ,p_attribute12              => p_attribute12
     ,p_attribute13              => p_attribute13
     ,p_attribute14              => p_attribute14
     ,p_attribute15              => p_attribute15
     ,p_attribute16              => p_attribute16
     ,p_attribute17              => p_attribute17
     ,p_attribute18              => p_attribute18
     ,p_attribute19              => p_attribute19
     ,p_attribute20              => p_attribute20
     ,p_appr_line_score          => p_appr_line_score
     );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Call After Process User Hook
  --
  begin
	hr_performance_ratings_bk2.update_performance_rating_a	(
         p_effective_date           => p_effective_date
        ,p_performance_rating_id    => p_performance_rating_id
        ,p_object_version_number    => l_object_version_number
        ,p_appraisal_id             => p_appraisal_id
	,p_person_id                => p_person_id
        ,p_objective_id             => p_objective_id
        ,p_performance_level_id     => p_performance_level_id
        ,p_comments                 => p_comments
        ,p_attribute_category       => p_attribute_category
        ,p_attribute1               => p_attribute1
        ,p_attribute2               => p_attribute2
        ,p_attribute3               => p_attribute3
        ,p_attribute4               => p_attribute4
        ,p_attribute5               => p_attribute5
        ,p_attribute6               => p_attribute6
        ,p_attribute7               => p_attribute7
        ,p_attribute8               => p_attribute8
        ,p_attribute9               => p_attribute9
        ,p_attribute10              => p_attribute10
        ,p_attribute11              => p_attribute11
        ,p_attribute12              => p_attribute12
        ,p_attribute13              => p_attribute13
        ,p_attribute14              => p_attribute14
        ,p_attribute15              => p_attribute15
        ,p_attribute16              => p_attribute16
        ,p_attribute17              => p_attribute17
        ,p_attribute18              => p_attribute18
        ,p_attribute19              => p_attribute19
        ,p_attribute20              => p_attribute20
	,p_appr_line_score          => p_appr_line_score
	);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_performance_rating',
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
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_performance_rating;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_object_version_number := l_temp_ovn;
    ROLLBACK TO update_performance_rating;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
--
end update_performance_rating;
--
end hr_performance_ratings_api;

/
