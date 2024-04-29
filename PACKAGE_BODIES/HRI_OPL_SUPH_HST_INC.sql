--------------------------------------------------------
--  DDL for Package Body HRI_OPL_SUPH_HST_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_SUPH_HST_INC" AS
/* $Header: hrioshhi.pkb 115.15 2003/05/27 14:45:06 jtitmas noship $ */

/******************************************************************************/
/*                                                                            */
/* OUTLINE / DEFINITIONS                                                      */
/*                                                                            */
/* CHAINS                                                                     */
/* ======                                                                     */
/* A chain is defined for an employee as a list starting with the employee    */
/* which contains their supervisor, and successive higher level supervisors   */
/* finishing with the highest level (overall) supervisor.                     */
/*                                                                            */
/* Each chain is valid for the length of time it describes the supervisor     */
/* hierarchy between the employee it is defined for and the overall           */
/* supervisor in the hierarchy.                                               */
/*                                                                            */
/* The supervisor hierarchy table implements each link in the chain as a      */
/* row with the employee the chain is defined for as the subordinate. The     */
/* absolute levels refer to absolute positions within the overall hierarchy   */
/* whereas the relative level refers to the difference in the absolute levels */
/* for the row.                                                               */
/*                                                                            */
/* When an employee changes supervisor, their chain must change since their   */
/* immediate supervisor is different. However, the chains of all that         */
/* employee's subordinates must also change because a chain consists of       */
/* each higher level supervisor up to and including the overall supervisor.   */
/*                                                                            */
/* LEAF NODES                                                                 */
/* ==========                                                                 */
/* If a person is supervised but is not themselves a supervisor they are      */
/* termed a "leaf node". The supervisor hierarchy history table also tracks   */
/* whether the chain owner is a leaf node or not. Terminated people do not    */
/* have a leaf node status.                                                   */
/*                                                                            */
/* IMPLEMENTATION LOGIC                                                       */
/* ====================                                                       */
/* The supervisor hierarchy history table is populated by carrying out the    */
/* following steps:                                                           */
/*                                                                            */
/*  1) Empty out existing table                                               */
/*                                                                            */
/*  2) Loop through a view containing supervisor changes. Supervisor changes  */
/*     are:                                                                   */
/*             - New hires with a supervisor                                  */
/*             - Switching supervisor (before separation)                     */
/*             - Supervisors (including "leaf nodes") who terminate           */
/*             - Subordinates of supervisors which are finally processed      */
/*               without the subordinate being updated                        */
/*             - Plus the initialization which is done by selecting all the   */
/*               top supervisors at the start of the collection               */
/*                                                                            */
/*     Processing the changes sequentially in reverse date order:             */
/*                                                                            */
/*    i) Calculate new chain for the person who has changed supervisor        */
/*   ii) Get the end date for the chain (held in global, or if not then the   */
/*       chain owner's termination date, or if not then end of time)          */
/*  iii) Insert new chain into hierarchy table                                */
/*   iv) Store the same information in a global data structure                */
/*    v) If the supervisor change is not the first record of the person then  */
/*       propagate the change down to all that person's subordinates making   */
/*       use of the data structure to avoid recalculating the same            */
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
/*  vii) Keep track of whether a supervisor is a leaf node                    */
/*                                                                            */
/*  4) Errors encountered which are specifically handled arise from data      */
/*     inconsistencies:                                                       */
/*                                                                            */
/*    i) Loops in supervisor chain - error is output to log file with the     */
/*       date and assignment in looped chain                                  */
/*   ii) Overlapping assignment records - these mean a unique constraint      */
/*       error is encountered when inserting. This is recovered and the       */
/*       offending row found. An error is recorded in the log and processing  */
/*       continues.                                                           */
/*                                                                            */
/******************************************************************************/

/* Information to be held for each link in a chain */
TYPE g_link_record_type IS RECORD
  (business_group_id       per_all_assignments_f.business_group_id%TYPE
  ,person_id               per_all_assignments_f.person_id%TYPE
  ,assignment_id           per_all_assignments_f.assignment_id%TYPE
  ,asg_status_id           per_all_assignments_f.assignment_status_type_id%TYPE
  ,invalid_flag            VARCHAR2(30)
  ,primary_asg_flag        per_all_assignments_f.primary_flag%TYPE
  ,leaf_node               VARCHAR2(30)
  ,end_date                per_all_assignments_f.effective_end_date%TYPE);

/* Table type to hold information about the current chain */
TYPE g_chain_type IS TABLE OF g_link_record_type INDEX BY BINARY_INTEGER;

/* Simple table types */
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/* PLSQL table of terminated assignment status types */
g_term_asg_statuses        g_varchar2_tab_type;

/* PLSQL table of end dates */
g_final_date_tab           g_date_tab_type;

/* PLSQL tables for main bulk fetch */
g_fetch_asg_id             g_number_tab_type;
g_fetch_strt_dt            g_date_tab_type;
g_fetch_end_dt             g_date_tab_type;
g_fetch_bgr_id             g_number_tab_type;
g_fetch_psn_id             g_number_tab_type;
g_fetch_sup_id             g_number_tab_type;
g_fetch_prev_sup_id        g_number_tab_type;
g_fetch_ast_id             g_number_tab_type;
g_fetch_pos_id             g_number_tab_type;
g_fetch_chng_dt            g_date_tab_type;
g_fetch_evt_code           g_varchar2_tab_type;
g_fetch_term_dt            g_date_tab_type;
g_fetch_fprc_dt            g_date_tab_type;

/* PLSQL table of top level supervisor checks */
g_top_level_check          g_date_tab_type;

/* PLSQL table of dates assignments have already been processed */
/* Indexed by assignment id */
g_assgnmnts_prcssd         g_date_tab_type;

g_collect_from_date        DATE;   -- Collection date range start
g_collect_to_date          DATE;   -- Collection date range end

/* Information about current chain within the hierarchy */
g_crrnt_chain              g_chain_type;    -- Current chain
g_crrnt_chain_start_date   DATE;            -- Current chain start date
g_crrnt_chain_end_date     DATE;            -- Current chain end date
g_crrnt_chain_owner_lvl    PLS_INTEGER;     -- Chain owner's level within chain
g_crrnt_chain_orphan_flag  VARCHAR2(1);     -- Whether current chain is orphaned
g_crrnt_chain_top_pos_id   NUMBER;          -- Current top node period of service

/* Set to true to output to a concurrent log file */
g_conc_request_flag       BOOLEAN := FALSE;

/* Number of rows bulk processed at a time */
g_chunk_size              PLS_INTEGER := 2000;
g_chain_chunk_size        PLS_INTEGER := 500;
g_chain_transactions      PLS_INTEGER := 0;

/* Stores end of time value */
g_end_of_time             DATE := hr_general.end_of_time;

/* Stores current time value */
g_current_time            DATE;
g_current_date            DATE := TRUNC(SYSDATE);

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
/* Load g_term_asg_statuses with the assignment status types which are        */
/* terminated                                                                 */
/******************************************************************************/
PROCEDURE init_term_per_system_status IS

  CURSOR term_asg_statuses_csr IS
    SELECT ast.assignment_status_type_id
    FROM   per_assignment_status_types ast
    WHERE  ast.per_system_status = 'TERM_ASSIGN';

BEGIN

  FOR term_asg_status in term_asg_statuses_csr LOOP

    -- load g_term_asg_statuses element at index position of value returned
    g_term_asg_statuses(term_asg_status.assignment_status_type_id) := 'Y';

  END LOOP;

END init_term_per_system_status;

/******************************************************************************/
/* Return whether the assignment status type id is terminated                 */
/******************************************************************************/
FUNCTION get_inv_flag_status(p_assignment_status_type_id
                IN per_assignment_status_types.assignment_status_type_id%TYPE)
         RETURN VARCHAR2 IS

BEGIN

  -- returns Y if the element exists otherwise a NO_DATA_FOUND exception
  -- will be raised
  RETURN(g_term_asg_statuses(p_assignment_status_type_id));

EXCEPTION
  WHEN NO_DATA_FOUND THEN

   -- element doesn't exist, return N
   RETURN('N');

END get_inv_flag_status;

/******************************************************************************/
/* Checks whether a person is a leaf node on a given date                     */
/******************************************************************************/
FUNCTION is_a_leaf_node( p_person_id   IN NUMBER
                       , p_on_date     IN DATE )
           RETURN VARCHAR2 IS

/* A supervisor is a leaf node if they have no non-terminated direct */
/* subordinates. Hint seems obvious but on GSIAPDEV it was required */
  CURSOR is_a_leaf_csr IS
  SELECT /*+ index(ast PER_ASSIGNMENT_STATUS_TYPE_PK) use_nl(asg ast) */
   'N'
  FROM per_all_assignments_f  asg,
       per_assignment_status_types ast
  WHERE asg.supervisor_id = p_person_id
  AND asg.assignment_type = 'E'
  AND asg.primary_flag = 'Y'
  AND ast.assignment_status_type_id = asg.assignment_status_type_id
  AND ast.per_system_status <> 'TERM_ASSIGN'
  AND p_on_date BETWEEN asg.effective_start_date
                AND asg.effective_end_date;

  l_is_a_leaf_flag    VARCHAR2(1);

BEGIN

/* Check if the supervisor has any non terminated subordinates */
  OPEN is_a_leaf_csr;
  FETCH is_a_leaf_csr INTO l_is_a_leaf_flag;
  CLOSE is_a_leaf_csr;

  RETURN NVL(l_is_a_leaf_flag, 'Y');

END is_a_leaf_node;

/******************************************************************************/
/* Inserts row into global temporary table                                    */
/******************************************************************************/
PROCEDURE insert_row( p_sup_business_group_id   IN NUMBER
                    , p_sup_person_id           IN NUMBER
                    , p_sup_assignment_id       IN NUMBER
                    , p_sup_asg_status_id       IN NUMBER
                    , p_sup_level               IN NUMBER
                    , p_sup_inv_flag            IN VARCHAR2
                    , p_sub_business_group_id   IN NUMBER
                    , p_sub_person_id           IN NUMBER
                    , p_sub_assignment_id       IN NUMBER
                    , p_sub_asg_status_id       IN NUMBER
                    , p_sub_primary_asg_flag    IN VARCHAR2
                    , p_sub_level               IN NUMBER
                    , p_sub_relative_level      IN NUMBER
                    , p_sub_inv_flag            IN VARCHAR2
                    , p_effective_start_date    IN DATE
                    , p_effective_end_date      IN DATE
                    , p_orphan_flag             IN VARCHAR2
                    , p_sub_leaf_flag           IN VARCHAR2 ) IS

BEGIN

  BEGIN

    INSERT INTO hri_cs_suph
      (sup_business_group_id
      ,sup_person_id
      ,sup_assignment_id
      ,sup_assignment_status_type_id
      ,sup_level
      ,sup_invalid_flag_code
      ,sub_business_group_id
      ,sub_person_id
      ,sub_assignment_id
      ,sub_assignment_status_type_id
      ,sub_primary_asg_flag_code
      ,sub_level
      ,sub_relative_level
      ,sub_invalid_flag_code
      ,orphan_flag_code
      ,sub_leaf_flag_code
      ,effective_start_date
      ,effective_end_date)
        VALUES
              (p_sup_business_group_id
              ,p_sup_person_id
              ,p_sup_assignment_id
              ,p_sup_asg_status_id
              ,p_sup_level
              ,p_sup_inv_flag
              ,p_sub_business_group_id
              ,p_sub_person_id
              ,p_sub_assignment_id
              ,p_sub_asg_status_id
              ,p_sub_primary_asg_flag
              ,p_sub_level
              ,p_sub_relative_level
              ,p_sub_inv_flag
              ,p_orphan_flag
              ,p_sub_leaf_flag
              ,p_effective_start_date
              ,p_effective_end_date);

  EXCEPTION WHEN OTHERS THEN
    output('Error inserting chain for:');
    output('--: ' || to_char(p_sub_person_id) || ' between ' || to_char(p_effective_start_date) ||
           ' and ' || to_char(p_effective_end_date));
  END;

END insert_row;

/******************************************************************************/
/* Inserts chain from specified level                                         */
/******************************************************************************/
PROCEDURE insert_chain( p_level      IN NUMBER,
                        p_end_date   IN DATE) IS

BEGIN

  g_chain_transactions := g_chain_transactions + 1;

  FOR i IN 1..p_level LOOP

    insert_row
        (p_sup_business_group_id => g_crrnt_chain(i).business_group_id
        ,p_sup_person_id => g_crrnt_chain(i).person_id
        ,p_sup_assignment_id => g_crrnt_chain(i).assignment_id
        ,p_sup_asg_status_id => g_crrnt_chain(i).asg_status_id
        ,p_sup_level => i
        ,p_sup_inv_flag => g_crrnt_chain(i).invalid_flag
        ,p_sub_business_group_id  => g_crrnt_chain(p_level).business_group_id
        ,p_sub_person_id => g_crrnt_chain(p_level).person_id
        ,p_sub_assignment_id => g_crrnt_chain(p_level).assignment_id
        ,p_sub_asg_status_id => g_crrnt_chain(p_level).asg_status_id
        ,p_sub_primary_asg_flag => 'Y'
        ,p_sub_level => p_level
        ,p_sub_relative_level => p_level - i
        ,p_sub_inv_flag => g_crrnt_chain(p_level).invalid_flag
        ,p_effective_start_date => g_crrnt_chain_start_date
        ,p_effective_end_date => p_end_date
        ,p_orphan_flag => g_crrnt_chain_orphan_flag
        ,p_sub_leaf_flag => g_crrnt_chain(p_level).leaf_node);

  END LOOP;

END insert_chain;

/******************************************************************************/
/* End dates chain for person                                                 */
/******************************************************************************/
PROCEDURE end_date_chain( p_person_id      IN NUMBER,
                          p_end_date       IN DATE) IS

BEGIN

  g_chain_transactions := g_chain_transactions + 1;

  UPDATE hri_cs_suph
  SET effective_end_date = p_end_date
  WHERE sub_person_id = p_person_id
  AND p_end_date BETWEEN effective_start_date AND effective_end_date;

END end_date_chain;

/******************************************************************************/
/* Processes incremental changes to the table for the current chain           */
/*                                                                            */
/* This procedure takes the current chain and change date and picks out the   */
/* existing date tracked chain in the table in which the change date falls.   */
/*                                                                            */
/*                                                                            */
/*                                                                            */
/******************************************************************************/
PROCEDURE process_chain( p_level     IN NUMBER,
                         p_end_date  IN DATE) IS

/* Bug 2670477 - join by person id */
  CURSOR existing_chain_csr IS
  SELECT
   effective_start_date
  ,effective_end_date
  FROM hri_cs_suph
  WHERE sub_person_id = g_crrnt_chain(p_level).person_id
  AND g_crrnt_chain_start_date
    BETWEEN effective_start_date AND effective_end_date;

/* Bug 2670477 - join by person id */
  CURSOR next_chain_start_csr IS
  SELECT
    MIN(effective_start_date)   next_chain_start_date
  FROM hri_cs_suph
  WHERE sub_person_id = g_crrnt_chain(p_level).person_id
  AND effective_start_date > g_crrnt_chain_start_date;

  l_existing_chain_start      DATE;
  l_existing_chain_end        DATE;
  l_next_chain_start          DATE;
  l_chain_end_date            DATE;

BEGIN

/* Get information about existing chain */
  OPEN existing_chain_csr;
  FETCH existing_chain_csr INTO l_existing_chain_start, l_existing_chain_end;
  CLOSE existing_chain_csr;

/* If a chain exists, take the earlier of the current and existing end dates */
  IF (l_existing_chain_end IS NULL) THEN

  /* If there is no existing chain, check for a future dated one */
    OPEN next_chain_start_csr;
    FETCH next_chain_start_csr INTO l_next_chain_start;
    CLOSE next_chain_start_csr;

  /* If there's a future dated chain, take the earlier of the current end */
  /* and one less than the future dated chain start */
    IF (l_next_chain_start IS NULL) THEN
      l_chain_end_date := p_end_date;
    ELSE
      l_chain_end_date := LEAST(l_next_chain_start - 1, p_end_date);
    END IF;

  ELSE

    l_chain_end_date := LEAST(l_existing_chain_end, p_end_date);

  END IF;

/* End date existing chain if it is earlier then the current */
  IF (l_existing_chain_start < g_crrnt_chain_start_date) THEN
    g_chain_transactions := g_chain_transactions + 1;
  /* End date existing chain */
  /* Bug 2670477 - join by person id */
    UPDATE hri_cs_suph
    SET effective_end_date = g_crrnt_chain_start_date - 1
    WHERE sub_person_id =
             g_crrnt_chain(p_level).person_id
    AND effective_start_date = l_existing_chain_start;

/* Delete existing chain if it is the same date as the current */
  ELSIF (l_existing_chain_start = g_crrnt_chain_start_date) THEN
    g_chain_transactions := g_chain_transactions + 1;
  /* Delete existing chain */
  /* Bug 2670477 - join by person id */
    DELETE FROM hri_cs_suph
    WHERE sub_person_id = g_crrnt_chain(p_level).person_id
    AND effective_start_date = l_existing_chain_start;

  END IF;

/* Insert new chain */
  insert_chain(p_level => p_level
              ,p_end_date => l_chain_end_date);

/* Remove any obsolete chain updates */
  BEGIN
    IF (g_final_date_tab(g_crrnt_chain(p_level).person_id) IS NOT NULL) THEN
      g_chain_transactions := g_chain_transactions + 1;
    /* Bug 2670477 - join by person id */
      DELETE FROM hri_cs_suph
      WHERE sub_person_id = g_crrnt_chain(p_level).person_id
      AND effective_start_date > g_final_date_tab(g_crrnt_chain(p_level).person_id);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    null;
  END;

END process_chain;

/******************************************************************************/
/* Returns the end date to use for an assignment                              */
/******************************************************************************/
FUNCTION get_end_date( p_index                   IN NUMBER,
                       p_person_id               IN NUMBER,
                       p_period_of_service_id    IN NUMBER,
                       p_change_date             IN DATE)
             RETURN DATE IS

  CURSOR pos_end_date_csr IS
  SELECT actual_termination_date, final_process_date
  FROM per_periods_of_service
  WHERE period_of_service_id = p_period_of_service_id;

  l_return_date        DATE;
  l_final_process      DATE;
  l_actual_termination DATE;

BEGIN

/* If no end date recorded for assignment, get the termination date */
  IF (p_person_id = g_fetch_psn_id(p_index)) THEN
    l_actual_termination := g_fetch_term_dt(p_index);
    l_final_process      := g_fetch_fprc_dt(p_index);
  ELSE
    OPEN pos_end_date_csr;
    FETCH pos_end_date_csr INTO l_actual_termination, l_final_process;
    CLOSE pos_end_date_csr;
  END IF;

/* If the change date is after the termination date and the event is */
/* not the leaf node termination return the final process date */
  IF (p_change_date > l_actual_termination) THEN
    l_return_date := NVL(l_final_process, g_end_of_time);
/* Otherwise return the actual termination date */
  ELSE
    l_return_date := NVL(l_actual_termination, g_end_of_time);
  END IF;

/* If the termination date is in the future return end of time */
  IF (l_return_date > g_current_date) THEN
    l_return_date := g_end_of_time;
  END IF;

/* Store final process date used */
  g_final_date_tab(p_person_id) := l_final_process;

  RETURN l_return_date;

END get_end_date;

/******************************************************************************/
/* Tests whether the top level supervisor is new                              */
/******************************************************************************/
PROCEDURE test_top_supervisor( p_index        IN NUMBER,
                               p_change_date  IN DATE,
                               p_event_code   IN VARCHAR2) IS

/***********************************************************************/
/* Cursor to find whether top level supervisor is new                  */
/***********************************************************************/
  CURSOR top_manager_new_csr IS
  SELECT 'N'
  FROM per_all_assignments_f asg
  WHERE asg.supervisor_id = g_fetch_sup_id(p_index)
  AND asg.assignment_type = 'E'
  AND asg.primary_flag = 'Y'
  AND p_change_date - 1
         BETWEEN asg.effective_start_date AND asg.effective_end_date;

  l_top_manager_new_flag   VARCHAR2(1);
  l_end_date               DATE;

BEGIN

/* Catch errors accessing the global table in a PL/SQL block */
  BEGIN
  /* Raise an error if there is no record of a check (automatic) or */
  /* if the last check was later than the current change date (explicit) */
    IF (g_top_level_check(g_fetch_sup_id(p_index)) > p_change_date) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  EXCEPTION WHEN OTHERS THEN
  /* Check whether the top manager was previously a supervisor */
    OPEN top_manager_new_csr;
    FETCH top_manager_new_csr INTO l_top_manager_new_flag;
    CLOSE top_manager_new_csr;

  /* Log the check has been done */
    g_top_level_check(g_fetch_sup_id(p_index)) := p_change_date;

  /* If the top level manager is new */
    IF (l_top_manager_new_flag IS NULL) THEN
    /* Get the end date to insert for the new top manager record */
      l_end_date := get_end_date
                (p_index => p_index
                ,p_person_id => g_crrnt_chain(1).person_id
                ,p_period_of_service_id => g_crrnt_chain_top_pos_id
                ,p_change_date => p_change_date);

    /* Top manager is not leaf node because level 2 supervisor is */
    /* non-terminated */
      IF (g_crrnt_chain(1).invalid_flag = 'N') THEN
        g_crrnt_chain(1).leaf_node := 'N';
      END IF;

    /* Insert chain link in historical hierarchy table for new top  */
    /* level manager */
      process_chain(p_level => 1,
                    p_end_date => l_end_date);

    END IF;

  END;

END test_top_supervisor;

/******************************************************************************/
/* Inserts and stores the chain of the current supervisor change person       */
/******************************************************************************/
FUNCTION insert_supv_change( p_index        IN NUMBER,
                             p_change_date  IN DATE,
                             p_event_code   IN VARCHAR2)
                  RETURN PLS_INTEGER IS

/***********************************************************************/
/* Cursor picking all managers above person who has changed supervisor */
/* LEVEL (wrt this cursor) will be 1 for this person                   */
/* Rows are returned with the topmost supervisor first                 */
/***********************************************************************/
  CURSOR new_manager_chain_csr IS
  SELECT
   hier.business_group_id
  ,hier.person_id
  ,hier.assignment_id
  ,hier.assignment_status_type_id   asg_status_id
  ,hier.supervisor_id
  ,hier.period_of_service_id
  ,hier.primary_flag
  ,LEVEL relative_level
  FROM (SELECT
         asg.business_group_id
        ,asg.person_id
        ,asg.assignment_id
        ,asg.assignment_status_type_id
        ,asg.supervisor_id
        ,asg.period_of_service_id
        ,asg.primary_flag
        FROM
         per_all_assignments_f        asg
        WHERE asg.assignment_type = 'E'
        AND asg.primary_flag = 'Y'
        AND p_change_date
          BETWEEN asg.effective_start_date AND asg.effective_end_date) hier
  START WITH hier.assignment_id = g_fetch_asg_id(p_index)
  CONNECT BY hier.person_id = PRIOR hier.supervisor_id
  ORDER BY relative_level desc;

  l_person_level           PLS_INTEGER;
  l_sup_lvl                PLS_INTEGER;

  l_fetch_bgr_id     g_number_tab_type;
  l_fetch_psn_id     g_number_tab_type;
  l_fetch_asg_id     g_number_tab_type;
  l_fetch_ast_id     g_number_tab_type;
  l_fetch_sup_id     g_number_tab_type;
  l_fetch_pos_id     g_number_tab_type;
  l_fetch_prm_flg    g_varchar2_tab_type;
  l_fetch_level      g_number_tab_type;

  l_rows_fetched     PLS_INTEGER;

BEGIN

/* Get the end date */
  g_crrnt_chain_end_date := get_end_date
                  (p_index => p_index
                  ,p_person_id => g_fetch_psn_id(p_index)
                  ,p_period_of_service_id => g_fetch_pos_id(p_index)
                  ,p_change_date => p_change_date);

/* Bulk fetch from cursor without limit as there are never going */
/* to be many levels going up */
  OPEN new_manager_chain_csr;
  FETCH new_manager_chain_csr
    BULK COLLECT INTO
      l_fetch_bgr_id,
      l_fetch_psn_id,
      l_fetch_asg_id,
      l_fetch_ast_id,
      l_fetch_sup_id,
      l_fetch_pos_id,
      l_fetch_prm_flg,
      l_fetch_level;
  l_rows_fetched := new_manager_chain_csr%ROWCOUNT;
  CLOSE new_manager_chain_csr;

/* Loop through the links in the chain */
  FOR i IN 1..l_rows_fetched LOOP

  /* If this is the first row, grab the level as it will be the */
  /* absolute level for the person within the overall hierarchy */
  /* Also note the top level supervisor period of service id    */
    IF (l_person_level IS NULL) THEN
      l_person_level := l_fetch_level(i);
      g_crrnt_chain_top_pos_id := l_fetch_pos_id(i);
    /* If the top level manager has a supervisor fk */
    /* then they are an orphan */
      IF (l_fetch_sup_id(i) IS NOT NULL) THEN
        g_crrnt_chain_orphan_flag := 'Y';
      ELSE
        g_crrnt_chain_orphan_flag := 'N';
      END IF;
    END IF;

  /* Calculate the absolute level for the supervisor within the */
  /* overall hierarchy */
    l_sup_lvl := l_person_level - l_fetch_level(i) + 1;

  /* Store information in the global data structure */
    g_crrnt_chain(l_sup_lvl).business_group_id := l_fetch_bgr_id(i);
    g_crrnt_chain(l_sup_lvl).person_id         := l_fetch_psn_id(i);
    g_crrnt_chain(l_sup_lvl).assignment_id     := l_fetch_asg_id(i);
    g_crrnt_chain(l_sup_lvl).asg_status_id     := l_fetch_ast_id(i);
    g_crrnt_chain(l_sup_lvl).primary_asg_flag  := l_fetch_prm_flg(i);
    g_crrnt_chain(l_sup_lvl).invalid_flag := get_inv_flag_status(l_fetch_ast_id(i));
    g_crrnt_chain(l_sup_lvl).leaf_node := null;

  END LOOP;

/* Bug 2521182 (115.12) */
/* If the cursor returned no data, then there is probably a data problem */
  IF (l_person_level IS NULL) THEN
    output('Possible data corruption for person id:  ' ||
           to_char(g_fetch_psn_id(p_index)) ||
           ' on ' || to_char(p_change_date,'YYYY/MM/DD'));
    RETURN -1;
  END IF;

/* Store information about the current chain */
  g_crrnt_chain_owner_lvl := l_person_level;
  g_crrnt_chain_start_date := p_change_date;

/* Bug 2748797 - Check for top level supervisor changes */
/* If the insert is for a non-terminated level 2 supervisor then */
/* potentially the top level supervisor could be new. */
  IF (l_person_level = 2 AND p_event_code <> 'TERM') THEN
    test_top_supervisor(p_index => p_index,
                        p_change_date => p_change_date,
                        p_event_code => p_event_code);
  END IF;

/* If the change owner is non-terminated then default them to a leaf node */
  IF (g_crrnt_chain(g_crrnt_chain_owner_lvl).invalid_flag = 'N') THEN
    g_crrnt_chain(g_crrnt_chain_owner_lvl).leaf_node := 'Y';

  /* If the change owner has a non-terminated supervisor then the supervisor */
  /* is not a leaf node */
    IF (g_crrnt_chain_owner_lvl > 1) THEN
      IF (g_crrnt_chain(g_crrnt_chain_owner_lvl - 1).invalid_flag = 'N') THEN
      /* Update immediate supervisor to non-leaf node */
        null;
      END IF;
    END IF;
  END IF;

/* Return without error */
  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN

  IF new_manager_chain_csr%ISOPEN THEN
    CLOSE new_manager_chain_csr;
  END IF;

/* ORA 01436 - loop in tree walk */
  IF (SQLCODE = -1436) THEN
    output('Loop found in supervisor chain for person id:  ' ||
            to_char(g_fetch_psn_id(p_index)) ||
           ' on ' || to_char(p_change_date,'YYYY/MM/DD'));
    RETURN -1;
  ELSE
/* Some other error */
    RAISE;
  END IF;

END insert_supv_change;

/******************************************************************************/
/* Calls the chain processing procedure for each of the subordinate chains to */
/* process                                                                    */
/******************************************************************************/
PROCEDURE update_sub_chains( p_min_lvl     IN NUMBER,
                             p_max_lvl     IN NUMBER,
                             p_index       IN NUMBER) IS

BEGIN

  FOR v_sub_lvl IN p_min_lvl..p_max_lvl LOOP

    process_chain(p_level => v_sub_lvl,
                  p_end_date => g_crrnt_chain_end_date);

  END LOOP;

END update_sub_chains;

/******************************************************************************/
/* Updates all subordinates of the current supervisor change person           */
/* The cursor tree walk returns rows on a depth first basis. The global chain */
/* is kept updated with the latest information returned. For example, suppose */
/* the supervisor labelled X below changed supervisor. The subordinates of X  */
/* would be returned in the order they are numbered. This means that when 2   */
/* is processed it is guaranteed that the global chain will contain the       */
/* correct information for X and above, and then for 1 and 2.                 */
/*                                                                            */
/*                       X                                                    */
/*                      / \                                                   */
/*                     1   4                                                  */
/*                    / \                                                     */
/*                   2   3                                                    */
/*                                                                            */
/* A breadth first tree walk would return the subordinates of X in the order  */
/* 1 -> 4 -> 2 -> 3. This would mean that when 2 is processed the global      */
/* chain would contain information for X and above, and then for 4 and 2.     */
/* This would be wrong!!!                                                     */
/******************************************************************************/
PROCEDURE update_subordinates( p_index        IN NUMBER,
                               p_change_date  IN DATE,
                               p_event_code   IN VARCHAR2) IS

/* Cursor picks out all subordates of the person who has changed supervisor  */
/* so that the chains of the subordinates can all be updated with the change */
/* This cursor MUST return rows in the default order                         */
  CURSOR subordinates_csr IS
  SELECT
   hier.business_group_id
  ,hier.person_id
  ,hier.assignment_id
  ,hier.assignment_status_type_id  asg_status_id
  ,hier.supervisor_id
  ,hier.period_of_service_id
  ,hier.primary_flag
  ,LEVEL-1+g_crrnt_chain_owner_lvl   actual_level
  FROM (SELECT
        asg.business_group_id
       ,asg.person_id
       ,asg.assignment_id
       ,asg.assignment_status_type_id
       ,asg.period_of_service_id
       ,asg.supervisor_id
       ,asg.primary_flag
       FROM
        per_all_assignments_f        asg
       WHERE asg.assignment_type = 'E'
       AND asg.primary_flag = 'Y'
       AND p_change_date
         BETWEEN asg.effective_start_date AND asg.effective_end_date) hier
  WHERE hier.person_id <> g_fetch_psn_id(p_index)
  START WITH hier.person_id = g_fetch_psn_id(p_index)
  CONNECT BY hier.supervisor_id = PRIOR hier.person_id;
/******************************/
/* DO NOT ADD ORDER BY CLAUSE */
/******************************/

  l_end_date         DATE;
  l_last_sub_lvl     PLS_INTEGER := 0;

  l_fetch_bgr_id     g_number_tab_type;
  l_fetch_psn_id     g_number_tab_type;
  l_fetch_asg_id     g_number_tab_type;
  l_fetch_ast_id     g_number_tab_type;
  l_fetch_sup_id     g_number_tab_type;
  l_fetch_pos_id     g_number_tab_type;
  l_fetch_prm_flg    g_varchar2_tab_type;
  l_fetch_level      g_number_tab_type;

  l_rows_fetched     PLS_INTEGER := g_chunk_size;
  l_exit_sub_loop    BOOLEAN := FALSE;

BEGIN

  OPEN subordinates_csr;

  <<subordinates_loop>>
  LOOP

    FETCH subordinates_csr
    BULK COLLECT INTO
      l_fetch_bgr_id,
      l_fetch_psn_id,
      l_fetch_asg_id,
      l_fetch_ast_id,
      l_fetch_sup_id,
      l_fetch_pos_id,
      l_fetch_prm_flg,
      l_fetch_level
    LIMIT g_chunk_size;
    -- check to see if the last row has been fetched
    IF subordinates_csr%NOTFOUND THEN
      -- last row fetched, set exit loop flag
      l_exit_sub_loop := TRUE;
      -- do we have any rows to process?
      l_rows_fetched := MOD(subordinates_csr%ROWCOUNT,g_chunk_size);
      -- note: if l_rows_fetched > 0 then more rows are required to be
      -- processed and the l_rows_fetched will contain the exact number of
      -- rows left to process
      IF l_rows_fetched = 0 THEN
        -- no more rows to process so exit loop
        EXIT subordinates_loop;
      END IF;
    END IF;

    FOR i IN 1..l_rows_fetched LOOP

      BEGIN

      /* If there is no data in the global, NO_DATA_FOUND will be raised.   */
      /* If the data in the global is an earlier date the same exception is */
      /* raised. Otherwise the processing has already been done.            */
        IF (p_change_date = g_assgnmnts_prcssd(l_fetch_asg_id(i))) THEN
          null;
        ELSE
          RAISE NO_DATA_FOUND;
        END IF;

      /* If the subordinate is for the current chain, active and their supervisor */
      /* is active, mark the supervisor as a non-leaf */
        IF (g_crrnt_chain(l_fetch_level(i) - 1).person_id = l_fetch_sup_id(i) AND
            get_inv_flag_status(l_fetch_ast_id(i)) = 'N' AND
            g_crrnt_chain(l_fetch_level(i) - 1).invalid_flag = 'N') THEN
          g_crrnt_chain(l_fetch_level(i) - 1).leaf_node := 'N';
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

      /* Store information about assignment to be processed */
        g_assgnmnts_prcssd(l_fetch_asg_id(i)) := p_change_date;

      /* If the end of a chain is reached then insert it */
        IF (l_fetch_level(i) <= l_last_sub_lvl) THEN

        /* Insert the changed subordinate chains */
          update_sub_chains(p_min_lvl  => l_fetch_level(i),
                            p_max_lvl  => l_last_sub_lvl,
                            p_index    => p_index);

        END IF;  -- End of chain reached

      /* Get the end date */
        l_end_date := get_end_date
                      (p_index => p_index
                      ,p_person_id => l_fetch_psn_id(i)
                      ,p_period_of_service_id => l_fetch_pos_id(i)
                      ,p_change_date => p_change_date);

        g_crrnt_chain(l_fetch_level(i)).business_group_id := l_fetch_bgr_id(i);
        g_crrnt_chain(l_fetch_level(i)).person_id         := l_fetch_psn_id(i);
        g_crrnt_chain(l_fetch_level(i)).assignment_id     := l_fetch_asg_id(i);
        g_crrnt_chain(l_fetch_level(i)).asg_status_id     := l_fetch_ast_id(i);
        g_crrnt_chain(l_fetch_level(i)).primary_asg_flag  := l_fetch_prm_flg(i);
        g_crrnt_chain(l_fetch_level(i)).end_date          := l_end_date;
        g_crrnt_chain(l_fetch_level(i)).invalid_flag :=
                                          get_inv_flag_status(l_fetch_ast_id(i));

      /* If the subordinate is valid then mark them a leaf node by default */
        IF (g_crrnt_chain(l_fetch_level(i)).invalid_flag = 'N') THEN
          g_crrnt_chain(l_fetch_level(i)).leaf_node := 'Y';

        /* In addition, if their supervisor is valid then mark their */
        /* supervisor as not a leaf node */
          IF (g_crrnt_chain(l_fetch_level(i) - 1).invalid_flag = 'N') THEN
            g_crrnt_chain(l_fetch_level(i) - 1).leaf_node := 'N';
          END IF;
        ELSE
          g_crrnt_chain(l_fetch_level(i)).leaf_node := null;
        END IF;

        l_last_sub_lvl := l_fetch_level(i);

      END;

    /* Commit every so often */
      IF (g_chain_transactions > (g_chain_chunk_size)) THEN
        commit;
        g_chain_transactions := 0;
      END IF;

    END LOOP;

    -- exit loop if required
    IF l_exit_sub_loop THEN
      EXIT subordinates_loop;
    END IF;

  END LOOP;

  CLOSE subordinates_csr;

  IF (l_last_sub_lvl > 0) THEN

  /* Insert the changed subordinate chains */
    update_sub_chains(p_min_lvl  => g_crrnt_chain_owner_lvl+1,
                      p_max_lvl  => l_last_sub_lvl,
                      p_index    => p_index);

  END IF;  -- End of chain reached

EXCEPTION
  WHEN OTHERS THEN

  IF subordinates_csr%ISOPEN THEN
    CLOSE subordinates_csr;
  END IF;

/* ORA 01436 - loop in tree walk */
  IF (SQLCODE = -1436) THEN
    output('Loop found in supervisor chain for person id:  ' ||
            to_char(g_crrnt_chain(g_crrnt_chain_owner_lvl).person_id) ||
           ' on ' || to_char(p_change_date,'DD-MON-YYYY'));
  ELSE
/* Some other error */
    RAISE;
  END IF;

END update_subordinates;

/******************************************************************************/
/* Updates stored leaf node information                                       */
/******************************************************************************/
PROCEDURE update_leaf_node_change( p_person_id        IN NUMBER,
                                   p_change_date      IN DATE,
                                   p_from_leaf_flag   IN VARCHAR2,
                                   p_to_leaf_flag     IN VARCHAR2) IS

/* Selects single link in chain for a non-terminated supervisor on a date */
  CURSOR chain_csr IS
  SELECT *
  FROM hri_cs_suph
  WHERE sub_person_id = p_person_id
  AND sup_person_id = p_person_id
  AND sub_invalid_flag_code = 'N'
  AND sub_leaf_flag_code = p_from_leaf_flag
  AND p_change_date BETWEEN effective_start_date AND effective_end_date;

BEGIN

  FOR chain_rec IN chain_csr LOOP

  /* If the start dates match then update the existing chain */
    IF (chain_rec.effective_start_date = p_change_date) THEN

      g_chain_transactions := g_chain_transactions + 1;

    /* Update all links in chain at once */
      UPDATE hri_cs_suph
      SET sub_leaf_flag_code = p_to_leaf_flag
      WHERE sub_person_id = p_person_id
      AND effective_start_date = p_change_date
      AND sub_invalid_flag_code = 'N';

    /* Otherwise end date existing chain and insert new one */
      ELSE

        g_chain_transactions := g_chain_transactions + 2;

      /* Insert new chain */
        INSERT INTO hri_cs_suph
          (sup_business_group_id
          ,sup_person_id
          ,sup_assignment_id
          ,sup_assignment_status_type_id
          ,sup_level
          ,sup_invalid_flag_code
          ,sub_business_group_id
          ,sub_person_id
          ,sub_assignment_id
          ,sub_assignment_status_type_id
          ,sub_primary_asg_flag_code
          ,sub_level
          ,sub_relative_level
          ,sub_invalid_flag_code
          ,orphan_flag_code
          ,sub_leaf_flag_code
          ,effective_start_date
          ,effective_end_date)
          SELECT
           sup_business_group_id
          ,sup_person_id
          ,sup_assignment_id
          ,sup_assignment_status_type_id
          ,sup_level
          ,sup_invalid_flag_code
          ,sub_business_group_id
          ,sub_person_id
          ,sub_assignment_id
          ,sub_assignment_status_type_id
          ,sub_primary_asg_flag_code
          ,sub_level
          ,sub_relative_level
          ,sub_invalid_flag_code
          ,orphan_flag_code
          ,p_to_leaf_flag
          ,p_change_date
          ,chain_rec.effective_end_date
          FROM hri_cs_suph
          WHERE sub_person_id = p_person_id
          AND effective_start_date = chain_rec.effective_start_date
          AND sub_invalid_flag_code = 'N';

      /* End date existing chain */
        UPDATE hri_cs_suph
        SET effective_end_date = p_change_date - 1
        WHERE sub_person_id = p_person_id
        AND effective_start_date = chain_rec.effective_start_date
        AND sub_invalid_flag_code = 'N';

      END IF;

    END LOOP;

END update_leaf_node_change;


/******************************************************************************/
/* Loops through supervisor changes                                           */
/******************************************************************************/
PROCEDURE collect_data( p_collect_from    IN DATE,
                        p_collect_to      IN DATE) IS

/* Pick out all primary assignment supervisor changes */
  CURSOR supervisor_changes_csr IS
  SELECT
   asg.assignment_id                assignment_id
  ,asg.effective_start_date         asg_start
  ,asg.effective_end_date           asg_end
  ,asg.business_group_id            business_group_id
  ,asg.person_id                    person_id
  ,NVL(asg.supervisor_id , -1)      supervisor_id
  ,DECODE(prev_asg.assignment_id,
            to_number(null), to_number(null),
          NVL(prev_asg.supervisor_id, -1))  prev_supervisor_id
  ,asg.assignment_status_type_id    assignment_status_type_id
  ,pos.period_of_service_id         period_of_service_id
  ,asg.effective_start_date         change_date
  ,DECODE(asg.effective_start_date,
            pos.date_start, 'HIRE',
          'CHNG')                   event_code
  ,pos.actual_termination_date      termination_date
  ,pos.final_process_date           final_process_date
  FROM
   per_all_assignments_f        asg
  ,per_periods_of_service       pos
  ,per_all_assignments_f        prev_asg
  WHERE asg.primary_flag = 'Y'
  AND prev_asg.primary_flag (+) = 'Y'
  AND asg.assignment_type  = 'E'
  AND prev_asg.assignment_type (+) = 'E'
  AND asg.period_of_service_id = pos.period_of_service_id (+)
  AND prev_asg.person_id (+) = asg.person_id
  AND prev_asg.effective_end_date (+) = asg.effective_start_date - 1
/* All non-terminated assignment supervisor changes within date range */
  AND ((asg.effective_start_date BETWEEN p_collect_from AND p_collect_to
        AND NVL(asg.supervisor_id, -1) <> NVL(prev_asg.supervisor_id, -1)
        AND NVL(prev_asg.assignment_id, -1) <> -1
        AND asg.effective_start_date <= NVL(pos.actual_termination_date, g_current_date))
/* All initial hire assignments with a supervisor */
    OR (asg.effective_start_date = pos.date_start
        AND pos.date_start BETWEEN p_collect_from AND p_collect_to
        AND asg.supervisor_id IS NOT NULL))
  UNION ALL
/* All terminations and final processes */
  SELECT /*+ leading(pos) use_hash(pos asg) */
   asg.assignment_id                assignment_id
  ,asg.effective_start_date         asg_start
  ,asg.effective_end_date           asg_end
  ,asg.business_group_id            business_group_id
  ,asg.person_id                    person_id
  ,to_number(null)                  supervisor_id
  ,NVL(asg.supervisor_id , -1)      prev_supervisor_id
  ,asg.assignment_status_type_id    assignment_status_type_id
  ,pos.period_of_service_id         period_of_service_id
  ,pos.actual_termination_date + 1  change_date
  ,'TERM'                           event_code
  ,pos.actual_termination_date      termination_date
  ,pos.final_process_date           final_process_date
  FROM
   per_all_assignments_f        asg
  ,per_periods_of_service       pos
  WHERE asg.effective_end_date = pos.actual_termination_date
  AND (pos.actual_termination_date BETWEEN p_collect_from AND p_collect_to
    OR pos.final_process_date BETWEEN p_collect_from AND p_collect_to)
  AND asg.period_of_service_id = pos.period_of_service_id
  UNION ALL
/* All subordinates of supervisors who have separated (final process) */
/* whose assignments have not been updated with a new supervisor and so */
/* are invalid */
  SELECT /*+ leading(pps) use_hash(pps sub_asg sub_pps) */
   sub_asg.assignment_id                assignment_id
  ,sub_asg.effective_start_date         asg_start
  ,sub_asg.effective_end_date           asg_end
  ,sub_asg.business_group_id            business_group_id
  ,sub_asg.person_id                    person_id
  ,to_number(null)                      supervisor_id
  ,sub_asg.supervisor_id                prev_supervisor_id
  ,sub_asg.assignment_status_type_id    assignment_status_type_id
  ,sub_pps.period_of_service_id         period_of_service_id
  ,pps.final_process_date + 1           change_date
/* Event code ORPH for subordinates orphaned by their supervisor's separation */
  ,'ORPH'                               event_code
  ,sub_pps.actual_termination_date      actual_termination_date
  ,sub_pps.final_process_date           final_process_date
  FROM
   per_all_assignments_f  sub_asg
  ,per_periods_of_service pps
  ,per_periods_of_service sub_pps
  WHERE pps.final_process_date BETWEEN p_collect_from AND p_collect_to
  AND sub_asg.supervisor_id = pps.person_id
  AND sub_asg.period_of_service_id = sub_pps.period_of_service_id
  AND sub_asg.assignment_type = 'E'
  AND sub_asg.primary_flag = 'Y'
  AND pps.final_process_date + 1
    BETWEEN sub_asg.effective_start_date AND sub_asg.effective_end_date
  ORDER BY change_date;

  l_return_code          PLS_INTEGER;
  l_exit_main_loop       BOOLEAN := FALSE;
  l_rows_fetched         PLS_INTEGER := g_chunk_size;
  l_leaf_end_date        DATE;
  l_leaf_flag            VARCHAR2(1);

BEGIN
  -- set the global collection date range
  g_collect_from_date := p_collect_from;
  g_collect_to_date   := p_collect_to;
  -- load TERM assignment statuses
  init_term_per_system_status;
  -- open main cursor
  OPEN supervisor_changes_csr;
  -- enter main loop
  <<main_loop>>
  LOOP
    -- bulk fetch rows limit the fetch to value of g_chunk_size
    FETCH supervisor_changes_csr
    BULK COLLECT INTO
          g_fetch_asg_id,
          g_fetch_strt_dt,
          g_fetch_end_dt,
          g_fetch_bgr_id,
          g_fetch_psn_id,
          g_fetch_sup_id,
          g_fetch_prev_sup_id,
          g_fetch_ast_id,
          g_fetch_pos_id,
          g_fetch_chng_dt,
          g_fetch_evt_code,
          g_fetch_term_dt,
          g_fetch_fprc_dt
    LIMIT g_chunk_size;
    -- check to see if the last row has been fetched
    IF supervisor_changes_csr%NOTFOUND THEN
      -- last row fetched, set exit loop flag
      l_exit_main_loop := TRUE;
      -- do we have any rows to process?
      l_rows_fetched := MOD(supervisor_changes_csr%ROWCOUNT,g_chunk_size);
      -- note: if l_rows_fetched > 0 then more rows are required to be
      -- processed and the l_rows_fetched will contain the exact number of
      -- rows left to process
      IF l_rows_fetched = 0 THEN
        -- no more rows to process so exit loop
        EXIT main_loop;
      END IF;
    END IF;

    -- Loop through supervisor changes
    FOR i IN 1..l_rows_fetched LOOP

/******************************************************************************/
/* Orphans */
/***********/
      IF (g_fetch_evt_code(i) = 'ORPH') THEN
        BEGIN
        /* Process orphan if the assignment hasn't already been */
        /* processed on the orphaning date */
          IF (g_assgnmnts_prcssd(g_fetch_asg_id(i)) = g_fetch_chng_dt(i)) THEN
            null;
          ELSE
            RAISE NO_DATA_FOUND;
          END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        /* Store record of processing */
          g_assgnmnts_prcssd(g_fetch_asg_id(i)) := g_fetch_chng_dt(i);
        /* Calculate new chain for orphan */
          l_return_code := insert_supv_change(p_index => i
                                             ,p_change_date => g_fetch_chng_dt(i)
                                             ,p_event_code => 'ORPH');
        /* If no error encountered then update chains for all their subordinates */
          IF (l_return_code = 0) THEN
          /* Process subordinates for assignment */
            update_subordinates(p_index => i
                               ,p_change_date => g_fetch_chng_dt(i)
                               ,p_event_code => 'ORPH');
          /* Insert chain for assignment */
            process_chain(p_level => g_crrnt_chain_owner_lvl,
                          p_end_date => g_crrnt_chain_end_date);
          END IF;
        END;

/******************************************************************************/
/* Hires */
/*********/
      ELSIF (g_fetch_evt_code(i) = 'HIRE') THEN
        BEGIN
        /* Process hire if the assignment hasn't already been */
        /* processed on the hire date */
          IF (g_assgnmnts_prcssd(g_fetch_asg_id(i)) = g_fetch_chng_dt(i)) THEN
            null;
          ELSE
            RAISE NO_DATA_FOUND;
          END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        /* Store record of processing hire */
          g_assgnmnts_prcssd(g_fetch_asg_id(i)) := g_fetch_chng_dt(i);
        /* Process chain for new hire */
          l_return_code := insert_supv_change(p_index => i
                                             ,p_change_date => g_fetch_chng_dt(i)
                                             ,p_event_code => 'HIRE');
        /* Skip processing if an error is encountered */
          IF (l_return_code = 0) THEN
          /* Test whether the new hire is a leaf node */
            g_crrnt_chain(g_crrnt_chain_owner_lvl).leaf_node
                          := is_a_leaf_node(p_person_id => g_fetch_psn_id(i),
                                            p_on_date   => g_fetch_chng_dt(i));
          /* Update new hire's manager to be a non-leaf node */
          /* if they weren't before */
            update_leaf_node_change(p_person_id => g_fetch_sup_id(i),
                                    p_change_date => g_fetch_chng_dt(i),
                                    p_from_leaf_flag => 'Y',
                                    p_to_leaf_flag => 'N');
          /* Process subordinates for assignment */
            update_subordinates(p_index => i
                               ,p_change_date => g_fetch_chng_dt(i)
                               ,p_event_code => 'HIRE');
          /* Insert chain for new hire */
            process_chain(p_level => g_crrnt_chain_owner_lvl,
                          p_end_date => g_crrnt_chain_end_date);
          END IF;
        END;

/******************************************************************************/
/* Non-terminated Supervisor change */
/************************************/
      ELSIF (g_fetch_evt_code(i) = 'CHNG') THEN
        BEGIN
        /* Process the change if the assignment hasn't already */
        /* been processed on the change date */
          IF (g_assgnmnts_prcssd(g_fetch_asg_id(i)) = g_fetch_strt_dt(i)) THEN
          /* Is the previous manager of the person still supervising? */
            l_leaf_flag := is_a_leaf_node
                             (p_person_id => g_fetch_prev_sup_id(i),
                              p_on_date   => g_fetch_strt_dt(i));
          /* If not then update chain */
            IF (l_leaf_flag = 'Y') THEN
              update_leaf_node_change(p_person_id => g_fetch_prev_sup_id(i),
                                      p_change_date => g_fetch_strt_dt(i),
                                      p_from_leaf_flag => 'N',
                                      p_to_leaf_flag => 'Y');
            END IF;
          ELSE
            RAISE NO_DATA_FOUND;
          END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        /* Record processing being done for assignment */
          g_assgnmnts_prcssd(g_fetch_asg_id(i)) := g_fetch_strt_dt(i);
        /* Process chain for supervisor change and all subordinates */
          l_return_code := insert_supv_change(p_index => i
                                             ,p_change_date => g_fetch_strt_dt(i)
                                             ,p_event_code => 'CHNG');
        /* If no error encountered then update chains for all their subordinates */
          IF (l_return_code = 0) THEN
          /* Process subordinates for assignment */
            update_subordinates(p_index => i
                               ,p_change_date => g_fetch_strt_dt(i)
                               ,p_event_code => 'CHNG');
          /* Insert chain for assignment */
            process_chain(p_level => g_crrnt_chain_owner_lvl,
                          p_end_date => g_crrnt_chain_end_date);
          /* Update new manager to be a non-leaf node */
          /* if they weren't before */
            update_leaf_node_change(p_person_id => g_fetch_sup_id(i),
                                    p_change_date => g_fetch_strt_dt(i),
                                    p_from_leaf_flag => 'Y',
                                    p_to_leaf_flag => 'N');
          END IF;
        /* Is the previous manager of the person still supervising? */
          IF (g_fetch_prev_sup_id(i) > 0) THEN
            l_leaf_flag := is_a_leaf_node
                             (p_person_id => g_fetch_prev_sup_id(i),
                              p_on_date   => g_fetch_strt_dt(i));
          /* If not then update chain */
            IF (l_leaf_flag = 'Y') THEN
              update_leaf_node_change(p_person_id => g_fetch_prev_sup_id(i),
                                      p_change_date => g_fetch_strt_dt(i),
                                      p_from_leaf_flag => 'N',
                                      p_to_leaf_flag => 'Y');
            END IF;
          END IF;
        END;

      ELSE  -- event code 'TERM'
/******************************************************************************/
/* Terminations */
/****************/
        IF (g_fetch_term_dt(i) >= p_collect_from AND
            g_fetch_term_dt(i) <= p_collect_to) THEN
          BEGIN
          /* If the termination has been processed before */
          /* then don't process the termination */
            IF (g_assgnmnts_prcssd(g_fetch_asg_id(i)) = g_fetch_chng_dt(i)) THEN
              null;
            ELSE
              RAISE NO_DATA_FOUND;
            END IF;
          EXCEPTION WHEN NO_DATA_FOUND THEN
          /* Store record of processing */
            g_assgnmnts_prcssd(g_fetch_asg_id(i)) := g_fetch_chng_dt(i);
          /* If the termination occurs before the final process extra work required */
            IF (g_fetch_term_dt(i) <> g_fetch_fprc_dt(i) OR
                g_fetch_fprc_dt(i) IS NULL) THEN
            /* Is the terminated supervisor still supervising? */
              l_leaf_flag := is_a_leaf_node
                               (p_person_id => g_fetch_psn_id(i),
                                p_on_date   => g_fetch_term_dt(i) + 1);
            /* If the terminated supervisor is still supervising, update their chain */
            /* and those of all their subordinates */
              IF (l_leaf_flag = 'N') THEN
              /* Calculate new chain for terminated supervisor */
                l_return_code := insert_supv_change(p_index => i
                                                   ,p_change_date => g_fetch_term_dt(i) + 1
                                                   ,p_event_code => 'TERM');
              /* If no error encountered then update chains for all their subordinates */
                IF (l_return_code = 0) THEN
                /* Process subordinates for assignment */
                  update_subordinates(p_index => i
                                     ,p_change_date => g_fetch_term_dt(i) + 1
                                     ,p_event_code => 'TERM');
                /* Insert chain for assignment */
                  process_chain(p_level => g_crrnt_chain_owner_lvl,
                                p_end_date => g_crrnt_chain_end_date);
                END IF;
            /* otherwise end date the terminated supervisor chain */
              ELSE
                end_date_chain(p_person_id => g_fetch_psn_id(i),
                               p_end_date => g_fetch_term_dt(i));
              END IF;
            END IF;  -- Termination before final process
          /* Is the manager of the terminated supervisor still supervising? */
            l_leaf_flag := is_a_leaf_node
                             (p_person_id => g_fetch_prev_sup_id(i),
                              p_on_date   => g_fetch_term_dt(i) + 1);
          /* If not then update chain */
            IF (l_leaf_flag = 'Y') THEN
              update_leaf_node_change(p_person_id => g_fetch_prev_sup_id(i),
                                      p_change_date => g_fetch_term_dt(i) + 1,
                                      p_from_leaf_flag => 'N',
                                      p_to_leaf_flag => 'Y');
            END IF;
          END;
        END IF;

/******************************************************************************/
/* Final process */
/*****************/
        IF (g_fetch_fprc_dt(i) >= p_collect_from AND
            g_fetch_fprc_dt(i) <= p_collect_to AND
            g_fetch_term_dt(i) = g_fetch_end_dt(i)) THEN
        /* End date chain */
          end_date_chain(p_person_id => g_fetch_psn_id(i),
                         p_end_date => g_fetch_fprc_dt(i));
        END IF;

/******************************************************************************/

      END IF; -- Event codes

    END LOOP;
    -- exit loop if required
    IF l_exit_main_loop THEN
      EXIT main_loop;
    END IF;
  /* Commit every so often */
    IF (g_chain_transactions > (g_chain_chunk_size)) THEN
      commit;
      g_chain_transactions := 0;
    END IF;
  END LOOP;

  CLOSE supervisor_changes_csr;

EXCEPTION
  WHEN OTHERS THEN
    -- unexpected error has occurred so close down
    -- main bulk cursor if it is open
    IF supervisor_changes_csr%ISOPEN THEN
      CLOSE supervisor_changes_csr;
    END IF;
    -- re-raise error
    RAISE;
END collect_data;

/******************************************************************************/
/* Main entry point to reload the historical supervisor hierarchy table       */
/******************************************************************************/
PROCEDURE load_managers( p_start_date    IN DATE,
                         p_end_date      IN DATE ) IS

  l_sql_stmt      VARCHAR2(2000);
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);
  l_schema        VARCHAR2(400);

BEGIN

/* Time at start */
  output('PL/SQL Start:   ' || to_char(sysdate,'HH24:MI:SS'));

/* Insert new supervisor hierarchy history records */
  collect_data
    (p_collect_from => TRUNC(p_start_date)
    ,p_collect_to   => TRUNC(p_end_date));

  COMMIT;

/* Write timing information to log */
  output('Updated Supervisor History table:  '  ||
         to_char(sysdate,'HH24:MI:SS'));

END load_managers;

/******************************************************************************/
/* Entry point to be called from the concurrent manager                       */
/******************************************************************************/
PROCEDURE load_managers( errbuf          OUT NOCOPY VARCHAR2,
                         retcode         OUT NOCOPY VARCHAR2,
                         p_start_date    IN DATE,
                         p_end_date      IN DATE )

IS

BEGIN

/* Enable output to concurrent request log */
  g_conc_request_flag := TRUE;

/* Call main function */
  load_managers
    (p_start_date => p_start_date
    ,p_end_date   => p_end_date);

EXCEPTION
  WHEN OTHERS THEN
    errbuf := SQLERRM;
    retcode := SQLCODE;

END load_managers;

END hri_opl_suph_hst_inc;

/
