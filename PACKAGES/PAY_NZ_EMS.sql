--------------------------------------------------------
--  DDL for Package PAY_NZ_EMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_EMS" AUTHID CURRENT_USER as
/*  $Header: pynzems.pkh 120.2.12010000.8 2010/03/18 08:51:16 dduvvuri ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  EMS mag tape writer stuff
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  27 JUL 1999 JTURNER  N/A       Big bang
**  14 OCT 1999 ATOPOL   N/A       Bug-Fixes
**  21 APR 2000 ABAJPAI  N/A       b.oraganizaion_id is made char in the view
**                                 ,corresponding changes done
**  15 SEP 2000 SRIKRISH 1406196   Added a join in cursor c_detail
**                                   subquery input value to get correct
**                                   effective_start_date
**  10 OCT 2001 HNAINANI 1864377   According to the requirements for Student Loan Tax Calc
**                                      STC should be displayed as a tax code only if 'STC ='Y and
**                                      Paye Tax Rate is not null - Otherwise display the actual Tax Code
**  06 Dec 2001 Apunekar 2135629   Fixed EMS issues
**  18 Dec 2001 Ragovind 2154439   Removed the Dynamic view for performance issue
**  30 Jan 2002 shoskatt 2197687   Changed the cursor c_detail so  that the value of Tax Code, Special Tax
**                                 code and Tax Rate is fetched from the view
**  06 Mar 2002 Ragovind 2233511   Changed the c_detail cursor to fix the 2197687 and 2233511 bugs.
**  25 Mar 2002 Apunekar 2276649   Corrected reporting of start and finish dates.
**  05 Apr 2002 Apunekar 2306743   Handled multiple assignments beng reported.
**  01 May 2002 SRussell 2352807   TAR 2188761.995. Return employees whose
**                                 start date was prior to payroll start.
**  25 May 2002 Apunekar 2280938   Extra columns added for displaying negative values in exceptions report
**  28 May 2002 Ragovind 2381433   Changed the c_detail cursor for employee having a payroll with +ve offset
**  08 Nov 2002 Apunekar 2600912   Removed redundant columns as per the view changes.
**  17 Jan 2002 srrajago 2755544   Included negative value check for student_loan_deduction in c_detail cursor.
**  30 May 2002 puchil   2920728   Changed both the cursors to use secured views.
**  22 Dec 2003 puchil   3306269   Removed fnd_sessions table in the header cursor to remove Cartesian joins.
**  12-Apr-2007 dduvvuri 5846247   Modified header and detail cursors for KiwiSaver Requirement
**  24-Apr-2007 dduvvuri 5846247   Modified spellings for certain Formula parameters req by KiwiSaver
**  06-Nov-2008 dduvvuri 7480679   Modified c_detail cursor
**  07-Nov-2008 dduvvuri 7480679   Modified c_detail cursor after review comments.
**                                 Removed usages of tables 'pay_input_values_f iv2' , 'pay_run_results prr2',
**                                 'pay_run_result_values prrv2' from the query
**  07-Nov-2007 dduvvuri 7480679   Backed out the above change and implemented it in a different way.
**                                 Modified the c_detail cursor to get the value of 'Tax Rate' input field
**                                 from a function in package pay_nz_ems_tax_rate
**  10-NOv-2007 dduvvuri 7480679   Removed usages of tables 'pay_input_values_f iv2' , 'pay_run_results prr2',
**                                 'pay_run_result_values prrv2' from the query.Also removed the usage of
**                                 "distinct" keyword in c_detail query. The parameters to the function call
**                                 in package pay_nz_ems_tax_rate are also changed.
**  07-JAN-2010 dduvvuri 9237657   Made Changes in ems header and detail cursors due to
**                                 introduction of statutory changes effective 01-Apr-2010
**  03-Feb-2010 dduvvuri 9237657   Multiply the values of payroll tax credits by -1 in header , detail cursors
**                                 because balance value of tax credits is negative and EMS must report positive value
**  18-Mar-2010 dduvvuri 9484915   Payroll package version is based on Apps version 11i or R12
*/

level_cnt                     number ;

/*
**  Cursor to retrieve Inland Revenue employer monthly schedule e-file
**  header record
*/

cursor c_header is
  select 'HEADER_RECORD_INDICATOR=P'
  ,      'HDR'                                              -- header_record_indicator
  ,      'EMPLOYER_IRD_NUMBER=P'
  ,      lpad(replace(oi.org_information1,'-',NULL), 9, '0') -- employer_IRD_number
  ,      'RETURN_PERIOD=P'
  ,      to_char(last_day(b.effective_date),'YYYYMMDD')     -- return_period
  ,      'PAYROLL_CONTACT_NAME=P'
  ,      oi.org_information2                                -- payroll_contact_name
  ,      'PAYROLL_CONTACT_PHONE=P'
  ,      replace
                (replace(oi.org_information3, '(' ,NULL)
                , ')' ,NULL
                )                                           -- payroll_contact_phone
  ,      'PAYE=P'
  ,      to_char(b.paye_deductions*100)                     -- PAYE
  ,      'CHILD_SUPPORT=P'
  ,      to_char(b.child_support_deductions*100)            -- child_support
  ,      'STUDENT_LOANS=P'
  ,      to_char(b.student_loan_deductions*100)             -- student_loans
  -- Changes for bug 5846247 start
  ,      'KIWISAVER_EMPLOYEE_CONTRIBUTIONS=P'
  ,      to_char(b.kiwisaver_ee_contributions*100)             -- Kiwisaver Employee Deductions
  ,      'KIWISAVER_EMPLOYER_CONTRIBUTIONS=P'
  ,      to_char(b.kiwisaver_er_contributions*100)             -- Kiwisaver Employer Contributions
  -- Changes for bug 5846247 end
  -- Changes for bug 9237657 start
  ,      'PAYROLL_TAX_CREDITS=P'
  ,      to_char(-1*b.payroll_tax_credits*100)                  -- Payroll giving Tax Credits
  -- Changes for bug 9237657 end
  ,      'FAMILY_ASSISTANCE=P'
  ,      '0'                                                -- family_assistance
  ,      'GROSS_EARNINGS=P'
  ,      to_char(b.gross_earnings*100)                      -- gross_earnings
  ,      'EARNINGS_NOT_LIABLE_FOR_ACC_EP=P'
  ,      to_char(b.earnings_not_liable_for_acc_ep*100)      -- earnings_not_liable_for_acc_ep
  -- Changes for bug 9237657 start
  ,      'PAYROLL_PACKAGE_VERSION=P'
  ,      (  SELECT decode(substr(PRODUCT_VERSION,1,2),'11','Oracle HRMS V11i','Oracle HRMS V12')
            FROM fnd_application a,fnd_product_installations p
            WHERE a.application_id = p.application_id
            AND substr(a.application_short_name, 1, 3) = 'PAY')  -- Payroll Package Version
  ,      'PAYROLL_CONTACT_EMAIL=P'
  ,       decode(instr(substr(oi.org_information5,
                              decode(sign(instr(oi.org_information5,'@')),0,length(oi.org_information5)+1,instr(oi.org_information5,'@'))
                              ),'.',1,2
                      ),0,decode(instr(substr(oi.org_information5,instr(oi.org_information5,'@')),'.'),0,null,oi.org_information5),null
                )                                           -- Payroll Contact Email
  ,      'IR_FORM_VERSION_NO=P'
  ,      '0004'                                             -- IR_form_version_no
    -- Changes for bug 9237657 end
  ,      'TRANSFER_HEAD_FLAG=P'
  ,      'notprinted'
  from   hr_organization_units ou /*Bug No 2920728*/
  ,      hr_organization_information oi
  ,      pay_nz_er_cal_mth_bal_v b
  where  ou.organization_id = pay_magtape_generic.get_parameter_value('REGISTERED_EMPLOYER')
  and    ou.business_group_id = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
  and    oi.organization_id = ou.organization_id
  and    oi.org_information_context = 'NZ_IRD_EMPLOYER'
  and    b.organization_id = to_char(ou.organization_id) ;

/*
**  Cursor to retrieve Inland Revenue employer monthly schedule e-file
**  detail records
*/

cursor c_detail is
select   'DETAIL_RECORD_INDICATOR=P'
  ,      'DTL'                                                  -- detail_record_indicator
  ,      'EMPLOYEE_IRD_NUMBER=P'
  ,      decode
         (p.national_identifier
         ,NULL, '000000000'
         ,lpad(replace(p.national_identifier,'-',NULL), 9, '0')
         )                                                      -- employee_ird_number
  ,      'EMPLOYEE_NAME=P'
  ,      replace
         (substr(p.first_name || ' ' || p.last_name, 1, 20)
         , ',', ' '
         )                                                      -- employee_name
  ,      'EMPLOYEE_TAX_CODE=P'
  --
  --     The NULL value was not recognised by the fast formula using the
  --     default for ...
  --     if ... was defaulted ...
  --     therefore the string NULL VALUE is passed
  --     7480679 - made use of package pay_nz_ems_tax_rate to get the tax rate input value.
  ,      nvl(decode(prrv1.result_value,'N',prrv.result_value,'Y', (decode(pay_nz_ems_tax_rate.get_tax_rate(s.effective_date,prr.run_result_id),'N',
                                                                          prrv.result_value,'STC'))),'NULL VALUE')  -- employee_tax_code
  ,      'START_DATE=P'
  , decode(to_char(ptp.END_DATE  ,'YYYYMM')
                ,to_char(s.effective_date,'YYYYMM')
                ,to_char(pos.date_start, 'YYYYMMDD')
                ,'NULL VALUE'
                )   -- start_date/*2276649*/
  ,      'FINISH_DATE=P'
  ,      decode(to_char(nvl(pos.final_process_date,pos.last_standard_process_date), 'YYYYMM')
               ,to_char(s.effective_date,'YYYYMM')
               , to_char(pos.actual_termination_date,'YYYYMMDD')
               ,'NULL VALUE'
               )                                                -- finish_date/*2135629,2276649*/
  ,      'GROSS_EARNINGS=P'
  ,      b.gross_earnings*100                                   -- gross_earnings
  ,      'EARNINGS_NOT_LIABLE_FOR_ACC_EP=P'
  ,      b.earnings_not_liable_for_acc_ep*100                   -- earnings_not_liable_for_acc_ep
  ,      'LUMP_SUM_INDICATOR=P'
  ,      decode(b.extra_emol_at_low_tax_rate, 'Y', 1, 0)        -- lump_sum_indicator
  ,      'PAYE_DEDUCTIONS=P'
  ,      b.paye_deductions*100                                  -- paye_deductions
  ,      'CHILD_SUPPORT_DEDUCTIONS=P'
  ,      b.child_support_deductions*100                         -- child_support_deductions
  ,      'CHILD_SUPPORT_CODE=P'
  ,      nvl(b.child_support_code, 'NULL VALUE')                -- child_support_code
  ,      'STUDENT_LOAN_DEDUCTIONS=P'
  ,      b.student_loan_deductions*100                          -- student_loan_deductions
  -- Changes for bug 5846247 start
  ,      'KIWISAVER_EMPLOYEE_CONTRIBUTIONS=P'
  ,      b.kiwisaver_ee_contributions*100                          -- Kiwisaver Employee Deductions
  ,      'KIWISAVER_EMPLOYER_CONTRIBUTIONS=P'
  ,      b.kiwisaver_er_contributions*100                          -- Kiwisaver Employer Contributions
  -- Changes for bug 5846247 end
  -- Changes for bug 9237657 start
  ,      'PAYROLL_TAX_CREDITS=P'
  ,       -1*b.payroll_tax_credits*100
  -- Changes for bug 9237657 end
  ,      'FAMILY_ASSISTANCE=P'
  ,      '0'                                                    -- family_assistance
  ,      'EMPLOYEE_NUMBER=P'
  ,      p.employee_number
  ,      'VALID=P'
  ,  decode(sign(least(b.gross_earnings,
                          b.earnings_not_liable_for_acc_ep,
                          b.paye_deductions,
                          b.child_support_deductions,b.student_loan_deductions)),-1,0  /* Bug No : 2755544 */
                ,decode(sign(b.gross_earnings - (b.paye_deductions + b.child_support_deductions + b.student_loan_deductions)),-1,0,1)) flag
   from   hr_organization_units ou /*Bug No 2920728*/
  ,      per_people_f p /*Bug No 2920728*/
  ,      per_assignments_f a
  ,      hr_soft_coding_keyflex scl
  ,      pay_nz_asg_cal_mth_bal_v b
  ,      pay_element_types_f et
  ,      pay_input_values_f iv
  ,      pay_input_values_f iv1
 -- ,      pay_input_values_f iv2    /* 7480679 */
  ,      pay_run_results prr
  ,      pay_run_results prr1
 -- ,      pay_run_results prr2     /* 7480679 */
  ,      pay_run_result_values prrv
  ,      pay_run_result_values prrv1
 -- ,      pay_run_result_values prrv2 /* 7480679 */
  ,      pay_assignment_actions assact
  ,      pay_payroll_actions pact
  ,      fnd_sessions s
  ,      per_periods_of_service pos
  ,      per_time_periods  ptp
  where  ou.organization_id = pay_magtape_generic.get_parameter_value('REGISTERED_EMPLOYER')
  and    ou.business_group_id = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
  and    b.organization_id = to_char(ou.organization_id)
  and    p.effective_start_date <= last_day(s.effective_date)
  and    p.effective_end_date   >= to_date('01/' || to_char(s.effective_date, 'mm/yyyy'), 'dd/mm/yyyy')
  -- the following sub query makes sure that we get the person record in effect at the end of the month
  and    p.effective_start_date = (select max(p2.effective_start_date)
                                   from   per_people_f p2 /*Bug No 2920728*/
                                   where  p2.person_id = p.person_id
                                   and    p2.effective_start_date <= last_day(s.effective_date)
                                  )
  and    scl.soft_coding_keyflex_id = a.soft_coding_keyflex_id
  and    b.assignment_id = a.assignment_id
--
-- start TAR 2188761.995 change.
--
--  and pos.DATE_START between ptp.START_DATE and ptp.END_DATE /*2276649*/
--  and ptp.PAYROLL_ID = a.PAYROLL_ID
--
AND (ptp.payroll_id,ptp.start_date) = (SELECT payroll_id,MIN(start_date)
                    FROM per_time_periods
                    WHERE payroll_id = a.payroll_id
                    AND end_date > pos.date_start
                    GROUP BY payroll_id)
-- end TAR 2188761.995 change
--
  and    b.organization_id = scl.segment1
  and    a.person_id = p.person_id
  and    a.effective_start_date   <= last_day(s.effective_date)
  and    a.effective_end_date     >= to_date('01/' || to_char(s.effective_date, 'mm/yyyy'), 'dd/mm/yyyy')
  -- the following sub query makes sure that we get the assignment in effect at the end of the month
  and    a.effective_start_date = (select max(a2.effective_start_date)
                                   from   per_assignments_f a2
                                   where  a2.person_id = a.person_id
                                   and    a2.assignment_id = a.assignment_id
                                   and    a2.effective_start_date <= last_day(s.effective_date)
                                  )
  and    et.element_name in ('PAYE Information', 'Withholding Tax Information Record')
  and    et.effective_start_date  <= last_day(s.effective_date)
  and    et.effective_end_date    >= to_date('01/' || to_char(s.effective_date, 'mm/yyyy'), 'dd/mm/yyyy')
 -- the following sub query makes sure that we get the element type in effect at the end of the month
  and    et.effective_start_date  = (select max(et2.effective_start_date)
                                     from   pay_element_types_f et2
                                     where  et2.element_type_id = et.element_type_id
                                     and    et2.effective_start_date <= last_day(s.effective_date)
                                    )
  and   assact.assignment_action_id = ( select max(assact4.assignment_action_id)
                                         from   pay_assignment_actions assact4
                                                 ,pay_payroll_actions pact4
                                                 ,pay_run_results prr4
                                         where  assact4.assignment_id = a.assignment_id
                                         and    assact4.assignment_action_id = prr4.assignment_action_id
                                         and    pact4.payroll_action_id = assact4.payroll_action_id
                                         and    pact4.effective_date between to_date('01/' || to_char(s.effective_date, 'mm/yyyy'), 'dd/mm/yyyy')
                                                                      and last_day(s.effective_date)
                                         and    prr4.element_type_id = et.element_type_id )
  and    iv.name  = 'Tax Code'
  and    iv.element_type_id   = et.element_type_id
  and    prr.element_type_id  = et.element_type_id
  and    prr.run_result_id    = prrv.run_result_id
  and    prrv.input_value_id  = iv.input_value_id
  and    prr.assignment_action_id = assact.assignment_action_id
  and    iv1.name = 'Special Tax Code'
  and    iv1.element_type_id  = et.element_type_id
  and    prr1.element_type_id = et.element_type_id
  and    prr1.run_result_id   = prrv1.run_result_id
  and    prrv1.input_value_id = iv1.input_value_id
  and    prr1.assignment_action_id = assact.assignment_action_id
  /* 7480679 - Removed all joins related to "Tax Rate" input value */
  and    pact.payroll_action_id = assact.payroll_action_id
  and    assact.assignment_id = a.assignment_id
  and    s.session_id = userenv('SESSIONID')
  and    pos.person_id = p.person_id
  -- the next couple of clauses identify the period of service, if there is more then one period
  -- of service in the month this query will return record for each period of service
  and    pos.date_start <= last_day(s.effective_date)
  and    nvl(pos.final_process_date, s.effective_date) >=
                            to_date('01/' || to_char(s.effective_date, 'mm/yyyy'), 'dd/mm/yyyy') /*2135629*/
order by flag desc;

end pay_nz_ems ;

/
