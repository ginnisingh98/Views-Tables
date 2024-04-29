--------------------------------------------------------
--  DDL for Package Body PAY_US_MULTI_MMRF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MULTI_MMRF" AS
/* $Header: payusmultimmrf.pkb 120.0.12000000.1 2007/02/23 10:16:48 sackumar noship $ */
FUNCTION  get_w2_er_arch_bal(
                         w2_balance_name      in varchar2,
                         w2_tax_unit_id           in varchar2,
                         w2_jurisdiction_code   in varchar2,
                         w2_jurisdiction_level   in varchar2,
                         w2_year                     in varchar2,
                         a1 OUT NOCOPY varchar2,
                         a2 OUT NOCOPY varchar2,
                         a3 OUT NOCOPY varchar2,
                         a4 OUT NOCOPY varchar2,
                         a5 OUT NOCOPY varchar2,
                         a6 OUT NOCOPY varchar2,
                         a7 OUT NOCOPY varchar2,
                         a8 OUT NOCOPY varchar2,
                         a9 OUT NOCOPY varchar2,
                         a10 OUT NOCOPY varchar2,
                         a11 OUT NOCOPY varchar2,
                         a12 OUT NOCOPY varchar2,
                         a13 OUT NOCOPY varchar2,
                         a14 OUT NOCOPY varchar2,
                         a15 OUT NOCOPY varchar2,
                         a16 OUT NOCOPY varchar2,
                         a17 OUT NOCOPY varchar2,
                         a18 OUT NOCOPY varchar2,
                         a19 OUT NOCOPY varchar2,
                         a20 OUT NOCOPY varchar2,
                         a21 OUT NOCOPY varchar2,
                         a22 OUT NOCOPY varchar2,
                         a23 OUT NOCOPY varchar2,
                         a24 OUT NOCOPY varchar2,
                         a25 OUT NOCOPY varchar2,
                         a26 OUT NOCOPY varchar2,
                         a27 OUT NOCOPY varchar2,
                         a28 OUT NOCOPY varchar2,
                         a29 OUT NOCOPY varchar2,
                         a30 OUT NOCOPY varchar2,
                         a31 OUT NOCOPY varchar2,
                         a32 OUT NOCOPY varchar2,
                         a33 OUT NOCOPY varchar2,
                         a34 OUT NOCOPY varchar2,
                         a35 OUT NOCOPY varchar2,
                         a36 OUT NOCOPY varchar2,
                         a37 OUT NOCOPY varchar2,
                         a38 OUT NOCOPY varchar2,
                         a39 OUT NOCOPY varchar2,
                         a40 OUT NOCOPY varchar2,
                         a41 OUT NOCOPY varchar2,
                         a42 OUT NOCOPY varchar2,
                         a43 OUT NOCOPY varchar2,
                         a44 OUT NOCOPY varchar2,
                         a45 OUT NOCOPY varchar2,
                         a46 OUT NOCOPY varchar2,
                         a47 OUT NOCOPY varchar2
                         )
                          RETURN varchar2 IS

CURSOR C_EMP_count(cp_tax_unit_id number) IS
  select   count(*)
   from pay_payroll_actions ppa,
           pay_assignment_actions paa
 where ppa.report_type            = 'W2'
     and report_qualifier             = 'FED'
     and effective_date              = to_date('31/12/'||w2_year,'dd/mm/yyyy')
     and ppa.payroll_action_id    = paa.payroll_action_id
     and paa.action_status          = 'C'
     and paa.tax_unit_id             = cp_tax_unit_id;

CURSOR C_ER_SUM ( P_TAX_UNIT_ID number) IS
SELECT user_entity_name,
              DECODE(fue.user_entity_name,
       'A_REGULAR_EARNINGS_PER_GRE_YTD' ,nvl(sum(value),0) * 100,
       'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,nvl(sum(value),0) * 100,
       'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,nvl(sum(value),0) * 100,
       'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,nvl(sum(value),0) * 100,
       'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' ,nvl(sum(value),0) * 100,
       'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' ,nvl(sum(value),0) * 100,
       'A_FIT_WITHHELD_PER_GRE_YTD',nvl(sum(value),0) * 100,
       'A_SS_EE_TAXABLE_PER_GRE_YTD', nvl(sum(value),0) * 100 ,
       'A_SS_EE_WITHHELD_PER_GRE_YTD', nvl(sum(value),0) * 100 ,
       'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD', nvl(sum(value),0) * 100 ,
       'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD', nvl(sum(value),0) * 100 ,
       'A_W2_BOX_7_PER_GRE_YTD', nvl(sum(value),0) * 100 ,
       'A_EIC_ADVANCE_PER_GRE_YTD',nvl(sum(value),0) * 100,
       'A_W2_DEPENDENT_CARE_PER_GRE_YTD',nvl(sum(value),0) * 100  ,
       'A_W2_401K_PER_GRE_YTD',nvl(sum(value),0) * 100,
       'A_W2_403B_PER_GRE_YTD',nvl(sum(value),0) * 100,
       'A_W2_408K_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_457_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_501C_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_MILITARY_HOUSING_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_NONQUAL_PLAN_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_NONQUAL_457_PER_GRE_YTD',nvl(sum(value),0) * 100,
       'A_W2_BOX_11_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_FIT_3RD_PARTY_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_NONQUAL_STOCK_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_HSA_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_NONTAX_COMBAT_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD',nvl(sum(value),0) * 100,
       'A_W2_BOX_8_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_MSA_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_408P_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_ADOPTION_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_UNCOLL_SS_GTL_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_UNCOLL_MED_GTL_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD', nvl(sum(value),0) * 100,
       'A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD', nvl(sum(value),0) * 100
       , 'A_W2_ROTH_401K_PER_GRE_YTD', nvl(sum(value),0) * 100
       , 'A_W2_ROTH_403B_PER_GRE_YTD', nvl(sum(value),0) * 100
       ) val
 FROM  ff_archive_items fai,
             pay_action_interlocks pai,
             pay_payroll_actions  ppa,
             pay_assignment_actions paa,
             ff_user_entities fue
where   ppa.report_type           = 'W2'
   and ppa.report_qualifier         = 'FED'
   and effective_date                 = to_date('31/12/'||w2_year,'dd/mm/yyyy')
   and ppa.payroll_action_id       = paa.payroll_action_id
   and paa.tax_unit_id                = p_tax_unit_id
   and paa.action_status             = 'C'
   and paa.assignment_action_id = pai.locking_action_id
   and fai.context1                     = pai.locked_action_id
   and fai.user_entity_id             = fue.user_entity_id
   and fue.user_entity_name  IN
(
     'A_REGULAR_EARNINGS_PER_GRE_YTD' ,
     'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,
     'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,
     'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' ,
     'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' ,
     'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' ,
     'A_FIT_WITHHELD_PER_GRE_YTD',
     'A_SS_EE_TAXABLE_PER_GRE_YTD',
     'A_SS_EE_WITHHELD_PER_GRE_YTD',
     'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD',
     'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD',
     'A_W2_BOX_7_PER_GRE_YTD',
     'A_EIC_ADVANCE_PER_GRE_YTD',
     'A_W2_DEPENDENT_CARE_PER_GRE_YTD',
     'A_W2_401K_PER_GRE_YTD',
     'A_W2_403B_PER_GRE_YTD',
     'A_W2_408K_PER_GRE_YTD',
     'A_W2_457_PER_GRE_YTD',
     'A_W2_501C_PER_GRE_YTD',
     'A_W2_MILITARY_HOUSING_PER_GRE_YTD',
     'A_W2_NONQUAL_PLAN_PER_GRE_YTD',
     'A_W2_NONQUAL_457_PER_GRE_YTD',
     'A_W2_BOX_11_PER_GRE_YTD',
     'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD',
     'A_FIT_3RD_PARTY_PER_GRE_YTD',
     'A_W2_NONQUAL_STOCK_PER_GRE_YTD',
     'A_W2_HSA_PER_GRE_YTD',
     'A_W2_NONTAX_COMBAT_PER_GRE_YTD',
     'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD',
     'A_W2_BOX_8_PER_GRE_YTD',
     /* Sum of  */
     'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD',
     'A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD',
     'A_W2_MSA_PER_GRE_YTD',
     'A_W2_408P_PER_GRE_YTD',
     'A_W2_ADOPTION_PER_GRE_YTD',
     'A_W2_UNCOLL_SS_GTL_PER_GRE_YTD',
     'A_W2_UNCOLL_MED_GTL_PER_GRE_YTD',
     'A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD',
     'A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD',
     'A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD',
     'A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD',
     'A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD'
   , 'A_W2_ROTH_401K_PER_GRE_YTD'
   , 'A_W2_ROTH_403B_PER_GRE_YTD'
)
group by fue.user_entity_name;

CURSOR c_ter(cp_tax_unit_id number) IS
SELECT
 fue.user_entity_name,decode(fue.user_entity_name,
                              'A_SIT_WITHHELD_PER_JD_GRE_YTD',nvl(sum(value),0) * 100,
                              'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD',nvl(sum(value),0) * 100,
                              'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD',nvl(sum(value),0) * 100,
                              'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD',nvl(sum(value),0) * 100
                              ) val
FROM ff_archive_item_contexts faic
           ,ff_archive_items fai
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,pay_action_interlocks pai
           ,ff_user_entities fue
WHERE
    ppa.report_type                   = 'W2'
and ppa.report_qualifier           = 'FED'
and ppa.effective_date            = to_date('31/12/'||w2_year,'dd/mm/yyyy')
and paa.payroll_action_id        = ppa.payroll_action_id
and paa.assignment_action_id  = pai.locking_action_id
and fai.context1                      = pai.locked_action_id
and context                            = '72-000-0000'
and fai.archive_item_id           = faic.archive_item_id
and fai.user_entity_id             = fue.user_entity_id
and paa.tax_unit_id                = cp_tax_unit_id
and fue.user_entity_name       in ( 'A_SIT_WITHHELD_PER_JD_GRE_YTD',
                                                   'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD',
                                                   'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD',
                                                   'A_SIT_PRE_TAX_REDNS_PER_JD_GRE_YTD')
and paa.action_status = 'C'
group by fue.user_entity_name;


CURSOR c_ro_count ( cp_tax_unit_id number) IS
select count(*)
from pay_payroll_actions ppa
       ,pay_assignment_actions paa
       ,ff_archive_items fai
where ppa.report_type = 'W2'
    and ppa.report_qualifier = 'FED'
    and effective_date = to_date('31/12/'||w2_year,'dd/mm/yyyy')
    and ppa.payroll_action_id = paa.payroll_action_id
    and paa.assignment_action_id = fai.context1
    and name is not null
    and name like 'TRANSFER_RO_TOTAL'
    and paa.tax_unit_id = cp_tax_unit_id
  group by tax_unit_id;

l_date                date;
l_tax_unit_id      varchar2(10);
l_total_emp        number;
l_er_sum           er_sum_table;
l_fit_with           varchar2(20);
l_ss_ee_taxable varchar2(20);
l_ro_count         number;

BEGIN

        a1 := '0';
        a2 := '0';
        a3 := '0';
        a4 := '0';
        a5 := '0';
        a6 := '0';
        a7 := '0';
        a8 := '0';
        a9 := '0';
        a10:= '0';
        a11 := '0';
        a12 := '0';
        a13 := '0';
        a14 := '0';
        a15 := '0';
        a16 := '0';
        a17 := '0';
        a18 := '0';
        a19 := '0';
        a20 := '0';
        a21 := '0';
        a22 := '0';
        a23 := '0';
        a24 := '0';
        a25 := '0';
        a26 := '0';
        a27 := '0';
        a28 := '0';
        a29 := '0';
        a30 := '0';
        a31 := '0';
        a32 := '0';
        a33 := '0';
        a34 := '0';
        a35 := '0';
        a36 := '0';
        a37 := '0';
        a38 := '0';
        a39 := '0';
        a40 := '0';
        a41 := '0';
        a42 := '0';
        a43 := '0';
        a44 := '0';
        a45 := '0';
        a46 := '0';
        a47 := '0';


     OPEN   C_EMP_COUNT(to_number(W2_tax_unit_id));
     FETCH C_EMP_COUNT  INTO a1;
     IF C_EMP_COUNT%NOTFOUND THEN
         a1 := 0;
     END IF;
     CLOSE C_EMP_COUNT;



   FOR I IN C_ER_SUM(to_number(W2_TAX_UNIT_ID)) LOOP

       if I.user_entity_name = 'A_REGULAR_EARNINGS_PER_GRE_YTD' THEN
              a2 := a2 + i.val;
       ELSIF I.user_entity_name = 'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' THEN
             a2 := a2 + i.val;
       ELSIF I.user_entity_name = 'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD' THEN
             a2  := a2 + i.val;
       ELSIF I.user_entity_name = 'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD' THEN
             a2 := a2 + i.val;
       ELSIF I.user_entity_name = 'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD' THEN
             a2 := a2 + i.val;
       ELSIF I.user_entity_name = 'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD' THEN
             a2 := a2 - i.val;
       ELSIF I.user_entity_name = 'A_FIT_WITHHELD_PER_GRE_YTD'THEN
              a3 := i.val;
        ELSIF i.user_entity_name =  'A_SS_EE_TAXABLE_PER_GRE_YTD'THEN
             a4 := i.val;
        ELSIF i.user_entity_name ='A_SS_EE_WITHHELD_PER_GRE_YTD' THEN
            a5 := i.val;
        ELSIF i.user_entity_name = 'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD'  THEN
            a6 := i.val;
        ELSIF i.user_entity_name = 'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD'  THEN
            a7 := i.val;
        ELSIF i.user_entity_name =      'A_W2_BOX_7_PER_GRE_YTD'  THEN
            a8 := i.val;
        ELSIF i.user_entity_name =      'A_EIC_ADVANCE_PER_GRE_YTD'  THEN
            a9 := i.val;
        ELSIF i.user_entity_name =      'A_W2_DEPENDENT_CARE_PER_GRE_YTD'  THEN
            a10 := i.val;
        ELSIF i.user_entity_name =      'A_W2_401K_PER_GRE_YTD'  THEN
            a11 := i.val;
        ELSIF i.user_entity_name =      'A_W2_403B_PER_GRE_YTD'  THEN
            a12 := i.val;
        ELSIF i.user_entity_name =      'A_W2_408K_PER_GRE_YTD'  THEN
            a13 := i.val;
        ELSIF i.user_entity_name =     'A_W2_457_PER_GRE_YTD'  THEN
            a14 := i.val;
        ELSIF i.user_entity_name =      'A_W2_501C_PER_GRE_YTD'  THEN
            a15 := i.val;
        ELSIF i.user_entity_name =      'A_W2_MILITARY_HOUSING_PER_GRE_YTD'  THEN
            a16 := i.val;
        ELSIF i.user_entity_name =      'A_W2_NONQUAL_457_PER_GRE_YTD'  THEN
            a17:= i.val;
        ELSIF i.user_entity_name =      'A_W2_BOX_11_PER_GRE_YTD'  THEN
            a18 := i.val;
        ELSIF i.user_entity_name =       'A_W2_HSA_PER_GRE_YTD'  THEN
            a19 := i.val;
        ELSIF i.user_entity_name =   'A_W2_NONQUAL_PLAN_PER_GRE_YTD' THEN
            a20 :=  i.val;
        ELSIF i.user_entity_name =   'A_W2_NONTAX_COMBAT_PER_GRE_YTD'  THEN
            a21 := i.val;
         ELSIF i.user_entity_name =      'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD'  THEN
            a22:= i.val;
        ELSIF i.user_entity_name =       'A_FIT_3RD_PARTY_PER_GRE_YTD'  THEN
            a23 := i.val;
        ELSIF i.user_entity_name =        'A_W2_NONQUAL_STOCK_PER_GRE_YTD' THEN
            a24 := i.val;
        ELSIF i.user_entity_name =     'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD' THEN
            a25 := i.val;
       ELSIF i.user_entity_name ='A_W2_BOX_8_PER_GRE_YTD' THEN
             a26 := i.val;
       ELSIF i.user_entity_name = 'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD' THEN
             a27 :=  a27 + i.val;
       ELSIF i.user_entity_name ='A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD' THEN
              a27 :=  a27 + i.val;
       ELSIF i.user_entity_name ='A_W2_MSA_PER_GRE_YTD' THEN
              a28 := i.val;
       ELSIF i.user_entity_name ='A_W2_408P_PER_GRE_YTD' THEN
              a29 := i.val;
       ELSIF i.user_entity_name ='A_W2_ADOPTION_PER_GRE_YTD' THEN
              a30 := i.val;
       ELSIF i.user_entity_name ='A_W2_UNCOLL_SS_GTL_PER_GRE_YTD' THEN
               a31 := i.val;
       ELSIF i.user_entity_name ='A_W2_UNCOLL_MED_GTL_PER_GRE_YTD' THEN
               a32 := i.val;
       ELSIF i.user_entity_name ='A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD' THEN
               a33  := i.val;
       ELSIF i.user_entity_name ='A_TERRITORY_RETIRE_CONTRIB_PER_GRE_YTD' THEN
                a34  := i.val;
       ELSIF i.user_entity_name ='A_TERRITORY_TAXABLE_ALLOW_PER_GRE_YTD' THEN
               a35 := i.val;
       ELSIF i.user_entity_name ='A_TERRITORY_TAXABLE_COMM_PER_GRE_YTD' THEN
               a36  := i.val;
       ELSIF i.user_entity_name ='A_TERRITORY_TAXABLE_TIPS_PER_GRE_YTD' THEN
                a37  := i.val;
       ELSIF i.user_entity_name ='A_W2_ROTH_401K_PER_GRE_YTD' THEN
                a46  := i.val;
       ELSIF i.user_entity_name ='A_W2_ROTH_403B_PER_GRE_YTD' THEN
                a47  := i.val;
       END IF;

       IF i.user_entity_name =      'A_W2_NONQUAL_457_PER_GRE_YTD'  THEN
               a20 := a20 - i.val;
        END IF;
     END LOOP;

    OPEN   c_ro_count(to_number(W2_TAX_UNIT_ID));
    FETCH c_ro_count  INTO l_ro_count;
    CLOSE c_ro_count;
    a38  := to_char(nvl(l_ro_count,0));

   IF l_ro_count > 0 THEN

      FOR J IN c_ter(to_number(W2_TAX_UNIT_ID)) LOOP
          if J.user_entity_name         =  'A_SIT_SUBJ_WHABLE_PER_JD_GRE_YTD' THEN
                a39 := a39 + J.val;
          ELSIF J.user_entity_name =  'A_SIT_SUBJ_NWHABLE_PER_JD_GRE_YTD' THEN
                a39 := a39 + J.val;
          ELSIF J.user_entity_name =  'A_SIT_PRE_TAX_REDNS_PER_GRE_YTD' THEN
                a39  := a39 - J.val;
          ELSIF J.user_entity_name  = 'A_SIT_WITHHELD_PER_JD_GRE_YTD' THEN
                a40  := J.val;
          END IF;
       END LOOP;
    END IF ;

    a41 := to_number(a39) - to_number(a37) - to_number(a35) - to_number(a36);

    return '0' ;
END get_w2_er_arch_bal;
end pay_us_multi_mmrf;

/
