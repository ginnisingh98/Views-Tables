--------------------------------------------------------
--  DDL for Package Body XXAH_PATC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_PATC_PUB" AS
/**************************************************************************
 * HISTORY
 * =======
 *
 * VERSION DATE        AUTHOR(S)         DESCRIPTION
 * ------- ----------- ---------------   ------------------------------------
 * 1.00    03-JAN-2008 Marc Smeenge      Initial creation.
 * 1.01    10-JAN-2008 Ralph Hopman      Include show_project. Replaced
 *                                       sysdate in NVLs with
 *                                       hr_general.end_of_time.
 * 1.02    28-JAN-2008 Ralph Hopman      Use type DATE for dates.
 * 1.1     29-SEP-2008 Kevin Bouwmeester Adapted for Equens
 * 1.2     04-DEC-2009 Kevin Bouwmeester Adapted for Ahold
 *************************************************************************/

-- -----------------------------------------------------------------
-- Private constants
-- -----------------------------------------------------------------
  gc_show     CONSTANT  VARCHAR2(1) := 'Y';
  gc_no_show  CONSTANT  VARCHAR2(1) := 'N';

  /*
   * Assumptions for customer Ahold:
   *
   * 1. Transaction Controls are only used to authorize persons for
   * a task / project (limit_to_trx_controls_flag = 'Y').
   *
   * 2. Task control is leading. When there is no task control, but
   * there is a projects control, then all tasks are allowed. When
   * a task control is added later on, it is possible that existing
   * charges on tasks become invalid.
   *
   * 3. TCs are per person. There are no general TCs.
   */

  FUNCTION show_project
  ( p_project_id IN pa_projects_all.project_id%TYPE
  , p_resource_id IN per_all_people_f.person_id%TYPE
  , p_date_from IN DATE
  , p_date_to IN DATE)
  RETURN VARCHAR2
  IS

    CURSOR c_project_tc
    ( b_project_id  pa_transaction_controls.project_id%TYPE
    , b_person_id pa_transaction_controls.person_id%TYPE
    , b_period_start  DATE
    , b_period_end    DATE)
    IS
    SELECT 1
    FROM   pa_transaction_controls ptc
    WHERE  ptc.project_id         = b_project_id
    AND    ptc.person_id          = b_person_id
    AND    ptc.start_date_active <= b_period_end
    AND    nvl(ptc.end_date_active, hr_general.end_of_time) >= b_period_start
    ;

    v_result VARCHAR2(1) := gc_show;
    v_found  BOOLEAN;
    v_dummy NUMBER;
  BEGIN
    -- Ahold: A project is shown if a transaction control exists for
    -- this project or a task in this project within the given period.
    /*
    OPEN c_project_tc
    ( b_project_id => p_project_id
    , b_person_id => p_resource_id
    , b_period_start => p_date_from
    , b_period_end  => p_date_to
    );

    FETCH c_project_tc INTO v_dummy;
    v_found := c_project_tc%FOUND;
    CLOSE c_project_tc;

    IF v_found THEN
      v_result := gc_show;
    ELSE
      v_result := gc_no_show;
    END IF;

    RETURN v_result;
    */
    RETURN 'Y';
  END show_project;

  FUNCTION show_task
  ( p_task_id     IN pa_tasks.task_id%TYPE
  , p_project_id  IN pa_projects_all.project_id%TYPE
  , p_resource_id IN per_all_people_f.person_id%TYPE
  , p_date_from   IN DATE
  , p_date_to     IN DATE
  ) RETURN VARCHAR2
  IS
    -- CHECK 1:
    -- Is there a transaction control for this specific task?
    CURSOR c_task_tc
    ( b_task_id       pa_tasks.task_id%TYPE
    , b_person_id     pa_transaction_controls.person_id%TYPE
    , b_period_start  DATE
    , b_period_end    DATE
    ) IS
    SELECT 1
    FROM   pa_transaction_controls ptc
    WHERE  ptc.task_id = b_task_id
    AND    ptc.start_date_active <= b_period_end
    AND    nvl(ptc.end_date_active, hr_general.end_of_time) >= b_period_start
    AND    ptc.person_id = b_person_id
    ;

    -- CHECK 2:
    -- Is there a transaction control on the project and not on a task?
    CURSOR c_proj_tc
    ( b_project_id    pa_transaction_controls.project_id%TYPE
    , b_person_id     pa_transaction_controls.person_id%TYPE
    , b_period_start  DATE
    , b_period_end    DATE
    ) IS
    SELECT 1
    FROM   pa_transaction_controls ptc
    WHERE  ptc.project_id = b_project_id
    AND    ptc.start_date_active <= b_period_end
    AND    nvl(ptc.end_date_active, hr_general.end_of_time) >= b_period_start
    AND    ptc.person_id = b_person_id
    AND    ptc.task_id IS NULL
    AND NOT EXISTS
      (SELECT 1
       FROM pa_transaction_controls ptc
       WHERE  ptc.project_id = b_project_id
       AND    ptc.start_date_active <= b_period_end
       AND    nvl(ptc.end_date_active, hr_general.end_of_time) >= b_period_start
       AND    ptc.person_id = b_person_id
       AND    ptc.task_id IS NOT NULL)
    ;
    v_result VARCHAR2(1) := gc_show;
    v_found  BOOLEAN;
    v_dummy NUMBER;
  BEGIN
    -- Ahold: a task is shown if there is a transaction control on project
    -- and NO transaction control on task level, OR there is a transaction
    -- control on this specific task for this specific person.
    /*
    OPEN c_task_tc
    ( b_task_id => p_task_id
    , b_person_id => p_resource_id
    , b_period_start => p_date_from
    , b_period_end  => p_date_to
    );
    FETCH c_task_tc INTO v_dummy;
    v_found := c_task_tc%FOUND;
    CLOSE c_task_tc;
    IF v_found THEN
      v_result := gc_show;
    ELSE
      OPEN c_proj_tc
      ( b_project_id => p_project_id
      , b_person_id => p_resource_id
      , b_period_start => p_date_from
      , b_period_end  => p_date_to
      );
      FETCH c_proj_tc INTO v_dummy;
      v_found := c_proj_tc%FOUND;
      CLOSE c_proj_tc;
      IF v_found THEN
        v_result := gc_show;
      ELSE
        v_result := gc_no_show;
      END IF;
    END IF;
    RETURN v_result;
    */
    RETURN 'Y';
  END show_task;

END XXAH_PATC_PUB;

/
