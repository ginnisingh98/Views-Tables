--------------------------------------------------------
--  DDL for Package Body HRI_EDW_FCT_RECRUITMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_FCT_RECRUITMENT" AS
/* $Header: hriefwrt.pkb 120.0 2005/05/29 07:10:44 appldev noship $ */

  g_instance_fk       VARCHAR2(40);     -- Holds data source

/* Holds stage dates and reasons for each applicant */
  g_application_date        DATE;
  g_interview1_date         DATE;
  g_interview2_date         DATE;
  g_offer_date              DATE;
  g_accept_date             DATE;
  g_separation_date         DATE;

  g_application_reason      VARCHAR2(30);
  g_interview1_reason       VARCHAR2(30);
  g_interview2_reason       VARCHAR2(30);
  g_offer_reason            VARCHAR2(30);
  g_accept_reason           VARCHAR2(30);
  g_separation_reason       VARCHAR2(30);

  g_application_success     NUMBER;
  g_interview1_success      NUMBER;
  g_interview2_success      NUMBER;
  g_offer_success           NUMBER;
  g_accept_success          NUMBER;

  g_success                 NUMBER;

/******************************************************************************/
/* This is a dummy function which calls the calc_abv function in the business */
/* process layer. It returns the assignment budget value of an applicant      */
/* given their assignment, the vacancy they are applying for, the effective   */
/* date the budget measurement type (BMT) and the applicant's business group  */
/******************************************************************************/
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_budget_type       IN VARCHAR2,
                  p_effective_date    IN DATE)
                  RETURN NUMBER    IS

  l_return_value   NUMBER := to_number(null);  -- Keeps the ABV to be returned

BEGIN

  l_return_value := hri_bpl_abv.calc_abv
        ( p_assignment_id      => p_assignment_id
        , p_business_group_id  => p_business_group_id
        , p_budget_type        => p_budget_type
        , p_effective_date     => p_effective_date );

RETURN l_return_value;

EXCEPTION
  WHEN OTHERS THEN
    RETURN to_number(null);

END calc_abv;

/******************************************************************************/
/* This function takes in the assignment and populates global variables with  */
/* the dates of and reasons for stages. If a stages is not reached the global */
/* will be null, if a stage is reached more than once the first is returned.  */
/******************************************************************************/
PROCEDURE find_stages (p_assignment_id      IN NUMBER) IS

/* Selects the first date on which the system status passed in is        */
/* set on the given assignment, and whether or not the stage was         */
/* successful (based on whether another assignment record exists with    */
/* a different status and whether the overall application was successful */
  CURSOR assign_csr
  (v_csr_system_status VARCHAR2) IS
  SELECT asg.effective_start_date
  ,asg.change_reason
  ,DECODE(next_asg.assignment_id, to_number(null), g_success, 1)
  FROM per_all_assignments_f    asg
  ,per_assignment_status_types  ast
  ,per_all_assignments_f        next_asg
  WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
  AND asg.assignment_id = p_assignment_id
  AND ast.per_system_status = v_csr_system_status
  AND next_asg.assignment_id (+) = asg.assignment_id
  AND next_asg.effective_start_date (+) > asg.effective_start_date
  AND next_asg.assignment_status_type_id (+) <> asg.assignment_status_type_id
  ORDER BY asg.effective_start_date ASC;

BEGIN

  OPEN assign_csr('ACTIVE_APL');
  FETCH assign_csr into g_application_date,
                        g_application_reason,
                        g_application_success;
  CLOSE assign_csr;

  IF (g_application_date IS NULL) THEN
/* Application successful, status changed immediately */
    g_application_success := 1;
  END IF;

  OPEN assign_csr('INTERVIEW1');
  FETCH assign_csr into g_interview1_date,
                        g_interview1_reason,
                        g_interview1_success;
  CLOSE assign_csr;

  OPEN assign_csr('INTERVIEW2');
  FETCH assign_csr into g_interview2_date,
                        g_interview2_reason,
                        g_interview2_success;
  CLOSE assign_csr;

  OPEN assign_csr('OFFER');
  FETCH assign_csr into g_offer_date,
                        g_offer_reason,
                        g_offer_success;
  CLOSE assign_csr;

  OPEN assign_csr('ACCEPTED');
  FETCH assign_csr into g_accept_date,
                        g_accept_reason,
                        g_accept_success;
  CLOSE assign_csr;

END find_stages;

/* Same as the procedure above, but for separation */
PROCEDURE find_employment_end (p_person_id    NUMBER,
                               p_date_start   DATE) IS

/* Cursor selecting the end date of the period of employment immediately */
/* following the application */
  CURSOR end_emp_cur IS
  SELECT pps.actual_termination_date, pps.leaving_reason
  FROM per_periods_of_service pps
  WHERE person_id = p_person_id
  AND (p_date_start BETWEEN date_start
       AND actual_termination_date
    OR p_date_start > date_start
       AND actual_termination_date IS NULL);

BEGIN

  OPEN end_emp_cur;
  FETCH end_emp_cur INTO g_separation_date, g_separation_reason;
  CLOSE end_emp_cur;

END find_employment_end;


/* Returns the hire reason first looking at the applicant assignment */
/* and if that doesn't become an employee assignment then looking at */
/* the primary employee assignment */
FUNCTION find_hire_reason(p_assignment_id  IN NUMBER,
                          p_person_id      IN NUMBER,
                          p_hire_date      IN DATE)
                   RETURN VARCHAR2 IS

  l_reason          VARCHAR2(400);

/* 115.3 Added hr_lookups to cursor below to filter out rogue reasons */
/* See bugs 1787981 and 1785779 */

/* Looking at the applicant assignment */
  CURSOR smpl_hire_reason_cur IS
  SELECT
   asg.change_reason
  FROM
   per_all_assignments_f asg,
   hr_lookups hrl
  WHERE
  asg.assignment_id = p_assignment_id
  AND asg.change_reason = hrl.lookup_code
  AND hrl.lookup_type = 'EMP_ASSIGN_REASON'
  AND asg.effective_start_date = p_hire_date;

/* Looking at the primary employee assignment */
  CURSOR prmry_hire_reason_cur IS
  SELECT
   asg.change_reason
  FROM
   per_all_assignments_f asg,
   hr_lookups hrl
  WHERE
  asg.person_id = p_person_id
  AND asg.effective_start_date = p_hire_date
  AND asg.change_reason = hrl.lookup_code
  AND hrl.lookup_type = 'EMP_ASSIGN_REASON'
  AND asg.primary_flag = 'Y';

BEGIN

  OPEN smpl_hire_reason_cur;
  FETCH smpl_hire_reason_cur INTO l_reason;
  IF (smpl_hire_reason_cur%NOTFOUND
    OR smpl_hire_reason_cur%NOTFOUND IS NULL) THEN
  /* If that didn't return any rows check the primary assignment */
    CLOSE smpl_hire_reason_cur;
     OPEN prmry_hire_reason_cur;
     FETCH prmry_hire_reason_cur INTO l_reason;
     CLOSE prmry_hire_reason_cur;
  ELSE
    CLOSE smpl_hire_reason_cur;
  END IF;

  RETURN l_reason;

END find_hire_reason;


/******************************************************************************/
/* Takes the stage, the gain type and whether the stage was successful and    */
/* returns the movement pk for that event                                     */
/******************************************************************************/
FUNCTION find_movement_pk(p_system_status    IN VARCHAR2,
                          p_gain_type        IN VARCHAR2,
                          p_success_flag     IN NUMBER)
                   RETURN VARCHAR2 IS

  l_return_string   VARCHAR2(800);    -- Keeps the string to return
  l_stage           VARCHAR2(30);     -- Holds current stage

/* Movement Type PK is made by concatenating the following primary keys */
  l_gain_type_pk       VARCHAR2(400); -- Holds gain type pk
  l_loss_type_pk       VARCHAR2(400); -- Holds loss type pk
  l_recruitment_pk     VARCHAR2(400); -- Holds recruitment stage pk
  l_separation_pk      VARCHAR2(400); -- Holds separation stage pk
  l_na_edw_pk          VARCHAR2(140); -- Points to N/A row

BEGIN

  l_na_edw_pk := 'NA_EDW-' || g_instance_fk || '-NA_EDW-' ||
                 g_instance_fk || '-NA_EDW-' || g_instance_fk;

  l_separation_pk := l_na_edw_pk;

/* Populate gain and loss type pks */
/***********************************/

/* Break out all the definite gains and losses */
  IF (p_success_flag = 1 AND
       (p_system_status = 'ACCEPTED' OR p_system_status = 'HIRE')) THEN
  /* A successful applicant at the HIRE or ACCEPTED stage is a */
  /* gain (actual) - break out by gain type to get the gain pk */
    IF p_gain_type = 'NEW_HIRE' THEN
      l_loss_type_pk := l_na_edw_pk;
      l_gain_type_pk := 'GAINS-' || g_instance_fk || '-GAIN_HIRE-' ||
                        g_instance_fk || '-HIRE_NEW-' || g_instance_fk;
    ELSIF p_gain_type = 'RE_HIRE' THEN
      l_loss_type_pk := l_na_edw_pk;
      l_gain_type_pk := 'GAINS-' || g_instance_fk || '-GAIN_HIRE-' ||
                        g_instance_fk || '-HIRE_RE-' || g_instance_fk;
    ELSIF p_gain_type = 'ASG_START' THEN
      l_loss_type_pk := l_na_edw_pk;
      l_gain_type_pk := 'GAINS-' || g_instance_fk || '-GAIN_ASG-' ||
                        g_instance_fk || '-GAIN_ASG-' || g_instance_fk;
    ELSE
      l_loss_type_pk := 'LOSSES-' || g_instance_fk ||'-LOSS_ORG-' ||
                        g_instance_fk || '-LOSS_ORG-' || g_instance_fk;
      l_gain_type_pk := 'GAINS-' || g_instance_fk || '-GAIN_ORG-' ||
                        g_instance_fk || '-GAIN_ORG-' || g_instance_fk;
    END IF;
  ELSIF (p_success_flag = 1 AND p_system_status = 'END_EMP') THEN
    /* Formulate loss type pk - using push down of separation until a method */
    /* has been agreed for resolving the difference with involuntary */
    l_loss_type_pk := 'LOSSES-' || g_instance_fk || '-LOSS_SEP-' ||
                      g_instance_fk || '-LOSS_SEP-' || g_instance_fk;
    l_separation_pk := 'SEP_STAGE-' || g_instance_fk || '-SEP-' ||
                       g_instance_fk || '-SEP-' || g_instance_fk;
    l_gain_type_pk := l_na_edw_pk;
  ELSIF (p_success_flag = -1) THEN
    l_loss_type_pk := l_na_edw_pk;
    l_gain_type_pk := l_na_edw_pk;
  ELSE
  /* Application stage still pending, so formulate the Potential Gain PK */
    IF p_gain_type = 'NEW_HIRE' THEN
      l_loss_type_pk := l_na_edw_pk;
      l_gain_type_pk := 'POT_GAINS-' || g_instance_fk || '-POT_HIRE-' ||
                        g_instance_fk || '-HIRE_NEW-' || g_instance_fk;
    ELSIF p_gain_type = 'RE_HIRE' THEN
      l_loss_type_pk := l_na_edw_pk;
      l_gain_type_pk := 'POT_GAINS-' || g_instance_fk || '-POT_HIRE-' ||
                        g_instance_fk || '-HIRE_RE-' || g_instance_fk;
    ELSIF p_gain_type = 'ASG_START' THEN
      l_loss_type_pk := l_na_edw_pk;
      l_gain_type_pk := 'POT_GAINS-' || g_instance_fk || '-POT_ASG-' ||
                        g_instance_fk || '-POT_ASG-' || g_instance_fk;
    ELSE
      l_loss_type_pk := 'POT_LOSSES-' || g_instance_fk ||'-POT_ORG-' ||
                        g_instance_fk || '-POT_ORG-' || g_instance_fk;
      l_gain_type_pk := 'POT_GAINS-' || g_instance_fk || '-POT_ORG-' ||
                        g_instance_fk || '-POT_ORG-' || g_instance_fk;
    END IF;
  END IF;


/* Populate recruitment pk */
/***************************/

  IF (p_system_status = 'HIRE') THEN
    l_recruitment_pk := 'REC_STAGE-' || g_instance_fk || '-END-' ||
                        g_instance_fk || '-END_SCCSS-' || g_instance_fk;
  ELSIF (p_system_status = 'TERM_APL') THEN
    l_recruitment_pk := 'REC_STAGE-' || g_instance_fk || '-END-' ||
                        g_instance_fk || '-END_FAIL-' || g_instance_fk;
  ELSIF (p_system_status = 'END_EMP') THEN
    l_recruitment_pk := l_na_edw_pk;
  ELSE
    l_stage := p_system_status;
    l_recruitment_pk := 'REC_STAGE-' || g_instance_fk || '-' ||
                        l_stage || '-' || g_instance_fk;
      IF (p_success_flag = 1) THEN
        l_stage := l_stage || '_ACC';
      ELSIF (p_success_flag = 0) THEN
        l_stage := l_stage || '_PEND';
      ELSE
        l_stage := l_stage || '_REJ';
      END IF;
      l_recruitment_pk := l_recruitment_pk || '-' || l_stage
                          || '-' || g_instance_fk;
  END IF;


/* Compose dimension fk */
/************************/
/* Concatenate pks into movement type pk */
  l_return_string := l_gain_type_pk || '-' || l_loss_type_pk  || '-' ||
                 l_recruitment_pk || '-' || l_separation_pk || '-' || g_instance_fk;

  RETURN l_return_string;

END find_movement_pk;


/***************************************************************************/
/* This function returns 1 if the applicant was successful and 0 otherwise */
/* It is assumed that there is no termination reason given for the         */
/* application end and that the applicant is successful if either the      */
/* applicant assignment becomes an employee assignment, or if the existing */
/* primary (employee) assignment of the applicant changes on the day after */
/* the application assignment ends.                                        */
/***************************************************************************/
FUNCTION is_successful(p_assignment_id        IN NUMBER,
                       p_person_id            IN NUMBER,
                       p_date_end             IN DATE)
                 RETURN NUMBER IS

  l_result        NUMBER;         -- Whether the applicant was successful

/* Cursor returns 1 if the applicant assignment becomes an employee */
/* assignment */
  CURSOR successful_asg_csr IS
  SELECT 1
  FROM per_all_assignments_f
  WHERE assignment_id = p_assignment_id
  AND effective_start_date > p_date_end
  AND assignment_type = 'E';

/* Cursor returns 1 if there is a date-tracked change to the primary */
/* assignment on the day after the application terminated */
  CURSOR primary_success_csr IS
  SELECT 1
  FROM per_all_assignments_f prim
  WHERE prim.person_id = p_person_id
  AND prim.primary_flag = 'Y'
  AND prim.effective_start_date = (p_date_end + 1);

BEGIN

  IF p_date_end IS NULL THEN
  /* Application active still */
    RETURN 0;
  END IF;

  OPEN successful_asg_csr;
  FETCH successful_asg_csr INTO l_result;

  IF successful_asg_csr%FOUND THEN
  /* Applicant assignment becomes an employee assignment - success */
    CLOSE successful_asg_csr;
    RETURN 1;
  ELSE
    CLOSE successful_asg_csr;
    OPEN primary_success_csr;
    FETCH primary_success_csr INTO l_result;

    IF primary_success_csr%FOUND THEN
    /* Primary (employee) assignment changes - success */
      CLOSE primary_success_csr;
      RETURN 1;
/* Otherwise unsuccessful */
    ELSE
       CLOSE primary_success_csr;
       RETURN -1;
    END IF;

  END IF;

RETURN -1;

END is_successful;


/* To improve performance on collecting recruitment fact the following */
/* procedure populates a temporary table with information about each   */
/* assignment and its recruitment stages */
PROCEDURE populate_recruitment_table IS

/* Selects the first assignment record for each assignment */
  CURSOR initial_assignment_cursor IS
  SELECT asg.assignment_id              assignment_id
  ,asg.person_id                        person_id
  ,asg.business_group_id                business_group_id
  ,asg.assignment_type                  assignment_type
  ,asg.application_id                   application_id
  ,asg.effective_start_date             assignment_start
  ,apl.date_end                         application_end
  ,apl.projected_hire_date              planned_start_date
  ,apl.termination_reason               termination_reason
  ,decode(prev_pps.date_start,
/* If a previous period of service doesn't exist then applicant is new hire */
            to_date(NULL),'NEW_HIRE',
          decode(SIGN(prev_pps.actual_termination_date - asg.effective_start_date),
/* If the latest previous period of service has a past actual termination */
/* date then the applicant was an ex_employee */
                   -1,'RE_HIRE',
                 decode(emp_asg.organization_id,
/* If the applicant is an employee and is applying within the */
/* same organization then assignment start else org transfer  */
                          asg.organization_id,'ASG_START',
                        'ORG_TRANS')))
                                        gain_type
  ,decode(apl.application_id,
/* If person is an employee type they were successful */
            to_number(null),1,
          decode(apl.date_end,
/* If the application has not ended it is neither successful nor unsuccessful */
                    to_date(null),0,
                 decode(apl.termination_reason,
/* If there is a termination reason it is not successful */
                          null,hri_edw_fct_recruitment.is_successful(
                                      asg.assignment_id,
                                      apl.person_id,
                                      apl.date_end),
                        -1)))           success_flag
 ,GREATEST(
     NVL(asg.last_update_date,to_date('01-01-2000','DD-MM-YYYY')),
     NVL(apl.last_update_date,to_date('01-01-2000','DD-MM-YYYY')))
                                        last_update_date
   ,asg.creation_date                   creation_date
  FROM per_all_assignments_f  asg        -- Initial assignment record
  ,per_applications           apl        -- Application for assignment
  ,per_all_assignments_f      emp_asg    -- Pre-existing employee assignment
  ,per_periods_of_service     prev_pps   -- Previously ended period of service
  WHERE asg.assignment_type IN ('E','A')
   AND apl.application_id (+) = asg.application_id
   AND asg.person_id = emp_asg.person_id (+)
   AND emp_asg.primary_flag (+) = 'Y'
/* 115.3 Added following line to filter out benefits assignments */
   AND emp_asg.assignment_type (+) = 'E'
   AND asg.effective_start_date - 1
     BETWEEN emp_asg.effective_start_date (+) AND emp_asg.effective_end_date (+)
/* 115.6 If an employee assignment exists then only include applicant assignments */
   AND (emp_asg.assignment_id IS NULL
     OR (emp_asg.assignment_id IS NOT NULL AND asg.assignment_type = 'A'))
   AND asg.person_id = prev_pps.person_id (+)
   AND prev_pps.date_start (+) < asg.effective_start_date
/* If a previous period of service exists, restrict to the most recent */
   AND NOT EXISTS
     (SELECT 1
      FROM per_periods_of_service dummy
      WHERE dummy.person_id = apl.person_id
      AND dummy.date_start > prev_pps.date_start)
/* Filter out all but first assignment */
  AND asg.effective_start_date = (SELECT MIN(asg1.effective_start_date)
                                  FROM per_all_assignments_f asg1
                                  WHERE asg1.assignment_id = asg.assignment_id);

  l_head               NUMBER;
  l_fte                NUMBER;
  l_hire_date          DATE;
  l_hire_reason        VARCHAR2(30);
  l_termination_date   DATE;
  l_termination_reason VARCHAR2(30);

BEGIN

  DELETE FROM hri_recruitment_stages;

  FOR new_asg_rec IN initial_assignment_cursor LOOP

    g_application_date := TO_DATE(null);
    g_interview1_date := TO_DATE(null);
    g_interview2_date := TO_DATE(null);
    g_offer_date      := TO_DATE(null);
    g_accept_date     := TO_DATE(null);
    g_separation_date := TO_DATE(null);

    g_application_reason  := null;
    g_interview1_reason  := null;
    g_interview2_reason  := null;
    g_offer_reason       := null;
    g_accept_reason      := null;
    g_separation_reason  := null;

    g_application_success := null;
    g_interview1_success  := null;
    g_interview2_success  := null;
    g_offer_success       := null;
    g_accept_success      := null;

    g_success := new_asg_rec.success_flag;

    IF (new_asg_rec.application_id IS NOT NULL) THEN
      find_stages(new_asg_rec.assignment_id);
    END IF;

    IF (new_asg_rec.success_flag = 1) THEN
      l_hire_date := NVL(new_asg_rec.application_end+1,new_asg_rec.assignment_start);
      l_hire_reason := find_hire_reason
                 ( new_asg_rec.assignment_id
                 , new_asg_rec.person_id
                 , NVL(new_asg_rec.application_end+1, new_asg_rec.assignment_start));
    ELSE
      l_hire_date := TO_DATE(null);
      l_hire_reason := null;
    END IF;

    IF (new_asg_rec.success_flag = 1) THEN
      find_employment_end
        ( new_asg_rec.person_id
        , NVL(new_asg_rec.application_end+1, new_asg_rec.assignment_start));
    END IF;

    IF (new_asg_rec.success_flag = -1) THEN
      l_termination_reason := new_asg_rec.termination_reason;
      l_termination_date := new_asg_rec.application_end;
    ELSE
      l_termination_reason := null;
      l_termination_date := TO_DATE(null);
    END IF;

--    l_head := calc_abv
--                ( new_asg_rec.assignment_id
--                , new_asg_rec.business_group_id
--                , 'HEAD'
--                , new_asg_rec.assignment_start );

--    l_fte  := calc_abv
--                ( new_asg_rec.assignment_id
--                , new_asg_rec.business_group_id
--                , 'FTE'
--                , new_asg_rec.assignment_start );


    INSERT INTO hri_recruitment_stages
      ( assignment_id
      , assignment_start_date
      , business_group_id
      , assignment_type
      , application_id
      , person_id
      , gain_type
      , success
      , application_date
      , application_end_date
      , planned_start_date
      , application_reason
      , application_success
      , interview1_date
      , interview1_reason
      , interview1_success
      , interview2_date
      , interview2_reason
      , interview2_success
      , offer_date
      , offer_reason
      , offer_success
      , accept_date
      , accept_reason
      , accept_success
      , hire_date
      , hire_reason
      , termination_date
      , termination_reason
      , separation_date
      , separation_reason
      , last_update_date
      , creation_date )
      VALUES
        ( new_asg_rec.assignment_id
        , new_asg_rec.assignment_start
        , new_asg_rec.business_group_id
        , new_asg_rec.assignment_type
        , new_asg_rec.application_id
        , new_asg_rec.person_id
        , new_asg_rec.gain_type
        , new_asg_rec.success_flag
        , g_application_date
        , new_asg_rec.application_end
        , new_asg_rec.planned_start_date
        , g_application_reason
        , g_application_success
        , g_interview1_date
        , g_interview1_reason
        , g_interview1_success
        , g_interview2_date
        , g_interview2_reason
        , g_interview2_success
        , g_offer_date
        , g_offer_reason
        , g_offer_success
        , g_accept_date
        , g_accept_reason
        , g_accept_success
        , l_hire_date
        , l_hire_reason
        , l_termination_date
        , l_termination_reason
        , g_separation_date
        , g_separation_reason
        , new_asg_rec.last_update_date
        , new_asg_rec.creation_date );

  END LOOP;

END populate_recruitment_table;

BEGIN

  SELECT instance_code INTO g_instance_fk
  FROM edw_local_instance;

END hri_edw_fct_recruitment;

/
