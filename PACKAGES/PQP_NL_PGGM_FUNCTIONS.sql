--------------------------------------------------------
--  DDL for Package PQP_NL_PGGM_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_NL_PGGM_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pqpnlpgg.pkh 120.3 2006/08/29 17:23:46 sashriva noship $ */

g_pkg_name   varchar2(80) := 'pqp_nl_pggm_functions.';

TYPE r_version_info IS RECORD
(version_id NUMBER);

TYPE t_version_info is TABLE OF r_version_info
INDEX BY BINARY_INTEGER;

g_version_info t_version_info;

-- ----------------------------------------------------------------------------
-- |------------------------<CHECK_ELIGIBILITY >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION CHECK_ELIGIBILITY
         (p_date_earned       IN  DATE
         ,p_business_group_id IN  NUMBER
         ,p_person_age        IN  NUMBER
         ,p_pension_type_id   IN  NUMBER
         ,p_eligible          OUT NOCOPY NUMBER
         ,p_err_message       OUT NOCOPY VARCHAR2
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |------------------------<GET_CONTRIBUTION >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_CONTRIBUTION
         (p_assignment_id     IN  NUMBER
         ,p_date_earned       IN  DATE
         ,p_business_group_id IN  NUMBER
         ,p_ee_or_total       IN  NUMBER
         ,p_pension_type_id   IN  NUMBER
         ,p_contrib_value     OUT NOCOPY NUMBER
         ,p_err_message       OUT NOCOPY VARCHAR2
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |------------------------<GET_PENSION_BASIS >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_PENSION_BASIS
         (p_payroll_action_id    IN  NUMBER
	 ,p_date_earned          IN  DATE
         ,p_business_group_id    IN  NUMBER
         ,p_person_age           IN  NUMBER
         ,p_pension_type_id      IN  NUMBER
         ,p_pension_salary       IN  NUMBER
         ,p_part_time_percentage IN  NUMBER
         ,p_pension_basis        OUT NOCOPY NUMBER
         ,p_err_message          OUT NOCOPY VARCHAR2
         ,p_avlb_thld            IN  OUT NOCOPY NUMBER
         ,p_used_thld            IN  OUT NOCOPY NUMBER
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------------<DO_PRORATION >---------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION DO_PRORATION
         (p_assignment_id     IN  NUMBER
	 ,p_payroll_action_id IN  NUMBER
         ,p_period_start_date IN  DATE
         ,p_period_end_date   IN  DATE
         ,p_dedn_amount       IN  OUT NOCOPY NUMBER
         ,p_err_message       OUT NOCOPY VARCHAR2
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |------------------------<GET_PENSION_SALARY >------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_PENSION_SALARY
         (p_assignment_id        IN  NUMBER
         ,p_date_earned          IN  DATE
         ,p_business_group_id    IN  NUMBER
         ,p_payroll_id           IN  NUMBER
         ,p_period_start_date    IN  DATE
         ,p_period_end_date      IN  DATE
         ,p_scale_salary         IN  NUMBER
         ,p_scale_salary_h       IN  NUMBER
         ,p_scale_salary_e       IN  NUMBER
         ,p_ft_rec_payments      IN  NUMBER
         ,p_ft_rec_payments_h    IN  NUMBER
         ,p_ft_rec_payments_e    IN  NUMBER
         ,p_pt_rec_payments      IN  NUMBER
         ,p_pt_rec_payments_h    IN  NUMBER
         ,p_pt_rec_payments_e    IN  NUMBER
         ,p_salary_balance_value OUT NOCOPY NUMBER
         ,p_err_message          OUT NOCOPY VARCHAR2
         ,p_err_message1         OUT NOCOPY VARCHAR2
         ,p_err_message2         OUT NOCOPY VARCHAR2
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |----------------------<GET_PART_TIME_PERCENTAGE >--------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION GET_PART_TIME_PERCENTAGE
         (p_assignment_id        IN  NUMBER
	 ,p_payroll_action_id    IN  NUMBER
  	 ,p_date_earned          IN  DATE
         ,p_business_group_id    IN  NUMBER
         ,p_period_start_date    IN  DATE
         ,p_period_end_date      IN  DATE
         ,p_override_value       IN  NUMBER
         ,p_parental_leave       IN  VARCHAR2
         ,p_extra_hours          IN  NUMBER
         ,p_hours_worked         OUT NOCOPY NUMBER
         ,p_total_hours          OUT NOCOPY NUMBER
         ,p_part_time_percentage OUT NOCOPY NUMBER
         ,p_err_message          OUT NOCOPY VARCHAR2
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |----------------------<GET_INCI_WKR_CODE >--------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_INCI_WKR_CODE
         (p_assignment_id         IN  NUMBER
          ,p_business_group_id    IN  NUMBER
	  ,p_date_earned          IN  DATE
	  ,p_result_value         OUT NOCOPY VARCHAR2
          ,p_err_message          OUT NOCOPY VARCHAR2
         )
RETURN NUMBER;

END PQP_NL_PGGM_FUNCTIONS;

/
