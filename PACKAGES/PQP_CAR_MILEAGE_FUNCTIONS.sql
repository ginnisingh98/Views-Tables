--------------------------------------------------------
--  DDL for Package PQP_CAR_MILEAGE_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_CAR_MILEAGE_FUNCTIONS" AUTHID CURRENT_USER AS
--REM $Header: pqgbcmfn.pkh 120.2.12010000.1 2008/07/28 11:10:57 appldev ship $


TYPE r_ses_date is RECORD  (asg_id per_assignments_f.assignment_id%TYPE,
                            start_index number(3),start_date date,
                             end_index number(3),end_date date);
TYPE t_ses_date IS TABLE OF r_ses_date INDEX BY BINARY_INTEGER;
l_ses_date t_ses_date;

ses_start number;
ses_end number;

--Function get_legislation_code
----------------------------------------------------------------------------

FUNCTION get_legislation_code (p_business_group_id IN NUMBER)
RETURN VARCHAR2;
-----------------------------------------------------------------------------
-- PQP_GET_RANGE
-----------------------------------------------------------------------------
FUNCTION  pqp_get_range(       p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_table_name         IN  VARCHAR2
                              ,p_row_or_column      IN  VARCHAR2
                              ,p_value              IN  NUMBER
                              ,p_claim_date         IN  DATE
                              ,p_low_value          OUT NOCOPY NUMBER
                              ,p_high_value         OUT NOCOPY NUMBER)
RETURN NUMBER;

----------------------------------------------------------------------------
--FUNCTION get_config_info
---------------------------------------------------------------------------
FUNCTION get_config_info (p_business_group_id IN NUMBER
                         ,p_info_type         IN VARCHAR2
                          )
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- PQP_GET_ATTR_VAL
-----------------------------------------------------------------------------
FUNCTION  pqp_get_attr_val(    p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_car_type           IN  VARCHAR2
                              ,p_cc                 OUT NOCOPY NUMBER
                              ,p_rates_table        OUT NOCOPY VARCHAR2
                              ,p_calc_method        OUT NOCOPY VARCHAR2
                              ,p_error_msg          OUT NOCOPY VARCHAR2
                              ,p_claim_date         IN  DATE
                              ,p_fuel_type          OUT NOCOPY VARCHAR2
			      ,p_veh_reg           IN  VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

-----------------------------------------------------------------------------
-- PQP_GET_PERIOD
-----------------------------------------------------------------------------
FUNCTION  pqp_get_period(      p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_id         IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_claim_date         IN  DATE
                              ,p_period_num         OUT NOCOPY NUMBER)
RETURN NUMBER;

-----------------------------------------------------------------------------
-- PQP_GET_VEH_CC
-----------------------------------------------------------------------------
FUNCTION  pqp_get_veh_cc(      p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_reg_num            IN  VARCHAR2)
RETURN NUMBER;

-----------------------------------------------------------------------------
-- PQP_GET_YEAR
-----------------------------------------------------------------------------
FUNCTION  pqp_get_year(        p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_claim_date         IN  DATE)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- PQP_MULTIPLE_ASG
-----------------------------------------------------------------------------
FUNCTION  pqp_multiple_asg(    p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- PQP_GET_TABLE_VALUE
-----------------------------------------------------------------------------
FUNCTION pqp_get_table_value ( p_bus_group_id      IN NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_table_name        IN VARCHAR2
                              ,p_col_name          IN VARCHAR2
                              ,p_row_value         IN VARCHAR2
                              ,p_effective_date    IN DATE  DEFAULT NULL
                              ,p_error_msg         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- PQP_CHECK_RATES_TABLE
-----------------------------------------------------------------------------
FUNCTION  pqp_check_rates_table(p_business_group_id  IN  NUMBER
                               ,p_table_name         IN  VARCHAR2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- PQP_VALIDATE_DATE
-----------------------------------------------------------------------------
FUNCTION  pqp_validate_date(p_date_earned          IN  DATE
                           ,p_claim_end_date       IN  DATE)
RETURN VARCHAR2;

------------------------------------------------------------------------

--Function  Max_Limit_Calc
------------------------------------------------------------------------
 FUNCTION Max_limit_calc ( p_assignment_id    IN NUMBER
                                          ,p_bg_id            IN NUMBER
                                          ,p_payroll_action_id  IN  NUMBER
                                          ,p_prorated_mileage IN NUMBER
                                          ,p_cc               IN NUMBER
                                          ,p_claim_date       IN date
                                          ,p_total_period     IN NUMBER
                                          ,p_cl_period        IN NUMBER
                                          ,p_rates_table      IN VARCHAR2
                                          )
RETURN VARCHAR2;




--------------------------------------------------------------------------
--Function PQP_PRORATE_CALC returns prorated Amt
--------------------------------------------------------------------------
FUNCTION pqp_prorate_calc(  p_assignment_id    IN NUMBER
                                          ,p_bg_id            IN NUMBER
                                          ,p_payroll_action_id  IN  NUMBER
                                          ,p_prorated_mileage IN NUMBER
                                          ,p_cc               IN NUMBER
                                          ,p_claim_date       IN DATE
                                          ,p_total_period     IN NUMBER
                                          ,p_cl_period        IN NUMBER
                                          ,p_rates_table      IN VARCHAR2
                                          ,p_lower_pro_mileage IN NUMBER
                                          ,p_end_date          IN OUT NOCOPY VARCHAR2)
RETURN NUMBER;


--------------------------------------------------------------------------
--Procedure  PQP_GET_TAXNI_RATES Calculates Taxable and NIC liabilities
--------------------------------------------------------------------------

FUNCTION  pqp_get_taxni_rates  (  p_assignment_id           IN  NUMBER
                                 ,p_business_group_id       IN  NUMBER
                                 ,p_payroll_action_id       IN  NUMBER
                                 ,p_itd_ac_miles            IN  NUMBER
                                 ,p_actual_mileage          IN  NUMBER
                                 ,p_total_actual_mileage    IN  NUMBER
                                 ,p_ele_iram_itd            IN NUMBER
                                 ,p_cc                      IN  NUMBER
                                 ,p_claim_end_date          IN  DATE
                                 ,p_two_wheeler_type        IN  VARCHAR2
                                 ,p_wheeler_type            IN  VARCHAR2
                                 ,p_table_name              IN  VARCHAR2
                                 ,p_ele_iram_amt            OUT NOCOPY NUMBER
                                 ,p_error_mesg              OUT NOCOPY VARCHAR2)

RETURN NUMBER;


--------------------------------------------------------------------------
--Procedure  PQP_GET_ADDLPASG_RATE  Calculates Additional Passengers Rates
--------------------------------------------------------------------------
FUNCTION  PQP_GET_ADDLPASG_RATE (p_business_group_id         IN  NUMBER
                                ,p_payroll_action_id         IN  NUMBER
                                ,p_vehicle_type              IN  VARCHAR2
                                ,p_claimed_mileage           IN  NUMBER
                                ,p_itd_miles                 IN  NUMBER
                                ,p_total_passengers          IN  NUMBER
                                ,p_total_pasg_itd_val        IN  NUMBER
                                ,p_cc                        IN  NUMBER
                                ,p_rates_table               IN  VARCHAR2
                                ,p_claim_end_date            IN  DATE
                                ,p_tax_free_amt              OUT NOCOPY NUMBER
                                ,p_ni_amt                    OUT NOCOPY NUMBER
                                ,p_tax_amt                   OUT NOCOPY NUMBER
                                ,p_err_msg                   OUT NOCOPY VARCHAR2)

RETURN NUMBER ;

--------------------------------------------------------------------------
--Function PQP_GET_DATE_PAID gets date paid based on payroll action id
--------------------------------------------------------------------------
FUNCTION pqp_get_date_paid (      p_payroll_action_id          IN NUMBER)
RETURN DATE;

------------------------------------------------------------------------
--Function pqp_get_passenger_rate
-----------------------------------------------------------------------
FUNCTION  pqp_get_passenger_rate ( p_business_group_id         IN  NUMBER
                                  ,p_payroll_action_id         IN  NUMBER
                                  ,p_vehicle_type              IN  VARCHAR2
                                  ,p_claimed_mileage           IN  NUMBER
                                  ,p_cl_itd_miles              IN  NUMBER
                                  ,p_actual_mileage            IN  NUMBER
                                  ,p_ac_itd_miles              IN  NUMBER
                                  ,p_total_passengers          IN  NUMBER
                                  ,p_total_pasg_itd_val        IN  NUMBER
                                  ,p_cc                        IN  NUMBER
                                  ,p_rates_table               IN  VARCHAR2
                                  ,p_claim_end_date            IN  DATE
                                  ,p_tax_free_amt              OUT NOCOPY NUMBER
                                  ,p_ni_amt                    OUT NOCOPY NUMBER
                                  ,p_tax_amt                   OUT NOCOPY NUMBER
                                  ,p_err_msg                   OUT NOCOPY VARCHAR2)

RETURN number;

---------------------------------------------------------------
--FUNCTION pqp_get_ele_endate checks if element entry is
--end dated.
---------------------------------------------------------------
FUNCTION pqp_get_ele_endate (  p_assignment_id           IN  NUMBER
                              ,p_business_group_id       IN  NUMBER
                              ,p_payroll_action_id       IN  NUMBER
                              ,p_element_entry_id        IN  NUMBER
                             )
RETURN VARCHAR2;
---------------------------------------------------------------
---------------------------------------------------------------
--FUNCTION pqp_is_emp_term checks if employee is terminated.
---------------------------------------------------------------

FUNCTION pqp_is_emp_term  (  p_assignment_id           IN  NUMBER
                            ,p_business_group_id       IN  NUMBER
                            ,p_payroll_action_id       IN  NUMBER
                            ,p_date_earned             IN  DATE
                           )
RETURN VARCHAR2;
-----------------------------------------------------------------

-----------------------------------------------------------------
--FUNCTION get_rates_table
----------------------------------------------------------------
FUNCTION get_rates_table (p_business_group_id    IN NUMBER
                         ,p_lookup_type          IN VARCHAR2
                         ,p_additional_passenger IN NUMBER
                         )
RETURN VARCHAR2;
------------------------------------------------------------------
--FUNCTION get_vehicle_type
-----------------------------------------------------------------
FUNCTION get_vehicle_type (p_business_group_id    IN NUMBER
                          ,p_element_type_id     IN NUMBER
                          ,p_payroll_action_id   IN NUMBER
                           )
RETURN VARCHAR2;

----------------------------------------------------------------

---------------------------------------------------------------
FUNCTION is_miles_nonreimbursed
                (  p_assignment_id           IN  NUMBER
                  ,p_business_group_id       IN  NUMBER
                  ,p_payroll_action_id       IN  NUMBER
                  ,p_element_type_id         IN NUMBER
                  ,p_date_earned             IN  DATE
                  ,p_to_date               IN  DATE
                )
RETURN VARCHAR2;
END pqp_car_mileage_functions;

/
