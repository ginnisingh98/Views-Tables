--------------------------------------------------------
--  DDL for Package PAY_CN_DEDUCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_DEDUCTIONS" AUTHID CURRENT_USER AS
/* $Header: pycndedn.pkh 120.7.12010000.5 2009/08/24 13:39:33 dduvvuri ship $ */

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_SPECIAL_TAX_METHOD                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tax method for Special       --
--                  payment types based on the tax area for China       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id        NUMBER                       --
--                  p_date_earned          DATE                         --
--                  p_tax_area             VARCHAR2                     --
--                  p_special_payment_type VARCHAR2                     --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_special_tax_method ( p_assignment_id              IN  NUMBER
                                , p_date_earned                IN  DATE
                                , p_tax_area                   IN  VARCHAR2
                                , p_special_payment_type       IN  VARCHAR2
                            )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TERM_NET_ACCRUAL                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the accrued leave for the given  --
--                  accrual plan                                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id        NUMBER                       --
--                  p_payroll_id           NUMBER                       --
--                  p_business_group_id    NUMBER                       --
--                  p_calculation_date     DATE                         --
--                  p_plan_category        VARCHAR2                     --
--            OUT : p_message              VARCHAR2                     --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_term_net_accrual ( p_assignment_id     IN  NUMBER
                               ,p_payroll_id        IN  NUMBER
                               ,p_business_group_id IN  NUMBER
                               ,p_calculation_date  IN  DATE
                               ,p_plan_category     IN  VARCHAR2
                               ,p_message           OUT NOCOPY VARCHAR2
                   )
RETURN NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_CONT_BASE_METHODS                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the contribute method details    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id           NUMBER                --
--                  p_contribution_area           VARCHAR2              --
--                  p_phf_si_type                 VARCHAR2              --
--                  p_hukou_type                  VARCHAR2              --
--                  p_effective_date              DATE                  --
--            OUT : p_ee_cont_base_method         VARCHAR2              --
--                  p_er_cont_base_method         VARCHAR2              --
--                  p_low_limit_method            VARCHAR2              --
--                  p_low_limit_amount            NUMBER                --
--                  p_high_limit_method           VARCHAR2              --
--                  p_high_limit_amount           NUMBER               --
--                  p_switch_periodicity          VARCHAR2              --
--                  p_switch_month                VARCHAR2              --
--                  p_rounding_method             VARCHAR2              --
--                  p_lowest_avg_salary           NUMBER              --
--                  p_average_salary              NUMBER              --
--                  p_ee_fixed_amount             NUMBER              --
--                  p_er_fixed_amount             NUMBER              --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION  get_cont_base_methods
                 (p_business_group_id           IN   NUMBER
                 ,p_contribution_area           IN   VARCHAR2
                 ,p_phf_si_type                 IN   VARCHAR2
                 ,p_hukou_type                  IN   VARCHAR2
                 ,p_effective_date              IN   DATE
         --
                 ,p_ee_cont_base_method         OUT  NOCOPY VARCHAR2
                 ,p_er_cont_base_method         OUT  NOCOPY VARCHAR2
                 ,p_low_limit_method            OUT  NOCOPY VARCHAR2
                 ,p_low_limit_amount            OUT  NOCOPY NUMBER
                 ,p_high_limit_method           OUT  NOCOPY VARCHAR2
                 ,p_high_limit_amount           OUT  NOCOPY NUMBER
                 ,p_switch_periodicity          OUT  NOCOPY VARCHAR2
                 ,p_switch_month                OUT  NOCOPY VARCHAR2
                 ,p_rounding_method             OUT  NOCOPY VARCHAR2
                 ,p_lowest_avg_salary           OUT  NOCOPY NUMBER
                 ,p_average_salary              OUT  NOCOPY NUMBER
                 ,p_ee_fixed_amount             OUT  NOCOPY NUMBER
                 ,p_er_fixed_amount             OUT  NOCOPY NUMBER
		 ,p_tax_thrhld_amount           OUT  NOCOPY NUMBER /* added for bug 6828199 */
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_SI_RATES                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the PHF/SI Rates from Org Level  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id          IN NUMBER                  --
--                  p_contribution_area      VARCHAR2                   --
--                  p_hukou_type             VARCHAR2                   --
--                  p_legal_employer_id      NUMBER                     --
--                  p_phf_si_type            VARCHAR2                   --
--                  p_effective_date         VARCHAR2                   --
--                  p_organization_id        NUMBER                     --
--            OUT : p_ee_rate                NUMBER                     --
--                  p_er_rate                NUMBER                     --
--                  p_ee_percent_or_fixed    VARCHAR2                   --
--                  p_er_percent_or_fixed    VARCHAR2                   --
--                  p_ee_rounding_method     VARCHAR2                   --
--                  p_er_rounding_method     VARCHAR2                   --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_phf_si_rates    (p_assignment_id               IN NUMBER
                             ,p_business_group_id           IN  NUMBER
                             ,p_contribution_area           IN  VARCHAR2
                             ,p_phf_si_type                 IN  VARCHAR2
                             ,p_employer_id                 IN  VARCHAR2
                             ,p_hukou_type                  IN  VARCHAR2
                             ,p_effective_date              IN  DATE
                 --
                             ,p_ee_rate_type         OUT NOCOPY VARCHAR2
                             ,p_er_rate_type         OUT NOCOPY VARCHAR2
                             ,p_ee_rate              OUT NOCOPY NUMBER
                             ,p_er_rate              OUT NOCOPY NUMBER
			     ,p_ee_thrhld_rate       OUT NOCOPY NUMBER  /* for bug 6828199 */
			     ,p_er_thrhld_rate       OUT NOCOPY NUMBER  /* for bug 6828199 */
                             ,p_ee_rounding_method   OUT NOCOPY VARCHAR2
                             ,p_er_rounding_method   OUT NOCOPY VARCHAR2
                 )
RETURN VARCHAR2;

----------------------------------------------------------------------------
--                                                                        --
-- Name     : CALCULATE_CONTRIBUTION                                      --
-- Type     : Function                                                    --
-- Access   : Public                                                      --
-- Description  : Function to process the PHF/SI elements                 --
--                                                                        --
-- Parameters   :                                                         --
--          IN  :                                                         --
--               p_business_group_id            NUMBER                    --
--               p_element_entry_id             NUMBER                    --
--               p_assignment_action_id         NUMBER                    --
--               p_assignment_id                NUMBER                    --
--               p_date_earned                  DATE                      --
--               p_contribution_area            VARCHAR2                  --
--               p_phf_si_type                  VARCHAR2                  --
--               p_hukuo_type                   VARCHAR2                  --
--               p_employer_id                  VARCHAR2                  --
--               p_proc_end_date                DATE                      --
-- Bug 4522945:Extra input parameters added                               --
--               p_phf_si_earnings_asg_ptd      NUMBER                    --
--               p_phf_si_earnings_asg_pyear    NUMBER                    --
--               p_phf_si_earnings_asg_pmth     NUMBER                    --
--               p_taxable_earnings_asg_er_ptd  NUMBER                    --
--               p_ee_cont_base_asg_ltd         NUMBER                    --
--               p_er_cont_base_asg_ltd         NUMBER                    --
--               p_ee_deductions_asg_er_ptd     NUMBER                    --
--               p_er_deductions_asg_er_ptd     NUMBER                    --
--               p_undeducted_ee_asg_ltd        NUMBER                    --
--               p_undeducted_er_asg_ltd        NUMBER                    --
--               p_undeducted_ee_asg_er_ptd     NUMBER                    --
--               p_undeducted_er_asg_er_ptd     NUMBER                    --
-- Bug 4522945 Changes End                                                --
--       IN/OUT :                                                         --
--               p_calculation_date             DATE                      --
--               p_ee_cont_base_amount          NUMBER                    --
--               p_er_cont_base_amount          NUMBER                    --
--          OUT :                                                         --
--               p_ee_phf_si_amount             NUMBER                    --
--               p_er_phf_si_amount             NUMBER                    --
--               p_undeducted_ee_phf_si_amount  NUMBER                    --
--               p_undeducted_er_phf_si_amount  NUMBER                    --
--               p_new_ee_cont_base_amount      NUMBER                    --
--               p_new_er_cont_base_amount      NUMBER                    --
--       RETURN : VARCHAR2                                                --
----------------------------------------------------------------------------
FUNCTION calculate_contribution(
                  p_business_group_id                IN       NUMBER
                 ,p_element_entry_id                 IN       NUMBER
                 ,p_assignment_action_id             IN       NUMBER
                 ,p_assignment_id                    IN       NUMBER
                 ,p_date_earned                      IN       DATE
                 ,p_contribution_area                IN       VARCHAR2
                 ,p_phf_si_type                      IN       VARCHAR2
                 ,p_hukou_type                       IN       VARCHAR2
                 ,p_employer_id                      IN       VARCHAR2
                 ,p_pay_proc_period_end_date         IN       DATE
         --
                 ,p_phf_si_earnings_asg_ptd          IN       NUMBER
                 ,p_phf_si_earnings_asg_pyear        IN       NUMBER
                 ,p_phf_si_earnings_asg_pmth         IN       NUMBER
                 ,p_taxable_earnings_asg_er_ptd      IN       NUMBER
                 ,p_ee_cont_base_asg_ltd             IN       NUMBER
                 ,p_er_cont_base_asg_ltd             IN       NUMBER
                 ,p_ee_deductions_asg_er_ptd         IN       NUMBER
                 ,p_er_deductions_asg_er_ptd         IN       NUMBER
                 ,p_undeducted_ee_asg_ltd            IN       NUMBER
                 ,p_undeducted_er_asg_ltd            IN       NUMBER
                 ,p_undeducted_ee_asg_er_ptd         IN       NUMBER
                 ,p_undeducted_er_asg_er_ptd         IN       NUMBER
         --
                 ,p_calculation_date            IN OUT NOCOPY  DATE
                 ,p_ee_cont_base_amount         IN OUT NOCOPY  NUMBER
                 ,p_er_cont_base_amount         IN OUT NOCOPY  NUMBER
                 --
                 ,p_ee_phf_si_amount            OUT NOCOPY NUMBER
                 ,p_er_phf_si_amount            OUT NOCOPY NUMBER
                 ,p_new_ee_cont_base_amount     OUT NOCOPY NUMBER
                 ,p_new_er_cont_base_amount     OUT NOCOPY NUMBER
                 ,p_undeducted_ee_phf_si_amount OUT NOCOPY NUMBER
                 ,p_undeducted_er_phf_si_amount OUT NOCOPY NUMBER
                 ,p_ee_hi_cont_type                IN       VARCHAR2
                 ,p_er_hi_cont_type                IN       VARCHAR2
                 ,p_ee_hi_cont_amt                 IN       NUMBER
                 ,p_er_hi_cont_amt                 IN       NUMBER
                 ,p_ee_hi_cont_base_meth           IN       VARCHAR2
                 ,p_er_hi_cont_base_meth           IN       VARCHAR2
                 ,p_ee_hi_cont_base_amount         IN       NUMBER
                 ,p_er_hi_cont_base_amount         IN       NUMBER
                 ,p_ee_taxable_cont OUT NOCOPY NUMBER
                 ,p_er_taxable_cont OUT NOCOPY NUMBER
                 ,p_lt_ee_taxable_cont_ptd         IN       NUMBER
                 ,p_lt_er_taxable_cont_ptd         IN       NUMBER
                 )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_SI_DEFERRED_AMOUNTS                         --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Procedure to calculate the deferred contributions   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pay_proc_period_end_date    DATE                  --
--                  p_actual_probation_end_date   DATE                  --
--                  p_const_probation_end_date    DATE                  --
--                  p_defer_deductions            VARCHAR2              --
--                  p_deduct_in_probation_expiry  VARCHAR2              --
--                  p_taxable_earnings_asg_er_ptd NUMBER                --
--         IN/OUT : p_ee_phf_si_amount            NUMBER                --
--                  p_er_phf_si_amount            NUMBER                --
--                  p_undeducted_ee_phf_ltd       NUMBER                --
--                  p_undeducted_er_phf_ltd       NUMBER                --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_phf_si_deferred_amounts
                 (p_pay_proc_period_end_date     IN DATE
                 ,p_actual_probation_end_date    IN DATE
                 ,p_const_probation_end_date     IN DATE
                 ,p_defer_deductions             IN VARCHAR2
                 ,p_deduct_in_probation_expiry   IN VARCHAR2
                 ,p_taxable_earnings_asg_er_ptd  IN  NUMBER
                 --
                 ,p_ee_phf_si_amount             IN OUT NOCOPY NUMBER
                 ,p_er_phf_si_amount             IN OUT NOCOPY NUMBER
                 ,p_undeducted_ee_phf_ltd        IN OUT NOCOPY NUMBER
                 ,p_undeducted_er_phf_ltd        IN OUT NOCOPY NUMBER
             )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_CONT_BASE_SETUP                               --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to Check the Contribution Base Setup      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_organization_id          NUMBER                   --
--                  p_contribution_area        VARCHAR2                 --
--                  p_phf_si_type              VARCHAR2                 --
--                  p_hukou_type               VARCHAR2                 --
--                  p_ee_cont_base_method      VARCHAR2                 --
--                  p_er_cont_base_method      VARCHAR2                 --
--                  p_low_limit_method         VARCHAR2                 --
--                  p_low_limit_amount         NUMBER                 --
--                  p_high_limit_method        VARCHAR2                 --
--                  p_high_limit_amount        NUMBER                 --
--                  p_switch_periodicity       VARCHAR2                 --
--                  p_switch_month             VARCHAR2                 --
--                  p_rounding_method          VARCHAR2                 --
--                  p_lowest_avg_salary        NUMBER                 --
--                  p_average_salary           NUMBER                 --
--                  p_ee_fixed_amount          NUMBER                 --
--                  p_er_fixed_amount          NUMBER                 --
--                  p_effective_start_date     DATE                     --
--                  p_effective_end_date       DATE                     --
--        IN/ OUT :                                                     --
--           OUT :  p_message_name    NOCOPY VARCHAR2                   --
--                  p_token_name      NOCOPY hr_cn_api.char_tab_type    --
--                  p_token_value     NOCOPY hr_cn_api.char_tab_type    --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_cont_base_setup
          (p_organization_id         IN NUMBER
          ,p_contribution_area       IN VARCHAR2
          ,p_phf_si_type             IN VARCHAR2
          ,p_hukou_type              IN VARCHAR2
          ,p_ee_cont_base_method     IN VARCHAR2
          ,p_er_cont_base_method     IN VARCHAR2
          ,p_low_limit_method        IN VARCHAR2
          ,p_low_limit_amount        IN NUMBER
          ,p_high_limit_method       IN VARCHAR2
          ,p_high_limit_amount       IN NUMBER
          ,p_switch_periodicity      IN VARCHAR2
          ,p_switch_month            IN VARCHAR2
          ,p_rounding_method         IN VARCHAR2
          ,p_lowest_avg_salary       IN NUMBER
          ,p_average_salary          IN NUMBER
          ,p_ee_fixed_amount         IN NUMBER
          ,p_er_fixed_amount         IN NUMBER
          ,p_effective_start_date    IN DATE
          ,p_effective_end_date      IN DATE
          ,p_message_name            OUT NOCOPY VARCHAR2
          ,p_token_name              OUT NOCOPY hr_cn_api.char_tab_type
          ,p_token_value             OUT NOCOPY hr_cn_api.char_tab_type
          );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PHF_SI_RATES_SETUP                            --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to Check the Contribution Base Setup      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_organization_id          NUMBER                   --
--                  p_contribution_area        VARCHAR2                 --
--                  p_phf_si_type              VARCHAR2                 --
--                  p_hukou_type               VARCHAR2                 --
--                  p_effective_start_date     DATE                     --
--                  p_effective_end_date       DATE                     --
--        IN/ OUT :                                                     --
--           OUT :  p_message_name     NOCOPY VARCHAR2                  --
--                  p_token_name       NOCOPY hr_cn_api.char_tab_type   --
--                  p_token_value      NOCOPY hr_cn_api.char_tab_type   --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE check_phf_si_rates_setup
          (p_organization_id         IN NUMBER
          ,p_contribution_area       IN VARCHAR2
          ,p_organization            IN VARCHAR2
          ,p_phf_si_type             IN VARCHAR2
          ,p_hukou_type              IN VARCHAR2
          ,p_effective_start_date    IN DATE
          ,p_effective_end_date      IN DATE
          ,p_message_name            OUT NOCOPY VARCHAR2
          ,p_token_name              OUT NOCOPY hr_cn_api.char_tab_type
          ,p_token_value             OUT NOCOPY hr_cn_api.char_tab_type
          );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PHF_SI_EARNINGS                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get PYEAR and PMTH values for PHF/SI Earnings --
--                  Called from all 8 PHF/SI formulas                   --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   31-MAR-09  dduvvuri  8328944 - Created this Function           --
--------------------------------------------------------------------------

FUNCTION get_phf_si_earnings
               ( p_business_group_id         IN NUMBER
                ,p_assignment_id             IN NUMBER
                ,p_date_earned               IN DATE
                ,p_pay_proc_period_end_date  IN DATE
                ,p_employer_id               IN VARCHAR2
                ,p_phf_si_earnings_pyear  IN OUT NOCOPY NUMBER
                ,p_phf_si_earnings_pmth   IN OUT NOCOPY NUMBER
                ,p_contribution_area         IN VARCHAR2
                ,p_phf_si_type               IN VARCHAR2
                ,p_hukou_type                IN VARCHAR2
               )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_YOS_SEV_PAY_TAX_RULE                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get Severance Pay Taxation rule from BG level --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   24-aug-09  dduvvuri  8799060 - Created this Function           --
--------------------------------------------------------------------------

FUNCTION get_yos_sev_pay_tax_rule (
                                  p_date_earned                IN  DATE
                                , p_tax_area                   IN  VARCHAR2
                                )
RETURN VARCHAR2;

END pay_cn_deductions;




/
