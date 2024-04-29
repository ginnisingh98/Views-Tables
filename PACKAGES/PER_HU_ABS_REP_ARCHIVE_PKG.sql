--------------------------------------------------------
--  DDL for Package PER_HU_ABS_REP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_HU_ABS_REP_ARCHIVE_PKG" AUTHID CURRENT_USER AS
/* $Header: pehuarep.pkh 115.3 2004/05/10 23:52:40 srjanard noship $ */
--
FUNCTION get_parameter(
                   p_parameter_string   IN VARCHAR2
                  ,p_token              IN VARCHAR2
                      ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
FUNCTION get_abs_rep_parameter(
                   p_actid              IN  NUMBER
                      ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
PROCEDURE get_all_parameters(
                   p_payroll_action_id  IN         NUMBER
                  ,p_business_group_id  OUT NOCOPY NUMBER
                  ,p_effective_date     OUT NOCOPY DATE
                  ,p_reporting_date     OUT NOCOPY DATE
                  ,p_payroll_id         OUT NOCOPY NUMBER
                  ,p_assignment_set_id  OUT NOCOPY NUMBER
                  ,p_employee_id        OUT NOCOPY NUMBER
                     );
--------------------------------------------------------------------------------
PROCEDURE range_code(
                   p_actid              IN  NUMBER
                  ,sqlstr               OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE action_creation_code(
                   p_actid              IN  NUMBER
                  ,stperson             IN  NUMBER
                  ,endperson            IN  NUMBER
                  ,chunk                IN  NUMBER);
--------------------------------------------------------------------------------
FUNCTION get_children_info(
                   p_assignment_id      IN  NUMBER
                  ,p_business_group_id  IN  NUMBER
                  ,p_start_date         IN  DATE
                  ,p_end_date           IN  DATE
                  ,p_no_child_less_16   OUT NOCOPY NUMBER
                  ,p_no_child_16        OUT NOCOPY NUMBER
                  ,p_child_dob1         OUT NOCOPY DATE
                  ,p_child_dob2         OUT NOCOPY DATE
                  ,p_child_dob3         OUT NOCOPY DATE
                           ) RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION get_payroll_Period (
                   p_payroll_id          IN  NUMBER
                  ,p_calculation_date    IN  DATE
                  ,p_accrual_frequency   OUT NOCOPY VARCHAR2
                  ,p_accrual_multiplier  OUT NOCOPY NUMBER
                             ) RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION working_day_count (
                   p_assignment_id       IN NUMBER
                  ,p_business_group_id   IN NUMBER
                  ,p_start_date          IN DATE
                  ,p_end_date            IN DATE
                            ) RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION get_person_dob    (
                   p_assignment_id       IN  NUMBER
                  ,p_calculation_date    IN  DATE
                           ) RETURN DATE;
--------------------------------------------------------------------------------
FUNCTION get_prev_emp_sickness_leave(
                   p_assignment_id       IN  NUMBER
                  ,p_business_group_id   IN  NUMBER
                  ,p_termination_year    IN  VARCHAR2
                  ,p_prev_emp            OUT NOCOPY VARCHAR2
                            )RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION get_disability(
                   p_assignment_id        IN NUMBER
                  ,p_business_group_id    IN NUMBER
                  ,p_period_start_date    IN DATE
                  ,p_period_end_date      IN DATE
                           ) RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION get_job_info(
                   p_assignment_id        IN NUMBER
                  ,p_business_group_id    IN NUMBER
                  ,p_period_start_date    IN DATE
                  ,p_period_end_date      IN DATE
                           ) RETURN NUMBER;
--------------------------------------------------------------------------------
FUNCTION chk_entry_in_accrual_plan(
                   p_entry_val            IN  VARCHAR2
                  ,p_message              OUT NOCOPY VARCHAR2
                           ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
END PER_HU_ABS_REP_ARCHIVE_PKG;

 

/
