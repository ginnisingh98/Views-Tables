--------------------------------------------------------
--  DDL for Package Body PAY_MX_YEAREND_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_YEAREND_REP" AS
/* $Header: paymxyearend.pkb 120.11.12010000.7 2010/01/15 12:31:57 sjawid ship $ */


TYPE number_tbl      is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE varchar_80_tbl  is TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
-- TYPE varchar_240_tbl  is TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE date_tbl        IS TABLE OF DATE INDEX BY BINARY_INTEGER;


TYPE format37_cache_r is RECORD
(
    payroll_action_id                number_tbl,
    person_id                        number_tbl,
    effective_date                   date_tbl,
    bal_name                         varchar_80_tbl,
    bal_value                        number_tbl,
    sz                               number
) ;


g_format37_cache        format37_cache_r;
-- g_f37_bal               varchar_240_tbl ;

/******************************************************************
Name      : get_yearch_bal_amt
Purpose   : returns ye archived balance
*****************************************************************/
FUNCTION get_ye_arch_bal_amt (ye_payroll_action_id  in number,
                              ye_person_id          in number,
                              ye_effective_date     in date,
                              ye_balance_name       in varchar2
                              ) RETURN NUMBER
IS
 l_bal_amt        number := 0;

BEGIN

  hr_utility.trace('Inside pay_mx_yearend_rep.get_ye_arch_bal_amt');
  hr_utility.trace('ye_payroll_action_id : '||ye_payroll_action_id);
  hr_utility.trace('ye_person_id : '||ye_person_id);
  hr_utility.trace('ye_effective_date : '||ye_effective_date);
  hr_utility.trace('ye_balance_name : '||ye_balance_name);

  select round(SUM(nvl(fnd_number.canonical_to_number(fai.value),0)))
  into l_bal_amt
  from pay_assignment_actions paa,
       pay_action_information pai,
       ff_archive_items fai,
       ff_archive_item_contexts fic,
       ff_user_entities fue,
       ff_contexts ffc,
       pay_payroll_actions ppa
  where paa.payroll_action_id = ye_payroll_action_id
  and   paa.payroll_action_id = ppa.payroll_action_id
  and paa.serial_number = ye_person_id
  and pai.action_context_id = paa.assignment_action_id
  /*and pai.effective_date = ye_effective_date*/
  and pai.action_information7 = fnd_date.date_to_canonical(ye_effective_date)
  and fai.context1 = paa.assignment_action_id
  and fai.archive_item_id = fic.archive_item_id
  and fai.user_entity_id = fue.user_entity_id
  and fic.context_id = ffc.context_id
  and ffc.context_name ='TAX_UNIT_ID'
  and ltrim(rtrim(fic.context)) in(
	     SELECT DISTINCT gre_node.entity_id
         FROM   per_gen_hierarchy_nodes    gre_node,
		        per_gen_hierarchy_nodes    le_node,
		        per_gen_hierarchy_versions hier_ver,
		        fnd_lookup_values          flv
	     WHERE gre_node.node_type = 'MX GRE'
	     and gre_node.entity_id = fic.context
		 AND gre_node.business_group_id = ppa.business_group_id
		 --AND pay_mx_yrend_arch.gre_exists (gre_node.entity_id) = 1
		 AND le_node.node_type = 'MX LEGAL EMPLOYER'
		 AND gre_node.hierarchy_version_id = le_node.hierarchy_version_id
		 AND le_node.hierarchy_node_id     = gre_node.parent_hierarchy_node_id
		 AND gre_node.hierarchy_version_id = hier_ver.hierarchy_version_id
		 AND status = flv.lookup_code
		 AND flv.meaning = 'Active'
		 AND flv.LANGUAGE = 'US'
		 AND flv.lookup_type = 'PQH_GHR_HIER_VRSN_STATUS'
		 AND ye_effective_date BETWEEN hier_ver.date_from
					           AND NVL(hier_ver.date_to,
						           hr_general.end_of_time))
  and fue.user_entity_name = ye_balance_name  ;

  hr_utility.trace('l_bal_amt : '||l_bal_amt);

  return(l_bal_amt);


EXCEPTION
 when no_data_found then
   return(0);
END get_ye_arch_bal_amt;


/******************************************************************
Name      : get_cache_balance
Purpose   : retruns balance value from the cache
******************************************************************/
function get_cache_balance( p_payroll_action_id  in number,
                            p_person_id          in number,
                            p_effective_date     in date,
                            p_bal_name           in varchar2 )

   return number is

   ctr             number;
   l_bal_value     number;

begin

   l_bal_value      := 0;

   for ctr in 1..g_format37_cache.sz loop

     if   (g_format37_cache.payroll_action_id(ctr) = p_payroll_action_id)
     and  (g_format37_cache.person_id(ctr) = p_person_id)
     and  (g_format37_cache.effective_date(ctr) = p_effective_date)
     and  (g_format37_cache.bal_name(ctr)  = p_bal_name )   then

       l_bal_value := g_format37_cache.bal_value(ctr);

     end if;

   end loop;

   return nvl(l_bal_value,0) ;

   -- This will be zero if the balance is not in the cached format37s
end get_cache_balance;

/******************************************************************
Name      : load_bal
Purpose   : loads balances in the pl/sql table
******************************************************************/
procedure load_bal (p_payroll_action_id  in number,
                    p_person_id          in number,
                    p_effective_date     in date
                   ) IS


    -- Get balances from archiver
    CURSOR c_get_balances IS
      SELECT DISTINCT
             fue_live.user_entity_name
      FROM   pay_bal_attribute_definitions pbad,
             pay_balance_attributes        pba,
             pay_defined_balances          pdb_attr,
             pay_defined_balances          pdb_call,
             pay_balance_dimensions        pbd,
             ff_user_entities              fue_live
      WHERE  pbad.attribute_name           = 'Year End Balances'
        AND  pbad.legislation_code         = 'MX'
        AND  pba.attribute_id              = pbad.attribute_id
        AND  pdb_attr.defined_balance_id   = pba.defined_balance_id
        AND  pdb_attr.balance_type_id      = pdb_call.balance_type_id
        AND  pdb_call.balance_dimension_id = pbd.balance_dimension_id
        AND  pbd.database_item_suffix      = '_PER_PDS_GRE_YTD'
        AND  pbd.legislation_code          = pbad.legislation_code
        AND  fue_live.creator_id           = pdb_call.defined_balance_id
        AND  fue_live.creator_type         = 'B'
   ORDER BY  fue_live.user_entity_name;

cursor c_prev_er_isr_withheld  is
select nvl(action_information9,'N'),
       decode(nvl(action_information9,'N'),'Y', round(nvl(to_number(action_information24),0)),0) ,
       decode(nvl(action_information9,'N'),'Y', round(nvl(to_number(action_information25),0)),0) ,
       decode(nvl(action_information9,'N'),'Y', round(nvl(to_number(action_information27),0)),0) ,
       to_number(action_information8 )
from pay_assignment_actions paa,
     pay_action_information pai
where paa.payroll_action_id = p_payroll_action_id
and paa.serial_number = p_person_id
--and pai.effective_date = p_effective_date
and pai.action_information7 = fnd_date.date_to_canonical(p_effective_date) /*Bug 8402505*/
and pai.action_context_id = paa.assignment_action_id
and pai.action_information_category='MX YREND EE DETAILS' ;

  l_annual_tax_calc_flag varchar2(1);
  l_prev_er_isr_earnings number ;
  l_prev_er_isr_withheld number ;
  l_prev_er_isr_exempt   number ;
  l_seniority            number ;

begin

/* ----------

Following balances should be archived during the ye archive process
cursor c_get_balances should return the following balances

AMENDS_PER_PDS_GRE_YTD
FORMAT_2D_AID_FOR_PANTRY_AND_FOOD_PER_PDS_GRE_YTD
FORMAT_37_ASSIMILATED_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_CURRENT_FISCAL_YEAR_ARREARS_PER_PDS_GRE_YTD
FORMAT_37_ISR_CREDITABLE_SUBSIDY_AS_PER_FRACTION_III_PER_PDS_GRE_YTD
FORMAT_37_ISR_CREDITABLE_SUBSIDY_AS_PER_FRACTION_IV_PER_PDS_GRE_YTD
FORMAT_37_ISR_EXEMPT_FOR_AMENDS_PER_PDS_GRE_YTD
FORMAT_37_ISR_EXEMPT_FOR_OTHER_INCOME_PER_PDS_GRE_YTD
FORMAT_37_ISR_EXEMPT_FOR_SOCIAL_FORESIGHT_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_ISR_ON_NON_CUMULATIVE_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_ISR_ON_SUBJECT_BOX_TOTALS_PER_PDS_GRE_YTD
FORMAT_37_ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD
FORMAT_37_ISR_SUBJECT_FOR_OTHER_INCOME_PER_PDS_GRE_YTD
FORMAT_37_ISR_WITHHELD_FOR_ASSIMILATED_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_ISR_WITHHELD_FOR_RETIREMENT_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_NON_CUMULATIVE_AMENDS_PER_PDS_GRE_YTD
FORMAT_37_PREVIOUS_FISCAL_YEAR_ARREARS_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_CUMULATIVE_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_DAILY_EARNINGS_IN_ONE_PAYMENT_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_EARNINGS_DAYS_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_EARNINGS_IN_ONE_PAYMENT_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_EARNINGS_IN_PARTIAL_PAYMENTS_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_EXEMPT_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_PERIOD_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_RETIREMENT_TAXABLE_EARNINGS_PER_PDS_GRE_YTD
FORMAT_37_SOCIAL_FORESIGHT_EARNINGS_PER_PDS_GRE_YTD
ISR_CALCULATED_PER_PDS_GRE_YTD
ISR_CREDITABLE_SUBSIDY_PER_PDS_GRE_YTD
ISR_CREDIT_TO_SALARY_PAID_PER_PDS_GRE_YTD
ISR_CREDIT_TO_SALARY_PER_PDS_GRE_YTD
ISR_NON_CREDITABLE_SUBSIDY_PER_PDS_GRE_YTD
ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD
ISR_WITHHELD_FOR_AMENDS_PER_PDS_GRE_YTD
ISR_WITHHELD_PER_PDS_GRE_YTD
LAST_MONTHLY_ORDINARY_SALARY_PER_PDS_GRE_YTD
LAST_MONTHLY_ORDINARY_SALARY_WITHHELD_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_CHILDREN_SCHOLARSHIP_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_CHRISTMAS_BONUS_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_DISABILITIES_SUBSIDY_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_DOMINICAL_PREMIUM_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_EDUCATIONAL_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_FIXED_EARNINGS_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_FUNERAL_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_GASOLINE_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_GLASSES_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_HEALTHCARE_REIMBURSEMENT_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_LIFE_INSURANCE_PREMIUM_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_MAJOR_MEDICAL_EXPENSE_INSURANCE_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_OVERTIME_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_PANTRY_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_PROFIT_SHARING_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_PUNCTUALITY_INCENTIVE_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_RENTAL_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_RESTAURANT_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_SAVINGS_BOX_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_SAVINGS_FUND_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_TRANSPORTATION_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_TRAVEL_EXPENSES_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_UNIFORM_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_UNION_QUOTA_PAID_BY_ER_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_VACATION_PREMIUM_PER_PDS_GRE_YTD
YEAR_END_ISR_EXEMPT_FOR_WORKER_CONTRIBUTION_PAID_BY_ER_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_CHILDREN_SCHOLARSHIP_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_CHRISTMAS_BONUS_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_DISABILITIES_SUBSIDY_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_DOMINICAL_PREMIUM_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_EDUCATIONAL_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_FIXED_EARNINGS_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_FUNERAL_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_GASOLINE_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_GLASSES_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_HEALTHCARE_REIMBURSEMENT_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_LIFE_INSURANCE_PREMIUM_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_MAJOR_MEDICAL_EXPENSE_INSURANCE_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_OVERTIME_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_PANTRY_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_PROFIT_SHARING_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_PUNCTUALITY_INCENTIVE_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_RENTAL_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_RESTAURANT_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_SAVINGS_BOX_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_SAVINGS_FUND_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_TRANSPORTATION_AID_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_TRAVEL_EXPENSES_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_UNIFORM_COUPONS_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_UNION_QUOTA_PAID_BY_ER_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_VACATION_PREMIUM_PER_PDS_GRE_YTD
YEAR_END_ISR_SUBJECT_FOR_WORKER_CONTRIBUTION_PAID_BY_ER_PER_PDS_GRE_YTD

EMPLOYE_STATE_TAX_WITHHELD_PER_PDS_GRE_YTD

YEAR_END_STOCK_OPTIONS_VESTING_MARKET_VALUE_PER_PDS_GRE_YTD
YEAR_END_STOCK_OPTIONS_GRANT_PRICE_PER_PDS_GRE_YTD
YEAR_END_STOCK_OPTIONS_CUMULATIVE_INCOME_PER_PDS_GRE_YTD
YEAR_END_STOCK_OPTIONS_ISR_WITHHELD_PER_PDS_GRE_YTD



------ */

    -- get the Previous ER ISR earnings,Withheld and Exempt
    l_annual_tax_calc_flag := null ;
    l_prev_er_isr_earnings := 0 ;
    l_prev_er_isr_withheld := 0 ;
    l_prev_er_isr_exempt   := 0 ;
    l_seniority            := null ;

    open c_prev_er_isr_withheld ;
    fetch c_prev_er_isr_withheld into l_annual_tax_calc_flag, l_prev_er_isr_earnings, l_prev_er_isr_withheld,
                                      l_prev_er_isr_exempt, l_seniority  ;
    close c_prev_er_isr_withheld ;


     g_format37_cache.sz := 0;

     FOR c_get_balances_rec IN c_get_balances LOOP
         g_format37_cache.sz := g_format37_cache.sz + 1;
         g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id ;
         g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
         g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
         g_format37_cache.bal_name(g_format37_cache.sz) := 'A_'||c_get_balances_rec.user_entity_name ;

         if l_seniority is null and
            ( c_get_balances_rec.user_entity_name = 'AMENDS_PER_PDS_GRE_YTD' or
              c_get_balances_rec.user_entity_name = 'FORMAT_37_ISR_EXEMPT_FOR_AMENDS_PER_PDS_GRE_YTD' or
              c_get_balances_rec.user_entity_name = 'FORMAT_37_ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD' or
              c_get_balances_rec.user_entity_name = 'FORMAT_37_NON_CUMULATIVE_AMENDS_PER_PDS_GRE_YTD'
            )  then

            g_format37_cache.bal_value(g_format37_cache.sz) := 0 ;

         elsif l_annual_tax_calc_flag <> 'Y' and
               c_get_balances_rec.user_entity_name = 'ISR_CALCULATED_PER_PDS_GRE_YTD' then

            g_format37_cache.bal_value(g_format37_cache.sz) := 0 ;

         else
            g_format37_cache.bal_value(g_format37_cache.sz) :=
            pay_mx_yearend_rep.get_ye_arch_bal_amt(p_payroll_action_id,p_person_id,p_effective_date,
                       'A_'||c_get_balances_rec.user_entity_name ) ;
         end if;

    END LOOP ;


    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'PREV_ER_ISR_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) := l_prev_er_isr_earnings ;

    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'PREV_ER_ISR_WITHHELD' ;
    g_format37_cache.bal_value(g_format37_cache.sz) := l_prev_er_isr_withheld ;

    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'PREV_ER_ISR_EXEMPT' ;
    g_format37_cache.bal_value(g_format37_cache.sz) := l_prev_er_isr_exempt ;

    -- derived balances
    -- Sum of subject earnings caused for wages and salaries
    -- j1 Sum of Subject Portions from h to i1
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOTAL_SUBJECT_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_FIXED_EARNINGS_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_CHRISTMAS_BONUS_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_TRAVEL_EXPENSES_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_OVERTIME_PER_PDS_GRE_YTD')        +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_VACATION_PREMIUM_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_DOMINICAL_PREMIUM_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_PROFIT_SHARING_PER_PDS_GRE_YTD' )   +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_HEALTHCARE_REIMBURSEMENT_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_SAVINGS_FUND_PER_PDS_GRE_YTD')  +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_SAVINGS_BOX_PER_PDS_GRE_YTD')   +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_PANTRY_COUPONS_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_YEAR_END_ISR_SUBJECT_FOR_FUNERAL_AID_PER_PDS_GRE_YTD')    +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
    'A_YEAR_END_ISR_SUBJECT_FOR_WORKER_CONTRIBUTION_PAID_BY_ER_PER_PDS_GRE_YTD' ) +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_PUNCTUALITY_INCENTIVE_PER_PDS_GRE_YTD')     +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_LIFE_INSURANCE_PREMIUM_PER_PDS_GRE_YTD')    +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_MAJOR_MEDICAL_EXPENSE_INSURANCE_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_RESTAURANT_COUPONS_PER_PDS_GRE_YTD')        +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_GASOLINE_COUPONS_PER_PDS_GRE_YTD')          +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_UNIFORM_COUPONS_PER_PDS_GRE_YTD')           +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_RENTAL_AID_PER_PDS_GRE_YTD')                +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_EDUCATIONAL_AID_PER_PDS_GRE_YTD'   )        +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_GLASSES_AID_PER_PDS_GRE_YTD')               +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_TRANSPORTATION_AID_PER_PDS_GRE_YTD' )       +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_UNION_QUOTA_PAID_BY_ER_PER_PDS_GRE_YTD')    +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_DISABILITIES_SUBSIDY_PER_PDS_GRE_YTD' )     +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_YEAR_END_ISR_SUBJECT_FOR_CHILDREN_SCHOLARSHIP_PER_PDS_GRE_YTD' )     +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'PREV_ER_ISR_EARNINGS' )                                                +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
     'A_FORMAT_37_ISR_SUBJECT_FOR_OTHER_INCOME_PER_PDS_GRE_YTD' )     ;


    -- Sum of exempt earnings caused for wages and salaries k1
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOTAL_EXEMPT_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_FIXED_EARNINGS_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_CHRISTMAS_BONUS_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_TRAVEL_EXPENSES_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_OVERTIME_PER_PDS_GRE_YTD')        +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_VACATION_PREMIUM_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_DOMINICAL_PREMIUM_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_PROFIT_SHARING_PER_PDS_GRE_YTD' )   +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_HEALTHCARE_REIMBURSEMENT_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_SAVINGS_FUND_PER_PDS_GRE_YTD')      +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_SAVINGS_BOX_PER_PDS_GRE_YTD')       +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_PANTRY_COUPONS_PER_PDS_GRE_YTD')    +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_FUNERAL_AID_PER_PDS_GRE_YTD')       +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_WORKER_CONTRIBUTION_PAID_BY_ER_PER_PDS_GRE_YTD' ) +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_PUNCTUALITY_INCENTIVE_PER_PDS_GRE_YTD')     +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_LIFE_INSURANCE_PREMIUM_PER_PDS_GRE_YTD')      +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_MAJOR_MEDICAL_EXPENSE_INSURANCE_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_RESTAURANT_COUPONS_PER_PDS_GRE_YTD')        +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_GASOLINE_COUPONS_PER_PDS_GRE_YTD')          +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_UNIFORM_COUPONS_PER_PDS_GRE_YTD')           +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_RENTAL_AID_PER_PDS_GRE_YTD')                +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_EDUCATIONAL_AID_PER_PDS_GRE_YTD'   )        +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_SUBJECT_FOR_GLASSES_AID_PER_PDS_GRE_YTD')              +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_TRANSPORTATION_AID_PER_PDS_GRE_YTD' )       +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_UNION_QUOTA_PAID_BY_ER_PER_PDS_GRE_YTD')    +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_DISABILITIES_SUBSIDY_PER_PDS_GRE_YTD' )    +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_YEAR_END_ISR_EXEMPT_FOR_CHILDREN_SCHOLARSHIP_PER_PDS_GRE_YTD' )    +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'PREV_ER_ISR_EXEMPT' )                                              +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
          'A_FORMAT_37_ISR_EXEMPT_FOR_OTHER_INCOME_PER_PDS_GRE_YTD') ;

    -- Total earnings caused for salary, wages and assimilated concepts
    -- A =      O + P + a + i + m + Q1 + R1
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOT_EARNING_ASSI_CONCEPTS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_FORMAT_37_RETIREMENT_DAILY_EARNINGS_IN_ONE_PAYMENT_PER_PDS_GRE_YTD') +
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_FORMAT_37_RETIREMENT_EARNINGS_IN_PARTIAL_PAYMENTS_PER_PDS_GRE_YTD' ) +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_AMENDS_PER_PDS_GRE_YTD') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_FORMAT_37_ASSIMILATED_EARNINGS_PER_PDS_GRE_YTD' ) +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_YEAR_END_STOCK_OPTIONS_CUMULATIVE_INCOME_PER_PDS_GRE_YTD' ) +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOTAL_SUBJECT_EARNINGS' ) +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOTAL_EXEMPT_EARNINGS')  ;


    -- c =      Exempt earnings a - d
    -- a        Total amount paid Amends
    -- d        Subject earnings ISR Subject for Amends
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'ISR_EXEMPT_FOR_AMENDS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_AMENDS_PER_PDS_GRE_YTD' ) -
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD')  ;

    -- Exempt earnings
    -- C =      T + c + R1
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOT_EXEMPT_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
       'A_FORMAT_37_RETIREMENT_EXEMPT_EARNINGS_PER_PDS_GRE_YTD' ) +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'ISR_EXEMPT_FOR_AMENDS') +
    get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOTAL_EXEMPT_EARNINGS')  ;


    -- Non cumulative earnings
    -- W = U - V
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'RET_NON_CUMULATIVE_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
         'A_FORMAT_37_RETIREMENT_TAXABLE_EARNINGS_PER_PDS_GRE_YTD' ) -
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
         'A_FORMAT_37_RETIREMENT_CUMULATIVE_EARNINGS_PER_PDS_GRE_YTD')  ;

    -- need to calculate d first using
    -- g        Non-cumulative earnings IF d <> e AND d > e THEN g  = d minus e ELSE g = 0
    --d Subject earnings        ISR Subject for Amends
    --e Cumulative earnings (last monthly ordinary salary)
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'NON_CUMULATIVE_AMENDS' ;
    if ( get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD' ) <>
        get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_LAST_MONTHLY_ORDINARY_SALARY_PER_PDS_GRE_YTD' )
       ) AND
       ( get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD' ) >
        get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_LAST_MONTHLY_ORDINARY_SALARY_PER_PDS_GRE_YTD' )
       ) THEN

         g_format37_cache.bal_value(g_format37_cache.sz) :=
         get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_ISR_SUBJECT_FOR_AMENDS_PER_PDS_GRE_YTD' ) -
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_LAST_MONTHLY_ORDINARY_SALARY_PER_PDS_GRE_YTD' )  ;

    else
       g_format37_cache.bal_value(g_format37_cache.sz) := 0 ;
    end if;


    -- Non cumulative earnings
    -- D        Non cumulative earnings W + g
    -- W        Non cumulative earnings U - V
    -- g        Non-cumulative earnings IF d <> e AND d > e THEN g  = d - e ELSE g = 0
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOT_NON_CUMULATIVE_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'RET_NON_CUMULATIVE_EARNINGS') +
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'NON_CUMULATIVE_AMENDS')  ;

/*Bug#:9171641:Calculate 'Total amount of deductable voluntary contributions' */
-- Total amount of deductable voluntary contributions
    -- E = TOT_DED_VOL_CONTRIBUTION

    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOT_DED_VOL_CONTRIBUTION' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
        get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
           'A_FORMAT_37_VOLUNTARY_CONTRIBUTIONS_ER_PER_PDS_GRE_YTD');
/*Bug#:9171641 */

    -- Cumulative earnings
    -- F = A -B - C - D -E

    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TOT_CUMULATIVE_EARNINGS' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOT_EARNING_ASSI_CONCEPTS') -
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
           'A_EMPLOYEE_STATE_TAX_WITHHELD_PER_PDS_GRE_YTD') -
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOT_EXEMPT_EARNINGS') -
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOT_NON_CUMULATIVE_EARNINGS')-
     get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'TOT_DED_VOL_CONTRIBUTION') ;
     /*Bug#:9171641: Subtract 'Cumulative earnings' by TOT_DED_VOL_CONTRIBUTION */


   -- Tax on cumulative earnings
   -- K = F - G
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'ISR_ON_CUMULATIVE_EARNINGS' ;
    if l_annual_tax_calc_flag = 'Y' then
     g_format37_cache.bal_value(g_format37_cache.sz) :=
       get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_ISR_CALCULATED_PER_PDS_GRE_YTD') -
       get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'A_ISR_CREDITABLE_SUBSIDY_PER_PDS_GRE_YTD') ;
    else
     g_format37_cache.bal_value(g_format37_cache.sz) := 0 ;
    end if;


   -- Tax on income caused in fiscal year
   -- L = J + K
   -- M = K + L
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TAX_ON_INCOME_FISCAL_YEAR' ;
    if l_annual_tax_calc_flag = 'Y' then
       g_format37_cache.bal_value(g_format37_cache.sz) :=
       get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'ISR_ON_CUMULATIVE_EARNINGS') +
       get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_FORMAT_37_ISR_ON_NON_CUMULATIVE_EARNINGS_PER_PDS_GRE_YTD') ;
    else
       g_format37_cache.bal_value(g_format37_cache.sz) := 0 ;
    end if ;

    -- U1       Tax withheld in fiscal year     ISR Withheld - h
    -- ISR Withheld
    -- h        Tax withheld    ISR Withheld for Amends
    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'TAX_WITHHELD_IN_FISCAL_YEAR' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_ISR_WITHHELD_PER_PDS_GRE_YTD') -
       get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_ISR_WITHHELD_FOR_AMENDS_PER_PDS_GRE_YTD') ;

   -- Tax withheld
   -- N = x + h + j + n + U1 + V1

    g_format37_cache.sz := g_format37_cache.sz + 1;
    g_format37_cache.payroll_action_id(g_format37_cache.sz) := p_payroll_action_id;
    g_format37_cache.person_id(g_format37_cache.sz) := p_person_id ;
    g_format37_cache.effective_date(g_format37_cache.sz) := p_effective_date ;
    g_format37_cache.bal_name(g_format37_cache.sz) := 'ISR_TAX_WITHHELD' ;
    g_format37_cache.bal_value(g_format37_cache.sz) :=
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_FORMAT_37_ISR_WITHHELD_FOR_RETIREMENT_EARNINGS_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_ISR_WITHHELD_FOR_AMENDS_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_FORMAT_37_ISR_WITHHELD_FOR_ASSIMILATED_EARNINGS_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'A_YEAR_END_STOCK_OPTIONS_ISR_WITHHELD_PER_PDS_GRE_YTD') +
      get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,
        'TAX_WITHHELD_IN_FISCAL_YEAR') +
       get_cache_balance(p_payroll_action_id,p_person_id,p_effective_date,'PREV_ER_ISR_WITHHELD') ;

end load_bal;

/******************************************************************
Name      : bal_loaded
Purpose   : function to check whether the balances loaded to pl/sql
            table or not
******************************************************************/
function bal_loaded(p_payroll_action_id  in number,
                    p_person_id          in number,
                    p_effective_date     in date
                    )
   return boolean is

   l_bal_loaded  boolean ;
begin
   l_bal_loaded := FALSE ;

   if g_format37_cache.sz is not null then

      for ctr in 1..g_format37_cache.sz loop

      if ( g_format37_cache.payroll_action_id(ctr) is null
          and g_format37_cache.person_id(ctr) is null
          and g_format37_cache.effective_date(ctr) is null ) or
        (g_format37_cache.payroll_action_id(ctr) = p_payroll_action_id
          and  g_format37_cache.person_id(ctr) = p_person_id
          and  g_format37_cache.effective_date(ctr) = p_effective_date)  then

         l_bal_loaded := TRUE ;

     end if;

     end loop ;

   end if;

   return l_bal_loaded ;

end bal_loaded ;

/******************************************************************
Name      : get_f37_balance
Purpose   : retruns format37 balance. called from the
            pay_mx_isr_tax_format_v
******************************************************************/
function get_f37_balance(p_payroll_action_id  in number,
                         p_person_id          in number,
                         p_effective_date     in date,
                         p_bal_name           in varchar2 )
   return number is

l_bal_amt  number;
l_bal_loaded boolean ;

begin
--


   l_bal_amt    := 0 ;


   l_bal_loaded := bal_loaded(p_payroll_action_id, p_person_id,p_effective_date ) ;

   if NOT l_bal_loaded then

       load_bal(p_payroll_action_id, p_person_id,p_effective_date );

   end if;

   l_bal_amt := get_cache_balance(p_payroll_action_id, p_person_id,p_effective_date,p_bal_name ) ;

   return l_bal_amt;

end get_f37_balance ;


end pay_mx_yearend_rep;

/
