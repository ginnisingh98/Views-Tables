--------------------------------------------------------
--  DDL for Package PAY_NZ_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_EFT" AUTHID CURRENT_USER as
/* $Header: pynzeft.pkh 120.0.12010000.3 2008/10/23 09:09:21 pmatamsr ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  EFT direct credit of pay stuff
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  1 NOV 1999  ATOPOL   N/A       Big bang
**  9 AUG 2001  APUNEKAR 1876803   New Cursor Added.
**  26 SEP 2001 APUNEKAR 1998102   Validated delimiters such as commas.
**  30 May 2003 PUCHIL   2920728   Changed both cursors to use secured views.
**                                 Removed check_sql errors.
**  24 Jun 2003 PUCHIL   3719858   Changed both cursors to improve
**                                 performance.
**  07 Oct 2008 PMATAMSR 6891410   As part of NewZealand Direct Credit Enhancement
**             /AVENKATK           procedure add_custom_xml is added to the
**                                 package.This procedure will be called by the
**                                 XML generation process and adds required XML tags
**                                 in XML generated for each assignment.
*/

level_cnt                     number ;


/*
**  Cursor to retrieve ASB Bank Fastnet Office Direct Credit CSV Import File
**  header records
*/
/*
**  Bug 2920728 - Replaced per_all_people_f with per_people_f
*/

cursor c_asb_csv_header is
 Select
        'RECORD_TYPE=P'
        ,'12'
        ,'REGISTRATION_NUMBER=P'
        ,oea.segment1
       ||oea.segment2
       ||oea.segment3                             -- account_no
      ,'CLIENT_SHORT_NAME=P'                      -- BG Name
      ,nvl(replace(o.name,','),'NULL VALUE')
        ,'DUE_DATE=P'
        ,to_char(to_date(pay_magtape_generic.get_parameter_value('TRANSACTION_DATE'),'YYYY/MM/DD'),'ddmmyy')
      ,'HASH_TOTAL=P'
        ,to_char(SUM(pea.segment2) + SUM(substr(pea.segment1,3,4)))
        ,'BATCH_COUNT=P'
        ,to_char(COUNT(*))
        ,'BATCH_TOTAL=P'
        ,substr(to_char(SUM(nvl(ppp.VALUE,0) * 100)),1,11)
      ,'TRANSFER_HEAD_FLAG=P'
      ,'Not_Printed'
  from
         pay_org_payment_methods_f      popm
  ,      pay_external_accounts          oea
  ,      pay_personal_payment_methods_f pppm
  ,      pay_external_accounts          pea
  ,      pay_pre_payments               ppp
  ,      pay_assignment_actions         paa
  ,      pay_payroll_actions            ppa
  ,      per_assignments_f              a
  ,      per_people_f                   p
  ,      hr_organization_units          o

  where
         ppa.payroll_action_id           =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and
         ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    ppa.business_group_id           = popm.business_group_id --Bug 3719858
  and    oea.external_account_id         = popm.external_account_id
  and    ppa.business_group_id           = o.organization_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
  and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
  group by oea.segment1||oea.segment2||oea.segment3,o.name;


/*
**  Cursor to retrieve ASB Bank Fastnet Office Direct Credit CSV Import File
**  detail records
*/
/*
**  Bug 2920728 - Replaced per_all_people_f with per_people_f
*/


cursor c_asb_csv_detail is
  select
          'ACCOUNT_NO=P'
  ,      lpad(substr(pea.segment1,1,2),2,0)||'-'
         ||lpad(substr(pea.segment1,3,6),4,0)||'-'
         ||pea.segment2||'-'
         ||pea.segment3                             -- account_no
  ,      'TRANSACTION_CODE=P'                       --transaction code
  ,      '052'
  ,      'AMOUNT=P'
  ,      to_char(ppp.value*100)                     -- amount
  ,      'THIS_PARTY_PARTICULARS=P'
  ,      'Salary/Wages'             -- this_party_particulars
  ,      'THIS_PARTY_CODE=P'
  --
  --     The NULL value was not recognised by the fast formula using the
  --     default for ...
  --     if ... was defaulted ...
  --     therefore the string NULL VALUE is passed
  --
  ,      nvl(replace(pea.segment5,','), 'NULL VALUE')            -- this_party_code
  ,      'THIS_PARTY_ALPHA_REFERENCE=P'
  ,      nvl(replace(pea.segment4,','), 'NULL VALUE')            -- this_party_alpha_reference
  ,      'THIS_PARTY_NUM_REF=P'
  ,      '000000000000'                             -- this_party_num_reference
  ,      'OTHER_PARTY_PARTICULARS=P'
  ,      'Salary/Wages'            -- other_party_particulars
  ,      'OTHER_PARTY_CODE=P'
  ,      nvl(replace(oea.segment5,','), 'NULL VALUE')            -- other_party_code
  ,      'OTHER_PARTY_ALPHA_REF=P'
  ,      nvl(replace(oea.segment4,','), 'NULL VALUE')            -- other_party_reference
  ,      'OTHER_PARTY_NAME=P'
  ,      nvl(replace(o.name,','),'NULL VALUE')  -- other_party_name ie payee_name
  ,      'THIS_PARTY_NAME=P'
  ,       substr
          (replace(p.first_name,',') ||' '||replace(p.last_name,','), 1, 20)  -- this_party_name ie payee_name
  from
         pay_org_payment_methods_f      popm
  ,      pay_external_accounts          oea
  ,      pay_personal_payment_methods_f pppm
  ,      pay_external_accounts          pea
  ,      pay_pre_payments               ppp
  ,      pay_assignment_actions         paa
  ,      pay_payroll_actions            ppa
  ,      per_assignments_f              a
  ,      per_people_f               p
  ,      hr_organization_units          o
  where
         ppa.payroll_action_id           =
         pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
  and    ppp.pre_payment_id              = paa.pre_payment_id
  and    paa.payroll_action_id           = ppa.payroll_action_id
  and    ppa.business_group_id           = popm.business_group_id --Bug 3719858
  and    oea.external_account_id         = popm.external_account_id
  and    ppa.business_group_id           = o.organization_id
  and    popm.org_payment_method_id      = ppp.org_payment_method_id
  and    pea.external_account_id         = pppm.external_account_id
  and    pppm.personal_payment_method_id = ppp.personal_payment_method_id
  and    paa.assignment_id               = a.assignment_id
  and    a.person_id                     = p.person_id
  and    ppa.effective_date between popm.effective_start_date and popm.effective_end_date
  and    ppa.effective_date between pppm.effective_start_date and pppm.effective_end_date
  and    ppa.effective_date between    a.effective_start_date and    a.effective_end_date
  and    ppa.effective_date between    p.effective_start_date and    p.effective_end_date
;


/* Bug# 6891410 --This Procedure will be called by the XML generation process.This will
 * add additional required tags in the XML generated for each assignment */

PROCEDURE add_custom_xml;

end pay_nz_eft ;

/
