--------------------------------------------------------
--  DDL for Package Body HRI_OPL_WMV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_WMV" AS
/* $Header: hriowmv.pkb 120.0 2005/05/29 06:56:21 appldev noship $ */

/* Simple table types */
TYPE g_date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_number_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/* PL/SQL table of tables representing database table */
  g_fte_value_tab               g_number_tab_type;
  g_head_value_tab              g_number_tab_type;
  g_start_date_tab              g_date_tab_type;
  g_asg_id_tab                  g_number_tab_type;
  g_bgr_id_tab                  g_number_tab_type;
  g_psn_id_tab                  g_number_tab_type;
  g_ast_id_tab                  g_number_tab_type;
  g_per_sys_stat_tab            g_varchar2_tab_type;
  g_pay_sys_stat_tab            g_varchar2_tab_type;
  g_pos_id_tab                  g_number_tab_type;
  g_primary_flag_tab            g_varchar2_tab_type;
  g_last_chng_tab               g_date_tab_type;
  g_final_proc_tab              g_date_tab_type;

/* Null tables - to use in initialization */
  g_null_number_tab             g_number_tab_type;
  g_null_varchar2_tab           g_varchar2_tab_type;
  g_null_date_tab               g_date_tab_type;

/* Global variables representing parameters passed */
  g_collect_from_date      DATE;
  g_collect_to_date        DATE;
  g_collect_fte            VARCHAR2(5);
  g_collect_head           VARCHAR2(5);
  g_full_refresh           VARCHAR2(5);

/* Global end of time date */
  g_end_of_time            DATE := hr_general.end_of_time;

/* Stores number of rows inserted into the PL/SQL global table structure */
  g_rows_inserted          PLS_INTEGER;

/******************************************************************************/
/* Inserts row into concurrent program log                                    */
/******************************************************************************/
PROCEDURE output(p_text  VARCHAR2) IS

BEGIN

/* Write to the concurrent request log */
   fnd_file.put_line(fnd_file.log, p_text);

END output;

/******************************************************************************/
/* Initializes global table                                                   */
/******************************************************************************/
PROCEDURE init_global_table IS

BEGIN

/* Assign the corresponding null table to each of the global tables */
  g_fte_value_tab      := g_null_number_tab;
  g_head_value_tab     := g_null_number_tab;
  g_start_date_tab     := g_null_date_tab;
  g_asg_id_tab         := g_null_number_tab;
  g_bgr_id_tab         := g_null_number_tab;
  g_psn_id_tab         := g_null_number_tab;
  g_ast_id_tab         := g_null_number_tab;
  g_per_sys_stat_tab   := g_null_varchar2_tab;
  g_pay_sys_stat_tab   := g_null_varchar2_tab;
  g_pos_id_tab         := g_null_number_tab;
  g_primary_flag_tab   := g_null_varchar2_tab;
  g_last_chng_tab      := g_null_date_tab;

END init_global_table;

/******************************************************************************/
/* Sets up global list of parameters                                          */
/******************************************************************************/
PROCEDURE get_parameters( p_payroll_action_id       IN NUMBER ) IS

BEGIN

/* If parameters haven't already been set, then set them */
  IF (g_collect_from_date IS NULL) THEN

    SELECT
     ppa.start_date
    ,ppa.effective_date
    ,SUBSTR(ppa.legislative_parameters,1,1)
    ,SUBSTR(ppa.legislative_parameters,3,1)
    ,SUBSTR(ppa.legislative_parameters,5,1)
    INTO
     g_collect_from_date
    ,g_collect_to_date
    ,g_full_refresh
    ,g_collect_fte
    ,g_collect_head
    FROM pay_payroll_actions   ppa
    WHERE payroll_action_id = p_payroll_action_id;

  END IF;

END get_parameters;

/******************************************************************************/
/* Truncates the HRI_MB_WMV table if a full refresh has been selected         */
/* Checks that the seeded budget measurement type formulae are compiled       */
/* Returns list of people to be processed                                     */
/******************************************************************************/
PROCEDURE range_cursor( pactid         IN NUMBER,
                        sqlstr         OUT NOCOPY VARCHAR2) IS

  l_sql_stmt         VARCHAR2(500);
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);

BEGIN

/* Record the process start */
  hri_bpl_conc_log.record_process_start('HRI_MB_WMV');

/* Set up the parameters */
  get_parameters( p_payroll_action_id => pactid );

/* Feedback parameters selected */
  output('Parameters selected:');
  output('  Full Refresh:     ' || g_full_refresh);
  output('  Collect HEAD:     ' || g_collect_head);
  output('  Collect FTE:      ' || g_collect_fte);

/* Raise a ff compile error if either of the seeded ffs to be used are not */
/* compiled */
  IF (g_collect_fte = 'Y') THEN
    hri_bpl_abv.check_ff_name_compiled( p_formula_name => 'TEMPLATE_FTE' );
  END IF;

  IF (g_collect_head = 'Y') THEN
    hri_bpl_abv.check_ff_name_compiled( p_formula_name => 'TEMPLATE_HEAD' );
  END IF;

/************************/
/* FULL REFRESH SECTION */
/************************/
/* Truncate the table if a full refresh is selected */
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN

  /* If it's a full refresh */
    IF (g_full_refresh = 'Y') THEN

    /* Truncate the table */
      l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_WMV';
      EXECUTE IMMEDIATE(l_sql_stmt);

    /* Select all people with employee assignments in the collection range */
      sqlstr :=
        'SELECT DISTINCT
          asg.person_id
         FROM
          per_all_assignments_f    asg
         ,pay_payroll_actions      ppa
         WHERE ppa.payroll_action_id = :payroll_action_id
         AND asg.assignment_type = ''E''
         AND (ppa.start_date
                BETWEEN asg.effective_start_date AND asg.effective_end_date
           OR asg.effective_start_date
                BETWEEN ppa.start_date AND ppa.effective_date)
         ORDER BY asg.person_id';

    ELSE

/*******************************/
/* INCREMENTAL REFRESH SECTION */
/*******************************/
    /* Select all people with changes to employee assignments or ABVs in the */
    /* collection range */
      sqlstr :=
        'SELECT DISTINCT
          asg.person_id
         FROM
          per_all_assignments_f    asg
         ,pay_payroll_actions      ppa
         WHERE ppa.payroll_action_id = :payroll_action_id
         AND asg.assignment_type = ''E''
         AND (asg.effective_start_date
                BETWEEN ppa.start_date AND ppa.effective_date
           OR asg.effective_end_date
                BETWEEN ppa.start_date AND ppa.effective_date
           OR EXISTS (SELECT null FROM per_assignment_budget_values_f  abv
                      WHERE abv.assignment_id = asg.assignment_id
                      AND (abv.effective_start_date
                             BETWEEN ppa.start_date AND ppa.effective_date
                        OR abv.effective_end_date
                             BETWEEN ppa.start_date AND ppa.effective_date)))
         ORDER BY asg.person_id';

    END IF;

  END IF;

END range_cursor;

/******************************************************************************/
/* Returns list of people to be processed                                     */
/******************************************************************************/
PROCEDURE action_creation( pactid      IN NUMBER,
                           stperson    IN NUMBER,
                           endperson   IN NUMBER,
                           chunk       IN NUMBER) IS

/* Pick out assignments for people in range for incremental refresh */
/* all employee assignments which either have been updated or had an ABV */
/* updated within the collection range */
  CURSOR incr_action_csr IS
  SELECT
   pay_assignment_actions_s.nextval   next_seq
  ,assignment_id                      assignment_id
  FROM
   (SELECT DISTINCT
     asg.assignment_id                  assignment_id
    FROM
     per_all_assignments_f        asg
    WHERE asg.assignment_type = 'E'
    AND asg.person_id BETWEEN stperson AND endperson
    AND (asg.effective_start_date
           BETWEEN g_collect_from_date AND g_collect_to_date
      OR asg.effective_end_date
           BETWEEN g_collect_from_date AND g_collect_to_date
      OR EXISTS (SELECT null FROM per_assignment_budget_values_f  abv
                 WHERE abv.assignment_id = asg.assignment_id
                 AND (abv.effective_start_date
                        BETWEEN g_collect_from_date AND g_collect_to_date
                   OR abv.effective_end_date
                        BETWEEN g_collect_from_date AND g_collect_to_date))));

BEGIN

  get_parameters( p_payroll_action_id => pactid );

/************************/
/* FULL REFRESH SECTION */
/************************/
  IF (g_full_refresh = 'Y') THEN

    INSERT INTO pay_assignment_actions
      (assignment_action_id,
       assignment_id,
       payroll_action_id,
       action_status,
       chunk_number,
       action_sequence,
       pre_payment_id,
       object_version_number,
       tax_unit_id,
       source_action_id)
      SELECT
       pay_assignment_actions_s.nextval
      ,assignment_id
      ,pactid
      ,'U'
      ,chunk
      ,pay_assignment_actions_s.nextval
      ,to_number(null)
      ,1
      ,to_number(null)
      ,to_number(null)
      FROM
/* Pick out assignments for people in range for full refresh */
/* all employee assignments which exist at any point in the collection range */
       (SELECT DISTINCT
         asg.assignment_id                  assignment_id
        FROM
         per_all_assignments_f        asg
        WHERE asg.assignment_type = 'E'
        AND asg.person_id BETWEEN stperson AND endperson
        AND (g_collect_from_date
               BETWEEN asg.effective_start_date AND asg.effective_end_date
          OR asg.effective_start_date
               BETWEEN g_collect_from_date AND g_collect_to_date));

  ELSE

/*******************************/
/* INCREMENTAL REFRESH SECTION */
/*******************************/
  /* Loop through cursor and insert actions one at a time */
    FOR asg_rec IN incr_action_csr LOOP

      hr_nonrun_asact.insact
        (lockingactid => asg_rec.next_seq
        ,assignid     => asg_rec.assignment_id
        ,pactid       => pactid
        ,chunk        => chunk
        ,greid        => null);

    END LOOP;

  END IF;

END action_creation;

/******************************************************************************/
/* Initialization - sets up global parameters                                 */
/******************************************************************************/
PROCEDURE init_code( p_payroll_action_id      IN NUMBER) IS

  l_test  VARCHAR2(20);

BEGIN

  get_parameters( p_payroll_action_id => p_payroll_action_id );

END init_code;

/******************************************************************************/
/* Inserts row into database table                                            */
/******************************************************************************/
PROCEDURE insert_row( p_fte_value                   IN NUMBER,
                      p_head_value                  IN NUMBER,
                      p_effective_start_date        IN DATE,
                      p_effective_end_date          IN DATE,
                      p_assignment_id               IN NUMBER,
                      p_person_id                   IN NUMBER,
                      p_business_group_id           IN NUMBER,
                      p_asg_stat_type_id            IN NUMBER,
                      p_per_sys_status              IN VARCHAR2,
                      p_pay_sys_status              IN VARCHAR2,
                      p_period_of_service_id        IN NUMBER,
                      p_primary_flag                IN VARCHAR2,
                      p_last_change_date            IN VARCHAR2) IS

BEGIN

/* Inserts row */
  INSERT INTO hri_mb_wmv
    (primary_asg_indicator
    ,asg_indicator
    ,fte
    ,head
    ,effective_start_date
    ,effective_end_date
    ,assignment_id
    ,person_id
    ,business_group_id
    ,assignment_status_type_id
    ,per_system_status_code
    ,pay_system_status_code
    ,period_of_service_id
    ,primary_flag
    ,last_change_date)
      VALUES
        (DECODE(p_primary_flag,'Y',1,0)
        ,1
        ,p_fte_value
        ,p_head_value
        ,p_effective_start_date
        ,p_effective_end_date
        ,p_assignment_id
        ,p_person_id
        ,p_business_group_id
        ,p_asg_stat_type_id
        ,p_per_sys_status
        ,p_pay_sys_status
        ,p_period_of_service_id
        ,p_primary_flag
        ,p_last_change_date);

END insert_row;

/******************************************************************************/
/* Inserts stored rows into empty table - FULL REFRESH ONLY                   */
/******************************************************************************/
PROCEDURE insert_stored_rows IS

  l_index          PLS_INTEGER;
  l_last_fte       NUMBER;
  l_last_head      NUMBER;
  l_end_date       DATE;

BEGIN

/* Procedure only called if global table is populated */
  l_index := g_start_date_tab.first;

/* Loop until there are no more rows left */
  WHILE l_index IS NOT NULL LOOP

  /* Get the next end date if it exists */
    IF (g_start_date_tab.next(l_index) IS NOT NULL) THEN
      l_end_date := g_start_date_tab(g_start_date_tab.next(l_index)) - 1;
  /* otherwise use the final process date if that exists */
    ELSIF (g_final_proc_tab(l_index) IS NOT NULL) THEN
      l_end_date := g_final_proc_tab(l_index);
  /* otherwise go with the end of time */
    ELSE
      l_end_date := g_end_of_time;
    END IF;

  /* If the FTE value has changed, store the change */
    IF (g_fte_value_tab(l_index) IS NOT NULL) THEN
    /* If an error has occurred running fast formula, set to null */
      IF (g_fte_value_tab(l_index) = -999) THEN
        l_last_fte := to_number(null);
      ELSE
        l_last_fte := g_fte_value_tab(l_index);
      END IF;
    END IF;

  /* If the HEAD value has changed, store the change */
    IF (g_head_value_tab(l_index) IS NOT NULL) THEN
    /* If an error has occurred running fast formula, set to null */
      IF (g_head_value_tab(l_index) = -999) THEN
        l_last_head := to_number(null);
      ELSE
        l_last_head := g_head_value_tab(l_index);
      END IF;
    END IF;

  /* Call procedure to insert the row */
    insert_row
      (p_fte_value            => l_last_fte
      ,p_head_value           => l_last_head
      ,p_effective_start_date => g_start_date_tab(l_index)
      ,p_effective_end_date   => l_end_date
      ,p_assignment_id        => g_asg_id_tab(l_index)
      ,p_person_id            => g_psn_id_tab(l_index)
      ,p_business_group_id    => g_bgr_id_tab(l_index)
      ,p_asg_stat_type_id     => g_ast_id_tab(l_index)
      ,p_per_sys_status       => g_per_sys_stat_tab(l_index)
      ,p_pay_sys_status       => g_pay_sys_stat_tab(l_index)
      ,p_period_of_service_id => g_pos_id_tab(l_index)
      ,p_primary_flag         => g_primary_flag_tab(l_index)
      ,p_last_change_date     => g_last_chng_tab(l_index));

  /* Get the next index */
    l_index := g_start_date_tab.next(l_index);

  END LOOP;

END insert_stored_rows;

/******************************************************************************/
/* Inserts into or updates table with stored rows - INCREMENTAL REFRESH ONLY  */
/******************************************************************************/
PROCEDURE process_stored_rows IS

/******************************************************************************/
/* The complexity here is due to the incremental updating of the abv table.   */
/* If the first run populated fte values only, and the next run populates     */
/* headcount only, there is no guarantee that the dates or periods on the     */
/* table match the ones stored for inserting. So this procedure stores all    */
/* the logic which marries up periods in the table with the stored periods to */
/* insert.                                                                    */
/*                                                                            */
/* For example, if the following already exists in the table for an           */
/* assignment:                                                                */
/*                                                                            */
/*                     TIME ======>                                           */
/*                                                                            */
/* FTE:      |--- 1 ---|--- 0.6 ---|--- 0.3 ---|                              */
/*                                                                            */
/* and the stored rows are for the following incremental headcount changes:   */
/*                                                                            */
/* HEAD:     |----- 1 -----|---- 0 ----|-- 1 --|                              */
/*                                                                            */
/* then the resulting data in the table after this process has run should be: */
/*                                                                            */
/* FTE:      |    1    |0.6|  0.6  |0.3|  0.3  |                              */
/* HEAD:     |    1    | 1 |   0   | 0 |   1   |                              */
/*                                                                            */
/******************************************************************************/

/* Cursor pulls out existing rows from the table each of which overlaps with */
/* the period for which the collection has taken place */
/* Note that the global table structure is populated in reverse chronological */
/* order */
  CURSOR existing_rows_csr(v_assignment_id  NUMBER,
                           v_start_date     DATE,
                           v_end_date       DATE) IS
  SELECT
   wmv.effective_start_date
  ,wmv.effective_end_date
  ,wmv.fte
  ,wmv.head
  FROM hri_mb_wmv  wmv
  WHERE wmv.assignment_id = v_assignment_id
  AND (v_start_date BETWEEN wmv.effective_start_date AND wmv.effective_end_date
    OR wmv.effective_start_date BETWEEN v_start_date AND v_end_date);
/* DO NOT CHANGE ORDER BY - PROCESSING IS DONE IN DATE ORDER (IMPLICIT) */

/* Variables to hold information from the cursor */
  l_existing_start_date     DATE;
  l_existing_end_date       DATE;
  l_existing_fte            NUMBER;
  l_existing_head           NUMBER;

/* Loop control variables */
  l_next_insert_start       DATE;
  l_infinite_loop_catch     DATE;
  l_index                   PLS_INTEGER;

/* Variables to store calculations */
  l_new_fte                 NUMBER;
  l_new_head                NUMBER;
  l_end_date                DATE;

BEGIN

/**********************************************************************/
/* The following should hold true for the main loop                   */
/*                                                                    */
/* 1) Current existing row overlaps with current row to insert        */
/*     \- from cursor  -/                 \-  from cache  -/          */
/*                                                                    */
/* 2) The next insert start date is within the date range of the      */
/*    current row to insert                                           */
/*                                                                    */
/* The following is enforced to prevent the WHILE loop never ending   */
/*                                                                    */
/*  a) l_next_insert_start is strictly increasing                     */
/*                                                                    */
/**********************************************************************/

/* Open the cursor with the end date of the range to insert. This is the */
/* final process date, if one exists, otherwise the end of time date */
  IF (g_final_proc_tab(g_final_proc_tab.last) IS NULL) THEN
    OPEN existing_rows_csr(g_asg_id_tab(g_start_date_tab.first)
                          ,g_start_date_tab(g_start_date_tab.first)
                          ,g_end_of_time);
  ELSE
    OPEN existing_rows_csr(g_asg_id_tab(g_start_date_tab.first)
                          ,g_start_date_tab(g_start_date_tab.first)
                          ,g_final_proc_tab(g_final_proc_tab.last));
  END IF;

/* Initialize first existing row - overlaps with first row to insert by */
/* definition of cursor */
  FETCH existing_rows_csr INTO l_existing_start_date,
                               l_existing_end_date,
                               l_existing_fte,
                               l_existing_head;

/* Initialize the index to the first record */
  l_index := g_start_date_tab.first;

/* Set the next insert start date */
  l_next_insert_start := g_start_date_tab(l_index);

          --  EXISTING:              - - - - - - - - - - -
          --  TO INSERT:                |-------------| - - - - -
          -- PROCESSED TO:              *

/* Loop through rows to insert */
  WHILE l_index IS NOT NULL LOOP

  /* Get the next end date if it exists */
    IF (g_start_date_tab.next(l_index) IS NOT NULL) THEN
      l_end_date := g_start_date_tab(g_start_date_tab.next(l_index)) - 1;
  /* otherwise use the final process date if that exists */
    ELSIF (g_final_proc_tab(l_index) IS NOT NULL) THEN
      l_end_date := g_final_proc_tab(l_index);
  /* otherwise go with the end of time */
    ELSE
      l_end_date := g_end_of_time;
    END IF;

    WHILE (l_next_insert_start <= l_end_date) LOOP

      l_infinite_loop_catch := l_next_insert_start;

    /* If the FTE value has changed, store the change */
      IF (g_fte_value_tab(l_index) IS NOT NULL) THEN
      /* If a fast formula error has occurred, set to null */
        IF (g_fte_value_tab(l_index) = -999) THEN
          l_new_fte := to_number(null);
        ELSE
          l_new_fte := g_fte_value_tab(l_index);
        END IF;
    /* Otherwise, use an existing value if there is one */
      ELSIF (l_existing_fte IS NOT NULL) THEN
        l_new_fte := l_existing_fte;
    /* If there is no existing value, use the last value of l_new_fte */
      END IF;

    /* If the HEAD value has changed, store the change */
      IF (g_head_value_tab(l_index) IS NOT NULL) THEN
      /* If a fast formula error has occurred, set to null */
        IF (g_head_value_tab(l_index) = -999) THEN
          l_new_head := to_number(null);
        ELSE
          l_new_head := g_head_value_tab(l_index);
        END IF;
    /* Otherwise, use an existing value if there is one */
      ELSIF (l_existing_head IS NOT NULL) THEN
        l_new_head := l_existing_head;
    /* If there is no existing value, use the last value of l_new_head */
      END IF;

    /*********************/
    /* Main Body of Loop */
    /*********************/
      IF (l_existing_start_date < g_start_date_tab(l_index)) THEN

        --  EXISTING:          |------------- - - - - -
        --  TO INSERT:                |-------------| - - - - -
        -- PROCESSED TO:       |------*

      /* End date existing row */
        UPDATE hri_mb_wmv
        SET effective_end_date = g_start_date_tab(l_index) - 1
        WHERE assignment_id = g_asg_id_tab(l_index)
        AND effective_start_date = l_existing_start_date;

        --  EXISTING:          |------------- - - - - -
        --  TO INSERT:                |-------------| - - - - -
        -- PROCESSED TO:       |------|*

      /* Insert new row up to the end of the existing row */
        insert_row
          (p_fte_value => l_new_fte
          ,p_head_value => l_new_head
          ,p_effective_start_date => g_start_date_tab(l_index)
          ,p_effective_end_date => LEAST(l_existing_end_date,l_end_date)
          ,p_assignment_id => g_asg_id_tab(l_index)
          ,p_person_id => g_psn_id_tab(l_index)
          ,p_business_group_id => g_bgr_id_tab(l_index)
          ,p_asg_stat_type_id => g_ast_id_tab(l_index)
          ,p_per_sys_status => g_per_sys_stat_tab(l_index)
          ,p_pay_sys_status => g_pay_sys_stat_tab(l_index)
          ,p_period_of_service_id => g_pos_id_tab(l_index)
          ,p_primary_flag => g_primary_flag_tab(l_index)
          ,p_last_change_date => g_last_chng_tab(l_index));

        --  EXISTING:          |------------- - - - - -
        --  TO INSERT:                |-------------| - - - - -
        --  PROCESSED TO:      |------|-----* - - - *
        --                               Processed to the earlier end date

      /* Update the loop variable */
        l_next_insert_start := LEAST(l_existing_end_date,l_end_date) + 1;

      /* If the EXISTING row had the earlier end date, get the next one */
        IF (l_next_insert_start > l_existing_end_date) THEN

        /* Get the next existing row */
          FETCH existing_rows_csr INTO l_existing_start_date,
                                       l_existing_end_date,
                                       l_existing_fte,
                                       l_existing_head;

        ELSE

        /* Move the existing start date to the start of the last row */
        /* inserted */
          l_existing_start_date := g_start_date_tab(l_index);

        END IF;

      ELSIF (l_existing_start_date = g_start_date_tab(l_index)) THEN

        IF (l_existing_end_date <= l_end_date) THEN

          --  EXISTING:                 |------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          -- PROCESSED TO:              *

        /* Update existing row */
          UPDATE hri_mb_wmv
          SET fte  = l_new_fte,
              head = l_new_head,
              assignment_status_type_id = g_ast_id_tab(l_index),
              per_system_status_code = g_per_sys_stat_tab(l_index),
              pay_system_status_code = g_pay_sys_stat_tab(l_index),
              primary_flag = g_primary_flag_tab(l_index),
              last_change_date = g_last_chng_tab(l_index)
          WHERE assignment_id = g_asg_id_tab(l_index)
          AND effective_start_date = l_existing_start_date;

          --  EXISTING:                 |------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |------*

        /* Update the loop variable */
          l_next_insert_start := l_existing_end_date + 1;

        /* Get the next existing row */
          FETCH existing_rows_csr INTO l_existing_start_date,
                                       l_existing_end_date,
                                       l_existing_fte,
                                       l_existing_head;

        ELSIF (l_existing_end_date   > l_end_date) THEN

          --  EXISTING:                 |--------------------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          -- PROCESSED TO:              *

        /* Start date existing row */
          UPDATE hri_mb_wmv
          SET effective_start_date = l_end_date + 1
          WHERE assignment_id = g_asg_id_tab(l_index)
          AND effective_start_date = l_existing_start_date;

        /* Update l_existing_start_date */
          l_existing_start_date := l_end_date + 1;

          --  EXISTING:                               |------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          -- PROCESSED TO:              *

        /* Insert new row up to the beginning of the updated existing row */
          insert_row
            (p_fte_value => l_new_fte
            ,p_head_value => l_new_head
            ,p_effective_start_date => g_start_date_tab(l_index)
            ,p_effective_end_date => l_end_date
            ,p_assignment_id => g_asg_id_tab(l_index)
            ,p_person_id => g_psn_id_tab(l_index)
            ,p_business_group_id => g_bgr_id_tab(l_index)
            ,p_asg_stat_type_id => g_ast_id_tab(l_index)
            ,p_per_sys_status => g_per_sys_stat_tab(l_index)
            ,p_pay_sys_status => g_pay_sys_stat_tab(l_index)
            ,p_period_of_service_id => g_pos_id_tab(l_index)
            ,p_primary_flag => g_primary_flag_tab(l_index)
            ,p_last_change_date => g_last_chng_tab(l_index));

          --  EXISTING:                               |------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |-------------*

        /* Update the loop variable */
          l_next_insert_start := l_end_date + 1;

        END IF;

      ELSIF (l_existing_start_date > g_start_date_tab(l_index)) THEN

      /* Will only happen on the first record if collection period is earlier */
      /* than previous collection periods... */
        IF (l_existing_start_date > l_next_insert_start) THEN

          --  EXISTING:                    |-------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             *

        /* Insert part of new row before existing row */
          insert_row
              (p_fte_value => l_new_fte
              ,p_head_value => l_new_head
              ,p_effective_start_date => l_next_insert_start
              ,p_effective_end_date => l_existing_start_date - 1
              ,p_assignment_id => g_asg_id_tab(l_index)
              ,p_person_id => g_psn_id_tab(l_index)
              ,p_business_group_id => g_bgr_id_tab(l_index)
              ,p_asg_stat_type_id => g_ast_id_tab(l_index)
              ,p_per_sys_status => g_per_sys_stat_tab(l_index)
              ,p_pay_sys_status => g_pay_sys_stat_tab(l_index)
              ,p_period_of_service_id => g_pos_id_tab(l_index)
              ,p_primary_flag => g_primary_flag_tab(l_index)
              ,p_last_change_date => g_last_chng_tab(l_index));

          --  EXISTING:                    |-------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |--*

        END IF;

        IF (l_existing_end_date <= l_end_date) THEN

          --  EXISTING:                    |-------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |--*

        /* Update existing row with latest information */
          UPDATE hri_mb_wmv
          SET fte  = l_new_fte,
              head = l_new_head,
              assignment_status_type_id = g_ast_id_tab(l_index),
              per_system_status_code = g_per_sys_stat_tab(l_index),
              pay_system_status_code = g_pay_sys_stat_tab(l_index),
              primary_flag = g_primary_flag_tab(l_index),
              last_change_date = g_last_chng_tab(l_index)
          WHERE assignment_id = g_asg_id_tab(l_index)
          AND effective_start_date = l_existing_start_date;

          --  EXISTING:                    |-------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |--|-------*

        /* Update the loop variable */
          l_next_insert_start := l_existing_end_date + 1;

        /* Get the next existing row */
          FETCH existing_rows_csr INTO l_existing_start_date,
                                       l_existing_end_date,
                                       l_existing_fte,
                                       l_existing_head;

        ELSIF (l_existing_end_date > l_end_date) THEN

          --  EXISTING:                        |-------------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |------*

        /* Start date existing row */
          UPDATE hri_mb_wmv
          SET effective_start_date = l_end_date + 1
          WHERE assignment_id = g_asg_id_tab(l_index)
          AND effective_start_date = l_existing_start_date;

          --  EXISTING:                               |------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |------*

        /* Insert new row up to the beginning of the updated existing row */
          insert_row
            (p_fte_value => l_new_fte
            ,p_head_value => l_new_head
            ,p_effective_start_date => l_existing_start_date
            ,p_effective_end_date => l_end_date
            ,p_assignment_id => g_asg_id_tab(l_index)
            ,p_person_id => g_psn_id_tab(l_index)
            ,p_business_group_id => g_bgr_id_tab(l_index)
            ,p_asg_stat_type_id => g_ast_id_tab(l_index)
            ,p_per_sys_status => g_per_sys_stat_tab(l_index)
            ,p_pay_sys_status => g_pay_sys_stat_tab(l_index)
            ,p_period_of_service_id => g_pos_id_tab(l_index)
            ,p_primary_flag => g_primary_flag_tab(l_index)
            ,p_last_change_date => g_last_chng_tab(l_index));

        /* Update l_existing_start_date */
          l_existing_start_date := l_end_date + 1;

          --  EXISTING:                               |------| - - - - -
          --  TO INSERT:                |-------------| - - - - -
          --  PROCESSED TO:             |------|------*

        /* Update the loop variable */
          l_next_insert_start := l_end_date + 1;

        END IF;

      ELSIF (l_existing_start_date IS NULL) THEN

      /* No overlap - insert row */
        insert_row
          (p_fte_value => l_new_fte
          ,p_head_value => l_new_head
          ,p_effective_start_date => g_start_date_tab(l_index)
          ,p_effective_end_date => l_end_date
          ,p_assignment_id => g_asg_id_tab(l_index)
          ,p_person_id => g_psn_id_tab(l_index)
          ,p_business_group_id => g_bgr_id_tab(l_index)
          ,p_asg_stat_type_id => g_ast_id_tab(l_index)
          ,p_per_sys_status => g_per_sys_stat_tab(l_index)
          ,p_pay_sys_status => g_pay_sys_stat_tab(l_index)
          ,p_period_of_service_id => g_pos_id_tab(l_index)
          ,p_primary_flag => g_primary_flag_tab(l_index)
          ,p_last_change_date => g_last_chng_tab(l_index));

        l_next_insert_start := l_end_date + 1;

      END IF;

    /* Trap any infinite loops which may occur because of dodgy data or */
    /* mistakes in the code - this should never actually happen... */
      IF (l_next_insert_start = l_infinite_loop_catch) THEN

      /* Put a note in the log */
        output('Trapped for ' || to_char(g_asg_id_tab(l_index)) || ' on ' ||
               to_char(l_infinite_loop_catch,'DD-MM-YYYY'));

      /* This effectively exits the loops */
        l_next_insert_start := to_date(null);

      END IF;

    END LOOP;

  /* Move to next stored row */
    l_index := g_start_date_tab.next(l_index);

  END LOOP;

/* Close cursor */
  CLOSE existing_rows_csr;

/* Tidy up obsolete rows if a termination has occurred */
  IF (g_full_refresh = 'N' AND
      g_final_proc_tab(g_final_proc_tab.last) IS NOT NULL) THEN

  /* For some reason two statements are needed here */
    l_index := g_asg_id_tab.last;

    DELETE FROM hri_mb_wmv
    WHERE assignment_id = g_asg_id_tab(l_index)
    AND effective_start_date > g_final_proc_tab(l_index);

  END IF;

EXCEPTION
  WHEN OTHERS THEN

/* Close the cursor if an exception occurs */
  CLOSE existing_rows_csr;

  raise;

END process_stored_rows;

/******************************************************************************/
/* Calcualates potential ABV changes for an assignment and measurement type   */
/******************************************************************************/
PROCEDURE process_assignment(p_assignment_id    IN NUMBER,
                             p_bmt_code         IN VARCHAR2) IS

  CURSOR ptntl_abv_changes_csr IS
/* All assignment budget values active during the collect period */
  SELECT
   abv.value                         abv_value
  ,GREATEST(asg.effective_start_date,
            abv.effective_start_date,
            g_collect_from_date)     effective_start_date
  ,asg.assignment_id                 assignment_id
  ,asg.business_group_id             business_group_id
  ,asg.person_id                     person_id
  ,asg.assignment_status_type_id     asg_status_type_id
  ,ast.per_system_status             per_system_status
  ,ast.pay_system_status             pay_system_status
  ,asg.period_of_service_id          period_of_service_id
  ,asg.primary_flag                  primary_flag
  ,GREATEST(abv.last_update_date, asg.last_update_date)
                                     last_change_date
  ,pos.final_process_date            final_process_date
  FROM
   per_assignment_budget_values_f   abv
  ,per_all_assignments_f            asg
  ,per_assignment_status_types      ast
  ,per_periods_of_service           pos
  WHERE abv.assignment_id = asg.assignment_id
  AND asg.assignment_id = p_assignment_id
  AND asg.period_of_service_id = pos.period_of_service_id
  AND ast.assignment_status_type_id = asg.assignment_status_type_id
  AND abv.unit = p_bmt_code
  AND asg.assignment_type = 'E'
/* ABV Date Joins - all post hire ABV changes within the collection period */
/* Restrict to ABVs at hire or later */
  AND (abv.effective_start_date >= pos.date_start
    OR pos.date_start
          BETWEEN abv.effective_start_date AND abv.effective_end_date)
/* Only ABVs starting in collection period */
  AND (GREATEST(abv.effective_start_date, pos.date_start)
          BETWEEN g_collect_from_date AND g_collect_to_date
/* or finishing in collection period (incremental refresh only) */
    OR (pos.final_process_date
          BETWEEN g_collect_from_date AND g_collect_to_date
        AND pos.final_process_date
          BETWEEN abv.effective_start_date AND abv.effective_end_date
        AND g_full_refresh = 'N')
/* or active at the start of the collection period (full refresh only) */
    OR (g_collect_from_date
          BETWEEN abv.effective_start_date AND abv.effective_end_date
        AND g_full_refresh = 'Y'))
/* Assignment Date Join - Pin by ABV, hire or period start */
  AND GREATEST(abv.effective_start_date, pos.date_start, g_collect_from_date)
          BETWEEN asg.effective_start_date AND asg.effective_end_date
  UNION ALL
/* All ended assignment budget values with still active assignments */
/* that are not picked up in the next union (i.e. do not coincide with */
/* an assignment change */
  SELECT
   to_number(null)                   abv_value
  ,abv.effective_end_date + 1        effective_start_date
  ,asg.assignment_id                 assignment_id
  ,asg.business_group_id             business_group_id
  ,asg.person_id                     person_id
  ,asg.assignment_status_type_id     asg_status_type_id
  ,ast.per_system_status             per_system_status
  ,ast.pay_system_status             pay_system_status
  ,asg.period_of_service_id          period_of_service_id
  ,asg.primary_flag                  primary_flag
  ,GREATEST(abv.last_update_date, asg.last_update_date)
                                     last_change_date
  ,pos.final_process_date            final_process_date
  FROM
   per_assignment_budget_values_f   abv
  ,per_all_assignments_f            asg
  ,per_assignment_status_types      ast
  ,per_periods_of_service           pos
  WHERE abv.assignment_id = asg.assignment_id
  AND asg.assignment_id = p_assignment_id
  AND pos.period_of_service_id = asg.period_of_service_id
  AND asg.assignment_type = 'E'
  AND ast.assignment_status_type_id = asg.assignment_status_type_id
  AND abv.unit = p_bmt_code
  AND abv.effective_end_date + 1
         BETWEEN g_collect_from_date AND g_collect_to_date
  AND asg.effective_start_date < abv.effective_end_date + 1
  AND abv.effective_end_date + 1 <= asg.effective_end_date
  AND NOT EXISTS
     (SELECT null
      FROM per_assignment_budget_values_f   abv_next
      WHERE abv_next.assignment_id = abv.assignment_id
      AND abv_next.unit = abv.unit
      AND abv_next.effective_start_date = abv.effective_end_date + 1)
  UNION ALL
/* All assignment changes without an abv in the table */
/* If full refresh is selected then active assignments at the start */
/* of the collect period are also picked up */
  SELECT
   to_number(null)                   abv_value
  ,GREATEST(asg.effective_start_date, g_collect_from_date)
                                     effective_start_date
  ,asg.assignment_id                 assignment_id
  ,asg.business_group_id             business_group_id
  ,asg.person_id                     person_id
  ,asg.assignment_status_type_id     asg_status_type_id
  ,ast.per_system_status             per_system_status
  ,ast.pay_system_status             pay_system_status
  ,asg.period_of_service_id          period_of_service_id
  ,asg.primary_flag                  primary_flag
  ,asg.last_update_date              last_change_date
  ,pos.final_process_date            final_process_date
  FROM
   per_all_assignments_f        asg
  ,per_assignment_status_types  ast
  ,per_periods_of_service           pos
  WHERE asg.assignment_id = p_assignment_id
  AND pos.period_of_service_id = asg.period_of_service_id
  AND ast.assignment_status_type_id = asg.assignment_status_type_id
  AND asg.assignment_type = 'E'
  AND (asg.effective_start_date
         BETWEEN g_collect_from_date AND g_collect_to_date
    OR (g_collect_from_date
         BETWEEN asg.effective_start_date AND asg.effective_end_date
        AND g_full_refresh = 'Y'))
  AND NOT EXISTS
        (SELECT null
         FROM per_assignment_budget_values_f   abv
         WHERE abv.assignment_id = asg.assignment_id
         AND abv.unit = p_bmt_code
         AND GREATEST(asg.effective_start_date, g_collect_from_date)
           BETWEEN abv.effective_start_date AND abv.effective_end_date)
  UNION ALL
/* Bug 2649221 - All assignment status and primary flag changes with an ABV */
  SELECT
   abv.value                           abv_value
  ,next_asg.effective_start_date       effective_start_date
  ,next_asg.assignment_id              assignment_id
  ,next_asg.business_group_id          business_group_id
  ,next_asg.person_id                  person_id
  ,next_asg.assignment_status_type_id  asg_status_type_id
  ,ast.per_system_status               per_system_status
  ,ast.pay_system_status               pay_system_status
  ,next_asg.period_of_service_id       period_of_service_id
  ,next_asg.primary_flag               primary_flag
  ,GREATEST(abv.last_update_date, next_asg.last_update_date)
                                       last_change_date
  ,pos.final_process_date              final_process_date
  FROM
   per_assignment_budget_values_f   abv
  ,per_all_assignments_f            asg
  ,per_all_assignments_f            next_asg
  ,per_assignment_status_types      ast
  ,per_periods_of_service           pos
  WHERE abv.assignment_id = asg.assignment_id
  AND asg.assignment_id = p_assignment_id
  AND next_asg.assignment_id = asg.assignment_id
  AND next_asg.effective_start_date = asg.effective_end_date + 1
/* Primary flag or assignment status change */
  AND (NVL(next_asg.primary_flag,'N') <> NVL(asg.primary_flag,'N')
    OR next_asg.assignment_status_type_id <> asg.assignment_status_type_id)
  AND next_asg.period_of_service_id = pos.period_of_service_id
  AND ast.assignment_status_type_id = next_asg.assignment_status_type_id
  AND abv.unit = p_bmt_code
  AND next_asg.assignment_type = 'E'
  AND next_asg.effective_start_date
          BETWEEN abv.effective_start_date AND abv.effective_end_date
  AND next_asg.effective_start_date
          BETWEEN g_collect_from_date AND g_collect_to_date
  ORDER BY 2 ASC;
/* DO NOT CHANGE THE ORDER BY - MUST PROCESS IN DATE ORDER */

  l_index           PLS_INTEGER;   -- index for package global table
  l_abv_value       NUMBER;

  l_last_fte        NUMBER;
  l_last_head       NUMBER;
  l_last_ast_id     NUMBER;
  l_last_prm_flag   VARCHAR2(30);

BEGIN

  FOR abv_change_rec IN ptntl_abv_changes_csr LOOP

  /* If no values have changed, skip the insert */
    IF ((p_bmt_code = 'FTE' AND
         abv_change_rec.abv_value = l_last_fte AND
         abv_change_rec.primary_flag = l_last_prm_flag AND
         abv_change_rec.asg_status_type_id = l_last_ast_id)
       OR
        (p_bmt_code = 'HEAD' AND
         abv_change_rec.abv_value = l_last_head AND
         abv_change_rec.primary_flag = l_last_prm_flag AND
         abv_change_rec.asg_status_type_id = l_last_ast_id)
       ) THEN

    /* Easier to write the above condition this way round! */
      null;

    ELSE

    /* Get index of new row to insert */
    /* Cursor guarantees that: {cursor start date >= g_collect_from date} */
      l_index := abv_change_rec.effective_start_date - g_collect_from_date;

    /* Get the ABV value if it is not in the ABV table */
      IF (abv_change_rec.abv_value IS NULL) THEN
          BEGIN
            l_abv_value := hri_bpl_abv.calc_abv
                  (p_assignment_id => abv_change_rec.assignment_id
                  ,p_business_group_id => abv_change_rec.business_group_id
                  ,p_budget_type => p_bmt_code
                  ,p_effective_date => abv_change_rec.effective_start_date
                  ,p_primary_flag => NVL(abv_change_rec.primary_flag,'N')
                  ,p_run_formula => 'Y');
          EXCEPTION WHEN OTHERS THEN
            l_abv_value := -999;  -- error in running fast formula
          END;
      ELSE
        l_abv_value := abv_change_rec.abv_value;
      END IF;

    /* If a row already exists for a date, skip and just update the ABV */
      IF (NOT g_start_date_tab.EXISTS(l_index)) THEN

      /* Store row indexed by start date */
        g_start_date_tab(l_index)   := abv_change_rec.effective_start_date;
        g_asg_id_tab(l_index)       := abv_change_rec.assignment_id;
        g_bgr_id_tab(l_index)       := abv_change_rec.business_group_id;
        g_psn_id_tab(l_index)       := abv_change_rec.person_id;
        g_ast_id_tab(l_index)       := abv_change_rec.asg_status_type_id;
        g_per_sys_stat_tab(l_index) := abv_change_rec.per_system_status;
        g_pay_sys_stat_tab(l_index) := abv_change_rec.pay_system_status;
        g_pos_id_tab(l_index)       := abv_change_rec.period_of_service_id;
        g_primary_flag_tab(l_index) := abv_change_rec.primary_flag;
        g_last_chng_tab(l_index)    := abv_change_rec.last_change_date;
        g_final_proc_tab(l_index)   := abv_change_rec.final_process_date;
        l_last_ast_id               := abv_change_rec.asg_status_type_id;
        l_last_prm_flag             := abv_change_rec.primary_flag;

      /* Sort out the ABV values */
        IF (p_bmt_code = 'HEAD') THEN
          g_fte_value_tab(l_index) := to_number(null);
          g_head_value_tab(l_index) := l_abv_value;
          l_last_head               := l_abv_value;
        ELSIF (p_bmt_code = 'FTE') THEN
          g_fte_value_tab(l_index)  := l_abv_value;
          g_head_value_tab(l_index) := to_number(null);
          l_last_fte                := l_abv_value;
        END IF;

      ELSE

      /* Just update the single column corresponding to the ABV */
        IF (p_bmt_code = 'HEAD') THEN
          g_head_value_tab(l_index) := l_abv_value;
          l_last_head               := l_abv_value;
        ELSIF (p_bmt_code = 'FTE') THEN
          g_fte_value_tab(l_index)  := l_abv_value;
          l_last_fte                := l_abv_value;
        END IF;

      END IF;

    /* Increment stored rows counter */
      g_rows_inserted := g_rows_inserted + 1;

    END IF;

  END LOOP;

END process_assignment;

/******************************************************************************/
/* Processes actions and inserts data into summary table                      */
/* This procedure is executed for every assignment in a chunk                 */
/******************************************************************************/
PROCEDURE archive_code( p_assactid        IN NUMBER,
                        p_effective_date  IN DATE) IS

/* Cursor to get the assignment_id for the assignment action */
  CURSOR asg_action_csr IS
  SELECT
   paa.assignment_id
  FROM pay_assignment_actions   paa
  WHERE paa.assignment_action_id = p_assactid;

/* Holds assignment from the cursor */
  l_assignment_id          NUMBER;

BEGIN

/* Initialize global variables */
  g_rows_inserted := 0;
  init_global_table;

  OPEN asg_action_csr;
  FETCH asg_action_csr INTO l_assignment_id;
  CLOSE asg_action_csr;

/* Process for FTE changes if the collect_fte parameter is set */
  IF (g_collect_fte = 'Y') THEN
    process_assignment
      (p_assignment_id       => l_assignment_id
      ,p_bmt_code            => 'FTE');
  END IF;

/* Process for HEAD changes if the collect_fte parameter is set */
  IF (g_collect_head = 'Y') THEN
    process_assignment
      (p_assignment_id       => l_assignment_id
      ,p_bmt_code            => 'HEAD');
  END IF;

/* Insert stored rows only if there are any stored */
  IF (g_full_refresh = 'Y' AND g_rows_inserted > 0) THEN
    insert_stored_rows;
  ELSIF (g_full_refresh = 'N' AND g_rows_inserted > 0) THEN
    process_stored_rows;
  END IF;

END archive_code;

/******************************************************************************/
/* Runs at process end to clean up payroll actions and log conc process run   */
/******************************************************************************/
PROCEDURE deinit_code(p_payroll_action_id      IN NUMBER) IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
  --
  CURSOR wmv_pact_id_csr IS
  SELECT payroll_action_id
  FROM   pay_payroll_actions
  WHERE  report_qualifier = 'HRI_MB_WMV'
  AND    report_type = 'HISTORIC_SUMMARY'
  AND    action_type = 'X';
  --
BEGIN
  --
  -- Bug 2911335 - Collect stats for full refresh
  --
  IF (g_full_refresh = 'Y') THEN
    --
    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
      --
      output('Full Refresh selected - gathering stats');
      fnd_stats.gather_table_stats(l_schema,'HRI_MB_WMV');
      --
    END IF;
    --
  END IF;
  --
  -- Bug 2823028 - Clean up payroll actions
  -- 4200282 Purge all historic payroll action records for HRI_MB_WMV
  -- process. This was done by hrizxwmv.sql which slows down patch application
  -- therefore it has been moved to
  --
  FOR wmv_pact_id_rec IN wmv_pact_id_csr LOOP
    --
    pay_archive.remove_report_actions(wmv_pact_id_rec.payroll_action_id);
    --
  END LOOP;
  --
  hri_bpl_conc_log.log_process_end(
          p_status         => TRUE,
          p_period_from    => TRUNC(g_collect_from_date),
          p_period_to      => TRUNC(g_collect_to_date),
          p_attribute1     => g_collect_fte,
          p_attribute2     => g_collect_head,
          p_attribute3     => g_full_refresh);
  --
END deinit_code;


/******************************************************************************/
/* Debugging procedure to run for a single business group                     */
/******************************************************************************/
PROCEDURE run_for_bg(p_business_group_id  IN NUMBER,
                     p_full_refresh       IN VARCHAR2,
                     p_collect_fte        IN VARCHAR2,
                     p_collect_head       IN VARCHAR2,
                     p_collect_from       IN VARCHAR2,
                     p_collect_to         IN VARCHAR2) IS

  CURSOR asg_csr IS
  SELECT DISTINCT
   asg.assignment_id
  FROM
   per_all_assignments_f  asg
  WHERE (asg.business_group_id = p_business_group_id
    OR p_business_group_id IS NULL)
  AND asg.assignment_type = 'E'
  AND (g_collect_from_date
        BETWEEN asg.effective_start_date AND asg.effective_end_date
    OR asg.effective_start_date
        BETWEEN g_collect_from_date AND g_collect_to_date);

l_dummy1  VARCHAR2(2000);
l_dummy2  VARCHAR2(2000);
l_sql_stmt  VARCHAR2(2000);
l_schema  VARCHAR2(30);

BEGIN

  g_collect_from_date := to_date(p_collect_from,'DD-MM-YYYY');
  g_collect_to_date   := to_date(p_collect_to,'DD-MM-YYYY');
  g_full_refresh      := p_full_refresh;
  g_collect_fte       := p_collect_fte;
  g_collect_head      := p_collect_head;

/* Raise a ff compile error if either of the seeded ffs to be used are not */
/* compiled */
  IF (g_collect_head = 'Y') THEN
    hri_bpl_abv.check_ff_name_compiled( p_formula_name => 'TEMPLATE_FTE' );
  END IF;

  IF (g_collect_head = 'Y') THEN
    hri_bpl_abv.check_ff_name_compiled( p_formula_name => 'TEMPLATE_HEAD' );
  END IF;

/* Truncate the table if a full refresh is selected */
  IF (g_full_refresh = 'Y') THEN

    IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN

      l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_WMV';
      EXECUTE IMMEDIATE(l_sql_stmt);

      output('Full Refresh selected - truncated existing data');

    END IF;

  END IF;

  FOR asg_rec IN asg_csr LOOP

  /* Initialise globals */
    init_global_table;
    g_rows_inserted := 0;

    IF (g_collect_fte = 'Y') THEN
      process_assignment
        (p_assignment_id       => asg_rec.assignment_id
        ,p_bmt_code            => 'FTE');
    END IF;

    IF (g_collect_head = 'Y') THEN
      process_assignment
        (p_assignment_id       => asg_rec.assignment_id
        ,p_bmt_code            => 'HEAD');
    END IF;

    IF (g_full_refresh = 'Y' AND g_rows_inserted > 0) THEN
      insert_stored_rows;
    ELSIF (g_full_refresh = 'N' AND g_rows_inserted > 0) THEN
      process_stored_rows;
    END IF;

    END LOOP;


END run_for_bg;
--
-- ----------------------------------------------------------------------------
-- shared_hrms_dflt_prcss
-- This process will be launched by shared_hrms_dflt_prcss (OVERLOADED).
-- ============================================================================
-- This procedure contains the code required to populate hri_mb_wmv in shared
-- HR.
--
PROCEDURE shared_hrms_dflt_prcss
IS
  --
  l_dummy1           VARCHAR2(2000);
  l_dummy2           VARCHAR2(2000);
  l_schema           VARCHAR2(400);
  l_sql_stmt         VARCHAR2(500);
  --
BEGIN
  --
  output('Entering the default collection process,'||
         ' called when foundation HR is detected.');
  --
  -- Record the process start
  --
  hri_bpl_conc_log.record_process_start('HRI_MB_WMV');
  --
  -- Truncate the table
  --
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
    --
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_WMV';
    EXECUTE IMMEDIATE(l_sql_stmt);
    --
  END IF;
  --
  g_end_of_time := hr_general.end_of_time;
  --
  -- Inserts row
  --
  INSERT /*+ APPEND */ INTO hri_mb_wmv
    (primary_asg_indicator
    ,asg_indicator
    ,fte
    ,head
    ,effective_start_date
    ,effective_end_date
    ,assignment_id
    ,person_id
    ,business_group_id
    ,assignment_status_type_id
    ,per_system_status_code
    ,pay_system_status_code
    ,period_of_service_id
    ,primary_flag
    ,last_change_date)
  SELECT
    DECODE(asg.primary_flag,'Y',1,0)  primary_flag_indicator
   ,1                                 asg_indicator
   ,1                                 fte_value
   ,1                                 head_value
   ,GREATEST(asg.effective_start_date
             ,trunc(SYSDATE))
                                      effective_start_date
   ,nvl(pos.final_process_date , g_end_of_time) effective_end_date
   ,asg.assignment_id                 assignment_id
   ,asg.person_id                     person_id
   ,asg.business_group_id             business_group_id
   ,asg.assignment_status_type_id     asg_status_type_id
   ,ast.per_system_status             per_system_status
   ,ast.pay_system_status             pay_system_status
   ,asg.period_of_service_id          period_of_service_id
   ,asg.primary_flag                  primary_flag
   ,asg.last_update_date              last_change_date
   FROM
    per_all_assignments_f        asg
   ,per_assignment_status_types  ast
   ,per_periods_of_service       pos
   WHERE pos.period_of_service_id = asg.period_of_service_id
   AND   ast.assignment_status_type_id = asg.assignment_status_type_id
   AND   asg.assignment_type = 'E'
   AND   trunc(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date;
  --
  -- Gather Statistics
  --
  IF (fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema)) THEN
    --
    fnd_stats.gather_table_stats(l_schema,'HRI_MB_WMV');
    --
  END IF;
  --
  -- Insert process execution stats
  --
  hri_bpl_conc_log.log_process_end(
          p_status         => TRUE,
          p_period_from    => TRUNC(SYSDATE),
          p_period_to      => TRUNC(SYSDATE),
          p_attribute1     => g_collect_fte,
          p_attribute2     => g_collect_head,
          p_attribute3     => g_full_refresh);
  --
END shared_hrms_dflt_prcss;
--
-- ----------------------------------------------------------------------------
-- shared_hrms_dflt_prcss (OVERLOADED)
-- Default process executed when PYUGEN is not available.
-- ============================================================================
-- This process will be launched by the package HRI_BPL_PYUGEN_WRAPPER
-- whenever it detects PYUGEN is not installed.
--
-- The parameters of this function are standard for all default processes
-- called where PYUGEN does not exist. This particular package IGNORES THEM
--
PROCEDURE shared_hrms_dflt_prcss
  (
   errbuf              OUT NOCOPY VARCHAR2
  ,retcode             OUT NOCOPY NUMBER
  ,p_collect_from_date IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_collect_to_date   IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_full_refresh      IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_attribute1        IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  ,p_attribute2        IN VARCHAR2 DEFAULT NULL -- Optional Param default NULL
  )
IS
  --
BEGIN
  --
  -- Do not pass throuh IN parameters, as they are not used.
  --
  shared_hrms_dflt_prcss;
  --
EXCEPTION
  WHEN OTHERS
  THEN
    --
    errbuf := SQLERRM;
    retcode := SQLCODE;
    RAISE;
    --
  --
END shared_hrms_dflt_prcss;
--
END hri_opl_wmv;

/
