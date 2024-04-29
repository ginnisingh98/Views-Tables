--------------------------------------------------------
--  DDL for Package Body HR_DISCOVERER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DISCOVERER" AS
/* $Header: hrdiscov.pkb 115.2 2003/12/18 05:29:47 prasharm ship $ */
--
FUNCTION time_in
 (p_assignment_id IN NUMBER
 ,p_mode          IN VARCHAR2
 ,p_terminate     IN VARCHAR2 DEFAULT NULL
 )
RETURN NUMBER
IS
l_number NUMBER                := NULL;
--
-- declaring function variables
--
l_assignment_id NUMBER         := NULL;
l_organization_id NUMBER       := NULL;
l_job_id NUMBER                := NULL;
l_position_id NUMBER           := NULL;
l_grade_id NUMBER              := NULL;
l_location_id NUMBER           := NULL;
l_service_date_start DATE      := NULL;
l_date_start DATE              := NULL;
l_actual_termination_date DATE := NULL;
l_change_date DATE             := NULL;
--
-- cursor to select an assignment as of sysdate
--
CURSOR c_get_1 IS
  SELECT a.organization_id,
         a.job_id,
         a.position_id,
         a.grade_id,
         a.location_id,
         b.date_start,
         SYSDATE
    FROM per_periods_of_service b,
         per_assignments_f a
   WHERE (TRUNC(SYSDATE)
         BETWEEN TRUNC(a.effective_start_date)
         AND     TRUNC(a.effective_end_date))
     AND a.assignment_id        = p_assignment_id
     AND a.period_of_service_id = b.period_of_service_id
     AND ROWNUM                 = 1;
--
-- cursor to select an assignment which has ended before sysdate
--
CURSOR c_get_2 IS
  SELECT a.organization_id,
         a.job_id,
         a.position_id,
         a.grade_id,
         a.location_id,
         b.date_start,
         b.actual_termination_date
    FROM per_periods_of_service      b,
         per_assignment_status_types c,
         per_assignments_f           a
   WHERE (TRUNC(SYSDATE)                 > TRUNC(a.effective_end_date))
         AND a.assignment_id             = p_assignment_id
         AND a.period_of_service_id      = b.period_of_service_id
         AND a.assignment_status_type_id = c.assignment_status_type_id
         AND c.per_system_status         = 'ACTIVE_ASSIGN'
         AND a.effective_end_date        = b.actual_termination_date
         AND TRUNC(b.final_process_date)
           = TRUNC(b.actual_termination_date)
         AND ROWNUM                      = 1;
--
BEGIN
--
-- selection modes SERVICE, ORGANIZATION, JOB, POSITION, GRADE, LOCATION
--
 IF p_terminate = 'TERMINATE' THEN
  SELECT a.organization_id,
         a.job_id,
         a.position_id,
         a.grade_id,
         a.location_id,
         b.date_start,
         b.actual_termination_date
    INTO l_organization_id,
         l_job_id,
         l_position_id,
         l_grade_id,
         l_location_id,
         l_service_date_start,
         l_actual_termination_date
    FROM per_periods_of_service      b,
         per_assignments_f           a,
         per_assignment_status_types c
   WHERE a.assignment_id             = p_assignment_id
     AND a.period_of_service_id      = b.period_of_service_id
     AND a.assignment_status_type_id = c.assignment_status_type_id
     AND ROWNUM                      = 1
     AND ((TRUNC(SYSDATE)             >= TRUNC(a.effective_start_date)
       AND c.per_system_status         = 'TERM_ASSIGN')
       OR (TRUNC(SYSDATE)              > TRUNC(a.effective_end_date)
       AND b.final_process_date        = b.actual_termination_date
       AND c.per_system_status         = 'ACTIVE_ASSIGN')
       OR (TRUNC(SYSDATE)
         BETWEEN TRUNC(a.effective_start_date)
             AND TRUNC(a.effective_end_date))
       AND c.per_system_status        not in ('ACTIVE_ASSIGN','TERM_ASSIGN'));
 ELSE
    OPEN  c_get_1;
    FETCH c_get_1
    INTO l_organization_id,
         l_job_id,
         l_position_id,
         l_grade_id,
         l_location_id,
         l_service_date_start,
         l_actual_termination_date;
         IF c_get_1%NOTFOUND THEN
            OPEN  c_get_2;
            FETCH c_get_2
            INTO l_organization_id,
                 l_job_id,
                 l_position_id,
                 l_grade_id,
                 l_location_id,
                 l_service_date_start,
                 l_actual_termination_date;
            CLOSE c_get_2;
         END IF;
    CLOSE c_get_1;
 END IF;
--
--
-- MODE SERVICE
--
-- identify time in service
--
 IF l_actual_termination_date IS NOT NULL THEN
  IF p_mode = 'SERVICE' THEN
--
    l_date_start := l_service_date_start;
--
-- MODE ORGANIZATION
--
-- identify time in organization
--
  ELSIF p_mode = 'ORGANIZATION' THEN
--
   SELECT MIN(ass.effective_start_date)
   INTO   l_date_start
   FROM   per_assignments_f     ass
   WHERE  ass.organization_id = l_organization_id
   AND    ass.assignment_id   = p_assignment_id
   AND    ass.assignment_type = 'E'
   AND    NOT EXISTS
    (
    SELECT null
    FROM   per_assignments_f ass1
    WHERE  ass1.assignment_id        = ass.assignment_id
    AND    NVL(ass1.organization_id,9.9)+0  = NVL(ass.organization_id,9.9)+0
    AND    ass1.effective_start_date =
           (
            SELECT MAX(ass2.effective_start_date)
            FROM   per_assignments_f ass2
            WHERE  ass2.assignment_id        = ass1.assignment_id
            AND    ass2.effective_start_date < ass.effective_start_date
           )
    AND    ass1.assignment_type = 'E'
    )
   AND    ass.business_group_id+0=
          NVL(hr_bis.get_sec_profile_bg_id, ass.business_group_id);  /* changed for bug 3294224 */
--
-- checking for organization changes
--
   SELECT MAX(cass.effective_end_date+1)
   INTO  l_change_date
   FROM  per_assignments_f cass
   WHERE cass.assignment_id         = p_assignment_id
   AND   cass.organization_id      <> l_organization_id
   AND   cass.effective_start_date  > l_date_start
   AND   cass.effective_end_date   <  l_actual_termination_date;
--
-- MODE JOB
--
-- identify time in job
--
  ELSIF p_mode = 'JOB' THEN
--
   SELECT MIN(ass.effective_start_date)
   INTO   l_date_start
   FROM   per_assignments_f     ass
   WHERE  ass.job_id          = l_job_id
   AND    ass.assignment_id   = p_assignment_id
   AND    ass.assignment_type = 'E'
   AND NOT EXISTS
    (
    SELECT null
    FROM   per_assignments_f ass1
    WHERE  ass1.assignment_id      = ass.assignment_id
    AND    NVL(ass1.job_id,9.9)+0  = NVL(ass.job_id,9.9)+0
    AND    ass1.effective_start_date =
           (
            SELECT MAX(ass2.effective_start_date)
            FROM   per_assignments_f ass2
            WHERE  ass2.assignment_id        = ass1.assignment_id
            AND    ass2.effective_start_date < ass.effective_start_date
           )
    AND    ass1.assignment_type  = 'E'
    )
   AND  ass.business_group_id+0=
     NVL(hr_bis.get_sec_profile_bg_id, ass.business_group_id);        /* changed for bug 3294224 */
--
-- checking for job changes
--
   SELECT MAX(cass.effective_end_date+1)
   INTO  l_change_date
   FROM  per_assignments_f cass
   WHERE cass.assignment_id         = p_assignment_id
   AND   cass.job_id               <> l_job_id
   AND   cass.effective_start_date  > l_date_start
   AND   cass.effective_end_date   <  l_actual_termination_date;
--
-- MODE POSITION
--
-- identify time in position
--
  ELSIF p_mode = 'POSITION' THEN
--
   SELECT MIN(ass.effective_start_date)
   INTO   l_date_start
   FROM   per_assignments_f         ass
   WHERE  ass.position_id     = l_position_id
   AND    ass.assignment_id   = p_assignment_id
   AND    ass.assignment_type = 'E'
   AND NOT EXISTS
    (
    SELECT null
    FROM   per_assignments_f       ass1
    WHERE  ass1.assignment_id      = ass.assignment_id
    AND    NVL(ass1.position_id,9.9)+0 =
           NVL(ass.position_id,9.9)+0
    AND    ass1.effective_start_date =
           (
            SELECT MAX(ass2.effective_start_date)
            FROM   per_assignments_f ass2
            WHERE  ass2.assignment_id        = ass1.assignment_id
            AND    ass2.effective_start_date < ass.effective_start_date
           )
    AND    ass1.assignment_type = 'E'
    )
   AND  ass.business_group_id+0=
     NVL(hr_bis.get_sec_profile_bg_id, ass.business_group_id);  /* changed for bug 3294224 */
--
-- checking for position changes
--
   SELECT MAX(cass.effective_end_date+1)
   INTO  l_change_date
   FROM  per_assignments_f cass
   WHERE cass.assignment_id        = p_assignment_id
   AND   cass.position_id         <> l_position_id
   AND   cass.effective_start_date > l_date_start
   AND   cass.effective_end_date  <  l_actual_termination_date;
--
-- MODE GRADE
--
-- identify time in grade
--
  ELSIF p_mode = 'GRADE' THEN
--
   SELECT MIN(ass.effective_start_date)
   INTO   l_date_start
   FROM   per_assignments_f     ass
   WHERE  ass.grade_id        = l_grade_id
   AND    ass.assignment_id   = p_assignment_id
   AND    ass.assignment_type = 'E'
   AND NOT EXISTS
    (
    SELECT null
    FROM   per_assignments_f ass1
    WHERE  ass1.assignment_id        = ass.assignment_id
    AND    NVL(ass1.grade_id,9.9)+0  = NVL(ass.grade_id,9.9)+0
    AND    ass1.effective_start_date =
           (
            SELECT MAX(ass2.effective_start_date)
            FROM   per_assignments_f ass2
            WHERE  ass2.assignment_id        = ass1.assignment_id
            AND    ass2.effective_start_date < ass.effective_start_date
           )
    AND    ass1.assignment_type = 'E'
    )
    AND  ass.business_group_id+0=
     NVL(hr_bis.get_sec_profile_bg_id, ass.business_group_id);  /* changed for bug 3294224 */
--
-- checking for grade changes
--
   SELECT MAX(cass.effective_end_date+1)
   INTO  l_change_date
   FROM  per_assignments_f cass
   WHERE cass.assignment_id        = p_assignment_id
   AND   cass.grade_id            <> l_grade_id
   AND   cass.effective_start_date > l_date_start
   AND   cass.effective_end_date  <  l_actual_termination_date;
--
-- MODE LOCATION
--
-- identify time in location
--
  ELSIF p_mode = 'LOCATION' THEN
--
   SELECT MIN(ass.effective_start_date)
   INTO   l_date_start
   FROM   per_assignments_f     ass
   WHERE  ass.location_id     = l_location_id
   AND    ass.assignment_id   = p_assignment_id
   AND    ass.assignment_type = 'E'
   AND NOT EXISTS
    (
    SELECT null
    FROM   per_assignments_f ass1
    WHERE  ass1.assignment_id        = ass.assignment_id
    AND    NVL(ass1.location_id,9.9)+0  =
           NVL(ass.location_id,9.9)+0
    AND    ass1.effective_start_date =
           (
            SELECT MAX(ass2.effective_start_date)
            FROM   per_assignments_f ass2
            WHERE  ass2.assignment_id        = ass1.assignment_id
            AND    ass2.effective_start_date < ass.effective_start_date
           )
    AND    ass1.assignment_type = 'E'
    )
   AND  ass.business_group_id+0=
     NVL(hr_bis.get_sec_profile_bg_id, ass.business_group_id);      /* changed for bug 3294224 */
--
-- checking for location changes
--
   SELECT MAX(cass.effective_end_date+1)
   INTO  l_change_date
   FROM  per_assignments_f cass
   WHERE cass.assignment_id        = p_assignment_id
   AND   cass.location_id         <> l_location_id
   AND   cass.effective_start_date > l_date_start
   AND   cass.effective_end_date  <  l_actual_termination_date;
  END IF;
--
-- if there have been more recent changes then update
-- the start date with that of the most recent change
--
  IF l_change_date IS NOT NULL THEN
    l_date_start := l_change_date;
  END IF;
--
-- FOR ASSIGNMENT(SERVICE):
-- calculate months between the start date of the assignment
-- and sysdate or termination date whichever is earliest.
-- FOR ORGANIZATION, JOB, POSITION, GRADE, LOCATION
-- calculate months between the start date of the organization
-- job, position, grade or location and the end of the organization
-- job, position, grade or location or sysdate whichever is earliest
--
  IF TRUNC(l_actual_termination_date) < TRUNC(SYSDATE) THEN
    l_number :=
    TRUNC(MONTHS_BETWEEN(TRUNC(l_actual_termination_date+1),
                         TRUNC(l_date_start)));
  ELSE
     l_number :=
     TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE+1),
                          TRUNC(l_date_start)));
  END IF;
 END IF;
RETURN l_number;
END time_in;
--
-- function over 70 check
--
--
-- this function checks to see if a person is over 70 years of age
-- it returns 1 for true and 0 for false.
--
FUNCTION over_70_check
(p_date_of_birth IN DATE
)
RETURN NUMBER IS
l_number NUMBER;
--
BEGIN
--
 IF (TRUNC((SYSDATE-p_date_of_birth)/365)) > 70
 THEN
  l_number := 1;
 ELSE
  l_number := 0;
 END IF;
RETURN l_number;
END over_70_check;
--
-- function end_date
--
-- this function checks to see if a date is equivalent to the end of time
-- if this is true it will return null.
--
FUNCTION check_end_date
(p_end_date IN DATE
)
RETURN DATE IS
l_end_date DATE;
--
BEGIN
--
 IF p_end_date = hr_general.end_of_time THEN
  l_end_date := NULL;
 ELSE
  l_end_date := p_end_date;
 END IF;
--
RETURN l_end_date;
--
END check_end_date;
--
-- this function get the actual budget values
--
FUNCTION get_actual_budget_values
(p_unit              IN VARCHAR2,
 p_bus_group_id      IN NUMBER,
 p_organization_id   IN NUMBER,
 p_job_id            IN NUMBER,
 p_position_id       IN NUMBER,
 p_grade_id          IN NUMBER,
 p_start_date        IN DATE,
 p_end_date          IN DATE,
 p_actual_val        IN NUMBER
)
RETURN NUMBER IS
l_actual_end_val NUMBER;
l_actual_start_val NUMBER;
l_variance_amount  NUMBER;
l_variance_percent VARCHAR2(240);
--
BEGIN
hrgetact.get_actuals(p_unit,
                     p_bus_group_id,
                     p_organization_id,
                     p_job_id,
                     p_position_id,
                     p_grade_id,
                     p_start_date,
                     p_end_date,
                     p_actual_val,
                     l_actual_start_val,
                     l_actual_end_val,
                     l_variance_amount,
                     l_variance_percent);
 return l_actual_end_val;
END get_actual_budget_values;
--
END hr_discoverer;

/
