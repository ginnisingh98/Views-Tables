--------------------------------------------------------
--  DDL for Package Body HRI_OPL_POSH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_POSH" AS
/* $Header: hrioposh.pkb 120.1 2005/06/08 02:53:23 anmajumd noship $ */

/******************************************************************************/
/*                                                                            */
/* OUTLINE / DEFINITIONS                                                      */
/*                                                                            */
/* A chain is defined for a position as a list starting with the position     */
/* which contains and successive higher level positions finishing with the    */
/* highest level (top) position.                                              */
/*                                                                            */
/* IMPLEMENTATION LOGIC                                                       */
/*                                                                            */
/* The position hierarchy table is populated by carrying out the following    */
/* steps:                                                                     */
/*                                                                            */
/*  1) Empty out existing table                                               */
/*                                                                            */
/*  2) Loop through a view containing top positions for each position         */
/*     hierarchy version                                                      */
/*                                                                            */
/*    i) Insert top position chain into the position hierarchy table          */
/*   ii) Insert chain for all positions in that position hierarchy version    */
/*       making use of the data structure to avoid recalculating the same     */
/*       information twice                                                    */
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
  (business_group_id       per_pos_structure_elements.business_group_id%TYPE
  ,position_id             per_pos_structure_elements.parent_position_id%TYPE);

/* Table type to hold information about the current chain */
TYPE g_chain_type IS TABLE OF g_link_record_type INDEX BY BINARY_INTEGER;

/* Global structure holding information about the current chain */
g_crrnt_chain              g_chain_type;

/* Simple table types */
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/* PLSQL table of tables representing database table */
g_dbtab_pst_id             g_number_tab_type;
g_dbtab_prm_flg            g_varchar2_tab_type;
g_dbtab_psv_id             g_number_tab_type;
g_dbtab_vno_id             g_number_tab_type;
g_dbtab_bgr_id             g_number_tab_type;
g_dbtab_sup_pos_id         g_number_tab_type;
g_dbtab_sup_level          g_number_tab_type;
g_dbtab_sub_pos_id         g_number_tab_type;
g_dbtab_sub_level          g_number_tab_type;
g_dbtab_sub_rlt_lvl        g_number_tab_type;
g_dbtab_start_date         g_date_tab_type;
g_dbtab_end_date           g_date_tab_type;

/* Global variables for current position structure version */
g_position_structure_id      NUMBER;
g_pos_structure_version_id   NUMBER;
g_version_number             NUMBER;
g_effective_start_date       NUMBER;
g_effective_end_date         NUMBER;

/* Global tables for bulk fetch */
g_fetch_top_pos_id      g_number_tab_type;
g_fetch_psv_id          g_number_tab_type;
g_fetch_pst_id          g_number_tab_type;
g_fetch_vno_id          g_number_tab_type;
g_fetch_prm_flg         g_varchar2_tab_type;
g_fetch_start_dt        g_date_tab_type;
g_fetch_end_dt          g_date_tab_type;
g_fetch_bgr_id          g_number_tab_type;

g_stored_rows_to_insert    PLS_INTEGER;  -- Number of row to insert

/* Set to true to output to a concurrent log file */
g_conc_request_flag       BOOLEAN := FALSE;

/* Number of rows bulk processed at a time */
g_chunk_size              PLS_INTEGER;

/* End of time date */
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
/* Recovers rows to insert when an exception occurs                           */
/******************************************************************************/
PROCEDURE recover_insert_rows IS

BEGIN
  -- loop through rows still to insert one at a time
  FOR i IN 1..g_stored_rows_to_insert LOOP

    -- Trap unique constraint errors
    BEGIN

      INSERT INTO hri_cs_posh
        (position_structure_id
        ,primary_hierarchy_flag_code
        ,pos_structure_version_id
        ,version_number
        ,business_group_id
        ,sup_position_id
        ,sup_level
        ,sub_position_id
        ,sub_level
        ,sub_relative_level
        ,effective_start_date
        ,effective_end_date)
          VALUES
            (g_dbtab_pst_id(i)
            ,g_dbtab_prm_flg(i)
            ,g_dbtab_psv_id(i)
            ,g_dbtab_vno_id(i)
            ,g_dbtab_bgr_id(i)
            ,g_dbtab_sup_pos_id(i)
            ,g_dbtab_sup_level(i)
            ,g_dbtab_sub_pos_id(i)
            ,g_dbtab_sub_level(i)
            ,g_dbtab_sub_rlt_lvl(i)
            ,g_dbtab_start_date(i)
            ,g_dbtab_end_date(i));

    EXCEPTION
      WHEN OTHERS THEN

      /* Probable overlap on date tracked assignment rows */
      output('Single insert error: ' || to_char(g_dbtab_sub_pos_id(i)) ||
             ' - ' || to_char(g_dbtab_sup_pos_id(i)));
      output('Inserting date range: ' ||
              to_char(g_dbtab_start_date(i),'DD-MON-YYYY') || ' - ' ||
              to_char(g_dbtab_end_date(i),'DD-MON-YYYY'));
      output(sqlerrm);
      output(sqlcode);

    END;

  END LOOP;

  -- commit
  commit;

END recover_insert_rows;

/******************************************************************************/
/* Bulk inserts rows from global temporary table to database table            */
/******************************************************************************/
PROCEDURE bulk_insert_rows IS

BEGIN
  -- insert chunk of rows
  FORALL i IN 1..g_stored_rows_to_insert
    INSERT INTO hri_cs_posh
        (position_structure_id
        ,primary_hierarchy_flag_code
        ,pos_structure_version_id
        ,version_number
        ,business_group_id
        ,sup_position_id
        ,sup_level
        ,sub_position_id
        ,sub_level
        ,sub_relative_level
        ,effective_start_date
        ,effective_end_date)
          VALUES
            (g_dbtab_pst_id(i)
            ,g_dbtab_prm_flg(i)
            ,g_dbtab_psv_id(i)
            ,g_dbtab_vno_id(i)
            ,g_dbtab_bgr_id(i)
            ,g_dbtab_sup_pos_id(i)
            ,g_dbtab_sup_level(i)
            ,g_dbtab_sub_pos_id(i)
            ,g_dbtab_sub_level(i)
            ,g_dbtab_sub_rlt_lvl(i)
            ,g_dbtab_start_date(i)
            ,g_dbtab_end_date(i));
  -- commit the chunk of rows
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN

/* Unique constraint error */
  rollback;
  recover_insert_rows;

END bulk_insert_rows;

/******************************************************************************/
/* Inserts row into global temporary table                                    */
/******************************************************************************/
PROCEDURE insert_row( p_business_group_id       IN NUMBER
                    , p_sup_position_id         IN NUMBER
                    , p_sup_level               IN NUMBER
                    , p_sub_position_id         IN NUMBER
                    , p_sub_level               IN NUMBER
                    , p_index                   IN NUMBER ) IS

BEGIN
  -- increment the index
  g_stored_rows_to_insert := g_stored_rows_to_insert + 1;
  -- set the table structures
  g_dbtab_pst_id(g_stored_rows_to_insert)       := g_fetch_pst_id(p_index);
  g_dbtab_prm_flg(g_stored_rows_to_insert)      := g_fetch_prm_flg(p_index);
  g_dbtab_psv_id(g_stored_rows_to_insert)       := g_fetch_psv_id(p_index);
  g_dbtab_vno_id(g_stored_rows_to_insert)       := g_fetch_vno_id(p_index);
  g_dbtab_bgr_id(g_stored_rows_to_insert)       := p_business_group_id;
  g_dbtab_sup_pos_id(g_stored_rows_to_insert)   := p_sup_position_id;
  g_dbtab_sup_level(g_stored_rows_to_insert)    := p_sup_level;
  g_dbtab_sub_pos_id(g_stored_rows_to_insert)   := p_sub_position_id;
  g_dbtab_sub_level(g_stored_rows_to_insert)    := p_sub_level;
  g_dbtab_sub_rlt_lvl(g_stored_rows_to_insert)  := p_sub_level - p_sup_level;
  g_dbtab_start_date(g_stored_rows_to_insert)   := g_fetch_start_dt(p_index);
  g_dbtab_end_date(g_stored_rows_to_insert)     := g_fetch_end_dt(p_index);
END insert_row;

/******************************************************************************/
/* Updates all positions in the position hierarchy version starting with the  */
/* top position.                                                              */
/******************************************************************************/
PROCEDURE calculate_chains( p_index        IN NUMBER ) IS

/* Cursor picks out all positions in the position structure */
/* This cursor MUST return rows in the default order */
  CURSOR positions_csr IS
  SELECT
   hier.business_group_id         business_group_id
  ,hier.subordinate_position_id   position_id
  ,LEVEL+1                        actual_level
  FROM (SELECT
        pse.business_group_id
       ,pse.subordinate_position_id
       ,pse.parent_position_id
       FROM
        per_pos_structure_elements   pse
       WHERE pse.pos_structure_version_id = g_fetch_psv_id(p_index))  hier
  START WITH hier.parent_position_id = g_fetch_top_pos_id(p_index)
  CONNECT BY PRIOR hier.subordinate_position_id = parent_position_id;
/******************************/
/* DO NOT ADD ORDER BY CLAUSE */
/******************************/

  l_pos_lvl          PLS_INTEGER;

BEGIN

/* Store details for top position */
  g_crrnt_chain(1).business_group_id := g_fetch_bgr_id(p_index);
  g_crrnt_chain(1).position_id       := g_fetch_top_pos_id(p_index);

      /* Insert chain */
        insert_row
          (p_business_group_id     => g_crrnt_chain(1).business_group_id
          ,p_sup_position_id       => g_crrnt_chain(1).position_id
          ,p_sup_level             => 1
          ,p_sub_position_id       => g_crrnt_chain(1).position_id
          ,p_sub_level             => 1
          ,p_index                 => p_index);

/* Loop through positions in position hierarchy veresion */
  FOR pos_rec IN positions_csr LOOP

    l_pos_lvl := pos_rec.actual_level;

    g_crrnt_chain(l_pos_lvl).business_group_id := pos_rec.business_group_id;
    g_crrnt_chain(l_pos_lvl).position_id       := pos_rec.position_id;

    /* Loop through links in (stored) chain of positions */
      FOR l_sup_lvl IN 1..l_pos_lvl LOOP

      /* Insert chain */
        insert_row
          (p_business_group_id     => g_crrnt_chain(l_sup_lvl).business_group_id
          ,p_sup_position_id       => g_crrnt_chain(l_sup_lvl).position_id
          ,p_sup_level             => l_sup_lvl
          ,p_sub_position_id       => g_crrnt_chain(l_pos_lvl).position_id
          ,p_sub_level             => l_pos_lvl
          ,p_index                 => p_index);

      END LOOP; -- Links in stored chain

  END LOOP;  -- Positions in hierarchy version

EXCEPTION
  WHEN OTHERS THEN

/* ORA 01436 - loop in tree walk */
  IF (SQLCODE = -1436) THEN
    output('Loop found for position id:  ' ||
            to_char(g_fetch_top_pos_id(p_index)));
  ELSE
/* Some other error */
    RAISE;
  END IF;

END calculate_chains;

/******************************************************************************/
/* Loops through position structure versions                                  */
/******************************************************************************/
PROCEDURE collect_pos_structures IS

/* Pick out all position structure versions and their top positions */
  CURSOR hrchy_version_csr IS
  SELECT DISTINCT
   pse.parent_position_id
  ,psv.pos_structure_version_id
  ,psv.position_structure_id
  ,psv.version_number
  ,pst.primary_position_flag
  ,psv.date_from
  ,NVL(psv.date_to,g_end_of_time)
  ,psv.business_group_id
  FROM
   per_pos_structure_elements pse
  ,per_pos_structure_versions psv
  ,per_position_structures    pst
  WHERE psv.pos_structure_version_id = pse.pos_structure_version_id
  AND pst.position_structure_id = psv.position_structure_id
  AND pst.primary_position_flag = 'Y'
  AND NOT EXISTS
    (SELECT NULL
     FROM per_pos_structure_elements pse2
     WHERE pse2.pos_structure_version_id = pse.pos_structure_version_id
     AND pse2.subordinate_position_id = pse.parent_position_id);

  l_return_code          PLS_INTEGER;
  l_exit_main_loop       BOOLEAN := FALSE;
  l_rows_fetched         PLS_INTEGER := g_chunk_size;

BEGIN
  -- initialise the g_stored_rows_to_insert
  g_stored_rows_to_insert := 0;
  -- open main cursor
  OPEN hrchy_version_csr;
  <<main_loop>>
  LOOP
    -- bulk fetch rows limit the fetch to value of g_chunk_size
    FETCH hrchy_version_csr
    BULK COLLECT INTO
          g_fetch_top_pos_id,
          g_fetch_psv_id,
          g_fetch_pst_id,
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

    -- Loop through position hierarchy versions
    FOR i IN 1..l_rows_fetched LOOP

      calculate_chains( p_index => i );

    END LOOP;
    -- bulk insert rows processed so far
    bulk_insert_rows;
    -- reset the index
    g_stored_rows_to_insert := 0;
    -- exit loop if required
    IF l_exit_main_loop THEN
      EXIT main_loop;
    END IF;
  END LOOP;
  CLOSE hrchy_version_csr;
EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    IF hrchy_version_csr%ISOPEN THEN
      CLOSE hrchy_version_csr;
    END IF;
    -- re-raise error
    RAISE;
END collect_pos_structures;

/******************************************************************************/
/* Main entry point to reload the position hierarchy table                    */
/******************************************************************************/
PROCEDURE Load_all_positions( p_chunk_size    IN NUMBER ) IS

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

  /* Empty out position hierarchy table */
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_CS_POSH';
    EXECUTE IMMEDIATE(l_sql_stmt);

  /* Write timing information to log */
    output('Truncated Position Hierarchy table:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Insert new position hierarchy records */
    collect_pos_structures;

  /* Write timing information to log */
    output('Re-populated Position Hierarchy table:  '  ||
           to_char(sysdate,'HH24:MI:SS'));

  /* Gather index stats */
    fnd_stats.gather_table_stats(l_schema, 'HRI_CS_POSH');

  /* Write timing information to log */
    output('Gathered stats:   '  ||
           to_char(sysdate,'HH24:MI:SS'));

  END IF;

END Load_all_positions;

/******************************************************************************/
/* Entry point to be called from the concurrent manager                       */
/******************************************************************************/
PROCEDURE load_all_positions( errbuf          OUT NOCOPY VARCHAR2,
                              retcode         OUT NOCOPY VARCHAR2,
                              p_chunk_size    IN NUMBER )

IS

BEGIN

/* Enable output to concurrent request log */
  g_conc_request_flag := TRUE;

/* Call main function */
  load_all_positions
    (p_chunk_size => p_chunk_size);

EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := SQLCODE;

END load_all_positions;

END hri_opl_posh;

/
