--------------------------------------------------------
--  DDL for Package Body HXC_RETRIEVAL_RULE_GRP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RETRIEVAL_RULE_GRP_API" as
/* $Header: hxcrrgapi.pkb 120.2 2005/09/23 06:20:31 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_retrieval_rule_grp_api.';

g_entity_type varchar2(16) := 'RETRIEVAL_RULES';

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_retrieval_rule_grp >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rule_grp
  (p_validate                       in  boolean   default false
  ,p_retrieval_rule_grp_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number     hxc_entity_groups.object_version_number%TYPE;
	l_retrieval_rule_grp_id  hxc_entity_groups.entity_group_id%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --

  --
  if g_debug then
  	l_proc := g_package||' create_retrieval_rule_grp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_retrieval_rule_grp;
  --
  hxc_retrieval_rule_grp_api.chk_name
	(    p_name		=> p_name
	,    p_entity_group_id	=> p_retrieval_rule_grp_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_retrieval_rule_grp_BK_1.create_retrieval_rule_grp_b
	  (p_retrieval_rule_grp_id => p_retrieval_rule_grp_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_retrieval_rule_grp'
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
--
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
--
-- call row handler
--
hxc_heg_ins.ins (
   p_name		=> p_name
  ,p_entity_type	=> g_entity_type
  ,p_entity_group_id 	=> l_retrieval_rule_grp_id
  ,p_object_version_number => l_object_version_number );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_retrieval_rule_grp_BK_1.create_retrieval_rule_grp_a
	  (p_retrieval_rule_grp_id             => l_retrieval_rule_grp_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_retrieval_rule_grp'
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
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
  -- Set all output arguments
  --
  p_retrieval_rule_grp_id            := l_retrieval_rule_grp_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_retrieval_rule_grp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_retrieval_rule_grp_id             := null;
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO create_retrieval_rule_grp;
    raise;
    --
END create_retrieval_rule_grp;
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_retrieval_rule_grp>-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rule_grp
  (p_validate                       in  boolean   default false
  ,p_retrieval_rule_grp_id       in  number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_entity_groups.object_version_number%TYPE := p_object_version_number;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_retrieval_rule_grp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_retrieval_rule_grp;
  --
  hxc_retrieval_rule_grp_api.chk_name
	(    p_name		=> p_name
	,    p_entity_group_id	=> p_retrieval_rule_grp_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_retrieval_rule_grp_BK_2.update_retrieval_rule_grp_b
	  (p_retrieval_rule_grp_id             => p_retrieval_rule_grp_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_retrieval_rule_grp'
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
-- call row handler
--
hxc_heg_upd.upd (
   p_name                  => p_name
  ,p_entity_type           => g_entity_type
  ,p_entity_group_id       => p_retrieval_rule_grp_id
  ,p_object_version_number => l_object_version_number );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_retrieval_rule_grp_BK_2.update_retrieval_rule_grp_a
	  (p_retrieval_rule_grp_id => p_retrieval_rule_grp_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_name                   => p_name
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_retrieval_rule_grp'
        ,p_hook_type   => 'AP'
        );
  end;
  --
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
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_retrieval_rule_grp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 60);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO update_retrieval_rule_grp;
    raise;
    --
END update_retrieval_rule_grp;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_retrieval_rule_grp >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rule_grp
  (p_validate                       in  boolean  default false
  ,p_retrieval_rule_grp_id       in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin
  g_debug := hr_utility.debug_enabled;
  --

  if g_debug then
  	l_proc := g_package||'delete_retrieval_rule_grp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_retrieval_rule_grp;
  --
	chk_delete ( p_entity_group_id => p_retrieval_rule_grp_id );

  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_retrieval_rule_grp_BK_3.delete_retrieval_rule_grp_b
	  (p_retrieval_rule_grp_id => p_retrieval_rule_grp_id
	  ,p_object_version_number    => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_retrieval_rule_grp_b'
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
  hxc_heg_del.del
    (
     p_entity_group_id       => p_retrieval_rule_grp_id
    ,p_object_version_number => p_object_version_number
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
  hxc_retrieval_rule_grp_BK_3.delete_retrieval_rule_grp_a
	  (p_retrieval_rule_grp_id            => p_retrieval_rule_grp_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_retrieval_rule_grp_a'
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
    ROLLBACK TO delete_retrieval_rule_grp;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_retrieval_rule_grp;
    raise;
    --
end delete_retrieval_rule_grp;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- Note:
--      This procedure is called from the client
--
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name            in hxc_entity_groups.name%TYPE
  ,p_entity_group_id in hxc_entity_groups.entity_group_id%TYPE
  ) IS

  l_proc  varchar2(72);
--
-- cursor to check name is unique
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_entity_groups heg
	WHERE	heg.name	= p_name
	AND	heg.entity_type = g_entity_type AND
	( heg.entity_group_id <> p_entity_group_id OR
	  p_entity_group_id IS NULL ) );
--
 l_dup_name varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_name';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the name has been entered
--
IF ( p_name IS NULL )
THEN
--
      hr_utility.set_message(809, 'HXC_HEG_RR_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the name is unique
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_dup_name;
  CLOSE csr_chk_name;
--
IF ( l_dup_name IS NOT NULL )
THEN
--
      hr_utility.set_message(809, 'HXC_HEG_RR_NAME_DUP');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_entity_group_id in hxc_entity_groups.entity_group_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
--
/*
 CURSOR csr_chk_pref IS
 SELECT 'exists'
 FROM	sys.dual
 WHERE	EXISTS (
	SELECT	'x'
	FROM    hxc_resource_all_elig_pref_v
	WHERE	preference_code = 'TS_PER_RETRIEVAL_RULES'
	AND	attribute1	= TO_CHAR(p_entity_group_id) );
*/

 l_exists VARCHAR2(6) := NULL;

 BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- check that entity_group is not being used in the pref hierarchy
-- call function num_hierarchy_occurances to check for data integrity.

  /*OPEN  csr_chk_pref;
    FETCH csr_chk_pref INTO l_exists;
    CLOSE csr_chk_pref;*/

  if g_debug then
  	hr_utility.set_location('Calling num_hierarchy_occurances:'||l_proc,10);
  end if;
  l_exists := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                         ('TS_PER_RETRIEVAL_RULES'
                          ,1
                          ,TO_CHAR(p_entity_group_id));
  if g_debug then
  	hr_utility.set_location('After calling num_hierarchy_occurances:'||l_proc,20);
  end if;
  IF l_exists <> 0 THEN
--
      hr_utility.set_message(809, 'HXC_HEG_RR_IN_USE');
      hr_utility.raise_error;
--
  END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 60);
  end if;
  --
 END chk_delete;
--
END hxc_retrieval_rule_grp_api;

/
