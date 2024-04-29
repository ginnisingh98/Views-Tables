--------------------------------------------------------
--  DDL for Package Body PAY_US_USER_INIT_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_USER_INIT_DEDN" As
/* $Header: pyusdtmp.pkb 120.11.12000000.2 2007/07/09 06:53:47 sudedas noship $ */

  g_proc constant varchar2(150) := 'PAY_US_User_Init_Dedn';

-- =============================================================================
-- create_user_init_template:
-- =============================================================================
function create_user_init_template
        (p_ele_name              in varchar2
        ,p_ele_reporting_name    in varchar2
        ,p_ele_description       in varchar2
        ,p_ele_classification    in varchar2
        ,p_ben_class_id          in number
        ,p_ele_category          in varchar2
        ,p_ele_processing_type   in varchar2
        ,p_ele_priority          in number
        ,p_ele_standard_link     in varchar2
        ,p_ele_proc_runtype      in varchar2
        ,p_ele_calc_rule         in varchar2
        ,p_ele_start_rule        in varchar2
        ,p_ele_stop_rule         in varchar2
        ,p_ele_partial_deduction in varchar2
        ,p_ele_arrearage         in varchar2
        ,p_ele_eff_start_date    in date
        ,p_ele_eff_end_date      in date
        ,p_employer_match        in varchar2
        ,p_after_tax_component   in varchar2
        ,p_ele_srs_plan_type     in varchar2
        ,p_ele_srs_buy_back      in varchar2
        ,p_roth_contribution     in varchar2
        ,p_userra_contribution   in varchar2
        ,p_bg_id                 in number
        ,p_catchup_processing    in varchar2
        ,p_termination_rule      in varchar2
         )
  return number is
--
-- =============================================================================
-- The input values are explained below : V-varchar2, D-Date, N-number
-- =============================================================================
-- Input-Name             Type   Valid Values/Explaination
-- ====================== ===== ================================================
-- p_ele_name             (V) - User i/p Element name
-- p_ele_reporting_name   (V) - User i/p reporting name
-- p_ele_description      (V) - User i/p Description
-- p_ele_classification   (V) - 'Pre-Tax Deductions'
-- p_ben_class_id         (N) - '' - not used
-- p_ele_category         (V) - 'E'/'G' (403B/457)
-- p_ele_processing_type  (V) - 'R'/'N' (Recurring/Non-recurring)
-- p_ele_priority         (N) - User i/p priority
-- p_ele_standard_link    (V) - 'Y'/'N'  (default N)
-- p_ele_proc_runtype     (V) - 'REG'/'ALL'
-- p_ele_calc_rule        (V) - 'FA'/'PE'  (Flat amount/Percentage)
-- p_ele_start_rule       (V) - 'ET'(Earnings threshold),'CHAINED',''
-- p_ele_stop_rule        (V) - 'OE'(On Entry), 'Total Reached'
-- p_ele_partial_deduction(V) - 'Y'/'N'
-- p_ele_arrearage        (V) - 'Y'/'N'
-- p_ele_eff_start_date   (D) - Trunc(start date)
-- p_ele_eff_end_date     (D) - Trunc(end date)
-- p_employer_match       (D) - 'Y'/'N'
-- p_after_tax_component  (V) - 'Y'/'N'
-- p_ele_srs_plan_type    (V) - 'N' (NONE), 'C' (DCP), 'B' (DBP)
-- p_ele_srs_buy_back     (V) - 'Y'/'N'
-- p_bg_id                (N) - Business group id
-- p_roth_contribution    (V) - Y= Creates the Roth AT element
-- p_userra_contribution  (V) - Y= Creates the USERRA elements
-- =============================================================================
--
   l_arrearage_create            varchar2(1);
   l_aftertax_nonrecurring_rule  varchar2(1);
   l_aftertax_si_rule            varchar2(1);
   l_at_er_exclusion_rule        varchar2(1);
   l_cu_si_exclusion_rule        varchar2(1);
   l_accr_bal_id                 number(9);
   l_arr_bal_id                  number(9);
   l_addl_bal_id                 number(9);
   l_at_element_type_id          number(9);
   l_at_sf_element_type_id       number(9);
   l_at_si_element_type_id       number(9);
   l_at_base_element_type_id     number(9);
   l_at_pri_bal_id               number(9);
   l_at_arr_bal_id               number(9);
   l_at_not_taken_bal_id         number(9);
   l_at_addl_bal_id              number(9);
   l_at_repl_bal_id              number(9);
   l_at_accr_bal_id              number(9);
   l_at_si_core_element_type_id  number(9);
   l_at_sf_core_element_type_id  number(9);
   l_base_element_type_id        number(9);
   l_cal_core_element_type_id    number(9);
   l_element_type_id             number(9);
   l_ele_obj_ver_number          number(9);
   l_fee_bal_id                  number(9);
   l_not_taken_bal_id            number(9);
   l_object_version_number       number(9);
   l_pri_bal_id                  number(9);
   l_repl_bal_id                 number(9);
   l_source_template_id          number(9);
   l_sf_element_type_id          number(9);
   l_sf_core_element_type_id     number(9);
   l_sf_ele_obj_ver_number       number(9);
   l_si_element_type_id          number(9);
   l_si_core_element_type_id     number(9);
   l_si_ele_obj_ver_number       number(9);
   l_template_id                 number(9);
   l_total_owed_create           varchar2(1);
   l_skip_formula                varchar2(30);
   l_er_element_type_id	         number(9);
   l_er_bal_id                   number(9);
   l_at_er_element_type_id       number(9);
   l_at_er_bal_id                number(9);
   l_etei_id                     number(9);
   l_etei_ovn                    number(9);
   l_srs_etei_id                 number(9);
   l_srs_etei_ovn                number(9);
   l_cu_element_type_id          number(9);
   l_cu_sf_element_type_id       number(9);
   l_cu_si_element_type_id       number(9);
   l_cur_temp                    number(9);
   l_cu_pri_bal_id               number(9);
   l_cu_addl_bal_id              number(9);
   l_cu_repl_bal_id              number(9);
   l_cu_ele_obj_ver_number       number(9);
   l_dummy                       number(9);
   l_glb_rowid                   rowid;
   l_glb_rowid1                  rowid;
   l_glb_id                      number(9);
   l_glb_id1                     number(9);
   l_glb_name1                   varchar2(50);
   l_glb_name                    varchar2(50);
   l_cu_accrued_bal_id           number(9);
   l_cu_nottaken_bal_id          number(9);
   l_cu_arrears_bal_id           number(9);
   l_bb_nottaken_bal_id          number(9);
   l_bb_arrears_bal_id           number(9);
   l_jd_core_element_type_id     number;
   l_jd_ele_obj_ver_number       number;
   l_cu_proc_inp_value_id        number;
   l_vol_ded_bal_id              number(9);
   --l_ver_core_element_type_id    NUMBER(9);
   l_dbp_exclusion_rule          varchar2(1);
   l_dcp_exclusion_rule          varchar2(1);
   l_bb_element_type_id          number(9);
   l_bb_sf_element_type_id       number(9);
   l_bb_si_element_type_id       number(9);
   l_bb_pri_bal_id               number(9);
   l_bb_addl_bal_id              number(9);
   l_bb_repl_bal_id              number(9);
   l_bb_ele_obj_ver_number       number(9);
   l_bb_accrued_bal_id           number(9);
   l_er_contr_element_type_id    number(9);
   l_er_contr_pri_bal_id         number(9);
   l_er_contr_ele_obj_ver_number number(9);
   l_ele_category                varchar2(20);
   -- Added by sdahiya for involuntary deductions
   l_ca_ele_obj_ver_number        number(9);
   l_pri_ele_obj_ver_number       number(9);
   l_fee_ele_obj_ver_number       number(9);
   l_ver_ele_obj_ver_number       number(9);
   l_ca_element_type_id           number(9);
   l_pri_element_type_id          number(9);
   l_fee_element_type_id          number(9);
   l_ver_element_type_id          number(9);
   l_element_information_category varchar2(30);
   l_fees_core_element_type_id    number(9);
   l_inv_ded                      varchar2(22);
   l_accr_fees_bal_id             number(9);
   l_srs_ercontr_type_id          pay_element_types_f.element_type_id%type;
   l_srs_ercontr_obj_ver_number   pay_element_types_f.object_version_number%type;
   l_srs_ercontr_rep_name         pay_element_types_f.reporting_name%type;
   l_srs_ercontr_desc_name        pay_element_types_f.description%type;
   -- USERRA Changes
   l_pt_userra_si_rule            varchar2(2);
   l_pt_userra_rule               varchar2(2);
   l_pt_userra_er_rule            varchar2(2);
   l_atr_userra_si_rule           varchar2(2);
   l_atr_userra_rule              varchar2(2);
   l_atr_userra_er_rule           varchar2(2);
   -- Roth Changes
   l_at_roth_si_rule              varchar2(2);
   l_at_roth_er_rule              varchar2(2);
   l_roth_ele_type_id             number(15);
   l_roth_si_ele_type_id          number(15);
   l_roth_sf_ele_type_id          number(15);
   l_roth_eligiCmp_ipv_id         number(15);
   l_atr_pri_bal_id               number(15);
   l_atr_addl_bal_id              number(15);
   l_atr_repl_bal_id              number(15);
   l_atr_element_type_id          number(15);
   l_atr_er_element_type_id       number(15);
   l_atr_si_element_type_id       number(15);
   l_atr_sf_element_type_id       number(15);
   l_atr_er_bal_id                number(15);
   l_atr_accr_bal_id              number(15);
   l_atr_not_taken_bal_id         number(15);
   l_atr_arr_bal_id               number(15);
   l_roth_er_ele_type_id          number(15);

   -- Bug# 4676867: Impact of Roth on Involuntary Deductions
   l_ele_information1             varchar2(100) ;
   l_relative_processing_priority number(15) ;

   l_ben_class_name             ben_benefit_classifications.benefit_classification_name%type;
   type r_temp_var is record
                     (sub_name  pay_element_types_f.element_name%type);
   type t_temp_var is table of  r_temp_var
        index by binary_integer;
   l_temp_var                   t_temp_var;
   --
   l_proc   varchar2(80);
   --
   -- Get the element type id for a given template id
   --
   cursor c1 (c_ele_name varchar2) is
   select element_type_id, object_version_number
     from pay_shadow_element_types
    where template_id    = l_template_id
      and element_name   = c_ele_name;
   --
   -- Cursor to fetch the core element id
   --
   cursor c5 (c_element_name in varchar2) is
   select ptco.core_object_id
   from   pay_shadow_element_types  psbt,
          pay_template_core_objects ptco
   where  psbt.template_id      = l_template_id
     and  psbt.element_name     = c_element_name
     and  ptco.template_id      = psbt.template_id
     and  ptco.shadow_object_id = psbt.element_type_id
     and  ptco.core_object_type = 'ET';
   --
   -- Cursor to get Input Value ID's for the AT Element
   --
   cursor c_at_ivn(p_element_type_id in number) is
   select input_value_id, name
     from pay_input_values_f
    where element_type_id  = p_element_type_id
      and name in ('Take Overlimit AT',
                   'AT Processing Order')
      and business_group_id = p_bg_id ;
   --
   -- Cursor to get Input Value ID's for the Roth Element
   --
   cursor c_atr_ivn(p_element_type_id in number) is
   select input_value_id, name
     from pay_input_values_f
    where element_type_id  = p_element_type_id
      and name in ('Take Overlimit Roth',
                   'Roth Processing Order')
      and business_group_id = p_bg_id ;

   --
   -- Cursor to check if EMPLOYER_MATCH_PCT global value was created.
   --
   cursor c_global is
   select 1
     from ff_globals_f
    where business_group_id = p_bg_id
      and global_name = 'EMPLOYER_MATCH_PCT';
   --
   -- Cursor to check if EMPLOYER_MATCH_LIMIT global value was created.
   --
   cursor c_global1 is
   select 1
     from ff_globals_f
    where business_group_id = p_bg_id
      and global_name = 'EMPLOYER_MATCH_LIMIT';
   --
   -- Get the benefit classification name
   --
   cursor c_ben_class (l_ben_class_id in varchar2) is
   select benefit_classification_name
     from ben_benefit_classifications
    where benefit_classification_id = l_ben_class_id
      and legislation_code          = 'US';
   --
   -- Pre Tax Arrearage
   --
   cursor c_iter_formula  is
   select formula_id
     from ff_formulas_f
    where formula_name     = 'US_ITERATIVE_PRETAX'
      and legislation_code = 'US';
   --
   -- Cursor to make Pay Value non user enterable
   --
   cursor csr_ele ( c_effective_date in date
                   ,c_ele_prefix     in varchar2 ) is
   select pet.element_name
         ,pet.element_type_id
         ,piv.name
         ,piv.input_value_id
         ,piv.mandatory_flag
     from pay_element_types_f pet
         ,pay_input_values_f  piv
    where (pet.element_name like c_ele_prefix||'% Special Inputs'
           or
           pet.element_name like c_ele_prefix||'% SI' )
      and piv.element_type_id   = pet.element_type_id
      and piv.name              ='Pay Value'
      and pet.business_group_id = p_bg_id
      and piv.business_group_id = p_bg_id
      and c_effective_date between pet.effective_start_date
                               and pet.effective_end_date
      and c_effective_date between piv.effective_start_date
                               and piv.effective_end_date;
   --
   -- For the balance architecture changes
   -- as per US Payroll Team request - 02-APR-03
   --
   cursor get_asg_gre_run_dim_id is
   select balance_dimension_id
     from pay_balance_dimensions
    where dimension_name   = 'Assignment within Government Reporting Entity Run'
      and legislation_code = 'US';
   --
   l_asg_gre_run_dim_id     pay_balance_dimensions.balance_dimension_id%type;
   l_iter_formula_id        ff_formulas_f.formula_id%type;
   l_iter_priority          pay_element_types_f.iterative_priority%type;
   l_priority_inc           number;
   l_ele_template_priority  number;
   l_template_priority      number;
   --
-- =============================================================================
-- get_jd_bal_id:
-- =============================================================================
  function get_jd_bal_id
          (p_jd_bal_name in varchar2
          ) return number is

   l_bal_id       number := null ;
   l_proc         varchar2(200);
   cursor c_bal is
   select balance_type_id
     from pay_balance_types
     where balance_name = p_jd_bal_name
      and legislation_code = 'US';
  begin
   l_proc := g_proc||'.get_template_id';
   hr_utility.set_location('Entering: '||l_proc, 5);
   --
   for temp_rec in c_bal loop
     l_bal_id := temp_rec.balance_type_id;
   end loop;
   hr_utility.set_location('Leaving: '||l_proc, 10);
   return l_bal_id;
   --
  end;
-- =============================================================================
-- get_cu_input_value_id:
-- =============================================================================
  function get_cu_input_value_id
          (p_element_type_id  in number
          ) return number is

   l_input_value_id       number := null ;
   l_proc                 varchar2(200);

   cursor c_bal is
   select input_value_id
     from pay_input_values_f
     where element_type_id  = p_element_type_id
      and  name = 'Catchup Processing'
      and  business_group_id = p_bg_id ;

  begin
   l_proc := g_proc||'.get_template_id';
   hr_utility.set_location('Entering: '||l_proc, 5);

   for temp_rec in c_bal loop
     l_input_value_id := temp_rec.input_value_id;
   end loop;
   hr_utility.set_location('Leaving: '||l_proc, 10);
   return l_input_value_id;

  end;
-- =============================================================================
-- get_template_id:
-- =============================================================================
  function get_template_id
          (p_legislation_code    in varchar2,
           p_ele_category        in varchar2,
           p_ele_srs_plan_type   in varchar2
           ) return number is

   l_template_id   number(9);
   l_template_name varchar2(80);
   l_proc          varchar2(60);
   l_ele_category  varchar2(30);

   cursor c4  is
   select template_id,base_processing_priority
     from pay_element_templates
    where template_name     = l_template_name
      and legislation_code  = p_legislation_code
      and template_type     = 'T'
      and business_group_id is null;
    --
  begin
    --
    l_proc := g_proc||'.get_template_id';
    hr_utility.set_location('Entering: '||l_proc, 10);

    l_ele_category := p_ele_category;
    if p_ele_srs_plan_type = 'C' then
       l_ele_category := 'DCP';
    elsif p_ele_srs_plan_type = 'B' then
       l_ele_category := 'DBP';
    end if;
    --
    if l_ele_category  = 'E' then
       l_template_name := '403b Deduction 2002';
       l_iter_priority := 60;
    -- Modified for Garnishment rewrite
    elsif l_ele_category = 'G' and p_ele_classification <> l_inv_ded then
       l_template_name := '457 Deduction 2002';
       l_iter_priority := 50;

    elsif l_ele_category = 'D' then
       l_template_name := '401K Deduction 2002';
       l_iter_priority := 70;

    elsif l_ele_category = 'DBP' then
       l_template_name := 'State Retirement Plan';
       l_iter_priority := 30;

    elsif l_ele_category = 'DCP' then
       l_template_name := 'State Retirement Plan';
       l_iter_priority := 20;

    elsif l_ele_category = 'S' then /* Dependent Care 125 */
       l_template_name := 'Dependent Care'; /*Bug:3452933 */
       l_iter_priority := 40;

    elsif l_ele_category = 'H' then /* Health Care 125 */
       l_template_name := '125 Deduction';
       l_iter_priority := 80;

    elsif l_ele_category in ('AY','CS','SS') then
       l_template_name := 'Alimony';
       l_iter_priority := 10;

    elsif l_ele_category = 'BO' then
       l_template_name := 'Bankruptcy';
       l_iter_priority := 10;

    elsif l_ele_category in ('CD','G') then
       l_template_name := 'Credit Debt';
       l_iter_priority := 10;

    elsif l_ele_category = 'EL' then
       l_template_name := 'Educational Loan';
       l_iter_priority := 10;

    elsif l_ele_category = 'ER' then
       l_template_name := 'Employee Requested';
       l_iter_priority := 10;

    elsif l_ele_category = 'TL' then
       l_template_name := 'Tax Levy';
       l_iter_priority := 10;

    elsif l_ele_category = 'DCIA' then
       l_template_name := 'DCIA';
       l_iter_priority := 10;

    else
       -- added by kumar thirmiya
       -- only 403b,457,401K and all the userdefined category will be passed this procedure so
       -- if it is other than the above three use the Other Pretax Deduction template
       l_template_name  := 'Other Pretax Deduction';
       l_iter_priority := 10;

    end if;
    --
    hr_utility.set_location(l_proc, 30);
    --
    for c4_rec in c4 loop
       l_template_id   := c4_rec.template_id;
       l_ele_template_priority := c4_rec.base_processing_priority;
    end loop;
    --
    if l_ele_category = 'S' then

       l_ele_template_priority := l_ele_template_priority + 175;

    elsif  l_ele_category = 'DCP' then

       l_ele_template_priority := l_ele_template_priority + 50;

    end if;

    hr_utility.set_location('Leaving: '||l_proc, 50);
    --
    return l_template_id;
      --
   end get_template_id;
   --
-- =============================================================================
-- create_eligible_comp_bal_feeds:
-- =============================================================================
   procedure create_eligible_comp_bal_feeds is

    l_row_id             rowid;
    l_balance_feed_id    pay_balance_feeds_f.balance_feed_id%type;
    l_proc               varchar2(160);
    --
	-- added hint no_merge(pbf) for bug 5187416
    cursor c1_get_reg_earn_feeds is
    -- Commenting this section for Performance Issue

    --select /*+ no_merge(pbf) */ bc.classification_id
    /*    ,pbf.input_value_id
          ,pbf.scale
          ,pbf.element_type_id
      from pay_balance_feeds_v         pbf,
           pay_balance_classifications bc
     where nvl(pbf.balance_initialization_flag,'N') = 'N'
       and nvl(pbf.business_group_id,p_bg_id) = p_bg_id
       and nvl(pbf.legislation_code, 'US') = 'US'
       and pbf.balance_name   = 'Regular Earnings'
       and bc.balance_type_id = pbf.balance_type_id
      order by pbf.element_name;
      */
    -- Changed the above Cusror, replacing View with Base Tables
    -- Removed 'Order By' Clause (Bug# 5724902)

    select     /*+ no_merge(BF) */
               bc.classification_id
              ,bf.input_value_id
              ,bf.scale
              ,et.element_type_id
          from pay_balance_classifications bc
                , PAY_BALANCE_FEEDS_F BF
                , PAY_BALANCE_TYPES BT
                , PAY_INPUT_VALUES_F IV
                , PAY_ELEMENT_TYPES_F ET
                , PAY_ELEMENT_CLASSIFICATIONS EC
                , HR_LOOKUPS HL
                , HR_LOOKUPS HL2
                , FND_SESSIONS SES
    WHERE       BT.BALANCE_TYPE_ID = BF.BALANCE_TYPE_ID
    AND         IV.INPUT_VALUE_ID = BF.INPUT_VALUE_ID
    AND         ET.ELEMENT_TYPE_ID = IV.ELEMENT_TYPE_ID
    AND         EC.CLASSIFICATION_ID = ET.CLASSIFICATION_ID
    AND         HL.LOOKUP_TYPE = 'ADD_SUBTRACT'
    AND         HL.LOOKUP_CODE = BF.SCALE
    AND         HL2.LOOKUP_TYPE = 'UNITS'
    AND         HL2.LOOKUP_CODE = IV.UOM
    AND         SES.SESSION_ID = USERENV('SESSIONID')
    AND         SES.EFFECTIVE_DATE BETWEEN BF.EFFECTIVE_START_DATE
        AND         BF.EFFECTIVE_END_DATE
    AND         SES.EFFECTIVE_DATE BETWEEN IV.EFFECTIVE_START_DATE
        AND         IV.EFFECTIVE_END_DATE
    AND         SES.EFFECTIVE_DATE BETWEEN ET.EFFECTIVE_START_DATE
        AND ET.EFFECTIVE_END_DATE
    AND         BC.BALANCE_TYPE_ID = BF.BALANCE_TYPE_ID
    AND         nvl(EC.BALANCE_INITIALIZATION_FLAG , 'N') = 'N'
    AND         nvl(BF.BUSINESS_GROUP_ID, p_bg_id) = p_bg_id
    AND         nvl(BF.LEGISLATION_CODE, 'US') = 'US'
    AND         BT.BALANCE_NAME = 'Regular Earnings' ;

    -- To get the balance type id
    cursor c2_balance_type is
    select balance_type_id
      from pay_balance_types
     where business_group_id =  p_bg_id
       and balance_name in (p_ele_name||' Eligible Comp',
                            p_ele_name||' Roth Eligible Comp',
                            p_ele_name||' AT Eligible Comp');
  begin
    l_proc := g_proc||'.create_eligible_comp_bal_feeds';
    hr_utility.set_location('Entering: '||l_proc, 5);
    for c1_rec in c1_get_reg_earn_feeds loop
      for c2_rec in c2_balance_type loop
          pay_balance_feeds_f_pkg.insert_row
         (x_rowid                => l_row_id,
          x_balance_feed_id      => l_balance_feed_id,
          x_effective_start_date => p_ele_eff_start_date,
          x_effective_end_date   => hr_api.g_eot,
          x_business_group_id    => p_bg_id,
          x_legislation_code     => null,
          x_balance_type_id      => c2_rec.balance_type_id,
          x_input_value_id       => c1_rec.input_value_id,
          x_scale                => c1_rec.scale,
          x_legislation_subgroup => null,
          x_initial_balance_feed => false
          );
          l_balance_feed_id := null;
          l_row_id          := null;
      end loop;
    end loop;
    hr_utility.set_location('Leaving: '||l_proc, 10);
  end create_eligible_comp_bal_feeds;
   --
-- =============================================================================
-- get_object_id:
-- =============================================================================
  function get_object_id
          (p_object_type  in varchar2,
           p_object_name  in varchar2
           ) return number is
   --
   l_object_id  number  := null;
   l_proc       varchar2(200);
   --
   cursor c2 (c_object_name varchar2) is
   select element_type_id
     from pay_element_types_f
    where element_name      = c_object_name
      and business_group_id = p_bg_id;
   --
   cursor c3 (c_object_name in varchar2) is
   select ptco.core_object_id
     from pay_shadow_balance_types psbt,
          pay_template_core_objects ptco
    where psbt.template_id      = l_template_id
      and psbt.balance_name     = c_object_name
      and ptco.template_id      = psbt.template_id
      and ptco.shadow_object_id = psbt.balance_type_id;
   --
  begin
    l_proc := g_proc||'.get_object_id';
    hr_utility.set_location('Entering: '||l_proc, 10);
    --
    if p_object_type = 'ELE' then
       for c2_rec in c2 (p_object_name) loop
            l_object_id := c2_rec.element_type_id;  -- element id
       end loop;
    elsif p_object_type = 'BAL' then
       for c3_rec in c3 (p_object_name) loop
          l_object_id := c3_rec.core_object_id;   -- balance id
       end loop;
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc, 50);
    --
    return l_object_id;
    --
   end get_object_id;

-- =============================================================================
-- get_elgicomp_ipv: to get the Eligible comp option Input value Id.
-- =============================================================================
  function get_elgicomp_ipv
          (p_element_type_id  in number
           ) return number is

   l_input_value_id  number := null ;
   l_proc            varchar2(200);

   cursor c_bal is
   select input_value_id
     from pay_input_values_f
    where element_type_id   = p_element_type_id
      and name              = 'Eligible Comp Option'
      and business_group_id = p_bg_id ;

  begin

    l_proc := g_proc||'.get_elgicomp_ipv';
    hr_utility.set_location('Entering: '||l_proc, 5);

    for temp_rec in c_bal loop
      l_input_value_id := temp_rec.input_value_id;
    end loop;
    hr_utility.set_location('Leaving: '||l_proc, 10);
    return l_input_value_id;

  end get_elgicomp_ipv;
-- =============================================================================
-- get_element_and_balance_ids:
-- =============================================================================
  procedure get_element_and_bal_ids is
    --
    l_proc  varchar2(200);
    l_eligicmp_ipv_id        number(9);
    --
  begin
    l_proc := g_proc||'.get_element_and_bal_ids';
    hr_utility.set_location('Entering: '||l_proc, 10);
    --
    l_base_element_type_id    := get_object_id('ELE',p_ele_name);
    -- Added to check the ER match element is exist for base element.
    -- If not, then set the default_value to S_EE and lookup_type
    -- to US_ELIGIBLE_COMP_OPTIONS_EE
    if nvl(p_employer_match ,'N') = 'N' then
        --Added to get input value id for eligible Compensation option
         l_eligiCmp_ipv_id := get_elgiComp_ipv (l_base_element_type_id);
         update pay_input_values_f
            set default_value = 'S_EE'
               ,lookup_type   = 'US_ELIGIBLE_COMP_OPTIONS_EE'
          where input_value_id = l_eligicmp_ipv_id;
    end if;
    -- Code to get ids for catchup objects.
    if nvl(p_catchup_processing ,'NONE') <> 'NONE' then
       l_cu_element_type_id    := get_object_id('ELE',p_ele_name||' Catchup');
       l_cu_si_element_type_id := get_object_id('ELE',p_ele_name||' Catchup SI');
       l_cu_sf_element_type_id := get_object_id('ELE',p_ele_name||' Catchup SF');
       l_cu_pri_bal_id         := get_object_id('BAL', p_ele_name||' Catchup');
       l_cu_addl_bal_id        := get_object_id('BAL', p_ele_name||' Catchup Additional Amt');
       l_cu_repl_bal_id        := get_object_id('BAL', p_ele_name||' Catchup Replacement Amt');
       l_cu_accrued_bal_id     := get_object_id('BAL', p_ele_name||' Catchup Accrued');
       l_cu_nottaken_bal_id    := get_object_id('BAL', p_ele_name||' Catchup Not Taken');
       -- Attach the arrears balance only if Arrearage is selected in the Ded. form.
       if p_ele_arrearage = 'Y' then
          l_cu_arrears_bal_id  := get_object_id('BAL', p_ele_name||' Catchup Arrears');
       end if;
    end if;
    --
    -- Code to get ids for SRS objects.
    --
    if (p_ele_category in ('DCP', 'DBP')) or
       (NVL(p_ele_srs_plan_type, 'N') <> 'N')  then
       -- Means that the Category is SRS type.
       -- Check for the Buy Back Flag and get Id's for the Buy back element
       if p_ele_srs_buy_back = 'Y' then
          l_bb_element_type_id    := get_object_id('ELE',p_ele_name||' Buy Back');
          l_bb_si_element_type_id := get_object_id('ELE',p_ele_name||' Buy Back SI');
          l_bb_sf_element_type_id := get_object_id('ELE',p_ele_name||' Buy Back SF');
          l_bb_pri_bal_id         := get_object_id('BAL',p_ele_name||' Buy Back');
          l_bb_addl_bal_id        := get_object_id('BAL',p_ele_name||' Buy Back Additional Amt');
          l_bb_repl_bal_id        := get_object_id('BAL',p_ele_name||' Buy Back Replacement Amt');
          l_bb_accrued_bal_id     := get_object_id('BAL',p_ele_name||' Accrued Buy Back');
          l_bb_nottaken_bal_id    := get_object_id('BAL',p_ele_name||' Buy Back Not Taken');
          -- Attach the arrears balance only if Arrearage is selected in the Ded. form.
          if p_ele_arrearage = 'Y' then
             l_bb_arrears_bal_id  := get_object_id('BAL', p_ele_name||' Buy Back Arrears');
          end if;
       end if;
        -- Get object Id's for ER contribution Element
        l_er_contr_element_type_id := get_object_id('ELE',p_ele_name||' ER Contribution');
        l_er_contr_pri_bal_id      := get_object_id('BAL',p_ele_name||' ER Contribution');
    end if;
    l_si_core_element_type_id := get_object_id('ELE',p_ele_name||' Special Inputs');
    l_sf_core_element_type_id := get_object_id('ELE',p_ele_name||' Special Features');
    l_fees_core_element_type_id := get_object_id('ELE',p_ele_name||' Fees');
    -- Added for Garnishment Rewrite --
    if p_ele_classification = l_inv_ded then
        --l_ver_core_element_type_id := get_object_id('ELE',p_ele_name||' Verifier');
        l_cal_core_element_type_id := get_object_id('ELE',p_ele_name||' Calculator');
    end if;
    --
    -- Get the Id for the JD Element. Modified for Garnishment rewrite
    --
    if p_ele_category in ('D','E','G')and
       p_ele_classification <> l_inv_ded then
       l_jd_core_element_type_id :=
          get_object_id('ELE', p_ele_name||' Taxable By JD');
    end if;
    l_pri_bal_id   := get_object_id('BAL', p_ele_name);

    -- Added for Garnishment rewrite --
    if p_ele_classification = l_inv_ded then
      l_addl_bal_id      := get_object_id('BAL', p_ele_name||' Additional');
      l_repl_bal_id      := get_object_id('BAL', p_ele_name||' Replacement');
      l_fee_bal_id       := get_object_id('BAL', p_ele_name||' Fees');
      l_accr_fees_bal_id := get_object_id('BAL',p_ele_name||' Accrued Fees');
      l_vol_ded_bal_id   := get_object_id('BAL', p_ele_name||' Vol Dedns');
    else
      l_addl_bal_id  := get_object_id('BAL', p_ele_name||' Additional Amount');
      l_repl_bal_id  := get_object_id('BAL', p_ele_name||' Replacement Amount');
    end if;

    l_accr_bal_id  := get_object_id('BAL', p_ele_name||' Accrued');
    l_not_taken_bal_id := get_object_id('BAL', p_ele_name||' Not Taken');

    if p_ele_arrearage = 'Y' then
       l_arr_bal_id := get_object_id('BAL', p_ele_name||' Arrears');
    end if;
    --
    -- Get the input value id for Catchup Processing
    --
    if nvl(p_catchup_processing ,'NONE') <> 'NONE' then
       l_cu_proc_inp_value_id
         := get_cu_input_value_id (l_cu_element_type_id);
       --
       -- Update the Default Value for Catchup Processing
       -- to the one selected in the deductions form.
       --
       update pay_input_values_f
          set default_value  = substr(p_catchup_processing,1,1)
        where input_value_id = l_cu_proc_inp_value_id;
    end if;
    --
    -- Get the id's for the AT components if the After Tax component is Y
    --
    if p_after_tax_component = 'Y' then
        -- element ids
        l_at_base_element_type_id := get_object_id('ELE', p_ele_name||' AT');
        l_at_si_core_element_type_id :=
           get_object_id ('ELE', p_ele_name||' AT Special Inputs');
        l_at_sf_core_element_type_id :=
           get_object_id ('ELE', p_ele_name||' AT Special Features');
        -- balance id's
        l_at_pri_bal_id  := get_object_id('BAL', p_ele_name||' AT');
        l_at_addl_bal_id := get_object_id('BAL', p_ele_name||' AT Additional Amount');
        l_at_repl_bal_id := get_object_id('BAL', p_ele_name||' AT Replacement Amount');
        if p_ele_arrearage = 'Y' then
           l_at_arr_bal_id  :=
             get_object_id('BAL', p_ele_name||' AT Arrears');
           l_at_not_taken_bal_id :=
             get_object_id('BAL', p_ele_name||' AT Not Taken');
        end if;
        if p_ele_stop_rule = 'Total Reached' then
           l_at_accr_bal_id :=
             get_object_id('BAL', p_ele_name||' AT Accrued');
        end if;
    end if;
    --
    -- Update the Input value with the correct lookup code if CU is not
    -- chosen and just AT is chosen.
    --
    if p_after_tax_component = 'Y' and
       p_catchup_processing = 'NONE' then
      for temp_rec in c_at_ivn(l_at_base_element_type_id)
      loop
        if temp_rec.name = 'Take Overlimit AT' then
           update pay_input_values_f
              set lookup_type = 'PQP_US_OVERLIMIT_AT1'
            where input_value_id = temp_rec.input_value_id;
        elsif temp_rec.name = 'AT Processing Order' then
           update pay_input_values_f
              set lookup_type = 'PQP_US_AT_PROCESSING_ORDER1'
            where input_value_id = temp_rec.input_value_id;
        end if;
      end loop;
    end if;
    --
    --  Get the pre-tax ER and After-Tax ER balance
    --
    if p_employer_match = 'Y' then
        -- element id
        l_er_element_type_id := get_object_id('ELE', p_ele_name||' ER');
        -- balance id
        l_er_bal_id := get_object_id('BAL',  p_ele_name||' ER');
        if p_after_tax_component = 'Y' then
           l_at_er_element_type_id := get_object_id('ELE', p_ele_name||' AT ER');
           l_at_er_bal_id := get_object_id('BAL',  p_ele_name||' AT ER');
        end if;
    end if;
    --
    -- Check if element has Roth Contribution, option valid for 401k/403b only
    --
    if nvl(p_roth_contribution,'N') = 'Y' then

       l_roth_ele_type_id := get_object_id('ELE',p_ele_name||' Roth');

       -- If employer match is not selected then change the lookup type for
       -- eligible comp option for Roth 401k AT element
       if nvl(p_employer_match ,'N') = 'N' and
          p_ele_category in ('D') then
         l_roth_eligiCmp_ipv_id := get_elgiComp_ipv (l_roth_ele_type_id);
         if l_roth_eligiCmp_ipv_id is not null then
            update pay_input_values_f
               set default_value  = 'S_EE'
                  ,lookup_type    = 'US_ELIGIBLE_COMP_OPTIONS_EE'
             where input_value_id = l_roth_eligiCmp_ipv_id;
         end if;
       end if;

       -- Get the Roth ER Match element and primary balance
       if p_employer_match = 'Y' then
          l_roth_er_ele_type_id := get_object_id('ELE',p_ele_name||' Roth ER');
          l_atr_er_bal_id := get_object_id('BAL', p_ele_name||' Roth ER');
       end if;
       --
       l_roth_si_ele_type_id := get_object_id('ELE',p_ele_name||' Roth SI');
       l_roth_sf_ele_type_id := get_object_id('ELE',p_ele_name||' Roth SF');

       -- Get the primary Roth AT element's balance id
       l_atr_pri_bal_id := get_object_id('BAL', p_ele_name||' Roth');
       -- If element processing is Recurring the get the Rep. and Add. balance
       if p_ele_processing_type = 'R' then
         l_atr_addl_bal_id :=
           get_object_id('BAL', p_ele_name||' Roth Additional Amount');
         l_atr_repl_bal_id :=
           get_object_id('BAL', p_ele_name||' Roth Replacement Amount');
       end if;

       -- If Arrearage is selected then get the Arrears and Not taken balance
       if p_ele_arrearage = 'Y' then
          l_atr_arr_bal_id :=
            get_object_id('BAL', p_ele_name||' Roth Arrears');
       end if;
       --
       l_atr_not_taken_bal_id
            :=  get_object_id('BAL', p_ele_name||' Roth Not Taken');
       -- If element has stop rule
       if p_ele_stop_rule = 'Total Reached' then
          l_atr_accr_bal_id :=
            get_object_id('BAL', p_ele_name||' Roth Accrued');
       end if;
       -- If catch-up processing is selected
       if p_catchup_processing = 'NONE' then
         for temp_rec in c_atr_ivn(l_roth_er_ele_type_id)
         loop
           if temp_rec.name = 'Take Overlimit Roth' then
              update pay_input_values_f
                 set lookup_type = 'PQP_US_OVERLIMIT_AT1'
               where input_value_id = temp_rec.input_value_id;
           elsif temp_rec.name = 'Roth Processing Order' then
              update pay_input_values_f
                 set lookup_type = 'PQP_US_AT_PROCESSING_ORDER1'
               where input_value_id = temp_rec.input_value_id;
           end if;
         end loop;
       end if;

    end if; --if nvl(p_roth_contribution,'N')
    --
    hr_utility.set_location('Leaving: '||l_proc, 100);
    --
   end get_element_and_bal_ids;
   --
-- =============================================================================
-- insert_iterative_rules:
-- =============================================================================
  procedure insert_iterative_rules
           (p_iter_element_type_id pay_element_types_f.element_type_id%type
            ) is

    l_proc varchar2(160);

  begin
    l_proc := g_proc||'.insert_iterative_rules';
    hr_utility.set_location('Entering: '||l_proc, 5);

    insert into pay_iterative_rules_f
    (iterative_rule_id
    ,element_type_id
    ,effective_start_date
    ,effective_end_date
    ,result_name
    ,iterative_rule_type
    ,input_value_id
    ,severity_level
    ,business_group_id
    ,legislation_code
    ,object_version_number
    ,created_by
    ,creation_date
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    )
    values
    (pay_iterative_rules_s.nextval
    ,p_iter_element_type_id
    ,p_ele_eff_start_date
    ,to_date('31-12-4712','DD-MM-YYYY')
    ,'STOPPER'
    ,'S'
    ,null
    ,null
    ,p_bg_id
    ,'US'
    ,1
    ,-1
    ,p_ele_eff_start_date
    ,p_ele_eff_start_date
    ,-1
    ,-1
    );
    hr_utility.set_location('Leaving: '||l_proc, 10);
  end insert_iterative_rules;

-- =============================================================================
--                          Main Function
-- =============================================================================
  begin
   --hr_utility.trace_on(null,'tmehra');
   l_proc := g_proc||'.create_user_init_template';
   hr_utility.set_location('Entering : '||l_proc, 10);
   --
   -- Initialize local variables
   --
   l_at_er_exclusion_rule := 'N';
   l_cu_si_exclusion_rule := 'N';
   l_glb_name1            := 'EMPLOYER_MATCH_LIMIT';
   l_glb_name             := 'EMPLOYER_MATCH_PCT';
   l_dbp_exclusion_rule   := 'N';
   l_dcp_exclusion_rule   := 'N';
   l_inv_ded              := 'Involuntary Deductions';
   --
   -- Set local variable for ele information category
   --
   if p_ele_classification = l_inv_ded then
      l_element_information_category := 'US_INVOLUNTARY DEDUCTIONS';
   else
      l_element_information_category := 'US_PRE-TAX DEDUCTIONS';
   end if;
   --
   -- Set session date
   --
   pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
   --
   hr_utility.set_location(l_proc, 20);
   --
   -- Get Source Template ID
   --
   l_source_template_id := get_template_id
                          (p_legislation_code  => 'US'
                          ,p_ele_category      => p_ele_category
                          ,p_ele_srs_plan_type => NVL(p_ele_srs_plan_type,'NONE')
                           );
   hr_utility.set_location(l_proc, 30);
   --
  /*
  ==============================================================================
  create the user structure the Configuration Flex segments for the
  Exclusion Rules are as follows:
  ==============================================================================
    Config1  -- exclude SI and SF elements if ele_processing_type='N'
    Config2  -- exclude Arrearage related structures if ele_arrearage='N'
    Config3  -- exclude Partial Deductions structures if
             --         ele_partial_deduction='N'
    Config4  -- exclude Stop rule structures if ele_stop_rule='Total Reached'
             --         default is OE -On entry
    Config5  -- exclude Start rule structures. Default is '', excludes if
             -- ET(Earnings Threshold),  Chained is not supported in 403/457
    Config6  -- exclude After tax element structures if after_tax_component='N'
    Config7  -- exclude Employer Match element structures if employer_match='N'
    Config8  -- exclude Non Recurring-After tax structures if
             --         after_tax_component='Y' and ele_processing_type='N'
    Config9  -- exclude DCP elements
    Config10 -- exclude Flat amt calculation structures if ele_calc_rule=FA
    Config11 -- exclude Percentage calculation structures if ele_calc_rule=PE
    Config12 -- exclude AT-ER element if either employer_match or
             --         after_tax_component = 'N'
    Config13 -- exclude catchup processing
    Config14 -- exclude Buy Back element if p_ele_srs_buy_back = 'N'
    Config15 -- exclude DBP elements
    Config16 -- exclude the CatchUp SI when base is non-recurring
    Config17 -- exclude the After-Tax SI when base is non-recurring
    Config18 -- Roth contribution for 401k
    Config19 -- exclude After-Tax Roth SI when base is non-recurring
    Config20 -- exclude Roth ER match element when ER component is not selected

    Config21 -- rule to create Pre-tax USERRA element
    Config22 -- rule to create Pre-tax USERRA element
    Config23 -- rule to create Pre-tax USERRA element

    Config24 -- rule to create After-Tax USERRA element
    Config25 -- rule to create After-Tax USERRA element
    Config26 -- rule to create After-Tax USERRA element
    Config27 -- rule to create balance feeds for W2 Roth 403b
    Config28 -- rule to create balance feeds for W2 Roth 401k
   =============================================================================
  */
   --
   -- set the aftertax nonrecurring rule(config8)
   --
   if p_after_tax_component = 'N' then
      l_aftertax_nonrecurring_rule := 'N';
   elsif p_ele_processing_type = 'N' then
      l_aftertax_nonrecurring_rule := 'N';
   else
      l_aftertax_nonrecurring_rule := 'Y';
   end if;
   -- AT Special Inputs created only for Recurring processing type
   -- Config17: Exclude the After-Tax SI when base is non-recurring
   if p_after_tax_component = 'Y' and
      p_ele_processing_type = 'R' then
      l_aftertax_si_rule := 'Y';
   else
      l_aftertax_si_rule := 'N';
   end if;
   -- Config16: The Catch Special Inputs should only be
   -- created for recurring base element.
   if p_catchup_processing ='NONE' or
      p_ele_processing_type='N'    then
      l_cu_si_exclusion_rule := 'N';
   elsif p_catchup_processing <> 'NONE' and
         p_ele_processing_type <> 'N'   then
         l_cu_si_exclusion_rule := 'Y';
   end if;
   --
   -- After-tax ER Match
   --
   if p_after_tax_component = 'Y'  and
      p_employer_match      = 'Y' then
      l_at_er_exclusion_rule := 'Y';
   end if;
   -- State Retirement, Buy Back rules
   if (p_ele_category in ('DCP', 'DBP')) or
      (NVL(p_ele_srs_plan_type, 'N') <> 'N')  then
     if p_ele_srs_plan_type = 'B' then
        l_dbp_exclusion_rule := 'N';
        l_dcp_exclusion_rule := 'Y';
     else
        l_dbp_exclusion_rule := 'Y';
        l_dcp_exclusion_rule := 'N';
     end if;
   end if;
   -- Config19: If base is recurring then create Roth Contribution SI element
   if nvl(p_roth_contribution,'N') = 'Y' and
      p_ele_processing_type = 'R'        then
      l_at_roth_si_rule := 'Y';
   else
      l_at_roth_si_rule := 'N';
   end if;
   -- Config20: Create the Roth ER Match element only ER
   -- and Roth components are selected
   if p_roth_contribution = 'Y' and
      p_employer_match    = 'Y' then
      l_at_roth_er_rule := 'Y';
   else
      l_at_roth_er_rule := 'N';
   end if;

   -- Pre-Tax USERRA element, SI and ER
   if p_userra_contribution ='Y' and
      p_ele_processing_type = 'R' and
      p_employer_match = 'Y' then

      l_pt_userra_si_rule := 'Y';
      l_pt_userra_rule    := 'Y';
      l_pt_userra_er_rule := 'Y';

   elsif p_userra_contribution ='Y' and
         p_ele_processing_type <> 'R' and
         p_employer_match = 'Y' then

         l_pt_userra_si_rule := 'N';
         l_pt_userra_rule    := 'Y';
         l_pt_userra_er_rule := 'Y';

   elsif p_userra_contribution ='Y' and
         p_ele_processing_type <> 'R' and
         p_employer_match <> 'Y' then

         l_pt_userra_si_rule := 'N';
         l_pt_userra_rule    := 'Y';
         l_pt_userra_er_rule := 'N';
   end if;
   -- Roth After-Tax USERRA element, SI and ER  4489655
   if p_roth_contribution = 'Y' then
      if p_userra_contribution ='Y' and
         p_ele_processing_type = 'R' and
         p_employer_match = 'Y' then

         l_atr_userra_si_rule := 'Y';
         l_atr_userra_rule    := 'Y';
         l_atr_userra_er_rule := 'Y';

      elsif p_userra_contribution ='Y' and
            p_ele_processing_type <> 'R' and
            p_employer_match = 'Y' then

            l_atr_userra_si_rule := 'N';
            l_atr_userra_rule    := 'Y';
            l_atr_userra_er_rule := 'Y';

      elsif p_userra_contribution ='Y' and
            p_ele_processing_type <> 'R' and
            p_employer_match <> 'Y' then

            l_atr_userra_si_rule := 'N';
            l_atr_userra_rule    := 'Y';
            l_atr_userra_er_rule := 'N';
      end if;
   end if;

   --
   -- Set the element processing priority
   --
   if p_ele_priority = 3750  or
      p_ele_classification = 'Involuntary Deductions' then

      l_template_priority := l_ele_template_priority;
   else
      l_template_priority := p_ele_priority;

   end if;

   pay_element_template_api.create_user_structure
   (p_validate                    => false
   ,p_effective_date              => p_ele_eff_start_date
   ,p_business_group_id           => p_bg_id
   ,p_source_template_id          => l_source_template_id
   ,p_base_name                   => p_ele_name
   ,p_base_processing_priority    => l_template_priority
   ,p_configuration_information1  => p_ele_processing_type
   ,p_configuration_information2  => p_ele_arrearage
   ,p_configuration_information3  => p_ele_partial_deduction
   ,p_configuration_information4  => p_ele_stop_rule
   ,p_configuration_information5  => p_ele_start_rule
   ,p_configuration_information6  => p_after_tax_component
   ,p_configuration_information7  => p_employer_match
   ,p_configuration_information8  => l_aftertax_nonrecurring_rule
   ,p_configuration_information9  => l_dcp_exclusion_rule
   ,p_configuration_information10 => p_ele_calc_rule
   ,p_configuration_information11 => p_ele_calc_rule
   ,p_configuration_information12 => l_at_er_exclusion_rule
   ,p_configuration_information13 => p_catchup_processing
   ,p_configuration_information14 => p_ele_srs_buy_back
   ,p_configuration_information15 => l_dbp_exclusion_rule
   ,p_configuration_information16 => l_cu_si_exclusion_rule
   ,p_configuration_information17 => l_aftertax_si_rule
   -- Roth Rules
   ,p_configuration_information18 => p_roth_contribution
   ,p_configuration_information19 => l_at_roth_si_rule
   ,p_configuration_information20 => l_at_roth_er_rule
   -- Pre-Tax USERRA Rules
   ,p_configuration_information21 => l_pt_userra_si_rule
   ,p_configuration_information22 => l_pt_userra_rule
   ,p_configuration_information23 => l_pt_userra_er_rule
   -- After-Tax Roth USERRA Rules
   ,p_configuration_information24 => l_atr_userra_si_rule
   ,p_configuration_information25 => l_atr_userra_rule
   ,p_configuration_information26 => l_atr_userra_er_rule
   --
   ,p_template_id                 => l_template_id
   ,p_object_version_number       => l_object_version_number
   );
   --
   hr_utility.set_location(l_proc, 80);
   -- =========================================================================
   -- Create Global Values: For 401k ER Match percentage and limit
   -- =========================================================================
   open c_global;
   fetch c_global into l_dummy;
   if c_global%notfound then
      -- Create Global Value
      ff_globals_f_pkg.insert_row(
       x_rowid                => l_glb_rowid,
       x_global_id            => l_glb_id,
       x_effective_start_date => to_date('01/01/1900','dd/mm/yyyy'),
       x_effective_end_date   => to_date('31/12/4712','dd/mm/yyyy'),
       x_business_group_id    => p_bg_id,
       x_legislation_code     => null,
       x_data_type            => 'N',
       x_global_name          => l_glb_name,
       x_global_description   => 'The rate of the employer match',
       x_global_value         => .50);
       close c_global;
   else
       close c_global;
   end if;

   open c_global1;
   fetch c_global1 into l_dummy;
   if c_global1%notfound then
      -- Create Global Value
      ff_globals_f_pkg.insert_row(
       x_rowid                => l_glb_rowid1,
       x_global_id            => l_glb_id1,
       x_effective_start_date => to_date('01/01/1900','dd/mm/yyyy'),
       x_effective_end_date   => to_date('31/12/4712','dd/mm/yyyy'),
       x_business_group_id    => p_bg_id,
       x_legislation_code     => null,
       x_data_type            => 'N',
       x_global_name          => l_glb_name1,
       x_global_description   => 'The rate of the employer match limit',
       x_global_value         => .06);
       close c_global1;
   else
       close c_global1;
   end if;

   hr_utility.set_location(l_proc, 85);
   -- =========================================================================
   -- Update Shadow Structure: Get Element Type id and update user-specified
   -- Classification,Category, Processing Type and Standard Link on Base Element
   -- =========================================================================
   for c1_rec in c1 ( p_ele_name ) loop
      l_element_type_id    := c1_rec.element_type_id;
      l_ele_obj_ver_number := c1_rec.object_version_number;
   end loop;
   -- Added for Garnishment rewrite --
   if p_ele_classification <> l_inv_ded then
      if p_ele_start_rule = 'ET' then
          l_skip_formula := 'THRESHOLD_SKIP_FORMULA';
      else
          l_skip_formula := 'FREQ_RULE_SKIP_FORMULA';
      end if;
   end if;
   --
   if p_ben_class_id is not null then
      for c_rec in c_ben_class(p_ben_class_id) loop
         l_ben_class_name := c_rec.benefit_classification_name;
      end loop;
   end if;
   --
   pay_shadow_element_api.update_shadow_element
   (p_validate                     => false
   ,p_effective_date               => p_ele_eff_start_date
   ,p_element_type_id              => l_element_type_id
   ,p_description                  => p_ele_description
   ,p_reporting_name               => p_ele_reporting_name
   ,p_post_termination_rule        => p_termination_rule
   ,p_benefit_classification_name  => l_ben_class_name
   ,p_element_information_category => l_element_information_category
   ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
   ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
   ,p_standard_link_flag           => nvl(p_ele_standard_link, hr_api.g_varchar2)
   ,p_skip_formula                 => l_skip_formula
   ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
   ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
   ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
   ,p_element_information9         => 'D'
   ,p_object_version_number        => l_ele_obj_ver_number
    );
   hr_utility.set_location(l_proc, 90);
   -- SRS: State Retirement Systems
   -- Update Reporting Name and other details on the shadow tables.
   --
   if (p_ele_category in ('DCP', 'DBP')) or
      (nvl(p_ele_srs_plan_type, 'N') <> 'N')  then
       for i in 1..2
       loop
        if i = 1 then
          -- For the ER Contribution Element
          for c1_rec in c1 ( p_ele_name||' ER Contribution' ) loop
             l_srs_ERContr_type_id        := c1_rec.element_type_id;
             l_srs_erContr_obj_ver_number := c1_rec.object_version_number;
             l_srs_erContr_rep_name :=
               nvl(p_ele_reporting_name,p_ele_name)||' ER Contribution';
             l_srs_erContr_desc_name :=
               'Generated Element for :'||
               nvl(p_ele_reporting_name,p_ele_name)||
               ' ER Contribution';
          end loop;
        else
          -- For ER Contribution Special Features
          for c1_rec in c1 ( p_ele_name||' ER Contribution SF' ) loop
               l_srs_ERContr_type_id        := c1_rec.element_type_id;
               l_srs_erContr_obj_ver_number := c1_rec.object_version_number;
               l_srs_erContr_rep_name       := nvl(p_ele_reporting_name,p_ele_name)||
                                               ' ER Contribution SF';
               l_srs_erContr_desc_name      := 'Generated Element for :'||
                                               nvl(p_ele_reporting_name,p_ele_name)||
                                               ' ER Contribution Special Features';
          end loop;
        end if;
        pay_shadow_element_api.update_shadow_element
       (p_validate                     => false
       ,p_effective_date               => p_ele_eff_start_date
       ,p_element_type_id              => l_srs_ERContr_type_id
       ,p_description                  => l_srs_erContr_desc_name
       ,p_reporting_name               => l_srs_erContr_rep_name
       ,p_post_termination_rule        => p_termination_rule
       ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
       ,p_object_version_number        => l_srs_erContr_obj_ver_number
        );
      end loop;
      --
      -- For Buy Back element
      --
      if p_ele_srs_buy_back = 'Y' then
        -- Means that the category is SRS type. Check for the Buy Back Flag
        -- and get Id's for the Buy back element
       for c1_rec in c1 ( p_ele_name||' Buy Back' ) loop
           l_bb_element_type_id    := c1_rec.element_type_id;
           l_bb_ele_obj_ver_number := c1_rec.object_version_number;
       end loop;
       pay_shadow_element_api.update_shadow_element
        (p_validate                     => false
        ,p_effective_date               => p_ele_eff_start_date
        ,p_element_type_id              => l_bb_element_type_id
        ,p_description                  => 'Generated Element For:'
                                           ||p_ele_name||' Buy Back'
        ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)
                                           ||' Buy Back'
        ,p_post_termination_rule        => p_termination_rule
        ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
        ,p_element_information_category => 'US_PRE-TAX DEDUCTIONS'
        ,p_skip_formula                 => l_skip_formula
        ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
        ,p_standard_link_flag           => nvl(p_ele_standard_link, hr_api.g_varchar2)
        ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
        ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
        ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
        ,p_object_version_number        => l_bb_ele_obj_ver_number
        );
        l_temp_var(1).sub_name:=' Buy Back SI';
        l_temp_var(2).sub_name:=' Buy Back SF';
        for i in 1..2
        loop
          l_cur_temp:='';
          for c1_rec in c1 ( p_ele_name||l_temp_var(i).sub_name )
          loop
            if l_temp_var(i).sub_name=' Buy Back SI' then
               l_bb_si_element_type_id    := c1_rec.element_type_id;
               l_bb_ele_obj_ver_number    := c1_rec.object_version_number;
               l_cur_temp                 := c1_rec.element_type_id;
            elsif l_temp_var(i).sub_name=' Buy Back SF' then
               l_bb_sf_element_type_id    := c1_rec.element_type_id;
               l_bb_ele_obj_ver_number    := c1_rec.object_version_number;
               l_cur_temp                 := c1_rec.element_type_id;
            end if;
            pay_shadow_element_api.update_shadow_element
             (p_validate                     => false
             ,p_effective_date               => p_ele_eff_start_date
             ,p_post_termination_rule        => p_termination_rule
             ,p_element_type_id              => l_cur_temp
             ,p_description                  => 'Generated Element For:'
                                                 ||p_ele_name||l_temp_var(i).sub_name
             ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)
                                                 ||l_temp_var(i).sub_name
             ,p_element_information_category => 'US_PRE-TAX DEDUCTIONS'
             ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
             ,p_object_version_number        => l_bb_ele_obj_ver_number
             );
          end loop;
        end loop;
        hr_utility.set_location(l_proc, 95);
      end if; -- p_ele_srs_buy_back = y
   end if; -- p_ele_srs_plan_type = Y

   hr_utility.set_location(l_proc, 96);

   -- Update Reporting Name and other details on the shadow tables.
   -- for Catch-Up element if option is selected
   if nvl(p_catchup_processing,'NONE') <> 'NONE' then

     for c1_rec in c1 ( p_ele_name||' Catchup' )
     loop
      l_cu_element_type_id    := c1_rec.element_type_id;
      l_cu_ele_obj_ver_number := c1_rec.object_version_number;
     end loop;

     pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_cu_element_type_id
     ,p_description                  => 'Generated Element For:'
                                         ||p_ele_name||' Catchup'
     ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name) ||' Catchup'
     ,p_post_termination_rule        => p_termination_rule
     ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
     ,p_element_information_category => 'US_PRE-TAX DEDUCTIONS'
     ,p_skip_formula                 => l_skip_formula
     ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
     ,p_standard_link_flag           => nvl(p_ele_standard_link, hr_api.g_varchar2)
     ,p_element_information1         => nvl(p_ele_category||'C', hr_api.g_varchar2)
     ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
     ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
     ,p_object_version_number        => l_cu_ele_obj_ver_number
     );

    l_temp_var(1).sub_name:=' Catchup SI';
    l_temp_var(2).sub_name:=' Catchup SF';
    for i in 1..2
    loop
      l_cur_temp:='';
      for c1_rec in c1 ( p_ele_name||l_temp_var(i).sub_name )
      loop
       if l_temp_var(i).sub_name=' Catchup SI' then
          l_cu_si_element_type_id := c1_rec.element_type_id;
          l_cu_ele_obj_ver_number := c1_rec.object_version_number;
          l_cur_temp              := c1_rec.element_type_id;
       elsif l_temp_var(i).sub_name=' Catchup SF' then
          l_cu_sf_element_type_id := c1_rec.element_type_id;
          l_cu_ele_obj_ver_number := c1_rec.object_version_number;
          l_cur_temp              := c1_rec.element_type_id;
       end if;
       pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_cur_temp
         ,p_description                  => 'Generated Element For:'
                                             ||p_ele_name||l_temp_var(i).sub_name
         ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)
                                             ||l_temp_var(i).sub_name
         ,p_post_termination_rule        => p_termination_rule
         ,p_element_information_category => 'US_PRE-TAX DEDUCTIONS'
         ,p_element_information1         => nvl(p_ele_category||'C', hr_api.g_varchar2)
         ,p_object_version_number        => l_cu_ele_obj_ver_number
         );
      end loop;
    end loop;
    hr_utility.set_location(l_proc, 97);
  end if; -- If Catch-Up <> NONE

   -- Update Taxable by JD element with relevant Data.
   -- Modified for Garnishment rewrite
   if p_ele_category in ('D','E','G') and
      p_ele_classification <> l_inv_ded then

      for c1_rec in c1 ( p_ele_name||' Taxable By JD' )
      loop
         l_jd_core_element_type_id    := c1_rec.element_type_id;
         l_jd_ele_obj_ver_number      := c1_rec.object_version_number;
      end loop;

      pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_jd_core_element_type_id
     ,p_description                  => 'Generated Element For:'
                                         ||p_ele_name||' Taxable by JD'
     ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)
                                        ||' Taxable by JD'
     ,p_post_termination_rule        => p_termination_rule
     ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
     ,p_element_information_category => 'US_PRE-TAX DEDUCTIONS'
     ,p_element_information1         => nvl(p_ele_category||'J', hr_api.g_varchar2)
     ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
     ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
     ,p_object_version_number        => l_jd_ele_obj_ver_number
     );
   end if;

   hr_utility.set_location(l_proc, 98);

   --
   -- Update user-specified Classification on Special Features Element.
   -- ref. bug 1559726.
   if p_ele_classification <> l_inv_ded then
       for c1_rec in c1 ( p_ele_name||' Special Features' ) loop
          l_sf_element_type_id    := c1_rec.element_type_id;
          l_sf_ele_obj_ver_number := c1_rec.object_version_number;
       end loop;
       pay_shadow_element_api.update_shadow_element
      (p_validate                     => false
      ,p_effective_date               => p_ele_eff_start_date
      ,p_element_type_id              => l_sf_element_type_id
      ,p_description                  => 'Generated results element for:'
                                          ||p_ele_name
      ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name) ||' Special Features'
      ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
      ,p_post_termination_rule        => p_termination_rule
      ,p_element_information_category => 'US_PRE-TAX DEDUCTIONS'
      ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
      ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
      ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
      ,p_object_version_number        => l_sf_ele_obj_ver_number
       );
   end if;

   hr_utility.set_location(l_proc, 99);

   --
   -- Update user-specified Classification Special Inputs if it exists.
   --
   if p_ele_processing_type = 'R' then
      for c1_rec in c1 ( p_ele_name||' Special Inputs' )
      loop
           l_si_element_type_id    := c1_rec.element_type_id;
           l_si_ele_obj_ver_number := c1_rec.object_version_number;
      end loop;
      pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_si_element_type_id
     ,p_description                  => 'Generated adjustments element for:'
                                         ||p_ele_name
     ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
     ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)||' Special Inputs'
     ,p_post_termination_rule        => p_termination_rule
     ,p_element_information_category => l_element_information_category
     ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
     ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
     ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
     ,p_object_version_number        => l_si_ele_obj_ver_number
      );
   end if;

   hr_utility.set_location(l_proc, 100);

   -- Added for Garnishment rewrite
   if p_ele_classification = l_inv_ded then
        for c1_rec in c1 ( p_ele_name||' Calculator' ) loop
             l_ca_element_type_id    := c1_rec.element_type_id;
             l_ca_ele_obj_ver_number := c1_rec.object_version_number;
        end loop;
        pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_ca_element_type_id
         ,p_description                  => 'Generated calculation element for '
                                             ||p_ele_name
         ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
         ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)||' Calculator'
         ,p_post_termination_rule        => p_termination_rule
         ,p_element_information_category => l_element_information_category
         ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
         ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
         ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
         ,p_object_version_number        => l_ca_ele_obj_ver_number
         );

        for c1_rec in c1 ( p_ele_name||' Fees' ) loop
             l_fee_element_type_id    := c1_rec.element_type_id;
             l_fee_ele_obj_ver_number := c1_rec.object_version_number;
        end loop;
        pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_fee_element_type_id
         ,p_description                  => 'Generated Fee results element for '
                                             ||p_ele_name
         ,p_classification_name          => nvl(p_ele_classification, hr_api.g_varchar2)
         ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)||' Fees'
         ,p_post_termination_rule        => p_termination_rule
         ,p_element_information_category => l_element_information_category
         ,p_element_information1         => nvl(p_ele_category, hr_api.g_varchar2)
         ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
         ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
         ,p_object_version_number        => l_fee_ele_obj_ver_number
         );
   end if;

   hr_utility.set_location(l_proc, 101);

   --
   -- Update user-specified details on all After-Tax Elements
   --
   if p_employer_match ='Y' then
      l_temp_var(1).sub_name:=  ' ER';
      l_cur_temp  :=  '';
      for c1_rec in c1 ( p_ele_name||l_temp_var(1).sub_name ) loop
         l_er_element_type_id    := c1_rec.element_type_id;
         l_object_version_number := c1_rec.object_version_number;
      pay_shadow_element_api.update_shadow_element
       (p_validate                     => false
       ,p_effective_date               => p_ele_eff_start_date
       ,p_element_type_id              => l_er_element_type_id
       ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)||l_temp_var(1).sub_name
       ,p_post_termination_rule        => p_termination_rule
       ,p_description                  => 'Employer Match element for:'||p_ele_name
       ,p_object_version_number        => l_object_version_number
       );
      end loop;
   end if;

   hr_utility.set_location(l_proc, 102);

   if p_after_tax_component = 'Y' then

      for c1_rec in c1 ( p_ele_name||' AT' ) loop
        l_at_element_type_id    := c1_rec.element_type_id;
        l_object_version_number := c1_rec.object_version_number;
      end loop;

      pay_shadow_element_api.update_shadow_element
       (p_validate                     => false
       ,p_effective_date               => p_ele_eff_start_date
       ,p_element_type_id              => l_at_element_type_id
       ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name) ||' AT'
       ,p_post_termination_rule        => p_termination_rule
       ,p_description                  => 'After Tax element for:'||p_ele_name
       ,p_element_information_category => 'US_VOLUNTARY DEDUCTIONS'
       ,p_skip_formula                 => l_skip_formula
       ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
       ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
       ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
       ,p_object_version_number        => l_object_version_number
       );

       l_temp_var(1).sub_name:=' AT ER';
       l_cur_temp:='';

      for c1_rec in c1 ( p_ele_name||l_temp_var(1).sub_name )
      loop
         l_at_er_element_type_id    := c1_rec.element_type_id;
         l_object_version_number := c1_rec.object_version_number;

         pay_shadow_element_api.update_shadow_element
        (p_validate                     => false
        ,p_effective_date               => p_ele_eff_start_date
        ,p_element_type_id              => l_at_er_element_type_id
        ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)||l_temp_var(1).sub_name
        ,p_post_termination_rule        => p_termination_rule
        ,p_description                  => 'After Tax Employer Match element for:'||p_ele_name
        ,p_object_version_number        => l_object_version_number
        );
      end loop;

      if p_ele_processing_type = 'R' then
         for c1_rec in c1 ( p_ele_name||' AT Special Inputs' ) loop
           l_at_si_element_type_id := c1_rec.element_type_id;
           l_object_version_number := c1_rec.object_version_number;
         end loop;
         pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_at_si_element_type_id
         ,p_description                  => 'Generated adjustments AT element for:'
                                             ||p_ele_name
         ,p_reporting_name               => nvl(p_ele_reporting_name,p_ele_name)||' AT SI'
         ,p_post_termination_rule        => p_termination_rule
         ,p_element_information_category => 'US_VOLUNTARY DEDUCTIONS'
         ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
         ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
         ,p_object_version_number        => l_object_version_number
         );
      end if;

      for c1_rec in c1 ( p_ele_name||' AT Special Features' ) loop
           l_at_sf_element_type_id    := c1_rec.element_type_id;
           l_object_version_number    := c1_rec.object_version_number;
      end loop;
      pay_shadow_element_api.update_shadow_element
         (p_validate                     => false
         ,p_effective_date               => p_ele_eff_start_date
         ,p_element_type_id              => l_at_sf_element_type_id
         ,p_description                  => 'Generated Special Features AT element for:'
                                             ||p_ele_name
         ,p_reporting_name               => nvl(p_ele_reporting_name
                                               ,p_ele_name)||': AT SF'
         ,p_post_termination_rule        => p_termination_rule
         ,p_element_information_category => 'US_VOLUNTARY DEDUCTIONS'
         ,p_element_information2         => nvl(p_ele_partial_deduction,hr_api.g_varchar2)
         ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
         ,p_object_version_number        => l_object_version_number
         );
   end if;
   hr_utility.set_location(l_proc, 110);
   --
   -- Update shadow element if Roth Contribution option is selected.
   --
   if p_roth_contribution = 'Y' then

       for c1_rec in c1 ( p_ele_name||' Roth' )
       loop
         l_atr_element_type_id    := c1_rec.element_type_id;
         l_object_version_number  := c1_rec.object_version_number;
       end loop;
       -- Bug# 4676867
       IF p_ele_category = 'D' THEN
         l_relative_processing_priority := 1425 ;
         l_ele_information1 := 'R401K' ;
       ELSIF p_ele_category = 'E' THEN
         l_relative_processing_priority := 1425 ;
         l_ele_information1 := 'R403B' ;
       END IF ;

       hr_utility.set_location(l_proc, 111);

       pay_shadow_element_api.update_shadow_element
      (p_validate                     => false
      ,p_effective_date               => p_ele_eff_start_date
      ,p_element_type_id              => l_atr_element_type_id
      ,p_reporting_name               => nvl(p_ele_reporting_name
                                            ,p_ele_name)||' Roth'
      ,p_post_termination_rule        => p_termination_rule
      ,p_description                  => 'Roth Contribution element for:'||p_ele_name
      ,p_element_information_category => 'US_VOLUNTARY DEDUCTIONS'
      ,p_skip_formula                 => l_skip_formula
      ,p_processing_type              => nvl(p_ele_processing_type, hr_api.g_varchar2)
      ,p_relative_processing_priority => l_relative_processing_priority
      ,p_element_information1         => l_ele_information1
      ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
      ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
      ,p_object_version_number        => l_object_version_number
       );

       hr_utility.set_location(l_proc, 112);
       --
       -- Update the Roth AT ER element
       --
       l_temp_var(1).sub_name := ' Roth ER';
       l_cur_temp             := '';
       for c1_rec in c1 ( p_ele_name||l_temp_var(1).sub_name )
       loop
          l_atr_er_element_type_id := c1_rec.element_type_id;
          l_object_version_number  := c1_rec.object_version_number;

          pay_shadow_element_api.update_shadow_element
         (p_validate              => false
         ,p_effective_date        => p_ele_eff_start_date
         ,p_description           => 'Generated Roth ER element for:'||p_ele_name
         ,p_element_type_id       => l_atr_er_element_type_id
         ,p_reporting_name        => nvl(p_ele_reporting_name
                                        ,p_ele_name)||l_temp_var(1).sub_name
         ,p_post_termination_rule => p_termination_rule
         ,p_object_version_number => l_object_version_number
         );

       end loop;
       hr_utility.set_location(l_proc, 113);
       --
       -- Update the Special Inputs element for Roth 401k
       --
       if p_ele_processing_type = 'R' then
         for c1_rec in c1 ( p_ele_name||' Roth SI' )
         loop
           l_atr_si_element_type_id := c1_rec.element_type_id;
           l_object_version_number := c1_rec.object_version_number;
         end loop;
         -- Bug# 4676867: Impact of Roth on Involuntary Deductions
         IF p_ele_category = 'D' THEN
           l_relative_processing_priority := 1405 ;
         ELSIF p_ele_category = 'E' THEN
           l_relative_processing_priority := 1405 ;
         END IF ;

         pay_shadow_element_api.update_shadow_element
         (p_validate         => false
         ,p_effective_date   => p_ele_eff_start_date
         ,p_element_type_id  => l_atr_si_element_type_id
         ,p_description      => 'Generated adjustments Roth SI element for:'||p_ele_name
         ,p_reporting_name               => nvl(p_ele_reporting_name
                                               ,p_ele_name)||' Roth SI'
         ,p_post_termination_rule        => p_termination_rule
         ,p_element_information_category => 'US_VOLUNTARY DEDUCTIONS'
         ,p_relative_processing_priority => l_relative_processing_priority
         ,p_element_information2         => nvl(p_ele_partial_deduction, hr_api.g_varchar2)
         ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
         ,p_object_version_number        => l_object_version_number
         );
      end if;
      hr_utility.set_location(l_proc, 114);
      --
      -- Update the Special Features element for Roth 401k
      --
      for c1_rec in c1 ( p_ele_name||' Roth SF' )
      loop
           l_atr_sf_element_type_id := c1_rec.element_type_id;
           l_object_version_number  := c1_rec.object_version_number;
      end loop;

      -- Bug# 4676867: Impact of Roth on Involuntary Deductions
      IF p_ele_category = 'D' THEN
           l_relative_processing_priority := 1435 ;
      ELSIF p_ele_category = 'E' THEN
           l_relative_processing_priority := 1435 ;
      END IF ;

      pay_shadow_element_api.update_shadow_element
     (p_validate                     => false
     ,p_effective_date               => p_ele_eff_start_date
     ,p_element_type_id              => l_atr_sf_element_type_id
     ,p_description                  => 'Generated Special Features Roth SF element for:'
                                          ||p_ele_name
     ,p_reporting_name               => nvl(p_ele_reporting_name
                                           ,p_ele_name)||' Roth SF'
     ,p_post_termination_rule        => p_termination_rule
     ,p_element_information_category => 'US_VOLUNTARY DEDUCTIONS'
     ,p_relative_processing_priority => l_relative_processing_priority
     ,p_element_information2         => nvl(p_ele_partial_deduction,hr_api.g_varchar2)
     ,p_element_information3         => nvl(p_ele_proc_runtype, hr_api.g_varchar2)
     ,p_object_version_number        => l_object_version_number
      );
      hr_utility.set_location(l_proc, 115);
   end if; -- if p_roth_contribution = 'Y'

   hr_utility.set_location(l_proc, 120);

   -- ========================================================================
   -- Generate Core Objects
   -- ========================================================================
    pay_element_template_api.generate_part1
   (p_validate                      =>     false
   ,p_effective_date                =>     p_ele_eff_start_date
   ,p_hr_only                       =>     false
   ,p_hr_to_payroll                 =>     false
   ,p_template_id                   =>     l_template_id);

   hr_utility.set_location(l_proc, 121);

   -- ========================================================================
   --  Add logic to see generate part2 only if payroll is installed
   -- ========================================================================
    pay_element_template_api.generate_part2
   (p_validate                      =>     false
   ,p_effective_date                =>     p_ele_eff_start_date
   ,p_template_id                   =>     l_template_id
    );

   hr_utility.set_location(l_proc, 130);

   -- ========================================================================
   -- Get Element Type ID and Balance Id's to update the Further Information
   -- ========================================================================

      get_element_and_bal_ids;

   --
   -- get the Iterative Formula Id
   --
   hr_utility.set_location(l_proc, 135);
    open c_iter_formula;
   fetch c_iter_formula into l_iter_formula_id;
   close c_iter_formula;
   --
   hr_utility.set_location(l_proc, 140);
   --
   -- Added for Garnishment rewrite --
   if p_ele_classification = l_inv_ded then
      update pay_element_types_f
         set element_information5 = l_cal_core_element_type_id,
             element_information8 = l_vol_ded_bal_id,
             element_information10 = l_pri_bal_id,
             element_information11 = l_accr_bal_id,
             --element_information12 = l_arr_bal_id, Commented for Bug 2527761, 980683
             --element_information13 = l_not_taken_bal_id,
             element_information15 = l_fee_bal_id,
             element_information16 = l_addl_bal_id,
             element_information17 = l_repl_bal_id,
             element_information18 = l_si_core_element_type_id
             --element_information19 = l_sf_core_element_type_id,
             --element_information20 = l_ver_core_element_type_id,
       where element_type_id       = l_base_element_type_id
         and business_group_id     = p_bg_id;

      update pay_element_types_f
         set element_information10 = l_fee_bal_id,
             element_information11 = l_accr_fees_bal_id
       where element_type_id       = l_fees_core_element_type_id
         and business_group_id     = p_bg_id;

      update pay_input_values_f
         set mandatory_flag = 'X'
       where name           = 'Pay Value'
         and element_type_id in (select  element_type_id
                                   from  pay_element_types_f
                                   where element_name like p_ele_name ||'%');
   else
      update pay_element_types_f
         set element_information10 = l_pri_bal_id,
             element_information11 = l_accr_bal_id,
             element_information12 = l_arr_bal_id,
             element_information13 = l_not_taken_bal_id,
             element_information16 = l_addl_bal_id,
             element_information17 = l_repl_bal_id,
             element_information18 = l_si_core_element_type_id,
             element_information19 = l_sf_core_element_type_id,
             iterative_flag        = 'Y',
             iterative_formula_id  = l_iter_formula_id,
             iterative_priority    = l_iter_priority
       where element_type_id       = l_base_element_type_id
         and business_group_id     = p_bg_id;
   end if;
   hr_utility.set_location(l_proc, 150);

   insert_iterative_rules(l_base_element_type_id);

   -- Get the _ASG_GRE_RUN dimension id
   for crec in get_asg_gre_run_dim_id
   loop
     l_asg_gre_run_dim_id := crec.balance_dimension_id;
   end loop;

   update pay_defined_balances
      set save_run_balance     = 'Y'
    where balance_type_id      = l_pri_bal_id
      and balance_dimension_id = l_asg_gre_run_dim_id
      and business_group_id    = p_bg_id;

   hr_utility.set_location(l_proc, 170);
   --
   if p_after_tax_component = 'Y' then
      update pay_element_types_f
         set element_information10 = l_at_pri_bal_id,
             element_information11 = l_at_accr_bal_id,
             element_information12 = l_at_arr_bal_id,
             element_information13 = l_at_not_taken_bal_id,
             element_information16 = l_at_addl_bal_id,
             element_information17 = l_at_repl_bal_id,
             element_information18 = l_at_si_core_element_type_id,
             element_information19 = l_at_sf_core_element_type_id
       where element_type_id       = l_at_base_element_type_id
         and business_group_id     = p_bg_id;

      update pay_defined_balances
         set save_run_balance         = 'Y'
       where balance_type_id          = l_at_pri_bal_id
         and balance_dimension_id     = l_asg_gre_run_dim_id
         and business_group_id        = p_bg_id;
   end if;

   hr_utility.set_location(l_proc, 175);
   -- Update Roth element if Roth contribution is selected
   if p_roth_contribution = 'Y' then
      update pay_element_types_f
         set element_information10 = l_atr_pri_bal_id,
             element_information11 = l_atr_accr_bal_id,
             element_information12 = l_atr_arr_bal_id,
             element_information13 = l_atr_not_taken_bal_id,
             element_information16 = l_atr_addl_bal_id,
             element_information17 = l_atr_repl_bal_id,
             element_information18 = l_roth_si_ele_type_id,
             element_information19 = l_roth_sf_ele_type_id
       where element_type_id       = l_roth_ele_type_id
         and business_group_id     = p_bg_id;

      update pay_defined_balances
         set save_run_balance      = 'Y'
       where balance_type_id       = l_atr_pri_bal_id
         and balance_dimension_id  = l_asg_gre_run_dim_id
         and business_group_id     = p_bg_id;
     -- If ER component is selected then update the Roth ER match element
     if p_employer_match ='Y' then
        update pay_element_types_f
           set element_information1         = 'O',
               element_information10        = l_atr_er_bal_id,
               element_information_category = 'US_EMPLOYER LIABILITIES'
         where element_type_id              = l_roth_er_ele_type_id
           and business_group_id            = p_bg_id;

        update pay_defined_balances
           set save_run_balance     = 'Y'
         where balance_type_id      = l_atr_er_bal_id
           and balance_dimension_id = l_asg_gre_run_dim_id
           and business_group_id    = p_bg_id;
     end if;

   end if;

   hr_utility.set_location(l_proc, 180);
   -- Update the element_types_f table with the primary
   -- catchup balance id for the catch-up element
   if NVL(p_catchup_processing,'NONE') <> 'NONE' then
      update pay_element_types_f
         set element_information10 = l_cu_pri_bal_id,
             element_information11 = l_cu_accrued_bal_id,
             element_information12 = l_cu_arrears_bal_id,
             element_information13 = l_cu_nottaken_bal_id,
             element_information16 = l_cu_addl_bal_id,
             element_information17 = l_cu_repl_bal_id,
             element_information18 = l_cu_si_element_type_id,
             element_information19 = l_cu_sf_element_type_id,
             iterative_flag        = 'Y',
             iterative_formula_id  = l_iter_formula_id,
             iterative_priority    = (l_iter_priority - 5)
       where element_type_id       = l_cu_element_type_id
         and business_group_id     = p_bg_id;

      insert_iterative_rules(l_cu_element_type_id);
       update pay_defined_balances
          set save_run_balance         = 'Y'
        where balance_type_id          = l_cu_pri_bal_id
          and balance_dimension_id     = l_asg_gre_run_dim_id
          and business_group_id        = p_bg_id;
   end if;
   hr_utility.set_location(l_proc, 190);
   -- Update the element_types_f table with the primary
   -- Buy Back balance id for the Buy-back element
   if NVL(p_ele_srs_buy_back,'N') <> 'N' then
      update pay_element_types_f
      set    element_information10 = l_bb_pri_bal_id,
             element_information11 = l_bb_accrued_bal_id,
             element_information12 = l_bb_arrears_bal_id,
             element_information13 = l_bb_nottaken_bal_id,
             element_information16 = l_bb_addl_bal_id,
             element_information17 = l_bb_repl_bal_id,
             element_information18 = l_bb_si_element_type_id,
             element_information19 = l_bb_sf_element_type_id,
             iterative_flag        = 'Y',
             iterative_formula_id  = l_iter_formula_id,
             iterative_priority    = (l_iter_priority - 5)
      where  element_type_id       = l_bb_element_type_id
        and  business_group_id     = p_bg_id;

       insert_iterative_rules(l_bb_element_type_id);

       update pay_defined_balances
          set save_run_balance         = 'Y'
        where balance_type_id          = l_bb_pri_bal_id
          and balance_dimension_id     = l_asg_gre_run_dim_id
          and business_group_id        = p_bg_id;
   end if;
   hr_utility.set_location(l_proc, 200);
   -- Update the element_types_f table with the primary
   -- ER Contribution balance id for the ER Contr element
   if nvl(p_ele_srs_plan_type,'N') <> 'N' then
      update pay_element_types_f
         set element_information10 = l_er_contr_pri_bal_id,
             element_information_category = 'US_EMPLOYER LIABILITIES'
       where element_type_id              = l_er_contr_element_type_id
         and business_group_id            = p_bg_id;
   end if;
   hr_utility.set_location(l_proc, 210);
   -- For SRS type Base element
   if nvl(p_ele_srs_plan_type,'N') <> 'N' then

      pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id            => l_base_element_type_id
     ,p_information_type           => 'PQP_US_SRS_DEDUCTIONS'
     ,p_eei_information_category   => 'PQP_US_SRS_DEDUCTIONS'
     ,p_eei_information4           =>  p_ele_srs_plan_type
     ,p_eei_information5           =>  p_ele_srs_buy_back
     ,p_element_type_extra_info_id =>  l_srs_etei_id
     ,p_object_version_number      =>  l_srs_etei_ovn
     );
   end if;
   hr_utility.set_location(l_proc, 220);
   -- For ER Contribution Element
   if nvl(p_ele_srs_plan_type,'N') <> 'N' then

      pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id            => l_er_contr_element_type_id
     ,p_information_type           => 'PQP_US_SRS_DEDUCTIONS'
     ,p_eei_information_category   => 'PQP_US_SRS_DEDUCTIONS'
     ,p_eei_information4           =>  p_ele_srs_plan_type
     ,p_eei_information5           =>  p_ele_srs_buy_back
     ,p_element_type_extra_info_id =>  l_srs_etei_id
     ,p_object_version_number      =>  l_srs_etei_ovn);
   end if;
   -- For Buy Back Element
   if nvl(p_ele_srs_plan_type,'N') <> 'N'  and
      p_ele_srs_buy_back = 'Y' then

      pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id            => l_bb_element_type_id
     ,p_information_type           => 'PQP_US_SRS_DEDUCTIONS'
     ,p_eei_information_category   => 'PQP_US_SRS_DEDUCTIONS'
     ,p_eei_information4           =>  p_ele_srs_plan_type
     ,p_eei_information5           =>  p_ele_srs_buy_back
     ,p_element_type_extra_info_id =>  l_srs_etei_id
     ,p_object_version_number      =>  l_srs_etei_ovn
     );
   end if;
   hr_utility.set_location(l_proc, 220);
   --
   -- Update further info for the ER and AT ER elements
   --
   if p_employer_match = 'Y' then
      update pay_element_types_f
         set element_information1         = 'O',
             element_information10        = l_er_bal_id,
             element_information_category = 'US_EMPLOYER LIABILITIES'
       where element_type_id              = l_er_element_type_id
         and business_group_id            = p_bg_id;
      --
      if p_after_tax_component = 'Y' then
      update pay_element_types_f
         set element_information1         = 'O',
             element_information10        = l_at_er_bal_id,
             element_information_category = 'US_EMPLOYER LIABILITIES'
       where element_type_id              = l_at_er_element_type_id
         and business_group_id            = p_bg_id;
      end if;
      --
      update pay_defined_balances
         set save_run_balance         = 'Y'
       where balance_type_id          = l_er_bal_id
         and balance_dimension_id     = l_asg_gre_run_dim_id
         and business_group_id        = p_bg_id;

      update pay_defined_balances
         set save_run_balance         = 'Y'
       where balance_type_id          = l_at_er_bal_id
         and balance_dimension_id     = l_asg_gre_run_dim_id
         and business_group_id        = p_bg_id;

   end if;
   hr_utility.set_location(l_proc, 230);
   --
   -- Create Information Type for Catch-Up Processing
   -- If p_catchup_processing is not null then should be checking for NONE
   --
   if nvl(p_catchup_processing ,'NONE') <> 'NONE' then

      pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id            => l_base_element_type_id
     ,p_information_type           => 'PQP_US_PRE_TAX_DEDUCTIONS'
     ,p_eei_information_category   => 'PQP_US_PRE_TAX_DEDUCTIONS'
     ,p_eei_information3           =>  p_catchup_processing
     ,p_element_type_extra_info_id =>  l_etei_id
     ,p_object_version_number      =>  l_etei_ovn);

   end if;
   --
   hr_utility.set_location(l_proc, 240);
   if nvl(p_roth_contribution ,'N') <> 'N' and
      l_roth_ele_type_id is not null then

      pay_element_extra_info_api.create_element_extra_info
     (p_element_type_id            => l_roth_ele_type_id
     ,p_information_type           => 'PAY_US_ROTH_OPTIONS'
     ,p_eei_information_category   => 'PAY_US_ROTH_OPTIONS'
     ,p_eei_information4           =>  'Y'
     ,p_eei_information6           =>  'N'
     ,p_element_type_extra_info_id =>  l_etei_id
     ,p_object_version_number      =>  l_etei_ovn);

   end if;
   hr_utility.set_location(l_proc, 245);

   -- Make Pay Value as non user-enterable field for all the elements
   -- created under this pre-tax deduction plan.
   for i in csr_ele(c_effective_date => p_ele_eff_start_date
                   ,c_ele_prefix     => p_ele_name )
   loop
        update pay_input_values_f piv
           set piv.mandatory_flag     = 'X'
         where piv.input_value_id     = i.input_value_id
           and piv.element_type_id    = i.element_type_id
           and piv.business_group_id  = p_bg_id;
   end loop;
   -- ======================================================
   -- Create the balance feeds for the eligible comp balance
   -- ======================================================

      create_eligible_comp_bal_feeds;
   --
   hr_utility.set_location('Leaving: '||l_proc, 250);
   return l_base_element_type_id;
   --
end create_user_init_template;
--
-- =============================================================================
--  delete_user_init_template: Delete User Created template.
-- =============================================================================
procedure delete_user_init_template
         (p_business_group_id     in number
         ,p_ele_type_id           in number
         ,p_ele_name              in varchar2
         ,p_effective_date		      in date
         ) is
   --
   l_template_id   number(9);
   l_proc          varchar2(200);
   --
   cursor c1 is
   select template_id
   from   pay_element_templates
   where  base_name         = p_ele_name
     and  business_group_id = p_business_group_id
     and  template_type     = 'U';
   --
  begin
   --
   l_proc := g_proc||'.delete_user_init_template';
   hr_utility.set_location('Entering :'||l_proc, 10);
   --
   for c1_rec in c1 loop
       l_template_id := c1_rec.template_id;
   end loop;
   --
   pay_element_template_api.delete_user_structure
  (p_validate                =>   false
  ,p_drop_formula_packages   =>   true
  ,p_template_id             =>   l_template_id
   );
   --
   hr_utility.set_location('Leaving :'||l_proc, 50);
   --
  end delete_user_init_template;
--
end pay_us_user_init_dedn;

/
