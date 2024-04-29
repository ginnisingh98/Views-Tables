--------------------------------------------------------
--  DDL for Package Body PAY_CA_CONT_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_CONT_CALC" as
/* $Header: pycacoc.pkb 120.0 2005/05/29 01:57:24 appldev noship $ */

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
/* PAY_CA_EMP_FED_TAX_INFO_F */
/* name : PAY_CA_EMP_FED_TAX_INFO_F_aru
   purpose : This is procedure that records any changes for updates
             on Federal Tax Information.
*/
procedure PAY_CA_EMP_FED_TAX_INFO_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDITIONAL_TAX in NUMBER,
p_new_ADDITIONAL_TAX in NUMBER ,
p_old_ANNUAL_DEDN in NUMBER,
p_new_ANNUAL_DEDN in NUMBER ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_BASIC_EXEMPTION_FLAG in VARCHAR2,
p_new_BASIC_EXEMPTION_FLAG in VARCHAR2 ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_CA_TAX_INFORMATION1 in VARCHAR2,
p_new_CA_TAX_INFORMATION1 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION10 in VARCHAR2,
p_new_CA_TAX_INFORMATION10 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION11 in VARCHAR2,
p_new_CA_TAX_INFORMATION11 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION12 in VARCHAR2,
p_new_CA_TAX_INFORMATION12 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION13 in VARCHAR2,
p_new_CA_TAX_INFORMATION13 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION14 in VARCHAR2,
p_new_CA_TAX_INFORMATION14 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION15 in VARCHAR2,
p_new_CA_TAX_INFORMATION15 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION16 in VARCHAR2,
p_new_CA_TAX_INFORMATION16 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION17 in VARCHAR2,
p_new_CA_TAX_INFORMATION17 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION18 in VARCHAR2,
p_new_CA_TAX_INFORMATION18 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION19 in VARCHAR2,
p_new_CA_TAX_INFORMATION19 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION2 in VARCHAR2,
p_new_CA_TAX_INFORMATION2 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION20 in VARCHAR2,
p_new_CA_TAX_INFORMATION20 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION21 in VARCHAR2,
p_new_CA_TAX_INFORMATION21 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION22 in VARCHAR2,
p_new_CA_TAX_INFORMATION22 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION23 in VARCHAR2,
p_new_CA_TAX_INFORMATION23 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION24 in VARCHAR2,
p_new_CA_TAX_INFORMATION24 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION25 in VARCHAR2,
p_new_CA_TAX_INFORMATION25 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION26 in VARCHAR2,
p_new_CA_TAX_INFORMATION26 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION27 in VARCHAR2,
p_new_CA_TAX_INFORMATION27 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION28 in VARCHAR2,
p_new_CA_TAX_INFORMATION28 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION29 in VARCHAR2,
p_new_CA_TAX_INFORMATION29 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION3 in VARCHAR2,
p_new_CA_TAX_INFORMATION3 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION30 in VARCHAR2,
p_new_CA_TAX_INFORMATION30 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION4 in VARCHAR2,
p_new_CA_TAX_INFORMATION4 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION5 in VARCHAR2,
p_new_CA_TAX_INFORMATION5 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION6 in VARCHAR2,
p_new_CA_TAX_INFORMATION6 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION7 in VARCHAR2,
p_new_CA_TAX_INFORMATION7 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION8 in VARCHAR2,
p_new_CA_TAX_INFORMATION8 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION9 in VARCHAR2,
p_new_CA_TAX_INFORMATION9 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION_CATEG in VARCHAR2,
p_new_CA_TAX_INFORMATION_CATEG in VARCHAR2 ,
p_old_CLAIM_CODE in VARCHAR2,
p_new_CLAIM_CODE in VARCHAR2 ,
p_old_CPP_QPP_EXEMPT_FLAG in VARCHAR2,
p_new_CPP_QPP_EXEMPT_FLAG in VARCHAR2 ,
p_old_EI_EXEMPT_FLAG in VARCHAR2,
p_new_EI_EXEMPT_FLAG in VARCHAR2 ,
p_old_EMPLOYMENT_PROVINCE in VARCHAR2,
p_new_EMPLOYMENT_PROVINCE in VARCHAR2 ,
p_old_EMP_FED_TAX_INF_ID in NUMBER,
p_new_EMP_FED_TAX_INF_ID in NUMBER ,
p_old_FED_EXEMPT_FLAG in VARCHAR2,
p_new_FED_EXEMPT_FLAG in VARCHAR2 ,
p_old_FED_OVERRIDE_AMOUNT in NUMBER,
p_new_FED_OVERRIDE_AMOUNT in NUMBER ,
p_old_FED_OVERRIDE_RATE in NUMBER,
p_new_FED_OVERRIDE_RATE in NUMBER ,
p_old_LEGISLATION_CODE in VARCHAR2,
p_new_LEGISLATION_CODE in VARCHAR2 ,
p_old_OTHER_FEDTAX_CREDITS in NUMBER,
p_new_OTHER_FEDTAX_CREDITS in NUMBER ,
p_old_PRESCRIBED_ZONE_DEDN_AMT in NUMBER,
p_new_PRESCRIBED_ZONE_DEDN_AMT in NUMBER ,
p_old_TAX_CALC_METHOD in VARCHAR2,
p_new_TAX_CALC_METHOD in VARCHAR2 ,
p_old_TAX_CREDIT_AMOUNT in NUMBER,
p_new_TAX_CREDIT_AMOUNT in NUMBER ,
p_old_TOTAL_EXPENSE_BY_COMMISS in NUMBER,
p_new_TOTAL_EXPENSE_BY_COMMISS in NUMBER ,
p_old_TOTAL_REMNRTN_BY_COMMISS in NUMBER,
p_new_TOTAL_REMNRTN_BY_COMMISS in NUMBER ,
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
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'ADDITIONAL_TAX',
                                     p_old_ADDITIONAL_TAX,
                                     p_new_ADDITIONAL_TAX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'ANNUAL_DEDN',
                                     p_old_ANNUAL_DEDN,
                                     p_new_ANNUAL_DEDN,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'BASIC_EXEMPTION_FLAG',
                                     p_old_BASIC_EXEMPTION_FLAG,
                                     p_new_BASIC_EXEMPTION_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION1',
                                     p_old_CA_TAX_INFORMATION1,
                                     p_new_CA_TAX_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION10',
                                     p_old_CA_TAX_INFORMATION10,
                                     p_new_CA_TAX_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION11',
                                     p_old_CA_TAX_INFORMATION11,
                                     p_new_CA_TAX_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION12',
                                     p_old_CA_TAX_INFORMATION12,
                                     p_new_CA_TAX_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION13',
                                     p_old_CA_TAX_INFORMATION13,
                                     p_new_CA_TAX_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION14',
                                     p_old_CA_TAX_INFORMATION14,
                                     p_new_CA_TAX_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION15',
                                     p_old_CA_TAX_INFORMATION15,
                                     p_new_CA_TAX_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION16',
                                     p_old_CA_TAX_INFORMATION16,
                                     p_new_CA_TAX_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION17',
                                     p_old_CA_TAX_INFORMATION17,
                                     p_new_CA_TAX_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION18',
                                     p_old_CA_TAX_INFORMATION18,
                                     p_new_CA_TAX_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION19',
                                     p_old_CA_TAX_INFORMATION19,
                                     p_new_CA_TAX_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION2',
                                     p_old_CA_TAX_INFORMATION2,
                                     p_new_CA_TAX_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION20',
                                     p_old_CA_TAX_INFORMATION20,
                                     p_new_CA_TAX_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION21',
                                     p_old_CA_TAX_INFORMATION21,
                                     p_new_CA_TAX_INFORMATION21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION22',
                                     p_old_CA_TAX_INFORMATION22,
                                     p_new_CA_TAX_INFORMATION22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION23',
                                     p_old_CA_TAX_INFORMATION23,
                                     p_new_CA_TAX_INFORMATION23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION24',
                                     p_old_CA_TAX_INFORMATION24,
                                     p_new_CA_TAX_INFORMATION24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION25',
                                     p_old_CA_TAX_INFORMATION25,
                                     p_new_CA_TAX_INFORMATION25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION26',
                                     p_old_CA_TAX_INFORMATION26,
                                     p_new_CA_TAX_INFORMATION26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION27',
                                     p_old_CA_TAX_INFORMATION27,
                                     p_new_CA_TAX_INFORMATION27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION28',
                                     p_old_CA_TAX_INFORMATION28,
                                     p_new_CA_TAX_INFORMATION28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION29',
                                     p_old_CA_TAX_INFORMATION29,
                                     p_new_CA_TAX_INFORMATION29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION3',
                                     p_old_CA_TAX_INFORMATION3,
                                     p_new_CA_TAX_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION30',
                                     p_old_CA_TAX_INFORMATION30,
                                     p_new_CA_TAX_INFORMATION30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION4',
                                     p_old_CA_TAX_INFORMATION4,
                                     p_new_CA_TAX_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION5',
                                     p_old_CA_TAX_INFORMATION5,
                                     p_new_CA_TAX_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION6',
                                     p_old_CA_TAX_INFORMATION6,
                                     p_new_CA_TAX_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION7',
                                     p_old_CA_TAX_INFORMATION7,
                                     p_new_CA_TAX_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION8',
                                     p_old_CA_TAX_INFORMATION8,
                                     p_new_CA_TAX_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION9',
                                     p_old_CA_TAX_INFORMATION9,
                                     p_new_CA_TAX_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CA_TAX_INFORMATION_CATEGORY',
                                     p_old_CA_TAX_INFORMATION_CATEG,
                                     p_new_CA_TAX_INFORMATION_CATEG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CLAIM_CODE',
                                     p_old_CLAIM_CODE,
                                     p_new_CLAIM_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'CPP_QPP_EXEMPT_FLAG',
                                     p_old_CPP_QPP_EXEMPT_FLAG,
                                     p_new_CPP_QPP_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'EI_EXEMPT_FLAG',
                                     p_old_EI_EXEMPT_FLAG,
                                     p_new_EI_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'EMPLOYMENT_PROVINCE',
                                     p_old_EMPLOYMENT_PROVINCE,
                                     p_new_EMPLOYMENT_PROVINCE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'EMP_FED_TAX_INF_ID',
                                     p_old_EMP_FED_TAX_INF_ID,
                                     p_new_EMP_FED_TAX_INF_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'FED_EXEMPT_FLAG',
                                     p_old_FED_EXEMPT_FLAG,
                                     p_new_FED_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'FED_OVERRIDE_AMOUNT',
                                     p_old_FED_OVERRIDE_AMOUNT,
                                     p_new_FED_OVERRIDE_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'FED_OVERRIDE_RATE',
                                     p_old_FED_OVERRIDE_RATE,
                                     p_new_FED_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'LEGISLATION_CODE',
                                     p_old_LEGISLATION_CODE,
                                     p_new_LEGISLATION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'OTHER_FEDTAX_CREDITS',
                                     p_old_OTHER_FEDTAX_CREDITS,
                                     p_new_OTHER_FEDTAX_CREDITS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'PRESCRIBED_ZONE_DEDN_AMT',
                                     p_old_PRESCRIBED_ZONE_DEDN_AMT,
                                     p_new_PRESCRIBED_ZONE_DEDN_AMT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'TAX_CALC_METHOD',
                                     p_old_TAX_CALC_METHOD,
                                     p_new_TAX_CALC_METHOD,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'TAX_CREDIT_AMOUNT',
                                     p_old_TAX_CREDIT_AMOUNT,
                                     p_new_TAX_CREDIT_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'TOTAL_EXPENSE_BY_COMMISSION',
                                     p_old_TOTAL_EXPENSE_BY_COMMISS,
                                     p_new_TOTAL_EXPENSE_BY_COMMISS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'TOTAL_REMNRTN_BY_COMMISSION',
                                     p_old_TOTAL_REMNRTN_BY_COMMISS,
                                     p_new_TOTAL_REMNRTN_BY_COMMISS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
                                     'TOTAL_REMNRTN_BY_COMMISSION',
                                     p_old_TOTAL_REMNRTN_BY_COMMISS,
                                     p_new_TOTAL_REMNRTN_BY_COMMISS,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
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
                                     'PAY_CA_EMP_FED_TAX_INFO_F',
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
                                            p_surrogate_key         => p_old_EMP_FED_TAX_INF_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_CA_EMP_FED_TAX_INFO_F_aru;
/* PAY_CA_EMP_PROV_TAX_INFO_F */
/* name : PAY_CA_EMP_PROV_TAX_INFO_F_aru
   purpose : This is procedure that records any changes for updates
             on Povincial Tax Information.
*/
--
procedure PAY_CA_EMP_PROV_TAX_INFO_F_aru(
p_business_group_id in number,
p_legislation_code in varchar2,
p_effective_date in date ,
p_old_ADDITIONAL_TAX in NUMBER,
p_new_ADDITIONAL_TAX in NUMBER ,
p_old_ANNUAL_DEDN in NUMBER,
p_new_ANNUAL_DEDN in NUMBER ,
p_old_ASSIGNMENT_ID in NUMBER,
p_new_ASSIGNMENT_ID in NUMBER ,
p_old_BASIC_EXEMPTION_FLAG in VARCHAR2,
p_new_BASIC_EXEMPTION_FLAG in VARCHAR2 ,
p_old_BUSINESS_GROUP_ID in NUMBER,
p_new_BUSINESS_GROUP_ID in NUMBER ,
p_old_CA_TAX_INFORMATION1 in VARCHAR2,
p_new_CA_TAX_INFORMATION1 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION10 in VARCHAR2,
p_new_CA_TAX_INFORMATION10 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION11 in VARCHAR2,
p_new_CA_TAX_INFORMATION11 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION12 in VARCHAR2,
p_new_CA_TAX_INFORMATION12 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION13 in VARCHAR2,
p_new_CA_TAX_INFORMATION13 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION14 in VARCHAR2,
p_new_CA_TAX_INFORMATION14 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION15 in VARCHAR2,
p_new_CA_TAX_INFORMATION15 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION16 in VARCHAR2,
p_new_CA_TAX_INFORMATION16 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION17 in VARCHAR2,
p_new_CA_TAX_INFORMATION17 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION18 in VARCHAR2,
p_new_CA_TAX_INFORMATION18 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION19 in VARCHAR2,
p_new_CA_TAX_INFORMATION19 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION2 in VARCHAR2,
p_new_CA_TAX_INFORMATION2 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION20 in VARCHAR2,
p_new_CA_TAX_INFORMATION20 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION21 in VARCHAR2,
p_new_CA_TAX_INFORMATION21 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION22 in VARCHAR2,
p_new_CA_TAX_INFORMATION22 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION23 in VARCHAR2,
p_new_CA_TAX_INFORMATION23 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION24 in VARCHAR2,
p_new_CA_TAX_INFORMATION24 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION25 in VARCHAR2,
p_new_CA_TAX_INFORMATION25 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION26 in VARCHAR2,
p_new_CA_TAX_INFORMATION26 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION27 in VARCHAR2,
p_new_CA_TAX_INFORMATION27 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION28 in VARCHAR2,
p_new_CA_TAX_INFORMATION28 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION29 in VARCHAR2,
p_new_CA_TAX_INFORMATION29 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION3 in VARCHAR2,
p_new_CA_TAX_INFORMATION3 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION30 in VARCHAR2,
p_new_CA_TAX_INFORMATION30 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION4 in VARCHAR2,
p_new_CA_TAX_INFORMATION4 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION5 in VARCHAR2,
p_new_CA_TAX_INFORMATION5 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION6 in VARCHAR2,
p_new_CA_TAX_INFORMATION6 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION7 in VARCHAR2,
p_new_CA_TAX_INFORMATION7 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION8 in VARCHAR2,
p_new_CA_TAX_INFORMATION8 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION9 in VARCHAR2,
p_new_CA_TAX_INFORMATION9 in VARCHAR2 ,
p_old_CA_TAX_INFORMATION_CATEG in VARCHAR2,
p_new_CA_TAX_INFORMATION_CATEG in VARCHAR2 ,
p_old_DEDUCTION_CODE in VARCHAR2,
p_new_DEDUCTION_CODE in VARCHAR2 ,
p_old_DISABILITY_STATUS in VARCHAR2,
p_new_DISABILITY_STATUS in VARCHAR2 ,
p_old_EMP_PROVINCE_TAX_INF_ID in NUMBER,
p_new_EMP_PROVINCE_TAX_INF_ID in NUMBER ,
p_old_EXTRA_INFO_NOT_PROVIDED in VARCHAR2,
p_new_EXTRA_INFO_NOT_PROVIDED in VARCHAR2 ,
p_old_JURISDICTION_CODE in VARCHAR2,
p_new_JURISDICTION_CODE in VARCHAR2 ,
p_old_LEGISLATION_CODE in VARCHAR2,
p_new_LEGISLATION_CODE in VARCHAR2 ,
p_old_MARRIAGE_STATUS in VARCHAR2,
p_new_MARRIAGE_STATUS in VARCHAR2 ,
p_old_NON_RESIDENT_STATUS in VARCHAR2,
p_new_NON_RESIDENT_STATUS in VARCHAR2 ,
p_old_NO_OF_DEPENDANTS in NUMBER,
p_new_NO_OF_DEPENDANTS in NUMBER ,
p_old_NO_OF_INFIRM_DEPENDANTS in NUMBER,
p_new_NO_OF_INFIRM_DEPENDANTS in NUMBER ,
p_old_OTHER_TAX_CREDIT in NUMBER,
p_new_OTHER_TAX_CREDIT in NUMBER ,
p_old_PMED_EXEMPT_FLAG in VARCHAR2,
p_new_PMED_EXEMPT_FLAG in VARCHAR2 ,
p_old_PRESCRIBED_ZONE_DEDN_AMT in NUMBER,
p_new_PRESCRIBED_ZONE_DEDN_AMT in NUMBER ,
p_old_PROVINCE_CODE in VARCHAR2,
p_new_PROVINCE_CODE in VARCHAR2 ,
p_old_PROV_EXEMPT_FLAG in VARCHAR2,
p_new_PROV_EXEMPT_FLAG in VARCHAR2 ,
p_old_PROV_OVERRIDE_AMOUNT in NUMBER,
p_new_PROV_OVERRIDE_AMOUNT in NUMBER ,
p_old_PROV_OVERRIDE_RATE in NUMBER,
p_new_PROV_OVERRIDE_RATE in NUMBER ,
p_old_QPP_EXEMPT_FLAG in VARCHAR2,
p_new_QPP_EXEMPT_FLAG in VARCHAR2 ,
p_old_TAX_CALC_METHOD in VARCHAR2,
p_new_TAX_CALC_METHOD in VARCHAR2 ,
p_old_TAX_CREDIT_AMOUNT in NUMBER,
p_new_TAX_CREDIT_AMOUNT in NUMBER ,
p_old_TOTAL_EXPENSE_BY_COMMISS in NUMBER,
p_new_TOTAL_EXPENSE_BY_COMMISS in NUMBER ,
p_old_TOTAL_REMNRTN_BY_COMMISS in NUMBER,
p_new_TOTAL_REMNRTN_BY_COMMISS in NUMBER ,
p_old_WC_EXEMPT_FLAG in VARCHAR2,
p_new_WC_EXEMPT_FLAG in VARCHAR2 ,
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
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'ADDITIONAL_TAX',
                                     p_old_ADDITIONAL_TAX,
                                     p_new_ADDITIONAL_TAX,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'ANNUAL_DEDN',
                                     p_old_ANNUAL_DEDN,
                                     p_new_ANNUAL_DEDN,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'ASSIGNMENT_ID',
                                     p_old_ASSIGNMENT_ID,
                                     p_new_ASSIGNMENT_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'BASIC_EXEMPTION_FLAG',
                                     p_old_BASIC_EXEMPTION_FLAG,
                                     p_new_BASIC_EXEMPTION_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'BUSINESS_GROUP_ID',
                                     p_old_BUSINESS_GROUP_ID,
                                     p_new_BUSINESS_GROUP_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION1',
                                     p_old_CA_TAX_INFORMATION1,
                                     p_new_CA_TAX_INFORMATION1,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION10',
                                     p_old_CA_TAX_INFORMATION10,
                                     p_new_CA_TAX_INFORMATION10,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION11',
                                     p_old_CA_TAX_INFORMATION11,
                                     p_new_CA_TAX_INFORMATION11,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION12',
                                     p_old_CA_TAX_INFORMATION12,
                                     p_new_CA_TAX_INFORMATION12,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION13',
                                     p_old_CA_TAX_INFORMATION13,
                                     p_new_CA_TAX_INFORMATION13,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION14',
                                     p_old_CA_TAX_INFORMATION14,
                                     p_new_CA_TAX_INFORMATION14,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION15',
                                     p_old_CA_TAX_INFORMATION15,
                                     p_new_CA_TAX_INFORMATION15,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION16',
                                     p_old_CA_TAX_INFORMATION16,
                                     p_new_CA_TAX_INFORMATION16,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION17',
                                     p_old_CA_TAX_INFORMATION17,
                                     p_new_CA_TAX_INFORMATION17,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION18',
                                     p_old_CA_TAX_INFORMATION18,
                                     p_new_CA_TAX_INFORMATION18,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION19',
                                     p_old_CA_TAX_INFORMATION19,
                                     p_new_CA_TAX_INFORMATION19,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION2',
                                     p_old_CA_TAX_INFORMATION2,
                                     p_new_CA_TAX_INFORMATION2,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION20',
                                     p_old_CA_TAX_INFORMATION20,
                                     p_new_CA_TAX_INFORMATION20,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION21',
                                     p_old_CA_TAX_INFORMATION21,
                                     p_new_CA_TAX_INFORMATION21,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION22',
                                     p_old_CA_TAX_INFORMATION22,
                                     p_new_CA_TAX_INFORMATION22,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION23',
                                     p_old_CA_TAX_INFORMATION23,
                                     p_new_CA_TAX_INFORMATION23,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION24',
                                     p_old_CA_TAX_INFORMATION24,
                                     p_new_CA_TAX_INFORMATION24,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION25',
                                     p_old_CA_TAX_INFORMATION25,
                                     p_new_CA_TAX_INFORMATION25,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION26',
                                     p_old_CA_TAX_INFORMATION26,
                                     p_new_CA_TAX_INFORMATION26,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION27',
                                     p_old_CA_TAX_INFORMATION27,
                                     p_new_CA_TAX_INFORMATION27,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION28',
                                     p_old_CA_TAX_INFORMATION28,
                                     p_new_CA_TAX_INFORMATION28,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION29',
                                     p_old_CA_TAX_INFORMATION29,
                                     p_new_CA_TAX_INFORMATION29,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION3',
                                     p_old_CA_TAX_INFORMATION3,
                                     p_new_CA_TAX_INFORMATION3,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION30',
                                     p_old_CA_TAX_INFORMATION30,
                                     p_new_CA_TAX_INFORMATION30,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION4',
                                     p_old_CA_TAX_INFORMATION4,
                                     p_new_CA_TAX_INFORMATION4,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION5',
                                     p_old_CA_TAX_INFORMATION5,
                                     p_new_CA_TAX_INFORMATION5,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION6',
                                     p_old_CA_TAX_INFORMATION6,
                                     p_new_CA_TAX_INFORMATION6,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION7',
                                     p_old_CA_TAX_INFORMATION7,
                                     p_new_CA_TAX_INFORMATION7,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION8',
                                     p_old_CA_TAX_INFORMATION8,
                                     p_new_CA_TAX_INFORMATION8,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION9',
                                     p_old_CA_TAX_INFORMATION9,
                                     p_new_CA_TAX_INFORMATION9,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'CA_TAX_INFORMATION_CATEGORY',
                                     p_old_CA_TAX_INFORMATION_CATEG,
                                     p_new_CA_TAX_INFORMATION_CATEG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'DEDUCTION_CODE',
                                     p_old_DEDUCTION_CODE,
                                     p_new_DEDUCTION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'DISABILITY_STATUS',
                                     p_old_DISABILITY_STATUS,
                                     p_new_DISABILITY_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'EMP_PROVINCE_TAX_INF_ID',
                                     p_old_EMP_PROVINCE_TAX_INF_ID,
                                     p_new_EMP_PROVINCE_TAX_INF_ID,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'EXTRA_INFO_NOT_PROVIDED',
                                     p_old_EXTRA_INFO_NOT_PROVIDED,
                                     p_new_EXTRA_INFO_NOT_PROVIDED,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'JURISDICTION_CODE',
                                     p_old_JURISDICTION_CODE,
                                     p_new_JURISDICTION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'LEGISLATION_CODE',
                                     p_old_LEGISLATION_CODE,
                                     p_new_LEGISLATION_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'MARRIAGE_STATUS',
                                     p_old_MARRIAGE_STATUS,
                                     p_new_MARRIAGE_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'NON_RESIDENT_STATUS',
                                     p_old_NON_RESIDENT_STATUS,
                                     p_new_NON_RESIDENT_STATUS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'NO_OF_DEPENDANTS',
                                     p_old_NO_OF_DEPENDANTS,
                                     p_new_NO_OF_DEPENDANTS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'NO_OF_INFIRM_DEPENDANTS',
                                     p_old_NO_OF_INFIRM_DEPENDANTS,
                                     p_new_NO_OF_INFIRM_DEPENDANTS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'OTHER_TAX_CREDIT',
                                     p_old_OTHER_TAX_CREDIT,
                                     p_new_OTHER_TAX_CREDIT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'PMED_EXEMPT_FLAG',
                                     p_old_PMED_EXEMPT_FLAG,
                                     p_new_PMED_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'PRESCRIBED_ZONE_DEDN_AMT',
                                     p_old_PRESCRIBED_ZONE_DEDN_AMT,
                                     p_new_PRESCRIBED_ZONE_DEDN_AMT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'PROVINCE_CODE',
                                     p_old_PROVINCE_CODE,
                                     p_new_PROVINCE_CODE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'PROV_EXEMPT_FLAG',
                                     p_old_PROV_EXEMPT_FLAG,
                                     p_new_PROV_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'PROV_OVERRIDE_AMOUNT',
                                     p_old_PROV_OVERRIDE_AMOUNT,
                                     p_new_PROV_OVERRIDE_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'PROV_OVERRIDE_RATE',
                                     p_old_PROV_OVERRIDE_RATE,
                                     p_new_PROV_OVERRIDE_RATE,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'QPP_EXEMPT_FLAG',
                                     p_old_QPP_EXEMPT_FLAG,
                                     p_new_QPP_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'TAX_CALC_METHOD',
                                     p_old_TAX_CALC_METHOD,
                                     p_new_TAX_CALC_METHOD,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'TAX_CREDIT_AMOUNT',
                                     p_old_TAX_CREDIT_AMOUNT,
                                     p_new_TAX_CREDIT_AMOUNT,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'TOTAL_EXPENSE_BY_COMMISSION',
                                     p_old_TOTAL_EXPENSE_BY_COMMISS,
                                     p_new_TOTAL_EXPENSE_BY_COMMISS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'TOTAL_REMNRTN_BY_COMMISSION',
                                     p_old_TOTAL_REMNRTN_BY_COMMISS,
                                     p_new_TOTAL_REMNRTN_BY_COMMISS,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'WC_EXEMPT_FLAG',
                                     p_old_WC_EXEMPT_FLAG,
                                     p_new_WC_EXEMPT_FLAG,
                                     p_effective_date
                                  );
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
                                     'WC_EXEMPT_FLAG',
                                     p_old_WC_EXEMPT_FLAG,
                                     p_new_WC_EXEMPT_FLAG,
                                     p_effective_date
                                  );
  else
    /* OK it must be a date track change */
--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
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
                                     'PAY_CA_EMP_PROV_TAX_INFO_F',
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
                                            p_surrogate_key         => p_old_EMP_PROVINCE_TAX_INF_ID
                                           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end PAY_CA_EMP_PROV_TAX_INFO_F_aru;
--
end pay_ca_cont_calc;

/
