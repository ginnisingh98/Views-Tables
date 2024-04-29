--------------------------------------------------------
--  DDL for Package Body PAY_GB_PERSON_TITLE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_PERSON_TITLE_UPDATE" AS
/* $Header: pygbupdt.pkb 120.0.12010000.1 2008/11/07 12:48:05 smeduri noship $ */
 --
 -- Global variables.
 --
  g_package VARCHAR2(31) := 'pay_gb_person_title_update.';
  --
   -- -------------------------------------------------------------------------------------------
  -- The main update.
  -- -------------------------------------------------------------------------------------------
  --
  PROCEDURE run(errbuf			OUT	NOCOPY VARCHAR2
	       ,retcode			OUT	NOCOPY NUMBER
               ,p_bg_id                         IN NUMBER
	       ,p_title  IN VARCHAR2
	       )  IS

-- To get business_group name
  CURSOR csr_business_group is
	SELECT name
	       FROM   per_business_groups
	       WHERE  business_group_id =p_bg_id;

 -- To get person details
    CURSOR csr_person_det is
	SELECT   ppf.person_id person_id,
		 ppf.title title,
	         ppf.national_identifier national_identifier,
	         ppf.employee_number employee_number,
	         ppf.object_version_number object_version_number,
	         ppf.effective_start_date effective_start_date,
	         ppf.effective_end_date effective_end_date,
	         ppf.full_name full_name
	FROM     per_all_people_f   ppf
        WHERE    ppf.business_group_id = p_bg_id
                 and ppf.title='HU_PROF'
	order by ppf.person_id;

  -- Local variables.
    l_new_title           varchar2(15);
    l_business_group_name per_business_groups.name%type;
    l_no_data_found varchar2(1);
    l_full_name varchar2(100);
    l_comment_id number;
    l_person_id  per_people_f.person_id%type;
    l_ovn number;
    l_emp_no      VARCHAR2(20);
    l_eff_sdt      DATE;
    l_eff_edt      DATE;
    l_name_combination_warning BOOLEAN := FALSE;
    l_assign_payroll_warning BOOLEAN := FALSE;
    l_orig_hire_warning BOOLEAN := FALSE;


  BEGIN
    --
     l_no_data_found := 'Y';
    -- hr_utility.trace_on(null,'title');
    hr_utility.set_location('Entering: ' || g_package, 10);
        OPEN  csr_business_group;
        FETCH csr_business_group into l_business_group_name;
        CLOSE csr_business_group;

    hr_utility.set_location('Leaving: ' || g_package, 20);
    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,'                                  Title Changes For Employees in : '||rpad(l_business_group_name,30));
    fnd_file.put_line(FND_FILE.OUTPUT,' ');
    fnd_file.put_line(FND_FILE.OUTPUT,'                                  Title '||rpad(p_title,30)||'updated for the following records');
    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    fnd_file.put_line(FND_FILE.OUTPUT,'                                                                                ');
    fnd_file.put_line(FND_FILE.OUTPUT, rpad('Person ID',20)||'  '||rpad('National Identifier',20)||'  '||rpad('Effective Start Date',20)||'  '||
    rpad('Effective End Date ',20)||'  '||rpad('Initial Employee Name',75)||'  '||rpad('Final Employee name',75));
    fnd_file.put_line(FND_FILE.OUTPUT,'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');


   for v_csr_person in csr_person_det
    loop
        if l_no_data_found = 'Y' then
            l_no_data_found := 'N';
        end if;
        l_person_id :=v_csr_person.person_id;
        l_ovn := v_csr_person.object_version_number;
        l_emp_no :=v_csr_person.employee_number;

 HR_PERSON_API.update_gb_person(
                                p_effective_date => v_csr_person.effective_start_date
                               ,p_datetrack_update_mode => 'CORRECTION'
                               ,p_person_id  => l_person_id
                               ,p_object_version_number => l_ovn
                               ,p_employee_number => l_emp_no
                               ,p_effective_start_date => l_eff_sdt
                               ,p_effective_end_date => l_eff_edt
                               ,p_full_name =>l_full_name
                               ,p_title => p_title
                               ,p_comment_id => l_comment_id
                               ,p_name_combination_warning  =>l_name_combination_warning
                               ,p_assign_payroll_warning => l_assign_payroll_warning
                               ,p_orig_hire_warning => l_orig_hire_warning);


        fnd_file.put_line(FND_FILE.OUTPUT,rpad(v_csr_person.person_id,20)||'  '||rpad(v_csr_person.national_identifier,20)||'  '||rpad(v_csr_person.effective_start_date,20)||'  '||
        rpad(v_csr_person.effective_end_date,20)||'  '||rpad(v_csr_person.full_name,75)||'  '||rpad(l_full_name,75));

    end loop;

if l_no_data_found = 'Y' THEN
    fnd_file.put_line(FND_FILE.OUTPUT,'--------------------------------No Person record with HU_PROF title, So no records updated---------------------------------');
end if;

 --
  EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
        fnd_file.put_line(FND_FILE.OUTPUT,SQLERRM);
	RAISE_APPLICATION_ERROR(-20001, SQLERRM);

  END run;
 --
END pay_gb_person_title_update;

/
