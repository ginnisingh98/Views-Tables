--------------------------------------------------------
--  DDL for Package Body PAY_FR_ARC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_ARC_PKG" as
/* $Header: pyfrarch.pkb 120.3 2006/03/05 12:07:10 aparkes noship $ */
--
-- Globals
--
g_package    CONSTANT VARCHAR2(20):= 'pay_fr_arc_pkg.';
--
-- Parameters to the process - g_payroll_action_id is the cache context
--
g_payroll_action_id       pay_payroll_actions.payroll_action_id%TYPE;
g_param_payroll_id        pay_all_payrolls_f.payroll_id%TYPE;
g_param_assignment_id     per_all_assignments_f.assignment_id%TYPE;
g_param_assignment_set_id hr_assignment_sets.assignment_set_id%TYPE;
g_param_business_group_id per_business_Groups.business_group_id%TYPE;
g_param_start_date        date;
g_param_effective_date    date;
--
--
-- Globals for scope of ARCHINIT and ARCHIVE CODE
--
--
-- Global Defined Balance IDs
--
g_1total_gross_pay_db         pay_defined_balances.defined_balance_id%TYPE;
g_2ss_ceiling_db              pay_defined_balances.defined_balance_id%TYPE;
g_3es_total_contributions_db  pay_defined_balances.defined_balance_id%TYPE;
g_4statutory_er_charges_db    pay_defined_balances.defined_balance_id%TYPE;
g_5conventional_er_charges_db pay_defined_balances.defined_balance_id%TYPE;
g_6t1_arrco_band_db           pay_defined_balances.defined_balance_id%TYPE;
g_7t2_arrco_band_db           pay_defined_balances.defined_balance_id%TYPE;
g_8tb_argic_band_db           pay_defined_balances.defined_balance_id%TYPE;
g_9tc_agirc_band_db           pay_defined_balances.defined_balance_id%TYPE;
g_10gmp_agirc_band_db         pay_defined_balances.defined_balance_id%TYPE;
g_11total_cost_to_employer_db pay_defined_balances.defined_balance_id%TYPE;
g_12taxable_income_db         pay_defined_balances.defined_balance_id%TYPE;
--
-- Global dimension IDs
--
g_asg_run                 pay_defined_balances.balance_dimension_id%TYPE;
g_asg_pro_run             pay_defined_balances.balance_dimension_id%TYPE;
g_asg_et_pr_ra_cu_run     pay_defined_balances.balance_dimension_id%TYPE;
g_asg_et_pr_ra_cu_pro_run pay_defined_balances.balance_dimension_id%TYPE;
g_asg_et_pr_cu_run        pay_defined_balances.balance_dimension_id%TYPE;
g_asg_et_pr_cu_pro_run    pay_defined_balances.balance_dimension_id%TYPE;
--
-- global totals contexts (holds lookup codes to get meanings)
--
g_totals_c1_total_gross      varchar2(30) := 'TOTAL_GROSS';
g_totals_c2_total_subject    varchar2(30) := 'TOTAL_SUBJECT';
g_totals_c3_total_deductions varchar2(30) := 'TOTAL_DEDUCTIONS';    /* holds name not value      */
g_totals_c3_total_deduct_ee  varchar2(30) := 'TOTAL_DEDUCTIONS_EE'; /* not used in names, used in values */
g_totals_c3_total_deduct_er  varchar2(30) := 'TOTAL_DEDUCTIONS_ER'; /* not used in names, used in values */
g_totals_c4_taxable_income   varchar2(30) := 'TAXABLE_INCOME';
g_totals_c5_total_charges    varchar2(30) := 'TOTAL_CHARGES';       /* holds name not value          */
g_totals_c5_total_charges_ee varchar2(30) := 'TOTAL_CHARGES_EE';    /* not used in names, used in values */
g_totals_c5_total_charges_er varchar2(30) := 'TOTAL_CHARGES_ER';    /* not used in names, used in values */
g_totals_c6_net_salary       varchar2(30) := 'NET_SALARY';
g_totals_c7_total_pay        varchar2(30) := 'TOTAL_PAY';
g_totals_c8_previous_advice  varchar2(30) := 'PREVIOUS_ADVICE';
g_totals_c9_this_advice      varchar2(30) := 'THIS_ADVICE';
g_totals_c10_net_advice      varchar2(30) := 'NET_ADVICE';
--
-- global balance contexts (holds lookup codes to get meanings)
--
g_balance_c1_total_gross      varchar2(30) := 'TOTAL_GROSS_PAY';
g_balance_c2_ss_ceiling       varchar2(30) := 'SS_CEILING';
g_balance_c3_ee_total_conts   varchar2(30) := 'EMPLOYEES_TOTAL_CONTRIBUTIONS';
g_balance_c4_stat_er_charges  varchar2(30) := 'STATUTORY_EMPLOYER_CHARGES';
g_balance_c5_conv_er_charges  varchar2(30) := 'CONVENTIONAL_EMPLOYER_CHARGES';
g_balance_c6_t1_arrco         varchar2(30) := 'T1_ARRCO_BAND';
g_balance_c7_t2_arrco         varchar2(30) := 'T2_ARRCO_BAND';
g_balance_c8_tb_agirc         varchar2(30) := 'TB_AGIRC_BAND';
g_balance_c9_tc_agirc         varchar2(30) := 'TC_AGIRC_BAND';
g_balance_c10_gmp             varchar2(30) := 'GMP_AGIRC_BAND';
g_balance_c11_total_er_cost   varchar2(30) := 'TOTAL_COST_TO_EMPLOYER';
g_balance_c12_taxable_income  varchar2(30) := 'TAXABLE_INCOME';
--
-- globals for name translations
--
g_us_name_pay_value    varchar2(10) := 'Pay Value';
g_us_name_rate         varchar2(10) := 'Rate';
g_us_name_base         varchar2(10) := 'Base';
g_us_name_start_date   varchar2(10) := 'Start Date';
g_us_name_end_date     varchar2(10) := 'End Date';
g_retro_tl             fnd_lookup_values.meaning%TYPE := 'Default Retro';
g_fr_name_pay_value    fnd_lookup_values.meaning%TYPE;
g_fr_name_rate         fnd_lookup_values.meaning%TYPE;
g_fr_name_base         fnd_lookup_values.meaning%TYPE;
g_fr_name_start_date   fnd_lookup_values.meaning%TYPE;
g_fr_name_end_date     fnd_lookup_values.meaning%TYPE;
--
--
g_source_text ff_contexts.context_id%TYPE;
--
-- To hold termination element id - special processing for termination
--
g_term_ele_subject_to_ss  pay_element_types_f.element_Type_id%TYPE;
g_term_ele_exempt_of_ss   pay_element_types_f.element_Type_id%TYPE;
--
-- to hold the application_id of 'PER'
--
g_per_id                  fnd_application.application_id%TYPE;
--
g_CSG_non_Deductible      pay_balance_categories_f.balance_category_id%TYPE;
g_Conv_EE_Deductions      pay_balance_categories_f.balance_category_id%TYPE;
g_Conv_ER_Charges         pay_balance_categories_f.balance_category_id%TYPE;
g_Income_Tax_Excess       pay_balance_categories_f.balance_category_id%TYPE;
g_Rebates                 pay_balance_categories_f.balance_category_id%TYPE;
g_Stat_EE_Deductions      pay_balance_categories_f.balance_category_id%TYPE;
g_Stat_ER_Charges         pay_balance_categories_f.balance_category_id%TYPE;
--
g_ele_class_CSG_non_Deductible  pay_element_classifications.classification_id%TYPE;
g_ele_class_Conv_EE_Deductions  pay_element_classifications.classification_id%TYPE;
g_ele_class_Conv_ER_Charges     pay_element_classifications.classification_id%TYPE;
g_ele_class_Income_Tax_Excess   pay_element_classifications.classification_id%TYPE;
g_ele_class_Rebates             pay_element_classifications.classification_id%TYPE;
g_ele_class_Stat_EE_Deductions  pay_element_classifications.classification_id%TYPE;
g_ele_class_Stat_ER_Charges     pay_element_classifications.classification_id%TYPE;
g_ele_class_Net_EE_Deductions   pay_element_classifications.classification_id%TYPE;
g_ele_class_ER_LV_Charges   pay_element_classifications.classification_id%TYPE;
--
-- Globals added for security groups (bug 3683906)
g_sec_grp_id_user_element_grp   FND_LOOKUP_VALUES.SECURITY_GROUP_ID%TYPE;
g_sec_grp_id_base_unit          FND_LOOKUP_VALUES.SECURITY_GROUP_ID%TYPE;
g_sec_grp_id_element_grp        FND_LOOKUP_VALUES.SECURITY_GROUP_ID%TYPE;
-- more added for bug 4778143:
g_sec_grp_id_process_type       FND_LOOKUP_VALUES.SECURITY_GROUP_ID%TYPE;
g_sec_grp_id_fixed_time_units   FND_LOOKUP_VALUES.SECURITY_GROUP_ID%TYPE;
g_sec_grp_id_fixed_time_freq    FND_LOOKUP_VALUES.SECURITY_GROUP_ID%TYPE;
--
---------------------------------------------------------------------------------------------------
-- ARCHIVE HOOK POINTS
--
---------------------------------------------------------------------------------------------------
-- RANGE CURSOR
-- DESCRIPTION : Single threaded. Performs 1-off archiving of :
--                                - Establishment data and address
--                                - Company data and address
--               Returns the Range Cursor String
---------------------------------------------------------------------------------------------------
procedure range_cursor (
          pactid                       in number
         ,sqlstr                       out nocopy varchar) is
  --
  l_proc VARCHAR2(40) :=    g_package||' range_cursor ';
  --
BEGIN
  --
  -- Load the boilerplate for totals and balances against their entities
  --
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Get the descriptive text for running subtotals and YTD balances
  --
  pay_fr_arc_pkg.load_payslip_text (
                 p_action_id         => pactid);
  --
  hr_utility.set_location('Step ' || l_proc,20);
  --
  -- Return the select string
  --
  sqlstr := 'SELECT DISTINCT person_id
             FROM  per_people_f ppf
                  ,pay_payroll_actions ppa
             WHERE ppa.payroll_action_id = :payroll_action_id
               AND ppa.business_group_id = ppf.business_group_id
          ORDER BY ppf.person_id';
  --
  hr_utility.set_location(' Leaving:  '||l_proc,50);
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(' Leaving with EXCEPTION: '||l_proc,50);
      -- Return cursor that selects no rows
      sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
END range_cursor;
---------------------------------------------------------------------------------------------------
-- ACTION CREATION --
-- DESCRIPTION :      Creates new assignment actions under the (archive) payroll action
--                    creates one per master or normal prepayment action.
--                    restricts to user chosen parameters - assignment_id
--                                                        - payroll_id
--                    and Locks all prepayment master / normal actions for the assignment in period
---------------------------------------------------------------------------------------------------
PROCEDURE action_creation  (pactid    IN NUMBER,
                            stperson  IN NUMBER,
                            endperson IN NUMBER,
                            chunk     IN NUMBER) IS
--
l_actid                      pay_assignment_actions.assignment_action_id%TYPE;
--
l_proc VARCHAR2(60):= g_package||' action_creation ';
 --
 --This cursor fetches all master (or standard) prepayment assignment actions
 --
 cursor csr_assignments (p_stperson  number, p_endperson number) IS
 SELECT pre_assact.assignment_action_id assignment_action_id
       ,pre_assact.assignment_id        assignment_id
       ,pre_assact.tax_unit_id          establishment_id
 FROM   per_all_assignments_f     asg
       ,pay_assignment_actions    pre_assact
       ,pay_payroll_actions       pre_payact
 WHERE  asg.person_id             between p_stperson and p_endperson
   and  asg.period_of_service_id       is not null
   and  g_param_effective_date    between asg.effective_start_date
                                      and asg.effective_end_date
   and  asg.assignment_id               = pre_assact.assignment_id
   and  pre_assact.source_action_id    is null  /* not a child */
   and  pre_assact.action_status        = 'C'
   and  pre_payact.payroll_action_id    = pre_assact.payroll_action_id
   and  pre_payact.action_status        = 'C'
   and  pre_payact.action_type         in ('P','U')
   and  pre_payact.payroll_id           = g_param_payroll_id
   and  pre_payact.effective_date between g_param_start_date
                                      and g_param_effective_date;
  --
  rec_this  csr_assignments%ROWTYPE;
  l_counter number := 0;
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc,20);

  if g_payroll_action_id is null
  or g_payroll_action_id <> pactid
  then
    pay_fr_arc_pkg.get_all_parameters
       (p_payroll_action_id => pactid
       ,p_payroll_id        => g_param_payroll_id
       ,p_assignment_id     => g_param_assignment_id
       ,p_assignment_set_id => g_param_assignment_set_id
       ,p_business_Group_id => g_param_business_group_id
       ,p_start_date        => g_param_start_date
       ,p_effective_date    => g_param_effective_date);
    g_payroll_action_id := pactid;
  end if;
  --
  -- Fetch the first record
  --

  open csr_assignments(stperson, endperson);
    LOOP
      Fetch csr_assignments into rec_this;
      EXIT WHEN csr_assignments%NOTFOUND;
      -- create the action
      SELECT pay_assignment_actions_s.nextval
        INTO   l_actid
        FROM   dual;
      hr_nonrun_asact.insact(l_actid
                             ,rec_this.assignment_id
                             ,pactid
                             ,chunk
                             ,rec_this.establishment_id);
      -- lock this prepayment record with the newly created assignment action
      hr_nonrun_asact.insint(l_actid, rec_this.assignment_action_id);
    END LOOP;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location(' Leaving with EXCEPTION: '||l_proc,50);
END action_creation;
---------------------------------------------------------------------------------------------------
-- ARCHINIT --
-- DESCRIPTION :                    populates defined balance ids for later use.
--                                  loads all entity ids into globals
--                                  gets rebate sub classs id into global
--                                  loads user parameters into globals.
---------------------------------------------------------------------------------------------------
procedure archinit(
          p_payroll_action_id        in number) is
  --
  cursor csr_context(p_name varchar2) is
  select context_id
  from   ff_contexts
  where  context_name = p_name;
  --
  -- Get the element_type_ids of the termination elements
  --
  cursor csr_termination_elements (p_element_name varchar2) is
         select element_type_id
         from pay_element_types_f
         where element_name = p_element_name
           and legislation_code = 'FR';
  --
  cursor csr_get_dimension (p_name varchar2) is
  select balance_dimension_id
  from pay_balance_dimensions
  where legislation_code = 'FR'
  and dimension_name = p_name;
  --
  cursor csr_get_per_id is
  select application_id
  from fnd_application
  where application_short_name = 'PER';
  --
  -- get the balance category IDs
  cursor csr_get_bal_cat (p_name varchar2) is
  select balance_category_id
  from   pay_balance_categories_f
  where  legislation_code = 'FR'
  and    category_name = p_name
  order by effective_start_date asc;
  --
  -- get the element_classification IDs
  --
  cursor csr_get_ele_class (p_name varchar2) is
  select classification_id
  from   pay_element_classifications
  where  legislation_code = 'FR'
  and    classification_name = p_name;
  --
  l_proc VARCHAR2(40):= g_package||' archinit ';
BEGIN
  --
  -- Load the defined balance ids, note balance 12 is a PTD
  --
  hr_utility.set_location('Entering ' || l_proc, 10);
  hr_utility.set_location('Loading def balance ids ' || l_proc, 20);
  g_1total_gross_pay_db         := pay_fr_arc_pkg.get_balance_id('FR_TOTAL_GROSS_PAY'
                                                                  ,'Assignment Establishment Year To Date');
  g_2ss_ceiling_db              := pay_fr_arc_pkg.get_balance_id('FR_SS_CEILING'
                                                                  ,'Assignment Establishment Year To Date');
  g_3es_total_contributions_db  := pay_fr_arc_pkg.get_balance_id('FR_EMPLOYEES_TOTAL_CONTRIBUTIONS'
                                                                  ,'Assignment Establishment Year To Date');
  g_4statutory_er_charges_db    := pay_fr_arc_pkg.get_balance_id('FR_STATUTORY_EMPLOYER_CHARGES'
                                                                  ,'Assignment Establishment Year To Date');
  g_5conventional_er_charges_db := pay_fr_arc_pkg.get_balance_id('FR_CONVENTIONAL_EMPLOYER_CHARGES'
                                                                  ,'Assignment Establishment Year To Date');
  g_6t1_arrco_band_db           := pay_fr_arc_pkg.get_balance_id('FR_T1_ARRCO_BAND'
                                                                  ,'Assignment Establishment Year To Date');
  g_7t2_arrco_band_db           := pay_fr_arc_pkg.get_balance_id('FR_T2_ARRCO_BAND'
                                                                  ,'Assignment Establishment Year To Date');
  g_8tb_argic_band_db           := pay_fr_arc_pkg.get_balance_id('FR_TB_AGIRC_BAND'
                                                                  ,'Assignment Establishment Year To Date');
  g_9tc_agirc_band_db           := pay_fr_arc_pkg.get_balance_id('FR_TC_AGIRC_BAND'
                                                                  ,'Assignment Establishment Year To Date');
  g_10gmp_agirc_band_db         := pay_fr_arc_pkg.get_balance_id('FR_GMP_AGIRC_BAND'
                                                                  ,'Assignment Establishment Year To Date');
  g_11total_cost_to_employer_db := pay_fr_arc_pkg.get_balance_id('FR_TOTAL_COST_TO_EMPLOYER'
                                                                  ,'Assignment Establishment Year To Date');
  g_12taxable_income_db         := pay_fr_arc_pkg.get_balance_id('FR_TAXABLE_INCOME'
                                                                  ,'Assignment Establishment Period To Date');
  --
  -- Get the translated names of input values from NAME Translations lookup
  --
  hr_utility.set_location('Loading translated names ' || l_proc, 50);
  g_fr_name_pay_value  := nvl(substr(hr_general.decode_lookup('NAME_TRANSLATIONS','PAY VALUE'),1,30), g_us_name_pay_value);
  g_retro_tl           := nvl(substr(hr_general.decode_lookup('NAME_TRANSLATIONS','RETRO'),1,30), g_retro_tl);
  g_fr_name_rate       := nvl(substr(hr_general.decode_lookup('NAME_TRANSLATIONS','RATE'),1,30), g_fr_name_rate);
  g_fr_name_base       := nvl(substr(hr_general.decode_lookup('NAME_TRANSLATIONS','BASE'),1,30), g_fr_name_base);
  g_fr_name_start_date := nvl(hr_general.decode_lookup('NAME_TRANSLATIONS','START_DATE'), g_fr_name_start_date);
  g_fr_name_end_date   := nvl(hr_general.decode_lookup('NAME_TRANSLATIONS','END_DATE'), g_fr_name_end_date);
  --
  -- Get the context id of SOURCE_TEXT in ff_contexts
  --
  open csr_context('SOURCE_TEXT');
  fetch csr_context INTO g_source_text;
  close csr_context;
  --
  -- Get the termination element type ids
  --
  open csr_termination_elements('FR_TERMINATION_SUBJECT_TO_SS');
  fetch csr_termination_elements into g_term_ele_subject_to_ss;
  close csr_termination_elements;
  open csr_termination_elements('FR_TERMINATION_EXEMPT_OF_SS');
  fetch csr_termination_elements into g_term_ele_exempt_of_ss;
  close csr_termination_elements;
  --
  -- Load the parameters to the process
  --
  if g_payroll_action_id is null
  or g_payroll_action_id <> p_payroll_action_id
  then
    hr_utility.set_location('Loading parameters ' || l_proc, 60);
    pay_fr_arc_pkg.get_all_parameters
       (p_payroll_action_id => p_payroll_action_id
       ,p_payroll_id        => g_param_payroll_id
       ,p_assignment_id     => g_param_assignment_id
       ,p_assignment_set_id => g_param_assignment_set_id
       ,p_business_Group_id => g_param_business_group_id
       ,p_start_date        => g_param_start_date
       ,p_effective_date    => g_param_effective_date);
    g_payroll_action_id := p_payroll_action_id;
  end if;
  --
    hr_utility.set_location('Loading dimension ' || l_proc, 70);
    open csr_get_dimension('Assignment Run To Date');
    fetch csr_get_dimension into g_asg_run;
    close csr_get_dimension;
    --
    open csr_get_dimension('Assignment Proration Run To Date');
    fetch csr_get_dimension into g_asg_pro_run;
    close csr_get_dimension;
    --
    open csr_get_dimension('ASG_ET_PR_RA_CU_RUN contexts Establishment, Process Type, Rate, CU_ID');
    fetch csr_get_dimension into g_asg_et_pr_ra_cu_run;
    close csr_get_dimension;
    --
    open csr_get_dimension('ASG_ET_PR_RA_CU_PRO_RUN contexts Establishment, Process Type, Rate, CU_ID');
    fetch csr_get_dimension into g_asg_et_pr_ra_cu_pro_run;
    close csr_get_dimension;
    --
    open csr_get_dimension('ASG_ET_PR_CU_RUN contexts Establishment, Process Type, Contribution Usage');
    fetch csr_get_dimension into g_asg_et_pr_cu_run;
    close csr_get_dimension;
    --
    open csr_get_dimension('ASG_ET_PR_CU_PRO_RUN contexts Establishment, Process Type, Contribution Usage');
    fetch csr_get_dimension into g_asg_et_pr_cu_pro_run;
    close csr_get_dimension;
    --
    -- get the PER application ID
    --
    open csr_get_per_id;
    fetch csr_get_per_id into g_per_id;
    close csr_get_per_id;
    --
    -- Get the balance category ids.
    --
    open csr_get_bal_cat('CSG Non-Deductible');
    fetch csr_get_bal_cat into g_CSG_non_Deductible;
    close csr_get_bal_cat;
    --
    open csr_get_bal_cat('Conventional EE Deductions');
    fetch csr_get_bal_cat into g_Conv_EE_Deductions;
    close csr_get_bal_cat;
    --
    open csr_get_bal_cat('Conventional ER Charges');
    fetch csr_get_bal_cat into g_Conv_ER_Charges;
    close csr_get_bal_cat;
    --
    open csr_get_bal_cat('Income Tax Excess');
    fetch csr_get_bal_cat into g_Income_Tax_Excess;
    close csr_get_bal_cat;
    --
    open csr_get_bal_cat('Rebates');
    fetch csr_get_bal_cat into g_Rebates;
    close csr_get_bal_cat;
    --
    open csr_get_bal_cat('Statutory EE Deductions');
    fetch csr_get_bal_cat into g_Stat_EE_Deductions;
    close csr_get_bal_cat;
    --
    open csr_get_bal_cat('Statutory ER Charges');
    fetch csr_get_bal_cat into g_Stat_ER_Charges;
    close csr_get_bal_cat;
  --
    --
    -- Get the element classification ids.
    --
    open csr_get_ele_class('CSG Non-Deductible');
    fetch csr_get_ele_class into g_ele_class_CSG_non_Deductible;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Conventional EE Deductions');
    fetch csr_get_ele_class into g_ele_class_Conv_EE_Deductions;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Conventional ER Charges');
    fetch csr_get_ele_class into g_ele_class_Conv_ER_Charges;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Income Tax Excess');
    fetch csr_get_ele_class into g_ele_class_Income_Tax_Excess;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Rebates');
    fetch csr_get_ele_class into g_ele_class_Rebates;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Statutory EE Deductions');
    fetch csr_get_ele_class into g_ele_class_Stat_EE_Deductions;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Statutory ER Charges');
    fetch csr_get_ele_class into g_ele_class_Stat_ER_Charges;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('Net EE Deductions');
    fetch csr_get_ele_class into g_ele_class_Net_EE_Deductions;
    close csr_get_ele_class;
    --
    open csr_get_ele_class('ER LV Charges');
    fetch csr_get_ele_class into g_ele_class_ER_LV_Charges;
    close csr_get_ele_class;
  --
  -- Retrieving security code (bug 3683906) - moved here from archive_code_sub
  -- and altered as part of bug 4778143
  g_sec_grp_id_user_element_grp :=
                   fnd_global.lookup_security_group('FR_USER_ELEMENT_GROUP',3);
  g_sec_grp_id_base_unit := fnd_global.lookup_security_group('FR_BASE_UNIT',3);
  g_sec_grp_id_element_grp :=
                        fnd_global.lookup_security_group('FR_ELEMENT_GROUP',3);
  g_sec_grp_id_process_type :=
                         fnd_global.lookup_security_group('FR_PROCESS_TYPE',3);
  g_sec_grp_id_fixed_time_units :=
                     fnd_global.lookup_security_group('FR_FIXED_TIME_UNITS',3);
  g_sec_grp_id_fixed_time_freq :=
                 fnd_global.lookup_security_group('FR_FIXED_TIME_FREQUENCY',3);
  --
  hr_utility.set_location('Leaving ' || l_proc, 100);
  --
END archinit;
---------------------------------------------------------------------------------------------------
-- ARCHIVE CODE
-- DESCRIPTION : Main routine that determins if child actions should be created. If so creates
--               child actions and loads archive data against those actions. Otherwise creates
--               archive data against the parameter assignment action.
---------------------------------------------------------------------------------------------------
procedure archive_code(
          p_assactid                 in number
         ,p_effective_date           in date) is
  --
  l_proc VARCHAR2(40):= g_package||' Archive code ';
  --
  cursor csr_prepay_children is
  SELECT child_pre.assignment_action_id   assignment_action_id
        ,child_pre.assignment_id          assignment_id
        ,child_pre.tax_unit_id            establishment_id
        ,master_arc.chunk_number          chunk_number
        ,master_arc.payroll_action_id     payroll_action_id
        ,pay_assignment_actions_s.nextval new_ass_act_id
   FROM   pay_assignment_Actions master_arc
         ,pay_action_interlocks lok
         ,pay_assignment_Actions child_pre
   WHERE master_arc.assignment_action_id = p_assactid
     and lok.locking_Action_id           = master_arc.assignment_action_id
     and lok.locked_action_id            = child_pre.source_action_id;
  --
  l_child                          boolean;
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Determine if need to create child actions and store in a loop, or
  -- just archive the data under the action created in Action Creation
  --
  l_child := false;
  FOR child IN csr_prepay_children LOOP
    --
    l_child := true;
    hr_nonrun_asact.insact(lockingactid => child.new_ass_act_id
                          ,assignid     => child.assignment_id
                          ,pactid       => child.payroll_action_id
                          ,chunk        => child.chunk_number
                          ,greid        => child.establishment_id
                          ,source_act   => p_assactid);
    --
    -- insert the lock archive child action->prepay child action
    --
    hr_nonrun_asact.insint(child.new_ass_act_id,child.assignment_action_id);
    --
    -- process the child action
    --

    archive_code_sub(p_assactid       => child.new_ass_act_id
                    ,p_effective_date => p_effective_date);
    --
    -- this child action is now complete
    --
    update pay_assignment_actions
    set action_status = 'C'
    where assignment_action_id = child.new_ass_act_id;
  END LOOP;
  --
  -- Only process the parent action if it has no child actions
  --
  IF not l_child THEN
    --
    -- process the main action
    --
    archive_code_sub(p_assactid       => p_assactid
                    ,p_effective_date => p_effective_date);
  END IF;
  --
--
END Archive_Code;

---------------------------------------------------------------------------------------------------
-- ARCHIVE CODE SUB
-- DESCRIPTION : routine that calls all other procedures to archive for an assignment aciton.
--
---------------------------------------------------------------------------------------------------
procedure archive_code_sub(
          p_assactid            in number
         ,p_effective_date      in date) is
  --
  l_establishment_id            pay_assignment_actions.tax_unit_id%TYPE;
  l_person_id                   per_all_people_f.person_id%TYPE;
  l_assignment_id               per_all_assignments_f.assignment_id%TYPE;
  l_payroll_id                  pay_all_payrolls_f.payroll_id%TYPE;
  l_latest_assignment_action_id pay_assignment_actions.assignment_id%TYPE;
  l_latest_date_paid            date;
  l_ee_asat_date                date;
  l_total_gross_pay             number;
  l_net_payments                number;
  l_court_orders                number;
  l_action_info_id              number (15);
  l_ovn                         number (15);
  l_archive_type                varchar2(3)  := 'AAP';
  l_latest_process_type         varchar2(30);
  l_ee_info_id                  pay_action_information.action_information_id%TYPE;
  l_term_reason                 fnd_lookup_values.meaning%TYPE;
  l_term_pay_schedule           fnd_lookup_values.lookup_code%TYPE;
  l_term_atd                    date;
  l_term_lwd                    date;
  --
  -- variables to hold totals values, passed back from various functions
  --
  l_totals_c1_total_gross       number(15,2) := 0.00;
  l_totals_c2_total_subject     number(15,2) := 0.00;
  l_totals_c3_total_deduct_ee   number(15,2) := 0.00;
  l_totals_c3_total_deduct_er   number(15,2) := 0.00;
  l_totals_c4_taxable_income    number(15,2) := 0.00;
  l_totals_c5_total_charges_ee  number(15,2) := 0.00;
  l_totals_c5_total_charges_er  number(15,2) := 0.00;
  l_totals_c6_net_salary        number(15,2) := 0.00;
  l_totals_c7_total_pay         number(15,2) := 0.00;
  l_totals_c8_previous_advice   number(15,2) := 0.00;
  l_totals_c9_this_advice       number(15,2) := 0.00;
  l_totals_c10_net_advice       number(15,2) := 0.00;
  --
  l_total_ee_net_deductions     number(15,2) := 0.00;
  l_reductions                  number(15,2) := 0.00;
  --
  l_processing_aborted          exception;
  --
  l_proc VARCHAR2(40):= g_package||' Archive code Sub';
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -------------------------------------------------------------------
  -- Get instance variables for this particular assignment action
  -------------------------------------------------------------------
  pay_fr_arc_pkg.get_instance_variables (
             p_assignment_action_id         => p_assactid
            ,p_person_id                    => l_person_id          /* out */
            ,p_establishment_id             => l_establishment_id   /* out */
            ,p_assignment_id                => l_assignment_id      /* out */
            ,p_payroll_id                   => l_payroll_id);       /* out */
  --
  -------------------------------------------------------------------
  -- Get latest date earned (no archiving) and process type
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,20);
  pay_fr_arc_pkg.get_latest_run_data (
             p_archive_action_id            => p_assactid
            ,p_assignment_id                => l_assignment_id
            ,p_establishment_id             => l_establishment_id
            ,p_date_earned                  => l_latest_date_paid               /* out */
            ,p_latest_process_type          => l_latest_process_type            /* out */
            ,p_latest_assignment_action_id  => l_latest_assignment_action_id ); /* out */
  --
  if l_latest_date_paid is null then
    -- no non-reversed run action found by get_latest_run_data so don't archive
    raise l_processing_aborted;
  end if;
  -------------------------------------------------------------------
  -- Get the employee dates start / end estab, pay_period dates,
  -- term date, sen date and archive
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,30);
  pay_fr_arc_pkg.load_employee_dates (
             p_assignment_id                => l_assignment_id
            ,p_effective_date               => g_param_effective_date
            ,p_assignment_action_id         => p_assactid
            ,p_latest_date_earned           => l_latest_date_paid
            ,p_asat_date                    => l_ee_asat_date     /* out */
            ,p_payroll_id                   => l_payroll_id
            ,p_establishment_id             => l_establishment_id
            ,p_term_reason                  => l_term_reason
            ,p_term_atd                     => l_term_atd
            ,p_term_lwd                     => l_term_lwd
            ,p_term_pay_schedule            => l_term_pay_schedule);
  --
hr_utility.trace('asg ' || to_char(l_assignment_id));
hr_utility.trace('est ' || to_char(l_establishment_id));
hr_utility.trace('asat ' || to_char(l_ee_asat_date));
  -------------------------------------------------------------------
  -- Get the employee data and archive AS AT p_asat date
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,40);
  hr_utility.set_location('person_id   is   ' || to_char(l_person_id),12);
  pay_fr_arc_pkg.load_employee (
             p_assignment_id                => l_assignment_id
            ,p_person_id                    => l_person_id
            ,p_asat_date                    => l_ee_asat_date
            ,p_assignment_action_id         => p_assactid
            ,p_latest_date_earned           => l_latest_date_paid
            ,p_establishment_id             => l_establishment_id
            ,p_ee_info_id                   => l_ee_info_id);
  --
  -------------------------------------------------------------------
  -- Get the balance values and archive
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,50);
   pay_fr_arc_pkg.load_balances(
          p_assignment_action_id     => l_latest_assignment_action_id /* TO GET BALANCE VALUES */
         ,p_archive_action_id        => p_assactid
         ,p_context_id               => l_establishment_id
         ,p_totals_taxable_income    => l_totals_c4_taxable_income);
  --
  -------------------------------------------------------------------
  -- Get the Holidays values and archive
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,60);
  pay_fr_arc_pkg.load_holidays (
             p_assignment_id                => l_assignment_id
            ,p_person_id                    => l_person_id
            ,p_effective_date               => g_param_effective_date
            ,p_assignment_action_id         => p_assactid
            ,p_establishment_id             => l_establishment_id
            ,p_business_group_id            => g_param_business_group_id);
  --
  -------------------------------------------------------------------
  -- Get the BANK values and archive
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,70);
  pay_fr_arc_pkg.load_bank (
             p_assignment_action_id         => p_assactid
            ,p_assignment_id                => l_assignment_id
            ,p_totals_previous_advice       => l_totals_c8_previous_advice
            ,p_totals_this_advice           => l_totals_c9_this_advice
            ,p_totals_net_advice            => l_totals_c10_net_advice
            ,p_establishment_id             => l_establishment_id
            ,p_asat_date                    => l_ee_asat_date);
  --
  -------------------------------------------------------------------
  -- Get the MESSAGES values and archive
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,80);
  pay_fr_arc_pkg.load_messages (
             p_archive_assignment_action_id => p_assactid
            ,p_establishment_id             => l_establishment_id
            ,p_term_atd                     => l_term_atd
            ,p_term_reason                  => l_term_reason);
  --
  -------------------------------------------------------------------
  -- Get the Rate GROUPED Earnings and Net payments run values and archive
  -- pass back total gross pay, net pay and court orders
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,90);
  pay_fr_arc_pkg.load_ee_rate_grouped_runs(
             p_archive_assignment_action_id => p_assactid
            ,p_assignment_id                => l_assignment_id
            ,p_latest_process_type          => l_latest_process_type
            ,p_total_gross_pay              => l_totals_c1_total_gross    /* out */
            ,p_reductions                   => l_reductions               /* out */
            ,p_net_payments                 => l_net_payments             /* out */
            ,p_court_orders                 => l_court_orders             /* out */
            ,p_establishment_id             => l_establishment_id
            ,p_effective_date               => p_effective_date
            ,p_termination_reason           => l_term_reason
            ,p_term_st_ele_id               => g_term_ele_subject_to_ss
            ,p_term_ex_ele_id               => g_term_ele_exempt_of_ss

);
  --
  -------------------------------------------------------------------
  -- Get the DEDUCTIONS values and archive
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,100);
  pay_fr_arc_pkg.load_deductions(
             p_archive_assignment_action_id => p_assactid
            ,p_assignment_id                => l_assignment_id
            ,p_latest_process_type          => l_latest_process_type
            ,p_total_deduct_ee              => l_totals_c3_total_deduct_ee     /* out */
            ,p_total_deduct_er              => l_totals_c3_total_deduct_er     /* out */
            ,p_total_charge_ee              => l_totals_c5_total_charges_ee    /* out */
            ,p_total_charge_er              => l_totals_c5_total_charges_er    /* out */
            ,p_establishment_id             => l_establishment_id
            ,p_effective_date               => p_effective_date);
  --
  -------------------------------------------------------------------
  -- Get the RATE GROUPED run values and archive   (net ee and ER LV)
  -------------------------------------------------------------------
  hr_utility.set_location('Step ' || l_proc,110);
  pay_fr_arc_pkg.load_rate_grouped_runs(
             p_archive_assignment_action_id => p_assactid
            ,p_assignment_id                => l_assignment_id
            ,p_latest_process_type          => l_latest_process_type
            ,p_total_ee_net_deductions      => l_total_ee_net_deductions
            ,p_establishment_id             => l_establishment_id
            ,p_total_gross_pay              => l_totals_c1_total_gross /* in out */
            ,p_effective_date               => p_effective_date);
  --
  -------------------------------------------------------------------
  -- Calculate all running totals and archive
  -------------------------------------------------------------------
  l_totals_c2_total_subject :=  nvl(l_totals_c1_total_gross,0)  - l_reductions;
  l_totals_c6_net_salary    :=  nvl(l_totals_c1_total_gross, 0) - nvl(l_totals_c5_total_charges_ee,0);
  l_totals_c7_total_pay     :=  nvl(l_totals_c6_net_salary, 0)
                             + nvl(l_net_payments, 0)
                             - nvl(l_total_ee_net_deductions,0)
                             - nvl(l_court_orders, 0);
  --
  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_assactid
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_action_information_category =>  'FR_SOE_EE_TOTALS'
  , p_tax_unit_id                 =>  l_establishment_id
  , p_action_information4         =>  to_char(l_totals_c1_total_gross)
  , p_action_information5         =>  to_char(l_totals_c2_total_subject)
  , p_action_information6         =>  to_char(l_totals_c3_total_deduct_ee)
  , p_action_information7         =>  to_char(l_totals_c3_total_deduct_er)
  , p_action_information8         =>  to_char(l_totals_c4_taxable_income)
  , p_action_information9         =>  to_char(l_totals_c5_total_charges_ee)
  , p_action_information10        =>  to_char(l_totals_c5_total_charges_er)
  , p_action_information11        =>  to_char(l_totals_c6_net_salary)
  , p_action_information12        =>  to_char(l_totals_c7_total_pay)
  , p_action_information13        =>  to_char(l_totals_c8_previous_advice)
  , p_action_information14        =>  to_char(l_totals_c9_this_advice)
  , p_action_information15        =>  to_char(l_totals_c10_net_advice));
  --
  -- Test to ensure TOTAL_PAY is always equal to the sum of all payments to bank accounts
  -- (ie notified by this payslip)
  --
  if greatest(to_number(nvl(l_totals_c7_total_pay,0)),0) <>
     greatest(to_number(nvl(l_totals_c9_this_advice,0)),0) then
     hr_utility.trace(' l_totals_c7_total_pay ' || l_totals_c7_total_pay);
     hr_utility.trace(' l_totals_c9_this_advice ' || l_totals_c9_this_advice);
     hr_utility.set_message(801, 'PAY_74982_INCONSISTENT_PAY');
--     hr_utility.raise_error;
  end if;
  --
  -- test if this payslip should be suppressed
  --
  if      l_term_atd is not null
          AND  l_term_pay_schedule = 'LAST_DAY_WORKED'
          AND  nvl(l_term_atd, sysdate) <> nvl(l_term_lwd, sysdate)
          AND  g_param_effective_date > nvl(l_term_atd, g_param_effective_date)
          AND  g_param_effective_date < nvl(l_term_lwd, g_param_effective_date)
          AND  nvl(l_totals_c7_total_pay,0) = 0 THEN
    pay_action_information_api.update_action_information (
      p_action_information_id       =>  l_ee_info_id
     ,p_object_version_number       =>  l_ovn
     ,p_action_information16        =>  'Y');
  end if;
EXCEPTION
  when l_processing_aborted then null;
END archive_code_sub;
-------------------------------------------------------------------------------
-- LOAD_PAYSLIP_TEXT                                         loads bolierplate
-- DESCRIPTION : Archives all text (from lookup) against the payroll action,
--               ie not per asg.
-------------------------------------------------------------------------------
procedure load_payslip_text (p_action_id         in number ) is
  --
  l_action_info_id    number(15);
  l_archive_type      varchar2(3)  := 'PA';
  l_ovn               number (15);
  l_proc              VARCHAR2(40):= g_package||' load payslip text ';
  l_text1             fnd_lookup_values.meaning%TYPE;
  l_text2             fnd_lookup_values.meaning%TYPE;
  l_text3             fnd_lookup_values.meaning%TYPE;
  l_text4             fnd_lookup_values.meaning%TYPE;
  l_text5             fnd_lookup_values.meaning%TYPE;
  l_text6             fnd_lookup_values.meaning%TYPE;
  l_text7             fnd_lookup_values.meaning%TYPE;
  l_text8             fnd_lookup_values.meaning%TYPE;
  l_text9             fnd_lookup_values.meaning%TYPE;
  l_text10            fnd_lookup_values.meaning%TYPE;
  l_text11            fnd_lookup_values.meaning%TYPE;
  l_text12            fnd_lookup_values.meaning%TYPE;
BEGIN
  --
  -- Load the TOTALS bolierplate text
  --
  hr_utility.set_location('Entering ' || l_proc || 'loading totals names', 10);
  --
  l_text1  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c1_total_gross);
  l_text2  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c2_total_subject);
  l_text3  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c3_total_deductions);
  l_text4  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c4_taxable_income);
  l_text5  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c5_total_charges);
  l_text6  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c6_net_salary);
  l_text7  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c7_total_pay);
  l_text8  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c8_previous_advice);
  l_text9  := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c9_this_advice);
  l_text10 := hr_general.decode_lookup('FR_PAYSLIP_TEXT',g_totals_c10_net_advice);
  --
  -- Archive the bolilerplate to the running totals
  --
  pay_action_information_api.create_action_information(
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_action_id
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_action_information_category =>  'FR_SOE_TOTALS_TEXT'
  , p_action_information4         =>  l_text1
  , p_action_information5         =>  l_text2
  , p_action_information6         =>  l_text3
  -- not using 7 to ease mapping to ee_totals values
  , p_action_information8         =>  l_text4
  , p_action_information9         =>  l_text5
-- not using 10 to ease mapping to ee_totals values
  , p_action_information11         =>  l_text6
  , p_action_information12        =>  l_text7
  , p_action_information13        =>  l_text8
  , p_action_information14        =>  l_text9
  , p_action_information15        =>  l_text10);
  --
  -- Load balance names
  --
  hr_utility.set_location('Entering ' || l_proc || 'loading balance names', 20);
  --
  l_text1  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c1_total_gross);
  l_text2  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c2_ss_ceiling);
  l_text3  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c3_ee_total_conts);
  l_text4  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c4_stat_er_charges);
  l_text5  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c5_conv_er_charges);
  l_text6  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c6_t1_arrco);
  l_text7  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c7_t2_arrco);
  l_text8  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c8_tb_agirc);
  l_text9  := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c9_tc_agirc);
  l_text10 := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c10_gmp);
  l_text11 := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c11_total_er_cost);
--  l_text12 := hr_general.decode_lookup('FR_PAYSLIP_TOTALS',g_balance_c12_taxable_income);
  --
  -- Archive the bolilerplate to the Balances
  --
  hr_utility.set_location('Entering ' || l_proc || 'archiving balance names', 30);
  --
  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_action_id
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_action_information_category =>  'FR_SOE_BALANCE_TEXT'
  , p_action_information4         =>  l_text1
  , p_action_information5         =>  l_text2
  , p_action_information6         =>  l_text3
  , p_action_information7         =>  l_text4
  , p_action_information8         =>  l_text5
  , p_action_information9         =>  l_text6
  , p_action_information10        =>  l_text7
  , p_action_information11        =>  l_text8
  , p_action_information12        =>  l_text9
  , p_action_information13        =>  l_text10
  , p_action_information14        =>  l_text11);
  --
END load_payslip_text;
-------------------------------------------------------------------------------
-- LOAD_ORGANIZATION_DETAILS
-- DESCRIPTION :                    archives company and est data and addresses
--                                  against the payroll action, ie not asg
-------------------------------------------------------------------------------
procedure load_organization_details(
          p_payroll_action_id                    in number
         ,p_business_group_id                    in number
         ,p_payroll_id                           in number
         ,p_assignment_id                        in number
         ,p_assignment_set_id                    in number
         ,p_effective_date                       in date
         ,p_start_date                           in date) is
  --
  -- Archiver local variables
  l_action_info_id    number (15);
  l_ovn               number (15);
  l_archive_type      varchar2(3)  := 'PA';
  l_error_flag        varchar2(3)  := 'N';
--
-- csr_urssaf - was part of csr_company, but split out for
-- performance repository
--
cursor csr_urssaf (p_urssaf_id number) is
  select urssaf_info.org_information1      code,
         substr(urssaf.name,1,150)         urssaf_name
   from hr_all_organization_units_tl urssaf,
        hr_organization_information  urssaf_info
  where urssaf.language                       = userenv('lang')
  and   urssaf.organization_id                = urssaf_info.organization_id
  and   urssaf_info.org_information_context   = 'FR_URSSAF_CENTR_INFO'
  and   urssaf_info.organization_id            = p_urssaf_id;
--
-- csr_company
--   Get all companies referenced by establishments in the actions
--
cursor csr_company (p_payroll_action_id number  ) is
  select /*+ORDERED USE_NL(est_info comp_info) */
                    distinct comp.organization_id,
                    substr(comptl.name,1,150)         name,
                    comp_info.org_information1        siren,
                    comp.location_id,
                    comp_info.org_information3        urssaf_org_id,
                    comp_info.org_information2        naf_code,
                    substr(addr.address_line_1,1,150) address_line_1
  from (select distinct tax_unit_id id
        from   pay_assignment_actions       paa1
        where  paa1.payroll_action_id = p_payroll_action_id) tax_unit,
       hr_organization_information  est_info,
       hr_all_organization_units    comp,
       hr_all_organization_units_tl comptl,
       hr_organization_information  comp_info,
       hr_locations_all             addr
  where addr.location_id(+)                   = comp.location_id
  and   comptl.organization_id                = comp.organization_id
  and   comptl.language                       = userenv('lang')
  and   comp_info.organization_id(+)          = comp.organization_id
  and   comp_info.org_information_context(+)  = 'FR_COMP_INFO'
  and   est_info.org_information_context      = 'FR_ESTAB_INFO'
  and   est_info.org_information1             = comp.organization_id
  and   est_info.organization_id              = tax_unit.id;
  --
  -- csr_establishment
  --
  --   This gets all the establishment data, for any establishments referenced by the
  --   payroll action.
  --
  cursor csr_establishment (p_business_group_id number
                           ,p_payroll_action_id number) is
  select distinct
        est.organization_id                     organization_id,
        substr(esttl.name,1,150)                name,
        est_info.org_information2               siret_info,
        est_info.org_information1               company_org_id,
        est.location_id
  from  hr_all_organization_units    est
      , hr_organization_information  est_info
      , hr_all_organization_units_tl esttl
      , pay_assignment_Actions paa
  where paa.payroll_action_id                 = p_payroll_action_id
  and   est.organization_id                   = paa.tax_unit_id
  and   est_info.organization_id(+)           = est.organization_id
  and   est_info.org_information_context(+)   = 'FR_ESTAB_INFO'
  and   esttl.organization_id                 = est.organization_id
  and   esttl.language                        = userenv('lang')
  and   est.business_group_id                 = p_business_group_id;
  --
  -- csr_addresses
  --   Get all the distinct address ids used by the companies and establishments just archived
  --   and archive these values.
  --
  cursor csr_addresses (p_pay_act_id number) is
  select /*+ordered*/
         distinct addr.location_id,
                  substr(addr.address_line_1,1,150) address_line_1,
                  substr(addr.address_line_2,1,150) address_line_2,
                  substr(addr.address_line_3,1,150) address_line_3,
                  substr(addr.region_2,1,150) region_2,
                  substr(addr.region_3,1,150) region_3,
                  addr.town_or_city,
                  addr.postal_code
  from pay_action_information      pai,
       hr_locations_all            addr
  where addr.location_id                 = pai.ACTION_INFORMATION2
  and   pai.action_context_type = 'PA'
  and   pai.action_information_category in ('FR_SOE_COMPANY_DETAILS',
                                            'FR_SOE_ESTAB_INFORMATION')
  and   pai.action_context_id = p_pay_act_id;
  --
  rec_company          csr_company%ROWTYPE;
  rec_establishment    csr_establishment%ROWTYPE;
  rec_addresses        csr_addresses%ROWTYPE;
  rec_urssaf           csr_urssaf%ROWTYPE;
  l_proc VARCHAR2(60):= g_package||' Load_Organization_Details ';
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  --
  BEGIN
    --
    -- delete any previous rows previously created - only relevent
    -- in the case of a retry.
    --
    Delete from pay_action_information
    Where action_context_id = p_payroll_Action_id
    And action_context_type = 'PA'
    And action_information_category in ('FR_SOE_COMPANY_DETAILS'
                                       ,'FR_SOE_ESTAB_INFORMATION'
                                       ,'FR_SOE_ER_ADDRESSES');
  EXCEPTION
    /* this is only used in retry and is not critical */
    WHEN OTHERS THEN NULL;
  END;
  --
  BEGIN
    --
    -- COMPANY
    --
    open csr_company(p_payroll_action_id);
    LOOP
      fetch csr_company INTO rec_company;
      EXIT WHEN csr_company%NOTFOUND;
      --
      -- check that the company has an address, and address line 1 is not null
      --  else raise an error
      --
      if rec_company.address_line_1 is null then
        hr_utility.set_location('Archiving Error ',30);
        l_error_flag := 'Y';
      else
        l_error_flag := 'N';
      end if;
      --
      -- Get the urssaf details (separate cursor for performance repository)
      --
      if rec_company.urssaf_org_id is not null then
        BEGIN
          open csr_urssaf(rec_company.urssaf_org_id);
          fetch csr_urssaf into rec_urssaf;
          close csr_urssaf;
        EXCEPTION
          when others then null;
        END;
      end if;
      hr_utility.trace('Fetched urssaf ' || rec_urssaf.urssaf_name);
      --
      -- Archive the Company details, using source_id to hold context of company id
      --
      pay_action_information_api.create_action_information (
        p_action_information_id       =>  l_action_info_id
      , p_action_context_id           =>  p_payroll_action_id
      , p_action_context_type         =>  l_archive_type
      , p_object_version_number       =>  l_ovn
      , p_action_information_category =>  'FR_SOE_COMPANY_DETAILS'
      , p_action_information1         =>  to_char(rec_company.organization_id)
      , p_action_information2         =>  to_char(rec_company.location_id)
      , p_action_information4         =>  rec_company.name
      , p_action_information5         =>  rec_company.siren
      , p_action_information6         =>  rec_urssaf.code
      , p_action_information7         =>  rec_urssaf.urssaf_name
      , p_action_information8         =>  rec_company.naf_code
      , p_action_information10        =>  l_error_flag);
    --
    END LOOP;
  close csr_company;
  END;
  --
  -- Repeat for the Establishment details
  --
  BEGIN
    --
    -- ESTABLISHMENT
    --
    hr_utility.set_location('Step ' || l_proc, 30);
    open csr_establishment(p_business_group_id, p_payroll_action_id);
    LOOP
      fetch csr_establishment INTO rec_establishment;
      hr_utility.set_location('Step ' || l_proc, 31);
      EXIT WHEN csr_establishment%NOTFOUND;
      --
      if rec_establishment.location_id is null then
        hr_utility.set_location('Archiving Error ',35);
        l_error_flag := 'Y';
      else
        l_error_flag := 'N';
      end if;
      --
      -- Archive the Establishment details, using source_id to hold context of establishment id
      --
      pay_action_information_api.create_action_information (
        p_action_information_id       =>  l_action_info_id
      , p_action_context_id           =>  p_payroll_action_id
      , p_action_context_type         =>  l_archive_type
      , p_object_version_number       =>  l_ovn
      , p_action_information_category =>  'FR_SOE_ESTAB_INFORMATION'
      , p_action_information1         =>  to_char(rec_establishment.organization_id)
      , p_action_information2         =>  to_char(rec_establishment.location_id)
      , p_action_information3         =>  rec_establishment.company_org_id
      , p_action_information4         =>  rec_establishment.name
      , p_action_information5         =>  rec_establishment.siret_info
      , p_action_information10        =>  l_error_flag);
      --
    END LOOP;
    close csr_establishment;
  END;
  --
  -- Repeat for all location_ids (addresses) used by either the est or coy
  --
  -- ADDRESS items
  BEGIN
    hr_utility.set_location('Step ' || l_proc, 40);
    open csr_addresses(p_payroll_action_id);
    LOOP
      fetch csr_addresses INTO rec_addresses;
      EXIT WHEN csr_addresses%NOTFOUND;
      --
      -- Archive the Address details, using source_id to hold context of the address id
      --
      pay_action_information_api.create_action_information (
        p_action_information_id       =>  l_action_info_id
      , p_action_context_id           =>  p_payroll_action_id
      , p_action_context_type         =>  l_archive_type
      , p_object_version_number       =>  l_ovn
      , p_action_information_category =>  'FR_SOE_ER_ADDRESSES'
      , p_action_information1         =>  to_char(rec_addresses.location_id)
      , p_action_information4         =>  rec_addresses.address_line_2
      , p_action_information5         =>  rec_addresses.address_line_1
      , p_action_information6         =>  rec_addresses.address_line_3
      , p_action_information7         =>  rec_addresses.region_2
      , p_action_information8         =>  rec_addresses.region_3
      , p_action_information9         =>  rec_addresses.town_or_city
      , p_action_information10        =>  rec_addresses.postal_code);
      --
    END LOOP;
  close csr_addresses;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  END;
end load_organization_details;
-------------------------------------------------------------------------------
-- GET_INSTANCE_VARIABLES
--
-------------------------------------------------------------------------------
procedure get_instance_variables (
          p_assignment_action_id                 in  number
         ,p_person_id                            out nocopy number
         ,p_establishment_id                     out nocopy number
         ,p_assignment_id                        out nocopy number
         ,p_payroll_id                           out nocopy number) is
  --
  l_tax_unit_id      pay_assignment_actions.tax_unit_id%TYPE;
  l_person_id        per_all_people_f.person_id%TYPE;
  l_assignment_id    per_all_assignments_f.assignment_id%TYPE;
  l_payroll_id       pay_all_payrolls_f.payroll_id%TYPE;
  --
  l_proc VARCHAR2(40):= g_package||' get_instance_variables ';
  cursor csr_establishment(p_paa_id number) is
    select paa.tax_unit_id, paa.assignment_id, asg.person_id, asg.payroll_id
    from   pay_assignment_actions paa
          ,per_assignments asg
    where  paa.assignment_action_id = p_paa_id
      and  paa.assignment_id = asg.assignment_id;
BEGIN
  --
  hr_utility.set_location(' Entering ' || l_proc, 10);
  --
  open  csr_establishment(p_assignment_action_id);
  fetch csr_establishment into l_tax_unit_id, l_assignment_id, l_person_id, l_payroll_id;
  if csr_establishment%NOTFOUND then
    close csr_establishment;
    hr_utility.set_location('DEV ERROR : BAD assignment action : ' || to_char(p_assignment_action_id), 20);
  else
    close csr_establishment;
    p_person_id := l_person_id;
    p_establishment_id := l_tax_unit_id;
    p_assignment_id := l_assignment_id;
    p_payroll_id := l_payroll_id;
  end if;
  hr_utility.set_location(' Leaving ' || l_proc, 100);
end get_instance_variables;
-------------------------------------------------------------------------------
-- GET_LATEST_RUN_DATA
-- DESCRIPTION : gets the latest process type and date earned in set of
--               archived actions, and the latest run aa_id
-------------------------------------------------------------------------------
procedure get_latest_run_data(
          p_archive_action_id                    in number
         ,p_assignment_id                        in number
         ,p_establishment_id                     in number
         ,p_date_earned                          out nocopy date
         ,p_latest_process_type                  out nocopy varchar2
         ,p_latest_assignment_action_id          out nocopy number) is
  --
  l_date_earned             date;
  l_latest_action_sequence  pay_assignment_actions.action_sequence%TYPE;
  l_latest_asg_action_id    pay_assignment_actions.assignment_action_id%TYPE;
  l_latest_process_type     varchar2(30);
  l_dummy                   number;
  --
  l_proc VARCHAR2(40):= g_package||' get_latest_run_data ';
  --
  cursor csr_date_earned(p_establishment_id  number
                        ,p_archive_action_id number)  is
  SELECT  run_payact.effective_date, run_assact.action_sequence,
          run_assact.assignment_action_id, proc_type.context_value
   FROM   pay_action_interlocks     arc_interlock
   ,      pay_action_interlocks     pre_interlock
   ,      pay_assignment_actions    run_assact
   ,      pay_payroll_actions       run_payact
   ,      pay_action_contexts       proc_type /*will exclude proration actions*/
   WHERE  arc_interlock.locking_action_id = p_archive_action_id
     and  pre_interlock.locking_action_id = arc_interlock.locked_action_id
     and  pre_interlock.locked_action_id  = run_assact.assignment_action_id
     and  proc_type.assignment_id         = run_assact.assignment_id
     and  proc_type.assignment_action_id  = run_assact.assignment_action_id
     and  proc_type.context_id            = g_source_text
     and  run_payact.payroll_action_id    = run_assact.payroll_action_id
     and  run_payact.action_type         in ('Q','R')
     and  run_assact.run_type_id         is not null
   order  by run_payact.effective_date desc
            ,run_assact.action_sequence desc ;
  --
  CURSOR csr_locking_reversal (p_run_act_id number) is
  SELECT 1 /* if the run action is reversed exclude it */
  FROM   pay_action_interlocks rev_interlock
  ,      pay_assignment_actions rev_assact
  ,      pay_payroll_actions rev_payact
  WHERE  rev_interlock.locked_action_id  = p_run_act_id
  AND    rev_interlock.locking_action_id = rev_assact.assignment_action_id
  AND    rev_assact.action_status        = 'C'
  AND    rev_payact.payroll_action_id    = rev_assact.payroll_action_id
  AND    rev_payact.action_type          = 'V'
  AND    rev_payact.action_status        = 'C';
  --
BEGIN
  --
  hr_utility.set_location('Entering ' || l_proc , 10);
  --
  open csr_date_earned(p_establishment_id, p_archive_action_id);
  loop
    fetch csr_date_earned into l_date_earned, l_latest_action_sequence,
                               l_latest_asg_action_id, l_latest_process_type;
    exit when csr_date_earned%NOTFOUND;
    open csr_locking_reversal(l_latest_asg_action_id);
    fetch csr_locking_reversal into l_dummy;
    if csr_locking_reversal%FOUND then
      l_date_earned            := null;
      l_latest_asg_action_id   := null;
      l_latest_process_type    := null;
      close csr_locking_reversal;
    else
      close csr_locking_reversal;
      exit;
    end if;
  end loop;
  --
  close csr_date_earned;
  p_date_earned := l_date_earned;
  p_latest_process_type := l_latest_process_type;
  p_latest_assignment_action_id := l_latest_asg_action_id;
  hr_utility.set_location(' Leaving ' || l_proc, 100);
end get_latest_run_data;
------------------------------------------------------------------------------
-- LOAD EMPLOYEE DATES
-- DESCRIPTION : fetches and adjustes employee dates
------------------------------------------------------------------------------
procedure load_employee_dates(
          p_assignment_id            in number
         ,p_effective_date           in date
         ,p_assignment_action_id     in number
         ,p_latest_date_earned       in date
         ,p_asat_date                out nocopy date
         ,p_payroll_id               in number
         ,p_establishment_id         in number
         ,p_term_reason              OUT nocopy varchar2
         ,p_term_atd                 OUT nocopy date
         ,p_term_lwd                 OUT nocopy date
         ,p_term_pay_schedule        OUT nocopy varchar2) is

  --
  -- employee dates to determine
  --
  l_ee_est_start_date        date;
  l_ee_est_end_date          date;
  l_ee_pay_period_start_date date;
  l_ee_pay_period_end_date   date;
  l_ee_pay_date              date;
  l_ee_deposit_date          date;
  l_direct_dd_date           date;
  l_ee_seniority_date        date;
  l_ee_termination_date      date;
  l_ee_adjusted_term_date    date; -- this is term date bounded by period dates
  --
  l_action_info_id    number (15);
  l_ovn               number (15);
  l_archive_type      varchar2(3)  := 'AAP';
  l_proc VARCHAR2(60):= g_package||' Load_Employee_dates ';
  --
  -- csr_estab_start_date Gets the employees estab start dates
  --
  cursor csr_ee_estab_start_date (p_assignment_id number, p_date_earned date, p_establishment_id number) is
    select min(asg1.effective_start_date)
    from per_all_assignments_f asg1
        ,per_all_assignments_f asg2
    where asg1.assignment_id = p_assignment_id
      and asg2.assignment_id = p_assignment_id
      and asg1.establishment_id = asg2.establishment_id
      and asg2.effective_start_date >= asg1.effective_start_date
      and not exists /* no in between row with different estab id */
            (select null
             from   per_all_assignments_f asg
             where  asg.effective_start_date >   asg1.effective_end_Date
               and  asg.effective_end_date   <   asg2.effective_start_date
               and  asg.establishment_id     <>  asg1.establishment_id
               and  asg.assignment_id        =   asg1.assignment_id)
     and asg2.effective_start_date =
           (select  max(effective_Start_Date)
              from  per_all_assignments_f
              where assignment_id = p_assignment_id
                and establishment_id = p_establishment_id
                and effective_Start_Date <= p_date_earned);

  --
  -- csr_estab_end_date Gets the employees estab end dates
  --
  cursor csr_ee_estab_end_date (p_assignment_id number, p_date_earned date, p_establishment_id number) is
  select max(asg4.effective_end_date)
    from per_all_assignments_f asg3
        ,per_all_assignments_f asg4
   where asg3.assignment_id = p_assignment_id
     and asg4.assignment_id = p_assignment_id
     and asg3.establishment_id = asg4.establishment_id
     and asg4.effective_start_date >= asg3.effective_start_date
     and not exists /* no in between row with different estab id */
            (select null
             from   per_all_assignments_f asg
             where  asg.effective_start_date <   asg4.effective_start_Date
               and  asg.effective_start_date >   asg3.effective_start_date
               and  asg.establishment_id     <>  asg4.establishment_id
               and  asg.assignment_id        =   asg4.assignment_id)
     and asg4.effective_start_date =
           (select  max(effective_Start_Date)
              from  per_all_assignments_f
              where assignment_id = p_assignment_id
                and establishment_id = p_establishment_id
                and effective_Start_Date <= p_date_earned);

  --
  -- csr_direct deposit date gets the default bank deposit date
  --
  cursor csr_deposit_date (p_payroll_id number, p_latest_date_earned date) is
    select default_dd_date
      from per_time_periods
     where payroll_id = p_payroll_id
       and p_latest_date_earned between start_date and end_date;
  --
  -- If there has already been a mag tape transfer, get the transfer date from
  -- that payroll action.
  -- The transfer action's assignment action will be locking the same prepayment
  -- actions as the archive extract.
  --
  cursor csr_actual_deposit_date (p_payroll_id    number
                                 ,p_assignment_action_id number
                                 ,p_assignment_id number) is
	  select m_ppa.overriding_dd_date
	  from pay_action_interlocks   a_lock
	      ,pay_payroll_actions     a_ppa
	      ,pay_assignment_Actions  a_asg
	      ,pay_assignment_actions  m_asg
  	      ,pay_assignment_actions  p_asg
  	      ,pay_payroll_actions     m_ppa
	      ,pay_action_interlocks   m_lock
	 where a_lock.locking_Action_id = p_assignment_action_id
	  and  a_lock.locked_action_id  = a_asg.assignment_Action_id
  	  and  a_asg.payroll_action_id  = a_ppa.payroll_action_id
	  and  a_asg.assignment_id      = p_assignment_id
	  and  a_ppa.action_type        = 'U'
	  and  a_ppa.action_status      = 'C'
	  and  a_ppa.payroll_action_id  = p_asg.payroll_action_id
	  and  p_asg.assignment_id      = p_assignment_id
	  and  p_asg.assignment_Action_id = m_lock.locked_action_id
	  and  m_lock.locking_action_id = m_asg.assignment_action_id
	  and  m_asg.assignment_id      = p_assignment_id
	  and  m_asg.payroll_action_id  = m_ppa.payroll_action_id
	  and  m_ppa.action_type        = 'M'
	  and  m_ppa.action_status      = 'C';
  --
  -- svc history record, get termination date and seniority date
  -- There must be a svc record as at effective date
  --
  cursor csr_get_service_dates (p_assignment_id number, p_effective_date date) is
    select svc.actual_termination_date  ATD
          ,nvl(svc.adjusted_svc_date, svc.date_start)
          ,hr_general.decode_lookup('LEAV_REAS', svc.leaving_reason)
          ,svc.pds_information11        final_pay_schedule
          ,fnd_date.canonical_to_date(svc.pds_information10) LWD
    from   per_periods_of_service svc
          ,per_all_assignments_f asg
    where  asg.period_of_service_id = svc.period_of_service_id
      and  p_effective_date between asg.effective_start_date and asg.effective_end_date
      and  asg.assignment_id = p_assignment_id;
  --
  BEGIN

  hr_utility.set_location('Entering ' || l_proc, 10);
  --
  -- Fetch the address data
  --
  open  csr_ee_estab_start_date(p_assignment_id, p_latest_date_earned, p_establishment_id);
  fetch csr_ee_estab_start_date INTO l_ee_est_start_date;
  close csr_ee_estab_start_date;
  --
--
--  hr_utility.trace('p_assignment_id ' || to_char(p_assignment_id));
--  hr_utility.trace('p_latest_date_earned ' || to_char(p_latest_date_earned));
--  hr_utility.trace('p_establishment_id ' || to_char(p_establishment_id));
--
  open  csr_ee_estab_end_date(p_assignment_id, p_latest_date_earned, p_establishment_id);
  fetch csr_ee_estab_end_date INTO l_ee_est_end_date;  /* may be eot */
  close csr_ee_estab_end_date;
  --
  -- Fetch the actual direct deposit dates
  --
  hr_utility.trace('p_assignment_action_id ' || p_assignment_action_id);

  open  csr_actual_deposit_date(p_payroll_id, p_assignment_action_id, p_assignment_id);
  fetch csr_actual_deposit_date INTO l_direct_dd_date;
  close csr_actual_deposit_date;
  --
  -- Fetch the direct deposit dates, if actual does not exist;
  --
  if l_direct_dd_date is null then
    open  csr_deposit_date(p_payroll_id, p_latest_date_earned);
    fetch csr_deposit_date INTO l_direct_dd_date;
    close csr_deposit_date;
  end if;
  --
  -- Get the service history dates
  --
  hr_utility.set_location('Entering ' || l_proc, 22);
  open  csr_get_service_dates(p_assignment_id, p_effective_date);
  hr_utility.set_location('Entering ' || l_proc, 23);
  fetch csr_get_service_dates INTO l_ee_termination_date
                                  ,l_ee_seniority_date
                                  ,p_term_reason
                                  ,p_term_pay_schedule
                                  ,p_term_lwd;
  hr_utility.set_location('Entering ' || l_proc, 24);
  /* pass actual termination date to out variable */
  p_term_atd             := l_ee_termination_date;
  close csr_get_service_dates;
  --
  -- Store the dates
  --
  hr_utility.set_location('Adjusting Dates ' || l_proc, 20);
  --
  -- Adjust the employee dates
  --
  -- adjust termination date to be last day of period if null or outside period
  l_ee_adjusted_term_date := greatest(least(nvl(l_ee_termination_date
                            ,g_param_effective_date) ,g_param_effective_date)
                            ,greatest(nvl(l_ee_termination_date, g_param_start_date)
                             ,g_param_start_date));
  --
  l_ee_pay_period_start_date := greatest(g_param_start_date, l_ee_est_start_date);
  --
  l_ee_pay_period_end_date := least(g_param_effective_date
                                   ,l_ee_adjusted_term_date
                                   ,l_ee_est_end_date);
  --
  l_ee_pay_date := least( l_ee_pay_period_end_date ,p_latest_date_earned);
  --
  l_ee_deposit_date := l_direct_dd_date;
  --
  --
  -- Archive the employee dates details
  --
  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_assignment_action_id
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_tax_unit_id                 =>  p_establishment_id
  , p_action_information_category =>  'FR_SOE_EE_DATES'
  , p_action_information4         =>  fnd_date.date_to_canonical(l_ee_est_start_date)
  , p_action_information5         =>  fnd_date.date_to_canonical(l_ee_est_end_date)
  , p_action_information6         =>  fnd_date.date_to_canonical(l_ee_pay_date)
  , p_action_information7         =>  fnd_date.date_to_canonical(l_ee_pay_period_start_date)
  , p_action_information8         =>  fnd_date.date_to_canonical(l_ee_pay_period_end_date)
  , p_action_information9         =>  fnd_date.date_to_canonical(l_ee_deposit_date)
  , p_action_information10        =>  fnd_date.date_to_canonical(l_ee_seniority_date));
  --
  -- Termination date is not archived
  --
  -- pass back the date as at to fetch the employee data
  --
  p_asat_date := l_ee_pay_period_end_date;
  --
  hr_utility.set_location('Leaving ' || l_proc, 100);
end load_employee_dates;
-------------------------------------------------------------------------------
-- LOAD EMPLOYEE
-- DESCRIPTION : Archives basic employee datails as at p_asat_date
--               Archives ee address
--               Archives ee collective agreement grade(s) and coefficient
-------------------------------------------------------------------------------
procedure load_employee(
          p_assignment_id             in number
         ,p_person_id                 in number
         ,p_asat_date                 in date  /* fetch ee data as at this date */
         ,p_assignment_action_id      in number
         ,p_latest_date_earned        in date
         ,p_establishment_id          in number
         ,p_ee_info_id                out nocopy number) is
  --
  -- ADDRESS items
  --
  l_address_1              varchar2(150);
  l_address_2              varchar2(150);
  l_address_3              varchar2(150);
  l_address_insee_code     varchar2(150);
  l_address_small_town     varchar2(150);
  l_address_city           varchar2(150);
  l_address_post_code      varchar2(150);
  --
  -- ee details cursor items
  --
  l_ee_soc_sec_number         varchar2(30);
  l_ee_last_name              per_all_people_f.last_name%TYPE;
  l_ee_first_name             per_all_people_f.first_name%TYPE;
  l_ee_full_name              per_all_people_f.full_name%TYPE;
  l_ee_job_name               per_jobs.name%TYPE;
  l_ee_job_id                 per_jobs.job_id%type;
  l_ee_job_definition_id      per_jobs.job_definition_id%type;
  l_ee_position_name          per_positions.name%TYPE;
  l_ee_coll_agree_name        per_collective_agreements.name%TYPE;
  l_ee_coy_id                 varchar2(150);
  l_ee_payroll_id             per_all_assignments_f.payroll_id%TYPE;
  l_ee_maiden_name            per_all_people_f.previous_last_name%TYPE;
  l_ee_assignment_number      per_all_assignments_f.assignment_number%TYPE;
  l_ee_org_name               hr_all_organization_units.name%TYPE;
  --
  NO_ADDRESS                  EXCEPTION; /* error as must be sent to a home address */
  --
  -- ee CAGR details
  --
  l_qualifier                 fnd_segment_attribute_values.segment_attribute_type%TYPE;
  l_cagr_value                per_cagr_grades_def.segment1%TYPE;
  l_coefficient               per_cagr_grades_def.segment1%TYPE;
  l_coefficient_name          fnd_id_flex_segments.segment_name%TYPE;
  --
  -- Archiver local variables
  --
  l_action_info_id    number (15);
  l_ovn               number (15);
  l_archive_type      varchar2(3)  := 'AAP';
  --
  -- Local variables added as part of tiem analysis changes
  l_con_fixed_working_time per_contracts_f.ctr_information10%type;
  l_amount                 per_contracts_f.ctr_information11%type;
  l_units                  per_contracts_f.ctr_information12%type;
  l_units_mean             hr_lookups.meaning%type;
  l_frequency              per_contracts_f.ctr_information13%type;
  l_freq_mean              hr_lookups.meaning%type;
  --
  -- csr_ee_address Gets the employees primary address
  --
  cursor csr_ee_address (p_person_id number, p_asat_date date)   is
    select addr.address_line1, addr.address_line2, addr.address_line3
          ,addr.region_2, addr.region_3, addr.town_or_city, addr.postal_code
    from   per_addresses addr
    where  addr.person_id = p_person_id
      and  addr.primary_flag = 'Y'
      and  p_asat_date >= addr.date_from
      and  p_asat_date <= nvl(addr.date_to, p_asat_date);

  l_proc VARCHAR2(40):= g_package||' Load_Employee ';
  --
  -- csr_ee_details gets basic person and assignment details
  --
  -- Changed for Time_analysis
  --
  cursor csr_ee_details(p_assignment_id number, p_asat_date date) is
  Select peo.national_identifier
        ,peo.last_name
        ,peo.first_name
        ,peo.full_name
        ,job.job_id
	,job.job_definition_id
        ,postl.name
        ,cag.name
        ,to_number(estinfo.org_information1)
        ,asg.payroll_id
        ,peo.previous_last_name
        ,asg.assignment_number
        ,orgtl.name
        ,ctr.ctr_information10 fixed_working_time
        ,ctr.ctr_information11 Con_Amount
        ,ctr.ctr_information12 Con_Units
        ,hrl.meaning Con_Unit_mean
        ,ctr.ctr_information13 Con_Frequency
        ,hrl1.meaning Con_freq_mean
  from
         per_all_assignments_f        asg
        ,per_all_people_f             peo
        ,per_jobs                     job
        ,hr_all_positions_f_tl        postl
        ,per_collective_agreements    cag
        ,hr_all_organization_units    est
        ,hr_organization_information  estinfo
        ,hr_all_organization_units_tl orgtl
        ,per_contracts_f              ctr
        ,fnd_lookup_values            hrl
        ,fnd_lookup_values            hrl1
  where  asg.assignment_id               = p_assignment_id
    and  p_asat_date               between asg.effective_start_date
                                       and asg.effective_end_date
    and  asg.establishment_id            = est.organization_id
    and  p_asat_date               between est.date_from
                                       and nvl(est.date_to, p_asat_date)
    and  estinfo.organization_id         = est.organization_id
    and  estinfo.org_information_context = 'FR_ESTAB_INFO'
    and  asg.collective_agreement_id     = cag.collective_agreement_id(+)
    and  asg.person_id                   = peo.person_id
    and  asg.position_id                 = postl.position_id(+)
    and  postl.language(+)               = userenv('LANG')
    and  asg.job_id                      = job.job_id(+)
    and  orgtl.organization_id           = asg.organization_id
    and  orgtl.language                  = userenv('LANG')
    and  p_asat_date               between peo.effective_start_date
                                       and peo.effective_end_date
    and  asg.contract_id                 = ctr.contract_id
    and  p_asat_date               between ctr.effective_start_date
                                       and ctr.effective_end_date
    and  hrl.lookup_type                 = 'FR_FIXED_TIME_UNITS'
    and  hrl.view_application_id         = 3
    and  hrl.security_group_id           = g_sec_grp_id_fixed_time_units
    and  hrl.language                    = userenv('LANG')
    and  hrl.lookup_code                 = ctr.ctr_information12
    and  hrl1.lookup_type                = 'FR_FIXED_TIME_FREQUENCY'
    and  hrl1.view_application_id        = 3
    and  hrl1.security_group_id          = g_sec_grp_id_fixed_time_freq
    and  hrl1.language                   = userenv('LANG')
    and  hrl1.lookup_code                = ctr.ctr_information13;
--
-- csr_ee_cagr_details gets qualified collective agreement grade segment values
-- nb _all_ tables used as not all columns available in session date views
-- nb any number of qualifiers may be being used.
-- report only 'GRADE' and 'COEFFICIENT' qualified values.
--
cursor csr_ee_cagr_details (p_assignment_id number, p_asat_date date, p_per_id number) is
Select     gqual.segment_attribute_type                        qualifier
          ,seg_tl.Form_left_prompt                             seg_name
          ,substr(decode(gqual.application_column_name
                       ,'SEGMENT1',  CAGR.segment1
                       ,'SEGMENT2',  CAGR.segment2
                       ,'SEGMENT3',  CAGR.segment3
                       ,'SEGMENT4',  CAGR.segment4
                       ,'SEGMENT5',  CAGR.segment5
                       ,'SEGMENT6',  CAGR.segment6
                       ,'SEGMENT7',  CAGR.segment7
                       ,'SEGMENT8',  CAGR.segment8
                       ,'SEGMENT9',  CAGR.segment9
                       ,'SEGMENT10', CAGR.segment10
                       ,'SEGMENT11', CAGR.segment11
                       ,'SEGMENT12', CAGR.segment12
                       ,'SEGMENT13', CAGR.segment13
                       ,'SEGMENT14', CAGR.segment14
                       ,'SEGMENT15', CAGR.segment15
                       ,'SEGMENT16', CAGR.segment16
                       ,'SEGMENT17', CAGR.segment17
                       ,'SEGMENT18', CAGR.segment18
                       ,'SEGMENT19', CAGR.segment19
                       ,'SEGMENT20', CAGR.segment20, null),1,60) seg_value
  from
    per_all_assignments_f        asg
   ,per_cagr_grades_def          cagr
   ,fnd_id_flex_segments         seg
   ,fnd_id_flex_segments_tl      seg_tl
   ,fnd_segment_attribute_values gqual
  where  asg.assignment_id        = p_assignment_id
   and   asg.cagr_grade_def_id    = CAGR.cagr_grade_def_id (+)
   and   gqual.id_flex_num(+)     = CAGR.id_flex_num
   and   gqual.id_flex_code(+)    = 'CAGR'
   and   gqual.attribute_value(+) = 'Y'
   and   seg.id_flex_code         = 'CAGR'
   and   seg.id_flex_num          = asg.cagr_id_flex_num
   and   seg.application_id       = p_per_id
   and   gqual.application_id     = p_per_id
   and   seg.application_column_name = gqual.application_column_name
   and   p_asat_date between asg.effective_start_date and asg.effective_end_date
   and  (gqual.segment_attribute_type = 'COEFFICIENT'
         or
         gqual.segment_attribute_type = 'GRADE')
   and seg_tl.application_id = seg.application_id
   and seg_tl.id_flex_code         = 'CAGR'
   and seg_tl.id_flex_num          = asg.cagr_id_flex_num
   and seg_tl.application_column_name = seg.application_column_name
   and seg_tl.language = userenv('LANG')
  order by seg.segment_num;

  rec_ee_cagr_details csr_ee_cagr_details%ROWTYPE;
  --
BEGIN
  hr_utility.set_location(' Entering ' || l_proc, 10);
  hr_utility.set_location('  as at date is ' || to_char(p_asat_date, 'yyyy-mm-dd'),20);
  --
  -- Fetch the address data
  --
  open  csr_ee_address(p_person_id, p_asat_date);
  fetch csr_ee_address INTO   l_address_1, l_address_2, l_address_3
                             ,l_address_insee_code,  l_address_small_town, l_address_city
                             ,l_address_post_code;
  if csr_ee_address%NOTFOUND then
    hr_utility.set_message(800, 'PER_52990_ASG_PRADD_NE_PAY');
    hr_utility.raise_error;
    close csr_ee_address;
  else
    close csr_ee_address;
    --
    -- Archive the employee address details
    --
    pay_action_information_api.create_action_information (
      p_action_information_id       =>  l_action_info_id
    , p_action_context_id           =>  p_assignment_action_id
    , p_action_context_type         =>  l_archive_type
    , p_object_version_number       =>  l_ovn
    , p_tax_unit_id                 =>  p_establishment_id
    , p_action_information_category =>  'FR_SOE_EE_ADDRESS'
    , p_action_information4         =>  l_address_2
    , p_action_information5         =>  l_address_1
    , p_action_information6         =>  l_address_3
    , p_action_information7         =>  l_address_insee_code
    , p_action_information8         =>  l_address_small_town
    , p_action_information9         =>  l_address_city
    , p_action_information10        =>  l_address_post_code);
  end if;
    -------------------------------------------------------
    -- Get basic employee details
    -------------------------------------------------------
  hr_utility.set_location('Getting Basic Detail ' || l_proc, 30);
  open  csr_ee_details(p_assignment_id, p_asat_date);
  fetch csr_ee_details INTO l_ee_soc_sec_number, l_ee_last_name, l_ee_first_name
                           ,l_ee_full_name, l_ee_job_id, l_ee_job_definition_id, l_ee_position_name
                           ,l_ee_coll_agree_name, l_ee_coy_id
                           ,l_ee_payroll_id, l_ee_maiden_name, l_ee_assignment_number
                           ,l_ee_org_name
                           --Time_analysis changes
                           ,l_con_fixed_working_time
                           ,l_amount
                           ,l_units
                           ,l_units_mean
                           ,l_frequency
                           ,l_freq_mean;
  close csr_ee_details;
  /* 3815632 appropriate job name is obtained using job_id and job_definition_id values */
  if l_ee_job_definition_id is not null then
     l_ee_job_name := per_fr_report_utilities.get_job_names (p_job_id => l_ee_job_id,
                                                     p_job_definition_id => l_ee_job_definition_id,
				                     p_report_name => 'PAYSLIP');
  else
     l_ee_job_name := NULL;
  end if;
  /* 3815632 appropriate job name is obtained using job_id and job_definition_id values */
  -----------------------------------------------------------------
  -- Get employees CAGR grade(s) and coefficient, if present
  -----------------------------------------------------------------
  hr_utility.set_location('Fetching CAGR details' || l_proc, 10);
  open  csr_ee_cagr_details(p_assignment_id, p_asat_date, g_per_id);
  LOOP
--@c:\local\fr\bal\pyfrarch.pkb;
    fetch csr_ee_cagr_details INTO rec_ee_cagr_details;
    EXIT WHEN csr_ee_cagr_details%NOTFOUND;
    --
    -- Archive the values
    --
    if rec_ee_cagr_details.qualifier = 'COEFFICIENT' then
      --  there is only one coefficient
      l_coefficient      := rec_ee_cagr_details.seg_value;
      l_coefficient_name := rec_ee_cagr_details.seg_name;
    --
    end if;
    if rec_ee_cagr_details.qualifier = 'GRADE' then
      pay_action_information_api.create_action_information (
        p_action_information_id       =>  l_action_info_id
      , p_action_context_id           =>  p_assignment_action_id
      , p_action_context_type         =>  l_archive_type
      , p_object_version_number       =>  l_ovn
      , p_tax_unit_id                 =>  p_establishment_id
      , p_action_information_category =>  'FR_SOE_EE_CAGR'
      , p_action_information1         =>  to_char(csr_ee_cagr_details%ROWCOUNT)
      , p_action_information4         =>  rec_ee_cagr_details.seg_value
      , p_action_information5         =>  rec_ee_cagr_details.seg_name);
    end if;
  END LOOP;
  close csr_ee_cagr_details;
  --
  -- Now archive the ee basic details with the collectiva agreement coefficient + desc
  --
  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_assignment_action_id
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_tax_unit_id                 =>  p_establishment_id
  , p_action_information_category =>  'FR_SOE_EE_DETAILS'
  , p_action_information1         =>  to_char(l_ee_payroll_id)
  , p_action_information2         =>  to_char(p_establishment_id)  /* for the estab to address */
  , p_action_information3         =>  l_ee_coy_id           /* for the coy to address   */
  , p_action_information4         =>  l_ee_soc_sec_number
  , p_action_information5         =>  l_ee_last_name
  , p_action_information6         =>  l_ee_first_name
  , p_action_information7         =>  substr(l_ee_full_name,1,150)
  , p_action_information8         =>  substr(l_ee_job_name, 1,150)
  , p_action_information9         =>  substr(l_ee_position_name, 1,150)
  , p_action_information10         =>  l_ee_coll_agree_name
  , p_action_information11         =>  l_ee_maiden_name
  , p_action_information12         =>  l_coefficient
  , p_action_information13         =>  l_coefficient_name
  , p_action_information14         =>  l_ee_assignment_number
  , p_action_information15         =>  l_ee_org_name
  --Time Analysis Changes
  , p_action_information17         =>  l_con_fixed_working_time
  , p_action_information18         =>  l_amount
  , p_action_information19         =>  l_units_mean
  , p_action_information20         =>  l_freq_mean);
  --
  -- pass out the action_information_id of the ee_details, as may need for update
  --
  p_ee_info_id :=  l_action_info_id;
  --
  hr_utility.set_location('Leaving ' || l_proc, 100);
end load_employee;
-------------------------------------------------------------------------------
-- LOAD_BALANCES
-- DESCRIPTION :   Gets the balance values and archives for the given asg.
-------------------------------------------------------------------------------
procedure load_balances(
          p_assignment_action_id     in number
         ,p_archive_action_id        in number
         ,p_context_id               in number
         ,p_totals_taxable_income   out nocopy number ) is
  --
  l_balance_value1  pay_assignment_latest_balances.value%TYPE;
  l_balance_value2  pay_assignment_latest_balances.value%TYPE;
  l_balance_value3  pay_assignment_latest_balances.value%TYPE;
  l_balance_value4  pay_assignment_latest_balances.value%TYPE;
  l_balance_value5  pay_assignment_latest_balances.value%TYPE;
  l_balance_value6  pay_assignment_latest_balances.value%TYPE;
  l_balance_value7  pay_assignment_latest_balances.value%TYPE;
  l_balance_value8  pay_assignment_latest_balances.value%TYPE;
  l_balance_value9  pay_assignment_latest_balances.value%TYPE;
  l_balance_value10 pay_assignment_latest_balances.value%TYPE;
  l_balance_value11 pay_assignment_latest_balances.value%TYPE;
  l_balance_value12 pay_assignment_latest_balances.value%TYPE;
  --
  l_action_info_id    number(15);
  l_archive_type      varchar2(3)  := 'AAP';
  l_ovn               number (15);
  --
  l_proc VARCHAR2(40):= g_package||' load_balances ';
BEGIN
  hr_utility.set_location(' Entering ' || l_proc, 10);
  --
  -- set the contexts
  --
  pay_balance_pkg.set_context ('ASSIGNMENT_ACTION_ID',to_char(p_assignment_action_id));
  pay_balance_pkg.set_context ('TAX_UNIT_ID',to_char(p_context_id));
  --
  -- Get all the defined balance values for this assignment
  --
  -- BALANCE 1 total gross pay
  l_balance_value1 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_1total_gross_pay_db,
                      p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 1 is ' || to_char(l_balance_value1), 15);
  -- BALANCE 2 ss ceiling
  l_balance_value2 := pay_balance_pkg.get_value (
	              p_defined_balance_id           => g_2ss_ceiling_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 2 is ' || to_char(l_balance_value2), 20);
  -- BALANCE 3 employees total contributions
  l_balance_value3 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_3es_total_contributions_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 3 is ' || to_char(l_balance_value3), 30);
  -- BALANCE 4 statutory employer charges
  l_balance_value4 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_4statutory_er_charges_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 4 is ' || to_char(l_balance_value4), 40);
  -- BALANCE 5 conventional employer charges
  l_balance_value5 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_5conventional_er_charges_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 5 is ' || to_char(l_balance_value5), 50);
  -- BALANCE 6 t1 arrco band
  l_balance_value6 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_6t1_arrco_band_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 6 is ' || to_char(l_balance_value6), 60);
  -- BALANCE 7 t2 arrco band
  l_balance_value7 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_7t2_arrco_band_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 7 is ' || to_char(l_balance_value7), 70);
  -- BALANCE 8 tb arrco band
  l_balance_value8 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_8tb_argic_band_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 8 is ' || to_char(l_balance_value8), 80);
  -- BALANCE 9 tc arrco band
  l_balance_value9 := pay_balance_pkg.get_value (
                      p_defined_balance_id           => g_9tc_agirc_band_db
                     ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 9 is ' || to_char(l_balance_value9), 90);
  -- BALANCE 10 gmp agirc band
  l_balance_value10 := pay_balance_pkg.get_value (
                       p_defined_balance_id           => g_10gmp_agirc_band_db
                      ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 10 is ' || to_char(l_balance_value10), 100);
  -- BALANCE 11 total cost to employer
  l_balance_value11 := pay_balance_pkg.get_value (
                       p_defined_balance_id           => g_11total_cost_to_employer_db
                      ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 110 is ' || to_char(l_balance_value11), 110);
  --
  -- Archive the employee balances
  --
  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_archive_action_id
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_tax_unit_id                 =>  p_context_id
  , p_action_information_category =>  'FR_SOE_EE_BALANCES'
  , p_action_information4         =>  to_char(l_balance_value1)
  , p_action_information5         =>  to_char(l_balance_value2)
  , p_action_information6         =>  to_char(l_balance_value3)
  , p_action_information7         =>  to_char(l_balance_value4)
  , p_action_information8         =>  to_char(l_balance_value5)
  , p_action_information9         =>  to_char(l_balance_value6)
  , p_action_information10        =>  to_char(l_balance_value7)
  , p_action_information11        =>  to_char(l_balance_value8)
  , p_action_information12        =>  to_char(l_balance_value9)
  , p_action_information13        =>  to_char(l_balance_value10)
  , p_action_information14        =>  to_char(l_balance_value11));
  --
  -- BALANCE 12 taxable income
  -- This is an exception, it is stored as a totals value as it appears within
  -- the deductions block against totals text, and is a PTD dimension
  --
  l_balance_value12 := pay_balance_pkg.get_value (
                       p_defined_balance_id           => g_12taxable_income_db
                      ,p_assignment_action_id         => p_assignment_action_id);
  hr_utility.set_location('Balance 12 is ' || to_char(l_balance_value12), 120);
  hr_utility.set_location('Balance 12 db ' || to_char(g_12taxable_income_db), 121);
  --
  -- Set out variables
  --
  p_totals_taxable_income  :=  l_balance_value12;
  --
  hr_utility.set_location(' Leaving ' || l_proc, 150);
  --
end load_balances;
-------------------------------------------------------------------------------
-- LOAD_HOLIDAYS
-- DESCRIPTION : Calls pay_fr_pto_pkg function to load a pl/sql table
--               with results for archiving,
--               Then fetches from the table
-------------------------------------------------------------------------------
procedure load_holidays(
          p_assignment_id            in number
         ,p_person_id                in number
         ,p_effective_date           in date
         ,p_assignment_action_id     in number
         ,p_establishment_id         in number
         ,p_business_Group_id        in number) is
--
l_action_info_id    number (15);
l_ovn               number (15);
l_archive_type      varchar2(3)  := 'AAP';
--
l_proc VARCHAR2(40):= g_package||' Load Holidays ';
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  --
  -- Get the holiday values
  --
  pay_fr_pto_pkg.load_fr_payslip_accrual_data
    (p_business_group_id              => p_business_Group_id
    ,p_date_earned                    => p_effective_date
    ,p_assignment_id                  => p_assignment_id );
  --
  hr_utility.set_location('Step ' || l_proc, 20);
  --
  -- Loop through each record to fetch and archive
  --
  BEGIN
    FOR i in 1 .. pay_fr_pto_pkg.g_fr_payslip_info.LAST LOOP
    hr_utility.set_location('I loop is ' || l_proc, i);
      pay_action_information_api.create_action_information (
        p_action_information_id       =>  l_action_info_id
      , p_action_context_id           =>  p_assignment_action_id
      , p_action_context_type         =>  l_archive_type
      , p_object_version_number       =>  l_ovn
      , p_tax_unit_id                 =>  p_establishment_id
      , p_action_information_category =>  'FR_SOE_EE_HOLIDAYS'
      , p_action_information4         =>  to_char(pay_fr_pto_pkg.g_fr_payslip_info(i).entitlement)
      , p_action_information5         =>  to_char(pay_fr_pto_pkg.g_fr_payslip_info(i).accrual)
      , p_action_information6         =>  to_char(pay_fr_pto_pkg.g_fr_payslip_info(i).taken)
      , p_action_information7         =>  to_char(pay_fr_pto_pkg.g_fr_payslip_info(i).balance)
      , p_action_information8         =>  pay_fr_pto_pkg.g_fr_payslip_info(i).plan_name
      );
    END LOOP;
  EXCEPTION
    when others then null;
  END;
   --
    hr_utility.set_location('Leaving ' || l_proc, 100);
end load_holidays;
-------------------------------------------------------------------------------
-- LOAD_BANK
-- DESCRIPTION : fetches and archives all prepayments to be shown on payslip.
--               includes bank details, and determines if another soe archive
--               action is also locking it, in which case the value is
--               'previously notified'
-------------------------------------------------------------------------------
procedure load_bank(
          p_assignment_action_id     in number
         ,p_assignment_id            in number
         ,p_totals_previous_advice   out nocopy number
         ,p_totals_this_advice       out nocopy number
         ,p_totals_net_advice        out nocopy number
         ,p_establishment_id         in number
         ,p_asat_date                in date) is
  --
  cursor csr_bank_details(p_archive_action_id number) is
  select pppmf.external_account_id                        external_account_id
        ,ppp.pre_payment_id                                    pre_payment_id
        ,opmtl.org_payment_method_name                         payment_method
        ,ppp.value                                                     amount
        ,count(decode(all_arc_lock.locking_action_id
                     ,this_arc_lock.locking_action_id,null
                     ,all_arc_lock.locking_action_id))           num_previous
   from   pay_action_interlocks           this_arc_lock
         ,pay_action_interlocks           all_arc_lock
         ,pay_assignment_actions          arc_assact
         ,pay_payroll_actions             arc_payact
         ,pay_pre_payments                ppp
         ,pay_personal_payment_methods_f  pppmf
         ,pay_org_payment_methods_f_tl    opmtl
   where this_arc_lock.locking_action_id     = p_archive_action_id
     and all_arc_lock.locked_action_id       = this_arc_lock.locked_action_id
     and arc_assact.assignment_action_id     = all_arc_lock.locking_action_id
     and arc_payact.payroll_action_id        = arc_assact.payroll_action_id
     and arc_payact.action_type              = 'X'
     and arc_payact.report_qualifier         = 'FR'
     and arc_payact.report_category          = 'SOE_ARCHIVE'
     and arc_payact.report_type              = 'SOE_ARCHIVE'
     and this_arc_lock.locked_action_id      = ppp.assignment_action_id
     and ppp.value                          <> 0
     and opmtl.org_payment_method_id         = ppp.org_payment_method_id
     and opmtl.language                      = userenv('LANG')
     and pppmf.personal_payment_method_id(+) = ppp.personal_payment_method_id
     and p_asat_date                   between pppmf.effective_start_date(+)
                                           and pppmf.effective_end_date(+)
   group by opmtl.org_payment_method_name, ppp.value, ppp.pre_payment_id,
            pppmf.external_account_id
   order by opmtl.org_payment_method_name, ppp.value;

  cursor csr_bank(p_account_id number) is
  select   bank.meaning                     bank_name
          ,substr(pxa.segment2, 1, 5)       bank_code
          ,substr(pxa.segment3, 1, 5)       branch_code
          ,substr(pxa.segment5, 1, 14)      account_number
  from     pay_external_accounts             pxa
          ,hr_lookups                        bank
  where    bank.lookup_type(+) = 'FR_BANK'
    and    bank.lookup_code(+) = pxa.segment1
    and    pxa.external_account_id = p_account_id;
  --
  l_proc             VARCHAR2(60):= g_package||' Load Bank ';
  l_already_notified number(15,2) := 0.00;
  l_running_total    number(15,2) := 0.00;
  l_net_deposit      number(15,2) := 0.00;
  l_loop_counter     smallint     := 0;
  rec_bank           csr_bank_details%ROWTYPE;
  rec_acct           csr_bank%ROWTYPE;
  l_action_info_id   number (15);
  l_ovn              number (15);
  l_archive_type     varchar2(3)  := 'AAP';
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  --
  open csr_bank_details(p_assignment_action_id);
  LOOP
    fetch csr_bank_details INTO rec_bank;
    EXIT WHEN csr_bank_details%NOTFOUND;
    l_loop_counter := l_loop_counter + 1;
    --
    rec_acct.bank_name := null;
    rec_acct.bank_code := null;
    rec_acct.branch_code := null;
    rec_acct.account_number := null;
    if rec_bank.external_account_id is not null then
      open csr_bank(rec_bank.external_account_id);
      fetch csr_bank into rec_acct;
      close csr_bank;
    end if;
    pay_action_information_api.create_action_information (
       p_action_information_id       => l_action_info_id
      ,p_action_context_id           => p_assignment_action_id
      ,p_action_context_type         => l_archive_type
      ,p_object_version_number       => l_ovn
      ,p_tax_unit_id                 => p_establishment_id
      ,p_action_information_category => 'FR_SOE_EE_BANK_DEPOSIT'
      ,p_action_information1         => to_char(l_loop_counter) /* to sort by*/
      ,p_action_information4         => rec_bank.payment_method
      ,p_action_information5         => rec_acct.bank_name
      ,p_action_information6         => rec_acct.bank_code
      ,p_action_information7         => rec_acct.branch_code
      ,p_action_information8         => rec_acct.account_number
      ,p_action_information9         => to_char(rec_bank.amount));
    --
    l_running_total := l_running_total + rec_bank.amount;
    if rec_bank.num_previous > 0 then
      l_already_notified := l_already_notified + rec_bank.amount;
    end if;
  END LOOP;
  close csr_bank_details;
  l_net_deposit := l_running_total - l_already_notified;
  hr_utility.set_location('Step ' || l_proc, 50);
  --
  -- Set out variables
  --
  p_totals_previous_advice   := l_already_notified;
  p_totals_this_advice       := l_running_total;
  p_totals_net_advice        := l_net_deposit;
  --
  hr_utility.set_location('Leaving ' || l_proc, 100);
END load_bank;
-------------------------------------------------------------------------------
-- LOAD_MESSAGES
-- DESCRIPTION : fetches and archives all the payroll action messages locked
--               by this action, in order. eg 'Happy new Year'.
--               also constructs the termination date and reason message line.
-------------------------------------------------------------------------------
procedure load_messages(
          p_archive_assignment_action_id     in number
         ,p_establishment_id                 in number
         ,p_term_atd                         in date
         ,p_term_reason                      in varchar2) is
  --
  -- Select all the messages from pay_payroll_actions.pay_advice_message
  -- for runs that are locked by this archive assignment action id
  -- archiving per assignment allows for future expansion of assignment level
  -- messages
  --
  -- nb messages restricted to 150, as that size in FND_COLUMNS.
  --

  cursor csr_message_details(p_archive_assignment_action_id number) is
    select substrb(run_payact.pay_advice_message, 1, 240)    message
    from   pay_payroll_actions              pre_payact
          ,pay_assignment_actions           pre_assact
          ,pay_payroll_actions              run_payact
          ,pay_assignment_actions           run_assact
          ,pay_action_interlocks            arc_lock
          ,pay_action_interlocks            pre_lock
    where
          arc_lock.locking_action_id      = p_archive_assignment_action_id
      and arc_lock.locked_action_id       = pre_assact.assignment_action_id
      and pre_lock.locking_action_id      = pre_assact.assignment_action_id
      and pre_lock.locked_action_id       = run_assact.assignment_action_id
      and pre_payact.payroll_action_id    = pre_assact.payroll_action_id
      and run_payact.payroll_action_id    = run_assact.payroll_action_id
      and run_payact.action_type          in ('Q', 'R')
      and pre_payact.action_type          in ('P', 'U')
      and run_payact.pay_advice_message   is not null
    order by run_payact.action_sequence;
  --
  l_proc VARCHAR2(60)     := g_package||' Load Messages ';
  l_message                  fnd_new_messages.message_text%TYPE;
  l_loop_counter smallint := 0;
  l_action_info_id    number (15);
  l_ovn               number (15);
  l_archive_type      varchar2(3)  := 'AAP';
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  open csr_message_details(p_archive_assignment_action_id);
  LOOP
    fetch csr_message_details INTO l_message;
    EXIT WHEN csr_message_details%NOTFOUND;
    l_loop_counter := l_loop_counter + 1;
    --
    -- Archive the Message Details
    --
  pay_action_information_api.create_action_information (
    p_action_information_id       =>  l_action_info_id
  , p_action_context_id           =>  p_archive_assignment_action_id
  , p_action_context_type         =>  l_archive_type
  , p_object_version_number       =>  l_ovn
  , p_tax_unit_id                 =>  p_establishment_id
  , p_action_information_category =>  'FR_SOE_EE_MESSAGES'
  , p_action_information1         =>   to_char(l_loop_counter)
  , p_action_information4         =>  substrb(l_message, 1, 150));
  --
  END LOOP;
  --
  -- Construct the termination message
  --
  hr_utility.set_location('Step ' || l_proc, 50);
  if p_term_atd is not null then
    fnd_message.set_name('PAY', 'PAY_75057_SOE_TERM_DATA');
    fnd_message.set_token('TERM_DATE', fnd_date.date_to_displaydate(p_term_atd));
    fnd_message.set_token('TERM_REASON',p_term_reason);
    l_message := hr_utility.get_message;
    l_message := substrb(l_message, 1, 240);
    --
    -- archive the termination message
    --
  hr_utility.set_location('Step ' || l_proc, 55);
    pay_action_information_api.create_action_information (
      p_action_information_id       =>  l_action_info_id
     ,p_action_context_id           =>  p_archive_assignment_action_id
     ,p_action_context_type         =>  l_archive_type
     ,p_object_version_number       =>  l_ovn
     ,p_tax_unit_id                 =>  p_establishment_id
     ,p_action_information_category =>  'FR_SOE_EE_MESSAGES'
     ,p_action_information1         =>  to_char(l_loop_counter+1)
     ,p_action_information4         =>  substrb(l_message, 1, 150));
  end if;
  --
  hr_utility.set_location('Leaving ' || l_proc, 100);
  close csr_message_details;
END load_messages;
---------------------------------------------------------------------------------------------------
-- LOAD_EE_RATE_GROUPED_RUNS                                    EARNINGS and NET PAYMENTS
-- DESCRIPTION : loads all element data that is only grouped to consolidate several runs into one
--               payslip.
--               Court Orders is included here, with manual summing within a rubric, to save a cursor.
--               Usually there will be one rubric for all COs, but if the user sets up more than 1
--               it will handle this.
--               Benefits is a special case, the values must be reported separately.
---------------------------------------------------------------------------------------------------
procedure load_ee_rate_grouped_runs(
          p_archive_assignment_action_id   in number
         ,p_assignment_id                  in number
         ,p_latest_process_type            in varchar2
         ,p_total_gross_pay                out nocopy number
         ,p_reductions                     out nocopy number
         ,p_net_payments                   out nocopy number
         ,p_court_orders                   out nocopy number
         ,p_establishment_id               in number
         ,p_effective_date                 in date
         ,p_termination_reason             in varchar2
         ,p_term_st_ele_id                 in number
         ,p_term_ex_ele_id                 in number) is
  --
  -- Select all the entries in parameterized element classifications for this assignment
  -- action.
  -- All entries are fetched separately.
  --
  cursor csr_get_ee_rate_grouped
           (p_ee_class1 varchar2, p_ee_class2 varchar2
           ,p_ee_class3 varchar2, p_ee_class4 varchar2
           ,p_ee_class5 varchar2, p_ee_class6 varchar2
           ,p_archive_assignment_action_id number
           ,p_us_base_name varchar2      ,p_fr_base_name varchar2
           ,p_us_rate_name varchar2      ,p_fr_rate_name varchar2
           ,p_us_pay_value_name varchar2 ,p_fr_pay_value_name varchar2
           ,p_us_start_name varchar2     ,p_fr_start_name varchar2
           ,p_us_end_name varchar2       ,p_fr_end_name varchar2
           ,p_retro_tl varchar2) is
  select result_rollup.rubric_code                Rubric
        ,result_rollup.description           Description
        ,result_rollup.classification_name         Class
        ,result_rollup.element_information1   Group_Code
        ,result_rollup.element_type_id           Element
        ,result_rollup.process_type              Process
        ,sum(base_value)                            Base
        ,rate_value                                 Rate
        ,sum(pay_value)                           Amount
        ,base_units_meaning                   base_units
        ,week_end_date                     week_end_date
        ,factor                                   factor
        ,label                                     label
        ,absattid                  absence_attendance_id
        ,decode(classification_name, 'Benefits', run_result_id, 0) distinct_ben
        ,decode(classification_name, 'Earnings Adjustment', -1, 1) adjust_sign
        /* get the correct dates for non-retro - input value names or proration dates if they exist */
        ,nvl(result_rollup.start_date, fnd_date.date_to_canonical(result_rollup.prorate_start_date))   std_start_date
        ,nvl(result_rollup.end_date, fnd_date.date_to_canonical(result_rollup.prorate_end_date))   std_end_Date
        /* get the correct dates for retro - retro proration dates or original period */
	,decode(creator_type,'EE', nvl(result_rollup.retro_pro_start, ptp.start_date), 'RR', nvl(result_rollup.retro_pro_start, ptp.start_date)) retro_pro_start
	,decode(creator_type,'EE', nvl(result_rollup.retro_pro_end,   ptp.end_date)  , 'RR', nvl(result_rollup.retro_pro_end,   ptp.end_date))   retro_pro_end
	,creator_type
  from (
    select
      pee.creator_type creator_type,
      max(decode(piv.name,p_fr_start_name,prrv.result_value,
                          p_us_start_name,prrv.result_value)) start_date,
      max(decode(piv.name,p_fr_end_name,prrv.result_value,
                          p_us_end_name,prrv.result_value)) end_date,
      decode(pee.creator_type,
             'RR',rr_ret.assignment_action_id,
             'EE',pee.source_asg_action_id)                         retro_act_id,
      nvl(user_rubric.tag,seed_rubric.tag)                         rubric_code,
      nvl(user_rubric.meaning,seed_rubric.meaning)
        || decode(pee.creator_type,'EE',' '|| p_retro_tl,
                                   'RR',' '|| p_retro_tl)          description,
      pec.classification_name,
      pet.element_information1,
      pet.element_type_id,
      max(decode(piv.name,'Process_Type',prrv.result_value)) process_type,
      max(decode(piv.name,p_fr_base_name,prrv.result_value,
                          p_us_base_name,prrv.result_value)) base_value,
      max(decode(piv.name,p_fr_rate_name,prrv.result_value,
                          p_us_rate_name,prrv.result_value)) rate_value,
      max(decode(piv.name,p_fr_pay_value_name,prrv.result_value,
                          p_us_pay_value_name,prrv.result_value)) pay_value,
      base_units.meaning base_units_meaning,
      max(decode(piv.name,'Week End Date',prrv.result_value)) week_end_date,
      max(decode(piv.name,'Overtime Factor',prrv.result_value)) factor,
      max(decode(piv.name,'Label',prrv.result_value)) label,
      max(decode(piv.name,'Absence Attendance ID',prrv.result_value)) absattid,
      prrv.run_result_id,
      prr.start_date prorate_start_date,
      prr.end_date prorate_end_date,
      decode(pee.creator_type,
            'EE',pee.source_start_date,
            'RR',rr_ret.start_date) retro_pro_start,
      decode(pee.creator_type,
            'EE',pee.source_end_date,
            'RR',rr_ret.end_date) retro_pro_end
    from   pay_run_result_values       prrv
          ,pay_run_results             prr
          ,pay_element_types_f         pet
          ,pay_element_classifications pec
          ,pay_input_values_f_tl       piv
          ,fnd_lookup_values           user_rubric
          ,fnd_lookup_values           seed_rubric
          ,fnd_lookup_values           base_units
          ,pay_payroll_actions         pre_payact
          ,pay_assignment_actions      pre_assact
          ,pay_payroll_actions         run_payact
          ,pay_assignment_actions      run_assact
          ,pay_action_interlocks       arc_lock
          ,pay_action_interlocks       pre_lock
          ,pay_element_entries_f       pee
	  ,pay_run_results             rr_ret
    where pee.element_entry_id(+)    = prr.source_id
    and   rr_ret.run_result_id(+)    = pee.source_id
    and   prrv.run_result_id         = prr.run_result_id
    and   prr.element_type_id        = pet.element_type_id
    and   prr.element_type_id        = pet.element_type_id
    and   p_effective_date     between pet.effective_start_date
                                   and pet.effective_end_date
    and   pet.classification_id      = pec.classification_id
    and   pec.classification_name in (p_ee_class1,p_ee_class2
                                     ,p_ee_class3,p_ee_class4
                                     ,p_ee_class5,p_ee_class6)
    and   piv.input_value_id         = prrv.input_value_id
    and   piv.language               = userenv('lang')
    and   piv.name in  (p_us_pay_value_name, p_fr_pay_value_name
                       ,p_us_base_name, p_fr_base_name
                       ,p_us_rate_name, p_fr_rate_name
                       ,p_us_start_name, p_fr_start_name
                       ,p_us_end_name, p_fr_end_name
                       ,'Overtime Factor','Label'
                       ,'Process_Type','Absence Attendance ID', 'Week End Date')
    and   prr.assignment_action_id     = run_assact.assignment_action_id
    and   arc_lock.locking_action_id   = p_archive_assignment_action_id
    and   arc_lock.locked_action_id    = pre_assact.assignment_action_id
    and   pre_lock.locking_action_id   = pre_assact.assignment_action_id
    and   pre_lock.locked_action_id    = run_assact.assignment_action_id
    and   pre_payact.payroll_action_id = pre_assact.payroll_action_id
    and   run_payact.payroll_action_id = run_assact.payroll_action_id
    and   run_payact.action_type      in ('Q', 'R')
    and   pre_payact.action_type      in ('P', 'U')
    and   user_rubric.lookup_code(+)   = pet.element_information1
    and   user_rubric.lookup_type(+)   = 'FR_USER_ELEMENT_GROUP'
    and   user_rubric.LANGUAGE(+)      = USERENV('LANG')
    and   user_rubric.security_group_id(+) = g_sec_grp_id_user_element_grp
    and   user_rubric.VIEW_APPLICATION_ID(+) = 3
    and   seed_rubric.lookup_code(+)   = pet.element_information1
    and   seed_rubric.lookup_type(+)   = 'FR_ELEMENT_GROUP'
    and   seed_rubric.LANGUAGE(+)      = USERENV('LANG')
    and   seed_rubric.security_group_id(+) = g_sec_grp_id_element_grp
    and   seed_rubric.VIEW_APPLICATION_ID(+) = 3
    and   base_units.lookup_type(+)    = 'FR_BASE_UNIT'
    and   base_units.lookup_code(+)    = pet.element_information2
    and   base_units.LANGUAGE(+)       = USERENV('LANG') /*bug 3683906*/
    and   base_units.security_group_id(+) = g_sec_grp_id_base_unit
    and   base_units.VIEW_APPLICATION_ID(+) = 3
    and   prrv.result_value is not null
    group by nvl(user_rubric.tag,seed_rubric.tag),
          nvl(user_rubric.meaning,seed_rubric.meaning) || decode(pee.creator_type,'EE',' '|| p_retro_tl,'RR',' '|| p_retro_tl),
          pec.classification_name,
          pet.element_information1,
          pet.element_type_id,
          base_units.meaning,
          prrv.run_result_id,
          prr.start_date,
          prr.end_date,
          decode(pee.creator_type,
                'RR',rr_ret.assignment_action_id,
                'EE',pee.source_asg_action_id),
          pee.creator_type,
          decode(pee.creator_type,
            'EE',pee.source_start_date,
            'RR',rr_ret.start_date),
          decode(pee.creator_type,
            'EE',pee.source_end_date,
            'RR',rr_ret.end_date)
    ) result_rollup
    ,pay_assignment_actions paa
    ,pay_payroll_actions    ppa
    ,per_time_periods       ptp
  where  paa.assignment_action_id (+) = result_rollup.retro_act_id
    and   ppa.payroll_action_id   (+) = paa.payroll_action_id
    and   ptp.time_period_id      (+) = ppa.time_period_id
  group by result_rollup.start_date
        ,result_rollup.end_date
        ,result_rollup.rubric_code
        ,result_rollup.description
        ,result_rollup.classification_name
        ,result_rollup.element_information1
        ,result_rollup.element_type_id
        ,result_rollup.process_type
        ,result_rollup.rate_value
        ,result_rollup.base_units_meaning
        ,result_rollup.week_end_date
        ,result_rollup.factor
        ,result_rollup.label
        ,result_rollup.absattid
        ,decode(classification_name, 'Benefits', run_result_id, 0)
        ,decode(classification_name, 'Earnings Adjustment', -1, 1)
        ,result_rollup.prorate_start_date
        ,result_rollup.prorate_end_date
        ,result_rollup.creator_type
        ,decode(creator_type,'EE', nvl(result_rollup.retro_pro_start, ptp.start_date), 'RR', nvl(result_rollup.retro_pro_start, ptp.start_date))
	,decode(creator_type,'EE', nvl(result_rollup.retro_pro_end,   ptp.end_date)  , 'RR', nvl(result_rollup.retro_pro_end,   ptp.end_date))
        ,nvl(result_rollup.start_date, fnd_date.date_to_canonical(result_rollup.prorate_start_date))
        ,nvl(result_rollup.end_date, fnd_date.date_to_canonical(result_rollup.prorate_end_date))
 order by decode(absattid,null,null,result_rollup.start_date)
           ,rubric_code
	   ,result_rollup.description desc
           ,week_end_date
           ,label
           ,decode(creator_type,'EE', nvl(result_rollup.retro_pro_start, ptp.start_date), 'RR', nvl(result_rollup.retro_pro_start, ptp.start_date))
	   ,decode(creator_type,'EE',2, 'RR',1,3)
           ,process_type
       	   ,sum(base_value);

  cursor csr_process_meaning (p_process_type varchar2) is
   select upper(meaning)
   from   fnd_lookup_values
   where  lookup_type         = 'FR_PROCESS_TYPE'
   and    view_application_id = 3
   and    lookup_code         = p_process_type
   and    security_group_id   = g_sec_grp_id_process_type
   and    language            = userenv('LANG');
  --
  rec_results   csr_get_ee_rate_grouped%ROWTYPE;
  l_proc VARCHAR2(60):= g_package||' load_ee_rate_grouped_runs ';
  l_ee_classification1 varchar2(60);
  l_ee_classification2 varchar2(60);
  l_ee_classification3 varchar2(60);
  l_ee_classification4 varchar2(60);
  l_ee_classification5 varchar2(60);
  l_ee_classification6 varchar2(60);
  --
  l_context_prefix    varchar2(30);
  l_context           varchar2(30)  := 'FR_SOE_ELEMENTS';
  l_loop              smallint;
  --
  -- Archiver local variables
  l_action_info_id    number (15);
  l_ovn               number (15);
  l_archive_type      varchar2(3)  := 'AAP';
  --
  l_total_gross_pay         number(15,2) := 0.00;
  l_total_subject           number(15,2) := 0.00;
  l_total_net_payments      number(15,2) := 0.00;
  l_total_court_orders      number(15,2) := 0.00;
  l_total_loop_court_orders number(15,2) := 0.00;
  l_total_reductions        number(15,2) := 0.00;
  l_loop_counter            smallint;
  l_previous_rubric         varchar2(10);
  l_previous_process        varchar2(20);
  l_this_process_type       varchar2(80);
  l_base_units              varchar2(80);
  l_description             varchar2(200);
  l_previous_description    varchar2(200);
  l_previous_class          varchar2(20);
  l_previous_base           number(15,2);
  l_sign_adjust_amount      number(15,2);
  l_ee_context_order        smallint;     /* context order for ee values in rubric/process/base */
  l_append_dates            varchar2(150); /* temp area for for constructing dd-mm - dd-mm */
  l_debug                   number;
  --
  l_previous_absence_id     number;
  l_previous_pto_rubric     number;
  l_substitute_rubric       varchar2(30);
  l_printed_start_date      varchar2(60);
  l_printed_end_date        varchar2(60);
  --
  -----------------------------------------------------------------------------------------
  -- BEGIN LOAD_EE_RATE_GROUPED_RUNS
  -----------------------------------------------------------------------------------------
BEGIN

  hr_utility.set_location('Entering ' || l_proc, 5);
  for l_loop in 1..4 LOOP
    hr_utility.set_location('Major Loop ='||to_char(l_loop), 9);
    l_loop_counter := 0;
    l_ee_context_order := 0;
    l_previous_rubric  := ' ';
    l_previous_process := ' ';
    l_previous_base    := -1;
    l_previous_class   := ' ';
    l_previous_description := ' ';
    --
    if l_loop = 1 THEN
      l_ee_classification1 := 'Earnings';
      l_ee_classification2 := 'Supplementary Earnings';
      l_ee_classification3 := 'Overtime';
      l_ee_classification4 := 'Earnings Adjustment';
      l_ee_classification5 := 'Payment for Absence';
      l_ee_classification6 := 'Benefits';
      l_context_prefix    := 'EARNINGS';
    elsif l_loop = 2 THEN
      l_ee_classification1 := 'Reductions';
      l_ee_classification2 :=  null;
      l_ee_classification3 :=  null;
      l_ee_classification4 :=  null;
      l_ee_classification5 :=  null;
      l_ee_classification6 :=  null;
      l_context_prefix    := 'EARNINGS_REDUCTIONS';
    elsif l_loop = 3 THEN
      l_ee_classification1 := 'Net Payments';
      l_ee_classification2 :=  null;
      l_ee_classification3 :=  null;
      l_ee_classification4 :=  null;
      l_ee_classification5 :=  null;
      l_ee_classification6 :=  null;
      l_context_prefix    := 'NET_PAYMENTS';
    elsif l_loop = 4 THEN
      l_ee_classification1 := 'Court Orders';
      l_ee_classification2 :=  null;
      l_ee_classification3 :=  null;
      l_ee_classification4 :=  null;
      l_ee_classification5 :=  null;
      l_ee_classification6 :=  null;
      l_context_prefix    := 'NET_PAYMENTS';
    end if;
    open csr_get_ee_rate_grouped(l_ee_classification1, l_ee_classification2
                                ,l_ee_classification3, l_ee_classification4
                                ,l_ee_classification5, l_ee_classification6
                                ,p_archive_assignment_action_id
                                ,g_us_name_base,      g_fr_name_base
                                ,g_us_name_rate,      g_fr_name_rate
                                ,g_us_name_pay_value, g_fr_name_pay_value
                                ,g_us_name_start_date,g_fr_name_start_date
                                ,g_fr_name_end_date,  g_fr_name_end_date
                                ,g_retro_tl);
    LOOP
      fetch csr_get_ee_rate_grouped INTO rec_results;
      EXIT WHEN csr_get_ee_rate_grouped%NOTFOUND;
      l_loop_counter := l_loop_counter + 1;
      l_append_dates := null;
      l_this_process_type := null;
      l_substitute_rubric := null;

      rec_results.amount  := nvl(rec_results.amount, 0) * rec_results.adjust_sign;
      if rec_results.base is not null then
        rec_results.base    := rec_results.base * rec_results.adjust_sign;
      end if;
      --
      l_ee_context_order := l_ee_context_order + 1; /* each is on a new line */
      --
      -- use local variable l_description as may need to append to it for overtime.
      --
      l_description := substrb(rec_results.description, 1, 200);
      --
      -- Adjust the start and end dates to be 'dd-mm - dd-mm'
      --
      begin
        if rec_results.creator_type = 'EE' or rec_results.creator_type = 'RR' THEN
          l_printed_start_date := fnd_date.date_to_canonical(rec_results.retro_pro_start);
          l_printed_end_date   := fnd_date.date_to_canonical(rec_results.retro_pro_end);
        else
          l_printed_start_date := rec_results.std_start_date;
          l_printed_end_date   := rec_results.std_end_date;
        end if;

        if l_printed_start_date is not null and l_loop <> 4 and rec_results.class <> 'Overtime' THEN
          l_append_dates := to_char(fnd_date.canonical_to_date(l_printed_start_date), ' dd-mm');
        end if;
        if l_printed_end_date is not null and l_loop <> 4 and rec_results.class <> 'Overtime' THEN
          l_append_dates := l_append_dates || to_char(fnd_date.canonical_to_date(l_printed_end_date), ' - dd-mm');
        end if;
      exception
        when others then null;   /* fnd date may raise error */
      end;
      --
      -- Special procesing for overtime.
      --
      if rec_results.class = 'Overtime' THEN
        begin
          -- Adjust the rubric description to be Label @ factor eg 'overtime @ 125%'
          l_description := substrb(trim(rec_results.label || ' @ ' || rec_results.factor) || '%'   , 1, 200);
          if rec_results.creator_type = 'EE' or rec_results.creator_type = 'RR' THEN
            l_description := substrb(l_description || ' '|| g_retro_tl, 1, 200);
          end if;
          --
          -- Adjust the overtime date to be displayable
          if rec_results.week_end_date is not null THEN
            l_append_dates := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(rec_results.week_end_date));
          end if;
        exception
          when others then null;   /* fnd date may raise error */
        end;
      end if;
      --
      -- Special processing for termination
      --
      if p_termination_reason is not null and rec_results.class = 'Earnings'
         and (rec_results.element = nvl(p_term_st_ele_id,-1)
              or
              rec_results.element = nvl(p_term_ex_ele_id,-1)
             ) THEN
        --
        -- Prefix the termination reason to the rubric
        --
        --hr_utility.trace('reason ' || p_termination_reason);
        --hr_utility.trace('descr  ' || l_description);
        l_description := substrb(p_termination_reason || '-' || l_description, 1, 200);
      End If;
      --
      -- Only store the base units if the base is not null and not zero
      --
      if nvl(rec_results.base, 0) = 0 then
        l_base_units := null;
      else
        l_base_units := rec_results.base_units;
      end if;
      --
      -- Arcvive Process Type, only if it's not the latest process type from the latest run in this set
      -- do not archive if in the net pay section
      --
      if p_latest_process_type <> rec_results.process and l_loop <= 2 and rec_results.process is not null THEN
        BEGIN
          open csr_process_meaning(rec_results.process);
          fetch csr_process_meaning into l_this_process_type;
          close csr_process_meaning;
        EXCEPTION
          when others then null;
        END;
      else
        l_this_process_type := null;
      end if;
      If rec_results.class = 'Earnings Adjustment' and rec_results.absence_attendance_id is not null then
        --
        -- Store these values incase the next fetch is the corresponding payment
        --
        l_previous_absence_id := rec_results.absence_attendance_id;
        l_previous_pto_rubric := rec_results.rubric;
      ELSIF rec_results.class = 'Payment for Absence' and rec_results.absence_attendance_id is not null
                                AND nvl(l_previous_absence_id,-1) = rec_results.absence_attendance_id THEN
        --
        -- Store this payment with the deduction rubric values
        --
        l_substitute_rubric := l_previous_pto_rubric;
      END IF;
      --
      -- Arcvive ee values
      -- only archive the pay_value and rubric and description for court orders
      -- and sum the pay_values until the end of fetch or a new rubric is fetched.
      --
      hr_utility.set_location('context='||l_context_prefix, 30);
      if l_loop <> 4 and rec_results.amount <> 0 then
        pay_action_information_api.create_action_information (
          p_action_information_id       =>  l_action_info_id
        , p_action_context_id           =>  p_archive_assignment_action_id
        , p_action_context_type         =>  l_archive_type
        , p_object_version_number       =>  l_ovn
        , p_tax_unit_id                 =>  p_establishment_id
        , p_action_information_category =>  l_context             /* FR_SOE_ELEMENTS  */
        , p_action_information1         =>  l_context_prefix      /* EARNINGS...      */
        , p_action_information2         =>  nvl(l_substitute_rubric, rec_results.rubric)
        , p_action_information3         =>  l_ee_context_order
        , p_action_information4         =>  rec_results.rubric
        , p_action_information5         =>  l_description
        , p_action_information6         =>  l_append_dates
        , p_action_information7         =>  l_this_process_type
        , p_action_information8         =>  l_base_units
        , p_action_information9         =>  rec_results.base
        , p_action_information10        =>  rec_results.rate
        , p_action_information11        =>  rec_results.amount);
        --
      end if;
      --
      -- If the previous fetch was a court order, and this is a new rubric,
      -- and it's not the first court order fetch, then archive the old CO values
      -- dont archive process type or dates, or base units
      --
      if l_loop = 4 and l_previous_rubric <> rec_results.rubric and l_previous_rubric <> ' '
                    and l_total_loop_court_orders <> 0 THEN
        pay_action_information_api.create_action_information (
          p_action_information_id       =>  l_action_info_id
        , p_action_context_id           =>  p_archive_assignment_action_id
        , p_action_context_type         =>  l_archive_type
        , p_object_version_number       =>  l_ovn
        , p_tax_unit_id                 =>  p_establishment_id
        , p_action_information_category =>  l_context             /* FR_SOE_ELEMENTS  */
        , p_action_information1         =>  l_context_prefix
        , p_action_information2         =>  l_previous_rubric
        , p_action_information3         =>  l_ee_context_order
        , p_action_information4         =>  l_previous_rubric
        , p_action_information5         =>  l_previous_description
        , p_action_information11        =>  l_total_loop_court_orders * -1); /* store as negative */
        --
        /* this court order rubric finished, clear down for next one; */
        l_total_loop_court_orders := 0;
    end if;
    --
    -- Maintain the running totals
    --
    if l_loop = 1 then                                       /* Earnings     */
       l_total_gross_pay    := l_total_gross_pay + rec_results.amount;
    elsif l_loop = 2 then                                    /* Reductions   */
       l_total_reductions   := l_total_reductions + rec_results.amount;
    elsif l_loop = 3 then                                    /* Net Payments */
       l_total_net_payments := l_total_net_payments + rec_results.amount;
    else                                                     /* Court Orders */
      l_total_court_orders      := l_total_court_orders + rec_results.amount;
      l_total_loop_court_orders :=  l_total_loop_court_orders + rec_results.amount;
      --
      -- bug 2683309 only record non-null rubrics, as cursor will fetch
      -- 'Court Orders' with null pay values and descriptions
      --
      l_previous_rubric         := nvl(rec_results.rubric, l_previous_rubric);
      l_previous_description    := nvl(l_description, l_previous_description);
      l_append_dates            := null;
    end if;
    --
    l_printed_start_date := null;
    l_printed_end_date := null;

    --
    END LOOP;                                                 /* cursor loop */
    hr_utility.set_location('End of Prefix Loop ' || l_proc, 90);
    --
    -- Write any CO fetched on the very last fetch of loop = 4
    --
    if l_loop = 4 and l_total_loop_court_orders <> 0 then
        pay_action_information_api.create_action_information (
          p_action_information_id       =>  l_action_info_id
        , p_action_context_id           =>  p_archive_assignment_action_id
        , p_action_context_type         =>  l_archive_type
        , p_object_version_number       =>  l_ovn
        , p_tax_unit_id                 =>  p_establishment_id
        , p_action_information_category =>  l_context             /* FR_SOE_ELEMENTS  */
        , p_action_information1         =>  l_context_prefix
        , p_action_information2         =>  l_previous_rubric
        , p_action_information3         =>  l_ee_context_order
        , p_action_information4         =>  l_previous_rubric
        , p_action_information5         =>  l_previous_description
        , p_action_information11        =>  l_total_loop_court_orders * -1 ); /* store as negative */
    --
    end if;
    close csr_get_ee_rate_grouped;
  END LOOP;                                         /* loop of statutory deductions */
  hr_utility.set_location('End of Major Loop ' || l_proc, 100);
  --
  -- pass out the totals needed in future calculations of totals
  --
  p_total_gross_pay  :=  nvl(l_total_gross_pay, 0);
  p_reductions       :=  nvl(l_total_reductions, 0);
  p_net_payments     :=  nvl(l_total_net_payments, 0);
  p_court_orders     :=  nvl(l_total_court_orders, 0);
  --
  hr_utility.set_location('Leaving ' || l_proc, 110);
END load_ee_rate_grouped_runs;
-------------------------------------------------------------------------------
-- LOAD_DEDUCTIONS1
-- DESCRIPTION :                                                            OLD
-------------------------------------------------------------------------------
procedure load_deductions1(
          p_archive_assignment_action_id in number
         ,p_assignment_id                in number
         ,p_latest_process_type          in varchar2
         ,p_total_deduct_ee              out nocopy number
         ,p_total_deduct_er              out nocopy number
         ,p_total_charge_ee              out nocopy number
         ,p_total_charge_er              out nocopy number
         ,p_establishment_id             in number
         ,p_effective_date               in date ) is
  --
BEGIN
  null;
END load_deductions1;
------------------------------------------------------------------------------
-- WRITE_ARCHIVE
-- DESCRIPTION : writes a new line to the archive only if an existing line to
--               update is not found.
------------------------------------------------------------------------------
procedure write_archive(
          p_action_context_id             in number
         ,p_action_context_type           in varchar2
         ,p_rubric                        in varchar2
         ,p_rubric_sort                   in number
         ,p_tax_unit_id                   in number
         ,p_context_prefix                in varchar2
         ,p_action_information_category   in varchar2
         ,p_action_information4           in varchar2 default null
         ,p_action_information5           in varchar2 default null
         ,p_action_information6           in varchar2 default null
         ,p_action_information7           in varchar2 default null
         ,p_action_information8           in varchar2 default null
         ,p_action_information9           in varchar2 default null
         ,p_action_information10          in varchar2 default null
         ,p_action_information11          in varchar2 default null
         ,p_action_information12          in varchar2 default null
         ,p_action_information13          in varchar2 default null ) is
  --
  cursor csr_find_row is
      select action_information_id, object_version_number
       from  pay_action_information
      where  action_context_id   = p_action_context_id
        and  action_context_type = p_action_context_type
        and  action_information_category = p_action_information_category
        and  action_information1 = p_context_prefix
        and  action_information2 = p_rubric
        and  action_information3 = to_char(p_rubric_sort);

  l_action_info_id  pay_action_information.action_information_id%TYPE;
  l_ovn             pay_action_information.object_version_number%TYPE;
  --
  l_proc VARCHAR2(60):= g_package||' Write Archive ';
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  open csr_find_row;
  fetch csr_find_row into l_action_info_id, l_ovn;
  if csr_find_row%NOTFOUND THEN
    pay_action_information_api.create_action_information (
      p_action_information_id       =>  l_action_info_id
    , p_action_context_id           =>  p_action_context_id
    , p_action_context_type         =>  p_action_context_type
    , p_action_information1         =>  p_context_prefix
    , p_action_information2         =>  p_rubric
    , p_action_information3         =>  to_char(p_rubric_sort)
    , p_tax_unit_id                 =>  p_tax_unit_id
    , p_object_version_number       =>  l_ovn
    , p_action_information_category =>  p_action_information_category
    , p_action_information4         =>  p_action_information4
    , p_action_information5         =>  p_action_information5
    , p_action_information6         =>  p_action_information6
    , p_action_information7         =>  p_action_information7
    , p_action_information8         =>  p_action_information8
    , p_action_information9         =>  p_action_information9
    , p_action_information10        =>  p_action_information10
    , p_action_information11        =>  p_action_information11
    , p_action_information12        =>  p_action_information12
    , p_action_information13        =>  p_action_information13);
  else
    pay_action_information_api.update_action_information (
      p_action_information_id       =>  l_action_info_id
--    , p_action_context_id           =>  p_action_context_id
--    , p_action_context_type         =>  p_action_context_type
    , p_object_version_number       =>  l_ovn
    , p_action_information1         =>  nvl(p_context_prefix, hr_api.g_varchar2)
    , p_action_information2         =>  nvl(p_rubric, hr_api.g_varchar2)
    , p_action_information3         =>  nvl(to_char(p_rubric_sort), hr_api.g_varchar2)
--    , p_tax_unit_id                 =>  p_tax_unit_id
--    , p_action_information_category =>  p_action_information_category
    , p_action_information4         =>  nvl(p_action_information4, hr_api.g_varchar2)
    , p_action_information5         =>  nvl(p_action_information5, hr_api.g_varchar2)
    , p_action_information6         =>  nvl(p_action_information6, hr_api.g_varchar2)
    , p_action_information7         =>  nvl(p_action_information7, hr_api.g_varchar2)
    , p_action_information8         =>  nvl(p_action_information8, hr_api.g_varchar2)
    , p_action_information9         =>  nvl(p_action_information9, hr_api.g_varchar2)
    , p_action_information10        =>  nvl(p_action_information10, hr_api.g_varchar2)
    , p_action_information11        =>  nvl(p_action_information11, hr_api.g_varchar2)
    , p_action_information12        =>  nvl(p_action_information12, hr_api.g_varchar2)
    , p_action_information13        =>  nvl(p_action_information13, hr_api.g_varchar2));
  end if;
  close csr_find_row;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  EXCEPTION
    WHEN OTHERS then
      raise;           /* error as no write to archive */
END write_archive;
------------------------------------------------------------------------------
-- LOAD_RATE_GROUPED_RUNS_RUNS
-- DESCRIPTION : fetches and archives elements grouped by rate.
--               these are net ee deductions and ER luncheon vouchers
------------------------------------------------------------------------------
procedure load_rate_grouped_runs(
          p_archive_assignment_action_id in number
         ,p_assignment_id                in number
         ,p_latest_process_type          in varchar2
         ,p_total_ee_net_deductions      out nocopy number
         ,p_establishment_id             in number
         ,p_total_gross_pay              in out nocopy number
         ,p_effective_date               in date ) is
  --
  -- csr_get_results
  -- Select all the entries in parameterized element classifications for this assignment
  -- action.
  -- This code will be designmed so that is can handle other classifcations that also need
  -- to be grouped.
  -- For Luncheon vourcers, we are expecting er to be an indirect of ee, but cannot enforce
  -- this. So source_id is ordered by, so that in the normal case grouped
  -- ee lines will appear with their equivalent grouped er lines.
  -- Check this for retropay entries.
  -- Modified for 3683906, commented out under bug 4778143
  -- l_sec_grp_id_user_ele_grp     number;
  -- l_sec_grp_id_base_unit        number;
  --
  cursor csr_get_results (p_ee_classification number , p_er_classification number
                         ,p_archive_assignment_action_id number
                         ,p_us_base_name varchar2      , p_fr_base_name varchar2
                         ,p_us_rate_name varchar2      , p_fr_rate_name varchar2
                         ,p_us_pay_value_name varchar2 , p_fr_pay_value_name varchar2) is
  select   class
        ,element_type_id                                 Element_type
        ,sum(fnd_number.canonical_to_number(base_value)) Base
        ,rate_value                                      Rate
        ,sum(fnd_number.canonical_to_number(pay_value))  Amount
        ,rubric                                          Rubric
        ,description                                     Description
        ,sum(source_id)                                  Source_id
        ,base_units
  from  (
select   prr.run_result_id
        ,decode(pet.classification_id
               ,p_ee_classification, 'EE', 'ER')                 Class
        ,pet.element_type_id                                    element_type_id
        ,max(decode(piv.name
                   ,p_fr_base_name,prrv.result_value
                   ,p_us_base_name,prrv.result_value))               Base_value
        ,max(decode(piv.name
                   ,p_fr_rate_name,prrv.result_value
                   ,p_us_rate_name,prrv.result_value))               Rate_value
        ,max(decode(piv.name
                   ,p_fr_pay_value_name,prrv.result_value
                   ,p_us_pay_value_name,prrv.result_value))           pay_value
        ,prr.source_id                                                Source_id
        ,nvl(user_rubric.tag,seed_rubric.tag)                            Rubric
        ,nvl(user_rubric.meaning,seed_rubric.meaning)               Description
        ,base_units.meaning                                          BASE_UNITS
  from   pay_element_types_f         pet
        ,pay_run_results             prr
        ,pay_input_values_f          piv
        ,pay_run_result_values       prrv
        ,fnd_lookup_values           user_rubric
        ,fnd_lookup_values           seed_rubric
        ,fnd_lookup_values           base_units
        ,pay_action_interlocks       arc_lock
        ,pay_action_interlocks       pre_lock
        ,pay_assignment_actions      run_assact
        ,pay_payroll_actions         run_payact
  where pet.classification_id in (p_ee_classification, p_er_classification)
    and (pet.legislation_code = 'FR' or pet.legislation_code is null)
    and pet.element_type_id   = prr.element_Type_id
    and p_effective_date between pet.effective_start_date
                             and pet.effective_end_date
    and prr.assignment_action_id  = run_assact.assignment_action_id
    and prrv.run_result_id         = prr.run_result_id
    and piv.element_type_id        = pet.element_Type_id
    and p_effective_date between piv.effective_start_date
                             and piv.effective_end_date
    and piv.input_value_id        = prrv.input_value_id
    and piv.name in  (p_us_pay_value_name, p_fr_pay_value_name
                     ,p_us_base_name, p_fr_base_name
                     ,p_us_rate_name, p_fr_rate_name)
    and arc_lock.locking_action_id      = p_archive_assignment_action_id
    and arc_lock.locked_action_id       = pre_lock.locking_action_id
    and pre_lock.locked_action_id       = run_assact.assignment_action_id
    and run_payact.payroll_action_id    = run_assact.payroll_action_id
    and run_payact.action_type          in ('Q', 'R')
    and user_rubric.lookup_code(+)   = pet.element_information1
    and user_rubric.lookup_type(+)   = 'FR_USER_ELEMENT_GROUP'
    and user_rubric.LANGUAGE(+)      = USERENV('LANG')
    and user_rubric.security_group_id(+) = g_sec_grp_id_user_element_grp
    and user_rubric.VIEW_APPLICATION_ID(+) = 3
    and seed_rubric.lookup_code(+)   = pet.element_information1
    and seed_rubric.lookup_type(+)   = 'FR_ELEMENT_GROUP'
    and seed_rubric.LANGUAGE(+)      = USERENV('LANG')
    and seed_rubric.security_group_id(+) = g_sec_grp_id_element_grp
    and seed_rubric.VIEW_APPLICATION_ID(+) = 3
    and base_units.lookup_code(+)   = pet.element_information2
    and base_units.lookup_type(+)   = 'FR_BASE_UNIT'
    and base_units.LANGUAGE(+)      = USERENV('LANG')
    and base_units.security_group_id(+) = g_sec_grp_id_base_unit
    and base_units.VIEW_APPLICATION_ID(+) = 3
  group by
         decode(pet.classification_id, p_ee_classification, 'EE', 'ER')
        ,pet.element_type_id
        ,prr.source_id
        ,nvl(user_rubric.tag,seed_rubric.tag)
        ,nvl(user_rubric.meaning,seed_rubric.meaning)
        ,base_units.meaning
        ,prr.run_result_id) result_rollup
  group by
        rubric
       ,description
       ,class
       ,element_type_id
       ,rate_value
       ,base_units
  order by rubric
          ,source_id;
  --
  --
  rec_results   csr_get_results%ROWTYPE;
  l_proc VARCHAR2(60):= g_package||' Load Rate Grouped ';
  --
  l_context_prefix          varchar2(30);
  l_context                 varchar2(30) := 'FR_SOE_ELEMENTS';
  l_total_ee_net_deductions number(15,2) := 0;
  l_previous_base           number(15,2);
  --
  l_loop_counter            smallint;
  l_previous_rubric         varchar2(10);
  l_ee_context_order        smallint;     /* context order for ee values in rubric/source */
  l_er_context_order        smallint;     /* context order for er values in rubric/source */
  l_archive_type      varchar2(3)  := 'AAP';
  --
  -----------------------------------------------------------------------------
  -- BEGIN LOAD_RATE_GROUPED_RUNS                   net payments, ER LV charges
  -----------------------------------------------------------------------------
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 5);
  -- Modified for bug 3683906, commented out under bug 4778143
  -- l_sec_grp_id_user_ele_grp := g_sec_grp_id_user_element_grp;
  -- l_sec_grp_id_base_unit := g_sec_grp_id_base_unit;
  --
  l_loop_counter := 0;
  l_ee_context_order := 0;
  l_er_context_order := 0;
  l_previous_rubric  := ' ';
  l_previous_base      := 0;
  --
  l_context_prefix    := 'NET_PAYMENTS';
  open csr_get_results (g_ele_class_Net_EE_Deductions
                       ,g_ele_class_ER_LV_Charges
                       ,p_archive_assignment_action_id
                       ,g_us_name_base, g_fr_name_base
                       ,g_us_name_rate, g_fr_name_rate
                       ,g_us_name_pay_value, g_fr_name_pay_value);
  LOOP
    fetch csr_get_results INTO rec_results;
    EXIT WHEN csr_get_results%NOTFOUND;
    l_loop_counter := l_loop_counter + 1;
    rec_results.amount := nvl(rec_results.amount, 0);
    --
    -- Manage the context order.
    --
    if (  l_previous_rubric  <> nvl(rec_results.rubric,  ' ')
       or(l_previous_base    <> nvl(rec_results.base, 0))
      ) THEN
      l_ee_context_order := l_loop_counter; /* The bases MAY be different for the same rubric, if they are, */
      l_er_context_order := l_loop_counter; /* report them on separate lines - should never happen          */
    end if;
    --
    -- Arcvive ee values
    --
    if rec_results.class = 'EE' then
      l_ee_context_order := l_ee_context_order + 1;
      pay_fr_arc_pkg.write_archive(p_action_context_id           =>  p_archive_assignment_action_id
                                  ,p_action_context_type         =>  l_archive_type
                                  ,p_context_prefix              =>  l_context_prefix
                                  ,p_rubric                      =>  rec_results.rubric
                                  ,p_rubric_sort                 =>  l_ee_context_order
                                  ,p_tax_unit_id                 =>  p_establishment_id
                                  ,p_action_information_category =>  l_context
                                  ,p_action_information4         =>  rec_results.rubric
                                  ,p_action_information5         =>  rec_results.description
                                  ,p_action_information8         =>  rec_results.base_units
                                  ,p_action_information9         =>  rec_results.base
                                  ,p_action_information10        =>  rec_results.rate
                                  ,p_action_information11        =>  rec_results.amount * -1);
    else
      --
      -- Arcvive er values
      --
      l_er_context_order := l_er_context_order + 1;
      pay_fr_arc_pkg.write_archive(p_action_context_id           =>  p_archive_assignment_action_id
                                  ,p_action_context_type         =>  l_archive_type
                                  ,p_context_prefix              =>  l_context_prefix
                                  ,p_rubric                      =>  rec_results.rubric
                                  ,p_rubric_sort                 =>  l_er_context_order
                                  ,p_tax_unit_id                 =>  p_establishment_id
                                  ,p_action_information_category =>  l_context
                                  ,p_action_information4         =>  rec_results.rubric
                                  ,p_action_information5         =>  rec_results.description
                                  ,p_action_information8         =>  rec_results.base_units
                                  ,p_action_information9         =>  rec_results.base
                                  ,p_action_information12        =>  rec_results.rate
                                  ,p_action_information13        =>  rec_results.amount);
    end if;
    --
    -- Maintain the running totals
    --
    if rec_results.class = 'EE' then
      l_total_ee_net_deductions := l_total_ee_net_deductions + rec_results.amount;
    end if;
    l_previous_rubric    := nvl(rec_results.rubric, '.');
    l_previous_base      := nvl(rec_results.base, 0);
  END LOOP; -- cursor loop
  hr_utility.set_location('End of Prefix Loop ' || l_proc, 90);
  close csr_get_results;
  --
  -- Pass back the return variable
  --
  p_total_ee_net_deductions := l_total_ee_net_deductions;
  --
  hr_utility.set_location('Leaving ' || l_proc, 110);
END load_rate_grouped_runs;
-------------------------------------------------------------------------------
-- SUPPORT CODE
-------------------------------------------------------------------------------
-- GET_PARAMETER                   used in sql to decode legislative parameters
--                                 copied from uk code.
-------------------------------------------------------------------------------
function get_parameter(
         p_parameter_string in varchar2
        ,p_token            in varchar2
        ,p_segment_number   in number default null )    RETURN varchar2
IS
  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
  l_proc VARCHAR2(40):= g_package||' get parameter ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 20);
  l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  IF l_start_pos = 0 THEN
    l_delimiter := '|';
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
  end if;
  IF l_start_pos <> 0 THEN
    l_start_pos := l_start_pos + length(p_token||'=');
    l_parameter := substr(p_parameter_string,
                          l_start_pos,
                          instr(p_parameter_string||' ',
                          l_delimiter,l_start_pos)
                          - l_start_pos);
    IF p_segment_number IS NOT NULL THEN
      l_parameter := ':'||l_parameter||':';
      l_parameter := substr(l_parameter,
                            instr(l_parameter,':',1,p_segment_number)+1,
                            instr(l_parameter,':',1,p_segment_number+1) -1
                            - instr(l_parameter,':',1,p_segment_number));
    END IF;
  END IF;
  hr_utility.set_location('Leaving ' || l_proc, 100);
  RETURN l_parameter;
END get_parameter;
-------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS                gets all parameters for the payroll action
-------------------------------------------------------------------------------
procedure get_all_parameters (
          p_payroll_action_id                    in number
         ,p_payroll_id                           out nocopy number
         ,p_assignment_id                        out nocopy number
         ,p_assignment_set_id                    out nocopy number
         ,p_business_group_id                    out nocopy number
         ,p_start_date                           out nocopy date
         ,p_effective_date                       out nocopy date) is
  --
  cursor   csr_parameter_info(p_payroll_action_id NUMBER) IS
  SELECT   pay_fr_arc_pkg.get_parameter(legislative_parameters, 'PAYROLL_ID')
          ,pay_fr_arc_pkg.get_parameter(legislative_parameters, 'ASSIGNMENT_ID')
          ,pay_fr_arc_pkg.get_parameter(legislative_parameters, 'ASSIGNMENT_SET')
          ,business_group_id
          ,start_date
          ,effective_date
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  l_proc VARCHAR2(40):= g_package||' get_all_parameters ';

BEGIN
  hr_utility.set_location('Entering ' || l_proc, 20);
  open csr_parameter_info (p_payroll_action_id);
  fetch csr_parameter_info into p_payroll_id, p_assignment_id, p_assignment_set_id
                               ,p_business_group_id, p_start_date, p_effective_date;
  close csr_parameter_info;

  hr_utility.set_location('Leaving ' || l_proc, 100);
END get_all_parameters;
-------------------------------------------------------------------------------
-- GET_BALANCE_ID
-- DESCRIPTION : gets a defined balance id
-------------------------------------------------------------------------------
function get_balance_id (
         p_balance_name                         in varchar2
        ,p_dimension                            in varchar2)   RETURN number is
  --
  l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
  --
  l_proc VARCHAR2(40):= g_package||' get_balance_id ';
  --
BEGIN
  --
  hr_utility.set_location('Entering ' || l_proc, 10);
  SELECT defined_balance_id
  INTO   l_defined_balance_id
  FROM   pay_defined_balances db
        ,pay_balance_types    b
        ,pay_balance_dimensions d
  WHERE  b.balance_name          = p_balance_name
    AND  d.dimension_name        = p_dimension
    AND  db.balance_type_id      = b.balance_type_id
    AND  db.balance_dimension_id = d.balance_dimension_id
    AND  d.legislation_code      = 'FR';
  hr_utility.set_location(' Leaving ' || l_proc, 100);
  return  l_defined_balance_id;
EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_location('DEV ERROR Balance Name not found ' || p_balance_name, 20);
    raise;
  when TOO_MANY_ROWS then
    hr_utility.set_location('DEV ERROR Balance Name ambiguous ' || p_balance_name, 20);
    raise;
end get_balance_id;
-------------------------------------------------------------------------------
-- DEINITIALIZE
-- DESCRIPTION : Called once per payroll action; to load all org details
-------------------------------------------------------------------------------
procedure deinitialize(
      p_payroll_action_id            in number) is
  --
  cursor csr_check_archive_org_address (p_payroll_action_id number) is
  select action_information4        name
        ,ppa.payroll_id             payroll_id
   from  pay_action_information    pai
        ,pay_payroll_actions       ppa
   where pai.action_information_category in('FR_SOE_ESTAB_INFORMATION', 'FR_SOE_COMPANY_DETAILS')
    and  pai.action_information2 is null   /* address id */
    and  pai.action_context_id = p_payroll_action_id
    and  pai.action_context_id = ppa.payroll_Action_id
    and  pai.action_context_type = 'PA';
--
  l_proc VARCHAR2(40) :=    g_package||' deinitialize ';
  l_error boolean     :=    FALSE;
  l_message                 varchar2(240);
--
BEGIN
  --
  if g_payroll_action_id is null
  or g_payroll_action_id <> p_payroll_action_id
  then
    pay_fr_arc_pkg.get_all_parameters (
                 p_payroll_action_id => p_payroll_action_id
                ,p_payroll_id        => g_param_payroll_id
                ,p_assignment_id     => g_param_assignment_id
                ,p_assignment_set_id => g_param_assignment_set_id
                ,p_business_Group_id => g_param_business_group_id
                ,p_start_date        => g_param_start_date
                ,p_effective_date    => g_param_effective_date);
    g_payroll_action_id := p_payroll_action_id;
  end if;
  --
  --
  -- Get the company addresses and establishment addresses and
  -- company and establishment details
  --
  hr_utility.set_location('Step ' || l_proc,30);
  pay_fr_arc_pkg.load_organization_details(
                 p_payroll_action_id => p_payroll_action_id
                ,p_business_Group_id => g_param_business_group_id
                ,p_payroll_id        => g_param_payroll_id
                ,p_assignment_id     => g_param_assignment_id
                ,p_assignment_set_id => g_param_assignment_set_id
                ,p_effective_date    => g_param_effective_date
                ,p_start_date        => g_param_start_date);
  --
  -- Error if any company or establishment
  -- addresses are missing.
  --
  hr_utility.set_location('Step ' || l_proc,30);
  FOR missing_address in csr_check_archive_org_address(p_payroll_action_id)
  LOOP
    hr_utility.set_message(801, 'PAY_74979_INCOMPLETE_ADDRESS');
    hr_utility.set_message_token(801,'ORGANIZATION',missing_address.name);
    l_message := substr(hr_utility.get_message,1,240);
    l_error :=  TRUE;
  END LOOP;
  IF l_error = TRUE THEN
    fnd_file.put_line (fnd_file.LOG, l_message);
    hr_utility.raise_error;
  END IF;
  hr_utility.set_location('Leaving ' || l_proc, 100);
end deinitialize;
-------------------------------------------------------------------------------
-- LOAD_DEDUCTIONS
-- DESCRIPTION :                                                            New
-------------------------------------------------------------------------------
procedure load_deductions(
          p_archive_assignment_action_id in number
         ,p_assignment_id                in number
         ,p_latest_process_type          in varchar2
         ,p_total_deduct_ee              out nocopy number
         ,p_total_deduct_er              out nocopy number
         ,p_total_charge_ee              out nocopy number
         ,p_total_charge_er              out nocopy number
         ,p_establishment_id             in number
         ,p_effective_date               in date ) is
--
/* Bulk fetches into table of records not supported in 8.1.7 */
TYPE t_char_tbl    is TABLE of varchar2(2000) INDEX by BINARY_INTEGER;
TYPE t_date_tbl    is TABLE of date           INDEX by BINARY_INTEGER;
TYPE t_num_tbl     is TABLE of number         INDEX by BINARY_INTEGER;
TYPE t_binint_tbl  is TABLE of BINARY_INTEGER INDEX by BINARY_INTEGER;
tbl_tax_unit_id    t_num_tbl;
tbl_process_type   t_char_tbl;
tbl_ee_rate        t_num_tbl;
tbl_er_rate        t_num_tbl;
tbl_ee_amount      t_num_tbl;
tbl_er_amount      t_num_tbl;
tbl_cu_id          t_num_tbl;
tbl_EE_ER          t_char_tbl;
tbl_cxt_prefix     t_char_tbl;
tbl_action_id      t_num_tbl;
tbl_group_code     t_char_tbl;
tbl_row_base       t_num_tbl;
tbl_base           t_num_tbl;
tbl_start_date     t_date_tbl;
tbl_end_date       t_date_tbl;
tbl_pos_idx        t_binint_tbl;
tbl_retrieval_list pay_balance_pkg.t_balance_value_tab;
l_pos_offset       BINARY_INTEGER;
l_grouped_rate_ptr BINARY_INTEGER;
l_action_ptr       BINARY_INTEGER;
l_current_ptr      BINARY_INTEGER;
--
-- Modified for bug 3683906, commented out under bug 4778143
-- l_sec_grp_id_user_ele_grp number;
-- l_sec_grp_id_ele_grp      number;
--
l_proc                VARCHAR2(60):= g_package||' Load Deductions ';
l_this_process_type   fnd_lookup_values.meaning%TYPE;
l_proc_type           fnd_lookup_values.lookup_code%TYPE;
l_proc_type_meaning   fnd_lookup_values.meaning%TYPE;
l_total_ee_deductions number(15,2) := 0.00;
l_total_er_deductions number(15,2) := 0.00;
l_total_ee_csg        number(15,2) := 0.00;
l_context             varchar2(20) := 'FR_SOE_ELEMENTS';
l_action_info_id      pay_action_information.action_information_id%TYPE;
l_ovn                 pay_action_information.object_version_number%TYPE;
l_archive_type        varchar2(3)  := 'AAP';
l_group_code          fnd_lookup_values.lookup_code%TYPE;
l_def_bal_id          pay_defined_balances.defined_balance_id%TYPE;
l_rubric              fnd_lookup_values.tag%TYPE;
l_description         fnd_lookup_values.meaning%TYPE;
l_retro_tl            fnd_lookup_values.meaning%TYPE;
--
l_append_dates            varchar2(150); /* temp area for for constructing dd-mm - dd-mm */
--
cursor csr_get_run_bals is
select rb.tax_unit_id      /* estab */
,      rb.source_text                                              process_type
,      rb.source_number                                                    rate
,      rb.source_id                                                       cu_id
,      decode(b.balance_category_id
             ,g_Stat_ER_Charges    ,'ER'
             ,g_Conv_ER_Charges    ,'ER'
             ,g_Rebates            ,'ER'
                                   ,'EE')                                 EE_ER
,      decode(b.balance_category_id
             ,g_Rebates            ,'CONTRIBUTIONS_REBATE'
             ,g_Income_Tax_Excess  ,'CONTRIBUTIONS_TAX'
             ,g_CSG_non_Deductible ,'CONTRIBUTIONS_CSG'
                                   ,'CONTRIBUTIONS')                     balcat
,     db2.defined_balance_id                                             defbal
,     max(aa.assignment_action_id)                         assignment_action_id
,     nvl(fcu.group_code, pet.element_information1)               element_group
from pay_action_interlocks      arclck
,    pay_action_interlocks      prelck
,    pay_balance_types          b
,    pay_run_balances           rb
,    pay_defined_balances       db
,    pay_payroll_actions        pa
,    pay_assignment_actions     aa
,    pay_defined_balances       db2
,    pay_fr_contribution_usages fcu
,    pay_input_values_f         piv
,    pay_element_types_f        pet
where arclck.locking_action_id    = p_archive_assignment_action_id
and   prelck.locking_action_id    = arclck.locked_action_id
and   aa.assignment_action_id     = prelck.locked_action_id
and   b.balance_category_id in (g_Income_Tax_Excess
                               ,g_Stat_EE_Deductions
                               ,g_Stat_ER_Charges
                               ,g_Conv_ER_Charges
                               ,g_Conv_EE_Deductions
                               ,g_Rebates
                               ,g_CSG_non_Deductible)
and   db.balance_type_id = b.balance_type_id
and   db.balance_dimension_id in (g_asg_et_pr_ra_cu_run
                                 ,g_asg_et_pr_cu_run
                                 ,g_asg_run)
and (db.balance_dimension_id <> g_asg_run or not exists (select 1
  from pay_defined_balances    db1
   where  db1.balance_type_id       = db.balance_type_id
     and  db1.balance_dimension_id in (g_asg_et_pr_ra_cu_run
                                      ,g_asg_et_pr_cu_run)))
and   rb.defined_balance_id = db.defined_balance_id
and ((db.business_group_id is null and   db.legislation_code = 'FR') or
     (db.business_group_id = g_param_business_group_id))
and   rb.assignment_action_id = aa.assignment_action_id
and   pa.action_type         in ('Q','R')
and   pa.payroll_action_id = aa.payroll_action_id
and   aa.run_type_id is not null
and   fcu.contribution_usage_id(+) = rb.source_id
and   b.input_value_id = piv.input_value_id(+)
and   p_effective_Date between piv.effective_start_date(+)
                           and piv.effective_end_date(+)
and   piv.element_type_id = pet.element_type_id(+)
and   p_effective_Date between pet.effective_start_date(+)
                           and pet.effective_end_date(+)
and   db2.balance_type_id = b.balance_type_id
and   db2.balance_dimension_id = decode(db.balance_dimension_id
                                       ,g_asg_et_pr_ra_cu_run
                                       ,g_asg_et_pr_ra_cu_pro_run
                                       ,g_asg_et_pr_cu_run
                                       ,g_asg_et_pr_cu_pro_run
                                       ,g_asg_run
                                       ,g_asg_pro_run)
and  (db2.business_group_id = g_param_business_group_id or
      (db2.business_group_id is null and db2.legislation_code = 'FR'))
group by aa.source_action_id
,        nvl(fcu.group_code, pet.element_information1)
,        rb.source_text
,        rb.tax_unit_id
,        rb.source_number    /* rate */
,        rb.source_id     /* cu_id */
,        decode(b.balance_category_id
               ,g_Stat_ER_Charges    ,'ER'
               ,g_Conv_ER_Charges    ,'ER'
               ,g_Rebates            ,'ER'
                                     ,'EE')
,        decode(b.balance_category_id
               ,g_Rebates            ,'CONTRIBUTIONS_REBATE'
               ,g_Income_Tax_Excess  ,'CONTRIBUTIONS_TAX'
               ,g_CSG_non_Deductible ,'CONTRIBUTIONS_CSG'
                                     ,'CONTRIBUTIONS')
,        db2.defined_balance_id
order by max(aa.assignment_action_id)
,        nvl(fcu.group_code, pet.element_information1)
,        rb.source_text
,        decode(b.balance_category_id
               ,g_Rebates            ,'CONTRIBUTIONS_REBATE'
               ,g_Income_Tax_Excess  ,'CONTRIBUTIONS_TAX'
               ,g_CSG_non_Deductible ,'CONTRIBUTIONS_CSG'
                                     ,'CONTRIBUTIONS');
-- Above order by is important for subsequent looping/grouping
--
cursor csr_get_retros is
select
   pcu.group_code                                                    group_code
,  fnd_number.canonical_to_number(result.base_value)                 base_value
,  sum(decode(result.EE_ER
             ,'EE',fnd_number.canonical_to_number(result.rate)))        ee_rate
,  sum(decode(result.EE_ER
             ,'EE',fnd_number.canonical_to_number(result.amount)))    ee_amount
,  sum(decode(result.EE_ER
             ,'ER',fnd_number.canonical_to_number(result.rate)))        er_rate
,  sum(decode(result.EE_ER
             ,'ER',fnd_number.canonical_to_number(result.amount)))    er_amount
,  result.process_type                                                  process
,  elecls
,  ptp_start_date
,  ptp_end_date
from   pay_fr_contribution_usages pcu,
      (
    select
      max(decode(piv.name,'Process_Type',prrv.result_value))       process_type
     ,max(decode(piv.name,g_fr_name_base,prrv.result_value,
                          g_us_name_base,prrv.result_value))         base_value
     ,max(decode(piv.name,g_fr_name_rate,prrv.result_value,
                          g_us_name_rate,prrv.result_value))               rate
     ,max(decode(piv.name,g_fr_name_pay_value,prrv.result_value,
                          g_us_name_pay_value,prrv.result_value))        amount
     ,max(decode(piv.name,'Contribution_Usage_ID',prrv.result_value))     cu_id
     ,prrv.run_result_id
     ,decode(pet.classification_id
            ,g_ele_class_Stat_EE_Deductions   ,'EE'
            ,g_ele_class_Stat_ER_Charges      ,'ER'
            ,g_ele_class_Conv_EE_Deductions   ,'EE'
            ,g_ele_class_Conv_ER_Charges      ,'ER'
            ,g_ele_class_CSG_non_Deductible   ,'EE'
            ,g_ele_class_Rebates              ,'ER'
            ,g_ele_class_Income_Tax_Excess    ,'EE')                      EE_ER
     ,decode(pet.classification_id
            ,g_ele_class_Stat_EE_Deductions   ,'CONTRIBUTIONS'
            ,g_ele_class_Stat_ER_Charges      ,'CONTRIBUTIONS'
            ,g_ele_class_Conv_EE_Deductions   ,'CONTRIBUTIONS'
            ,g_ele_class_Conv_ER_Charges      ,'CONTRIBUTIONS'
            ,g_ele_class_CSG_non_Deductible   ,'CONTRIBUTIONS_CSG'
            ,g_ele_class_Rebates              ,'CONTRIBUTIONS_REBATE'
            ,g_ele_class_Income_Tax_Excess    ,'CONTRIBUTIONS_TAX')      elecls
     ,ptp_date.start_date                                        ptp_start_date
     ,ptp_date.end_date                                            ptp_end_date
    from   pay_run_result_values       prrv
          ,pay_run_results             prr
          ,pay_element_types_f         pet
          ,pay_input_values_f_tl       piv
          ,pay_payroll_actions         run_payact
          ,pay_assignment_actions      run_assact
          ,pay_action_interlocks       arc_lock
          ,pay_action_interlocks       pre_lock
          ,pay_entry_process_details   epd
          ,per_time_periods            ptp_date
          ,pay_payroll_actions         ppa_date
          ,pay_assignment_actions      paa_date
    where epd.element_entry_id       = prr.element_entry_id
    and   epd.retro_component_id    is not null
    and   prrv.run_result_id         = prr.run_result_id
    and   prr.element_type_id        = pet.element_type_id
    and   run_payact.date_earned between pet.effective_start_date
                                     and pet.effective_end_date
    and   pet.classification_id   in (g_ele_class_Conv_EE_Deductions
                                     ,g_ele_class_Conv_ER_Charges
                                     ,g_ele_class_Stat_EE_Deductions
                                     ,g_ele_class_Stat_ER_Charges
                                     ,g_ele_class_CSG_non_Deductible
                                     ,g_ele_class_Rebates
                                     ,g_ele_class_Income_Tax_Excess)
    and   piv.input_value_id         = prrv.input_value_id
    and   piv.language               = userenv('lang')
    and   piv.name in  (  g_us_name_pay_value, g_fr_name_pay_value
                         ,g_us_name_base, g_fr_name_base
                         ,g_us_name_rate, g_fr_name_rate
                         ,'Contribution_Usage_ID', 'Process_Type')
    and   prr.assignment_action_id     = run_assact.assignment_action_id
    and   arc_lock.locking_action_id   = p_archive_assignment_action_id
    and   arc_lock.locked_action_id    = pre_lock.locking_action_id
    and   pre_lock.locked_action_id    = run_assact.assignment_action_id
    and   run_payact.payroll_action_id = run_assact.payroll_action_id
    and   run_payact.action_type      in ('Q', 'R')
    and   prrv.result_value is not null
    and   epd.source_asg_action_id   = paa_date.assignment_action_id
    and   ppa_date.payroll_action_id = paa_date.payroll_action_id
    and   ptp_date.time_period_id    = ppa_date.time_period_id
    group by
          prrv.run_result_id,
          decode(pet.classification_id
                ,g_ele_class_Stat_EE_Deductions   ,'EE'
                ,g_ele_class_Stat_ER_Charges      ,'ER'
                ,g_ele_class_Conv_EE_Deductions   ,'EE'
                ,g_ele_class_Conv_ER_Charges      ,'ER'
                ,g_ele_class_CSG_non_Deductible   ,'EE'
                ,g_ele_class_Rebates              ,'ER'
                ,g_ele_class_Income_Tax_Excess    ,'EE'),
          decode(pet.classification_id
                ,g_ele_class_Stat_EE_Deductions   ,'CONTRIBUTIONS'
                ,g_ele_class_Stat_ER_Charges      ,'CONTRIBUTIONS'
                ,g_ele_class_Conv_EE_Deductions   ,'CONTRIBUTIONS'
                ,g_ele_class_Conv_ER_Charges      ,'CONTRIBUTIONS'
                ,g_ele_class_CSG_non_Deductible   ,'CONTRIBUTIONS_CSG'
                ,g_ele_class_Rebates              ,'CONTRIBUTIONS_REBATE'
                ,g_ele_class_Income_Tax_Excess    ,'CONTRIBUTIONS_TAX'),
          ptp_date.start_date,
          ptp_date.end_date
     ) result
where pcu.contribution_usage_id = result.cu_id
group by pcu.group_code
,        result.process_type
,        result.base_value
,        result.ptp_start_date
,        result.ptp_end_date
,        result.elecls
order by 1,7,2;

--
cursor csr_process_meaning (p_process_type varchar2) is
   select upper(meaning)
   from   fnd_lookup_values
   where  lookup_type         = 'FR_PROCESS_TYPE'
   and    view_application_id = 3
   and    lookup_code         = p_process_type
   and    security_group_id   = g_sec_grp_id_process_type
   and    language            = userenv('LANG');

-- modified for bug 3683906
cursor csr_get_rubric(p_group_code varchar2,
                      p_sec_grp_id_ele_grp number,
                      p_sec_grp_id_user_ele_grp number) is
select tag ,meaning
from   fnd_lookup_values
where ((lookup_type = 'FR_ELEMENT_GROUP'
and   security_group_id = p_sec_grp_id_ele_grp)
OR    (lookup_type = 'FR_USER_ELEMENT_GROUP'
and   security_group_id = p_sec_grp_id_user_ele_grp))
and   lookup_code = p_group_code
and   LANGUAGE    = USERENV('LANG')
and   VIEW_APPLICATION_ID = 3
order by lookup_type desc;
  --
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 5);
  -- Modified for bug 3683906, commented out under bug 4778143
  -- l_sec_grp_id_user_ele_grp := g_sec_grp_id_user_element_grp;
  -- l_sec_grp_id_ele_grp      := g_sec_grp_id_element_grp;
    --
    hr_utility.trace('LOAD DEDUCTIONS 1');
  l_pos_offset := 0;
  open csr_get_run_bals;
  fetch csr_get_run_bals bulk collect into
    tbl_tax_unit_id, tbl_process_type, tbl_ee_rate, tbl_cu_id, tbl_EE_ER,
    tbl_cxt_prefix, tbl_ee_amount, tbl_action_id, tbl_group_code;
  close csr_get_run_bals;
  l_action_ptr := tbl_action_id.FIRST;
  l_grouped_rate_ptr := 0;
  tbl_action_id(0) := null; -- invoke null trap first time through loop
  l_current_ptr := l_action_ptr;
  --
  -- loop through whole table, grouping EE/ER rows
  WHILE l_current_ptr IS NOT NULL LOOP
    -- Get the balance amount (tbl_ee_amount currently stores the def bal id)
    tbl_ee_amount(l_current_ptr) := pay_balance_pkg.get_value(
                                           tbl_ee_amount(l_current_ptr)
                                          ,tbl_action_id(l_current_ptr)
                                          ,tbl_tax_unit_id(l_current_ptr)
                                          ,null
                                          ,tbl_cu_id(l_current_ptr)
                                          ,tbl_process_type(l_current_ptr)
                                          ,null ,null ,null ,null ,null
                                          ,tbl_ee_rate(l_current_ptr));
    -- if current row matches the group row
    if  tbl_action_id(l_current_ptr)    = tbl_action_id(l_grouped_rate_ptr)
    and tbl_group_code(l_current_ptr)   = tbl_group_code(l_grouped_rate_ptr)
    and nvl(tbl_process_type(l_current_ptr),'<null>') =
                             nvl(tbl_process_type(l_grouped_rate_ptr),'<null>')
    and tbl_cxt_prefix(l_current_ptr)   = tbl_cxt_prefix(l_grouped_rate_ptr)
    then
      -- if balance amount <> 0
      if tbl_ee_amount(l_current_ptr) <> 0 then
        -- add current row values to appropriate cols of group row
        if tbl_EE_ER(l_current_ptr) = 'ER' then
          if tbl_ee_rate(l_current_ptr) is not null then
            tbl_er_rate(l_grouped_rate_ptr) :=
              nvl(tbl_er_rate(l_grouped_rate_ptr),0) +
              tbl_ee_rate(l_current_ptr);
          end if;
          tbl_er_amount(l_grouped_rate_ptr) :=
            nvl(tbl_er_amount(l_grouped_rate_ptr),0) +
            tbl_ee_amount(l_current_ptr);
        else
          if tbl_ee_rate(l_current_ptr) is not null then
            tbl_ee_rate(l_grouped_rate_ptr) :=
              nvl(tbl_ee_rate(l_grouped_rate_ptr),0) +
              tbl_ee_rate(l_current_ptr);
          end if;
          tbl_ee_amount(l_grouped_rate_ptr) :=
            nvl(tbl_ee_amount(l_grouped_rate_ptr),0) +
            tbl_ee_amount(l_current_ptr);
        end if;
      end if;
    else -- (current row doesn't match the group row)
      -- if balance amount <> 0 then
      if tbl_ee_amount(l_current_ptr) <> 0 then
        -- delete any rows between the group row and current row non-inclusive
        tbl_tax_unit_id.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_process_type.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_ee_rate.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_cu_id.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_EE_ER.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_cxt_prefix.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_ee_amount.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_action_id.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        tbl_group_code.delete(l_grouped_rate_ptr+1,l_current_ptr-1);
        -- make the current row the new group row
        l_grouped_rate_ptr := l_current_ptr;
        -- if rate is not null then
        if tbl_ee_rate(l_current_ptr) is not null
        then
          -- get base name from group code then base def bal id from base name
          if nvl(l_group_code,'<null>') <> tbl_group_code(l_current_ptr) then
            l_group_code := tbl_group_code(l_current_ptr);
            l_def_bal_id :=
              get_balance_id(PAY_FR_GENERAL.get_base_name
                               (g_param_business_group_id,l_group_code)
                            ,'Assignment Proration Run To Date');
          end if;
          if not tbl_pos_idx.exists(l_def_bal_id) then
            -- store base def bal id in next row of tbl_retrieval_list (from 1)
            tbl_retrieval_list(nvl(tbl_retrieval_list.last+1
                                  ,1)).defined_balance_id := l_def_bal_id;
            -- store (id of above row)+offset in tbl_pos_idx(def_bal_id)
            tbl_pos_idx(l_def_bal_id) := tbl_retrieval_list.last+l_pos_offset;
          end if;
          -- store tbl_pos_idx(def_bal_id) against current row
          tbl_row_base(l_current_ptr) := tbl_pos_idx(l_def_bal_id);
        end if; -- rate exists
        -- if ER then
        if tbl_EE_ER(l_current_ptr) = 'ER' then
          -- move amount to correct col, nullify EE cols
          tbl_er_rate(l_current_ptr) := tbl_ee_rate(l_current_ptr);
          tbl_ee_rate(l_current_ptr) := null;
          tbl_er_amount(l_current_ptr) := tbl_ee_amount(l_current_ptr);
          tbl_ee_amount(l_current_ptr) := null;
        -- else initialise ER cols
        else
          tbl_er_rate(l_current_ptr) := null;
          tbl_er_amount(l_current_ptr) := null;
        end if;
      else
      -- (else balance amount = 0)
        -- if l_action_ptr points to the current row
        if l_action_ptr = l_current_ptr then
          -- set l_action_ptr to the next row; current row will be deleted
          l_action_ptr := l_action_ptr + 1;
        end if;
      end if;
    end if; -- row matching
    -- Queue up next row
    l_current_ptr := tbl_action_id.next(l_current_ptr);
    -- If change of action or end of table
    if l_current_ptr is null
    or tbl_action_id(l_current_ptr) <> tbl_action_id(l_action_ptr)
    then
      -- if there were deductions with bases against previous action then
      if tbl_pos_idx.count > 0 then
        -- fetch tbl_retrieval_list for previous action id
        pay_balance_pkg.get_value(tbl_action_id(l_action_ptr)
                                 ,tbl_retrieval_list);
        -- copy each tbl_retrieval_list(i).balance_value to tbl_base(i+offset)
        for i in tbl_retrieval_list.first..tbl_retrieval_list.last loop
          tbl_base(i+l_pos_offset):=nvl(tbl_retrieval_list(i).balance_value,0);
        end loop;
        l_pos_offset := tbl_base.last;
        -- clear bases tables tbl_pos_idx and tbl_retrieval_list
        tbl_retrieval_list.delete;
        tbl_pos_idx.delete;
      end if;
      -- delete tbl_action_id rows between l_action_ptr and last grouped row
      -- non-inc
      -- (remaining tbl_action_id rows serve as end markers for later grouping)
      tbl_action_id.delete(l_action_ptr,l_grouped_rate_ptr-1);
      -- set l_action_ptr
      l_action_ptr := l_current_ptr;
    end if;
  end loop; -- ee/er pairing.
  -- delete any rows following the (last) group row.
  tbl_process_type.delete(l_grouped_rate_ptr+1,tbl_process_type.last);
  tbl_ee_rate.delete(l_grouped_rate_ptr+1,tbl_ee_rate.last);
  tbl_cxt_prefix.delete(l_grouped_rate_ptr+1,tbl_cxt_prefix.last);
  tbl_ee_amount.delete(l_grouped_rate_ptr+1,tbl_ee_amount.last);
  tbl_action_id.delete(l_grouped_rate_ptr+1,tbl_action_id.last);
  tbl_group_code.delete(l_grouped_rate_ptr+1,tbl_group_code.last);
  -- delete cols no longer required
  tbl_cu_id.delete;
  tbl_tax_unit_id.delete;
  tbl_EE_ER.delete;
  l_group_code := null; -- is the context to a different 'cache' below.

  -- loop through whole (sparse) table again, grouping by rate combination
  -- then again for retros, which would be already grouped.
  --
  for l_retro_processing in 0..1 loop
    if l_retro_processing = 1 then
      open csr_get_retros;
      fetch csr_get_retros bulk collect into
        tbl_group_code, tbl_row_base, tbl_ee_rate, tbl_ee_amount, tbl_er_rate,
        tbl_er_amount, tbl_process_type, tbl_cxt_prefix, tbl_start_date,
        tbl_end_date;
      close csr_get_retros;
      l_retro_tl :=  ' ' ||g_retro_tl;
    end if;
    l_grouped_rate_ptr := tbl_group_code.first;
    <<grouped_rate_loop>>
    WHILE l_grouped_rate_ptr IS NOT NULL LOOP
      if l_retro_processing = 0 then
        -- processing non-retros, which need further grouping
        if tbl_row_base.exists(l_grouped_rate_ptr)
        then
          -- replace pointer to base with actual base value, reusing column
          tbl_row_base(l_grouped_rate_ptr) :=
                                    tbl_base(tbl_row_base(l_grouped_rate_ptr));
        else
          -- initialise the base
          tbl_row_base(l_grouped_rate_ptr) := 0;
        end if;
        -- loop through subsequent rows looking for matches
        l_current_ptr := tbl_group_code.next(l_grouped_rate_ptr);
        <<match_loop>>
        WHILE l_current_ptr IS NOT NULL LOOP
          if tbl_group_code(l_current_ptr) > tbl_group_code(l_grouped_rate_ptr)
          or (tbl_group_code(l_current_ptr)= tbl_group_code(l_grouped_rate_ptr)
              and tbl_process_type(l_current_ptr) >
                                          tbl_process_type(l_grouped_rate_ptr))
          then
            -- skip to first row for the next action
            -- (Nb. it will be after the current actions end marker, which may
            -- actually be the current row)
            l_current_ptr :=
              tbl_group_code.next(nvl(tbl_action_id.next(l_current_ptr-1)
                                     ,tbl_group_code.last));
          else
            if  nvl(tbl_ee_rate(l_current_ptr),0) =
                                         nvl(tbl_ee_rate(l_grouped_rate_ptr),0)
            and nvl(tbl_er_rate(l_current_ptr),0) =
                                         nvl(tbl_er_rate(l_grouped_rate_ptr),0)
            and tbl_group_code(l_current_ptr) =
                                             tbl_group_code(l_grouped_rate_ptr)
            and nvl(tbl_process_type(l_current_ptr),'<null>') =
                             nvl(tbl_process_type(l_grouped_rate_ptr),'<null>')
            and tbl_cxt_prefix(l_current_ptr) =
                                             tbl_cxt_prefix(l_grouped_rate_ptr)
            then
              if tbl_ee_amount(l_current_ptr) is not null then
                tbl_ee_amount(l_grouped_rate_ptr) :=
                  nvl(tbl_ee_amount(l_grouped_rate_ptr),0) +
                  tbl_ee_amount(l_current_ptr);
              end if;
              if tbl_er_amount(l_current_ptr) is not null then
                tbl_er_amount(l_grouped_rate_ptr) :=
                  nvl(tbl_er_amount(l_grouped_rate_ptr),0) +
                  tbl_er_amount(l_current_ptr);
              end if;
              if tbl_row_base.exists(l_current_ptr) then
                tbl_row_base(l_grouped_rate_ptr) :=
                  tbl_row_base(l_grouped_rate_ptr) +
                  tbl_base(tbl_row_base(l_current_ptr));
              end if;
              -- delete the current row
              tbl_process_type.delete(l_current_ptr);
              tbl_ee_rate.delete(l_current_ptr);
              tbl_er_rate.delete(l_current_ptr);
              tbl_cxt_prefix.delete(l_current_ptr);
              tbl_ee_amount.delete(l_current_ptr);
              tbl_er_amount.delete(l_current_ptr);
              tbl_group_code.delete(l_current_ptr);
              tbl_row_base.delete(l_current_ptr);
            end if; -- match
            l_current_ptr := tbl_group_code.next(l_current_ptr);
          end if;
        end loop match_loop;
      else -- processing retros; format dates
        l_append_dates := to_char(tbl_start_date(l_grouped_rate_ptr),' dd-mm')
                       || to_char(tbl_end_date(l_grouped_rate_ptr),' - dd-mm');
      end if; -- end retro processing
      --
      -- Can now archive the row.
      -- First fetch the rubric
      if nvl(l_group_code,'<null>') <> tbl_group_code(l_grouped_rate_ptr) then
        l_group_code := tbl_group_code(l_grouped_rate_ptr);
        open csr_get_rubric(l_group_code,
                            g_sec_grp_id_element_grp,
                            g_sec_grp_id_user_element_grp);
        fetch csr_get_rubric into l_rubric, l_description;
        close csr_get_rubric;
      end if;
      -- Derive Process Type, only if it's not the latest process type from
      -- the latest run in this archive set
      --
      if p_latest_process_type <> tbl_process_type(l_grouped_rate_ptr) then
        if nvl(l_proc_type,'<null>') <> tbl_process_type(l_grouped_rate_ptr)
        then
          l_proc_type := tbl_process_type(l_grouped_rate_ptr);
          open csr_process_meaning(l_proc_type);
          fetch csr_process_meaning into l_proc_type_meaning;
          close csr_process_meaning;
        end if;
        l_this_process_type := l_proc_type_meaning;
      else
        l_this_process_type := null;
      end if;
      -- Maintain the running totals
      if tbl_cxt_prefix(l_grouped_rate_ptr) = 'CONTRIBUTIONS' then
        l_total_ee_deductions := l_total_ee_deductions +
                                 nvl(tbl_ee_amount(l_grouped_rate_ptr),0);
        l_total_er_deductions := l_total_er_deductions +
                                 nvl(tbl_er_amount(l_grouped_rate_ptr),0);
      elsif tbl_cxt_prefix(l_grouped_rate_ptr) = 'CONTRIBUTIONS_CSG' then
        l_total_ee_csg := l_total_ee_csg +
                          nvl(tbl_ee_amount(l_grouped_rate_ptr),0);
      elsif tbl_cxt_prefix(l_grouped_rate_ptr) = 'CONTRIBUTIONS_REBATE' then
        tbl_er_amount(l_grouped_rate_ptr) :=
                                          tbl_er_amount(l_grouped_rate_ptr)*-1;
        l_total_er_deductions := l_total_er_deductions +
                                 nvl(tbl_er_amount(l_grouped_rate_ptr),0);
      end if;
      -- Do not print zeros
      --
      if tbl_row_base(l_grouped_rate_ptr) = 0 then
        tbl_row_base(l_grouped_rate_ptr) := null;
      end if;

      -- Write this line to the archive
      --
      pay_action_information_api.create_action_information (
        p_action_information_id       =>  l_action_info_id
      , p_action_context_id           =>  p_archive_assignment_action_id
      , p_action_context_type         =>  l_archive_type
      , p_action_information1         =>  tbl_cxt_prefix(l_grouped_rate_ptr)
      , p_action_information2         =>  l_rubric
      , p_action_information3         =>  l_grouped_rate_ptr
      , p_tax_unit_id                 =>  p_establishment_id
      , p_object_version_number       =>  l_ovn
      , p_action_information_category =>  l_context
      , p_action_information4         =>  l_rubric
      , p_action_information5         =>  l_description||l_retro_tl
      , p_action_information6         =>  l_append_dates
      , p_action_information7         =>  l_this_process_type
      , p_action_information9         =>  fnd_number.number_to_canonical(
                                              tbl_row_base(l_grouped_rate_ptr))
      , p_action_information10        =>  fnd_number.number_to_canonical(
                                               tbl_ee_rate(l_grouped_rate_ptr))
      , p_action_information11        =>  fnd_number.number_to_canonical(
                                             tbl_ee_amount(l_grouped_rate_ptr))
      , p_action_information12        =>  fnd_number.number_to_canonical(
                                               tbl_er_rate(l_grouped_rate_ptr))
      , p_action_information13        =>  fnd_number.number_to_canonical(
                                           tbl_er_amount(l_grouped_rate_ptr)));
      --
      l_grouped_rate_ptr := tbl_group_code.next(l_grouped_rate_ptr);
    end loop grouped_rate_loop;
    -- clear all the tables
    tbl_row_base.delete;
    tbl_ee_rate.delete;
    tbl_ee_amount.delete;
    tbl_er_rate.delete;
    tbl_er_amount.delete;
    tbl_cxt_prefix.delete;
    tbl_process_type.delete;
    tbl_group_code.delete;
    tbl_action_id.delete;
  end loop;  -- retro / non retro
  --
  -- pass back the total ee charges for further totals derivation
  --
  p_total_deduct_ee := l_total_ee_deductions;
  p_total_deduct_er := l_total_er_deductions;
  p_total_charge_ee := l_total_ee_deductions + l_total_ee_csg;
  p_total_charge_er := l_total_er_deductions;
  --
  hr_utility.trace('p_total_deduct_ee='|| p_total_deduct_ee);
  hr_utility.trace('p_total_deduct_er='|| p_total_deduct_er);
  hr_utility.trace('p_total_charge_ee='|| p_total_charge_ee);
  hr_utility.trace('p_total_charge_er='|| p_total_charge_er);
  --
  hr_utility.set_location('Leaving ' || l_proc, 210);
END load_deductions;
END pay_fr_arc_pkg;

/
