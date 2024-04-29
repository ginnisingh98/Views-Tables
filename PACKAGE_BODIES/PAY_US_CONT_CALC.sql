--------------------------------------------------------
--  DDL for Package Body PAY_US_CONT_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_CONT_CALC" as
/* $Header: pyuscoc.pkb 120.0 2005/05/29 02:18:43 appldev noship $ */

/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Description : Package and procedure to build sql for payroll processes.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   26-MAR-2001  nbristow    115.0           Created.

*/
/* Used generator to build this procedure, but removed some of that table values.
*/
/* PAY_US_EMP_FED_TAX_RULES_F */
/* name : PAY_US_FED_TAX_RULES_F_aru
   purpose : This is procedure that records any changes for updates
             on Federal Tax Rules.
*/
procedure PAY_US_FED_TAX_RULES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDITIONAL_WA_AMOUNT in NUMBER,
p_new_ADDITIONAL_WA_AMOUNT in NUMBER ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_CUMULATIVE_TAXATION in VARCHAR2,
p_new_CUMULATIVE_TAXATION in VARCHAR2 ,
p_old_EIC_FILING_STATUS_CODE in VARCHAR2,
p_new_EIC_FILING_STATUS_CODE in VARCHAR2 ,
p_old_EMP_FED_TAX_RULE_ID in NUMBER,
p_new_EMP_FED_TAX_RULE_ID in NUMBER ,
p_old_EXCESSIVE_WA_REJECT_DATE in DATE,
p_new_EXCESSIVE_WA_REJECT_DATE in DATE ,
p_old_FILING_STATUS_CODE in VARCHAR2,
p_new_FILING_STATUS_CODE in VARCHAR2 ,
p_old_FIT_ADDITIONAL_TAX in NUMBER,
p_new_FIT_ADDITIONAL_TAX in NUMBER ,
p_old_FIT_EXEMPT in VARCHAR2,
p_new_FIT_EXEMPT in VARCHAR2 ,
p_old_FIT_OVERRIDE_AMOUNT in NUMBER,
p_new_FIT_OVERRIDE_AMOUNT in NUMBER ,
p_old_FIT_OVERRIDE_RATE in NUMBER,
p_new_FIT_OVERRIDE_RATE in NUMBER ,
p_old_FUTA_TAX_EXEMPT in VARCHAR2,
p_new_FUTA_TAX_EXEMPT in VARCHAR2 ,
p_old_MEDICARE_TAX_EXEMPT in VARCHAR2,
p_new_MEDICARE_TAX_EXEMPT in VARCHAR2 ,
p_old_SS_TAX_EXEMPT in VARCHAR2,
p_new_SS_TAX_EXEMPT in VARCHAR2 ,
p_old_STATUTORY_EMPLOYEE in VARCHAR2,
p_new_STATUTORY_EMPLOYEE in VARCHAR2 ,
p_old_SUI_JURISDICTION_CODE in VARCHAR2,
p_new_SUI_JURISDICTION_CODE in VARCHAR2 ,
p_old_SUI_STATE_CODE in VARCHAR2,
p_new_SUI_STATE_CODE in VARCHAR2 ,
p_old_SUPP_TAX_OVERRIDE_RATE in NUMBER,
p_new_SUPP_TAX_OVERRIDE_RATE in NUMBER ,
p_old_W2_FILED_YEAR in NUMBER,
p_new_W2_FILED_YEAR in NUMBER ,
p_old_WITHHOLDING_ALLOWANCES in NUMBER,
p_new_WITHHOLDING_ALLOWANCES in NUMBER ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'ADDITIONAL_WA_AMOUNT',
                                     p_old_ADDITIONAL_WA_AMOUNT,
                                     p_new_ADDITIONAL_WA_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'CUMULATIVE_TAXATION',
                                     p_old_CUMULATIVE_TAXATION,
                                     p_new_CUMULATIVE_TAXATION,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'EIC_FILING_STATUS_CODE',
                                     p_old_EIC_FILING_STATUS_CODE,
                                     p_new_EIC_FILING_STATUS_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'EMP_FED_TAX_RULE_ID',
                                     p_old_EMP_FED_TAX_RULE_ID,
                                     p_new_EMP_FED_TAX_RULE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'EXCESSIVE_WA_REJECT_DATE',
                                     p_old_EXCESSIVE_WA_REJECT_DATE,
                                     p_new_EXCESSIVE_WA_REJECT_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'FILING_STATUS_CODE',
                                     p_old_FILING_STATUS_CODE,
                                     p_new_FILING_STATUS_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'FIT_ADDITIONAL_TAX',
                                     p_old_FIT_ADDITIONAL_TAX,
                                     p_new_FIT_ADDITIONAL_TAX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'FIT_EXEMPT',
                                     p_old_FIT_EXEMPT,
                                     p_new_FIT_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'FIT_OVERRIDE_AMOUNT',
                                     p_old_FIT_OVERRIDE_AMOUNT,
                                     p_new_FIT_OVERRIDE_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'FIT_OVERRIDE_RATE',
                                     p_old_FIT_OVERRIDE_RATE,
                                     p_new_FIT_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'FUTA_TAX_EXEMPT',
                                     p_old_FUTA_TAX_EXEMPT,
                                     p_new_FUTA_TAX_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'MEDICARE_TAX_EXEMPT',
                                     p_old_MEDICARE_TAX_EXEMPT,
                                     p_new_MEDICARE_TAX_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'SS_TAX_EXEMPT',
                                     p_old_SS_TAX_EXEMPT,
                                     p_new_SS_TAX_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'STATUTORY_EMPLOYEE',
                                     p_old_STATUTORY_EMPLOYEE,
                                     p_new_STATUTORY_EMPLOYEE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'SUI_JURISDICTION_CODE',
                                     p_old_SUI_JURISDICTION_CODE,
                                     p_new_SUI_JURISDICTION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'SUI_STATE_CODE',
                                     p_old_SUI_STATE_CODE,
                                     p_new_SUI_STATE_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'SUPP_TAX_OVERRIDE_RATE',
                                     p_old_SUPP_TAX_OVERRIDE_RATE,
                                     p_new_SUPP_TAX_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'W2_FILED_YEAR',
                                     p_old_W2_FILED_YEAR,
                                     p_new_W2_FILED_YEAR,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_FED_TAX_RULES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_ASSIGNMENT_ID,
                                            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                                            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => pay_continuous_calc.g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_surrogate_key         => p_old_EMP_FED_TAX_RULE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_US_FED_TAX_RULES_F_aru;
--
/* PAY_US_EMP_STATE_TAX_RULES_F */
/* name : PAY_US_STATE_TAX_RULES_F_aru
   purpose : This is procedure that records any changes for updates
             on State Tax Rules.
*/
procedure PAY_US_STATE_TAX_RULES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDITIONAL_WA_AMOUNT in NUMBER,
p_new_ADDITIONAL_WA_AMOUNT in NUMBER ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_EMP_STATE_TAX_RULE_ID in NUMBER,
p_new_EMP_STATE_TAX_RULE_ID in NUMBER ,
p_old_EXCESSIVE_WA_REJECT_DATE in DATE,
p_new_EXCESSIVE_WA_REJECT_DATE in DATE ,
p_old_FILING_STATUS_CODE in VARCHAR2,
p_new_FILING_STATUS_CODE in VARCHAR2 ,
p_old_JURISDICTION_CODE in VARCHAR2,
p_new_JURISDICTION_CODE in VARCHAR2 ,
p_old_REMAINDER_PERCENT in NUMBER,
p_new_REMAINDER_PERCENT in NUMBER ,
p_old_SDI_EXEMPT in VARCHAR2,
p_new_SDI_EXEMPT in VARCHAR2 ,
p_old_SECONDARY_WA in NUMBER,
p_new_SECONDARY_WA in NUMBER ,
p_old_SIT_ADDITIONAL_TAX in NUMBER,
p_new_SIT_ADDITIONAL_TAX in NUMBER ,
p_old_SIT_EXEMPT in VARCHAR2,
p_new_SIT_EXEMPT in VARCHAR2 ,
p_old_SIT_OPTIONAL_CALC_IND in VARCHAR2,
p_new_SIT_OPTIONAL_CALC_IND in VARCHAR2 ,
p_old_SIT_OVERRIDE_AMOUNT in NUMBER,
p_new_SIT_OVERRIDE_AMOUNT in NUMBER ,
p_old_SIT_OVERRIDE_RATE in NUMBER,
p_new_SIT_OVERRIDE_RATE in NUMBER ,
p_old_STATE_CODE in VARCHAR2,
p_new_STATE_CODE in VARCHAR2 ,
p_old_STATE_NON_RESIDENT_CERT in VARCHAR2,
p_new_STATE_NON_RESIDENT_CERT in VARCHAR2 ,
p_old_SUI_EXEMPT in VARCHAR2,
p_new_SUI_EXEMPT in VARCHAR2 ,
p_old_SUI_WAGE_BASE_OVERRIDE_A in NUMBER,
p_new_SUI_WAGE_BASE_OVERRIDE_A in NUMBER ,
p_old_SUPP_TAX_OVERRIDE_RATE in NUMBER,
p_new_SUPP_TAX_OVERRIDE_RATE in NUMBER ,
p_old_WC_EXEMPT in VARCHAR2,
p_new_WC_EXEMPT in VARCHAR2 ,
p_old_WITHHOLDING_ALLOWANCES in NUMBER,
p_new_WITHHOLDING_ALLOWANCES in NUMBER ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'ADDITIONAL_WA_AMOUNT',
                                     p_old_ADDITIONAL_WA_AMOUNT,
                                     p_new_ADDITIONAL_WA_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'EMP_STATE_TAX_RULE_ID',
                                     p_old_EMP_STATE_TAX_RULE_ID,
                                     p_new_EMP_STATE_TAX_RULE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'EXCESSIVE_WA_REJECT_DATE',
                                     p_old_EXCESSIVE_WA_REJECT_DATE,
                                     p_new_EXCESSIVE_WA_REJECT_DATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'FILING_STATUS_CODE',
                                     p_old_FILING_STATUS_CODE,
                                     p_new_FILING_STATUS_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'JURISDICTION_CODE',
                                     p_old_JURISDICTION_CODE,
                                     p_new_JURISDICTION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'REMAINDER_PERCENT',
                                     p_old_REMAINDER_PERCENT,
                                     p_new_REMAINDER_PERCENT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SDI_EXEMPT',
                                     p_old_SDI_EXEMPT,
                                     p_new_SDI_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SECONDARY_WA',
                                     p_old_SECONDARY_WA,
                                     p_new_SECONDARY_WA,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SIT_ADDITIONAL_TAX',
                                     p_old_SIT_ADDITIONAL_TAX,
                                     p_new_SIT_ADDITIONAL_TAX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SIT_EXEMPT',
                                     p_old_SIT_EXEMPT,
                                     p_new_SIT_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SIT_OPTIONAL_CALC_IND',
                                     p_old_SIT_OPTIONAL_CALC_IND,
                                     p_new_SIT_OPTIONAL_CALC_IND,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SIT_OVERRIDE_AMOUNT',
                                     p_old_SIT_OVERRIDE_AMOUNT,
                                     p_new_SIT_OVERRIDE_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SIT_OVERRIDE_RATE',
                                     p_old_SIT_OVERRIDE_RATE,
                                     p_new_SIT_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'STATE_CODE',
                                     p_old_STATE_CODE,
                                     p_new_STATE_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'STATE_NON_RESIDENT_CERT',
                                     p_old_STATE_NON_RESIDENT_CERT,
                                     p_new_STATE_NON_RESIDENT_CERT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SUI_EXEMPT',
                                     p_old_SUI_EXEMPT,
                                     p_new_SUI_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SUI_WAGE_BASE_OVERRIDE_AMOUNT',
                                     p_old_SUI_WAGE_BASE_OVERRIDE_A,
                                     p_new_SUI_WAGE_BASE_OVERRIDE_A,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'SUPP_TAX_OVERRIDE_RATE',
                                     p_old_SUPP_TAX_OVERRIDE_RATE,
                                     p_new_SUPP_TAX_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'WC_EXEMPT',
                                     p_old_WC_EXEMPT,
                                     p_new_WC_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_STATE_TAX_RULES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_assignment_id,
                                            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                                            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => pay_continuous_calc.g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_surrogate_key         => p_old_EMP_STATE_TAX_RULE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_US_STATE_TAX_RULES_F_aru;
--
/* PAY_US_EMP_COUNTY_TAX_RULES_F */
/* name : PAY_US_COUNTY_TAX_RULES_F_aru
   purpose : This is procedure that records any changes for updates
             on County Tax Rules.
*/
procedure PAY_US_COUNTY_TAX_RULES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDITIONAL_WA_RATE in NUMBER,
p_new_ADDITIONAL_WA_RATE in NUMBER ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_COUNTY_CODE in VARCHAR2,
p_new_COUNTY_CODE in VARCHAR2 ,
p_old_EMP_COUNTY_TAX_RULE_ID in NUMBER,
p_new_EMP_COUNTY_TAX_RULE_ID in NUMBER ,
p_old_FILING_STATUS_CODE in VARCHAR2,
p_new_FILING_STATUS_CODE in VARCHAR2 ,
p_old_HT_EXEMPT in VARCHAR2,
p_new_HT_EXEMPT in VARCHAR2 ,
p_old_JURISDICTION_CODE in VARCHAR2,
p_new_JURISDICTION_CODE in VARCHAR2 ,
p_old_LIT_ADDITIONAL_TAX in NUMBER,
p_new_LIT_ADDITIONAL_TAX in NUMBER ,
p_old_LIT_EXEMPT in VARCHAR2,
p_new_LIT_EXEMPT in VARCHAR2 ,
p_old_LIT_OVERRIDE_AMOUNT in NUMBER,
p_new_LIT_OVERRIDE_AMOUNT in NUMBER ,
p_old_LIT_OVERRIDE_RATE in NUMBER,
p_new_LIT_OVERRIDE_RATE in NUMBER ,
p_old_SCHOOL_DISTRICT_CODE in VARCHAR2,
p_new_SCHOOL_DISTRICT_CODE in VARCHAR2 ,
p_old_SD_EXEMPT in VARCHAR2,
p_new_SD_EXEMPT in VARCHAR2 ,
p_old_STATE_CODE in VARCHAR2,
p_new_STATE_CODE in VARCHAR2 ,
p_old_WITHHOLDING_ALLOWANCES in NUMBER,
p_new_WITHHOLDING_ALLOWANCES in NUMBER ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'ADDITIONAL_WA_RATE',
                                     p_old_ADDITIONAL_WA_RATE,
                                     p_new_ADDITIONAL_WA_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'COUNTY_CODE',
                                     p_old_COUNTY_CODE,
                                     p_new_COUNTY_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'EMP_COUNTY_TAX_RULE_ID',
                                     p_old_EMP_COUNTY_TAX_RULE_ID,
                                     p_new_EMP_COUNTY_TAX_RULE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'FILING_STATUS_CODE',
                                     p_old_FILING_STATUS_CODE,
                                     p_new_FILING_STATUS_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'HT_EXEMPT',
                                     p_old_HT_EXEMPT,
                                     p_new_HT_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'JURISDICTION_CODE',
                                     p_old_JURISDICTION_CODE,
                                     p_new_JURISDICTION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'LIT_ADDITIONAL_TAX',
                                     p_old_LIT_ADDITIONAL_TAX,
                                     p_new_LIT_ADDITIONAL_TAX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'LIT_EXEMPT',
                                     p_old_LIT_EXEMPT,
                                     p_new_LIT_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'LIT_OVERRIDE_AMOUNT',
                                     p_old_LIT_OVERRIDE_AMOUNT,
                                     p_new_LIT_OVERRIDE_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'LIT_OVERRIDE_RATE',
                                     p_old_LIT_OVERRIDE_RATE,
                                     p_new_LIT_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'SCHOOL_DISTRICT_CODE',
                                     p_old_SCHOOL_DISTRICT_CODE,
                                     p_new_SCHOOL_DISTRICT_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'SD_EXEMPT',
                                     p_old_SD_EXEMPT,
                                     p_new_SD_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'STATE_CODE',
                                     p_old_STATE_CODE,
                                     p_new_STATE_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_COUNTY_TAX_RULES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_ASSIGNMENT_ID,
                                            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                                            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => pay_continuous_calc.g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_surrogate_key         => p_old_EMP_COUNTY_TAX_RULE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_US_COUNTY_TAX_RULES_F_aru;
--
/* PAY_US_EMP_CITY_TAX_RULES_F */
/* name : PAY_US_CITY_TAX_RULES_F_aru
   purpose : This is procedure that records any changes for updates
             on City Tax Rules.
*/
procedure PAY_US_CITY_TAX_RULES_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDITIONAL_WA_RATE in NUMBER,
p_new_ADDITIONAL_WA_RATE in NUMBER ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_CITY_CODE in VARCHAR2,
p_new_CITY_CODE in VARCHAR2 ,
p_old_COUNTY_CODE in VARCHAR2,
p_new_COUNTY_CODE in VARCHAR2 ,
p_old_EMP_CITY_TAX_RULE_ID in NUMBER,
p_new_EMP_CITY_TAX_RULE_ID in NUMBER ,
p_old_FILING_STATUS_CODE in VARCHAR2,
p_new_FILING_STATUS_CODE in VARCHAR2 ,
p_old_HT_EXEMPT in VARCHAR2,
p_new_HT_EXEMPT in VARCHAR2 ,
p_old_JURISDICTION_CODE in VARCHAR2,
p_new_JURISDICTION_CODE in VARCHAR2 ,
p_old_LIT_ADDITIONAL_TAX in NUMBER,
p_new_LIT_ADDITIONAL_TAX in NUMBER ,
p_old_LIT_EXEMPT in VARCHAR2,
p_new_LIT_EXEMPT in VARCHAR2 ,
p_old_LIT_OVERRIDE_AMOUNT in NUMBER,
p_new_LIT_OVERRIDE_AMOUNT in NUMBER ,
p_old_LIT_OVERRIDE_RATE in NUMBER,
p_new_LIT_OVERRIDE_RATE in NUMBER ,
p_old_SCHOOL_DISTRICT_CODE in VARCHAR2,
p_new_SCHOOL_DISTRICT_CODE in VARCHAR2 ,
p_old_SD_EXEMPT in VARCHAR2,
p_new_SD_EXEMPT in VARCHAR2 ,
p_old_STATE_CODE in VARCHAR2,
p_new_STATE_CODE in VARCHAR2 ,
p_old_WITHHOLDING_ALLOWANCES in NUMBER,
p_new_WITHHOLDING_ALLOWANCES in NUMBER ,
p_old_EFFECTIVE_END_DATE in DATE,
p_new_EFFECTIVE_END_DATE in DATE ,
p_old_EFFECTIVE_START_DATE in DATE,
p_new_EFFECTIVE_START_DATE in DATE
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_EFFECTIVE_END_DATE = p_new_EFFECTIVE_END_DATE
     and  p_old_EFFECTIVE_START_DATE = p_new_EFFECTIVE_START_DATE) then
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'ADDITIONAL_WA_RATE',
                                     p_old_ADDITIONAL_WA_RATE,
                                     p_new_ADDITIONAL_WA_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'CITY_CODE',
                                     p_old_CITY_CODE,
                                     p_new_CITY_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'COUNTY_CODE',
                                     p_old_COUNTY_CODE,
                                     p_new_COUNTY_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'EMP_CITY_TAX_RULE_ID',
                                     p_old_EMP_CITY_TAX_RULE_ID,
                                     p_new_EMP_CITY_TAX_RULE_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'FILING_STATUS_CODE',
                                     p_old_FILING_STATUS_CODE,
                                     p_new_FILING_STATUS_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'HT_EXEMPT',
                                     p_old_HT_EXEMPT,
                                     p_new_HT_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'JURISDICTION_CODE',
                                     p_old_JURISDICTION_CODE,
                                     p_new_JURISDICTION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'LIT_ADDITIONAL_TAX',
                                     p_old_LIT_ADDITIONAL_TAX,
                                     p_new_LIT_ADDITIONAL_TAX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'LIT_EXEMPT',
                                     p_old_LIT_EXEMPT,
                                     p_new_LIT_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'LIT_OVERRIDE_AMOUNT',
                                     p_old_LIT_OVERRIDE_AMOUNT,
                                     p_new_LIT_OVERRIDE_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'LIT_OVERRIDE_RATE',
                                     p_old_LIT_OVERRIDE_RATE,
                                     p_new_LIT_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'SCHOOL_DISTRICT_CODE',
                                     p_old_SCHOOL_DISTRICT_CODE,
                                     p_new_SCHOOL_DISTRICT_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'SD_EXEMPT',
                                     p_old_SD_EXEMPT,
                                     p_new_SD_EXEMPT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'STATE_CODE',
                                     p_old_STATE_CODE,
                                     p_new_STATE_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'WITHHOLDING_ALLOWANCES',
                                     p_old_WITHHOLDING_ALLOWANCES,
                                     p_new_WITHHOLDING_ALLOWANCES,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'EFFECTIVE_END_DATE',
                                     p_old_EFFECTIVE_END_DATE,
                                     p_new_EFFECTIVE_END_DATE,
                                     p_new_effective_end_date,
                                     least(p_old_effective_end_date,
                                           p_new_effective_end_date)
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_US_EMP_CITY_TAX_RULES_F',
                                     'EFFECTIVE_START_DATE',
                                     p_old_EFFECTIVE_START_DATE,
                                     p_new_EFFECTIVE_START_DATE,
                                     p_new_effective_start_date,
                                     least(p_old_effective_start_date,
                                           p_new_effective_start_date)
                                  );

  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
                                            p_assignment_id         => p_old_ASSIGNMENT_ID,
                                            p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
                                            p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
                                            p_status                => 'U',
                                            p_description           => pay_continuous_calc.g_event_list.description(cnt),
                                            p_process_event_id      => l_process_event_id,
                                            p_object_version_number => l_object_version_number,
                                            p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
                                            p_business_group_id     => p_business_group_id,
                                            p_surrogate_key         => p_old_EMP_CITY_TAX_RULE_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_US_CITY_TAX_RULES_F_aru;
--
end pay_us_cont_calc;

/
