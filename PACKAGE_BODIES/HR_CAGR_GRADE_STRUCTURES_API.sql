--------------------------------------------------------
--  DDL for Package Body HR_CAGR_GRADE_STRUCTURES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_GRADE_STRUCTURES_API" as
/* $Header: pegrsapi.pkb 115.3 2002/12/11 11:04:23 pkakar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_cagr_grade_structures_api.';
--
-- ----------------------------------------------------------------------------
-- |------- -------------< create_cagr_grade_structures >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_grade_structures
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_structure_id        out nocopy number
  ,p_collective_agreement_id        in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_id_flex_num                    in  number    default null
  ,p_dynamic_insert_allowed         in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_effective_date		    in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cagr_grade_structure_id per_cagr_grade_structures.cagr_grade_structure_id%TYPE;
  l_proc varchar2(72) := g_package||'create_cagr_grade_structures';
  l_object_version_number per_cagr_grade_structures.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_cagr_grade_structures;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_cagr_grade_structures
    --
    hr_cagr_grade_structures_bk1.create_cagr_grade_structures_b
      (
       p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_id_flex_num                    =>  p_id_flex_num
      ,p_dynamic_insert_allowed         =>  p_dynamic_insert_allowed
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date			=>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CAGR_GRADE_STRUCTURES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_cagr_grade_structures
    --
  end;
  --
  per_grs_ins.ins
    (
     p_cagr_grade_structure_id       => l_cagr_grade_structure_id
    ,p_collective_agreement_id       => p_collective_agreement_id
    ,p_object_version_number         => l_object_version_number
    ,p_id_flex_num                   => p_id_flex_num
    ,p_dynamic_insert_allowed        => p_dynamic_insert_allowed
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
    ,p_effective_date		     =>  trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_cagr_grade_structures
    --
    hr_cagr_grade_structures_bk1.create_cagr_grade_structures_a
      (
       p_cagr_grade_structure_id        =>  l_cagr_grade_structure_id
      ,p_collective_agreement_id        =>  p_collective_agreement_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_id_flex_num                    =>  p_id_flex_num
      ,p_dynamic_insert_allowed         =>  p_dynamic_insert_allowed
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date			=>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CAGR_GRADE_SRUCTURE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_cagr_grade_structures
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
  p_cagr_grade_structure_id := l_cagr_grade_structure_id;
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
    ROLLBACK TO create_cagr_grade_structures;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cagr_grade_structure_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cagr_grade_structures;
    --
    -- set in out parameters and set out parameters
    --
     p_cagr_grade_structure_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_cagr_grade_structures;
-- ----------------------------------------------------------------------------
-- |----------------------< update_cagr_grade_structures >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_grade_structures
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_structure_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_dynamic_insert_allowed         in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_effective_date	            in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cagr_grade_structures';
  l_object_version_number per_cagr_grade_structures.object_version_number%TYPE;
  l_ovn per_cagr_grade_structures.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cagr_grade_structures;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_cagr_grade_structures
    --
    hr_cagr_grade_structures_bk2.update_cagr_grade_structures_b
      (
       p_cagr_grade_structure_id        =>  p_cagr_grade_structure_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_dynamic_insert_allowed         =>  p_dynamic_insert_allowed
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date			=>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CAGR_GRADE_STRUCTURES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_cagr_grade_structures
    --
  end;
  --
  per_grs_upd.upd
    (
     p_cagr_grade_structure_id       => p_cagr_grade_structure_id
    ,p_object_version_number         => l_object_version_number
    ,p_dynamic_insert_allowed        => p_dynamic_insert_allowed
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
    ,p_effective_date		     =>  trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_BP_NOT_FOUND
    --
    hr_cagr_grade_structures_bk2.update_cagr_grade_structures_a
      (
       p_cagr_grade_structure_id        =>  p_cagr_grade_structure_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_dynamic_insert_allowed         =>  p_dynamic_insert_allowed
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date			=>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CAGR_GRADE_STRUCTURES'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cagr_grade_structures
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
    ROLLBACK TO update_cagr_grade_structures;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_cagr_grade_structures;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
end update_cagr_grade_structures;
-- ----------------------------------------------------------------------------
-- |--------------------< delete_cagr_grade_structures >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_grade_structures
  (p_validate                       in  boolean  default false
  ,p_cagr_grade_structure_id        in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date		    in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cagr_grade_structures';
  l_object_version_number per_cagr_grade_structures.object_version_number%TYPE;
  l_ovn per_cagr_grade_structures.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cagr_grade_structures;
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
    -- Start of API User Hook for the before hook of delete_BP_NOT_FOUND
    --
   hr_cagr_grade_structures_bk3.delete_cagr_grade_structures_b
      (
       p_cagr_grade_structure_id        =>  p_cagr_grade_structure_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date			=>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CAGR_GRADES_STRUCTURES'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_cagr_grade_structures
    --
  end;
  --
  per_grs_del.del
    (
     p_cagr_grade_structure_id       => p_cagr_grade_structure_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date	             =>  trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cagr_grade_structures
    --
    hr_cagr_grade_structures_bk3.delete_cagr_grade_structures_a
      (
       p_cagr_grade_structure_id        =>  p_cagr_grade_structure_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date			=>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CAGR_GRADE_STRUCTURES'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cagr_grade_structures
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
    ROLLBACK TO delete_cagr_grade_structures;
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
    ROLLBACK TO delete_cagr_grade_structures;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
end delete_cagr_grade_structures;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cagr_grade_structure_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date	   in date
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
  per_grs_shd.lck
    (
      p_cagr_grade_structure_id    => p_cagr_grade_structure_id
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date		   =>  trunc(p_effective_date)
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end hr_cagr_grade_structures_api;

/
