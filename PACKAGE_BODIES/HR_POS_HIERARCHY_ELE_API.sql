--------------------------------------------------------
--  DDL for Package Body HR_POS_HIERARCHY_ELE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_POS_HIERARCHY_ELE_API" as
/* $Header: pepseapi.pkb 120.0.12000000.2 2007/06/29 10:07:15 sidsaxen noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_pos_hierarchy_ele_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pos_hierarchy_ele >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pos_hierarchy_ele
  (p_validate                      in     boolean  default false
  ,p_parent_position_id            in     number
  ,p_pos_structure_version_id      in     number
  ,p_subordinate_position_id       in     number
  ,p_business_group_id             in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_effective_date                in     date
  ,p_pos_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pos_structure_element_id
           per_pos_structure_elements.pos_structure_element_id%TYPE;
  l_object_version_number
           per_pos_structure_elements.object_version_number%TYPE;
  l_proc                varchar2(72) := g_package||'create_pos_hierarchy_ele';
  l_effective_date date;
  --
  cursor get_old_element is select pos_structure_element_id,
  object_version_number
  from per_pos_structure_elements
  where subordinate_position_id = p_subordinate_position_id
  and   pos_structure_version_id = p_pos_structure_version_id;
  --

	--start changes for bug 6139893
	--cursor returns values when the passing 'Parent' is already present as a 'Child' in the below hierarchy
  cursor chk_child_sub_node is
	SELECT distinct '1'
	FROM    per_pos_structure_elements a
	WHERE   a.business_group_id            = p_business_group_id
			AND a.POS_structure_version_id = p_pos_structure_version_id
			AND a.parent_position_id       = p_subordinate_position_id
			AND p_parent_position_id IN
					(SELECT subordinate_position_id
					FROM    per_pos_structure_elements b
					WHERE   a.business_group_id        = b.business_group_id
							AND a.POS_structure_version_id = b.pos_structure_version_id
							CONNECT BY parent_position_id = prior subordinate_position_id
							START WITH parent_position_id = a.parent_position_id
					);
	l_chk varchar2(10);

	--end changes for bug 6139893

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_pos_hierarchy_ele;
  --
  -- Truncate the time portion from all IN date parameters
  l_effective_date := trunc(p_effective_date);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_pos_hierarchy_ele_bk1.create_pos_hierarchy_ele_b
     (p_parent_position_id         =>     p_parent_position_id
     ,p_pos_structure_version_id   =>     p_pos_structure_version_id
     ,p_subordinate_position_id    =>     p_subordinate_position_id
     ,p_business_group_id          =>     p_business_group_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pos_hierarchy_ele'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
	--

	--start changes for bug 6139893
  -- check the 'Parent' should not present as 'Child' in the lower hierarchy.

  open chk_child_sub_node;
  fetch chk_child_sub_node into l_chk;

  if chk_child_sub_node%found THEN
    close chk_child_sub_node;
    hr_utility.set_message(801,'PER_7421_POS_PARENT_BELOW');
    hr_utility.raise_error;
  ELSE
		CLOSE chk_child_sub_node;
  END if;
	---
  --end changes for bug 6139893
  --
  if ((PER_POSITIONS_PKG.exists_in_hierarchy(
         X_Pos_Structure_Version_Id => p_Pos_Structure_Version_Id
        ,X_Position_Id => p_Subordinate_Position_Id)) ='Y') then
  --
  -- Yes, then remove existing element and replace with a new one
  --
    open get_old_element;
    fetch get_old_element into l_pos_structure_element_id, l_object_version_number;
    if get_old_element%found then
      close get_old_element;
  --
      per_pse_del.del
       (p_pos_structure_element_id       =>     l_pos_structure_element_id
       ,p_object_version_number          =>     l_object_version_number
       ,p_hr_installed                   =>     p_hr_installed
       ,p_chk_children                   =>     'N'
       );
  --
    else
       close get_old_element;
    end if;
  end if;
  --
      per_pse_ins.ins
       (p_business_group_id              =>     p_business_group_id
       ,p_pos_structure_version_id       =>     p_pos_structure_version_id
       ,p_subordinate_position_id        =>     p_subordinate_position_id
       ,p_parent_position_id             =>     p_parent_position_id
       ,p_effective_date                 =>     l_effective_date
       ,p_pos_structure_element_id       =>     p_pos_structure_element_id
       ,p_object_version_number          =>     p_object_version_number
       );
   --
   -- Post-insert code
   --
   --
  --
  -- Call After Process User Hook
  --
  begin
    hr_pos_hierarchy_ele_bk1.create_pos_hierarchy_ele_a
     (p_parent_position_id         =>     p_parent_position_id
     ,p_pos_structure_version_id   =>     p_pos_structure_version_id
     ,p_subordinate_position_id    =>     p_subordinate_position_id
     ,p_business_group_id          =>     p_business_group_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pos_hierarchy_ele'
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
  -- use values returned from ins (PZWALKER)
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_pos_hierarchy_ele;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pos_structure_element_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_pos_structure_element_id := null;
    p_object_version_number  := null;
    rollback to create_pos_hierarchy_ele;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_pos_hierarchy_ele;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pos_hierarchy_ele >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pos_hierarchy_ele
  (p_validate                      in     boolean  default false
  ,p_pos_structure_element_id      in     number
  ,p_effective_date                in     date
  ,p_parent_position_id            in     number   default hr_api.g_number
  ,p_subordinate_position_id       in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date date;
  l_proc                varchar2(72) := g_package||'update_pos_hierarchy_ele';
  l_object_version_number   per_pos_structure_elements
                                   .object_version_number%TYPE;
  l_temp_ovn            number       := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint
  --
  savepoint update_pos_hierarchy_ele;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_pos_hierarchy_ele_bk2.update_pos_hierarchy_ele_b
     (p_pos_structure_element_id       =>     p_pos_structure_element_id
     ,p_parent_position_id             =>     p_parent_position_id
     ,p_subordinate_position_id        =>     p_subordinate_position_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pos_hierarchy_ele'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_pse_upd.upd
   (p_pos_structure_element_id       =>     p_pos_structure_element_id
   ,p_object_version_number          =>     l_object_version_number
   ,p_effective_date                 =>     l_effective_date
   ,p_parent_position_id             =>     p_parent_position_id
   ,p_subordinate_position_id        =>     p_subordinate_position_id
   );
  --
  -- Call After Process User Hook
  --
  begin
    hr_pos_hierarchy_ele_bk2.update_pos_hierarchy_ele_a
     (p_pos_structure_element_id       =>     p_pos_structure_element_id
     ,p_parent_position_id             =>     p_parent_position_id
     ,p_subordinate_position_id        =>     p_subordinate_position_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pos_hierarchy_ele'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_pos_hierarchy_ele;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_temp_ovn;
    rollback to update_pos_hierarchy_ele;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_pos_hierarchy_ele;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pos_hierarchy_ele >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pos_hierarchy_ele
  (p_validate                      in     boolean  default false
  ,p_pos_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_pos_hierarchy_ele';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Issue a savepoint
  --
  savepoint delete_pos_hierarchy_ele;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    hr_pos_hierarchy_ele_bk3.delete_pos_hierarchy_ele_b
     (p_pos_structure_element_id       =>     p_pos_structure_element_id
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pos_hierarchy_ele'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  per_pse_del.del
   (p_pos_structure_element_id       =>     p_pos_structure_element_id
   ,p_object_version_number          =>     p_object_version_number
   ,p_hr_installed                   =>     p_hr_installed
   ,p_chk_children                   =>     'Y'
   );
  --
  -- Call After Process User Hook
  --
  begin
    hr_pos_hierarchy_ele_bk3.delete_pos_hierarchy_ele_a
     (p_pos_structure_element_id       =>     p_pos_structure_element_id
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pos_hierarchy_ele'
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
    rollback to delete_pos_hierarchy_ele;
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
    rollback to delete_pos_hierarchy_ele;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_pos_hierarchy_ele;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pos_hier_elem_internal
  (p_parent_position_id            in     number
  ,p_pos_structure_version_id      in     number
  ,p_subordinate_position_id       in     number
  ,p_business_group_id             in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_effective_date                in     date
  ,p_pos_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
begin
  hr_pos_hierarchy_ele_api.create_pos_hierarchy_ele
  (p_validate                      =>     false
  ,p_parent_position_id            =>     p_parent_position_id
  ,p_pos_structure_version_id      =>     p_pos_structure_version_id
  ,p_subordinate_position_id       =>     p_subordinate_position_id
  ,p_business_group_id             =>     p_business_group_id
  ,p_hr_installed                  =>     p_hr_installed
  ,p_pos_structure_element_id      =>     p_pos_structure_element_id
  ,p_effective_date                =>     p_effective_date
  ,p_object_version_number         =>     p_object_version_number
  );
end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pos_hier_elem_internal
  (p_pos_structure_element_id      in     number
  ,p_parent_position_id            in     number   default hr_api.g_number
  ,p_subordinate_position_id       in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_object_version_number         in out nocopy number
  ) is
begin
  hr_pos_hierarchy_ele_api.update_pos_hierarchy_ele
  (p_validate                      =>     false
  ,p_pos_structure_element_id      =>     p_pos_structure_element_id
  ,p_parent_position_id            =>     p_parent_position_id
  ,p_subordinate_position_id       =>     p_subordinate_position_id
  ,p_effective_date                =>     p_effective_date
  ,p_object_version_number         =>     p_object_version_number
  );
end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pos_hier_elem_internal >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pos_hier_elem_internal
  (p_pos_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  ) is
begin
  hr_pos_hierarchy_ele_api.delete_pos_hierarchy_ele
  (p_validate                      =>     false
  ,p_pos_structure_element_id      =>     p_pos_structure_element_id
  ,p_object_version_number         =>     p_object_version_number
  ,p_hr_installed                  =>     p_hr_installed
  );
end;
--  -
end hr_pos_hierarchy_ele_api;

/
