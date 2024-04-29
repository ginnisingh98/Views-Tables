--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_DISC_RCTMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_DISC_RCTMNT" AS
/* $Header: hriodrec.pkb 120.0 2005/05/29 07:28:35 appldev noship $ */

/******************************************************************************/
/* This function returns the number of applicants who have been hired into a  */
/* vacancy                                                                    */
/******************************************************************************/
FUNCTION get_vacancy_hire_count(p_vacancy          IN VARCHAR2,
                                p_business_group   IN VARCHAR2,
                                p_requisition      IN VARCHAR2,
                                p_applicant_number IN VARCHAR2)
RETURN NUMBER IS
  --
  l_v_hires    NUMBER;
  --
BEGIN
  --
  SELECT COUNT(p.person_id)
  INTO  l_v_hires
  FROM  hr_all_organization_units b,
        per_requisitions          r,
        per_all_vacancies         v,
        per_all_assignments_f     a,
        per_all_people_f          p
  WHERE TRUNC(SYSDATE) BETWEEN p.effective_start_date
                          AND p.effective_end_date
/* bug 2033292 */
  AND    TRUNC(SYSDATE) BETWEEN a.effective_start_date
            AND a.effective_end_date
/* bug 2033292 */
  AND   p.employee_number IS NOT NULL
  AND   p.person_id        = a.person_id
  AND   a.vacancy_id       = v.vacancy_id
  AND   v.name             = p_vacancy
  AND   v.requisition_id   = r.requisition_id
  AND   r.name             = p_requisition
  AND   b.organization_id  = v.business_group_id
  AND   b.organization_id  = b.business_group_id
  AND   a.assignment_type  = 'E'
  AND   b.name             = p_business_group;
  --
  RETURN l_v_hires;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_vacancy_hire_count;


/******************************************************************************/
/* This function returns the number of applicants who have been made an offer */
/* for a vacancy                                                              */
/******************************************************************************/
FUNCTION get_vacancy_offer_count(p_vacancy        IN VARCHAR2,
                                 p_business_group IN VARCHAR2,
                                 p_requisition    IN VARCHAR2)
RETURN NUMBER IS
  --
  l_v_offers NUMBER;
  --
BEGIN
  --
  SELECT COUNT(p.person_id)
  INTO  l_v_offers
  FROM  hr_all_organization_units   b,
        per_assignment_status_types ast,
        per_requisitions            r,
        per_all_vacancies           v,
        per_all_assignments_f       a,
        per_all_people_f            p
  WHERE TRUNC(SYSDATE) BETWEEN p.effective_start_date
                       AND p.effective_end_date
/* bug 2033292 */
  AND    TRUNC(SYSDATE) BETWEEN a.effective_start_date
            AND a.effective_end_date
/* bug 2033292 */
  AND   p.applicant_number IS NOT NULL
  AND   p.person_id           = a.person_id
  AND   a.assignment_type     = 'A'
  AND   a.assignment_status_type_id =
        ast.assignment_status_type_id
  AND   ast.per_system_status = 'OFFER'
  AND   a.vacancy_id          = v.vacancy_id
  AND   v.name                = p_vacancy
  AND   v.requisition_id      = r.requisition_id
  AND   r.name                = p_requisition
  AND   b.organization_id     = v.business_group_id
  AND   b.organization_id     = b.business_group_id
  AND   b.name                = p_business_group;
  --
  RETURN l_v_offers;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_vacancy_offer_count;


/******************************************************************************/
/* This function returns the number of applicants who have been hired via the */
/* recruitment activity                                                       */
/******************************************************************************/
FUNCTION get_rec_act_hire_count(p_rec_activity     IN VARCHAR2,
                                p_business_group   IN VARCHAR2,
                                p_applicant_number IN VARCHAR2)
                        RETURN NUMBER IS
  --
  l_ra_hires NUMBER;
  --
BEGIN
  --
  SELECT COUNT(p.person_id)
  INTO   l_ra_hires
  FROM   hr_all_organization_units  b,
         per_recruitment_activities r,
         per_all_assignments_f      a,
         per_all_people_f           p
  WHERE  TRUNC(SYSDATE) BETWEEN p.effective_start_date
                            AND p.effective_end_date
/* bug 2033292 */
  AND    TRUNC(SYSDATE) BETWEEN a.effective_start_date
            AND a.effective_end_date
/* bug 2033292 */
  AND    p.employee_number IS NOT NULL
  AND    p.person_id               = a.person_id
  AND    a.recruitment_activity_id = r.recruitment_activity_id
  AND    r.name                    = p_rec_activity
  AND    b.organization_id         = r.business_group_id
  AND    b.organization_id         = b.business_group_id
  AND    a.assignment_type         = 'E'
  AND    b.name                    = p_business_group;
  --
  RETURN l_ra_hires;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_rec_act_hire_count;


/******************************************************************************/
/* This function returns the number of applicants who have been made offers   */
/* via the recruitment activity                                               */
/******************************************************************************/
FUNCTION get_rec_act_offer_count(p_rec_activity   IN VARCHAR2,
                                 p_business_group IN VARCHAR2)
RETURN NUMBER IS
  --
  l_ra_offers NUMBER;
  --
BEGIN
  --
  SELECT COUNT(p.person_id)
  INTO   l_ra_offers
  FROM   hr_all_organization_units   b,
         per_assignment_status_types ast,
         per_recruitment_activities  r,
         per_all_assignments_f       a,
         per_all_people_f            p
  WHERE  TRUNC(SYSDATE) BETWEEN p.effective_start_date
                            AND p.effective_end_date
/* bug 2033292 */
  AND    TRUNC(SYSDATE) BETWEEN a.effective_start_date
            AND a.effective_end_date
/* bug 2033292 */
  AND    p.applicant_number IS NOT NULL
  AND    p.person_id               = a.person_id
  AND    a.assignment_type         = 'A'
  AND    a.assignment_status_type_id =
         ast.assignment_status_type_id
  AND    ast.per_system_status     = 'OFFER'
  AND    a.recruitment_activity_id = r.recruitment_activity_id
  AND    r.name                    = p_rec_activity
  AND    b.organization_id         = r.business_group_id
  AND    b.organization_id         = b.business_group_id
  AND    b.name                    = p_business_group;
  --
  RETURN l_ra_offers;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_rec_act_offer_count;


/******************************************************************************/
/* This function returns the number of applicants who have been hired into    */
/* the vacancy via the recruitment activity                                   */
/******************************************************************************/
FUNCTION get_rec_act_vac_hire_count(p_rec_activity     IN VARCHAR2,
                                    p_vacancy          IN VARCHAR2,
                                    p_business_group   IN VARCHAR2,
                                    p_applicant_number IN VARCHAR2)
RETURN NUMBER IS
  --
  l_rav_hires NUMBER;
  --
BEGIN
  --
  SELECT COUNT(p.person_id)
  INTO   l_rav_hires
  FROM   hr_all_organization_units  b,
         per_all_vacancies          v,
         per_recruitment_activities r,
         per_all_assignments_f      a,
         per_all_people_f           p
  WHERE  TRUNC(SYSDATE) BETWEEN p.effective_start_date
                            AND p.effective_end_date
/* bug 2033292 */
  AND    TRUNC(SYSDATE) BETWEEN a.effective_start_date
            AND a.effective_end_date
/* bug 2033292 */
  AND    p.employee_number IS NOT NULL
  AND    p.person_id               = a.person_id
  AND    a.vacancy_id              = v.vacancy_id
  AND    a.recruitment_activity_id = r.recruitment_activity_id
  AND    v.name                    = p_vacancy
  AND    r.name                    = p_rec_activity
  AND    b.organization_id         = v.business_group_id
  AND    b.organization_id         = r.business_group_id
  AND    b.organization_id         = b.business_group_id
  AND    a.assignment_type         = 'E'
  AND    b.name                    = p_business_group;
  --
  RETURN l_rav_hires;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_rec_act_vac_hire_count;


/******************************************************************************/
/* This function returns the number of applicants who have been made offers   */
/* for the vacancy via the recruitment activity                               */
/******************************************************************************/
FUNCTION get_rec_act_vac_offer_count(p_rec_activity   IN VARCHAR2,
                                     p_vacancy        IN VARCHAR2,
                                     p_business_group IN VARCHAR2)
RETURN NUMBER IS
  --
  l_rav_offers NUMBER;
  --
BEGIN
  --
  SELECT COUNT(p.person_id)
  INTO   l_rav_offers
  FROM   hr_all_organization_units   b,
         per_assignment_status_types ast,
         per_all_vacancies           v,
         per_recruitment_activities  r,
         per_all_assignments_f       a,
         per_all_people_f            p
  WHERE  TRUNC(SYSDATE) BETWEEN p.effective_start_date
                            AND p.effective_end_date
/* bug 2033292 */
  AND    TRUNC(SYSDATE) BETWEEN a.effective_start_date
            AND a.effective_end_date
/* bug 2033292 */
  AND    p.applicant_number IS NOT NULL
  AND    p.person_id       = a.person_id
  AND    a.assignment_type = 'A'
  AND    a.assignment_status_type_id =
         ast.assignment_status_type_id
  AND    ast.per_system_status       = 'OFFER'
  AND    a.recruitment_activity_id   = r.recruitment_activity_id
  AND    a.vacancy_id      = v.vacancy_id
  AND    r.name            = p_rec_activity
  AND    v.name            = p_vacancy
  AND    b.organization_id = r.business_group_id
  AND    b.organization_id = v.business_group_id
  AND    b.organization_id = b.business_group_id
  AND    b.name            = p_business_group;
  --
  RETURN l_rav_offers;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_rec_act_vac_offer_count;


/******************************************************************************/
/* This function returns the hiring cost per head of hiring employees who are */
/* still employed                                                             */
/******************************************************************************/
FUNCTION get_hiring_cost_current_emp(p_rec_act_id  IN NUMBER,
                                     p_actual_cost IN NUMBER)
RETURN NUMBER IS
  --
  l_cost       NUMBER;
  l_emp_count  INTEGER;
  --
BEGIN
  --
  -- Count number of current emps hired through the recruitment activity
  --
  SELECT COUNT(person_id)
  INTO l_emp_count
  FROM per_all_assignments_f a
  WHERE TRUNC(SYSDATE) BETWEEN a.effective_start_date AND a.effective_end_date
  AND a.assignment_type = 'E'
  AND a.recruitment_activity_id = p_rec_act_id;
  --
  IF l_emp_count = 0 THEN
    l_cost := NULL;
  ELSE
    l_cost := p_actual_cost / l_emp_count;
  END IF;
  --
  RETURN l_cost;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN 0; -- Default vacancy hire count to 0
    --
END get_hiring_cost_current_emp;

/******************************************************************************/
/* This function returns 'Y' if the vacancy is currently active and 'N'       */
/* otherwise                                                                  */
/******************************************************************************/
FUNCTION check_active_vacancy(p_date_from     IN DATE,
                              p_date_to       IN DATE)
RETURN VARCHAR2 IS
  --
  CURSOR check_vacancy IS
  SELECT 'Y'
  FROM dual
  WHERE TRUNC(SYSDATE) BETWEEN p_date_from
                       AND NVL(p_date_to,SYSDATE);
  --
  l_active_flag VARCHAR2(1) := 'N';
  --
BEGIN
  --
  OPEN check_vacancy;
  FETCH check_vacancy INTO l_active_flag;
  CLOSE check_vacancy;
  --
  RETURN l_active_flag;
  --
EXCEPTION
  --
  WHEN OTHERS
  THEN
    --
    RETURN ''; -- Default vacancy hire count to 0
    --
END check_active_vacancy;
--
END hri_oltp_disc_rctmnt;

/
