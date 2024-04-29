--------------------------------------------------------
--  DDL for Package Body PAY_KW_PIFSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_PIFSS" as
 /* $Header: pykwpifs.pkb 120.1 2006/08/11 12:34:19 spendhar noship $ */
 g_package                  varchar2(33) := 'PAY_KW_PIFSS.';
--
PROCEDURE range_cursor (pactid IN NUMBER,
                        sqlstr OUT nocopy VARCHAR2)
IS
  l_proc             VARCHAR2(60);
BEGIN
  --
l_proc := g_package||'range_cursor';

  hr_utility.set_location('Entering: '||l_proc,1);
  --
  -- Note: There must be one and only one entry of :payroll_action_id in
  -- the string, and the statement must be, order by person_id
  --
  sqlstr := 'select distinct person_id '||
            'from per_people_f ppf, '||
            'pay_payroll_actions ppa '||
            'where ppa.payroll_action_id = :payroll_action_id '||
            'and ppa.business_group_id = ppf.business_group_id '||
            'order by ppf.person_id';
  --
  hr_utility.set_location(' Leaving: '||l_proc,100);
END range_cursor;
--
procedure assignment_action_code
      (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in per_all_people_f.person_id%type,
       p_end_person_id      in per_all_people_f.person_id%type,
       p_chunk              in number) is
    v_next_action_id  pay_assignment_actions.assignment_action_id%type;
      cursor process_assignments
        (c_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
         c_start_person_id    in per_all_people_f.person_id%type,
         c_end_person_id      in per_all_people_f.person_id%type) is
         select  distinct a.assignment_id,
                 pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters) archive_action_id,
                 ppac.assignment_action_id
                from   per_assignments_f a,
                       per_people_f p,
                       pay_payroll_actions pa,
                       pay_payroll_actions ppa,
                       pay_assignment_actions ppac
                where  pa.payroll_action_id   = c_payroll_action_id
                 and    p.person_id             between c_start_person_id and c_end_person_id
                 and    p.person_id           = a.person_id
                 and    p.business_group_id   = pa.business_group_id
                 and    ppa.payroll_action_id = ppac.payroll_action_id
                 and    a.assignment_id       = ppac.assignment_id
                 and    ppa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_ID', pa.legislative_parameters)
                 And    ppa.action_type       = 'X'
                 and    ppa.action_status     = 'C'
		 and ppac.assignment_action_id in
			 (select max(ppac1.assignment_action_id)
			  from pay_assignment_actions ppac1,
			       pay_payroll_Actions    ppaa
			  where ppaa.action_type       ='X'
			   and  ppaa.action_status     ='C'
			   and  ppaa.report_type       ='KW_PIFSS_REPORT'
			   and  ppaa.payroll_Action_id = ppac1.payroll_action_id
			  group by ppac1.assignment_id)
                and  not exists
	                    (select locked_action_id
	                     FROM   pay_action_interlocks pail
                           WHERE pail.locked_action_id=ppac.assignment_action_id);
  cursor next_action_id is
        select pay_assignment_actions_s.nextval
        from   dual;
  begin
       hr_utility.set_location('Start of assignment_action_code',3);
       hr_utility.set_location('The payroll_action_id passed  '|| p_payroll_action_id,4);
       hr_utility.set_location('The p_start_person_id  '|| p_start_person_id,5);
       hr_utility.set_location('The p_end_person_id '|| p_end_person_id,6);
       hr_utility.set_location('The p_chunk number '|| p_chunk ,7);
       for process_rec in process_assignments (p_payroll_action_id,
                                               p_start_person_id,
                                               p_end_person_id)
       loop
        hr_utility.set_location('LOOP STARTED   '|| process_rec.assignment_id ,14);
        open next_action_id;
        fetch next_action_id into v_next_action_id;
        close next_action_id;
        hr_utility.set_location('before calling insact  '|| v_next_action_id ,14);
        hr_nonrun_asact.insact(v_next_action_id,
	                         process_rec.assignment_id,
	                         p_payroll_action_id,
	                         p_chunk,
                               null);
        hr_utility.set_location('inserted assigment action assignment '|| process_rec.assignment_id ,15);
        hr_utility.set_location('Before calling hr_nonrun_asact.insint archive ' || process_rec.archive_action_id,16);
        hr_utility.set_location('v_next_action_id' || v_next_action_id,16);
        hr_nonrun_asact.insint(v_next_action_id,process_rec.assignment_action_id);
        hr_utility.set_location('After calling hr_nonrun_asact.insint',14);
       end loop;
       hr_utility.set_location('End of assignment_action_code',5);
 exception
    when others then
    hr_utility.set_location('error raised in assignment_action_code procedure ',5);
    raise;
 end assignment_action_code;
 --
  procedure spawn_archive_reports is
  begin
  pay_magtape_generic.new_formula;
  end;
 --
 END PAY_KW_PIFSS;

/
