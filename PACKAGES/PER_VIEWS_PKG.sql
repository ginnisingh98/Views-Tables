--------------------------------------------------------
--  DDL for Package PER_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VIEWS_PKG" AUTHID CURRENT_USER as
/* $Header: peronvew.pkh 120.0.12010000.3 2008/08/06 09:35:57 ubhat ship $ */

/* ==========================================================================
   FUNCTION NAME : per_get_grade_step
   DESCRIPTION   : Function to get the Grade Step from the Grade Step
                   Placement Information.
   ========================================================================*/
function PER_GET_GRADE_STEP
           (  p_grade_spine_id        NUMBER,
              p_step_id               NUMBER,
              p_parent_spine_id       NUMBER,
              p_effective_start_date  DATE
           )
return number ;
pragma restrict_references(PER_GET_GRADE_STEP, WNDS, WNPS);


/* ==========================================================================
   FUNCTION NAME : per_calc_comparatio
   DESCRIPTION   : Function to Calculate the Salary Comparatio for a given
                   assignment.
   ========================================================================*/
function PER_CALC_COMPARATIO
             ( p_assignment_id          NUMBER,
               p_change_date            DATE,
               p_actual_salary          NUMBER,
               p_element_entry_id       NUMBER,
               p_normal_hours           NUMBER,
               p_org_working_hours      NUMBER,
               p_pos_working_hours      NUMBER,
               p_org_frequency          VARCHAR2,
               p_pos_frequency          VARCHAR2,
               p_number_per_fiscal_year NUMBER,
               p_grade_id               NUMBER,
               p_rate_id                NUMBER,
               p_pay_basis              VARCHAR2,
               p_rate_basis             VARCHAR2,
               p_business_group_id      NUMBER
             )
             return number ;
--changes for bug 5945278 starts here
--pragma restrict_references(PER_CALC_COMPARATIO, WNDS, WNPS);
--changes for bug 5945278 ends here
/* ========================================================================
   FUNCTION NAME : per_get_parent_org
   DESCRIPTION   : Function to get the Parent Organization of a given
                   Organization in the specified hierarchy version.
   ========================================================================*/
function PER_GET_PARENT_ORG
                      ( p_org_child                  number,
                        p_level                      number,
                        p_business_group_id          number,
                        p_org_structure_version_id   number
                      )
                      return number  ;
pragma restrict_references(PER_GET_PARENT_ORG, WNDS, WNPS);

/* ========================================================================
   FUNCTION NAME : per_get_effective_end_date
   DESCRIPTION   : Function to get the effective end date of an assignment
                   from the assignment history view.
   ========================================================================*/
function PER_GET_EFFECTIVE_END_DATE
               ( p_assignment_id    number,
                 p_effective_start_date  date
               )
               return date ;
--pragma restrict_references(PER_GET_EFFECTIVE_END_DATE, WNDS, WNPS);

/* ========================================================================
   FUNCTION NAME : per_get_organization_employees
   DESCRIPTION   : Function to get the number of employees working in the
                   specified organization.
   ========================================================================*/
function PER_GET_ORGANIZATION_EMPLOYEES
               ( p_organization_id   number
               )
               return number ;
pragma restrict_references(PER_GET_ORGANIZATION_EMPLOYEES,WNDS,WNPS) ;

/* ========================================================================
   FUNCTION NAME : per_get_element_accrual
   DESCRIPTION   : Function to get the accrued value of a particular element
                   of an accrual plan for an assignment.
   ========================================================================*/
FUNCTION per_get_element_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_input_value_id       number,
                      P_plan_id              number   DEFAULT NULL,
                      P_plan_category        varchar2 DEFAULT NULL)
         RETURN Number;
pragma restrict_references(per_get_element_accrual, WNDS, WNPS);

/* ========================================================================
   FUNCTION NAME : per_get_accrual
   DESCRIPTION   : Function to get the current accrued balance value for an
                   assignment.
   ========================================================================*/
FUNCTION per_get_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   DEFAULT NULL,
                      P_plan_category        varchar2 DEFAULT NULL)
         RETURN Number;
pragma restrict_references(per_get_accrual, WNDS, WNPS);

/* ========================================================================
   PROCEDURE NAME :  per_accrual_calc_detail
   DESCRIPTION    :  Procedure called by all the accrual functions to
                     calculate accrual dates and value for an assignment.
   ========================================================================*/
PROCEDURE per_accrual_calc_detail
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT NOCOPY   date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual                OUT NOCOPY   number,
               P_payroll_id          IN OUT NOCOPY   number,
               P_first_period_start  IN OUT NOCOPY   date,
               P_first_period_end    IN OUT NOCOPY   date,
               P_last_period_start   IN OUT NOCOPY   date,
               P_last_period_end     IN OUT NOCOPY   date,
               P_cont_service_date      OUT NOCOPY   date,
               P_start_date             OUT NOCOPY   date,
               P_end_date               OUT NOCOPY   date,
               P_current_ceiling        OUT NOCOPY   number,
               P_current_carry_over     OUT NOCOPY   number);
pragma restrict_references(per_accrual_calc_detail, WNDS, WNPS);

/* ========================================================================
   PROCEDURE NAME :  per_get_accrual_for_plan
   DESCRIPTION    :  Procedure called by the accrual functions to calculate
                     tha accrued value for a particular plan.
   ========================================================================*/
PROCEDURE per_get_accrual_for_plan
                    ( p_plan_id                 Number,
                      p_first_p_start_date      date,
                      p_first_p_end_date        date,
                      p_first_calc_P_number     number,
                      p_accrual_calc_p_end_date date,
                      P_accrual_calc_P_number   number,
                      P_number_of_periods       number,
                      P_payroll_id              number,
                      P_assignment_id           number,
                      P_plan_ele_type_id        number,
                      P_continuous_service_date date,
                      P_Plan_accrual            OUT NOCOPY number,
                      P_current_ceiling         OUT NOCOPY number,
                      P_current_carry_over      OUT NOCOPY number );
pragma restrict_references(per_get_accrual_for_plan, WNDS, WNPS);

/* ========================================================================
   FUNCTION NAME : per_get_working_days
   DESCRIPTION   : Function to get the number of working days between the
                   dates in the given range.
   ========================================================================*/
FUNCTION per_get_working_days
                    ( P_start_date           date,
                      P_end_date             date )
         RETURN   NUMBER;
pragma restrict_references(per_get_working_days, WNDS, WNPS);

/* ========================================================================
   FUNCTION NAME : per_get_net_accrual
   DESCRIPTION   : Function to get the total accrured balance for a given
                   assignment.
   ========================================================================*/
FUNCTION per_get_net_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   default null,
                      P_plan_category        Varchar2 default null)
         RETURN   NUMBER;
pragma restrict_references(per_get_net_accrual, WNDS, WNPS);

/* ========================================================================
   PROCEDURE NAME : per_net_accruals
   DESCRIPTION    : Procedure called by the PER_NET_ACCRUALS function to
                    calculate the total accrued balance.
   ========================================================================*/
PROCEDURE per_net_accruals
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT NOCOPY   date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual             IN OUT NOCOPY   number,
               P_net_accrual            OUT NOCOPY   number,
               P_payroll_id          IN OUT NOCOPY   number,
               P_first_period_start  IN OUT NOCOPY   date,
               P_first_period_end    IN OUT NOCOPY   date,
               P_last_period_start   IN OUT NOCOPY   date,
               P_last_period_end     IN OUT NOCOPY   date,
               P_cont_service_date      OUT NOCOPY   date,
               P_start_date          IN OUT NOCOPY   date,
               P_end_date            IN OUT NOCOPY   date,
               P_current_ceiling        OUT NOCOPY   number,
               P_current_carry_over     OUT NOCOPY   number);
pragma restrict_references(per_net_accruals, WNDS, WNPS);
--
end PER_VIEWS_PKG ;

/
