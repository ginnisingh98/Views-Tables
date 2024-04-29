--------------------------------------------------------
--  DDL for Package Body PER_ORG_STRUCTURE_VERSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ORG_STRUCTURE_VERSION_API" AS
/* $Header: peosvapi.pkb 120.0 2005/05/31 12:36:17 appldev noship $ */
--
-- Package Variables
--
-- -------------------------------------------------------------------------
-- | -------------------< copy_elements >-----------------------------------|
----------------------------------------------------------------------------
 procedure copy_elements(
  p_validate        boolean
 ,p_org_structure_version_id    number
 ,p_copy_structure_version_id   number
 ,p_effective_date   date
 )
 is
 --
  cursor struct_element is  select *
    from per_org_structure_elements ose
    where ose.org_structure_version_id = p_copy_structure_version_id;


  ele_record struct_element%ROWTYPE;
  l_org_structure_element_id   per_org_structure_elements.org_structure_element_id%TYPE;
  l_object_version_number per_org_structure_elements.object_version_number%TYPE;
  l_inactive_org_warning  boolean;
  l_effective_date date;
  --
 begin

  open struct_element;
     fetch struct_element into ele_record;
	 loop
		exit when struct_element%NOTFOUND;
		hr_hierarchy_element_api.create_hierarchy_element(
          p_validate                       =>     p_validate
         ,p_organization_id_parent         =>     ele_record.Organization_Id_Parent
         ,p_org_structure_version_id       =>     p_org_structure_version_id
         ,p_organization_id_child          =>     ele_record.Organization_Id_Child
         ,p_business_group_id              =>     ele_record.Business_Group_Id
         ,p_effective_date                 =>     p_effective_date
         ,p_pos_control_enabled_flag       =>     null
         ,p_inactive_org_warning           =>     l_inactive_org_warning
         ,p_org_structure_element_id       =>     l_org_structure_element_id
         ,p_object_version_number          =>     l_object_version_number
        );
--
		fetch struct_element into ele_record;
	end loop;
	close struct_element;
 --
end  copy_elements;

-- ----------------------------------------------------------------------------
-- |--------------------< create_org_structure_version >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_org_structure_version
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_organization_structure_id      in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default null
  ,p_date_to                        in     date     default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2 default 'N'
  ,p_org_structure_version_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_gap_warning                       out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables

  l_rowid VARCHAR2(20);
  l_proc                  VARCHAR2(72) := g_package||'create_org_structure_version';
  l_org_structure_version_id       per_org_Structure_versions.org_structure_version_id%TYPE;
  l_object_version_number per_org_structure_versions.object_version_number%TYPE;
  l_effective_date   date;
  l_date_from        date;
  l_date_to          date;
  --
  cursor c is select rowid
      FROM PER_ORG_STRUCTURE_VERSIONS
      WHERE org_structure_version_id = l_Org_Structure_Version_Id;
  --

  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_date_from  := trunc(p_date_from);
  l_date_to    := trunc(p_date_to);
  --
  -- Issue a savepoint
  --
  savepoint create_org_structure_version;
  --

begin

per_org_structure_version_bk1.create_org_structure_version_b
  (p_validate                      =>   p_validate
  ,p_effective_date                =>   l_effective_date
  ,p_organization_structure_id     =>   p_organization_structure_id
  ,p_date_from                     =>   l_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   l_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_topnode_pos_ctrl_enabled_fla  =>   p_topnode_pos_ctrl_enabled_fla
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_structure_version'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  per_osv_ins.ins
  (p_effective_date                =>   l_effective_date
  ,p_organization_structure_id     =>   p_organization_structure_id
  ,p_date_from                     =>   l_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   l_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_topnode_pos_ctrl_enabled_fla  =>   p_topnode_pos_ctrl_enabled_fla
  ,p_org_structure_version_id      =>   l_org_structure_version_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_gap_warning                   =>   p_gap_warning
  );
  --
  hr_utility.set_location(l_proc, 60);

begin

per_org_structure_version_bk1.create_org_structure_version_a
  (p_validate                      =>   p_validate
  ,p_effective_date                =>   l_effective_date
  ,p_organization_structure_id     =>   p_organization_structure_id
  ,p_date_from                     =>   l_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   l_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_topnode_pos_ctrl_enabled_fla  =>   p_topnode_pos_ctrl_enabled_fla
  ,p_org_structure_version_id      =>   l_org_structure_version_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_gap_warning                   =>   p_gap_warning  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_org_structure_version'
        ,p_hook_type   => 'AP'
        );
  end;
 --
  -- Set all output arguments
  --
  p_org_structure_version_id := l_org_structure_version_id;
  p_object_version_number := l_object_version_number;

  --
 begin
  open c;
  fetch c into l_rowid;
  if (c%notfound) then
      close c;
      raise no_data_found;
   end if;
   close c;
  if p_copy_structure_version_id is not null then
     copy_elements(
         p_validate                  => p_validate
        ,p_org_structure_version_id  => p_org_structure_version_id
        ,p_copy_structure_version_id => p_copy_structure_version_id
        ,p_effective_date            => l_effective_date );
  end if;
 end;
 --

 --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
   --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --

EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_org_structure_version;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_org_structure_version_id := NULL;
    p_object_version_number  := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO create_org_structure_version;
        --
    -- set in out parameters and set out parameters
    --
    p_org_structure_version_id := NULL;
    p_object_version_number  := NULL;
    p_gap_warning := false;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
   --
END create_org_structure_version;



-- ----------------------------------------------------------------------------
-- |---------------------< update_org_structure_version >---------------------|
-- ----------------------------------------------------------------------------
--
--
PROCEDURE update_org_structure_version
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
  ,p_topnode_pos_ctrl_enabled_fla   in     varchar2 default hr_api.g_varchar2
  ,p_org_structure_version_id       in     number
  ,p_object_version_number          in out nocopy number
  ,p_gap_warning                       out nocopy boolean
) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_org_structures';
  l_object_version_number per_organization_structures.object_version_number%TYPE;
 l_ovn per_organization_structures.object_version_number%TYPE := p_object_version_number;
BEGIN

  --
  -- Issue a savepoint.
  --
  savepoint update_org_structure_version;
  --
begin
per_org_structure_version_bk2.update_org_structure_version_b
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
  ,p_topnode_pos_ctrl_enabled_fla  =>   p_topnode_pos_ctrl_enabled_fla
  ,p_org_structure_version_id      =>   p_org_structure_version_id
  ,p_object_version_number         =>   p_object_version_number
);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_structure'
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
  per_osv_upd.upd
  (p_effective_date                =>   p_effective_date
  ,p_date_from                     =>   p_date_from
  ,p_version_number                =>   p_version_number
  ,p_copy_structure_version_id     =>   p_copy_structure_version_id
  ,p_date_to                       =>   p_date_to
  ,p_request_id                    =>   p_request_id
  ,p_program_application_id        =>   p_program_application_id
  ,p_program_id                    =>   p_program_id
  ,p_program_update_date           =>   p_program_update_date
  ,p_topnode_pos_ctrl_enabled_fla  =>   p_topnode_pos_ctrl_enabled_fla
  ,p_org_structure_version_id      =>   p_org_structure_version_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_gap_warning                   =>   p_gap_warning    );
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
per_org_structure_version_bk2.update_org_structure_version_a
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
  ,p_topnode_pos_ctrl_enabled_fla  =>   p_topnode_pos_ctrl_enabled_fla
  ,p_org_structure_version_id      =>   p_org_structure_version_id
  ,p_object_version_number         =>   p_object_version_number
  ,p_gap_warning                   =>   p_gap_warning);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_org_structure_version'
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
    ROLLBACK TO update_org_structure;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO update_org_structure_version;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    p_gap_warning := false;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
    --
END update_org_structure_version;

-- ----------------------------------------------------------------------------
-- |---------------------< delete_org_structure_version >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_org_structure_version
   (  p_validate                     IN BOOLEAN         default false
     ,p_org_structure_version_id     IN number
     ,p_object_version_number        IN number )

IS
  --
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'delete_org_structure_version';
  --
BEGIN

  --
  -- Issue a savepoint
  --
  savepoint delete_organization;
  --
begin
per_org_structure_version_bk3.delete_org_structure_version_b
    ( p_validate                    => p_validate
    , p_org_structure_version_id    => p_org_structure_version_id
    , p_object_version_number       => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_org_structure_version'
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
  per_osv_shd.lck (p_org_structure_version_id    => p_org_structure_version_id,
                  p_object_version_number       => p_object_version_number );
  --
  hr_utility.set_location( l_proc, 40);
  per_osv_del.del   (  p_org_structure_version_id => p_org_structure_version_id,
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
per_org_structure_version_bk3.delete_org_structure_version_a
    (p_validate                     => p_validate
    ,p_org_structure_version_id     => p_org_structure_version_id
    ,p_object_version_number        => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_org_structure_version'
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
    ROLLBACK TO delete_org_structure_version;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    ROLLBACK TO delete_org_structure_version;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    RAISE;
    --
end delete_org_structure_version;
--
--
END per_org_structure_version_api;

/
