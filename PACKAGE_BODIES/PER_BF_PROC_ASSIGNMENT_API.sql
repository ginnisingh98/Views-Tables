--------------------------------------------------------
--  DDL for Package Body PER_BF_PROC_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_PROC_ASSIGNMENT_API" as
/* $Header: pebpaapi.pkb 115.4 2002/12/02 13:04:34 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(35) := 'PER_BF_PROC_ASSIGNMENT_API.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< check_row_exists >------------------------------|
-- ---------------------------------------------------------------------------
PROCEDURE chk_row_exists(p_assignment_id in number
                        ,p_payroll_run_id    in number) IS
  --
  -- Cursors
  CURSOR csr_find_row IS
    SELECT 'Y'
      FROM per_bf_processed_assignments
     WHERE payroll_run_id = p_payroll_run_id
       AND assignment_id = p_assignment_id;
  --
  l_exists  varchar2(1);
  --
BEGIN
  --
  OPEN csr_find_row;
  FETCH csr_find_row INTO l_exists;
  --
  IF csr_find_row%FOUND THEN
     CLOSE csr_find_row;
     --
     -- Row already exists for assignment/payroll combination
     -- Raise error
    hr_utility.set_message(800,'PER_289340_BF_PROC_ASGN_EXISTS');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_find_row;
  --
END chk_row_exists;

--
-- ----------------------------------------------------------------------------
-- |--------------------< create_processed_assignment >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_processed_assignment
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_payroll_run_id                in     number
  ,p_bpa_attribute_category            in     varchar2 default null
  ,p_bpa_attribute1                    in     varchar2 default null
  ,p_bpa_attribute2                    in     varchar2 default null
  ,p_bpa_attribute3                    in     varchar2 default null
  ,p_bpa_attribute4                    in     varchar2 default null
  ,p_bpa_attribute5                    in     varchar2 default null
  ,p_bpa_attribute6                    in     varchar2 default null
  ,p_bpa_attribute7                    in     varchar2 default null
  ,p_bpa_attribute8                    in     varchar2 default null
  ,p_bpa_attribute9                    in     varchar2 default null
  ,p_bpa_attribute10                   in     varchar2 default null
  ,p_bpa_attribute11                   in     varchar2 default null
  ,p_bpa_attribute12                   in     varchar2 default null
  ,p_bpa_attribute13                   in     varchar2 default null
  ,p_bpa_attribute14                   in     varchar2 default null
  ,p_bpa_attribute15                   in     varchar2 default null
  ,p_bpa_attribute16                   in     varchar2 default null
  ,p_bpa_attribute17                   in     varchar2 default null
  ,p_bpa_attribute18                   in     varchar2 default null
  ,p_bpa_attribute19                   in     varchar2 default null
  ,p_bpa_attribute20                   in     varchar2 default null
  ,p_bpa_attribute21                   in     varchar2 default null
  ,p_bpa_attribute22                   in     varchar2 default null
  ,p_bpa_attribute23                   in     varchar2 default null
  ,p_bpa_attribute24                   in     varchar2 default null
  ,p_bpa_attribute25                   in     varchar2 default null
  ,p_bpa_attribute26                   in     varchar2 default null
  ,p_bpa_attribute27                   in     varchar2 default null
  ,p_bpa_attribute28                   in     varchar2 default null
  ,p_bpa_attribute29                   in     varchar2 default null
  ,p_bpa_attribute30                   in     varchar2 default null
  ,p_processed_assignment_id          out nocopy number
  ,p_processed_assignment_ovn         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_processed_assignment_id
      PER_BF_PROCESSED_ASSIGNMENTS.processed_assignment_id%TYPE;
  l_processed_assignment_ovn
      PER_BF_PROCESSED_ASSIGNMENTS.object_version_number%TYPE;
  --
  l_proc   varchar2(72) := g_package||'create_processed_assignment';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_processed_assignment;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_PROC_ASSIGNMENT_BK1.CREATE_PROCESSED_ASSIGNMENT_B
      (p_effective_date                => p_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_payroll_run_id                => p_payroll_run_id
      ,p_bpa_attribute_category            => p_bpa_attribute_category
      ,p_bpa_attribute1                    => p_bpa_attribute1
      ,p_bpa_attribute2                    => p_bpa_attribute2
      ,p_bpa_attribute3                    => p_bpa_attribute3
      ,p_bpa_attribute4                    => p_bpa_attribute4
      ,p_bpa_attribute5                    => p_bpa_attribute5
      ,p_bpa_attribute6                    => p_bpa_attribute6
      ,p_bpa_attribute7                    => p_bpa_attribute7
      ,p_bpa_attribute8                    => p_bpa_attribute8
      ,p_bpa_attribute9                    => p_bpa_attribute9
      ,p_bpa_attribute10                   => p_bpa_attribute10
      ,p_bpa_attribute11                   => p_bpa_attribute11
      ,p_bpa_attribute12                   => p_bpa_attribute12
      ,p_bpa_attribute13                   => p_bpa_attribute13
      ,p_bpa_attribute14                   => p_bpa_attribute14
      ,p_bpa_attribute15                   => p_bpa_attribute15
      ,p_bpa_attribute16                   => p_bpa_attribute16
      ,p_bpa_attribute17                   => p_bpa_attribute17
      ,p_bpa_attribute18                   => p_bpa_attribute18
      ,p_bpa_attribute19                   => p_bpa_attribute19
      ,p_bpa_attribute20                   => p_bpa_attribute20
      ,p_bpa_attribute21                   => p_bpa_attribute21
      ,p_bpa_attribute22                   => p_bpa_attribute22
      ,p_bpa_attribute23                   => p_bpa_attribute23
      ,p_bpa_attribute24                   => p_bpa_attribute24
      ,p_bpa_attribute25                   => p_bpa_attribute25
      ,p_bpa_attribute26                   => p_bpa_attribute26
      ,p_bpa_attribute27                   => p_bpa_attribute27
      ,p_bpa_attribute28                   => p_bpa_attribute28
      ,p_bpa_attribute29                   => p_bpa_attribute29
      ,p_bpa_attribute30                   => p_bpa_attribute30
       );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PROCESSED_ASSIGNMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  chk_row_exists(p_assignment_id  => p_assignment_id
                ,p_payroll_run_id => p_payroll_run_id);
  --
  --
  -- Process Logic
  --
  per_bpa_ins.ins
    (p_effective_date          => p_effective_date
    ,p_payroll_run_id          => p_payroll_run_id
    ,p_bpa_attribute_category  => p_bpa_attribute_category
    ,p_bpa_attribute1          => p_bpa_attribute1
    ,p_bpa_attribute2          => p_bpa_attribute2
    ,p_bpa_attribute3          => p_bpa_attribute3
    ,p_bpa_attribute4          => p_bpa_attribute4
    ,p_bpa_attribute5          => p_bpa_attribute5
    ,p_bpa_attribute6          => p_bpa_attribute6
    ,p_bpa_attribute7          => p_bpa_attribute7
    ,p_bpa_attribute8          => p_bpa_attribute8
    ,p_bpa_attribute9          => p_bpa_attribute9
    ,p_bpa_attribute10         => p_bpa_attribute10
    ,p_bpa_attribute11         => p_bpa_attribute11
    ,p_bpa_attribute12         => p_bpa_attribute12
    ,p_bpa_attribute13         => p_bpa_attribute13
    ,p_bpa_attribute14         => p_bpa_attribute14
    ,p_bpa_attribute15         => p_bpa_attribute15
    ,p_bpa_attribute16         => p_bpa_attribute16
    ,p_bpa_attribute17         => p_bpa_attribute17
    ,p_bpa_attribute18         => p_bpa_attribute18
    ,p_bpa_attribute19         => p_bpa_attribute19
    ,p_bpa_attribute20         => p_bpa_attribute20
    ,p_bpa_attribute21         => p_bpa_attribute21
    ,p_bpa_attribute22         => p_bpa_attribute22
    ,p_bpa_attribute23         => p_bpa_attribute23
    ,p_bpa_attribute24         => p_bpa_attribute24
    ,p_bpa_attribute25         => p_bpa_attribute25
    ,p_bpa_attribute26         => p_bpa_attribute26
    ,p_bpa_attribute27         => p_bpa_attribute27
    ,p_bpa_attribute28         => p_bpa_attribute28
    ,p_bpa_attribute29         => p_bpa_attribute29
    ,p_bpa_attribute30         => p_bpa_attribute30
    ,p_assignment_id           => p_assignment_id
    ,p_processed_assignment_id => l_processed_assignment_id
    ,p_object_version_number   => l_processed_assignment_ovn
    );
  --
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_PROC_ASSIGNMENT_BK1.CREATE_PROCESSED_ASSIGNMENT_A
      (p_effective_date                => p_effective_date
      ,p_assignment_id                 => p_assignment_id
      ,p_payroll_run_id                => p_payroll_run_id
      ,p_bpa_attribute_category            => p_bpa_attribute_category
      ,p_bpa_attribute1                    => p_bpa_attribute1
      ,p_bpa_attribute2                    => p_bpa_attribute2
      ,p_bpa_attribute3                    => p_bpa_attribute3
      ,p_bpa_attribute4                    => p_bpa_attribute4
      ,p_bpa_attribute5                    => p_bpa_attribute5
      ,p_bpa_attribute6                    => p_bpa_attribute6
      ,p_bpa_attribute7                    => p_bpa_attribute7
      ,p_bpa_attribute8                    => p_bpa_attribute8
      ,p_bpa_attribute9                    => p_bpa_attribute9
      ,p_bpa_attribute10                   => p_bpa_attribute10
      ,p_bpa_attribute11                   => p_bpa_attribute11
      ,p_bpa_attribute12                   => p_bpa_attribute12
      ,p_bpa_attribute13                   => p_bpa_attribute13
      ,p_bpa_attribute14                   => p_bpa_attribute14
      ,p_bpa_attribute15                   => p_bpa_attribute15
      ,p_bpa_attribute16                   => p_bpa_attribute16
      ,p_bpa_attribute17                   => p_bpa_attribute17
      ,p_bpa_attribute18                   => p_bpa_attribute18
      ,p_bpa_attribute19                   => p_bpa_attribute19
      ,p_bpa_attribute20                   => p_bpa_attribute20
      ,p_bpa_attribute21                   => p_bpa_attribute21
      ,p_bpa_attribute22                   => p_bpa_attribute22
      ,p_bpa_attribute23                   => p_bpa_attribute23
      ,p_bpa_attribute24                   => p_bpa_attribute24
      ,p_bpa_attribute25                   => p_bpa_attribute25
      ,p_bpa_attribute26                   => p_bpa_attribute26
      ,p_bpa_attribute27                   => p_bpa_attribute27
      ,p_bpa_attribute28                   => p_bpa_attribute28
      ,p_bpa_attribute29                   => p_bpa_attribute29
      ,p_bpa_attribute30                   => p_bpa_attribute30
      ,p_processed_assignment_id       => l_processed_assignment_id
      ,p_processed_assignment_ovn      => l_processed_assignment_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PROCESSED_ASSIGNMENT'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_processed_assignment_id := l_processed_assignment_id;
  p_processed_assignment_ovn:= l_processed_assignment_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_processed_assignment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_processed_assignment_id := null;
    p_processed_assignment_ovn:= null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_processed_assignment;
    --set out variables
    p_processed_assignment_id := null;
    p_processed_assignment_ovn:= null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PROCESSED_ASSIGNMENT;
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_processed_assignment >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_processed_assignment
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_processed_assignment_id       in     number
  ,p_bpa_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_processed_assignment_ovn      in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_processed_assignment_id   NUMBER;
  --
  l_processed_assignment_ovn
      PER_BF_PROCESSED_ASSIGNMENTS.object_version_number%TYPE;
  --
  l_proc  varchar2(72) := g_package||'update_processed_assignment';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_processed_assignment;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_PROC_ASSIGNMENT_BK2.UPDATE_PROCESSED_ASSIGNMENT_B
      (p_effective_date                => p_effective_date
      ,p_bpa_attribute_category            => p_bpa_attribute_category
      ,p_bpa_attribute1                    => p_bpa_attribute1
      ,p_bpa_attribute2                    => p_bpa_attribute2
      ,p_bpa_attribute3                    => p_bpa_attribute3
      ,p_bpa_attribute4                    => p_bpa_attribute4
      ,p_bpa_attribute5                    => p_bpa_attribute5
      ,p_bpa_attribute6                    => p_bpa_attribute6
      ,p_bpa_attribute7                    => p_bpa_attribute7
      ,p_bpa_attribute8                    => p_bpa_attribute8
      ,p_bpa_attribute9                    => p_bpa_attribute9
      ,p_bpa_attribute10                   => p_bpa_attribute10
      ,p_bpa_attribute11                   => p_bpa_attribute11
      ,p_bpa_attribute12                   => p_bpa_attribute12
      ,p_bpa_attribute13                   => p_bpa_attribute13
      ,p_bpa_attribute14                   => p_bpa_attribute14
      ,p_bpa_attribute15                   => p_bpa_attribute15
      ,p_bpa_attribute16                   => p_bpa_attribute16
      ,p_bpa_attribute17                   => p_bpa_attribute17
      ,p_bpa_attribute18                   => p_bpa_attribute18
      ,p_bpa_attribute19                   => p_bpa_attribute19
      ,p_bpa_attribute20                   => p_bpa_attribute20
      ,p_bpa_attribute21                   => p_bpa_attribute21
      ,p_bpa_attribute22                   => p_bpa_attribute22
      ,p_bpa_attribute23                   => p_bpa_attribute23
      ,p_bpa_attribute24                   => p_bpa_attribute24
      ,p_bpa_attribute25                   => p_bpa_attribute25
      ,p_bpa_attribute26                   => p_bpa_attribute26
      ,p_bpa_attribute27                   => p_bpa_attribute27
      ,p_bpa_attribute28                   => p_bpa_attribute28
      ,p_bpa_attribute29                   => p_bpa_attribute29
      ,p_bpa_attribute30                   => p_bpa_attribute30
      ,p_processed_assignment_id       => p_processed_assignment_id
      ,p_processed_assignment_ovn      => p_processed_assignment_ovn
       );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROCESSED_ASSIGNMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  l_processed_assignment_ovn   := p_processed_assignment_ovn;
  --
  per_bpa_upd.upd
     (p_effective_date               => p_effective_date
     ,p_processed_assignment_id      => p_processed_assignment_id
     ,p_bpa_attribute_category       => p_bpa_attribute_category
     ,p_bpa_attribute1               => p_bpa_attribute1
     ,p_bpa_attribute2               => p_bpa_attribute2
     ,p_bpa_attribute3               => p_bpa_attribute3
     ,p_bpa_attribute4               => p_bpa_attribute4
     ,p_bpa_attribute5               => p_bpa_attribute5
     ,p_bpa_attribute6               => p_bpa_attribute6
     ,p_bpa_attribute7               => p_bpa_attribute7
     ,p_bpa_attribute8               => p_bpa_attribute8
     ,p_bpa_attribute9               => p_bpa_attribute9
     ,p_bpa_attribute10              => p_bpa_attribute10
     ,p_bpa_attribute11              => p_bpa_attribute11
     ,p_bpa_attribute12              => p_bpa_attribute12
     ,p_bpa_attribute13              => p_bpa_attribute13
     ,p_bpa_attribute14              => p_bpa_attribute14
     ,p_bpa_attribute15              => p_bpa_attribute15
     ,p_bpa_attribute16              => p_bpa_attribute16
     ,p_bpa_attribute17              => p_bpa_attribute17
     ,p_bpa_attribute18              => p_bpa_attribute18
     ,p_bpa_attribute19              => p_bpa_attribute19
     ,p_bpa_attribute20              => p_bpa_attribute20
     ,p_bpa_attribute21              => p_bpa_attribute21
     ,p_bpa_attribute22              => p_bpa_attribute22
     ,p_bpa_attribute23              => p_bpa_attribute23
     ,p_bpa_attribute24              => p_bpa_attribute24
     ,p_bpa_attribute25              => p_bpa_attribute25
     ,p_bpa_attribute26              => p_bpa_attribute26
     ,p_bpa_attribute27              => p_bpa_attribute27
     ,p_bpa_attribute28              => p_bpa_attribute28
     ,p_bpa_attribute29              => p_bpa_attribute29
     ,p_bpa_attribute30              => p_bpa_attribute30
     ,p_object_version_number        => l_processed_assignment_ovn
     );
  --
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_PROC_ASSIGNMENT_BK2.UPDATE_PROCESSED_ASSIGNMENT_A
      (p_effective_date                => p_effective_date
      ,p_processed_assignment_id       => p_processed_assignment_id
      ,p_bpa_attribute_category            => p_bpa_attribute_category
      ,p_bpa_attribute1                    => p_bpa_attribute1
      ,p_bpa_attribute2                    => p_bpa_attribute2
      ,p_bpa_attribute3                    => p_bpa_attribute3
      ,p_bpa_attribute4                    => p_bpa_attribute4
      ,p_bpa_attribute5                    => p_bpa_attribute5
      ,p_bpa_attribute6                    => p_bpa_attribute6
      ,p_bpa_attribute7                    => p_bpa_attribute7
      ,p_bpa_attribute8                    => p_bpa_attribute8
      ,p_bpa_attribute9                    => p_bpa_attribute9
      ,p_bpa_attribute10                   => p_bpa_attribute10
      ,p_bpa_attribute11                   => p_bpa_attribute11
      ,p_bpa_attribute12                   => p_bpa_attribute12
      ,p_bpa_attribute13                   => p_bpa_attribute13
      ,p_bpa_attribute14                   => p_bpa_attribute14
      ,p_bpa_attribute15                   => p_bpa_attribute15
      ,p_bpa_attribute16                   => p_bpa_attribute16
      ,p_bpa_attribute17                   => p_bpa_attribute17
      ,p_bpa_attribute18                   => p_bpa_attribute18
      ,p_bpa_attribute19                   => p_bpa_attribute19
      ,p_bpa_attribute20                   => p_bpa_attribute20
      ,p_bpa_attribute21                   => p_bpa_attribute21
      ,p_bpa_attribute22                   => p_bpa_attribute22
      ,p_bpa_attribute23                   => p_bpa_attribute23
      ,p_bpa_attribute24                   => p_bpa_attribute24
      ,p_bpa_attribute25                   => p_bpa_attribute25
      ,p_bpa_attribute26                   => p_bpa_attribute26
      ,p_bpa_attribute27                   => p_bpa_attribute27
      ,p_bpa_attribute28                   => p_bpa_attribute28
      ,p_bpa_attribute29                   => p_bpa_attribute29
      ,p_bpa_attribute30                   => p_bpa_attribute30
      ,p_processed_assignment_ovn      => l_processed_assignment_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PROCESSED_ASSIGNMENT'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_processed_assignment_ovn  := l_processed_assignment_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_processed_assignment;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_processed_assignment_ovn      := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_processed_assignment;
    --set out variables
    p_processed_assignment_ovn      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_PROCESSED_ASSIGNMENT;
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_processed_assignment >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_processed_assignment
  (p_validate                      in     boolean  default false
  ,p_processed_assignment_id       in     number
  ,p_processed_assignment_ovn      in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc  varchar2(72) := g_package||'delete_processed_assignment';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_processed_assignment;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_PROC_ASSIGNMENT_BK3.DELETE_PROCESSED_ASSIGNMENT_B
      (p_processed_assignment_id       => p_processed_assignment_id
      ,p_processed_assignment_ovn      => p_processed_assignment_ovn
       );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROCESSED_ASSIGNMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_bpa_del.del
   (p_processed_assignment_id       => p_processed_assignment_id
    ,p_object_version_number        => p_processed_assignment_ovn
    );
  --
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_PROC_ASSIGNMENT_BK3.DELETE_PROCESSED_ASSIGNMENT_A
      (
       p_processed_assignment_id       => p_processed_assignment_id
      ,p_processed_assignment_ovn      => p_processed_assignment_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PROCESSED_ASSIGNMENT'
        ,p_hook_type   => 'AP'
        );
  end;
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_processed_assignment;
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
    rollback to delete_processed_assignment;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_PROCESSED_ASSIGNMENT;
--
end PER_BF_PROC_ASSIGNMENT_API;

/
