--------------------------------------------------------
--  DDL for Package PAY_IN_TAX_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_TAX_UTILS" AUTHID CURRENT_USER AS
/* $Header: pyintxut.pkh 120.9.12010000.2 2010/03/12 07:11:55 mdubasi ship $ */

  function get_financial_year_start (p_date in date ) return date;
  function get_financial_year_end   (p_date in date ) return date ;
  function get_period_number ( p_payroll_id in pay_all_payrolls_f.payroll_id%type,
                               p_date       in date ) return number ;
  function taxable_hra(  p_assact_id              in number
                        ,p_element_entry_id       in number
                        ,p_effective_date         in date
                        ,p_pay_period_num         in number
                        ,p_hra_salary             in number
                        ,p_std_hra_salary         in number
                        ,p_hra_allowance_asg_run  in number
                        ,p_hra_allowance_asg_ytd  in number
                        ,p_std_hra_allow_asg_run  in number
                        ,p_std_hra_allow_asg_ytd  in number
                        ,p_hra_taxable_mth        out NOCOPY  number
                        ,p_hra_taxable_annual     out NOCOPY  number
                        ,p_message                out nocopy varchar2) return number;

  /* Bug:3901883 Added two more output parameters for pf and superannuation */
  /* Bug:3919215 Added p_prev_govt_ent_alw */
  function prev_emplr_details
                             (p_assignment_id in number
                             ,p_date_earned in date
                             ,p_prev_sal out nocopy number
                             ,p_prev_tds out nocopy number
                             ,p_prev_pt out nocopy number
                             ,p_prev_ent_alw out NOCOPY number
                             ,p_prev_pf OUT NOCOPY number
                             ,p_prev_super OUT NOCOPY number
                             ,p_prev_govt_ent_alw out nocopy number
                             ,p_prev_grat OUT NOCOPY NUMBER
                             ,p_prev_leave_encash OUT NOCOPY NUMBER
                             ,p_prev_retr_amt OUT NOCOPY NUMBER
                             ,p_designation OUT NOCOPY VARCHAR2
                             ,p_annual_sal OUT NOCOPY NUMBER
                             ,p_pf_number OUT NOCOPY VARCHAR2
                             ,p_pf_estab_code OUT NOCOPY VARCHAR2
                             ,p_epf_number OUT NOCOPY VARCHAR2
                             ,p_emplr_class OUT NOCOPY VARCHAR2
                             ,p_ltc_curr_block OUT NOCOPY NUMBER
                             ,p_vrs_amount OUT NOCOPY NUMBER
                             ,p_prev_sc   OUT NOCOPY NUMBER
                             ,p_prev_cess  OUT NOCOPY NUMBER
                             ,p_prev_exemp_80gg OUT NOCOPY NUMBER
                             ,p_prev_med_reimburse_amt OUT NOCOPY NUMBER
			     ,p_prev_sec_and_he_cess OUT NOCOPY NUMBER
			     ,p_prev_exemp_80ccd OUT NOCOPY NUMBER
                             ,p_prev_cghs_exemp_80d OUT NOCOPY NUMBER) Return Number;

  function other_allowance_details
                  ( p_element_type_id in number
                   ,p_date_earned in date
                   ,p_allowance_name out NOCOPY varchar2
                   ,p_allowance_category out NOCOPY varchar2
                   ,p_max_exemption_amount out NOCOPY number
                   ,p_nature_of_expense OUT NOCOPY VARCHAR2 ) Return Number;


  function get_disability_details
                 ( p_assignment_id in number
                  ,p_date_earned in date
                  ,p_disable_catg out NOCOPY varchar2
                  ,p_disable_degree out NOCOPY number
                  ,p_disable_proof out NOCOPY varchar2) Return Number;


  function get_age( p_assignment_id in number
                   ,p_date_earned in date) Return Number;

  function act_rent_paid( p_assignment_action_id in number
                         ,p_date_earned in date) Return Number;


  FUNCTION check_ee_exists(p_element_name      IN VARCHAR2
                          ,p_assignment_id     IN NUMBER
                          ,p_effective_date    IN DATE
                          ,p_element_entry_id  OUT NOCOPY NUMBER
                          ,p_start_date        OUT NOCOPY DATE
                          ,p_ee_ovn            OUT NOCOPY NUMBER
                                      )
  RETURN BOOLEAN;


  FUNCTION get_entry_earliest_start_date(p_element_entry_id IN NUMBER
                                        ,p_element_type_id  IN NUMBER
                                        ,p_assignment_id    IN NUMBER
                                        )
  RETURN DATE;


  FUNCTION get_projected_loan_perquisite(p_outstanding_balance   IN NUMBER
                                        ,p_remaining_period      IN NUMBER
                                        ,p_employee_contribution IN NUMBER
                                        ,p_interest              IN NUMBER
                                        ,p_concessional_interest IN NUMBER
                                        )
  RETURN NUMBER;

  FUNCTION get_perquisite_details
                  (p_element_type_id      IN NUMBER
                  ,p_date_earned          IN DATE
                  ,p_assignment_action_id IN NUMBER
                  ,p_assignment_id        IN NUMBER
                  ,p_business_group_id    IN NUMBER
                  ,p_element_entry_id     IN NUMBER
                  ,p_emp_status           IN VARCHAR2
                  ,p_taxable_flag         OUT NOCOPY VARCHAR2
                  ,p_exemption_amount     OUT NOCOPY NUMBER)
  RETURN NUMBER;

  FUNCTION calculate_80gg_exemption
                    (p_assact_id          IN NUMBER
                    ,p_assignment_id      IN NUMBER
                    ,p_payroll_id         IN NUMBER
                    ,p_effective_date     IN DATE
                    ,p_std_exemption      IN NUMBER
                    ,p_adj_tot_income     IN NUMBER
                    ,p_std_exem_percent   IN NUMBER
                    ,p_start_period_num   IN NUMBER
                    ,p_last_period_number IN NUMBER
                    ,p_flag               IN VARCHAR2)
  RETURN NUMBER;

  FUNCTION check_ltc_exemption
                   (p_element_type_id      IN NUMBER
                   ,p_date_earned          IN DATE
                   ,p_assignment_action_id IN NUMBER
                   ,p_assignment_id        IN NUMBER
                   ,p_element_entry_id     IN NUMBER
                   ,p_carry_over_flag      IN OUT NOCOPY VARCHAR2
                   ,p_exempted_flag        IN OUT NOCOPY VARCHAR2
  ) RETURN NUMBER;

  FUNCTION get_defined_balance
                (p_balance_type   in pay_balance_types.balance_name%type
                ,p_dimension_name in pay_balance_dimensions.dimension_name%type  )
  RETURN NUMBER;


  FUNCTION get_balance_value
        (p_assignment_action_id IN NUMBER
        ,p_balance_name         IN pay_balance_types.balance_name%TYPE
        ,p_dimension_name       IN pay_balance_dimensions.dimension_name%TYPE
        ,p_context_name         IN ff_contexts.context_name%TYPE
        ,p_context_value        IN VARCHAR2
        )  RETURN NUMBER ;


  FUNCTION get_org_id
        (p_assignment_id     IN NUMBER
        ,p_business_group_id IN NUMBER
        ,p_date              IN DATE
        ,p_org_type          IN VARCHAR2)
  RETURN NUMBER ;

  FUNCTION get_pay_periods (p_payroll_id       IN NUMBER
                           ,p_tax_unit_id      IN NUMBER
                           ,p_assignment_id    IN NUMBER
                           ,p_date_earned      IN DATE
                           ,p_period_end_date  IN DATE
 	                   ,p_termination_date IN DATE
                           ,p_period_number    IN NUMBER
                           ,p_condition        IN VARCHAR2
                           )
  RETURN NUMBER;

  FUNCTION get_income_tax(p_business_group_id  IN NUMBER
                         ,p_total_income       IN NUMBER
                         ,p_gender             IN VARCHAR2
                         ,p_age                IN NUMBER
                         ,p_pay_end_date       IN DATE
                         ,p_marginal_relief    OUT NOCOPY NUMBER
                         ,p_surcharge          OUT NOCOPY NUMBER
                         ,p_education_cess     OUT NOCOPY NUMBER
			 ,p_message            OUT NOCOPY VARCHAR2
			 ,p_sec_and_he_cess     OUT NOCOPY NUMBER)
  RETURN NUMBER ;

  FUNCTION le_start_date(p_tax_unit_id IN NUMBER
                        ,p_assignment_id IN NUMBER
                        ,p_effective_date IN DATE
                         )
  RETURN DATE;

  FUNCTION le_end_date(p_tax_unit_id IN NUMBER
                      ,p_assignment_id IN NUMBER
                      ,p_effective_date IN DATE
                       )
  RETURN DATE;

  FUNCTION get_value_on_le_start
    (p_assignment_id      IN NUMBER
    ,p_tax_unit_id        IN NUMBER
    ,p_effective_date     IN DATE
    ,p_balance_name       IN pay_balance_types.balance_name%TYPE
    ,p_dimension_name     IN pay_balance_dimensions.dimension_name%TYPE
    ,p_context_name       IN ff_contexts.context_name%TYPE
    ,p_context_value      IN VARCHAR2
    ,p_success            OUT NOCOPY VARCHAR2
    )
RETURN NUMBER;

FUNCTION prev_med_reimbursement(p_assignment_id in number
                               ,p_date_earned in date
                              )
RETURN NUMBER;

FUNCTION get_value_prev_period
    (p_assignment_id          IN NUMBER
    ,p_assignment_action_id   IN NUMBER
    ,p_payroll_action_id      IN NUMBER
    ,p_tax_unit_id            IN NUMBER
    ,p_balance_name           IN pay_balance_types.balance_name%TYPE
    ,p_le_start_date          IN DATE
    )
RETURN NUMBER;

FUNCTION get_regular_run_exists
         (p_assignment_action_id NUMBER)
RETURN VARCHAR2 ;

FUNCTION bon_section_89_relief
                          (p_business_group_id    IN NUMBER
                          ,p_total_income         IN NUMBER
                          ,p_retro_earnings_py    IN NUMBER
                          ,p_retro_allw_exempt_py IN NUMBER
                          ,p_emplr_class          IN VARCHAR2
                          ,p_retro_ent_allw_py    IN NUMBER
                          ,p_pay_end_date         IN DATE
                          ,p_tax_section_89       IN NUMBER
                          ,p_tax_Pyble_Curr_Yr    IN NUMBER
                          ,p_gender               IN VARCHAR2
                          ,p_age                  IN NUMBER)
RETURN NUMBER ;

FUNCTION bon_calculate_80g_gg
                        (p_assact_id         IN NUMBER,
                        p_assignment_id      IN NUMBER,
                        p_payroll_id         IN NUMBER,
                        p_effective_date     IN DATE,
                        p_gross_Total_Income IN NUMBER,
                        p_tot_via_exc_80gg_g IN NUMBER,
                        p_oth_inc            IN NUMBER,
                        p_80gg_periods       IN NUMBER,
                        p_start_period       IN NUMBER,
                        p_end_period         IN NUMBER,
                        p_flag               IN VARCHAR2,
                        p_exemptions_80g_ue  IN NUMBER,
                        p_exemptions_80g_le  IN NUMBER,
                        p_exemptions_80g_fp  IN NUMBER,
                        p_dedn_Sec_80GG      OUT NOCOPY NUMBER,
                        p_dedn_Sec_80G       OUT NOCOPY  NUMBER,
                        p_dedn_Sec_80G_UE    OUT NOCOPY  NUMBER,
                        p_dedn_Sec_80G_LE    OUT NOCOPY NUMBER,
                        p_Dedn_Sec_80G_FP    OUT NOCOPY NUMBER,
                        p_adj_total_income   OUT NOCOPY NUMBER)
RETURN NUMBER;

END pay_in_tax_utils ;


/
