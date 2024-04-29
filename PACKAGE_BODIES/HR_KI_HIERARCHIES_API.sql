--------------------------------------------------------
--  DDL for Package Body HR_KI_HIERARCHIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_HIERARCHIES_API" as
/* $Header: hrhrcapi.pkb 115.0 2004/01/09 01:13:25 vkarandi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_HIERARCHIES_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_hierarchy_node >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_hierarchy_node
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_hierarchy_key                 in     varchar2
  ,p_parent_hierarchy_id           in     number
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_hierarchy_id                  out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_hierarchy_node';
  l_hierarchy_id      number;
  l_language_code       varchar2(30);
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_hierarchy_node;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk1.create_hierarchy_node_b
      (
      p_language_code                 => p_language_code
     ,p_hierarchy_key                 => p_hierarchy_key
     ,p_parent_hierarchy_id           => p_parent_hierarchy_id
     ,p_name                          => p_name
     ,p_description                   => p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_hierarchy_node'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_hrc_ins.ins
     (
       p_hierarchy_key           => p_hierarchy_key
      ,p_parent_hierarchy_id     => p_parent_hierarchy_id
      ,p_hierarchy_id            => l_hierarchy_id
      ,p_object_version_number   => l_object_version_number
      );

  hr_htl_ins.ins_tl(
       p_language_code          => l_language_code
      ,p_hierarchy_id           => l_hierarchy_id
      ,p_name                   => p_name
      ,p_description            => p_description
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk1.create_hierarchy_node_a
      (
       p_language_code           =>    l_language_code
      ,p_hierarchy_key           =>    p_hierarchy_key
      ,p_parent_hierarchy_id     =>    p_parent_hierarchy_id
      ,p_name                    =>    p_name
      ,p_description             =>    p_description
      ,p_hierarchy_id            =>    l_hierarchy_id
      ,p_object_version_number   =>    l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_hierarchy_node'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_hierarchy_id           := l_hierarchy_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_hierarchy_node;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_hierarchy_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_hierarchy_node;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_hierarchy_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_hierarchy_node;

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_hierarchy_node >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_node
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_parent_hierarchy_id           in     number   default hr_api.g_number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_hierarchy_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_hierarchy_node';
  l_language_code       varchar2(30);
  l_object_version_number number := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_hierarchy_node;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk2.update_hierarchy_node_b
      (
       p_language_code           =>    l_language_code
      ,p_parent_hierarchy_id     =>    p_parent_hierarchy_id
      ,p_name                    =>    p_name
      ,p_description             =>    p_description
      ,p_hierarchy_id            =>    p_hierarchy_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hierarchy_node'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_hrc_upd.upd
     (
      p_hierarchy_id            => p_hierarchy_id
     ,p_parent_hierarchy_id     => p_parent_hierarchy_id
     ,p_object_version_number   => p_object_version_number
      );

  hr_htl_upd.upd_tl(
       p_language_code           => l_language_code
      ,p_hierarchy_id            => p_hierarchy_id
      ,p_name                    => p_name
      ,p_description             => p_description
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk2.update_hierarchy_node_a
      (
       p_language_code           =>    l_language_code
      ,p_parent_hierarchy_id     =>    p_parent_hierarchy_id
      ,p_name                    =>    p_name
      ,p_description             =>    p_description
      ,p_hierarchy_id            =>    p_hierarchy_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hierarchy_node'
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
  -- Set all IN OUT and OUT parameters with out values
  --

  -- p_object_version_number  := p_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_hierarchy_node;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_hierarchy_node;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_hierarchy_node;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_hierarchy_node >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_node
  (
   P_VALIDATE                 in boolean         default false
  ,P_HIERARCHY_ID             in number
  ,P_OBJECT_VERSION_NUMBER    in number
  ) is
  --
  -- Declare cursors and local variables
  --

cursor get_child_ids
is
select hierarchy_id,object_version_number from hr_ki_hierarchies
connect by prior
hierarchy_id=parent_hierarchy_id
start with hierarchy_id=p_hierarchy_id order by level desc;

cursor get_node_map_ids(cur_id number)
is
select hierarchy_node_map_id,object_version_number from hr_ki_hierarchy_node_maps
where hierarchy_id =cur_id;

Cursor C_Sel1 is
    select object_version_number
    from        hr_ki_hierarchies
    where       hierarchy_id = p_hierarchy_id;

  l_proc varchar2(72) := g_package||'delete_hierarchy_node';
  l_found number(15);
  l_found_node_map number(15);
  l_no number(9);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_hierarchy_node;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk3.delete_hierarchy_node_b
      (
        p_hierarchy_id           => p_hierarchy_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_hierarchy_node'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --


  --throw error for invalid object_version_number
  -- and invalid hierarchy_id
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'HIERARCHY_ID'
    ,p_argument_value     => p_hierarchy_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into l_no;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> l_no) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;

  --first get the child rows if any for the hierarchy_id

     for hierarchy_rec in get_child_ids
     LOOP

         -- get the hierarchy_node_map_ids
         for node_rec in get_node_map_ids(hierarchy_rec.hierarchy_id)
         LOOP
         --call delete from hierarchy_node_map
         delete_hierarchy_node_map(
              p_hierarchy_node_map_id   => node_rec.hierarchy_node_map_id
             ,p_object_version_number   => node_rec.object_version_number

         );
         end loop;

         --delete hierachy_ids from tl table and then from hierarchies table
          hr_hrc_shd.lck
             (
              p_hierarchy_id            => hierarchy_rec.hierarchy_id
             ,p_object_version_number   => hierarchy_rec.object_version_number
             );
          hr_htl_del.del_tl(
              p_hierarchy_id            =>  hierarchy_rec.hierarchy_id
              );
          hr_hrc_del.del
             (
              p_hierarchy_id            => hierarchy_rec.hierarchy_id
             ,p_object_version_number   => hierarchy_rec.object_version_number
              );


     END LOOP;


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk3.delete_hierarchy_node_a
      (
       p_hierarchy_id            =>    p_hierarchy_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_hierarchy_node'
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
  -- Set all IN OUT and OUT parameters with out values
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_hierarchy_node;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_hierarchy_node;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_hierarchy_node;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_topic_hierarchy_map >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_hierarchy_map
  (p_validate                      in     boolean  default false
  ,p_hierarchy_id                  in     number
  ,p_topic_id                      in     number
  ,p_hierarchy_node_map_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_topic_hierarchy_map';
  l_hierarchy_node_map_id number;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_topic_hierarchy_map;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk4.create_topic_hierarchy_map_b
      (
       p_hierarchy_id               => p_hierarchy_id
      ,p_topic_id                   => p_topic_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic_hierarchy_map'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_hnm_ins.ins
     (
       p_topic_id                => p_topic_id
      ,p_hierarchy_id            => p_hierarchy_id
      ,p_hierarchy_node_map_id   => l_hierarchy_node_map_id
      ,p_object_version_number   => l_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk4.create_topic_hierarchy_map_a
      (
       p_hierarchy_id               => p_hierarchy_id
      ,p_topic_id                   => p_topic_id
      ,p_hierarchy_node_map_id      => p_hierarchy_node_map_id
      ,p_object_version_number      => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic_hierarchy_map'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_hierarchy_node_map_id           := l_hierarchy_node_map_id;
  p_object_version_number           := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_topic_hierarchy_map;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_hierarchy_node_map_id         := null;
    p_object_version_number         := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_topic_hierarchy_map;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_hierarchy_node_map_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_topic_hierarchy_map;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ui_hierarchy_map >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ui_hierarchy_map
  (p_validate                      in     boolean  default false
  ,p_hierarchy_id                  in     number
  ,p_user_interface_id             in     number
  ,p_hierarchy_node_map_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_ui_hierarchy_map';
  l_hierarchy_node_map_id number;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ui_hierarchy_map;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk5.create_ui_hierarchy_map_b
      (
       p_hierarchy_id               => p_hierarchy_id
      ,p_user_interface_id          => p_user_interface_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ui_hierarchy_map'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_hnm_ins.ins
     (
       p_user_interface_id       => p_user_interface_id
      ,p_hierarchy_id            => p_hierarchy_id
      ,p_hierarchy_node_map_id   => l_hierarchy_node_map_id
      ,p_object_version_number   => l_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk5.create_ui_hierarchy_map_a
      (
       p_user_interface_id       => p_user_interface_id
      ,p_hierarchy_id            => p_hierarchy_id
      ,p_hierarchy_node_map_id   => l_hierarchy_node_map_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ui_hierarchy_map'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_hierarchy_node_map_id           := l_hierarchy_node_map_id;
  p_object_version_number           := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ui_hierarchy_map;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_hierarchy_node_map_id         := null;
    p_object_version_number         := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ui_hierarchy_map;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_hierarchy_node_map_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ui_hierarchy_map;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_topic_ui_map >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_ui_map
  (p_validate                      in     boolean  default false
  ,p_topic_id                      in     number
  ,p_user_interface_id             in     number
  ,p_hierarchy_node_map_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_topic_ui_map';
  l_hierarchy_node_map_id number;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_topic_ui_map;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk6.create_topic_ui_map_b
      (
       p_topic_id                   => p_topic_id
      ,p_user_interface_id          => p_user_interface_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic_ui_map'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_hnm_ins.ins
     (
       p_user_interface_id       => p_user_interface_id
      ,p_topic_id                => p_topic_id
      ,p_hierarchy_node_map_id   => l_hierarchy_node_map_id
      ,p_object_version_number   => l_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk6.create_topic_ui_map_a
      (
       p_user_interface_id       => p_user_interface_id
      ,p_topic_id                => p_topic_id
      ,p_hierarchy_node_map_id   => l_hierarchy_node_map_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic_ui_map'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_hierarchy_node_map_id           := l_hierarchy_node_map_id;
  p_object_version_number           := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_topic_ui_map;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_hierarchy_node_map_id         := null;
    p_object_version_number         := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_topic_ui_map;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_hierarchy_node_map_id         := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_topic_ui_map;

--
-- ----------------------------------------------------------------------------
-- |----------------------< update_hierarchy_node_map >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_hierarchy_node_map
  (p_validate                      in     boolean  default false
  ,p_hierarchy_id                  in     number   default hr_api.g_number
  ,p_topic_id                      in     number   default hr_api.g_number
  ,p_user_interface_id             in     number   default hr_api.g_number
  ,p_hierarchy_node_map_id         in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_hierarchy_node_map';
  l_object_version_number number := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_hierarchy_node_map;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk7.update_hierarchy_node_map_b
      (
       p_topic_id                =>    p_topic_id
      ,p_hierarchy_id            =>    p_hierarchy_id
      ,p_user_interface_id       =>    p_user_interface_id
      ,p_hierarchy_node_map_id   =>    p_hierarchy_node_map_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hierarchy_node_map'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_hnm_upd.upd
     (
       p_topic_id                =>    p_topic_id
      ,p_hierarchy_id            =>    p_hierarchy_id
      ,p_user_interface_id       =>    p_user_interface_id
      ,p_hierarchy_node_map_id   =>    p_hierarchy_node_map_id
      ,p_object_version_number   =>    p_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk7.update_hierarchy_node_map_a
      (
       p_topic_id                =>    p_topic_id
      ,p_hierarchy_id            =>    p_hierarchy_id
      ,p_user_interface_id       =>    p_user_interface_id
      ,p_hierarchy_node_map_id   =>    p_hierarchy_node_map_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_hierarchy_node_map'
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
  -- Set all IN OUT and OUT parameters with out values
  --

  -- p_object_version_number  := p_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_hierarchy_node_map;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_hierarchy_node_map;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_hierarchy_node_map;

-- ----------------------------------------------------------------------------
-- |----------------------< delete_hierarchy_node_map >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_hierarchy_node_map
  (
   P_VALIDATE                 in boolean         default false
  ,P_HIERARCHY_NODE_MAP_ID    in number
  ,P_OBJECT_VERSION_NUMBER    in number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc varchar2(72) := g_package||'delete_hierarchy_node_map';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_hierarchy_node_map;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_hierarchies_bk8.delete_hierarchy_node_map_b
      (
        p_hierarchy_node_map_id  => p_hierarchy_node_map_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_hierarchy_node_map'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_hnm_del.del
     (
      p_hierarchy_node_map_id   => p_hierarchy_node_map_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_hierarchies_bk8.delete_hierarchy_node_map_a
      (
       p_hierarchy_node_map_id   =>    p_hierarchy_node_map_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_hierarchy_node_map'
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
  -- Set all IN OUT and OUT parameters with out values
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_hierarchy_node_map;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_hierarchy_node_map;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_hierarchy_node_map;


end HR_KI_HIERARCHIES_API;

/
