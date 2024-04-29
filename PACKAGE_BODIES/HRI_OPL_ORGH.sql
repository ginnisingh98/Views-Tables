--------------------------------------------------------
--  DDL for Package Body HRI_OPL_ORGH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_ORGH" AS
/* $Header: hriporgh.pkb 115.2 2004/05/25 07:27:09 prasharm noship $ */

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
/*  2) Loop through a view containing top organizations for each organization */
/*     hierarchy version                                                      */
/*                                                                            */
/*    i) Insert top organization chain into the organization hierarchy table  */
/*   ii) Insert chain for all organizations in that organization hierarchy    */
/*       version making use of the data structure to avoid recalculating the  */
/*       same information twice                                               */
/*                                                                            */
/*  3) Global structures are used to:                                         */
/*                                                                            */
/*    i) Bulk fetch the main loop                                             */
/*   ii) Bulk insert the chains into the hierarchy table                      */
/*  iii) Store information about the current chain being processed            */
/*   iv) Keep a note of which chains have been processed on a particular      */
/*       date to avoid re-processing the same information                     */
/*    v) Keep a note of the date each chain starts, so that the next time     */
/*       a chain is processed (on an earlier date) the end date is known      */
/*   vi) Store the terminated assignment status types so that it is quick to  */
/*       find out which are invalid at insert time                            */
/*                                                                            */
/******************************************************************************/

/* Information to be held for each link in a chain */
TYPE g_link_record_type IS RECORD
  (business_group_id    per_org_structure_elements.business_group_id%TYPE
  ,organization_id      per_org_structure_elements.organization_id_parent%TYPE
  ,last_chng_date       DATE);

/* Table type to hold information about the current chain */
TYPE g_chain_type IS TABLE OF g_link_record_type INDEX BY BINARY_INTEGER;

/* Global structure holding information about the current chain */
g_crrnt_chain              g_chain_type;

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
g_cs_sub_level          g_number_tab_type;
g_cs_sub_rlt_lvl        g_number_tab_type;
g_cs_last_chng          g_date_tab_type;

/* Global tables for bulk fetch */
g_fetch_top_org_id      g_number_tab_type;
g_fetch_osv_id          g_number_tab_type;
g_fetch_ost_id          g_number_tab_type;
g_fetch_vno_id          g_number_tab_type;
g_fetch_prm_flg         g_varchar2_tab_type;
g_fetch_start_dt        g_date_tab_type;
g_fetch_end_dt          g_date_tab_type;
g_fetch_bgr_id          g_number_tab_type;

g_cs_rows_to_insert    PLS_INTEGER;  -- Number of CS rows to insert

/* Set to true to output to a concurrent log file */
g_conc_request_flag       BOOLEAN := FALSE;

/* Number of rows bulk processed at a time */
g_chunk_size              PLS_INTEGER;

/* Start / End of time dates */
g_start_of_time           DATE := hr_general.start_of_time;
g_end_of_time             DATE := hr_general.end_of_time;

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
/* Recovers CS rows to insert when an exception occurs                        */
/******************************************************************************/
PROCEDURE recover_insert_cs_rows IS

BEGIN
  -- loop through rows still to insert one at a time
  FOR i IN 1..g_cs_rows_to_insert LOOP

    -- Trap unique constraint errors
    BEGIN

      INSERT INTO hri_org_hrchy_summary
        (organization_structure_id
        ,org_structure_version_id
        ,org_business_group_id
        ,organization_id
        ,organization_level
        ,sub_org_business_group_id
        ,sub_organization_id
        ,sub_organization_level
        ,sub_org_relative_level
        ,last_ptntl_change)
          VALUES
            (g_cs_ost_id(i)
            ,g_cs_osv_id(i)
            ,g_cs_bgr_id(i)
            ,g_cs_sup_org_id(i)
            ,g_cs_sup_level(i)
            ,g_cs_bgr_id(i)
            ,g_cs_sub_org_id(i)
            ,g_cs_sub_level(i)
            ,g_cs_sub_rlt_lvl(i)
            ,g_cs_last_chng(i));

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
    INSERT INTO hri_org_hrchy_summary
        (organization_structure_id
        ,org_structure_version_id
        ,org_business_group_id
        ,organization_id
        ,organization_level
        ,sub_org_business_group_id
        ,sub_organization_id
        ,sub_organization_level
        ,sub_org_relative_level
        ,last_ptntl_change)
          VALUES
            (g_cs_ost_id(i)
            ,g_cs_osv_id(i)
            ,g_cs_bgr_id(i)
            ,g_cs_sup_org_id(i)
            ,g_cs_sup_level(i)
            ,g_cs_bgr_id(i)
            ,g_cs_sub_org_id(i)
            ,g_cs_sub_level(i)
            ,g_cs_sub_rlt_lvl(i)
            ,g_cs_last_chng(i));
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
                       , p_sub_organization_id     IN NUMBER
                       , p_sub_level               IN NUMBER
                       , p_index                   IN NUMBER
                       , p_last_ptntl_change       IN DATE ) IS

BEGIN
  -- increment the index
  g_cs_rows_to_insert := g_cs_rows_to_insert + 1;
  -- set the table structures
  g_cs_sup_org_id(g_cs_rows_to_insert)   := p_sup_organization_id;
  g_cs_sup_level(g_cs_rows_to_insert)    := p_sup_level;
  g_cs_sub_org_id(g_cs_rows_to_insert)   := p_sub_organization_id;
  g_cs_sub_level(g_cs_rows_to_insert)    := p_sub_level;
  g_cs_sub_rlt_lvl(g_cs_rows_to_insert)  := p_sub_level - p_sup_level;
  g_cs_ost_id(g_cs_rows_to_insert)       := g_fetch_ost_id(p_index);
  g_cs_bgr_id(g_cs_rows_to_insert)       := g_fetch_bgr_id(p_index);
  g_cs_osv_id(g_cs_rows_to_insert)       := g_fetch_osv_id(p_index);
  g_cs_last_chng(g_cs_rows_to_insert)    := p_last_ptntl_change;
END insert_cs_row;


/******************************************************************************/
/* Updates all organizations in the organization hierarchy version starting   */
/* with the top organization.                                                 */
/******************************************************************************/
PROCEDURE calculate_chains( p_index        IN NUMBER ) IS

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
        WHERE ose.org_structure_version_id = g_fetch_osv_id(p_index))  hier
  START WITH hier.organization_id_parent = g_fetch_top_org_id(p_index)
  CONNECT BY PRIOR hier.organization_id_child = organization_id_parent;
/******************************/
/* DO NOT ADD ORDER BY CLAUSE */
/******************************/

  l_org_lvl          PLS_INTEGER;
  l_last_org_lvl     PLS_INTEGER;

BEGIN

/* Store details for top organization */
  g_crrnt_chain(1).organization_id   := g_fetch_top_org_id(p_index);
  g_crrnt_chain(1).last_chng_date    := g_fetch_start_dt(p_index);

/* Insert chain */
  insert_cs_row
    (p_sup_organization_id   => g_crrnt_chain(1).organization_id
    ,p_sup_level             => 1
    ,p_sub_organization_id   => g_crrnt_chain(1).organization_id
    ,p_sub_level             => 1
    ,p_index                 => p_index
    ,p_last_ptntl_change     => g_crrnt_chain(1).last_chng_date);

/* Loop through organizations in organization hierarchy version */
  FOR org_rec IN organizations_csr LOOP

    l_org_lvl := org_rec.actual_level;

    IF (l_last_org_lvl > l_org_lvl) THEN
    /* Reset end of chain */
      FOR i IN l_org_lvl+1..l_last_org_lvl LOOP
        g_crrnt_chain(i).organization_id := to_number(null);
      END LOOP;
    END IF;

    g_crrnt_chain(l_org_lvl).organization_id   := org_rec.organization_id;
    g_crrnt_chain(l_org_lvl).last_chng_date    :=
           GREATEST(org_rec.last_update_date,
                    g_crrnt_chain(l_org_lvl - 1).last_chng_date);

    /* Loop through links in (stored) chain of organizations */
      FOR l_sup_lvl IN 1..l_org_lvl LOOP

      /* Insert chain into CS */
        insert_cs_row
          (p_sup_organization_id   => g_crrnt_chain(l_sup_lvl).organization_id
          ,p_sup_level             => l_sup_lvl
          ,p_sub_organization_id   => g_crrnt_chain(l_org_lvl).organization_id
          ,p_sub_level             => l_org_lvl
          ,p_index                 => p_index
          ,p_last_ptntl_change     => g_crrnt_chain(l_org_lvl).last_chng_date);

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
            to_char(g_fetch_top_org_id(p_index)));
  ELSE
/* Some other error */
    RAISE;
  END IF;

END calculate_chains;

/******************************************************************************/
/* Loops through organization structure versions                              */
/******************************************************************************/
PROCEDURE collect_org_structures IS

/* Pick out all organization structure versions and their top organizations */
  CURSOR hrchy_version_csr IS
  SELECT /*+ USE_NL(ose ost) */ DISTINCT
   ose.organization_id_parent
  ,osv.org_structure_version_id
  ,osv.organization_structure_id
  ,osv.version_number
  ,ost.primary_structure_flag
  ,osv.date_from
  ,NVL(osv.date_to,g_end_of_time)
  ,osv.business_group_id
  FROM
   per_org_structure_elements     ose
  ,per_org_structure_versions     osv
  ,per_organization_structures    ost
  WHERE osv.org_structure_version_id = ose.org_structure_version_id
  AND ost.organization_structure_id = osv.organization_structure_id
--  AND ost.primary_structure_flag = 'Y'
  AND NOT EXISTS
    (SELECT NULL
     FROM per_org_structure_elements ose2
     WHERE ose2.org_structure_version_id = ose.org_structure_version_id
     AND ose2.organization_id_child = ose.organization_id_parent);

  l_return_code          PLS_INTEGER;
  l_exit_main_loop       BOOLEAN := FALSE;
  l_rows_fetched         PLS_INTEGER := g_chunk_size;

BEGIN
  -- initialise the g_cs_rows_to_insert
  g_cs_rows_to_insert := 0;
  -- initialise the current chain for CSF structure
  FOR i IN 1..15 LOOP
    g_crrnt_chain(i).organization_id := to_number(null);
  END LOOP;
  -- open main cursor
  OPEN hrchy_version_csr;
  <<main_loop>>
  LOOP
    -- bulk fetch rows limit the fetch to value of g_chunk_size
    FETCH hrchy_version_csr
    BULK COLLECT INTO
          g_fetch_top_org_id,
          g_fetch_osv_id,
          g_fetch_ost_id,
          g_fetch_vno_id,
          g_fetch_prm_flg,
          g_fetch_start_dt,
          g_fetch_end_dt,
          g_fetch_bgr_id
    LIMIT g_chunk_size;
    -- check to see if the last row has been fetched
    IF hrchy_version_csr%NOTFOUND THEN
      -- last row fetched, set exit loop flag
      l_exit_main_loop := TRUE;
      -- do we have any rows to process?
      l_rows_fetched := MOD(hrchy_version_csr%ROWCOUNT,g_chunk_size);
      -- note: if l_rows_fetched > 0 then more rows are required to be
      -- processed and the l_rows_fetched will contain the exact number of
      -- rows left to process
      IF l_rows_fetched = 0 THEN
        -- no more rows to process so exit loop
        EXIT main_loop;
      END IF;
    END IF;

    -- Loop through organization hierarchy versions
    FOR i IN 1..l_rows_fetched LOOP

      calculate_chains( p_index => i );

    END LOOP;
    -- exit loop if required
    IF l_exit_main_loop THEN
      EXIT main_loop;
    END IF;
  END LOOP; -- main loop
  CLOSE hrchy_version_csr;
/* Insert any remaining stored rows */
  IF (g_cs_rows_to_insert > 0) THEN
      bulk_insert_cs_rows;
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
/* Main entry point to reload the organization hierarchy table                */
/******************************************************************************/
PROCEDURE load( p_chunk_size    IN NUMBER ) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

/* Set chunk size */
  g_chunk_size := p_chunk_size;

/* Time at start */
  output('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));

/* Get HRI schema name - get_app_info populates l_schema */
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN

  /* Empty out organization hierarchy tables */
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_ORG_HRCHY_SUMMARY';
    EXECUTE IMMEDIATE(l_sql_stmt);

  /* Write timing information to log */
    output('Truncated organization Hierarchy tables:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Insert new organization hierarchy records */
    collect_org_structures;

  /* Write timing information to log */
    output('Re-populated organization Hierarchy table:  '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Gather index stats */
--    fnd_stats.gather_table_stats(l_schema, 'HRI_CS_orgH');

  /* Write timing information to log */
--    output('Gathered stats:   '  ||
--           to_char(sysdate,'HH24:MI:SS'));

  END IF;

END load;

/******************************************************************************/
/* Entry point to be called from the concurrent manager                       */
/******************************************************************************/
PROCEDURE load( errbuf          OUT NOCOPY VARCHAR2,
                retcode         OUT NOCOPY VARCHAR2,
                p_chunk_size    IN NUMBER )

IS

BEGIN

/* Enable output to concurrent request log */
  g_conc_request_flag := TRUE;

/* Call main function */
  load(p_chunk_size => p_chunk_size);

EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := SQLCODE;

END load;

END hri_opl_orgh;

/
