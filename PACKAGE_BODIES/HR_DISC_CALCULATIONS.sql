--------------------------------------------------------
--  DDL for Package Body HR_DISC_CALCULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DISC_CALCULATIONS" AS
/* $Header: hrdicalc.pkb 115.26 2002/08/22 09:21:39 jtitmas ship $ */


/***********************/
/* RECRUITMENT SECTION */
/***********************/

/******************************************************************************/
/* This function returns the number of applicants who have been hired into a  */
/* vacancy                                                                    */
/******************************************************************************/
FUNCTION vacancy_hires(p_vacancy          IN VARCHAR2,
                       p_business_group   IN VARCHAR2,
                       p_requisition      IN VARCHAR2,
                       p_applicant_number IN VARCHAR2)
               RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_vacancy_hire_count
                        (p_vacancy => p_vacancy,
                         p_business_group => p_business_group,
                         p_requisition => p_requisition,
                         p_applicant_number => p_applicant_number);

  RETURN l_return_value;

END vacancy_hires;


/******************************************************************************/
/* This function returns the number of applicants who have been made an offer */
/* for a vacancy                                                              */
/******************************************************************************/
FUNCTION vacancy_offers(p_vacancy        IN VARCHAR2,
                        p_business_group IN VARCHAR2,
                        p_requisition    IN VARCHAR2)
                RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_vacancy_offer_count
                        (p_vacancy => p_vacancy,
                         p_business_group => p_business_group,
                         p_requisition => p_requisition);

  RETURN l_return_value;

END vacancy_offers;


/******************************************************************************/
/* This function returns the number of applicants who have been hired via the */
/* recruitment activity                                                       */
/******************************************************************************/
  FUNCTION rec_activity_hires(p_rec_activity     IN VARCHAR2,
                              p_business_group   IN VARCHAR2,
                              p_applicant_number IN VARCHAR2)
                       RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_rec_act_hire_count
                        (p_rec_activity => p_rec_activity,
                         p_business_group => p_business_group,
                         p_applicant_number => p_applicant_number);

  RETURN l_return_value;

END rec_activity_hires;


/******************************************************************************/
/* This function returns the number of applicants who have been made offers   */
/* via the recruitment activity                                               */
/******************************************************************************/
FUNCTION rec_activity_offers(p_rec_activity   IN VARCHAR2,
                             p_business_group IN VARCHAR2)
                       RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_rec_act_offer_count
                        (p_rec_activity => p_rec_activity,
                         p_business_group => p_business_group);

  RETURN l_return_value;

END rec_activity_offers;


/******************************************************************************/
/* This function returns the number of applicants who have been hired into    */
/* the vacancy via the recruitment activity                                   */
/******************************************************************************/
FUNCTION rec_activity_vacancy_hires(p_rec_activity     IN VARCHAR2,
                                    p_vacancy          IN VARCHAR2,
                                    p_business_group   IN VARCHAR2,
                                    p_applicant_number IN VARCHAR2)
                            RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_rec_act_vac_hire_count
                        (p_rec_activity => p_rec_activity,
                         p_vacancy => p_vacancy,
                         p_business_group => p_business_group,
                         p_applicant_number => p_applicant_number);

  RETURN l_return_value;

END rec_activity_vacancy_hires;


/******************************************************************************/
/* This function returns the number of applicants who have been made offers   */
/* for the vacancy via the recruitment activity                               */
/******************************************************************************/
FUNCTION rec_activity_vacancy_offers(p_rec_activity   IN VARCHAR2,
                                     p_vacancy        IN VARCHAR2,
                                     p_business_group IN VARCHAR2)
                             RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_rec_act_vac_offer_count
                        (p_rec_activity => p_rec_activity,
                         p_vacancy => p_vacancy,
                         p_business_group => p_business_group);

  RETURN l_return_value;

END rec_activity_vacancy_offers;


/******************************************************************************/
/* This function returns the hiring cost per head of hiring employees who are */
/* still employed                                                             */
/******************************************************************************/
FUNCTION hiring_cost_current_emp(p_rec_act_id  IN NUMBER,
                                 p_actual_cost IN NUMBER)
                          RETURN NUMBER IS

  l_return_value         NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.get_hiring_cost_current_emp
                        (p_rec_act_id => p_rec_act_id,
                         p_actual_cost => p_actual_cost);

  RETURN l_return_value;

END hiring_cost_current_emp;

/* function active_vacancy */

FUNCTION active_vacancy(  p_date_from     IN DATE,
                          p_date_to       IN DATE)
                          RETURN VARCHAR2 IS

  l_return_value         VARCHAR2(30);

BEGIN

  l_return_value := hri_oltp_disc_rctmnt.check_active_vacancy
                        (p_date_from => p_date_from,
                         p_date_to => p_date_to);

  RETURN l_return_value;

END active_vacancy;


/*********************/
/* WORKFORCE SECTION */
/*********************/

/******************************************************************************/
/* Public function to determine the appropriate FastFormula Id to be used for */
/* calculating manpower actuals                                               */
/******************************************************************************/
FUNCTION get_manpower_formula_id(p_business_group_id       IN NUMBER
                                ,p_budget_measurement_code IN VARCHAR2)
             RETURN NUMBER IS

  l_return_value         VARCHAR2(30);

BEGIN

  l_return_value := hri_oltp_disc_wrkfrc.get_manpower_formula_id
                      (p_business_group_id => p_business_group_id,
                       p_budget_measurement_code => p_budget_measurement_code);

  RETURN l_return_value;

END get_manpower_formula_id;


/******************************************************************************/
/* Public function to calculate manpower actuals for a single assignment      */
/******************************************************************************/
FUNCTION get_ff_actual_value(p_budget_id         IN NUMBER
                            ,p_formula_id        IN NUMBER
                            ,p_grade_id          IN NUMBER DEFAULT NULL
                            ,p_job_id            IN NUMBER DEFAULT NULL
                            ,p_organization_id   IN NUMBER DEFAULT NULL
                            ,p_position_id       IN NUMBER DEFAULT NULL
                            ,p_time_period_id    IN NUMBER)
             RETURN NUMBER IS

  l_return_value        NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_wrkfrc.get_ff_actual_value
                       (p_budget_id => p_budget_id,
                        p_formula_id => p_formula_id,
                        p_grade_id => p_grade_id,
                        p_job_id => p_job_id,
                        p_organization_id => p_organization_id,
                        p_position_id => p_position_id,
                        p_time_period_id => p_time_period_id);

  RETURN l_return_value;

END get_ff_actual_value;


/********************/
/* TRAINING SECTION */
/********************/

/******************************************************************************/
/* Public function to calculate the Budget Cost of a training event           */
/******************************************************************************/
FUNCTION get_event_budget_cost(p_event_id      IN NUMBER)
               RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_event_budget_cost
           (p_event_id => p_event_id);

  RETURN l_return_value;

END get_event_budget_cost;


/******************************************************************************/
/* Public function to calculate the Actual Cost of a training event           */
/******************************************************************************/
FUNCTION get_event_actual_cost(p_event_id    IN NUMBER)
                   RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_event_actual_cost
           (p_event_id => p_event_id);

  RETURN l_return_value;

END get_event_actual_cost;


/******************************************************************************/
/* Public function to calculate the Total Revenue generated by a training     */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_event_revenue(p_event_id    IN NUMBER)
              RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_event_revenue
           (p_event_id => p_event_id);

  RETURN l_return_value;

END get_event_revenue;


/******************************************************************************/
/* Private function to calculate the Internal Revenue generated by a training */
/* event for a particular delegate booking where the delegate attended the    */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_att_int_rev_booking(p_event_id       IN NUMBER,
                                 p_booking_id     IN NUMBER)
                    RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_att_int_rev_booking
           (p_event_id => p_event_id,
            p_booking_id => p_booking_id);

  RETURN l_return_value;

END get_att_int_rev_booking;


/******************************************************************************/
/* Private function to calculate the External Revenue generated by a training */
/* event for a particular delegate booking where the delegate attended the    */
/* event                                                                      */
/******************************************************************************/
FUNCTION get_att_ext_rev_booking(p_event_id    IN NUMBER,
                                 p_booking_id  IN NUMBER)
              RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_att_ext_rev_booking
           (p_event_id => p_event_id,
            p_booking_id => p_booking_id);

  RETURN l_return_value;

END get_att_ext_rev_booking;


/******************************************************************************/
/* Private function to calculate the Internal Revenue generated by a training */
/* event for a particular delegate booking where the delegate did not attend  */
/* the event                                                                  */
/******************************************************************************/
FUNCTION get_non_att_int_rev_booking(p_event_id     IN NUMBER,
                                     p_booking_id   IN NUMBER)
                 RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_non_att_int_rev_booking
           (p_event_id => p_event_id,
            p_booking_id => p_booking_id);

  RETURN l_return_value;

END get_non_att_int_rev_booking;


/******************************************************************************/
/* Private function to calculate the External Revenue generated by a training */
/* event for a particular delegate booking where the delegate did not attend  */
/* the event                                                                  */
/******************************************************************************/
FUNCTION get_non_att_ext_rev_booking(p_event_id     IN NUMBER,
                                     p_booking_id   IN NUMBER)
                RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.get_non_att_ext_rev_booking
           (p_event_id => p_event_id,
            p_booking_id => p_booking_id);

  RETURN l_return_value;

END get_non_att_ext_rev_booking;


/******************************************************************************/
/* Public function to convert Training Duration FROM one set of units to      */
/* another                                                                    */
/******************************************************************************/
FUNCTION training_convert_duration(p_formula_id              IN NUMBER
                                  ,p_from_duration           IN NUMBER
                                  ,p_from_duration_units     IN VARCHAR2
                                  ,p_to_duration_units       IN VARCHAR2
                                  ,p_activity_version_name   IN VARCHAR2
                                  ,p_event_name              IN VARCHAR2
                                  ,p_session_date            IN DATE)
                  RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_training.convert_training_duration
               (p_formula_id => p_formula_id,
                p_from_duration => p_from_duration,
                p_from_duration_units => p_from_duration_units,
                p_to_duration_units => p_to_duration_units,
                p_activity_version_name => p_activity_version_name,
                p_event_name => p_event_name,
                p_session_date => p_session_date);

  RETURN l_return_value;

END training_convert_duration;


/******************************************************************************/
/* Public function to determine the Id of a FastFormula                       */
/******************************************************************************/
FUNCTION get_formula_id(p_business_group_id   IN NUMBER
                       ,p_formula_name        IN VARCHAR2)
             RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_wrkfrc.get_formula_id
               (p_business_group_id => p_business_group_id,
                p_formula_name => p_formula_name);

  RETURN l_return_value;

END get_formula_id;


/******************************************************************************/
/* Function to get an assignment budget value for an assignment               */
/******************************************************************************/
FUNCTION get_asg_budget_value(p_budget_metric_formula_id  IN NUMBER
                             ,p_budget_metric             IN VARCHAR2
                             ,p_assignment_id             IN NUMBER
                             ,p_effective_date            IN DATE
                             ,p_session_date              IN DATE )
               RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_wrkfrc.get_asg_budget_value
               (p_budget_metric_formula_id => p_budget_metric_formula_id,
                p_budget_metric => p_budget_metric,
                p_assignment_id => p_assignment_id,
                p_effective_date => p_effective_date,
                p_session_date => p_session_date);

  RETURN l_return_value;

END get_asg_budget_value;


/******************************************************************************/
/* cbridge, 28/06/2001 , pqh budgets support function for                     */
/* hrfv_workforce_budgets business view                                       */
/* Public function to calculate workforce actuals for a single assignment     */
/* using new PQH budgets schema model                                         */
/* bug enhancement 1317484                                                    */
/******************************************************************************/
FUNCTION get_ff_actual_value_pqh
(p_budget_id            IN NUMBER
,p_business_group_id    IN NUMBER
,p_grade_id             IN NUMBER       DEFAULT NULL
,p_job_id               IN NUMBER       DEFAULT NULL
,p_organization_id      IN NUMBER       DEFAULT NULL
,p_position_id          IN NUMBER       DEFAULT NULL
,p_time_period_id       IN NUMBER
,p_budget_metric        IN VARCHAR2
)
RETURN NUMBER IS

  l_return_value           NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_wrkfrc.get_ff_actual_value_pqh
                          (p_budget_id => p_budget_id,
                           p_business_group_id => p_business_group_id,
                           p_grade_id => p_grade_id,
                           p_job_id => p_job_id,
                           p_organization_id => p_organization_id,
                           p_position_id => p_position_id,
                           p_time_period_id => p_time_period_id,
                           p_budget_metric => p_budget_metric);

  RETURN l_return_value;

END get_ff_actual_value_pqh;


/******************************************************************************/
/* Function returning the number of direct reports for a person on a date     */
/******************************************************************************/
FUNCTION direct_reports
(p_person_id            IN NUMBER
,p_effective_start_date IN DATE
,p_effective_end_date   IN DATE)
RETURN NUMBER IS

  l_return_value    NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_wrkfrc.direct_reports
                             (p_person_id => p_person_id,
                              p_effective_start_date => p_effective_start_date,
                              p_effective_end_date => p_effective_end_date);

  RETURN l_return_value;

END direct_reports;


/******************/
/* SALARY SECTION */
/******************/

/******************************************************************************/
/* This function will return the previous salary proposal of a given          */
/* pay_proposal_id, it is called from the Oracle Internal workbooks that      */
/* display previous salary.                                                   */
/*                                                                            */
/* The function was found to be the most performant way of returning an       */
/* employees previous salary proposal amount for a given employees            */
/* pay_proposal_id.                                                           */
/******************************************************************************/
FUNCTION get_prev_salary_pro_amount(p_pay_proposal_id   NUMBER)
                RETURN NUMBER IS

  l_return_value    NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_salary.get_prev_salary_pro_amount
                             (p_pay_proposal_id => p_pay_proposal_id);

  RETURN l_return_value;

END get_prev_salary_pro_amount;


/******************************************************************************/
/* Gets the annual salary for an assignment on a given date                   */
/******************************************************************************/
FUNCTION get_annual_salary_as_of_date(p_effective_date    DATE
                                    , p_assignment_id     NUMBER)
             RETURN NUMBER IS

  l_return_value    NUMBER;

BEGIN

  l_return_value := hri_oltp_disc_salary.get_annual_salary_as_of_date
                             (p_effective_date => p_effective_date,
                              p_assignment_id => p_assignment_id);

  RETURN l_return_value;

END get_annual_salary_as_of_date;

END hr_disc_calculations;

/
