--------------------------------------------------------
--  DDL for Package Body HR_CAL_ENTRY_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAL_ENTRY_VALUE_API" as
/* $Header: peenvapi.pkb 120.0 2005/05/31 08:10:04 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(23) := 'HR_CAL_ENTRY_VALUE_API.';
g_current_entry_id number(15);
g_current_osv_id number(15);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_entry_value >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_entry_value
  (p_validate                      in     boolean      default false
  ,p_effective_date                in     date
  ,p_calendar_entry_id             in     number
  ,p_usage_flag                    in     varchar2
  ,p_hierarchy_node_id             in     number       default null
  ,p_value                         in     varchar2     default null
  ,p_org_structure_element_id      in     number       default null
  ,p_organization_id               in     number       default null
  ,p_override_name                 in     varchar2     default null
  ,p_override_type                 in     varchar2     default null
  ,p_parent_entry_value_id         in     number       default null
  ,p_identifier_key                in     varchar2     default null
  ,p_cal_entry_value_id               out nocopy number
  ,p_object_version_number            out nocopy number) IS

  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(70) := g_package||'create_entry_value';
  l_cal_entry_value_id     number(15);
  l_object_version_number  number(15);
  l_effective_date         date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_cal_entry_value;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    HR_CAL_ENTRY_VALUE_BK1.create_entry_value_b
      (p_effective_date                => l_effective_date
      ,p_calendar_entry_id             => p_calendar_entry_id
      ,p_hierarchy_node_id             => p_hierarchy_node_id
      ,p_value                         => p_value
      ,p_org_structure_element_id      => p_org_structure_element_id
      ,p_organization_id               => p_organization_id
      ,p_override_name                 => p_override_name
      ,p_override_type                 => p_override_type
      ,p_parent_entry_value_id         => p_parent_entry_value_id
      ,p_usage_flag                    => p_usage_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_entry_value_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_env_ins.ins
       (p_effective_date                => l_effective_date
       ,p_calendar_entry_id             => p_calendar_entry_id
       ,p_hierarchy_node_id             => p_hierarchy_node_id
       ,p_value                         => p_value
       ,p_org_structure_element_id      => p_org_structure_element_id
       ,p_organization_id               => p_organization_id
       ,p_override_name                 => p_override_name
       ,p_override_type                 => p_override_type
       ,p_parent_entry_value_id         => p_parent_entry_value_id
       ,p_usage_flag                    => p_usage_flag
       ,p_identifier_key                => p_identifier_key
       ,p_cal_entry_value_id            => l_cal_entry_value_id
       ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    HR_CAL_ENTRY_VALUE_BK1.create_entry_value_a
       (p_effective_date                => l_effective_date
       ,p_calendar_entry_id             => p_calendar_entry_id
       ,p_hierarchy_node_id             => p_hierarchy_node_id
       ,p_value                         => p_value
       ,p_org_structure_element_id      => p_org_structure_element_id
       ,p_organization_id               => p_organization_id
       ,p_override_name                 => p_override_name
       ,p_override_type                 => p_override_type
       ,p_parent_entry_value_id         => p_parent_entry_value_id
       ,p_usage_flag                    => p_usage_flag
       ,p_cal_entry_value_id            => l_cal_entry_value_id
       ,p_object_version_number         => l_object_version_number
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_entry_value_a'
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
  p_cal_entry_value_id     := l_cal_entry_value_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_cal_entry_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cal_entry_value_id      := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cal_entry_value;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_entry_value;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_entry_value >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_entry_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_cal_entry_value_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_override_name                 in     varchar2     default hr_api.g_varchar2
  ,p_override_type                 in     varchar2     default hr_api.g_varchar2
  ,p_parent_entry_value_id         in     number       default hr_api.g_number
  ,p_usage_flag                    in     varchar2     default hr_api.g_varchar2
  ) IS

  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(80) := g_package||'update_entry_value';
  l_cal_entry_value_id     per_cal_entry_values.cal_entry_value_id%TYPE;
  l_object_version_number  per_cal_entry_values.object_version_number%TYPE;
  l_effective_date         date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_cal_entry_value;
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    HR_CAL_ENTRY_VALUE_BK2.update_entry_value_b
       (p_effective_date                => l_effective_date
       ,p_cal_entry_value_id            => p_cal_entry_value_id
       ,p_object_version_number         => l_object_version_number
       ,p_override_name                 => p_override_name
       ,p_override_type                 => p_override_type
       ,p_parent_entry_value_id         => p_parent_entry_value_id
       ,p_usage_flag                    => p_usage_flag
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_entry_value_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
   per_env_upd.upd
      (p_effective_date                 => l_effective_date
       ,p_cal_entry_value_id            => p_cal_entry_value_id
       ,p_object_version_number         => l_object_version_number
       ,p_override_name                 => p_override_name
       ,p_override_type                 => p_override_type
       ,p_parent_entry_value_id         => p_parent_entry_value_id
       ,p_usage_flag                    => p_usage_flag
      );
  --
  --
  begin
      HR_CAL_ENTRY_VALUE_BK2.update_entry_value_a
       (p_effective_date                => l_effective_date
       ,p_cal_entry_value_id            => p_cal_entry_value_id
       ,p_object_version_number         => l_object_version_number
       ,p_override_name                 => p_override_name
       ,p_override_type                 => p_override_type
       ,p_parent_entry_value_id         => p_parent_entry_value_id
       ,p_usage_flag                    => p_usage_flag
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_entry_value_a'
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
    rollback to update_cal_entry_value;
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
    rollback to update_cal_entry_value;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_entry_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_entry_value >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_entry_value
  (p_validate                      in     boolean  default false
  ,p_cal_entry_value_id            in     number
  ,p_object_version_number         in     number
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_entry_value';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint if operating in validation only mode.
  --
  savepoint delete_cal_entry_value;
  --
  -- Call Before Process User Hook
  --
  begin
    HR_CAL_ENTRY_VALUE_BK3.delete_entry_value_b
     (p_cal_entry_value_id       => p_cal_entry_value_id,
      p_object_version_number   => p_object_version_number
     );
     exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
          (p_module_name => 'delete_entry_value_b',
           p_hook_type   => 'BP'
          );
  end;
  --
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_env_del.del
  (p_cal_entry_value_id             => p_cal_entry_value_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Call After Process User Hook
  begin
    HR_CAL_ENTRY_VALUE_BK3.delete_entry_value_a
     (p_cal_entry_value_id       => p_cal_entry_value_id
     ,p_object_version_number   => p_object_version_number
     );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
           (p_module_name  => 'delete_entry_value_a',
            p_hook_type   => 'AP'
           );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_cal_entry_value;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
  when others then
  --
  --
  ROLLBACK TO delete_cal_entry_value;
  --
  raise;
  --
end delete_entry_value;
--
--
FUNCTION get_display_value(p_entity_id IN VARCHAR2,
                           p_node_type IN VARCHAR2,
                           p_calendar_entry_id IN NUMBER,
                           p_vs_value_id IN VARCHAR2) RETURN VARCHAR2 IS
--

 l_value_set_id            number(15) := NULL;
-- get VS details for gen hier node EV..
 CURSOR csr_VS IS
   SELECT flex_value_set_id,validation_type
   FROM   fnd_flex_value_sets
   WHERE  flex_value_set_name  = (SELECT pgt.child_value_set
                                  FROM per_gen_hier_node_types pgt
                                  WHERE pgt.child_node_type = p_node_type);

--
-- get VS details for stand-alone EV..
--
 CURSOR csr_VS2 IS
   SELECT value_set_id
   FROM   per_calendar_entries pce
   WHERE  pce.CALENDAR_ENTRY_ID = p_calendar_entry_id;

 CURSOR csr_VS3 IS
    SELECT description
    FROM fnd_flex_values_vl
    WHERE flex_value = p_entity_id
    AND flex_value_set_id = l_value_set_id;
--
--

  l_value_set_csr csr_VS%rowtype;
  l_validation_type         VARCHAR2(1);
  l_table_name              VARCHAR2(40);
  l_column_id               VARCHAR2(40);
  l_column_name	            VARCHAR2(40);
  l_where_clause            VARCHAR2(4000);
  l_sql_statement           VARCHAR2(2000);
  l_value_id                VARCHAR2(255);
  l_id                      VARCHAR2(255);
  l_id_column               VARCHAR2(200);
  l_name                    VARCHAR2(2000) := 'NULL';
  l_proc                    VARCHAR2(30)  := 'get_display_value';
--
--
  FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2 IS
  --
    l_v_r  fnd_vset.valueset_r;
    l_v_dr fnd_vset.valueset_dr;
    l_str  varchar2(4000);
    l_whr  varchar2(4000);
    l_ord  varchar2(4000);
    l_col  varchar2(4000);
    --
  BEGIN
    --
    fnd_vset.get_valueset(valueset_id => p_vset_id ,
                          valueset    => l_v_r,
                          format      => l_v_dr);
    --
    IF l_v_r.table_info.table_name IS NULL THEN
      --
      l_str := '';
          --
    END IF;
    --
    IF l_v_r.table_info.id_column_name IS NULL THEN
        --
      l_str := '';
            --
    END IF;
    --
    IF l_v_r.table_info.value_column_name IS NULL THEN
      --
      l_str := '';
            --
    END IF;
    --
    l_whr := l_v_r.table_info.where_clause ;
    l_str := 'select '||substr(l_v_r.table_info.id_column_name,1,instr(l_v_r.table_info.id_column_name||' ',' '))||','
                        ||substr(l_v_r.table_info.value_column_name,1,instr(l_v_r.table_info.value_column_name||' ',' '))
                      ||' from '
                      ||l_v_r.table_info.table_name||' '||l_whr;
    --
    RETURN (l_str);
    --
  END get_sql_from_vset_id;
--
--
 BEGIN

  if (p_entity_id is not null and p_node_type is not null) then
    -- open CSR1 to get the VS
      open csr_VS;
      fetch csr_VS into l_value_set_csr;
      close csr_VS;

      l_id := p_entity_id;
      l_value_set_id := l_value_set_csr.flex_value_set_id;
      l_validation_type := l_value_set_csr.validation_type;

  elsif (p_calendar_entry_id is not null and p_vs_value_id is not null) then
    -- open CSR2 to get the VS
      open csr_VS2;
      fetch csr_VS2 into l_value_set_id;
      close csr_VS2;

     l_id := p_vs_value_id;

  end if;
   --
  if l_value_set_id is not null then
    if l_validation_type = 'I' then
     open csr_VS3;
     fetch csr_VS3 into l_name;
     close csr_vs3;

   elsif l_validation_type = 'F' then

    --
    -- next evaluate the value_set for the entity_id supplied
    hr_utility.set_location(l_proc, 30);
    --
    l_sql_statement := get_sql_from_vset_id(p_vset_id => l_value_set_id);
    --
    l_sql_statement := REPLACE(l_sql_statement
                             ,':$PROFILES$.PER_BUSINESS_GROUP_ID'
                             ,fnd_profile.value('PER_BUSINESS_GROUP_ID'));

    --
    l_id_column := SUBSTR(l_sql_statement,(INSTR(UPPER(l_sql_statement),'SELECT') +7)
                                          ,INSTR(UPPER(l_sql_statement),',') -
                                       (INSTR(UPPER(l_sql_statement),'SELECT')+ 7));

    if INSTR(upper(l_sql_statement),'ORDER BY') > 0 then
      l_sql_statement := SUBSTR(l_sql_statement,1,(INSTR(upper(l_sql_statement),'ORDER BY')-1));
    end if;
    --

    if INSTR(upper(l_sql_statement),'WHERE') > 0 then
      -- just append as AND clause...
      l_sql_statement := l_sql_statement||' and '||l_id_column||' = :id ';
    else
      -- just append as WHERE clause...
      l_sql_statement := l_sql_statement||' where '||l_id_column||' = :id ';
    end if;
    --
    --
    hr_utility.set_location(l_proc, 40);
    --
     BEGIN
          --
      EXECUTE IMMEDIATE l_sql_statement INTO l_value_id, l_name USING l_id;
      --
     EXCEPTION
      --
       WHEN OTHERS THEN
         hr_utility.set_location(l_proc||l_sql_statement,45);
         l_name := 'INVALID_VALUE_SET SQL: ' || l_sql_statement ||
                                ', vs_id : ' || l_value_set_id  ||
                            ', l_value_id: ' || l_id;
       --
     END;
    hr_utility.set_location(l_proc, 50);
    --
  end if;

  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc, 60);
  --
  RETURN l_name;
--
END get_display_value;
--
--
--
FUNCTION  get_g_current_entry_id RETURN NUMBER IS
--
-- PURPOSE: return g_current_entry_id value.
--
BEGIN

  RETURN g_current_entry_id;

END get_g_current_entry_id;
--
--
--
PROCEDURE set_g_current_entry_id (p_entry_id NUMBER) IS
--
-- PURPOSE: set g_current_entry_id value from the param supplied.
--
BEGIN
--
  g_current_entry_id := p_entry_id;
--
END set_g_current_entry_id;
--
--
--
FUNCTION  get_g_current_osv_id RETURN NUMBER IS
--
-- PURPOSE: return g_current_osv_id value.
--
BEGIN

  RETURN g_current_osv_id;

END get_g_current_osv_id;
--
--
--
PROCEDURE set_g_current_osv_id (p_osv_id NUMBER) IS
--
-- PURPOSE: set g_current_osv_id value from the param supplied.
--
BEGIN
--
  g_current_osv_id := p_osv_id;
--
END set_g_current_osv_id;

--


Function get_node_level (P_HIERARCHY_NODE_ID in NUMBER
                        ,P_HIERARCHY_VERSION_ID in NUMBER) RETURN VARCHAR2 IS

-- tree walk from supplied  child gen hier node to top level
-- to obtain level of child within the hierarchy
-- This could utilise  some form of data caching to improve performance,
-- possibly using the parent node to derive the current level
-- rather than tree-walking for all nodes...revisit
--
-- also returns . delimited list of the node's parent ids
--
CURSOR csr_get_level IS
  select PARENT_HIERARCHY_NODE_ID from per_gen_hierarchy_nodes
  where HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
  connect by HIERARCHY_NODE_ID = prior PARENT_HIERARCHY_NODE_ID
         AND HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
  start with HIERARCHY_NODE_ID = P_HIERARCHY_NODE_ID;

  l_level NUMBER := 0;
  l_id_list VARCHAR2(2000) := null;
  l_return varchar2(2000) := null;

BEGIN

  for l_rec in csr_get_level loop
   l_level := csr_get_level%rowcount;
   l_id_list := to_char(l_rec.PARENT_HIERARCHY_NODE_ID)||'.'||l_id_list;
  end loop;

   l_return := to_char(l_level)||'.'||l_id_list;
  RETURN l_return;

END get_node_level;
--
--
Function get_ele_level (P_ORG_STRUCTURE_ELEMENT_ID in NUMBER
                       ,P_ORG_STRUCTURE_VERSION_ID in NUMBER) RETURN VARCHAR2 IS

-- tree walk from supplied  child link record (element) to top level link record
-- to obtain level of link child within the organisation hierarchy.
-- This could utilise  some form of data caching to improve performance,
-- possibly using the parent node to derive the current level
-- rather than tree-walking for all nodes...revisit
--
-- also returns . delimited list of the link's parent link ids
--
CURSOR csr_get_level IS
  select ORG_STRUCTURE_ELEMENT_ID from PER_ORG_STRUCTURE_ELEMENTS
  where ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
  connect by ORGANIZATION_ID_CHILD = prior ORGANIZATION_ID_PARENT
  	     AND ORG_STRUCTURE_VERSION_ID = P_ORG_STRUCTURE_VERSION_ID
  start with ORG_STRUCTURE_ELEMENT_ID = P_ORG_STRUCTURE_ELEMENT_ID;

  l_level NUMBER := 0;
  l_id_list VARCHAR2(2000) := null;
  l_return varchar2(2000) := null;

BEGIN

  for l_rec in csr_get_level loop
   l_level := csr_get_level%rowcount;
   l_id_list := to_char(l_rec.ORG_STRUCTURE_ELEMENT_ID)||'.'||l_id_list;
  end loop;

   l_id_list := substr(l_id_list,1,instr(l_id_list,'.',-1,2));
   l_return := to_char(l_level)||'..'||'-987123654.'||l_id_list;
  RETURN l_return;

END get_ele_level;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_sql_from_vset_id >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER) RETURN VARCHAR2 IS
  --
  l_v_r  fnd_vset.valueset_r;
  l_v_dr fnd_vset.valueset_dr;
  l_str  varchar2(4000);
  l_whr  varchar2(4000);
  l_ord  varchar2(4000);
  l_col  varchar2(4000);
  --
BEGIN
  --
  fnd_vset.get_valueset(valueset_id => p_vset_id ,
                        valueset    => l_v_r,
                        format      => l_v_dr);
  --
  IF l_v_r.table_info.table_name IS NULL THEN
    --
    l_str := '';
        --
  END IF;
  --
  IF l_v_r.table_info.id_column_name IS NULL THEN
    --
    l_str := '';
        --
  END IF;
  --
  IF l_v_r.table_info.value_column_name IS NULL THEN
    --
    l_str := '';
        --
  END IF;
  --
  l_whr := l_v_r.table_info.where_clause ;
  l_str := 'select '||substr(l_v_r.table_info.id_column_name,1,instr(l_v_r.table_info.id_column_name||' ',' '))||','
                    ||substr(l_v_r.table_info.value_column_name,1,instr(l_v_r.table_info.value_column_name||' ',' '))
                    ||' from '
                    ||l_v_r.table_info.table_name||' '||l_whr;

  -- substitute the BG if required.
  l_str := REPLACE(l_str,':$PROFILES$.PER_BUSINESS_GROUP_ID',fnd_profile.value('PER_BUSINESS_GROUP_ID'));
  --
  RETURN (l_str);
  --
END get_sql_from_vset_id;
--
--
end HR_CAL_ENTRY_VALUE_API;

/
