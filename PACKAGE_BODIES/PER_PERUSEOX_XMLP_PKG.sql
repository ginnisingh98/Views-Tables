--------------------------------------------------------
--  DDL for Package Body PER_PERUSEOX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSEOX_XMLP_PKG" AS
/* $Header: PERUSEOXB.pls 120.1 2007/12/31 09:15:06 amakrish noship $ */

function BeforeReport return boolean is

l_dummy		varchar2(1);
l_buffer	varchar2(1000);
g_delimiter 	varchar2(1) := ',';
g_eol		varchar2(1) := fnd_global.local_chr(10);
x boolean;
begin
 P_PAYROLL_PERIOD_DATE_START_1:=TO_DATE(substr(P_PAYROLL_PERIOD_DATE_START,1,10),'YYYY/MM/DD');
  P_PAYROLL_PERIOD_DATE_END_1:=TO_DATE(substr(P_PAYROLL_PERIOD_DATE_END,1,10),'YYYY/MM/DD');

-- hr_standard.event('BEFORE REPORT');
x := P_REPORT_YEARValidTrigger ;
c_business_group_name := hr_reports.get_business_group(p_business_group_id);
c_report_date := trunc(sysdate);
if P_PAYROLL_PERIOD_DATE_START is not null
  then
    c_report_year:= to_char(fnd_date.canonical_to_date(P_PAYROLL_PERIOD_DATE_START),'RRRR');
else
    c_report_year:= to_char(sysdate,'RRRR');
end if;
select
    pgh.name, pgv.version_number, pgn.entity_id, pgn.hierarchy_node_id
into
    c_hierarchy_name, c_hierarchy_version_num, c_parent_org_id, c_parent_node_id
from
    per_gen_hierarchy pgh,
    per_gen_hierarchy_versions pgv,
    per_gen_hierarchy_nodes pgn
where
    pgh.hierarchy_id         = p_hierarchy_id
and pgh.hierarchy_id         = pgv.hierarchy_id
and pgv.hierarchy_version_id = p_hierarchy_version_id
and pgn.hierarchy_version_id = pgv.hierarchy_version_id
and pgn.node_type = 'PAR';
/*srw.message('05','c_parent_node_id   : '||c_parent_node_id);*/null;

/*srw.message('05','c_parent_org_id    : '||c_parent_org_id);*/null;

/*srw.message('05','c_hierarchy_vsn_num: '||c_hierarchy_version_num);*/null;

/*srw.message('05','c_hierarchy_name   : '||c_hierarchy_name);*/null;


begin
  select null
  into   l_dummy
  from   hr_all_organization_units
  where  organization_id = c_parent_org_id
  and    location_id is not null;
exception
  when no_data_found then
    fnd_message.set_name('PER','PER_75228_ORG_LOC_MISSING');
    /*srw.message('999',fnd_message.get);*/null;

    raise;
end;
begin
  select null
  into   l_dummy
  from   hr_organization_information
  where  organization_id = c_parent_org_id
  and    org_information_context = 'EEO_Spec';
exception
  when no_data_found then
    fnd_message.set_name('PER','PER_75229_EEO_CLASS_MISSING');
    /*srw.message('999',fnd_message.get);*/null;

    raise;
end;
begin
  select null
  into   l_dummy
  from   hr_location_extra_info hlei1,
         hr_location_extra_info hlei2,
         per_gen_hierarchy_nodes pgn,
         hr_locations_all eloc
  where  pgn.hierarchy_version_id = p_hierarchy_version_id
  and    pgn.node_type = 'EST'
  and    eloc.location_id = pgn.entity_id
  and    hlei1.location_id = eloc.location_id
  and    hlei1.information_type = 'EEO-1 Specific Information'
  and    hlei1.lei_information_category= 'EEO-1 Specific Information'
  and    hlei2.location_id = eloc.location_id
  and    hlei2.information_type = 'Establishment Information'
  and    hlei2.lei_information_category= 'Establishment Information';
exception
  when no_data_found then
    fnd_message.set_name('PER','PER_75230_EST_CLASS_MISSING');
    /*srw.message('999',fnd_message.get);*/null;

    raise;
  when others then
     null;
end;
if P_AUDIT_REPORT = 'Y' then
  /* file_io.open;
   l_buffer := 'Person Id' || g_delimiter ||
		'Employee Last Name' || g_delimiter ||
		'Employee First Name' || g_delimiter ||
		'Employee Number' || g_delimiter ||
		'Gender' || g_delimiter ||
		'Ethnic Origin' || g_delimiter ||
		'Employee Category' || g_delimiter ||
		'Assignment Type' || g_delimiter ||
		'Location Id' || g_delimiter ||
		'Location' || g_delimiter ||
		'Reason' ||
		g_eol;
   file_io.put(l_buffer); */
null;
end if;
RETURN True;
end;

function P_REPORT_YEARValidTrigger return boolean is
begin
  if P_PAYROLL_PERIOD_DATE_START is not null
  then
    p_report_year:= to_char(fnd_date.canonical_to_date(P_PAYROLL_PERIOD_DATE_START),'RRRR');
  else
    p_report_year:= to_char(sysdate,'RRRR');
  end if;
  return (TRUE);
end;

function AfterReport return boolean is
begin

-- hr_standard.event('AFTER REPORT');
  if P_AUDIT_REPORT = 'Y' then
   null;
   --  file_io.close;
  end if;

  return (TRUE);
end;

function cf_set_detailsformula(person_id1 in number, report_date_end in date, ASS_LOC in number, location_id in number, address1 in varchar2) return number is
l_ex_reason varchar2(500) := null;
l_counted char(1) := 'N';
l_exists char(1) := 'N';
l_name varchar2(150) := null;
l_emp_num varchar2(50) := null;
l_sex varchar2(10) := null;
l_buffer varchar2(2000);
g_delimiter varchar2(1) := ',';
g_eol varchar2(1) := fnd_global.local_chr(10);
cursor c_location is
select 'Y'
from
per_all_assignments_f ass
where
    ass.person_id = person_id1
and report_date_end between ass.effective_start_date
and ass.effective_end_date
and ass.assignment_type = 'E'
and ass.primary_flag = 'Y'
and (ass.location_id is null
    or ass.location_id not in
       (select entity_id
        from   per_gen_hierarchy_nodes
        where  hierarchy_version_id = p_hierarchy_version_id
        and   node_type <> 'PAR'))
;
cursor c_assignment is
 select 'Y'
  from
      per_all_assignments_f ass
  where
      ass.person_id = person_id1
  and ass.business_group_id = P_BUSINESS_GROUP_ID
      and report_date_end between ass.effective_start_date and ass.effective_end_date

  and ass.assignment_type  = 'E'
  and ass.primary_flag     = 'Y'
  and exists (select 'x'
      from hr_organization_information hoi1
     where to_char(ass.assignment_status_type_id) = hoi1.org_information1
       and hoi1.org_information_context = 'Reporting Statuses'
       and hoi1.organization_id         = P_BUSINESS_GROUP_ID);
                            cursor c_ethnic is
  select 'Y'
  from per_all_people_f peo
  where
  (
   (peo.per_information1 is not null
     and exists
     (select null
      from   hr_lookups
      where  peo.per_information1 = lookup_code
      and    lookup_type = 'US_ETHNIC_GROUP'
      )
    )
     )
  and peo.person_id = person_id1
  and peo.per_information_category = 'US'
  and peo.business_group_id = P_BUSINESS_GROUP_ID
  and report_date_end between peo.effective_start_date
  and peo.effective_end_date
  ;
      cursor c_emp_category is
 select 'Y'
  from
    per_all_assignments_f ass
 where
      ass.person_id = person_id1
  and ass.business_group_id = P_BUSINESS_GROUP_ID
  and report_date_end between ass.effective_start_date
  and ass.effective_end_date

  and ass.assignment_type          = 'E'
  and ass.primary_flag             = 'Y'
  and ass.employment_category is not null
  and exists (select 'x'
      from hr_organization_information hoi2
     where ass.employment_category      = hoi2.org_information1
       and hoi2.org_information_context  = 'Reporting Categories'
       and hoi2.organization_id          = P_BUSINESS_GROUP_ID);
  cursor c_job_category is
  select 'Y'
  from
     per_all_assignments_f ass
    ,per_jobs         job
  where
      ass.person_id = person_id1
  and ass.business_group_id = P_BUSINESS_GROUP_ID
  and job.business_group_id = P_BUSINESS_GROUP_ID
  and report_date_end between ass.effective_start_date
  and ass.effective_end_date

  and ass.assignment_type            = 'E'
  and ass.primary_flag               = 'Y'
  and ass.job_id is not null
  and ass.job_id = job.job_id
  and job.job_information_category   = 'US'
  and report_date_end between job.date_from
  and nvl(job.date_to, report_date_end)
      and job.job_information1 in
    (select lookup_code
     from   hr_lookups
     where  lookup_type = 'US_EEO1_JOB_CATEGORIES')
    ;
    cursor c_person_name is
  select substr(peo.full_name,1,150)        emp_name,
         peo.employee_number  emp_num,
         peo.sex              sex
  from per_all_people_f peo
  where peo.person_id = person_id1
    and peo.business_group_id = P_BUSINESS_GROUP_ID
    and report_date_end between peo.effective_start_date
    and peo.effective_end_date

           ;
cursor c_job_cat is
select  nvl(jbt.name, 'Not Specified')||' '||nvl(lup.meaning,'') job_cat
  from  hr_lookups            lup
       ,per_all_assignments_f ass
       ,per_jobs_vl           job
       ,per_jobs_tl           jbt
 where  ass.person_id = person_id1

   and report_date_end between ass.effective_start_date
   and ass.effective_end_date
   and report_date_end between job.date_from
   and nvl(job.date_to, report_date_end)
   and  ass.assignment_type  = 'E'
   and  ass.primary_flag     = 'Y'
   and  ass.business_group_id = P_BUSINESS_GROUP_ID
   and  job.business_group_id = P_BUSINESS_GROUP_ID
      and  ass.job_id = jbt.job_id (+)
   and  jbt.language(+) = userenv('LANG')
   and  ass.job_id = job.job_id (+)
   and  job.job_information1 = lup.lookup_code(+)
   and  lup.lookup_type(+) = 'US_EEO1_JOB_CATEGORIES'
   and  job.job_information_category(+) = 'US' ;
      cursor c_eth_cat is
  select  nvl(lup.meaning, 'Not Specified')   ethnic
    from  hr_lookups            lup
         ,per_all_people_f  peo
   where  peo.person_id = person_id1
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.per_information_category(+) = 'US'
     and  peo.per_information1 = lup.lookup_code(+)
     and  lup.lookup_type(+) = 'US_ETHNIC_GROUP'
     and report_date_end between peo.effective_start_date
     and peo.effective_end_date

           ;
                                 cursor c_emp_cat is
  select nvl(lup.meaning, 'Not Specified')    emp_cat
    from hr_lookups              lup
        ,per_all_assignments_f   ass
   where ass.person_id = person_id1
    and  ass.business_group_id = P_BUSINESS_GROUP_ID
    and  ass.employment_category = lup.lookup_code(+)
    and  lup.lookup_type(+) = 'EMP_CAT'

and report_date_end between ass.effective_start_date
and ass.effective_end_date
and  ass.assignment_type  = 'E'
and  ass.primary_flag    = 'Y';
cursor c_ass_type is
  select past.user_status   ustat
    from per_all_assignments_f  ass
        ,per_assignment_status_types past
   where ass.person_id = person_id1
     and  ass.business_group_id = P_BUSINESS_GROUP_ID

     and report_date_end between ass.effective_start_date
     and ass.effective_end_date
     and ass.assignment_type  = 'E'
     and ass.primary_flag    = 'Y'
     and ass.assignment_status_type_id = past.assignment_status_type_id
     and past.active_flag = 'Y'
     and past.primary_flag = 'P'
     ;
     cursor c_eeo1_extra_info is
    select 'Y'
    from
     per_all_assignments_f ass
    ,hr_location_extra_info          hlei1
    ,hr_location_extra_info          hlei2
    where
         ass.person_id = person_id1
    and report_date_end between ass.effective_start_date
    and ass.effective_end_date
    and ass.assignment_type = 'E'
    and ass.primary_flag = 'Y'
    and to_char(hlei1.location_id) = ass.location_id
    and to_char(hlei2.location_id) = ass.location_id
    and hlei1.location_id = hlei2.location_id
    and hlei1.information_type = 'EEO-1 Specific Information'
    and hlei1.lei_information_category= 'EEO-1 Specific Information'
    and hlei2.information_type = 'Establishment Information'
    and hlei2.lei_information_category= 'Establishment Information';

begin


if ASS_LOC <> c_ass_loc then
  cp_display := 0;
end if;

c_ass_loc := ASS_LOC;
    open c_location;
    fetch c_location into l_exists;
    if c_location%found then
      l_counted := 'Y';
      l_ex_reason := 'Loc not in hierarchy';
    end if;
    close c_location;
   open c_ethnic;
   fetch c_ethnic into l_exists;
    if c_ethnic%notfound then
      l_counted := 'Y';
      if l_ex_reason is not null then
        l_ex_reason := l_ex_reason||', No Ethnic Origin';
      else
        l_ex_reason := 'No Ethnic Origin';
      end if;
    end if;
   close c_ethnic;
   open c_assignment;
   fetch c_assignment into l_exists;
    if c_assignment%notfound then
      l_counted := 'Y';
      if l_ex_reason is not null then
        l_ex_reason := l_ex_reason||', Assignment is not of reporting type';
      else
        l_ex_reason := 'Assignment is not of reporting type';
      end if;
    end if;
   close c_assignment;
   open c_emp_category;
   fetch c_emp_category into l_exists;
    if c_emp_category%notfound then
      l_counted := 'Y';
      if l_ex_reason is not null then
        l_ex_reason := l_ex_reason||', Employment category is not of reporting category';
      else
        l_ex_reason := 'Employment category is not of reporting category';
      end if;
    end if;
   close c_emp_category;
   open c_job_category;
   fetch c_job_category into l_exists;
    if c_job_category%notfound then
      l_counted := 'Y';
      if l_ex_reason is not null then
        l_ex_reason := l_ex_reason||', Job category is not of EEO-1 category';
      else
        l_ex_reason := 'Job category is not of EEO-1 category';
      end if;
    end if;
   close c_job_category;
   open c_eeo1_extra_info;
   fetch c_eeo1_extra_info into l_exists;
   if c_eeo1_extra_info%NOTFOUND then
      l_counted := 'Y';
      if l_ex_reason is not null then
        l_ex_reason := l_ex_reason||', Loc has no EEO-1 Extra Information Type';
      else
        l_ex_reason := 'Loc has no EEO-1 Extra Information Type';
      end if;
   end if;
   close c_eeo1_extra_info;


cp_emp_name := null;
cp_emp_num := null;
cp_gender := null;
cp_job_cat := null;
cp_ethnic := null;
cp_emp_cat := null;
cp_ass_type := null;
cp_reason := null;
if l_ex_reason is not null then
   cp_reason := l_ex_reason;
      open c_person_name;
   fetch c_person_name into cp_emp_name
                           ,cp_emp_num
                           ,cp_gender;
   if c_person_name%notfound or cp_emp_name is null then
      l_ex_reason := 'data not found for name, employee number or gender';
   end if;
   close c_person_name;
      open c_job_cat;
   fetch c_job_cat into cp_job_cat;
   if c_job_cat%notfound then
      l_ex_reason := 'data not found for job or job category';

            cp_job_cat := 'Not Specified';

   end if;
   close c_job_cat;

      open c_eth_cat;
   fetch c_eth_cat into cp_ethnic;
   if c_eth_cat%notfound or cp_ethnic is null then
      l_ex_reason := 'data not found for ethnic category';
   end if;
   close c_eth_cat;
      open c_emp_cat;
   fetch c_emp_cat into cp_emp_cat;
   if c_emp_cat%notfound or cp_emp_cat is null then
      l_ex_reason := 'data not found for emp category';
   end if;
   close c_emp_cat;
      open c_ass_type;
   fetch c_ass_type into cp_ass_type;
   if c_ass_type%notfound or cp_ass_type is null then
      l_ex_reason := 'data not found for assignment type';
   end if;
   close c_ass_type;
   cp_no_rows := cp_no_rows + 1;
   --PER_PERUSEOX_XMLP_PKG.cp_display := PER_PERUSEOX_XMLP_PKG.cp_display + 1;
   cp_display := cp_display + 1;

  --RAISE_APPLICATION_ERROR(-20001,'cp_display'||cp_display) ;

   --auto_trans(cp_display);
  if P_AUDIT_REPORT = 'Y' then
    l_buffer := person_id1 || g_delimiter ||
		cp_emp_name || g_delimiter ||
		cp_emp_num || g_delimiter ||
		cp_gender || g_delimiter ||
		cp_ethnic || g_delimiter ||
		cp_emp_cat || g_delimiter ||
		cp_ass_type || g_delimiter ||
		location_id || g_delimiter ||
		replace(address1,',',' ') || g_delimiter ||
		replace(cp_reason,',',';') ||
		g_eol;
   -- file_io.put(l_buffer);
  end if;
end if;
return(null);
end;

--Functions to refer Oracle report placeholders--

 Function CP_no_rows_p return number is
	Begin
	 return CP_no_rows;
	 END;
 Function CP_Emp_Name_p return varchar2 is
	Begin
	 return CP_Emp_Name;
	 END;
 Function CP_Emp_Num_p return varchar2 is
	Begin
	 return CP_Emp_Num;
	 END;
 Function CP_Gender_p return varchar2 is
	Begin
	 return CP_Gender;
	 END;
 Function CP_Location_p return varchar2 is
	Begin
	 return CP_Location;
	 END;
 Function CP_Job_Cat_p return varchar2 is
	Begin
	 return CP_Job_Cat;
	 END;
 Function CP_Ethnic_p return varchar2 is
	Begin
	 return CP_Ethnic;
	 END;
 Function CP_Emp_Cat_p return varchar2 is
	Begin
	 return CP_Emp_Cat;
	 END;
 Function CP_ass_type_p return varchar2 is
	Begin
	 return CP_ass_type;
	 END;
 Function CP_Reason_p return varchar2 is
	Begin
	 return CP_Reason;
	 END;
 Function CP_display_p return number is
	Begin
	-- return nvl(PER_PERUSEOX_XMLP_PKG.CP_display,0);
	return nvl(CP_display,0);
	 END;
 Function c_business_group_name_p return varchar2 is
	Begin
	 return c_business_group_name;
	 END;
 Function c_hierarchy_name_p return varchar2 is
	Begin
	 return c_hierarchy_name;
	 END;
 Function c_hierarchy_version_num_p return number is
	Begin
	 return c_hierarchy_version_num;
	 END;
 Function c_parent_org_id_p return number is
	Begin
	 return c_parent_org_id;
	 END;
 Function c_parent_node_id_p return number is
	Begin
	 return c_parent_node_id;
	 END;
 Function c_ass_loc_p return number is
	Begin
	 return c_ass_loc;
	 END;
 Function c_report_date_p return date is
	Begin
	 return c_report_date;
	 END;
 Function c_report_year_p return varchar2 is
	Begin
	 return c_report_year;
	 END;
END PER_PERUSEOX_XMLP_PKG ;

/
