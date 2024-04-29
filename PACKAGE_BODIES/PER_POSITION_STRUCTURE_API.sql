--------------------------------------------------------
--  DDL for Package Body PER_POSITION_STRUCTURE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POSITION_STRUCTURE_API" AS
/* $Header: pepstapi.pkb 115.7 2002/12/11 12:15:52 eumenyio noship $ */
--
-- Package Variables
--
-- ----------------------------------------------------------------------------
-- |------------------< create_pos_struct_and_def_ver >--------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_pos_struct_and_def_ver
  (p_validate                       IN     BOOLEAN   DEFAULT false
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number
  ,p_comments                       in     varchar2 default null
  ,p_primary_position_flag         in     varchar2 default 'N'
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_position_structure_id         out nocopy number
  ,p_object_version_number             out nocopy number

  ) IS
l_bin   number(9);
l_gap_warning boolean;
begin

create_position_structure
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_name                         => p_name
  ,p_business_group_id            => p_business_group_id
  ,p_comments                     => p_comments
  ,p_primary_position_flag       => p_primary_position_flag
  ,p_request_id                   => p_request_id
  ,p_program_application_id       => p_program_application_id
  ,p_program_id                   => p_program_id
  ,p_program_update_date          => p_program_update_date
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
  ,p_position_structure_id    => p_position_structure_id
  ,p_object_version_number        => p_object_version_number
  );
per_pos_structure_version_api.create_pos_structure_version
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_position_structure_id    => p_position_structure_id
  ,p_date_from                    => p_effective_date
  ,p_version_number               => 1
  ,p_request_id                   => p_request_id
  ,p_program_application_id       => p_program_application_id
  ,p_program_id                   => p_program_id
  ,p_program_update_date          => p_program_update_date
  ,p_pos_structure_version_id     => l_bin
  ,p_object_version_number        => l_bin
  ,p_gap_warning                  => l_gap_warning
  );
end create_pos_struct_and_def_ver;


-- ----------------------------------------------------------------------------
-- |--------------------< create_position_structure >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_position_structure
  (p_validate                       IN     BOOLEAN   DEFAULT false
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number
  ,p_comments                       in     varchar2 default null
  ,p_primary_position_flag         in     varchar2 default 'N'
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_position_structure_id         out nocopy number
  ,p_object_version_number             out nocopy number

  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_position_structure';
  l_position_structure_id       per_position_Structures.position_structure_id%TYPE;
  l_object_version_number per_position_structures.object_version_number%TYPE;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_position_structure;
  --

begin

per_pos_structure_bk1.create_pos_structure_b
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_name                         => p_name
  ,p_business_group_id            => p_business_group_id
  ,p_comments                     => p_comments
  ,p_primary_position_flag       => p_primary_position_flag
  ,p_request_id                   => p_request_id
  ,p_program_application_id       => p_program_application_id
  ,p_program_id                   => p_program_id
  ,p_program_update_date          => p_program_update_date
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
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_position_structure'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  per_pst_ins.ins
  (p_effective_date                  =>p_effective_date
  ,p_name                            =>p_name
  ,p_business_group_id               =>p_business_group_id
  ,p_comments                        =>p_comments
  ,p_primary_position_flag          =>p_primary_position_flag
  ,p_request_id                      =>p_request_id
  ,p_program_application_id          =>p_program_application_id
  ,p_program_id                      =>p_program_id
  ,p_program_update_date             =>p_program_update_date
  ,p_attribute_category              =>p_attribute_category
  ,p_attribute1                      =>p_attribute1
  ,p_attribute2                      =>p_attribute2
  ,p_attribute3                      =>p_attribute3
  ,p_attribute4                      =>p_attribute4
  ,p_attribute5                      =>p_attribute5
  ,p_attribute6                      =>p_attribute6
  ,p_attribute7                      =>p_attribute7
  ,p_attribute8                      =>p_attribute8
  ,p_attribute9                      =>p_attribute9
  ,p_attribute10                     =>p_attribute10
  ,p_attribute11                     =>p_attribute11
  ,p_attribute12                     =>p_attribute12
  ,p_attribute13                     =>p_attribute13
  ,p_attribute14                     =>p_attribute14
  ,p_attribute15                     =>p_attribute15
  ,p_attribute16                     =>p_attribute16
  ,p_attribute17                     =>p_attribute17
  ,p_attribute18                     =>p_attribute18
  ,p_attribute19                     =>p_attribute19
  ,p_attribute20                     =>p_attribute20
  ,p_position_structure_id       =>l_position_structure_id
  ,p_object_version_number           =>l_object_version_number );

  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments
  --
  p_position_structure_id := l_position_structure_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --



begin

per_pos_structure_bk1.create_pos_structure_a
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_name                         => p_name
  ,p_business_group_id            => p_business_group_id
  ,p_comments                     => p_comments
  ,p_primary_position_flag       => p_primary_position_flag
  ,p_request_id                   => p_request_id
  ,p_program_application_id       => p_program_application_id
  ,p_program_id                   => p_program_id
  ,p_program_update_date          => p_program_update_date
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
  ,p_object_version_number        => p_object_version_number
  ,p_position_structure_id        => p_position_structure_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_position_structure'
        ,p_hook_type   => 'AP'
        );
  end;


EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_position_structure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_position_structure_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    p_position_structure_id := NULL;
    p_object_version_number  := NULL;
    ROLLBACK TO create_position_structure;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_position_structure;




-- ----------------------------------------------------------------------------
-- |-------------------< update_position_structure >----------------------|
-- ----------------------------------------------------------------------------
--
--
PROCEDURE update_position_structure
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_position_structure_id    in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_primary_position_flag       in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
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
  ,p_object_version_number        in out nocopy number
) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_position_structures';
  l_object_version_number per_position_structures.object_version_number%TYPE;
  l_temp_ovn              number       := p_object_version_number;
BEGIN

  --
  -- Issue a savepoint.
  --
  savepoint update_position_structure;
  --
begin
per_pos_structure_bk2.update_pos_structure_b
  (p_validate                       =>  p_validate
  ,p_effective_date                 =>  p_effective_date
  ,p_position_structure_id      =>  p_position_structure_id
  ,p_object_version_number          =>  p_object_version_number
  ,p_name                           =>  p_name
  ,p_comments                       =>  p_comments
  ,p_primary_position_flag         =>  p_primary_position_flag
  ,p_request_id                     =>  p_request_id
  ,p_program_application_id         =>  p_program_application_id
  ,p_program_id                     =>  p_program_id
  ,p_program_update_date            =>  p_program_update_date
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
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_position_structure'
        ,p_hook_type   => 'BP'
        );
  end;
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  --
  per_pst_upd.upd
 ( p_effective_date                 =>  p_effective_date
  ,p_position_structure_id      =>  p_position_structure_id
  ,p_object_version_number          =>  l_object_version_number
  ,p_name                           =>  p_name
  ,p_comments                       =>  p_comments
  ,p_business_group_id              =>  hr_api.g_number
  ,p_primary_position_flag         =>  p_primary_position_flag
  ,p_request_id                     =>  p_request_id
  ,p_program_application_id         =>  p_program_application_id
  ,p_program_id                     =>  p_program_id
  ,p_program_update_date            =>  p_program_update_date
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
    );
  --
  --
--
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set all output arguments.  If p_validate was TRUE, this bit is
  -- never reached, so p_object_version_number is passed back unchanged.
  --
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --

begin
per_pos_structure_bk2.update_pos_structure_a
  (p_validate                       =>  p_validate
  ,p_effective_date                 =>  p_effective_date
  ,p_position_structure_id          =>  p_position_structure_id
  ,p_object_version_number          =>  p_object_version_number
  ,p_name                           =>  p_name
  ,p_comments                       =>  p_comments
  ,p_primary_position_flag          =>  p_primary_position_flag
  ,p_request_id                     =>  p_request_id
  ,p_program_application_id         =>  p_program_application_id
  ,p_program_id                     =>  p_program_id
  ,p_program_update_date            =>  p_program_update_date
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
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_position_structure'
        ,p_hook_type   => 'AP'
        );
  end;

EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_position_structure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    p_object_version_number  := l_temp_ovn;
    ROLLBACK TO update_position_structure;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_position_structure;

-- ----------------------------------------------------------------------------
-- |-------------------< delete_position_structure >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_position_structure
   (  p_validate                     IN BOOLEAN default false
     ,p_position_structure_id    IN number
     ,p_object_version_number        IN number )

IS
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_position_structure';
  --
BEGIN

  --
  -- Issue a savepoint
  --
  savepoint delete_position_structure;
  --
begin
per_pos_structure_bk3.delete_pos_structure_b
    (p_validate                    => p_validate
    ,p_position_structure_id       => p_position_structure_id
    ,p_object_version_number       => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_position_structure'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  per_pst_shd.lck ( p_position_structure_id             => p_position_structure_id,
                     p_object_version_number       => p_object_version_number );
  hr_utility.set_location( l_proc, 40);
  per_pst_del.del   (  p_position_structure_id  => p_position_structure_id,
    p_object_version_number       => p_object_version_number );
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
     RAISE hr_api.validate_enabled;
  END IF;
  --
  --
begin
per_pos_structure_bk3.delete_pos_structure_a
    (p_validate                     => p_validate
    ,p_position_structure_id    => p_position_structure_id
    ,p_object_version_number        => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_position_structure'
        ,p_hook_type   => 'AP'
        );
  end;


EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_position_structure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO delete_position_structure;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
END delete_position_structure;
--
--
END per_position_structure_api;

/
