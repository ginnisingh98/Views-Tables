--------------------------------------------------------
--  DDL for Package Body HR_HIERARCHY_ELEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HIERARCHY_ELEMENT_API" as
/* $Header: peoseapi.pkb 120.0 2005/05/31 12:22:41 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_hierarchy_element_api.';
g_hr_installed varchar2(1);
g_pa_installed varchar2(1);
g_industry varchar2(20);
g_installed1 boolean := fnd_installation.get(800,800,g_hr_installed,g_industry);
g_installed2 boolean := fnd_installation.get(275,275,g_pa_installed,g_industry);
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_hierarchy_element - new >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_element
  (p_validate                      in     boolean   default false
  ,p_effective_date                in     DATE
  ,p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number    default null
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_inactive_org_warning             out nocopy boolean
  ,p_org_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_org_structure_element_id
           per_org_structure_elements.org_structure_element_id%TYPE;
  l_object_version_number
           per_org_structure_elements.object_version_number%TYPE;
  l_exists_in_hierarchy varchar2(1);
  l_view_all_orgs    varchar2(3);
  l_effective_date      date;
  l_date_from           date;
  l_security_profile_id number;
  l_warning_raised  varchar2(1);
  l_proc                varchar2(72) := g_package||'create_hierarchy_element';
  --
  cursor get_old_element is select org_structure_element_id,
  object_version_number
  from per_org_structure_elements
  where organization_id_child = p_Organization_Id_Child
  and   org_structure_version_id = p_org_structure_version_id;

 --Bug fix 2879820 starts here

  cursor c_date_from is select date_from
  from per_org_structure_versions
  where org_structure_version_id= p_org_structure_version_id;

  cursor c_org_flag is select VIEW_ALL_ORGANIZATIONS_FLAG
  from per_security_profiles
  where security_profile_id= l_security_profile_id;

   --Bug fix 2879820 ends here
 --
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('p_org_structure_version_id:'||p_org_structure_version_id, 568);
  hr_utility.set_location('p_effective_date:'||p_effective_date, 568);
  hr_utility.set_location('p_business_group_id:'||p_business_group_id, 568);
  --
  -- Issue a savepoint
  --
  savepoint create_hierarchy_element;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_security_profile_id := hr_security.get_security_profile; --Bug 2879820


  --
  -- Call Before Process User Hook
  --
  begin
    hr_hierarchy_element_bk1.create_hierarchy_element_b
    ( p_effective_date                 =>     p_effective_date
     ,p_organization_id_parent         =>     p_organization_id_parent
     ,p_org_structure_version_id       =>     p_org_structure_version_id
     ,p_organization_id_child          =>     p_organization_id_child
     ,p_business_group_id              =>     p_business_group_id
     ,p_pos_control_enabled_flag       =>     p_pos_control_enabled_flag
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_hierarchy_element'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --Bug fix 2879820 starts here
  --
  open c_date_from;
  fetch c_date_from into l_date_from;
  if c_date_from%notfound then
     close c_date_from;
     hr_utility.set_message(800,'HR_289732_ORG_VER_INV');
     hr_utility.raise_error;
  else
     close c_date_from;
  end if;
  --Bug fix 2879820 ends here
  --
  per_org_structure_elements_pkg.check_org_active
               (p_org_id_parent      =>    p_Organization_Id_Parent
               ,p_date_from          =>    l_date_from       --Bug 2879820
               ,p_end_of_time        =>    hr_api.g_eot      --Bug 2879820
               ,p_warning_raised     =>    l_warning_raised
               );
 if l_warning_raised= 'Y' then
    p_inactive_org_warning := TRUE;
 elsif l_warning_raised= 'N' then
    p_inactive_org_warning := FALSE;
 else
   p_inactive_org_warning := NULL;
 end if;
  --
  -- Process Logic
  --
  if ((hr_organization_units_pkg.exists_in_hierarchy(p_org_structure_version_id
                            ,p_organization_id_child) = 'Y')) then

  --
  -- Yes, then remove existing element and replace with a new one
  --
    open get_old_element;
    fetch get_old_element into l_org_structure_element_id, l_object_version_number;
    if get_old_element%found then
      close get_old_element;
  --
      per_ose_del.del
       (p_org_structure_element_id       =>     l_org_structure_element_id
       ,p_object_version_number          =>     l_object_version_number
       ,p_hr_installed                   =>     g_hr_installed   --Bug 2879820
       ,p_pa_installed                   =>     g_pa_installed   --Bug 2879820
       ,p_chk_children_exist             =>     'N'
       );
  --
    else
       close get_old_element;
    end if;
  end if;
  --
      per_ose_ins.ins
       (p_organization_id_parent         =>     p_organization_id_parent
       ,p_org_structure_version_id       =>     p_org_structure_version_id
       ,p_organization_id_child          =>     p_organization_id_child
       ,p_business_group_id              =>     p_business_group_id
       ,p_effective_date                 =>     l_effective_date
       ,p_org_structure_element_id       =>     p_org_structure_element_id
       ,p_object_version_number          =>     p_object_version_number
       ,p_pos_control_enabled_flag       =>     p_pos_control_enabled_flag
       );
   --
   -- Post-insert code
   -- Maintains org_list security profiles
   -- Bug fix 2879820 starts here
  open c_org_flag;
  fetch c_org_flag into l_view_all_orgs;
  if c_org_flag%notfound then
     l_view_all_orgs := 'Y';
     close c_org_flag;
  else
     close c_org_flag;
  end if;

   if l_view_all_orgs = 'N' then
      per_org_structure_elements_pkg.maintain_org_lists(p_Business_Group_Id
      ,l_security_profile_id
      ,p_Organization_Id_Parent
      );
   end if;
 -- Bug fix 2879820 ends here
  --
  -- Call After Process User Hook
  --
  begin
    hr_hierarchy_element_bk1.create_hierarchy_element_a
    ( p_effective_date                 =>     p_effective_date
     ,p_organization_id_parent         =>     p_organization_id_parent
     ,p_org_structure_version_id       =>     p_org_structure_version_id
     ,p_organization_id_child          =>     p_organization_id_child
     ,p_business_group_id              =>     p_business_group_id
     ,p_pos_control_enabled_flag       =>     p_pos_control_enabled_flag
     ,p_inactive_org_warning           =>     p_inactive_org_warning
     ,p_org_structure_element_id       =>     p_org_structure_element_id
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_hierarchy_element'
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
  -- p_id                     := <local_var_set_in_process_logic>;
  -- p_object_version_number  := <local_var_set_in_process_logic>;
  -- p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_hierarchy_element;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_org_structure_element_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_hierarchy_element;
    --
    -- set in out parameters and set out parameters
    --
    p_org_structure_element_id := null;
    p_object_version_number  := null;
    p_inactive_org_warning  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_hierarchy_element;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_hierarchy_element- old >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_element
  (p_validate                      in     boolean   default false
  ,p_organization_id_parent        in     number
  ,p_org_structure_version_id      in     number
  ,p_organization_id_child         in     number
  ,p_business_group_id             in     number    default null
  ,p_effective_date                in     DATE
  ,p_date_from                     in     DATE
  ,p_security_profile_id           in     NUMBER
  ,p_view_all_orgs                 in     VARCHAR2
  ,p_end_of_time                   in     DATE
  ,p_hr_installed                  in     VARCHAR2
  ,p_pa_installed                  in     VARCHAR2
  ,p_pos_control_enabled_flag      in     varchar2
  ,p_warning_raised                IN OUT NOCOPY VARCHAR2
  ,p_org_structure_element_id         out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_inactive_org_warning boolean;
  l_proc                varchar2(72) := g_package||'create_hierarchy_element (old)';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_hierarchy_element1;

   create_hierarchy_element(
   p_validate                      =>    p_validate
  ,p_effective_date                =>    p_effective_date
  ,p_organization_id_parent        =>    p_organization_id_parent
  ,p_org_structure_version_id      =>    p_org_structure_version_id
  ,p_organization_id_child         =>    p_organization_id_child
  ,p_business_group_id             =>    p_business_group_id
  ,p_pos_control_enabled_flag      =>    p_pos_control_enabled_flag
  ,p_inactive_org_warning          =>    l_inactive_org_warning
  ,p_org_structure_element_id      =>    p_org_structure_element_id
  ,p_object_version_number         =>    p_object_version_number
  );

  if l_inactive_org_warning  then
     p_warning_raised := 'Y';
  elsif not(l_inactive_org_warning) then
     p_warning_raised := 'N';
  else
     p_warning_raised := null;
  end if;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 --
end create_hierarchy_element;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_hierarchy_element >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_element
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_org_structure_element_id      in     number
  ,p_organization_id_parent        in     number   default hr_api.g_number
  ,p_organization_id_child         in     number   default hr_api.g_number
  ,p_pos_control_enabled_flag      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_hierarchy_element';
  l_object_version_number   per_org_structure_elements
                                   .object_version_number%TYPE;
  l_ovn per_org_structure_elements .object_version_number%TYPE := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint
  --
  savepoint update_hierarchy_element;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_hierarchy_element_bk2.update_hierarchy_element_b
     (p_effective_date                 =>     p_effective_date
     ,p_org_structure_element_id       =>     p_org_structure_element_id
     ,p_organization_id_parent         =>     p_organization_id_parent
     ,p_organization_id_child          =>     p_organization_id_child
     ,p_pos_control_enabled_flag       =>     p_pos_control_enabled_flag
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hierarchy_element'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

  per_ose_upd.upd
   (p_org_structure_element_id       =>     p_org_structure_element_id
   ,p_effective_date                 =>     l_effective_date
   ,p_object_version_number          =>     l_object_version_number
   ,p_organization_id_parent         =>     p_organization_id_parent
   ,p_organization_id_child          =>     p_organization_id_child
   ,p_pos_control_enabled_flag       =>     p_pos_control_enabled_flag
   );


  --
  -- Call After Process User Hook
  --
  begin
    hr_hierarchy_element_bk2.update_hierarchy_element_a
     (p_effective_date                 =>     p_effective_date
     ,p_org_structure_element_id       =>     p_org_structure_element_id
     ,p_organization_id_parent         =>     p_organization_id_parent
     ,p_organization_id_child          =>     p_organization_id_child
     ,p_pos_control_enabled_flag       =>     p_pos_control_enabled_flag
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hierarchy_element'
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
    rollback to update_hierarchy_element;
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
    rollback to update_hierarchy_element;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_hierarchy_element;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_hierarchy_element - new >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_element
  (p_validate                      in     boolean  default false
  ,p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_hierarchy_element';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Issue a savepoint
  --
  savepoint delete_hierarchy_element;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hr_hierarchy_element_bk3.delete_hierarchy_element_b
     (p_org_structure_element_id       =>     p_org_structure_element_id
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_hierarchy_element'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --

  per_ose_del.del
   (p_org_structure_element_id       =>     p_org_structure_element_id
   ,p_object_version_number          =>     p_object_version_number
   ,p_hr_installed                   =>     g_hr_installed    --Bug 2879820
   ,p_pa_installed                   =>     g_pa_installed    --Bug 2879820
   ,p_chk_children_exist             =>     'Y'
-- ,p_exists_in_hierarchy            =>     p_exists_in_hierarchy --Bug 2879820
   );


  --
  -- Call After Process User Hook
  --
  begin
    hr_hierarchy_element_bk3.delete_hierarchy_element_a
     (p_org_structure_element_id       =>     p_org_structure_element_id
     ,p_object_version_number          =>     p_object_version_number
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_hierarchy_element'
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
    rollback to delete_hierarchy_element;
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
    rollback to delete_hierarchy_element;
    --
    -- set in out parameters and set out parameters
    --
  --  p_exists_in_hierarchy := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_hierarchy_element;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_hierarchy_element - old >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_element
  (p_validate                      in     boolean  default false
  ,p_org_structure_element_id      in     number
  ,p_object_version_number         in     number
  ,p_hr_installed                  in     VARCHAR2
  ,p_pa_installed                  in     VARCHAR2
  ,p_exists_in_hierarchy           in out nocopy VARCHAR2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_hierarchy_element- old';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Issue a savepoint
  --
  savepoint delete_hierarchy_element;

  delete_hierarchy_element
  (p_validate                     =>   p_validate
  ,p_org_structure_element_id     =>   p_org_structure_element_id
  ,p_object_version_number        =>   p_object_version_number
  );
 --
  p_exists_in_hierarchy := 'N';
 --
hr_utility.set_location(' Leaving:'||l_proc, 90);

end delete_hierarchy_element;
--
--
end hr_hierarchy_element_api;


/
