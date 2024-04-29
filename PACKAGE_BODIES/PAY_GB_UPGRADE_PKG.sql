--------------------------------------------------------
--  DDL for Package Body PAY_GB_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_UPGRADE_PKG" AS
/* $Header: pygbgupd.pkb 120.2.12000000.2 2007/02/20 09:35:58 npershad noship $ */
-- |-------------------------------------------------------------------|
-- |---------------------< upg_disability_status >---------------------|
-- |-------------------------------------------------------------------|

g_package   CONSTANT VARCHAR2(30) := 'pay_gb_upgrade_pkg.';
l_count number := 1 ;

procedure qualify_disability_status(p_person_id	 in number,
	                            p_qualifier	 out nocopy varchar2)
is
	c_proc		constant varchar2(61) := g_package || 'qualify_disability_status';
	l_exists varchar2(1) := 'N';

	cursor csr_exists
	is
	select	'Y'
	from	dual
	where	exists
	(select	null
	from  per_all_people_f papf
	where papf.person_id = p_person_id
	and   papf.registered_disabled_flag is not null)
	or
	exists (select null
        from per_disabilities_f pdf,
             per_all_people_f papf
        where pdf.person_id =papf.person_id
        and pdf.category not in ('Y','N','ND')
        and papf.person_id = p_person_id);
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	--
	 open csr_exists;
	 fetch csr_exists into l_exists;

	    if l_exists = 'Y' then
		p_qualifier := 'Y';
	    else
		p_qualifier := 'N';
	    end if;

	close csr_exists;
	--
	hr_utility.trace(p_person_id || ' : ' || p_qualifier);
	hr_utility.set_location('Leaving: ' || c_proc, 100);

end qualify_disability_status;

PROCEDURE upg_disability_status(p_person_id in number) is

--Get the person details having Disability recorded on person form.
cursor csr_person_details
is
select nvl(decode(papf.registered_disabled_flag,'Y','Yes','F','Yes - Fully Disabled','P','Yes - Partially Disabled','N','No',null),' ') old_category,
       nvl(decode(papf.registered_disabled_flag, 'Y','Yes','F','Yes','P','Yes','N','No',null),' ') new_category,
       nvl(decode(papf.registered_disabled_flag, 'Y','Y','F','Y','P','Y','N','N',null),' ') category,
       nvl(papf.national_identifier,' ') ni_no,
       papf.effective_start_date effective_start_date,
       papf.effective_end_date effective_end_date,
       papf.object_version_number,
       nvl(papf.employee_number,' ') employee_number ,
       papf.person_id person_id,
       nvl(papf.full_name,' ') full_name
from  per_all_people_f papf
where papf.person_id = p_person_id
and   papf.registered_disabled_flag is not null
order by papf.person_id,effective_start_date;

--Fetches the disability records if any.
cursor csr_disability_details
is
select pdf.disability_id,
       pdf.object_version_number
from   per_disabilities_f pdf
where  pdf.person_id = p_person_id
order by pdf.effective_start_date desc;

cursor csr_disability_det
is
select pdf.disability_id,
       pdf.object_version_number
from   per_disabilities_f pdf
where  pdf.person_id = p_person_id
order by pdf.effective_start_date desc;

--Fetches the disability records recorded with Non-GB specific categories.
cursor csr_get_disability(p_person_id in number)
is
select distinct papf.person_id person_id,
       nvl(papf.full_name,' ') full_name,
       pdf.disability_id disability_id,
       nvl(papf.national_identifier,' ') ni_no,
       nvl(pdf.category,' ') category,
       nvl(pdf.quota_fte,'') quota_fte,
       nvl(pdf.degree,'') degree,
       pdf.effective_start_date effective_start_date,
       pdf.effective_end_date effective_end_date,
       pdf.object_version_number object_version_number
from per_disabilities_f pdf,
per_all_people_f papf
where pdf.person_id =papf.person_id
  and (pdf.category not in ('Y','N','ND'))
  and papf.person_id = p_person_id
order by papf.person_id;

  l_object_version_number     number;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_full_name                 varchar2(240);
  l_comment_id                number;
  l_name_combination_warning  boolean;
  l_assign_payroll_warning    boolean;
  l_orig_hire_warning         boolean;
  l_disability_id             number;
  v_disability_id number;
  v_object_version_number number;
  v_disability_id_new number;
  v_object_version_number_new number;
  l_proc     VARCHAR2(50) := g_package || 'upg_disability_status';
  l_category varchar2(30);

v_dis_det  csr_get_disability%rowtype;
begin

l_category :='X';
hr_utility.set_location('Entering ' || l_proc,10);

open  csr_disability_det;
fetch csr_disability_det into v_disability_id,v_object_version_number;
if csr_disability_det%notfound then

     for v_csr_details in csr_person_details
     loop
            hr_utility.set_location('Entering ' || l_proc,20);
	    if l_count = 1 then
		    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------');
		    fnd_file.put_line(FND_FILE.OUTPUT,'						                 List of employees                                                            ');
		    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------');
		    fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');
		    fnd_file.put_line(FND_FILE.OUTPUT, rpad('Person ID',10)||' '||rpad('Full Name',30)||' '||rpad('NI Number',13)
		    ||' '||rpad('Old Category',25)||' '||rpad('New Category',12)||' '||rpad('Effective Start Date',20)||' '||rpad('Effective End Date',20));
	    end if;

	    fnd_file.put_line(FND_FILE.OUTPUT, rpad(v_csr_details.person_id,10)
	    ||' '||rpad(v_csr_details.full_name,30)
	    ||' '||rpad(v_csr_details.ni_no,13)
	    ||' '||rpad(v_csr_details.old_category,25)
	    ||' '||rpad(v_csr_details.new_category,12)
	    ||' '||rpad(to_char(v_csr_details.effective_start_date,'DD/MM/YYYY'),20)
	    ||' '||rpad(to_char(v_csr_details.effective_end_date,'DD/MM/YYYY'),20));

	    l_count := l_count + 1;


       hr_utility.trace('v_csr_details.person_id='||v_csr_details.person_id);

       if l_category <> v_csr_details.category then

	     open  csr_disability_details;
	     fetch csr_disability_details into v_disability_id_new,v_object_version_number_new;
	     if csr_disability_details%notfound then

		hr_utility.set_location('Entering ' || l_proc,30);
		insert into per_disabilities_f
		      (disability_id
		      ,effective_start_date
		      ,effective_end_date
		      ,person_id
		      ,category
		      ,status
		      ,degree
		      ,quota_fte
		      ,object_version_number
		      ,created_by
		      ,creation_date
		      ,last_update_date
		      ,last_updated_by
		      ,last_update_login
		      )
		  Values
		    (per_disabilities_s.nextval
		    ,v_csr_details.effective_start_date
		    ,v_csr_details.effective_end_date
		    ,p_person_id
		    ,v_csr_details.category
		    ,'A'
		    ,null
		    ,1.0
		    ,1
		    ,-1
		    ,sysdate
		    ,sysdate
		    ,-1
		    ,-1
		    );

		 l_category := v_csr_details.category;

	     else

	         -- Creating date track updates against Disability records
	         hr_utility.set_location('Entering ' || l_proc,40);
	         insert into per_disabilities_f
		      (disability_id
		      ,effective_start_date
		      ,effective_end_date
		      ,person_id
		      ,category
		      ,status
		      ,degree
		      ,quota_fte
		      ,object_version_number
		      ,created_by
		      ,creation_date
		      ,last_update_date
		      ,last_updated_by
		      ,last_update_login
		      )

		    select
		    v_disability_id_new
		    ,v_csr_details.effective_start_date
		    ,v_csr_details.effective_end_date
		    ,p_person_id
		    ,v_csr_details.category
		    ,'A'
		    ,null
		    ,1.0
		    ,v_object_version_number_new
		    ,-1
		    ,sysdate
		    ,sysdate
		    ,-1
		    ,-1
		    from dual
		    where not exists
		    (select null from per_disabilities_f
		     where effective_start_date = v_csr_details.effective_start_date
		     and effective_end_date = v_csr_details.effective_end_date
		     and person_id = p_person_id)
		    ;

		l_category := v_csr_details.category;
	     end if;  -- end of insert

             close csr_disability_details;

       else

             open csr_disability_details;
	     fetch csr_disability_details into v_disability_id_new,v_object_version_number_new;
	     if csr_disability_details%found then

                hr_utility.set_location('Entering ' || l_proc,45);
		update per_disabilities_f
		set    effective_end_date = v_csr_details.effective_end_date
		where  disability_id = v_disability_id_new
		and    category = v_csr_details.category;
	    end if;
	    close csr_disability_details;
       end if; -- end of category

          hr_utility.set_location('Entering ' || l_proc,50);
          --Correcting the person record, setting Disability field to null

	   update per_all_people_f
	   set registered_disabled_flag = null
	   where person_id = p_person_id
	   and   effective_start_date = v_csr_details.effective_start_date;
	   --and   object_version_number= v_csr_details.object_version_number
	   --and   employee_number = v_csr_details.employee_number;


    end loop;

else
     for v_dis_det in csr_get_disability(p_person_id)
     loop

	   hr_utility.set_location('Entering ' || l_proc,60);
	    if l_count = 1 then
		    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------');
		    fnd_file.put_line(FND_FILE.OUTPUT,'						                 List of employees                                                            ');
		    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------');
		    fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');
		    fnd_file.put_line(FND_FILE.OUTPUT, rpad('Person ID',10)||' '||rpad('Full Name',30)||' '||rpad('NI Number',13)
		    ||' '||rpad('Old Category',25)||' '||rpad('New Category',12)||' '||rpad('Effective Start Date',20)||' '||rpad('Effective End Date',20));
	    end if;

	    fnd_file.put_line(FND_FILE.OUTPUT, rpad(v_dis_det.person_id,10)
	    ||' '||rpad(v_dis_det.full_name,30)
	    ||' '||rpad(v_dis_det.ni_no,13)
	    ||' '||rpad(v_dis_det.category,25)
	    ||' '||rpad('Yes',12)
	    ||' '||rpad(to_char(v_dis_det.effective_start_date,'DD/MM/YYYY'),20)
	    ||' '||rpad(to_char(v_dis_det.effective_end_date,'DD/MM/YYYY'),20));


             --Correcting the disability record, updating category field to 'Yes' against non-GB Categories.
	       hr_utility.set_location('Entering ' || l_proc,70);

		update per_disabilities_f
		set category='Y'
		where effective_start_date = v_dis_det.effective_start_date
		and disability_id = v_dis_det.disability_id ;

             hr_utility.set_location('Entering ' || l_proc,80);
     l_count := l_count + 1;
     end loop;
end if; -- end of main
close csr_disability_det;

hr_utility.set_location('Leaving         ' || l_proc,90);
end upg_disability_status;

end pay_gb_upgrade_pkg;

/
