--------------------------------------------------------
--  DDL for Package PAY_IN_TAX_DECLARATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_TAX_DECLARATION" AUTHID CURRENT_USER AS
/* $Header: pyintaxd.pkh 120.6.12010000.6 2010/04/01 11:09:02 mdubasi ship $ */

-- Global Variables Section
type t_element_values_rec is record
(element_name pay_element_types_f.element_name%TYPE
,input_name   pay_input_values_f.name%TYPE
,planned_val  pay_element_entry_values.screen_entry_value%TYPE
,actual_val   pay_element_entry_values.screen_entry_value%TYPE
);

type t_element_values_tab is table of t_element_values_rec
  index by binary_integer;

-- Bug 3886086
-- Record to store the details of tabular details like
-- Section 80DD, 80G and life insurace.
--
type t_tab_entry_details_rec is record
(entry_id     pay_element_entries_f.element_entry_id%TYPE
,input1_value pay_element_entry_values.screen_entry_value%TYPE
,input2_value pay_element_entry_values.screen_entry_value%TYPE
,input3_value pay_element_entry_values.screen_entry_value%TYPE
);

type t_entry_details_tab is table of t_tab_entry_details_rec
  index by binary_integer;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_LOCKING_PERIOD                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  freeze period details like start date, along with   --
--                  a flag to indicate if it is the freeze period.      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id   per_people_f.person_id%TYPE           --
--            OUT : p_locked      VARCHAR2                              --
--                  p_lock_start  DATE                                  --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE is_locking_period
   (p_person_id  IN         per_people_f.person_id%TYPE
   ,p_locked     OUT NOCOPY VARCHAR2
   ,p_lock_start OUT NOCOPY DATE);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_APPROVED                                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  the flag stating if the employee tax declaration    --
--                  details have been approved or not.           .      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id       per_people_f.person_id%TYPE       --
--                  p_effective_date  DATE                              --
--            OUT : p_status          VARCHAR2                          --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE is_approved
   (p_person_id      IN NUMBER
   ,p_effective_date IN DATE default null
   ,p_status         OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_CITY_TYPE                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function is responsible for quering the city    --
--                  type of the primary address of the employee if the  --
--                  primary address is not available then return NA.    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id       per_people_f.person_id%TYPE       --
--                  p_effective_date  DATE                              --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_city_type
        (p_person_id       IN    number
        ,p_effective_date  IN    date)
RETURN varchar2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAX_YEAR                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function is responsible returning the tax year  --
--                  created based on the effective date passed to it.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date  DATE                              --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_tax_year(p_effective_date IN DATE)
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_APPROVAL_STATUS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  the flag stating if the employee tax declaration    --
--                  details have been approved or not.           .      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  per_assignments_f.assignment_id    --
--                  p_tax_year       VARCHAR2                           --
--                  p_extra_info_id  assignment_extra_info_id           --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_approval_status
   (p_assignment_id IN per_assignments_f.assignment_id%TYPE
   ,p_tax_year      IN VARCHAR2
   ,p_extra_info_id OUT NOCOPY per_assignment_extra_info.assignment_extra_info_id%TYPE)
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DONATION_TYPE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function has the same code which is used to     --
--                  validate teh donation type details entered. Further --
--                  is used to validate the same in self-service        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_lookup_code    VARCHAR2                           --
--         RETURN : pay_user_column_instances_f.value%TYPE              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_donation_type(p_lookup_code IN VARCHAR2)
RETURN pay_user_column_instances_f.value%TYPE;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PLANNED_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function calculates the value of an element     --
--                  entries's input value on a date which is before the --
--                  freeze date for the financial year.                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_actual_value  VARCHAR2                            --
--                  p_ele_entry_id  element_entry_id%TYPE               --
--                  p_input_value_id input_value_id%TYPE                --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_planned_value
        (p_assignment_id   IN per_assignments_f.assignment_id%TYPE
        ,p_actual_value    IN VARCHAR2
        ,p_ele_entry_id    IN pay_element_entries_f.element_entry_id%TYPE
        ,p_input_value_id  IN pay_input_values_f.input_value_id%TYPE)
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_VALUE                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function calculates the planned and the actual  --
--                  values of the following elements and stores then in --
--                  the cache when the function is first called on sub- --
--                  sequent calls it would used the cached value.       --
--                    1. Rebates under Section 88                       --
--                    2. Tuition Fee                                    --
--                    3. Deductions under Chapter VI A and              --
--                    4. Other Income                                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id NUMBER                              --
--                  p_element_name  VARCHAR2                            --
--                  p_input_name    VARCHAR2                            --
--                  p_effective_date DATE                               --
--                  p_actual_value  VARCHAR2                            --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_value
        (p_assignment_id   IN    number
        ,p_element_name    IN    varchar2
        ,p_input_name      IN    varchar2
        ,p_effective_date  IN    date
        ,p_actual_value    IN    varchar2
        )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_NUMERIC_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The function calls get_value internally, but the    --
--                  value returned would be converted to number using   --
--                  to_number and the numeric value returned.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id NUMBER                              --
--                  p_element_name  VARCHAR2                            --
--                  p_input_name    VARCHAR2                            --
--                  p_effective_date DATE                               --
--                  p_actual_value  VARCHAR2                            --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_numeric_value
   (p_assignment_id   IN    number
   ,p_element_name    IN    varchar2
   ,p_input_name      IN    varchar2
   ,p_effective_date  IN    date
   ,p_actual_value    IN    varchar2
   )
RETURN NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LAST_UPDATED_DATE                               --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The is called with one of these values and returns  --
--                  the last updated date of the associated element for --
--                  element type in question. The valid element types   --
--                  are:                                                --
--                      1. HOUSE                                        --
--                      2. CHAPTER6                                     --
--                      3. SECTION88                                    --
--                      4. OTHER                                        --
--                      5. ALL                                          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id      NUMBER                             --
--                  p_effective_date DATE                               --
--                  p_element_type   VARCHAR2                           --
--         RETURN : NUMBER                                              --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_last_updated_date
         (p_person_id      IN NUMBER
         ,p_effective_date IN DATE
         ,p_element_type   IN VARCHAR2)
RETURN DATE;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_HOUSE_RENT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the detials--
--                  in 'House Rent Information' element.                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_apr             NUMBER                            --
--                  p_may             NUMBER                            --
--                  p_jun             NUMBER                            --
--                  p_jul             NUMBER                            --
--                  p_aug             NUMBER                            --
--                  p_sep             NUMBER                            --
--                  p_oct             NUMBER                            --
--                  p_nov             NUMBER                            --
--                  p_dec             NUMBER                            --
--                  p_jan             NUMBER                            --
--                  p_feb             NUMBER                            --
--                  p_mar             NUMBER                            --
--                  p_effective_date  DATE                              --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_house_rent
   (p_assignment_id  IN per_assignments_f.assignment_id%TYPE
   ,p_apr            IN NUMBER
   ,p_may            IN NUMBER
   ,p_jun            IN NUMBER
   ,p_jul            IN NUMBER
   ,p_aug            IN NUMBER
   ,p_sep            IN NUMBER
   ,p_oct            IN NUMBER
   ,p_nov            IN NUMBER
   ,p_dec            IN NUMBER
   ,p_jan            IN NUMBER
   ,p_feb            IN NUMBER
   ,p_mar            IN NUMBER
   ,p_effective_date IN DATE DEFAULT NULL
   ,p_warnings       OUT NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_CHAPTER6A                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure calculates the value of permanent     --
--                  disability 80u and then stores the detials in the   --
--                  'Deductions under Chapter VI A' element.            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_pension_fund_80ccc           NUMBER               --
--                  p_medical_insurance_prem_80d   NUMBER               --
--                  p_sec_80ddb_senior_citizen     VARCHAR2             --
--                  p_disease_treatment_80ddb      NUMBER               --
--                  p_sec_80d_senior_citizen       VARCHAR2             --
--                  p_higher_education_loan_80e    NUMBER               --
--                  p_claim_exemp_under_sec_80gg   VARCHAR2             --
--                  p_donation_for_research_80gga  NUMBER               --
--                  p_int_on_gen_investment_80L    NUMBER               --
--                  p_int_on_securities_80L        NUMBER               --
--                  p_effective_date               DATE                 --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_chapter6a
   (p_assignment_id                   IN   per_assignments_f.assignment_id%TYPE
   ,p_pension_fund_80ccc              IN   NUMBER
   ,p_medical_insurance_prem_80d      IN   NUMBER
   ,p_sec_80ddb_senior_citizen        IN   VARCHAR2
   ,p_disease_treatment_80ddb         IN   NUMBER
   ,p_sec_80d_senior_citizen          IN   VARCHAR2
   ,p_higher_education_loan_80e       IN   NUMBER
   ,p_claim_exemp_under_sec_80gg      IN   VARCHAR2
   ,p_donation_for_research_80gga     IN   NUMBER
   ,p_int_on_gen_investment_80L       IN   NUMBER
   ,p_int_on_securities_80L           IN   NUMBER
   ,p_effective_date                  IN   DATE DEFAULT NULL
   ,p_warnings                        OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION88                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the detials--
--                  in 'Rebates under Section 88' element.              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_public_provident_fund           NUMBER            --
--                  p_post_office_savings_scheme      NUMBER            --
--                  p_deposit_in_nsc_vi_issue         NUMBER            --
--                  p_deposit_in_nsc_viii_issue       NUMBER            --
--                  p_interest_on_nsc_reinvested      NUMBER            --
--                  p_house_loan_repayment            NUMBER            --
--                  p_notified_mutual_fund_or_uti     NUMBER            --
--                  p_national_housing_bank_scheme    NUMBER            --
--                  p_unit_linked_insurance_plan      NUMBER            --
--                  p_notified_annuity_plan           NUMBER            --
--                  p_notified_pension_fund           NUMBER            --
--                  p_public_sector_company_scheme    NUMBER            --
--                  p_approved_superannuation_fund    NUMBER            --
--                  p_infrastructure_bond             NUMBER            --
--                  p_effective_date                  DATE              --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section88
   (p_assignment_id                  IN per_assignments_f.assignment_id%TYPE
   ,p_deferred_annuity               IN NUMBER
   ,p_senior_citizen_sav_scheme      IN NUMBER
   ,p_public_provident_fund          IN NUMBER
   ,p_post_office_savings_scheme     IN NUMBER
   ,p_deposit_in_nsc_vi_issue        IN NUMBER
   ,p_deposit_in_nsc_viii_issue      IN NUMBER
   ,p_interest_on_nsc_reinvested     IN NUMBER
   ,p_house_loan_repayment           IN NUMBER
   ,p_notified_mutual_fund_or_uti    IN NUMBER
   ,p_national_housing_bank_scheme   IN NUMBER
   ,p_unit_linked_insurance_plan     IN NUMBER
   ,p_notified_annuity_plan          IN NUMBER
   ,p_notified_pension_fund          IN NUMBER
   ,p_public_sector_company_scheme   IN NUMBER
   ,p_approved_superannuation_fund   IN NUMBER
   ,p_infrastructure_bond            IN NUMBER
   ,p_effective_date                 IN DATE DEFAULT NULL
   ,p_warnings                       OUT NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_OTHER_INCOME                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Other Income' element.                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_income_from_house_property     NUMBER             --
--                  p_profit_and_gain_from_busines   NUMBER             --
--                  p_long_term_capital_gain         NUMBER             --
--                  p_short_term_capital_gain        NUMBER             --
--                  p_income_from_any_other_source   NUMBER             --
--                  p_tds_paid_on_other_income       NUMBER             --
--                  p_effective_date                  DATE              --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_other_income
   (p_assignment_id                 IN per_assignments_f.assignment_id%TYPE
   ,p_income_from_house_property    IN NUMBER
   ,p_profit_and_gain_from_busines  IN NUMBER
   ,p_long_term_capital_gain        IN NUMBER
   ,p_short_term_capital_gain       IN NUMBER
   ,p_income_from_any_other_source  IN NUMBER
   ,p_tds_paid_on_other_income      IN NUMBER
   ,p_effective_date                IN DATE DEFAULT NULL
   ,p_warnings                      OUT NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80DD                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80DD' element.  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_disability_type        VARCHAR2                   --
--                  p_disability_percentage  VARCHAR2                   --
--                  p_treatment_amount       NUMBER                     --
--                  p_effective_date         DATE                       --
--                  p_element_entry_id       element_entry_id%TYPE      --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80dd
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_disability_type       IN VARCHAR2
   ,p_disability_percentage IN VARCHAR2
   ,p_treatment_amount      IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_warnings              OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80G                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80G' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_donation_type      VARCHAR2                       --
--                  p_donation_amount    NUMBER                         --
--                  p_effective_date     DATE                           --
--                  p_element_entry_id   element_entry_id%TYPE          --
--            OUT : p_warnings           BOOLEAN                        --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80g
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_donation_type         IN VARCHAR2
   ,p_donation_amount       IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_warnings              OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80CCE                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80CCE' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_investment_type    VARCHAR2                       --
--                  p_investment_amount  NUMBER                         --
--                  p_effective_date     DATE                           --
--                  p_element_entry_id   element_entry_id%TYPE          --
--            OUT : p_warnings           BOOLEAN                        --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80cce
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_investment_type       IN VARCHAR2
   ,p_investment_amount     IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_warnings              OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_LIFE_INSURANCE_PREMIUM                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Life Insurance Premium' element.        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_premium_paid       VARCHAR2                       --
--                  p_sum_assured        NUMBER                         --
--                  p_effective_date     DATE                           --
--                  p_element_entry_id   element_entry_id%TYPE          --
--            OUT : p_warnings           BOOLEAN                        --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_life_insurance_premium
   (p_assignment_id         IN per_assignments_f.assignment_id%TYPE
   ,p_premium_paid          IN VARCHAR2
   ,p_sum_assured           IN NUMBER
   ,p_effective_date        IN DATE default null
   ,p_element_entry_id      IN pay_element_entries_f.element_entry_id%TYPE default null
   ,p_policy_number         IN VARCHAR2
   ,p_warnings              OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_VPF
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  details in 'PF Information' element.  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date         DATE                       --
--                  p_ee_vol_pf_amount       NUMBER                     --
--                  p_ee_vol_pf_percent      NUMBER
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------

PROCEDURE declare_vpf
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date            IN   DATE DEFAULT NULL
          ,p_ee_vol_pf_amount           IN   NUMBER
          ,p_ee_vol_pf_percent          IN   NUMBER
          ,p_warnings                   OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_TUITION_FEE                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Tuition Fee' element.                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_tuition_fee_for_child_1 NUMBER                    --
--                  p_tuition_fee_for_child_2 NUMBER                    --
--                  p_effective_date          DATE                      --
--                  p_element_entry_id        element_entry_id%TYPE     --
--            OUT : p_warnings                BOOLEAN                   --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_tuition_fee
   (p_assignment_id           IN per_assignments_f.assignment_id%TYPE
   ,p_tuition_fee_for_child_1 IN NUMBER
   ,p_tuition_fee_for_child_2 IN NUMBER
   ,p_effective_date          IN DATE DEFAULT NULL
   ,p_warnings                OUT NOCOPY BOOLEAN);

PROCEDURE declare_tax
   (p_assignment_id                IN  per_assignments_f.assignment_id%TYPE
   ,p_is_monthly_rent_changed      IN  VARCHAR2
   ,p_apr                          IN  NUMBER   default null
   ,p_may                          IN  NUMBER   default null
   ,p_jun                          IN  NUMBER   default null
   ,p_jul                          IN  NUMBER   default null
   ,p_aug                          IN  NUMBER   default null
   ,p_sep                          IN  NUMBER   default null
   ,p_oct                          IN  NUMBER   default null
   ,p_nov                          IN  NUMBER   default null
   ,p_dec                          IN  NUMBER   default null
   ,p_jan                          IN  NUMBER   default null
   ,p_feb                          IN  NUMBER   default null
   ,p_mar                          IN  NUMBER   default null
   ,p_is_chapter6a_changed         IN  VARCHAR2
   ,p_pension_fund_80ccc           IN  NUMBER   default NULL
   ,p_medical_insurance_prem_80d   IN  NUMBER   default null
   ,p_med_par_insurance_prem_80d   IN  NUMBER   default NULL
   ,p_80d_par_prem_changed         IN  VARCHAR2 DEFAULT NULL
   ,p_sec_80d_par_senior_citizen   IN  VARCHAR2 default null
   ,p_80d_par_snr_changed          IN  VARCHAR2 DEFAULT NULL
   ,p_sec_80ddb_senior_citizen     IN  VARCHAR2 default null
   ,p_disease_treatment_80ddb      IN  NUMBER   default null
   ,p_sec_80d_senior_citizen       IN  VARCHAR2 default null
   ,p_higher_education_loan_80e    IN  NUMBER   default null
   ,p_claim_exemp_under_sec_80gg   IN  VARCHAR2 default null
   ,p_donation_for_research_80gga  IN  NUMBER   default null
   ,p_80gg_changed                 IN  VARCHAR2 DEFAULT NULL
   ,p_80e_changed                  IN  VARCHAR2 DEFAULT NULL
   ,p_80gga_changed                IN  VARCHAR2 DEFAULT NULL
   ,p_80d_changed                  IN  VARCHAR2 DEFAULT NULL
   ,p_80dsc_planned_value          IN  VARCHAR2 DEFAULT NULL
   ,p_80ddb_changed                IN  VARCHAR2 DEFAULT NULL
   ,p_80ddbsc_planned_value        IN  VARCHAR2 DEFAULT NULL
   ,p_int_on_gen_investment_80L    IN  NUMBER   default null
   ,p_int_on_securities_80L        IN  NUMBER   default null
   ,p_80ccf_changed                IN  Varchar2 default null
   ,p_infrastructure_bonds_80ccf   IN  NUMBER   default null
   ,p_ee_vol_pf_amount             IN  NUMBER   default null
   ,p_ee_vol_pf_percent            IN  NUMBER   default null
   ,p_ee_pf_amt_changed            IN  VARCHAR2 DEFAULT NULL
   ,p_ee_pf_percent_changed        IN  VARCHAR2 DEFAULT NULL
   ,p_is_section88_changed         IN  VARCHAR2 DEFAULT NULL
   ,p_deferred_annuity             IN  NUMBER   default NULL
   ,p_senior_citizen_sav_scheme    IN  NUMBER   default null
   ,p_public_provident_fund        IN  NUMBER   default null
   ,p_post_office_savings_scheme   IN  NUMBER   default null
   ,p_deposit_in_nsc_vi_issue      IN  NUMBER   default null
   ,p_deposit_in_nsc_viii_issue    IN  NUMBER   default null
   ,p_interest_on_nsc_reinvested   IN  NUMBER   default null
   ,p_house_loan_repayment         IN  NUMBER   default null
   ,p_notified_mutual_fund_or_uti  IN  NUMBER   default null
   ,p_national_housing_bank_scheme IN  NUMBER   default null
   ,p_unit_linked_insurance_plan   IN  NUMBER   default null
   ,p_notified_annuity_plan        IN  NUMBER   default null
   ,p_notified_pension_fund        IN  NUMBER   default null
   ,p_public_sector_company_scheme IN  NUMBER   default null
   ,p_approved_superannuation_fund IN  NUMBER   default null
   ,p_infrastructure_bond          IN  NUMBER   default null
   ,p_tuition_fee_for_child_1      IN  NUMBER   default null
   ,p_tuition_fee_for_child_2      IN  NUMBER   default null
   ,p_is_other_income_changed      IN  VARCHAR2
   ,p_income_from_house_property   IN  NUMBER   default null
   ,p_profit_and_gain_from_busines IN  NUMBER   default null
   ,p_long_term_capital_gain       IN  NUMBER   default null
   ,p_short_term_capital_gain      IN  NUMBER   default null
   ,p_income_from_any_other_source IN  NUMBER   default null
   ,p_tds_paid_on_other_income     IN  NUMBER   default null
   ,p_approved_flag                IN  VARCHAR2 default null
   ,p_comment_text                 IN  VARCHAR2 default null
   ,p_effective_date               IN  DATE     default null
   ,p_warnings                     OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DELETE_DECLARATION                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for deletion of        --
--                  element entries as of the effective date.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id        element_entry_id%TYPE     --
--                  p_effective_date          DATE                      --
--            OUT : p_warnings                BOOLEAN                   --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE delete_declaration
   (p_element_entry_id IN NUMBER
   ,p_effective_date   IN DATE DEFAULT NULL
   ,p_warnings         OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : APPROVE_DECLARATION                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for approval of        --
--                  tax declaration for the assignment in question.     --
--                                                                      --
-- Parameters     :                                                     --
--             IN :p_assignment_id  per_assignments_f.assignment_id%TYPE--
--                  p_approval_flag  VARCHAR2                           --
--                  p_effective_date DATE                               --
--                  p_comment_text   VARCHAR2                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE approve_declaration
   (p_assignment_id  IN per_assignments_f.assignment_id%TYPE
   ,p_approval_flag  IN VARCHAR2
   ,p_effective_date IN DATE
   ,p_comment_text   IN VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_VALUE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for retrieval of       --
--                  tax declaration details for the assignment.         --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_value
        (p_assignment_id   IN    number
        ,p_index           IN    number
        ,p_element_name    IN    varchar2
        ,p_input_name      IN    varchar2
        ,p_effective_date  IN    date
        )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : WEB_ADI_DECLARE_TAX                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  tax declaration details for the assignment.         --
--                  This is called from Web ADI.                        --
--------------------------------------------------------------------------
PROCEDURE web_adi_declare_tax
   (p_assignment_id                 IN number
   ,p_effective_date                IN date default null
   ,p_april                         IN number default null
   ,p_may                           IN number default null
   ,p_june                          IN number default null
   ,p_july                          IN number default null
   ,p_august                        IN number default null
   ,p_september                     IN number default null
   ,p_october                       IN number default null
   ,p_november                      IN number default null
   ,p_december                      IN number default null
   ,p_january                       IN number default null
   ,p_february                      IN number default null
   ,p_march                         IN number default null
   ,p_cce_ee_id1                    IN number default null
   ,p_cce_component1                IN varchar2 default null
   ,p_investment_amount1            IN number default null
   ,p_cce_ee_id2                    IN number default null
   ,p_cce_component2                IN varchar2 default null
   ,p_investment_amount2            IN number default null
   ,p_cce_ee_id3                    IN number default null
   ,p_cce_component3                IN varchar2 default null
   ,p_investment_amount3            IN number default null
   ,p_cce_ee_id4                    IN number default null
   ,p_cce_component4                IN varchar2 default null
   ,p_investment_amount4            IN number default null
   ,p_cce_ee_id5                    IN number default null
   ,p_cce_component5                IN varchar2 default null
   ,p_investment_amount5            IN number default null
   ,p_cce_ee_id6                    IN number default null
   ,p_cce_component6                IN varchar2 default null
   ,p_investment_amount6            IN number default null
   ,p_cce_ee_id7                    IN number default null
   ,p_cce_component7                IN varchar2 default null
   ,p_investment_amount7            IN number default null
   ,p_cce_ee_id8                    IN number default null
   ,p_cce_component8                IN varchar2 default null
   ,p_investment_amount8            IN number default null
   ,p_cce_ee_id9                    IN number default null
   ,p_cce_component9                IN varchar2 default null
   ,p_investment_amount9            IN number default null
   ,p_cce_ee_id10                   IN number default null
   ,p_cce_component10               IN varchar2 default null
   ,p_investment_amount10           IN number default null
   ,p_cce_ee_id11                   IN number default null
   ,p_cce_component11               IN varchar2 default null
   ,p_investment_amount11           IN number default null
   ,p_cce_ee_id12                   IN number default null
   ,p_cce_component12               IN varchar2 default null
   ,p_investment_amount12           IN number default null
   ,p_cce_ee_id13                   IN number default null
   ,p_cce_component13               IN varchar2 default null
   ,p_investment_amount13           IN number default null
   ,p_cce_ee_id14                   IN number default null
   ,p_cce_component14               IN varchar2 default null
   ,p_investment_amount14           IN number default null
   ,p_cce_ee_id15                   IN number default null
   ,p_cce_component15               IN varchar2 default null
   ,p_investment_amount15           IN number default null
   ,p_cce_ee_id16                   IN number default null
   ,p_cce_component16               IN varchar2 default null
   ,p_investment_amount16           IN number default null
   ,p_cce_ee_id17                   IN number default null
   ,p_cce_component17               IN varchar2 default null
   ,p_investment_amount17           IN number default null
   ,p_cce_ee_id18                   IN number default null
   ,p_cce_component18               IN varchar2 default null
   ,p_investment_amount18           IN number default null
   ,p_cce_ee_id19                   IN number default null
   ,p_cce_component19               IN varchar2 default null
   ,p_investment_amount19           IN number default null
   ,p_cce_ee_id20                   IN number default null
   ,p_cce_component20               IN varchar2 default null
   ,p_investment_amount20           IN number default null
   ,p_cce_ee_id21                   IN number default null
   ,p_cce_component21               IN varchar2 default null
   ,p_investment_amount21           IN number default null
   ,p_higher_education_loan         IN number default null
   ,p_donation_for_research         IN number default null
   ,p_claim_exemption_sec_80gg      IN varchar2 default null
   ,p_premium_amount                IN number default null
   ,p_premium_covers_sc             IN varchar2 default null
   ,p_treatment_amount              IN number default null
   ,p_treatment_covers_sc           IN varchar2 default null
   ,p_income_from_house_property    IN number default null
   ,p_profit_and_gain               IN number default null
   ,p_long_term_capital_gain        IN number default null
   ,p_short_term_capital_gain       IN number default null
   ,p_income_from_other_sources     IN number default null
   ,p_tds_paid                      IN number default null
   ,p_disease_entry_id1             IN number default null
   ,p_disability_type1              IN varchar2 default null
   ,p_disability_percentage1        IN varchar2 default null
   ,p_treatment_amount1             IN number default null
   ,p_disease_entry_id2             IN number default null
   ,p_disability_type2              IN varchar2 default null
   ,p_disability_percentage2        IN varchar2 default null
   ,p_treatment_amount2             IN number default null
   ,p_donation_entry_id1            IN number default null
   ,p_donation_type1                IN varchar2 default null
   ,p_donation_amount1              IN number default null
   ,p_donation_entry_id2            IN number default null
   ,p_donation_type2                IN varchar2 default null
   ,p_donation_amount2              IN number default null
   ,p_lic_entry_id1                 IN number default null
   ,p_premium_paid1                 IN number default null
   ,p_sum_assured1                  IN number default null
   ,p_lic_entry_id2                 IN number default null
   ,p_premium_paid2                 IN number default null
   ,p_sum_assured2                  IN number default null
   ,p_lic_entry_id3                 IN number default null
   ,p_premium_paid3                 IN number default null
   ,p_sum_assured3                  IN number default null
   ,p_lic_entry_id4                 IN number default null
   ,p_premium_paid4                 IN number default null
   ,p_sum_assured4                  IN number default null
   ,p_lic_entry_id5                 IN number default null
   ,p_premium_paid5                 IN number default null
   ,p_sum_assured5                  IN number default null
   ,p_comment_text                  IN varchar2 default NULL
   ,P_PERSON_ID                     IN number default null
   ,P_FULL_NAME                     IN varchar2 default NULL
   ,P_EMPLOYEE_NUMBER               IN varchar2 default NULL
   ,P_ASSIGNMENT_NUMBER             IN varchar2 default NULL
   ,P_DEPARTMENT                    IN varchar2 default NULL
   ,P_LAST_UPDATED_DATE             IN date default null
   ,P_ORGANIZATION_ID               IN number default null
   ,P_BUSINESS_GROUP_ID             IN number default null
   ,P_START_DATE                    IN date default null
   ,P_GRADE_ID                      IN number default null
   ,P_JOB_ID                        IN number default null
   ,P_POSITION_ID                   IN number default null
   ,P_TAX_AREA_NUMBER               IN varchar2 default NULL
   ,P_APPROVAL_STATUS               IN varchar2 default NULL
   ,P_TAX_YEAR			    IN varchar2 default NULL
   ,p_parent_premium                IN number default null
   ,p_parent_sc                     IN varchar2 default null
   ,p_isb_amount                    IN Number  default null
   ,p_policy_number2                IN Varchar2 default null
   ,p_policy_number3                IN Varchar2 default null
   ,p_policy_number4                IN Varchar2 default null
   ,p_policy_number5                IN Varchar2 default null
   ,p_vpf_amount                    IN number default null
   ,p_vpf_percent                   IN number default null
   ,p_policy_number1                IN Varchar2 default null

);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80GG                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80GG' element.  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date             DATE                   --
--                  p_claim_exemp_under_sec_80gg VARCHAR2               --
--            OUT : p_warnings        BOOLEAN                           --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80gg
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date             IN   DATE DEFAULT NULL
          ,p_claim_exemp_under_sec_80gg IN   VARCHAR2
          ,p_warnings                   OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80E                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80E' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date             DATE                   --
--                  p_higher_education_loan_80e  NUMBER                 --
--            OUT : p_warnings                   BOOLEAN                --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80e
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date             IN   DATE DEFAULT NULL
          ,p_higher_education_loan_80e  IN   NUMBER DEFAULT NULL
          ,p_warnings                   OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80CCF                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80CCF' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date             DATE                   --
--                  p_infrastructure_bonds_80ccf  NUMBER                 --
--            OUT : p_warnings                   BOOLEAN                --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80ccf
          (p_assignment_id              IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date             IN   DATE DEFAULT NULL
          ,p_infrastructure_bonds_80ccf  IN   NUMBER DEFAULT NULL
          ,p_warnings                   OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80GGA                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80GGA' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_donation_for_research_80gga NUMBER                --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80gga
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_donation_for_research_80gga IN   NUMBER DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80D                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80D' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_medical_insurance_prem_80d  NUMBER                --
--                  p_sec_80d_senior_citizen      VARCHAR2              --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80d
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_medical_insurance_prem_80d  IN   NUMBER DEFAULT NULL
          ,p_sec_80d_senior_citizen      IN   VARCHAR2 DEFAULT NULL
	  ,p_med_par_insurance_prem_80d  IN   NUMBER DEFAULT NULL
          ,p_sec_80d_par_senior_citizen  IN   VARCHAR2 DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80DDB                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80DDB' element. --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--                  p_disease_treatment_80ddb     NUMBER                --
--                  p_sec_80ddb_senior_citizen    VARCHAR2              --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80ddb
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_disease_treatment_80ddb     IN   NUMBER DEFAULT NULL
          ,p_sec_80ddb_senior_citizen    IN   VARCHAR2 DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : DECLARE_SECTION80U                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for storing the        --
--                  detials in 'Deduction under Section 80U' element.   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id per_assignments_f.assignment_id%TYPE--
--                  p_effective_date              DATE                  --
--            OUT : p_warnings                    BOOLEAN               --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE declare_section80U
          (p_assignment_id               IN   per_assignments_f.assignment_id%TYPE
          ,p_effective_date              IN   DATE DEFAULT NULL
          ,p_warnings                    OUT  NOCOPY BOOLEAN);


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_UPDATE_MODE                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Determines the update mode                          --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id pay_element_entries_f.element_entry_id%TYPE--
--                  p_effective_date              DATE                  --
--            OUT :                                                     --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_update_mode
   (p_element_entry_id IN pay_element_entries_f.element_entry_id%TYPE
   ,p_effective_date   IN DATE)
RETURN VARCHAR2;


END pay_in_tax_declaration;

/
