--------------------------------------------------------
--  DDL for Package Body HRI_EDW_FCT_WRK_ACTVTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_FCT_WRK_ACTVTY" AS
/* $Header: hriefwac.pkb 120.0 2005/05/29 07:10:23 appldev noship $ */


/*****************************************************************************/
/* Checks that assignment change reason is an employee change reason. When   */
/* new applicants with applicant assignment change reasons are hired the     */
/* applicant change reason gets updated into the employee assignment and     */
/* causes errors when it tries to be resolved as an employee change reason   */
/*****************************************************************************/
FUNCTION check_reason( p_change_reason  IN VARCHAR2,
                       p_instance       IN VARCHAR2 )
                        RETURN VARCHAR2 IS

  l_reason_fk       VARCHAR2(80);  -- Reason foreign key
  l_reason_code     VARCHAR2(30);  -- Reason code

  CURSOR reason_cur IS
  SELECT lookup_code
  FROM hr_lookups
  WHERE lookup_code = p_change_reason
  AND lookup_type = 'EMP_ASSIGN_REASON';

BEGIN

  OPEN reason_cur;
  FETCH reason_cur INTO l_reason_code;
  CLOSE reason_cur;

  IF (l_reason_code IS NULL) THEN
    RETURN 'NA_EDW';
  ELSE
    l_reason_fk := 'EMP_ASSIGN_REASON-' || l_reason_code || '-' || p_instance;
    RETURN l_reason_fk;
  END IF;

  RETURN 'NA_EDW';

END check_reason;

/*****************************************************************************/
/* Returns the start date of the period of service current on the date given */
/*****************************************************************************/
FUNCTION get_hire_days( p_person_id         IN NUMBER,
                        p_effective_date    IN DATE )
               RETURN DATE
IS

  l_hire_date           DATE;  -- Holds most recent start date

/* Selects the start date for the effective period of service */
  CURSOR hire_cur IS
  SELECT MAX(date_start)
  FROM per_periods_of_service
  WHERE person_id = p_person_id
  AND date_start <= p_effective_date;

BEGIN

/* Retrieve the result from the cursor */
  OPEN hire_cur;
  FETCH hire_cur INTO l_hire_date;
  CLOSE hire_cur;

  RETURN l_hire_date;

END get_hire_days;

/******************************************************************************/
/* Returns the number of days since the last organization change from the     */
/* date given. If no such change previously occurred then a null value is     */
/* returned                                                                   */
/******************************************************************************/
FUNCTION get_days_to_last_org_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER
IS

  l_last_change_date          DATE;   -- Holds last change date
  l_days_to_last_change       NUMBER; -- Converts to number of days

/* Gets the change date prior to the given change date when an */
/* organization change occurred */
  CURSOR last_org_cur IS
  SELECT MAX(asg2.effective_start_date)
  FROM
   per_all_assignments_f  asg1
  ,per_all_assignments_f  asg2
  WHERE
      asg1.assignment_id = p_assignment_id
  AND asg2.assignment_id = p_assignment_id
  AND asg1.effective_end_date + 1 = asg2.effective_start_date
  AND asg1.organization_id <> asg2.organization_id
  AND asg2.effective_start_date < p_change_date;

/* Get assignment creation date */
  CURSOR asg_start_cur IS
  SELECT MIN(asg.effective_start_date)
  FROM per_all_assignments_f asg
  WHERE asg.assignment_id = p_assignment_id
  AND asg.assignment_type = 'E';

BEGIN

/* Gets result from cursor */
  OPEN last_org_cur;
  FETCH last_org_cur INTO l_last_change_date;
  CLOSE last_org_cur;
/* If no change previously occurred use assignment start date */
  IF (l_last_change_date IS NULL) THEN
    OPEN asg_start_cur;
    FETCH asg_start_cur INTO l_last_change_date;
    CLOSE asg_start_cur;
  /* If change is assignment start, then return null */
    IF (l_last_change_date = p_change_date) THEN
      RETURN to_number(null);
    END IF;
  END IF;

/* Convert to days */
  l_days_to_last_change := p_change_date - l_last_change_date;

  RETURN l_days_to_last_change;

END get_days_to_last_org_x;

/******************************************************************************/
/* Returns the number of days since the last job change from the given date.  */
/* If no such change previously occurred then a null value is returned        */
/******************************************************************************/
FUNCTION get_days_to_last_job_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER
IS

  l_last_change_date          DATE;   -- Holds last change date
  l_days_to_last_change       NUMBER; -- Converts to number of days

/* Gets the change date prior to the given change date when an */
/* job change occurred */
  CURSOR last_job_cur IS
  SELECT MAX(asg2.effective_start_date)
  FROM
   per_all_assignments_f  asg1
  ,per_all_assignments_f  asg2
  WHERE
      asg1.assignment_id = p_assignment_id
  AND asg2.assignment_id = p_assignment_id
  AND asg1.effective_end_date + 1 = asg2.effective_start_date
  AND NVL(asg1.job_id, -1) <> NVL(asg2.job_id, -1)
  AND asg2.effective_start_date < p_change_date;

/* Get assignment creation date */
  CURSOR asg_start_cur IS
  SELECT MIN(asg.effective_start_date)
  FROM per_all_assignments_f asg
  WHERE asg.assignment_id = p_assignment_id
  AND asg.assignment_type = 'E';

BEGIN

/* Gets result from cursor */
  OPEN last_job_cur;
  FETCH last_job_cur INTO l_last_change_date;
  CLOSE last_job_cur;
/* If no change previously occurred use assignment start date */
  IF (l_last_change_date IS NULL) THEN
    OPEN asg_start_cur;
    FETCH asg_start_cur INTO l_last_change_date;
    CLOSE asg_start_cur;
  /* If change is assignment start, then return null */
    IF (l_last_change_date = p_change_date) THEN
      RETURN to_number(null);
    END IF;
  END IF;

/* Convert to days */
  l_days_to_last_change := p_change_date - l_last_change_date;

  RETURN l_days_to_last_change;

END get_days_to_last_job_x;

/******************************************************************************/
/* Returns the number of days since the last position change from the date    */
/* given. If no such change previously occurred then a null value is returned */
/******************************************************************************/
FUNCTION get_days_to_last_pos_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER
IS

  l_last_change_date          DATE;   -- Holds last change date
  l_days_to_last_change       NUMBER; -- Converts to number of days

/* Gets the change date prior to the given change date when an */
/* position change occurred */
  CURSOR last_pos_cur IS
  SELECT MAX(asg2.effective_start_date)
  FROM
   per_all_assignments_f  asg1
  ,per_all_assignments_f  asg2
  WHERE
      asg1.assignment_id = p_assignment_id
  AND asg2.assignment_id = p_assignment_id
  AND asg1.effective_end_date + 1 = asg2.effective_start_date
  AND NVL(asg1.position_id, -1) <> NVL(asg2.position_id, -1)
  AND asg2.effective_start_date < p_change_date;

/* Get assignment creation date */
  CURSOR asg_start_cur IS
  SELECT MIN(asg.effective_start_date)
  FROM per_all_assignments_f asg
  WHERE asg.assignment_id = p_assignment_id
  AND asg.assignment_type = 'E';

BEGIN

/* Gets result from cursor */
  OPEN last_pos_cur;
  FETCH last_pos_cur INTO l_last_change_date;
  CLOSE last_pos_cur;
/* If no change previously occurred use assignment start date */
  IF (l_last_change_date IS NULL) THEN
    OPEN asg_start_cur;
    FETCH asg_start_cur INTO l_last_change_date;
    CLOSE asg_start_cur;
  /* If change is assignment start, then return null */
    IF (l_last_change_date = p_change_date) THEN
      RETURN to_number(null);
    END IF;
  END IF;

/* Convert to days */
  l_days_to_last_change := p_change_date - l_last_change_date;

  RETURN l_days_to_last_change;

END get_days_to_last_pos_x;

/******************************************************************************/
/* Returns the number of days since the last grade change from the date given */
/* If no such change previously occurred then a null value is returned.       */
/******************************************************************************/
FUNCTION get_days_to_last_grd_x( p_assignment_id     IN NUMBER,
                                 p_person_id         IN NUMBER,
                                 p_change_date       IN DATE )
            RETURN NUMBER
IS

  l_last_change_date          DATE;   -- Holds last change date
  l_days_to_last_change       NUMBER; -- Converts to number of days

/* Gets the change date prior to the given change date when an */
/* grade change occurred */
  CURSOR last_grd_cur IS
  SELECT MAX(asg2.effective_start_date)
  FROM
   per_all_assignments_f  asg1
  ,per_all_assignments_f  asg2
  WHERE
      asg1.assignment_id = p_assignment_id
  AND asg2.assignment_id = p_assignment_id
  AND asg1.effective_end_date + 1 = asg2.effective_start_date
  AND NVL(asg1.grade_id, -1) <> NVL(asg2.grade_id, -1)
  AND asg2.effective_start_date < p_change_date;

/* Get assignment creation date */
  CURSOR asg_start_cur IS
  SELECT MIN(asg.effective_start_date)
  FROM per_all_assignments_f asg
  WHERE asg.assignment_id = p_assignment_id
  AND asg.assignment_type = 'E';

BEGIN

/* Gets result from cursor */
  OPEN last_grd_cur;
  FETCH last_grd_cur INTO l_last_change_date;
  CLOSE last_grd_cur;
/* If no change previously occurred use assignment start date */
  IF (l_last_change_date IS NULL) THEN
    OPEN asg_start_cur;
    FETCH asg_start_cur INTO l_last_change_date;
    CLOSE asg_start_cur;
  /* If change is assignment start, then return null */
    IF (l_last_change_date = p_change_date) THEN
      RETURN to_number(null);
    END IF;
  END IF;

/* Convert to days */
  l_days_to_last_change := p_change_date - l_last_change_date;

  RETURN l_days_to_last_change;

END get_days_to_last_grd_x;

/******************************************************************************/
/* Returns the number of days since the last geography change from the date   */
/* given. If no such change previously occurred then a null value is returned */
/******************************************************************************/
FUNCTION get_days_to_last_geog_x( p_assignment_id     IN NUMBER,
                                  p_person_id         IN NUMBER,
                                  p_change_date       IN DATE )
            RETURN NUMBER
IS

  l_last_change_date          DATE;   -- Holds last change date
  l_days_to_last_change       NUMBER; -- Converts to number of days

/* Gets the change date prior to the given change date when an */
/* geography change occurred */
  CURSOR last_geog_cur IS
  SELECT MAX(asg2.effective_start_date)
  FROM
   per_all_assignments_f  asg1
  ,per_all_assignments_f  asg2
  WHERE
      asg1.assignment_id = p_assignment_id
  AND asg2.assignment_id = p_assignment_id
  AND asg1.effective_end_date + 1 = asg2.effective_start_date
  AND NVL(asg1.location_id, -1) <> NVL(asg2.location_id, -1)
  AND asg2.effective_start_date < p_change_date;

/* Get assignment creation date */
  CURSOR asg_start_cur IS
  SELECT MIN(asg.effective_start_date)
  FROM per_all_assignments_f asg
  WHERE asg.assignment_id = p_assignment_id
  AND asg.assignment_type = 'E';

BEGIN

/* Gets result from cursor */
  OPEN last_geog_cur;
  FETCH last_geog_cur INTO l_last_change_date;
  CLOSE last_geog_cur;
/* If no change previously occurred use assignment start date */
  IF (l_last_change_date IS NULL) THEN
    OPEN asg_start_cur;
    FETCH asg_start_cur INTO l_last_change_date;
    CLOSE asg_start_cur;
  /* If change is assignment start, then return null */
    IF (l_last_change_date = p_change_date) THEN
      RETURN to_number(null);
    END IF;
  END IF;

/* Convert to days */
  l_days_to_last_change := p_change_date - l_last_change_date;

  RETURN l_days_to_last_change;

END get_days_to_last_geog_x;

END hri_edw_fct_wrk_actvty;

/
