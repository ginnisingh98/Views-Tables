--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_WRKFRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_WRKFRC" AUTHID CURRENT_USER AS
/* $Header: hriodwrk.pkh 115.3 2003/08/04 04:57:06 cbridge noship $ */


FUNCTION get_formula_id(p_business_group_id    IN NUMBER
                       ,p_formula_name         IN VARCHAR2)
             RETURN NUMBER;

FUNCTION get_manpower_formula_id(p_business_group_id       IN NUMBER
                                ,p_budget_measurement_code IN VARCHAR2)
              RETURN NUMBER;

FUNCTION get_ff_actual_value(p_budget_id         IN NUMBER
                            ,p_formula_id        IN NUMBER
                            ,p_grade_id          IN NUMBER DEFAULT NULL
                            ,p_job_id            IN NUMBER DEFAULT NULL
                            ,p_organization_id   IN NUMBER DEFAULT NULL
                            ,p_position_id       IN NUMBER DEFAULT NULL
                            ,p_time_period_id    IN NUMBER)
             RETURN NUMBER;

FUNCTION get_asg_budget_value(p_budget_metric_formula_id  IN NUMBER
                             ,p_budget_metric             IN VARCHAR2
                             ,p_assignment_id             IN NUMBER
                             ,p_effective_date            IN DATE
                             ,p_session_date              IN DATE )
               RETURN NUMBER;

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
RETURN NUMBER;

FUNCTION direct_reports
(p_person_id            IN NUMBER
,p_effective_start_date IN DATE
,p_effective_end_date   IN DATE)
RETURN NUMBER;

FUNCTION calc_abv_lookup(p_assignment_id     IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_bmt_meaning       IN VARCHAR2,
                         p_effective_date    IN DATE)
          RETURN NUMBER;

FUNCTION calc_abv_lookup(p_assignment_id     IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_bmt_meaning       IN VARCHAR2,
                         p_effective_date    IN DATE,
                         p_primary_flag      IN VARCHAR2)
          RETURN NUMBER;

-- cbridge 09-JAN-02, new function for ADA
-- returns actuals for a given PQH budget on a effective_date
-- required to replace Organization Budgets HTML report in Disco.
FUNCTION get_ff_actual_value_pqh
(p_budget_id            IN NUMBER
,p_business_group_id    IN NUMBER
,p_grade_id             IN NUMBER       DEFAULT NULL
,p_job_id               IN NUMBER       DEFAULT NULL
,p_organization_id      IN NUMBER       DEFAULT NULL
,p_position_id          IN NUMBER       DEFAULT NULL
,p_effective_date       IN DATE
,p_budget_metric        IN VARCHAR2
)
RETURN NUMBER;

-- bug 2527147, new function to determine months of service.
FUNCTION get_period_service_in_months(p_person_id IN NUMBER
                                     ,p_period_of_service_id IN NUMBER
                                     ,p_effective_date IN DATE) RETURN NUMBER;

-- bug 2527147, new function to determine years of service.
FUNCTION get_period_service_in_years(p_person_id IN NUMBER
                                     ,p_period_of_service_id IN NUMBER
                                     ,p_effective_date IN DATE) RETURN NUMBER;


END hri_oltp_disc_wrkfrc;

 

/
