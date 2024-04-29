--------------------------------------------------------
--  DDL for Package Body PER_REQUISITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REQUISITIONS_API" as
/* $Header: pereqapi.pkb 115.8 2002/12/10 15:37:17 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_REQUISITIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_REQUISITION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_requisition
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_date_from                     in	  date
  ,p_name			   in	  varchar2
  ,p_person_id                     in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_to                       in     date     default null
  ,p_description                   in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_requisition_id                out nocopy    number
  ,p_object_version_number         out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_requisition';
  l_requisition_id      number;
  l_object_version_number  number;
  l_date_from		date;
  l_date_to		date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_requisition;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_from := trunc(p_date_from);
  l_date_to   := trunc(p_date_to);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_REQUISITIONS_BK1.CREATE_REQUISITION_B
    (
       p_date_from                      => l_date_from
      ,p_business_group_id              => p_business_group_id
      ,p_name			        => p_name
      ,p_person_id                      => p_person_id
      ,p_comments                       => p_comments
      ,p_date_to                        => l_date_to
      ,p_description                    => p_description
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
      ,p_attribute21                    => p_attribute21
      ,p_attribute22                    => p_attribute22
      ,p_attribute23                    => p_attribute23
      ,p_attribute24                    => p_attribute24
      ,p_attribute25                    => p_attribute25
      ,p_attribute26                    => p_attribute26
      ,p_attribute27                    => p_attribute27
      ,p_attribute28                    => p_attribute28
      ,p_attribute29                    => p_attribute29
      ,p_attribute30                    => p_attribute30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REQUISITION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  per_req_ins.ins
  (
   p_requisition_id		    => l_requisition_id
  ,p_object_version_number          => l_object_version_number
  ,p_business_group_id              => p_business_group_id
  ,p_person_id                      => p_person_id
  ,p_date_from                      => l_date_from
  ,p_name			    => p_name
  ,p_comments                       => p_comments
  ,p_date_to                        => l_date_to
  ,p_description                    => p_description
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
  ,p_attribute20		    => p_attribute20
  );

  --
  -- Call After Process User Hook
  --
  begin
    PER_REQUISITIONS_BK1.CREATE_REQUISITION_A
      (
       p_business_group_id             => p_business_group_id
      ,p_requisition_id                => l_requisition_id
      ,p_object_version_number         => l_object_version_number
      ,p_date_from                     => l_date_from
      ,p_name			       => p_name
      ,p_person_id                     => p_person_id
      ,p_comments                      => p_comments
      ,p_date_to                       => l_date_to
      ,p_description                   => p_description
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
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
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REQUISITION'
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
  p_requisition_id         := l_requisition_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_REQUISITION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_requisition_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_requisition_id         := null;
    p_object_version_number  := null;
    rollback to CREATE_REQUISITION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_REQUISITION;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_REQUISITION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_requisition
  (p_validate                      in     boolean  default false
  ,p_requisition_id                in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in	  date     default hr_api.g_date
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_description                   in     varchar2 default hr_api.g_varchar2
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
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'update_requisition';
  l_object_version_number  number := p_object_version_number;
  l_date_from		   date;
  l_date_to		   date;
  l_temp_ovn               number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_requisition;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_from := trunc(p_date_from);
  l_date_to   := trunc(p_date_to);
  --
  -- Call Before Process User Hook
  --
  begin
    PER_REQUISITIONS_BK2.UPDATE_REQUISITION_b
      (
      p_requisition_id             => p_requisition_id
     ,p_object_version_number      => l_object_version_number
     ,p_date_from                  => l_date_from
     ,p_person_id                  => p_person_id
     ,p_comments                   => p_comments
     ,p_date_to			   => l_date_to
     ,p_description                => p_description
     ,p_attribute_category         => p_attribute_category
     ,p_attribute1                 => p_attribute1
     ,p_attribute2		   => p_attribute2
     ,p_attribute3                 => p_attribute3
     ,p_attribute4                 => p_attribute4
     ,p_attribute5                 => p_attribute5
     ,p_attribute6                 => p_attribute6
     ,p_attribute7                 => p_attribute7
     ,p_attribute8                 => p_attribute8
     ,p_attribute9                 => p_attribute9
     ,p_attribute10                => p_attribute10
     ,p_attribute11                => p_attribute11
     ,p_attribute12                => p_attribute12
     ,p_attribute13                => p_attribute13
     ,p_attribute14                => p_attribute14
     ,p_attribute15                => p_attribute15
     ,p_attribute16                => p_attribute16
     ,p_attribute17                => p_attribute17
     ,p_attribute18                => p_attribute18
     ,p_attribute19                => p_attribute19
     ,p_attribute20                => p_attribute20
     ,p_attribute21                => p_attribute21
     ,p_attribute22                => p_attribute22
     ,p_attribute23                => p_attribute23
     ,p_attribute24                => p_attribute24
     ,p_attribute25                => p_attribute25
     ,p_attribute26                => p_attribute26
     ,p_attribute27                => p_attribute27
     ,p_attribute28                => p_attribute28
     ,p_attribute29                => p_attribute29
     ,p_attribute30                => p_attribute30
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REQUISITION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

per_req_upd.upd
  (
   p_requisition_id                => p_requisition_id
  ,p_object_version_number         => l_object_version_number
  ,p_date_from                     => l_date_from
  ,p_person_id                     => p_person_id
  ,p_comments                      => p_comments
  ,p_date_to                       => l_date_to
  ,p_description                   => p_description
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
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
);



  --
  -- Call After Process User Hook
  --
  begin
    PER_REQUISITIONS_BK2.UPDATE_REQUISITION_a
      (
       p_requisition_id                => p_requisition_id
      ,p_object_version_number         => l_object_version_number
      ,p_date_from                     => l_date_from
      ,p_person_id                     => p_person_id
      ,p_comments                      => p_comments
      ,p_date_to                       => l_date_to
      ,p_description                   => p_description
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2		       => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
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
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REQUISITION'
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_REQUISITION;
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
    p_object_version_number := l_temp_ovn;
    rollback to UPDATE_REQUISITION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_REQUISITION;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_REQUISITION >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_requisition
  (p_validate                      in     boolean  default false
  ,p_requisition_id                in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_requisition';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_requisition;

  --
  -- Call Before Process User Hook
  --
  begin
    PER_REQUISITIONS_BK3.DELETE_REQUISITION_b
      (
       p_requisition_id             => p_requisition_id
      ,p_object_version_number      => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REQUISITION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

per_req_del.del
(
 p_requisition_id	 =>	p_requisition_id
,p_object_version_number =>     p_object_version_number
);


  --
  -- Call After Process User Hook
  --
  begin
    PER_REQUISITIONS_BK3.DELETE_REQUISITION_a
      (
       p_requisition_id                => p_requisition_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REQUISITION'
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
    rollback to DELETE_REQUISITION;
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
    rollback to DELETE_REQUISITION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_REQUISITION;
--
end PER_REQUISITIONS_API;

/
