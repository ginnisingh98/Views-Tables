--------------------------------------------------------
--  DDL for Package Body HXC_RETRIEVAL_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RETRIEVAL_RULES_API" as
/* $Header: hxcrtrapi.pkb 120.2 2005/09/23 06:22:25 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_retrieval_rules_api.';

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_retrieval_rules >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rules
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_id             in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number hxc_retrieval_rules.object_version_number%TYPE;
  l_retrieval_rule_id     hxc_retrieval_rules.retrieval_rule_id%TYPE;
--
Begin
  g_debug := hr_utility.debug_enabled;
--
  if g_debug then
  	l_proc   := g_package||'create_retrieval_rules ';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_retrieval_rules;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
   hxc_retrieval_rules_bk_1.create_retrieval_rules_b
  (p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_object_version_number   => p_object_version_number
  ,p_retrieval_process_id    => p_retrieval_process_id
  ,p_name                    => p_name
  ,p_effective_date          => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_retrieval_rules'
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
  hxc_rtr_ins.ins
  (p_effective_date          => p_effective_date
  ,p_retrieval_process_id    => p_retrieval_process_id
  ,p_name                    => p_name
  ,p_retrieval_rule_id       => l_retrieval_rule_id
  ,p_object_version_number   => l_object_version_number
  );
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_retrieval_rules_bk_1.create_retrieval_rules_a
  (p_retrieval_rule_id              => p_retrieval_rule_id
  ,p_object_version_number          => p_object_version_number
  ,p_retrieval_process_id           => p_retrieval_process_id
  ,p_name                           => p_name
  ,p_effective_date                 => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_retrieval_rules'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 60);
  end if;
  --
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
  p_retrieval_rule_id      := l_retrieval_rule_id;
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
    rollback to create_retrieval_rules;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_retrieval_rule_id      := null;
    p_object_version_number  := null;
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_retrieval_rules;
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_retrieval_rules;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_retrieval_rules>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rules
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_process_id          in     number
  ,p_name                          in     varchar2
  ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_retrieval_rules.object_version_number%TYPE := p_object_version_number;
  --
Begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_retrieval_rules';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_retrieval_rules;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_retrieval_rules_bk_1.update_retrieval_rules_b
  (p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_object_version_number   => p_object_version_number
  ,p_retrieval_process_id    => p_retrieval_process_id
  ,p_name                    => p_name
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_retrieval_rules'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --if g_debug then
  	--hr_utility.set_location(l_proc, 30);
  --end if;
  --
  -- Process Logic
--
-- call row handler
--
hxc_rtr_upd.upd
  (p_effective_date          => p_effective_date
  ,p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_object_version_number   => l_object_version_number
  ,p_retrieval_process_id    => p_retrieval_process_id
  ,p_name                    => p_name
  );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_retrieval_rules_bk_1.update_retrieval_rules_a
  (p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_object_version_number   => p_object_version_number
  ,p_retrieval_process_id    => p_retrieval_process_id
  ,p_name                    => p_name
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_retrieval_rules'
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
    ROLLBACK TO update_retrieval_rules;
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
    ROLLBACK TO update_retrieval_rules;
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_retrieval_rules;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_retrieval_rules >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rules
  (p_validate                       in  boolean  default false
  ,p_retrieval_rule_id              in  number
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
  	l_proc := g_package||'delete_retrieval_rules';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_retrieval_rules;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_retrieval_rules_bk_1.delete_retrieval_rules_b
          (p_retrieval_rule_id            => p_retrieval_rule_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_retrieval_rules'
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
  hxc_rtr_del.del
    (
     p_retrieval_rule_id            => p_retrieval_rule_id
    ,p_object_version_number        => p_object_version_number
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
        hxc_retrieval_rules_bk_1.delete_retrieval_rules_a
          (p_retrieval_rule_id            => p_retrieval_rule_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_retrieval_rules'
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
    ROLLBACK TO delete_retrieval_rules;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_retrieval_rules;
    raise;
    --
end delete_retrieval_rules;
--
end hxc_retrieval_rules_api;

/
