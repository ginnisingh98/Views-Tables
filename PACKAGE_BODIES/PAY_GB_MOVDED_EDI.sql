--------------------------------------------------------
--  DDL for Package Body PAY_GB_MOVDED_EDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_MOVDED_EDI" as
/* $Header: pygbmedi.pkb 120.19.12010000.24 2010/03/25 11:02:17 krreddy ship $ */
/*===========================================================================+
|               Copyright (c) 1993 Oracle Corporation                       |
|                  Redwood Shores, California, USA                          |
|                       All rights reserved.                                |
+============================================================================
 Name
    PAY_GB_MOVDED_EDI
  Purpose
    Package to control archiver process in the creation of assignment actions
    and the creation of EDI Message files uing the magtape process for EDI
    Message Types : P45(3), P46, P46PENNOT
    This is a UK Specific payroll package.
  Notes

  History
  10-OCT-2000  S.Robinson     115.0  Date Created.
  06-NOV-2002  BTHAMMIN       115.1  Bug 2657976
                                     A new procedure get_job_segment
                                     is added.
  09-DEC-2002  BTHAMMIN       115.2  Check for enabled and displayed
                                     segments.
  23-DEC-2002  NSUGAVAN       115.3   To be R8.0 compliant, commented out
                                      function get_job_segment as it has been
                                      moved to a different file(pygbjseg.pkh)
  24-DEC-2002  AMILLS         115.4   Bug 2677022. Performance fix for three
                                      c_state cursors.
 23-DEC-2002  NSUGAVAN         115.5   Removed commented code.
 21-MAY-2003  ASENGAR         115.6   Changed the cursor c_state of the
                                      procedure p46_action_creation for picking
                                      assignments on basis on P46_SEND_EDI_FLAG
                                      and P46_SEND_EDI for Bug 1843915.
 27-AUG-2003  SSEKHAR          115.7  Bug 1843915: Changed the cursor c_state of
                                      p45_3_action_creation to pick assignments
                                      on basis of P45_3_SEND_EDI_FLAG and
                                      P45_3_SEND_EDI. Also the cursor c_state of
                                      p46_pennot_action_creation has been changed
                                      to pick up assignments based on
                                      P46_PENNOT_SEND_EDI_FLAG and
                                      P46_PENNOT_SEND_EDI
 07-OCT-2004  ALIKHAR          115.8  Bug 3891351: Changed the cursors c_state of
				      p45_3_action_creation, p46_action_creation
				      and p46_pennot_action_creation to join
				      assignment table with period of service
				      table based on period_of_service_id column.
 16-JUN-2006  KTHAMPAN         115.9  Code change for EDI Rollback.
 23-JUN-2006  KTHAMPAN         115.10 Not to create asg action if no rows is found
                                      on the per_assignment_extra_info table
                                      (internal_action_creation)
 29-JUN-2006  KTHAMPAN         115.11 Fix gscc error.
 16-AUG-2006  TUKUMAR          115.12 Bug 5469122 : changed csr_student_loan in
				      function fetch_p45_3_rec
 21-NOV-2006  TUKUMAR	       115.13 Bug 5660011 : changed function fetch_tax_rec
 31-Oct-2007  ABHGANGU         115.14  6345375   UK EOY Changes..
                                                   Added
                                                   fetch_45_46_pennot_rec
                                                  ,p46_5_pennot_action_creation
                                                  ,p45pt_3_action_creation
                                                  ,date_validate
                                                  Modified
                                                    archive_code
1-NOV-07      PARUSIA          115.15  Added check in range_cursor to log
                                       error in Logfile for P45PT3 if Test Submission
				       is Yes and Test_ID is not provided. It also
				       raises an unhandled exception
1-NOV-07      PARUSIA          115.16  Added the same check of Test_ID for
                                       P46_Pennot too.
19-Nov-2007 ABHGANGU   115.17    6345375  Added fetch_p46_5_rec,p46_5_action_creation
                                          Changed internal_action_creation for P46 EDI
19-Nov-2007 PARUSIA    115.19    6345375  Changed fetch_p45_3_rec
                                          to archive continue_student_loan_deductions
12-Dec-2007 PARUSIA    115.20    6643668  In fetch_tax_rec, commented the code
                                          which was getting tax data from
                                          run result values, prior to element element
                                          values. Tax data should be picked only
                                          from element entry values only irrespective
                                          of run results. Also commented the check
                                          in csr_paye_details of link's max effective
                                          date.
27-Dec-2007 rlingama  115.23     6710197  Added function get_territory_short_name for
                                          fetching country name for the country code
30-Jan-2007 parusia   115.24     6770200  Changed check_action to check if the employee
                                          has already been processed by the old process
                                          also. Like for P45PT3, check for P45(3) (old
					  process) also.
05-Feb-2007 apmishra   115.24    6652235  P46 Car Edi enhancement.
8-feb-2008  parusia    115.26    6804206  Corrected the l_tax_year_start conversion line.
8-feb-2008  parusia    115.27    6804206  Corrected the l_tax_year_start conversion line.
30-Apr-2008 rlingama   115.28    6994632  P45(3) minor enhancements for UK EOY Changes APR08
20-Oct-2008 dwkrishn   115.29    7433580  IYF Changes for Year 2009
20-Oct-2008 dwkrishn   115.30    7433580  Corrected check_action parameters
23-Oct-2008 dwkrishn   115.31    7433580  Added l_mode Parameter for P46
30-Oct-2008 dwkrishn   115.32    7433580  P45PT3 Changes Incorporated
03-Nov-2008 dwkrishn   115.33    7519033  Minor Changes for Bug 7519033
04-Nov-2008 dwkrishn   115.34    7433580  Fixed Pension start Date for v6
11-Nov-2008 dwkrishn   115.35    7433580  Modified Display of Displaying O/P
                                          Added a PL/SQL Table,Populate it Via Formula Function,Display
                                          in deinitialization_code Procedure
28-Nov-2008 dwkrishn   115.36    7433580  Minor Changes to internal_action_creation
07-Jan-2009 krreddy    115.37    7633799  Modified 3 data types in archinit procedure
05-Feb-2009 krreddy    115.38    8216080  Modified the code to implement P46Expat Notification
13-Feb-2009 krreddy    115.39    8216080  Modified the code to implement P46Expat Notification
26-Mar-2009 dwkrishn   115.40    8315067  Modified characterset for Job Title from FULL_EDI to P14_FULL_EDI
25-Jun-2009 dwkrishn   115.41    8609586  Modified characterset for address from EDI_SURNAME to P14_FULL_EDI
09-Jul-2009 dwkrishn   115.42    8609586  Modified characterset for employer address from FULL_EDI to P14_FULL_EDI
22-Jul-2009 rlingama   115.43    8574855  Added hint PER_ASSIGNMENTS_F_N12 in csr_asg cursor for tuning the query.
31-Jul-2009 namgoyal   115.44    8704601  Modified date_validate logic for P46_CAR
10-Aug-2009 namgoyal   115.45    8704601  Modified date_validate logic for P46_CAR
10-Aug-2009 namgoyal   115.46    8830306  Added Logic to display P46 ( MOVDED 6.0 ) in output file
22-Jan-2010 namgoyal   115.47 9255173,9255183 Updated for P46 V6 and P46 Expat eText reports
29-Jan-2010 namgoyal   115.48 9255173,9255183 Updated O/P file logic for P46 V6 and P46 Expat eText reports
24-Jan-2010 rlingama   115.49     9495487  Added upper for all columns of cursor csr_et_asg in write_body procedure
25-Mar-2010 krreddy    115.50     9503248  Modified the case of the parameter in validate_input function call
                                           inside movded6_asg_etext_validations procedure.
==============================================================================*/
--
--
TYPE act_info_rec IS RECORD
     ( assignment_id          number(20)
      ,person_id              number(20)
      ,effective_date         date
      ,action_info_category   varchar2(50)
      ,act_info1              varchar2(300)
      ,act_info2              varchar2(300)
      ,act_info3              varchar2(300)
      ,act_info4              varchar2(300)
      ,act_info5              varchar2(300)
      ,act_info6              varchar2(300)
      ,act_info7              varchar2(300)
      ,act_info8              varchar2(300)
      ,act_info9              varchar2(300)
      ,act_info10             varchar2(300)
      ,act_info11             varchar2(300)
      ,act_info12             varchar2(300)
      ,act_info13             varchar2(300)
      ,act_info14             varchar2(300)
      ,act_info15             varchar2(300)
      ,act_info16             varchar2(300)
      ,act_info17             varchar2(300)
      ,act_info18             varchar2(300)
      ,act_info19             varchar2(300)
      ,act_info20             varchar2(300)
      ,act_info21             varchar2(300)
      ,act_info22             varchar2(300)
      ,act_info23             varchar2(300)
      ,act_info24             varchar2(300)
      ,act_info25             varchar2(300)
      ,act_info26             varchar2(300)
      ,act_info27             varchar2(300)
      ,act_info28             varchar2(300)
      ,act_info29             varchar2(300)
      ,act_info30             varchar2(300)
     );

TYPE action_info_table IS TABLE OF
     act_info_rec INDEX BY BINARY_INTEGER;
---


TYPE g_tax_rec IS RECORD(
     tax_code    VARCHAR2(20),
     tax_basis   VARCHAR2(20),
     prev_paid   VARCHAR2(20),
     prev_tax    VARCHAR2(20));

g_package    CONSTANT VARCHAR2(20):= 'pay_gb_movded_edi.';
--
--
/*------------- PRIVATE PROCEDURE -----------------*/
--
--
FUNCTION validate_data(p_value  in varchar2,
                       p_name  in varchar2,
                       p_mode  in varchar2) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'validate_data';
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     if pay_gb_eoy_magtape.validate_input(UPPER(p_value),p_mode) > 0 then
        hr_utility.set_location('Name/Value : ' || p_name || '/' || p_value ,10);
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', p_name);
        pay_core_utils.push_token('INPUT_VALUE', p_value);
        return false;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
     return true;
END validate_data;
--
--
FUNCTION check_action(p_mode          varchar2,
                      p_assignment_id number)  RETURN boolean
IS
     l_proc CONSTANT VARCHAR2(50):= g_package||'check_action';
     l_action number;
     l_ret    boolean;

     cursor csr_check_action(l_mode1 varchar2, l_mode2 varchar2 , l_mode3 varchar2, l_mode4 varchar2) is --Changed for bug 9255173
     select 1
     from   pay_payroll_actions    pay,
            pay_assignment_actions paa
     where  (pay.report_type like l_mode1
             or
             pay.report_type like l_mode2 -- Bug 6770200.
             or
             pay.report_type like l_mode3 -- Added for Version 6
             or
             pay.report_type like l_mode4)
     and    pay.action_status ='C'
     and    pay.report_qualifier = 'GB'
     and    pay.report_category = 'EDI'
     and    pay.payroll_action_id = paa.payroll_action_id
     and    paa.action_status = 'C'
     and    paa.assignment_id = p_assignment_id;

     l_mode1 varchar2(15) ;
     l_mode2 varchar2 (15) ;
     l_mode3 varchar2 (15) ;
     l_mode4 varchar2 (15) :='NO_VALUE' ; --For bug 9255173

BEGIN
     l_ret := true;
     hr_utility.set_location('Entering: '||l_proc,1);

     -- Bug 6770200
     -- Additional modes added. Like while checking for P45PT3,
     -- also check if the employee has been picked by a P45PT3(new) or
     -- P45(3) - pre 06-Apr-08 process. Similar checks done for P46 and Pennot
     -- also.
     -- Added Additional modes l_mode3 for P45PT_3_VER6 for Post 06-APR-08
     if p_mode = 'P45PT_3' or p_mode = 'P45_3' or p_mode = 'P45PT_3_VER6' then
        l_mode1 := 'P45_3' ;
        l_mode2 := 'P45PT_3';
        l_mode3 := 'P45PT_3_VER6';
     elsif p_mode = 'P45PT1' or p_mode = 'P45' then
        l_mode1 := 'P45' ;
        l_mode2 := 'P45PT1' ;
        l_mode3 := 'P45PT1_VER6';
     elsif p_mode = 'P46_5' or p_mode = 'P46' or p_mode = 'P46_VER6'
           or p_mode = 'P46_VER6ET' then --Added for bug 9255173
        l_mode1 := 'P46' ;
        l_mode2 := 'P46_5';
        l_mode3 := 'P46_VER6';
        l_mode4 := 'P46_VER6ET';
/* changes for P46_ver6_pennot starts **/
     elsif p_mode = 'P46_PENNOT' or p_mode = 'P46_5_PENNOT' or p_mode= 'P46_VER6_PENNOT' then
        l_mode1 := 'P46_PENNOT';
        l_mode2 := 'P46_5_PENNOT' ;
        l_mode3 := 'P46_VER6_PENNOT';
/* changes for P46_ver6_pennot ends **/

	/*Changes for P46EXP_Ver6 starts*/
     elsif p_mode = 'P46_EXPAT'
           or p_mode = 'P46EXP_VER6ET' then --Added for bug 9255183
        l_mode1 := 'P46_EXPAT';
        l_mode2 := 'P46EXP_VER6ET';
        l_mode3 := 'P46_EXPAT';
	/*Changes for P46EXP_Ver6 End*/


     else
        l_mode1 := p_mode ;
        l_mode2 := p_mode ;
        l_mode3 := p_mode ;
     end if ;

     hr_utility.set_location('p_mode: '||p_mode,1);
     hr_utility.set_location('l_mode1: '||l_mode1,1);
     hr_utility.set_location('l_mode2: '||l_mode2,1);
     hr_utility.set_location('l_mode3: '||l_mode3,1);
     hr_utility.set_location('l_mode4: '||l_mode4,1);

     open csr_check_action(l_mode1, l_mode2 , l_mode3, l_mode4);
     fetch csr_check_action into l_action;
     if csr_check_action%FOUND then
        hr_utility.set_location('Assignment action complete',5);
        l_ret := false;
     end if;
     close csr_check_action;
     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_ret;
END;
--
--
PROCEDURE reset_flag(p_type       varchar2,
                     p_assact     number)
IS
     l_proc CONSTANT VARCHAR2(50):= g_package||'reset_flag';
     l_ovn  number;

     cursor csr_aei_details is
     select aei.assignment_extra_info_id,
            aei.object_version_number,
            aei.aei_information1
     from   pay_assignment_actions    paa,
            per_assignment_extra_info aei
     where  paa.assignment_action_id = p_assact
     and    aei.assignment_id = paa.assignment_id
     and    aei.information_type = p_type;

     l_aei_rec  csr_aei_details%rowtype;
BEGIN
     open csr_aei_details;
     fetch csr_aei_details into l_aei_rec;
     close csr_aei_details;

     if l_aei_rec.aei_information1 = 'N' then
        hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_aei_rec.assignment_extra_info_id,
               p_aei_information_category       => p_type,
               p_aei_information1               => 'Y');
     end if;
END;
--
--
PROCEDURE internal_action_creation(pactid      in number,
                                   stperson    in number,
                                   endperson   in number,
                                   chunk       in number,
                                   p_info_type in varchar2,
                                   p_rep_type  in varchar2)
IS
     l_proc CONSTANT VARCHAR2(90):= g_package||'internal_action_creation';
     l_payroll_id        number;
     l_business_group_id number;
     l_ass_act_id        number;
     l_assignment_id     number;
     l_effective_date    date;
     l_arch              boolean;
     l_send_flag         varchar2(2);
     l_static_flag       varchar2(2);
     l_tax_ref           varchar2(20);
/**** for p46_5 ***/
     l_def_send_flag         varchar2(2);
     l_def_static_flag       varchar2(2);
     l_reason                varchar2(2);
     l_p45_not_run           boolean;
     l_p46_5_def             number;   /**** l_p46_5_def : 0 -> no default to be run; 1 -> default for P46_5 to be run; 2 -> default has been run,now the normal P46_5 *****/
     l_locked_action_id      number;
     l_exist                 number;
     cursor csr_parameter_info is
     select to_number(pay_gb_eoy_archive.get_parameter(legislative_parameters, 'PAYROLL_ID')) payroll_id,
            substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,'TAX_REF'),1,20) tax_ref,
            effective_date,
            business_group_id
     from   pay_payroll_actions
     where  payroll_action_id = pactid;

     -- Bug 8574855 : Added hint PER_ASSIGNMENTS_F_N12 for tuning the query.
     cursor csr_asg is
     select /*+ ordered index(ASG PER_ASSIGNMENTS_F_N12) */ asg.assignment_id
     from   per_all_people_f pap,
            per_assignments_f asg,
            per_periods_of_service serv,
            pay_all_payrolls_f pay,
            hr_soft_coding_keyflex sck
     where  pap.person_id between stperson and endperson
     and    pap.current_employee_flag = 'Y'
     and    pap.person_id = asg.person_id
     and    asg.business_group_id = l_business_group_id
     and    asg.payroll_id = pay.payroll_id
     and    asg.period_of_service_id = serv.period_of_service_id
     and    pay.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
     and    upper(l_tax_ref) = upper(sck.segment1)
     and    (l_payroll_id IS NULL
             or
             l_payroll_id = pay.payroll_id)
     and    serv.date_start <= l_effective_date
     and    l_effective_date between asg.effective_start_date and asg.effective_end_date
     and    l_effective_date between pap.effective_start_date and pap.effective_end_date
     and    l_effective_date between pay.effective_start_date and pay.effective_end_date;

     cursor csr_aei_flag(p_assignment_id number) is
     select aei_information1,
            decode(p_info_type,'GB_P45_3',     aei_information8
                              ,'GB_P46PENNOT', aei_information4
                              ,'GB_P46',       aei_information3
                              ,'GB_P46EXP',    aei_information3 ) --Added for P46EXP_Ver6 Changes
     from   per_assignment_extra_info
     where  assignment_id = p_assignment_id
     and    information_type = p_info_type;

     cursor csr_p46_5_default(p_assignment_id number) is /*** open this cursor only for rep_type=P46_5 ***/
     select aei_information5,
            aei_information6
     from   per_assignment_extra_info
     where  assignment_id = p_assignment_id
     and    information_type = p_info_type;

     cursor csr_p46_5_def_det(p_assignment_id number,default_archive varchar2)
     is
     select 1
     from pay_action_information pa
         ,pay_payroll_actions    ppa
         ,pay_assignment_actions paa
     where  pa.action_information_category in 'GB P46_5 EDI'
     and    pa.action_context_type = 'AAP'
     and    pa.action_information4 = default_archive
     and    pa.assignment_id       = p_assignment_id
     and    paa.assignment_action_id = pa.action_context_id
     and    ppa.payroll_action_id    = paa.payroll_action_id
     and    ppa.action_status       = 'C';

     cursor csr_p46_5_def_assact(p_assignment_id number) is
     select act.assignment_action_id
     from   pay_payroll_actions pact,
            pay_assignment_actions act
     where  pact.report_type = p_rep_type -- Changed to handle P46_VER6 also
	 and    pact.action_status ='C'
     and    pact.report_qualifier = 'GB'
     and    pact.report_category = 'EDI'
     and    pact.payroll_action_id = act.payroll_action_id
     and    act.action_status = 'C'
     and    act.assignment_id = p_assignment_id;

BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     open csr_parameter_info;
     fetch csr_parameter_info into l_payroll_id,
                                   l_tax_ref,
                                   l_effective_date,
                                   l_business_group_id;
     close csr_parameter_info;

     hr_utility.set_location('Before CSR_ASG cursor effective_date '|| to_char(l_effective_date),10);
     for asg_rec in csr_asg loop
         hr_utility.set_location('Assignment ID :' || asg_rec.assignment_id,15);
		 l_arch := false;
         l_p46_5_def := 0;
         open csr_aei_flag(asg_rec.assignment_id);
         fetch csr_aei_flag into l_send_flag, l_static_flag;

         -- only create asg action if rows is found
         if csr_aei_flag%FOUND then
            hr_utility.set_location('\n l_send_flag = ' || l_send_flag || '    l_static_flag = ' || l_static_flag,20);

           if p_rep_type = 'P46_5' then
              l_p45_not_run := check_action('P45%3', asg_rec.assignment_id);
              if l_p45_not_run then
                open csr_p46_5_default(asg_rec.assignment_id);
                fetch csr_p46_5_default into l_def_send_flag,l_def_static_flag;
                close csr_p46_5_default;
                /*** checking if the default is to be run *****/
                if l_def_send_flag = 'Y' then
                  l_arch := true;
                  l_p46_5_def := 1;
                else
                  if l_def_send_flag = 'N' and l_def_static_flag = 'Y' then
                    l_arch := check_action(p_rep_type, asg_rec.assignment_id);
                    if l_arch then
                      l_p46_5_def := 1; /** if def not archived then archive ***/
                    else
                      l_p46_5_def := 0;
                     end if;
                  end if;
                end if;
                 fnd_file.put_line(fnd_file.LOG,to_char(l_p46_5_def)||l_def_send_flag||l_def_static_flag||l_send_flag||l_static_flag||asg_rec.assignment_id);
                /**** checking if the default has been run or not enabled to run ****/
                if l_p46_5_def = 0 and nvl(l_def_send_flag,'N') = 'N' /*and nvl(l_def_static_flag,'Y') = 'Y'*/ then
                  if l_send_flag = 'Y' then
                    l_arch := true;
                    l_p46_5_def := 2;   /**** diff b/n normal run for other report types and P46_5 normal run ***/
                  else
                    if l_send_flag = 'N' and l_static_flag = 'Y' then /** checking if P46 normal is rolled back ***/
                      fnd_file.put_line(fnd_file.LOG,'11111');
                      open csr_p46_5_def_det(asg_rec.assignment_id,'N');
                      fetch csr_p46_5_def_det into l_exist;
                      if csr_p46_5_def_det%notfound then
                        -- Bug 6770200
                        l_arch := check_action('P46_5', asg_rec.assignment_id);
                      end if;
                      close csr_p46_5_def_det;
                      if l_arch then
                        l_p46_5_def := 2;
                      end if;
                      fnd_file.put_line(fnd_file.LOG,to_char(l_p46_5_def));
                    end if;
                  end if;
                end if;
              /*else
                l_reason := 'X';   */
              end if;
           else
            if l_send_flag = 'Y' then
              l_arch := true;
            else
              if l_send_flag = 'N' and l_static_flag = 'Y' then
                 l_arch := check_action(p_rep_type, asg_rec.assignment_id);
              end if;
            end if;
           end if;

           /* EOY Changes for P46_VER6 Start*/
            if p_rep_type = 'P46_VER6' then
              l_p45_not_run := check_action('P45%3%', asg_rec.assignment_id); -- Changed to handle version 6 Reports also
              if l_p45_not_run then
                open csr_p46_5_default(asg_rec.assignment_id);
                fetch csr_p46_5_default into l_def_send_flag,l_def_static_flag;
                close csr_p46_5_default;
                /*** checking if the default is to be run *****/
                if l_def_send_flag = 'Y' then
                  l_arch := true;
                  l_p46_5_def := 1;
                else
                  if l_def_send_flag = 'N' and l_def_static_flag = 'Y' then
                    l_arch := check_action(p_rep_type, asg_rec.assignment_id);
                    if l_arch then
                      l_p46_5_def := 1; /** if def not archived then archive ***/
                    else
                      l_p46_5_def := 0;
                     end if;
                  end if;
                end if;
                 fnd_file.put_line(fnd_file.LOG,to_char(l_p46_5_def)||l_def_send_flag||l_def_static_flag||l_send_flag||l_static_flag||asg_rec.assignment_id);
                /**** checking if the default has been run or not enabled to run ****/
                if l_p46_5_def = 0 and nvl(l_def_send_flag,'N') = 'N' /*and nvl(l_def_static_flag,'Y') = 'Y'*/ then
                  if l_send_flag = 'Y' then
                    l_arch := true;
                    l_p46_5_def := 2;   /**** diff b/n normal run for other report types and P46_5 normal run ***/
                  else
                    if l_send_flag = 'N' and l_static_flag = 'Y' then /** checking if P46 normal is rolled back ***/
                      fnd_file.put_line(fnd_file.LOG,'11111');
                      open csr_p46_5_def_det(asg_rec.assignment_id,'N');
                      fetch csr_p46_5_def_det into l_exist;
                      if csr_p46_5_def_det%notfound then
                        -- Bug 6770200
                        l_arch := check_action('P46_VER6', asg_rec.assignment_id);
                      end if;
                      close csr_p46_5_def_det;
                      if l_arch then
                        l_p46_5_def := 2;
                      end if;
                      fnd_file.put_line(fnd_file.LOG,to_char(l_p46_5_def));
                    end if;
                  end if;
                end if;
              /*else
                l_reason := 'X';   */
              end if;
           else
            if l_send_flag = 'Y' then
              l_arch := true;
            else
              if l_send_flag = 'N' and l_static_flag = 'Y' then
                 l_arch := check_action(p_rep_type, asg_rec.assignment_id);
              end if;
            end if;
           end if;
           /*EOY Changes for P46_Ver6 End*/

          --Added for bug 9255173
           /* Changes for P46_VER6 eTextStart*/
            if p_rep_type = 'P46_VER6ET' then
              l_p45_not_run := check_action('P45%3%', asg_rec.assignment_id); -- Changed to handle version 6 Reports also
              if l_p45_not_run then
                open csr_p46_5_default(asg_rec.assignment_id);
                fetch csr_p46_5_default into l_def_send_flag,l_def_static_flag;
                close csr_p46_5_default;
                /*** checking if the default is to be run *****/
                if l_def_send_flag = 'Y' then
                  l_arch := true;
                  l_p46_5_def := 1;
                else
                  if l_def_send_flag = 'N' and l_def_static_flag = 'Y' then
                    l_arch := check_action(p_rep_type, asg_rec.assignment_id);
                    if l_arch then
                      l_p46_5_def := 1; /** if def not archived then archive ***/
                    else
                      l_p46_5_def := 0;
                     end if;
                  end if;
                end if;
                 fnd_file.put_line(fnd_file.LOG,to_char(l_p46_5_def)||l_def_send_flag||l_def_static_flag||l_send_flag||l_static_flag||asg_rec.assignment_id);
                /**** checking if the default has been run or not enabled to run ****/
                if l_p46_5_def = 0 and nvl(l_def_send_flag,'N') = 'N' /*and nvl(l_def_static_flag,'Y') = 'Y'*/ then
                  if l_send_flag = 'Y' then
                    l_arch := true;
                    l_p46_5_def := 2;   /**** diff b/n normal run for other report types and P46_5 normal run ***/
                  else
                    if l_send_flag = 'N' and l_static_flag = 'Y' then /** checking if P46 normal is rolled back ***/
                      fnd_file.put_line(fnd_file.LOG,'11111');
                      open csr_p46_5_def_det(asg_rec.assignment_id,'N');
                      fetch csr_p46_5_def_det into l_exist;
                      if csr_p46_5_def_det%notfound then
                        -- Bug 6770200
                        l_arch := check_action('P46_VER6ET', asg_rec.assignment_id);
                      end if;
                      close csr_p46_5_def_det;
                      if l_arch then
                        l_p46_5_def := 2;
                      end if;
                      fnd_file.put_line(fnd_file.LOG,to_char(l_p46_5_def));
                    end if;
                  end if;
                end if;
              /*else
                l_reason := 'X';   */
              end if;
           else
            if l_send_flag = 'Y' then
              l_arch := true;
            else
              if l_send_flag = 'N' and l_static_flag = 'Y' then
                 l_arch := check_action(p_rep_type, asg_rec.assignment_id);
              end if;
            end if;
           end if;
           /*Changes for P46_Ver6 eText End*/

           if l_arch then
              hr_utility.set_location('Creating assignment action for ' || asg_rec.assignment_id,30);
              select pay_assignment_actions_s.nextval
              into   l_ass_act_id
              from   dual;
              --
              -- insert into pay_assignment_actions.
              hr_nonrun_asact.insact(l_ass_act_id,
                                     asg_rec.assignment_id,
                                     pactid,
                                     chunk,
                                     null);

             if l_p46_5_def = 2 then
                 open csr_p46_5_def_assact(asg_rec.assignment_id);
                 fetch csr_p46_5_def_assact into l_locked_action_id;
                 if csr_p46_5_def_assact%NOTFOUND then /*** condition happens only when default is not run prior to normal P46 ****/
                   l_locked_action_id := -1;
                 end if;
                 close csr_p46_5_def_assact;

               fnd_file.put_line(fnd_file.LOG,to_char(l_locked_action_id));
               if l_locked_action_id > 0 then
                 delete pay_action_interlocks where locked_action_id = l_locked_action_id;
                 hr_nonrun_asact.insint(l_ass_act_id,l_locked_action_id);
               end if;
             end if;

           end if;
         end if;
         close csr_aei_flag;

     end loop;

     hr_utility.set_location('Leaving: '||l_proc,999);
END internal_action_creation;
--
--
--
--
/*** EOY 07-08 ****/
FUNCTION fetch_45_46_pennot_rec(p_effective_date IN  DATE,
                        p_tax_rec        IN  g_tax_rec,
                        p_person_rec     IN  act_info_rec,
                        p_info_type      IN VARCHAR2,
                        p_assact_id      IN NUMBER,
                        p_45_46_pennot_rec       OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_45_46_pennot_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_arch           boolean;


     cursor csr_45_46_pennot_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 send_edi,
            aei.aei_information2 annual_pension,
            aei.aei_information3 date_pension_start,
            aei.aei_information4 static_flag,
            aei.aei_information5 prev_emp_paye_ref,
            aei.aei_information6 date_left_prev_emp,
            aei.aei_information7 prev_tax_code,
            aei.aei_information8 prev_tax_basis,
            aei.aei_information9 prev_last_pay_period_type,
            aei.aei_information10 prev_last_pay_period,
            aei.aei_information11 recently_bereaved,
            aei.object_version_number
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_person_rec.assignment_id
     and    aei.information_type = p_info_type;



     l_45_46_pennot_rec  csr_45_46_pennot_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

 fnd_file.put_line(fnd_file.LOG,'Entering: '||l_proc);
     open csr_45_46_pennot_details;
     fetch csr_45_46_pennot_details into l_45_46_pennot_rec;
     close csr_45_46_pennot_details;


     if length(ltrim(p_tax_rec.tax_code,'S')) > 6 then
        --l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Tax Code');
        pay_core_utils.push_token('MAX_VALUE', '6 characters');
        hr_utility.set_location('Tax Code error',20);
           fnd_file.put_line(fnd_file.LOG,'l_arch3: ');

     end if;
     if length(ltrim(l_45_46_pennot_rec.prev_tax_code,'S')) > 6 then
        --l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Previous Tax Code');
        pay_core_utils.push_token('MAX_VALUE', '6 characters');
        hr_utility.set_location('Prev Tax Code',40);
        fnd_file.put_line(fnd_file.LOG,'l_arch4: ');
     end if;

     if not validate_data(substr(ltrim(substr(l_45_46_pennot_rec.prev_emp_paye_ref,4,8),'/'),1,7),'Previous Tax Reference','FULL_EDI') then
        --l_arch := false;
        hr_utility.set_location('Previous Tax Reference error',50);
        fnd_file.put_line(fnd_file.LOG,'l_arch5: ');
     end if;

     if not validate_data(substr(l_45_46_pennot_rec.prev_emp_paye_ref,1,3),'Previous Tax District','FULL_EDI') then
        --l_arch := false;
        hr_utility.set_location('Previous Tax District error',60);
        fnd_file.put_line(fnd_file.LOG,'l_arch6: ');
     end if;

     if not validate_data(p_tax_rec.prev_paid,'Previous Pay','FULL_EDI')  then
       -- l_arch := false;
        hr_utility.set_location('Prev Pay Valiation',70);
        fnd_file.put_line(fnd_file.LOG,'l_arch7: ');
     end if;

     if not validate_data(p_tax_rec.prev_tax,'Previous Tax','FULL_EDI')  then
        --l_arch := false;
        hr_utility.set_location('Prev Tax Validation',80);
        fnd_file.put_line(fnd_file.LOG,'l_arch8: ');
     end if;

     if not validate_data(l_45_46_pennot_rec.prev_last_pay_period,'Previous Last Payment Period','FULL_EDI') then
        --l_arch := false;
        hr_utility.set_location('Previous period error',90);
        fnd_file.put_line(fnd_file.LOG,'l_arch9: ');
     end if;

     l_ovn := l_45_46_pennot_rec.object_version_number;
     if l_arch then
        hr_utility.set_location('Clear Flag',20);
        hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_45_46_pennot_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P46PENNOT',
               p_aei_information1               => 'N');
     end if;

    if p_info_type = 'GB_P46PENNOT' then
       p_45_46_pennot_rec.action_info_category := 'GB P46 PENNOT EDI';
    end if;

     p_45_46_pennot_rec.assignment_id := p_person_rec.assignment_id;
     p_45_46_pennot_rec.effective_date := p_effective_date;
     p_45_46_pennot_rec.act_info1 := l_ovn;
     p_45_46_pennot_rec.act_info2 := trim(l_45_46_pennot_rec.annual_pension);
     p_45_46_pennot_rec.act_info3 := l_45_46_pennot_rec.date_pension_start;
     p_45_46_pennot_rec.act_info4 := l_45_46_pennot_rec.prev_emp_paye_ref;
     p_45_46_pennot_rec.act_info5 := l_45_46_pennot_rec.date_left_prev_emp;
     p_45_46_pennot_rec.act_info6 := l_45_46_pennot_rec.prev_tax_code;
     p_45_46_pennot_rec.act_info7 := l_45_46_pennot_rec.prev_tax_basis;
     p_45_46_pennot_rec.act_info8 := l_45_46_pennot_rec.prev_last_pay_period_type;
     p_45_46_pennot_rec.act_info9 := l_45_46_pennot_rec.prev_last_pay_period;
     p_45_46_pennot_rec.act_info10 := l_45_46_pennot_rec.recently_bereaved;
     p_45_46_pennot_rec.act_info11 := p_tax_rec.prev_paid;
     p_45_46_pennot_rec.act_info12 := p_tax_rec.prev_tax;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;



  EXCEPTION
    WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.LOG,'2435*****');
      return false;
END fetch_45_46_pennot_rec;
--

PROCEDURE fetch_tax_rec(p_assactid       IN  NUMBER,
                        p_effective_date IN  DATE,
                        p_tax_rec        OUT nocopy g_tax_rec) IS

     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_tax_rec';
     l_paye_id            number;
     l_paye_details_id    number;
     l_paye_rr_id         number;
     l_paye_details_rr_id number;
     l_assignment_id      number;
     l_element_id         number;
     l_asg_start          date;
     l_asg_end            date;

     cursor csr_element_id(p_name varchar2) is
     select element_type_id
     from   pay_element_types_f
     where  element_name = p_name
     and legislation_code = 'GB';

     cursor csr_assignment_details is
     select /*+ ORDERED */
            asg.assignment_id,
            asg.effective_start_date,
            asg.effective_end_date
     from   pay_assignment_actions paa,
            per_assignments_f      asg
     where  paa.assignment_action_id = p_assactid
     and    paa.assignment_id = asg.assignment_id
     and    p_effective_date between asg.effective_start_date and asg.effective_end_date;

     -- Bug 6643668
     -- Tax data should be picked only from element entry values.
     -- Earlier code was checking run results first, then if values not found
     -- there, then it was going for element entry values.
     /*
     cursor csr_max_run_result(p_element_id number) is
     select /*+ ORDERED INDEX (assact2 PAY_ASSIGNMENT_ACTIONS_N51,
                                  pact PAY_PAYROLL_ACTIONS_PK,
                                    r2 PAY_RUN_RESULTS_N50)
                USE_NL(assact2, pact, r2) */
     /*        to_number(substr(max(lpad(assact2.action_sequence,15,'0')||r2.source_type|| r2.run_result_id),17))
     from   pay_assignment_actions assact2,
            pay_payroll_actions pact,
            pay_run_results r2
     where  assact2.assignment_id = l_assignment_id
     and    r2.element_type_id+0 = p_element_id
     and    r2.assignment_action_id = assact2.assignment_action_id
     and    r2.status IN ('P', 'PA')
     and    pact.payroll_action_id = assact2.payroll_action_id
     and    pact.action_type IN ( 'Q','R','B','I')
     and    assact2.action_status = 'C'
     and    pact.effective_date between l_asg_start and l_asg_end
     and    not exists(
            select '1'
             from  pay_action_interlocks pai,
                   pay_assignment_actions assact3,
                   pay_payroll_actions pact3
            where  pai.locked_action_id = assact2.assignment_action_id
            and    pai.locking_action_id = assact3.assignment_action_id
            and    pact3.payroll_action_id = assact3.payroll_action_id
            and    pact3.action_type = 'V'
            and    assact3.action_status = 'C');

     cursor csr_run_result(l_run_result_id number,l_element_type_id number) is
     select max(decode(name,'Tax Code',result_value,NULL)) tax_code,
            max(decode(name,'Tax Basis',result_value,NULL)) tax_basis,
            to_number(max(decode(name,'Pay Previous',
            fnd_number.canonical_to_number(result_value),NULL))) pay_previous,
            to_number(max(decode(name,'Tax Previous',
            fnd_number.canonical_to_number(result_value),NULL))) tax_previous
     from   pay_input_values_f v,
            pay_run_result_values rrv
     where  rrv.run_result_id = l_run_result_id
     and    v.input_value_id = rrv.input_value_id
     and    v.element_type_id = l_element_type_id;
     */

     cursor csr_paye_details is
     select max(decode(iv.name,'Tax Code',screen_entry_value))     tax_code,
            max(decode(iv.name,'Tax Basis',screen_entry_value))    tax_basis,
            max(decode(iv.name,'Pay Previous',screen_entry_value)) pay_previous,
            max(decode(iv.name,'Tax Previous',screen_entry_value)) tax_previous
     from   pay_element_entries_f e,
            pay_element_entry_values_f v,
            pay_input_values_f iv,
            pay_element_links_f link
     where  e.assignment_id = l_assignment_id
     and    link.element_type_id = l_paye_details_id
     and    e.element_link_id = link.element_link_id
     and    e.element_entry_id = v.element_entry_id
     and    iv.input_value_id = v.input_value_id
     and    p_effective_date between e.effective_start_date and e.effective_end_date -- 5660011
     and    p_effective_date between v.effective_start_date and v.effective_end_date
     and    p_effective_date between link.effective_start_date and link.effective_end_date
     and    e.effective_end_date between link.effective_start_date and link.effective_end_date
     and    e.effective_end_date between iv.effective_start_date and iv.effective_end_date
     and    e.effective_end_date between v.effective_start_date and v.effective_end_date ;
     -- Bug 6643668 - this check is not reuqired
     /*and    e.effective_end_date = (select max(e1.effective_end_date)
                                    from   pay_element_entries_f  e1,
                                           pay_element_links_f    link1
                                    where  link1.element_type_id = l_paye_details_id
                                    and    e1.assignment_id = l_assignment_id
                                    and    e1.element_link_id = link1.element_link_id);
      */

BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);



     open csr_element_id('PAYE');
     fetch csr_element_id into l_paye_id;
     close csr_element_id;

     open csr_element_id('PAYE Details');
     fetch csr_element_id into l_paye_details_id;
     close csr_element_id;

     open csr_assignment_details;
     fetch csr_assignment_details into l_assignment_id,
                                       l_asg_start,
                                       l_asg_end;
     close csr_assignment_details;

     -- Bug 6643668
     -- Tax data should be picked only from element entry values.
     -- Earlier code was checking run results first, then if values not found
     -- there, then it was going for element entry values.
     /*
     open csr_max_run_result(l_paye_id);
     fetch csr_max_run_result into l_paye_rr_id;
     close csr_max_run_result;

     open csr_max_run_result(l_paye_details_id);
     fetch csr_max_run_result into l_paye_details_rr_id;
     close csr_max_run_result;

     open csr_run_result(l_paye_rr_id, l_paye_id);
     fetch csr_run_result into p_tax_rec.tax_code,
                               p_tax_rec.tax_basis,
                               p_tax_rec.prev_paid,
                               p_tax_rec.prev_tax;
     close csr_run_result;
     -- if Tax code is not found, fetch from the latest PAYE Details run results

	-- Bug 5660011
	if ( p_tax_rec.prev_tax is null and p_tax_rec.prev_paid is null ) or
		( p_tax_rec.prev_tax = 0 and p_tax_rec.prev_paid = 0 ) then
    */
   	open csr_paye_details;
	fetch csr_paye_details into p_tax_rec.tax_code,
                                p_tax_rec.tax_basis,
                                p_tax_rec.prev_paid,
                                p_tax_rec.prev_tax;
	close csr_paye_details;
	/* -- Bug 6643668 continued
    end if;

     if p_tax_rec.tax_code is null then
        open csr_run_result(l_paye_details_rr_id, l_paye_details_id);
        fetch csr_run_result into p_tax_rec.tax_code,
                                  p_tax_rec.tax_basis,
                                  p_tax_rec.prev_paid,
                                  p_tax_rec.prev_tax;
       close csr_run_result;

       -- 3. Still not found, fetch the value from the PAYE
       if p_tax_rec.tax_code is null then
          hr_utility.trace('Fetching run result 3');
          open csr_paye_details;
          fetch csr_paye_details into p_tax_rec.tax_code,
                                      p_tax_rec.tax_basis,
                                      p_tax_rec.prev_paid,
                                      p_tax_rec.prev_tax;
          close csr_paye_details;
       end if;
    end if;
    */
    hr_utility.set_location('Leaving: '||l_proc,999);
END fetch_tax_rec;
--
--
FUNCTION fetch_address_rec(p_person_id      IN NUMBER,
                           p_assignment_id  IN NUMBER,
                           p_effective_date IN DATE,
                           p_addr_rec       OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_address_rec';
     l_arch   boolean;
     l_temp  varchar2(200);
     cursor csr_address is
     select upper(substr(addr.address_line1,1,35)) addr1,
            upper(substr(addr.address_line2,1,35)) addr2,
            upper(substr(addr.address_line3,1,35)) addr3,
            upper(hr_general.decode_lookup('GB_COUNTY', substr(addr.region_1,1,35))) county,
            addr.postal_code post_code,
            upper(addr.town_or_city) town_or_city,
	    upper(addr.country) country
     from   per_addresses addr
     where  addr.person_id(+) = p_person_id
     and    (   addr.primary_flag = 'Y'
             or addr.primary_flag is null)
     and    p_effective_date between nvl(addr.date_from,fnd_date.canonical_to_date('0001/01/01 00:00:00'))
                             and     nvl(addr.date_to, fnd_date.canonical_to_date('4712/12/31 00:00:00'));
     l_addr_rec csr_address%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

     open csr_address;
     fetch csr_address into l_addr_rec;
     close csr_address;

     l_temp := l_addr_rec.addr1 || ' ' || l_addr_rec.addr2 ||
               l_addr_rec.addr3 || ' ' || l_addr_rec.town_or_city ||
               l_addr_rec.county;

--For bugs 9255173 and 9255183
--Following validations are not required for eText reports here
--as they have been moved to a different procedure
IF g_archive_type <> 'P46_VER6ET' AND g_archive_type <> 'P46EXP_VER6ET' THEN
     if l_addr_rec.addr1 is null then
        pay_core_utils.push_message(800, 'HR_78088_MISSING_DATA_ERR', 'F');
        pay_core_utils.push_token('TOKEN', 'Address');
        l_arch := false;
        hr_utility.set_location('Address missing',10);
     end if;

     if not validate_data(l_temp,'Address','P14_FULL_EDI') then
        l_arch := false;
        hr_utility.set_location('Address Validation',20);
     end if;

     if not validate_data(l_addr_rec.post_code,'Post Code','FULL_EDI') then
        l_arch := false;
        hr_utility.set_location('Post Code error',20);
     end if;
END IF;

     p_addr_rec.assignment_id := p_assignment_id;
     p_addr_rec.effective_date := p_effective_date;
     p_addr_rec.action_info_category := 'ADDRESS DETAILS';
     p_addr_rec.act_info5  := l_addr_rec.addr1;
     p_addr_rec.act_info6  := l_addr_rec.addr2;
     p_addr_rec.act_info7  := l_addr_rec.addr3;
     p_addr_rec.act_info8  := l_addr_rec.town_or_city;
     p_addr_rec.act_info9  := l_addr_rec.county;
     p_addr_rec.act_info12 := l_addr_rec.post_code;
     p_addr_rec.act_info13 := l_addr_rec.country;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;
END fetch_address_rec;
--
--
--
--
-- Function to fetch country name for the given country code
--

FUNCTION get_territory_short_name(prm_name in varchar2)
return varchar2 is
--
-- Cursor to fetch country name for the country code
--
   Cursor csr_territory_short_name (p_code varchar2) is
   select territory_short_name
   from fnd_territories_vl
   where territory_code = p_code;

   l_code varchar2(200);
BEGIN
     open csr_territory_short_name(prm_name);
     fetch csr_territory_short_name into l_code;
     close csr_territory_short_name;

     return l_code;

END get_territory_short_name;
--
--
--
FUNCTION fetch_person_rec(p_assactid       IN NUMBER,
                          p_effective_date IN DATE,
                          p_tax_rec        IN g_tax_rec,
                          p_person_rec     OUT nocopy act_info_rec) return boolean IS

     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_person_rec';
     l_job            varchar2(70);
     l_person_id      number;
     l_arch           boolean;
     l_temp           varchar2(30);

     cursor csr_person_details is
     select /*+ ORDERED */
            pap.person_id,
            paa.assignment_id,
            pap.title,
            pap.first_name,
            pap.last_name,
            pap.middle_names,
            paa.ASSIGNMENT_NUMBER,
            pap.national_identifier,
            pap.sex,
            fnd_date.date_to_canonical(pap.date_of_birth) date_of_birth,
            fnd_date.date_to_canonical(decode(pap.current_employee_flag, 'Y', serv.date_start, null)) hire_date
     from   pay_assignment_actions act,
            per_assignments_f      paa,
            per_people_f           pap,
            per_periods_of_service serv
     where  act.assignment_action_id = p_assactid
     and    act.assignment_id = paa.assignment_id
     and    paa.person_id = pap.person_id
     and    paa.period_of_service_id = serv.period_of_service_id
     and    serv.date_start <= p_effective_date
     and    p_effective_date between paa.effective_start_date and paa.effective_end_date
     and    p_effective_date between pap.effective_start_date and pap.effective_end_date;

     cursor csr_job is
     select pay_get_job_segment_pkg.get_job_segment(paa.business_group_id,job.job_definition_id,act.payroll_action_id) job
     from   pay_assignment_actions act,
            per_assignments_f      paa,
            per_jobs               job
     where  act.assignment_action_id = p_assactid
     and    act.assignment_id = paa.assignment_id
     and    paa.job_id = job.job_id(+)
     and    p_effective_date between paa.effective_start_date and paa.effective_end_date;

     l_person_rec  csr_person_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

     open csr_person_details;
     fetch csr_person_details into l_person_rec;
     close csr_person_details;

     open csr_job;
     fetch csr_job into l_job;
     close csr_job;

--For bugs 9255173 and 9255183
--Following validations are not required for eText reports here
--as they have been moved to a different procedure
IF g_archive_type <> 'P46_VER6ET' AND g_archive_type <> 'P46EXP_VER6ET' THEN

     if not validate_data(l_person_rec.first_name,'First Name','EDI_SURNAME') then
        l_arch := false;
         hr_utility.set_location('First Name error',10);
     end if;

     if not validate_data(l_person_rec.last_name,'Last Name','EDI_SURNAME') then
        l_arch := false;
         hr_utility.set_location('Last Name error',20);
     end if;

     if not validate_data(l_person_rec.assignment_number,'Assignment Number','FULL_EDI') then
        l_arch := false;
         hr_utility.set_location('Assignment Number error',30);
     end if;

     if not validate_data(l_person_rec.sex,'Sex','FULL_EDI') then
        l_arch := false;
         hr_utility.set_location('Sex error',40);
     end if;

     if not validate_data(l_job,'Job Title','P14_FULL_EDI') then -- Bug 8315067
        l_arch := false;
         hr_utility.set_location('Job Title error',50);
     end if;

     if l_person_rec.national_identifier is not null and
        hr_gb_utility.ni_validate(l_person_rec.national_identifier,sysdate) <> 0 then
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', 'NI Number');
        pay_core_utils.push_token('INPUT_VALUE', l_person_rec.national_identifier);
        l_arch := false;
        hr_utility.set_location('NI error',60);
     end if;
END IF;

     /** -- NO Tax code validation yet as it is different between P45(3),P46 and P46P --**
     l_temp := hr_gb_utility.tax_code_validate(p_tax_rec.tax_code,sysdate,l_person_rec.assignment_id);
     if l_temp <> ' ' then
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', 'Tax Code');
        pay_core_utils.push_token('INPUT_VALUE', p_tax_rec.tax_code);
        l_arch := false;
        hr_utility.set_location('Tax Code error',30);
     end if;
     */
     p_person_rec.person_id  := l_person_rec.person_id;
     p_person_rec.assignment_id := l_person_rec.assignment_id;
     p_person_rec.effective_date := p_effective_date;
     p_person_rec.action_info_category := 'GB EMPLOYEE DETAILS';
     p_person_rec.act_info6  := l_person_rec.first_name;
     p_person_rec.act_info7  := l_person_rec.middle_names;
     p_person_rec.act_info8  := l_person_rec.last_name;
     p_person_rec.act_info11 := l_person_rec.assignment_number;
     p_person_rec.act_info12 := l_person_rec.national_identifier;
     p_person_rec.act_info14 := l_person_rec.title;
     p_person_rec.act_info15 := l_person_rec.date_of_birth;
     p_person_rec.act_info16 := l_person_rec.hire_date;
     p_person_rec.act_info17 := l_person_rec.sex;
     p_person_rec.act_info18 := l_job;
     p_person_rec.act_info21 := p_tax_rec.tax_code;
     p_person_rec.act_info22 := p_tax_rec.tax_basis;
     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;
END fetch_person_rec;
--
--
FUNCTION fetch_p45_3_rec(p_effective_date IN  DATE,
                         p_tax_rec        IN  g_tax_rec,
                         p_person_rec     IN  act_info_rec,
                         p_p45_3_rec      OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_p45_3_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_arch           boolean;
     l_temp           varchar2(30);

     cursor csr_p45_3_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 send_edi,
            aei.aei_information2 prev_tax_district,
            aei.aei_information3 date_left,
            aei.aei_information4 prev_tax_code,
            aei.aei_information5 prev_tax_basis,
            aei.aei_information6 prev_period_type,
            aei.aei_information7 prev_period,
            aei.aei_information8 static_flag,
            /*changes for P45PT_3 start*/
            aei.aei_information9 prev_tax_paid_notified,
            aei.aei_information10 not_paid_between_start_and5apr,
            aei.aei_information11 continue_sl_deductions,
            /*changes for P45PT_3 start*/
	    --Bug 6994632 fetching Prev Tax Pay Notified value
	    aei.aei_information12 prev_tax_pay_notified,
            aei.object_version_number
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_person_rec.assignment_id
     and    aei.information_type = 'GB_P45_3';

     cursor csr_student_loan is
     select  nvl(min(decode(inv.name, 'Start Date', eev.screen_entry_value, 'X')),'X') s_date,
             nvl(min(decode(inv.name, 'End Date', eev.screen_entry_value, null)),'4712/12/31 00:00:00') e_date,
             fnd_date.date_to_canonical(min(decode(inv.name, 'End Date', eev.effective_end_date, fnd_date.canonical_to_date('4712/12/31 00:00:00')))) eff_date
     from    pay_element_types_f        elt,
             pay_element_entries_f      ele,
             pay_input_values_f         inv,
             pay_element_entry_values_f eev
     where   elt.element_name = 'Student Loan'
     and     ele.element_type_id = elt.element_type_id
     and     ele.assignment_id   = p_person_rec.assignment_id
     and     inv.element_type_id = elt.element_type_id
     and     eev.input_value_id + 0 = inv.input_value_id
     and     eev.element_entry_id = ele.element_entry_id -- Bug 5469122
     and     p_effective_date between elt.effective_start_date and elt.effective_end_date
     and     p_effective_date between ele.effective_start_date and ele.effective_end_date
     and     p_effective_date between inv.effective_start_date and inv.effective_end_date
     and     p_effective_date between eev.effective_start_date and eev.effective_end_date;

     l_p45_3_rec  csr_p45_3_details%rowtype;
     l_student_rec csr_student_loan%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

     open csr_p45_3_details;
     fetch csr_p45_3_details into l_p45_3_rec;
     close csr_p45_3_details;

     open csr_student_loan;
     fetch csr_student_loan into l_student_rec;
     close csr_student_loan;

     if l_p45_3_rec.date_left is null then
        pay_core_utils.push_message(800, 'HR_78088_MISSING_DATA_ERR', 'F');
        pay_core_utils.push_token('TOKEN', 'Date Left Previous Employer');
        l_arch := false;
        hr_utility.set_location('Date Left null',30);
     end if;

     if to_number(p_tax_rec.prev_paid) > 999999.99 then
        l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Previous Pay');
        pay_core_utils.push_token('MAX_VALUE', '999999.99');
        hr_utility.set_location('Prev Paid > 999999.99',10);
     end if;

     if to_number(p_tax_rec.prev_tax) > 999999.99 then
        l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Previous Tax');
        pay_core_utils.push_token('MAX_VALUE', '999999.99');
        hr_utility.set_location('Prev Tax > 999999.99',20);
     end if;

     /** -- Validate using the orignal, will use new one when requirement comes out --
     l_temp := hr_gb_utility.tax_code_validate(l_p45_3_rec.prev_tax_code,sysdate,p_person_rec.assignment_id);
     if l_temp <> ' ' then
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', 'Previous Tax Code');
        pay_core_utils.push_token('INPUT_VALUE', p_tax_rec.tax_code);
        l_arch := false;
        hr_utility.set_location('Tax Code error',30);
     end if;
     */
     if length(ltrim(p_tax_rec.tax_code,'S')) > 6 then
        l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Tax Code');
        pay_core_utils.push_token('MAX_VALUE', '6 characters');
        hr_utility.set_location('Tax Code error',30);
     end if;

     if length(ltrim(l_p45_3_rec.prev_tax_code,'S')) > 6 then
        l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Previous Tax Code');
        pay_core_utils.push_token('MAX_VALUE', '6 characters');
        hr_utility.set_location('Prev Tax Code',40);
     end if;

     if not validate_data(substr(ltrim(substr(l_p45_3_rec.prev_tax_district,4,8),'/'),1,7),'Previous Tax Reference','FULL_EDI') then
        l_arch := false;
        hr_utility.set_location('Previous Tax Reference error',50);
     end if;

     if not validate_data(substr(l_p45_3_rec.prev_tax_district,1,3),'Previous Tax District','FULL_EDI') then
        l_arch := false;
        hr_utility.set_location('Previous Tax District error',60);
     end if;

     if not validate_data(p_tax_rec.prev_paid,'Previous Pay','FULL_EDI')  then
        l_arch := false;
        hr_utility.set_location('Prev Pay Valiation',70);
     end if;

     if not validate_data(p_tax_rec.prev_tax,'Previous Tax','FULL_EDI')  then
        l_arch := false;
        hr_utility.set_location('Prev Tax Validation',80);
     end if;

     if not validate_data(l_p45_3_rec.prev_period,'Previous Last Payment Period','FULL_EDI') then
        l_arch := false;
        hr_utility.set_location('Previous period error',90);
     end if;

     l_ovn := l_p45_3_rec.object_version_number;
     if l_arch then
        hr_utility.set_location('Clear Flag',100);
        hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_p45_3_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P45_3',
               p_aei_information1               => 'N');
     end if;

     p_p45_3_rec.assignment_id := p_person_rec.assignment_id;
     p_p45_3_rec.effective_date := p_effective_date;
     p_p45_3_rec.action_info_category := 'GB P45(3) EDI';
     p_p45_3_rec.act_info1 := l_ovn;
     p_p45_3_rec.act_info2 := l_p45_3_rec.prev_tax_district;
     p_p45_3_rec.act_info3 := l_p45_3_rec.date_left;
     p_p45_3_rec.act_info4 := l_p45_3_rec.prev_tax_code;
     p_p45_3_rec.act_info5 := l_p45_3_rec.prev_tax_basis;
     p_p45_3_rec.act_info6 := l_p45_3_rec.prev_period_type;
     p_p45_3_rec.act_info7 := l_p45_3_rec.prev_period;
     p_p45_3_rec.act_info8 := p_tax_rec.prev_paid;
     p_p45_3_rec.act_info9 := p_tax_rec.prev_tax;
     p_p45_3_rec.act_info10:= l_student_rec.s_date;
     p_p45_3_rec.act_info11:= l_student_rec.e_date;
     p_p45_3_rec.act_info12:= l_student_rec.eff_date;
     /*changes for P45PT_3 start*/
     p_p45_3_rec.act_info13:= l_p45_3_rec.prev_tax_paid_notified;
     p_p45_3_rec.act_info14:= l_p45_3_rec.not_paid_between_start_and5apr;
     p_p45_3_rec.act_info15:= l_p45_3_rec.continue_sl_deductions;
     /*changes for P45PT_3 end*/
     -- Bug 6994632 passing Prev Tax Pay Notified value to archive function
     p_p45_3_rec.act_info16:= l_p45_3_rec.prev_tax_pay_notified;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;
END fetch_p45_3_rec;
--
--
FUNCTION fetch_p46_rec(p_effective_date IN  DATE,
                       p_tax_rec      IN  g_tax_rec,
                       p_person_rec   IN  act_info_rec,
                       p_p46_rec      OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_p46_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_arch           boolean;
     l_temp           varchar2(50);

     cursor csr_p46_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 send_edi,
            aei.aei_information2 p46_statement,
            aei.aei_information3 static_flag,
            aei.aei_information4 student_loan,
            aei.object_version_number
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_person_rec.assignment_id
     and    aei.information_type = 'GB_P46';

     l_p46_rec  csr_p46_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

     open csr_p46_details;
     fetch csr_p46_details into l_p46_rec;
     close csr_p46_details;

     if not validate_data(l_p46_rec.p46_statement,'P46 Statement','FULL_EDI')  then
        l_arch := false;
        hr_utility.set_location('P46 Statement validation',10);
     end if;

     l_temp := hr_gb_utility.tax_code_validate(p_tax_rec.tax_code,sysdate,p_person_rec.assignment_id);
     if l_temp <> ' ' then
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', 'Tax Code');
        pay_core_utils.push_token('INPUT_VALUE', p_tax_rec.tax_code);
        l_arch := false;
        hr_utility.set_location('Tax Code error',20);
     end if;

     l_ovn := l_p46_rec.object_version_number;
     if l_arch then
        hr_utility.set_location('Clear Flag',30);
        hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_p46_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P46',
               p_aei_information1               => 'N');
     end if;

     p_p46_rec.assignment_id := p_person_rec.assignment_id;
     p_p46_rec.effective_date := p_effective_date;
     p_p46_rec.action_info_category := 'GB P46 EDI';
     p_p46_rec.act_info1 := l_ovn;
     p_p46_rec.act_info2 := l_p46_rec.p46_statement;
     p_p46_rec.act_info3 := l_p46_rec.student_loan;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;
END fetch_p46_rec;
--

	/*Changes for P46EXP_Ver6 starts*/
FUNCTION fetch_p46exp_rec(p_effective_date IN  DATE,
                       p_tax_rec      IN  g_tax_rec,
                       p_person_rec   IN  act_info_rec,
                       p_p46_rec      OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_p46exp_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_arch           boolean;
     l_temp           varchar2(50);

     cursor csr_p46_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 send_edi,
            aei.aei_information2 p46_statement,
            aei.aei_information3 static_flag,
            aei.aei_information4 student_loan,
            aei.object_version_number,
            aei.aei_information5 eea_cw_citizen,
            aei.aei_information6 em6_scheme,
            aei.aei_information7 date_started_uk
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_person_rec.assignment_id
     and    aei.information_type = 'GB_P46EXP';

     l_p46_rec  csr_p46_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

     open csr_p46_details;
     fetch csr_p46_details into l_p46_rec;
     close csr_p46_details;

     if not validate_data(l_p46_rec.p46_statement,'P46(Expat) Statement','FULL_EDI')  then
        l_arch := false;
        hr_utility.set_location('P46(Expat) Statement validation',10);
     end if;

     l_temp := hr_gb_utility.tax_code_validate(p_tax_rec.tax_code,sysdate,p_person_rec.assignment_id);
/*     if l_temp <> ' ' then
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', 'Tax Code');
        pay_core_utils.push_token('INPUT_VALUE', p_tax_rec.tax_code);
        l_arch := false;
        hr_utility.set_location('Tax Code error',20);
     end if;*/

     l_ovn := l_p46_rec.object_version_number;
     if l_arch then
        hr_utility.set_location('Clear Flag',30);
        hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_p46_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P46EXP',
               p_aei_information1               => 'N');
     end if;

     p_p46_rec.assignment_id := p_person_rec.assignment_id;
     p_p46_rec.effective_date := p_effective_date;
     p_p46_rec.action_info_category := 'GB P46EXP EDI';
     p_p46_rec.act_info1 := l_ovn;
     p_p46_rec.act_info2 := l_p46_rec.p46_statement;
     p_p46_rec.act_info3 := l_p46_rec.student_loan;
     p_p46_rec.act_info4 := l_p46_rec.eea_cw_citizen;
     p_p46_rec.act_info5 := l_p46_rec.date_started_uk;
     p_p46_rec.act_info6 := l_p46_rec.em6_scheme;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;
END fetch_p46exp_rec;

	/*Changes for P46EXP_Ver6 End*/

--For bugs 9255173 and 9255183
--This procedure is used to collect all the eText report validation failures
--they would then be written to the o/p file
PROCEDURE populate_run_msg(
             p45_assignment_action_id IN     NUMBER
            ,p_message_text           IN     varchar2
           )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
hr_utility.set_location(' Entering: populate_run_msg',111);

  INSERT INTO pay_message_lines(line_sequence,
                                payroll_id,
                                message_level,
                                source_id,
                                source_type,
                                line_text)
                         VALUES(
                                pay_message_lines_s.nextval
                               ,null
                               ,'F'
                               ,p45_assignment_action_id
                               ,'A'
                               ,substr(p_message_text,1,240)
                              );

hr_utility.set_location(' Leaving: populate_run_msg',999);
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    hr_utility.trace('Error occured in populate_run_msg');
    RAISE;
END populate_run_msg;


--For bug 9255183
--This procedure implements P46Expat formula validations
PROCEDURE p46exp_asg_etext_validations(p_assactid       IN NUMBER,
                                 p_effective_date IN DATE,
                                 p_tab_rec_data   IN action_info_table,
                                 edi_validation_fail out nocopy  varchar2) IS

CURSOR get_effective_date IS
     SELECT ppa.effective_date
       FROM pay_payroll_actions ppa, pay_assignment_actions paa
      WHERE ppa.payroll_action_id = paa.payroll_action_id
        AND paa.assignment_action_id = p_assactid;

     l_proc  CONSTANT VARCHAR2(50):= g_package||'p46exp_asg_etext_validations';
     l_ovn       number;
     l_action_id number;
     --edi_validation_fail varchar2(50);

  l_sex per_people_f.sex%TYPE;
  l_assignment_number per_assignments_f.assignment_number%TYPE;
  l_date_of_birth varchar2(100);
  l_tax_code_in_use varchar2(100);
  l_tax_basis_in_use varchar2(100);
  l_msg_value varchar2(100);
  l_eff_date date;

  l_p46_expat_statement per_assignment_extra_info.aei_information2%TYPE;
  l_p46_expat_start_empl_date per_assignment_extra_info.aei_information7%TYPE;
  l_p46_expat_eea_citizen per_assignment_extra_info.aei_information5%TYPE;

BEGIN
l_sex := p_tab_rec_data(0).act_info17;
hr_utility.set_location('Etext41 l_sex'||l_sex,111);
l_assignment_number := p_tab_rec_data(0).act_info11;
hr_utility.set_location('Etext41 l_assignment_number'||l_assignment_number,111);

l_date_of_birth := p_tab_rec_data(0).act_info15;
hr_utility.set_location('Etext41 l_date_of_birth'||l_date_of_birth,111);
l_tax_code_in_use := p_tab_rec_data(0).act_info21;
l_tax_basis_in_use := p_tab_rec_data(0).act_info22;
hr_utility.set_location('Etext42'||l_tax_basis_in_use,111);

l_p46_expat_eea_citizen := p_tab_rec_data(2).act_info4;
l_p46_expat_start_empl_date := p_tab_rec_data(2).act_info5;
l_p46_expat_statement := p_tab_rec_data(2).act_info2;

hr_utility.set_location('Etext43'||l_p46_expat_statement,111);

IF l_p46_expat_eea_citizen = 'Y' AND (l_tax_code_in_use = ' ' OR l_tax_code_in_use IS NULL) THEN
    populate_run_msg(p_assactid,'You have not entered a tax code for the EEA Citizen ' || l_assignment_number || '. Ensure you enter Emergency Tax Code on a Cumulative Basis.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : You have not entered a tax code for the EEA Citizen ' || l_assignment_number || '. Ensure you enter Emergency Tax Code on a Cumulative Basis.');
    edi_validation_fail := 'Y';
END IF;

IF l_p46_expat_eea_citizen = 'Y' and (l_tax_code_in_use <> ' ' OR l_tax_code_in_use IS NOT NULL) and l_tax_basis_in_use = 'N' THEN
    populate_run_msg(p_assactid,' The tax basis cannot be Week1/Month1 for an EEA Citizen ' || l_assignment_number || ' .');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The tax basis cannot be Week1/Month1 for an EEA Citizen ' || l_assignment_number || ' .');
    edi_validation_fail := 'Y';
END IF;

IF l_p46_expat_start_empl_date = ' ' OR l_p46_expat_start_empl_date IS NULL THEN
    populate_run_msg(p_assactid,' The start date of employment in UK (P46EXPAT) for the assignment ' || l_assignment_number || ' is blank. Enter a valid start date.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The start date of employment in UK (P46EXPAT) for the assignment ' || l_assignment_number || ' is blank. Enter a valid start date.');
    edi_validation_fail := 'Y';
ELSIF PAY_GB_MOVDED_EDI.date_validate(p_assactid,'UK_EMPL_DATE',to_date(l_p46_expat_start_empl_date,'YYYY/MM/DD HH24:MI:SS')) = 0 THEN
    populate_run_msg(p_assactid,' The start date of employment in UK (P46EXPAT) for the assignment ' || l_assignment_number || ' is invalid.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The start date of employment in UK (P46EXPAT) for the assignment ' || l_assignment_number || ' is blank. Enter a valid start date.');
    edi_validation_fail := 'Y';
END IF;

IF l_tax_code_in_use = ' ' OR l_tax_code_in_use IS NULL THEN
    populate_run_msg(p_assactid,' The Tax Code in use of the assignment ' || l_assignment_number || ' is missing.');
    fnd_file.put_line (fnd_file.LOG,l_assignment_number||' : The Tax Code in use of the assignment ' || l_assignment_number || ' is missing.');
    edi_validation_fail := 'Y';
END IF;

IF ((l_assignment_number <> ' ' OR l_assignment_number IS NOT NULL)
   and pay_gb_eoy_magtape.validate_input(l_assignment_number,'P14_FULL_EDI') > 0) THEN
    populate_run_msg(p_assactid,' Assignment Number has invalid character(s).' || l_assignment_number);
    fnd_file.put_line (fnd_file.LOG,' : The Assignment Number has invalid character(s). ' || l_assignment_number);
    edi_validation_fail := 'Y';
END IF;

IF ((l_sex <> 'M' AND l_sex <> 'F') OR (l_sex = ' ' OR l_sex IS NULL)) THEN
    populate_run_msg(p_assactid,' Sex is undefined for the assignment.' || l_assignment_number);
    fnd_file.put_line (fnd_file.LOG,' : The sex ' || l_sex || ' is undefined for the assignment' || l_assignment_number);
    edi_validation_fail := 'Y';
END IF;

IF l_date_of_birth = ' ' OR l_date_of_birth IS NULL THEN
		hr_utility.set_location('Etext43 l_date_of_birth'||l_date_of_birth,111);
    populate_run_msg(p_assactid,' The Date of Birth of the assignment ' || l_assignment_number || ' is missing.');
    fnd_file.put_line (fnd_file.LOG,' : The Date of Birth of the assignment '|| l_assignment_number || ' is missing.');
    edi_validation_fail := 'Y';
END IF;

IF l_p46_expat_statement = ' ' OR l_p46_expat_statement IS NULL OR (l_p46_expat_statement <> 'A' AND l_p46_expat_statement <> 'B' AND l_p46_expat_statement <> 'C') THEN
    populate_run_msg(p_assactid,' P46EXPAT statement for the assignment ' || l_assignment_number || ' is invalid. The P46EXPAT statement must be A, B or C.');
    fnd_file.put_line (fnd_file.LOG,' : P46EXPAT statement for the assignment ' || l_assignment_number || ' is invalid. The P46EXPAT statement must be A, B or C.');
    edi_validation_fail := 'Y';
END IF;

     OPEN get_effective_date;
         FETCH get_effective_date
         INTO l_eff_date;
     CLOSE get_effective_date;

l_eff_date := to_date(to_char(to_date(l_eff_date,'RRRR/MM/DD HH24:MI:SS'),'RRRR/MM/DD'),'RRRR/MM/DD');
l_msg_value := pay_gb_eoy_magtape.validate_tax_code_yrfil(p_assactid,l_tax_code_in_use,l_eff_date);

IF (l_tax_code_in_use <> ' ' OR l_tax_code_in_use IS NOT NULL)
    AND (l_msg_value <> ' ') THEN
    populate_run_msg(p_assactid, l_msg_value || 'tax code, ' || l_tax_code_in_use || ', for assignment ' || l_assignment_number);
    fnd_file.put_line (fnd_file.LOG,' : The ' || l_msg_value || ':tax code, ' || l_tax_code_in_use || ', for assignment ' || l_assignment_number);
    edi_validation_fail := 'Y';
END IF;


IF (l_tax_code_in_use <>' ' OR l_tax_code_in_use IS NOT NULL) AND (l_tax_basis_in_use = ' ' OR l_tax_basis_in_use IS NULL)THEN
    populate_run_msg(p_assactid, 'The Tax Basis in use is not present for Tax code in use, for assignment ' || l_assignment_number);
    fnd_file.put_line (fnd_file.LOG,' : The Tax Basis in use is not present for Tax code in use, for assignment ' || l_assignment_number);
    edi_validation_fail := 'Y';
END IF;
hr_utility.set_location('Etext44 Leaving',111);

END p46exp_asg_etext_validations;

--For bugs 9255173 and 9255183
--This procedure implements validations of formula PAY_GB_EDI_MOVDED6_ASG
PROCEDURE movded6_asg_etext_validations(p_assactid       IN NUMBER,
                                        p_effective_date IN DATE,
                                        p_tab_rec_data   IN action_info_table,
                                        edi_validation_fail out nocopy  varchar2) IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'p46exp_asg_etext_validations';
     l_ovn       number;
     l_action_id number;
     --edi_validation_fail varchar2(50);


l_national_insurance_number per_people_f.national_identifier%TYPE;
l_assignment_number per_assignments_f.assignment_number%TYPE;
l_address_line1 per_addresses.address_line1%TYPE;
l_address_line2 per_addresses.address_line2%TYPE;
l_address_line3 per_addresses.address_line3%TYPE;
l_town_or_city per_addresses.town_or_city%TYPE;
l_county per_addresses.region_1%TYPE;
l_postal_code per_addresses.postal_code%TYPE;
l_last_name per_people_f.last_name%TYPE;
l_first_name per_people_f.first_name%TYPE;
l_middle_name per_people_f.middle_names%TYPE;
l_title per_people_f.title%TYPE;
l_job_title varchar(100);
l_tax_code varchar(100);
l_assignment_id number;
l_national_identifier per_people_f.national_identifier%TYPE;

l_session_date date;
l_count_char_errors number;
l_count_missing_val number;

BEGIN
hr_utility.set_location('Etext50',111);

l_count_char_errors := 0;
l_count_missing_val := 0;

l_national_insurance_number := p_tab_rec_data(0).act_info12;
l_assignment_number := p_tab_rec_data(0).act_info11;
l_address_line1 := p_tab_rec_data(1).act_info5;
l_address_line2 := p_tab_rec_data(1).act_info6;
l_address_line3 := p_tab_rec_data(1).act_info7;
l_town_or_city := p_tab_rec_data(1).act_info8;
l_county := p_tab_rec_data(1).act_info9;
l_postal_code := p_tab_rec_data(1).act_info12;
l_last_name := p_tab_rec_data(0).act_info8;
l_first_name := p_tab_rec_data(0).act_info6;
l_middle_name := p_tab_rec_data(0).act_info7;
l_title := p_tab_rec_data(0).act_info14;
l_job_title := p_tab_rec_data(0).act_info18;
l_tax_code := p_tab_rec_data(0).act_info21;
l_national_identifier := p_tab_rec_data(0).act_info12;

l_assignment_id := p_tab_rec_data(0).assignment_id;

IF l_national_insurance_number  <> ' ' THEN

l_session_date := HR_GBNICAR.NICAR_SESSION_DATE(0);
    IF hr_gb_utility.ni_validate(l_national_insurance_number,l_session_date)<>0 THEN
    populate_run_msg(p_assactid,'The National Insurance Number ' || l_national_insurance_number || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The National Insurance Number ' || l_national_insurance_number || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

IF l_address_line1 = ' ' OR l_address_line1 IS NULL THEN
    populate_run_msg(p_assactid,'The Address Line 1 of the assignment ' || l_assignment_number || ' is missing.');
    fnd_file.put_line (fnd_file.LOG,' : The Address Line 1 of the assignment ' || l_assignment_number || ' is missing.');
    edi_validation_fail := 'Y';
    l_count_missing_val := l_count_missing_val + 1;
ELSIF pay_gb_eoy_magtape.validate_input(l_address_line1,'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Address Line 1 ' || l_address_line1 || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Address Line 1 ' || l_address_line1 || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
END IF;

IF l_address_line2 = ' ' OR l_address_line2 IS NULL THEN
    populate_run_msg(p_assactid,'The Address Line 2 of the assignment ' || l_assignment_number || ' is missing.');
    fnd_file.put_line (fnd_file.LOG,' : The Address Line 2 of the assignment ' || l_assignment_number || ' is missing.');
    edi_validation_fail := 'Y';
    l_count_missing_val := l_count_missing_val + 1;
ELSIF pay_gb_eoy_magtape.validate_input(l_address_line2,'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Address Line 2 ' || l_address_line2 || ' of the assignment '|| l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Address Line 2 ' || l_address_line2 || ' of the assignment '|| l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
END IF;

IF l_address_line3 <> ' ' OR l_address_line3 IS NOT NULL THEN
    IF pay_gb_eoy_magtape.validate_input(l_address_line3,'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Address Line 3 ' || l_address_line3 || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Address Line 3 ' || l_address_line3 || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

IF l_town_or_city <> ' ' OR l_town_or_city IS NOT NULL THEN
    IF pay_gb_eoy_magtape.validate_input(l_town_or_city,'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Town Or City ' || l_town_or_city || ' of the assignment '|| l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Town Or City ' || l_town_or_city ||' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

IF l_county <> ' ' OR l_county IS NOT NULL THEN
    IF pay_gb_eoy_magtape.validate_input(l_county,'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The County ' || l_county || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The County ' || l_county || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

IF l_last_name = ' ' OR per_formula_functions.isnull(l_last_name)='Y' THEN
    populate_run_msg(p_assactid,'The Last Name of the assignment ' || l_assignment_number || ' is missing.');
    fnd_file.put_line (fnd_file.LOG,' : The Last Name of the assignment '||  l_assignment_number || ' is missing.');
    edi_validation_fail := 'Y';
    l_count_missing_val := l_count_missing_val + 1;
elsif pay_gb_eoy_magtape.validate_input(l_last_name,'P45_46_LAST_NAME') > 0 then
    populate_run_msg(p_assactid,'The Last Name ' || l_last_name || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Last Name ' + l_last_name || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
END IF;

IF l_first_name = ' ' OR per_formula_functions.isnull(l_first_name)='Y' THEN
    populate_run_msg(p_assactid,'The First Name of the assignment '||  l_assignment_number || ' is missing.');
    fnd_file.put_line (fnd_file.LOG,' : The First Name of the assignment ' || l_assignment_number || ' is missing.');
    edi_validation_fail := 'Y';
    l_count_missing_val := l_count_missing_val + 1;

ELSIF pay_gb_eoy_magtape.validate_input(l_first_name,'P45_46_FIRST_NAME') > 0 THEN
    populate_run_msg(p_assactid,'The First Name ' || l_first_name ||' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The First Name ' || l_first_name || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
END IF;

IF l_middle_name <> ' ' AND per_formula_functions.isnull(l_middle_name)<>'Y' THEN
  IF pay_gb_eoy_magtape.validate_input(l_middle_name,'P45_46_FIRST_NAME') > 0 THEN
    populate_run_msg(p_assactid,'The Middle Name ' || l_middle_name || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Middle Name ' || l_middle_name || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
  END IF;
END IF;

IF l_title <> ' ' AND per_formula_functions.isnull(l_title)<>'Y' THEN
    IF pay_gb_eoy_magtape.validate_input(l_title,'P45_46_TITLE') > 0 THEN
    populate_run_msg(p_assactid,'The Title ' || l_title || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Title ' || l_title || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

IF l_postal_code <> ' ' OR l_postal_code IS NOT NULL THEN
    IF pay_gb_eoy_magtape.validate_input(l_postal_code,'P45_46_POSTCODE') > 0 THEN
    populate_run_msg(p_assactid,'The Postal Code ' || l_postal_code || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Postal Code ' || l_postal_code || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

-- below validations are from fetch_person_rec
IF l_assignment_number <> ' ' OR l_assignment_number IS NOT NULL THEN
    IF pay_gb_eoy_magtape.validate_input(upper(l_assignment_number),'FULL_EDI') > 0 THEN  --Added 'upper' to fix the bug 9503248
    populate_run_msg(p_assactid,'The Assignment Number ' || l_assignment_number || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Assignment Number ' || l_assignment_number || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
    l_count_char_errors := l_count_char_errors + 1;
    END IF;
END IF;

IF l_job_title <> ' ' OR l_job_title IS NOT NULL THEN
IF pay_gb_eoy_magtape.validate_input(l_job_title,'P14_FULL_EDI') > 0 THEN
    populate_run_msg(p_assactid,'The Job Title ' || l_job_title || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Job Title ' || l_job_title || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;
END IF;

IF l_national_identifier is not null AND
    hr_gb_utility.ni_validate(l_national_identifier,sysdate) <> 0 THEN
    populate_run_msg(p_assactid,'The National Identifier ' || l_national_identifier || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The National Identifier ' || l_national_identifier || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

IF (hr_gb_utility.tax_code_validate(l_tax_code,sysdate,l_assignment_id) <> ' ') THEN
    populate_run_msg(p_assactid,'The Tax Code ' || l_tax_code || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    fnd_file.put_line (fnd_file.LOG,' : The Tax Code ' || l_tax_code || ' of the assignment ' || l_assignment_number || ' has invalid character(s).');
    edi_validation_fail := 'Y';
END IF;

hr_utility.set_location('Etext50 Leaving',111);
END movded6_asg_etext_validations;


FUNCTION fetch_p46_5_rec(p_effective_date IN  DATE,
                       p_tax_rec      IN  g_tax_rec,
                       p_person_rec   IN  act_info_rec,
                       p_p46_rec      OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_p46_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_arch           boolean;
     l_temp           varchar2(50);
     l_def_archive    varchar2(2);
     l_exist          number;

     cursor csr_p46_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 send_edi,
            aei.aei_information2 p46_statement,
            aei.aei_information3 static_flag,
            aei.aei_information4 student_loan,
            aei.aei_information5 default_send_edi,
            aei.aei_information6 default_static_edi,
            aei.object_version_number
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_person_rec.assignment_id
     and    aei.information_type = 'GB_P46';

     cursor csr_p46_5_def_det
     is
     select 1
     from pay_action_information pa
         ,pay_payroll_actions    ppa
         ,pay_assignment_actions paa
     where  pa.action_information_category = 'GB P46_5 EDI'
     and    pa.action_context_type = 'AAP'
     and    pa.action_information4  = 'Y'
     and    pa.assignment_id       = p_person_rec.assignment_id
     and    paa.assignment_action_id = pa.action_context_id
     and    ppa.payroll_action_id    = paa.payroll_action_id
     and    ppa.action_status       = 'C';


     l_p46_rec  csr_p46_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     fnd_file.put_line(fnd_file.LOG,'Entering: '||l_proc);
     l_arch := true;

     open csr_p46_details;
     fetch csr_p46_details into l_p46_rec;
     close csr_p46_details;
     l_def_archive := 'N';

     if l_p46_rec.default_send_edi = 'Y' then
       l_def_archive := 'Y';
     else
       if l_p46_rec.default_send_edi = 'N' and l_p46_rec.default_static_edi = 'Y' then
         open csr_p46_5_def_det;
         fetch csr_p46_5_def_det into l_exist;
         if csr_p46_5_def_det%found then
           l_def_archive := 'N';
         else
           l_def_archive := 'Y';
         end if;
         close csr_p46_5_def_det;
       /*else
         l_def_archive := 'N';*/
       end if;
     end if;

    /* if not validate_data(l_p46_rec.p46_statement,'P46 Statement','FULL_EDI')  then
        l_arch := false;
        hr_utility.set_location('P46 Statement validation',10);
     end if;

     l_temp := hr_gb_utility.tax_code_validate(p_tax_rec.tax_code,sysdate,p_person_rec.assignment_id);
     if l_temp <> ' ' then
        pay_core_utils.push_message(800, 'HR_78057_GB_MAGTAPE_VAILDATION', 'F');
        pay_core_utils.push_token('INPUT_NAME', 'Tax Code');
        pay_core_utils.push_token('INPUT_VALUE', p_tax_rec.tax_code);
        l_arch := false;
        hr_utility.set_location('Tax Code error',20);
     end if;*/

     l_ovn := l_p46_rec.object_version_number;
     if l_arch then
        hr_utility.set_location('Clear Flag',30);
        if l_def_archive = 'N' then
          hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_p46_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P46',
               p_aei_information1               => 'N');
        else
          hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_p46_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P46',
               p_aei_information5               => 'N');

        end if;
     end if;

     p_p46_rec.assignment_id := p_person_rec.assignment_id;
     p_p46_rec.effective_date := p_effective_date;
     p_p46_rec.action_info_category := 'GB P46_5 EDI';
     p_p46_rec.act_info1 := l_ovn;
     p_p46_rec.act_info2 := l_p46_rec.p46_statement;
     p_p46_rec.act_info3 := l_p46_rec.student_loan;
     p_p46_rec.act_info4 := l_def_archive;
     hr_utility.set_location('Leaving: '||l_proc,999);
     fnd_file.put_line(fnd_file.LOG,'Leaving: '||l_proc);
     return l_arch;
END fetch_p46_5_rec;
--
FUNCTION fetch_p46p_rec(p_effective_date IN  DATE,
                        p_tax_rec        IN  g_tax_rec,
                        p_person_rec     IN  act_info_rec,
                        p_p46p_rec       OUT nocopy act_info_rec) return boolean IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'fetch_p46p_rec';
     l_assignment_id  number;
     l_ovn            number;
     l_arch           boolean;

     cursor csr_p46p_details is
     select aei.assignment_extra_info_id,
            aei.aei_information1 send_edi,
            aei.aei_information2 annual_pension,
            aei.aei_information3 date_pension_start,
            aei.aei_information4 static_flag,
            aei.object_version_number
     from   per_assignment_extra_info aei
     where  aei.assignment_id = p_person_rec.assignment_id
     and    aei.information_type = 'GB_P46PENNOT';

     l_p46p_rec  csr_p46p_details%rowtype;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     l_arch := true;

     open csr_p46p_details;
     fetch csr_p46p_details into l_p46p_rec;
     close csr_p46p_details;

     if not validate_data(l_p46p_rec.annual_pension,'Annual Pension','FULL_EDI')  then
        l_arch := false;
        hr_utility.set_location('Annaul Pension',10);
     end if;

     if length(ltrim(p_tax_rec.tax_code,'S')) > 6 then
        l_arch := false;
        pay_core_utils.push_message(801, 'PAY_78034_VALUE_EXCEEDS_MAX', 'F');
        pay_core_utils.push_token('ITEM_NAME', 'Tax Code');
        pay_core_utils.push_token('MAX_VALUE', '6 characters');
        hr_utility.set_location('Tax Code error',20);
     end if;

     l_ovn := l_p46p_rec.object_version_number;
     if l_arch then
        hr_utility.set_location('Clear Flag',20);
        hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
               p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_p46p_rec.assignment_extra_info_id,
               p_aei_information_category       => 'GB_P46PENNOT',
               p_aei_information1               => 'N');
     end if;

     p_p46p_rec.assignment_id := p_person_rec.assignment_id;
     p_p46p_rec.effective_date := p_effective_date;
     p_p46p_rec.action_info_category := 'GB P46 Pension EDI';
     p_p46p_rec.act_info1 := l_ovn;
     p_p46p_rec.act_info2 := l_p46p_rec.annual_pension;
     p_p46p_rec.act_info3 := l_p46p_rec.date_pension_start;

     hr_utility.set_location('Leaving: '||l_proc,999);
     return l_arch;
END fetch_p46p_rec;
--
--
PROCEDURE insert_archive_row(p_assactid       IN NUMBER,
                             p_effective_date IN DATE,
                             p_tab_rec_data   IN action_info_table) IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'insert_archive_row';
     l_ovn       number;
     l_action_id number;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);
     if p_tab_rec_data.count > 0 then
        for i in p_tab_rec_data.first .. p_tab_rec_data.last loop
            hr_utility.trace('Defining category '|| p_tab_rec_data(i).action_info_category);
            hr_utility.trace('action_context_id = '|| p_assactid);
            if p_tab_rec_data(i).action_info_category is not null then
               pay_action_information_api.create_action_information(
                p_action_information_id => l_action_id,
                p_object_version_number => l_ovn,
                p_action_information_category => p_tab_rec_data(i).action_info_category,
                p_action_context_id    => p_assactid,
                p_action_context_type  => 'AAP',
                p_assignment_id        => p_tab_rec_data(i).assignment_id,
                p_effective_date       => p_effective_date,
                p_action_information1  => p_tab_rec_data(i).act_info1,
                p_action_information2  => p_tab_rec_data(i).act_info2,
                p_action_information3  => p_tab_rec_data(i).act_info3,
                p_action_information4  => p_tab_rec_data(i).act_info4,
                p_action_information5  => p_tab_rec_data(i).act_info5,
                p_action_information6  => p_tab_rec_data(i).act_info6,
                p_action_information7  => p_tab_rec_data(i).act_info7,
                p_action_information8  => p_tab_rec_data(i).act_info8,
                p_action_information9  => p_tab_rec_data(i).act_info9,
                p_action_information10 => p_tab_rec_data(i).act_info10,
                p_action_information11 => p_tab_rec_data(i).act_info11,
                p_action_information12 => p_tab_rec_data(i).act_info12,
                p_action_information13 => p_tab_rec_data(i).act_info13,
                p_action_information14 => p_tab_rec_data(i).act_info14,
                p_action_information15 => p_tab_rec_data(i).act_info15,
                p_action_information16 => p_tab_rec_data(i).act_info16,
                p_action_information17 => p_tab_rec_data(i).act_info17,
                p_action_information18 => p_tab_rec_data(i).act_info18,
                p_action_information19 => p_tab_rec_data(i).act_info19,
                p_action_information20 => p_tab_rec_data(i).act_info20,
                p_action_information21 => p_tab_rec_data(i).act_info21,
                p_action_information22 => p_tab_rec_data(i).act_info22,
                p_action_information23 => p_tab_rec_data(i).act_info23,
                p_action_information24 => p_tab_rec_data(i).act_info24,
                p_action_information25 => p_tab_rec_data(i).act_info25,
                p_action_information26 => p_tab_rec_data(i).act_info26,
                p_action_information27 => p_tab_rec_data(i).act_info27,
                p_action_information28 => p_tab_rec_data(i).act_info28,
                p_action_information29 => p_tab_rec_data(i).act_info29,
                p_action_information30 => p_tab_rec_data(i).act_info30
                );
            end if;
        end loop;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
END insert_archive_row;
--
--
/*------------ PUBLIC PROCEDURE --------------*/
--
--
function edi_errors_log(assignment_number  IN   varchar2,
                          ni_number        IN   varchar2,
                          first_name       IN   varchar2,
                          last_name        IN   varchar2,
                          middle_name      IN   varchar2,
                          title            IN   varchar2,
                          status           IN   varchar2)
RETURN NUMBER
IS
i NUMBER;
BEGIN
i := g_edi_errors_table.count + 1;
g_edi_errors_table(i).assignment_number := assignment_number;
g_edi_errors_table(i).ni_number := ni_number;
g_edi_errors_table(i).first_name := first_name;
g_edi_errors_table(i).last_name := last_name;
g_edi_errors_table(i).middle_name := middle_name;
g_edi_errors_table(i).title := title;
g_edi_errors_table(i).status := status;

Return 0;
END;

--For bug 9255173
--This function implements validations of fast formula PAY_GB_EDI_MOVDED6_TAX_DIST
--It would be called only for eText reports
FUNCTION tax_dist_etext_vals(p_tst_indi  in varchar2,
                             p_tst_id  in varchar2,
                             p_tax_ref  in varchar2,
                             p_employer_name in varchar2)
Return BOOLEAN
IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'tax_dist_etext_vals';
     l_tax_dist_no    VARCHAR2(5);
     l_tax_dist_ref   VARCHAR2(15);
     l_err            BOOLEAN := False;

BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);

     l_tax_dist_no := substr(p_tax_ref,1,3);
     l_tax_dist_ref := substr(ltrim(substr(p_tax_ref,4,11),'/'),1,10);

     hr_utility.set_location('l_tax_dist_no: '||l_tax_dist_no,1);
     hr_utility.set_location('l_tax_dist_ref: '||l_tax_dist_ref,1);

     --Tax Reference validations
     IF l_tax_dist_no is null
     THEN
         l_err := TRUE;
         hr_utility.set_location('The HMRC Office Number is missing.',10);
         fnd_file.put_line(fnd_file.output,'The HMRC Office Number is missing.');
     END IF;


     IF l_tax_dist_ref is null
     THEN
         l_err := TRUE;
         hr_utility.set_location('The employer''s PAYE Reference is missing.',10);
         fnd_file.put_line(fnd_file.output,'The employer''s PAYE Reference is missing.');

     ELSIF pay_gb_eoy_magtape.validate_input(l_tax_dist_ref,'P14_FULL_EDI') > 0
     THEN
         l_err := TRUE;
         hr_utility.set_location('The employer''s PAYE Reference contains invalid characters.',10);
         fnd_file.put_line(fnd_file.output,'The employer''s PAYE Reference contains invalid characters.');
     END IF;

   --Employer name validations
     IF p_employer_name IS NULL
     THEN
         l_err := TRUE;
         hr_utility.set_location('The employer''s name is missing for employer''s PAYE Reference '||p_tax_ref,10);
         fnd_file.put_line(fnd_file.output,'The employer''s name is missing for employer''s PAYE Reference '||p_tax_ref);

     ELSIF pay_gb_eoy_magtape.validate_input(p_employer_name,'P14_FULL_EDI') > 0
     THEN
         l_err := TRUE;
         hr_utility.set_location('The employer''s name '||p_employer_name||' contains invalid character(s) for the employer''s PAYE Reference '||p_tax_ref,10);
         fnd_file.put_line(fnd_file.output,'The employer''s name '||p_employer_name||' contains invalid character(s) for the employer''s PAYE Reference '||p_tax_ref);
     END IF;

   --Test Indicator validations
     IF p_tst_indi = 'Y'
     THEN
         IF pay_gb_eoy_magtape.validate_input(p_tst_id,'MIXED_CHAR_ALPHA_NUM') > 0
         THEN
              l_err := TRUE;
              hr_utility.set_location('The Test ID '||p_tst_id||' contains invalid character(s).',10);
              fnd_file.put_line(fnd_file.output,'The Test ID '||p_tst_id||' contains invalid character(s).');
         END IF;
     END IF;

     hr_utility.set_location('Leaving: '||l_proc,999);
     RETURN l_err;

END tax_dist_etext_vals;

PROCEDURE archinit(p_payroll_action_id IN NUMBER)
IS
     l_proc      CONSTANT VARCHAR2(50) := g_package || ' archinit';

/*Start Modifications for bug 7633799 fix*/
/*   l_sender_id     VARCHAR2(30);
     l_tax_ref       VARCHAR2(30);
     l_tax_dist      VARCHAR2(30);*/
     l_sender_id     hr_organization_information.org_information11%TYPE;
     l_tax_ref       hr_organization_information.org_information1%TYPE;
     l_tax_dist      hr_organization_information.org_information2%TYPE;
/*End Modifications for bug 7633799 fix*/

     l_employer_addr VARCHAR2(255);
     l_employer_name VARCHAR2(150);
     l_err           BOOLEAN;
     l_exp           EXCEPTION;

     cursor csr_sender_id is
     select upper(hoi.org_information11),
            upper(hoi.org_information1),
            upper(hoi.org_information2),
            upper(hoi.org_information3),
            upper(hoi.org_information4)
     from   pay_payroll_actions pact,
            hr_organization_information hoi
     where  pact.payroll_action_id = p_payroll_action_id
     and    pact.business_group_id = hoi.organization_id
     and    hoi.org_information_context = 'Tax Details References'
     and    (hoi.org_information10 is null
             OR
             hoi.org_information10 = 'UK')
     and    upper(hoi.org_information1) =
            upper(substr(pact.legislative_parameters,
                   instr(pact.legislative_parameters,'TAX_REF=') + 8,
                   instr(pact.legislative_parameters||' ',' ',
                   instr(pact.legislative_parameters,'TAX_REF=')+8)
                 - instr(pact.legislative_parameters,'TAX_REF=') - 8));

--For bugs 9255173 and 9255183
     Cursor csr_cp_info
     IS
       SELECT substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                             'TEST'),1,1) test_indicator,
              trim(substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TEST_ID'),1,8)) test_id,
              report_type
       FROM  pay_payroll_actions
       WHERE payroll_action_id = p_payroll_action_id;

     l_tst_indi           varchar2(1);
     l_tst_id             varchar2(10);
     l_rep_typ            varchar2(15);

BEGIN
     hr_utility.set_location('Entering '|| l_proc, 10);
     l_err := FALSE;

     open csr_sender_id;
     fetch csr_sender_id into l_sender_id, l_tax_ref, l_tax_dist, l_employer_name, l_employer_addr;
     close csr_sender_id;

   --For bugs 9255173 and 9255183
   --header validations
     hr_utility.set_location('l_sender_id '|| l_sender_id, 10);

     OPEN csr_cp_info;
     FETCH csr_cp_info into l_tst_indi,l_tst_id,l_rep_typ;
     CLOSE csr_cp_info;

     hr_utility.set_location('l_tst_indi '|| l_tst_indi, 10);
     hr_utility.set_location('l_tst_id '|| l_tst_id, 10);
     hr_utility.set_location('l_rep_typ '|| l_rep_typ, 10);
     hr_utility.set_location('l_tax_ref: '||l_tax_ref,1);
     hr_utility.set_location('l_employer_name: '||l_employer_name,1);

     IF l_rep_typ in ('P46_VER6ET','P46EXP_VER6ET')
     THEN
         hr_utility.set_location('Call header validations', 10);
         l_err := tax_dist_etext_vals(l_tst_indi,
                                      l_tst_id,
                                      l_tax_ref,
                                      l_employer_name);

     END IF;

     if l_sender_id is null then
        pay_core_utils.push_message(800, 'HR_78087_EDI_SENDER_ID_MISSING', 'F');
        pay_core_utils.push_token('TAX_REF', l_tax_ref);
        l_err := true;
     else
        if (not validate_data(l_sender_id,'Sender ID','FULL_EDI')) then
           l_err := true;
        end if;
     end if;

     if pay_gb_eoy_magtape.validate_input(substr(l_tax_ref,1,3),'NUMBER') > 0
	    OR
	      pay_gb_eoy_magtape.validate_input(l_tax_ref,'FULL_EDI') > 0  then
        pay_core_utils.push_message(800, 'HR_GB_78049_INV_EMP_PAYE_REF', 'F');
        l_err := true;
     end if;

     if (not validate_data(l_tax_dist,'IR Office Name ','FULL_EDI'))  then
        l_err := true;
     end if;

     if (not validate_data(l_employer_name,'Employers Name','FULL_EDI')) then
        l_err := true;
     end if;

     if (not validate_data(l_employer_addr,'Employers Address','P14_FULL_EDI')) then
        l_err := true;
     end if;

     if (l_err) then
          raise l_exp;
     end if;
      hr_utility.set_location('Leaving '|| l_proc, 10);
EXCEPTION
     when others then
          hr_utility.raise_error;
END archinit;
--
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT NOCOPY VARCHAR2)
IS
     /* Changes for P45PT3 start*/
     cursor csr_parameter_info IS
     SELECT
          substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TEST'),1,1) test_indicator,
          trim(substr(pay_gb_eoy_archive.get_parameter(legislative_parameters,
                                            'TEST_ID'),1,8)) test_id,
          report_type
     FROM  pay_payroll_actions
     WHERE payroll_action_id = pactid;


     l_test_indicator     varchar2(1);
     l_test_id            varchar2(8);
     l_report_type        varchar2(15);
     test_indicator_error  EXCEPTION;
     /* Changes for P45PT3 end*/
     l_proc CONSTANT VARCHAR2(35):= g_package||'range_cursor';
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);

     /* Changes for P45PT3 start*/
     OPEN csr_parameter_info;
     fetch csr_parameter_info into l_test_indicator,l_test_id,l_report_type;
     CLOSE csr_parameter_info ;
    /* changes for P46_ver6_pennot starts **/
     IF l_report_type = 'P45PT_3' or l_report_type='P46_5_PENNOT' or
        l_report_type='P46_VER6_PENNOT' or l_report_type='P46_5' or
        l_report_type = 'P45PT_3_VER6' or l_report_type = 'P46_VER6' or
        l_report_type = 'P46EXP_VER6' or l_report_type = 'P46EXP_VER6ET' or
        l_report_type = 'P46_VER6ET' THEN --Bugs 9255173 and 9255183
    /* changes for P46_ver6_pennot ends **/
         IF (l_test_indicator = 'Y' AND l_test_id IS NULL) THEN
            fnd_file.put_line (fnd_file.LOG,'Enter the Test ID as EDI Test Indicator is Yes.');
            RAISE test_indicator_error;
         END IF;
     END IF;
     /* Changes for P45PT3 end*/

     sqlstr := 'select distinct person_id '||
               'from per_people_f ppf, '||
               'pay_payroll_actions ppa '||
               'where ppa.payroll_action_id = :payroll_action_id '||
               'and ppa.business_group_id = ppf.business_group_id '||
               'order by ppf.person_id';
     hr_utility.trace(' Range Cursor Statement : '||sqlstr);
     hr_utility.set_location(' Leaving: '||l_proc,100);
/* Changes for P45PT3 start*/
EXCEPTION
     WHEN test_indicator_error THEN
            RAISE;  -- reraise the error
/* Changes for P45PT3 end*/
END range_cursor;
--
--
PROCEDURE p45_3_action_creation (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P45_3', 'P45_3');
END p45_3_action_creation;
--
--
/*changes for P45PT_3 start*/
PROCEDURE p45pt_3_action_creation (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P45_3', 'P45PT_3');
END p45pt_3_action_creation;
/*changes for P45PT_3 end*/

/*changes for P45PT_3_ver6 start*/
PROCEDURE  p45pt_3_ver6_action_creation(pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P45_3', 'P45PT_3_VER6');
END p45pt_3_ver6_action_creation;
/*changes for P45PT_3_ver6 end*/
--
--
PROCEDURE p46_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46', 'P46');
END p46_action_creation;
--
/*** Changes for P46 EOY *****/
PROCEDURE p46_5_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46', 'P46_5');
END p46_5_action_creation;
/*** End ***/
--
--
PROCEDURE p46_ver6_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46', 'P46_VER6');
END p46_ver6_action_creation;

--Added for bug 9255173
PROCEDURE p46_ver6et_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     hr_utility.set_location('Entering:p46_ver6et_action_creation',1);
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46', 'P46_VER6ET');
END p46_ver6et_action_creation;


--Added for bug 9255183
PROCEDURE p46exp_ver6et_action_creation   (pactid    in number,
                                 stperson  in number,
                                 endperson in number,
                                 chunk     in number) IS
BEGIN
     hr_utility.set_location('Entering:p46exp_ver6et_action_creation',1);
     internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46EXP', 'P46EXP_VER6ET');
     hr_utility.set_location('Leaving:p46exp_ver6et_action_creation',1);
END p46exp_ver6et_action_creation;

--
PROCEDURE p46_pennot_action_creation (pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number) IS
BEGIN
    internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46PENNOT', 'P46_PENNOT');
END p46_pennot_action_creation;
--

/**UK EOY07-08 P46 PENNOT --- Corresponds to CP PENNOT EDI Process **/
PROCEDURE p46_5_pennot_action_creation (pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number) IS
BEGIN
    internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46PENNOT', 'P46_5_PENNOT');
END p46_5_pennot_action_creation;

--
/* changes for P46_ver6_pennot starts **/
PROCEDURE P46_VER6_PENNOT_ACT_CREATION (pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number) IS
BEGIN
    internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46PENNOT', 'P46_VER6_PENNOT');
END P46_VER6_PENNOT_ACT_CREATION;
/* changes for P46_ver6_pennot ends **/


	/*Changes for P46EXP_Ver6 starts*/
PROCEDURE P46EXP_VER6_ACTION_CREATION (pactid    in number,
                                     stperson  in number,
                                     endperson in number,
                                     chunk     in number) IS
BEGIN
    internal_action_creation(pactid, stperson, endperson, chunk,'GB_P46EXP', 'P46EXP_VER6');
END P46EXP_VER6_ACTION_CREATION;
	/*Changes for P46EXP_Ver6 End*/

--
--
--
--
--For bug 9255173
--this function implements validations of formula PAY_GB_EDI_P46_6_ASG
FUNCTION p46_v6_asg_etext_vals(p_assactid       IN NUMBER,
                               p_effective_date IN DATE,
                               p_tab_rec_data   IN action_info_table)
Return BOOLEAN
IS
     l_proc  CONSTANT VARCHAR2(50):= g_package||'p46_v6_asg_etext_vals';
     l_err                BOOLEAN := False;

     l_tax_code_in_use    VARCHAR2(50);
     l_assignment_number  per_assignments_f.assignment_number%TYPE;
     l_sex                per_people_f.sex%TYPE;
     l_date_of_birth      VARCHAR2(100);
     l_hire_date          VARCHAR2(100);
     l_tax_basis_in_use   VARCHAR2(50);

     l_default_p46        VARCHAR2(5);
     l_p46_statement      VARCHAR2(5);

     l_msg_value          VARCHAR2(1000);


BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);

     l_tax_code_in_use :=    p_tab_rec_data(0).act_info21;
     l_assignment_number :=  p_tab_rec_data(0).act_info11;
     l_sex :=                p_tab_rec_data(0).act_info17;
     l_date_of_birth :=      p_tab_rec_data(0).act_info15;
     l_hire_date :=          p_tab_rec_data(0).act_info16;
     l_tax_basis_in_use :=   p_tab_rec_data(0).act_info22;

     l_default_p46 :=        p_tab_rec_data(2).act_info4;
     l_p46_statement :=      p_tab_rec_data(2).act_info2;

     hr_utility.set_location('l_tax_code_in_use '||l_tax_code_in_use,111);
     hr_utility.set_location('l_assignment_number '||l_assignment_number,111);
     hr_utility.set_location('l_sex '||l_sex,111);
     hr_utility.set_location('l_date_of_birth '||l_date_of_birth,111);
     hr_utility.set_location('l_hire_date '||l_hire_date,111);
     hr_utility.set_location('l_tax_basis_in_use '||l_tax_basis_in_use,111);
     hr_utility.set_location('l_default_p46 '||l_default_p46,111);
     hr_utility.set_location('l_p46_statement '||l_p46_statement,111);

     --Validations
     IF l_tax_code_in_use IS NULL
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The Tax Code in use of the assignment '||l_assignment_number||' is missing.');
         hr_utility.set_location('The Tax Code in use of the assignment '||l_assignment_number||' is missing.',10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The Tax Code in use of the assignment '||l_assignment_number||' is missing.');
     END IF;

     IF l_assignment_number IS NOT NULL
        AND pay_gb_eoy_magtape.validate_input(l_assignment_number,'P14_FULL_EDI') > 0
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The Assignment Number '||l_assignment_number||' has invalid character(s).');
         hr_utility.set_location('The Assignment Number '||l_assignment_number||' has invalid character(s).',10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The Assignment Number '||l_assignment_number||' has invalid character(s).');
     END IF;

     IF l_sex IS NULL
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The Sex of the assignment '||l_assignment_number||' is missing.');
         hr_utility.set_location('The Sex of the assignment '||l_assignment_number||' is missing.',10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The Sex of the assignment '||l_assignment_number||' is missing.');
     ELSIF l_sex NOT IN ('M', 'F')
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The sex '||l_sex||' is undefined for the assignment'||l_assignment_number);
         hr_utility.set_location('The sex '||l_sex||' is undefined for the assignment'||l_assignment_number,10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The sex '||l_sex||' is undefined for the assignment'||l_assignment_number);
     END IF;

     IF l_date_of_birth IS NULL
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The Date of Birth of the assignment '||l_assignment_number||' is missing.');
         hr_utility.set_location('The Date of Birth of the assignment '||l_assignment_number||' is missing.',10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The Date of Birth of the assignment '||l_assignment_number||' is missing.');
     END IF;

     IF l_default_p46 = 'N' AND l_p46_statement IS NULL
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The assignment, '||l_assignment_number||', does not have a P46 Statement for a Normal P46 Process.');
         hr_utility.set_location('The assignment, '||l_assignment_number||', does not have a P46 Statement for a Normal P46 Process.',10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The assignment, '||l_assignment_number||', does not have a P46 Statement for a Normal P46 Process.');
     END IF;

     IF l_hire_date IS NULL
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The assignment, '||l_assignment_number||', does not have a Hire Date.');
         hr_utility.set_location('The assignment, '||l_assignment_number||', does not have a Hire Date.',10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The assignment, '||l_assignment_number||', does not have a Hire Date.');
     END IF;


     l_msg_value := pay_gb_eoy_magtape.validate_tax_code_yrfil(p_assactid,l_tax_code_in_use,p_effective_date);

     IF l_tax_code_in_use IS NOT NULL
        AND l_msg_value <> ' '
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The '||l_msg_value||':tax code, '||l_tax_code_in_use||', for assignment '||l_assignment_number);
         hr_utility.set_location('The '||l_msg_value||':tax code, '||l_tax_code_in_use||', for assignment '||l_assignment_number,10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The '||l_msg_value||':tax code, '||l_tax_code_in_use||', for assignment '||l_assignment_number);
     END IF;

     IF l_tax_code_in_use IS NOT NULL
        AND l_tax_basis_in_use IS NULL
     THEN
         l_err := TRUE;
         populate_run_msg(p_assactid,'The Tax Basis in use is not present for Tax code in use, for assignment '||l_assignment_number);
         hr_utility.set_location('The Tax Basis in use is not present for Tax code in use, for assignment '||l_assignment_number,10);
         fnd_file.put_line (fnd_file.LOG,l_assignment_number||': The Tax Basis in use is not present for Tax code in use, for assignment '||l_assignment_number);
     END IF;

     hr_utility.set_location('Leaving: '||l_proc,999);
     RETURN l_err;

END p46_v6_asg_etext_vals;

PROCEDURE archive_code(p_assactid       IN NUMBER,
                       p_effective_date IN DATE) IS
     l_proc  CONSTANT VARCHAR2(35):= g_package||'archive_code';
     error_found      EXCEPTION;
     l_archive_tab    action_info_table;
     l_tax_rec        g_tax_rec;
     l_archive_person boolean;
     l_archive_addr   boolean;
     l_archive_data   boolean;
     l_archive_type   VARCHAR2(20);

--For bugs 9255173 and 9255183
     l_p46exp_etext_asg_flag varchar2(1);
     l_movded6_etext_asg_flag varchar2(1);
     l_p46exp_val_err     boolean := False;

     l_p46_val_err       boolean := False;
     l_asg_val_err       boolean := False;
     l_err_log           number;

     l_assignment_number          VARCHAR2(50);
     l_national_insurance_number  VARCHAR2(50);
     l_first_name                 VARCHAR2(50);
     l_last_name                  VARCHAR2(50);
     l_middle_name                VARCHAR2(50);
     l_title                      VARCHAR2(10);

     cursor csr_archive_type is
     select report_type
     from   pay_assignment_actions paa,
            pay_payroll_actions    ppa
     where  paa.assignment_action_id = p_assactid
     and    paa.payroll_action_id = ppa.payroll_action_id;

BEGIN
     hr_utility.trace('\n xxxx Test Indicator='||pay_magtape_generic.get_parameter_value('TEST'));
     --hr_utility.trace_on(null,'TKP');
     fnd_file.put_line(fnd_file.LOG,'Entering: '||l_proc);
     --hr_utility.trace('Tushar effective date is '|| to_char(p_effective_date,'DD-MON-YYYY')  );
     --hr_utility.set_location('Entering: '||l_proc,1);
     open csr_archive_type;
     fetch csr_archive_type into l_archive_type;
     close csr_archive_type;

   --For bugs 9255173 and 9255183
     g_archive_type := l_archive_type;

     fetch_tax_rec(p_assactid,p_effective_date,l_tax_rec);

     hr_utility.set_location('Fetching person details ',10);
     l_archive_person := fetch_person_rec(p_assactid, p_effective_date, l_tax_rec, l_archive_tab(0));

     hr_utility.set_location('Fetching address details ',20);
     l_archive_addr := fetch_address_rec(l_archive_tab(0).person_id,
                                         l_archive_tab(0).assignment_id,
                                         p_effective_date,
                                         l_archive_tab(1));

     hr_utility.set_location('Fetching P45(3) details ',30);
     if l_archive_type = 'P45_3' then
        l_archive_data := fetch_p45_3_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
     /*changes for P45PT_3 start*/
     elsif l_archive_type = 'P45PT_3' then
        l_archive_data := fetch_p45_3_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
     /*changes for P45PT_3 end*/
     /*changes for P45PT_3 Version 6 start*/
     elsif l_archive_type = 'P45PT_3_VER6' then
        l_archive_data := fetch_p45_3_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
     /*changes for P45PT_3 Version 6 end*/
     elsif l_archive_type = 'P46' then
        l_archive_data := fetch_p46_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
     elsif l_archive_type = 'P46_5' then
        l_archive_data := fetch_p46_5_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
     elsif l_archive_type = 'P46_VER6' or l_archive_type = 'P46_VER6ET' then --Added for bug 9255173
        l_archive_data := fetch_p46_5_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
     elsif l_archive_type =  'P46_PENNOT' then
        l_archive_data := fetch_p46p_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
    /**** EOY 07-08 ****/
     elsif l_archive_type =  'P46_5_PENNOT' then
        l_archive_data := fetch_45_46_pennot_rec(p_effective_date,l_tax_rec, l_archive_tab(0),'GB_P46PENNOT',p_assactid,l_archive_tab(2));
     /* changes for P46_ver6_pennot starts **/
     elsif l_archive_type =  'P46_VER6_PENNOT' then
        l_archive_data := fetch_45_46_pennot_rec(p_effective_date,l_tax_rec, l_archive_tab(0),'GB_P46PENNOT',p_assactid,l_archive_tab(2));
    /* changes for P46_ver6_pennot ends **/

	/*Changes for P46EXP_Ver6 starts*/
     elsif l_archive_type = 'P46EXP_VER6' or l_archive_type = 'P46EXP_VER6ET' then --Added for bug 9255183
        l_archive_data := fetch_p46exp_rec(p_effective_date,l_tax_rec, l_archive_tab(0),l_archive_tab(2));
	/*Changes for P46EXP_Ver6 End*/

    END IF;

 --For bugs 9255173 and 9255183
    IF l_archive_type = 'P46_VER6ET' or l_archive_type = 'P46EXP_VER6ET'
    THEN
        movded6_asg_etext_validations(p_assactid, p_effective_date, l_archive_tab, l_movded6_etext_asg_flag);

        IF l_movded6_etext_asg_flag = 'Y' THEN
               l_asg_val_err := TRUE;
        END IF;

        IF l_archive_type = 'P46_VER6ET'
        THEN
             hr_utility.set_location('Call P46 validations', 10);
             l_p46_val_err := p46_v6_asg_etext_vals(p_assactid, p_effective_date, l_archive_tab);

         ELSIF l_archive_type = 'P46EXP_VER6ET'
         THEN
             hr_utility.set_location('Call P46Expat validations', 10);
             p46exp_asg_etext_validations(p_assactid, p_effective_date, l_archive_tab, l_p46exp_etext_asg_flag);

	     IF l_p46exp_etext_asg_flag = 'Y' THEN
                       l_p46exp_val_err := TRUE;
             END IF;

         END IF;

/*    --Section removed as it is not needed with new logic of writing to O/P file
       --Write to error log
         l_assignment_number         := nvl(l_archive_tab(0).act_info11, ' ');
         l_national_insurance_number := nvl(l_archive_tab(0).act_info12,' ');
         l_first_name                := nvl(upper(substr(l_archive_tab(0).act_info6,1,35)),' ');
         l_last_name                 := nvl(upper(substr(l_archive_tab(0).act_info8,1,35)),' ');
         l_middle_name               := nvl(upper(substr(l_archive_tab(0).act_info7,1,35)),' ');
         l_title                     := nvl(substr(l_archive_tab(0).act_info14,1,4),' ');

         hr_utility.set_location('l_assignment_number '||l_assignment_number,111);
         hr_utility.set_location('l_national_insurance_number '||l_national_insurance_number,111);
         hr_utility.set_location('l_first_name '||l_first_name,111);
         hr_utility.set_location('l_last_name '||l_last_name,111);
         hr_utility.set_location('l_middle_name '||l_middle_name,111);
         hr_utility.set_location('l_title '||l_title,111);

	 IF (not l_p46_val_err) AND (not l_asg_val_err) AND (not l_p46exp_val_err)
            AND l_archive_person AND l_archive_addr AND l_archive_data
         THEN
             l_err_log := edi_errors_log(l_assignment_number,l_national_insurance_number,
                                         l_first_name,l_last_name,
                                         l_middle_name,l_title,'C');
         END IF;
*/
    END IF;

     if l_archive_person and l_archive_addr and l_archive_data then
     --For bugs 9255173 and 9255183
        IF l_archive_type = 'P46_VER6ET' OR l_archive_type = 'P46EXP_VER6ET'
        THEN
            IF l_asg_val_err OR l_p46_val_err OR l_p46exp_val_err
            THEN
                 hr_utility.set_location('Validation failed, raise error.',999);
                 fnd_file.put_line(fnd_file.LOG,'Archiving');
                 raise error_found;
            ELSE
                 hr_utility.set_location('Validation successful, archive data.',999);
                 insert_archive_row(p_assactid, p_effective_date, l_archive_tab);
            END IF;
        ELSE
            insert_archive_row(p_assactid, p_effective_date, l_archive_tab);
        END IF;
     else
         fnd_file.put_line(fnd_file.LOG,'Archiving');
         raise error_found;
     end if;

     hr_utility.set_location('Leaving: '||l_proc,999);

EXCEPTION
     when error_found then
          if l_archive_type = 'P45_3' then
             reset_flag('GB_P45_3',p_assactid);
          /* changes for P45PT_3 start */
          elsif l_archive_type = 'P45PT_3' then
             reset_flag('GB_P45_3',p_assactid);
          /* changes for P45PT_3 end */
           /* changes for P45PT_3 Version 6 start */
          elsif l_archive_type = 'P45PT_3_VER6' then
             reset_flag('GB_P45_3',p_assactid);
          /* changes for P45PT_3 Version 6 end */
          elsif l_archive_type = 'P46' then
             reset_flag('GB_P46',p_assactid);
          elsif l_archive_type =  'P46_PENNOT' then
             reset_flag('GB_P46PENNOT',p_assactid);
          elsif l_archive_type =  'P46_5_PENNOT' then
             reset_flag('GB_P46PENNOT',p_assactid);
          /* changes for P46_ver6_pennot starts **/
          elsif l_archive_type =  'P46_VER6_PENNOT' then
             reset_flag('GB_P46PENNOT',p_assactid);
          /* changes for P46_ver6_pennot ends **/
          /*Changes for P46EXP_Ver6 starts*/
	  elsif l_archive_type =  'P46EXP_VER6' then
             reset_flag('GB_P46EXP',p_assactid);
	  /*Changes for P46EXP_Ver6 End*/
          end if;

       --For bugs 9255173 and 9255183
          IF l_archive_type in ('P46EXP_VER6ET','P46_VER6ET')
          THEN
               raise_application_error(-20001,'Error(s) found while archiving data.');
          ELSE
              hr_utility.raise_error;
          END IF;
END archive_code;
--
--
PROCEDURE deinitialization_code(pactid IN NUMBER)
IS
     l_proc  CONSTANT VARCHAR2(50) := g_package || 'deinitialization_code';
     l_counter number;

   --For bugs 9255173 and 9255183
     Cursor csr_is_etext_report IS
     Select report_type
     From pay_payroll_actions pact
     Where pact.payroll_action_id = pactid;

     l_is_etext_report      varchar2(50);
     l_request_id           fnd_concurrent_requests.request_id%TYPE;
     xml_layout             boolean;

     procedure write_header is
         l_token   varchar2(255);
         l_addr1   varchar2(255);
         l_addr2   varchar2(255);
         l_addr3   varchar2(255);
         l_addr4   varchar2(255);
         l_form    varchar2(40);
         l_tax_ref varchar2(20);
         l_urgent  varchar2(2);
         l_test    varchar2(2);
         l_temp    number;

         cursor csr_leg_param is
         select legislative_parameters para,
                fnd_number.number_to_canonical(request_id) control_id,
                report_type,
                business_group_id
         from   pay_payroll_actions
         where  payroll_action_id = pactid;

         cursor csr_header_det(p_bus_id  number,
                               p_tax_ref varchar2) is
         select nvl(hoi.org_information11,' ')       sender_id,
                nvl(upper(hoi.org_information2),' ') hrmc_office,
                nvl(upper(hoi.org_information4),' ') er_addr,
                nvl(upper(hoi.org_information3),' ') er_name
         from   hr_organization_information hoi
         where  hoi.organization_id = p_bus_id
         and    hoi.org_information_context = 'Tax Details References'
         and    nvl(hoi.org_information10,'UK') = 'UK'
         and    upper(hoi.org_information1) = upper(p_tax_ref);

       --For bugs 9255173 and 9255183
         Cursor csr_act_actions
         Is
           Select assignment_action_id
           From pay_assignment_actions paa
           Where paa.payroll_action_id = pactid
           Order by assignment_action_id;

         Cursor messages (p_asg_act_id in number)
         Is
           Select pml.line_text error_text
           From pay_message_lines pml
           Where pml.source_id = p_asg_act_id
           and   pml.MESSAGE_LEVEL = 'F'
           and   pml.line_sequence < (select line_sequence
                                      from pay_message_lines pml1
                                      where pml1.source_id = p_asg_act_id
                                      and   pml1.line_text like 'Error ORA-20001: Error(s) found while archiving data.')
           UNION ALL
           Select pml.line_text error_text
           From pay_message_lines pml
           Where pml.source_id = p_asg_act_id
           and   pml.message_level = 'W';

         l_param csr_leg_param%rowtype;
         l_det   csr_header_det%rowtype;
     begin
         open csr_leg_param;
         fetch csr_leg_param into l_param;
         close csr_leg_param;

         l_token   := 'TAX_REF';
         l_temp    := instr(l_param.para,l_token);
         l_tax_ref := substr(l_param.para, l_temp + length(l_token) + 1,
                      instr(l_param.para||' ',' ',l_temp) - (l_temp + length(l_token) + 1));
         l_token  := 'URGENT';
         l_temp   := instr(l_param.para,l_token);
         l_urgent := substr(l_param.para, l_temp + length(l_token) + 1,
                     instr(l_param.para||' ',' ',l_temp) - (l_temp + length(l_token) + 1));
         l_token := 'TEST';
         l_temp  := instr(l_param.para,l_token);
         l_test  := substr(l_param.para, l_temp + length(l_token) + 1,
                    instr(l_param.para||' ',' ',l_temp) - (l_temp + length(l_token) + 1));

         open csr_header_det(l_param.business_group_id, l_tax_ref);
         fetch csr_header_det into l_det;
         close csr_header_det;

         l_addr1 := l_det.er_addr;
         if length(l_addr1) > 35 then
            l_temp := instr(l_addr1, ',', 34 - length(l_addr1));
            if l_temp = 0 then
               l_temp := 35;
            end if;
            l_addr2 := ltrim(substr(l_addr1, 1 + l_temp),' ,');
            l_addr1 := substr(l_addr1,1,l_temp);
         end if;
         if length(l_addr2) > 35 then
            l_temp := instr(l_addr2, ',', 34 - length(l_addr2));
            if l_temp = 0 then
               l_temp := 35;
            end if;
            l_addr3 := ltrim(substr(l_addr2, 1 + l_temp),' ,');
            l_addr2 := substr(l_addr2,1,l_temp);
         end if;
         if length(l_addr3) > 35 then
            l_temp := instr(l_addr3, ',', 34 - length(l_addr3));
            if l_temp = 0 then
               l_temp := 35;
            end if;
            l_addr3 := ltrim(substr(l_addr3, 1 + l_temp),' ,');
            l_addr4 := substr(l_addr3,1,l_temp);
         end if;


         if l_param.report_type = 'P45_3' then
            l_form := 'P45(3) ( MOVDED 3.0 )';
         /* changes for P45PT_3 start */
         elsif l_param.report_type = 'P45PT_3' then
            l_form := 'P45(3) ( MOVDED 5.0 )';
         /* changes for P45PT_3 end */

         /* changes for P45PT_3 Version 6 start */
         elsif l_param.report_type = 'P45PT_3_VER6' then
            l_form := 'P45(3) ( MOVDED 6.0 )';
         /* changes for P45PT_3 Version 6 end */
         elsif l_param.report_type = 'P46' then
            l_form := 'P46 ( P46 4.0 )';
         elsif l_param.report_type = 'P46_PENNOT' then
            l_form := 'P46 Pension Notification ( MOVDED 3.0 )';
         elsif l_param.report_type = 'P46_5_PENNOT' then
            l_form := 'P46 Pension Notification ( MOVDED 5.0 )';
        /* changes for P46_ver6_pennot starts **/
         elsif l_param.report_type = 'P46_VER6_PENNOT' then
            l_form := 'P46 Pension Notification ( MOVDED 6.0 )';
         /* changes for P46_ver6_pennot ends **/
         elsif l_param.report_type = 'P46_5' then
            l_form := 'P46 ( MOVDED 5.0 )';
	/*Changes for P46EXP_Ver6 starts*/
         elsif l_param.report_type = 'P46EXP_VER6' or l_param.report_type = 'P46EXP_VER6ET' then  --For bug 9255183
            l_form := 'P46Exp ( MOVDED 6.0 )';
	/*Changes for P46EXP_Ver6 End*/
	elsif l_param.report_type = 'P46_VER6' or l_param.report_type = 'P46_VER6ET' then --For bug 9255173
            l_form := 'P46 ( MOVDED 6.0 )'; -- Bug 8830306
	 end if;

       --For bugs 9255173 and 9255183
         IF l_param.report_type = 'P46_VER6ET' or l_param.report_type = 'P46EXP_VER6ET'
         THEN
             fnd_file.put_line(fnd_file.log,'Inside Deinit. Print error msgs');
             FOR act_actions IN csr_act_actions
             LOOP
                 FOR msg_rec IN messages(act_actions.assignment_action_id)
                 LOOP
                     fnd_file.put_line(fnd_file.output,substr(msg_rec.error_text,1,255));
                 END LOOP;
             END LOOP;
         END IF;

         fnd_file.put_line(fnd_file.output,' ');
         fnd_file.put_line(fnd_file.output,'EDI Transmission Report:');
         fnd_file.put_line(fnd_file.output,' ');
         fnd_file.put_line(fnd_file.output,rpad('Form Type : ',32) || l_form );
         fnd_file.put_line(fnd_file.output,rpad('Sender : ',32)    || l_det.sender_id);
         fnd_file.put_line(fnd_file.output,rpad('Date : ',32)      || to_char(sysdate, 'DD/MM/YYYY HH24:MI:SS'));
         fnd_file.put_line(fnd_file.output,rpad('Interchange Control Reference : ',32) || l_param.control_id);
         fnd_file.put_line(fnd_file.output,rpad('Test Transmission : ',32) || l_test);
         fnd_file.put_line(fnd_file.output,rpad('Urgent : ',32)    || l_urgent);
         fnd_file.put_line(fnd_file.output,rpad('-',80,'-'));
         fnd_file.put_line(fnd_file.output,rpad('Employers PAYE Reference : ',32) || l_tax_ref);
         fnd_file.put_line(fnd_file.output,rpad('HRMC Office : ',32)   || l_det.hrmc_office);
         fnd_file.put_line(fnd_file.output,rpad('Employer Name : ',32) || l_det.er_name);
         fnd_file.put_line(fnd_file.output,rpad('Employer Address : ',32) || l_addr1);
         if length(l_addr2) > 0 then
            fnd_file.put_line(fnd_file.output,rpad(' ',32) || l_addr2);
         end if;
         if length(l_addr3) > 0 then
            fnd_file.put_line(fnd_file.output,rpad(' ',32) || l_addr3);
         end if;
         if length(l_addr4) > 0 then
            fnd_file.put_line(fnd_file.output,rpad(' ',32) || l_addr4);
         end if;
     end write_header;

     procedure write_sub_header(p_type varchar2) is
     begin
         fnd_file.put_line(fnd_file.output,null);
         if p_type = 'E' then
            fnd_file.put_line(fnd_file.output,'The following assignments have completed with error');
         else
            fnd_file.put_line(fnd_file.output,'The following assignments have completed successfully');
         end if;
         fnd_file.put_line(fnd_file.output,rpad('Assignment Number',19) ||
                                           rpad('NI Number',11) ||
                                           rpad('Employee Name', 50));
         fnd_file.put_line(fnd_file.output,rpad('-',18,'-') || ' ' ||
                                           rpad('-',10,'-') || ' ' ||
                                           rpad('-',50,'-'));
     end write_sub_header;

     procedure write_body(p_type varchar2) is
         l_count number;
         i number;
         l_temp  varchar2(255);
         cursor csr_asg is
         select /*+ ORDERED */
                peo.first_name          f_name ,
                peo.middle_names        m_name,
                peo.last_name           l_name,
                peo.title               title,
                paf.assignment_number   emp_no,
                peo.national_identifier ni_no
         from   pay_payroll_actions    pay,
                pay_assignment_actions paa,
                per_all_assignments_f  paf,
                per_all_people_f       peo
         where  pay.payroll_action_id = pactid
         and    paa.payroll_action_id = pay.payroll_action_id
         and    paa.action_status = 'E'
         and    paf.assignment_id = paa.assignment_id
         and    peo.person_id = paf.person_id
         and    pay.effective_date between paf.effective_start_date and paf.effective_end_date
         and    pay.effective_date between peo.effective_start_date and peo.effective_end_date;

      --For bugs 9255173 and 9255183: Modified logic for writing to O/P file
      --For bug 9495487  Added upper function for all columns to make P46 output sync with P46 Magtape output
       cursor csr_et_asg is
         select /*+ ORDERED */
                upper(peo.first_name)          f_name ,
                upper(peo.middle_names)        m_name,
                upper(peo.last_name)           l_name,
                upper(peo.title)               title,
                upper(paf.assignment_number)   emp_no,
                upper(peo.national_identifier) ni_no
         from   pay_payroll_actions    pay,
                pay_assignment_actions paa,
                per_all_assignments_f  paf,
                per_all_people_f       peo
         where  pay.payroll_action_id = pactid
         and    paa.payroll_action_id = pay.payroll_action_id
         and    paa.action_status = 'C'
         and    paf.assignment_id = paa.assignment_id
         and    peo.person_id = paf.person_id
         and    pay.effective_date between paf.effective_start_date and paf.effective_end_date
         and    pay.effective_date between peo.effective_start_date and peo.effective_end_date;

         l_et_temp  varchar2(255);

      begin
         l_count := 0;
          i := g_edi_errors_table.count + 1;

         FOR i IN 1 .. g_edi_errors_table.count LOOP
            IF g_edi_errors_table(i).status = p_type THEN
             l_temp := g_edi_errors_table(i).last_name || ', '|| g_edi_errors_table(i).title || ' ' ||
                       g_edi_errors_table(i).first_name || ' ' || g_edi_errors_table(i).middle_name ;

             fnd_file.put_line(fnd_file.output,rpad(g_edi_errors_table(i).assignment_number, 18) || ' ' ||
                                               rpad(g_edi_errors_table(i).ni_number ,10) || ' ' ||
                                               rpad(l_temp,50));
             l_count := l_count + 1;
             END IF;
         END LOOP;

       --For bugs 9255173 and 9255183: Modified logic for writing to O/P file
         IF p_type = 'ET'THEN
          FOR et_asg_rec IN csr_et_asg LOOP
             l_et_temp := et_asg_rec.l_name || ', '|| et_asg_rec.title || ' ' ||
                       et_asg_rec.f_name || ' ' || et_asg_rec.m_name;
             fnd_file.put_line(fnd_file.output,rpad(et_asg_rec.emp_no, 18) || ' ' ||
                                               rpad(et_asg_rec.ni_no ,10) || ' ' ||
                                               rpad(l_et_temp,50));
             l_count := l_count + 1;
           END LOOP;
         END IF;

         IF p_type = 'E'THEN
          FOR asg_rec IN csr_asg LOOP
             l_temp := asg_rec.l_name || ', '|| asg_rec.title || ' ' ||
                       asg_rec.f_name || ' ' || asg_rec.m_name;
             fnd_file.put_line(fnd_file.output,rpad(asg_rec.emp_no, 18) || ' ' ||
                                               rpad(asg_rec.ni_no ,10) || ' ' ||
                                               rpad(l_temp,50));
             l_count := l_count + 1;
           END LOOP;
         END IF;

        fnd_file.put_line(fnd_file.output,null);
         if p_type = 'E' then
            fnd_file.put_line(fnd_file.output,'Total Number of assignments completed with error : ' || l_count);
         else
            fnd_file.put_line(fnd_file.output,'Total Number of assignments completed successfully :' || l_count);
         end if;
         l_counter := l_counter + l_count;
     end write_body;

     procedure write_footer is
     begin
          fnd_file.put_line(fnd_file.output,null);
          fnd_file.put_line(fnd_file.output,'Total Number Of Records : ' || l_counter);
     end write_footer;
BEGIN
     hr_utility.set_location('Entering: '||l_proc,1);

  --For bugs 9255173 and 9255183: Modified logic for O/P file
/*
     l_counter := 0;
     write_header;
     write_sub_header('C');
     write_body('C');
     write_sub_header('E');
     write_body('E');
     write_footer;
*/

     OPEN csr_is_etext_report;
     FETCH  csr_is_etext_report  INTO l_is_etext_report;
     CLOSE csr_is_etext_report;

     l_counter := 0;
     write_header;
     write_sub_header('C');

     IF l_is_etext_report IN ('P46_VER6ET', 'P46EXP_VER6ET')
     THEN
         write_body('ET');
     ELSE
          write_body('C');
     END IF;

     write_sub_header('E');
     write_body('E');
     write_footer;

     IF l_is_etext_report = 'P46_VER6ET'
     THEN
        --this is a eText report, Spawn the BI Publisher process
        hr_utility.set_location('This is a eText report, Spawn the BI Publisher process',1);

        xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','GB_P46_V6_ETO','en','US','ETEXT');

        IF xml_layout = true
        THEN
            l_request_id := fnd_request.submit_request
                                (application => 'PAY'
                                ,program     => 'GB_P46_V6_ETO'
                                ,argument1   => pactid
                                );
            Commit;

            --check for process submit error
            IF l_request_id = 0
            THEN
                hr_utility.set_location('Error spawning new process',1);
            END IF;
        END IF;
     END IF;

IF l_is_etext_report = 'P46EXP_VER6ET'
     THEN
        --this is a eText report, Spawn the BI Publisher process
        hr_utility.set_location('This is a eText report, Spawn the BI Publisher process',1);

        xml_layout := FND_REQUEST.ADD_LAYOUT('PAY','GB_P46EXP_V6_ETO','en','US','ETEXT');

        IF xml_layout = true
        THEN
            l_request_id := fnd_request.submit_request
                                (application => 'PAY'
                                ,program     => 'GB_P46EXP_V6_ETO'
                                ,argument1   => pactid
                                );
            Commit;

            --check for process submit error
            IF l_request_id = 0
            THEN
                hr_utility.set_location('Error spawning new process',1);
            END IF;
        END IF;
     END IF;

     hr_utility.set_location('Leaving: '||l_proc,999);
END deinitialization_code;
--
--
    FUNCTION date_validate (c_assignment_action_id  NUMBER,
                            p_mode                  VARCHAR2,
                            p_validate_date         DATE)
    RETURN NUMBER
    IS


     cursor csr_parameter_info is
     select pay_gb_eoy_archive.get_parameter(legislative_parameters, 'TEST_ID'),
            pay_gb_eoy_archive.get_parameter(legislative_parameters, 'TEST'),
            /*ppa.effective_date*/
            sysdate
     from   pay_payroll_actions ppa
           ,pay_assignment_actions paa
     where paa.assignment_action_id =  c_assignment_action_id
       and ppa.payroll_action_id = paa.payroll_action_id;


   --For bug 8704601:Added new cursor
     cursor csr_parameter_info_p46_car is
     select ppa.effective_date
     from   pay_payroll_actions ppa
           ,pay_assignment_actions paa
     where paa.assignment_action_id =  c_assignment_action_id
       and ppa.payroll_action_id = paa.payroll_action_id;


     l_date_valid        DATE;
     l_return_valid      NUMBER;
     l_test_id           VARCHAR2(8);
     l_test_submission   VARCHAR2(1);
     l_tax_date          DATE;
     l_tax_year          VARCHAR2(4);
     l_tax_year_start    DATE ;
  BEGIN
     l_return_valid := 1;
     open csr_parameter_info;
     fetch csr_parameter_info into l_test_id,l_test_submission,l_tax_date;
     close csr_parameter_info;


     l_tax_year := to_char(l_tax_date,'RRRR');
     if (l_tax_date > to_date(l_tax_year||'0405','RRRRMMDD')) THEN
       l_tax_date := ADD_MONTHS(to_date(l_tax_year||'0405','RRRRMMDD'),12) ; /*tax year end date*/
     else
       l_tax_date := to_date(l_tax_year||'0405','RRRRMMDD');     /*tax year end date*/
     end if;

     l_tax_date := fnd_date.canonical_to_date(to_char(l_tax_date,'RRRRMMDD'));

     l_tax_year_start := add_months(l_tax_date,-12)+1 ;  -- 6804206

     l_date_valid := p_validate_date;

     if (p_mode = 'LEFT_DATE') then
        if (l_date_valid < add_months(l_tax_date,-72)+1) then     /*vrn : 36*/
           l_return_valid := 0;
        else
           if (l_test_submission = 'N') then
             if (l_date_valid > l_tax_date+30) then
               l_return_valid := 0;
             end if;
           else
             if (l_date_valid > add_months(l_tax_date,12)) then
               l_return_valid := 0;
             end if;
           end if;
         end if;
      elsif (p_mode = 'LEFT_DATE_V6') then  -- Added for version 6 validation
        if (l_date_valid < add_months(l_tax_date,-72)+1) then     /*vrn : 36*/
           l_return_valid := 0;
        else
           if (l_test_submission = 'N') then
             if (l_date_valid > l_tax_date+30) then
               l_return_valid := 0;
             end if;
             if (l_date_valid > sysdate+30) then  -- Added for version 6 validation
               l_return_valid := 0;
             end if;
           else
             if (l_date_valid > add_months(l_tax_date,12)) then
               l_return_valid := 0;
             end if;
           end if;
         end if;
      elsif (p_mode = 'PENSION_DATE') then
         if (l_test_submission = 'N') then
           if (l_date_valid > l_tax_date) then
             l_return_valid := 0;
           end if;
         else
           if l_date_valid > add_months(l_tax_date,12) then
             l_return_valid := 0;
           end if;
         end if;
      elsif (p_mode = 'PENSION_DATE_V6') then
         if (l_test_submission = 'N') then
           if (l_date_valid > l_tax_date+30) then
             l_return_valid := 0;
           end if;
         else
           if l_date_valid > add_months(l_tax_date,12) then
             l_return_valid := 0;
           end if;
         end if;
      elsif (p_mode = 'HIRE_DATE') then
           if (l_test_submission = 'N') then
             if (l_date_valid > l_tax_date) then
               l_return_valid := 0;
             end if;
           else
             if (l_date_valid > add_months(l_tax_date,12)) then
               l_return_valid := 0;
             end if;
           end if;
      --
      elsif (p_mode = 'HIRE_DATE_V6') then -- Added for version 6 validation
           if (l_test_submission = 'N') then
             if (l_date_valid > l_tax_date) then
               l_return_valid := 0;
             end if;
             if (l_date_valid > sysdate+30) then  -- Added for version 6 validation
               l_return_valid := 0;
             end if;
           else
             if (l_date_valid > add_months(l_tax_date,12)) then
               l_return_valid := 0;
             end if;
           end if;

	/*Changes for P46EXP_Ver6 starts*/
      elsif (p_mode = 'UK_EMPL_DATE') then
           if (l_test_submission = 'N') then
             if (l_date_valid > sysdate+30) then
               l_return_valid := 0;
             end if;
           else
             if (l_date_valid > add_months(l_tax_date,12)) then
               l_return_valid := 0;
             end if;
           end if;
	/*Changes for P46EXP_Ver6 end*/

      elsif (p_mode = 'DOB') then
           if (l_date_valid > sysdate) then
               l_return_valid := 0;
           end if;

    elsif (p_mode = 'SOY_CHECK') then
           if l_date_valid <= l_tax_year_start then
               l_return_valid := 0;
           end if;

  --For bug 8704601:Added logic for P46_CAR
    elsif (p_mode = 'P46_CAR')
       then
           open csr_parameter_info_p46_car;
           fetch csr_parameter_info_p46_car into l_tax_date;
           close csr_parameter_info_p46_car;

           l_tax_year := to_char(l_tax_date,'RRRR');

           if (l_tax_date > to_date(l_tax_year||'0405','RRRRMMDD'))
           then
               l_tax_date := ADD_MONTHS(to_date(l_tax_year||'0405','RRRRMMDD'),12) ; /*tax year end date*/
           else
               l_tax_date := to_date(l_tax_year||'0405','RRRRMMDD');     /*tax year end date*/
           end if;

           l_tax_date := fnd_date.canonical_to_date(to_char(l_tax_date,'RRRRMMDD'));

           l_tax_year_start := add_months(l_tax_date,-12)+1 ;

           if l_date_valid < l_tax_year_start then
               l_return_valid := 0;
           end if;
      --
      end if;

       return l_return_valid;
 END date_validate;

end PAY_GB_MOVDED_EDI;

/
