--------------------------------------------------------
--  DDL for Package Body HXC_TIME_CATEGORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_CATEGORY_API" as
/* $Header: hxchtcapi.pkb 120.2.12010000.4 2009/01/07 15:00:50 asrajago ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_time_category_api.';

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_category >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_category
  (p_validate                       in  boolean   default false
  ,p_time_category_id               in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_name             in     varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc                  varchar2(72) ;
	l_object_version_number hxc_time_categories.object_version_number%TYPE;
	l_time_category_id      hxc_time_categories.time_category_id%TYPE;

begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' create_time_category';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_time_category;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_category_BK_1.create_time_category_b
	  (p_time_category_id       => p_time_category_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_time_category_name     => p_time_category_name
          ,p_operator               => p_operator
          ,p_description            => p_description
          ,p_display                => p_display
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_category'
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
hxc_htc_ins.ins (
   p_time_category_name    => p_time_category_name
  ,p_operator              => p_operator
  ,p_description            => p_description
  ,p_display                => p_display
  ,p_time_category_id      => l_time_category_id
  ,p_object_version_number => l_object_version_number );
--
  if g_debug then
	  hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_time_category_BK_1.create_time_category_a
	  (p_time_category_id       => l_time_category_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_time_category_name     => p_time_category_name
          ,p_operator               => p_operator
          ,p_description            => p_description
          ,p_display                => p_display
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_category'
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
  p_time_category_id      := l_time_category_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_time_category;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_time_category_id       := null;
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
    ROLLBACK TO create_time_category;
    raise;
    --
END create_time_category;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_category>-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_category
  (p_validate                       in  boolean   default false
  ,p_time_category_id               in  number
  ,p_object_version_number          in  out nocopy number
  ,p_time_category_name             in     varchar2
  ,p_operator                       in     varchar2
  ,p_description                    in     varchar2
  ,p_display                        in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

	l_proc varchar2(72) ;
	l_object_version_number hxc_time_categories.object_version_number%TYPE := p_object_version_number;

begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	  l_proc := g_package||' update_time_category';
	  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_time_category;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_category_BK_2.update_time_category_b
	  (p_time_category_id       => p_time_category_id
	  ,p_object_version_number  => p_object_version_number
	  ,p_time_category_name     => p_time_category_name
          ,p_description            => p_description
          ,p_display                => p_display
          ,p_operator               => p_operator
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_category'
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
hxc_htc_upd.upd (
   p_time_category_name    => p_time_category_name
  ,p_description            => p_description
  ,p_display                => p_display
  ,p_operator              => p_operator
  ,p_time_category_id      => p_time_category_id
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
    hxc_time_category_BK_2.update_time_category_a
	  (p_time_category_id       => p_time_category_id
	  ,p_object_version_number  => l_object_version_number
	  ,p_time_category_name     => p_time_category_name
          ,p_description            => p_description
          ,p_display                => p_display
          ,p_operator               => p_operator );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_category'
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
    ROLLBACK TO update_time_category;
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
    ROLLBACK TO update_time_category;
    raise;
    --
END update_time_category;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_category >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_category
  (p_validate                       in  boolean  default false
  ,p_time_category_id               in  number
  ,p_time_category_name             in  varchar2
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) ;
  --
begin
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||'delete_time_category';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_time_category;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
    hxc_time_category_BK_3.delete_time_category_b
	  (p_time_category_id      => p_time_category_id
          ,p_time_Category_name    => p_time_category_name
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_category_b'
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
  hxc_htc_del.del
    (
     p_time_category_id      => p_time_category_id
    ,p_time_category_name    => p_time_category_name
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
  hxc_time_category_BK_3.delete_time_category_a
	  (p_time_category_id      => p_time_category_id
          ,p_time_Category_name    => p_time_category_name
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_category_a'
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
    ROLLBACK TO delete_time_category;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_time_category;
    raise;
    --
end delete_time_category;
--
procedure set_dynamic_sql_string ( p_time_category_id NUMBER ) IS

l_time_sql long;
l_time_category_id   hxc_time_Categories.time_category_id%TYPE;
l_operator           hxc_time_categories.operator%TYPE;

BEGIN

g_debug := hr_utility.debug_enabled;

hxc_time_category_utils_pkg.mapping_component_string (
	p_time_category_id => p_time_category_id
,	p_time_sql	   => l_time_sql );

if g_debug then
	hr_utility.trace('set dyn sql string string is '||l_time_sql);
end if;

UPDATE hxc_time_categories
SET time_sql = l_time_sql
WHERE time_category_id = p_time_category_id;

exception when others then

if g_debug then
	hr_utility.trace('exception is '||SQLERRM);
end if;

raise;

END set_dynamic_sql_string;


-- Bug No : 7680264
-- Created the following procs.
-- delete_old_comps is called from hxcdeltcc.sql
-- to delete all the old corrupt Comps.
-- This happens only for the three seeded time categories below.

PROCEDURE delete_old_comps
IS

l_cat VARCHAR2(50);

CURSOR get_corrupt_tcs
    IS  SELECT cat.time_category_id
          FROM hxc_time_categories cat,
	       hxc_time_category_comps comp
         WHERE cat.time_category_id = comp.time_category_id
           AND cat.time_category_name IN  ('Payroll Processing Fields',
                                           'Projects Processing Fields',
		   		           'HR Processing Fields')
         GROUP
            BY cat.time_category_id,
               component_type_id
        HAVING COUNT(1) > 1;

TYPE NUMTABLE IS TABLE OF NUMBER;
l_tc_tab  NUMTABLE;


BEGIN

    OPEN get_corrupt_tcs;
    FETCH get_corrupt_tcs BULK COLLECT INTO l_tc_tab;
    IF l_tc_tab.COUNT = 0
    THEN
       CLOSE get_corrupt_tcs;
       RETURN;
    END IF;
    CLOSE get_corrupt_tcs;

    IF l_tc_tab.COUNT > 0
    THEN
       FORALL i IN l_tc_tab.FIRST..l_tc_tab.LAST
         DELETE FROM hxc_time_category_comps
               WHERE time_category_id = l_tc_tab(i);
    END IF;

    COMMIT;
    RETURN;

END delete_old_comps;


-- Bug No : 7680264
-- Returns the Mapping component name of the component Id passed.
-- Used in the download section of hxctmcatimcatgry.lct to return
-- the component type's name.

FUNCTION get_component_type_name( p_component_type_id   IN NUMBER)
RETURN VARCHAR2
IS

l_comp_name   VARCHAR2(50);

BEGIN
    SELECT name
      INTO l_comp_name
      FROM hxc_mapping_components
     WHERE mapping_component_id = p_component_type_id;

    RETURN l_comp_name;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN NULL;
END get_component_type_name;



END hxc_time_category_api;

/
