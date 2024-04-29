--------------------------------------------------------
--  DDL for Package HR_PTO_VIEWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PTO_VIEWS" AUTHID CURRENT_USER AS
/* $Header: hrptovws.pkh 120.0 2005/05/31 02:23 appldev noship $ */
--
-- Package global variables
--
    TYPE g_per_acc_plan_rec_type IS RECORD
    (plan_id               pay_accrual_plans.accrual_plan_id%TYPE
    ,plan_name             pay_accrual_plans.accrual_plan_name%TYPE
    ,UOM                   pay_accrual_plans.ACCRUAL_UNITS_OF_MEASURE%TYPE
    ,assignment_id         per_all_assignments_f.assignment_id%TYPE
    ,net_entitlement_ytd   number
    ,gross_accruals_ytd    number
    ,gross_accruals_ptd    number
    ,plan_element_entry_id pay_element_entries_f.element_entry_id%TYPE
    ,ee_start_date         date
    );

    TYPE g_per_acc_plan_tab_type IS TABLE OF g_per_acc_plan_rec_type
    	INDEX BY BINARY_INTEGER;
-- ---------------------------------------------------------------------- +
--                      Get_pto_ytd_net_entitlement
-- ---------------------------------------------------------------------- +
-- Returns the latest balance Year to date
-- This considers all the net calculation rules.
--
PROCEDURE Get_pto_ytd_net_entitlement(
 		     p_assignment_id        number
          ,p_plan_id              number
          ,p_calculation_date     date
          ,p_net_entitlement      OUT nocopy number
          ,p_last_accrual_date    OUT nocopy date);
-- ---------------------------------------------------------------------- +
--                       Get_pto_ytd_gross
-- ---------------------------------------------------------------------- +
-- Calculates the GROSS amount Year to Date
-- This returns the number of units accrued year to date as of last
-- accrual date. This does not consider any net calculation rule.
--
PROCEDURE Get_pto_ytd_gross(
 		     p_assignment_id        number
          ,p_plan_id              number
          ,p_calculation_date     date
          ,p_gross_accruals       OUT nocopy number
          ,p_last_accrual_date    OUT nocopy date);
-- ---------------------------------------------------------------------- +
--                     Get_pto_ptd_gross
-- ---------------------------------------------------------------------- +
-- Calculates the GROSS amount Period to Date
-- This returns the number of units accrued for a period as of
-- last accrual date.
--
PROCEDURE  Get_pto_ptd_gross
               (p_assignment_id        number
               ,p_plan_id              number
               ,p_calculation_date     date
               ,p_gross_accruals       OUT nocopy number
               ,p_last_accrual_date    OUT nocopy date);
--
-- ---------------------------------------------------------------------- +
--                  Get_pto_all_plans
-- ---------------------------------------------------------------------- +
-- Returns a list of plans associated with a person as of calculation date.
-- A PL/SQL table is returned and the following amounts are calculated:
--    + net entitlement year to date
--    + gross accruals year to date
--    + gross accruals period to date
--
FUNCTION Get_pto_all_plans(
            p_person_id            number
           ,p_calculation_date    date)   RETURN g_per_acc_plan_tab_type;
--
-- ---------------------------------------------------------------------- +
--                       Get_pto_stored_balance
-- ---------------------------------------------------------------------- +
-- Returns stored balance based on assignment action ID
-- Pre-requisites: defined balance ID exists for the plan and assignment
--                 action ID is not null
-- Returns stored balance, otherwise NULL
--
FUNCTION Get_pto_stored_balance(
           p_assignment_action_id number
          ,p_plan_id              number)    RETURN NUMBER;
--
END HR_PTO_VIEWS;

 

/
