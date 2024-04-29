--------------------------------------------------------
--  DDL for Package Body HXC_TK_GROUP_QUERY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TK_GROUP_QUERY_API" as
/* $Header: hxctkgqapi.pkb 120.2 2005/09/23 09:20:33 rchennur noship $ */
--
-- Package Variables
--
g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := '  hxc_tk_group_query_api.';

-- ----------------------------------------------------------------------------
-- |--------------------------< create_tk_group_query >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a timekeeper group query with a given name
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new tk group query
--                                                is created. Default is FALSE.
--   p_tk_group_query_id            No   number   Primary Key for timekeeper group query group query
--   p_tk_group_id                  Yes  number   Foreign Key for timekeeper group query group
--   p_object_version_number        No   number   Object Version Number
--   p_group_query_name             Yes  varchar2 tk group Name for the tk_group_query
--   p_include_exclude              Yes  varchar2 Include or Exclude flag
--   p_system_user                  Yes  varchar2 System or User flag
--
-- Post Success:
--
-- when the tk_group_query has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_tk_group_query_id            Number   Primary Key for the new tk group query
--   p_object_version_number        Number   Object version number for the
--                                           new tk group
--
-- Post Failure:
--
-- The timekeeper group query will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_tk_group_query
  (p_validate                       in  boolean   default false
  ,p_tk_group_query_id              in  out nocopy number
  ,p_tk_group_id                    in  number
  ,p_object_version_number          in  out nocopy number
  ,p_group_query_name                  in     varchar2
  ,p_include_exclude                in  varchar2
  ,p_system_user                    in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72) ;
	l_object_version_number     hxc_tk_group_queries.object_version_number%TYPE;
	l_tk_group_query_id  hxc_tk_group_queries.tk_group_query_id%TYPE;
  --
begin
  g_debug :=hr_utility.debug_enabled;
  --
  --
  if g_debug then
  	  l_proc := g_package||' create_tk_group_query';
  	  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_tk_group_query;
  --
  hxc_tk_group_query_api.chk_name
	(    p_group_query_name	 => p_group_query_name
	,    p_tk_group_id        => p_tk_group_id
	,    p_tk_group_query_id => p_tk_group_query_id );

  hxc_tk_group_query_api.chk_tk_group_id ( p_tk_group_id => p_tk_group_id );

  if g_debug then
  	  hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_tk_group_query_BK_1.create_tk_group_query_b
	  (p_tk_group_query_id      => p_tk_group_query_id
	  ,p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_group_query_name          => p_group_query_name
          ,p_include_exclude        => p_include_exclude
          ,p_system_user            => p_system_user
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_tk_group_query'
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
hxc_tkgq_ins.ins (
   p_group_query_name	=> p_group_query_name
  ,p_tk_group_query_id  => l_tk_group_query_id
  ,p_tk_group_id 	=> p_tk_group_id
  ,p_include_exclude    => p_include_exclude
  ,p_system_user        => p_system_user
  ,p_object_version_number => l_object_version_number );
--
  if g_debug then
  	  hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_tk_group_query_BK_1.create_tk_group_query_a
	  (p_tk_group_query_id      => l_tk_group_query_id
	  ,p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_group_query_name          => p_group_query_name
          ,p_include_exclude    => p_include_exclude
          ,p_system_user        => p_system_user
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_tk_group_query'
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
  p_tk_group_query_id     := l_tk_group_query_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_tk_group_query;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tk_group_query_id      := null;
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
    ROLLBACK TO create_tk_group_query;
    raise;
    --
END create_tk_group_query;



-- ----------------------------------------------------------------------------
-- |-------------------------<update_tk_group_query>------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Tk_Group_Query with a given name
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the tk group query
--                                                is updated. Default is FALSE.
--   p_tk_group_id                  Yes  number   Primary Key for entity
--   p_tk_group_query_id            Yes  number   Foreign Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_group_query_name             Yes  varchar2 tk group Name for the timekeeper group query
--   p_include_exclude              Yes  varchar2 Include or Exclude flag
--   p_system_user                  Yes  varchar2 System or User flag
--
-- Post Success:
--
-- when the timekeeper group query has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated tk group query
--
-- Post Failure:
--
-- The tk_group_query will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_tk_group_query
  (p_validate                       in  boolean   default false
  ,p_tk_group_id                    in  number
  ,p_tk_group_query_id              in  number
  ,p_object_version_number          in  out nocopy number
  ,p_group_query_name                  in     varchar2
  ,p_include_exclude                in  varchar2
  ,p_system_user                    in  varchar2)
IS
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72) ;
	l_object_version_number hxc_tk_group_queries.object_version_number%TYPE := p_object_version_number;
  --
begin
  --
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	  l_proc := g_package||' update_tk_group_query';
  	  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_tk_group_query;
  --
  hxc_tk_group_query_api.chk_name
	(    p_group_query_name	  => p_group_query_name
	,    p_tk_group_id        => p_tk_group_id
	,    p_tk_group_query_id  => p_tk_group_query_id );

  hxc_tk_group_query_api.chk_tk_group_id ( p_tk_group_id => p_tk_group_id );

  if g_debug then
  	  hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_tk_group_query_BK_2.update_tk_group_query_b
	  (p_tk_group_query_id      => p_tk_group_query_id
	  ,p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_group_query_name          => p_group_query_name
          ,p_include_exclude    => p_include_exclude
          ,p_system_user        => p_system_user
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_tk_group_query'
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
hxc_tkgq_upd.upd (
   p_group_query_name         => p_group_query_name
  ,p_tk_group_query_id     => p_tk_group_query_id
  ,p_tk_group_id           => p_tk_group_id
  ,p_include_exclude    => p_include_exclude
  ,p_system_user        => p_system_user
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
    hxc_tk_group_query_BK_2.update_tk_group_query_a
	  (p_tk_group_query_id      => p_tk_group_query_id
	  ,p_tk_group_id            => p_tk_group_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_group_query_name          => p_group_query_name
          ,p_include_exclude    => p_include_exclude
          ,p_system_user        => p_system_user
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_tk_group_query'
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
    ROLLBACK TO update_tk_group_query;
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
    ROLLBACK TO update_tk_group_query;
    raise;

end update_tk_group_query;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_tk_group_query >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Tk_Group_Query
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the tk_group_query
--                                                is deleted. Default is FALSE.
--   p_tk_group_query_id            Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the timekeeper group query has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The tk_group_query will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_tk_group_query
  (p_validate                       in  boolean  default false
  ,p_tk_group_query_id              in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  --
begin
  g_debug :=hr_utility.debug_enabled;
  --

  if g_debug then
  	  l_proc := g_package||'delete_tk_group_query';
  	  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_tk_group_query;
  --
	hxc_tk_group_query_api.chk_delete (
				 p_tk_group_query_id => p_tk_group_query_id );

  if g_debug then
  	  hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_tk_group_query_BK_3.delete_tk_group_query_b
	  (p_tk_group_query_id     => p_tk_group_query_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_tk_group_query'
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
  hxc_tkgq_del.del
    (
     p_tk_group_query_id     => p_tk_group_query_id
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
  hxc_tk_group_query_BK_3.delete_tk_group_query_a
	  (p_tk_group_query_id     => p_tk_group_query_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_tk_group_query'
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
    ROLLBACK TO delete_tk_group_query;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_tk_group_query;
    raise;
    --
end delete_tk_group_query;
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
   p_group_query_name   in varchar2
  ,p_tk_group_id        in number
  ,p_tk_group_query_id  in number
  ) IS

  l_proc  varchar2(72) ;
--
-- cursor to check name is unique
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_tk_group_queries tegq
	WHERE	tegq.group_query_name	= p_group_query_name
        AND     tegq.tk_group_id        = p_tk_group_id
        AND
	( tegq.tk_group_query_id <> p_tk_group_query_id OR
	  p_tk_group_query_id IS NULL ) );
--
 l_dup_name varchar2(5) := NULL;
--
BEGIN
g_debug :=hr_utility.debug_enabled;
if g_debug then
	l_proc := g_package||'chk_name';
	hr_utility.trace('Params are: ');
	hr_utility.trace('tk group id is       : '||to_char(p_tk_Group_id));
	hr_utility.trace('tk group query id is : '||to_char(p_tk_Group_query_id));
	hr_utility.set_location('Entering:'||l_proc, 5);
end if;
--
-- check that the name has been entered
--
IF ( p_group_query_name IS NULL )
THEN
--

      hr_utility.set_message(809, 'HXC_TEGQ_NAME_MAND');
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
      hr_utility.set_message(809, 'HXC_TEGQ_NAME_DUP');
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
-- |-----------------------< chk_tk_group_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--             SEE DESCRIPTION IN HEADER
--
-- ----------------------------------------------------------------------------
Procedure chk_tk_group_id
  (
   p_tk_group_id in number
  ) IS

l_proc varchar2(72) ;
l_dummy varchar2(1) := NULL;

CURSOR  csr_chk_tk_group_id IS
SELECT	'x'
FROM 	dual
WHERE EXISTS ( SELECT 'x'
               FROM   hxc_tk_groups tkg
               WHERE  tkg.tk_group_id = p_tk_group_id );

BEGIN
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	  l_proc := 'chk_tk_group_id';
  	  hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TK_GROUP_ID'
    ,p_argument_value     => p_tk_group_id
    );

OPEN  csr_chk_tk_group_id;
FETCH csr_chk_tk_group_id INTO l_dummy;

IF csr_chk_tk_group_id%NOTFOUND
THEN
      hr_utility.set_message(809, 'HXC_TKGQ_INVALID_TK_GROUP_ID');
      hr_utility.raise_error;
END IF;

CLOSE csr_chk_tk_group_id;

  if g_debug then
  	  hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
END chk_tk_group_id;

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
   p_tk_group_query_id in number
  ) IS
BEGIN
null;
END chk_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< maintain_tk_group_query >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- GAZ - this will need to change for the full blown solution - namely,
-- need to pass in the tk grpup query name
--
-- ----------------------------------------------------------------------------
Procedure maintain_tk_group_query
  (
   p_tk_group_query_id              in  out nocopy number
  ,p_tk_group_id                    in  number
  ) IS


l_proc varchar2(72) ;

l_tk_group_query_id hxc_tk_group_queries.tk_group_query_id%TYPE;
l_object_version_number hxc_tk_group_queries.object_version_number%TYPE;

CURSOR  csr_chk_group_query IS
SELECT tkgq.tk_group_query_id
FROM   hxc_tk_group_queries tkgq
WHERE  tkgq.tk_group_id = p_tk_group_id;

BEGIN
g_debug :=hr_utility.debug_enabled;
if g_debug then
	l_proc := 'maintain_tk_group_query';
	hr_utility.trace('Params are :');
	hr_utility.trace('tk group query id is : '||to_char(p_tk_group_query_id));
	hr_utility.trace('tk group id is       : '||to_char(p_tk_group_id));
        hr_utility.set_location('Entering:'||l_proc, 10);
end if;
-- chk to see if a tk group query row already exists

OPEN  csr_chk_group_query;
FETCH csr_chk_group_query INTO l_tk_group_query_id;

IF ( csr_chk_group_query%NOTFOUND )
THEN

	if g_debug then
		hr_utility.trace('tk group query not found');
	end if;
	-- create tk group query

	hxc_tk_group_query_api.create_tk_group_query
	  (p_validate              => FALSE
	  ,p_tk_group_query_id     => l_tk_group_query_id
	  ,p_tk_group_id           => p_tk_group_id
	  ,p_object_version_number => l_object_version_number
	  ,p_group_query_name      => 'System: Included Resources'
	  ,p_include_exclude       => 'I'
	  ,p_system_user           => 'S' );

	if g_debug then
		hr_utility.trace('new tk group query id is : '||to_char(l_tk_group_query_id));
	end if;

END IF;

CLOSE csr_chk_group_query;

if g_debug then
	hr_utility.trace('tk group query found');
	hr_utility.trace('old tk group query id is : '||to_char(l_tk_group_query_id));
end if;
p_tk_group_query_id := l_tk_group_query_id;

  if g_debug then
  	  hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
END maintain_tk_group_query;
--
END hxc_tk_group_query_api;

/
