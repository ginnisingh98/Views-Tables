--------------------------------------------------------
--  DDL for Package Body PAY_HK_IR56_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_IR56_MAGTAPE" AS
/* $Header: pyhk56mt.pkb 120.0.12010000.2 2008/09/01 07:24:30 jalin ship $
**
**  Copyright (c) 2000 Oracle Corporation
**  All Rights Reserved
**
**
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  17 SEP 2001 APUNEKAR N/A       Inital version.
**  04 JUN 2002 APUNEKAR N/A       Fixed for Bug#2397884.
**  04 JUN 2002 APUNEKAR N/A       Open eit cursor only if archive message is null
**  02 DEC 2002 SRRAJAGO 2689229   Included 'nocopy' option for the 'OUT' parameter
**                                 of the procedure 'range_code'
**  11 MAR 2003 SRRAJAGO 2829320   In the process_assignments cursor, included the join
**                                 paa.action_status = 'C' to prevent magtape fetching
**                                 the errored archive records.
**  29 MAY 2003 KAVERMA  2920731   Replaced tables per_all_assignments_f and per_all_people_f
**                                 by secured views per_assignments_f and per_people_f from queries.
**  28 AUG 2008 JALIN    7324233   In the process_assignments cursor,it should
**                                 lock the assignments which has magtape
**                                 generatedi, it should not lock with archive
*/





/********************************************************
*  Procedure to fetch RANGE CODE *
**********************************************************/
procedure range_code
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%type,
 p_sql out nocopy varchar2
 )
is
Begin
    hr_utility.set_location('Start of range_code',1);
    p_sql := 'SELECT distinct person_id '                            ||
             'FROM  per_people_f ppf, '                              ||
                    'pay_payroll_actions ppa '                       ||
             'WHERE ppa.payroll_action_id = :payroll_action_id '     ||
             'AND    ppa.business_group_id = ppf.business_group_id ' ||
             'ORDER BY ppf.person_id';
    hr_utility.set_location('End of range_code',2);
  End range_code;

/********************************************************
*  Procedure to fetch ASSIGNMENT ACTION CODE *
**********************************************************/

PROCEDURE assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
     p_start_person_id    in per_all_people_f.person_id%TYPE,
     p_end_person_id      in per_all_people_f.person_id%TYPE,
     p_chunk              in number)
  IS
    v_next_action_id  pay_assignment_actions.assignment_action_id%TYPE;
    v_run_action_id   pay_assignment_actions.assignment_action_id%TYPE;
    v_archive_action_id pay_assignment_actions.assignment_action_id%TYPE;
    x_hk_archive_message varchar2(1000);

    CURSOR next_action_id is
      SELECT pay_assignment_actions_s.NEXTVAL
      FROM  dual;



----------------------
--Define Cursor to check  EIT

cursor check_eit
      (c_assignment_id     in pay_assignment_actions.assignment_id%type,
       c_legal_entity_id   in pay_assignment_actions.tax_unit_id%type,
       c_reporting_year in number) is
SELECT      paei.assignment_extra_info_id,
                paei.assignment_id,
                paei.aei_information1,
                paei.aei_information4
    FROM        per_assignment_extra_info paei,
                per_assignment_info_types pait
    WHERE       paei.information_type = 'HR_IR56B_REPORTING_INFO_HK'
    AND         paei.assignment_id = c_assignment_id
    AND         paei.information_type = pait.information_type
    AND         pait.active_inactive_flag = 'Y'
    AND         paei.aei_information1 = c_reporting_year
    AND         paei.aei_information4 = c_legal_entity_id;


--------------------
CURSOR process_assignments
(c_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
 c_start_person_id    in per_all_people_f.person_id%TYPE,
 c_end_person_id      in per_all_people_f.person_id%TYPE)

IS

select distinct paaf.assignment_id,
paa.assignment_action_id,
pay_core_utils.get_parameter('ARCHIVE_ACTION_ID',ppa2.legislative_parameters) archive_action_id,
pay_core_utils.get_parameter('LEGAL_ENTITY_ID',ppa3.legislative_parameters) legal_entity_id,
pay_core_utils.get_parameter('REPORTING_YEAR',ppa3.legislative_parameters) reporting_year
from per_people_f papf,
     per_assignments_f paaf,
     pay_payroll_actions ppa, --magtape action
     pay_payroll_actions ppa2,--report action
	 pay_payroll_actions ppa3,--archive action
     pay_assignment_actions paa
where
     ppa.payroll_action_id = c_payroll_action_id
and  papf.person_id between  c_start_person_id and c_end_person_id
and  papf.person_id = paaf.person_id
and  papf.business_group_id = ppa.business_group_id
and  ppa3.payroll_action_id = paa.payroll_action_id
and  paaf.assignment_id= paa.assignment_id
and  ppa2.payroll_action_id = pay_core_utils.get_parameter('REPORT_ACTION_ID',ppa.legislative_parameters)
and  ppa3.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID',ppa2.legislative_parameters)
and  ppa3.action_type = 'X'
and  ppa3.action_status = 'C'
and  paa.action_status  = 'C' /* Bug No : 2829320 - To prevent Magtape fetching errored archive records */
 and  not exists /* dont process locked assignments, bug 7324233, it should only lock the assignments which has magtape generated previously */
 (select locked_action_id
  from   pay_action_interlocks pai,
         pay_payroll_actions ppa1,
         pay_payroll_actions ppa2,
         pay_assignment_actions paa1
  where pai.locked_action_id = paa.assignment_action_id
  and   ppa1.action_type='X'
  and   ppa1.report_type = 'HK_IR56B_MAGTAPE'
  and   ppa2.action_type='X'
  and   ppa2.action_status='C'
  and   ppa1.action_status='C'
  and   ppa2.report_type = 'HK_IR56B_REPORT'
  and   paa1.assignment_action_id = pai.locking_action_id
  and   ppa1.payroll_action_id = paa1.payroll_action_id
  and   ppa2.payroll_action_id = pay_core_utils.get_parameter('REPORT_ACTION_ID',
        ppa1.legislative_parameters)
  );


eit_rec check_eit%rowtype;
--------------------
 Begin
    hr_utility.set_location
    ('Start of assignment_action_code '||
     p_payroll_action_id || ':' ||
     p_start_person_id || ':' ||
     p_end_person_id,
     3);


   FOR process_rec IN process_assignments (p_payroll_action_id,
              p_start_person_id,
              p_end_person_id)
   LOOP

      x_hk_archive_message :=pay_hk_ir56_report.get_archive_value
      ('X_HK_ARCHIVE_MESSAGE',process_rec.assignment_action_id);

   if x_hk_archive_message is null then/*Bug#2397884-Check for message first and then for EIT*/

      open check_eit(process_rec.assignment_id,
                 process_rec.legal_entity_id,
                 process_rec.reporting_year
                 );
      fetch check_eit into eit_rec;

     --- Make Sure an EIT exists
        if check_eit%FOUND then


        --* Get the new action id
      	OPEN next_action_id;
      	FETCH next_action_id INTO v_next_action_id;
      	CLOSE next_action_id;

        hr_utility.set_location('Before calling hr_nonrun_asact.insact',4);

        hr_nonrun_asact.insact(v_next_action_id,
                       process_rec.assignment_id,
                       p_payroll_action_id,
                       p_chunk,
                       null);

        hr_utility.set_location('After calling hr_nonrun_asact.insact',4);


        hr_nonrun_asact.insint(v_next_action_id,
                       process_rec.assignment_action_id
                      );
        close check_eit;
        else --check EIT NOT FOUND
        close check_eit;
        raise_application_error(-20001, 'Assignment : ' || process_rec.assignment_id || ' has been processed by IR56B Report but no EIT exists.');
        end if;
  end if;



END LOOP;
hr_utility.set_location('End of assignment_action_code',5);

Exception
When Others Then
If next_action_id%ISOPEN Then
CLOSE next_action_id;
End If;
If check_eit%ISOPEN Then
CLOSE check_eit;
End If;

hr_utility.set_location('Exception in assignment_action_code ',20);
RAISE;

End assignment_action_code;


end pay_hk_ir56_magtape;

/
