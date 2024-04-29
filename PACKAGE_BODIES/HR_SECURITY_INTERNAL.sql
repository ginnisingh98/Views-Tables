--------------------------------------------------------
--  DDL for Package Body HR_SECURITY_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY_INTERNAL" as
/* $Header: pesecbsi.pkb 120.19.12010000.3 2009/05/26 07:22:17 rnemani ship $ */

--
-- Stores details of what security permission have been cached for a
-- particular person.
--
TYPE g_access_known_r IS RECORD
    (person_id           NUMBER
    ,user_id             NUMBER
    ,effective_date      DATE
    ,security_profile_id NUMBER
    ,org                 BOOLEAN DEFAULT FALSE
    ,pos                 BOOLEAN DEFAULT FALSE
    ,pay                 BOOLEAN DEFAULT FALSE
    ,per                 BOOLEAN DEFAULT FALSE);

--
-- Package Private Constants
--
g_PACKAGE   CONSTANT VARCHAR2(23) := 'hr_security_internal.';

--
-- Package Private Variables
--
g_access_known_rec g_access_known_r;
g_assignments_tbl  g_assignments_t;
g_debug            BOOLEAN      := hr_utility.debug_enabled;
g_session_context  NUMBER;

--
-- Proprietory debugging. Allows for concurrent request output, etc.
-- (see procedures "op").
--
g_dbg_type         NUMBER       := g_NO_DEBUG;
g_dbg              BOOLEAN      := g_debug;

--
-- ----------------------------------------------------------------------------
-- |------------------------< populate_new_payroll >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure populate_new_payroll
  (p_business_group_id             in     number
  ,p_payroll_id                     in     number) is
--
l_proc            varchar2(72) := g_package||'populate_new_payroll';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Insert new payroll into all payroll lists for all profiles which
  -- Restrict access to payrolls.
  --
  insert into pay_payroll_list (payroll_id, security_profile_id)
      select p_payroll_id, psp.security_profile_id
      from   per_security_profiles psp
      where  psp.view_all_flag     <> 'Y'
      and        ((    psp.view_all_payrolls_flag <> 'Y'
                   and business_group_id  = p_business_group_id)
              or  (    psp.view_all_payrolls_flag <> 'Y'
	           and business_group_id is null))
      and    not exists
             (select 1
              from   pay_payroll_list ppl
              where  ppl.security_profile_id = psp.security_profile_id
              and    ppl.payroll_id = p_payroll_id);

  hr_utility.set_location('Leaving:'|| l_proc, 30);
end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< populate_new_contact>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure populate_new_contact(
          p_business_group_id     in number
         ,p_person_id             in number
         ) is
  --
  l_proc     varchar2(72) := g_package||'populate_new_contact';
  l_prog_id  number(15)   := fnd_profile.value('CONC_PROGRAM_ID');
  l_req_id   number(15)   := fnd_profile.value('CONC_REQUEST_ID');
  l_appl_id  number(15)   := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
  l_upd_date date         := trunc(sysdate);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Insert new contact into all person lists for all profiles which:
  -- a) Restrict access to contacts
  -- b) No restriction for contacts but candidates are restricted.
  insert into per_person_list(person_id, security_profile_id, request_id
                             ,program_application_id, program_id
                             ,program_update_date)
         select p_person_id, psp.security_profile_id, l_req_id, l_appl_id,
                l_prog_id, l_upd_date
           from per_security_profiles psp
          where psp.view_all_flag <> 'Y'
            and (((psp.view_all_contacts_flag <> 'Y' or
                  (psp.view_all_contacts_flag = 'Y' and
                   psp.view_all_candidates_flag = 'X')) and
                   business_group_id  = p_business_group_id) or
                 ((psp.view_all_contacts_flag <> 'Y' or
                  (psp.view_all_contacts_flag = 'Y' and
                   psp.view_all_candidates_flag = 'X')) and
                   business_group_id is null))
            and not exists
                (select 1
                   from per_person_list ppl
                  where ppl.security_profile_id = psp.security_profile_id
                    and ppl.person_id = p_person_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_security.add_person(p_person_id);
  --
  hr_utility.set_location('Leaving:'|| l_proc, 30);
  --
end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< populate_new_person >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure populate_new_person
  (p_business_group_id             in     number
  ,p_person_id                     in     number) is
--
l_proc            varchar2(72) := g_package||'populate_new_person';
l_program_id number(15) := fnd_profile.value('CONC_PROGRAM_ID');
l_request_id number(15) := fnd_profile.value('CONC_REQUEST_ID');
l_program_application_id number(15) := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
l_update_date date := trunc(sysdate);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- insert the new person in to all person lists for all profiles
  -- for the business group and all global profiles which are restricted
  -- in someway but not if there are user-based restrictions because in this
  -- case there are no static lists maintained.
  --
  -- This is a change in behaviour arising from bug 2237407. Previously we only
  -- gave access to profiles which could see the business group. This caused
  -- problems where :
  --   a) profile is restrict by payroll but view all orgs(no records in org
  --      list so no match on the BG in the org list although that does not
  --      mean the BG is not visible)
  --   b) profile explicitly does not have access to BG(record goes out of scope
  --      immediately without giving the creator a chance to move person
  --      to correct org. This one is in the twilight zone, as the person will go
  --      invisible to the current user at the next LISTGEN run anyway)
  --
  INSERT INTO PER_PERSON_LIST
        (PERSON_ID
        ,SECURITY_PROFILE_ID
	,REQUEST_ID
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE)
      select p_person_id, psp.security_profile_id, l_request_id,
             l_program_application_id, l_program_id, l_update_date
      from   per_security_profiles psp
      where  psp.view_all_flag     <> 'Y'
      and        ((
                     (   (psp.view_all_organizations_flag <> 'Y' and
                          nvl(psp.top_organization_method, 'S') <> 'U')
                      or  psp.view_all_payrolls_flag      <> 'Y'
                      or (psp.view_all_positions_flag     <> 'Y' and
                          nvl(psp.top_position_method, 'S') <> 'U')
                     or   nvl(psp.custom_restriction_flag, 'N') = 'Y')
                 and  business_group_id  = p_business_group_id)
              or
	         (  (  psp.view_all_organizations_flag <> 'Y'
                  or  NVL(psp.custom_restriction_flag, 'N') = 'Y')
		  and business_group_id is null))
      and    not exists
             (select 1
              from   per_person_list ppl
              where  ppl.security_profile_id = psp.security_profile_id
              and    ppl.granted_user_id is null
              and    ppl.person_id = p_person_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_security.add_person(p_person_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
exception
  when NO_DATA_FOUND then
  hr_utility.set_location(l_proc, 30);
end populate_new_person;

-- ----------------------------------------------------------------------------
-- |-----------------------< clear_from_person_list >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_from_person_list
  (p_person_id             in     number) is
--
l_proc            varchar2(72) := g_package||'clear_person_list';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
-- remove the person from the list
    delete from per_person_list
    where person_id=p_person_id
    and security_profile_id is not null;
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_security.remove_person(p_person_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
exception
  when NO_DATA_FOUND then
  hr_utility.set_location(l_proc, 30);
end clear_from_person_list;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< evaluate_custom >----------------------------|
-- ----------------------------------------------------------------------------
--
function evaluate_custom
   (p_assignment_id    in number,
    p_restriction_text in varchar2,
    p_effective_date   in date)   return varchar2
is
  TYPE seccurtyp IS REF CURSOR;
  cursor_cv   seccurtyp;
  l_execution_stmt varchar2(5000);
  l_exec_str_print varchar2(5000);
  l_dummy number;
  --
  l_proc            varchar2(72) := g_package||'evaluate_custom';
  --
begin
  --
  --
  l_execution_stmt :=
       'select 1
        from   per_all_assignments_f    ASSIGNMENT,
	              per_all_people_f         PERSON,
	              per_person_type_usages_f PERSON_TYPE
        where  ASSIGNMENT.assignment_id = :asg_id
	and    to_date(:asg_eff_date,''dd-mon-yyyy'')
                         between ASSIGNMENT.effective_start_date
	                     and ASSIGNMENT.effective_end_date
	and    PERSON.person_id = ASSIGNMENT.person_id
 	and    to_date(:per_eff_date,''dd-mon-yyyy'')
                         between PERSON.effective_start_date
	                     and PERSON.effective_end_date
        and    PERSON.person_id = PERSON_TYPE.person_id
	and    to_date(:ptu_eff_date,''dd-mon-yyyy'')
                         between PERSON_TYPE.effective_start_date
	                     and PERSON_TYPE.effective_end_date';
  --
  -- Added as part of fix for bug 2506541
  --
  IF p_restriction_text IS NOT NULL THEN
    --
    --
    l_execution_stmt := l_execution_stmt||' and '||p_restriction_text;
    hr_utility.trace('Custom security is in use.');
    --
  END IF;
  --
  if g_debug then
    hr_utility.trace(P_restriction_text);
    l_exec_str_print:=l_execution_stmt;
    while length(l_exec_str_print)>0 loop
      hr_utility.trace(substr(l_exec_str_print,1,70));
      l_exec_str_print:=substr(l_exec_str_print,71);
    end loop;
  end if;

  open cursor_cv for l_execution_stmt
             using p_assignment_id, to_char(p_effective_date,'dd-mon-yyyy'),
	                            to_char(p_effective_date,'dd-mon-yyyy'),
	                            to_char(p_effective_date,'dd-mon-yyyy');
  fetch cursor_cv into l_dummy;
  if cursor_cv%notfound then
    close cursor_cv;
    return 'FALSE';
  end if;
  close cursor_cv;
  --
  return 'TRUE';
end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_to_person_list > --OVERLOAD---------------|
-- ----------------------------------------------------------------------------
--
procedure add_to_person_list(
          p_effective_date     in date
         ,p_assignment_id      in number
          ) is
  --
begin
  --
  -- Call main version of routine to define access for all profiles.
  add_to_person_list(p_effective_date    => p_effective_date,
                     p_assignment_id     => p_assignment_id,
                     p_business_group_id => null,
                     p_generation_scope  => 'ALL_PROFILES');
  --
end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< add_to_person_list >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_to_person_list(
          p_effective_date      in date
         ,p_assignment_id       in number
         ,p_business_group_id   in number   default null
         ,p_generation_scope    in varchar2 default 'ALL_PROFILES') is
  --
  cursor asg_details is
  select paf.person_id,
         paf.organization_id,
         paf.position_id,
         paf.payroll_id,
         paf.business_group_id,
         paf.assignment_type,
         ppf.current_employee_flag,
         ppf.current_npw_flag
    from per_all_assignments_f paf,
         per_all_people_f ppf
   where paf.assignment_id = p_assignment_id
     and p_effective_date between paf.effective_start_date
     and paf.effective_end_date
     and paf.person_id = ppf.person_id
     and p_effective_date between ppf.effective_start_date
     and ppf.effective_end_date;
  --
  l_person_id             per_all_assignments_f.person_id%type;
  l_organization_id       per_all_assignments_f.organization_id%type;
  l_position_id           per_all_assignments_f.position_id%type;
  l_payroll_id            per_all_assignments_f.payroll_id%type;
  l_business_group_id     per_all_assignments_f.business_group_id%type;
  l_assignment_type       per_all_assignments_f.assignment_type%type;
  l_current_employee_flag per_all_people_f.current_employee_flag%type;
  l_current_npw_flag      per_all_people_f.current_npw_flag%type;
  --
  l_program_id            number(15) := fnd_profile.value('CONC_PROGRAM_ID');
  l_request_id            number(15) := fnd_profile.value('CONC_REQUEST_ID');
  l_prog_appl_id          number(15) := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
  l_update_date           date       := trunc(sysdate);
  --
  l_proc                  varchar2(72) := g_package||'add_to_person_list';
  --
  l_bggr_str              varchar2(1000);
  l_asgt_str              varchar2(2000);
  l_from_str              varchar2(2000);
  l_inst_str              varchar2(3000);
  l_comm_str              varchar2(5000);
  l_cond_str              varchar2(5000);
  l_exec_str              varchar2(18000);
  l_exec_str_print        varchar2(18000);
  -- Declare the variables for the literal( for performance bug 5580144)
  l_all         varchar2(1) := 'Y';
  l_Restrict    varchar2(1) := 'N';
  l_none        varchar2(1) := 'X';
  l_U           varchar2(1) := 'U';
  l_S           varchar2(1) := 'S';
  l_true        varchar2(4) := 'TRUE';
  l_false       varchar2(5) := 'FALSE';
  --
  l_collection_index number:=0;

  -- This is used as a temp variable to collect the values for each Select Sql.
  TYPE l_security_profie_type_temp IS TABLE OF per_security_profiles.security_profile_id%TYPE INDEX BY BINARY_INTEGER;
  l_security_profie_table_temp l_security_profie_type_temp;

 -- This is used to store all the Records which need to be inserted after the
 -- completion of the bulk select.
  TYPE l_security_profie_type IS TABLE OF per_security_profiles.security_profile_id%TYPE INDEX BY BINARY_INTEGER;
  l_security_profie_table l_security_profie_type;

  -- This procedure is used to populate the final copy of the PL/Sql table
  -- before inserting the records in the table.

  PROCEDURE add_to_cache IS
  l_proc varchar2(100):= 'add_to_person_list.add_to_cache';
  Begin
   if g_debug then
     hr_utility.set_location('Entering '||l_proc, 10);
   End if;
    If  l_security_profie_table_temp.count > 0 then
    if g_debug then
     hr_utility.set_location(l_proc, 20);
    End if;
      for I in l_security_profie_table_temp.first .. l_security_profie_table_temp.last
      loop
       -- l_security_profie_table.extend;
       l_security_profie_table(l_collection_index + i):= l_security_profie_table_temp(i);
      end loop;
      l_collection_index := l_security_profie_table.last;
    End if;
    if g_debug then
     hr_utility.set_location('Leaveing '||l_proc, 30);
    End if;
  End;


 PROCEDURE INSERT_CACHE_TO_LIST IS
 errors		Number;
 l_cnt		Number;
 dml_errors	EXCEPTION;
 PRAGMA exception_init(dml_errors, -24381);
 l_proc varchar2(100):= 'add_to_person_list.insert_cache_to_list';
 Begin
 if g_debug then
  hr_utility.set_location('Entering '||l_proc, 10);
 End if;
   If l_security_profie_table.count > 0 then
     if g_debug then
       hr_utility.set_location(l_proc, 20);
     End if;
     forall per_rec in l_security_profie_table.first .. l_security_profie_table.last
     SAVE EXCEPTIONS
     Insert into per_person_list(security_profile_id,
                                 person_id,request_id,
                                 program_application_id,
                                 program_id,
                                 program_update_date)
                          values(l_security_profie_table(per_rec),
                                 l_person_id,
                                 nvl(l_request_id, ''),
                                 nvl(l_prog_appl_id, ''),
                                 nvl(l_program_id, ''),
                                 to_date(to_char(l_update_date,'dd/mm/yyyy'), 'dd/mm/yyyy')
                                 );
   End if;
   if g_debug then
    hr_utility.set_location('Leaveing '||l_proc, 30);
   End if;
 Exception
    WHEN dml_errors THEN
      errors := SQL%BULK_EXCEPTIONS.COUNT;
      l_cnt := l_cnt + errors;
      FOR i IN 1..errors LOOP
       If g_debug then
         hr_utility.trace ('Error occurred during iteration ' ||
         SQL%BULK_EXCEPTIONS(i).ERROR_INDEX ||' Oracle error is ' ||
         SQL%BULK_EXCEPTIONS(i).ERROR_CODE );
       End if;
       If SQL%BULK_EXCEPTIONS(i).ERROR_CODE <> 1 then
         raise;
       End if;
      End loop;
    WHEN OTHERS THEN
     raise;
 End;

Begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  open asg_details;
  fetch asg_details into
        l_person_id,
        l_organization_id,
        l_position_id,
        l_payroll_id,
        l_business_group_id,
        l_assignment_type,
        l_current_employee_flag,
        l_current_npw_flag;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_location('Program ID '|| to_char(l_program_id), 35);
  end if;
  --
  if(asg_details%found) then
    --
    close asg_details;
    --
    if p_generation_scope = 'ALL_BUS_GRP' then
       hr_utility.set_location(l_proc, 31);
       l_bggr_str := ' sec.business_group_id = :l_business_group_id  and ';
    end if;
    if p_generation_scope = 'ALL_GLOBAL' then
       hr_utility.set_location(l_proc, 32);
       l_bggr_str := ' sec.business_group_id is null and ';
    end if;
    if p_generation_scope = 'ALL_PROFILES' then
       hr_utility.set_location(l_proc, 33);
       l_bggr_str := ' (sec.business_group_id = :l_business_group_id
                       or sec.business_group_id is null) and ';
    end if;
    --
    if l_assignment_type = 'E' then
       hr_utility.set_location(l_proc, 34);
       l_asgt_str := ' (sec.view_all_employees_flag  = :l_Restrict or
                       (sec.view_all_employees_flag  = :l_all and
                       (sec.view_all_contacts_flag   = :l_Restrict or
                       (sec.view_all_contacts_flag   = :l_all and
                        sec.view_all_candidates_flag = :l_None)))) and ';
    end if;
    if l_assignment_type = 'C' then
       hr_utility.set_location(l_proc, 35);
       l_asgt_str := ' (sec.view_all_cwk_flag        = :l_Restrict or
                       (sec.view_all_cwk_flag        = :l_all and
                       (sec.view_all_contacts_flag   = :l_Restrict or
                       (sec.view_all_contacts_flag   = :l_all and
                        sec.view_all_candidates_flag = :l_None)))) and ';
    end if;
    if l_assignment_type = 'A' then
       hr_utility.set_location(l_proc, 36);
       l_asgt_str := ' (sec.view_all_applicants_flag = :l_Restrict or
                       (sec.view_all_applicants_flag = :l_all and
                       (sec.view_all_contacts_flag   = :l_Restrict or
                       (sec.view_all_contacts_flag   = :l_all and
                        sec.view_all_candidates_flag = :l_None)))) and ';
    end if;
    --
    l_inst_str := ' select sec.security_profile_id ';    --
    l_comm_str := ' decode(sec.custom_restriction_flag,:l_Restrict,:l_true,:l_U,:l_FALSE,
                    null,:l_true,hr_security_internal.evaluate_custom(
                    :p_assignment_id , sec.restriction_text,
                    to_date(to_char(:p_effective_date, ''dd/mm/yyyy'')
                    , ''dd/mm/yyyy''))) = :l_true and not exists (
                    select 1 from per_person_list ppl
                    where ppl.person_id = :l_person_id
                      and ppl.granted_user_id is null
                      and ppl.security_profile_id = sec.security_profile_id) ';
    -- if position is null
    if l_position_id is null then
      -- if position and payroll are null
      if l_payroll_id is null then
        --
        -- add to all lists with matching organization id     - A
        --
        -- The basic structure of all the select's in this procedure
        -- is indentical. The following comments apply to all statements.
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 40);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and org.organization_id = :l_organization_id
                          and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;

	if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
	   end loop;
	End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str
          bulk collect into l_security_profie_table_temp
          using
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_organization_id,  --l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
            l_U,                --l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
       else
           execute immediate l_exec_str
           bulk collect into l_security_profie_table_temp
           using
            l_business_group_id,--l_bggr_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_organization_id,  --l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
            l_U,                --l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
      end if;
           add_to_cache;
      exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 50);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 60);
            end if;
            raise;
       end;
        --
        -- add to all lists which don't care about organization  - B
        -- but do have restrictions on Position or Payroll
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 70);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and ((sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U)
                              or sec.view_all_payrolls_flag = :l_Restrict)
                          and sec.view_all_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
          -- execute immediate l_exec_str;
	 if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
          using
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_all,		--l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
            l_U,                --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_Restrict,         --l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;		--l_comm_str
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id,--l_bggr_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_all,		--l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
            l_U,                --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_Restrict,         --l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
      end if;
            add_to_cache;
           --
      exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 80);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 90);
            end if;
            raise;
        end;
        --
        -- add to all lists which don't care about organization,  - B1
        -- Position or Payroll but which do have a custom restriction.
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 100);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_all
                          and sec.custom_restriction_flag = :l_all
                          and sec.view_all_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	 if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_all,		--l_cond_str
            l_all,		--l_cond_str
            l_all,              --l_cond_str
            l_all,              --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_all,		--l_cond_str
            l_all,		--l_cond_str
            l_all,              --l_cond_str
            l_all,              --l_cond_str
	    l_Restrict,         --l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
      end if;
            add_to_cache;
           --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 110);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 120);
            end if;
            raise;
        end;
        --
      else -- position is null but payroll is not
        --
        -- add to all lists which have a matching org and payroll - C
        -- regardless of position restriction.
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 130);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               pay_payroll_list pay,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = org.security_profile_id
                          and org.organization_id = :l_organization_id
                         and pay.payroll_id = :l_payroll_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	 if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_organization_id,  --l_cond_str
            l_payroll_id,       --l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
	    l_U,		--l_cond_str
	    l_Restrict,		--l_cond_str
	    l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_organization_id,  --l_cond_str
            l_payroll_id,       --l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
	    l_U,		--l_cond_str
	    l_Restrict,		--l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 140);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 150);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by org and view all  - D
        -- payroll regardless of position restriction
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 160);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and org.organization_id = :l_organization_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_payrolls_flag = :l_all and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_organization_id,  --l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
	    l_U,		--l_cond_str
	    l_all,		--l_cond_str
	    l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_organization_id,  --l_cond_str
            l_Restrict,         --l_cond_str
            l_S,                --l_cond_str
	    l_U,		--l_cond_str
	    l_all,		--l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 170);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 180);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by payroll and view all - F
        -- org regardless of position.
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 190);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               pay_payroll_list pay ';
          --
          l_cond_str := ' pay.security_profile_id = sec.security_profile_id
                          and pay.payroll_id = :l_payroll_id
                         and sec.view_all_organizations_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_payroll_id,	--l_cond_str
	    l_all,		--l_cond_str
	    l_Restrict,         --l_cond_str
	    l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_Restrict,		--l_asgt_str
            l_all,		--l_asgt_str
            l_None,		--l_asgt_str
            l_payroll_id,	--l_cond_str
	    l_all,		--l_cond_str
	    l_Restrict,         --l_cond_str
            l_Restrict,		--l_comm_str
            l_true,		--l_comm_str
            l_U,		--l_comm_str
            l_FALSE,		--l_comm_str
            l_true,		--l_comm_str
            p_assignment_id,	--l_comm_str
            p_effective_date,	--l_comm_str
            l_true,		--l_comm_str
            l_person_id;	--l_comm_str
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 200);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 210);
            end if;
            raise;
        end;
        --
        -- add to lists which view all organization or payroll  - E
        -- and restrict by position
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 220);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_all
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and sec.view_all_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_S,        --l_cond_str
	    l_U,        --l_cond_str
	    l_Restrict,  --l_comm_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_S,        --l_cond_str
	    l_U,        --l_cond_str
	    l_Restrict,  --l_comm_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;

          --add_to_cache  (l_exec_str => l_exec_str);
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 230);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 240);
            end if;
            raise;
        end;
        --
      end if;
      --
      -- add to all lists which don't care about organization,  - E1
      -- Position or Payroll but which do have a custom restriction.
      begin
        --
        if g_debug then
          hr_utility.set_location(l_proc, 250);
        end if;
        --
        l_from_str := ' from per_security_profiles sec ';
        --
        l_cond_str := ' sec.view_all_organizations_flag = :l_all
                        and sec.view_all_positions_flag = :l_all
                        and sec.view_all_payrolls_flag = :l_all
                        and sec.custom_restriction_flag = :l_all
                        and sec.view_all_flag = :l_Restrict and ';
        --
        l_exec_str := l_inst_str||l_from_str||' where '||
                      l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
        --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict,         --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict,         --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
        --
      exception
        --
        -- If no data found handle exception so that other
        -- inserts can go ahead.
        --
        when no_data_found then
          if g_debug then
            hr_utility.set_location(l_proc, 260);
          end if;
          null;
        when others then
          if g_debug then
            hr_utility.set_location(l_proc, 270);
          end if;
          raise;
      end;
      --
    else -- position is not null
      --
      if l_payroll_id is null then
        -- position is not null but payroll is
        --
        -- add to lists which restrict by position and organization  - G
        -- regardless of payroll restriction
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 280);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_position_list posl,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and posl.security_profile_id = sec.security_profile_id
                          and posl.security_profile_id = org.security_profile_id
                          and org.organization_id = :l_organization_id
                         and posl.position_id = :l_position_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id,  --l_cond_str
	    l_position_id,  --l_cond_str
	    l_Restrict,  --l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id,  --l_cond_str
	    l_position_id,  --l_cond_str
	    l_Restrict,  --l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,         --l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 290);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 300);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by org and view all - H
        -- pos regardless of payroll
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 310);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and org.organization_id = :l_organization_id
                          and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_positions_flag = :l_all and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id,  --l_cond_str
	    l_Restrict,  --l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all, ----l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id,  --l_cond_str
	    l_Restrict,  --l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all, ----l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
	  --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 320);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 330);
            end if;
            raise;
        end;
        --
        -- add to lists which view all org and view all   - I
        -- pos and restrict by payroll
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 340);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_Restrict,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_Restrict,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 350);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 360);
            end if;
            raise;
        end;
        --
        -- add to lists which view all org, restrict by pos  - J
        -- regardless of payroll
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 370);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_position_list posl ';
          --
          l_cond_str := ' posl.security_profile_id = sec.security_profile_id
                          and posl.position_id = :l_position_id
                         and sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and sec.view_all_flag = :l_Restrict
                          and sec.business_group_id = :l_business_group_id
                         and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_position_id, ----l_cond_str
	    l_all, ----l_cond_str
	    l_Restrict,  --l_cond_str
	    l_S,      --l_cond_str
	    l_U,       --l_cond_str
	    l_Restrict,  --l_cond_str
	    l_business_group_id, --l_cond_str


	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_position_id, ----l_cond_str
	    l_all, ----l_cond_str
	    l_Restrict,  --l_cond_str
	    l_S,      --l_cond_str
	    l_U,       --l_cond_str
	    l_Restrict,  --l_cond_str
	    l_business_group_id, --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 380);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 390);
            end if;
            raise;
        end;
        --
        -- add to all lists which don't care about organization,  - J1
        -- Position or Payroll but which do have a custom restriction.
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 400);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_all
                          and sec.custom_restriction_flag = :l_all
                          and sec.view_all_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_Restrict,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_all, ----l_cond_str
	    l_Restrict,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 410);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 420);
            end if;
            raise;
        end;
        --
      else -- position and payroll are not null
        --
        -- add to lists which restrict by Org, Pos and Payroll   - K
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 430);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               pay_payroll_list pay,
                               per_position_list posl,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and posl.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = posl.security_profile_id
                          and pay.security_profile_id = org.security_profile_id
                          and org.security_profile_id = posl.security_profile_id
                          and org.organization_id = :l_organization_id
                         and posl.position_id = :l_position_id
                         and pay.payroll_id = :l_payroll_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_position_id, ----l_cond_str
	    l_payroll_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_position_id, ----l_cond_str
	    l_payroll_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 440);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 450);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by Org and Pos and view all  - L
        -- payroll
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 460);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_position_list posl,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and posl.security_profile_id = sec.security_profile_id
                          and posl.security_profile_id = org.security_profile_id
                          and org.organization_id = :l_organization_id
                         and posl.position_id = :l_position_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and sec.view_all_payrolls_flag = :l_all and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_position_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_position_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 470);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 480);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by org and payroll and view all  - M
        -- positions
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 490);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               pay_payroll_list pay,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = sec.security_profile_id
                          and org.organization_id = :l_organization_id
                         and pay.payroll_id = :l_payroll_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_payroll_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,
	    l_Restrict,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_payroll_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,
	    l_Restrict,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 500);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 510);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by pos and pay and view all  - O
        -- org
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 520);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               pay_payroll_list pay,
                               per_position_list posl ';
          --
          l_cond_str := ' posl.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = sec.security_profile_id
                          and pay.security_profile_id = posl.security_profile_id
                          and posl.position_id = :l_position_id
                         and pay.payroll_id = :l_payroll_id
                         and sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_position_id, ----l_cond_str
	    l_payroll_id, ----l_cond_str
	    l_all,
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_position_id, ----l_cond_str
	    l_payroll_id, ----l_cond_str
	    l_all,
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_Restrict,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 530);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 540);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by org and view all  - P
        -- position or payroll
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 550);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_organization_list org ';
          --
          l_cond_str := ' org.security_profile_id = sec.security_profile_id
                          and org.organization_id = :l_organization_id
                         and sec.view_all_organizations_flag = :l_Restrict
                          and nvl(sec.top_organization_method, :l_S) <> :l_U
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_all and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          -- execute immediate l_exec_str
	  execute immediate l_exec_str bulk collect into l_security_profie_table_temp -- 6368698
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str


	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp -- 6368698
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_organization_id, ----l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 560);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 570);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict by pos and view all    - Q
        -- organization and payroll
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 580);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               per_position_list posl ';
          --
          l_cond_str := ' posl.security_profile_id = sec.security_profile_id
                          and posl.position_id = :l_position_id
                         and sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_Restrict
                          and nvl(sec.top_position_method, :l_S) <> :l_U
                          and sec.view_all_payrolls_flag = :l_all and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp -- 6368698
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_position_id, ----l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,  --l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_position_id, ----l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str
	    l_S,  --l_cond_str
	    l_U,  --l_cond_str
	    l_all,  --l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
         --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 590);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 600);
            end if;
            raise;
        end;
        --
        -- add to lists which restrict bypayroll and view all - R
        -- organization and position
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 610);
          end if;
          --
          l_from_str := ' from per_security_profiles sec,
                               pay_payroll_list pay ';
          --
          l_cond_str := ' pay.security_profile_id = sec.security_profile_id
                          and pay.payroll_id = :l_payroll_id
                         and sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_payroll_id, ----l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_payroll_id, ----l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 620);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 630);
            end if;
            raise;
        end;
        --
        -- add to any profiles which don't care about org/pos/pay and
        -- which have a custom restriction.                            - N
        --
        -- Those view alls without a custom restriction are handled
        -- by the secure view and so don't need a person list. This with
        -- a custom restriction do however need person list data
        --
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 640);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_all
                          and sec.custom_restriction_flag = :l_all
                          and sec.view_all_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||
                        ' hr_security_internal.evaluate_custom(
                        :p_assignment_id,sec.restriction_text,
                        to_date(to_char(:p_effective_date, ''dd/mm/yyyy'')
                        , ''dd/mm/yyyy'')) = :l_true and not exists (
                        select 1 from per_person_list ppl
                        where ppl.person_id =:l_person_id
                       and ppl.security_profile_id = sec.security_profile_id)';
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str
	    p_assignment_id,
	    p_effective_date,
	    l_true,
	    l_person_id
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str
	    p_assignment_id,
	    p_effective_date,
	    l_true,
	    l_person_id
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 650);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 660);
            end if;
            raise;
        end;
        --
        -- add to all lists which don't care about organization,  - N1
        -- Position or Payroll but which do have a custom restriction.
        begin
          --
          if g_debug then
            hr_utility.set_location(l_proc, 670);
          end if;
          --
          l_from_str := ' from per_security_profiles sec ';
          --
          l_cond_str := ' sec.view_all_organizations_flag = :l_all
                          and sec.view_all_positions_flag = :l_all
                          and sec.view_all_payrolls_flag = :l_all
                          and sec.custom_restriction_flag = :l_all
                          and sec.view_all_flag = :l_Restrict and ';
          --
          l_exec_str := l_inst_str||l_from_str||' where '||
                        l_bggr_str||l_asgt_str||l_cond_str||l_comm_str;
          --
	  if g_debug then
	    l_exec_str_print:= l_exec_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
            end loop;
         End if;
	if p_generation_scope = 'ALL_GLOBAL' then
          execute immediate l_exec_str bulk collect into l_security_profie_table_temp
             using
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str

	    l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
       else
           execute immediate l_exec_str bulk collect into l_security_profie_table_temp
            using
            l_business_group_id, --l_bggr_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_Restrict,	 --l_asgt_str
            l_all,		 --l_asgt_str
            l_None,      --l_asgt_str

	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_all,  --l_cond_str
	    l_Restrict, ----l_cond_str

            l_Restrict,  --l_comm_str
            l_true,      --l_comm_str
            l_U,         --l_comm_str
            l_FALSE,     --l_comm_str
            l_true,      --l_comm_str
            p_assignment_id, --l_comm_str
            p_effective_date, --l_comm_str
            l_true,           --l_comm_str
            l_person_id      --l_comm_str
            ;
      end if;
            add_to_cache;
          --
        exception
          --
          -- If no data found handle exception so that other
          -- inserts can go ahead.
          --
          when no_data_found then
            if g_debug then
              hr_utility.set_location(l_proc, 680);
            end if;
            null;
          when others then
            if g_debug then
              hr_utility.set_location(l_proc, 690);
            end if;
            raise;
        end;
        --
      end if;
      --
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 700);
    end if;
  --
  else
    close asg_details;
  end if;

  if g_debug then
    hr_utility.set_location(l_proc, 705);
  end if;
  insert_cache_to_list;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 710);
  end if;
  --
  hr_security.add_person(l_person_id);
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 720);
  end if;
  --
exception
  when no_data_found then
    if g_debug then
      hr_utility.set_location(l_proc, 730);
    end if;
  --
end add_to_person_list;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< clear_from_person_list_changes >--------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_from_person_list_changes
  (p_person_id             in     number) is
--
l_proc            varchar2(72) := g_package||'clear_from_person_list_changes';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Stubbed out as part of Ex-Person security enhancements.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end clear_from_person_list_changes;
--
-- ----------------------------------------------------------------------------
-- |-------------------< re_enter_person_list_changes >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure re_enter_person_list_changes
  (p_person_id             in     number) is
--
l_proc            varchar2(72) := g_package||'re_enter_person_list_changes';
--
cursor asg_details is
select asg.person_id
,      asg.organization_id
,      asg.position_id
,      asg.payroll_id
,      asg.business_group_id
from   per_all_assignments_f asg
where  asg.person_id=p_person_id
and    ( (asg.assignment_type='E'
and       asg.effective_end_date = (select max(p.actual_termination_date)
                                    from per_periods_of_service p
                                    where p.person_id = p_person_id)
          ) or
         (asg.assignment_type='A'
          and asg.effective_end_date = (select max(ap.date_end)
                                        from   per_applications ap
                                        where  ap.person_id = p_person_id)
       ) );
--
l_person_id       per_assignments_f.person_id%TYPE;
l_organization_id per_assignments_f.organization_id%TYPE;
l_position_id     per_assignments_f.position_id%TYPE;
l_payroll_id      per_assignments_f.payroll_id%TYPE;
l_business_group_id per_assignments_f.business_group_id%TYPE;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Stubbed out as part of Ex-Person security enhancements.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
end re_enter_person_list_changes;
--
-- ----------------------------------------------------------------------------
-- |----------------------< copy_to_person_list_changes >---------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_to_person_list_changes
  (p_person_id             in     number) is
  --
l_proc              varchar2(72) := g_package||'copy_to_person_list_changes';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Stubbed out as part of Ex-Person security enhancements.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when NO_DATA_FOUND then
  hr_utility.set_location(l_proc, 30);
end copy_to_person_list_changes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< grant_access_to_person >------------------------|
-- ----------------------------------------------------------------------------
--
procedure grant_access_to_person
  (p_person_id             in     number
  ,p_granted_user_id       in     number) is
--
l_proc              varchar2(72) := g_package||'grant_access_to_person';
--
cursor chk_person_id is
select 1
from per_all_people_f
where person_id=p_person_id;
--
cursor chk_user_id is
select 1
from fnd_user
where user_id=p_granted_user_id;
--
-- Bug 3770018
--  Now that user based security profiles use the granted_user_id
--  column, the security_profile_id value should be checked.
--  Interestingly revoke_access_from_person was taken care of
--  presumably as part of the user based security changes.
--
cursor chk_person_list is
select 1
from per_person_list
where person_id = p_person_id
and granted_user_id = p_granted_user_id
and security_profile_id is null;
--
l_dummy number;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open chk_person_id;
  fetch chk_person_id into l_dummy;
  if chk_person_id%notfound then
    close chk_person_id;
    hr_utility.set_message(800, 'PER_52656_INVALID_PERSON_ID');
    hr_utility.raise_error;
  else
    close chk_person_id;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  open chk_user_id;
  fetch chk_user_id into l_dummy;
  if chk_user_id%notfound then
    close chk_user_id;
    hr_utility.set_message(800, 'PER_52672_INVALID_USER_ID');
    hr_utility.raise_error;
  else
    close chk_user_id;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Bug fix 1680524
  --
  open chk_person_list;
  fetch chk_person_list into l_dummy;
  if chk_person_list%notfound then
    close chk_person_list;
    INSERT INTO PER_PERSON_LIST
        (PERSON_ID
	,GRANTED_USER_ID)
    values
      (p_person_id
      ,p_granted_user_id);
  else
    close chk_person_list;
  end if;
 --
  hr_utility.set_location('Leaving: '||l_proc, 40);
  --
end grant_access_to_person;
--
-- ----------------------------------------------------------------------------
-- |----------------------< revoke_access_from_person >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure revoke_access_from_person
  (p_person_id             in     number
  ,p_granted_user_id       in     number default NULL) is
--
l_proc              varchar2(72) := g_package||'revoke_access_from_person';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_granted_user_id is not null
  then
    --
    -- If a user id is passed then revoke access for just that user
    --
    delete from per_person_list
    where person_id=p_person_id
    and   granted_user_id =p_granted_user_id
    and   security_profile_id is null;
  else
    --
    -- else revoke access for all users.
    --
    delete from per_person_list
    where  person_id = p_person_id
      and  granted_user_id is not null
      and  security_profile_id is null;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
end revoke_access_from_person;
--
-- ----------------------------------------------------------------------------
-- |----------------------< op >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE op
    (p_msg            IN VARCHAR2)
IS

    l_msg VARCHAR2(32000) := p_msg;

BEGIN

    IF g_dbg_type IS NOT NULL AND l_msg IS NOT NULL THEN

        --
        -- Break the output into chunks of 70 characters.
        --
        WHILE LENGTH(l_msg) > 0 LOOP

            IF g_dbg_type = g_PIPE OR g_debug THEN
                hr_utility.trace(SUBSTR(l_msg, 1, 70));
            ELSIF g_dbg_type = g_FND_LOG THEN
                fnd_file.put_line(FND_FILE.log, SUBSTR(l_msg, 1, 70));
            END IF;

            l_msg := SUBSTR(l_msg, 71);

        END LOOP;

    END IF;

END op;
--
-- ----------------------------------------------------------------------------
-- |----------------------< op >----------------------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE op
    (p_msg            IN VARCHAR2
    ,p_location       IN NUMBER)
IS

    l_msg VARCHAR2(32000) := p_msg;

BEGIN

    IF g_dbg_type IS NOT NULL AND p_msg IS NOT NULL AND
       p_location IS NOT NULL THEN
        --
        -- Break the output into chunks of 70 characters.
        --
        WHILE LENGTH(l_msg) > 0 LOOP

            IF g_dbg_type = g_PIPE OR g_debug THEN
                hr_utility.set_location(SUBSTR(l_msg, 1, 70), p_location);
            ELSIF g_dbg_type = g_FND_LOG THEN
                fnd_file.put_line(FND_FILE.log, SUBSTR(l_msg, 1, 70)
                                               ||', '||to_char(p_location));
            END IF;

            l_msg := SUBSTR(l_msg, 71);

        END LOOP;

    END IF;

END op;
--
-- ----------------------------------------------------------------------------
-- |----------------------< session_context_changed >-------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION session_context_changed
RETURN BOOLEAN IS

BEGIN

    --
    -- Check whether the local cached version of the session context
    -- differs to the AOL session context.
    -- This is the most aggressive form of session change identification
    -- as the session_context should increment for each
    -- fnd_global.apps_initialise call.
    --
    -- This procedure is used primarily for ADF applications, where database
    -- sessions (and therefore cached PL/SQL values) are pooled and can
    -- be reused by a user that may have entirely different security permissions
    -- and contexts (such as fnd profile options).
    --
    -- This is not relevant for PUI applications and new database sessions are
    -- always created, not reused.
    --
    -- No debug output is added here because this is called in each
    -- iteration of the secure view.
    --
    IF g_session_context IS NULL OR
       fnd_global.session_context IS NULL OR
       g_session_context <> fnd_global.session_context THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END session_context_changed;
--
-- ----------------------------------------------------------------------------
-- |----------------------< sync_session_context >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE sync_session_context
IS

BEGIN

    --
    -- Cache the AOL session context locally.
    --
    g_session_context := fnd_global.session_context;

END sync_session_context;
--
-- ----------------------------------------------------------------------------
-- |----------------------< restricted_orgs >---------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION restricted_orgs
    (p_sec_prof_rec   IN g_sec_prof_r)
RETURN BOOLEAN IS

BEGIN

    --
    -- Protect against null parameters.
    --
    IF p_sec_prof_rec.security_profile_id IS NOT NULL THEN

        IF p_sec_prof_rec.view_all_flag = 'N' AND
           p_sec_prof_rec.view_all_organizations_flag = 'N' AND
           p_sec_prof_rec.org_security_mode = 'HIER' THEN
            RETURN TRUE;
        END IF;

    END IF;

    RETURN FALSE;

END restricted_orgs;
--
-- ----------------------------------------------------------------------------
-- |----------------------< restricted_pos >----------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION restricted_pos
    (p_sec_prof_rec   IN g_sec_prof_r)
RETURN BOOLEAN IS

BEGIN

    --
    -- Protect against null parameters.
    --
    IF p_sec_prof_rec.security_profile_id IS NOT NULL THEN

        IF p_sec_prof_rec.view_all_flag = 'N' AND
           p_sec_prof_rec.view_all_positions_flag = 'N' THEN
            RETURN TRUE;
        END IF;

    END IF;

    RETURN FALSE;

END restricted_pos;
--
-- ----------------------------------------------------------------------------
-- |----------------------< restricted_pays >---------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION restricted_pays
    (p_sec_prof_rec   IN g_sec_prof_r)
RETURN BOOLEAN IS

BEGIN

    --
    -- Protect against null parameters.
    --
    IF p_sec_prof_rec.security_profile_id IS NOT NULL THEN

        IF p_sec_prof_rec.view_all_flag = 'N' AND
           p_sec_prof_rec.view_all_payrolls_flag = 'N' THEN
            RETURN TRUE;
        END IF;

    END IF;

    RETURN FALSE;

END restricted_pays;
--
-- ----------------------------------------------------------------------------
-- |----------------------< restricted_pers >---------------------------------|
-- ----------------------------------------------------------------------------
--
function restricted_pers(p_sec_prof_rec in g_sec_prof_r)
         return boolean is
  --
begin
  -- Protect against null parameters.
  if p_sec_prof_rec.security_profile_id is not null then
    -- Determine whether this security profile can see everyone
    -- without needing to evaluate permissions person by person.
    if p_sec_prof_rec.view_all_flag                = 'N'  and
      (p_sec_prof_rec.view_all_employees_flag     <> 'Y'  or
       p_sec_prof_rec.view_all_cwk_flag           <> 'Y'  or
       p_sec_prof_rec.view_all_applicants_flag    <> 'Y'  or
       p_sec_prof_rec.view_all_contacts_flag      <> 'Y'  or
       p_sec_prof_rec.view_all_candidates_flag    <> 'Y') and
      (restricted_orgs(p_sec_prof_rec)                    or
       restricted_pos (p_sec_prof_rec)                    or
       restricted_pays(p_sec_prof_rec)                    or
       p_sec_prof_rec.restrict_by_supervisor_flag <> 'N'  or
       p_sec_prof_rec.custom_restriction_flag     <> 'N'  or
       p_sec_prof_rec.exclude_person_flag         <> 'N'  or
       p_sec_prof_rec.named_person_id is not null) then
      --
      return true;
      --
    end if;
    --
  end if;
  --
  return false;
  --
end restricted_pers;
--
-- ----------------------------------------------------------------------------
-- |----------------------< show_organization >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION show_organization
    (p_organization_id IN NUMBER)
RETURN VARCHAR2 IS

BEGIN

    --
    -- Protect against incorrect passed parameters.
    --
    IF p_organization_id IS NOT NULL THEN
        --
        -- Check the org is in the cache.  Note that this function assumes
        -- that this is a restricted profile and assumes the relevant
        -- view all flags have been checked as a pre-requisite.
        --
        IF g_org_tbl.EXISTS(p_organization_id) THEN
            RETURN 'TRUE';
        END IF;
    END IF;

    RETURN 'FALSE';

END show_organization;
--
-- ----------------------------------------------------------------------------
-- |----------------------< show_position >-----------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION show_position
    (p_position_id IN NUMBER)
RETURN VARCHAR2 IS

BEGIN

    --
    -- Protect against incorrect passed parameters.
    --
    IF p_position_id IS NOT NULL THEN
        --
        -- Check the pos is in the cache.  Note that this function assumes
        -- that this is a restricted profile and assumes the relevant
        -- view all flags have been checked as a pre-requisite.
        --
        IF g_pos_tbl.EXISTS(p_position_id) THEN
            RETURN 'TRUE';
        END IF;
    END IF;

    RETURN 'FALSE';

END show_position;
--
-- ----------------------------------------------------------------------------
-- |----------------------< show_payroll >------------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION show_payroll
    (p_payroll_id IN NUMBER)
RETURN VARCHAR2 IS

BEGIN

    --
    -- Protect against incorrect passed parameters.
    --
    IF p_payroll_id IS NOT NULL THEN
        --
        -- Check the pay is in the cache.  Note that this function assumes
        -- that this is a restricted profile and assumes the relevant
        -- view all flags have been checked as a pre-requisite.
        --
        IF g_pay_tbl.EXISTS(p_payroll_id) THEN
            RETURN 'TRUE';
        END IF;
    END IF;

    RETURN 'FALSE';

END show_payroll;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_assignments >---------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_assignments
    (p_person_id      IN NUMBER
    ,p_effective_date IN DATE)
RETURN g_assignments_t IS

    --
    -- Local variable declarations.
    --
    l_assignments_tbl g_assignments_t;
    l_already_cached  BOOLEAN      := FALSE;
    l_proc            VARCHAR2(72) := g_package||'get_assignments';
    j                 NUMBER       := 1;

    --
    -- Fetches the assignments for the given person.
    -- Applicant and Benefits assignments are excluded
    -- as these types of assignments do not have any
    -- user permissions.
    --
    CURSOR csr_assignments_for_per IS
    SELECT *
    FROM   per_all_assignments_f paaf
    WHERE  paaf.person_id = p_person_id
    AND    p_effective_date BETWEEN
           paaf.effective_start_date AND paaf.effective_end_date
    AND    paaf.assignment_type NOT IN ('A','B');

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Protect against the in parameters being null.
    --
    IF p_person_id IS NOT NULL AND p_effective_date IS NOT NULL THEN
        --
        -- Look for the person in the existing cache. If they exist
        -- get the assignment details from the cache, otherwise
        -- fetch the details and cache them.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF g_assignments_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the varray to see if this person's
            -- details are already cached.
            --
            -- An Oracle 9i feature that could be used here (but cannot
            -- at the time of writing this because 8i is supported in 11i)
            -- is nested PL/SQL collections: nesting a table of assignments
            -- within a table of people.  This would enhance performance
            -- if the index was the assignment_id for the assignment
            -- collection and the person_id for the person collection
            -- because the person_id is known, so it would be possible
            -- to directly access all assignments for a person without
            -- running through the table of people.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            FOR i IN g_assignments_tbl.FIRST..g_assignments_tbl.LAST LOOP
                IF p_person_id = g_assignments_tbl(i).person_id THEN
                    l_assignments_tbl(j) := g_assignments_tbl(i);
                    j := j + 1;
                    l_already_cached := TRUE;
                END IF;
            END LOOP;
        END IF;

        IF g_dbg THEN op(l_proc, 40); END IF;

        IF NOT l_already_cached THEN
            --
            -- Fetch the assignments.  Bulk collect would not perform better
            -- considering the number of assignments a person will typically
            -- have: few.  As Oracle 8i is still supported at the time of
            -- writing, it is not possible to bulk collect into a collection
            -- so instead it would be necessary to fetch into individual
            -- collections of scalars if bulk collect was to be used.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;
            j := 1;
            FOR asg_rec IN csr_assignments_for_per LOOP
                l_assignments_tbl(j) := asg_rec;
                g_assignments_tbl(g_assignments_tbl.COUNT + 1) := asg_rec;
                j := j + 1;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN l_assignments_tbl;

END get_assignments;
--
-- ----------------------------------------------------------------------------
-- |----------------------< org_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION org_access_known
RETURN BOOLEAN IS

BEGIN

    --
    -- In a session pooling environment, database sessions are re-used and
    -- session cache is not necessarily flushed out of memory, so if the
    -- apps_initialise session has changed this should trigger a re-evaluation
    -- of security permissions and this should return FALSE.
    --
    IF session_context_changed THEN
        RETURN FALSE;
    END IF;

    --
    -- The session is current, so return the global flag that indicates whether
    -- organization security permissions are known for the user currently cached
    -- in memory.
    --
    -- No debug output is added here because this is called in each
    -- iteration of the secure view.
    --
    RETURN g_access_known_rec.org;

END org_access_known;
--
-- ----------------------------------------------------------------------------
-- |----------------------< pos_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION pos_access_known
RETURN BOOLEAN IS

BEGIN

    --
    -- In a session pooling environment, database sessions are re-used and
    -- session cache is not necessarily flushed out of memory, so if the
    -- apps_initialise session has changed this should trigger a re-evaluation
    -- of security permissions and this should return FALSE.
    --
    IF session_context_changed THEN
        RETURN FALSE;
    END IF;

    --
    -- The session is current, so return the global flag that indicates
    -- whether position security permissions are known for the user
    -- currently cached in memory.
    --
    -- No debug output is added here because this is called in each
    -- iteration of the secure view.
    --
    RETURN g_access_known_rec.pos;

END pos_access_known;
--
-- ----------------------------------------------------------------------------
-- |----------------------< pay_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION pay_access_known
RETURN BOOLEAN IS

BEGIN

    --
    -- In a session pooling environment, database sessions are re-used and
    -- session cache is not necessarily flushed out of memory, so if the
    -- apps_initialise session has changed this should trigger a re-evaluation
    -- of security permissions and this should return FALSE.
    --
    IF session_context_changed THEN
        RETURN FALSE;
    END IF;

    --
    -- The session is current, so return the global flag that indicates
    -- whether payroll security permissions are known for the user
    -- currently cached in memory.
    --
    -- No debug output is added here because this is called in each
    -- iteration of the secure view.
    --
    RETURN g_access_known_rec.pay;

END pay_access_known;
--
-- ----------------------------------------------------------------------------
-- |----------------------< per_access_known >--------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION per_access_known
RETURN BOOLEAN IS

BEGIN

    --
    -- In a session pooling environment, database sessions are re-used and
    -- session cache is not necessarily flushed out of memory, so if the
    -- apps_initialise session has changed this should trigger a re-evaluation
    -- of security permissions and this should return FALSE.
    --
    IF session_context_changed THEN
        RETURN FALSE;
    END IF;

    --
    -- The session is current, so return the global flag that indicates whether
    -- person security permissions are known for the user currently cached
    -- in memory.
    --
    -- No debug output is added here because this is called in each
    -- iteration of the secure view.
    --
    RETURN g_access_known_rec.per;

END per_access_known;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_org_structure_version >-----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_org_structure_version
    (p_organization_structure_id IN NUMBER
    ,p_effective_date            IN DATE)
RETURN NUMBER IS

    --
    -- Local variables.
    --
    l_org_structure_version_id NUMBER;
    l_proc     VARCHAR2(72) := g_package||'get_org_structure_version';

    --
    -- Get the effective hierarchy version for the given hierarchy
    -- structure.
    --
    CURSOR csr_get_hier_ver IS
    SELECT posv.org_structure_version_id
    FROM   per_org_structure_versions posv
    WHERE  posv.organization_structure_id = p_organization_structure_id
    AND    p_effective_date BETWEEN
           posv.date_from AND NVL(posv.date_to, hr_general.end_of_time);

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_organization_structure_id IS NOT NULL AND
       p_effective_date IS NOT NULL THEN
        --
        -- Fetch the hierarchy version.  This will not return a row
        -- if there is no effective hierarchy version.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        OPEN  csr_get_hier_ver;
        FETCH csr_get_hier_ver INTO l_org_structure_version_id;
        CLOSE csr_get_hier_ver;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN l_org_structure_version_id;

END get_org_structure_version;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_pos_structure_version >-----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_pos_structure_version
    (p_position_structure_id     IN NUMBER
    ,p_effective_date            IN DATE)
RETURN NUMBER IS

    --
    -- Local variables.
    --
    l_pos_structure_version_id NUMBER;
    l_proc     VARCHAR2(72) := g_package||'get_pos_structure_version';

    --
    -- Get the effective hierarchy version for the given hierarchy
    -- structure.
    --
    CURSOR csr_get_hier_ver IS
    SELECT ppsv.pos_structure_version_id
    FROM   per_pos_structure_versions ppsv
    WHERE  ppsv.position_structure_id = p_position_structure_id
    AND    p_effective_date BETWEEN
           ppsv.date_from AND NVL(ppsv.date_to, hr_general.end_of_time);

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_position_structure_id IS NOT NULL AND
       p_effective_date IS NOT NULL THEN
        --
        -- Fetch the hierarchy version.  This will not return a row
        -- if there is no effective hierarchy version.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        OPEN  csr_get_hier_ver;
        FETCH csr_get_hier_ver INTO l_pos_structure_version_id;
        CLOSE csr_get_hier_ver;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN l_pos_structure_version_id;

END get_pos_structure_version;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_hier_orgs_to_cache >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_hier_orgs_to_cache
    (p_top_organization_id      IN NUMBER
    ,p_org_structure_version_id IN NUMBER
    ,p_include_top_org_flag     IN VARCHAR2)
IS

    --
    -- Local variables.
    --
    l_temp_org_tbl g_number_t;
    l_proc         VARCHAR2(72) := g_package||'add_hier_orgs_to_cache';
    l_dummy        NUMBER;

    --
    -- Get all the organizations in the hierarchy given a top
    -- organization and a hierarchy version.
    --
    CURSOR csr_get_orgs_in_hier IS
    SELECT     o.organization_id_child
    FROM       per_org_structure_elements o
    CONNECT BY o.organization_id_parent = PRIOR o.organization_id_child
    AND        o.org_structure_version_id = PRIOR o.org_structure_version_id
    START WITH o.organization_id_parent = p_top_organization_id
    AND        o.org_structure_version_id = p_org_structure_version_id;

    --
    -- Check if the top organization is in the hierarchy.
    --
    CURSOR csr_top_org_in_hier IS
    SELECT NULL
    FROM   per_org_structure_elements o
    WHERE  o.org_structure_version_id = p_org_structure_version_id
    AND    o.organization_id_child = p_top_organization_id
    AND    rownum = 1;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_top_organization_id IS NOT NULL AND
       p_org_structure_version_id IS NOT NULL AND
       p_include_top_org_flag IS NOT NULL THEN
        --
        -- Traverse the organization hierarchy and fetch
        -- the orgs into a temporary collection.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        OPEN  csr_get_orgs_in_hier;
        FETCH csr_get_orgs_in_hier BULK COLLECT INTO l_temp_org_tbl;
        CLOSE csr_get_orgs_in_hier;

        IF g_dbg THEN op(l_proc, 30); END IF;

        IF l_temp_org_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of orgs into the global cache so that the
            -- index is the org_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            FOR i IN l_temp_org_tbl.FIRST..l_temp_org_tbl.LAST LOOP
                IF NOT g_org_tbl.EXISTS(l_temp_org_tbl(i)) THEN
                    g_org_tbl(l_temp_org_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;

        IF g_dbg THEN op(l_proc, 50); END IF;

        IF p_include_top_org_flag = 'Y' THEN
            --
            -- Add the top organization into the org cache.
            --
            -- The top organization should only be added when it
            -- does actually exist in the organization hierarchy.
            --
            -- If there are other orgs in the hierarchy (ie, if
            -- l_temp_org_tbl contains any rows) the top org
            -- can be added immediately to the cache.
            --
            -- If the top org does not have any subordinate orgs
            -- (ie, if l_temp_org_tbl contains no rows) it is
            -- necessary to verify that the top org does in fact
            -- exist in the hierarchy at all before adding it
            -- to the cache.
            --
            IF l_temp_org_tbl.COUNT > 0 THEN
                --
                -- The top org exists in the hierarchy so it is
                -- added straight into the cache.
                --
                IF g_dbg THEN op(l_proc, 60); END IF;

                IF NOT g_org_tbl.EXISTS(p_top_organization_id) THEN
                    g_org_tbl(p_top_organization_id) := TRUE;
                END IF;

            ELSE
                --
                -- Verify that the top org exists in the hierarchy
                -- before adding it to the cache.
                --
                IF g_dbg THEN op(l_proc, 70); END IF;

                OPEN  csr_top_org_in_hier;
                FETCH csr_top_org_in_hier INTO l_dummy;
                IF csr_top_org_in_hier%FOUND THEN
                    --
                    -- The top org is in the hierarchy so add it
                    -- to the cache.
                    --
                    IF g_dbg THEN op(l_proc, 80); END IF;

                    IF NOT g_org_tbl.EXISTS(p_top_organization_id) THEN
                        g_org_tbl(p_top_organization_id) := TRUE;
                    END IF;
                END IF;
                CLOSE csr_top_org_in_hier;
            END IF;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_hier_orgs_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< positions_org_visible >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION positions_org_visible
    (p_position_id             IN NUMBER
    ,p_effective_date          IN DATE)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_proc        VARCHAR2(72) := g_package||'positions_org_visible';
    l_position_id NUMBER;

    --
    -- Determines whether this position's organization is visible.
    --
    CURSOR csr_pos_org_visible IS
    SELECT hapf.position_id
    FROM   hr_all_positions_f hapf
    WHERE  hapf.position_id = p_position_id
    AND    p_effective_date BETWEEN
           hapf.effective_start_date AND hapf.effective_end_date
    AND    hr_security_internal.show_organization
               (hapf.organization_id) = 'TRUE';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_position_id IS NOT NULL AND p_effective_date IS NOT NULL THEN
        OPEN  csr_pos_org_visible;
        FETCH csr_pos_org_visible INTO l_position_id;
        CLOSE csr_pos_org_visible;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN (l_position_id IS NOT NULL);

END positions_org_visible;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_hier_pos_to_cache >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_hier_pos_to_cache
    (p_top_position_id           IN NUMBER
    ,p_pos_structure_version_id  IN NUMBER
    ,p_include_top_position_flag IN VARCHAR2
    ,p_effective_date            IN DATE
    ,p_restricted_orgs           IN BOOLEAN)
IS

    l_temp_pos_tbl g_number_t;
    l_proc         VARCHAR2(72) := g_package||'add_hier_pos_to_cache';
    l_dummy        NUMBER;

    --
    -- Get the restricted positions in the hierarchy given a top
    -- position and a hierarchy version. This cursor uses
    -- organization security to only allow positions whose
    -- organization can be seen.
    --
    CURSOR csr_get_restricted_pos IS
    SELECT     p.subordinate_position_id
    FROM       per_pos_structure_elements p
    CONNECT BY p.parent_position_id = PRIOR p.subordinate_position_id
    AND        p.pos_structure_version_id = PRIOR p.pos_structure_version_id
    START WITH p.parent_position_id = p_top_position_id
    AND        p.pos_structure_version_id = p_pos_structure_version_id
    AND EXISTS
        (SELECT null
         FROM   hr_all_positions_f hapf
         WHERE  hapf.position_id = p.subordinate_position_id
         AND    p_effective_date BETWEEN
                hapf.effective_start_date AND hapf.effective_end_date
         AND    hr_security_internal.show_organization
                    (hapf.organization_id) = 'TRUE');

    --
    -- Get all the positions in the hierarchy given a top
    -- position and a hierarchy version. This cursor does
    -- not secure by organizations.
    --
    CURSOR csr_get_all_pos IS
    SELECT     p.subordinate_position_id
    FROM       per_pos_structure_elements p
    CONNECT BY p.parent_position_id = PRIOR p.subordinate_position_id
    AND        p.pos_structure_version_id = PRIOR p.pos_structure_version_id
    START WITH p.parent_position_id = p_top_position_id
    AND        p.pos_structure_version_id = p_pos_structure_version_id;

    --
    -- Check if the top position is in the hierarchy.
    --
    CURSOR csr_top_pos_in_hier IS
    SELECT NULL
    FROM   per_pos_structure_elements p
    WHERE  p.pos_structure_version_id = p_pos_structure_version_id
    AND    p.subordinate_position_id = p_top_position_id
    AND    rownum = 1;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_top_position_id IS NOT NULL AND
       p_pos_structure_version_id IS NOT NULL AND
       p_include_top_position_flag IS NOT NULL AND
       p_effective_date IS NOT NULL AND
       p_restricted_orgs IS NOT NULL THEN
        --
        -- Traverse the position hierarchy and fetch
        -- the positions into a temporary collection.
        -- If restricting on organizations, use a cursor
        -- that uses show_organization.
        --
        IF p_restricted_orgs THEN
            IF g_dbg THEN op(l_proc, 20); END IF;
            OPEN  csr_get_restricted_pos;
            FETCH csr_get_restricted_pos BULK COLLECT INTO l_temp_pos_tbl;
            CLOSE csr_get_restricted_pos;
        ELSE
            IF g_dbg THEN op(l_proc, 30); END IF;
            OPEN  csr_get_all_pos;
            FETCH csr_get_all_pos BULK COLLECT INTO l_temp_pos_tbl;
            CLOSE csr_get_all_pos;
        END IF;

        IF g_dbg THEN op(l_proc, 40); END IF;

        IF l_temp_pos_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of positions into the global cache so that the
            -- index is the pos_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;

            FOR i IN l_temp_pos_tbl.FIRST..l_temp_pos_tbl.LAST LOOP
                IF NOT g_pos_tbl.EXISTS(l_temp_pos_tbl(i)) THEN
                    g_pos_tbl(l_temp_pos_tbl(i)) := TRUE;
                END IF;
            END LOOP;

            IF g_dbg THEN op(l_proc, 60); END IF;

            IF p_include_top_position_flag = 'Y' AND
             ((NOT p_restricted_orgs) OR
              (p_restricted_orgs AND
               positions_org_visible(p_top_position_id, p_effective_date)))
            THEN
                --
                -- Add the top position into the cache.
                --
                IF g_dbg THEN op(l_proc, 70); END IF;

                IF NOT g_pos_tbl.EXISTS(p_top_position_id) THEN
                    g_pos_tbl(p_top_position_id) := TRUE;
                END IF;
            END IF;
        END IF;

        IF g_dbg THEN op(l_proc, 60); END IF;

        IF p_include_top_position_flag = 'Y' AND
         ((NOT p_restricted_orgs) OR
          (p_restricted_orgs AND
           positions_org_visible(p_top_position_id, p_effective_date)))
        THEN
            --
            -- Add the top position into the position cache.
            --
            -- The top position should only be added when it
            -- does actually exist in the position hierarchy
            -- and when the position's org is visible.
            --
            -- If there are other positions in the hierarchy (ie, if
            -- l_temp_pos_tbl contains any rows) the top position
            -- can be added immediately to the cache.
            --
            -- If the top pos does not have any subordinate positions
            -- (ie, if l_temp_pos_tbl contains no rows) it is
            -- necessary to verify that the top pos does in fact
            -- exist in the hierarchy at all before adding it
            -- to the cache.
            --
            IF l_temp_pos_tbl.COUNT > 0 THEN
                --
                -- The top pos exists in the hierarchy so it is
                -- added straight into the cache.
                --
                IF g_dbg THEN op(l_proc, 70); END IF;

                IF NOT g_pos_tbl.EXISTS(p_top_position_id) THEN
                    g_pos_tbl(p_top_position_id) := TRUE;
                END IF;

            ELSE
                --
                -- Verify that the top pos exists in the hierarchy
                -- before adding it to the cache.
                --
                IF g_dbg THEN op(l_proc, 80); END IF;

                OPEN  csr_top_pos_in_hier;
                FETCH csr_top_pos_in_hier INTO l_dummy;
                IF csr_top_pos_in_hier%FOUND THEN
                    --
                    -- The top pos is in the hierarchy so add it
                    -- to the cache.
                    --
                    IF g_dbg THEN op(l_proc, 90); END IF;

                    IF NOT g_pos_tbl.EXISTS(p_top_position_id) THEN
                        g_pos_tbl(p_top_position_id) := TRUE;
                    END IF;
                END IF;
                CLOSE csr_top_pos_in_hier;
            END IF;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_hier_pos_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_contacts_to_cache >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_contacts_to_cache(
          p_effective_date    in date
         ,p_business_group_id in number
         ) is
  -- Local variables.
  l_proc            varchar2(72) := g_package||'add_contacts_to_cache';
  l_temp_per_tbl    g_number_t;
  l_temp_per_tbl2   g_boolean_t;
  i                 number;
  k                 number;
  -- Gets all the related contacts for a particular person.
  -- The contacts must not have any assignments because
  -- assignments are evaluated at an earlier point in the process.
  cursor csr_related_contacts(p_person_id in number) is
         select pcr.contact_person_id
           from per_contact_relationships pcr
          where pcr.person_id = p_person_id
            and p_effective_date between pcr.date_start
                and nvl(pcr.date_end, hr_api.g_eot)
            and not exists
                (select null
                   from per_all_assignments_f paaf
                  where paaf.person_id = pcr.contact_person_id
                  and paaf.ASSIGNMENT_TYPE <> 'B');  -- Bug 4450149
  -- Gets all unrelated contacts (excluding the candidates - registered
  -- users from iRec) for the business group, or globally if using a global
  -- profile. The people cannot have any current or historical assignments.
  -- Here the numbers are checked instead of hitting per_all_assignments_f.
  cursor csr_unrelated_contacts is
         select distinct papf.person_id
           from per_all_people_f papf
          where (p_business_group_id is null or
                papf.business_group_id = p_business_group_id)
            and papf.employee_number is null
            and papf.npw_number is null
            and papf.applicant_number is null
            and not exists
                (select null
                   from per_contact_relationships pcr
                  where pcr.contact_person_id = papf.person_id)
            and not exists
                (select null
                   from per_person_type_usages_f ptuf,
                        per_person_types ppt
                  where ppt.system_person_type = 'IRC_REG_USER'
                    and ptuf.person_type_id = ppt.person_type_id
                    and ptuf.person_id = papf.person_id);
  --
begin
  --
  if g_dbg then op('Entering: '||l_proc, 1); end if;
  -- Only evaluate contact security if all the values are specified.
  if p_effective_date is not null then
    --
    if g_dbg then op(l_proc, 20); end if;
    --
    if g_per_tbl.count > 0 then
      -- Loop through all people already in the cache and
      -- add their related contacts to the list.
      i := g_per_tbl.first;
      --
      while i <= g_per_tbl.last loop
        --
        if g_dbg then op(l_proc||':'||to_char(i), 30); end if;
        --
        open  csr_related_contacts(i);
        fetch csr_related_contacts bulk collect into l_temp_per_tbl;
        close csr_related_contacts;
        -- For any rows returned, restructure the results into a
        -- temporary table to avoid mutating the global table.
        -- The results are restructured so that the index is the person_id.
        if g_dbg then op(l_proc||':'||to_char(i), 40); end if;
        --
        if l_temp_per_tbl.count > 0 then
          --
          for j in l_temp_per_tbl.first..l_temp_per_tbl.last loop
            --
            if not l_temp_per_tbl2.exists(l_temp_per_tbl(j)) then
              l_temp_per_tbl2(l_temp_per_tbl(j)) := true;
            end if;
            --
          end loop;
        end if;
        -- Clear the table to free up memory before the next loop.
        if g_dbg then op(l_proc||':'||to_char(i), 50); end if;
        l_temp_per_tbl.delete;
        i := g_per_tbl.next(i);
        --
      end loop;
      --
    end if;

    -- Fetch all unrelated contacts.
    if g_dbg then op(l_proc, 60); end if;
    open  csr_unrelated_contacts;
    fetch csr_unrelated_contacts bulk collect into l_temp_per_tbl;
    close csr_unrelated_contacts;
    -- Add the related contacts to the cache.
    if g_dbg then op(l_proc, 70); end if;
    if l_temp_per_tbl2.count > 0 then
      -- Enumerate through the temporary table and add each
      -- person to the global cache.
      if g_dbg then op(l_proc, 80); end if;
      k := l_temp_per_tbl2.first;
      --
      while k <= l_temp_per_tbl2.last loop
        --
        if not g_per_tbl.exists(k) then
          g_per_tbl(k) := true;
        end if;
        k := l_temp_per_tbl2.next(k);
        --
      end loop;
      --
    end if;

    -- Add the unrelated contacts to the cache.
    if g_dbg then op(l_proc, 90); end if;
    if l_temp_per_tbl.count > 0 then
      -- Enumerate through the temporary table and add in the list of
      -- unrelated contacts into the global cache cache so that the index
      -- is the per_id.  This allows for direct index access.
      if g_dbg then op(l_proc, 100); end if;
      --
      for i in l_temp_per_tbl.first..l_temp_per_tbl.last loop
        --
        if not g_per_tbl.exists(l_temp_per_tbl(i)) then
          g_per_tbl(l_temp_per_tbl(i)) := true;
        end if;
        --
      end loop;
      --
    end if;
    --
  end if; -- End of effective date check
  --
  if g_dbg then op('Leaving: '||l_proc, 999); end if;
  --
end add_contacts_to_cache;
--
-- ----------------------------------------------------------------------------
-- |---------------------< add_candidates_to_cache >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure add_candidates_to_cache(
          p_effective_date    in date
         ,p_business_group_id in number
         ) is
  -- Local variables.
  l_proc            varchar2(72) := g_package||'add_candidates_to_cache';
  l_temp_per_tbl    g_number_t;
  -- Get all candidates (registered through iRecruitment) and excluding
  -- related contacts if any.
  cursor csr_candidates is
         select ptuf.person_id
           from per_person_type_usages_f ptuf,
                per_person_types ppt
          where ppt.system_person_type = 'IRC_REG_USER'
            and ptuf.person_type_id = ppt.person_type_id
            and ppt.business_group_id + 0 = nvl(p_business_group_id,ppt.business_group_id)--fix for bug 5222441.
            and not exists
                (select null
                   from per_all_assignments_f paaf
                  where paaf.person_id = ptuf.person_id)
            and not exists
                (select null
                   from per_contact_relationships pcr
                  where pcr.contact_person_id = ptuf.person_id);
  --
begin
  --
  if g_dbg then op('Entering: '||l_proc, 1); end if;
  -- Evaluate candidate security if all the values are specified.
  if p_effective_date is not null then
    --
    if g_dbg then op(l_proc, 20); end if;
    --
    open  csr_candidates;
    fetch csr_candidates bulk collect into l_temp_per_tbl;
    close csr_candidates;
    --
    if l_temp_per_tbl.count > 0 then
      -- Enumerate through the temporary table and add in the list of
      -- candidates into the global cache, so that the index is the
      -- person_id. This allows for direct index access.
      if g_dbg then op(l_proc, 30); end if;
      --
      for i in l_temp_per_tbl.first..l_temp_per_tbl.last loop
        --
        if not g_per_tbl.exists(l_temp_per_tbl(i)) then
          g_per_tbl(l_temp_per_tbl(i)) := true;
        end if;
        --
      end loop;
      --
    end if;
    --
    if g_dbg then op(l_proc, 40); end if;
    --
  end if;
  --
  if g_dbg then op('Leaving: '||l_proc, 99); end if;
  --
end add_candidates_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_remove_bgs_for_orgs >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_remove_bgs_for_orgs
    (p_exclude_business_groups_flag IN VARCHAR2
    ,p_business_group_id            IN NUMBER)
IS

    --
    -- Local variables.
    --
    l_proc         VARCHAR2(72) := g_package||'add_remove_bgs_for_orgs';
    l_bg_id        NUMBER;
    i              NUMBER;
    j              NUMBER       := 1;
    l_temp_org_tbl g_number_t;

    --
    -- Get the business group given a particular organization.
    -- This is used in global hierarchies when business groups should
    -- be included or excluded.
    --
    CURSOR csr_get_bg_for_org
        (p_organization_id IN NUMBER)
    IS
    SELECT o.business_group_id
    FROM   hr_all_organization_units o
    WHERE  o.organization_id = p_organization_id;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_business_group_id IS NOT NULL THEN
        --
        -- The profile is Business Group specific.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF NVL(p_exclude_business_groups_flag, 'N') = 'Y' THEN
            --
            -- The business groups should be excluded.
            --
            -- This is a local profile so at most there can only
            -- be one business group in the hierachy, and if it
            -- is in the hierarchy it is by definition the top org.
            -- When building the hierarchy, the top org is excluded
            -- unless "Include Top Organization" is ticked.  In the
            -- case of local profiles, it makes no sense to tick
            -- both "Include Top Organization" and "Exclude Business
            -- Groups" because the two contradict each other.
            -- Nevertheless, we explicitly remove the BG in this case.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            IF g_org_tbl.EXISTS(p_business_group_id) THEN
                g_org_tbl.DELETE(p_business_group_id);
            END IF;

        ELSIF NVL(p_exclude_business_groups_flag, 'N') = 'N' THEN
            --
            -- The business groups should not be excluded, which means
            -- they should be explicitly included.
            -- As this is a local profile, the BG of the profile can
            -- simply be added to the cache.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            IF NOT g_org_tbl.EXISTS(p_business_group_id) THEN
                g_org_tbl(p_business_group_id) := TRUE;
            END IF;
        END IF;

    ELSIF p_business_group_id IS NULL THEN
        --
        -- The profile is global.  The business group for each
        -- org in the hierarchy must be added or removed, depending
        -- on the exclude Business Groups flag.
        --
        -- Unfortunately, there is no quick way of finding out the
        -- BGs for the orgs in the cache without fetching the BG for
        -- each org.  The BG could be retrieved in the hierarchy tree-
        -- walk by joining to hr_all_organization_units but this would
        -- be an unnecessary hit where global profiles are not used.
        -- Instead, the BG for each org is retrieved separately here.
        --
        IF g_dbg THEN op(l_proc, 50); END IF;

        IF g_org_tbl.COUNT > 0 THEN
            --
            -- Loop through each org in the cache.
            --
            IF g_dbg THEN op(l_proc, 60); END IF;

            i := g_org_tbl.FIRST;

            WHILE i <= g_org_tbl.LAST LOOP
                --
                -- Fetch the business group for this org.
                --
                OPEN  csr_get_bg_for_org (i);
                FETCH csr_get_bg_for_org INTO l_bg_id;
                CLOSE csr_get_bg_for_org;

                IF g_dbg THEN op(l_proc||'('||to_char(i)||')', 70); END IF;

                IF l_bg_id IS NOT NULL THEN
                    --
                    -- Store the business group in a temporary table to avoid
                    -- mutating the global cache. l_bg_id should always be
                    -- populated but this is wrapped in an IF statement to
                    -- avoid data corruption issues.
                    --
                    l_temp_org_tbl(j) := l_bg_id;
                    j := j + 1;
                END IF;
                i := g_org_tbl.NEXT(i);
            END LOOP;
        END IF;

        IF g_dbg THEN op(l_proc, 80); END IF;

        IF l_temp_org_tbl.COUNT > 0 THEN
            --
            -- Add / remove each business group from the global org cache.
            --
            IF g_dbg THEN op(l_proc, 90); END IF;

            FOR i IN l_temp_org_tbl.FIRST..l_temp_org_tbl.LAST LOOP
                --
                -- For each business group...
                --
                IF NVL(p_exclude_business_groups_flag, 'N') = 'Y' THEN
                    --
                    -- The business group against this org should be
                    -- excluded from the cache if it exists.
                    --
                    IF g_dbg THEN op(l_proc||'('||to_char(i)||')', 100); END IF;

                    IF g_org_tbl.EXISTS(l_temp_org_tbl(i)) THEN
                        g_org_tbl.DELETE(l_temp_org_tbl(i));
                    END IF;

                ELSIF NVL(p_exclude_business_groups_flag, 'N') = 'N' THEN
                    --
                    -- The business group against this org should be
                    -- added to the cache if it's not already there.
                    --
                    IF g_dbg THEN op(l_proc||'('||to_char(i)||')', 110); END IF;

                    IF NOT g_org_tbl.EXISTS(l_temp_org_tbl(i)) THEN
                        g_org_tbl(l_temp_org_tbl(i)) := TRUE;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_remove_bgs_for_orgs;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_incl_remove_excl_orgs >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_incl_remove_excl_orgs
    (p_security_profile_id  IN NUMBER)
IS

    --
    -- Local variables.
    --
    l_proc     VARCHAR2(72) := g_package||'add_incl_remove_excl_orgs';

    --
    -- Gets the discrete list of orgs specified in the security profile.
    -- The parameter should always contain a value (i.e., be not null)
    -- but verify this anyway.
    -- Ordering is in descending order so that the include organizations
    -- come first and exclude orgs come second: this is the correct
    -- functional order, that is, if an org is both include and exclude
    -- it will be included and then removed so will not be visible.
    --
    CURSOR csr_get_discrete_orgs IS
    SELECT organization_id
          ,entry_type
    FROM   per_security_organizations
    WHERE  p_security_profile_id IS NOT NULL
    AND    security_profile_id = p_security_profile_id
    ORDER BY entry_type DESC;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_security_profile_id IS NOT NULL THEN
        --
        -- Add the include organizations. Here a bulk collect
        -- is not typically necessary because the volumes per
        -- security profile will not be significant.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        FOR org_rec IN csr_get_discrete_orgs LOOP
            --
            -- Add the "Include" organizations to the cached org
            -- list; remove the "Exclude" organizations from the
            -- cached list.  All include orgs are added before any
            -- org is removed (see the ORDER BY in the cursor).
            --
            IF org_rec.entry_type = 'I' THEN
                IF g_dbg THEN op(l_proc||' I: ', org_rec.organization_id);
                END IF;
                IF NOT g_org_tbl.EXISTS(org_rec.organization_id) THEN
                    g_org_tbl(org_rec.organization_id) := TRUE;
                END IF;
            ELSIF org_rec.entry_type = 'E' THEN
                IF g_dbg THEN op(l_proc||' E: ', org_rec.organization_id);
                END IF;
                IF g_org_tbl.EXISTS(org_rec.organization_id) THEN
                    g_org_tbl.DELETE(org_rec.organization_id);
                END IF;
            END IF;
        END LOOP;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_incl_remove_excl_orgs;
--
-- ----------------------------------------------------------------------------
-- |----------------------< and_clause >--------------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION and_clause(p_str IN VARCHAR2, p_append IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

    --
    -- Private utility function, used to build an 'OR' predicate.
    --
    IF p_str IS null OR p_append IS null THEN
      RETURN(p_str || p_append);
    ELSE
      RETURN(p_str||' AND '||p_append);
    END IF;

END and_clause;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< or_clause >---------------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION or_clause(p_str IN VARCHAR2, p_append IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

    --
    -- Private utility function, used to build an 'OR' predicate.
    --
    IF p_str IS null OR p_append IS null THEN
      RETURN(p_str || p_append);
    ELSE
      RETURN(p_str||' OR '||p_append);
    END IF;

END or_clause;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_brackets >------------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION add_brackets(p_str IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN

    --
    -- Private utility function that wraps the passed in string in brackets.
    --
    IF p_str IS NOT null THEN
      RETURN('('||p_str||')');
    ELSE
      RETURN(p_str);
    END IF;

END add_brackets;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_people_to_cache >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_people_to_cache
    (p_top_person_id               IN NUMBER
    ,p_effective_date              IN DATE
    ,p_sec_prof_rec                IN g_sec_prof_r
    ,p_use_static_lists            IN BOOLEAN)
IS
    -- Local type definitions.
    TYPE l_csr_type      IS REF CURSOR;
    -- Exceptions.
    loop_in_user_data EXCEPTION;
    PRAGMA EXCEPTION_INIT(loop_in_user_data, -01436);

    -- Local variables.
    l_proc               VARCHAR2(72) := g_package||'add_people_to_cache';
    l_org_restriction    VARCHAR2(1)  := 'N';
    l_pos_restriction    VARCHAR2(1)  := 'N';
    l_pay_restriction    VARCHAR2(1)  := 'N';
    l_custom_per         per_security_profiles.custom_restriction_flag%TYPE;
    l_temp_asg_tbl       g_number_t;
    l_temp_per_tbl       g_number_t;
    l_ex_emp_security    varchar2(1) := 'N';

        -- Added for Bug 8465433
    l_temp_vac_asg_tbl       g_number_t;
    l_temp_vac_per_tbl       g_number_t;
    l_vac_sql_str        VARCHAR2(32767);
    l_vac_csr               l_csr_type;

    --
    -- Dynamic SQL variables.
    --
    l_custom_y_set       BOOLEAN := FALSE;
    l_custom_u_set       BOOLEAN := FALSE;
    l_sup_hier_set       BOOLEAN := TRUE;
    l_sql_str            VARCHAR2(32767);
    l_exec_str_print     VARCHAR2(32767);
    l_select_from_clause VARCHAR2(1000);
    l_where_clause       VARCHAR2(31567);
    l_temp_clause        VARCHAR2(31567);
    l_connect_clause     VARCHAR2(2000); -- bug 5105261
    l_asg_types_y_or_n   VARCHAR2(200);
    l_asg_types_y        VARCHAR2(200);
    l_asg_types_n        VARCHAR2(200);
    l_cnt                BINARY_INTEGER;
    l_csr                l_csr_type;
    --
    -- Re-used Dynamic SQL strings
    --
    l_emp_str VARCHAR2(32)  := 'hr_asg.assignment_type = ''E''';
    l_cwk_str VARCHAR2(32)  := 'hr_asg.assignment_type = ''C''';
    l_apl_str VARCHAR2(32)  := 'hr_asg.assignment_type = ''A''';
    l_org_str VARCHAR2(150) :=
      'hr_security_internal.show_organization(hr_asg.organization_id) = ''TRUE''';
    l_pos_str VARCHAR2(150) :=
      '(hr_asg.position_id IS NULL OR hr_security_internal.show_position(hr_asg.position_id) = ''TRUE'')';
    l_pay_str VARCHAR2(150) :=
      '(hr_asg.payroll_id IS NULL OR hr_security_internal.show_payroll(hr_asg.payroll_id) = ''TRUE'')';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Only evaluate person security if all the values are specified.
    --
    IF p_effective_date IS NOT NULL
     AND p_sec_prof_rec.security_profile_id IS NOT NULL
    THEN
       -- Query for the Security Profile Option set for Ex-Employee.
       -- fnd_profile.get('PER_EX_SECURITY_PROFILE',l_ex_emp_security);
       fnd_profile.get(
              NAME => 'PER_EX_SECURITY_PROFILE'
             ,VAL => l_ex_emp_security);
      IF g_dbg THEN hr_utility.trace( 'Ex-Employee Profile Value= '||l_ex_emp_security); END IF;

        IF g_dbg THEN op(l_proc, 10); END IF;
        --
        -- Set the restricted flags.
        --
        IF restricted_orgs(p_sec_prof_rec) THEN
            l_org_restriction := 'Y';
        END IF;
        IF restricted_pos(p_sec_prof_rec) THEN
            l_pos_restriction := 'Y';
        END IF;
        IF restricted_pays(p_sec_prof_rec) THEN
            l_pay_restriction := 'Y';
        END IF;

        --
        -- Set the custom restriction flag.
        --
        l_custom_per := NVL(p_sec_prof_rec.custom_restriction_flag, 'N');

        --
        -- Force custom security to be evaluated on the fly
        -- where appropriate.
        --
        IF l_custom_per = 'Y' AND
            (NOT p_use_static_lists
             OR  (l_org_restriction = 'Y' AND
                  NVL(p_sec_prof_rec.top_organization_method, 'N') = 'U')
             OR  (l_pos_restriction = 'Y' AND
                  NVL(p_sec_prof_rec.top_position_method, 'N') = 'U'))
        THEN
            --
            -- Although custom security is not user-based (it is static),
            -- the static list cannot be used because either:
            --   a) the profile option permits the use of static lists
            --   b) user-based org security is in use
            --   c) user-based pos security is in use.
            --
            -- In these circumstances, force custom security to be
            -- evaluated on the fly.
            --
            l_custom_per := 'U';

        END IF;

        IF g_dbg THEN op(l_proc, 20); END IF;

        --
        -- Set the skeleton SELECT..FROM clause.
        --
        -- Fetch the visible people and assignments, applying the
        -- various different security restrictions before allowing
        -- them to be returned.
        -- This does not return ex-people (ex-employees, etc) and
        -- it does not return contacts.
        --
        -- Bug 3686545
        -- When restrict_on_individual_asg flag on security profile is set
        -- then custom security should be evaluated as user based because
        -- listgen currently does not maintain static assignment list.
        --
        l_select_from_clause :=
          'SELECT hr_asg.assignment_id
                 ,hr_asg.person_id
           FROM   per_all_assignments_f hr_asg ';

/*-- Check for the Supervisor Security --*/
/* -- In the New enhancement we are ignoring the supervisor security from
      showing the Ex-Employee and Future Employee records (New enhancement)
      This If condition will check whether the Supervisor Security is
      Present or Not.
      If there is Supervisorvisor Security Present do not change any thing
      This is functioning as it was in previous.
*/
     IF nvl(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') = 'Y'
     OR nvl(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') = 'A' THEN
	     l_sup_hier_set := TRUE;
     ELSE
	     l_sup_hier_set := FALSE;
     END IF;
    --
    -- Only evaluate person security if all the values are specified.
    --
IF NOT l_sup_hier_set and l_ex_emp_security= 'Y' THEN

/*--- Supervisor Security is not present ---*/
IF g_dbg THEN hr_utility.trace( 'Supervisor Security is Not present'); END IF;

        --
        -- Set the skeleton WHERE clause.
        --
	/* Where clause is modified for the enhancement
	   In the where clause,
	   1. To see the Ex-Employee`s
	   2. To see the Future Employees. */
        l_where_clause :=
   ' WHERE /* Active Employee */
     (:effective_date BETWEEN  hr_asg.effective_start_date AND hr_asg.effective_end_date
      /* Ex-Employee */
   or (hr_asg.effective_end_date < :effective_date
       and not exists
        ( select null from per_all_assignments_f papf
           where papf.person_id = hr_asg.person_id
             and papf.assignment_type in (''A'',''C'',''E'')
             and papf.effective_end_date >= :effective_date )
        )
	/* End Ex-Employee */
    /* Future Employee */
    or ( hr_asg.effective_start_date > :effective_date
        and not exists
        ( select null from per_all_assignments_f papf
           where papf.person_id = hr_asg.person_id
             and papf.assignment_type in (''A'',''C'',''E'')
             and papf.effective_start_date < hr_asg.effective_start_date )
       )
    /* End Future Employee */
      )';

        IF g_dbg THEN op(l_proc, 30); END IF;

        --
        -- Build strings that can be used to select
        -- allowable assignment types.
        --
        IF p_sec_prof_rec.view_all_employees_flag = 'Y' THEN
            l_asg_types_y := or_clause(l_asg_types_y, l_emp_str);
        ELSIF p_sec_prof_rec.view_all_employees_flag = 'N' THEN
            l_asg_types_n := or_clause(l_asg_types_n, l_emp_str);
        END IF;

        IF p_sec_prof_rec.view_all_cwk_flag = 'Y' THEN
            l_asg_types_y := or_clause(l_asg_types_y, l_cwk_str);
        ELSIF p_sec_prof_rec.view_all_cwk_flag = 'N' THEN
            l_asg_types_n := or_clause(l_asg_types_n, l_cwk_str);
        END IF;

        IF p_sec_prof_rec.view_all_applicants_flag = 'Y' THEN
            l_asg_types_y := or_clause(l_asg_types_y, l_apl_str);
        ELSIF p_sec_prof_rec.view_all_applicants_flag = 'N' THEN
            l_asg_types_n := or_clause(l_asg_types_n, l_apl_str);
        END IF;

        --
        -- Add brackets to the strings that have just been built.
        --
        l_asg_types_y_or_n := add_brackets(or_clause(l_asg_types_y, l_asg_types_n));
        l_asg_types_y      := add_brackets(l_asg_types_y);
        l_asg_types_n      := add_brackets(l_asg_types_n);

        IF g_dbg THEN op(l_proc, 40); END IF;

        --
        -- Allow all 'View All' and 'Restricted' assignment types
        -- but no 'View None' ('X') types.
        --
        IF l_asg_types_y_or_n IS NULL THEN
            --
            -- All assignment types must be 'X' so prevent
            -- any rows from being returned.
            --
            l_where_clause := and_clause(l_where_clause, 'rownum < 1');
        ELSE
            l_where_clause := and_clause(l_where_clause, l_asg_types_y_or_n);
        END IF;

        IF g_dbg THEN op(l_proc, 50); END IF;

        --
        -- Restrict to primary assignments only if set.
        --
        IF p_sec_prof_rec.exclude_secondary_asgs_flag = 'Y' THEN
            l_where_clause := and_clause(l_where_clause, 'hr_asg.primary_flag = ''Y''');
        END IF;

        IF g_dbg THEN op(l_proc, 55); END IF;

        --
        -- Restrict by business group if the profile is local.
        --
        -- Note: the business group restriction is only added when there
        -- is no supervisor restriction. Functionally, this is a bug
        -- because global profiles should be used instead of local profiles
        -- but security has always behaved like that so adding this restriction
        -- will cause havoc in customers' security profile setup.
        --
        IF p_sec_prof_rec.business_group_id IS NOT null AND
           NVL(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') = 'N' THEN
            l_where_clause := and_clause (l_where_clause,
                'hr_asg.business_group_id = '||p_sec_prof_rec.business_group_id);
        END IF;

        IF g_dbg THEN op(l_proc, 60); END IF;

        --
        -- If there are any restrictions to org, pos, pay or custom then
        -- apply them here - but only to assignment types that are 'Restricted'.
        --
        IF l_asg_types_n IS NOT null AND
          (l_org_restriction = 'Y' OR l_pos_restriction = 'Y' OR
           l_pay_restriction = 'Y' OR l_custom_per = 'Y' OR l_custom_per = 'U')
        THEN
            IF g_dbg THEN op(l_proc, 65); END IF;
            --
            -- Restrict by organization.
            --
            IF g_dbg THEN op(l_proc, 70); END IF;
            IF l_org_restriction = 'Y' THEN
              l_temp_clause := and_clause(l_temp_clause, l_org_str);
            END IF;
            --
            -- Restrict by position.
            --
            IF g_dbg THEN op(l_proc, 75); END IF;
            IF l_pos_restriction = 'Y' THEN
              l_temp_clause := and_clause(l_temp_clause, l_pos_str);
            END IF;
            --
            -- Restrict by payroll.
            --
            IF g_dbg THEN op(l_proc, 80); END IF;
            IF l_pay_restriction = 'Y' THEN
              l_temp_clause := and_clause(l_temp_clause, l_pay_str);
            END IF;
            --
            -- Restrict by custom (static).
            --
            IF g_dbg THEN op(l_proc, 85); END IF;
            IF ((p_sec_prof_rec.restrict_on_individual_asg IS NULL OR
                 p_sec_prof_rec.restrict_on_individual_asg = 'N') AND
                l_custom_per = 'Y') THEN
              l_temp_clause := and_clause(l_temp_clause,
                'EXISTS
                  (SELECT null
                   FROM   per_person_list ppl
                   WHERE  ppl.security_profile_id = :security_profile_id
                   AND    ppl.person_id = hr_asg.person_id)');
              l_custom_y_set := TRUE;
            END IF;
            --
            -- Restrict by custom (user-based).
            --
            IF g_dbg THEN op(l_proc, 90); END IF;
            IF ((p_sec_prof_rec.restrict_on_individual_asg IS NOT NULL AND
                 p_sec_prof_rec.restrict_on_individual_asg = 'Y') OR
                 l_custom_per = 'U') AND
                 p_sec_prof_rec.restriction_text IS NOT NULL THEN
                --
                -- Check if the custom restriction is using the PERSON or PERSON_TYPE
                -- table aliases. If they are, do the full sub-select otherwise
                -- substitute the ASSIGNMENT alias for asg and run the SQL as an
                -- in-line predicate.
                --
                IF instr(upper(p_sec_prof_rec.restriction_text), 'PERSON.') = 0 AND
                   instr(upper(p_sec_prof_rec.restriction_text), 'PERSON_TYPE.') = 0
                THEN
--
-- Added upper() clause for bug 5048562.
--
                    l_temp_clause := and_clause(l_temp_clause
                                               ,replace(upper(p_sec_prof_rec.restriction_text)
                                                       ,'ASSIGNMENT.', 'hr_asg.'));
                ELSE
	/* -- The l_temp_clause is changed for the enhancement  */
                    l_temp_clause := and_clause(l_temp_clause, and_clause(
                     'EXISTS (SELECT  NULL
                               FROM    per_all_assignments_f    ASSIGNMENT,
                                       per_all_people_f         PERSON,
                                       per_person_type_usages_f PERSON_TYPE
                               WHERE   ASSIGNMENT.rowid = hr_asg.rowid
			         AND   ASSIGNMENT.ASSIGNMENT_ID = hr_asg.assignment_id
                                 AND   ASSIGNMENT.ASSIGNMENT_TYPE IN (''A'',''C'',''E'')
                                 /* For the bug 6196437 */
                                 AND     PERSON.person_id = ASSIGNMENT.person_id
                                 AND     (
                                  /*    Active Employee */
                                  :effective_date
                                  BETWEEN PERSON.effective_start_date AND PERSON.effective_end_date
                                  or /* Future Employee */
                                  PERSON.effective_start_date > :effective_date)
                               AND     PERSON.person_id = PERSON_TYPE.person_id
                               AND  (  /*    Active Employee */
                                :effective_date BETWEEN
                                 PERSON_TYPE.effective_start_date AND PERSON_TYPE.effective_end_date
                                 or /* Future Employee */
                                 PERSON_TYPE.effective_start_date > :effective_date)',
                       p_sec_prof_rec.restriction_text||')'));
                      l_custom_u_set := TRUE;
                  END IF;
              END IF;

            IF g_dbg THEN op(l_proc, 95); END IF;

            --
            -- Merge the above restrictions into l_where_clause.
            --
            IF l_asg_types_y IS NOT null THEN
                --
                -- For workers that are 'Y' include those rows without checking
                -- the restrictions.
                --
                IF g_dbg THEN op(l_proc, 100); END IF;
                l_where_clause := and_clause
                   (l_where_clause, add_brackets
                     (or_clause(l_asg_types_y, add_brackets(l_temp_clause))));
            ELSE
                --
                -- l_asg_types_y is null, which means asg types are either
                -- 'Restricted' (in which case the above conditions must run for
                -- all rows) or 'None' (which are filtered out earlier).
                --
                IF g_dbg THEN op(l_proc, 105); END IF;
                l_where_clause := and_clause (l_where_clause, l_temp_clause);
            END IF;
            IF g_dbg THEN op(l_proc, 110); END IF;
        END IF;

        IF g_dbg THEN op(l_proc, 140); END IF;
        --
        -- Piece the SQL statement together.
        --
        l_sql_str := l_select_from_clause || l_where_clause || l_connect_clause;

	IF g_dbg THEN
        hr_utility.trace( 'No Supervisor Security is present');
        hr_utility.trace('***************************************************');
	    l_exec_str_print:= l_sql_str;
	    while length(l_exec_str_print)>0 loop
	      hr_utility.trace(substr(l_exec_str_print,1,70));
	      l_exec_str_print:=substr(l_exec_str_print,71);
	   end loop;
        hr_utility.trace('***************************************************');
	End if;

        IF g_dbg THEN op(l_proc, 150); END IF;
        --
        -- Open cursor, bulk fetch all the rows and close
        -- branching on dynamic binds.
        -- Do not to pass p_top_person_id.
        --
	/*-- Depending on the Security Profile Setup
	     We are opening the cusroer by passing the
	     bind variables.
	     As For enhancement we added more date clause for
	     Ex-EMployee and Future Employee so we modified the
	     bind variables accordingly. */
                IF l_custom_y_set THEN
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
		         p_effective_date,
        	         p_effective_date,
  		         p_effective_date,
                         p_sec_prof_rec.security_profile_id;
            ELSIF l_custom_u_set THEN
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
                         p_effective_date,
			 p_effective_date,
			 p_effective_date,
			 p_effective_date,
			 p_effective_date,
			 p_effective_date,
                         p_effective_date;
            ELSE
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
 		         p_effective_date,
		         p_effective_date,
		         p_effective_date;
            END IF;

        IF g_dbg THEN op(l_proc, 170); END IF;

        --
        -- Oracle 8/8i does not support BULK COLLECT of a dynamic PL/SQL
        -- statement.
        --
        IF hr_general2.get_oracle_db_version >= 9 THEN
          --
          -- Oracle 9+ being used so perform a BULK COLLECT.
          --
          FETCH l_csr BULK COLLECT INTO l_temp_asg_tbl
                                       ,l_temp_per_tbl;
        ELSE
          --
          -- Pre Oracle 9 so fetch each row individually.
          --
          l_cnt := 1;
          LOOP
            --
            -- A Pre Oracle 9 DB is being used so LOOP through,
            -- fetching each row.
            --
            FETCH l_csr INTO l_temp_asg_tbl(l_cnt), l_temp_per_tbl(l_cnt);
            EXIT WHEN l_csr%NOTFOUND;
            l_cnt := l_cnt + 1;
          END LOOP;
        END IF;
        CLOSE l_csr;

        IF g_dbg THEN op(l_proc, 180); END IF;

        IF l_temp_asg_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of asgs into the global cache so that the
            -- index is the asg_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 190); END IF;
            FOR i IN l_temp_asg_tbl.FIRST..l_temp_asg_tbl.LAST LOOP
                IF NOT g_asg_tbl.EXISTS(l_temp_asg_tbl(i)) THEN
                    g_asg_tbl(l_temp_asg_tbl(i)) := l_temp_per_tbl(i);
                END IF;
            END LOOP;

            --
            -- Enumerate through the temporary table and re-order
            -- the list of pers into the global cache so that the
            -- index is the per_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 200); END IF;
            FOR i IN l_temp_per_tbl.FIRST..l_temp_per_tbl.LAST LOOP
                IF NOT g_per_tbl.EXISTS(l_temp_per_tbl(i)) THEN
                    g_per_tbl(l_temp_per_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
ELSE
/*-- SUPERVISOR SECURITY IS SET */
  IF g_dbg THEN
   hr_utility.trace( 'Supervisor Security is present or HR: Ex-Employee Security Profile Option is not Set');
  END IF;
        --
        -- Set the skeleton WHERE clause.
        --
        l_where_clause :=
         ' WHERE  :effective_date BETWEEN
                  hr_asg.effective_start_date AND hr_asg.effective_end_date';

        IF g_dbg THEN op(l_proc, 30); END IF;

        --
        -- Build strings that can be used to select
        -- allowable assignment types.
        --
        IF p_sec_prof_rec.view_all_employees_flag = 'Y' THEN
            l_asg_types_y := or_clause(l_asg_types_y, l_emp_str);
        ELSIF p_sec_prof_rec.view_all_employees_flag = 'N' THEN
            l_asg_types_n := or_clause(l_asg_types_n, l_emp_str);
        END IF;

        IF p_sec_prof_rec.view_all_cwk_flag = 'Y' THEN
            l_asg_types_y := or_clause(l_asg_types_y, l_cwk_str);
        ELSIF p_sec_prof_rec.view_all_cwk_flag = 'N' THEN
            l_asg_types_n := or_clause(l_asg_types_n, l_cwk_str);
        END IF;

        IF p_sec_prof_rec.view_all_applicants_flag = 'Y' THEN
            l_asg_types_y := or_clause(l_asg_types_y, l_apl_str);
        ELSIF p_sec_prof_rec.view_all_applicants_flag = 'N' THEN
            l_asg_types_n := or_clause(l_asg_types_n, l_apl_str);
        END IF;

        --
        -- Add brackets to the strings that have just been built.
        --
        l_asg_types_y_or_n := add_brackets(or_clause(l_asg_types_y, l_asg_types_n));
        l_asg_types_y      := add_brackets(l_asg_types_y);
        l_asg_types_n      := add_brackets(l_asg_types_n);

        IF g_dbg THEN op(l_proc, 40); END IF;

        --
        -- Allow all 'View All' and 'Restricted' assignment types
        -- but no 'View None' ('X') types.
        --
        IF l_asg_types_y_or_n IS NULL THEN
            --
            -- All assignment types must be 'X' so prevent
            -- any rows from being returned.
            --
            l_where_clause := and_clause(l_where_clause, 'rownum < 1');
        ELSE
            l_where_clause := and_clause(l_where_clause, l_asg_types_y_or_n);
        END IF;

        IF g_dbg THEN op(l_proc, 50); END IF;

        --
        -- Restrict to primary assignments only if set.
        --
        IF p_sec_prof_rec.exclude_secondary_asgs_flag = 'Y' THEN
            l_where_clause := and_clause(l_where_clause, 'hr_asg.primary_flag = ''Y''');
        END IF;

        IF g_dbg THEN op(l_proc, 55); END IF;

        --
        -- Restrict by business group if the profile is local.
        --
        -- Note: the business group restriction is only added when there
        -- is no supervisor restriction. Functionally, this is a bug
        -- because global profiles should be used instead of local profiles
        -- but security has always behaved like that so adding this restriction
        -- will cause havoc in customers' security profile setup.
        --
        IF p_sec_prof_rec.business_group_id IS NOT null AND
           NVL(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') = 'N' THEN
            l_where_clause := and_clause (l_where_clause,
                'hr_asg.business_group_id = '||p_sec_prof_rec.business_group_id);
        END IF;

        IF g_dbg THEN op(l_proc, 60); END IF;

        --
        -- If there are any restrictions to org, pos, pay or custom then
        -- apply them here - but only to assignment types that are 'Restricted'.
        --
        IF l_asg_types_n IS NOT null AND
          (l_org_restriction = 'Y' OR l_pos_restriction = 'Y' OR
           l_pay_restriction = 'Y' OR l_custom_per = 'Y' OR l_custom_per = 'U')
        THEN
            IF g_dbg THEN op(l_proc, 65); END IF;
            --
            -- Restrict by organization.
            --
            IF g_dbg THEN op(l_proc, 70); END IF;
            IF l_org_restriction = 'Y' THEN
              l_temp_clause := and_clause(l_temp_clause, l_org_str);
            END IF;
            --
            -- Restrict by position.
            --
            IF g_dbg THEN op(l_proc, 75); END IF;
            IF l_pos_restriction = 'Y' THEN
              l_temp_clause := and_clause(l_temp_clause, l_pos_str);
            END IF;
            --
            -- Restrict by payroll.
            --
            IF g_dbg THEN op(l_proc, 80); END IF;
            IF l_pay_restriction = 'Y' THEN
              l_temp_clause := and_clause(l_temp_clause, l_pay_str);
            END IF;
            --
            -- Restrict by custom (static).
            --
            IF g_dbg THEN op(l_proc, 85); END IF;
            IF ((p_sec_prof_rec.restrict_on_individual_asg IS NULL OR
                 p_sec_prof_rec.restrict_on_individual_asg = 'N') AND
                l_custom_per = 'Y') THEN
              l_temp_clause := and_clause(l_temp_clause,
                'EXISTS
                  (SELECT null
                   FROM   per_person_list ppl
                   WHERE  ppl.security_profile_id = :security_profile_id
                   AND    ppl.person_id = hr_asg.person_id)');
              l_custom_y_set := TRUE;
            END IF;
            --
            -- Restrict by custom (user-based).
            --
            IF g_dbg THEN op(l_proc, 90); END IF;
            IF ((p_sec_prof_rec.restrict_on_individual_asg IS NOT NULL AND
                 p_sec_prof_rec.restrict_on_individual_asg = 'Y') OR
                 l_custom_per = 'U') AND
                 p_sec_prof_rec.restriction_text IS NOT NULL THEN
                --
                -- Check if the custom restriction is using the PERSON or PERSON_TYPE
                -- table aliases. If they are, do the full sub-select otherwise
                -- substitute the ASSIGNMENT alias for asg and run the SQL as an
                -- in-line predicate.
                --
                IF instr(upper(p_sec_prof_rec.restriction_text), 'PERSON.') = 0 AND
                   instr(upper(p_sec_prof_rec.restriction_text), 'PERSON_TYPE.') = 0
                THEN
--
-- Added upper() clause for bug 5048562.
--
                    l_temp_clause := and_clause(l_temp_clause
                                               ,replace(upper(p_sec_prof_rec.restriction_text)
                                                       ,'ASSIGNMENT.', 'hr_asg.'));
                ELSE
                    l_temp_clause := and_clause(l_temp_clause, and_clause(
                      'EXISTS (SELECT  NULL
                               FROM    per_all_assignments_f    ASSIGNMENT,
                                       per_all_people_f         PERSON,
                                       per_person_type_usages_f PERSON_TYPE
                               WHERE   ASSIGNMENT.rowid = hr_asg.rowid
			       AND     ASSIGNMENT.ASSIGNMENT_ID = hr_asg.assignment_id  /* For the bug 6196437 */
                               AND     PERSON.person_id = ASSIGNMENT.person_id
                               AND     :effective_date
                               BETWEEN PERSON.effective_start_date AND PERSON.effective_end_date
                               AND     PERSON.person_id = PERSON_TYPE.person_id
                                 AND     :effective_date BETWEEN
                                     PERSON_TYPE.effective_start_date AND
                                     PERSON_TYPE.effective_end_date',
                       p_sec_prof_rec.restriction_text||')'));
                      l_custom_u_set := TRUE;
                  END IF;
              END IF;

            IF g_dbg THEN op(l_proc, 95); END IF;

            --
            -- Merge the above restrictions into l_where_clause.
            --
            IF l_asg_types_y IS NOT null THEN
                --
                -- For workers that are 'Y' include those rows without checking
                -- the restrictions.
                --
                IF g_dbg THEN op(l_proc, 100); END IF;
                l_where_clause := and_clause
                   (l_where_clause, add_brackets
                     (or_clause(l_asg_types_y, add_brackets(l_temp_clause))));
            ELSE
                --
                -- l_asg_types_y is null, which means asg types are either
                -- 'Restricted' (in which case the above conditions must run for
                -- all rows) or 'None' (which are filtered out earlier).
                --
                IF g_dbg THEN op(l_proc, 105); END IF;
                l_where_clause := and_clause (l_where_clause, l_temp_clause);
            END IF;
            IF g_dbg THEN op(l_proc, 110); END IF;
        END IF;

        IF g_dbg THEN op(l_proc, 120); END IF;

        IF nvl(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') = 'Y' THEN
            --
            -- Add the connect by clause to traverse the supervisor
            -- hierarchy by person_id.
            --
	    -- added 'O' for bug 7476561
            IF g_dbg THEN op(l_proc, 125); END IF;
            -- effective date condition in connect by and start with added for bug 5105261
	    /*
            l_connect_clause :=
              ' CONNECT BY hr_asg.supervisor_id = PRIOR person_id
                and hr_asg.assignment_type <> ''B''
                and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date
                AND LEVEL <= NVL(:supervisor_levels, LEVEL) + 1
                START WITH hr_asg.person_id = :top_person_id
                and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date';

	-- added for the bug 5647930
		l_connect_clause := ' CONNECT BY hr_asg.supervisor_id = PRIOR person_id
                                   a and hr_asg.assignment_type not in (''B'',''O'')
                                  and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date
                                  AND LEVEL <= NVL(:supervisor_levels, LEVEL) + 1';

            IF p_sec_prof_rec.exclude_secondary_asgs_flag = 'Y' THEN
              l_connect_clause := l_connect_clause || ' and hr_asg.primary_flag = ''Y''';
            END IF;

            l_connect_clause := l_connect_clause || ' START WITH hr_asg.person_id = :top_person_id
            and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date';
	    -- end of bug 5647930
	   */
	   -- re added the code so that the fix goes into R12 branch line
         -- added for the bug 5647930
		l_connect_clause := ' CONNECT BY hr_asg.supervisor_id = PRIOR person_id
                                  and hr_asg.assignment_type not in (''B'',''O'')
                                  and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date
                                  AND LEVEL <= NVL(:supervisor_levels, LEVEL) + 1';

            IF p_sec_prof_rec.exclude_secondary_asgs_flag = 'Y' THEN
              l_connect_clause := l_connect_clause || ' and hr_asg.primary_flag = ''Y''';
            END IF;

            l_connect_clause := l_connect_clause || ' START WITH hr_asg.person_id = :top_person_id
            and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date';
	    -- end of bug 5647930
	    --
        ELSIF nvl(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') = 'A' THEN
            --
            -- Add the connect by clause to traverse the supervisor
            -- hierarchy by assignment_id.
            --
            -- effective date condition in connect by and start with added for bug 5105261
	    /*
            IF g_dbg THEN op(l_proc, 130); END IF;
            l_connect_clause :=
              ' CONNECT BY hr_asg.supervisor_assignment_id = PRIOR assignment_id
                and hr_asg.assignment_type not in (''B'',''O'')
                and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date
                AND LEVEL <= NVL(:supervisor_levels, LEVEL) + 1
                START WITH hr_asg.person_id = :top_person_id
                and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date';

	--
	-- added for the bug 5647930
		IF g_dbg THEN op(l_proc, 130); END IF;
            l_connect_clause := ' CONNECT BY hr_asg.supervisor_assignment_id = PRIOR assignment_id
                                  and hr_asg.assignment_type <> ''B''
                                  and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date
                                  AND LEVEL <= NVL(:supervisor_levels, LEVEL) + 1';

            IF p_sec_prof_rec.exclude_secondary_asgs_flag = 'Y' THEN
              l_connect_clause := l_connect_clause || ' and hr_asg.primary_flag = ''Y''';
            END IF;

            l_connect_clause := l_connect_clause || ' START WITH hr_asg.person_id = :top_person_id
                and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date';
        --
	--  end of bug 5647930
	--
	*/
        -- For R12 Branch line
	-- added for the bug 5647930
		IF g_dbg THEN op(l_proc, 130); END IF;
            l_connect_clause := ' CONNECT BY hr_asg.supervisor_assignment_id = PRIOR assignment_id
                                  and hr_asg.assignment_type not in (''B'',''O'')
                                  and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date
                                  AND LEVEL <= NVL(:supervisor_levels, LEVEL) + 1';

            IF p_sec_prof_rec.exclude_secondary_asgs_flag = 'Y' THEN
              l_connect_clause := l_connect_clause || ' and hr_asg.primary_flag = ''Y''';
            END IF;

            l_connect_clause := l_connect_clause || ' START WITH hr_asg.person_id = :top_person_id
                and :effective_date BETWEEN hr_asg.effective_start_date AND hr_asg.effective_end_date';
        --
	--  end of bug 5647930
	--
        ELSE
            l_sup_hier_set := FALSE;
        END IF;

        IF g_dbg THEN op(l_proc, 140); END IF;

        --
        -- Piece the SQL statement together.
        --
        l_sql_str := l_select_from_clause || l_where_clause || l_connect_clause;

        IF g_dbg THEN op(l_sql_str); END IF;
        IF g_dbg THEN op(l_proc, 150); END IF;

       IF l_sup_hier_set THEN
        l_vac_sql_str := replace(l_sql_str,'(''B'',''O'')','(''B'',''O'',''A'')');

        IF g_dbg THEN op(l_vac_sql_str); END IF;
        IF g_dbg THEN op(l_proc, 151); END IF;
       END IF;

        --
        -- Trace bind variables.
        --
        IF g_dbg THEN
            op(':effective_date: '||to_char(p_effective_date));
            op(':security_profile_id: '||to_char(p_sec_prof_rec.security_profile_id));
            op(':supervisor_levels: '||to_char(p_sec_prof_rec.supervisor_levels));
            op(':top_person_id: '||to_char(p_top_person_id));
        END IF;

        --
        -- Open cursor, bulk fetch all the rows and close
        -- branching on dynamic binds.
        --
        IF l_sup_hier_set THEN
            --
            -- Need to pass p_top_person_id for supervisor hierarchy tree-walk.
            --
            IF g_dbg THEN op(l_proc, 155); END IF;
            IF l_custom_y_set THEN
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
                         p_sec_prof_rec.security_profile_id,
                         p_effective_date, -- bug 5105261
                         p_sec_prof_rec.supervisor_levels,
                         p_top_person_id,
                         p_effective_date; -- bug 5105261

        -- Added for Bug 8353429

            OPEN l_vac_csr FOR l_vac_sql_str
                   USING p_effective_date,
                         p_sec_prof_rec.security_profile_id,
                         p_effective_date,
                         p_sec_prof_rec.supervisor_levels,
                         p_top_person_id,
                         p_effective_date;

            ELSIF l_custom_u_set THEN
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
                         p_effective_date,
                         p_effective_date,
                         p_effective_date, -- bug 5105261
                         p_sec_prof_rec.supervisor_levels,
                         p_top_person_id,
                         p_effective_date; -- bug 5105261

        -- Added for Bug 8353429

                   OPEN l_vac_csr FOR l_vac_sql_str
                   USING p_effective_date,
                         p_effective_date,
                         p_effective_date,
                         p_effective_date,
                         p_sec_prof_rec.supervisor_levels,
                         p_top_person_id,
                         p_effective_date;

            ELSE
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
                         p_effective_date, -- bug 5105261
                         p_sec_prof_rec.supervisor_levels,
                         p_top_person_id,
                         p_effective_date; -- bug 5105261

        -- Added for Bug 8353429

              OPEN l_vac_csr FOR l_vac_sql_str
                   USING p_effective_date,
                         p_effective_date,
                         p_sec_prof_rec.supervisor_levels,
                         p_top_person_id,
                         p_effective_date;

            END IF;
        ELSE
            --
            -- Do not to pass p_top_person_id.
            --
            IF g_dbg THEN op(l_proc, 160); END IF;
            IF l_custom_y_set THEN
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
                         p_sec_prof_rec.security_profile_id;
            ELSIF l_custom_u_set THEN
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date,
                         p_effective_date,
                         p_effective_date;
            ELSE
              OPEN l_csr FOR l_sql_str
                   USING p_effective_date;
            END IF;
        END IF;

        IF g_dbg THEN op(l_proc, 170); END IF;

        --
        -- Oracle 8/8i does not support BULK COLLECT of a dynamic PL/SQL
        -- statement.
        --
        IF hr_general2.get_oracle_db_version >= 9 THEN
          --
          -- Oracle 9+ being used so perform a BULK COLLECT.
          --
          FETCH l_csr BULK COLLECT INTO l_temp_asg_tbl
                                       ,l_temp_per_tbl;

-- Added for Bug 8353429
         IF l_sup_hier_set THEN
          FETCH l_vac_csr BULK COLLECT INTO l_temp_vac_asg_tbl
                                       ,l_temp_vac_per_tbl;
         END IF;

        ELSE
          --
          -- Pre Oracle 9 so fetch each row individually.
          --
          l_cnt := 1;
          LOOP
            --
            -- A Pre Oracle 9 DB is being used so LOOP through,
            -- fetching each row.
            --
            FETCH l_csr INTO l_temp_asg_tbl(l_cnt), l_temp_per_tbl(l_cnt);
            EXIT WHEN l_csr%NOTFOUND;
            l_cnt := l_cnt + 1;
          END LOOP;
        END IF;
        CLOSE l_csr;

-- Added for Bug 8353429
        IF l_sup_hier_set THEN
        CLOSE l_vac_csr;
        END IF;

        IF g_dbg THEN op(l_proc, 180); END IF;

        IF l_temp_asg_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of asgs into the global cache so that the
            -- index is the asg_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 190); END IF;
            FOR i IN l_temp_asg_tbl.FIRST..l_temp_asg_tbl.LAST LOOP
                IF NOT g_asg_tbl.EXISTS(l_temp_asg_tbl(i)) THEN
                    g_asg_tbl(l_temp_asg_tbl(i)) := l_temp_per_tbl(i);
                END IF;
            END LOOP;

            --
            -- Enumerate through the temporary table and re-order
            -- the list of pers into the global cache so that the
            -- index is the per_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 200); END IF;
            FOR i IN l_temp_per_tbl.FIRST..l_temp_per_tbl.LAST LOOP
                IF NOT g_per_tbl.EXISTS(l_temp_per_tbl(i)) THEN
                    g_per_tbl(l_temp_per_tbl(i)) := TRUE;
               END IF;
            END LOOP;

        END IF;

-- Added for Bug 8353429
      IF l_sup_hier_set THEN
        IF l_temp_vac_asg_tbl.COUNT > 0 THEN
            IF g_dbg THEN op(l_proc, 5190); END IF;

            FOR i IN l_temp_vac_asg_tbl.FIRST..l_temp_vac_asg_tbl.LAST LOOP
                IF NOT g_vac_asg_tbl.EXISTS(l_temp_vac_asg_tbl(i))
                   AND g_asg_tbl.EXISTS(l_temp_vac_asg_tbl(i)) THEN
                    g_vac_asg_tbl(l_temp_vac_asg_tbl(i)) := l_temp_vac_per_tbl(i);
                END IF;
            END LOOP;

            IF g_dbg THEN op(l_proc, 5200); END IF;

            FOR i IN l_temp_vac_per_tbl.FIRST..l_temp_vac_per_tbl.LAST LOOP
                IF NOT g_vac_per_tbl.EXISTS(l_temp_vac_per_tbl(i))
                   AND g_per_tbl.EXISTS(l_temp_vac_per_tbl(i)) THEN
                    g_vac_per_tbl(l_temp_vac_per_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
       END IF;
     End IF;
   END IF;
    IF g_dbg THEN op('Leaving: '||l_proc, 970); END IF;

 EXCEPTION

    WHEN no_data_found THEN
        --
        -- Close the cursor if open to avoid leaking.
        --
        IF l_csr%isopen THEN
          CLOSE l_csr;
        END IF;
        IF g_dbg THEN op('Leaving: '||l_proc, 993); END IF;

    WHEN loop_in_user_data THEN
        --
        -- Close the cursor if open to avoid leaking.
        --
        IF l_csr%isopen THEN
          CLOSE l_csr;
        END IF;
        IF g_dbg THEN op('Leaving: '||l_proc, 996); END IF;
        fnd_message.set_name('PER','PER_449800_ORA_1436');
        fnd_message.raise_error;

    WHEN others THEN
        --
        -- Close the cursor if open to avoid leaking.
        --
        IF l_csr%isopen THEN
          CLOSE l_csr;
        END IF;
        IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;
        RAISE;

END add_people_to_cache;

--
-- ----------------------------------------------------------------------------
-- |----------------------< add_static_orgs_to_cache >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_static_orgs_to_cache
    (p_user_id                 IN NUMBER
    ,p_security_profile_id     IN NUMBER
    ,p_top_organization_method IN VARCHAR2)
IS

    --
    -- Local variables.
    --
    l_temp_org_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_static_orgs_to_cache';

    --
    -- Fetch all the organizations in the static org list
    -- for the given user.
    -- As there is a user and security profile pair, this
    -- allows for scenarios whereby a single user has multiple
    -- secured responsibilities, each attached to a different
    -- security profile and therefore different access rights.
    --
    CURSOR csr_get_static_orgs_for_user IS
    SELECT pol.organization_id
    FROM   per_organization_list pol
    WHERE  pol.security_profile_id IS NOT NULL
    AND    pol.user_id IS NOT NULL
    AND    pol.security_profile_id = p_security_profile_id
    AND    pol.user_id = p_user_id;

    --
    -- Fetch the organizations in the static org list for this profile.
    -- This cursor is used when user-based org security is
    -- not in use.
    --
    CURSOR csr_get_static_orgs IS
    SELECT pol.organization_id
    FROM   per_organization_list pol
    WHERE  pol.security_profile_id IS NOT NULL
    AND    pol.user_id IS NULL
    AND    pol.security_profile_id = p_security_profile_id;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_user_id IS NOT NULL AND
       p_security_profile_id IS NOT NULL THEN
        --
        -- If this is user-based, look for a user and
        -- security profile pair. Generally speaking, the static
        -- user lists will only be cached when it is known that
        -- this user is in the list of users to build static
        -- lists for AND they have rows in per_organization_list.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF NVL(p_top_organization_method, 'S') = 'U' THEN
            --
            -- Get the user's visible orgs by bulk collecting into a
            -- temporary collection.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            OPEN  csr_get_static_orgs_for_user;
            FETCH csr_get_static_orgs_for_user BULK COLLECT INTO l_temp_org_tbl;
            CLOSE csr_get_static_orgs_for_user;

            IF g_dbg THEN op(l_proc, 40); END IF;

        ELSE
            --
            -- Get the visible orgs for the profile by bulk collecting
            -- into a temporary collection.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;

            OPEN  csr_get_static_orgs;
            FETCH csr_get_static_orgs BULK COLLECT INTO l_temp_org_tbl;
            CLOSE csr_get_static_orgs;

            IF g_dbg THEN op(l_proc, 60); END IF;

        END IF;

        IF l_temp_org_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of orgs into the global cache so that the
            -- index is the org_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 70); END IF;

            FOR i IN l_temp_org_tbl.FIRST..l_temp_org_tbl.LAST LOOP
                IF NOT g_org_tbl.EXISTS(l_temp_org_tbl(i)) THEN
                    g_org_tbl(l_temp_org_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_static_orgs_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_static_pos_to_cache >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_static_pos_to_cache
    (p_user_id                 IN NUMBER
    ,p_security_profile_id     IN NUMBER
    ,p_top_position_method     IN VARCHAR2)
IS

    --
    -- Local variables.
    --
    l_temp_pos_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_static_pos_to_cache';

    --
    -- Fetch all the positions in the static pos list
    -- for the given user.
    -- As there is a user and security profile pair, this
    -- allows for scenarios whereby a single user has multiple
    -- secured responsibilities, each attached to a different
    -- security profile and therefore different access rights.
    --
    CURSOR csr_get_static_pos_for_user IS
    SELECT ppl.position_id
    FROM   per_position_list ppl
    WHERE  ppl.security_profile_id IS NOT NULL
    AND    ppl.user_id IS NOT NULL
    AND    ppl.security_profile_id = p_security_profile_id
    AND    ppl.user_id = p_user_id;

    --
    -- Fetch the positions in the static pos list for this profile.
    -- This cursor is used when user-based pos security is
    -- not in use.
    --
    CURSOR csr_get_static_pos IS
    SELECT ppl.position_id
    FROM   per_position_list ppl
    WHERE  ppl.security_profile_id IS NOT NULL
    AND    ppl.user_id IS NULL
    AND    ppl.security_profile_id = p_security_profile_id;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_user_id IS NOT NULL AND
       p_security_profile_id IS NOT NULL THEN
        --
        -- If this is user-based, look for a user and
        -- security profile pair. Generally speaking, the static
        -- user lists will only be cached when it is known that
        -- this user is in the list of users to build static
        -- lists for AND they have rows in per_position_list.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF NVL(p_top_position_method, 'S') = 'U' THEN
            --
            -- Get the user's visible positions by bulk collecting into a
            -- temporary collection.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            OPEN  csr_get_static_pos_for_user;
            FETCH csr_get_static_pos_for_user BULK COLLECT INTO l_temp_pos_tbl;
            CLOSE csr_get_static_pos_for_user;

            IF g_dbg THEN op(l_proc, 40); END IF;

        ELSE
            --
            -- Get the visible positions for the profile by bulk collecting
            -- into a temporary collection.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;

            OPEN  csr_get_static_pos;
            FETCH csr_get_static_pos BULK COLLECT INTO l_temp_pos_tbl;
            CLOSE csr_get_static_pos;

            IF g_dbg THEN op(l_proc, 60); END IF;

        END IF;

        IF l_temp_pos_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of positions into the global cache so that the
            -- index is the pos_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 70); END IF;

            FOR i IN l_temp_pos_tbl.FIRST..l_temp_pos_tbl.LAST LOOP
                IF NOT g_pos_tbl.EXISTS(l_temp_pos_tbl(i)) THEN
                    g_pos_tbl(l_temp_pos_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_static_pos_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_static_pay_to_cache >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_static_pay_to_cache
    (p_security_profile_id     IN NUMBER)
IS

    --
    -- Local variables.
    --
    l_temp_pay_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_static_pay_to_cache';

    --
    -- Fetch the payrolls in the static pay list for this profile.
    --
    CURSOR csr_get_static_pay IS
    SELECT ppl.payroll_id
    FROM   pay_payroll_list ppl
    WHERE  ppl.security_profile_id IS NOT NULL
    AND    ppl.security_profile_id = p_security_profile_id;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_security_profile_id IS NOT NULL THEN
        --
        -- Get the visible payrolls for the profile by bulk collecting
        -- into a temporary collection.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        OPEN  csr_get_static_pay;
        FETCH csr_get_static_pay BULK COLLECT INTO l_temp_pay_tbl;
        CLOSE csr_get_static_pay;

        IF g_dbg THEN op(l_proc, 30); END IF;

        IF l_temp_pay_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of payrolls into the global cache so that the
            -- index is the pay_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            FOR i IN l_temp_pay_tbl.FIRST..l_temp_pay_tbl.LAST LOOP
                IF NOT g_pay_tbl.EXISTS(l_temp_pay_tbl(i)) THEN
                    g_pay_tbl(l_temp_pay_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_static_pay_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_static_per_to_cache >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_static_per_to_cache
    (p_user_id                 IN NUMBER
    ,p_security_profile_id     IN NUMBER
    ,p_cache_by_user           IN BOOLEAN)
IS

    --
    -- Local variables.
    --
    l_temp_per_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_static_per_to_cache';

    --
    -- Fetch all the people in the static per list
    -- for the given user.
    -- As there is a user and security profile pair, this
    -- allows for scenarios whereby a single user has multiple
    -- secured responsibilities, each attached to a different
    -- security profile and therefore different access rights.
    --
    CURSOR csr_get_static_per_for_user IS
    SELECT ppl.person_id
    FROM   per_person_list ppl
    WHERE  ppl.security_profile_id IS NOT NULL
    AND    ppl.granted_user_id IS NOT NULL
    AND    ppl.security_profile_id = p_security_profile_id
    AND    ppl.granted_user_id = p_user_id;

    --
    -- Fetch the people in the static per list for this profile.
    -- This cursor is used when user-based per security is
    -- not in use.
    --
    CURSOR csr_get_static_per IS
    SELECT ppl.person_id
    FROM   per_person_list ppl
    WHERE  ppl.security_profile_id IS NOT NULL
    AND    ppl.granted_user_id IS NULL
    AND    ppl.security_profile_id = p_security_profile_id;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_user_id IS NOT NULL AND
       p_security_profile_id IS NOT NULL THEN
        --
        -- If this is user-based, look for a user and
        -- security profile pair. Generally speaking, the static
        -- user lists will only be cached when it is known that
        -- this user is in the list of users to build static
        -- lists for AND they have rows in per_person_list.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF p_cache_by_user THEN
            --
            -- Get the user's visible people by bulk collecting into a
            -- temporary collection.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            OPEN  csr_get_static_per_for_user;
            FETCH csr_get_static_per_for_user BULK COLLECT INTO l_temp_per_tbl;
            CLOSE csr_get_static_per_for_user;

            IF g_dbg THEN op(l_proc, 40); END IF;

        ELSE
            --
            -- Get the security profile's visible people.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;

            OPEN  csr_get_static_per;
            FETCH csr_get_static_per BULK COLLECT INTO l_temp_per_tbl;
            CLOSE csr_get_static_per;

            IF g_dbg THEN op(l_proc, 60); END IF;

        END IF;

        IF l_temp_per_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of people into the global cache so that the
            -- index is the per_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 70); END IF;

            FOR i IN l_temp_per_tbl.FIRST..l_temp_per_tbl.LAST LOOP
                IF NOT g_per_tbl.EXISTS(l_temp_per_tbl(i)) THEN
                    g_per_tbl(l_temp_per_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_static_per_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_static_asg_to_cache >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_static_asg_to_cache
    (p_user_id                 IN NUMBER
    ,p_security_profile_id     IN NUMBER
    ,p_cache_by_user           IN BOOLEAN)
IS

    --
    -- Local variables.
    --
    l_temp_asg_tbl             g_number_t;
    l_temp_per_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_static_asg_to_cache';

    --
    -- Fetch all the assignments in the static asg list
    -- for the given user.
    -- As there is a user and security profile pair, this
    -- allows for scenarios whereby a single user has multiple
    -- secured responsibilities, each attached to a different
    -- security profile and therefore different access rights.
    --
    CURSOR csr_get_static_asg_for_user IS
    SELECT pal.assignment_id
          ,pal.person_id
    FROM   per_assignment_list pal
    WHERE  pal.security_profile_id IS NOT NULL
    AND    pal.user_id IS NOT NULL
    AND    pal.security_profile_id = p_security_profile_id
    AND    pal.user_id = p_user_id;

    --
    -- Fetch the people in the static asg list for this profile.
    -- This cursor is used when user-based asg security is
    -- not in use.  At the moment, permissions are only stored
    -- in the assignment list against a user so this cursor
    -- should never return any rows.
    --
    CURSOR csr_get_static_asg IS
    SELECT pal.assignment_id
          ,pal.person_id
    FROM   per_assignment_list pal
    WHERE  pal.security_profile_id IS NOT NULL
    AND    pal.user_id IS NULL
    AND    pal.security_profile_id = p_security_profile_id;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_user_id IS NOT NULL AND
       p_security_profile_id IS NOT NULL AND
       p_cache_by_user IS NOT NULL THEN
        --
        -- If this is user-based, look for a user and
        -- security profile pair. Generally speaking, the static
        -- user lists will only be cached when it is known that
        -- this user is in the list of users to build static
        -- lists for AND they have rows in per_assignment_list.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF p_cache_by_user THEN
            --
            -- Get the user's visible assignments by bulk collecting
            -- into a temporary collection.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            OPEN  csr_get_static_asg_for_user;
            FETCH csr_get_static_asg_for_user BULK COLLECT INTO l_temp_asg_tbl
                                                               ,l_temp_per_tbl;
            CLOSE csr_get_static_asg_for_user;

            IF g_dbg THEN op(l_proc, 40); END IF;

        ELSE
            --
            -- Get the security profile's visible assignments.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;

            OPEN  csr_get_static_asg;
            FETCH csr_get_static_asg BULK COLLECT INTO l_temp_asg_tbl
                                                      ,l_temp_per_tbl;
            CLOSE csr_get_static_asg;

            IF g_dbg THEN op(l_proc, 60); END IF;

        END IF;

        IF l_temp_asg_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of assignments into the global cache so that
            -- the index is the asg_id.  This allows for direct index
            -- access. Also, use the person ID as each row's value
            -- so that show_person could potentially use this table
            -- in the future.
            --
            IF g_dbg THEN op(l_proc, 70); END IF;

            FOR i IN l_temp_asg_tbl.FIRST..l_temp_asg_tbl.LAST LOOP
                IF NOT g_asg_tbl.EXISTS(l_temp_asg_tbl(i)) THEN
                    g_asg_tbl(l_temp_asg_tbl(i)) := l_temp_per_tbl(i);
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_static_asg_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_per_list_changes_to_cache >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_per_list_changes_to_cache
    (p_security_profile_id     IN NUMBER
    ,p_effective_date          IN DATE)
IS

    --
    -- Local variables.
    --
    l_temp_per_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_per_list_changes_to_cache';

    --
    -- Fetch all the people in the static person list changes to the
    -- cache. In theory, this table should be empty because of the
    -- ex-person enhancements but in practice, it is likely that this
    -- table is still maintained or was used by unsupported customer
    -- processes.
    -- Either way, cache the contents to be safe.
    -- Only include people that do not have an assignment effective
    -- as of the effective date (because they would have already been
    -- evaluated) but did once have an assignment.
    --
    CURSOR csr_get_static_per IS
    SELECT plc.person_id
    FROM   per_person_list_changes plc
    WHERE  plc.security_profile_id IS NOT NULL
    AND    plc.security_profile_id = p_security_profile_id
    AND NOT EXISTS
        (SELECT NULL
         FROM   per_all_assignments_f paaf
         WHERE  paaf.person_id = plc.person_id
         AND    paaf.assignment_type <> 'B'
         AND    p_effective_date BETWEEN
                paaf.effective_start_date AND paaf.effective_end_date)
    AND EXISTS
        (SELECT NULL
         FROM   per_all_assignments_f paaf2
         WHERE  paaf2.person_id = plc.person_id
         AND    paaf2.assignment_type <> 'B'
         AND    p_effective_date > paaf2.effective_start_date);

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_security_profile_id IS NOT NULL THEN
        --
        -- Get the people in the list by bulk collecting into a
        -- temporary collection.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        OPEN  csr_get_static_per;
        FETCH csr_get_static_per BULK COLLECT INTO l_temp_per_tbl;
        CLOSE csr_get_static_per;

        IF g_dbg THEN op(l_proc, 30); END IF;

        IF l_temp_per_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of people into the global cache so that the
            -- index is the per_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            FOR i IN l_temp_per_tbl.FIRST..l_temp_per_tbl.LAST LOOP
                IF NOT g_per_tbl.EXISTS(l_temp_per_tbl(i)) THEN
                    g_per_tbl(l_temp_per_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_per_list_changes_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_granted_users_to_cache >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_granted_users_to_cache
    (p_user_id                    IN NUMBER
    ,p_effective_date             IN DATE
    ,p_allow_granted_users_flag   IN VARCHAR2
    ,p_restrict_on_individual_asg IN VARCHAR2)
IS

    --
    -- Local variables.
    --
    l_proc         VARCHAR2(72) := g_package||'add_granted_users_to_cache';
    l_temp_per_tbl g_number_t;

    --
    -- Fetch all the people for whom this user has explicitly been
    -- granted access.
    --
    CURSOR csr_get_granted_users IS
    SELECT ppl.person_id
    FROM   per_person_list ppl
    WHERE  ppl.granted_user_id IS NOT NULL
    AND    ppl.granted_user_id = p_user_id
    AND    ppl.security_profile_id IS NULL;

    --
    -- Fetch all the non-benefits assignments for a given person.
    --
    CURSOR csr_get_asgs_for_per
        (p_person_id IN NUMBER) IS
    SELECT paaf.assignment_id
    FROM   per_all_assignments_f paaf
    WHERE  paaf.person_id = p_person_id
    AND    p_effective_date BETWEEN
           paaf.effective_start_date AND paaf.effective_end_date
    AND    paaf.assignment_type <> 'B';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_user_id IS NOT NULL AND
       p_effective_date IS NOT NULL THEN

        --
        -- If granted users are allowed.
        --
        IF NVL(p_allow_granted_users_flag, 'N') = 'Y' THEN
            --
            -- Get the granted users by bulk collecting into a
            -- temporary collection.
            --
            IF g_dbg THEN op(l_proc, 20); END IF;

            OPEN  csr_get_granted_users;
            FETCH csr_get_granted_users BULK COLLECT INTO l_temp_per_tbl;
            CLOSE csr_get_granted_users;

            IF g_dbg THEN op(l_proc, 30); END IF;

            IF l_temp_per_tbl.COUNT > 0 THEN
                --
                -- Enumerate through the temporary table and re-order
                -- the list of people into the global cache so that the
                -- index is the per_id.  This allows for direct index
                -- access.
                --
                    IF g_dbg THEN op(l_proc, 40); END IF;

                FOR i IN l_temp_per_tbl.FIRST..l_temp_per_tbl.LAST LOOP
                    --
                    -- Add the granted user to the person cache if they
                    -- do not already exist.
                    --
                    IF NOT g_per_tbl.EXISTS(l_temp_per_tbl(i)) THEN
                        g_per_tbl(l_temp_per_tbl(i)) := TRUE;
                    END IF;

                    IF NVL(p_restrict_on_individual_asg, 'N') = 'Y' THEN
                        --
                        -- This profile is securing at an individual assignment level
                        -- so add all the assignments for this person into the
                        -- assignment cache.
                        --
                        FOR asg_rec IN csr_get_asgs_for_per(l_temp_per_tbl(i)) LOOP
                            --
                            -- For each assignment, add it to the assignment
                            -- cache if it does not already exist.
                            --
                            IF NOT g_asg_tbl.EXISTS(asg_rec.assignment_id) THEN
                                g_asg_tbl(asg_rec.assignment_id) := l_temp_per_tbl(i);
                            END IF;
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_granted_users_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< add_sec_prof_pay_to_cache >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE add_sec_prof_pay_to_cache
    (p_security_profile_id          IN NUMBER
    ,p_include_exclude_payroll_flag IN VARCHAR2
    ,p_business_group_id            IN NUMBER
    ,p_effective_date               IN DATE)
IS

    --
    -- Local variables.
    --
    l_temp_pay_tbl             g_number_t;
    l_proc     VARCHAR2(72) := g_package||'add_sec_prof_pay_to_cache';

    --
    -- Fetch the effective payrolls in the security profile's payroll
    -- list.  This cursor is used when the payrolls listed should be
    -- included.
    --
    CURSOR csr_get_include_pay IS
    SELECT pay.payroll_id
    FROM   pay_all_payrolls_f pay
          ,pay_security_payrolls psp
    WHERE  psp.security_profile_id IS NOT NULL
    AND    psp.security_profile_id = p_security_profile_id
    AND    psp.payroll_id = pay.payroll_id
    AND    p_effective_date BETWEEN
           pay.effective_start_date AND pay.effective_end_date;

    --
    -- Fetch the effective payrolls in the business group of the
    -- security profile, specifically excluding those listed
    -- in the security profile's list of payrolls.
    -- This cursor is used when the payrolls listed should be
    -- included.
    --
    CURSOR csr_get_exclude_pay IS
    SELECT pay.payroll_id
    FROM   pay_all_payrolls_f pay
    WHERE  p_effective_date BETWEEN
           pay.effective_start_date AND pay.effective_end_date
    AND    pay.business_group_id IS NOT NULL
    AND    pay.business_group_id = p_business_group_id
    AND NOT EXISTS
          (SELECT NULL
           FROM   pay_security_payrolls psp
           WHERE  psp.security_profile_id IS NOT NULL
           AND    psp.security_profile_id = p_security_profile_id
           AND    psp.payroll_id = pay.payroll_id);

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Verify that the necessary parameters have a value.
    --
    IF p_security_profile_id IS NOT NULL AND
       p_include_exclude_payroll_flag IS NOT NULL AND
       p_business_group_id IS NOT NULL AND
       p_effective_date IS NOT NULL THEN

        IF g_dbg THEN op(l_proc, 20); END IF;

        --
        -- Add the payrolls to the cache: include them if
        -- Include is specified, otherwise exclude all
        -- except those in the payroll list.
        --
        IF p_include_exclude_payroll_flag = 'I' THEN
            --
            -- Include those in the security profile's payroll list.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            OPEN  csr_get_include_pay;
            FETCH csr_get_include_pay BULK COLLECT INTO l_temp_pay_tbl;
            CLOSE csr_get_include_pay;

        ELSIF p_include_exclude_payroll_flag = 'E' THEN
            --
            -- Include all but those in the security profile's payroll
            -- list.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            OPEN  csr_get_exclude_pay;
            FETCH csr_get_exclude_pay BULK COLLECT INTO l_temp_pay_tbl;
            CLOSE csr_get_exclude_pay;

        END IF;

        IF l_temp_pay_tbl.COUNT > 0 THEN
            --
            -- Enumerate through the temporary table and re-order
            -- the list of payrolls into the global cache so that the
            -- index is the pay_id.  This allows for direct index
            -- access.
            --
            IF g_dbg THEN op(l_proc, 50); END IF;

            FOR i IN l_temp_pay_tbl.FIRST..l_temp_pay_tbl.LAST LOOP
                IF NOT g_pay_tbl.EXISTS(l_temp_pay_tbl(i)) THEN
                    g_pay_tbl(l_temp_pay_tbl(i)) := TRUE;
                END IF;
            END LOOP;
        END IF;
    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END add_sec_prof_pay_to_cache;
--
-- ----------------------------------------------------------------------------
-- |----------------------< user_in_static_org_list >-------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION user_in_static_org_list
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_return          BOOLEAN := FALSE;
    l_organization_id NUMBER;
    l_proc            VARCHAR2(72) := g_package||'user_in_static_org_list';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        IF g_dbg THEN op(l_proc, 30); END IF;

        SELECT pol.organization_id
        INTO   l_organization_id
        FROM   per_organization_list pol
        WHERE  pol.user_id IS NOT NULL
        AND    pol.security_profile_id IS NOT NULL
        AND    pol.user_id = p_user_id
        AND    pol.security_profile_id = p_security_profile_id
        AND    rownum = 1;

        IF g_dbg THEN op(l_proc, 40); END IF;

    END IF;

    l_return := (l_organization_id IS NOT NULL);

    IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;

    RETURN l_return;

EXCEPTION

    WHEN no_data_found THEN

        IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

        RETURN l_return;

END user_in_static_org_list;
--
-- ----------------------------------------------------------------------------
-- |----------------------< user_in_static_pos_list >-------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION user_in_static_pos_list
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_return      BOOLEAN := FALSE;
    l_position_id NUMBER;
    l_proc        VARCHAR2(72) := g_package||'user_in_static_pos_list';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        IF g_dbg THEN op(l_proc, 30); END IF;

        SELECT ppl.position_id
        INTO   l_position_id
        FROM   per_position_list ppl
        WHERE  ppl.user_id IS NOT NULL
        AND    ppl.security_profile_id IS NOT NULL
        AND    ppl.user_id = p_user_id
        AND    ppl.security_profile_id = p_security_profile_id
        AND    rownum = 1;

        IF g_dbg THEN op(l_proc, 40); END IF;

    END IF;

    l_return := (l_position_id IS NOT NULL);

    IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;

    RETURN l_return;

EXCEPTION

    WHEN no_data_found THEN

        IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

        RETURN l_return;

END user_in_static_pos_list;
--
-- ----------------------------------------------------------------------------
-- |----------------------< user_in_static_per_list >-------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION user_in_static_per_list
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_return      BOOLEAN := FALSE;
    l_person_id   NUMBER;
    l_proc        VARCHAR2(72) := g_package||'user_in_static_per_list';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        IF g_dbg THEN op(l_proc, 30); END IF;

        --
        -- Here it is important to specify that the security_profile_id is not
        -- null because rows with a null security_profile_id indicate
        -- access explicitly granted through SSHR, and this should not be
        -- picked up here.
        --
        SELECT ppl.person_id
        INTO   l_person_id
        FROM   per_person_list ppl
        WHERE  ppl.granted_user_id IS NOT NULL
        AND    ppl.security_profile_id IS NOT NULL
        AND    ppl.granted_user_id = p_user_id
        AND    ppl.security_profile_id = p_security_profile_id
        AND    rownum = 1;

        IF g_dbg THEN op(l_proc, 40); END IF;

    END IF;

    l_return := (l_person_Id IS NOT NULL);

    IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;

    RETURN l_return;

EXCEPTION

    WHEN no_data_found THEN

        IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

        RETURN l_return;

END user_in_static_per_list;
--
-- ----------------------------------------------------------------------------
-- |----------------------< user_in_static_asg_list >-------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION user_in_static_asg_list
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_return        BOOLEAN := FALSE;
    l_assignment_id NUMBER;
    l_proc          VARCHAR2(72) := g_package||'user_in_static_asg_list';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        IF g_dbg THEN op(l_proc, 30); END IF;

        SELECT pal.assignment_id
        INTO   l_assignment_id
        FROM   per_assignment_list pal
        WHERE  pal.user_id IS NOT NULL
        AND    pal.security_profile_id IS NOT NULL
        AND    pal.user_id = p_user_id
        AND    pal.security_profile_id = p_security_profile_id
        AND    rownum = 1;

        IF g_dbg THEN op(l_proc, 40); END IF;

    END IF;

    l_return := (l_assignment_id IS NOT NULL);

    IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;

    RETURN l_return;

EXCEPTION

    WHEN no_data_found THEN

        IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

        RETURN l_return;

END user_in_static_asg_list;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_org_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_org_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get deleted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'delete_org_list_for_user';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        --
        -- Delete all orgs in per_organization_list for this user
        -- and this security profile.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        DELETE FROM per_organization_list pol
        WHERE  pol.user_id IS NOT NULL
        AND    pol.security_profile_id IS NOT NULL
        AND    pol.user_id = p_user_id
        AND    pol.security_profile_id = p_security_profile_id;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END delete_org_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pos_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_pos_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get deleted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'delete_pos_list_for_user';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        --
        -- Delete all positions in per_position_list for this user
        -- and this security profile.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        DELETE FROM per_position_list ppl
        WHERE  ppl.user_id IS NOT NULL
        AND    ppl.security_profile_id IS NOT NULL
        AND    ppl.user_id = p_user_id
        AND    ppl.security_profile_id = p_security_profile_id;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END delete_pos_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_per_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_per_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get deleted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'delete_per_list_for_user';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        --
        -- Delete all people in per_person_list for this user
        -- and this security profile.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        --
        -- Here it is important to specify that the security_profile_id is not
        -- null because rows with a null security_profile_id indicate
        -- access explicitly granted through SSHR.
        --
        DELETE FROM per_person_list ppl
        WHERE  ppl.granted_user_id IS NOT NULL
        AND    ppl.security_profile_id IS NOT NULL
        AND    ppl.granted_user_id = p_user_id
        AND    ppl.security_profile_id = p_security_profile_id;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END delete_per_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_asg_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_asg_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get deleted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'delete_asg_list_for_user';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN

        --
        -- Delete all assignments in per_assignment_list for this user
        -- and this security profile.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        DELETE FROM per_assignment_list pal
        WHERE  pal.user_id IS NOT NULL
        AND    pal.security_profile_id IS NOT NULL
        AND    pal.user_id = p_user_id
        AND    pal.security_profile_id = p_security_profile_id;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END delete_asg_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_org_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_org_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get inserted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.  Used for populating the who columns.
    --
    l_proc              VARCHAR2(72) := g_package||'insert_org_list_for_user';
    l_request_id              NUMBER := fnd_profile.value('CONC_REQUEST_ID');
    l_program_id              NUMBER := fnd_profile.value('CONC_PROGRAM_ID');
    l_program_application_id  NUMBER := fnd_profile.value
                                            ('CONC_PROGRAM_APPLICATION_ID');
    i NUMBER;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If all the values needed to insert rows are available,
    -- insert them.
    --
    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL
    AND g_org_tbl.COUNT > 0 THEN
        --
        -- Unfortunately, a bulk insert (forall) statement cannot
        -- be used here because the index is by organization_id
        -- and is therefore not contiguous and there are likely
        -- to be gaps in the range.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        i := g_org_tbl.FIRST;

        WHILE i <= g_org_tbl.LAST LOOP
            --
            -- There is no duplicate row checking.  Although the index
            -- in g_org_tbl will be unique, this routine relies on
            -- existing rows to have been deleted (through
            -- delete_org_list_for_user) prior to insertion.
            --
            IF g_dbg THEN op(l_proc||'('||to_char(i)||'):'); END IF;

            INSERT INTO per_organization_list
                (security_profile_id
                ,organization_id
                ,user_id
                ,request_id
                ,program_application_id
                ,program_id
                ,program_update_date)
            VALUES
                (p_security_profile_id
                ,i
                ,p_user_id
                ,l_request_id
                ,l_program_application_id
                ,l_program_id
                ,sysdate
                );

            i := g_org_tbl.NEXT(i);

        END LOOP;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END insert_org_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_pos_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_pos_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get inserted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.  Used for populating the who columns.
    --
    l_proc              VARCHAR2(72) := g_package||'insert_pos_list_for_user';
    l_request_id              NUMBER := fnd_profile.value('CONC_REQUEST_ID');
    l_program_id              NUMBER := fnd_profile.value('CONC_PROGRAM_ID');
    l_program_application_id  NUMBER := fnd_profile.value
                                            ('CONC_PROGRAM_APPLICATION_ID');
    i NUMBER;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If all the values needed to insert rows are available,
    -- insert them.
    --
    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL
    AND g_pos_tbl.COUNT > 0 THEN
        --
        -- Unfortunately, a bulk insert (forall) statement cannot
        -- be used here because the index is by position_id
        -- and is therefore not contiguous and there are likely
        -- to be gaps in the range.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        i := g_pos_tbl.FIRST;

        WHILE i <= g_pos_tbl.LAST LOOP
            --
            -- There is no duplicate row checking.  Although the index
            -- in g_pos_tbl will be unique, this routine relies on
            -- existing rows to have been deleted (through
            -- delete_pos_list_for_user) prior to insertion.
            --
            IF g_dbg THEN op(l_proc||'('||to_char(i)||'):'); END IF;

            INSERT INTO per_position_list
                (security_profile_id
                ,position_id
                ,user_id
                ,request_id
                ,program_application_id
                ,program_id
                ,program_update_date)
            VALUES
                (p_security_profile_id
                ,i
                ,p_user_id
                ,l_request_id
                ,l_program_application_id
                ,l_program_id
                ,sysdate
                );

            i := g_pos_tbl.NEXT(i);

        END LOOP;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END insert_pos_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_per_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_per_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get inserted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.  Used for populating the who columns.
    --
    l_proc              VARCHAR2(72) := g_package||'insert_per_list_for_user';
    l_request_id              NUMBER := fnd_profile.value('CONC_REQUEST_ID');
    l_program_id              NUMBER := fnd_profile.value('CONC_PROGRAM_ID');
    l_program_application_id  NUMBER := fnd_profile.value
                                            ('CONC_PROGRAM_APPLICATION_ID');
    i NUMBER;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If all the values needed to insert rows are available,
    -- insert them.
    --
    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL
    AND g_per_tbl.COUNT > 0 THEN
        --
        -- Unfortunately, a bulk insert (forall) statement cannot
        -- be used here because the index is by person_id
        -- and is therefore not contiguous and there are likely
        -- to be gaps in the range.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        i := g_per_tbl.FIRST;

        WHILE i <= g_per_tbl.LAST LOOP
            --
            -- There is no duplicate row checking.  Although the index
            -- in g_per_tbl will be unique, this routine relies on
            -- existing rows to have been deleted (through
            -- delete_per_list_for_user) prior to insertion.
            --
            IF g_dbg THEN op(l_proc||'('||to_char(i)||'):'); END IF;

            INSERT INTO per_person_list
                (security_profile_id
                ,person_id
                ,granted_user_id
                ,request_id
                ,program_application_id
                ,program_id
                ,program_update_date)
            VALUES
                (p_security_profile_id
                ,i
                ,p_user_id
                ,l_request_id
                ,l_program_application_id
                ,l_program_id
                ,sysdate
                );

            i := g_per_tbl.NEXT(i);

        END LOOP;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END insert_per_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_asg_list_for_user >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_asg_list_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- Break out into an autonomous transaction so that this does not
    -- share the same commit cycle as the calling routine.
    -- This ensures rows get inserted where there is no assumed commits
    -- elsewhere, for example, at longon.  It also commits regardless of
    -- unexpected exceptions elsewhere.
    --
    PRAGMA AUTONOMOUS_TRANSACTION;

    --
    -- Local variables.  Used for populating the who columns.
    --
    l_proc              VARCHAR2(72) := g_package||'insert_asg_list_for_user';
    l_request_id              NUMBER := fnd_profile.value('CONC_REQUEST_ID');
    l_program_id              NUMBER := fnd_profile.value('CONC_PROGRAM_ID');
    l_program_application_id  NUMBER := fnd_profile.value
                                            ('CONC_PROGRAM_APPLICATION_ID');
    i NUMBER;

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If all the values needed to insert rows are available,
    -- insert them.
    --
    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL
    AND g_asg_tbl.COUNT > 0 THEN
        --
        -- Unfortunately, a bulk insert (forall) statement cannot
        -- be used here because the index is by assignment_id
        -- and is therefore not contiguous and there are likely
        -- to be gaps in the range.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        i := g_asg_tbl.FIRST;

        WHILE i <= g_asg_tbl.LAST LOOP
            --
            -- There is no duplicate row checking.  Although the index
            -- in g_asg_tbl will be unique, this routine relies on
            -- existing rows to have been deleted (through
            -- delete_asg_list_for_user) prior to insertion.
            --
            IF g_dbg THEN op(l_proc||'('||to_char(i)||'):'); END IF;

            INSERT INTO per_assignment_list
                (security_profile_id
                ,assignment_id
                ,person_id
                ,user_id
                ,request_id
                ,program_application_id
                ,program_id
                ,program_update_date)
            VALUES
                (p_security_profile_id
                ,i
                ,g_asg_tbl(i)
                ,p_user_id
                ,l_request_id
                ,l_program_application_id
                ,l_program_id
                ,sysdate
                );

            i := g_asg_tbl.NEXT(i);

        END LOOP;

        IF g_dbg THEN op(l_proc, 30); END IF;
        --
        -- This is an autonomous transaction so an explicit
        -- commit or rollback is required.
        --
        COMMIT;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END insert_asg_list_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< evaluate_org_access >-----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION evaluate_org_access
    (p_user_id              IN NUMBER
    ,p_effective_date       IN DATE
    ,p_assignments_tbl      IN g_assignments_t
    ,p_sec_prof_rec         IN g_sec_prof_r
    ,p_use_static_lists     IN BOOLEAN DEFAULT TRUE
    ,p_update_static_lists  IN BOOLEAN DEFAULT FALSE)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_org_structure_version_id NUMBER;
    l_proc                     VARCHAR2(72) := g_package||'evaluate_org_access';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If there is no organization security, return true.
    --
    IF NOT restricted_orgs(p_sec_prof_rec) THEN
        IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;
        RETURN TRUE;
    END IF;

    --
    -- Here organization security is evaluated on the fly.
    -- This is done dynamically because:
    --   a) user-based org security is in use and the user does
    --      not have their permissions stored in static tables, or
    --   b) the per_organization_list table is not to be used.
    --
    IF NOT p_use_static_lists
    OR (NVL(p_sec_prof_rec.top_organization_method, 'S') = 'U'
        AND NOT user_in_static_org_list(p_user_id
                                       ,p_sec_prof_rec.security_profile_id))
    THEN
        --
        -- Start by getting the organization hierarchy version for the
        -- security profile. Note that the structure ID will be null
        -- when only Include orgs are used.  In this case, the
        -- get_org_structure_version function below will return null
        -- and the org hierarchy assessment will be stepped over.
        --
        IF g_dbg THEN op(l_proc, 30); END IF;

        l_org_structure_version_id := get_org_structure_version
            (p_sec_prof_rec.organization_structure_id
            ,p_effective_date);

        IF l_org_structure_version_id IS NOT NULL THEN
            --
            -- This will occur when using, for example, include organizations
            -- without hierarchies.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            IF NVL(p_sec_prof_rec.top_organization_method, 'S') = 'U' THEN
                --
                -- If using user-based security, permissions must be
                -- evaluated on a per assignment basis.
                --
                IF g_dbg THEN op(l_proc, 50); END IF;

                IF p_assignments_tbl.COUNT > 0 THEN
                    --
                    -- Check that assignments exist and evaluate access
                    -- for each assignment.
                    --
                    IF g_dbg THEN op(l_proc, 60); END IF;

                    FOR i IN p_assignments_tbl.FIRST..p_assignments_tbl.LAST LOOP

                        --
                        -- Add the organizations in the hierarchy to the cache,
                        -- using the assignment's organization as the top
                        -- org.
                        --
                        IF g_dbg THEN op(l_proc||'('||
                           to_char(p_assignments_tbl(i).assignment_id)||')', 10);
                        END IF;

                        add_hier_orgs_to_cache
                            (p_assignments_tbl(i).organization_id
                            ,l_org_structure_version_id
                            ,p_sec_prof_rec.include_top_organization_flag);

                        IF g_dbg THEN op(l_proc||'('||
                           to_char(p_assignments_tbl(i).assignment_id)||')', 20);
                        END IF;
                    END LOOP;
                END IF; -- End of evaluating each individual assignment

            ELSE
                --
                -- Add the organizations in the hierarchy to the cache,
                -- using the organization specified on the security profile
                -- as the top org.
                --
                IF g_dbg THEN op(l_proc, 70); END IF;

                add_hier_orgs_to_cache
                    (p_sec_prof_rec.organization_id
                    ,l_org_structure_version_id
                    ,p_sec_prof_rec.include_top_organization_flag);
            END IF;
        END IF;

        IF g_dbg THEN op(l_proc, 90); END IF;

        --
        -- If the exclude business groups flag is ticked, remove any BGs
        -- already in the list.
        -- If the exclude business groups flag is unticked, add the orgs'
        -- owning BGs to the list.
        --
        add_remove_bgs_for_orgs(p_sec_prof_rec.exclude_business_groups_flag
                               ,p_sec_prof_rec.business_group_id);

        IF g_dbg THEN op(l_proc, 100); END IF;
        --
        -- Add the include organizations; remove the exclude
        -- organizations.
        --
        add_incl_remove_excl_orgs(p_sec_prof_rec.security_profile_id);

        IF g_dbg THEN op(l_proc, 110); END IF;

    ELSE
        --
        -- Organization security will not be calculated on the fly
        -- so the static org list is cached.
        --
        IF g_dbg THEN op(l_proc, 120); END IF;

        add_static_orgs_to_cache(p_user_id
                                ,p_sec_prof_rec.security_profile_id
                                ,p_sec_prof_rec.top_organization_method);

        IF g_dbg THEN op(l_proc, 130); END IF;

    END IF;

    IF g_dbg THEN op(l_proc, 140); END IF;

    IF p_update_static_lists
    AND NVL(p_sec_prof_rec.top_organization_method, 'S') = 'U'
    THEN
        --
        -- Existing records for this user are deleted and then
        -- re-inserted.  Records are only inserted if this profile
        -- is using user-based org security.
        --
        IF g_dbg THEN op(l_proc, 150); END IF;

        delete_org_list_for_user
            (p_user_id, p_sec_prof_rec.security_profile_id);
        insert_org_list_for_user
            (p_user_id,p_sec_prof_rec.security_profile_id);

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN TRUE;

END evaluate_org_access;
--
-- ----------------------------------------------------------------------------
-- |----------------------< evaluate_pos_access >-----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION evaluate_pos_access
    (p_user_id              IN NUMBER
    ,p_effective_date       IN DATE
    ,p_assignments_tbl      IN g_assignments_t
    ,p_sec_prof_rec         IN g_sec_prof_r
    ,p_use_static_lists     IN BOOLEAN DEFAULT TRUE
    ,p_update_static_lists  IN BOOLEAN DEFAULT FALSE)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_pos_structure_version_id NUMBER;
    l_restricted_orgs          BOOLEAN;
    l_proc                     VARCHAR2(72) := g_package||'evaluate_pos_access';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If there is no position security, return true.
    --
    IF NOT restricted_pos(p_sec_prof_rec) THEN
        IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;
        RETURN TRUE;
    END IF;

    --
    -- Here position security is evaluated on the fly.
    -- This is done dynamically because:
    --   a) user-based pos security or user-based org security
    --      is in use and the user does not have their permissions
    --      stored in static tables, or
    --   b) the per_position_list table is not to be used.
    --
    IF NOT p_use_static_lists
    OR ((NVL(p_sec_prof_rec.top_position_method, 'S') = 'U' OR
         NVL(p_sec_prof_rec.top_organization_method, 'S') = 'U')
        AND NOT user_in_static_pos_list(p_user_id
                                       ,p_sec_prof_rec.security_profile_id))
    THEN

        IF g_dbg THEN op(l_proc, 20); END IF;
        l_restricted_orgs := restricted_orgs(p_sec_prof_rec);

        IF l_restricted_orgs AND (NOT org_access_known) THEN
            --
            -- The profile has organization restrictions, but
            -- the evaluation of organization security was deferred
            -- for performance reasons.  The org permissions
            -- are needed to determine the position permissions, so
            -- force evaluation of organization security permissions
            -- now.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            evaluate_access
                (p_person_id           => g_access_known_rec.person_id
                ,p_user_id             => p_user_id
                ,p_effective_date      => p_effective_date
                ,p_sec_prof_rec        => p_sec_prof_rec
                ,p_what_to_evaluate    => g_ORG_SEC_ONLY
                ,p_update_static_lists => p_update_static_lists
                ,p_debug               => g_dbg_type);
        END IF;

        --
        -- Get the position hierarchy version for the security
        -- profile. Note that the structure ID should be
        -- set (the below "IF" is for safety).
        --
        IF g_dbg THEN op(l_proc, 30); END IF;

        l_pos_structure_version_id := get_pos_structure_version
            (p_sec_prof_rec.position_structure_id
            ,p_effective_date);

        IF l_pos_structure_version_id IS NOT NULL THEN
            --
            -- This will occur if the hierarchy exists but does not have
            -- versions.
            --
            IF g_dbg THEN op(l_proc, 40); END IF;

            IF NVL(p_sec_prof_rec.top_position_method, 'S') = 'U' THEN
                --
                -- If using user-based security, permissions must be
                -- evaluated on a per assignment basis.
                --
                IF g_dbg THEN op(l_proc, 50); END IF;

                IF p_assignments_tbl.COUNT > 0 THEN
                    --
                    -- Check that assignments exist and evaluate access
                    -- for each assignment.
                    --
                    IF g_dbg THEN op(l_proc, 60); END IF;

                    FOR i IN p_assignments_tbl.FIRST..p_assignments_tbl.LAST LOOP
                        --
                        -- Add the positions in the hierarchy to the cache,
                        -- using the assignment's position as the top
                        -- position.
                        --
                        IF g_dbg THEN op(l_proc||'('||
                           to_char(p_assignments_tbl(i).assignment_id)||')', 10);
                        END IF;

                        add_hier_pos_to_cache
                            (p_assignments_tbl(i).position_id
                            ,l_pos_structure_version_id
                            ,p_sec_prof_rec.include_top_position_flag
                            ,p_effective_date
                            ,l_restricted_orgs);

                        IF g_dbg THEN op(l_proc||'('||
                           to_char(p_assignments_tbl(i).assignment_id)||')', 20);
                        END IF;
                    END LOOP;
                END IF; -- End of evaluating each individual assignment

            ELSE
                --
                -- Add the positions in the hierarchy to the cache,
                -- using the position specified on the security profile
                -- as the top position.
                --
                IF g_dbg THEN op(l_proc, 70); END IF;

                add_hier_pos_to_cache
                    (p_sec_prof_rec.position_id
                    ,l_pos_structure_version_id
                    ,p_sec_prof_rec.include_top_position_flag
                    ,p_effective_date
                    ,l_restricted_orgs);

                IF g_dbg THEN op(l_proc, 80); END IF;
            END IF;
        END IF;

        IF g_dbg THEN op(l_proc, 90); END IF;

    ELSE
        --
        -- Position security will not be calculated on the fly
        -- so the static position list is cached.
        --
        IF g_dbg THEN op(l_proc, 100); END IF;

        add_static_pos_to_cache(p_user_id
                               ,p_sec_prof_rec.security_profile_id
                               ,p_sec_prof_rec.top_position_method);

        IF g_dbg THEN op(l_proc, 110); END IF;

    END IF;

    IF g_dbg THEN op(l_proc, 120); END IF;

    IF p_update_static_lists AND
    NVL(p_sec_prof_rec.top_position_method, 'S') = 'U'
    THEN
        --
        -- Existing records for this user are deleted and then
        -- re-inserted.  Records are only inserted if this profile
        -- is using user-based org security.
        --
        IF g_dbg THEN op(l_proc, 130); END IF;

        delete_pos_list_for_user
            (p_user_id, p_sec_prof_rec.security_profile_id);
        insert_pos_list_for_user
            (p_user_id,p_sec_prof_rec.security_profile_id);

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN TRUE;

END evaluate_pos_access;
--
-- ----------------------------------------------------------------------------
-- |----------------------< evaluate_pay_access >-----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION evaluate_pay_access
    (p_user_id              IN NUMBER
    ,p_effective_date       IN DATE
    ,p_sec_prof_rec         IN g_sec_prof_r
    ,p_use_static_lists     IN BOOLEAN DEFAULT TRUE)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'evaluate_pay_access';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- If there is no payroll security, return true.
    --
    IF NOT restricted_pays(p_sec_prof_rec) THEN
        IF g_dbg THEN op(l_proc, 20); END IF;
        RETURN TRUE;
    END IF;

    IF NOT p_use_static_lists THEN
        --
        -- Here payroll security is evaluated on the fly if static
        -- lists will not be used.
        --
        IF g_dbg THEN op(l_proc, 30); END IF;

        add_sec_prof_pay_to_cache(p_sec_prof_rec.security_profile_id
                                 ,p_sec_prof_rec.include_exclude_payroll_flag
                                 ,p_sec_prof_rec.business_group_id
                                 ,p_effective_date);

        IF g_dbg THEN op(l_proc, 40); END IF;

    ELSE
        --
        -- Payroll security will not be calculated on the fly
        -- so the static payroll list is cached.
        --
        IF g_dbg THEN op(l_proc, 50); END IF;

        add_static_pay_to_cache(p_sec_prof_rec.security_profile_id);

        IF g_dbg THEN op(l_proc, 60); END IF;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN TRUE;

END evaluate_pay_access;
--
-- ----------------------------------------------------------------------------
-- |----------------------< evaluate_per_access >-----------------------------|
-- ----------------------------------------------------------------------------
--
function evaluate_per_access(
         p_user_id              in number
        ,p_effective_date       in date
        ,p_assignments_tbl      in g_assignments_t
        ,p_sec_prof_rec         in g_sec_prof_r
        ,p_use_static_lists     in boolean default true
        ,p_update_static_lists  in boolean default false
        ) return boolean is
  -- Local variables.
  l_proc              varchar2(72) := g_package||'evaluate_per_access';
  l_user_restriction  boolean      := false;
  l_restricted_orgs   boolean      := false;
  l_restricted_pos    boolean      := false;
  l_restricted_pays   boolean      := false;
  l_only_use_static   boolean      := false;
  --
begin
  --
  if g_dbg then op('Entering: '||l_proc, 1); end if;
  --
  -- If there is no person security, return true.
  if not restricted_pers(p_sec_prof_rec) then
    --
    if g_dbg then op(l_proc, 20); end if;
    return true;
    --
  end if;
  --
  -- Record whether this profile uses a user-based restriction.
  if nvl(p_sec_prof_rec.top_organization_method, 'S')      = 'U' or
     nvl(p_sec_prof_rec.top_position_method, 'S')          = 'U' or
     nvl(p_sec_prof_rec.restrict_by_supervisor_flag, 'N') <> 'N' or
     nvl(p_sec_prof_rec.custom_restriction_flag, 'N')      = 'U' then
    --
    l_user_restriction := true;
    --
  end if;
  --
  -- The static lists will be used when:
  -- a) No user-based or assignment-level security is in use,
  -- b) Assignment-level security is used without user-based security
  --    (the static lists are used for person-level security only where
  --    assignment security is evaluated dynamically),
  -- c) User-based security is in use, but permissions for this user
  --    are stored in static lists.
  if p_use_static_lists and
    (not l_user_restriction or
        (l_user_restriction and user_in_static_per_list(p_user_id,
                                p_sec_prof_rec.security_profile_id))) then
    --
    l_only_use_static := true;
    --
  end if;
  --
  -- Security is only assessed dynamically where essential.
  -- The conditions that force this are:
  -- a) User-based security is used and the user-based permissions
  --    are not stored in static lists for this user,
  -- a) Assignment-level security is in use and the assignment-level
  --    permissions are not stored in static lists for this user,
  -- c) The p_use_static_lists parameter is forcing the dynamic
  --    evaluation of security.
  if not l_only_use_static or
    (nvl(p_sec_prof_rec.restrict_on_individual_asg, 'N') = 'Y'
     and not user_in_static_asg_list(p_user_id,
             p_sec_prof_rec.security_profile_id)) then
    --
    -- First, ensure all other security criteria has already
    -- been evaluated where it is needed.
    if g_dbg then op(l_proc, 20); end if;
    --
    l_restricted_orgs := restricted_orgs(p_sec_prof_rec);
    --
    if l_restricted_orgs and (not org_access_known) then
      --
      -- The profile has organization restrictions, but
      -- the evaluation of organization security was deferred
      -- for performance reasons.  The org permissions
      -- are needed to determine the per / asg permissions, so
      -- force evaluation of organization security permissions now.
      if g_dbg then op(l_proc, 30); end if;
      --
      evaluate_access(p_person_id           => g_access_known_rec.person_id
                     ,p_user_id             => p_user_id
                     ,p_effective_date      => p_effective_date
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_what_to_evaluate    => g_ORG_SEC_ONLY
                     ,p_update_static_lists => p_update_static_lists
                     ,p_debug               => g_dbg_type);
      --
    end if;
    --
    if g_dbg then op(l_proc, 40); end if;
    --
    l_restricted_pos := restricted_pos(p_sec_prof_rec);
    --
    if l_restricted_pos and (not pos_access_known) then
      --
      -- The profile has position restrictions, but
      -- the evaluation of position security was deferred
      -- for performance reasons.  The pos permissions
      -- are needed to determine the per / asg permissions, so
      -- force evaluation of position security permissions now.
      if g_dbg then op(l_proc, 50); end if;
      --
      evaluate_access(p_person_id           => g_access_known_rec.person_id
                     ,p_user_id             => p_user_id
                     ,p_effective_date      => p_effective_date
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_what_to_evaluate    => g_POS_SEC_ONLY
                     ,p_update_static_lists => p_update_static_lists
                     ,p_debug               => g_dbg_type);
      --
    end if;
    --
    if g_dbg then op(l_proc, 60); end if;
    --
    l_restricted_pays := restricted_pays(p_sec_prof_rec);
    --
    if l_restricted_pays and (not pay_access_known) then
      --
      -- The profile has payroll restrictions, but
      -- the evaluation of payroll security was deferred
      -- for performance reasons.  The pay permissions
      -- are needed to determine the per / asg permissions, so
      -- force evaluation of payroll security permissions now.
      if g_dbg then op(l_proc, 70); end if;
      --
      evaluate_access(p_person_id           => g_access_known_rec.person_id
                     ,p_user_id             => p_user_id
                     ,p_effective_date      => p_effective_date
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_what_to_evaluate    => g_PAY_SEC_ONLY
                     ,p_update_static_lists => p_update_static_lists
                     ,p_debug               => g_dbg_type);
      --
    end if;
    --
    -- Evaluate person and assignment security permissions.
    if g_dbg then op(l_proc, 80); end if;

    add_people_to_cache(p_top_person_id    => g_access_known_rec.person_id
                       ,p_effective_date   => p_effective_date
                       ,p_sec_prof_rec     => p_sec_prof_rec
                       ,p_use_static_lists => p_use_static_lists);

    --
    -- Contacts for the people visible (both related and unrelated) and
    -- rows in per_person_list_changes are not processed and so not visible
    -- for all types of user-based security.

    -- The reason for this is to remain consistent with supervisor security
    -- (been around since 11i) where PPLC people were not processed and
    -- so not visible and contacts only being visible in a view all contacts
    -- profile.

    -- It is possible that future enhancements will allow contacts to be
    -- displayed in a user-based profile, but as it stands now they are
    -- never visible: the routines are kept here for future use only.

    -- Add contacts to the cache if the profile restricts by contacts.
    -- If the security profile does not restrict by  contacts, people
    -- are not added to the cache because the secure views handle
    -- this scenario without need to refer to the cache.

    -- A condition with view_all_contacts_flag = All and
    -- view_all_candidates_flag = None, needs caching (ie: similar to
    -- record existing in per_person_list). The additional OR condition
    -- is included as part of Candidate Security enchancements.

    -- if p_sec_prof_rec.view_all_contacts_flag = 'N' or
    --   (p_sec_prof_rec.view_all_contacts_flag = 'Y' and
    --    p_sec_prof_rec.view_all_candidates_flag = 'X') then
         --
    --   add_contacts_to_cache(p_effective_date
    --                        ,p_sec_prof_rec.business_group_id);
         --
    -- end if;
    --
    -- However Candidate Security still needs the contacts to be cached
    -- atleast for the following condition.
    if p_sec_prof_rec.view_all_contacts_flag   = 'Y' and
       p_sec_prof_rec.view_all_candidates_flag = 'X' then
      --
      add_contacts_to_cache(p_effective_date
                           ,p_sec_prof_rec.business_group_id);
      --
    end if;
    -- Add the people in per_person_list_changes to the cache.
    -- It is expected that this can be obsoleted at a future
    -- date, because per_person_list_changes is effectively
    -- obsolete and is retained solely for the purpose of not
    -- breaking customer custom processes that use this table.

    -- add_per_list_changes_to_cache(p_sec_prof_rec.security_profile_id
    --                              ,p_effective_date);

  end if;
  --
  if l_only_use_static then
    --
    -- Person security will not be calculated on the fly
    -- so the static person list is cached.
    add_static_per_to_cache(p_user_id
                           ,p_sec_prof_rec.security_profile_id
                           ,l_user_restriction);
    --
    -- If restricting at an assignment level, also cache
    -- the assignment list.
    if nvl(p_sec_prof_rec.restrict_on_individual_asg, 'N') = 'Y' then
      --
      add_static_asg_to_cache(p_user_id
                             ,p_sec_prof_rec.security_profile_id
                             ,l_user_restriction);
      --
    end if;
    --
  end if;
  --
  -- Add granted users and their assignments to the cache.
  add_granted_users_to_cache(p_user_id
                            ,p_effective_date
                            ,p_sec_prof_rec.allow_granted_users_flag
                            ,p_sec_prof_rec.restrict_on_individual_asg);
  --
  -- Caching candidates (registered users through iRecruitment), this is
  -- valid only if the iRecruitment is installed.
  if p_sec_prof_rec.view_all_candidates_flag = 'Y' and
     p_sec_prof_rec.view_all_contacts_flag = 'N' then
    --
    add_candidates_to_cache(p_effective_date
                           ,p_sec_prof_rec.business_group_id);
    --
  end if;
  --
  if p_update_static_lists and l_user_restriction then
    --
    -- Existing records for this user are deleted and then
    -- re-inserted.  Records are only inserted if this profile
    -- is using user-based security.
    if g_dbg then op(l_proc, 130); end if;
    --
    delete_per_list_for_user(p_user_id,p_sec_prof_rec.security_profile_id);
    --
    insert_per_list_for_user(p_user_id,p_sec_prof_rec.security_profile_id);
    --
    if g_dbg then op(l_proc, 140); end if;
    --
    if nvl(p_sec_prof_rec.restrict_on_individual_asg, 'N') = 'Y' then
      --
      -- Only insert the assignment privileges if securing
      -- at an assignment level.
      if g_dbg then op(l_proc, 150); end if;
      --
      delete_asg_list_for_user(p_user_id,p_sec_prof_rec.security_profile_id);
      --
      insert_asg_list_for_user(p_user_id,p_sec_prof_rec.security_profile_id);
      --
      if g_dbg then op(l_proc, 160); end if;
      --
    end if;
    --
  end if;
  --
  if g_dbg then op('Leaving: '||l_proc, 999); end if;
  --
  return true;
  --
end evaluate_per_access;
--
-- ----------------------------------------------------------------------------
-- |----------------------< evaluate_access >---------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE evaluate_access
    (p_user_id             IN NUMBER
    ,p_effective_date      IN DATE
    ,p_sec_prof_rec        IN g_sec_prof_r
    ,p_person_id           IN NUMBER       DEFAULT NULL
    ,p_what_to_evaluate    IN NUMBER       DEFAULT g_PER_SEC_ONLY
    ,p_use_static_lists    IN BOOLEAN      DEFAULT TRUE
    ,p_update_static_lists IN BOOLEAN      DEFAULT FALSE
    ,p_debug               IN NUMBER       DEFAULT g_NO_DEBUG)
IS

    --
    -- Local variables.
    --
    l_proc            VARCHAR2(72) := g_package||'evaluate_access';
    l_debug           BOOLEAN      := FALSE;
    l_effective_date  DATE         := TRUNC(p_effective_date);
    l_assignments_tbl g_assignments_t;

BEGIN

    --
    -- Initialise debugging.
    --
    IF p_debug = g_NO_DEBUG THEN
        --
        -- If no debug was specified (or defaulted) then
        -- checking for standard HRMS Pipe output.
        --
        IF g_debug THEN
            g_dbg_type := g_PIPE;
            g_dbg      := TRUE;
        END IF;
    ELSIF p_debug <> g_NO_DEBUG THEN
        --
        -- If debugging was specified, set accordingly.
        --
        g_dbg_type := p_debug;
        g_dbg      := TRUE;
    END IF;

    IF g_dbg THEN
       op('Entering: '||l_proc, 1);
       op(' ');
       op(' --------------------------------'||
          '---------------------------------');
       op(' Profile: '||p_sec_prof_rec.security_profile_name);
       op(' --------------------------------'||
          '+--------------------------------');
       op('  p_person_id                      '||
             to_char(p_person_id));
       op('  p_user_id                        '||
             to_char(p_user_id));
       op('  p_effective_date                 '||
             to_char(l_effective_date));
       op('  p_security_profile_id            '||
             to_char(p_sec_prof_rec.security_profile_id));
       op('  p_business_group_id              '||
             to_char(p_sec_prof_rec.business_group_id));
       op('  p_view_all_flag                  '||
             p_sec_prof_rec.view_all_flag);
       op('  p_reporting_oracle_username      '||
             p_sec_prof_rec.reporting_oracle_username);
       op('  p_allow_granted_users_flag       '||
             p_sec_prof_rec.allow_granted_users_flag);
       op('  p_restrict_on_individual_asg     '||
             p_sec_prof_rec.restrict_on_individual_asg);
       op('  p_view_all_employees_flag        '||
             p_sec_prof_rec.view_all_employees_flag);
       op('  p_view_all_cwk_flag              '||
             p_sec_prof_rec.view_all_cwk_flag);
       op('  p_view_all_applicants_flag       '||
             p_sec_prof_rec.view_all_applicants_flag);
       op('  p_view_all_contacts_flag         '||
             p_sec_prof_rec.view_all_contacts_flag);
       op('  p_view_all_organizations_flag    '||
             p_sec_prof_rec.view_all_organizations_flag);
       op('  p_org_security_mode              '||
             p_sec_prof_rec.org_security_mode);
       op('  p_top_organization_method        '||
             p_sec_prof_rec.top_organization_method);
       op('  p_organization_structure_id      '||
             to_char(p_sec_prof_rec.organization_structure_id));
       op('  p_organization_id                '||
             to_char(p_sec_prof_rec.organization_id));
       op('  p_include_top_organization_flag  '||
             p_sec_prof_rec.include_top_organization_flag);
       op('  p_exclude_business_groups_flag   '||
             p_sec_prof_rec.exclude_business_groups_flag);
       op('  p_view_all_positions_flag        '||
             p_sec_prof_rec.view_all_positions_flag);
       op('  p_top_position_method            '||
             p_sec_prof_rec.top_position_method);
       op('  p_position_structure_id          '||
             to_char(p_sec_prof_rec.position_structure_id));
       op('  p_position_id                    '||
             to_char(p_sec_prof_rec.position_id));
       op('  p_include_top_position_flag      '||
             p_sec_prof_rec.include_top_position_flag);
       op('  p_view_all_payrolls_flag         '||
             p_sec_prof_rec.view_all_payrolls_flag);
       op('  p_include_exclude_payroll_flag   '||
             p_sec_prof_rec.include_exclude_payroll_flag);
       op('  p_restrict_by_supervisor_flag    '||
             p_sec_prof_rec.restrict_by_supervisor_flag);
       op('  p_supervisor_levels              '||
             to_char(p_sec_prof_rec.supervisor_levels));
       op('  p_exclude_secondary_asgs_flag    '||
             p_sec_prof_rec.exclude_secondary_asgs_flag);
       op('  p_exclude_person_flag            '||
             p_sec_prof_rec.exclude_person_flag);
       op('  p_named_person_id                '||
             to_char(p_sec_prof_rec.named_person_id));
       op('  p_custom_restriction_flag        '||
             p_sec_prof_rec.custom_restriction_flag);
       op('  p_what_to_evaluate               '||
             to_char(p_what_to_evaluate));
       IF p_use_static_lists THEN
           op('  p_use_static_lists               '||
                 'TRUE');
       ELSE
           op('  p_use_static_lists               '||
                 'FALSE');
       END IF;
       IF p_update_static_lists THEN
           op('  p_update_static_lists            '||
                 'TRUE');
       ELSE
           op('  p_update_static_lists            '||
                 'FALSE');
       END IF;
    END IF;

    --
    -- Protect against required values being NULL.
    --
    IF p_user_id        IS NOT NULL AND
       l_effective_date IS NOT NULL AND
       p_sec_prof_rec.security_profile_id IS NOT NULL THEN

        --
        -- Check that the permissions in memory (if any) match the
        -- given person, user, and security profile.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF  g_access_known_rec.user_id IS NULL
         OR g_access_known_rec.effective_date IS NULL
         OR g_access_known_rec.security_profile_id IS NULL
         OR g_access_known_rec.user_id <> p_user_id
         OR g_access_known_rec.effective_date <> l_effective_date
         OR g_access_known_rec.security_profile_id <>
               p_sec_prof_rec.security_profile_id
        THEN
            --
            -- Clear the existing permission cache.
            --
            IF g_dbg THEN op(l_proc, 30); END IF;

            g_access_known_rec.org := FALSE;
            g_access_known_rec.pos := FALSE;
            g_access_known_rec.pay := FALSE;
            g_access_known_rec.per := FALSE;
            g_org_tbl.DELETE;
            g_pos_tbl.DELETE;
            g_pay_tbl.DELETE;
            g_per_tbl.DELETE;
            g_asg_tbl.DELETE;

-- Added for Bug 8353429
            g_vac_per_tbl.DELETE;
            g_vac_asg_tbl.DELETE;

            --
            -- Record the contexts of the (soon to be) cached permission.
            --
            g_access_known_rec.person_id := p_person_id;
            g_access_known_rec.user_id := p_user_id;
            g_access_known_rec.effective_date := l_effective_date;
            g_access_known_rec.security_profile_id
                := p_sec_prof_rec.security_profile_id;


        END IF;

        IF g_dbg THEN op(l_proc, 40); END IF;
        --
        --
        -- Fetch the assignments for this person if the person is
        -- known.
        --
        IF p_person_id IS NOT NULL THEN
            l_assignments_tbl :=
              get_assignments(p_person_id, l_effective_date);
        END IF;

        IF g_dbg THEN op(l_proc, 50); END IF;

        --
        -- Evaluate the security permissions for this person
        -- and each assignments.
        --
        -- Not all permissions are evalulated right now.  Where
        -- possible, evaluation is deferred until a more convenient
        -- point (eg, not at longon but perhaps on demand).
        -- The permissions are cached in PL/SQL list tables;
        -- the below g_access_known_rec record is used to indicate
        -- where evaluation has been deferred so that they can be
        -- evaluated at a later point.
        --

        --
        -- Organization security.
        --
        IF p_what_to_evaluate = g_ALL OR
           p_what_to_evaluate = g_ORG_SEC_ONLY
        THEN
            IF g_dbg THEN op(l_proc, 60); END IF;

            g_access_known_rec.org
                := evaluate_org_access
                     (p_user_id             => p_user_id
                     ,p_effective_date      => l_effective_date
                     ,p_assignments_tbl     => l_assignments_tbl
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_use_static_lists    => p_use_static_lists
                     ,p_update_static_lists => p_update_static_lists);
        END IF;

        --
        -- Position security.
        --
        IF p_what_to_evaluate = g_ALL OR
           p_what_to_evaluate = g_POS_SEC_ONLY
        THEN
            IF g_dbg THEN op(l_proc, 70); END IF;

            g_access_known_rec.pos
                := evaluate_pos_access
                     (p_user_id             => p_user_id
                     ,p_effective_date      => l_effective_date
                     ,p_assignments_tbl     => l_assignments_tbl
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_use_static_lists    => p_use_static_lists
                     ,p_update_static_lists => p_update_static_lists);
        END IF;

        --
        -- Payroll security.
        --
        IF p_what_to_evaluate = g_ALL OR
           p_what_to_evaluate = g_PAY_SEC_ONLY
        THEN
            --
            -- Payroll security currently has no user-based feature,
            -- so there is no need to pass the table of assignments.
            -- As such, there is no benefit of using the
            -- p_use_static_lists and p_update_static_lists parameters.
            --
            IF g_dbg THEN op(l_proc, 80); END IF;

            g_access_known_rec.pay
                := evaluate_pay_access
                     (p_user_id             => p_user_id
                     ,p_effective_date      => l_effective_date
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_use_static_lists    => p_use_static_lists);
        END IF;

        --
        -- Person security.
        --
        IF p_what_to_evaluate = g_ALL OR
           p_what_to_evaluate = g_PER_SEC_ONLY
        THEN
            IF g_dbg THEN op(l_proc, 90); END IF;

            g_access_known_rec.per
                := evaluate_per_access
                     (p_user_id             => p_user_id
                     ,p_effective_date      => l_effective_date
                     ,p_assignments_tbl     => l_assignments_tbl
                     ,p_sec_prof_rec        => p_sec_prof_rec
                     ,p_use_static_lists    => p_use_static_lists
                     ,p_update_static_lists => p_update_static_lists);
        END IF;

        --
        -- Keep a record of the fnd session context in the local cache
        -- so that a context change can be detected.
        --
        --DK:4188036. Have moved this call to the end of evaluate_access
        --to guard against the case where apps initialize is called without
        --a change a change in security context.

        sync_session_context;


    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

END evaluate_access;
--
-- ----------------------------------------------------------------------------
-- |----------------------< user_in_static_lists >----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION user_in_static_lists
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
RETURN BOOLEAN IS

    --
    -- Local variables.
    --
    l_proc            VARCHAR2(72) := g_package||'user_in_static_lists';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL and p_security_profile_id IS NOT NULL THEN
        --
        -- Look in each of the static lists for this user and security profile
        -- pair.  If a match is found in any list, immediately return true.
        -- The payroll list does not store static user permissions so it
        -- is not checked here.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        IF user_in_static_org_list(p_user_id, p_security_profile_id) THEN
            IF g_dbg THEN op('Leaving: '||l_proc, 959); END IF;
            RETURN TRUE;
        END IF;

        IF user_in_static_pos_list(p_user_id, p_security_profile_id) THEN
            IF g_dbg THEN op('Leaving: '||l_proc, 969); END IF;
            RETURN TRUE;
        END IF;

        IF user_in_static_per_list(p_user_id, p_security_profile_id) THEN
            IF g_dbg THEN op('Leaving: '||l_proc, 979); END IF;
            RETURN TRUE;
        END IF;

        IF user_in_static_asg_list(p_user_id, p_security_profile_id) THEN
            IF g_dbg THEN op('Leaving: '||l_proc, 989); END IF;
            RETURN TRUE;
        END IF;

    END IF;

    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN FALSE;

END user_in_static_lists;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_static_lists_for_user >--------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_static_lists_for_user
    (p_user_id              IN NUMBER
    ,p_security_profile_id  IN NUMBER)
IS

    --
    -- This is not an autonomous transaction because it is called during
    -- normal transaction processing, eg, by APIs, so an explicit commit
    -- cannot be issued.
    --
    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'delete_static_lists_for_user';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    IF p_user_id IS NOT NULL AND p_security_profile_id IS NOT NULL THEN
        --
        -- Delete from each of the static lists. The only list untouched
        -- is the payroll list and that is because it doesn't contain
        -- the user_id column, ie, it doesn't store static user permissions.
        --
        -- Organization List.
        --
        IF g_dbg THEN op(l_proc, 20); END IF;

        DELETE FROM per_organization_list pol
        WHERE       pol.user_id IS NOT NULL
        AND         pol.security_profile_id IS NOT NULL
        AND         pol.user_id = p_user_id
        AND         pol.security_profile_id = p_security_profile_id;

        --
        -- Position List.
        --
        IF g_dbg THEN op(l_proc, 30); END IF;

        DELETE FROM per_position_list ppl
        WHERE       ppl.user_id IS NOT NULL
        AND         ppl.security_profile_id IS NOT NULL
        AND         ppl.user_id = p_user_id
        AND         ppl.security_profile_id = p_security_profile_id;

        --
        -- Person List.
        --
        -- WARNING: This will delete any self-service grants.
        --
        IF g_dbg THEN op(l_proc, 40); END IF;

        DELETE FROM per_person_list ppl
        WHERE       ppl.granted_user_id IS NOT NULL
        AND         ppl.security_profile_id IS NOT NULL
        AND         ppl.granted_user_id = p_user_id
        AND         ppl.security_profile_id = p_security_profile_id;

        --
        -- Assignment List.
        --
        IF g_dbg THEN op(l_proc, 50); END IF;

        DELETE FROM per_assignment_list pal
        WHERE       pal.user_id IS NOT NULL
        AND         pal.security_profile_id IS NOT NULL
        AND         pal.user_id = p_user_id
        AND         pal.security_profile_id = p_security_profile_id;

    END IF;

END delete_static_lists_for_user;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_effective_date >------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_effective_date RETURN DATE
IS

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'get_effective_date';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Default the effective date to sysdate.  This could potentially
    -- be used in the future to set the effective date to the
    -- date-track effective date, but as it stands now, security
    -- is also determined as of sysdate.
    --
    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN trunc(sysdate);

END get_effective_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_what_to_evaluate >----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_what_to_evaluate RETURN NUMBER
IS

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'get_what_to_evaluate';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Determine what permissions should be cached when a secured object is
    -- first used for a session.  By default, only person security is first
    -- cached (although this may force the caching of org and pos security too
    -- if they are used-based) but it is possible to cache all security
    -- permissions when a secured object is first used, even if only person
    -- security is needed.
    --
    -- THIS PROFILE OPTION HAS NOT BEEN SEEDED, IT IS FOR ORACLE INTERNAL
    -- USE ONLY.
    --
    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN NVL(to_number(fnd_profile.value('HR_SEC_EVALUATION_TYPE'))
              ,g_PER_SEC_ONLY);

END get_what_to_evaluate;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_use_static_lists >----------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_use_static_lists RETURN BOOLEAN
IS

    --
    -- Local variables.
    --
    l_proc VARCHAR2(72) := g_package||'get_use_static_lists';

BEGIN

    IF g_dbg THEN op('Entering: '||l_proc, 1); END IF;

    --
    -- Determine whether the static lists should be used for profiles that
    -- use static security ("Y"), or whether security should be evaluated
    -- dynamically at each session initialisation and the static lists
    -- should be ignored ("N").
    --
    -- THIS PROFILE OPTION HAS NOT BEEN SEEDED, IT IS FOR ORACLE INTERNAL
    -- USE ONLY.
    --
    IF g_dbg THEN op('Leaving: '||l_proc, 999); END IF;

    RETURN (NVL(fnd_profile.value('HR_SEC_USE_STATIC_LISTS'),'Y')
            = 'Y');

END get_use_static_lists;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_security_list_for_bg >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_security_list_for_bg(p_business_group_id NUMBER)
IS
    --
    l_proc    varchar2(80) := g_package||'delete_security_list_for_bg';
    --
    -- DK 16-SEP-1996 Enabled use of business group index
    -- In development there are lots of business groups
    -- and otherwise it is not a very high cost.
    CURSOR pev IS
    SELECT pp.person_id
    FROM   per_people_f    pp,
           per_person_list pl
    WHERE  pp.person_id  = pl.person_id
    AND    pp.business_group_id = p_business_group_id;
BEGIN
    --
    hr_utility.set_location(l_proc,20);
    --
    DELETE FROM pay_security_payrolls psp
    WHERE  psp.business_group_id =  p_business_group_id;
    hr_utility.set_location(l_proc,30);
    --
    DELETE FROM pay_payroll_list ppl
    WHERE EXISTS ( SELECT ''
                   FROM   pay_payrolls_f pay
                   WHERE  pay.payroll_id = ppl.payroll_id
                   AND    pay.business_group_id = p_business_group_id);
    hr_utility.set_location(l_proc,40);
    --
    FOR pevrec IN pev LOOP
    DELETE FROM per_person_list pl
    WHERE pl.person_id = pevrec.person_id;
    END LOOP;
    hr_utility.set_location(l_proc,50);
    --
    -- Changes 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date track position req.
    --
    DELETE FROM per_position_list pol
    WHERE EXISTS ( SELECT ''
                   FROM   hr_all_positions_f pos
                   WHERE  pos.position_id = pol.position_id
                   AND    pos.business_group_id = p_business_group_id);
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',6);

    -- Bug fix 3622082.
    -- Delete statement modified to improve performance.

    -- Bug fix 4889068.
    -- SQL Tuned to improve performance.
    DELETE FROM per_organization_list ol
    WHERE EXISTS ( SELECT null
                   FROM   hr_all_organization_units  ou
                   WHERE  ou.business_group_id = p_business_group_id
                   and    ou.organization_id = ol.organization_id);
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',7);
    DELETE FROM per_security_profiles psp
    WHERE  psp.business_group_id = p_business_group_id
    AND    psp.view_all_flag = 'N';
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',8);

    -- Bug fix 4889068.
    -- SQL Tuned to improve performance.
    DELETE FROM per_security_organizations pso
    WHERE EXISTS( SELECT null
                  FROM   hr_all_organization_units  ou
                  WHERE  ou.business_group_id = p_business_group_id
                  and    ou.organization_id = pso.organization_id);
    --
    hr_utility.set_location('hr_delete.delete_security_list_for_bg',9);
    DELETE FROM per_security_users psu
    WHERE psu.security_profile_id  IN (SELECT sp.security_profile_id
                                       FROM   per_security_profiles  sp
                                       WHERE  sp.business_group_id = p_business_group_id);
    --
END delete_security_list_for_bg;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |------------------< delete_per_from_security_list >-----------------------|
  -- ----------------------------------------------------------------------------
  PROCEDURE delete_per_from_security_list(P_PERSON_ID  IN number)
  IS
  --
   -- bug fix 3760559. l_proc size increased to 80.
      l_proc  varchar2(80) := 'HR_SECURITY_INTERNAL.DELETE_PER_FROM_SECURITY_LIST';
  begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      delete    from per_person_list l
      where    l.person_id    = P_PERSON_ID;
  exception
      when NO_DATA_FOUND then
      hr_utility.set_location(l_proc, 20);
  end delete_per_from_security_list;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< add_org_to_security_list >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_org_to_security_list(p_security_profile_id  in number,
                                   p_organization_id      in number)
IS
  --
      l_proc        varchar2(80) := 'HR_SECURITY_INTERNAL.ADD_ORG_TO_SECURITY_LIST';
  --
      p_program_id               number;
      p_request_id               number;
      p_program_application_id   number;
      p_update_date              date;
  --
BEGIN
      -- Set WHO columns
      p_update_date := trunc(sysdate);
      p_request_id := fnd_profile.value('CONC_REQUEST_ID');

      -- If called from concurrent request then get other values
      IF (p_request_id > 0) THEN
        p_program_id := fnd_profile.value('CONC_PROGRAM_ID');
        p_program_application_id := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
      END IF;

      insert into per_organization_list
      (organization_id
      ,security_profile_id
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date)
      select
         p_organization_id
        ,p_security_profile_id
        ,p_request_id
        ,p_program_application_id
        ,p_program_id
        ,p_update_date
      from  sys.dual
      where not exists(select 1
                       from   per_organization_list pol
                       where  pol.organization_id = p_organization_id
                       and   pol.security_profile_id = p_security_profile_Id
                      );
  --
END add_org_to_security_list;


  --
  -- ----------------------------------------------------------------------------
  -- |------------------< delete_org_from_security_list >-----------------------|
  -- ----------------------------------------------------------------------------
  PROCEDURE delete_org_from_security_list(P_Organization_Id    in number)
  IS
  --
      l_proc  varchar2(80) := 'HR_SECURITY_INTERNAL.DELETE_ORG_FROM_SECURITY_LIST';
  begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      DELETE FROM PER_ORGANIZATION_LIST
      WHERE  organization_id = P_Organization_Id;
  exception
      when NO_DATA_FOUND then
        hr_utility.set_location(l_proc, 20);
  end delete_org_from_security_list;
--
  --
  --
  -- ----------------------------------------------------------------------------
  -- |---------------------< add_pos_to_security_list >--------------------------|
  -- ----------------------------------------------------------------------------
  PROCEDURE add_pos_to_security_list(p_security_profile_id  in number,
                                     p_position_id          in number)
  IS
  --
      l_proc        varchar2(80) := 'HR_SECURITY_INTERNAL.ADD_POS_TO_SECURITY_LIST';
  --
  begin
  --
    insert into per_position_list
               (security_profile_id, position_id)
        values (p_Security_Profile_Id, p_position_id);
  --
  end add_pos_to_security_list;
  --

  --
  -- ----------------------------------------------------------------------------
  -- |------------------< delete_pos_from_security_list >-----------------------|
  -- ----------------------------------------------------------------------------
  PROCEDURE delete_pos_from_security_list(p_position_Id    in number)
  IS
  --
      l_proc  varchar2(80) := 'HR_SECURITY_INTERNAL.DELETE_POS_FROM_SECURITY_LIST';
  begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      DELETE FROM PER_POSITION_LIST
      WHERE  position_id = p_position_Id;
  exception
      when NO_DATA_FOUND then
        hr_utility.set_location(l_proc, 20);
  end delete_pos_from_security_list;
--
-- ----------------------------------------------------------------------------
-- |----------------- delete_pay_from_security_list >---------------------|
-- ----------------------------------------------------------------------------
  PROCEDURE delete_pay_from_security_list(p_payroll_id     number)
  IS
  --
      l_proc  varchar2(80) := 'HR_SECURITY_INTERNAL.DELETE_PAY_FROM_SECURITY_LIST';
  begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      DELETE FROM PAY_PAYROLL_LIST
      WHERE  payroll_id = p_payroll_id;
  exception
      when NO_DATA_FOUND then
        hr_utility.set_location(l_proc, 20);
  end delete_pay_from_security_list;
--
END hr_security_internal;

/
