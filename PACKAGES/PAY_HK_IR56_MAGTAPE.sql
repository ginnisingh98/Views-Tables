--------------------------------------------------------
--  DDL for Package PAY_HK_IR56_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_IR56_MAGTAPE" AUTHID CURRENT_USER AS
/* $Header: pyhk56mt.pkh 120.0.12010000.1 2008/07/27 22:48:10 appldev ship $
  **  Change List
  **  ===========
  **
  **  Date        Author   Reference Description
  **  -----------+--------+---------+-------------
  **  17 AUG 2001 APUNEKAR   N/A       Created
  **  23 AUG 2002 SHOSKATT 2514400   Sorted by name in ir56b_details cursor
  **  27 AUG 2002 SHOSKATT 2514400   Added a Date Track Check for the details
  **                                 cursor
  **  02 DEC 2002 SRRAJAGO 2689229   Included nocopy option for the 'OUT'
  **                                 parameter of the procedure 'range_code'
  **  04 DEC 2002 PUCHIL   2690005   Changed the cursor ir56b_details to
  **                                 a) Sort the details on last_name and first_name
  **                                 b) Eliminate terminated employees.
  **  19 DEC 2002 PUCHIL   2715305   Changed the cursor ir56b_details to
  **                                 eliminate zero sheet numbers.
  **  23 DEC 2002 PUCHIL   2721327   Removed the changes made for Bug 2715305
  **  13 JAN 2003 SRRAJAGO 2746829   Modified the cursor ir56b_details to fetch
  **                                 last name and first name separately instead of
  **                                 the concatenation.Order by clause also modified.
  **  23 JAN 2003 CTREDWIN 2746829   Modified ir56b_details to include middle_name
  **                                 in the ordering, as well as first name, to bring
  **                                 magtape ordering fully into line with the IR56B
  **                                 report
  ** 23 JAN 2003 CTREDWIN  -         Syntax correction
  ** 19 APR 2003 NANURADH  2913879   Truncated the value of archived item.
  ** 29 MAY 2003 KAVERMA   2920731   Replaced tables per_all_assignments_f and per_all_people_f
  **                                 by secured views per_assignments_f and per_people_f in ir56b_details
*/


LEVEL_CNT Number;


/********************************************************
*  Procedure to fetch RANGE CODE *
**********************************************************/
PROCEDURE range_code
(p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE,
 p_sql out nocopy varchar2);

/********************************************************
*  Procedure to fetch ASSIGNMENT ACTION CODE *
**********************************************************/

PROCEDURE assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%TYPE,
     p_start_person_id    in per_all_people_f.person_id%TYPE,
     p_end_person_id      in per_all_people_f.person_id%TYPE,
     p_chunk              in number) ;

/********************************************************
*  Cursor to create Header Record
**********************************************************/
CURSOR ir56b_header is
 select  'ASSIGNMENT_ACTION_ID=C',
          assign_action.assignment_action_id,
          'SUBMISSION_DATE=P',
          to_char(sysdate,'YYYYMMDD') submission_date,
          'TOTAL_ASSIGNMENTS=P',
      count(archive_count.assignment_id) total_count,
       'TOTAL_INCOME=P',
       sum(archive_count.amount) total_amount
    from
(
  select paa.assignment_id,
         sum(trunc(nvl(fai.value, 0))) amount   /* Bug: 2913879 */
    from ff_archive_items fai,
         ff_user_entities fue,
         pay_assignment_actions paa,
         pay_payroll_actions ppa,
         pay_payroll_actions ppa2,
		 pay_payroll_actions ppa3
    where ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and   ppa2.payroll_action_id = pay_core_utils.get_parameter('REPORT_ACTION_ID', ppa.legislative_parameters)
    and   fue.user_entity_id = fai.user_entity_id
    and   fue.user_entity_name like 'X_HK_IR56_%_ASG_LE_YTD'
    and   fai.context1 = paa.assignment_action_id
    and   paa.payroll_action_id = ppa3.payroll_action_id
    and   paa.action_status = 'C'
    and   ppa3.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa2.legislative_parameters)
    and   pay_hk_ir56_report.get_archive_value('X_HK_ARCHIVE_MESSAGE', paa.assignment_action_id) is null
group by paa.assignment_id
  ) archive_count,
       (
   select paa.assignment_action_id
    from   pay_payroll_actions ppa,
           pay_payroll_actions ppa2,
           pay_assignment_actions paa,
	    pay_payroll_actions ppa3--archive action
    where ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and   ppa2.payroll_action_id = pay_core_utils.get_parameter('REPORT_ACTION_ID', ppa.legislative_parameters)
    and   ppa3.payroll_action_id = paa.payroll_action_id
    and   paa.action_status = 'C'
    and   ppa3.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa2.legislative_parameters)

    and   pay_hk_ir56_report.get_archive_value('X_HK_ARCHIVE_MESSAGE', paa.assignment_action_id) is null
    and   rownum=1
	) assign_action
group by
       assign_action.assignment_action_id;



/********************************************************
* Cursor to create Detail Record
**********************************************************/

/* Bug No : 2746829 - Modified cursor ir56b_details to fetch pap.last_name and pap.first_name instead of
   the concatenation pap.last_name || pap.first_name. Order by clause modified to include last_name,
   first_name  */

/* Sorted by name - Bug 2514400 */
cursor ir56b_details is
select distinct
           'ASSIGNMENT_ACTION_ID=C',
           pac3.assignment_action_id,
           pap.last_name lname,  /*Changed to get proper sorted order for bug 2690005*/
           pap.first_name||' '||pap.middle_names fname
    from   per_assignments_f paa,
           pay_payroll_actions ppa,   -- Magtape payroll action
           pay_payroll_actions ppa2,  -- Report payroll action
           pay_payroll_actions ppa3,  -- Archive payroll action
           pay_assignment_actions pac,
           pay_assignment_actions pac3,
           per_people_f pap
    where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    ppa2.payroll_action_id = pay_core_utils.get_parameter('REPORT_ACTION_ID', ppa.legislative_parameters)
    and    ppa3.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ACTION_ID', ppa2.legislative_parameters)
    and    pac.action_status = 'C'
    and    ppa3.payroll_action_id = pac.payroll_action_id
    and    paa.assignment_id = pac.assignment_id
    and    pac3.payroll_action_id = ppa3.payroll_action_id
   and    paa.assignment_id = pac3.assignment_id
   and    pap.person_id = paa.person_id
   and    pay_hk_ir56_report.get_archive_value('X_HK_ARCHIVE_MESSAGE', pac3.assignment_action_id) is null
   and    pap.effective_start_date = (select max(pap1.effective_start_date) from per_people_f pap1
          where pap1.person_id = pap.person_id and to_date('31-03'||pay_core_utils.get_parameter('REPORTING_YEAR',
          ppa3.legislative_parameters),'DD-MM-YYYY') between pap1.effective_start_date and pap1.effective_end_date)
	/* Start for bug 2690005 */
        /* Added to eliminate terminated employees */
   and   pay_hk_ir56_report.get_archive_value('X_HK_LAST_NAME', pac3.assignment_action_id) is not null
       /* End for bug 2690005 */
   order by lname,fname;

/********************************************************
* Cursor to Submit Control listing report.
**********************************************************/
--
-- Pass details to submit report.
--
cursor cusr_submit_reports is
select 'P_ARCHIVE_OR_MAGTAPE=P',
       'MAGTAPE'
  from dual;



end pay_hk_ir56_magtape;

/
