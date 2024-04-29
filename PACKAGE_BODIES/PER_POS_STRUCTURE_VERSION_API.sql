--------------------------------------------------------
--  DDL for Package Body PER_POS_STRUCTURE_VERSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_STRUCTURE_VERSION_API" AS
/* $Header: pepsvapi.pkb 115.6 2002/12/11 13:48:04 eumenyio noship $ */
--
-- Package Variables
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_pos_structure_version >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_pos_structure_version
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_position_structure_id          in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default null
  ,p_date_to                        in     date     default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_pos_structure_version_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_gap_warning                       out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'create_pos_structure_version';
  l_pos_structure_version_id       per_pos_Structure_versions.pos_structure_version_id%TYPE;
  l_object_version_number per_pos_structure_versions.object_version_number%TYPE;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_pos_structure_version;
  --

begin

per_pos_structure_version_bk1.create_pos_structure_version_b
  (p_validate                      =>   p_validate
  ,p_effective_date                =>   p_effective_date
  ,p_position_structure_id         =>   p_position_structure_id
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pos_structure_version'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  per_psv_ins.ins
  (p_effective_date                =>   p_effective_date
  ,p_position_structure_id     =>   p_position_structure_id
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_pos_structure_version_id      =>   l_pos_structure_version_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_gap_warning                   =>   p_gap_warning
);
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
  p_pos_structure_version_id := l_pos_structure_version_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --



begin

per_pos_structure_version_bk1.create_pos_structure_version_a
  (p_validate                      =>   p_validate
  ,p_effective_date                =>   p_effective_date
  ,p_position_structure_id     =>   p_position_structure_id
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_pos_structure_version_id      =>   l_pos_structure_version_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_gap_warning                   =>   p_gap_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pos_structure_version'
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
    ROLLBACK TO create_pos_structure_version;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pos_structure_version_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    p_pos_structure_version_id := NULL;
    p_object_version_number    := NULL;
    p_gap_warning              := NULL;
    ROLLBACK TO create_pos_structure_version;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_pos_structure_version;



-- ----------------------------------------------------------------------------
-- |---------------------< update_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
--
--
PROCEDURE update_pos_structure_version
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default hr_api.g_number
  ,p_date_to                        in     date     default hr_api.g_date
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
  ,p_pos_structure_version_id       in     number
  ,p_object_version_number          in out nocopy number
  ,p_gap_warning                       out nocopy boolean) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_pos_structures';
  l_object_version_number per_position_structures.object_version_number%TYPE;
  l_temp_ovn              number       := p_object_version_number;
BEGIN

  --
  -- Issue a savepoint.
  --
  savepoint update_pos_structure_version;
  --
begin
per_pos_structure_version_bk2.update_pos_structure_version_b
  ( p_validate                      =>   p_validate
  ,p_effective_date                =>   p_effective_date
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_pos_structure_version_id      =>   p_pos_structure_version_id
  ,p_object_version_number         =>   p_object_version_number
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pos_structure'
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
  per_psv_upd.upd
  (p_effective_date                =>   p_effective_date
  ,p_position_structure_id         =>   hr_api.g_number
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_pos_structure_version_id      =>   p_pos_structure_version_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_gap_warning                   =>   p_gap_warning );
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
per_pos_structure_version_bk2.update_pos_structure_version_a
  (p_validate                       =>  p_validate
  ,p_effective_date                =>   p_effective_date
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_pos_structure_version_id      =>   p_pos_structure_version_id
  ,p_object_version_number         =>   p_object_version_number
  ,p_gap_warning                   =>   p_gap_warning);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pos_structure_version'
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
    ROLLBACK TO update_pos_structure_version;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    p_gap_warning           := NULL;
    p_object_version_number := l_temp_ovn;
    ROLLBACK TO update_pos_structure_version;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_pos_structure_version;

-- ----------------------------------------------------------------------------
-- |---------------------< delete_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_pos_structure_version
   (  p_validate                     IN BOOLEAN default false
     ,p_pos_structure_version_id     IN number
     ,p_object_version_number        IN number )

IS
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_pos_structure_version';
  --
BEGIN

  --
  -- Issue a savepoint
  --
  savepoint delete_pos_structure_version;
  --
begin
per_pos_structure_version_bk3.delete_pos_structure_version_b
    ( p_validate                    => p_validate
    , p_pos_structure_version_id    => p_pos_structure_version_id
    , p_object_version_number       => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pos_structure_version'
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
  per_psv_shd.lck (p_pos_structure_version_id    => p_pos_structure_version_id,
                  p_object_version_number       => p_object_version_number );
  --
  hr_utility.set_location( l_proc, 40);
  per_psv_del.del   (  p_pos_structure_version_id => p_pos_structure_version_id,
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
per_pos_structure_version_bk3.delete_pos_structure_version_a
    (p_validate                     => p_validate
    ,p_pos_structure_version_id     => p_pos_structure_version_id
    ,p_object_version_number        => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pos_structure_version'
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
    ROLLBACK TO delete_pos_structure_version;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO delete_pos_structure_version;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
end delete_pos_structure_version;
--
--
END per_pos_structure_version_api;

/
