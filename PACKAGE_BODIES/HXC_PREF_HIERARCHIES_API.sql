--------------------------------------------------------
--  DDL for Package Body HXC_PREF_HIERARCHIES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_PREF_HIERARCHIES_API" as
/* $Header: hxchphapi.pkb 120.2 2005/09/23 10:42:34 sechandr noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_pref_hierarchies_api.';
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_node_data >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This enhancement is to allow the use of the API to load seed data easily.
-- This procedure gets the ID of a node in the hierarchy given the full name
-- of the Preference.get_node_data takes the full name of the preference
-- hierarchy node such as A.B.C and returns the id of the node C in A.B.C
-- So now if node D needs to be added as the child of C ,then id of the node
-- C becomes the p_parent_pref_hierarchy_id for node D.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   preference_full_name
--   p_name
--
-- Post Success:
--   Processing continues if the ID of a preference is determined
--
-- Post Failure:
--   An application error is raised for no_data_found or invalid data
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure get_node_data
  (
   p_preference_full_name     in varchar2
  ,p_name                     in varchar2
  ,p_business_group_id	      in number
  ,p_legislation_code         in varchar2
  ,p_mode                     out nocopy varchar2
  ,p_pref_hierarchy_id        out nocopy number
  ,p_parent_pref_hierarchy_id out nocopy number
  ,p_object_version_number    out nocopy number
   ) IS
--
  l_proc  varchar2(72);

  l_period                   number;
  l_next_period              number;
  l_name                     varchar2(80);

  l_parent_pref_hierarchy_id number       := null;
  l_pref_hierarchy_id        number       := null;
  l_object_version_number    number       := null;
  l_mode                     varchar2(50) := null;

  cursor c_top_node(l_name varchar2) is
       SELECT pref_hierarchy_id,object_version_number
       FROM   hxc_pref_hierarchies
       WHERE  parent_pref_hierarchy_id is null
       AND    name = l_name;

  cursor c_child_nodes(l_parent_pref_hierarchy_id number,l_name varchar2) is
       SELECT pref_hierarchy_id,object_version_number
       FROM   hxc_pref_hierarchies
       WHERE  parent_pref_hierarchy_id = l_parent_pref_hierarchy_id
       AND    name = l_name;

--
begin
--
g_debug:=hr_utility.debug_enabled;
if g_debug then
	l_proc := g_package||'get_node_data';
end if;
if p_preference_full_name is not null then

   if g_debug then
	hr_utility.set_location('Entering:'||l_proc, 5);
   end if;

   -- Consider preference_full_name A.B.C being passed.In this case the ID of node
   -- C needs to be calculated.
   -- Loop till the instr function,which gives the position of the next period in
   -- the string,returns 0 implying that the end of the string is reached.

   l_period := 0;

   -- This loop gives the parent_pref_hierarchy_id for new node to be created

    WHILE l_period <> (length(p_preference_full_name) + 1) LOOP

      -- find the position of the delimiter

      l_next_period := instr(p_preference_full_name,'.',l_period + 1,1);

      -- if l_next_period is 0,i.e.,another delimiter could not be found,implies
      -- that end of the sring is reached.

      if (l_next_period = 0) then
          l_next_period := length(p_preference_full_name) + 1;
      end if;

      -- get the name of the preference(i.e., the text between the two delimiters)

      l_name := substr(p_preference_full_name,l_period + 1,l_next_period
                                                           - (l_period + 1));

      -- get the id of the preference with this name(l_name)

      if (l_parent_pref_hierarchy_id is null) then

         open c_top_node(l_name);
         fetch c_top_node into l_parent_pref_hierarchy_id,l_object_version_number;
         close c_top_node;

      else

         open c_child_nodes(l_parent_pref_hierarchy_id,l_name);
         fetch c_child_nodes into l_parent_pref_hierarchy_id,l_object_version_number;
         if c_child_nodes%notfound then
            close c_child_nodes;

            -- since no data found therefore we must error
            fnd_message.set_name('HXC', 'HXC_PREF_FULL_NAME_NOT_EXIST');
            fnd_message.raise_error;
         end if;

         close c_child_nodes;

      end if;

      l_period := l_next_period;

    end loop;

    open c_child_nodes(l_parent_pref_hierarchy_id,p_name);
    fetch c_child_nodes into l_pref_hierarchy_id,l_object_version_number;

    -- set the OUT parameter
    if c_child_nodes%found then
       l_mode                     := 'UPDATE';
    else
       l_mode                     := 'INSERT';
       l_pref_hierarchy_id        := null;
       l_object_version_number    := null;
    end if;
    close c_child_nodes;

elsif p_preference_full_name is null then
    l_name := p_name;
    open c_top_node(l_name);
    fetch c_top_node into l_pref_hierarchy_id,l_object_version_number;

       if l_pref_hierarchy_id is null then
        l_mode := 'INSERT';
       else
        l_mode := 'UPDATE';
       end if;
    close c_top_node;

end if;

p_mode                     := l_mode;
p_pref_hierarchy_id        := l_pref_hierarchy_id;
p_object_version_number    := l_object_version_number;
p_parent_pref_hierarchy_id := l_parent_pref_hierarchy_id;

if g_debug then
	hr_utility.set_location('Leaving :'||l_proc, 10);
end if;

end get_node_data;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pref_hierarchies >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pref_hierarchies
  (p_validate                      in     boolean  default false
  ,p_pref_hierarchy_id             in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_type                          in     varchar2 default null
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_parent_pref_hierarchy_id      in     number   default null
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number   default null
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
  ,p_orig_pref_hierarchy_id        in     number   default null
  ,p_orig_parent_hierarchy_id      in     number   default null
  ,p_effective_date                in     date     default null
  ,p_top_level_parent_id           in     number   default null --Performance Fix
  ,p_code	                   in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72);
  l_object_version_number hxc_pref_hierarchies.object_version_number%TYPE;
  l_pref_hierarchy_id     hxc_pref_hierarchies.pref_hierarchy_id%TYPE;
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'create_pref_hierarchies';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_pref_hierarchies;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_pref_hierarchies_bk_1.create_pref_hierarchies_b
      (p_pref_hierarchy_id        => p_pref_hierarchy_id
      ,p_object_version_number    => p_object_version_number
      ,p_type                     => p_type
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_parent_pref_hierarchy_id => p_parent_pref_hierarchy_id
      ,p_edit_allowed             => p_edit_allowed
      ,p_displayed                => p_displayed
      ,p_pref_definition_id       => p_pref_definition_id
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_orig_pref_hierarchy_id   => p_orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id => p_orig_parent_hierarchy_id
      ,p_effective_date           => p_effective_date
      ,p_top_level_parent_id      => p_top_level_parent_id --Performance Fix
      ,p_code	                  => p_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pref_hierarchies'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 30);
  end if;
  --
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- call row handler
  --
  hxc_hph_ins.ins
      (p_pref_hierarchy_id        => l_pref_hierarchy_id
      ,p_object_version_number    => l_object_version_number
      ,p_type                     => p_type
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_parent_pref_hierarchy_id => p_parent_pref_hierarchy_id
      ,p_edit_allowed             => p_edit_allowed
      ,p_displayed                => p_displayed
      ,p_pref_definition_id       => p_pref_definition_id
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_orig_pref_hierarchy_id   => p_orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id => p_orig_parent_hierarchy_id
      ,p_effective_date           => p_effective_date
      ,p_top_level_parent_id      => p_top_level_parent_id --Performance Fix
      ,p_code	                  => p_code
      );
  --
  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_pref_hierarchies_bk_1.create_pref_hierarchies_a
      (p_pref_hierarchy_id        => p_pref_hierarchy_id
      ,p_object_version_number    => p_object_version_number
      ,p_type                     => p_type
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_parent_pref_hierarchy_id => p_parent_pref_hierarchy_id
      ,p_edit_allowed             => p_edit_allowed
      ,p_displayed                => p_displayed
      ,p_pref_definition_id       => p_pref_definition_id
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_orig_pref_hierarchy_id   => p_orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id => p_orig_parent_hierarchy_id
      ,p_effective_date           => p_effective_date
      ,p_top_level_parent_id      => p_top_level_parent_id --Performance Fix
      ,p_code	                  => p_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_pref_hierarchies'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --if g_debug then
	--hr_utility.set_location(' Leaving:'||l_proc, 70);
  --end if;
  --
  --
  -- Set all output arguments
  --
  p_pref_hierarchy_id      := l_pref_hierarchy_id;
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_pref_hierarchies;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pref_hierarchy_id      := null;
    p_object_version_number  := null;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_pref_hierarchies;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_pref_hierarchies;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_pref_hierarchies>------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pref_hierarchies
  (p_validate                      in     boolean  default false
  ,p_pref_hierarchy_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_type                          in     varchar2 default null
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_parent_pref_hierarchy_id      in     number   default null
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number   default null
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
  ,p_orig_pref_hierarchy_id        in     number   default null
  ,p_orig_parent_hierarchy_id      in     number   default null
  ,p_effective_date                in     date     default null
  ,p_top_level_parent_id           in     number   default null --Performance Fix
  ,p_code	                   in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_pref_hierarchies.object_version_number%TYPE := p_object_version_number;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||' update_pref_hierarchies';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_pref_hierarchies;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
   hxc_pref_hierarchies_bk_1.update_pref_hierarchies_b
      (p_pref_hierarchy_id        => p_pref_hierarchy_id
      ,p_object_version_number    => p_object_version_number
      ,p_type                     => p_type
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_parent_pref_hierarchy_id => p_parent_pref_hierarchy_id
      ,p_edit_allowed             => p_edit_allowed
      ,p_displayed                => p_displayed
      ,p_pref_definition_id       => p_pref_definition_id
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_orig_pref_hierarchy_id   => p_orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id => p_orig_parent_hierarchy_id
      ,p_effective_date           => p_effective_date
      ,p_top_level_parent_id      => p_top_level_parent_id  --Performance Fix
      ,p_code	                  => p_code
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pref_hierarchies'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --insert into mtemp values('out of comp_b');
  --commit;
  --if g_debug then
	--hr_utility.set_location(l_proc, 30);
  --end if;
  --
  -- Process Logic
--
-- call row handler
--
--insert into mtemp values('calling hxc_hac_upd.upd');
 -- commit;
hxc_hph_upd.upd
      (p_pref_hierarchy_id        => p_pref_hierarchy_id
      ,p_object_version_number    => l_object_version_number
      ,p_type                     => p_type
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_parent_pref_hierarchy_id => p_parent_pref_hierarchy_id
      ,p_edit_allowed             => p_edit_allowed
      ,p_displayed                => p_displayed
      ,p_pref_definition_id       => p_pref_definition_id
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_orig_pref_hierarchy_id   => p_orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id => p_orig_parent_hierarchy_id
      ,p_effective_date           => p_effective_date
      ,p_top_level_parent_id      => p_top_level_parent_id --Performance Fix
      ,p_code	                  => p_code
      );
--
  --
  --insert into mtemp values('out of hax_hac_upd');
  --commit;

  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
   hxc_pref_hierarchies_bk_1.update_pref_hierarchies_a
      (p_pref_hierarchy_id        => p_pref_hierarchy_id
      ,p_object_version_number    => p_object_version_number
      ,p_type                     => p_type
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_parent_pref_hierarchy_id => p_parent_pref_hierarchy_id
      ,p_edit_allowed             => p_edit_allowed
      ,p_displayed                => p_displayed
      ,p_pref_definition_id       => p_pref_definition_id
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_orig_pref_hierarchy_id   => p_orig_pref_hierarchy_id
      ,p_orig_parent_hierarchy_id => p_orig_parent_hierarchy_id
      ,p_effective_date           => p_effective_date
      ,p_top_level_parent_id      => p_top_level_parent_id --Performance Fix
      ,p_code	                  => p_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_pref_hierarchies'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --insert into mtemp values('out of comp_a');
  --commit;

  if g_debug then
	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 60);
  end if;
  --
  -- Set all output arguments
  --
  --
  --insert into mtemp values('setting OVN value ');
  --commit;

  p_object_version_number := l_object_version_number;
  --
  --insert into mtemp values('OVN value set');
  --commit;

exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_pref_hierarchies;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    --insert into mtemp values('OVN set to null');
    --commit;

    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 60);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_pref_hierarchies;
    if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_pref_hierarchies;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pref_hierarchies >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pref_hierarchies
  (p_validate                       in  boolean  default false
  ,p_pref_hierarchy_id              in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  --
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_pref_hierarchies';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_pref_hierarchies;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
         hxc_pref_hierarchies_bk_1.delete_pref_hierarchies_b
          (p_pref_hierarchy_id     => p_pref_hierarchy_id
          ,p_object_version_number => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pref_hierarchies'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
  hxc_hph_del.del
    (
     p_pref_hierarchy_id           => p_pref_hierarchy_id
    ,p_object_version_number       => p_object_version_number
    );
  --
  if g_debug then
	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  --
         hxc_pref_hierarchies_bk_1.delete_pref_hierarchies_a
          (p_pref_hierarchy_id      => p_pref_hierarchy_id
          ,p_object_version_number  => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_pref_hierarchies'
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
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_pref_hierarchies;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_pref_hierarchies;
    raise;
    --
end delete_pref_hierarchies;
--
end hxc_pref_hierarchies_api;

/
