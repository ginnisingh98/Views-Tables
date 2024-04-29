--------------------------------------------------------
--  DDL for Package Body PAY_US_OVER_LIMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_OVER_LIMIT_PKG" as
/* $Header: pyusoltm.pkb 120.3.12010000.1 2008/07/27 23:54:29 appldev ship $ */
/*
   Copyright (c) Oracle Corporation 2001. All rights reserved
--
   Name        :This package defines the cursors needed for OLT to run Multi-Threaded
--
   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   01-DEC-2001  irgonzal    115.0  2045352  Created.
   08-DEC-2001  irgonzal    115.1           Simplied the sort_action cursor
                                            since the sorting is performed in
                                            the second stage of the process.
                                            Removed reference to pactid and
                                            per_people_f in Action_Creation
                                            cursor.
   11-DEC-2001  irgonzal    115.2           Corrected typo in sort_action
                                            procedure and removed reference
                                            to per_people_f table in sort_
                                            action procedure.
   20-DEC-2001  meshah      115.3  2157065  changed hr_locations to
                                            hr_locations_all in c_actions
                                            cursor.
   04-FEB-2001  meshah      115.4  2166701  Changed the action creation cursor.
                                            Also changed the names of the
                                            dummy parameters from
                                            legislative_parameters.
   05-FEB-2001  meshah      115.5           Added checkfile entry to the file.
   19-MAR-2001  meshah      115.6  2262842  Added business_group_id checking
                                            in the range and actio_creation
                                            cursor.
                                   2261018  Changed the date checking on the
                                            per_assignments_f table in the
                                            action_creation cursor.
   06-AUG-2002 rmonge       115.7  2447123  Changed action_type to varchar2(30)
   12-SEP-2002 irgonzal     115.8  2453584  Split action creation cursor in
                                            several cursors to avoid reading
                                            same objects twice.
   13-NOV-2002 irgonzal     115.9  2453584  Changed action creation cursors:
                                            modified condition that checks
                                            ppa.effective_date.
   18-MAY-2003 vgunasek     115.10 2938556  report rewrite including support for
   					    new balance reporting architecture (run
   					    balances) and multi threading.
   06-JUN-2003 vgunasek     115.11 2938556  Changed sort action code
   18-JUN-2003 kaverma      115.12 3015312  Modified action_creation code and broke
                                            cursor all for performance improvement.
   23-JUN-2003 kaverma      115.13 3018606  Modified insert_action to call load_data
                                            only if assignment_action_id is not null
   19-DEC-2003 kaverma      115.14 3326648  disabled index on ppa.effective date in
                                            cursor c_get_latest_asg
   15-JAN-2004 ardsouza     115.15 3361891  Modified 4 cursors to improve performance.
   14-MAR-2005 sackumar     115.16 4222032  Change in the Range Cursor removing redundant
					    use of bind Variable (:payroll_action_id)
   07-DEC-2005 sackumar     115.17 4748245  Changed the Range Cursor and Action_creation procedure
					    to improve the performance.
					    Also replaced the pay_us_over_limit_pkg.get_parameter
					    call to pay_us_payroll_utils.get_parameter call.
   18-APR-2007 sudedas      115.18 5840569  In case Range Person ID Functionality
                                            is disabled where conditions need to
                                            be added to action_creation procedure.
   29-OCT-2007 vaisriva     115.19 5717518  Cursor c_get_latest_asg has been modified to improve
                                            it's performance
--
*/
-------------------- range_cursor ---------------------------------------------
--
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
--
  leg_param    pay_payroll_actions.legislative_parameters%type;
  l_gre_id     number;
  l_loc_id     number;
  l_org_id     number;
  l_as_of_date varchar2(240);
  l_bg_id      pay_payroll_actions.business_group_id%type;
  where_condition varchar(5000);

--
--
begin
--    hr_utility.trace_on(null,'oracle');
    hr_utility.set_location('IN range_cursor',200);

    begin
      select ppa.legislative_parameters,
             ppa.business_group_id,
             pay_us_payroll_utils.get_parameter('GRE',ppa.legislative_parameters),
	     pay_us_payroll_utils.get_parameter('ORG',ppa.legislative_parameters),
             pay_us_payroll_utils.get_parameter('LOC',ppa.legislative_parameters),
             pay_us_payroll_utils.get_parameter('AS_OF_DATE',ppa.legislative_parameters)
         into leg_param,
              l_bg_id,
              l_gre_id,
	      l_org_id,
	      l_loc_id,
              l_as_of_date
      from pay_payroll_actions ppa
      where ppa.payroll_action_id = pactid;
    exception
       when others then
          hr_utility.trace('Legislative parameters not found for pactid '||to_char(pactid));
          --raise;
    end;

    where_condition := '';
    if l_gre_id is not null then
       where_condition :=where_condition||' and paa.tax_unit_id ='||l_gre_id;
    end if;
    if l_org_id is not null then
       where_condition :=where_condition||' and paf.organization_id ='||l_org_id;
    end if;
    if l_loc_id is not null then
       where_condition :=where_condition||' and paf.location_id ='||l_loc_id;
    end if;

hr_utility.trace('Range where condition='||where_condition);
hr_utility.trace('l_as_of_date='||l_as_of_date);
hr_utility.trace('l_bg_id='||l_bg_id);

    sqlstr := 'select /*+ ORDERED
               index(ppa PAY_PAYROLL_ACTIONS_N5)
               index(paa PAY_ASSIGNMENT_ACTIONS_N50)
               index(paf per_assignments_pk) */
	   distinct paf.person_id
    from
        pay_payroll_actions ppa,
        pay_assignment_actions paa,
        per_assignments_f paf
    where :payroll_action_id    is not null
       and paa.payroll_action_id = ppa.payroll_action_id
       and paa.action_status=''C''
       and ppa.action_type in (''B'', ''I'', ''R'', ''Q'', ''V'')
       and ppa.action_status = ''C''
       and paf.assignment_id = paa.assignment_id
       and ppa.effective_date between trunc(to_date('''||l_as_of_date||''',''YYYY/MM/DD''), ''Y'')
                                  and to_date('''||l_as_of_date||''',''YYYY/MM/DD'')
       and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
       and paf.business_group_id + 0 = '''||l_bg_id||'''
       '|| where_condition ||'
    order by paf.person_id';

  hr_utility.set_location('OUT range_cursor',250);
end range_cursor;
--
--------------------------- action_creation ---------------------------------
--
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) is

  leg_param    pay_payroll_actions.legislative_parameters%type;
  action_type     varchar2(30);
  l_as_of_date    varchar2(240);
--  l_date_prm      varchar2(50);
  l_gre_id        pay_assignment_actions.tax_unit_id%type;
  l_org_id        per_assignments_f.organization_id%type;
  l_loc_id        per_assignments_f.location_id%type;
  l_bg_id         per_assignments_f.business_group_id%type;
  l_tax_type      varchar2(100);

  l_per_id         per_assignments_f.person_id%type;
  l_ssn            per_people_f.national_identifier%type;
  l_state_code     pay_us_states.state_code%type;
  l_state_abbrev   pay_us_states.state_abbrev%type;


  lockingactid  number;
  lockedactid   number;
  assignid      number;
  greid         number;
  num           number;

  l_aaid      pay_assignment_actions.assignment_action_id%TYPE;
  l_tu_id     pay_assignment_actions.tax_unit_id%TYPE;
  l_person_id     per_people_f.person_id%TYPE;

  p_over_limit_flag            varchar2(1);
  sac_temp number;
  lv_where_condition           varchar2(5000) ;
--
cursor c_parameters ( pactid number) is
   select
         ppa.legislative_parameters,
         ppa.business_group_id,
         pay_us_payroll_utils.get_parameter('GRE',ppa.legislative_parameters),
         pay_us_payroll_utils.get_parameter('ORG',ppa.legislative_parameters),
         pay_us_payroll_utils.get_parameter('LOC',ppa.legislative_parameters),
         pay_us_payroll_utils.get_parameter('AS_OF_DATE',ppa.legislative_parameters),
         pay_us_payroll_utils.get_parameter('TAX_TYPE',ppa.legislative_parameters)
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

   l_prev_person_id         per_people_f.person_id%type;
   l_prev_tu_id             pay_assignment_actions.tax_unit_id%type;

--
-- #2453584: split cursors
-- The report is only getting the YTD values so we only need to get
-- the payroll actions which have been submitted in the year for
-- which the user is running the report.
-- So this condition was modified:
--            " ...and ppa.effective_date <= to_date(l_as_of_date,'YYYY/MM/DD') ..."
--
-- All the four cursors are splitted for performance improvement. (Bug: 3015312)
-- Bug 3361891 - All the four cursors are modified to improve performance.
-- Bug 4748245 - All the four cursors are removed and introduce a ref cursor

TYPE overlimit IS REF CURSOR;
c_seq_act overlimit;
lv_sqlstr varchar2(5000);
lv_org_condition varchar2(200);
lv_loc_condition varchar2(200);
lv_gre_condition varchar2(200);

ln_greid  number;
ln_personid number;
ln_assgid number;

-- Bug 4748245
--
-- #2453584
-- Bug# 3015312 -  Added cursor to improve the performance of the action_code
-- and modified the procedure

procedure insert_action(pactid        IN number
		       ,chunk         IN number
                       ,p_greid       IN number
                       ,p_person_id   IN per_all_people_f.person_id%type
                       ,p_assignid    IN number
                       ) is

-- Cursor to get the assignment actions
-- Bug 5717518: Cursor c_get_latest_asg has been modified to improve it's performance
cursor c_get_latest_asg(
         cp_person_id in number
	,cp_tax_unit_id in number
	,cp_as_of_date in varchar2
	,cp_assignid in number) is    -- Bug 5717518
   select /*+ ORDERED */
          to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id  -- Bug 5717518
     from per_all_assignments_f paf,
          pay_assignment_actions paa,
          pay_payroll_actions ppa,
          pay_action_classifications pac
    where paf.assignment_id = cp_assignid      -- Bug 5717518: New parameter added for performance improvement
      and paf.person_id = cp_person_id         -- Bug 5717518: Shuffled the Where Clause for performance improvement
      and paa.assignment_id = paf.assignment_id
      and paa.tax_unit_id = cp_tax_unit_id
      and paa.payroll_action_id = ppa.payroll_action_id
      and ((nvl(paa.run_type_id, ppa.run_type_id) is null
                and paa.source_action_id is null)
            or (nvl(paa.run_type_id, ppa.run_type_id) is not null
                and paa.source_action_id is not null )
            or (ppa.action_type = 'V' and ppa.run_type_id is null
                and paa.run_type_id is not null
                and paa.source_action_id is null))
      and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
      and ppa.effective_date between trunc(to_date(cp_as_of_date,'YYYY/MM/DD'), 'Y') -- Bug 3326648
                                 and to_date(cp_as_of_date,'YYYY/MM/DD')
      and ppa.action_type = pac.action_type
      and pac.classification_name = 'SEQUENCED';
-- End of Bug 5717518

l_max_asg_action_id number;

begin
      if ((l_prev_person_id = p_person_id) AND
          (l_prev_tu_id = p_greid)) then
         null;
      else
         l_prev_person_id := p_person_id;
         l_prev_tu_id     := p_greid;

         num := 0;
         num := num + 1;
         --
         -- Added the call as part of the bug # 2938556
         -- moved insertion of assignment action to this package.
	 -- Bug 5717518: Cursor c_get_latest_asg has been modified to improve it's performance
         open c_get_latest_asg(p_person_id,p_greid,l_as_of_date,p_assignid);
	 fetch c_get_latest_asg into l_max_asg_action_id;
         close c_get_latest_asg;
         if l_max_asg_action_id is not null then  --Bug3018606
           pay_us_over_limit_tax_rpt_pkg.load_data
					(pactid,
					 chunk,
					 p_assignid,
					 l_max_asg_action_id,--p_lockedactid (Bug3015312 )
					 p_greid
					);
         end if;
      end if;
      hr_utility.trace(' Actions found = '||to_char(num));
end insert_action;
--
--
--------------- Main Action Creation --------------------------------
begin
--hr_utility.trace_on(null,'oracle');

  hr_utility.set_location('IN action_creation',300);
  --
  open c_parameters(pactid);
  fetch c_parameters into leg_param,
                          l_bg_id,
                          l_gre_id,
                          l_org_id,
                          l_loc_id,
                          l_as_of_date,
                          l_tax_type;

  if c_parameters%notfound then
      hr_utility.trace('Legislative parameters not found for pactid '||pactid);
      close c_parameters;
      --raise;
  end if;
  close c_parameters;

  hr_utility.set_location('action creation after prm',301);
  hr_utility.trace('Parmeters: ');
  hr_utility.trace('      gre_id : '||to_char(l_gre_id));
  hr_utility.trace('      bg_id : '||to_char(l_bg_id));
  hr_utility.trace('   as of date: '||l_as_of_date);
  hr_utility.trace('    pactid   : '||to_char(pactid));
  hr_utility.trace('    chunk   : '||to_char(chunk));
  hr_utility.trace('    loc_id   : '||to_char(l_loc_id)); -- l_loc_id
  hr_utility.trace('    org_id   : '||to_char(l_org_id)); -- l_org_id
  hr_utility.trace('    stperson : '|| to_char(stperson));
  hr_utility.trace('   endperson : '|| to_char(endperson));

  hr_utility.set_location('action creation before ref cursor',302);
  --
if pay_ac_utility.range_person_on(
					    P_REPORT_TYPE => 'OLT',
					    P_REPORT_FORMAT => 'DEFAULT',
					    P_REPORT_QUALIFIER => 'DEFAULT',
					    P_REPORT_CATEGORY => 'REPORT'
					   ) then

  hr_utility.set_location('action creation before opening ref cursor',303);
  hr_utility.trace('Range Person id is ON');


  lv_sqlstr := 'select distinct paf.person_id person_id,
                paf.assignment_id,
                paa.tax_unit_id
     from per_assignments_f       paf,
          pay_assignment_actions  paa,
          pay_payroll_actions     ppa,
          PAY_POPULATION_RANGES   ppr
    where ppr.payroll_action_id = '|| pactid ||'
      and ppr.chunk_number = '|| chunk ||'
      and paf.person_id = ppr.person_id
      and paf.assignment_type      = ''E''
      and paa.assignment_id = paf.assignment_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.payroll_id = ppa.payroll_id
      and paf.payroll_id is not null
      and ppa.action_type in (''R'',''Q'',''V'',''B'',''I'')
      and paa.action_status = ''C''
      and ppa.business_group_id = '||l_bg_id ||'
      and paf.business_group_id = ppa.business_group_id
      and ppa.effective_date between trunc(to_date('''|| l_as_of_date ||''',''yyyy/mm/dd''), ''Y'')
                                    and to_date('''|| l_as_of_date || ''',''yyyy/mm/dd'')
      and ppa.effective_date between paf.effective_start_date
                                    and paf.effective_end_date
      order by 1, 3';
else

  hr_utility.set_location('action creation before opening ref cursor',304);
  hr_utility.trace('Range Person id is Off');

  -- 5840569
  lv_where_condition := '' ;
  if l_gre_id is not null then
     lv_where_condition := lv_where_condition||' and paa.tax_unit_id ='||l_gre_id ;
  end if;
  if l_org_id is not null then
     lv_where_condition := lv_where_condition||' and paf.organization_id ='||l_org_id ;
  end if;
  if l_loc_id is not null then
     lv_where_condition := lv_where_condition||' and paf.location_id ='||l_loc_id ;
  end if;
  hr_utility.trace('lv_where_condition :'||lv_where_condition) ;

  lv_sqlstr := 'select
		/*+ ORDERED
               index(ppa PAY_PAYROLL_ACTIONS_PK)
               index(paa PAY_ASSIGNMENT_ACTIONS_N51)
               index(paf PER_ASSIGNMENTS_N12) */
	       distinct paf.person_id person_id,
                paf.assignment_id,
                paa.tax_unit_id
     from per_assignments_f       paf,
          pay_assignment_actions  paa,
          pay_payroll_actions     ppa
    where paf.person_id between '|| stperson ||' and '|| endperson ||'
      and paf.assignment_type      = ''E''
      and paa.assignment_id = paf.assignment_id
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.payroll_id = ppa.payroll_id
      and paf.payroll_id is not null
      and ppa.action_type in (''R'',''Q'',''V'',''B'',''I'')
      and paa.action_status = ''C''
      and ppa.business_group_id = '||l_bg_id ||'
      and paf.business_group_id = ppa.business_group_id
      and ppa.effective_date between trunc(to_date('''|| l_as_of_date ||''',''yyyy/mm/dd''), ''Y'')
                                    and to_date('''|| l_as_of_date || ''',''yyyy/mm/dd'')
      and ppa.effective_date between paf.effective_start_date
                                    and paf.effective_end_date '||
      lv_where_condition ||
      ' order by 1, 3';
end if;

  hr_utility.set_location('action creation before opening ref cursor',305);
  open c_seq_act for lv_sqlstr;
  loop
    hr_utility.set_location('in ref cursor loop',310);
    fetch c_seq_act into ln_personid,ln_assgid,ln_greid;
    if c_seq_act%notfound then
       hr_utility.set_location('exiting from ref cursor loop',320);
       exit;
    end if;
    hr_utility.set_location('Insert action',320);
    hr_utility.trace('ln_personid='||ln_personid);
    hr_utility.trace('ln_assgid'||ln_assgid);
    hr_utility.trace('ln_greid='||ln_greid);

    insert_action(pactid        => pactid,
	           chunk         => chunk,
                   p_greid       => ln_greid,
                   p_person_id   => ln_personid,
                   p_assignid    => ln_assgid
                   );
  end loop;
  close c_seq_act;

  hr_utility.set_location('OUT action_creation',350);
end action_creation;
--
--
------------------------------ sort_action ------------------------------------
--
procedure sort_action
(
   pactid   in     varchar2,     /* payroll action id */
   sqlstr   in out nocopy varchar2,     /* string holding the sql statement */
   len      out    nocopy number        /* length of the sql string */
) is
--
  leg_param          pay_payroll_actions.legislative_parameters%type;
  l_sort1            varchar2(60);
  l_sort2            varchar2(60);
  l_sort3            varchar2(60);

cursor c_parameters ( pactid number) is
   select
        ppa.legislative_parameters,
        pay_us_payroll_utils.get_parameter('SORT1',ppa.legislative_parameters),
        pay_us_payroll_utils.get_parameter('SORT2',ppa.legislative_parameters),
        pay_us_payroll_utils.get_parameter('SORT3',ppa.legislative_parameters)
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;
--
begin
  hr_utility.set_location('IN sort_action',400);
  open c_parameters(pactid);
  fetch c_parameters into leg_param,
                          l_sort1,
                          l_sort2,
                          l_sort3;
  if c_parameters%notfound then
      hr_utility.trace('Legislative parameters not found for pactid '||pactid);
      close c_parameters;
      -- raise;
  end if;
  close c_parameters;
  --

  sqlstr :=
'SELECT paa.rowid
   FROM pay_payroll_actions ppa,
	pay_assignment_actions paa,
	per_all_assignments_f paf,
      	per_all_people_f ppf,
	hr_organization_units hou,
	hr_locations_all hl
   WHERE ppa.payroll_action_id = :pactid
   AND paa.payroll_action_id = ppa.payroll_action_id
   and paf.assignment_id = paa.assignment_id
   and paf.effective_start_date =
                           (select max(paf2.effective_start_date)
                              from per_all_assignments_f paf2
                             where paf2.assignment_id = paf.assignment_id
                               and paf2.effective_start_date <= ppa.effective_date)
   and   paf.assignment_type = ''E''
   and ppf.person_id = paf.person_id
   and ppa.effective_date between ppf.effective_start_date and ppf.effective_end_date
   and hou.organization_id = nvl(paf.organization_id,paf.business_group_id)
   and hl.location_id = NVL(paf.location_id,hou.location_id)
ORDER BY
  decode('''||l_sort1||''',
  ''Employee_Name'',rpad(ppf.last_name||'' ''||ppf.first_name||'' ''||ppf.middle_names, 63),
  ''Social_Security_Number'',rpad(ppf.national_identifier, 63),''Organization'', rpad(hou.name, 63),
  ''Location'',rpad(hl.location_code, 63)),
  decode('''||l_sort2||''',
  ''Employee_Name'',rpad(ppf.last_name||'' ''||ppf.first_name||'' ''||ppf.middle_names, 63),
  ''Social_Security_Number'',rpad(ppf.national_identifier, 63),''Organization'', rpad(hou.name, 63),
  ''Location'',rpad(hl.location_code, 63)),
  decode('''||l_sort3||''',
  ''Employee_Name'',rpad(ppf.last_name||'' ''||ppf.first_name||'' ''||ppf.middle_names, 63),
  ''Social_Security_Number'',rpad(ppf.national_identifier, 63),''Organization'', rpad(hou.name, 63),
  ''Location'',rpad(hl.location_code, 63))
	';
  len := length(sqlstr); -- return the length of the string.

  hr_utility.trace('Sort sql string length = '||to_char(len));
  hr_utility.set_location('OUT sort_action',450);
 -- hr_utility.trace_off;

end sort_action;

--
------------------------------ get_parameter ----------------------------------
--
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2
is
  start_ptr number;
  end_ptr   number;
  token_val pay_payroll_actions.legislative_parameters%type;
  par_value pay_payroll_actions.legislative_parameters%type;
begin
--
     token_val := name||'=';
--
     start_ptr := instr(parameter_list, token_val) + length(token_val);
     end_ptr := instr(parameter_list, ' ',start_ptr);
--
     /* if there is no spaces use then length of the string */
     if end_ptr = 0 then
        end_ptr := length(parameter_list)+1;
     end if;
--
     /* Did we find the token */
     if instr(parameter_list, token_val) = 0 then
       par_value := NULL;
     else
       par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
     end if;
--
     return par_value;
--
end get_parameter;
--
end pay_us_over_limit_pkg;

/
