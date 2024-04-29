--------------------------------------------------------
--  DDL for Package Body PER_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOBS_PKG" as
/* $Header: pejbd01t.pkb 120.0 2005/05/31 10:32:42 appldev noship $ */
--
procedure get_next_sequence(p_job_id in out nocopy number) is
--
cursor c1 is select per_jobs_s.nextval
	     from sys.dual;
--
begin
  --
  -- Retrieve the next sequence number for job_id
  --
  if (p_job_id is null) then
    open c1;
    fetch c1 into p_job_id;
    if (C1%NOTFOUND) then
       CLOSE C1;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','get_next_sequence');
       hr_utility.set_message_token('STEP','1');
    end if;
      close c1;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.get_next_sequence', 1);
  --
end get_next_sequence;
--
procedure check_unique_name(p_job_id               in number,
			    p_business_group_id    in number,
			    p_name                 in varchar2) is
--
cursor csr_name is select null
		   from per_jobs j
		   where ((p_job_id is not null
			 and j.job_id <> p_job_id)
                   or    p_job_id is null)
		   and   j.business_group_id + 0 = p_business_group_id
		   and   j.name = p_name;
--
g_dummy_number number;
v_not_unique boolean := FALSE;
--
-- Check the job name is unique
--
begin
  --
  open csr_name;
  fetch csr_name into g_dummy_number;
  v_not_unique := csr_name%FOUND;
  close csr_name;
  --
  if v_not_unique then
     hr_utility.set_message(801,'PER_7810_DEF_JOB_EXISTS');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_unique_name', 1);
  --
end check_unique_name;
--
procedure check_date_from(p_job_id       in number,
			  p_date_from    in date) is
--
cursor csr_date_from is select null
			from per_valid_grades vg
			where vg.job_id    = p_job_id
			and   p_date_from  > vg.date_from;
--
g_dummy_number number;
v_job_date_greater boolean := FALSE;
--
begin
hr_utility.set_location('check date',99);
  --
  -- If the date from item in the jobs block is greater than
  -- the date from item in the grades block then raise an error
  --
  open csr_date_from;
  fetch csr_date_from into g_dummy_number;
  v_job_date_greater := csr_date_from%FOUND;
  close csr_date_from;
  --
  if v_job_date_greater then
    hr_utility.set_message(801,'PER_7825_DEF_GRD_JOB_START_JOB');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_date_from', 1);
  --
end check_date_from;
--
procedure get_job_flex_structure(p_structure_defining_column in out nocopy varchar2,
				 p_job_group_id in number) is
--
-- Get the job_flex_structure_id
--
l_struct varchar2(30);
--
cursor csr_job is select to_char(id_flex_num)
		  from per_job_groups_v
		  where p_job_group_id = job_group_id;
--
v_not_found boolean := FALSE;
--
-- Get job flex structure id
--
begin
  --
  open csr_job;
  fetch csr_job into p_structure_defining_column;
  v_not_found := csr_job%NOTFOUND;
  close csr_job;
  --
 l_struct := p_structure_defining_column;
 hr_utility.set_location('p_struct '||l_struct,99);
 --
  if v_not_found then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','get_job_flex_structure');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.get_job_flex_structure', 1);
  --
end get_job_flex_structure;
--
PROCEDURE check_altered_end_date(p_business_group_id      number,
				 p_job_id                 number,
				 p_end_of_time            date,
				 p_date_to                date,
				 p_early_date_to   in out nocopy boolean,
				 p_early_date_from in out nocopy boolean) is
--
cursor csr_date_to is select null
		    from   per_valid_grades vg
		    where  vg.business_group_id + 0 = p_business_group_id
		    and    vg.job_id            = p_job_id
		    and    nvl(vg.date_to, p_end_of_time) > p_date_to;
--
cursor csr_date_from is select null
		     from per_valid_grades vg
		     where  vg.business_group_id + 0 = p_business_group_id
		     and     vg.job_id            = p_job_id
		     and    vg.date_from > p_date_to;
--
g_dummy_number number;
--
begin
   --
   open csr_date_to;
   fetch csr_date_to into g_dummy_number;
   p_early_date_to := csr_date_to%FOUND;
   close csr_date_to;
   --
   hr_utility.set_location('PER_JOBS_PKG.check_altered_end_date', 1);
   --
   open csr_date_from;
   fetch csr_date_from into g_dummy_number;
   p_early_date_from := csr_date_from%FOUND;
   close csr_date_from;
   --
   hr_utility.set_location('PER_JOBS_PKG.check_altered_end_date', 2);
   --
end check_altered_end_date;
--
PROCEDURE update_valid_grades(p_business_group_id    number,
	                      p_job_id               number,
			      p_date_to              date,
			      p_end_of_time          date) is
--
begin
   --
   -- Update valid grade end dates to match the end date of the
   -- job where the end date of the job is earlier than the end
   -- date of the valid grade.or the previous end dates matched.
   --
   --
   update per_valid_grades vg
   set vg.date_to =
	(select least(nvl(p_date_to, p_end_of_time),
		      nvl(g.date_to, p_end_of_time))
         from   per_grades g
	 where  g.grade_id          = vg.grade_id
	 and    g.business_group_id + 0 = p_business_group_id)
   where vg.business_group_id + 0 = p_business_group_id
   and   vg.job_id            = p_job_id
   and   nvl(vg.date_to, p_end_of_time) > p_date_to;
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','update_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
   --
end update_valid_grades;
--
PROCEDURE delete_valid_grades(p_business_group_id    number,
				     p_job_id               number,
				     p_date_to              date) is
--
begin
   --
   -- Valid grades are deleted if the end date of the job
   -- has been made earlier than the start date of the
   -- valid grade.
   --
   --
   delete from per_valid_grades vg
   where  vg.business_group_id + 0 = p_business_group_id
   and    vg.job_id            = p_job_id
   and    vg.date_from         > p_date_to;
   --
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','delete_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
end delete_valid_grades;
--
PROCEDURE check_delete_record(p_job_id            number,
			      p_business_group_id number) is
--
-- Changed 01-Oct-99 SCNair (per_all_positions to hr_all_positions_f) date track requirement
--
cursor csr_position    is select null
		          from   hr_all_positions_f pst1
		          where  pst1.job_id = p_job_id;
--
cursor csr_assignment  is select null
		 	  from   per_all_assignments_f a
			  where  a.job_id = p_job_id
			  and    a.job_id is not null;
--
cursor csr_grade       is select null
		 	  from   per_valid_grades vg1
			  where  vg1.business_group_id + 0 = p_business_group_id
			  and    vg1.job_id            = p_job_id;
--
cursor csr_requirement is select null
			  from   per_job_requirements jre1
			  where  jre1.job_id = p_job_id;
--
cursor csr_evaluation  is select null
			  from   per_job_evaluations jev1
			  where  jev1.job_id = p_job_id;
--
cursor csr_elementp    is select null
			  from   per_career_path_elements cpe1
			  where  cpe1.parent_job_id = p_job_id;
--
cursor csr_elements    is select null
			  from per_career_path_elements cpe1
			  where cpe1.subordinate_job_id = p_job_id;
--
cursor csr_budget     is select null
			  from   per_budget_elements bde1
			  where  bde1.job_id = p_job_id
			  and    bde1.job_id is not null;
--
cursor csr_vacancy     is select null
			  from per_vacancies vac
			  where vac.job_id = p_job_id
			  and   vac.job_id is not null;
--
cursor csr_link        is select null
			  from pay_element_links_f eln
			  where eln.job_id = p_job_id
			  and   eln.job_id is not null;
--
cursor csr_role        is select null
			  from per_roles rol
			  where rol.job_id = p_job_id
			  and   rol.job_id is not null;
--
g_dummy_number  number;
v_record_exists boolean := FALSE;
v_dummy boolean := FALSE;
l_sql_text VARCHAR2(2000);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_oci_out VARCHAR2(1);
l_sql_cursor NUMBER;
l_rows_fetched NUMBER;
--
begin
  --
  --  Check there are no values in per_valid_grades, per_job_requirements,
  --  per_job_evaluations, per_career_path_elements (check on parent and
  --  subordinate id), hr_all_positions_f, per_budget_elements,
  --  PER_all_assignments, per_vacancies_f, per_element_links_f
  --
  --
  --
  open csr_position;
  fetch csr_position into g_dummy_number;
  v_record_exists := csr_position%FOUND;
  close csr_position;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7813_DEF_JOB_DEL_POS');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 1);
  --
  --
  --
  open csr_assignment;
  fetch csr_assignment into g_dummy_number;
  v_record_exists := csr_assignment%FOUND;
  close csr_assignment;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7817_DEF_JOB_DEL_EMP');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 2);
  --
  --
  --
  open csr_grade;
  fetch csr_grade into g_dummy_number;
  v_record_exists := csr_grade%FOUND;
  close csr_grade;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7812_DEF_JOB_DEL_GRADE');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 3);
  --
  --
  --
  open csr_requirement;
  fetch csr_requirement into g_dummy_number;
  v_record_exists := csr_requirement%FOUND;
  close csr_requirement;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7814_DEF_JOB_DEL_REQ');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 4);
  --
  --
  --
  open csr_evaluation;
  fetch csr_evaluation into g_dummy_number;
  v_record_exists := csr_evaluation%FOUND;
  close csr_evaluation;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7815_DEF_JOB_DEL_EVAL');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 5);
  --
  --
  --
  open csr_elementp;
  fetch csr_elementp into g_dummy_number;
  v_record_exists := csr_elementp%FOUND;
  close csr_elementp;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7811_DEF_JOB_DEL_PATH');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 6);
  --
  --
  --
  open csr_elements;
  fetch csr_elements into g_dummy_number;
  v_record_exists := csr_elements%FOUND;
  close csr_elements;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7811_DEF_JOB_DEL_PATH');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 7);
  --
  --
  --
  open csr_budget;
  fetch csr_budget into g_dummy_number;
  v_record_exists := csr_budget%FOUND;
  close csr_budget;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7816_DEF_JOB_DEL_BUD');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 8);
  --
  --
  --
  open csr_vacancy;
  fetch csr_vacancy into g_dummy_number;
  v_record_exists := csr_vacancy%FOUND;
  close csr_vacancy;
  --
  if v_record_exists then
      hr_utility.set_message(801,'HR_6945_JOB_DEL_RAC');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 9);
  --
  --
  --
  open csr_link;
  fetch csr_link into g_dummy_number;
  v_record_exists := csr_link%FOUND;
  close csr_link;
  --
  if v_record_exists then
      hr_utility.set_message(801,'HR_6946_JOB_DEL_LINK');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 10);
  --
  --
  open csr_role;
  fetch csr_role into g_dummy_number;
  v_record_exists := csr_role%FOUND;
  close csr_role;
  --
  if v_record_exists then
	hr_utility.set_message(800,'PER_52684_JOB_DEL_ROLE');
	hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 11);
  --
  -- is po installed?
  --
  if (fnd_installation.get(appl_id => 201
                          ,dep_appl_id => 201
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
  -- Dynamic SQL cursor to get round the problem of Table not existing.
  -- Shouldn't be a problem after 10.6, but better safe than sorry.
  -- This uses a similar method to OCI but Via PL/SQL instead.
  --
  -- #358988 removed the table alias 'pcc' which didn't match the column
  -- alias ppc. RMF 17-Apr-96.
  --
    begin
     l_sql_text := 'select null '
     ||'from sys.dual '
     ||'where exists( select null '
     ||'    from   po_position_controls '
     ||'    where  job_id = '
     ||to_char(p_job_id)
     ||' ) ';
      --
      -- Open Cursor for Processing Sql statment.
      --
      l_sql_cursor := dbms_sql.open_cursor;
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
      --
      -- Map the local variables to each returned Column
      --
      dbms_sql.define_column(l_sql_cursor, 1,l_oci_out,1);
      --
      -- Execute the SQL statement.
      --
      l_rows_fetched := dbms_sql.execute(l_sql_cursor);
      --
      if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
      then
         fnd_message.set_name('PAY','HR_6048_PO_POS_DEL_POS_CONT');
         fnd_message.raise_error;
      end if;
      --
      -- Close cursor used for processing SQL statement.
      --
      dbms_sql.close_cursor(l_sql_cursor);
     end;
   end if;
  end if;
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 11);
  --
  per_ota_predel_validation.ota_predel_job_validation(p_job_id);
  --
  hr_utility.set_location('PER_JOBS_PKG.check_delete_record', 12);
  --
  pa_job.pa_predel_validation(p_job_id);
  --
end check_delete_record;
--

procedure check_evaluation_dates(p_jobid in number,
                                 p_job_date_from in date,
                                 p_job_date_to in date) is


cursor csr_job_evaluations(p_job_id in number) is
       select jbe.job_evaluation_id,
              jbe.date_evaluated
       from per_job_evaluations jbe
       where jbe.job_id = csr_job_evaluations.p_job_id;

--
begin
--

   if p_jobid is not null then
     for l_job_evaluation in csr_job_evaluations(
        p_job_id => p_jobid) loop
        if l_job_evaluation.date_evaluated not between
          nvl(p_job_date_from, hr_api.g_sot) and
          nvl(p_job_date_to, hr_api.g_eot) then
          fnd_message.set_name('PER', 'HR_52603_JOB_JBE_OUT_PERIOD');
          hr_utility.raise_error;
        end if;
     end loop;
   end if;

--
exception
--

when others then
  if csr_job_evaluations%isopen then
    close csr_job_evaluations;
  end if;
  raise;

--
end check_evaluation_dates;
--

END PER_JOBS_PKG;

/
