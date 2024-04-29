--------------------------------------------------------
--  DDL for Package Body HR_CAL_EVENT_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAL_EVENT_MAPPING_PKG" AS
  -- $Header: pecalmap.pkb 120.5.12010000.2 2009/01/12 13:58:02 tkghosh ship $

  --
  -----------------------------------------------------------------------------
  ---------------------------< populate_org_list >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- Private procedure to build mapping data for ORG Hierarchy based calendar
  -- events. This procedure refreshes data in table PER_CAL_ENTRY_ORG_LIST.
  --
  PROCEDURE populate_org_list IS
    --
    -- Cursor to get unique list of OSVs that have calendar enrty coverages
    -- data defined.
    --
    CURSOR c_osv_ids IS
      SELECT DISTINCT ENT.org_structure_version_id "OSV_ID"
      FROM   per_calendar_entries ENT
      WHERE  ENT.org_structure_version_id IS NOT NULL
      AND    EXISTS (SELECT 'x'
                     FROM   per_cal_entry_values ENV
                     WHERE  ENV.calendar_entry_id = ENT.calendar_entry_id
                    );
    --
    -- Cursor to fetch the top of the hierarchy
    --
    CURSOR c_org_hier_top (cp_osv_id NUMBER
                          ) IS
      SELECT DISTINCT organization_id_parent
      FROM   per_org_structure_elements
      WHERE  org_structure_version_id = cp_osv_id
      AND    organization_id_parent NOT IN
             (SELECT organization_id_child
              FROM   per_org_structure_elements
              WHERE  org_structure_version_id = cp_osv_id
             );
    --
    -- Cursor to walk the ORG hierarchy to return all nodes and levels
    --
    CURSOR c_org_hier_elements (cp_osv_id                 NUMBER
                               ,cp_organization_id_parent NUMBER
                               ) IS
      SELECT LEVEL
            ,org_structure_version_id
            ,org_structure_element_id
            ,organization_id_parent
            ,organization_id_child
      FROM   per_org_structure_elements
      WHERE  org_structure_version_id = cp_osv_id
      START WITH organization_id_parent = cp_organization_id_parent
      CONNECT BY PRIOR organization_id_child = organization_id_parent;
    --
    -- Cursor to fetch calendar events on ORG Hierarchy
    --
    CURSOR c_org_events (cp_osv_id NUMBER
                        ) IS
      SELECT ENT.calendar_entry_id
            ,ENT.org_structure_version_id
            ,ENV.org_structure_element_id
            ,ENV.organization_id
            ,ENV.usage_flag
            ,DECODE(ENV.usage_flag,
                    'N','COV',
                    'Y','EXC',
                    'O','OVR') "USAGE"
            ,ENV.cal_entry_value_id
            ,ENV.parent_entry_value_id
            ,'' "ENTRY_FLAG"
      FROM  per_calendar_entries ENT
           ,per_cal_entry_values ENV
      WHERE ENT.org_structure_version_id = cp_osv_id
      AND   ENT.calendar_entry_id = ENV.calendar_entry_id
      AND   ENV.org_structure_element_id IS NOT NULL
      AND   ENV.organization_id IS NOT NULL
      ORDER BY ENT.calendar_entry_id
--              ,DECODE(ENV.usage_flag,
--                      'N',1,
--                      'O',2,
--                      'Y',3)
      ;

    TYPE t_org_hier_table  IS TABLE OF c_org_hier_elements%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE t_cal_event_table IS TABLE OF c_org_events%ROWTYPE        INDEX BY BINARY_INTEGER;
    TYPE t_org_id_table    IS TABLE OF NUMBER                      INDEX BY BINARY_INTEGER;

    -- Local variables for process_org_list
    l_org_hier_table  t_org_hier_table;
    l_cal_event_table t_cal_event_table;
    l_top_org_id      per_org_structure_elements.organization_id_parent%TYPE;
    l_proc            VARCHAR2(100);

    --
    -------------------------------------------------------------------------
    ---------------------< get_org_hier_elements >---------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to manually walk the ORG hierarchy as issues have
    -- been detected with the inherent tree walk feature in 9i
    --
    PROCEDURE get_org_hier_elements(p_osv_id         IN NUMBER
                                   ,p_top_org_id     IN NUMBER
                                   ,p_org_hier_table IN OUT NOCOPY t_org_hier_table
                                   ) IS
      l_stack_table t_org_hier_table;
      l_level       NUMBER;
      l_stack_index NUMBER;
      l_main_index  NUMBER;
      l_child_id    NUMBER;
      l_proc        VARCHAR2(100);

      -- Tree walk cursor
      CURSOR c_org_tree_walk (cp_osv_id     IN NUMBER
                             ,cp_par_org_id IN NUMBER
                             ) IS
        SELECT l_level "LEVEL"
              ,org_structure_version_id
              ,org_structure_element_id
              ,organization_id_parent
              ,organization_id_child
        FROM per_org_structure_elements
        WHERE org_structure_version_id = cp_osv_id
        AND organization_id_parent = cp_par_org_id;
    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.get_org_hier_elements';
      hr_utility.set_location('Entering '||l_proc,10);

      -- Populate hierarchy Level 1 to stack
      l_level := 1;
      l_stack_index := 0;
      l_main_index := 0;
      FOR l_org_hier_rec IN c_org_tree_walk(p_osv_id,p_top_org_id) LOOP
        hr_utility.set_location(l_proc,15);
        l_stack_index := l_stack_index + 1;
        l_stack_table(l_stack_index) := l_org_hier_rec;
      END LOOP;

      hr_utility.set_location(l_proc,20);

      -- Work from stack table
      WHILE l_stack_index > 0 LOOP
        hr_utility.set_location(l_proc,24);
        -- Get node from stack
        l_main_index := l_main_index + 1;
        p_org_hier_table(l_main_index) := l_stack_table(l_stack_index);
        l_child_id := l_stack_table(l_stack_index).organization_id_child;
        l_level := l_stack_table(l_stack_index).level;
        l_stack_index := l_stack_index - 1;
        -- Fetch children from stack
        l_level := l_level + 1;
        FOR l_org_hier_rec IN c_org_tree_walk(p_osv_id,l_child_id) LOOP
          hr_utility.set_location(l_proc,28);
          l_stack_index := l_stack_index + 1;
          l_stack_table(l_stack_index) := l_org_hier_rec;
        END LOOP;
      END LOOP;
      --
      hr_utility.set_location('Count: '||p_org_hier_table.COUNT,30);
      hr_utility.set_location('Leaving '||l_proc,40);
    EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_location('Leaving '||l_proc,50);
    END get_org_hier_elements;

    --
    -------------------------------------------------------------------------
    -------------------------< write_org_cache >-----------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to write calendar event ORG mapping records to the
    -- ORG cache table
    --
    PROCEDURE write_org_cache(p_coverage_list     t_org_id_table
                             ,p_calendar_entry_id NUMBER
                             ) IS

      -- Cursor to fetch override identifier (if any)
      CURSOR c_org_ovr ( cp_calendar_entry_id NUMBER
                       , cp_organization_id   NUMBER
                       ) IS
        SELECT cal_entry_value_id
        FROM per_cal_entry_values
        WHERE usage_flag = 'O'
        AND calendar_entry_id = cp_calendar_entry_id
        AND organization_id = cp_organization_id;

      l_ovr_id per_cal_entry_values.cal_entry_value_id%TYPE;
      l_proc VARCHAR2(100);

    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.write_org_cache';
      hr_utility.set_location('Entering '||l_proc,10);

      IF p_coverage_list.COUNT > 0 THEN
        hr_utility.set_location(l_proc,12);
        FOR idx IN p_coverage_list.FIRST .. p_coverage_list.LAST LOOP
          hr_utility.set_location(l_proc,14);
          l_ovr_id := NULL;

          -- Get override (if any)
          OPEN c_org_ovr (p_calendar_entry_id
                         ,p_coverage_list(idx)
                         );
          FETCH c_org_ovr INTO l_ovr_id;
          CLOSE c_org_ovr;

          hr_utility.set_location(l_proc,18);

          INSERT INTO per_cal_entry_org_list
            (calendar_entry_id
            ,organization_id
            ,ovr_cal_entry_value_id
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,created_by
            ,creation_date
            )
          VALUES
            (p_calendar_entry_id
            ,p_coverage_list(idx)
            ,l_ovr_id
            ,TRUNC(SYSDATE)
            ,0
            ,0
            ,0
            ,TRUNC(SYSDATE)
            );
        END LOOP;
      END IF;

      COMMIT;

      hr_utility.set_location('Leaving '||l_proc,20);
    END write_org_cache;

    --
    -------------------------------------------------------------------------
    --------------------------< is_org_in_list >-----------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to check is a given org is in the given list
    --
    FUNCTION is_org_in_list(p_org_id   NUMBER
                           ,p_org_list t_org_id_table
                           ) RETURN BOOLEAN IS
      l_return BOOLEAN;
      l_proc VARCHAR2(100);
    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.is_org_in_list';
      hr_utility.set_location('Entering '||l_proc,10);
      l_return := FALSE;

      IF p_org_list.COUNT > 0 THEN
        hr_utility.set_location(l_proc,13);
        FOR idx IN p_org_list.FIRST .. p_org_list.LAST LOOP
          hr_utility.set_location(l_proc,15);
          IF p_org_list(idx) = p_org_id THEN
            l_return := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      hr_utility.set_location('Leaving '||l_proc,20);

      RETURN l_return;
    END is_org_in_list;

    --
    -------------------------------------------------------------------------
    -----------------------< get_child_org_nodes >---------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to get the child coverage records for a given event
    --
    FUNCTION get_child_org_nodes(p_coverage_org_id NUMBER
                                ,p_exclusion_list  t_org_id_table
                                ,p_org_hier_table  t_org_hier_table
                                ) RETURN t_org_id_table IS
      l_result_list        t_org_id_table;
      l_result_count       NUMBER;
      l_coverage_top_level NUMBER;
      l_exclusion_level    NUMBER;
      l_parent_found       BOOLEAN;
      l_exclude_flag       BOOLEAN;
      l_hier_top_case      BOOLEAN;
      l_proc               VARCHAR2(100);

    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.get_child_org_nodes';
      hr_utility.set_location('Entering '||l_proc,5);
      l_result_count       := 0;
      l_parent_found       := FALSE;
      l_exclude_flag       := FALSE;
      l_coverage_top_level := 1;
      l_exclusion_level    := 0;
      l_hier_top_case      := FALSE;

      IF p_org_hier_table.COUNT > 0 THEN
        hr_utility.set_location(l_proc,10);
        -- Loop through the org hier tree elements
        FOR idx IN p_org_hier_table.FIRST .. p_org_hier_table.LAST LOOP
          hr_utility.set_location(l_proc,11);

          -- Due to the nature of results returned by a tree walk, the first
          -- record will always be a top node in the hierarchy. Check is the
          -- ORG at the hierarchy top is in coverage.
          IF idx = 1 AND p_org_hier_table(idx).organization_id_parent = p_coverage_org_id THEN
            hr_utility.set_location(l_proc,12);
            -- This is the first OSE for the COV as a special case where parent
            -- ORG is in coverage.
            l_parent_found := TRUE;
            l_result_count := l_result_count + 1;
            l_result_list(l_result_count) := p_org_hier_table(idx).organization_id_parent;
            l_coverage_top_level := p_org_hier_table(idx).level;
            l_hier_top_case := TRUE;
          END IF; -- top node

          IF p_org_hier_table(idx).organization_id_child = p_coverage_org_id THEN
            hr_utility.set_location(l_proc,13);
            -- This is the first OSE for the COV
            l_parent_found := TRUE;
            l_result_count := l_result_count + 1;
            l_result_list(l_result_count) := p_org_hier_table(idx).organization_id_child;
            l_coverage_top_level := p_org_hier_table(idx).level;
          ELSE -- not first OSE
            hr_utility.set_location(l_proc,14);
            IF l_parent_found THEN

              -- Check if we have moved back up the tree beyond coverage level
              IF p_org_hier_table(idx).level <= l_coverage_top_level AND NOT l_hier_top_case THEN
                -- Stop as we have moved up the tree again
                hr_utility.set_location(l_proc,15);
                EXIT; -- break the loop
              END IF; -- level check

              -- Check if we need to stop exclusions due to moving up the tree
              -- beyond exclusion level
              IF l_exclude_flag AND l_exclusion_level >= p_org_hier_table(idx).level THEN
                hr_utility.set_location(l_proc,16);
                l_exclude_flag := FALSE;
              END IF;

              -- Check for ORG exclusion
              IF NOT l_exclude_flag AND p_exclusion_list.COUNT > 0 THEN
                hr_utility.set_location(l_proc,17);
                l_exclude_flag := is_org_in_list(p_org_hier_table(idx).organization_id_child
                                                ,p_exclusion_list
                                                );
                IF l_exclude_flag THEN
                  hr_utility.set_location(l_proc,18);
                  -- Note the exclusion level
                  l_exclusion_level := p_org_hier_table(idx).level;
                END IF; -- exclusion
              END IF; -- check ORG exclusion

              -- Check if ORG is in coverage and save
              IF NOT l_exclude_flag THEN
                hr_utility.set_location(l_proc,19);
                l_result_count := l_result_count + 1;
                l_result_list(l_result_count) := p_org_hier_table(idx).organization_id_child;
              END IF; -- ORG is in coverage

            END IF; -- first OSE found
          END IF; -- first OSE

        END LOOP; -- org hier elements
      END IF; -- count

      hr_utility.set_location('Leaving '||l_proc,20);

      RETURN l_result_list;
    END get_child_org_nodes;

    --
    -------------------------------------------------------------------------
    -----------------------< process_org_coverage >--------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to build mapping data
    --
    PROCEDURE process_org_coverage(p_org_hier_table  t_org_hier_table
                                  ,p_cal_event_table t_cal_event_table
                                  ) IS
      -- Local variables for process_org_coverage
      l_exc_count       NUMBER;
      l_coverage_org_id NUMBER;
      l_coverage_list   t_org_id_table;
      l_exclusion_list  t_org_id_table;
      l_proc            VARCHAR2(100);
    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.process_org_coverage';
      hr_utility.set_location('Entering '||l_proc,10);
      l_exc_count := 0;
      IF p_cal_event_table.COUNT > 0 THEN
        hr_utility.set_location(l_proc,20);
        -- Loop for each entry in the calendar entry table passed in
        FOR idx IN p_cal_event_table.FIRST .. p_cal_event_table.LAST LOOP
          hr_utility.set_location(l_proc,21);
          IF p_cal_event_table(idx).usage = 'COV' THEN
            hr_utility.set_location(l_proc,22);
            -- This is the start of a coverage
            l_coverage_org_id := p_cal_event_table(idx).organization_id;
          ELSIF p_cal_event_table(idx).usage = 'EXC' THEN
            hr_utility.set_location(l_proc,23);
            -- Note the exclusion org
            l_exc_count := l_exc_count + 1;
            l_exclusion_list(l_exc_count) := p_cal_event_table(idx).organization_id;
          END IF;
          -- If end of coverage, process the coverage
          IF p_cal_event_table(idx).entry_flag = 'E' THEN
            hr_utility.set_location(l_proc,24);
            l_coverage_list := get_child_org_nodes(l_coverage_org_id
                                                  ,l_exclusion_list
                                                  ,p_org_hier_table
                                                  );
            -- If coverage rows returned, write to cache
            IF l_coverage_list.COUNT > 0 THEN
              hr_utility.set_location(l_proc,25);
              write_org_cache(l_coverage_list
                             ,p_cal_event_table(idx).calendar_entry_id
                             );
            END IF; -- coverage rows returned

            hr_utility.set_location(l_proc,26);

            -- Reset local variables for next calendar event
            l_exc_count := 0;
            l_coverage_org_id := NULL;
            l_coverage_list.DELETE;
            l_exclusion_list.DELETE;

          END IF; -- end of coverage
        END LOOP; -- event loop
      END IF; -- count of events to process
      hr_utility.set_location('Leaving '||l_proc,30);
    END process_org_coverage;

  BEGIN -- populate_org_list
    l_proc := 'HR_CAL_EVENT_MAPPING_PKG.populate_org_list';
    hr_utility.set_location('Entering '||l_proc,10);

    -- Get identifiers for all the hierarchies that need to be processed
    FOR l_osv_rec IN c_osv_ids LOOP
      hr_utility.set_location('OSVId:'||l_osv_rec.osv_id,20);

      -- Get the top of the associated ORG hierarchy
      OPEN c_org_hier_top(l_osv_rec.osv_id);
      FETCH c_org_hier_top INTO l_top_org_id;
      CLOSE c_org_hier_top;

      hr_utility.set_location('TopOrgId:'||l_top_org_id,30);

      -- Clear down PLSQL tables
      IF l_org_hier_table.COUNT > 0 THEN
        l_org_hier_table.DELETE;
      END IF;
      IF l_cal_event_table.COUNT > 0 THEN
        l_cal_event_table.DELETE;
      END IF;

      hr_utility.set_location(l_proc,35);

      -- Get the elements of the associated ORG hierarchy
--      FOR l_org_hier_element_rec IN c_org_hier_elements(l_osv_rec.osv_id
--                                                       ,l_top_org_id
--                                                       ) LOOP
--        -- Store the ORG Hierarchy element
--        l_org_hier_table(c_org_hier_elements%ROWCOUNT) := l_org_hier_element_rec;
--      END LOOP; -- c_org_hier_elements
      -- Using manual tree walk as inconsistent behaviour has been found with the
      -- hierarchical tree walk feature in 9i.
      get_org_hier_elements(l_osv_rec.osv_id
                           ,l_top_org_id
                           ,l_org_hier_table
                           );

      hr_utility.set_location(l_proc,40);

      -- Get the calendar events for the ORG Hierarchy
      FOR l_org_event_rec IN c_org_events(l_osv_rec.osv_id) LOOP
        hr_utility.set_location(l_proc,50);

        -- Store the event
        l_cal_event_table(c_org_events%ROWCOUNT) := l_org_event_rec;

        IF c_org_events%ROWCOUNT > 1 THEN
          hr_utility.set_location(l_proc,60);

          -- This is not the first record. Check if different from the
          -- previous event or if same event and end of coverage
          IF (l_org_event_rec.calendar_entry_id <> l_cal_event_table(c_org_events%ROWCOUNT-1).calendar_entry_id)
             OR
             (l_org_event_rec.calendar_entry_id = l_cal_event_table(c_org_events%ROWCOUNT-1).calendar_entry_id
              AND l_org_event_rec.usage_flag = 'N')
          THEN
            hr_utility.set_location(l_proc,70);

            -- Mark end of old event coverage and start of new event coverage
            l_cal_event_table(c_org_events%ROWCOUNT-1).entry_flag := 'E';
            l_cal_event_table(c_org_events%ROWCOUNT).entry_flag := 'S';
          END IF;

        ELSE
          hr_utility.set_location(l_proc,80);

          -- This is the first record. Mark it as coverage start.
          l_cal_event_table(c_org_events%ROWCOUNT).entry_flag := 'S';
        END IF;

      END LOOP; -- c_org_events

      -- Mark end of coverage for the last row
      IF l_cal_event_table.COUNT > 0 THEN
        hr_utility.set_location(l_proc,90);
        l_cal_event_table(l_cal_event_table.LAST).entry_flag := 'E';
      END IF;

      hr_utility.set_location(l_proc,100);

      -- Process coverage data
      process_org_coverage(l_org_hier_table
                          ,l_cal_event_table
                          );
    END LOOP; -- c_osv_ids

    hr_utility.set_location('Leaving '||l_proc,110);
  END populate_org_list;

  --
  -----------------------------------------------------------------------------
  ---------------------------< populate_geo_list >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- Private procedure to build mapping data for GEO Hierarchy based calendar
  -- events. This procedure refreshes data in table PER_CAL_ENTRY_GEO_LIST.
  --
  PROCEDURE populate_geo_list IS

    -- Cursor to get unique list of GHVs that have calendar entry coverages
    -- data defined.
    CURSOR c_ghv_ids IS
      SELECT DISTINCT ENT.hierarchy_id "GHV_ID"
      FROM   per_calendar_entries ENT
      WHERE  ENT.hierarchy_id IS NOT NULL
      AND    EXISTS (SELECT 'x'
                     FROM   per_cal_entry_values ENV
                     WHERE  ENV.calendar_entry_id = ENT.calendar_entry_id
                    );

    -- Cursor to fetch the version id of GHV
    CURSOR c_ghv_ver_id (cp_ghv_id NUMBER
                        ) IS
      SELECT hierarchy_version_id
      FROM   per_gen_hierarchy_versions
      WHERE  hierarchy_id = cp_ghv_id
      AND    version_number = (SELECT MAX(version_number)
                               FROM   per_gen_hierarchy_versions
                               WHERE  hierarchy_id = cp_ghv_id);

    -- Cursor to fetch the top of the hierarchy
    CURSOR c_geo_hier_top (cp_ghv_id NUMBER
                          ) IS
      SELECT hierarchy_node_id
      FROM   per_gen_hierarchy_nodes
      WHERE  hierarchy_version_id = cp_ghv_id
      AND    parent_hierarchy_node_id IS NULL;

    -- Cursor to walk the GEO hierarchy and return all nodes and levels
    CURSOR c_geo_hier_nodes (cp_ghv_id      NUMBER
                            ,cp_top_node_id NUMBER
                            ) IS
      SELECT LEVEL
            ,hierarchy_version_id
            ,hierarchy_node_id
            ,entity_id
      FROM   per_gen_hierarchy_nodes
      WHERE  hierarchy_version_id = cp_ghv_id
      START WITH hierarchy_node_id = cp_top_node_id
      CONNECT BY PRIOR hierarchy_node_id = parent_hierarchy_node_id;

    -- Cursor to fetch calendar events on GEO Hierarchy
    CURSOR c_geo_events (cp_ghv_id NUMBER
                        ) IS
      SELECT ENT.calendar_entry_id
            ,ENT.hierarchy_id
            ,ENV.hierarchy_node_id
            ,ENV.usage_flag
            ,DECODE(ENV.usage_flag,
                    'N','COV',
                    'Y','EXC',
                    'O','OVR') "USAGE"
            ,ENV.cal_entry_value_id
            ,ENV.parent_entry_value_id
            ,'' "ENTRY_FLAG"
      FROM  per_calendar_entries ENT
           ,per_cal_entry_values ENV
      WHERE ENT.hierarchy_id = cp_ghv_id
      AND   ENT.calendar_entry_id = ENV.calendar_entry_id
      AND   ENV.hierarchy_node_id IS NOT NULL
      ORDER BY ENT.calendar_entry_id
              ,DECODE(ENV.usage_flag,
                      'N',1,
                      'O',2,
                      'Y',3);

    TYPE t_geo_hier_table  IS TABLE OF c_geo_hier_nodes%ROWTYPE INDEX BY BINARY_INTEGER;
    TYPE t_cal_event_table IS TABLE OF c_geo_events%ROWTYPE     INDEX BY BINARY_INTEGER;
    TYPE t_node_id_table   IS TABLE OF NUMBER                   INDEX BY BINARY_INTEGER;

    -- Local variables for process_geo_list
    l_geo_hier_table  t_geo_hier_table;
    l_cal_event_table t_cal_event_table;
    l_top_node_id     per_gen_hierarchy_nodes.hierarchy_node_id%TYPE;
    l_ghv_ver_id      per_gen_hierarchy_versions.hierarchy_version_id%TYPE;
    l_proc            VARCHAR2(100);

    --
    -------------------------------------------------------------------------
    -------------------------< write_geo_cache >-----------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to write calendar event GEO mapping records to the
    -- GEO cache table
    --
    PROCEDURE write_geo_cache(p_coverage_list     t_node_id_table
                             ,p_calendar_entry_id NUMBER
                             ) IS

      -- Cursor to fetch override identifier (if any)
      CURSOR c_geo_ovr ( cp_calendar_entry_id NUMBER
                       , cp_hierarchy_node_id NUMBER
                       ) IS
        SELECT cal_entry_value_id
        FROM per_cal_entry_values
        WHERE usage_flag = 'O'
        AND calendar_entry_id = cp_calendar_entry_id
        AND hierarchy_node_id = cp_hierarchy_node_id;

      l_ovr_id per_cal_entry_values.cal_entry_value_id%TYPE;
      l_proc   VARCHAR2(100);

    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.write_geo_cache';
      hr_utility.set_location('Entering '||l_proc,10);

      IF p_coverage_list.COUNT > 0 THEN
        hr_utility.set_location(l_proc,12);
        FOR idx IN p_coverage_list.FIRST .. p_coverage_list.LAST LOOP
          hr_utility.set_location(l_proc,14);
          l_ovr_id := NULL;

          -- Get override (if any)
          OPEN c_geo_ovr (p_calendar_entry_id
                         ,p_coverage_list(idx)
                         );
          FETCH c_geo_ovr INTO l_ovr_id;
          CLOSE c_geo_ovr;

          hr_utility.set_location(l_proc,18);

          INSERT INTO per_cal_entry_geo_list
            (calendar_entry_id
            ,hierarchy_node_id
            ,ovr_cal_entry_value_id
            ,last_update_date
            ,last_updated_by
            ,last_update_login
            ,created_by
            ,creation_date
            )
          VALUES
            (p_calendar_entry_id
            ,p_coverage_list(idx)
            ,l_ovr_id
            ,TRUNC(SYSDATE)
            ,0
            ,0
            ,0
            ,TRUNC(SYSDATE)
            );
        END LOOP;
      END IF;

      COMMIT;

      hr_utility.set_location('Leaving '||l_proc,20);
    END write_geo_cache;

    --
    -------------------------------------------------------------------------
    -------------------------< is_node_in_list >-----------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to check is a given node is in the given list
    --
    FUNCTION is_node_in_list(p_node_id   NUMBER
                            ,p_node_list t_node_id_table
                            ) RETURN BOOLEAN IS
      l_return BOOLEAN;
      l_proc   VARCHAR2(100);
    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.is_node_in_list';
      hr_utility.set_location('Entering '||l_proc,10);
      l_return := FALSE;

      IF p_node_list.COUNT > 0 THEN
        hr_utility.set_location(l_proc,13);
        FOR idx IN p_node_list.FIRST .. p_node_list.LAST LOOP
          hr_utility.set_location(l_proc,15);
          IF p_node_list(idx) = p_node_id THEN
            l_return := TRUE;
            EXIT;
          END IF;
        END LOOP;
      END IF;

      hr_utility.set_location('Leaving '||l_proc,20);

      RETURN l_return;
    END is_node_in_list;

    --
    -------------------------------------------------------------------------
    -------------------------< get_child_nodes >-----------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to get the child coverage records for a given event
    --
    FUNCTION get_child_nodes(p_coverage_node_id NUMBER
                            ,p_exclusion_list   t_node_id_table
                            ,p_geo_hier_table   t_geo_hier_table
                            ) RETURN t_node_id_table IS
      l_result_list        t_node_id_table;
      l_result_count       NUMBER;
      l_coverage_top_level NUMBER;
      l_exclusion_level    NUMBER;
      l_parent_found       BOOLEAN;
      l_exclude_flag       BOOLEAN;
      l_proc               VARCHAR2(100);

    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.get_child_nodes';
      hr_utility.set_location('Entering '||l_proc,10);

      l_result_count       := 0;
      l_parent_found       := FALSE;
      l_exclude_flag       := FALSE;
      l_coverage_top_level := 1;
      l_exclusion_level    := 0;

      IF p_geo_hier_table.COUNT > 0 THEN
        hr_utility.set_location(l_proc,15);

        -- Loop through the geo hier tree nodes
        FOR idx IN p_geo_hier_table.FIRST .. p_geo_hier_table.LAST LOOP
          hr_utility.set_location(l_proc,20);

          IF p_geo_hier_table(idx).hierarchy_node_id = p_coverage_node_id THEN
            hr_utility.set_location(l_proc,30);
            -- This is the first HN for the COV
            l_parent_found := TRUE;
            l_result_count := l_result_count + 1;
            l_result_list(l_result_count) := p_geo_hier_table(idx).hierarchy_node_id;
            l_coverage_top_level := p_geo_hier_table(idx).level;
          ELSE -- not first HN
            hr_utility.set_location(l_proc,40);

            IF l_parent_found THEN
              hr_utility.set_location(l_proc,50);

              -- Check if we have moved back up the tree beyond coverage level
              IF p_geo_hier_table(idx).level <= l_coverage_top_level THEN
                hr_utility.set_location(l_proc,60);
                -- Stop as we have moved up the tree again
                EXIT; -- break the loop
              END IF; -- level check

              -- Check if we need to stop exclusions due to moving up the tree
              -- beyond exclusion level
              IF l_exclude_flag AND l_exclusion_level >= p_geo_hier_table(idx).level THEN
                hr_utility.set_location(l_proc,70);
                l_exclude_flag := FALSE;
              END IF;

              -- Check for node exclusion
              IF NOT l_exclude_flag AND p_exclusion_list.COUNT > 0 THEN
                hr_utility.set_location(l_proc,80);
                l_exclude_flag := is_node_in_list(p_geo_hier_table(idx).hierarchy_node_id
                                                 ,p_exclusion_list
                                                 );
                IF l_exclude_flag THEN
                  hr_utility.set_location(l_proc,90);
                  -- Note the exclusion level
                  l_exclusion_level := p_geo_hier_table(idx).level;
                END IF; -- exclusion
              END IF; -- check node exclusion

              -- Check if node is in coverage and save
              IF NOT l_exclude_flag THEN
                hr_utility.set_location(l_proc,100);
                l_result_count := l_result_count + 1;
                l_result_list(l_result_count) := p_geo_hier_table(idx).hierarchy_node_id;
              END IF; -- Node is in coverage

            END IF; -- first HN found
          END IF; -- first HN

        END LOOP; -- geo hier elements
      END IF; -- count

      hr_utility.set_location('Leaving '||l_proc,110);

      RETURN l_result_list;
    END get_child_nodes;

    --
    -------------------------------------------------------------------------
    -----------------------< process_geo_coverage >--------------------------
    -------------------------------------------------------------------------
    --
    -- Private procedure to build mapping data
    --
    PROCEDURE process_geo_coverage(p_geo_hier_table  t_geo_hier_table
                                  ,p_cal_event_table t_cal_event_table
                                  ) IS
      -- Local variables for process_geo_coverage
      l_exc_count        NUMBER;
      l_coverage_node_id NUMBER;
      l_coverage_list    t_node_id_table;
      l_exclusion_list   t_node_id_table;
      l_proc             VARCHAR2(100);
    BEGIN
      l_proc := 'HR_CAL_EVENT_MAPPING_PKG.process_geo_coverage';
      hr_utility.set_location('Entering '||l_proc,10);
      l_exc_count := 0;
      IF p_cal_event_table.COUNT > 0 THEN
        hr_utility.set_location(l_proc,20);
        -- Loop for each entry in the calendar entry table passed in
        FOR idx IN p_cal_event_table.FIRST .. p_cal_event_table.LAST LOOP
          hr_utility.set_location(l_proc,30);
          IF p_cal_event_table(idx).usage = 'COV' THEN
            hr_utility.set_location(l_proc,40);
            -- This is the start of a coverage
            l_coverage_node_id := p_cal_event_table(idx).hierarchy_node_id;
          ELSIF p_cal_event_table(idx).usage = 'EXC' THEN
            hr_utility.set_location(l_proc,50);
            -- Note the exclusion node
            l_exc_count := l_exc_count + 1;
            l_exclusion_list(l_exc_count) := p_cal_event_table(idx).hierarchy_node_id;
          END IF;
          -- If end of coverage, process the coverage
          IF p_cal_event_table(idx).entry_flag = 'E' THEN
            hr_utility.set_location(l_proc,60);
            l_coverage_list := get_child_nodes(l_coverage_node_id
                                              ,l_exclusion_list
                                              ,p_geo_hier_table
                                              );
            -- If coverage rows returned, write to cache
            IF l_coverage_list.COUNT > 0 THEN
              hr_utility.set_location(l_proc,70);
              write_geo_cache(l_coverage_list
                             ,p_cal_event_table(idx).calendar_entry_id
                             );
            END IF; -- coverage rows returned

            -- Reset local variables for next calendar event
            l_exc_count := 0;
            l_coverage_node_id := NULL;
            l_coverage_list.DELETE;
            l_exclusion_list.DELETE;
            hr_utility.set_location(l_proc,80);

          END IF; -- end of coverage
        END LOOP; -- event loop
      END IF; -- count of events to process
      hr_utility.set_location('Leaving '||l_proc,90);
    END process_geo_coverage;

  BEGIN -- populate_geo_list
    l_proc := 'HR_CAL_EVENT_MAPPING_PKG.populate_geo_list';
    hr_utility.set_location('Entering '||l_proc,10);

    -- Get the identifiers for all the hierarchies that need to be processed.
    FOR l_ghv_rec IN c_ghv_ids LOOP
      hr_utility.set_location('GHVId:'||l_ghv_rec.ghv_id,20);

      -- Get the version of the associated GEO hierarchy
      OPEN c_ghv_ver_id(l_ghv_rec.ghv_id);
      FETCH c_ghv_ver_id INTO l_ghv_ver_id;
      CLOSE c_ghv_ver_id;

      hr_utility.set_location('GHVVerId:'||l_ghv_ver_id,25);

      hr_utility.set_location(l_proc,50);

      -- Get the calendar events for the GEO Hierarchy
      FOR l_geo_event_rec IN c_geo_events(l_ghv_rec.ghv_id) LOOP
        hr_utility.set_location(l_proc,60);
        -- Store the event
        l_cal_event_table(c_geo_events%ROWCOUNT) := l_geo_event_rec;

        IF c_geo_events%ROWCOUNT > 1 THEN
          hr_utility.set_location(l_proc,70);

          -- This is not the first record. Check if different from the
          -- previous event.
          IF l_geo_event_rec.calendar_entry_id <>
             l_cal_event_table(c_geo_events%ROWCOUNT-1).calendar_entry_id THEN
            hr_utility.set_location(l_proc,80);

            -- Mark end of old event coverage and start of new event coverage
            l_cal_event_table(c_geo_events%ROWCOUNT-1).entry_flag := 'E';
            l_cal_event_table(c_geo_events%ROWCOUNT).entry_flag := 'S';
          END IF;

        ELSE
          hr_utility.set_location(l_proc,90);
          -- This is the first record. Mark it as coverage start.
          l_cal_event_table(c_geo_events%ROWCOUNT).entry_flag := 'S';
        END IF;

      END LOOP; -- c_geo_events

      -- Mark end of coverage for the last row
      IF l_cal_event_table.COUNT > 0 THEN
        hr_utility.set_location(l_proc,100);
        l_cal_event_table(l_cal_event_table.LAST).entry_flag := 'E';
      END IF;

    END LOOP; -- c_ghv_ids

    hr_utility.set_location(l_proc,110);

    -- Get the top of the associated GEO hierarchy
      /*OPEN c_geo_hier_top(l_ghv_ver_id);
      FETCH c_geo_hier_top INTO l_top_node_id;
      CLOSE c_geo_hier_top;*/

    FOR l_geo_hier_top_rec IN c_geo_hier_top(l_ghv_ver_id) LOOP

      l_top_node_id := l_geo_hier_top_rec.hierarchy_node_id;
      hr_utility.set_location('TopNodeId:'||l_top_node_id,30);

      -- Get the nodes of the associated GEO hierarchy
      FOR l_geo_hier_node_rec IN c_geo_hier_nodes(l_ghv_ver_id
                                                 ,l_top_node_id
                                                 ) LOOP
        hr_utility.set_location(l_proc,40);
        -- Store the GEO hierarchy node
        l_geo_hier_table(c_geo_hier_nodes%ROWCOUNT) := l_geo_hier_node_rec;
      END LOOP; -- c_geo_hier_nodes

       -- Process coverage data
      process_geo_coverage(l_geo_hier_table
                        ,l_cal_event_table
                        );

    END LOOP ; -- hier_top

    hr_utility.set_location('Leaving '||l_proc,120);
  END populate_geo_list;

  --
  -----------------------------------------------------------------------------
  ---------------------------< build_event_cache >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- Public procedure which populates the calendar event mapping cache tables
  -- and generates stats for these.
  --
  PROCEDURE build_event_cache(errbuf  IN OUT NOCOPY VARCHAR2
                             ,retcode IN OUT NOCOPY NUMBER
                             ) IS

    l_process_date DATE;
    l_table_owner  VARCHAR2(30);
    l_status       VARCHAR2(255);
    l_industry     VARCHAR2(255);
    l_dummy        BOOLEAN;
    l_proc         VARCHAR2(100);

  BEGIN
    l_proc := 'HR_CAL_EVENT_MAPPING_PKG.build_event_cache';
    hr_utility.set_location('Entering '||l_proc,10);

    -- Delete previous event org list records as this execution will
    -- refresh the list
    DELETE FROM per_cal_entry_org_list;
    DELETE FROM per_cal_entry_geo_list;

    hr_utility.set_location(l_proc,20);

    -- Generate event list for organization hierarchy coverage.
    populate_org_list;

    hr_utility.set_location(l_proc,30);

    -- Generate event list for geographic hierarchy coverage.
    populate_geo_list;

    hr_utility.set_location(l_proc,40);

    -- Gather stats on the cache tables for current schema (clone)
    l_dummy := fnd_installation.get_app_info
                    (application_short_name => 'PER'
                    ,status                 => l_status
                    ,industry               => l_industry
                    ,oracle_schema          => l_table_owner
                    );

    hr_utility.set_location(l_proc,50);

    fnd_stats.gather_table_stats(ownname => l_table_owner
                                ,tabname => 'PER_CAL_ENTRY_ORG_LIST'
                                ,percent => 50
                                );

    hr_utility.set_location(l_proc,60);

    fnd_stats.gather_table_stats(ownname => l_table_owner
                                ,tabname => 'PER_CAL_ENTRY_GEO_LIST'
                                ,percent => 50
                                );

    hr_utility.set_location('Leaving '||l_proc,70);
  END build_event_cache;

  --
  -----------------------------------------------------------------------------
  ------------------------< get_per_asg_cal_events >---------------------------
  -----------------------------------------------------------------------------
  --
  -- Public function returning a list of calendar events applicable to a person
  --
  PROCEDURE get_per_asg_cal_events (p_person_id        IN            NUMBER
                                   ,p_assignment_id    IN            NUMBER   DEFAULT NULL
                                   ,p_event_type       IN            VARCHAR2 DEFAULT NULL
                                   ,p_start_date       IN            DATE     DEFAULT NULL
                                   ,p_end_date         IN            DATE     DEFAULT NULL
                                   ,p_event_type_flag  IN            VARCHAR2 DEFAULT NULL
                                   ,x_cal_event_varray IN OUT NOCOPY per_cal_event_varray
                                   ) IS

    -- Cursor to fetch person assignment
    CURSOR c_per_asg ( cp_person_id     NUMBER
                     , cp_assignment_id NUMBER
                     , cp_start_date    DATE
                     , cp_end_date      DATE
                     ) IS
      SELECT assignment_id,
             organization_id, -- ORG Node Id
             location_id, -- for GEO mapping
             business_group_id -- for GEO mapping
      FROM per_all_assignments_f
      WHERE person_id = cp_person_id
      AND (
           (cp_assignment_id IS NOT NULL AND assignment_id = cp_assignment_id)
           OR
           (cp_assignment_id IS NULL AND primary_flag = 'Y')
          )
      AND effective_start_date <= NVL(cp_end_date, SYSDATE)
      AND effective_end_date >= NVL(cp_start_date, SYSDATE);

    -- Cursor to fetch GEO node at assignment EIT level
    CURSOR c_asg_geo_node (cp_assignment_id NUMBER) IS
      SELECT aei_information1
      FROM per_assignment_extra_info
      WHERE assignment_id = cp_assignment_id
      AND information_type = FND_PROFILE.value('HR_GEO_HIER_NODE_MAP')
      AND aei_information_category = FND_PROFILE.value('HR_GEO_HIER_NODE_MAP');

    -- Cursor to fetch GEO node at location EIT level
    CURSOR c_loc_geo_node (cp_location_id NUMBER) IS
      SELECT lei_information1
      FROM hr_location_extra_info
      WHERE location_id = cp_location_id
      AND information_type = FND_PROFILE.value('HR_GEO_HIER_NODE_MAP')
      AND lei_information_category = FND_PROFILE.value('HR_GEO_HIER_NODE_MAP');

    -- Cursor to fetch GEO node at business group legislation level
    CURSOR c_bg_geo_node (cp_business_group_id NUMBER) IS
      SELECT org_information9
      FROM hr_organization_information
      WHERE organization_id = cp_business_group_id
      AND org_information_context = 'Business Group Information'
      AND attribute_category = 'Business Group Information';

    -- Cursor to fetch GEO Node Id
    CURSOR c_geo_node_id (cp_geo_node VARCHAR2) IS
      SELECT GHN.hierarchy_node_id
      FROM per_gen_hierarchy GH,
           per_gen_hierarchy_versions GHV,
           per_gen_hierarchy_nodes GHN
      WHERE GH.type = 'PER_CAL_GEO'
      AND GH.hierarchy_id = GHV.hierarchy_id
      AND GHV.version_number = 1
      AND GHV.hierarchy_version_id = GHN.hierarchy_version_id
      AND GHN.entity_id = cp_geo_node;

    -- Cursor to fetch ORG events
    CURSOR c_org_events ( cp_organization_id NUMBER
                        , cp_event_type      VARCHAR2
                        , cp_start_date      DATE
                        , cp_end_date        DATE
                        ) IS
      SELECT ENT.calendar_entry_id,
             ENT.business_group_id,
             ENT.name,
             ENT.type,
             ENT.start_date,
             ENT.end_date,
             ENT.start_hour,
             ENT.end_hour,
             ENT.start_min,
             ENT.end_min,
             ORGENT.ovr_cal_entry_value_id
      FROM per_cal_entry_org_list ORGENT,
           per_calendar_entries   ENT
      WHERE ORGENT.organization_id = cp_organization_id
      AND ORGENT.calendar_entry_id = ENT.calendar_entry_id
      AND ENT.type = NVL(cp_event_type, ENT.type)
      AND ENT.start_date <= NVL(cp_end_date, ENT.start_date)
      AND ENT.end_date >= NVL(cp_start_date, ENT.end_date);

    -- Cursor to fetch GEO events
    CURSOR c_geo_events ( cp_geo_node_id NUMBER
                        , cp_event_type  VARCHAR2
                        , cp_start_date  DATE
                        , cp_end_date    DATE
                        ) IS
      SELECT ENT.calendar_entry_id,
             ENT.business_group_id,
             ENT.name,
             ENT.type,
             ENT.start_date,
             ENT.end_date,
             ENT.start_hour,
             ENT.end_hour,
             ENT.start_min,
             ENT.end_min,
             GEOENT.ovr_cal_entry_value_id
      FROM per_cal_entry_geo_list GEOENT,
           per_calendar_entries   ENT
      WHERE GEOENT.hierarchy_node_id = cp_geo_node_id
      AND GEOENT.calendar_entry_id = ENT.calendar_entry_id
      AND ENT.type = NVL(cp_event_type, ENT.type)
      AND ENT.start_date <= NVL(cp_end_date, ENT.start_date)
      AND ENT.end_date >= NVL(cp_start_date, ENT.end_date);

    -- Cursor to fetch event override name and type
    CURSOR c_event_ovr (cp_ovr_id NUMBER) IS
      SELECT override_name
            ,override_type
      FROM per_cal_entry_values
      WHERE cal_entry_value_id = cp_ovr_id;

    l_proc             VARCHAR2(50);
    l_cal_event_obj    per_cal_event_obj;
    l_event_type_flag  VARCHAR2(1);
    l_null_times       BOOLEAN;
    l_not_null_times   BOOLEAN;
    l_start_date       DATE;
    l_end_date         DATE;

    -- Person Assigment attributes
    l_assignment_id     per_all_assignments_f.assignment_id%TYPE;
    l_organization_id   per_all_assignments_f.organization_id%TYPE;
    l_location_id       per_all_assignments_f.location_id%TYPE;
    l_business_group_id per_all_assignments_f.business_group_id%TYPE;

    -- GEO Node attributes
    l_geo_node    VARCHAR2(150);
    l_geo_node_id NUMBER;

    -- Calendar event override attributes
    l_ovr_id           NUMBER;
    l_ovr_name         per_cal_entry_values.override_name%TYPE;
    l_ovr_type         per_cal_entry_values.override_type%TYPE;

    -- Local exceptions
    e_param_valdn_fail EXCEPTION;
    e_bg_leg_not_found EXCEPTION;

  BEGIN
    l_proc := 'hr_cal_event_mapping_pkg.get_per_asg_cal_events';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    l_cal_event_obj := per_cal_event_obj(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    x_cal_event_varray := per_cal_event_varray(); -- initialize empty
    l_event_type_flag := NVL(p_event_type_flag, 'B');
    l_geo_node := NULL;

    -- Range validate supplied start and end dates
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
      IF p_end_date < p_start_date THEN
        hr_utility.set_location(l_proc, 20);
        RAISE e_param_valdn_fail;
      END IF;
      l_start_date := TRUNC(p_start_date);
      l_end_date := TRUNC(p_end_date);
    END IF;

    -- Validate event type flag
    IF l_event_type_flag NOT IN ('B', -- Both ORG and GEO events
                                 'O', -- Only ORG events
                                 'G'  -- Only GEO events
                                ) THEN
      hr_utility.set_location(l_proc, 30);
      RAISE e_param_valdn_fail;
    END IF;

    -- Get the person assignment identifier
    OPEN c_per_asg ( p_person_id
                   , p_assignment_id
                   , p_start_date
                   , p_end_date
                   );
    FETCH c_per_asg INTO l_assignment_id
                       , l_organization_id
                       , l_location_id
                       , l_business_group_id;
    CLOSE c_per_asg;

    hr_utility.set_location('PerId: '||p_person_id||' AsgId: '||l_assignment_id, 30);

    -- Get GEO node from assignment EIT if present
    IF l_event_type_flag IN ('B','G') THEN
      BEGIN
        OPEN c_asg_geo_node (l_assignment_id);
        FETCH c_asg_geo_node INTO l_geo_node;
        CLOSE c_asg_geo_node;
        hr_utility.set_location('GEONode: '||l_geo_node, 40);
      EXCEPTION
        WHEN OTHERS THEN
          -- GEO node not found at assignment EIT level
          hr_utility.set_location(l_proc, 45);
      END;
    END IF; -- event flag is 'B' or 'G'

    -- Get GEO node from location EIT if present
    IF l_event_type_flag IN ('B','G') AND l_geo_node IS NULL THEN
      BEGIN
        OPEN c_loc_geo_node (l_location_id);
        FETCH c_loc_geo_node INTO l_geo_node;
        CLOSE c_loc_geo_node;
        hr_utility.set_location('GEONode: '||l_geo_node, 50);
      EXCEPTION
        WHEN OTHERS THEN
          -- GEO node not found at location EIT level
          hr_utility.set_location(l_proc, 55);
      END;
    END IF; -- event flag is ('B' or 'G') and GEO Node not yet found

    -- Get GEO node from business group legislation
    IF l_event_type_flag IN ('B','G') AND l_geo_node IS NULL THEN
      BEGIN
        OPEN c_bg_geo_node (l_business_group_id);
        FETCH c_bg_geo_node INTO l_geo_node;
        CLOSE c_bg_geo_node;
        hr_utility.set_location('GEONode: '||l_geo_node, 60);
      EXCEPTION
        WHEN OTHERS THEN
          -- GEO node not found at business group legislation level
          hr_utility.set_location(l_proc, 65);
          RAISE e_bg_leg_not_found;
      END;
    END IF; -- event flag is ('B' or 'G') and GEO Node not yet found

    -- Get GEO Node Id
    IF l_event_type_flag IN ('B','G') AND l_geo_node IS NOT NULL THEN
      OPEN c_geo_node_id (l_geo_node);
      FETCH c_geo_node_id INTO l_geo_node_id;
      CLOSE c_geo_node_id;
      hr_utility.set_location('GEONodeId: '||l_geo_node_id, 70);
    END IF; -- event flag is ('B' or 'G') and GEO Node found

    -- Get ORG Events if required
    IF l_event_type_flag IN ('B','O') AND l_organization_id IS NOT NULL THEN
      OPEN c_org_events (l_organization_id
                        ,p_event_type
                        ,l_start_date
                        ,p_end_date
                        );
      LOOP -- ORG Events
        l_ovr_id := NULL;
        l_ovr_name := NULL;
        l_ovr_type := NULL;

        FETCH c_org_events INTO l_cal_event_obj.cal_event_id
                               ,l_cal_event_obj.business_group_id
                               ,l_cal_event_obj.event_name
                               ,l_cal_event_obj.event_type
                               ,l_cal_event_obj.start_date
                               ,l_cal_event_obj.end_date
                               ,l_cal_event_obj.start_hour
                               ,l_cal_event_obj.end_hour
                               ,l_cal_event_obj.start_minute
                               ,l_cal_event_obj.end_minute
                               ,l_ovr_id;
        EXIT WHEN c_org_events%NOTFOUND;

        -- Handle incomplete times
        l_null_times := FALSE;
        l_not_null_times := FALSE;
        IF l_cal_event_obj.start_hour IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_cal_event_obj.end_hour IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_cal_event_obj.start_minute IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_cal_event_obj.end_minute IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_null_times AND l_not_null_times THEN
          -- Mixed nulls have been entered i.e. incomplete times
          IF l_cal_event_obj.start_hour IS NULL THEN
            l_cal_event_obj.start_hour := '0';
          END IF;
          IF l_cal_event_obj.end_hour IS NULL THEN
            l_cal_event_obj.end_hour := '0';
          END IF;
          IF l_cal_event_obj.start_minute IS NULL THEN
            l_cal_event_obj.start_minute := '0';
          END IF;
          IF l_cal_event_obj.end_minute IS NULL THEN
            l_cal_event_obj.end_minute := '0';
          END IF;
        END IF;

        -- Adjust date for same day events for CAC integration
        IF (
            (l_cal_event_obj.start_hour IS NULL AND
             l_cal_event_obj.end_hour IS NULL AND
             l_cal_event_obj.start_minute IS NULL AND
             l_cal_event_obj.end_minute IS NULL
            )
            OR
            (l_cal_event_obj.start_hour IS NOT NULL AND
             l_cal_event_obj.end_hour IS NOT NULL AND
             l_cal_event_obj.start_minute IS NOT NULL AND
             l_cal_event_obj.end_minute IS NOT NULL AND
             l_cal_event_obj.start_hour = l_cal_event_obj.end_hour AND
             l_cal_event_obj.start_minute = l_cal_event_obj.end_minute AND
             l_cal_event_obj.start_hour = '0' AND
             l_cal_event_obj.start_minute = '0' AND
             l_cal_event_obj.start_date = l_cal_event_obj.end_date
            )
           ) THEN
          l_cal_event_obj.end_date := l_cal_event_obj.end_date + 1;
          IF (l_cal_event_obj.start_hour IS NULL AND
              l_cal_event_obj.end_hour IS NULL AND
              l_cal_event_obj.start_minute IS NULL AND
              l_cal_event_obj.end_minute IS NULL) THEN
            l_cal_event_obj.start_hour:= '0';
            l_cal_event_obj.end_hour := '0';
            l_cal_event_obj.start_minute := '0';
            l_cal_event_obj.end_minute := '0';
          END IF;
        END IF;

        -- Fetch override if it exists
        IF l_ovr_id IS NOT NULL THEN
          OPEN c_event_ovr (l_ovr_id);
          FETCH c_event_ovr INTO l_ovr_name,
                                 l_ovr_type;
          CLOSE c_event_ovr;
          l_cal_event_obj.event_name := NVL(l_ovr_name, l_cal_event_obj.event_name);
          l_cal_event_obj.event_type := NVL(l_ovr_type, l_cal_event_obj.event_type);
        END IF;

        x_cal_event_varray.EXTEND(1);
        x_cal_event_varray(x_cal_event_varray.COUNT) := l_cal_event_obj;
      END LOOP; -- ORG Events
      CLOSE c_org_events;
      hr_utility.set_location(l_proc, 80);
    END IF; -- event flag is ('B' or ')') and ORG Node Id found

    -- Get GEO Events if required
    IF l_event_type_flag IN ('B','G') AND l_geo_node_id IS NOT NULL THEN
      OPEN c_geo_events (l_geo_node_id
                        ,p_event_type
                        ,l_start_date
                        ,p_end_date
                        );
      LOOP -- GEO Events
        l_ovr_id := NULL;
        l_ovr_name := NULL;
        l_ovr_type := NULL;

        FETCH c_geo_events INTO l_cal_event_obj.cal_event_id
                               ,l_cal_event_obj.business_group_id
                               ,l_cal_event_obj.event_name
                               ,l_cal_event_obj.event_type
                               ,l_cal_event_obj.start_date
                               ,l_cal_event_obj.end_date
                               ,l_cal_event_obj.start_hour
                               ,l_cal_event_obj.end_hour
                               ,l_cal_event_obj.start_minute
                               ,l_cal_event_obj.end_minute
                               ,l_ovr_id;
        EXIT WHEN c_geo_events%NOTFOUND;

        -- Handle incomplete times
        l_null_times := FALSE;
        l_not_null_times := FALSE;
        IF l_cal_event_obj.start_hour IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_cal_event_obj.end_hour IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_cal_event_obj.start_minute IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_cal_event_obj.end_minute IS NULL THEN
          l_null_times := TRUE;
        ELSE
          l_not_null_times := TRUE;
        END IF;
        IF l_null_times AND l_not_null_times THEN
          -- Mixed nulls have been entered i.e. incomplete times
          IF l_cal_event_obj.start_hour IS NULL THEN
            l_cal_event_obj.start_hour := '0';
          END IF;
          IF l_cal_event_obj.end_hour IS NULL THEN
            l_cal_event_obj.end_hour := '0';
          END IF;
          IF l_cal_event_obj.start_minute IS NULL THEN
            l_cal_event_obj.start_minute := '0';
          END IF;
          IF l_cal_event_obj.end_minute IS NULL THEN
            l_cal_event_obj.end_minute := '0';
          END IF;
        END IF;

        -- Adjust date for same day events for CAC integration
        IF (
            (l_cal_event_obj.start_hour IS NULL AND
             l_cal_event_obj.end_hour IS NULL AND
             l_cal_event_obj.start_minute IS NULL AND
             l_cal_event_obj.end_minute IS NULL
            )
            OR
            (l_cal_event_obj.start_hour IS NOT NULL AND
             l_cal_event_obj.end_hour IS NOT NULL AND
             l_cal_event_obj.start_minute IS NOT NULL AND
             l_cal_event_obj.end_minute IS NOT NULL AND
             l_cal_event_obj.start_hour = l_cal_event_obj.end_hour AND
             l_cal_event_obj.start_minute = l_cal_event_obj.end_minute AND
             l_cal_event_obj.start_hour = '0' AND
             l_cal_event_obj.start_minute = '0' AND
             l_cal_event_obj.start_date = l_cal_event_obj.end_date
            )
           ) THEN
          l_cal_event_obj.end_date := l_cal_event_obj.end_date + 1;
          IF (l_cal_event_obj.start_hour IS NULL AND
              l_cal_event_obj.end_hour IS NULL AND
              l_cal_event_obj.start_minute IS NULL AND
              l_cal_event_obj.end_minute IS NULL) THEN
            l_cal_event_obj.start_hour:= '0';
            l_cal_event_obj.end_hour := '0';
            l_cal_event_obj.start_minute := '0';
            l_cal_event_obj.end_minute := '0';
          END IF;
        END IF;

        -- Fetch override if it exists
        IF l_ovr_id IS NOT NULL THEN
          OPEN c_event_ovr (l_ovr_id);
          FETCH c_event_ovr INTO l_ovr_name,
                                 l_ovr_type;
          CLOSE c_event_ovr;
          l_cal_event_obj.event_name := NVL(l_ovr_name, l_cal_event_obj.event_name);
          l_cal_event_obj.event_type := NVL(l_ovr_type, l_cal_event_obj.event_type);
        END IF;

        x_cal_event_varray.EXTEND(1);
        x_cal_event_varray(x_cal_event_varray.COUNT) := l_cal_event_obj;
      END LOOP; -- GEO Events
      CLOSE c_geo_events;
      hr_utility.set_location(l_proc, 90);
    END IF; -- event flag is ('B' or 'G') and GEO Node Id found

    hr_utility.set_location('Leaving: '|| l_proc, 100);

  EXCEPTION

    WHEN e_param_valdn_fail THEN
      hr_utility.set_location('Leaving: '|| l_proc, 110);

    WHEN e_bg_leg_not_found THEN
      hr_utility.set_location('Leaving: '|| l_proc, 120);

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 130);
      hr_utility.set_location(SQLERRM, 135);

  END get_per_asg_cal_events;

  --
  -----------------------------------------------------------------------------
  -------------------< get_cal_events (Person Version) >-----------------------
  -----------------------------------------------------------------------------
  --
  -- Public function returning a list of calendar events applicable to a person
  --
  FUNCTION get_cal_events (p_person_id       IN NUMBER
                          ,p_event_type      IN VARCHAR2 DEFAULT NULL
                          ,p_start_date      IN DATE     DEFAULT NULL
                          ,p_end_date        IN DATE     DEFAULT NULL
                          ,p_event_type_flag IN VARCHAR2 DEFAULT NULL
                          ) RETURN per_cal_event_varray IS

    l_proc             VARCHAR2(60);
    l_cal_event_varray per_cal_event_varray;

  BEGIN

    l_proc := 'hr_cal_event_mapping_pkg.get_cal_events (PerVer)';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    -- Invoke private procedure to get calendar events
    get_per_asg_cal_events (p_person_id        => p_person_id
                           ,p_assignment_id    => ''
                           ,p_event_type       => p_event_type
                           ,p_start_date       => p_start_date
                           ,p_end_date         => p_end_date
                           ,p_event_type_flag  => p_event_type_flag
                           ,x_cal_event_varray => l_cal_event_varray
                           );

    hr_utility.set_location('Leaving: '|| l_proc, 20);
    RETURN l_cal_event_varray;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RETURN l_cal_event_varray;

  END get_cal_events; -- Person Version

  --
  -----------------------------------------------------------------------------
  ----------------< get_cal_events (Assignment Version) >----------------------
  -----------------------------------------------------------------------------
  --
  -- Public function returning a list of calendar events applicable to an
  -- assignment.
  --
  FUNCTION get_cal_events (p_assignment_id   IN NUMBER
                          ,p_event_type      IN VARCHAR2 DEFAULT NULL
                          ,p_start_date      IN DATE     DEFAULT NULL
                          ,p_end_date        IN DATE     DEFAULT NULL
                          ,p_event_type_flag IN VARCHAR2 DEFAULT NULL
                          ) RETURN per_cal_event_varray IS

    l_proc             VARCHAR2(60);
    l_cal_event_varray per_cal_event_varray;
    l_person_id        NUMBER;

    -- Cursor to get the person id for an assignment id.
    CURSOR c_per_id (cp_assignment_id NUMBER) IS
      SELECT person_id
      FROM per_all_assignments_f
      WHERE assignment_id = cp_assignment_id;

  BEGIN

    l_proc := 'hr_cal_event_mapping_pkg.get_cal_events (AsgVer)';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    -- Get the person id for an assignment id. Though multiple records could
    -- exist, the person id will be the same. So sufficient to fetch first.
    OPEN c_per_id (p_assignment_id);
    FETCH c_per_id INTO l_person_id;
    CLOSE c_per_id;

    hr_utility.set_location(l_proc, 20);

    -- Invoke private procedure to get calendar events
    get_per_asg_cal_events (p_person_id        => l_person_id
                           ,p_assignment_id    => p_assignment_id
                           ,p_event_type       => p_event_type
                           ,p_start_date       => p_start_date
                           ,p_end_date         => p_end_date
                           ,p_event_type_flag  => p_event_type_flag
                           ,x_cal_event_varray => l_cal_event_varray
                           );

    hr_utility.set_location('Leaving: '|| l_proc, 30);
    RETURN l_cal_event_varray;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 40);
      hr_utility.set_location(SQLERRM, 45);
      RETURN l_cal_event_varray;

  END get_cal_events; -- Assignment Version

  --
  -----------------------------------------------------------------------------
  ------------------< get_cal_events (HZ Party Version) >----------------------
  -----------------------------------------------------------------------------
  --
  -- Public function returning a list of calendar events applicable to an HZ
  -- party.
  --
  FUNCTION get_cal_events (p_hz_party_id     IN NUMBER
                          ,p_event_type      IN VARCHAR2 DEFAULT NULL
                          ,p_start_date      IN DATE     DEFAULT NULL
                          ,p_end_date        IN DATE     DEFAULT NULL
                          ,p_event_type_flag IN VARCHAR2 DEFAULT NULL
                          ) RETURN per_cal_event_varray IS

    l_proc             VARCHAR2(60);
    l_cal_event_varray per_cal_event_varray;
    l_person_id        NUMBER;

    -- Cursor to get the party id for a person id.
    CURSOR c_per_id (cp_party_id NUMBER) IS
      SELECT person_identifier
      FROM hz_parties
      WHERE party_id = cp_party_id
      AND created_by_module = 'HR API'
      AND orig_system_reference = 'PER:'||person_identifier;

  BEGIN

    l_proc := 'hr_cal_event_mapping_pkg.get_cal_events (HZVer)';
    hr_utility.set_location('Entering: '|| l_proc, 10);

    -- Get the person id for a party id. Though multiple records could
    -- exist, the person id will be the same. So sufficient to fetch first.
    OPEN c_per_id (p_hz_party_id);
    FETCH c_per_id INTO l_person_id;
    CLOSE c_per_id;

    hr_utility.set_location(l_proc, 20);

    -- Invoke private procedure to get calendar events
    get_per_asg_cal_events (p_person_id        => l_person_id
                           ,p_assignment_id    => ''
                           ,p_event_type       => p_event_type
                           ,p_start_date       => p_start_date
                           ,p_end_date         => p_end_date
                           ,p_event_type_flag  => p_event_type_flag
                           ,x_cal_event_varray => l_cal_event_varray
                           );

    hr_utility.set_location('Leaving: '|| l_proc, 30);
    RETURN l_cal_event_varray;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 40);
      hr_utility.set_location(SQLERRM, 45);
      RETURN l_cal_event_varray;

  END get_cal_events; -- HZ Party Version

  --
  -----------------------------------------------------------------------------
  --------------------------< get_all_cal_events >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- This function returns all the calendar events in the system or filtered
  -- as per given criteria.
  --
  FUNCTION get_all_cal_events (p_event_type IN VARCHAR2 DEFAULT NULL
                              ,p_start_date IN DATE     DEFAULT NULL
                              ,p_end_date   IN DATE     DEFAULT NULL
                              ) RETURN per_cal_event_varray IS

    l_proc             VARCHAR2(60);
    l_cal_event_varray per_cal_event_varray;
    l_cal_event_obj    per_cal_event_obj;
    l_null_times       BOOLEAN;
    l_not_null_times   BOOLEAN;
    l_bg_id            NUMBER;
    l_start_date       DATE;
    l_end_date         DATE;

    -- Cursor to fetch calendar events
    CURSOR c_cal_events ( cp_event_type VARCHAR2
                        , cp_start_date DATE
                        , cp_end_date   DATE
                        , cp_bg_id      NUMBER
                        ) IS
      SELECT calendar_entry_id,
             business_group_id,
             name,
             type,
             start_date,
             end_date,
             start_hour,
             end_hour,
             start_min,
             end_min
      FROM per_calendar_entries
      WHERE type = NVL(cp_event_type, type)
      AND start_date <= NVL(cp_end_date, start_date)
      AND end_date >= NVL(cp_start_date, end_date)
      AND (business_group_id IS NULL
           OR
           (business_group_id IS NOT NULL AND
            business_group_id = NVL(cp_bg_id, business_group_id)
           )
          );

  BEGIN

    l_proc := 'hr_cal_event_mapping_pkg.get_all_cal_events';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_cal_event_obj := per_cal_event_obj(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    l_cal_event_varray := per_cal_event_varray(); -- initialize empty
    l_bg_id := FND_PROFILE.Value('PER_BUSINESS_GROUP_ID');
    l_start_date := TRUNC(p_start_date);
    l_end_date := TRUNC(p_end_date);

    OPEN c_cal_events (p_event_type
                      ,l_start_date
                      ,p_end_date
                      ,l_bg_id
                      );
    LOOP -- Cal Events
      FETCH c_cal_events INTO l_cal_event_obj.cal_event_id
                             ,l_cal_event_obj.business_group_id
                             ,l_cal_event_obj.event_name
                             ,l_cal_event_obj.event_type
                             ,l_cal_event_obj.start_date
                             ,l_cal_event_obj.end_date
                             ,l_cal_event_obj.start_hour
                             ,l_cal_event_obj.end_hour
                             ,l_cal_event_obj.start_minute
                             ,l_cal_event_obj.end_minute;
      EXIT WHEN c_cal_events%NOTFOUND;

      -- Handle incomplete times
      l_null_times := FALSE;
      l_not_null_times := FALSE;
      IF l_cal_event_obj.start_hour IS NULL THEN
        l_null_times := TRUE;
      ELSE
        l_not_null_times := TRUE;
      END IF;
      IF l_cal_event_obj.end_hour IS NULL THEN
        l_null_times := TRUE;
      ELSE
        l_not_null_times := TRUE;
      END IF;
      IF l_cal_event_obj.start_minute IS NULL THEN
        l_null_times := TRUE;
      ELSE
        l_not_null_times := TRUE;
      END IF;
      IF l_cal_event_obj.end_minute IS NULL THEN
        l_null_times := TRUE;
      ELSE
        l_not_null_times := TRUE;
      END IF;
      IF l_null_times AND l_not_null_times THEN
        -- Mixed nulls have been entered i.e. incomplete times
        IF l_cal_event_obj.start_hour IS NULL THEN
          l_cal_event_obj.start_hour := '0';
        END IF;
        IF l_cal_event_obj.end_hour IS NULL THEN
          l_cal_event_obj.end_hour := '0';
        END IF;
        IF l_cal_event_obj.start_minute IS NULL THEN
          l_cal_event_obj.start_minute := '0';
        END IF;
        IF l_cal_event_obj.end_minute IS NULL THEN
          l_cal_event_obj.end_minute := '0';
        END IF;
      END IF;

      -- Adjust date for same day events for CAC integration
      IF (
          (l_cal_event_obj.start_hour IS NULL AND
           l_cal_event_obj.end_hour IS NULL AND
           l_cal_event_obj.start_minute IS NULL AND
           l_cal_event_obj.end_minute IS NULL
          )
          OR
          (l_cal_event_obj.start_hour IS NOT NULL AND
           l_cal_event_obj.end_hour IS NOT NULL AND
           l_cal_event_obj.start_minute IS NOT NULL AND
           l_cal_event_obj.end_minute IS NOT NULL AND
           l_cal_event_obj.start_hour = l_cal_event_obj.end_hour AND
           l_cal_event_obj.start_minute = l_cal_event_obj.end_minute AND
           l_cal_event_obj.start_hour = '0' AND
           l_cal_event_obj.start_minute = '0' AND
           l_cal_event_obj.start_date = l_cal_event_obj.end_date
          )
         ) THEN
        l_cal_event_obj.end_date := l_cal_event_obj.end_date + 1;
        IF (l_cal_event_obj.start_hour IS NULL AND
            l_cal_event_obj.end_hour IS NULL AND
            l_cal_event_obj.start_minute IS NULL AND
            l_cal_event_obj.end_minute IS NULL) THEN
          l_cal_event_obj.start_hour:= '0';
          l_cal_event_obj.end_hour := '0';
          l_cal_event_obj.start_minute := '0';
          l_cal_event_obj.end_minute := '0';
        END IF;
      END IF;

      l_cal_event_varray.EXTEND(1);
      l_cal_event_varray(l_cal_event_varray.COUNT) := l_cal_event_obj;
    END LOOP; -- ORG Events
    CLOSE c_cal_events;

    hr_utility.set_location('Leaving: '|| l_proc, 20);
    RETURN l_cal_event_varray;

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 30);
      hr_utility.set_location(SQLERRM, 35);
      RETURN l_cal_event_varray;

  END get_all_cal_events;

  --
  -----------------------------------------------------------------------------
  -------------------------< build_cal_map_cache >-----------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure builds transient data into table PER_CAL_MAP_CACHE for
  -- use by the calendar mapping user interface.
  --
  PROCEDURE build_cal_map_cache (p_person_id     IN NUMBER
                                ,p_assignment_id IN NUMBER
                                ,p_event_type    IN VARCHAR2 DEFAULT NULL
                                ,p_start_date    IN DATE     DEFAULT NULL
                                ,p_end_date      IN DATE     DEFAULT NULL
                                ) IS

    l_proc             VARCHAR2(60);
    l_cal_event_varray per_cal_event_varray;
    l_cal_event_obj    per_cal_event_obj;

  BEGIN

    l_proc := 'hr_cal_event_mapping_pkg.build_cal_map_cache';
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_cal_event_obj := per_cal_event_obj(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    l_cal_event_varray := per_cal_event_varray(); -- initialize empty

    l_cal_event_varray := get_cal_events ( p_assignment_id => p_assignment_id
                                         , p_event_type => p_event_type
                                         , p_start_date => p_start_date
                                         , p_end_date => p_end_date
                                         );

    hr_utility.set_location(l_proc, 20);

    DELETE FROM per_cal_map_cache;

    hr_utility.set_location(l_proc, 30);

    IF l_cal_event_varray.COUNT > 0 THEN
      hr_utility.set_location(l_proc, 35);

      FOR idx IN l_cal_event_varray.FIRST..l_cal_event_varray.LAST LOOP
        l_cal_event_obj := l_cal_event_varray(idx);
        INSERT INTO per_cal_map_cache
          (person_id
          ,assignment_id
          ,event_name
          ,event_type
          ,start_date
          ,end_date
          ,start_hour
          ,end_hour
          ,start_minute
          ,end_minute
          )
        VALUES
          (p_person_id
          ,p_assignment_id
          ,l_cal_event_obj.event_name
          ,l_cal_event_obj.event_type
          ,l_cal_event_obj.start_date
          ,l_cal_event_obj.end_date
          ,l_cal_event_obj.start_hour
          ,l_cal_event_obj.end_hour
          ,l_cal_event_obj.start_minute
          ,l_cal_event_obj.end_minute
          );
      END LOOP;
    END IF;

    hr_utility.set_location(l_proc, 40);

    COMMIT;

    hr_utility.set_location('Leaving: '|| l_proc, 50);

  EXCEPTION

    WHEN OTHERS THEN
      hr_utility.set_location('Leaving: '|| l_proc, 60);
      hr_utility.set_location(SQLERRM, 65);

  END build_cal_map_cache;

END hr_cal_event_mapping_pkg;

/
