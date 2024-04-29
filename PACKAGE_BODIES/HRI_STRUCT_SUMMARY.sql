--------------------------------------------------------
--  DDL for Package Body HRI_STRUCT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_STRUCT_SUMMARY" AS
/* $Header: hribstrc.pkb 115.21 2004/06/17 04:49:35 knarula noship $ */

--------------------------------------------------------------------------------

--Package Global Exceptions
e_g_no_top_node_found        exception;
e_g_many_top_nodes_found     exception;
--Package Global Variables
g_debug_flag                 BOOLEAN := TRUE;
-- EDW Default Last Update Date
g_default_last_update        DATE := to_date('01-01-2000','DD-MM-YYYY');
--------------------------------------------------------------------------------
--   Package Utilies
--
--------------------------------------------------------------------------------
PROCEDURE output(text1  VARCHAR2
                ,text2  VARCHAR2 DEFAULT NULL)
  IS

 l_text VARCHAR2(1000);

BEGIN
/*
  INSERT INTO HRI.HRI_DEBUG
  (Text1
  ,Text2
  ,time_date)
  values
  (Text1
  ,Text2
  ,sysdate);
  COMMIT;
*/
  /**/
  /*
  CREATE TABLE HRI.HRI_DEBUG
  (Text1 VARCHAR2(200)
  ,Text2 VARCHAR2(200)
  ,time_date  DATE)
  /**/

  -- write to the concurrent request log file.
  IF g_debug_flag = TRUE THEN
    IF text2 IS NOT NULL THEN
      l_text := text1 || ' : ' || text2;
    ELSE
      l_text := text1;
    END IF;

    fnd_file.put_line(FND_FILE.log, l_text);
  END IF;

END;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  GENERIC HIERARCHY FUNCTIONS
--
--  TABLE: HRI_GEN_HRCHY_SUMMARY
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  Function Name: Get_Top_Entity_id
--
--  Parameters:    p_gen_hierarhcy_version_id IN
--
--  Return:        Entity (Number) - if only 1 exists
--
--  Exceptions:    e_g_no_top_node_found    - if < 1 orgs found
--                 e_g_many_top_nodes_found - if > 1 orgs found
--
--  Description:   Returns entity id of top of org structure version if it exists
--                 otherwise exceptions
--
---------------------------------------------------------------------------------
FUNCTION Get_Top_Entity_Id
  (p_gen_hierarhcy_version_id IN NUMBER)
 RETURN NUMBER
 IS
-- Cursor returns the top entity of a particular entity structure
--  version
CURSOR csr_top_entity
         (cp_gen_hierarchy_version_id  NUMBER)
 IS

  SELECT ghn.entity_id    top_entity_id
  FROM  per_gen_hierarchy_nodes   ghn
  WHERE ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
  AND   ghn.parent_hierarchy_node_id is null;

--Return value
l_top_entity_id NUMBER;
--Local counter
l_counter    NUMBER;

BEGIN
  l_counter    := 0;
  l_top_entity_id := -1;

  FOR l_top_entity IN csr_top_entity
                    (p_gen_hierarhcy_version_id)
    LOOP
    l_counter := l_counter + 1;
    --output( '___Loop No: '|| to_char(l_counter));
    --output( '___Top Org: '|| to_char(l_top_entity.top_entity_id));
    l_top_entity_id := l_top_entity.top_entity_id;

  END LOOP;

  IF l_counter < 1 THEN
    RAISE e_g_no_top_node_found;
  ELSIF l_counter > 1 THEN
    RAISE e_g_many_top_nodes_found;
  END IF;

  RETURN l_top_entity_id;

END Get_Top_Entity_id;


--------------------------------------------------------------------------------
--  Procedure Name: Load_Org_Hierarchies
--
--  Exceptions:  None
--------------------------------------------------------------------------------
PROCEDURE Load_Org_Hierarchies
  (p_business_group_id       IN     NUMBER   DEFAULT NULL
  ,p_primary_hrchy_only      IN     VARCHAR2 DEFAULT 'Y'
  ,p_date                    IN     DATE     DEFAULT SYSDATE) IS

BEGIN

/* Call new organization hierarchy loading function */
  hri_opl_orgh.load(1500);

END Load_Org_Hierarchies;

--------------------------------------------------------------------------------
--  Procedure Name: Load_All_Org_Hierarchies
--
--  Exceptions:  None
--
--  Description: Overloaded version of Load_Org_Hierarchies
--               Overloaded to be called directly for debugging
--
--------------------------------------------------------------------------------
PROCEDURE Load_All_Org_Hierarchies
 IS
BEGIN

/* Call new organization hierarchy loading function */
  hri_opl_orgh.load(1500);

END Load_All_Org_Hierarchies;

--------------------------------------------------------------------------------
--  Procedure Name: Load_All_Org_Hierarchies
--
--  Exceptions:  None
--
--  Description: Overloaded version of Load_Org_Hierarchies
--               The purpose of this version is to be called from
--               the Concurrent Manager.
--
--------------------------------------------------------------------------------

PROCEDURE Load_All_Org_Hierarchies
    ( errbuf                       OUT NOCOPY  Varchar2
    , retcode                      OUT  NOCOPY Number )
 IS
BEGIN
  errbuf  := null;
  retcode := null;

  g_debug_flag := TRUE;

  Load_All_Org_Hierarchies;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;

END Load_All_Org_Hierarchies;

PROCEDURE Load_Gen_Hierarchies
  (p_business_group_id       IN     NUMBER   DEFAULT NULL)

 IS
---------------------
-- Cursor Definitions
---------------------


CURSOR csr_gen_struct_vers
         (cp_business_group_id  NUMBER)
 IS
  SELECT ghr.business_group_id
       , ghr.type
       , ghr.hierarchy_id
       , ghv.hierarchy_version_id
       , ghv.date_from
       , ghv.date_to
       , ghv.version_number
       , ghr.name
    FROM per_gen_hierarchy ghr
       , per_gen_hierarchy_versions ghv
   WHERE ghr.hierarchy_id = ghv.hierarchy_id
     AND ghr.business_group_id = ghv.business_group_id
     AND ghr.type = 'FEDREP'; -- bug 2492438
     -- bug 2834215 performance improvement removed order by

-- cursor walks down the tree to give all parent entities in a tree
-- and the level number where the top entity is 1.
CURSOR csr_gen_parents
        (cp_gen_hierarchy_version_id  NUMBER
        ,cp_top_entity_id       per_gen_hierarchy_nodes.entity_id%type ) -- 2492438
 IS
-- cursor walks down the tree to give all parent entities in a tree
-- and the level number where the top entity is 1.
  SELECT  ghn.business_group_id        business_group_id
        , ghn.hierarchy_node_id        hierarchy_node_id
        , ghn.entity_id                entity_id
        , LEVEL                        entity_level
        , ghn.node_type                node_type
   FROM per_gen_hierarchy_nodes ghn
   WHERE ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
   START WITH ghn.entity_id = cp_top_entity_id
   CONNECT BY  ghn.parent_hierarchy_node_id   =  PRIOR ghn.hierarchy_node_id
   -- Note: this looks excessive but making sure both
   -- the prior record and the current record
   -- are both using the specified org struct version
   AND PRIOR ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
   AND ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
  ;

-- cursor walks down the tree to give all children in the tree
-- and the number of levels away from the top entity
CURSOR csr_gen_children
        (cp_gen_hierarchy_version_id  NUMBER
        ,cp_top_entity_id       per_gen_hierarchy_nodes.entity_id%type ) -- 2492438
 IS
  SELECT  ghn.business_group_id        business_group_id
        , ghn.hierarchy_node_id        hierarchy_node_id
        , ghn.entity_id                entity_id
        , LEVEL -1                     entity_level
        , ghn.node_type                node_type
   FROM per_gen_hierarchy_nodes ghn
   WHERE ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
   START WITH ghn.entity_id = cp_top_entity_id
   CONNECT BY  ghn.parent_hierarchy_node_id   =  PRIOR ghn.hierarchy_node_id
   -- Note: this looks excessive but making sure both
   -- the prior record and the current record
   -- are both using the specified org struct version
   AND PRIOR ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
   AND ghn.hierarchy_version_id = cp_gen_hierarchy_version_id
 ;

---------------------
-- Local Variables
---------------------

TYPE t_gen_struct_ver_rec IS RECORD
  (business_group_id          per_gen_hierarchy.business_group_id%TYPE
  ,hierarchy_id               per_gen_hierarchy.hierarchy_id%TYPE
  ,hierarchy_version_id       per_gen_hierarchy_versions.hierarchy_version_id%TYPE
  ,date_from                  per_gen_hierarchy_versions.date_from%TYPE
  ,date_to                    per_gen_hierarchy_versions.date_to%TYPE
  );

l_gen_struct_ver_rec t_gen_struct_ver_rec;
l_top_entity           NUMBER;

-- Local vars to allow information to be passed
-- outside of the loops which restrict the scope of the records
-- Used only to give information at exceptions.
l_this_child_entity     NUMBER;
l_this_parent_entity    NUMBER;

l_sql_stmt      varchar2(2000);
l_dummy1        VARCHAR2(2000);
l_dummy2        VARCHAR2(2000);
l_schema        VARCHAR2(400);

BEGIN

  output('Truncate Table HRI_GEN_HRCHY_SUMMARY');

  --Clear the table
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
      l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_GEN_HRCHY_SUMMARY';
      EXECUTE IMMEDIATE(l_sql_stmt);
  END IF;


  -- 1. Loop through all Generic Hierarchy Versions
  FOR l_gen_struct_ver_rec in csr_gen_struct_vers
                                (p_business_group_id)
    LOOP

    output('Processing hierarchy');
    output('--------------------');
    output('Hierarchy Name',l_gen_struct_ver_rec.name);
    output('Hierarchy Type',l_gen_struct_ver_rec.type);
    output('Hierarchy Version',l_gen_struct_ver_rec.version_number);
    output('Start Date',l_gen_struct_ver_rec.date_from);
    output('End Date',l_gen_struct_ver_rec.date_to);


    BEGIN -- Handle Top Entity Query and Parent Entity tree walk exceptions
    -- Get Top Entity for Generic Structure version
    l_top_entity := Get_Top_Entity_id (l_gen_struct_ver_rec.hierarchy_version_id);

    -- 2. Loop through all parent entities starting with the top entity
    --    in the gen struct version
    FOR l_gen_parent_rec IN csr_gen_parents
                            (l_gen_struct_ver_rec.hierarchy_version_id
                            ,l_top_entity )
      LOOP

      BEGIN -- Handle Gen Children tree walk exceptions and Insert exceptions
            -- 3. Loop through and insert a row for each Parnet Child Entity
            --    combination
      l_this_parent_entity := l_gen_parent_rec.entity_id;

      FOR l_entity_child_rec IN csr_gen_children
                             (l_gen_struct_ver_rec.hierarchy_version_id
                             ,l_gen_parent_rec.entity_id)
        LOOP
        l_this_child_entity := l_gen_parent_rec.entity_id;

        -- bug 2885942, removed if statement to allow parent to be inserted
        -- below itself in the collection table.

        --Insert into table
        INSERT INTO
          HRI_GEN_HRCHY_SUMMARY
           (hierarchy_id
           ,hierarchy_version_id
           ,business_group_id
           ,hierarchy_node_id
           ,entity_id
           ,entity_level
           ,node_type
           ,sub_entity_bg_id
           ,sub_hierarchy_node_id
           ,sub_entity_id
           ,sub_entity_level
           ,sub_node_type
           /* -- This done by trigger HRI_GEN_HRCHY_SUMMARY_WHO
           ,created_by
           ,creation_date
           ,last_updated_by
           ,last_update_login
           ,last_update_date/**/
           )
          VALUES
           (l_gen_struct_ver_rec.hierarchy_id
           ,l_gen_struct_ver_rec.hierarchy_version_id
           ,l_gen_parent_rec.business_group_id
           ,l_gen_parent_rec.hierarchy_node_id
           ,l_gen_parent_rec.entity_id
           ,l_gen_parent_rec.entity_level
           ,l_gen_parent_rec.node_type
           ,l_entity_child_rec.business_group_id
           ,l_entity_child_rec.hierarchy_node_id
           ,l_entity_child_rec.entity_id
           ,l_gen_parent_rec.entity_level + l_entity_child_rec.entity_level
           ,l_entity_child_rec.node_type
           /* -- This done by trigger HRI_GEN_HRCHY_SUMMARY_WHO
           ,-1 --created_by
           ,sysdate
           ,-1 --last_updated_by
           ,-1 --last_update_login
           ,sysdate --last_update_date/**/
           );

      END LOOP; -- 3. Child entity

      EXCEPTION
        --Exception to handle loops in child cursor
        WHEN OTHERS THEN
          output( 'Child or Insert Exception ');
          output( sqlcode , sqlerrm );
          output( ' Generic Hierarchy Version ID: ',to_char(l_gen_struct_ver_rec.hierarchy_version_id));
          output( ' Parent Organization ID: ',l_gen_parent_rec.entity_id); -- 2261412 removed to_char()
          output( ' Parent Organization ID: ',to_char(l_this_child_entity));
          NULL;
      END;
    /**/
    END LOOP;  -- 2. Parent Entity

    EXCEPTION
      -- Handles either
      -- top entity issues
      -- or loops in parent entity elements data
      -- Either way need to be able to carry on from an excpetion
      -- and complete as many generic structures as possible
      WHEN e_g_no_top_node_found  THEN
        output( '****************************************************************');
        output( 'No Top Entity was found for hierarchy',l_gen_struct_ver_rec.name);
        output( 'Hierarchy version not collected',l_gen_struct_ver_rec.version_number);
        output( 'Check the hierarchy version has a top node and children. ');
        output( '****************************************************************');
      WHEN OTHERS THEN
        output( sqlcode , sqlerrm );
        output( 'Top or Parent Generic Exception for');
        output( 'Generic Hierarchy Version ID: ',to_char(l_gen_struct_ver_rec.hierarchy_version_id));
        output( 'Please check this structure for integrity');
    END;
    /**/


  output('--------------------');


  END LOOP; --1. Loop through all Generic Hierarchy Versions

EXCEPTION
-- Handles excetions at the Generic Struct Version cursor level
  WHEN OTHERS THEN
    output( 'Load_Gen_Hierarchies: Gen Struct Version Exception ');
    output( sqlcode , sqlerrm );

END Load_Gen_Hierarchies;
--------------------------------------------------------------------------------
--  Procedure Name: Load_All_Gen_Hierarchies
--
--  Exceptions:  None
--
--  Description: Overloaded version of Load_Gen_Hierarchies
--               Overloaded to be called directly for debugging
--
--------------------------------------------------------------------------------

PROCEDURE Load_All_Gen_Hierarchies
 IS
BEGIN

  g_debug_flag := FALSE;

  Load_Gen_Hierarchies
    (p_business_group_id       => NULL -- Do all business groups
    );

  COMMIT;

END Load_All_Gen_Hierarchies;

--------------------------------------------------------------------------------
--  Procedure Name: Load_All_Org_Hierarchies
--
--  Exceptions:  None
--
--  Description: Overloaded version of Load_Gen_Hierarchies
--               The purpose of this version is to be called from
--               the Concurrent Manager.
--
--------------------------------------------------------------------------------

PROCEDURE Load_All_Gen_Hierarchies
    ( errbuf                       OUT NOCOPY  Varchar2
    , retcode                      OUT NOCOPY  Number )
 IS
BEGIN
  errbuf  := null;
  retcode := null;

  g_debug_flag := TRUE;

  Load_Gen_Hierarchies
    (p_business_group_id       => NULL -- Do all business groups
    );

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    errbuf := sqlerrm;
    retcode := sqlcode;

END Load_All_Gen_Hierarchies;


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--  SUPERVISOR HIERARCHY FUNCTIONS
--
--  TABLE: HRI_SUPV_HRCHY_SUMMARY
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  Procedure Name: Load_Sup_Hierarchies
--
--  Exceptions:  <>               - <Description>
--
--  Description: Populates HRI_SUPV_STRUCT_SUMMARY table with flattened
--               supervisor (as of current) structure to speed up rollups and
--               Include subordinate queries.
--               Currently only primary asg hierarchy is supported so 3rd param
--               is not used but is retained to allow future scope and to stop
--               need for re-shipping and re-compiling of header and dependents
--
--------------------------------------------------------------------------------

/* Bugfix - version 115.3 JTitmas - added conditions assignment_type = 'E' */
/* throughout the following cursors to filter out benefits assignments */

PROCEDURE Load_Sup_Hierarchies
  ( p_business_group_id  IN NUMBER   DEFAULT NULL
  , p_include_supervisor IN BOOLEAN  DEFAULT FALSE
  , p_primary_ass_only   IN VARCHAR2 DEFAULT 'Y'      --Currently primary Hierarchy only
  , p_date               IN DATE     DEFAULT  SYSDATE)
 IS

  --
  -- Type and Variable holding the EDW latest change date of an assignment and all */
  -- the assignments above it for each person in the supervisor hiearchy */
  --
  TYPE l_sup_updates_tabtype IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  l_sup_updates_tab   l_sup_updates_tabtype;
  --
  -- Bug 3658473: Variables for getting application information
  --
  l_sql_stmt      varchar2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);
--
-- select all the people who are supervisors
-- are not supervised themselves (all the tops of individual supervisor hierarchies)
--
CURSOR cur_people
  (cp_business_group_id NUMBER
  ,cp_date              DATE
  ,cp_primary_ass_only  VARCHAR2)
 IS
  SELECT asg.person_id
       , asg.business_group_id
       , 0 supervisor_hier_level
       , NVL(asg.last_update_date, g_default_last_update)
                                     last_ptntl_change_date
    FROM per_all_assignments_f asg
   WHERE  DECODE(cp_primary_ass_only, 'Y', asg.primary_flag, 1)
       =  DECODE(cp_primary_ass_only, 'Y', 'Y', 1) -- primary assignments only
     AND asg.supervisor_id IS NULL -- not supervised themselves.
     AND asg.assignment_type = 'E'
     AND cp_date BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND asg.person_id IN
          (SELECT DISTINCT asg.supervisor_id
             FROM per_all_assignments_f asg
            WHERE DECODE(cp_primary_ass_only, 'Y', asg.primary_flag, 1)
               =  DECODE(cp_primary_ass_only, 'Y', 'Y', 1) -- primary assignments only
              AND asg.supervisor_id IS NOT NULL
              AND asg.assignment_type = 'E'
              AND cp_date BETWEEN
                     asg.effective_start_date AND asg.effective_end_date
           ) --
     AND asg.business_group_id
          = NVL(cp_business_group_id, asg.business_group_id);

-- Select the assignments that are below the p_supervisor_id
-- in the current supervisor tree starting at p_supervisor_id
--
-- For the purposes of determining the last update date of a position
-- this cursor must return rows on a strictly top down basis. This is
-- currently forced by starting at the top and having no order by
CURSOR cur_supervisors
   (cp_supervisor_id     NUMBER
   ,cp_date              DATE
   ,cp_primary_ass_only  VARCHAR2)
 IS
  SELECT hier.business_group_id
       , hier.person_id
       , hier.assignment_id
       , hier.primary_flag
       , LEVEL-1 supervisor_level
       , hier.assignment_id supv_asg_id
       , NVL(hier.last_update_date, g_default_last_update)
                                      last_ptntl_change_date
    FROM per_all_assignments_f  hier
   WHERE cp_date  BETWEEN
           hier.effective_start_date AND  hier.effective_end_date
     AND hier.assignment_type = 'E'
     AND  DECODE(cp_primary_ass_only, 'Y', hier.primary_flag, 1)
       =  DECODE(cp_primary_ass_only,'Y', 'Y', 1) -- primary assignments only
   START WITH hier.person_id     =  cp_supervisor_id
   CONNECT BY hier.supervisor_id = PRIOR hier.person_id
          AND hier.assignment_type = 'E'
          AND cp_date BETWEEN
                PRIOR hier.effective_start_date
                AND PRIOR hier.effective_end_date
          AND  DECODE(cp_primary_ass_only, 'Y', hier.primary_flag, 1)
            =  DECODE(cp_primary_ass_only,'Y', 'Y', 1); -- primary assignments only

-- select the assignments that are below the p_supervisor_id
-- in the current supervisor tree starting at p_supervisor_id
CURSOR cur_reports
   (cp_supervisor_id     NUMBER
   ,cp_date              DATE
   ,cp_primary_ass_only  VARCHAR2)
 IS
  SELECT hier.business_group_id
       , hier.person_id
       , hier.assignment_id
       , hier.primary_flag
       , LEVEL-1 subordinate_level
       , NVL(hier.last_update_date, g_default_last_update)
                              last_ptntl_change_date
    FROM per_all_assignments_f  hier
   WHERE cp_date BETWEEN
           hier.effective_start_date AND  hier.effective_end_date
     AND hier.assignment_type = 'E'
     AND  DECODE(cp_primary_ass_only, 'Y', hier.primary_flag, 1)
       =  DECODE(cp_primary_ass_only,'Y', 'Y', 1) -- primary assignments only
   START WITH hier.person_id    =  cp_supervisor_id
   CONNECT BY hier.supervisor_id = PRIOR hier.person_id
       AND hier.assignment_type = 'E'
       AND cp_date BETWEEN
           PRIOR hier.effective_start_date AND PRIOR hier.effective_end_date
       AND  DECODE(cp_primary_ass_only, 'Y', hier.primary_flag, 1)
         =  DECODE(cp_primary_ass_only,'Y', 'Y', 1); -- primary assignments only
BEGIN
  --
  -- empty the hri_supv_struct_summary table from any prvious run.
  --
  -- Bug 3658473: Changed delete to truncate
  --
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    --
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_SUPV_HRCHY_SUMMARY';
    EXECUTE IMMEDIATE(l_sql_stmt);
    --
  END IF;

  -- for supervisor hierarchy
  FOR cur_people_rec IN cur_people(p_business_group_id, p_date, p_primary_ass_only)
    LOOP

    -- Initialise the table of last update dates
    l_sup_updates_tab(cur_people_rec.person_id) := cur_people_rec.last_ptntl_change_date;

    -- Traps recursive loops in supervisor hierarchy
    BEGIN

    -- for each supervisor in the hierarchy
    FOR cur_supervisors_rec IN cur_supervisors(cur_people_rec.person_id, p_date, p_primary_ass_only )
      LOOP

      -- for each assignment below cur_supervisors_rec.person_id in the current hierarchy
      FOR cur_reports_rec IN cur_reports(cur_supervisors_rec.person_id, p_date, p_primary_ass_only)
        LOOP

        -- Update table of last update dates
        IF (l_sup_updates_tab(cur_supervisors_rec.person_id) >
                            cur_reports_rec.last_ptntl_change_date) THEN
          l_sup_updates_tab(cur_reports_rec.person_id) :=
                    l_sup_updates_tab(cur_supervisors_rec.person_id);
        ELSE
          l_sup_updates_tab(cur_reports_rec.person_id) :=
                    cur_reports_rec.last_ptntl_change_date;
        END IF;

        -- include the supervisor in their own rollup?
        IF (p_include_supervisor = TRUE)
          OR ((p_include_supervisor = FALSE)
          AND (cur_reports_rec.person_id <> cur_supervisors_rec.person_id))
          THEN

          -- insert into hri_supv_struct_summary table
          BEGIN
            INSERT INTO hri_supv_hrchy_summary(
                  supv_business_group_id
                , supv_person_id
                , supv_assignment_id
                , supv_level
                , supv_last_ptntl_change
                , sub_business_group_id
                , sub_person_id
                , sub_assignment_id
                , sub_primary_asg_flag
                , sub_level
                , sub_last_ptntl_change
              /* -- This done by trigger HRI_SUPV_HRCHY_SUMMARY_WHO
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login
              /**/
            )
            VALUES(
                  cur_supervisors_rec.business_group_id
                , cur_supervisors_rec.person_id
                , cur_supervisors_rec.supv_asg_id
                , cur_supervisors_rec.supervisor_level
                , l_sup_updates_tab(cur_supervisors_rec.person_id)
                , cur_reports_rec.business_group_id
                , cur_reports_rec.person_id
                , cur_reports_rec.assignment_id
                , cur_reports_rec.primary_flag
                , cur_reports_rec.subordinate_level + cur_supervisors_rec.supervisor_level
                , l_sup_updates_tab(cur_reports_rec.person_id)
              /* -- This done by trigger HRI_SUPV_HRCHY_SUMMARY_WHO
                , SYSDATE
                , -1
                , SYSDATE
                , -1
                , -1
              /**/
            );

          EXCEPTION
              WHEN OTHERS THEN
                output(sqlcode, sqlerrm);
          END;

        END IF;

      END LOOP; -- for each assignment below cur_supervisors_rec.person_id in the current hierarchy

    END LOOP; --  for each assignment below cur_supervisors_rec.person_id in the current hierarchy

    EXCEPTION
      WHEN OTHERS THEN
        output(sqlcode, sqlerrm);
    END;

  END LOOP; -- for each supervisor hierarchy

EXCEPTION
  WHEN OTHERS THEN
    output(sqlcode, sqlerrm);

END Load_Sup_Hierarchies;

--------------------------------------------------------------------------------
--  Procedure Name: Load_All_Supv_Hierarchies
--
--  Exceptions:  None
--
--  Description: Calls Load_Supv_Hierarchies directly
--               Overloaded to be called directly for debugging
--
--------------------------------------------------------------------------------
PROCEDURE Load_All_Sup_Hierarchies
  IS
  BEGIN

  g_debug_flag := FALSE;

    -- will load the supervisor hierarchies for all business groups
    -- excluding the supervisor from their own supervisor hierarchy
    -- for primary assignments only
    Load_Sup_Hierarchies(p_business_group_id  => NULL
                        ,p_include_supervisor => FALSE
                        ,p_primary_ass_only   => 'Y'
                        ,p_date               => SYSDATE);


    COMMIT;

END Load_All_Sup_Hierarchies;
--------------------------------------------------------------------------------
--  Procedure Name: Load_All_Supv_Hierarchies
--
--  Exceptions:  None
--
--  Description: Calls Load_Supv_Hierarchies directly
--               The purpose of this version is to be called from
--               the Concurrent Manager.
--
--------------------------------------------------------------------------------
PROCEDURE Load_All_Sup_Hierarchies
    ( errbuf                       OUT NOCOPY  Varchar2
    , retcode                      OUT  NOCOPY Number )
  IS
  BEGIN
  errbuf := null;
  retcode := null;

  g_debug_flag := TRUE;

    -- will load the supervisor hierarchies for all business groups
    -- excluding the supervisor from their own supervisor hierarchy
    -- for primary assignments only
    Load_Sup_Hierarchies( p_business_group_id  => NULL
                        , p_include_supervisor => FALSE
                        , p_primary_ass_only   => 'Y'
                        , p_date               => SYSDATE);


    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      errbuf := sqlerrm;
      retcode := sqlcode;

END Load_All_Sup_Hierarchies;

END HRI_STRUCT_SUMMARY; -- Package Body HRI_STRUCT_SUMMARY

/
