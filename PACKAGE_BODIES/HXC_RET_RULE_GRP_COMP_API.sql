--------------------------------------------------------
--  DDL for Package Body HXC_RET_RULE_GRP_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RET_RULE_GRP_COMP_API" as
/* $Header: hxcrrcapi.pkb 120.3 2005/10/25 22:40:48 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_ret_rule_grp_comp_api.';

g_entity_type varchar2(16) := 'RETRIEVAL_RULES';

g_debug boolean := hr_utility.debug_enabled;

-- ----------------------------------------------------------------------------
-- |--------------------< create_ret_rule_grp_comp>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ret_rule_grp_comp
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_ret_rule_grp_comp_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_retrieval_rule_id             in     number
  ,p_retrieval_rule_grp_id       in     number
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
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_called_from_form               in     varchar2 default 'Y' -- NOTE: default to Y because no DF for Retrieval Rules
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_entity_group_comps.object_version_number%TYPE;
	l_ret_rule_grp_comp_id hxc_entity_group_comps.entity_group_comp_id%TYPE;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --

  --
  if g_debug then
  	l_proc := g_package||' create_ret_rule_grp_comp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ret_rule_grp_comp;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;

	chk_rr_unique (  p_ret_rule_grp_comp_id	        => p_ret_rule_grp_comp_id
			,p_retrieval_rule_grp_id	        => p_retrieval_rule_grp_id
			,p_retrieval_rule_id	                => p_retrieval_rule_id );

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_ret_rule_grp_comp_BK_1.create_ret_rule_grp_comp_b
	  (p_ret_rule_grp_comp_id  => p_ret_rule_grp_comp_id
	  ,p_object_version_number  => p_object_version_number
          ,p_retrieval_rule_id         => p_retrieval_rule_id
          ,p_retrieval_rule_grp_id   => p_retrieval_rule_grp_id
          ,p_attribute_category    => p_attribute_category
          ,p_attribute1            => p_attribute1
          ,p_attribute2            => p_attribute2
          ,p_attribute3            => p_attribute3
          ,p_attribute4            => p_attribute4
          ,p_attribute5            => p_attribute5
          ,p_attribute6            => p_attribute6
          ,p_attribute7            => p_attribute7
          ,p_attribute8            => p_attribute8
          ,p_attribute9            => p_attribute9
          ,p_attribute10           => p_attribute10
          ,p_attribute11           => p_attribute11
          ,p_attribute12           => p_attribute12
          ,p_attribute13           => p_attribute13
          ,p_attribute14           => p_attribute14
          ,p_attribute15           => p_attribute15
          ,p_attribute16           => p_attribute16
          ,p_attribute17           => p_attribute17
          ,p_attribute18           => p_attribute18
          ,p_attribute19           => p_attribute19
          ,p_attribute20           => p_attribute20
          ,p_attribute21           => p_attribute21
          ,p_attribute22           => p_attribute22
          ,p_attribute23           => p_attribute23
          ,p_attribute24           => p_attribute24
          ,p_attribute25           => p_attribute25
          ,p_attribute26           => p_attribute26
          ,p_attribute27           => p_attribute27
          ,p_attribute28           => p_attribute28
          ,p_attribute29           => p_attribute29
          ,p_attribute30           => p_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ret_rule_grp_comp'
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
hxc_egc_ins.ins (
   p_effective_date       => p_effective_date
  ,p_entity_id            => p_retrieval_rule_id
  ,p_entity_type          => g_entity_type
  ,p_entity_group_id  	  => p_retrieval_rule_grp_id
  ,p_entity_group_comp_id => l_ret_rule_grp_comp_id
  ,p_object_version_number => l_object_version_number
  ,p_attribute_category    => p_attribute_category
  ,p_attribute1            => p_attribute1
  ,p_attribute2            => p_attribute2
  ,p_attribute3            => p_attribute3
  ,p_attribute4            => p_attribute4
  ,p_attribute5            => p_attribute5
  ,p_attribute6            => p_attribute6
  ,p_attribute7            => p_attribute7
  ,p_attribute8            => p_attribute8
  ,p_attribute9            => p_attribute9
  ,p_attribute10           => p_attribute10
  ,p_attribute11           => p_attribute11
  ,p_attribute12           => p_attribute12
  ,p_attribute13           => p_attribute13
  ,p_attribute14           => p_attribute14
  ,p_attribute15           => p_attribute15
  ,p_attribute16           => p_attribute16
  ,p_attribute17           => p_attribute17
  ,p_attribute18           => p_attribute18
  ,p_attribute19           => p_attribute19
  ,p_attribute20           => p_attribute20
  ,p_attribute21           => p_attribute21
  ,p_attribute22           => p_attribute22
  ,p_attribute23           => p_attribute23
  ,p_attribute24           => p_attribute24
  ,p_attribute25           => p_attribute25
  ,p_attribute26           => p_attribute26
  ,p_attribute27           => p_attribute27
  ,p_attribute28           => p_attribute28
  ,p_attribute29           => p_attribute29
  ,p_attribute30           => p_attribute30
  ,p_called_from_form      => p_called_from_form );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_ret_rule_grp_comp_BK_1.create_ret_rule_grp_comp_a
	  (p_ret_rule_grp_comp_id  => l_ret_rule_grp_comp_id
	  ,p_object_version_number          => l_object_version_number
          ,p_retrieval_rule_id             => p_retrieval_rule_id
          ,p_retrieval_rule_grp_id       => p_retrieval_rule_grp_id
          ,p_attribute_category    => p_attribute_category
          ,p_attribute1            => p_attribute1
          ,p_attribute2            => p_attribute2
          ,p_attribute3            => p_attribute3
          ,p_attribute4            => p_attribute4
          ,p_attribute5            => p_attribute5
          ,p_attribute6            => p_attribute6
          ,p_attribute7            => p_attribute7
          ,p_attribute8            => p_attribute8
          ,p_attribute9            => p_attribute9
          ,p_attribute10           => p_attribute10
          ,p_attribute11           => p_attribute11
          ,p_attribute12           => p_attribute12
          ,p_attribute13           => p_attribute13
          ,p_attribute14           => p_attribute14
          ,p_attribute15           => p_attribute15
          ,p_attribute16           => p_attribute16
          ,p_attribute17           => p_attribute17
          ,p_attribute18           => p_attribute18
          ,p_attribute19           => p_attribute19
          ,p_attribute20           => p_attribute20
          ,p_attribute21           => p_attribute21
          ,p_attribute22           => p_attribute22
          ,p_attribute23           => p_attribute23
          ,p_attribute24           => p_attribute24
          ,p_attribute25           => p_attribute25
          ,p_attribute26           => p_attribute26
          ,p_attribute27           => p_attribute27
          ,p_attribute28           => p_attribute28
          ,p_attribute29           => p_attribute29
          ,p_attribute30           => p_attribute30 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ret_rule_grp_comp'
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
  p_ret_rule_grp_comp_id := l_ret_rule_grp_comp_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ret_rule_grp_comp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ret_rule_grp_comp_id := null;
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
    ROLLBACK TO create_ret_rule_grp_comp;
    raise;
    --
END create_ret_rule_grp_comp;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ret_rule_grp_comp>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ret_rule_grp_comp
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_ret_rule_grp_comp_id  in  number
  ,p_object_version_number          in  out nocopy number
  ,p_retrieval_rule_id             in      number
  ,p_retrieval_rule_grp_id       in      number
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
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_called_from_form               in     varchar2 default 'Y' -- NOTE: default to Y because no DF for Retrieval Rules
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_entity_group_comps.object_version_number%TYPE := p_object_version_number;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_ret_rule_grp_comp';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ret_rule_grp_comp;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;

	chk_rr_unique (  p_ret_rule_grp_comp_id	=> p_ret_rule_grp_comp_id
			,p_retrieval_rule_grp_id	        => p_retrieval_rule_grp_id
			,p_retrieval_rule_id	        	=> p_retrieval_rule_id );

  --
  -- Call Before Process User Hook
  --
  begin
    hxc_ret_rule_grp_comp_BK_2.update_ret_rule_grp_comp_b
	  (p_ret_rule_grp_comp_id  => p_ret_rule_grp_comp_id
	  ,p_object_version_number  => p_object_version_number
          ,p_retrieval_rule_id         => p_retrieval_rule_id
          ,p_retrieval_rule_grp_id   => p_retrieval_rule_grp_id
          ,p_attribute_category    => p_attribute_category
          ,p_attribute1            => p_attribute1
          ,p_attribute2            => p_attribute2
          ,p_attribute3            => p_attribute3
          ,p_attribute4            => p_attribute4
          ,p_attribute5            => p_attribute5
          ,p_attribute6            => p_attribute6
          ,p_attribute7            => p_attribute7
          ,p_attribute8            => p_attribute8
          ,p_attribute9            => p_attribute9
          ,p_attribute10           => p_attribute10
          ,p_attribute11           => p_attribute11
          ,p_attribute12           => p_attribute12
          ,p_attribute13           => p_attribute13
          ,p_attribute14           => p_attribute14
          ,p_attribute15           => p_attribute15
          ,p_attribute16           => p_attribute16
          ,p_attribute17           => p_attribute17
          ,p_attribute18           => p_attribute18
          ,p_attribute19           => p_attribute19
          ,p_attribute20           => p_attribute20
          ,p_attribute21           => p_attribute21
          ,p_attribute22           => p_attribute22
          ,p_attribute23           => p_attribute23
          ,p_attribute24           => p_attribute24
          ,p_attribute25           => p_attribute25
          ,p_attribute26           => p_attribute26
          ,p_attribute27           => p_attribute27
          ,p_attribute28           => p_attribute28
          ,p_attribute29           => p_attribute29
          ,p_attribute30           => p_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ret_rule_grp_comp'
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
hxc_egc_upd.upd (
   p_effective_date        => p_effective_date
  ,p_entity_id		   => p_retrieval_rule_id
  ,p_entity_type	   => g_entity_type
  ,p_entity_group_id       => p_retrieval_rule_grp_id
  ,p_entity_group_comp_id  => p_ret_rule_grp_comp_id
  ,p_object_version_number => l_object_version_number
  ,p_attribute_category    => p_attribute_category
  ,p_attribute1            => p_attribute1
  ,p_attribute2            => p_attribute2
  ,p_attribute3            => p_attribute3
  ,p_attribute4            => p_attribute4
  ,p_attribute5            => p_attribute5
  ,p_attribute6            => p_attribute6
  ,p_attribute7            => p_attribute7
  ,p_attribute8            => p_attribute8
  ,p_attribute9            => p_attribute9
  ,p_attribute10           => p_attribute10
  ,p_attribute11           => p_attribute11
  ,p_attribute12           => p_attribute12
  ,p_attribute13           => p_attribute13
  ,p_attribute14           => p_attribute14
  ,p_attribute15           => p_attribute15
  ,p_attribute16           => p_attribute16
  ,p_attribute17           => p_attribute17
  ,p_attribute18           => p_attribute18
  ,p_attribute19           => p_attribute19
  ,p_attribute20           => p_attribute20
  ,p_attribute21           => p_attribute21
  ,p_attribute22           => p_attribute22
  ,p_attribute23           => p_attribute23
  ,p_attribute24           => p_attribute24
  ,p_attribute25           => p_attribute25
  ,p_attribute26           => p_attribute26
  ,p_attribute27           => p_attribute27
  ,p_attribute28           => p_attribute28
  ,p_attribute29           => p_attribute29
  ,p_attribute30           => p_attribute30
  ,p_called_from_form      => p_called_from_form );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_ret_rule_grp_comp_BK_2.update_ret_rule_grp_comp_a
	  (p_ret_rule_grp_comp_id  => p_ret_rule_grp_comp_id
	  ,p_object_version_number  => l_object_version_number
          ,p_retrieval_rule_id         => p_retrieval_rule_id
          ,p_retrieval_rule_grp_id   => p_retrieval_rule_grp_id
          ,p_attribute_category    => p_attribute_category
          ,p_attribute1            => p_attribute1
          ,p_attribute2            => p_attribute2
          ,p_attribute3            => p_attribute3
          ,p_attribute4            => p_attribute4
          ,p_attribute5            => p_attribute5
          ,p_attribute6            => p_attribute6
          ,p_attribute7            => p_attribute7
          ,p_attribute8            => p_attribute8
          ,p_attribute9            => p_attribute9
          ,p_attribute10           => p_attribute10
          ,p_attribute11           => p_attribute11
          ,p_attribute12           => p_attribute12
          ,p_attribute13           => p_attribute13
          ,p_attribute14           => p_attribute14
          ,p_attribute15           => p_attribute15
          ,p_attribute16           => p_attribute16
          ,p_attribute17           => p_attribute17
          ,p_attribute18           => p_attribute18
          ,p_attribute19           => p_attribute19
          ,p_attribute20           => p_attribute20
          ,p_attribute21           => p_attribute21
          ,p_attribute22           => p_attribute22
          ,p_attribute23           => p_attribute23
          ,p_attribute24           => p_attribute24
          ,p_attribute25           => p_attribute25
          ,p_attribute26           => p_attribute26
          ,p_attribute27           => p_attribute27
          ,p_attribute28           => p_attribute28
          ,p_attribute29           => p_attribute29
          ,p_attribute30           => p_attribute30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ret_rule_grp_comp'
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
    ROLLBACK TO update_ret_rule_grp_comp;
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
    ROLLBACK TO update_ret_rule_grp_comp;
    raise;
    --
END update_ret_rule_grp_comp;
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_ret_rule_grp_comp >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ret_rule_grp_comp
  (p_validate                       in  boolean  default false
  ,p_ret_rule_grp_comp_id  in  number
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
	l_proc := g_package||'delete_ret_rule_grp_comp';
	hr_utility.set_location('Entering:'|| l_proc, 10);
end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ret_rule_grp_comp;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;

  -- Call Before Process User Hook

  begin
  --
    hxc_ret_rule_grp_comp_BK_3.delete_ret_rule_grp_comp_b
	  (p_ret_rule_grp_comp_id => p_ret_rule_grp_comp_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ret_rule_grp_comp_b'
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
  hxc_egc_del.del
    (
     p_entity_group_comp_id => p_ret_rule_grp_comp_id
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
  hxc_ret_rule_grp_comp_BK_3.delete_ret_rule_grp_comp_a
	  (p_ret_rule_grp_comp_id => p_ret_rule_grp_comp_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ret_rule_grp_comp_a'
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
    ROLLBACK TO delete_ret_rule_grp_comp;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ret_rule_grp_comp;
    raise;
    --
end delete_ret_rule_grp_comp;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_rr_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a unique retrieval rule per grouping
--   and that the retrival process for a rule is not duplicated
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   ret_rule_grp_comp_id
--   retrieval_rule_grp_id
--   retrieval_rule_id
--
-- Post Success:
--   Processing continues if the entity id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the as id is not unique
--
-- ----------------------------------------------------------------------------
Procedure chk_rr_unique
  (
   p_ret_rule_grp_comp_id    in hxc_entity_group_comps.entity_group_comp_id%TYPE
,  p_retrieval_rule_grp_id    in hxc_entity_group_comps.entity_group_id%TYPE
,  p_retrieval_rule_id          in hxc_entity_group_comps.entity_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check rr is unique
--
CURSOR  csr_chk_rr IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_entity_group_comps egc
	WHERE	egc.entity_group_id	= p_retrieval_rule_grp_id
	AND	egc.entity_id		= p_retrieval_rule_id
	AND	(  egc.entity_group_comp_id <> p_ret_rule_grp_comp_id
		OR p_ret_rule_grp_comp_id IS NULL ));

CURSOR  csr_chk_rr_ret_proc IS
SELECT 'error'
FROM	hxc_retrieval_rules_v rr1
WHERE   rr1.retrieval_rule_id = p_retrieval_rule_id
AND EXISTS (
	SELECT 'x'
	FROM	hxc_retrieval_rules_v rr2
	,	hxc_retrieval_rule_grp_comps_v rrc
	,	hxc_retrieval_rule_groups_v rrg
	WHERE	rrg.retrieval_rule_group_id = p_retrieval_rule_grp_id
	AND	rrc.retrieval_rule_group_id = rrg.retrieval_rule_group_id
	AND	rr2.retrieval_rule_id       = rrc.retrieval_rule_id
 	AND	rr2.retrieval_rule_id       <> rr1.retrieval_rule_id
	AND	rr2.retrieval_process_id    =  rr1.retrieval_process_id );

--
 l_error varchar2(5) := NULL;
--
BEGIN
  if g_debug then
  	l_proc := g_package||'chk_rr_unique';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- check that rr is unique within the grouping

  OPEN  csr_chk_rr;
  FETCH csr_chk_rr INTO l_error;
  CLOSE csr_chk_rr;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_RR_NOT_UNIQUE');
      hr_utility.raise_error;
--
END IF;
--
  OPEN  csr_chk_rr_ret_proc;
  FETCH csr_chk_rr_ret_proc INTO l_error;
  CLOSE csr_chk_rr_ret_proc;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_EGC_RR_RETRIEVAL_DUP');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_rr_unique;
--
END hxc_ret_rule_grp_comp_api;

/
