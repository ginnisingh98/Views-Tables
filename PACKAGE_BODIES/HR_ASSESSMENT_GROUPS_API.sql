--------------------------------------------------------
--  DDL for Package Body HR_ASSESSMENT_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSESSMENT_GROUPS_API" as
/* $Header: peasrapi.pkb 115.3 99/07/17 18:43:44 porting ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_assessment_groups_api.';
--
-- ---------------------------------------------------------------------------
-- |---------------------< <create_assessment_group> >----------------------|
-- ---------------------------------------------------------------------------
--
procedure create_assessment_group
 (p_assessment_group_id           out 	number,
  p_name                         in 	varchar2,
  p_business_group_id            in 	number,
  p_comments                     in 	varchar2         default null,
  p_object_version_number        out 	number,
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
  p_validate                     in 	boolean   default false,
  p_effective_date               in 	date
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc               	varchar2(72) := g_package||'create_assessment_groups';
  l_assessment_group_id 		per_assessment_groups.assessment_group_id%TYPE;
  l_object_version_number	per_assessment_groups.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_assess_group;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_assessment_groups_bk1.create_assessment_group_b	(
         p_name                         =>   p_name
        ,p_business_group_id            =>   p_business_group_id
        ,p_comments                     =>   p_comments
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
        ,p_effective_date               =>   p_effective_date );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_assessment_group',
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
  per_asr_ins.ins (p_assessment_group_id =>   l_assessment_group_id
        ,p_name                         =>   p_name
        ,p_business_group_id            =>   p_business_group_id
        ,p_comments                     =>   p_comments
        ,p_object_version_number        =>   l_object_version_number
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
        ,p_validate                     =>   p_validate
        ,p_effective_date               =>   p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_assessment_groups_bk1.create_assessment_group_a	(
         p_assessment_group_id          =>   l_assessment_group_id
        ,p_object_version_number        =>   l_object_version_number
        ,p_name                         =>   p_name
        ,p_business_group_id            =>   p_business_group_id
        ,p_comments                     =>   p_comments
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
        ,p_effective_date               =>   p_effective_date );

      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_assessment_group',
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
  p_assessment_group_id          := l_assessment_group_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_assess_group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assessment_group_id          := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_assess_group;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_assessment_group;
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< <update_assessment_group> >-----------------------|
-- ---------------------------------------------------------------------------
--
procedure update_assessment_group
 (p_assessment_group_id           in number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out number,
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
  p_validate                     in boolean      default false,
  p_effective_date               in date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc               	varchar2(72) := g_package||'update_assessment_group';
  l_object_version_number      per_assessment_groups.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_assess_group;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_assessment_groups_bk2.update_assessment_group_b	(
           p_assessment_group_id          =>     p_assessment_group_id,
           p_name                         =>     p_name,
           p_comments                     =>     p_comments,
           p_object_version_number        =>     p_object_version_number,
           p_attribute_category           =>     p_attribute_category,
           p_attribute1                   =>     p_attribute1,
           p_attribute2                   =>     p_attribute2,
           p_attribute3                   =>     p_attribute3,
           p_attribute4                   =>     p_attribute4,
           p_attribute5                   =>     p_attribute5,
           p_attribute6                   =>     p_attribute6,
           p_attribute7                   =>     p_attribute7,
           p_attribute8                   =>     p_attribute8,
           p_attribute9                   =>     p_attribute9,
           p_attribute10                  =>     p_attribute10,
           p_attribute11                  =>     p_attribute11,
           p_attribute12                  =>     p_attribute12,
           p_attribute13                  =>     p_attribute13,
           p_attribute14                  =>     p_attribute14,
           p_attribute15                  =>     p_attribute15,
           p_attribute16                  =>     p_attribute16,
           p_attribute17                  =>     p_attribute17,
           p_attribute18                  =>     p_attribute18,
           p_attribute19                  =>     p_attribute19,
           p_attribute20                  =>     p_attribute20,
           p_effective_date               =>     p_effective_date		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_assessment_group',
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
  per_asr_upd.upd
  (p_assessment_group_id         =>     p_assessment_group_id,
  p_name                         =>     p_name,
  p_comments                     =>     p_comments,
  p_object_version_number        =>     l_object_version_number,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date
  );
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_assessment_groups_bk2.update_assessment_group_a	(
           p_assessment_group_id          =>     p_assessment_group_id,
           p_name                         =>     p_name,
           p_comments                     =>     p_comments,
           p_object_version_number        =>     l_object_version_number,
           p_attribute_category           =>     p_attribute_category,
           p_attribute1                   =>     p_attribute1,
           p_attribute2                   =>     p_attribute2,
           p_attribute3                   =>     p_attribute3,
           p_attribute4                   =>     p_attribute4,
           p_attribute5                   =>     p_attribute5,
           p_attribute6                   =>     p_attribute6,
           p_attribute7                   =>     p_attribute7,
           p_attribute8                   =>     p_attribute8,
           p_attribute9                   =>     p_attribute9,
           p_attribute10                  =>     p_attribute10,
           p_attribute11                  =>     p_attribute11,
           p_attribute12                  =>     p_attribute12,
           p_attribute13                  =>     p_attribute13,
           p_attribute14                  =>     p_attribute14,
           p_attribute15                  =>     p_attribute15,
           p_attribute16                  =>     p_attribute16,
           p_attribute17                  =>     p_attribute17,
           p_attribute18                  =>     p_attribute18,
           p_attribute19                  =>     p_attribute19,
           p_attribute20                  =>     p_attribute20,
           p_effective_date               =>     p_effective_date		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_assessment_group',
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
    ROLLBACK TO update_assess_group;
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
    ROLLBACK TO update_assess_group;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_assessment_group;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< delete_assessment_group >-----------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_assessment_group
(p_validate                           in boolean default false,
 p_assessment_group_id 		      in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_assessment_group';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_assess_group;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_assessment_groups_bk3.delete_assessment_group_b
		(
               p_assessment_group_id      =>  p_assessment_group_id
              ,p_object_version_number    =>  p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_assessment_group',
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
  per_asr_del.del
     (p_validate                 =>  FALSE
     ,p_assessment_group_id      =>  p_assessment_group_id
     ,p_object_version_number    =>  p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_assessment_groups_bk3.delete_assessment_group_a	(
               p_assessment_group_id      =>  p_assessment_group_id
              ,p_object_version_number    =>  p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_assessment_group',
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
    ROLLBACK TO delete_assess_group;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_assess_group;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_assessment_group;
--
end hr_assessment_groups_api;

/
