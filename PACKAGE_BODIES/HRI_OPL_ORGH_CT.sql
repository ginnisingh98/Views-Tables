--------------------------------------------------------
--  DDL for Package Body HRI_OPL_ORGH_CT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_ORGH_CT" AS
/* $Header: hriporghct.pkb 120.4.12000000.2 2007/04/12 13:27:15 smohapat noship $ */

/******************************************************************************/
/*                                                                            */
/* OUTLINE / DEFINITIONS                                                      */
/*                                                                            */
/* A chain is defined for a organization as a list starting with the          */
/* organization which contains and successive higher level organizations      */
/* finishing with the highest level (top) organization.                       */
/*                                                                            */
/* IMPLEMENTATION LOGIC                                                       */
/*                                                                            */
/* The organization hierarchy table is populated by carrying out the          */
/* following steps:                                                           */
/*                                                                            */
/*  1) Empty out existing table                                               */
/*                                                                            */
/*  2) Find the organization structure to collect. It will be the current     */
/*     version for:                                                           */
/*      - Structure in HR:BIS Reporting Hierarchy profile, if this structure  */
/*        is global                                                           */
/*      - If the profile is empty or not a global structure then default to   */
/*        the primary global structure                                        */
/*                                                                            */
/*  3) Collect chains for organization structure                              */
/*      - Process hierarchy in default (tree walk) order                      */
/*      - Maintain cache of chain for each node in tree walk                  */
/*      - For each node loop through links in chain:                          */
/*         - Calculate relative levels to supervisor organization             */
/*         - Insert link record (store in PL/SQL globals for bulk insert)     */
/*      - If bulk insert limit reached on rows to insert, then do bulk insert */
/*                                                                            */
/*  4) Bulk Insert any remaining rows at end of process                       */
/******************************************************************************/

/* Information to be held for each link in a chain */
TYPE g_link_record_type IS RECORD
  (business_group_id    per_org_structure_elements.business_group_id%TYPE
  ,organization_id      per_org_structure_elements.organization_id_parent%TYPE
  ,last_chng_date       DATE);

/* Table type to hold information about the current chain */
TYPE g_chain_type IS TABLE OF g_link_record_type INDEX BY BINARY_INTEGER;

/* Simple table types */
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/* PLSQL table of tables representing category structure table */
g_cs_ost_id             g_number_tab_type;
g_cs_bgr_id             g_number_tab_type;
g_cs_osv_id             g_number_tab_type;
g_cs_sup_org_id         g_number_tab_type;
g_cs_sup_level          g_number_tab_type;
g_cs_sub_org_id         g_number_tab_type;
g_cs_sub_org_prnt_id    g_number_tab_type;
g_cs_sub_level          g_number_tab_type;
g_cs_sub_rlt_lvl        g_number_tab_type;
g_cs_last_chng          g_date_tab_type;
g_cs_sup_sub1_id        g_number_tab_type;
g_cs_sup_sub2_id        g_number_tab_type;
g_cs_sup_sub3_id        g_number_tab_type;
g_cs_sup_sub4_id        g_number_tab_type;
g_cs_sup_sub5_id        g_number_tab_type;
--
g_new_orgs_with_worker  g_number_tab_type;
--
g_cs_rows_to_insert    PLS_INTEGER;  -- Number of CS rows to insert

/* Set to true to output to a concurrent log file */
g_conc_request_flag       BOOLEAN := FALSE;

/* Number of rows bulk processed at a time */
g_chunk_size              PLS_INTEGER;

/* Start / End of time dates */
g_start_of_time           DATE := hr_general.start_of_time;
g_end_of_time             DATE := hr_general.end_of_time;
g_user_id                 NUMBER;
g_sysdate                 DATE;

/******************************************************************************/
/* Inserts row into concurrent program log when the g_conc_request_flag has   */
/* been set to TRUE, otherwise does nothing                                   */
/******************************************************************************/
PROCEDURE output(p_text  VARCHAR2)
  IS

BEGIN

/* Write to the concurrent request log if called from a concurrent request */
  IF (g_conc_request_flag = TRUE) THEN

   /* Put text to log file */
    fnd_file.put_line(FND_FILE.log, p_text);
  END IF;

END output;


/******************************************************************************/
/* Runs given sql statement dynamically                                       */
/******************************************************************************/
PROCEDURE run_sql_stmt_noerr(p_sql_stmt   VARCHAR2) IS

BEGIN

  EXECUTE IMMEDIATE p_sql_stmt;

EXCEPTION WHEN OTHERS THEN

  output('Error running sql:');
  output(SUBSTR(p_sql_stmt,1,230));

END run_sql_stmt_noerr;


/******************************************************************************/
/* Recovers CS rows to insert when an exception occurs                        */
/******************************************************************************/
PROCEDURE recover_insert_cs_rows IS

BEGIN
  -- loop through rows still to insert one at a time
  FOR i IN 1..g_cs_rows_to_insert LOOP

    -- Trap unique constraint errors
    BEGIN

      INSERT INTO hri_cs_orgh_ct
       (orgh_orghrchy_fk
       ,orgh_global_flag
       ,orgh_orghvrsn_fk
       ,orgh_sup_organztn_fk
       ,orgh_sup_level
       ,orgh_sup_sub1_organztn_fk
       ,orgh_sup_sub2_organztn_fk
       ,orgh_sup_sub3_organztn_fk
       ,orgh_sup_sub4_organztn_fk
       ,orgh_organztn_fk
       ,orgh_level
       ,orgh_relative_level
       ,orgh_adt_org_struct_id
       ,orgh_adt_org_struct_version_id
       ,orgh_sub_node_has_workers_flag
       ,orgh_sub_org_has_workers_flag)
          VALUES
            (g_cs_ost_id(i)
            ,'Y'
            ,g_cs_osv_id(i)
            ,g_cs_sup_org_id(i)
            ,g_cs_sup_level(i)
            ,g_cs_sup_sub1_id(i)
            ,g_cs_sup_sub2_id(i)
            ,g_cs_sup_sub3_id(i)
            ,g_cs_sup_sub4_id(i)
            ,g_cs_sub_org_id(i)
            ,g_cs_sub_level(i)
            ,g_cs_sub_rlt_lvl(i)
            ,g_cs_ost_id(i)
            ,g_cs_osv_id(i)
            ,'N'
            ,'N');

    EXCEPTION
      WHEN OTHERS THEN

      /* Probable overlap on date tracked assignment rows */
      output('Single insert error: ' || to_char(g_cs_sub_org_id(i)) ||
             ' - ' || to_char(g_cs_sup_org_id(i)));
      output('Inserting chain for: ' ||
              to_char(g_cs_sub_org_id(i)) || ' in hierarchy version' ||
              to_char(g_cs_osv_id(i)));
      output(sqlerrm);
      output(sqlcode);

    END;

  END LOOP;

  -- commit
  commit;

END recover_insert_cs_rows;


/******************************************************************************/
/* Bulk inserts rows from global temporary table to CS database table         */
/******************************************************************************/
PROCEDURE bulk_insert_cs_rows IS

BEGIN
  -- insert chunk of rows
  FORALL i IN 1..g_cs_rows_to_insert
    INSERT INTO hri_cs_orgh_ct
       (orgh_orghrchy_fk
       ,orgh_global_flag
       ,orgh_orghvrsn_fk
       ,orgh_sup_organztn_fk
       ,orgh_sup_level
       ,orgh_sup_sub1_organztn_fk
       ,orgh_sup_sub2_organztn_fk
       ,orgh_sup_sub3_organztn_fk
       ,orgh_sup_sub4_organztn_fk
       ,orgh_organztn_fk
       ,orgh_level
       ,orgh_relative_level
       ,orgh_adt_org_struct_id
       ,orgh_adt_org_struct_version_id
       ,orgh_sub_node_has_workers_flag
       ,orgh_sub_org_has_workers_flag
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,created_by
       ,creation_date)
          VALUES
            (g_cs_ost_id(i)
            ,'Y'
            ,g_cs_osv_id(i)
            ,g_cs_sup_org_id(i)
            ,g_cs_sup_level(i)
            ,g_cs_sup_sub1_id(i)
            ,g_cs_sup_sub2_id(i)
            ,g_cs_sup_sub3_id(i)
            ,g_cs_sup_sub4_id(i)
            ,g_cs_sub_org_id(i)
            ,g_cs_sub_level(i)
            ,g_cs_sub_rlt_lvl(i)
            ,g_cs_ost_id(i)
            ,g_cs_osv_id(i)
            ,'N'
            ,'N'
            ,g_sysdate
            ,g_user_id
            ,g_user_id
            ,g_user_id
            ,g_sysdate);

  -- commit the chunk of rows
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN

/* Unique constraint error */
  rollback;
  output('Warning - recovering (CS)');
  recover_insert_cs_rows;

END bulk_insert_cs_rows;

/******************************************************************************/
/* Inserts row into global CS temporary table                                 */
/******************************************************************************/
PROCEDURE insert_cs_row( p_sup_organization_id     IN NUMBER
                       , p_sup_level               IN NUMBER
                       , p_sup_sub1_id             IN NUMBER
                       , p_sup_sub2_id             IN NUMBER
                       , p_sup_sub3_id             IN NUMBER
                       , p_sup_sub4_id             IN NUMBER
                       , p_sub_organization_id     IN NUMBER
                       , p_sub_level               IN NUMBER
                       , p_ost_id                  IN NUMBER
                       , p_osv_id                  IN NUMBER
                       , p_bgr_id                  IN NUMBER
                       , p_sub_org_parent_id       IN NUMBER
                       , p_last_ptntl_change       IN DATE ) IS

BEGIN
  -- increment the index
  g_cs_rows_to_insert := g_cs_rows_to_insert + 1;
  -- set the table structures
  g_cs_sup_org_id(g_cs_rows_to_insert)      := p_sup_organization_id;
  g_cs_sup_level(g_cs_rows_to_insert)       := p_sup_level;
  g_cs_sup_sub1_id(g_cs_rows_to_insert)     := p_sup_sub1_id;
  g_cs_sup_sub2_id(g_cs_rows_to_insert)     := p_sup_sub2_id;
  g_cs_sup_sub3_id(g_cs_rows_to_insert)     := p_sup_sub3_id;
  g_cs_sup_sub4_id(g_cs_rows_to_insert)     := p_sup_sub4_id;
  g_cs_sub_org_id(g_cs_rows_to_insert)      := p_sub_organization_id;
  g_cs_sub_level(g_cs_rows_to_insert)       := p_sub_level;
  g_cs_sub_rlt_lvl(g_cs_rows_to_insert)     := p_sub_level - p_sup_level;
  g_cs_sub_org_prnt_id(g_cs_rows_to_insert) := p_sub_org_parent_id;
  g_cs_ost_id(g_cs_rows_to_insert)          := p_ost_id;
  g_cs_bgr_id(g_cs_rows_to_insert)          := p_bgr_id;
  g_cs_osv_id(g_cs_rows_to_insert)          := p_osv_id;
  g_cs_last_chng(g_cs_rows_to_insert)       := p_last_ptntl_change;

END insert_cs_row;


/******************************************************************************/
/* Updates all organizations in the organization hierarchy version starting   */
/* with the top organization.                                                 */
/******************************************************************************/
PROCEDURE calculate_chains(p_top_org_id              IN NUMBER
                          ,p_ost_id                  IN NUMBER
                          ,p_bgr_id                  IN NUMBER
                          ,p_osv_id                  IN NUMBER
                          ,p_start_date              IN DATE) IS

/* Cursor picks out all organizations in the organization structure */
/* This cursor MUST return rows in the default order */
  CURSOR organizations_csr IS
  SELECT
   hier.organization_id_child   organization_id
  ,hier.last_update_date        last_update_date
  ,LEVEL+1                      actual_level
  FROM (SELECT
         ose.organization_id_child
        ,ose.organization_id_parent
        ,NVL(ose.last_update_date, g_start_of_time)  last_update_date
        FROM
         per_org_structure_elements   ose
        WHERE ose.org_structure_version_id = p_osv_id)  hier
  START WITH hier.organization_id_parent = p_top_org_id
  CONNECT BY PRIOR hier.organization_id_child = organization_id_parent;
/******************************/
/* DO NOT ADD ORDER BY CLAUSE */
/******************************/

  -- Cache of links in current chain
  l_crrnt_chain      g_chain_type;

  -- Current and previous levels - for maintaining cache
  l_org_lvl          PLS_INTEGER;
  l_last_org_lvl     PLS_INTEGER;

  -- Organizations relative to supervisor organization for each link
  l_sup_sub1_id      NUMBER;
  l_sup_sub2_id      NUMBER;
  l_sup_sub3_id      NUMBER;
  l_sup_sub4_id      NUMBER;

BEGIN

/* Store details for top organization */
  l_crrnt_chain(1).organization_id   := p_top_org_id;
  l_crrnt_chain(1).last_chng_date    := p_start_date;

/* Insert chain */
  insert_cs_row
    (p_sup_organization_id   => l_crrnt_chain(1).organization_id
    ,p_sup_level             => 1
    ,p_sup_sub1_id           => l_crrnt_chain(1).organization_id
    ,p_sup_sub2_id           => l_crrnt_chain(1).organization_id
    ,p_sup_sub3_id           => l_crrnt_chain(1).organization_id
    ,p_sup_sub4_id           => l_crrnt_chain(1).organization_id
    ,p_sub_organization_id   => l_crrnt_chain(1).organization_id
    ,p_sub_level             => 1
    ,p_sub_org_parent_id     => -1
    ,p_ost_id                => p_ost_id
    ,p_bgr_id                => p_bgr_id
    ,p_osv_id                => p_osv_id
    ,p_last_ptntl_change     => l_crrnt_chain(1).last_chng_date);

/* Loop through organizations in organization hierarchy version */
  FOR org_rec IN organizations_csr LOOP

    l_org_lvl := org_rec.actual_level;

    IF (l_last_org_lvl > l_org_lvl) THEN
    /* Reset end of chain */
      FOR i IN l_org_lvl+1..l_last_org_lvl LOOP
        l_crrnt_chain(i).organization_id := to_number(null);
      END LOOP;
    END IF;

    l_crrnt_chain(l_org_lvl).organization_id   := org_rec.organization_id;
    l_crrnt_chain(l_org_lvl).last_chng_date    :=
           GREATEST(org_rec.last_update_date,
                    l_crrnt_chain(l_org_lvl - 1).last_chng_date);

    /* Loop through links in (stored) chain of organizations */
      FOR l_sup_lvl IN 1..l_org_lvl LOOP

      /* Set relative levels */
        IF (l_org_lvl > l_sup_lvl) THEN
          l_sup_sub1_id := l_crrnt_chain(l_sup_lvl + 1).organization_id;
        ELSE
          l_sup_sub1_id := l_crrnt_chain(l_org_lvl).organization_id;
        END IF;
        IF (l_org_lvl > l_sup_lvl + 1) THEN
          l_sup_sub2_id := l_crrnt_chain(l_sup_lvl + 2).organization_id;
        ELSE
          l_sup_sub2_id := l_crrnt_chain(l_org_lvl).organization_id;
        END IF;
        IF (l_org_lvl > l_sup_lvl + 2) THEN
          l_sup_sub3_id := l_crrnt_chain(l_sup_lvl + 3).organization_id;
        ELSE
          l_sup_sub3_id := l_crrnt_chain(l_org_lvl).organization_id;
        END IF;
        IF (l_org_lvl > l_sup_lvl + 3) THEN
          l_sup_sub4_id := l_crrnt_chain(l_sup_lvl + 4).organization_id;
        ELSE
          l_sup_sub4_id := l_crrnt_chain(l_org_lvl).organization_id;
        END IF;

      /* Insert chain into CS */
        insert_cs_row
          (p_sup_organization_id   => l_crrnt_chain(l_sup_lvl).organization_id
          ,p_sup_level             => l_sup_lvl
          ,p_sup_sub1_id           => l_sup_sub1_id
          ,p_sup_sub2_id           => l_sup_sub2_id
          ,p_sup_sub3_id           => l_sup_sub3_id
          ,p_sup_sub4_id           => l_sup_sub4_id
          ,p_sub_organization_id   => l_crrnt_chain(l_org_lvl).organization_id
          ,p_sub_level             => l_org_lvl
          ,p_sub_org_parent_id     => l_crrnt_chain(l_org_lvl - 1).organization_id
          ,p_ost_id                => p_ost_id
          ,p_bgr_id                => p_bgr_id
          ,p_osv_id                => p_osv_id
          ,p_last_ptntl_change     => l_crrnt_chain(l_org_lvl).last_chng_date);

      END LOOP; -- Links in stored chain

  /* If the stored rows have reached a maximum, then insert them */
    IF (g_cs_rows_to_insert > g_chunk_size) THEN
      -- bulk insert rows processed so far
      bulk_insert_cs_rows;
      -- reset the index
      g_cs_rows_to_insert := 0;
    END IF;

    l_last_org_lvl := l_org_lvl;

  END LOOP;  -- organizations in hierarchy version

EXCEPTION
  WHEN OTHERS THEN

/* ORA 01436 - loop in tree walk */
  IF (SQLCODE = -1436) THEN
    output('Loop found for organization id:  ' ||
            to_char(p_top_org_id));
  ELSE
/* Some other error */
    RAISE;
  END IF;

END calculate_chains;

/******************************************************************************/
/* Loops through organization structure versions                              */
/******************************************************************************/
PROCEDURE collect_org_structures IS

-- Pick out hierarchy version to use. Cursor returns up to two rows:
--     - Primary Global Structure (current version)
--     - Structure selected in profile (HR BIS Reporting Hierarchy) providing
--       this is a global hierarchy
  CURSOR hrchy_csr(v_structure_id  NUMBER) IS
  SELECT
   osv.org_structure_version_id
  FROM
   per_org_structure_versions     osv
  ,per_organization_structures    ost
  WHERE ost.organization_structure_id = osv.organization_structure_id
-- Primary Global
  AND ((ost.primary_structure_flag = 'Y' AND osv.business_group_id IS NULL)
-- or, Profile
    OR ost.organization_structure_id = v_structure_id)
  AND trunc(sysdate) BETWEEN osv.date_from
                     AND NVL(osv.date_to, SYSDATE)
-- If returned, order structure from profile option first to override
-- default selection of primary global
  ORDER BY DECODE(ost.organization_structure_id, v_structure_id, 1, 2);

/* Pick out top organization from the selected version */
  CURSOR hrchy_version_csr(v_version_id  NUMBER) IS
  SELECT DISTINCT
   ose.organization_id_parent      top_org_id
  ,osv.org_structure_version_id    osv_id
  ,osv.organization_structure_id   ost_id
  ,osv.version_number              osv_no
  ,ost.primary_structure_flag      primary_flag
  ,osv.date_from                   start_date
  ,NVL(osv.date_to,g_end_of_time)  end_date
  ,osv.business_group_id           bgr_id
  FROM
   per_org_structure_elements     ose
  ,per_org_structure_versions     osv
  ,per_organization_structures    ost
  WHERE osv.org_structure_version_id = ose.org_structure_version_id
  AND ost.organization_structure_id = osv.organization_structure_id
  AND osv.org_structure_version_id = v_version_id
  AND NOT EXISTS
    (SELECT NULL
     FROM per_org_structure_elements ose2
     WHERE ose2.org_structure_version_id = ose.org_structure_version_id
     AND ose2.organization_id_child = ose.organization_id_parent);

  l_profile_structure    NUMBER;
  l_structure_version    NUMBER;

BEGIN

  -- Get value of profile HR: BIS Reporting Hierarchy
  l_profile_structure := fnd_profile.value('HR_BIS_REPORTING_HIERARCHY');

output('Structure:  '  || to_char(l_profile_structure));

  -- Get structure version to collect
  OPEN hrchy_csr(l_profile_structure);
  FETCH hrchy_csr INTO l_structure_version;
  CLOSE hrchy_csr;

output('Version:  '  || to_char(l_structure_version));

  -- Start collection
  IF (l_structure_version IS NOT NULL) THEN

    -- initialise the g_cs_rows_to_insert
    g_cs_rows_to_insert := 0;

    -- Populate table
    FOR hrchy_rec IN hrchy_version_csr(l_structure_version) LOOP

      calculate_chains
       (p_top_org_id => hrchy_rec.top_org_id
       ,p_ost_id     => hrchy_rec.ost_id
       ,p_bgr_id     => hrchy_rec.bgr_id
       ,p_osv_id     => hrchy_rec.osv_id
       ,p_start_date => hrchy_rec.start_date);

    END LOOP;

    -- Insert any remaining stored rows
    IF (g_cs_rows_to_insert > 0) THEN
        bulk_insert_cs_rows;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    IF hrchy_version_csr%ISOPEN THEN
      CLOSE hrchy_version_csr;
    END IF;
    -- re-raise error
    RAISE;
END collect_org_structures;


/******************************************************************************/
/* Updates flag orgh_sub_org_has_workers_flag,orgh_node_has_workers_flag      */
/******************************************************************************/

PROCEDURE upd_org_has_worker_flags_full IS
--
BEGIN
  --
  -- Time at flag update start
  --
  output('Flag update Start:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  -- Enable parallel DML
  --
    run_sql_stmt_noerr('ALTER SESSION ENABLE PARALLEL DML');
  --
  output('Enabled parallel DML:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  -- Update flag orgh_sub_org_has_workers_flag. This flag is set to 'Y' when
  -- the subordinate organization has workers. Else, it is 'N'.
  --
  UPDATE /*+ PARALLEL */ hri_cs_orgh_ct orgh
  SET orgh.orgh_sub_org_has_workers_flag = 'Y'
  WHERE orgh.rowid IN (SELECT sub_org.rowid
                      FROM hri_cs_orgh_ct sub_org,
                           hri_cs_organztn_ct org_wrkrs
                      WHERE sub_org.orgh_organztn_fk = org_wrkrs.org_organztn_pk
                      AND   org_wrkrs.org_has_workers_flag = 'Y'
                      );
  --
  COMMIT;
  --
/* Write timing information to log */
    output('orgh_sub_org_has_workers_flag updated:   '  ||
           to_char(sysdate,'HH24:MI:SS'));
  --
  -- Update flag orgh_node_has_workers_flag. This flag is set to 'Y' when
  -- the supervisor organization has workers for any of its subordinate
  -- organizations. Else, it is 'N'.
  --
  UPDATE /*+ PARALLEL(orgh) */ hri_cs_orgh_ct orgh
  SET orgh.orgh_sub_node_has_workers_flag = 'Y'
  WHERE orgh.rowid IN (
  SELECT sup_org.rowid
  FROM  hri_cs_orgh_ct sup_org
  WHERE EXISTS (SELECT null
                FROM   hri_cs_orgh_ct sub_org
                WHERE  sup_org.orgh_organztn_fk = sub_org.orgh_sup_organztn_fk
                AND    sub_org.orgh_sub_org_has_workers_flag = 'Y'));
  --
  COMMIT;
  --
/* Write timing information to log */
    output('orgh_node_has_workers_flag updated:   '  ||
           to_char(sysdate,'HH24:MI:SS'));
  --
EXCEPTION
  --
  WHEN OTHERS THEN
  RAISE;
  --
END upd_org_has_worker_flags_full;
--
/******************************************************************************/
/* Updates flag orgh_sub_org_has_workers_flag,orgh_node_has_workers_flag      */
/******************************************************************************/
--
PROCEDURE upd_org_has_worker_flags_incr
IS
BEGIN
  --
  output('Incremental flag update start:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
  IF g_new_orgs_with_worker.COUNT > 0 THEN
    --
    -- Update flag orgh_sub_org_has_workers_flag. This flag is set to 'Y' when
    -- the subordinate organization has workers. Else, it is 'N'.
    --
    FORALL i IN g_new_orgs_with_worker.FIRST..g_new_orgs_with_worker.LAST
    UPDATE hri_cs_orgh_ct orgh
    SET orgh.orgh_sub_org_has_workers_flag = 'Y'
    WHERE orgh.rowid IN (SELECT sub_org.rowid
                        FROM hri_cs_orgh_ct sub_org
                        WHERE sub_org.orgh_organztn_fk = g_new_orgs_with_worker(i)
                        );
    --
    COMMIT;
    --
    -- Write timing information to log
      output('orgh_sub_org_has_workers_flag updated incrementally:   '  ||
             to_char(sysdate,'HH24:MI:SS'));
    --
    -- Update flag orgh_node_has_workers_flag. This flag is set to 'Y' when
    -- the supervisor organization has workers for any of its subordinate
    -- organizations. Else, it is 'N'.
    --
    FORALL i IN g_new_orgs_with_worker.FIRST..g_new_orgs_with_worker.LAST
    UPDATE hri_cs_orgh_ct orgh
    SET orgh.orgh_sub_node_has_workers_flag = 'Y'
    WHERE orgh.rowid IN (
    SELECT sup_org.rowid
    FROM  hri_cs_orgh_ct sup_org
    WHERE EXISTS (SELECT null
                  FROM   hri_cs_orgh_ct sub_org
                  WHERE  sup_org.orgh_organztn_fk = sub_org.orgh_sup_organztn_fk
                  AND    sub_org.orgh_organztn_fk = g_new_orgs_with_worker(i)
                  AND    sub_org.orgh_sub_org_has_workers_flag = 'Y')
    AND   sup_org.orgh_sub_node_has_workers_flag = 'N');
    --
    COMMIT;
    --
    -- Write timing information to log */
      output('orgh_node_has_workers_flag updated incrementally:   '  ||
             to_char(sysdate,'HH24:MI:SS'));
  END IF;
  --
    output('Exiting worker flag update process:   '  ||
           to_char(sysdate,'HH24:MI:SS'));
  --
EXCEPTION
  --
  WHEN OTHERS THEN
  RAISE;
  --

END upd_org_has_worker_flags_incr;
--
/******************************************************************************/
/* Main entry point to reload the organization hierarchy table                */
/******************************************************************************/
PROCEDURE load( p_chunk_size    IN NUMBER ) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

/* Set chunk size */
  IF (p_chunk_size IS NULL) THEN
    g_chunk_size := 1500;
  ELSE
    g_chunk_size := p_chunk_size;
  END IF;
  g_user_id    := fnd_global.user_id;
  g_sysdate    := sysdate;

/* Time at start */
  output('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));

/* Get HRI schema name - get_app_info populates l_schema */
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN

  /* Empty out organization hierarchy tables */
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_ORGH_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

  /* Write timing information to log */
    output('Truncated organization hierarchy tables:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Disable WHO trigger */
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ORGH_CT_WHO DISABLE');

  /* Drop all the indexes on the table */
    hri_utl_ddl.log_and_drop_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_ORGH_CT',
      p_table_owner            => l_schema);

  /* Write timing information to log */
    output('Disabled indexes/WHO trigger:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Insert new organization hierarchy records */
    collect_org_structures;

  /* Write timing information to log */
    output('Re-populated organization hierarchy table:  '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Recreate indexes */
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_ORGH_CT',
      p_table_owner            => l_schema);

  /* Update flags to determine if orgs/nodes have workers */

    upd_org_has_worker_flags_full;

  /* Enable WHO trigger */
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ORGH_CT_WHO ENABLE');

  /* Write timing information to log */
    output('Enabled indexes/WHO trigger:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  END IF;

END load;

/******************************************************************************/
/* Load HRI_CS_ORGANZTN_CT table in full                                      */
/******************************************************************************/

PROCEDURE load_org_with_workers_full IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

/* Time at start */
  output('Start Loading Org with workers table:   ' || to_char(sysdate,'HH24:MI:SS'));
  --
/* Get HRI schema name - get_app_info populates l_schema */
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN

  /* Empty out organization with workers table */
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_ORGANZTN_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

  /* Write timing information to log */
    output('Truncated org with worker table:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Disable WHO trigger */
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ORGANZTN_CT_WHO DISABLE');

  /* Drop all the indexes on the table */
    hri_utl_ddl.log_and_drop_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_ORGANZTN_CT',
      p_table_owner            => l_schema);

  /* Write timing information to log */
    output('Disabled indexes/WHO trigger:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Enable parallel DML */
    run_sql_stmt_noerr('ALTER SESSION ENABLE PARALLEL DML');

  /* Insert new org with worker records */
    INSERT /*+ APPEND */ INTO HRI_CS_ORGANZTN_CT
    (org_organztn_pk,
    org_has_workers_flag,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
    SELECT DISTINCT
      organization_id  org_organztn_pk
     ,'Y'              org_has_workers_flag
     ,g_sysdate        last_update_date
     ,g_user_id        last_updated_by
     ,g_user_id        last_update_login
     ,g_user_id        created_by
     ,g_sysdate        creation_date
    FROM per_all_assignments_f;

    COMMIT;

  /* Write timing information to log */
    output('Re-populated org with workers table:  '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Recreate indexes */
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_CS_ORGANZTN_CT',
      p_table_owner            => l_schema);

  /* Enable WHO trigger */
    run_sql_stmt_noerr('ALTER TRIGGER HRI_CS_ORGANZTN_CT_WHO ENABLE');

  /* Write timing information to log */
    output('Enabled indexes/WHO trigger:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  END IF;

END load_org_with_workers_full;
--
/******************************************************************************/
/* Load HRI_CS_ORGANZTN_CT table incrementally                                */
/******************************************************************************/

PROCEDURE load_org_with_workers_incr
IS
CURSOR new_orgs_with_worker_csr
IS
--
SELECT DISTINCT asg.organization_id
FROM per_all_assignments_f asg
WHERE not exists (SELECT null
FROM hri_cs_organztn_ct org
WHERE org.org_organztn_pk = asg.organization_id);
--
BEGIN
  --
  output('Inside load_org_with_workers_incr:   '  ||
           to_char(sysdate,'HH24:MI:SS'));
  --
  OPEN new_orgs_with_worker_csr;
  FETCH new_orgs_with_worker_csr BULK COLLECT INTO g_new_orgs_with_worker;
  CLOSE new_orgs_with_worker_csr;
  --
  -- Insert records only if the cursor return records
  --
  IF g_new_orgs_with_worker.COUNT > 0 THEN
    --
    FORALL i IN g_new_orgs_with_worker.FIRST..g_new_orgs_with_worker.LAST
    INSERT INTO HRI_CS_ORGANZTN_CT
    (org_organztn_pk
    ,org_has_workers_flag
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date)
    VALUES
    (g_new_orgs_with_worker(i)
     ,'Y'
     ,g_sysdate
     ,g_user_id
     ,g_user_id
     ,g_user_id
     ,g_sysdate
     );
     --
  output('Inserted records incrementally:   '  ||
           to_char(sysdate,'HH24:MI:SS'));
  END IF;
   --
  output('Exiting load_org_with_workers_incr:   '  ||
           to_char(sysdate,'HH24:MI:SS'));
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    IF new_orgs_with_worker_csr%ISOPEN THEN
      CLOSE new_orgs_with_worker_csr;
    END IF;
    -- re-raise error
    RAISE;
END load_org_with_workers_incr;

/******************************************************************************/
/* Loads table to populate organization having workers                        */
/******************************************************************************/

PROCEDURE load_org_with_workers
IS
  --
  l_full_refresh      VARCHAR2(30);
  --
BEGIN

/* Determine full or incremental refresh */

  l_full_refresh := hri_oltp_conc_param.get_parameter_value
                       (p_parameter_name     => 'FULL_REFRESH',
                        p_process_table_name => 'HRI_CS_ORGANZTN_CT');

  IF l_full_refresh = 'Y' THEN

  /* Call main function to full refresh */
    load_org_with_workers_full;

  ELSE

  /* Incrementally include new organizations with  workers */

    load_org_with_workers_incr;

  END IF;

  /* Log process end */
    hri_bpl_conc_log.record_process_start('HRI_CS_ORGANZTN_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(SYSDATE)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => l_full_refresh);

END load_org_with_workers;
--
/******************************************************************************/
/* Entry point to be called from the concurrent manager                       */
/******************************************************************************/
PROCEDURE load( errbuf          OUT NOCOPY VARCHAR2,
                retcode         OUT NOCOPY VARCHAR2,
                p_chunk_size    IN NUMBER )

IS

  l_full_refresh      VARCHAR2(30);

BEGIN
  --
  g_user_id    := fnd_global.user_id;
  g_sysdate    := sysdate;

/* Enable output to concurrent request log */
  g_conc_request_flag := TRUE;

  /* Load table to populate organizations with workers */

  load_org_with_workers;

/* Determine full or incremental refresh */
  l_full_refresh := hri_oltp_conc_param.get_parameter_value
                     (p_parameter_name     => 'FULL_REFRESH',
                      p_process_table_name => 'HRI_CS_ORGH_CT');

  IF l_full_refresh = 'Y' THEN

  /* Call main function to full refresh */
    load
     (p_chunk_size => p_chunk_size);

  ELSE

  /* Incremental support for update of worker flags when a worker is   */
  /* assigned a organization not existing in table HRI_CS_ORGANZTN_CT  */

  upd_org_has_worker_flags_incr;

  /* Incremental support still to be added if it can be done */
  /* in a way to pick up new additions to structure only and */
  /* not support changes/updates to existing relationships  */
  --
  END IF;

/* Log process end */
  hri_bpl_conc_log.record_process_start('HRI_CS_ORGH_CT');
  hri_bpl_conc_log.log_process_end(
     p_status         => TRUE
    ,p_period_from    => TRUNC(SYSDATE)
    ,p_period_to      => TRUNC(SYSDATE)
    ,p_attribute1     => l_full_refresh);

EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := SQLCODE;

END load;

END hri_opl_orgh_ct;

/
