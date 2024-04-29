--------------------------------------------------------
--  DDL for Package Body PQP_FEDHR_USPAY_INTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_FEDHR_USPAY_INTG_PKG" 
/* $Header: pqpfhrel.pkb 120.2 2006/01/16 03:37:30 asubrahm noship $ */
AS
-- ********************************
-- Input Value Type Declaration
-- ********************************
TYPE input_vals_type IS RECORD
 (
    element_name            pay_element_types_f.element_name%TYPE,
    name                    pay_input_values_f.name%TYPE,
    uom_code                pay_input_values_f.uom%TYPE,
    mandatory_flag          pay_input_values_f.mandatory_flag%TYPE,
    generate_db_items_flag  pay_input_values_f.generate_db_items_flag%TYPE,
    display_sequence        pay_input_values_f.display_sequence%TYPE,
    lookup_type             pay_input_values_f.lookup_type%TYPE,
    effective_start_date    pay_input_values_f.effective_start_date%TYPE,
    effective_end_date      pay_input_values_f.effective_end_date%TYPE,
    warning_or_error        pay_input_values_f.warning_or_error%TYPE,
    legislation_code        pay_element_types_f.legislation_code%TYPE,
    formula_id              ff_formulas_f.formula_id%TYPE,
    business_group_name     per_business_groups.name%TYPE
 );

--=============================================================================
-- ********************************
-- Earnings Type Declaration
-- ********************************

 TYPE ele_earn_type IS RECORD
 ( ele_name                pay_all_earnings_types_v.element_name%TYPE,
   ele_reporting_name      pay_all_earnings_types_v.reporting_name%TYPE,
   ele_description         pay_all_earnings_types_v.description%TYPE,
   ele_classification_name pay_all_earnings_types_v.classification_name%TYPE,
   category                VARCHAR2(80),
   ele_ot_base             pay_all_earnings_types_v.include_in_ot_base%TYPE,
   flsa_hours              pay_all_earnings_types_v.flsa_hours%TYPE,
   ele_processing_type     pay_all_earnings_types_v.processing_type%TYPE,
   ele_priority            pay_all_earnings_types_v.processing_priority%TYPE,
   ele_standard_link       pay_all_earnings_types_v.standard_link_flag%TYPE,
   ele_calc_ff_id          ff_formulas_f.formula_id%TYPE,
   ele_calc_ff_name        ff_formulas_f.formula_name%TYPE,
   sep_check_option        VARCHAR2(4000),
   dedn_proc               VARCHAR2(4000),
   mix_flag                VARCHAR2(4000),
   reduce_regular          pay_all_earnings_types_v.reduce_regular%TYPE,
   ele_eff_start_date      pay_all_earnings_types_v.effective_start_date%TYPE,
   ele_eff_end_date        pay_all_earnings_types_v.effective_end_date%TYPE,
   alien_supp_category     VARCHAR2(4000),
   bg_id                   pay_all_earnings_types_v.business_group_id%TYPE,
   termination_rule        pay_element_types_f.post_termination_rule%TYPE,
   org_ele_name            Pay_all_earnings_types_v.element_name%TYPE,
   inp_val_low_range       NUMBER,
   inp_val_high_range      NUMBER
  );
--=============================================================================
-- ********************************
-- Earnings Type Declaration
-- ********************************
 TYPE ele_dedn_type IS RECORD
 ( ele_name                 pay_all_deduction_types_v.element_name%TYPE,
   ele_reporting_name       pay_all_deduction_types_v.reporting_name%TYPE,
   ele_description          pay_all_deduction_types_v.description%TYPE,
   ele_classification_name  pay_all_deduction_types_v.classification_name%TYPE,
   category                 VARCHAR2(4000),
   ben_class_id             pay_element_classifications.classification_id%TYPE,
   ele_processing_type      pay_all_deduction_types_v.processing_type%TYPE,
   ele_priority             pay_all_deduction_types_v.processing_priority%TYPE,
   ele_standard_link        pay_all_deduction_types_v.standard_link_flag%TYPE,
   ele_processing_runtype   pay_all_deduction_types_v.processing_run_type%TYPE,
   start_rule               VARCHAR2(150),
   stop_rule                VARCHAR2(150),
   amount_rule              VARCHAR2(150),
   series_ee_bond           VARCHAR2(150),
   payroll_table            pay_all_deduction_types_v.payroll_table%TYPE,
   paytab_column            VARCHAR2(4000),
   rowtype_meaning          VARCHAR2(4000),
   arrearage                VARCHAR2(150),
   deduct_partial           pay_all_deduction_types_v.deduct_partial%TYPE,
   employer_match           pay_all_deduction_types_v.employer_match_flag%TYPE,
   aftertax_component
         pay_all_deduction_types_v.aftertax_component_flag%TYPE,
   ele_eff_start_date       pay_all_earnings_types_v.effective_start_date%TYPE,
   ele_eff_end_date         pay_all_earnings_types_v.effective_end_date%TYPE,
   catchup_processing       VARCHAR2(150),
   termination_rule         pay_element_types_f.post_termination_rule%TYPE,
   srs_plan_type            VARCHAR2(150),
   srs_buy_back             VARCHAR2(150),
   bg_id                    pay_all_earnings_types_v.business_group_id%TYPE,
   org_ele_name             Pay_all_earnings_types_v.element_name%TYPE,
   inp_val_low_range        NUMBER,
   inp_val_high_range       NUMBER
  );

TYPE ele_dedn_type_var IS TABLE OF ele_dedn_type   INDEX BY BINARY_INTEGER;
TYPE ele_earn_type_var IS TABLE OF ele_earn_type   INDEX BY BINARY_INTEGER;
TYPE input_vals_var    IS TABLE OF input_vals_type INDEX BY BINARY_INTEGER;

g_package VARCHAR2(32) := 'PQP_FEDHR_ELE_CREATE';

p_bg_id            NUMBER;
p_eff_start_date   DATE;
p_earn             ele_earn_type_var;
p_dedn             Ele_dedn_type_var;
earn_input_vals    input_vals_var;
dedn_input_vals    input_vals_var;

  CURSOR get_prod_name(p_application_short_name
                             fnd_application.application_short_name%TYPE,
                       p_legislation_code VARCHAR2)
  IS
     SELECT fat.application_name application_name
     FROM   fnd_application    fa,
            fnd_application_tl fat
     WHERE  fa.application_id         = fat.application_id
     AND    fa.application_short_name = p_application_short_name
     AND    fat.language              = p_legislation_code;
--  ********************************************************************_
-- ---------------------------------------------------------------------------
-- |--------------------< populate_dc_ele_inp_tabs >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Assigning Values for Earnigns and Deduction Elements
--
-- Prerequisites:
-- Pl/Sql Table Structures for Earnings and Deductions, Input Values
--
-- In Parameters:
--   p_bg_id          - Business Group Id
--   p_eff_start_date - Start Date for Elements Creation
--   p_prefix         - Prefix for Element name for Customization
-- Out Parameters:
--
-- Post Success:
-- The Elements are assigned with Values to be created during Next step.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE populate_dc_ele_inp_tabs (p_bg_id   IN         NUMBER,
                            p_eff_start_date  IN         DATE,
                            p_prefix          IN         VARCHAR2,
                            p_ele_cnt         OUT NOCOPY NUMBER)
IS

l_ssn_start_date          DATE    :=TO_DATE('01-01-1951','DD-MM-YYYY');
l_end_of_time             DATE    :=TO_DATE('31-12-4712','DD-MM-YYYY');
l_end_date1               DATE    :=TO_DATE('30-09-2000','DD-MM-YYYY');
l_end_date2               DATE    :=TO_DATE('30-06-2001','DD-MM-YYYY');
l_bg_name                 VARCHAR2(240);
l_bg_id                   NUMBER;
l_prefix                  VARCHAR2(13);

l_earn_ele_tab_counter    NUMBER := 0;
l_input_value_counter     NUMBER := 0;
l_dedn_ele_tab_counter    NUMBER := 0;

CURSOR c_bgname(p_bg_id   NUMBER)
IS
SELECT name
FROM   per_business_groups_perf
WHERE  business_group_id=p_bg_id;

l_ff_flat_amt             VARCHAR2(240);
-- Formula 1 name
l_ff_hr_rt_recur          VARCHAR2(240);
-- Formula 2 name
l_ff_percent              VARCHAR2(240);
-- Formula 3 name

l_ff_flat_amt_non         VARCHAR2(240);
-- Formula 1 name
l_ff_hr_rt_non_recur      VARCHAR2(240);
-- Formula 2 name
l_ff_percent_non          VARCHAR2(240);
-- Formula 3 name

BEGIN

-- Formulae to be passed for Creating Elements
--==================================================
-- Initialization of Formula id for Recurring elements
--====================================================
l_ff_flat_amt        :='FLAT_AMOUNT_RECUR_V2';

l_ff_hr_rt_recur     :='HOURS_X_RATE_RECUR_V2';

l_ff_percent         :='PERCENTAGE_OF_REG_EARNINGS_RECUR_V2';

-- Initialization of Formula id for NON-Recurring elements
--========================================================
l_ff_flat_amt_non    :='FLAT_AMOUNT_NONRECUR_V2';

l_ff_hr_rt_non_recur :='HOURS_X_RATE_NONRECUR_V2';

l_ff_percent_non     :='PERCENTAGE_OF_REG_EARNINGS_NONRECUR_V2';

--
hr_utility.trace('Starts');
l_bg_id              :=p_bg_id;
l_prefix             :=p_prefix;
l_ssn_start_date     :=
     nvl(p_eff_start_date,to_Date('01-01-1951','DD-MM-YYYY'));

--
-- Cursor to pick the business group name
--
FOR c_bg_rec IN c_bgname(l_bg_id)
LOOP
      IF (c_bg_rec.name IS NOT NULL) then
        l_bg_name:=c_bg_rec.name;
      ELSE
        l_bg_name:=NULL;
      END IF;
hr_utility.trace('bg name is '||l_bg_name);
END LOOP;
--
hr_utility.trace('Starts');

-- #################################################################--
--                EARNINGS Elements ASSIGNMENT
-- #################################################################--

-- **************************************************************** --
--               1) Basic Salary Rate
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;

p_earn(l_earn_ele_tab_counter).ele_name                := 'Basic Salary Rate';
p_earn(l_earn_ele_tab_counter).org_ele_name            := 'Basic Salary Rate';
p_earn(l_earn_ele_tab_counter).ele_reporting_name      := 'Basic Salary Rate';
p_earn(l_earn_ele_tab_counter).ele_description         := 'Basic Salary Rate';
p_earn(l_earn_ele_tab_counter).ele_classification_name := 'Earnings';
p_earn(l_earn_ele_tab_counter).category                := 'REG';
p_earn(l_earn_ele_tab_counter).ele_ot_base             := 'Y';
p_earn(l_earn_ele_tab_counter).flsa_hours              := 'Y';
p_earn(l_earn_ele_tab_counter).ele_processing_type     := 'R';
p_earn(l_earn_ele_tab_counter).ele_priority            :=  1750;
p_earn(l_earn_ele_tab_counter).ele_standard_link       := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id          := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name        :=
                                           l_ff_hr_rt_recur;
p_earn(l_earn_ele_tab_counter).sep_check_option        := 'Y';
p_earn(l_earn_ele_tab_counter).dedn_proc               := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag                := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular          := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date      := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date        := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category     := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                   := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule        := 'L';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================
hr_utility.trace('Starts');
l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range       := l_input_value_counter;

earn_input_vals(l_input_value_counter).element_name    := 'Basic Salary Rate';
earn_input_vals(l_input_value_counter).name            := 'Salary';
earn_input_vals(l_input_value_counter).uom_code        := 'N';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
p_earn(l_earn_ele_tab_counter).inp_val_high_range     :=l_input_value_counter;

-- **************************************************************** --
--                        --2) AUO
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;
p_earn(l_earn_ele_tab_counter).ele_name                := 'AUO';
p_earn(l_earn_ele_tab_counter).org_ele_name            := 'AUO';
p_earn(l_earn_ele_tab_counter).ele_reporting_name      := 'AUO';
p_earn(l_earn_ele_tab_counter).ele_description         := 'AUO';
p_earn(l_earn_ele_tab_counter).ele_classification_name :=
                                                    'Earnings';
p_earn(l_earn_ele_tab_counter).category                := 'OP';
p_earn(l_earn_ele_tab_counter).ele_ot_base             := 'Y';
p_earn(l_earn_ele_tab_counter).flsa_hours              := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type     := 'R';
p_earn(l_earn_ele_tab_counter).ele_priority            :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link       := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id          := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name        := l_ff_percent;
p_earn(l_earn_ele_tab_counter).sep_check_option        :='N';
p_earn(l_earn_ele_tab_counter).dedn_proc               := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag                := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular          := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date      := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date        := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category     := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                   := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule        := 'L';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================

l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range := l_input_value_counter ;

earn_input_vals(l_input_value_counter).element_name    := 'AUO';
earn_input_vals(l_input_value_counter).name            := 'Premium Pay Ind';
earn_input_vals(l_input_value_counter).uom_code        := 'C';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := 'GHR_US_PREM_PAY_IND';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= 'E';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

p_earn(l_earn_ele_tab_counter).inp_val_high_range := l_input_value_counter;
--=============================================================================

-- **************************************************************** --
--                  --3) Availability Pay
-- **************************************************************** --

l_earn_ele_tab_counter                                 :=
                                                   l_earn_ele_tab_counter + 1;
p_earn(l_earn_ele_tab_counter).ele_name                := 'Availability Pay';
p_earn(l_earn_ele_tab_counter).org_ele_name            := 'Availability Pay';
p_earn(l_earn_ele_tab_counter).ele_reporting_name      := 'Avail. Pay';
p_earn(l_earn_ele_tab_counter).ele_description         := 'Availability Pay';
p_earn(l_earn_ele_tab_counter).ele_classification_name :=
                                                   'Earnings';
p_earn(l_earn_ele_tab_counter).category                := 'OP';
p_earn(l_earn_ele_tab_counter).ele_ot_base             := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours              := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type     := 'R';
p_earn(l_earn_ele_tab_counter).ele_priority            :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link       := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id          := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name        := l_ff_percent;
p_earn(l_earn_ele_tab_counter).sep_check_option        := 'N';
p_earn(l_earn_ele_tab_counter).dedn_proc               := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag                := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular          := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date      := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date        := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category     := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                   := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule        := 'L';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================

l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range       := l_input_value_counter;
earn_input_vals(l_input_value_counter).element_name    := 'Availability Pay';
earn_input_vals(l_input_value_counter).name            := 'Premium Pay Ind';
earn_input_vals(l_input_value_counter).uom_code        := 'C';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := 'GHR_US_PREM_PAY_IND';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error
                                                       := 'E';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
p_earn(l_earn_ele_tab_counter).inp_val_high_range      :=l_input_value_counter;
--=============================================================================

-- **************************************************************** --
--                    4) Federal Awards
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;

p_earn(l_earn_ele_tab_counter).ele_name                := 'Federal Awards';
p_earn(l_earn_ele_tab_counter).org_ele_name            := 'Federal Awards';
p_earn(l_earn_ele_tab_counter).ele_reporting_name      := 'Federal Awards';
p_earn(l_earn_ele_tab_counter).ele_description         := 'Federal Awards';
p_earn(l_earn_ele_tab_counter).ele_classification_name :=
                                                   'Supplemental Earnings';
p_earn(l_earn_ele_tab_counter).category                := 'A';
p_earn(l_earn_ele_tab_counter).ele_ot_base             := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours              := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type     := 'N';
p_earn(l_earn_ele_tab_counter).ele_priority            :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link       := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id          := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name        := l_ff_percent_non;
p_earn(l_earn_ele_tab_counter).sep_check_option        := 'Y';
p_earn(l_earn_ele_tab_counter).dedn_proc               := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag                := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular          := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date      := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date        := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category     := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                   := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule        := 'F';

--=============================================================================
-- No. of additional input values = 7
-- Percentage input value will be created by the template itself.
--=============================================================================

l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range      := l_input_value_counter;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Award Agency';
earn_input_vals(l_input_value_counter).uom_code        := 'C';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     :=
                                                     'GHR_US_AGENCY_CODE_2';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= 'E';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Award Type';
earn_input_vals(l_input_value_counter).uom_code        := 'C';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := 'GHR_US_AWARD_TYPE';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= 'E';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Amount';
earn_input_vals(l_input_value_counter).uom_code        := 'N';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Hours';
earn_input_vals(l_input_value_counter).uom_code        := 'H_DECIMAL2';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================

l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Group Award';
earn_input_vals(l_input_value_counter).uom_code        := 'I';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_date1;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            :=
                                                  'Tangible Benefit Dollars';
earn_input_vals(l_input_value_counter).uom_code        := 'I';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_date1;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Date Award Earned';
earn_input_vals(l_input_value_counter).uom_code        := 'D';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter  := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            := 'Appropriation Code';
earn_input_vals(l_input_value_counter).uom_code        := 'C';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     :=
                                                  'GHR_US_APPROPRIATION_CODE1';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= 'E';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Federal Awards';
earn_input_vals(l_input_value_counter).name            :=
                                                  'Date Ex Emp Award Paid';
earn_input_vals(l_input_value_counter).uom_code        := 'D';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

p_earn(l_earn_ele_tab_counter).inp_val_high_range    := l_input_value_counter;


-- **************************************************************** --
--                  5) Locality Pay
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;

p_earn(l_earn_ele_tab_counter).ele_name               := 'Locality Pay';
p_earn(l_earn_ele_tab_counter).org_ele_name           := 'Locality Pay';
p_earn(l_earn_ele_tab_counter).ele_reporting_name     := 'Locality Pay';
p_earn(l_earn_ele_tab_counter).ele_description        := 'Locality Pay';
p_earn(l_earn_ele_tab_counter).ele_classification_name:=
                                                'Earnings';
p_earn(l_earn_ele_tab_counter).category               := 'OP';
p_earn(l_earn_ele_tab_counter).ele_ot_base            := 'Y';
p_earn(l_earn_ele_tab_counter).flsa_hours             := 'Y';
p_earn(l_earn_ele_tab_counter).ele_processing_type    := 'R';
p_earn(l_earn_ele_tab_counter).ele_priority           :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link      := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id         :=  '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name       := l_ff_flat_amt;
p_earn(l_earn_ele_tab_counter).sep_check_option       := 'N';
p_earn(l_earn_ele_tab_counter).dedn_proc              := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag               := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular         := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date     := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date       := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category    := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                  := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule       := 'L';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================
p_earn(l_earn_ele_tab_counter).inp_val_low_range      := NULL;


-- **************************************************************** --
--                     6) Recruitment Bonus
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;

p_earn(l_earn_ele_tab_counter).ele_name               := 'Recruitment Bonus';
p_earn(l_earn_ele_tab_counter).org_ele_name           := 'Recruitment Bonus';
p_earn(l_earn_ele_tab_counter).ele_reporting_name     := 'Recruit Bonus';
p_earn(l_earn_ele_tab_counter).ele_description        := 'Recruitment Bonus';
p_earn(l_earn_ele_tab_counter).ele_classification_name:=
                                                     'Supplemental Earnings';
p_earn(l_earn_ele_tab_counter).category               := 'B';
p_earn(l_earn_ele_tab_counter).ele_ot_base            := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours             := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type    := 'N';
p_earn(l_earn_ele_tab_counter).ele_priority           :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link      := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id         := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name       := l_ff_flat_amt_non;
p_earn(l_earn_ele_tab_counter).sep_check_option       := 'Y';
p_earn(l_earn_ele_tab_counter).dedn_proc              := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag               := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular         := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date     := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date       := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category    := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                  := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule       := 'F';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================

l_input_value_counter  := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range      := l_input_value_counter;
earn_input_vals(l_input_value_counter).element_name    := 'Recruitment Bonus';
earn_input_vals(l_input_value_counter).name            := 'Expiration Date';
earn_input_vals(l_input_value_counter).uom_code        := 'D';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

p_earn(l_earn_ele_tab_counter).inp_val_high_range     := l_input_value_counter;
--=============================================================================


-- **************************************************************** --
--                7) Relocation Bonus
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;

p_earn(l_earn_ele_tab_counter).ele_name               := 'Relocation Bonus';
p_earn(l_earn_ele_tab_counter).org_ele_name           := 'Relocation Bonus';
p_earn(l_earn_ele_tab_counter).ele_reporting_name     := 'Reloc Bonus';
p_earn(l_earn_ele_tab_counter).ele_description        := 'Relocation Bonus';
p_earn(l_earn_ele_tab_counter).ele_classification_name:=
                                                    'Supplemental Earnings';
p_earn(l_earn_ele_tab_counter).category               := 'B';
p_earn(l_earn_ele_tab_counter).ele_ot_base            := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours             := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type    := 'N';
p_earn(l_earn_ele_tab_counter).ele_priority           :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link      := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id         := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name       := l_ff_flat_amt_non;
p_earn(l_earn_ele_tab_counter).sep_check_option       := 'Y';
p_earn(l_earn_ele_tab_counter).dedn_proc              := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag               := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular         := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date     := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date       := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category    := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                  := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule       := 'F';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range      := l_input_value_counter;

earn_input_vals(l_input_value_counter).element_name    := 'Relocation Bonus';
earn_input_vals(l_input_value_counter).name            := 'Expiration Date';
earn_input_vals(l_input_value_counter).uom_code        := 'D';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;
p_earn(l_earn_ele_tab_counter).inp_val_high_range    := l_input_value_counter;
--=============================================================================

-- **************************************************************** --
--                 8) Retention Allowance
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;

p_earn(l_earn_ele_tab_counter).ele_name               := 'Retention Allowance';
p_earn(l_earn_ele_tab_counter).org_ele_name           := 'Retention Allowance';
p_earn(l_earn_ele_tab_counter).ele_reporting_name     := 'Ret Allowance';
p_earn(l_earn_ele_tab_counter).ele_description        := 'Retention Allowance';
p_earn(l_earn_ele_tab_counter).ele_classification_name:=
                                                       'Supplemental Earnings';
p_earn(l_earn_ele_tab_counter).category               := 'ALW';
p_earn(l_earn_ele_tab_counter).ele_ot_base            := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours             := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type    := 'R';
p_earn(l_earn_ele_tab_counter).ele_priority           :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link      := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id         := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name       := l_ff_percent;
p_earn(l_earn_ele_tab_counter).sep_check_option       := 'N';
p_earn(l_earn_ele_tab_counter).dedn_proc              := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag               := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular         := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date     := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date       := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category    := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                  := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule       := 'L';
--Term rule changed

--=============================================================================
-- No. of additional input values = 2
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range     := l_input_value_counter;
earn_input_vals(l_input_value_counter).element_name   := 'Retention Allowance';
earn_input_vals(l_input_value_counter).name           := 'Date';
earn_input_vals(l_input_value_counter).uom_code       := 'D';
earn_input_vals(l_input_value_counter).mandatory_flag := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                      := 'Y';
earn_input_vals(l_input_value_counter).lookup_type    := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                      := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                      := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                      := l_bg_name;

--=============================================================================
l_input_value_counter:= l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name   := 'Retention Allowance';
earn_input_vals(l_input_value_counter).name           := 'Amount';
earn_input_vals(l_input_value_counter).uom_code       := 'I';
earn_input_vals(l_input_value_counter).mandatory_flag := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                      := 'Y';
earn_input_vals(l_input_value_counter).lookup_type    := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                      := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                      := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                      := l_bg_name;

p_earn(l_earn_ele_tab_counter).inp_val_high_range     := l_input_value_counter;
--=============================================================================
-- **************************************************************** --
--                9) Severance Pay
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;
p_earn(l_earn_ele_tab_counter).ele_name                := 'Severance Pay';
p_earn(l_earn_ele_tab_counter).org_ele_name            := 'Severance Pay';
p_earn(l_earn_ele_tab_counter).ele_reporting_name      := 'Severance Pay';
p_earn(l_earn_ele_tab_counter).ele_description         := 'Severance Pay';
p_earn(l_earn_ele_tab_counter).ele_classification_name :=
                                                  'Supplemental Earnings';
p_earn(l_earn_ele_tab_counter).category                := 'DP';
p_earn(l_earn_ele_tab_counter).ele_ot_base             := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours              := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type     := 'N';
p_earn(l_earn_ele_tab_counter).ele_priority            :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link       := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id          := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name        := l_ff_flat_amt_non;
p_earn(l_earn_ele_tab_counter).sep_check_option        := 'Y';
p_earn(l_earn_ele_tab_counter).dedn_proc               := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag                := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular          := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date      := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date        := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category     := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                   := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule        := 'F';

--=============================================================================
-- No. of additional input values = 3
--=============================================================================
l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range      := l_input_value_counter;

earn_input_vals(l_input_value_counter).element_name    := 'Severance Pay';
earn_input_vals(l_input_value_counter).name            :=
                                                'Total Entitlement Weeks';
earn_input_vals(l_input_value_counter).uom_code        := 'I';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

--=============================================================================
l_input_value_counter := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Severance Pay';
earn_input_vals(l_input_value_counter).name            := 'Number Weeks Paid';
earn_input_vals(l_input_value_counter).uom_code        := 'I';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

--=============================================================================
l_input_value_counter  := l_input_value_counter + 1;

earn_input_vals(l_input_value_counter).element_name    := 'Severance Pay';
earn_input_vals(l_input_value_counter).name            := 'Weekly Amount';
earn_input_vals(l_input_value_counter).uom_code        := 'N';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag := 'Y';
earn_input_vals(l_input_value_counter).lookup_type     := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= '';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

p_earn(l_earn_ele_tab_counter).inp_val_high_range     := l_input_value_counter;

--=============================================================================

-- **************************************************************** --
--               10) Supervisory Differential
-- **************************************************************** --

l_earn_ele_tab_counter := l_earn_ele_tab_counter + 1;
p_earn(l_earn_ele_tab_counter).ele_name               :=
                                                 'Supervisory Differential';
p_earn(l_earn_ele_tab_counter).org_ele_name           :=
                                                 'Supervisory Differential';
p_earn(l_earn_ele_tab_counter).ele_reporting_name     := 'Sup Differential';
p_earn(l_earn_ele_tab_counter).ele_description        :=
                                                 'Supervisory Differential';
p_earn(l_earn_ele_tab_counter).ele_classification_name:=
                                                    'Supplemental Earnings';
p_earn(l_earn_ele_tab_counter).category               := 'ALW';
p_earn(l_earn_ele_tab_counter).ele_ot_base            := 'N';
p_earn(l_earn_ele_tab_counter).flsa_hours             := 'N';
p_earn(l_earn_ele_tab_counter).ele_processing_type    := 'R';
p_earn(l_earn_ele_tab_counter).ele_priority           :=  2500;
p_earn(l_earn_ele_tab_counter).ele_standard_link      := 'N';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_id         := '';
p_earn(l_earn_ele_tab_counter).ele_calc_ff_name       := l_ff_percent;
p_earn(l_earn_ele_tab_counter).sep_check_option       := 'N';
p_earn(l_earn_ele_tab_counter).dedn_proc              := 'A';
p_earn(l_earn_ele_tab_counter).mix_flag               := NULL;
p_earn(l_earn_ele_tab_counter).reduce_regular         := 'N';
p_earn(l_earn_ele_tab_counter).ele_eff_start_date     := l_ssn_start_date;
p_earn(l_earn_ele_tab_counter).ele_eff_end_date       := l_end_of_time;
p_earn(l_earn_ele_tab_counter).alien_supp_category    := NULL;
p_earn(l_earn_ele_tab_counter).bg_id                  := l_bg_id;
p_earn(l_earn_ele_tab_counter).termination_rule       := 'L';

--=============================================================================
-- No. of additional input values = 1
--=============================================================================

l_input_value_counter := l_input_value_counter + 1;
p_earn(l_earn_ele_tab_counter).inp_val_low_range      := l_input_value_counter;

earn_input_vals(l_input_value_counter).element_name    :=
                                        'Supervisory Differential';
earn_input_vals(l_input_value_counter).name            := 'Amount';
earn_input_vals(l_input_value_counter).uom_code        := 'I';
earn_input_vals(l_input_value_counter).mandatory_flag  := 'N';
earn_input_vals(l_input_value_counter).generate_db_items_flag
                                                       := 'Y';
earn_input_vals(l_input_value_counter).lookup_type      := '';
earn_input_vals(l_input_value_counter).effective_start_date
                                                       := l_ssn_start_date;
earn_input_vals(l_input_value_counter).effective_end_date
                                                       := l_end_of_time;
earn_input_vals(l_input_value_counter).warning_or_error:= 'E';
earn_input_vals(l_input_value_counter).legislation_code:= '';
earn_input_vals(l_input_value_counter).business_group_name
                                                       := l_bg_name;

p_earn(l_earn_ele_tab_counter).inp_val_high_range     := l_input_value_counter;
--=============================================================================

-- **************************************************************** --
--             End Of Earnings Assignments
-- **************************************************************** --

--p_ele_cnt := l_earn_ele_tab_counter + l_dedn_ele_tab_counter;
hr_utility.trace('Total Elements'||to_char(p_ele_cnt));
hr_utility.trace('Assign vals completed');

p_ele_cnt := l_earn_ele_tab_counter;

END populate_dc_ele_inp_tabs;

-- End of Assigning Values to Earnings and Deductions
--###====================================================================###

-- ---------------------------------------------------------------------------
--       |--------------------< Input_values >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Calls wrapper to create Input Values.
--
-- Prerequisites:
-- Pl/Sql Table Structures for Earnings and Deductions, Input Values
-- Initialized with the Data
--
-- In Parameters:
--   p_inp_vals_tab   - Inputs Value record Structure
--   p_cnt            - The NUMBER from which the display sequence
--                      for GHR input values start
--   p_inp_cnt        - The no of Input values to be created
--                      for an element.

-- Out Parameters:
--
-- Post Success:
-- The GHR/ FHR Input Values are created for Elements.
--
-- Post Failure:
-- An application error will be raised and processing is terminated
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE input_values(
input_value_tab                input_vals_var,
 p_cnt                 IN      NUMBER,
input_value_low_range          NUMBER,
input_value_high_range         NUMBER,
p_prefix                       VARCHAR2 )

IS

l_cntr                         NUMBER;
l_input_value_id               NUMBER;
l_prefix                       VARCHAR2(13);
--
BEGIN
--

l_prefix := null;
l_cntr   :=p_cnt;

hr_utility.trace('entering input vals');

FOR l IN input_value_low_range..input_value_high_range
LOOP

hr_utility.trace(input_value_tab(l).name);
hr_utility.trace(input_value_tab(l).element_name);

   l_input_value_id:= pay_db_pay_setup.create_input_value (
        p_element_name          => input_value_tab(l).element_name,
        p_name                  => input_value_tab(l).name,
        p_display_sequence      => l_cntr,
        p_uom_code              => input_value_tab(l).uom_code,
        p_mandatory_flag        => input_value_tab(l).mandatory_flag,
        p_generate_db_item_flag => input_value_tab(l).generate_db_items_flag,
        p_effective_start_date  => input_value_tab(l).effective_start_date,
        p_effective_end_date    => input_value_tab(l).effective_end_date,
        p_legislation_code      => input_value_tab(l).legislation_code,
        p_warn_or_error_code    => input_value_tab(l).warning_or_error,
        p_lookup_type           => input_value_tab(l).lookup_type,
        p_business_group_name   => input_value_tab(l).business_group_name
);
l_cntr:=l_cntr+1;
--- Using this counter for incrementing the Display Sequence

END LOOP;

hr_utility.trace('out of inp vals');

END input_values;
--###====================================================================###

--
--
-- ---------------------------------------------------------------------------
--       |--------------------< Chk_ele_exists >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Checks for the existence of element passed and then returns
--   new element name if exists else old element name.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_ele_name   - Element to be checked for existence
--   p_bg_id      - Business Group Id

-- Out Parameters:
--  p_ele_name     - Element name.
--
-- Post Success:
--  Returns new element name if element already exists by suffixing no.
--  Else returns back the passed element name.
--
-- Post Failure:
-- An application error will be raised and processing is terminated
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

FUNCTION  chk_ele_exists(
                        p_ele_name IN OUT NOCOPY VARCHAR2,
                        p_bg_id    IN            NUMBER
                        )
RETURN VARCHAR2 IS

  -- Cursor to check if Element Already exists
CURSOR c_ele_exists(p_ele_name IN VARCHAR2,
                    p_bg_id       NUMBER)
IS
       SELECT element_name ele_name
       FROM   pay_element_types_f
       WHERE  element_name=p_ele_name
       AND    business_group_id=p_bg_id;

l_new_name         VARCHAR2(80);
l_ele_name         VARCHAR2(80);
l_cntr             NUMBER:=0;
l_flag             BOOLEAN:=FALSE;

--
BEGIN
--

l_ele_name := p_ele_name;

OPEN c_ele_exists(p_ele_name,p_bg_id);
FETCH c_ele_exists INTO l_ele_name;

IF c_ele_exists%NOTFOUND
THEN
   -- If element is not found return same ele name
      l_flag      := FALSE;
      RETURN(l_ele_name);
ELSE
      l_flag:= TRUE;
CLOSE c_ele_exists;

 WHILE l_flag=TRUE
 LOOP
     <<label1>>

      l_cntr        := l_cntr+1;
      l_new_name    := l_ele_name||TO_CHAR(l_cntr);
      IF ((LENGTH(l_ele_name) > 25 ) OR (LENGTH(l_new_name) > 25))
      THEN
      l_new_name    :=
         SUBSTR( l_ele_name,1,(LENGTH(l_ele_name) - LENGTH(l_cntr)) )
         ||TO_CHAR(l_cntr);
      END IF;

       FOR rec IN c_ele_exists(l_new_name,p_bg_id)
       LOOP
         l_flag     :=TRUE;
       GOTO label1;
       END LOOP;
         l_flag     :=FALSE;
       RETURN(l_new_name);

 END LOOP; -- End of While
END IF;
END;

--###====================================================================###
----
-- ---------------------------------------------------------------------------
--       |--------------------< Earnings >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Calls Earnings wrapper to create Earnigns Elements and
--   Corresponding Payroll Input Values
--
-- Prerequisites:
-- Pl/Sql Table Structures for Earnings and Deductions, Input Values
-- Initialized with the Data
--
-- In Parameters:
--
-- Out Parameters:
--
-- Post Success:
-- The Earnings Elements with Payroll/GHR Input Values are created.
--
-- Post Failure:
-- An application error will be raised and processing is terminated
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

PROCEDURE earnings(
                  p_prefix   IN         VARCHAR2,
                  p_earn_cnt OUT NOCOPY NUMBER) IS

l_index                 NUMBER;
l_cnt                   NUMBER;
l_element_type_id       NUMBER;
l_prefix                VARCHAR2(13);

-- Modified  the cursor to pick Max(display sequence) as Disp Seq for
-- 2 elements is overlapping and count(*) thus picking val +1 greater

CURSOR c_no_of_input_vals(p_element_type_id IN NUMBER)
 IS
SELECT max(display_sequence)   count
FROM   pay_input_values_f
WHERE  element_type_id=p_element_type_id;

TYPE PB_REC IS RECORD
(
 pay_basis VARCHAR2(80)
);
TYPE paybasis IS TABLE OF PB_REC INDEX BY BINARY_INTEGER;
PB                      paybasis;

l_rec                   pqp_pcv_shd.g_rec_type;
l_PB_indx               NUMBER;
l_ele_name              VARCHAR2(80);
l_bg_id                 NUMBER;
l_new_name              VARCHAR2(80);
l_prfx_ele_name         VARCHAR2(80);
l_subscript             NUMBER;
l_mesg                  VARCHAR2(4000);

--
BEGIN
--

-- Initialization
l_prefix  :=p_prefix;
p_earn_cnt:=0;
--

FOR l_index IN 1..p_earn.COUNT
LOOP

hr_utility.trace('EARNINGS');
hr_utility.trace(l_prefix || ' ' || p_earn(l_index).ele_name);
--
-----------------------------------------------------------------
-- check to see if Element already exists with this prefix
-----------------------------------------------------------------
--
l_prfx_ele_name := l_prefix||' ' || p_earn(l_index).ele_name;
l_bg_id         := p_earn(l_index).bg_id;

----**********************************************************************
--  Check if Element already exists. If so suffix the element with a number
--  and then wrapper procedure is called for Element Creation
----**********************************************************************

l_ele_name:=chk_ele_exists(p_ele_name  => l_prfx_ele_name,
                           p_bg_id     => l_bg_id);
----**********************************************************************
--
p_earn(l_index).ele_reporting_name :=
                l_prefix
              || ' '
              ||to_char(sysdate,'HH24:MM:SS')
              ||p_earn(l_index).ele_reporting_name;

l_element_type_id:=
    pay_us_earn_templ_wrapper.create_earnings_element(
        p_ele_name              => l_ele_name,
        p_ele_reporting_name    => p_earn(l_index).ele_reporting_name,
        p_ele_description       =>  p_earn(l_index).ele_description,
        p_ele_classification    =>  p_earn(l_index).ele_classification_name,
        p_ele_category          =>  p_earn(l_index).category,
        p_ele_ot_base           =>  p_earn(l_index).ele_ot_base,
        p_flsa_hours            =>  p_earn(l_index).flsa_hours,
        p_ele_processing_type   =>  p_earn(l_index).ele_processing_type,
        p_ele_priority          =>  '',
        p_ele_standard_link     =>  p_earn(l_index).ele_standard_link,
        p_ele_calc_ff_id        =>  '',
        p_ele_calc_ff_name      =>  p_earn(l_index).ele_calc_ff_name,
        p_sep_check_option      =>  p_earn(l_index).sep_check_option,
        p_dedn_proc             =>  p_earn(l_index).dedn_proc,
        p_mix_flag              =>  p_earn(l_index).mix_flag,
        p_reduce_regular        =>  p_earn(l_index).reduce_regular,
        p_ele_eff_start_date    =>  p_earn(l_index).ele_eff_start_date,
        p_ele_eff_end_date      =>  p_earn(l_index).ele_eff_end_date,
        p_alien_supp_category   =>  p_earn(l_index).alien_supp_Category,
        p_bg_id                 =>  p_earn(l_index).bg_id,
        p_termination_rule      =>  p_earn(l_index).termination_rule);

--****************************************************************
-- Make an Entry into PQP_CONFIGURATION_VALUES Table once
-- the  element is created after calling template wrapper
--****************************************************************
   IF ( p_earn(l_index).org_ele_name = 'Basic Salary Rate' )
   THEN
    PB(1).pay_basis:='PA';
    PB(2).pay_basis:='PM';
    PB(3).pay_basis:='PH';

    FOR l_PB_indx IN 1..PB.count
    LOOP
     l_rec.business_group_id := p_earn(l_index).bg_id;
     l_rec.pcv_information_category:= 'PQP_FEDHR_ELEMENT';
     l_rec.pcv_information1 := p_earn(l_index).org_ele_name;
     l_rec.pcv_information2 := l_element_type_id;
     l_rec.pcv_information3 := PB(l_PB_indx).pay_basis;

     -- Call Insert Row Handler
     pqp_pcv_ins.ins(p_earn(l_index).ele_eff_start_date,l_rec);
    END LOOP;

   ELSE
   -- Element is not Basic Salary Rate
     l_rec.business_group_id        := p_earn(l_index).bg_id;
     l_rec.pcv_information_category := 'PQP_FEDHR_ELEMENT';
     l_rec.pcv_information1 := p_earn(l_index).org_ele_name;
     l_rec.pcv_information2 := l_element_type_id;
     l_rec.pcv_information3 := NULL;

     -- Call Update row handler
     pqp_pcv_ins.ins(p_earn(l_index).ele_eff_start_date,l_rec);
   END IF;

--****************************************************************

  IF (p_earn(l_index).inp_val_low_range IS NOT NULL)
  THEN
      FOR cnt_rec IN c_no_of_input_vals(l_element_type_id)
      LOOP
       l_cnt:=cnt_rec.count;
      END LOOP;
   l_cnt:=l_cnt+1;

  --****************************************************************
  -- whether element is new or old pick the ele name from l_ele_name
  -- pass the same value to input valule table
  --****************************************************************
      FOR l_subscript IN
  p_earn(l_index).inp_val_low_range..p_earn(l_index).inp_val_high_range
      LOOP
        earn_input_vals(l_subscript).element_name := l_ele_name;
      END LOOP;

     input_values(
       input_value_tab        => earn_input_vals,
       p_cnt                  => l_cnt,
       input_value_low_range  => p_earn(l_index).inp_val_low_range,
       input_value_high_range => p_earn(l_index).inp_val_high_range,
       p_prefix               => p_prefix);

  END IF; -- End of if which checks for LOW RANGE is not null


--****************************************************************
--  Mapping of Old Element to New Name
-- Example Federal Awards to AM Federal Awards etc/
--****************************************************************

hr_utility.set_message(8303,'HR_374605_MAPPING_OLD_TO_NEW');
hr_utility.set_message_token('OLD_NAME',
                 rpad(p_earn(l_index).org_ele_name,30));
hr_utility.set_message_token('NEW_NAME',rpad(l_ele_name,30));
l_mesg:=hr_utility.get_message;
fnd_file.put(fnd_file.log,l_mesg);
fnd_file.new_line(fnd_file.log);

--****************************************************************

hr_utility.trace(
'Created EARNINGS Element'||p_earn(l_index).ele_name||TO_CHAR(l_index));

--######## Count number of Earnings Elements created
 p_earn_cnt := p_earn_cnt + 1;
--########

END LOOP;

END earnings;
--###====================================================================###

--
-- ---------------------------------------------------------------------------
--       |--------------------< Deductions >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Calls Deductions wrapper to create Deductions Elements and
--   Corresponding Payroll Input Values
--
-- Prerequisites:
-- Pl/Sql Table Structures for Earnings and Deductions, Input Values
-- Initialized with the Data
--
-- In Parameters:
--
-- Out Parameters:
--
-- Post Success:
-- The Deductions Elements with Payroll/GHR Input Values are created.
--
-- Post Failure:
-- An application error will be raised and processing is terminated
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

--Procedure deductions(
--                     p_prefix    IN  VARCHAR2,
--                     p_dedn_cnt  OUT NUMBER) IS

--l_index                 NUMBER; --j NUMBER;
--l_cnt                   NUMBER;
--l_element_type_id       NUMBER;

--CURSOR c_no_of_input_vals(p_element_type_id in NUMBER) is
--        select count(*) count
--        from pay_input_values_f
--        where element_type_id=p_element_type_id;
--l_prefix VARCHAR2(13);
--l_rec                   pqp_pcv_shd.g_rec_type;
--l_ele_name              VARCHAR2(80);
--l_prfx_ele_name         VARCHAR2(80);
--l_bg_id                 NUMBER;
--l_mesg                  VARCHAR2(4000);
--BEGIN

-- Initialization
--l_prefix:=p_prefix;
--p_dedn_cnt :=0;
--
--hr_utility.trace('ded count is ' || to_char(p_dedn.COUNT));
--
--FOR l_index in 1..p_dedn.COUNT
--Loop
--hr_utility.trace('DEDUCTIONS');
----
-------------------------------------------------------------------
---- Truncating Element name to 13 chars
-------------------------------------------------------------------
---- check to see if Element already exists with this prefix
--l_prfx_ele_name  := substr(l_prefix||' ' || p_dedn(l_index).ele_name,1,13);
--l_bg_id          := p_dedn(l_index).bg_id;
--
------**********************************************************************
----  Check if Element already exists. If so suffix the element with a number
---  and then wrapper procedure is called for Element Creation
------**********************************************************************
--
--l_ele_name :=chk_ele_exists(p_ele_name  => l_prfx_ele_name,
--                            p_bg_id     => l_bg_id);
--
--l_element_type_id:=
--     pay_us_dedn_template_wrapper.create_deduction_element (
--        p_element_name                  => l_ele_name,
--                    --     l_prefix|| ' ' || p_dedn(l_index).ele_name,
--        p_reporting_name                => l_ele_name,
--        -- p_dedn(l_index).ele_reporting_name||l_index,
--        --substr(l_ele_name||l_index,1,13),
--        --p_dedn(l_index).ele_reporting_name||l_index,
--        --l_prefix|| ' ' ||
--
--        p_description                   =>  p_dedn(l_index).ele_description,
--        p_classification_name           =>
--                                p_dedn(l_index).ele_classification_name,
--        p_ben_class_id                  =>  p_dedn(l_index).ben_class_id ,
--        p_category                      =>  p_dedn(l_index).category,
--        p_processing_type               =>
--                                p_dedn(l_index).ele_Processing_Type,
--        p_processing_priority           =>  '',
--        p_standard_link_flag            =>
--                                p_dedn(l_index).ele_Standard_Link,
--        p_processing_runtype            =>
--                                p_dedn(l_index).ele_Processing_runType,
--        p_start_rule                    =>  p_dedn(l_index).start_rule,
--        p_stop_rule                     =>  p_dedn(l_index).stop_rule,
--        p_amount_rule                   =>  p_dedn(l_index).amount_rule,
--        p_series_ee_bond                =>  p_dedn(l_index).series_ee_bond,
--        p_payroll_table                 =>  p_dedn(l_index).payroll_table,
--        p_paytab_column                 =>  p_dedn(l_index).paytab_column,
--        p_rowtype_meaning               =>  p_dedn(l_index).rowtype_meaning,
--        p_arrearage                     =>  p_dedn(l_index).arrearage,
--        p_deduct_partial                =>  p_dedn(l_index).deduct_partial,
--        p_employer_match                =>  p_dedn(l_index).employer_match,
--        p_aftertax_component            =>
--                                p_dedn(l_index).aftertax_component,
--        p_ele_eff_start_date            =>
--                                p_dedn(l_index).ele_eff_start_date,
--        p_ele_eff_end_date              =>
--                                p_dedn(l_index).ele_eff_end_date,
--        p_catchup_processing            =>
--                                p_dedn(l_index).catchup_processing,
--        p_Termination_rule              =>  p_dedn(l_index).Termination_rule,
--        p_srs_plan_type                 =>  p_dedn(l_index).srs_plan_type,
--        p_srs_buy_back                  =>  p_dedn(l_index).srs_buy_back,
--        p_business_group_id             =>  p_dedn(l_index).bg_id);
--
--l_rec.business_group_id := p_dedn(l_index).bg_id;
--l_rec.pcv_information_category:= 'PQP_FEDHR_ELEMENT';
--l_rec.pcv_information1  := p_dedn(l_index).org_ele_name;
--l_rec.pcv_information2 := l_element_type_id;
--pqp_pcv_ins.ins(p_dedn(l_index).ele_eff_start_date,l_rec);
--
--
--     IF (p_dedn(l_index).inp_val_low_range IS NOT NULL)
--     THEN
--hr_utility.trace('not null ----');
--        FOR cnt_rec in c_no_of_input_vals(l_element_type_id)
--        LOOP
--        l_cnt:=cnt_rec.count;
--        END LOOP;
--        l_cnt:=l_cnt+1;
--hr_utility.trace('inp count is ' || to_char(l_cnt));
--hr_utility.trace('low inp ' || to_char(p_dedn(l_index).inp_val_low_range));
--hr_utility.trace('high  ' || to_char(p_dedn(l_index).inp_val_high_range));
--
--
----****************************************************************
---- whether element is new or old pick the ele name from l_ele_name
---- pass the same value to input valule table
----*****************************************************************
--FOR l_subscript IN
--  p_dedn(l_index).inp_val_low_range..p_dedn(l_index).inp_val_high_range
--LOOP
--      dedn_input_vals(l_subscript).element_name := l_ele_name;
--END LOOP;
--
--input_values(
--   input_value_tab        => dedn_input_vals,
--   p_cnt                  => l_cnt,
--   input_value_low_range  => p_dedn(l_index).inp_val_low_range,
--   input_value_high_range => p_dedn(l_index).inp_val_high_range,
--   p_prefix               => p_prefix);
----
------****************************************************************
----  Mapping of Old Element to New Name
----  Example Health Benefits to AM Health Ben1
----******************************************************************
--hr_utility.set_message(8303,'HR_374605_MAPPING_OLD_TO_NEW');
--hr_utility.set_message_token('OLD_NAME',p_dedn(l_index).org_ele_name);
--hr_utility.set_message_token('NEW_NAME',l_ele_name);
--l_mesg:=hr_utility.get_message;
--fnd_file.put(fnd_file.log,l_mesg);
--fnd_file.new_line(fnd_file.log);
--
----******************************************************************
--
--hr_utility.trace
--('Dedn Low range for all'|| to_Char(p_dedn(l_index).inp_val_low_range));
--
--    END IF;
--
--hr_utility.trace(
--'Created DEDUCTIONS Element'||p_dedn(l_index).ele_name);
--
----######### Count of Deduction Elements created
--p_dedn_cnt := p_dedn_cnt + 1;
----#########
--
--END LOOP;
--
--END deductions;
------------------------------------------------------------------------------
--


--
-- ---------------------------------------------------------------------------
--  |--------------------< pqp_fedhr_element_creation >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Checks for
--     1) GHR,PAY Product Installations.Proceeds if Installed.
--     2) If already script is run,if yes stops exec.
--     3) If for the Element Prefix passed, any Element Link exists stops exec.
--     4) After all checks the Script creates the Federal Payroll Elements.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--###====================================================================###
--  Called by Conc Prog to create Federal Payroll Elements
--          This is a public procedure.
--###====================================================================###
--

PROCEDURE pqp_fedhr_element_creation
(
   errbuf              OUT NOCOPY VARCHAR2 ,
   retcode             OUT NOCOPY NUMBER   ,
   p_business_group_id NUMBER  ,
   p_effective_date    VARCHAR2    ,
   p_prefix            VARCHAR2
) IS
  l_dt                 DATE;
  l_req_id             NUMBER;
-- ASHU Change the following vars to %TYPE
  l_mesg               VARCHAR2(4000);
  l_app_name           VARCHAR2(100);
-- ASHU Whether to use language or source_language.
-- Determine legislation_code dynamically from Biz Group.

l_ele_cnt              NUMBER;
l_earn_cnt             NUMBER;
l_dedn_cnt             NUMBER;
l_tot_cnt              NUMBER;
l_index                NUMBER;
l_ele_lnk_flg          BOOLEAN:=FALSE;
l_lnk_exist_cnt        NUMBER:=0;
l_lnk_exist_cnt1       NUMBER:=0;
l_ele_name             VARCHAR2(80);
l_def_date             VARCHAR2(22):='1951/01/01 00:00:00';
l_max_date             VARCHAR2(22):='4712/12/31 23:59:59';

BEGIN

l_dt := fnd_date.canonical_to_date(p_effective_date);
l_def_date := fnd_date.canonical_to_date(l_def_date);
l_max_date := fnd_date.canonical_to_date(l_max_date);
----**********************************************************************
--            CHECK#  : Date must be >= 01-JAN-1951
----**********************************************************************

IF ( l_dt < l_def_date)
THEN
hr_utility.set_message(8303,'HR_374608_GREATR_DEF_DATE');
        l_mesg := l_mesg || hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
hr_utility.raise_error;
END IF;
----**********************************************************************
--            CHECK#  : Date must be < 31-DEC-4712
----**********************************************************************

IF ( l_dt > l_max_date)
THEN
hr_utility.set_message(8303,'HR_374609_LESSTHN_MAX_DATE');
        l_mesg := l_mesg || hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
hr_utility.raise_error;
END IF;
----**********************************************************************
--           CHECK#   :- Does prefix start with a
--                       number or any special character?
----**********************************************************************
IF (ascii(substr(p_prefix,1,1)) NOT BETWEEN ascii('a') AND ascii('z')
AND ascii(substr(p_prefix,1,1)) NOT between ascii('A') AND ascii('Z') )
THEN
hr_utility.set_message(8303,'HR_374610_STRTS_WTH_NUM_SPCL');
        l_mesg := l_mesg || hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
hr_utility.raise_error;
END IF;

----**********************************************************************
--           CHECK # :- Existence of GHR Product
----**********************************************************************

    IF (hr_utility.chk_product_install('GHR','US')  <> TRUE )
    THEN
        hr_utility.set_message(8303,'HR_374601_PROD_NOT_INSTALLED');
        FOR c_gpn IN get_prod_name('GHR','US')
        LOOP
            l_app_name := c_gpn.application_name;
        END LOOP;
        hr_utility.set_message_token('PROD',l_app_name);
        --hr_utility.raise_error;
        l_mesg := hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
        hr_multi_message.add(p_associated_column1 => 'Y');
    END IF;

----**********************************************************************
--           CHECK # :- Existence of PAYROLL Product
----**********************************************************************

    IF ( hr_utility.chk_product_install('PAY', 'US') <> TRUE )
    THEN
        hr_utility.set_message(8303,'HR_374601_PROD_NOT_INSTALLED');
        FOR c_gpn IN get_prod_name('PAY','US')
        LOOP
            l_app_name := c_gpn.application_name;
        END LOOP;
        hr_utility.set_message_token('PROD',l_app_name);
        l_mesg := l_mesg || hr_utility.get_message;
        --hr_utility.raise_error;
        fnd_file.put(fnd_file.log, l_mesg);
        hr_multi_message.add(p_associated_column1 => 'Y');
    END IF;
----**********************************************************************
--           CHECK # :- To Check if this script has been already run
----**********************************************************************

    IF (pqp_fedhr_uspay_int_utils.is_script_run(
                      p_business_group_id  =>  p_business_group_id,
                      p_fedhr_element_name => 'Federal Awards') = TRUE)
    THEN
        hr_utility.set_message(8303,'HR_374602_SCRIPT_ALREADY_RUN');
        l_mesg := l_mesg || hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
        --hr_utility.raise_error;
        hr_multi_message.add(p_associated_column1 => 'Y');
    END IF;

    populate_dc_ele_inp_tabs(p_bg_id  => p_business_group_id  ,
                             p_eff_start_date => l_dt         ,
                             p_prefix         => p_prefix     ,
                             p_ele_cnt        => l_ele_cnt);

--**********************************************************************
--   CHECK# :- Check for tracking if element link already exists
--              Stop Conc Prog If atleast one Element Link exists
--**********************************************************************

    FOR l_index in 1..p_earn.COUNT
    LOOP
      l_ele_name    := p_prefix||' '||p_earn(l_index).ele_name;
      l_ele_lnk_flg := pqp_fedhr_uspay_int_utils.is_ele_link_exists(
                                p_ele_name => l_ele_name,
                                p_bg_id    => p_earn(l_index).bg_id);
      IF l_ele_lnk_flg
      THEN
        hr_utility.set_message(8303,'HR_374604_ELE_LINK_EXISTS');

        l_mesg := l_mesg || hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
        hr_utility.raise_error;
      END IF;
    END LOOP; -- for earn


--    FOR l_index in 1..p_dedn.COUNT
--    Loop
--    l_ele_name:=p_prefix||' '||p_dedn(l_index).ele_name;
--    l_ele_lnk_flg:=pqp_fedhr_uspay_int_utils.is_ele_link_exists(
--                                p_ele_name => l_ele_name,
--                                p_bg_id    => p_dedn(l_index).bg_id);
--
--      If l_ele_lnk_flg then
--        hr_utility.set_message(8303,'HR_374604_ELE_LINK_EXISTS');
--        l_mesg := l_mesg || hr_utility.get_message;
--        fnd_file.put(fnd_file.log, l_mesg);
--       -- hr_utility.raise_error;
--       End if;
--    END LOOP; -- for dedn

----**********************************************************************
--    Report Header for Specifying Mapping Old element to New
----**********************************************************************

hr_utility.set_message(8303,'HR_374606_REPORT_HEADER');
l_mesg:=l_mesg||hr_utility.get_message;
fnd_file.put(fnd_file.log,l_mesg);
fnd_file.new_line(fnd_file.log);

----**********************************************************************
--           CHECK # :- Tally the Total Elements to be Created with
--                        the Elements actualyl created.
----**********************************************************************

     earnings(p_prefix   => p_prefix, p_earn_cnt => l_earn_cnt);
--
-- No Deduction Elemetns
--deductions(p_prefix => p_prefix, p_dedn_cnt => l_dedn_cnt);

     l_tot_cnt := l_earn_cnt;

     IF ( l_ele_cnt <> l_tot_cnt)
     THEN
      hr_utility.set_message(8303,'HR_374603_ALL_ELES_NOT_CREATED');
      hr_utility.set_message_token('TOTAL',l_ele_cnt);
      hr_utility.set_message_token('EDCOUNT',l_tot_cnt);
      l_mesg := l_mesg || hr_utility.get_message;
      hr_utility.raise_error;
     END IF;
----**********************************************************************
-- If all these checks are passed  then conc program is successful and
-- also successfully compiles Formulas
----**********************************************************************

     l_req_id := fnd_request.submit_request(application => 'FF'            ,
                                            program    => 'BULKCOMPILE'    ,
                                            argument1  => 'Oracle Payroll' ,
                                            argument2  => p_prefix || '%'
                                           );
END pqp_fedhr_element_creation;

--  ********************************************************************_
--
-- ---------------------------------------------------------------------------
--  |--------------------< update_ele_pqp_config_vals >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Checks for the existence of Old Element name under PQP_CONFIGURATION_VALUES
--     1) If exists then UPDATE the entry in pqp_configuration_values for
--        element_type_id with the new element element_type_id
--        ELSE
--     2) INSERT a row into pqp_configuration_values table.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_bg_id         - Inputs Value record Structure
--   p_old_ele_name  - The NUMBER from which the display sequence
--                      for GHR input values start
--   p_new_ele_name  - The no of Input values to be created
--                      for an element.

-- Out Parameters:
--
-- Post Success:
--  The element_type_id for element already existing under above mentioned table
--  is either Updated or Inserted.
--
-- Post Failure:
-- An application error will be raised and processing is terminated
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--  Called by Conc Prog to Insert/Update Federal Payroll Elements
--                   This is a public procedure.
-- ---------------------------------------------------------------------------

PROCEDURE update_or_ins_pqp_config_vals
(
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    p_business_group_id NUMBER,
    p_old_ele_name      VARCHAR2,
    p_new_ele_name      VARCHAR2,
    p_is_PB_Enabled     VARCHAR2,
    p_pay_basis         VARCHAR2
) IS

l_proc                  VARCHAR2(80):='update_or_ins_pqp_config_vals';
----**********************************************************************
-- Check for old element name under PQP_CONFIGURATION_VALUES
-- Exists if already script is run
----**********************************************************************

CURSOR c_ele_exists_pcv(
                        p_business_group_id  NUMBER,
                        p_old_ele_name       VARCHAR2
                       ) IS
SELECT pcv_information2       ele_type_id,
       configuration_value_id confg_val_id,
       object_version_number  ovn
FROM   pqp_configuration_values
WHERE  pcv_information1                 = p_old_ele_name
       and business_group_id            = p_business_group_id
       and NVL(pcv_information3,'NULL') = NVL(p_pay_basis,'NULL');

----**********************************************************************
-- Check if new name already exists under PAY_ELEMENT_TYPES_F
----**********************************************************************
CURSOR c_ele_exists_pet
(
 p_business_group_id  NUMBER,
 p_new_ele_name       VARCHAR2
)
IS
  SELECT element_type_id ele_type_id,
         effective_start_date eff_date
  FROM   pay_element_types_f
  WHERE  business_group_id = p_business_group_id
  AND    element_name      = p_new_ele_name;

l_old_ele_type_id       NUMBER;
l_old_ele_pay_basis     VARCHAR2(30);
l_new_ele_type_id       NUMBER;
l_rec                   pqp_pcv_shd.g_rec_type;
l_eff_date              DATE;
l_confg_val_id          NUMBER;
l_ovn                   NUMBER;
l_mesgbuff              VARCHAR2(4000);
l_dml                   VARCHAR2(80);
l_mesg                  VARCHAR2(4000);
l_app_name              VARCHAR2(100);
l_agency_ele_lnk_flg    BOOLEAN:=FALSE;
l_federal_ele_lnk_flg   BOOLEAN:=FALSE;
--
l_length                NUMBER:=0;
l_length1               NUMBER:=0;
l_length2               NUMBER:=0;
l_length3               NUMBER:=0;
l_hypen                 VARCHAR2(80);
l_mesgbuff1             VARCHAR2(4000);
l_indx_h                NUMBER:=0;

CURSOR c_ele_mapped
IS
SELECT pcv_information1 ele_name,
       pcv_information2 ele_type_id,
       pcv_information3 pay_basis
FROM   pqp_configuration_values
WHERE  business_group_id=p_business_group_id
AND    pcv_information_category='PQP_FEDHR_ELEMENT'
--AND   (pcv_information1 <> p_old_ele_name
--OR     pcv_information3 <> p_pay_basis)
ORDER BY pcv_information1 asc;


CURSOR c_new_ele_name_mapped(p_bg_id       IN NUMBER,
                             p_ele_type_id IN NUMBER)
IS
SELECT element_name ele_name
FROM   pay_element_types_f
WHERE  element_type_id   = p_ele_type_id
AND    business_group_id = p_bg_id;

l_map_old_ele           VARCHAR2(80);
l_map_new_ele           VARCHAR2(80);
l_map_ele_type_id       NUMBER;
l_rows_exists           BOOLEAN:=FALSE;
l_pay_basis             VARCHAR2(30);
--
CURSOR c_pay_basis(p_pay_basis VARCHAR2)
IS
SELECT meaning
FROM   hr_lookups
WHERE  lookup_type='GHR_US_PAY_BASIS'
AND    lookup_code=p_pay_basis;

l_pay_basis_meang     VARCHAR2(80);
--
CURSOR c_ele_type_id_exists_pcv(
                        p_business_group_id  NUMBER,
                        p_ele_type_id        NUMBER
                       ) IS
SELECT configuration_value_id confg_val_id,
       object_version_number  ovn,
       pcv_information1       ele_name,
       pcv_information3       pay_basis
FROM   pqp_configuration_values
WHERE  ghr_general.return_number(pcv_information2)        = p_ele_type_id
AND    business_group_id       = p_business_group_id
AND    pcv_information_category='PQP_FEDHR_ELEMENT';

l_agn_conf_val_id           NUMBER;
l_agn_ovn                   NUMBER;
l_agn_fed_ele_name          VARCHAR2(80);
l_agn_pay_basis             VARCHAR2(80);

--
BEGIN
--
hr_utility.trace('Entering :'||l_proc);
--
----**********************************************************************
--           CHECK 1 :- Existence of GHR Product
----**********************************************************************
  IF (hr_utility.chk_product_install('GHR','US')  <> TRUE )
  THEN
       hr_utility.set_message(8303,'PQP_230993_FED_PROD_NOT_INSTAL');

        FOR c_gpn IN get_prod_name('GHR','US')
        LOOP
            l_app_name := c_gpn.application_name;
        END LOOP;

        hr_utility.set_message_token('PROD',l_app_name);
        l_mesg := hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
        hr_multi_message.add(p_associated_column1 => 'Y');
  END IF;
----**********************************************************************
--           CHECK 2 :- Existence of PAYROLL Product
----**********************************************************************
  IF ( hr_utility.chk_product_install('PAY', 'US') <> TRUE )
  THEN
        hr_utility.set_message(8303,'PQP_230993_FED_PROD_NOT_INSTAL');

        FOR c_gpn IN get_prod_name('PAY','US')
        LOOP
            l_app_name := c_gpn.application_name;
        END LOOP;

        hr_utility.set_message_token('PROD',l_app_name);
        l_mesg := l_mesg || hr_utility.get_message;
        fnd_file.put(fnd_file.log, l_mesg);
        hr_multi_message.add(p_associated_column1 => 'Y');
  END IF;
--**********************************************************************
--   CHECK 3 :- Ensure Biz Group is Fed HR biz group.
--**********************************************************************
  IF (ghr_utility.is_ghr='FALSE')
  THEN
         hr_utility.set_message(8303,'PQP_230995_FED_BIZ_GROUP_FALSE');
         l_mesg := l_mesg || hr_utility.get_message;
         fnd_file.put(fnd_file.log, l_mesg);
         hr_multi_message.add(p_associated_column1 => 'Y');
  END IF;

--**********************************************************************
--   CHECK 4 :- Check for tracking if federal element link already exists
--              Stop Conc Prog If atleast one Element Link exists
--**********************************************************************
  l_federal_ele_lnk_flg:= pqp_fedhr_uspay_int_utils.is_ele_link_exists(
                                p_ele_name         => p_old_ele_name,
                                p_legislation_code => 'US'          ,
                                p_bg_id            => p_business_group_id);
  IF (l_federal_ele_lnk_flg = TRUE)
  THEN
         hr_utility.set_message(8303,'PQP_230994_FED_ELE_LINK_EXISTS');
         hr_utility.set_message_token('FEDERAL_ELEMENT', p_old_ele_name);
         l_mesg := l_mesg || hr_utility.get_message;
         fnd_file.put(fnd_file.log, l_mesg);
         hr_multi_message.add(p_associated_column1 => 'Y');
  END IF;
--**********************************************************************
--   CHECK 5 :- Check for tracking if agency element link already exists
--              Stop Conc Prog If atleast one Element Link exists
--**********************************************************************
  l_agency_ele_lnk_flg := pqp_fedhr_uspay_int_utils.is_ele_link_exists(
                                p_ele_name => p_new_ele_name,
                                p_bg_id    => p_business_group_id);

  IF (l_agency_ele_lnk_flg = TRUE)
  THEN
         hr_utility.set_message(8303,'PQP_230994_FED_ELE_LINK_EXISTS');
         hr_utility.set_message_token('FEDERAL_ELEMENT', p_new_ele_name);
         l_mesg := l_mesg || hr_utility.get_message;
         fnd_file.put(fnd_file.log, l_mesg);
         hr_multi_message.add(p_associated_column1 => 'Y');
  END IF;

 --****************************************************************

  FOR old_ele_rec IN c_ele_exists_PCV(p_business_group_id,
                                        p_old_ele_name)
  LOOP
         l_old_ele_type_id   := old_ele_rec.ele_type_id;
         l_confg_val_id      := old_ele_rec.confg_val_id;
         l_ovn               := old_ele_rec.ovn;

  END LOOP;

  FOR new_ele_rec IN c_ele_exists_PET(p_business_group_id,
                                       p_new_ele_name)
  LOOP
         l_new_ele_type_id := new_ele_rec.ele_type_id;
         l_eff_date        := new_ele_rec.eff_date;
  END LOOP;
--**********************************************************************
  FOR agency_ele_exists IN c_ele_type_id_exists_pcv(p_business_group_id,
                                          ghr_general.return_number(l_new_ele_type_id))
  LOOP
          l_agn_conf_val_id  := agency_ele_exists.confg_val_id;
	  l_agn_ovn          := agency_ele_exists.ovn;
          -- using object version number
	  l_agn_fed_ele_name := agency_ele_exists.ele_name;
	  l_agn_pay_basis := agency_ele_exists.pay_basis;
  END LOOP;
-- if old element and new element both exist then error out.
-- moved the error message to here
  IF l_old_ele_type_id is not NULL
  THEN
  hr_utility.trace('Inside Federal Element type id exists');
     IF l_new_ele_type_id is not NULL
     THEN
        IF (l_agn_conf_val_id is not NULL )
        THEN
          hr_utility.set_message(8303,'PQP_230008_FED_AGN_ALR_MPPD');
          hr_utility.set_message_token('AGENCY_ELE_NAME',p_new_ele_name);

  	   IF (l_agn_fed_ele_name = 'Basic Salary Rate') THEN
	 -- append the pay basis to Basic Salary Rate element
               IF ( l_agn_pay_basis is not null) THEN
               FOR pay_basis_meang IN c_pay_basis(l_agn_pay_basis)
               LOOP
                  l_pay_basis_meang := pay_basis_meang.meaning;
               END LOOP;
               ELSE
                  l_pay_basis_meang := NULL;
               END IF;
	   -- append the pay basis to Basic Salary Rate element
  	       l_agn_fed_ele_name    := l_agn_fed_ele_name||'('||l_pay_basis_meang||')';
   	   ELSE
	       l_agn_fed_ele_name    := l_agn_fed_ele_name;
	   END IF;
	 hr_utility.set_message_token('FEDERAL_ELE_NAME',l_agn_fed_ele_name);
         l_mesg := l_mesg||hr_utility.get_message;
         fnd_file.put(fnd_file.log,l_mesg);
         hr_multi_message.add(p_associated_column1 => 'Y');
        END IF;
     END IF;
  END IF;

--**********************************************************************
  IF (l_mesg IS NOT NULL)
  THEN
         hr_utility.raise_error;
  END IF;
 l_mesg  := NULL;
--****************************************************************
--                 Elements already Mapped
--****************************************************************
--
-- This message provides heading for currently existing mapping
--
  FOR pcv_ele_rec IN c_ele_mapped
  LOOP
  l_map_old_ele     := pcv_ele_rec.ele_name;
  l_map_ele_type_id := ghr_general.return_NUMBER(pcv_ele_rec.ele_type_id);
  l_pay_basis       := pcv_ele_rec.pay_basis;

  IF NOT l_rows_exists THEN

  IF ((p_old_ele_name <> l_map_old_ele
      OR NVL(p_pay_basis,'NO')<>NVL(pcv_ele_rec.pay_basis,'NO'))
  AND l_new_ele_type_id <> pcv_ele_rec.ele_type_id) THEN

  hr_utility.set_message(8303,'PQP_230997_FED_EXISTING_MAP');
  l_mesgbuff1 := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff1);
  fnd_file.new_line(fnd_file.log);

  l_length    := length(l_mesgbuff1);

  FOR l_indx_h IN 1..l_length
  LOOP
  fnd_file.put(fnd_file.log,'-');
  END LOOP;

  fnd_file.new_line(fnd_file.log);
  hr_utility.set_message(8303,'PQP_230998_FED_FEDERAL_ELEMENT');
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,rpad(l_mesgbuff,35));

  l_length1 := length(l_mesgbuff);

  hr_utility.set_message(8303,'PQP_230991_FED_AGENCY_ELEMENT');
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,rpad(l_mesgbuff,35));

  l_length2 := length(l_mesgbuff);

  hr_utility.set_message(8303,'PQP_230999_FED_PAY_BASIS');
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff);
  fnd_file.new_line(fnd_file.log);

  l_length3 := length(l_mesgbuff);

  FOR l_indx_h IN 1..l_length1
  LOOP
  l_hypen   := '-'||l_hypen;
  END LOOP;
  fnd_file.put(fnd_file.log,rpad(l_hypen,35));

  l_hypen:=NULL;

  FOR l_indx_h IN 1..l_length2
  LOOP
  l_hypen   := '-'||l_hypen;
  END LOOP;
  fnd_file.put(fnd_file.log,rpad(l_hypen,35));

  l_hypen:=NULL;

  FOR l_indx_h IN 1..l_length3
  LOOP
  l_hypen   := '-'||l_hypen;
  END LOOP;
  fnd_file.put(fnd_file.log,rpad(l_hypen,35));

  fnd_file.new_line(fnd_file.log);
  l_mesgbuff:=NULL;

  l_rows_exists:=TRUE;
  END IF; -- check if new ele being mapped already has a row
  END IF;
--****************************************************************
-- to display output in log file in the following fashion
-- Federal Element                Agency Element
--****************************************************************

--*-------------------------*
--* Prints Existing Mapping *
--*-------------------------*
  IF (l_new_ele_type_id = pcv_ele_rec.ele_type_id
     OR (p_old_ele_name = pcv_ele_rec.ele_name
     AND NVL(p_pay_basis,'NO')=NVL(pcv_ele_rec.pay_basis,'NO')) )
  THEN
  l_map_old_ele     := NULL;
  l_map_ele_type_id := NULL;
  l_pay_basis       := NULL;
  ELSE
  l_map_old_ele     := pcv_ele_rec.ele_name;
  l_map_ele_type_id := ghr_general.return_NUMBER(pcv_ele_rec.ele_type_id);
  l_pay_basis       := pcv_ele_rec.pay_basis;
  END IF;

   FOR pet_ele_rec IN c_new_ele_name_mapped(p_business_group_id,
                                            l_map_ele_type_id)
   LOOP
   l_map_new_ele     := pet_ele_rec.ele_name;

   hr_utility.set_message(8303,'PQP_230992_FED_ELE_TOKEN');
   hr_utility.set_message_token('ELEMENT_NAME',rpad(l_map_old_ele,35));
   l_mesgbuff := hr_utility.get_message;
   fnd_file.put(fnd_file.log,l_mesgbuff);


   hr_utility.set_message(8303,'PQP_230992_FED_ELE_TOKEN');
   hr_utility.set_message_token('ELEMENT_NAME',rpad(l_map_new_ele,35));
   l_mesgbuff := hr_utility.get_message;
   fnd_file.put(fnd_file.log,l_mesgbuff);

   IF ( l_pay_basis is not null) THEN
    FOR pay_basis_meang IN c_pay_basis(l_pay_basis)
    LOOP
    l_pay_basis_meang := pay_basis_meang.meaning;
    END LOOP;
   ELSE
    l_pay_basis_meang := NULL;
   END IF;

   hr_utility.set_message(8303,'PQP_230992_FED_ELE_TOKEN');
   hr_utility.set_message_token('ELEMENT_NAME',l_pay_basis_meang);
   l_mesgbuff := hr_utility.get_message;
   fnd_file.put(fnd_file.log,l_mesgbuff);

   fnd_file.new_line(fnd_file.log);
   l_mesgbuff:='';

   END LOOP;
  END LOOP;

-- *****************************************************************
-- Check to see if the Element exists under pqp_configuration_values
-- Table and if exists the element type id is updated otherwise, the
-- Element is inserted into pqp_configuration_values table

-- *****************************************************************

  IF l_old_ele_type_id is not NULL
  THEN
  hr_utility.trace('Inside Federal Element type id exists');
     IF l_new_ele_type_id is not NULL
     THEN
-- Commenting the code as this has been taken care of above
/*        IF (l_agn_conf_val_id is not NULL ) THEN
	 hr_utility.set_message(8303,'PQP_230008_FED_AGN_ALR_MPPD');
         hr_utility.set_message_token('AGENCY_ELE_NAME',p_new_ele_name);

	 IF (l_agn_fed_ele_name = 'Basic Salary Rate') THEN
	 -- append the pay basis to Basic Salary Rate element
          IF ( l_old_ele_pay_basis is not null) THEN
            FOR pay_basis_meang IN c_pay_basis(l_old_ele_pay_basis)
            LOOP
             l_pay_basis_meang := pay_basis_meang.meaning;
            END LOOP;
          ELSE
             l_pay_basis_meang := NULL;
          END IF;
	   -- append the pay basis to Basic Salary Rate element
	  l_agn_fed_ele_name    := l_agn_fed_ele_name||'('||l_pay_basis_meang||')';
	 ELSE
	  l_agn_fed_ele_name    := l_agn_fed_ele_name;
	 END IF;

	 hr_utility.set_message_token('FEDERAL_ELE_NAME',l_agn_fed_ele_name);
         l_mesg := l_mesg||hr_utility.get_message;
         fnd_file.put(fnd_file.log,l_mesg);
         hr_multi_message.add(p_associated_column1 => 'Y');
	 END IF; */

     hr_utility.trace('Inside Agency Element type id exists');
--******************************************************************
-- If the new Element picked already exists under pay_element_types_f
-- under current Biz Grp and as on the passed effective date
--******************************************************************
         l_DML := 'Updated';
           hr_utility.set_location('Element being updated',40);
         l_rec.object_version_number    := l_ovn;
         l_rec.configuration_value_id   := l_confg_val_id;
         l_rec.business_group_id        := p_business_group_id;
         l_rec.pcv_information_category := 'PQP_FEDHR_ELEMENT';
         l_rec.pcv_information1         := p_old_ele_name;
         l_rec.pcv_information2         := l_new_ele_type_id;

   -- Following Check added by Ashu to ensure Pay_basis is NULL for
   -- non Basic Salary Rate Elements.

     IF (p_old_ele_name = 'Basic Salary Rate')
     THEN
         l_rec.pcv_information3       := p_pay_basis;
     ELSE
         l_rec.pcv_information3       := NULL;
     END IF;

     --Calling row handler for updation of element type id
     pqp_pcv_upd.upd(l_eff_date,l_rec);

     END IF; -- End of new element type id check

  ELSE -- Old element type id is NULL, not existing under PCV table
   --
  -- This check is to update the agency element
  --

  IF (l_agn_conf_val_id is not NULL)
  THEN
 -- If the Agency element already is mapped and
 -- the federal element does not have a row in the pcv table
 -- update the row with new federal element.
	 l_DML := 'Updated';
         hr_utility.set_location('Element being updated',40);
         l_rec.object_version_number    := l_agn_ovn;
         l_rec.configuration_value_id   := l_agn_conf_val_id;
         l_rec.business_group_id        := p_business_group_id;
         l_rec.pcv_information_category := 'PQP_FEDHR_ELEMENT';
         l_rec.pcv_information1         := p_old_ele_name;
         l_rec.pcv_information2         := l_new_ele_type_id;

   -- Following Check added by Ashu to ensure Pay_basis is NULL for
   -- non Basic Salary Rate Elements.

     IF (p_old_ele_name = 'Basic Salary Rate')
     THEN
         l_rec.pcv_information3       := p_pay_basis;
     ELSE
         l_rec.pcv_information3       := NULL;
     END IF;

     --Calling row handler for updation of element type id
     pqp_pcv_upd.upd(l_eff_date,l_rec);

  ELSIF (l_agn_conf_val_id is NULL )
  THEN
--
-- *****************************************************************
-- If old element does not exist in PCV then insert a new row in PCV
-- Pick the ele_type_id,effective_start_date from pay_element_types_f
-- *****************************************************************
      l_DML := 'Inserted';
      hr_utility.set_location('Inside Federal Element type id NULL',20);
      hr_utility.set_location('Element being Inserted',30);

      l_rec.business_group_id        := p_business_group_id;
      l_rec.pcv_information_category := 'PQP_FEDHR_ELEMENT';
      l_rec.pcv_information1         := p_old_ele_name;
      l_rec.pcv_information2         := l_new_ele_type_id;

      IF (p_old_ele_name = 'Basic Salary Rate')
      THEN
          l_rec.pcv_information3       := p_pay_basis;
      ELSE
          l_rec.pcv_information3       := NULL;
      END IF;

   -- Call Insert row handler
   -- ******************************************
   -- ASHU
   -- ******************************************
      pqp_pcv_ins.ins(l_eff_date,l_rec);

  END IF;
  END IF;

--****************************************************************
--      Message to Print if Element is Inserted or Updated
--****************************************************************
  l_length :=0;
  l_length1:=0;
  l_length2:=0;
  l_length3:=0;
  l_hypen  := NULL;
  l_mesgbuff:=NULL;

  fnd_file.new_line(fnd_file.log);
  hr_utility.set_message(8303,'PQP_230996_FED_NEW_MAP');
  l_mesgbuff1 := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff1);
  fnd_file.new_line(fnd_file.log);

  l_length    := length(l_mesgbuff1);

  FOR l_indx_h IN 1..l_length
  LOOP
  fnd_file.put(fnd_file.log,'-');
  END LOOP;
  fnd_file.new_line(fnd_file.log);

  hr_utility.set_message(8303,'PQP_230998_FED_FEDERAL_ELEMENT');
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,rpad(l_mesgbuff,35));

  l_length1 := length(l_mesgbuff);

  hr_utility.set_message(8303,'PQP_230991_FED_AGENCY_ELEMENT');
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,rpad(l_mesgbuff,35));

  l_length2 := length(l_mesgbuff);

  hr_utility.set_message(8303,'PQP_230999_FED_PAY_BASIS');
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff);
  fnd_file.new_line(fnd_file.log);

  l_length3 := length(l_mesgbuff);


  FOR l_indx_h IN 1..l_length1
  LOOP
  l_hypen   := '-'||l_hypen;
  END LOOP;
  fnd_file.put(fnd_file.log,rpad(l_hypen,35));

  l_hypen:=NULL;

  FOR l_indx_h IN 1..l_length2
  LOOP
  l_hypen   := '-'||l_hypen;
  END LOOP;
  fnd_file.put(fnd_file.log,rpad(l_hypen,35));

  l_hypen:=NULL;

  FOR l_indx_h IN 1..l_length3
  LOOP
  l_hypen   := '-'||l_hypen;
  END LOOP;
  fnd_file.put(fnd_file.log,rpad(l_hypen,35));

  fnd_file.new_line(fnd_file.log);
  l_mesgbuff:=NULL;

  --*------------------------*
  --* Prints current mapping *
  --*------------------------*

  hr_utility.set_message(8303,'PQP_230992_FED_ELE_TOKEN');
  hr_utility.set_message_token('ELEMENT_NAME', rpad(p_old_ele_name,35));
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff);

  hr_utility.set_message(8303,'PQP_230992_FED_ELE_TOKEN');
  hr_utility.set_message_token('ELEMENT_NAME', rpad(p_new_ele_name,35));
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff);

  IF ( p_pay_basis is not null) THEN
  FOR pay_basis_meang IN c_pay_basis(p_pay_basis)
  LOOP
  l_pay_basis_meang := pay_basis_meang.meaning;
  END LOOP;
  ELSE
  l_pay_basis_meang := NULL;
  END IF;

  hr_utility.set_message(8303,'PQP_230992_FED_ELE_TOKEN');
  hr_utility.set_message_token('ELEMENT_NAME', l_pay_basis_meang);
  l_mesgbuff := hr_utility.get_message;
  fnd_file.put(fnd_file.log,l_mesgbuff);

  fnd_file.new_line(fnd_file.log);
--****************************************************************
hr_utility.trace('Leaving :'||l_proc);
END update_or_ins_pqp_config_vals;

END pqp_fedhr_uspay_intg_pkg;

/
