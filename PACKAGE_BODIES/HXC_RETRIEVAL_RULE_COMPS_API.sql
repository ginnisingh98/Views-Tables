--------------------------------------------------------
--  DDL for Package Body HXC_RETRIEVAL_RULE_COMPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RETRIEVAL_RULE_COMPS_API" as
/* $Header: hxcrtcapi.pkb 120.2 2005/09/23 06:21:33 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_retrieval_rule_comps_api.';

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_retrieval_rule_comps >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_retrieval_rule_comps
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_comp_id        in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc   varchar2(72);
  l_object_version_number  hxc_retrieval_rule_comps.object_version_number%TYPE;
  l_retrieval_rule_comp_id hxc_retrieval_rule_comps.retrieval_rule_comp_id%TYPE;
--
Begin
  g_debug := hr_utility.debug_enabled;
--
  if g_debug then
  	l_proc    := g_package||'create_retrieval_rule_comps ';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_retrieval_rule_comps;
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
   hxc_retrieval_rule_comps_bk_1.create_retrieval_rule_comps_b
  (p_retrieval_rule_comp_id  => p_retrieval_rule_comp_id
  ,p_object_version_number   => p_object_version_number
  ,p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_status                  => p_status
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_effective_date          => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_retrieval_rule_comps'
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
  hxc_rtc_ins.ins
  (p_effective_date          => p_effective_date
  ,p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_status                  => p_status
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_retrieval_rule_comp_id  => l_retrieval_rule_comp_id
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
    hxc_retrieval_rule_comps_bk_1.create_retrieval_rule_comps_a
  (p_retrieval_rule_comp_id         => p_retrieval_rule_comp_id
  ,p_object_version_number          => p_object_version_number
  ,p_retrieval_rule_id              => p_retrieval_rule_id
  ,p_status                         => p_status
  ,p_time_recipient_id              => p_time_recipient_id
  ,p_effective_date                 => p_effective_date
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_retrieval_rule_comps'
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
  p_retrieval_rule_comp_id := l_retrieval_rule_comp_id;
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
    rollback to create_retrieval_rule_comps;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_retrieval_rule_comp_id := null;
    p_object_version_number  := null;
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_retrieval_rule_comps;
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
    --
end create_retrieval_rule_comps;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_retrieval_rule_comps>---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_retrieval_rule_comps
  (p_validate                      in     boolean  default false
  ,p_retrieval_rule_comp_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_retrieval_rule_id             in     number
  ,p_status                        in     varchar2
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date     default null
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  l_object_version_number hxc_retrieval_rule_comps.object_version_number%TYPE := p_object_version_number;
  --
Begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_retrieval_rule_comps';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_retrieval_rule_comps;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_retrieval_rule_comps_bk_1.update_retrieval_rule_comps_b
  (p_retrieval_rule_comp_id  => p_retrieval_rule_comp_id
  ,p_object_version_number   => p_object_version_number
  ,p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_status                  => p_status
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_retrieval_rule_comps'
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
hxc_rtc_upd.upd
  (p_effective_date          => p_effective_date
  ,p_retrieval_rule_comp_id  => p_retrieval_rule_comp_id
  ,p_object_version_number   => l_object_version_number
  ,p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_status                  => p_status
  ,p_time_recipient_id       => p_time_recipient_id
  );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_retrieval_rule_comps_bk_1.update_retrieval_rule_comps_a
  (p_retrieval_rule_comp_id  => p_retrieval_rule_comp_id
  ,p_object_version_number   => p_object_version_number
  ,p_retrieval_rule_id       => p_retrieval_rule_id
  ,p_status                  => p_status
  ,p_time_recipient_id       => p_time_recipient_id
  ,p_effective_date          => p_effective_date
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_retrieval_rule_comps'
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
    ROLLBACK TO update_retrieval_rule_comps;
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
    ROLLBACK TO update_retrieval_rule_comps;
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 70);
    end if;
    raise;
    --
END update_retrieval_rule_comps;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_retrieval_rule_comps >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_retrieval_rule_comps
  (p_validate                       in  boolean  default false
  ,p_retrieval_rule_comp_id         in  number
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
  	l_proc := g_package||'delete_retrieval_rule_comps';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_retrieval_rule_comps;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
          hxc_retrieval_rule_comps_bk_1.delete_retrieval_rule_comps_b
          (p_retrieval_rule_comp_id       => p_retrieval_rule_comp_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_retrieval_rule_comps'
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
  hxc_rtc_del.del
    (
     p_retrieval_rule_comp_id       => p_retrieval_rule_comp_id
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
        hxc_retrieval_rule_comps_bk_1.delete_retrieval_rule_comps_a
          (p_retrieval_rule_comp_id       => p_retrieval_rule_comp_id
          ,p_object_version_number        => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_retrieval_rule_comps'
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
    ROLLBACK TO delete_retrieval_rule_comps;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_retrieval_rule_comps;
    raise;
    --
end delete_retrieval_rule_comps;
--
-- Added by ksethi ver 115.4
-- ----------------------------------------------------------------------------
-- |------------------------< chk_retr_as_unique >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a unique Retrieval Rule is only entered
--   in the system
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--
--   retrieval_rule_id
--
--
-- Post Success:
--   Processing continues if the retrieval rule set business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if already another retrieval rule
--   is present in the system with the same Retrieval Process Name,
--   Application and Status
--
-- ----------------------------------------------------------------------------
Procedure chk_retr_as_unique
  (
  p_retrieval_rule_id in hxc_retrieval_rules.retrieval_rule_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check retrieval rule is unique
--
CURSOR  csr_chk_as IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (select a
from (
	  select rc.retrieval_rule_id a,count(*) CNT
	  from hxc_retrieval_rule_comps rc, hxc_retrieval_rules rr
	  where  rr.RETRIEVAL_PROCESS_ID = (select RETRIEVAL_PROCESS_ID
								        from hxc_retrieval_rules
								        where retrieval_rule_id=p_retrieval_rule_id)
	   and    rr.retrieval_rule_id   <> p_retrieval_rule_id
	   and    rc.retrieval_rule_id   <> p_retrieval_rule_id
	   and    rc.retrieval_rule_id   =  rr.retrieval_rule_id
	   and    (rc.TIME_RECIPIENT_ID, rc.STATUS) in  ( select TIME_RECIPIENT_ID, STATUS
	   		  								  	     from hxc_retrieval_rule_comps
													 where retrieval_rule_id   = p_retrieval_rule_id
													 )
      group by rc.retrieval_rule_id

	  )
	  where CNT = (select count(distinct time_recipient_id)
	  			    from hxc_retrieval_rule_comps
					where retrieval_rule_id   = p_retrieval_rule_id)
   and a not in (
	  	  	  	 select retrieval_rule_id
			  	  from  hxc_retrieval_rule_comps
				  where
				  	  (TIME_RECIPIENT_ID, STATUS) not in  ( select TIME_RECIPIENT_ID, STATUS
	   		  								  	     from hxc_retrieval_rule_comps
													 where retrieval_rule_id   = p_retrieval_rule_id
													 )
  				));

--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'chk_retr_as_unique';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that there is no other similat retrieval rule in the system
--
  OPEN  csr_chk_as;
  FETCH csr_chk_as INTO l_error;
  CLOSE csr_chk_as;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_RETR_AS_NOT_UNIQUE');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_retr_as_unique;
--
--
end hxc_retrieval_rule_comps_api;

/
