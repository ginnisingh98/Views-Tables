--------------------------------------------------------
--  DDL for Package Body PAY_CA_MAG_ROE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_MAG_ROE" AS
/* $Header: pycaremg.pkb 120.0 2005/05/29 03:42:11 appldev noship $ */

 -----------------------------------------------------------------------------
   -- Name     ::		get_report_parameters
   --
   -- Purpose
   --   The procedure gets the 'parameter' for which the report is being
   --   run i.e., the period, person_id.
   --
   -- Arguments
   --   p_date_start		Start Date of the period for which the report
   --				has been requested
   --   p_date_end		End date of the period
   --   p_person_id		If start_date and end_date is null then
   --				we use person_id to get the record.
   --
   -- Notes
 ----------------------------------------------------------------------------

function fun_user_entity_id(p_user_entity_name varchar2)
				return number is
begin

declare

  cursor cur_user_entity_id is
  select user_entity_id
  from   ff_user_entities fue
  where  fue.user_entity_name = p_user_entity_name
  and    fue.legislation_code = 'CA';

  l_user_entity_id	ff_user_entities.user_entity_id%TYPE;

begin

  hr_utility.set_location('func_user_entity_id',1);

  open cur_user_entity_id;
  fetch cur_user_entity_id
    into  l_user_entity_id;
  close cur_user_entity_id;

  return l_user_entity_id;

end;

end fun_user_entity_id;

procedure get_report_parameters
(       p_pactid                        IN      NUMBER,
        p_start_date                    OUT     NOCOPY DATE,
        p_end_date                      OUT     NOCOPY DATE,
        p_person_id                     OUT     NOCOPY VARCHAR2,
        p_assignment_set                OUT     NOCOPY NUMBER

) is
begin

declare

  cursor cur_ppa is
  select ppa.start_date,
         ppa.effective_date,
         pay_core_utils.get_parameter('PERSON_ID',ppa.legislative_parameters),
         pay_core_utils.get_parameter('ASSIGNMENT_SET',ppa.legislative_parameters)
  from   pay_payroll_actions ppa
  where  payroll_action_id = p_pactid;

begin
	hr_utility.set_location
	('pay_ca_mag_roe.get_report_parameters', 10);

	open  cur_ppa;

	fetch cur_ppa
	into  p_start_date,
  	      p_end_date,
	      p_person_id,
              p_assignment_set;

	close cur_ppa;

	hr_utility.set_location
	('pay_ca_mag_roe.get_report_parameters', 20);
end;

	hr_utility.set_location
	('pay_ca_mag_roe.get_report_parameters', 30);
end get_report_parameters;


--
  ----------------------------------------------------------------------------
  --Name
  --  range_cursor
  --Purpose
  --  To prepare the the SQL statement to fetch the people.
  --Arguments
  --  p_pactid			payroll action id for the report.
  --  p_sqlstr			the SQL statement to fetch the people.
------------------------------------------------------------------------------
procedure range_cursor (
	p_pactid	IN	NUMBER,
	p_sqlstr	OUT	NOCOPY VARCHAR2) IS

begin

declare
  p_start_date          date;
  p_end_date            date;
  p_person_id           per_people_f.person_id%TYPE;
  p_assignment_set      number;
  l_roe_date_uid        ff_user_entities.user_entity_id%TYPE;
  l_roe_asg_id_uid      ff_user_entities.user_entity_id%TYPE;

begin

        --hr_utility.trace_on(1,'ORACLE');
	hr_utility.set_location( 'pay_ca_mag_roe.range_cursor', 10);

	get_report_parameters(
		p_pactid,
		p_start_date,
		p_end_date,
		p_person_id,
		p_assignment_set
	);

	hr_utility.set_location( 'pay_ca_mag_roe.range_cursor', 20);

        l_roe_date_uid := FUN_USER_ENTITY_ID('ROE_DATE');
        l_roe_asg_id_uid := FUN_USER_ENTITY_ID('ROE_ASSIGNMENT_ID');

	--if p_start_date or p_end_date is not null then

        /* Bug 2385763. Changes to handle the situation when ROE magnetic report is run
           for one employee. */

        if p_person_id is not null then
            p_sqlstr := 'select distinct person_id from
                        per_assignments_f paf,
                        ff_archive_items fai,
                        pay_payroll_actions ppa,
                        pay_assignment_actions paa
                        where
                        fai.user_entity_id = ' || l_roe_date_uid || ' and
                        fnd_date.canonical_to_date(fai.value) between
                            ppa.start_date and
                            ppa.effective_date and
                        ppa.payroll_action_id = :p_pactid and
                        ppa.business_group_id = paf.business_group_id and
                        paa.assignment_action_id = fai.context1 and
                        paf.assignment_id = paa.assignment_id and
                        fnd_date.canonical_to_date(fai.value) between
                          paf.effective_start_date and
                          paf.effective_end_date and
                        person_id = '|| p_person_id;
        elsif p_assignment_set is not null then
            p_sqlstr := 'select distinct paf.person_id from
                        per_assignments_f paf,
                        ff_archive_items fai,
                        pay_payroll_actions ppa,
                        pay_assignment_actions paa,
                        HR_ASSIGNMENT_SET_AMENDMENTS haa
                        where
                        fai.user_entity_id = ' || l_roe_date_uid || ' and
                        fnd_date.canonical_to_date(fai.value) between
                            ppa.start_date and
                            ppa.effective_date and
                        ppa.payroll_action_id = :p_pactid and
                        ppa.business_group_id = paf.business_group_id and
                        paa.assignment_action_id = fai.context1 and
                        paf.assignment_id = paa.assignment_id and
                        fnd_date.canonical_to_date(fai.value) between
                          paf.effective_start_date and
                          paf.effective_end_date and
                          haa.assignment_id = paf.assignment_id and
                          haa.include_or_exclude = ''I'' and
                        haa.assignment_set_id = '|| p_assignment_set;
         else
            p_sqlstr := 'select distinct person_id from
                        per_assignments_f paf,
                        ff_archive_items fai,
                        pay_payroll_actions ppa,
                        pay_assignment_actions paa
                        where
                        fai.user_entity_id = ' || l_roe_date_uid || ' and
                        fnd_date.canonical_to_date(fai.value) between
                            ppa.start_date and
                            ppa.effective_date and
                        ppa.payroll_action_id = :p_pactid and
                        ppa.business_group_id = paf.business_group_id and
                        paa.assignment_action_id = fai.context1 and
                        paf.assignment_id = paa.assignment_id and
                        fnd_date.canonical_to_date(fai.value) between
                          paf.effective_start_date and
                          paf.effective_end_date';
        end if;

	--end if;
	hr_utility.set_location( 'pay_ca_mag_roe.range_cursor', 30);
end;
end range_cursor;

--
  -----------------------------------------------------------------------------
  --Name
  --  create_assignment_act
  --Purpose
  --  Creates assignment actions for the payroll action associated with the
  --  report
  --Arguments
  --  p_pactid				payroll action for the report
  --  p_stperson			starting person id for the chunk
  --  p_endperson			last person id for the chunk
  --  p_chunk				size of the chunk
  --Note
  --  The procedure processes assignments in 'chunks' to facilitate
  --  multi-threaded operation. The chunk is defined by the size and the
  --  starting and ending person id. An interlock is also created against the
  --  pre-processor assignment action to prevent rolling back of the archiver.
  ----------------------------------------------------------------------------
--
procedure create_assignment_act(
	p_pactid 	IN NUMBER,
	p_stperson 	IN NUMBER,
	p_endperson 	IN NUMBER,
	p_chunk 	IN NUMBER ) is


begin

declare

	p_start_date			date;
	p_end_date			date;
	p_person_id			varchar2(10);

	l_roe_date_id			ff_archive_items.user_entity_id%TYPE;
	l_roe_assignment_id
		ff_archive_items.user_entity_id%TYPE;
	l_roe_gre_id
		ff_archive_items.user_entity_id%TYPE;
	l_roe_payroll_id
		ff_archive_items.user_entity_id%TYPE;
	l_assignment_id    pay_assignment_actions.assignment_id%type;
	l_gre_id           pay_assignment_actions.tax_unit_id%type;
	l_payroll_id       ff_archive_items.value%type;

	cursor	cur_assignment_action_id is
	select 	pay_assignment_actions_s.nextval
	from	dual;


	lockingactid			number;

        --
        -- per_assignments_f is not joined by date as there is
        -- a distinct in the select clause.
        --
	cursor 	cur_assignment_action is
        select
          paa.assignment_id assignment_id,
          paa.tax_unit_id   gre_id,
          fai2.value        payroll_id
        from
          pay_payroll_actions ppa,
          pay_assignment_actions paa,
          ff_archive_items fai1,
          ff_archive_items fai2,
          per_assignments_f paf
        where
          ppa.report_type = 'ROE' and
          ppa.report_category = 'ROEC' and
          ppa.report_qualifier = 'ROEQ' and
          ppa.payroll_action_id = paa.payroll_action_id and
          paa.assignment_action_id = fai1.context1 and
          fai1.user_entity_id=l_roe_date_id and
          fnd_date.canonical_to_date(fai1.value) between
            fnd_date.canonical_to_date(to_char(p_start_date,'yyyy/mm/dd hh24:mi:ss')) and
              fnd_date.canonical_to_date(to_char(p_end_date,'yyyy/mm/dd hh24:mi:ss')) and
          fai1.context1 = fai2.context1 and
          fai2.user_entity_id = l_roe_payroll_id and
          paa.assignment_id = paf.assignment_id and
          fnd_date.canonical_to_date(fai1.value) between
           paf.effective_start_date and
           paf.effective_end_date and
          paf.assignment_type = 'E' and
          paf.person_id between
            p_stperson and
            p_endperson;

	cursor 	cur_assignment_action_range is
        select
          paa.assignment_id assignment_id,
          paa.tax_unit_id   gre_id,
          fai2.value        payroll_id
        from
          pay_payroll_actions ppa,
          pay_assignment_actions paa,
          ff_archive_items fai1,
          ff_archive_items fai2,
          per_assignments_f paf,
	  pay_population_ranges ppr
        where
          ppa.report_type = 'ROE' and
          ppa.report_category = 'ROEC' and
          ppa.report_qualifier = 'ROEQ' and
          ppa.payroll_action_id = paa.payroll_action_id and
          paa.assignment_action_id = fai1.context1 and
          fai1.user_entity_id=l_roe_date_id and
          fnd_date.canonical_to_date(fai1.value) between
            fnd_date.canonical_to_date(to_char(p_start_date,'yyyy/mm/dd hh24:mi:ss')) and
              fnd_date.canonical_to_date(to_char(p_end_date,'yyyy/mm/dd hh24:mi:ss')) and
          fai1.context1 = fai2.context1 and
          fai2.user_entity_id = l_roe_payroll_id and
          paa.assignment_id = paf.assignment_id and
          fnd_date.canonical_to_date(fai1.value) between
           paf.effective_start_date and
           paf.effective_end_date and
          paf.assignment_type = 'E' and
	  ppr.payroll_action_id = p_pactid
        AND ppr.chunk_number = p_chunk
        AND paf.person_id = ppr.person_id;

	cursor cur_locked_action_id(l_assignment_id ff_archive_items.value%TYPE,
				     l_gre_id	    ff_archive_items.value%TYPE,
				     l_payroll_id   ff_archive_items.value%TYPE) 					is
           select
             paa.assignment_action_id locked_action_id
           from
             pay_payroll_actions ppa,
             pay_assignment_actions paa,
             ff_archive_items fai1,
             ff_archive_items fai2
           where
             ppa.report_type = 'ROE' and
             ppa.report_category = 'ROEC' and
             ppa.report_qualifier = 'ROEQ' and
             ppa.payroll_action_id = paa.payroll_action_id and
             paa.tax_unit_id = l_gre_id and
             paa.assignment_id = l_assignment_id and
             paa.assignment_action_id = fai1.context1 and
             fai1.user_entity_id =  l_roe_date_id and
  	     fnd_date.canonical_to_date(fai1.value) between
               fnd_date.canonical_to_date(to_char(p_start_date,'yyyy/mm/dd hh24:mi:ss')) and
               fnd_date.canonical_to_date(to_char(p_end_date,'yyyy/mm/dd hh24:mi:ss')) and
            fai1.context1 = fai2.context1 and
            fai2.user_entity_id = l_roe_payroll_id and
            fai2.value = l_payroll_id;

	  l_locked_action_id	pay_assignment_actions.assignment_action_id%TYPE;

	  cursor cur_already_locked is
	  select 'x'  from pay_action_interlocks
	  where locked_action_id = l_locked_action_id;

	  dummy		   varchar2(1);
	  lb_range_person  BOOLEAN;
          p_assignment_set  number;
begin
	-- Get the report parameters. These define the report being run.

	hr_utility.set_location( 'pay_ca_mag_roe.create_assignment_act',10);

	 get_report_parameters(
		p_pactid,
		p_start_date,
		p_end_date,
		p_person_id,
		p_assignment_set
	);



	hr_utility.set_location( 'pay_ca_mag_roe.create_assignment_act',20);

	for cur_ass_id in 1..4 loop

	  if cur_ass_id = 1 then
	    l_roe_date_id :=  fun_user_entity_id('ROE_DATE');
	    hr_utility.set_location( 'pay_ca_mag_roe.create_assignment_act',30);
	  elsif cur_ass_id = 2 then
	    l_roe_assignment_id :=  fun_user_entity_id('ROE_ASSIGNMENT_ID');
	    hr_utility.set_location( 'pay_ca_mag_roe.create_assignment_act',40);
	  elsif cur_ass_id = 3 then
	    l_roe_gre_id := fun_user_entity_id('ROE_GRE_ID');
	    hr_utility.set_location( 'pay_ca_mag_roe.create_assignment_act',50);
	  elsif cur_ass_id = 4 then
	    l_roe_payroll_id :=  fun_user_entity_id('ROE_PAYROLL_ID');
	    hr_utility.set_location( 'pay_ca_mag_roe.create_assignment_act',70);
	  end if;

	end loop;

        lb_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'MAG_ROE'
                          ,p_report_format    => 'MAG_ROEF'
                          ,p_report_qualifier => 'MAG_ROEQ'
                          ,p_report_category  => 'MAG_ROEC');

	if lb_range_person then
 	  open  cur_assignment_action_range;
	else
	  open  cur_assignment_action;
	end if;

	loop
	  if lb_range_person then
	    fetch cur_assignment_action_range into l_assignment_id, l_gre_id,l_payroll_id;
	    exit when cur_assignment_action_range%notfound;
	  else
	    fetch cur_assignment_action into l_assignment_id, l_gre_id,l_payroll_id;
	    exit when cur_assignment_action%notfound;
	  end if;

	  hr_utility.set_location('cur_assignment_action',10);

	  for j in  cur_locked_action_id(l_assignment_id,
				    l_gre_id,
				    l_payroll_id) loop

	    l_locked_action_id := j.locked_action_id;

	    open cur_already_locked ;
	    fetch cur_already_locked
	    into  dummy;

	    if cur_already_locked%NOTFOUND then

	      close cur_already_locked ;

	      open  cur_assignment_action_id;
	      fetch cur_assignment_action_id
	      into  lockingactid;
	      close cur_assignment_action_id;

              -- insert into pay_assignment_actions.

               hr_nonrun_asact.insact(lockingactid,l_assignment_id,
                            p_pactid,p_chunk,l_gre_id);

               hr_utility.set_location('assignment action creation',30);


               hr_nonrun_asact.insint(lockingactid, l_locked_action_id);

               hr_utility.set_location('Assignment action interlock',40);

	     else

	        close cur_already_locked;

	     end if;

	  end loop;

	end loop;
	if lb_range_person then
 	  close  cur_assignment_action_range;
	else
	  close  cur_assignment_action;
	end if;

end;

end create_assignment_act;


end pay_ca_mag_roe;

/
