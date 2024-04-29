--------------------------------------------------------
--  DDL for Package Body PAY_IE_MEDICAL_ADJUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_MEDICAL_ADJUST" AS
/* $Header: pyiemadj.pkb 120.2 2008/01/07 07:02:05 rrajaman noship $ */
g_package varchar2(33) := '  pay_ie_medical_adjust.';

/*---------------------------------------------------------------------------*/
/*-------------------------- Medical_Balance_Adjust ---------------------------*/
/*---------------------------------------------------------------------------*/
PROCEDURE Medical_Balance_Adjust(p_bg_id IN NUMBER,
					p_eff_date IN DATE,
					p_asg_id IN VARCHAR2,
					p_benefit_type IN VARCHAR2,
					p_validate_commit IN VARCHAR2,
					p_entry_value1 IN NUMBER)
IS
  l_proc_name Varchar2(100) := 'Medical_Balance_Adjust';

  --
  CURSOR element_csr IS
  SELECT element_type_id
  FROM   pay_element_types_f
  WHERE  element_name = 'Setup BIK Medical Insurance'
--  AND    nvl(business_group_id, p_bg_id) = p_bg_id
  AND    legislation_code = 'IE'
  AND    p_eff_date BETWEEN effective_start_date AND effective_end_date;
  --
  element_rec element_csr%ROWTYPE;
  --
  CURSOR input_val_csr(p_element_type_id IN NUMBER, p_name In VARCHAR2) IS
  SELECT input_value_id
  FROM   pay_input_values_f
  WHERE  element_type_id = p_element_type_id
  AND    name = p_name
  --AND    nvl(business_group_id, p_bg_id) = p_bg_id
  AND    legislation_code = 'IE'
  AND    p_eff_date BETWEEN effective_start_date AND effective_end_date;
  --
  input_val_rec1 input_val_csr%ROWTYPE;
  --
  CURSOR link_csr(p_element_type_id IN NUMBER) IS
   SELECT links.element_link_id
      FROM   pay_element_links_f links, per_all_assignments_f assign
      WHERE  links.element_type_id = p_element_type_id
      AND    links.business_group_id=p_bg_id
      AND    assign.assignment_id=p_asg_id
      AND   ((    links.payroll_id is not null
              and links.payroll_id = assign.payroll_id)
      OR     (    links.link_to_all_payrolls_flag='Y'
              and assign.payroll_id is not null)
      OR     (    links.payroll_id is null
              and links.link_to_all_payrolls_flag='N')
      OR     links.job_id=assign.job_id
      OR     links.position_id=assign.position_id
      OR     links.people_group_id=assign.people_group_id
      OR     links.organization_id=assign.organization_id
      OR     links.grade_id=assign.grade_id
      OR     links.location_id=assign.location_id
      OR     links.pay_basis_id=assign.pay_basis_id
      OR     links.employment_category=assign.employment_category)
      AND    p_eff_date BETWEEN links.effective_start_date
                              AND     links.effective_end_date;
  --
  link_rec link_csr%ROWTYPE;
  --
  l_element_entry_id NUMBER;
  l_effective_start_date DATE;
  l_effective_end_date DATE;
  l_object_version_number NUMBER;
  l_create_warning BOOLEAN := FALSE;
  --

BEGIN

hr_utility.set_location('Entering '||g_package||l_proc_name,2000);
fnd_file.put_line(FND_FILE.LOG,'Value of p_bg_id is '||p_bg_id);
fnd_file.put_line(FND_FILE.LOG,'Value of p_eff_date is '||p_eff_date);
fnd_file.put_line(FND_FILE.LOG,'Value of p_asg_id is '||p_asg_id);
fnd_file.put_line(FND_FILE.LOG,'Value of p_benefit_type is '||p_benefit_type);
fnd_file.put_line(FND_FILE.LOG,'Value of p_validate_commit is '||p_validate_commit);

      --
      -- Get Element information
      --
      OPEN  element_csr;
      FETCH element_csr INTO element_rec;
      CLOSE element_csr;
	hr_utility.set_location('element_rec.element_type_id '||element_rec.element_type_id,2010);
	--
      -- Get Input Values
      --
      OPEN  input_val_csr(element_rec.element_type_id, 'Taxable Value for Run');
      FETCH input_val_csr INTO input_val_rec1;
      CLOSE input_val_csr;
	hr_utility.set_location('input_val_rec1.input_value_id '||input_val_rec1.input_value_id,2020);
      --
      -- Get element link information
      --
      OPEN  link_csr(element_rec.element_type_id);
      FETCH link_csr INTO link_rec;
      CLOSE link_csr;
	hr_utility.set_location('link_rec.element_link_id '||link_rec.element_link_id,2030);
	--
      -- Call API To Create Element Entry
      --
	hr_utility.set_location('Before Calling API py_element_entry_api.create_element_entry ',2040);

	py_element_entry_api.create_element_entry(p_effective_date             => p_eff_date,
				p_business_group_id          => p_bg_id,
				--p_original_entry_id          => p_original_entry_id,          -- default
				p_assignment_id              => p_asg_id,
				p_element_link_id            => link_rec.element_link_id,
				p_entry_type                 => 'B',
				p_creator_type               => 'B',
				p_target_entry_id		     => 999999,
				p_input_value_id1            => input_val_rec1.input_value_id,
				p_entry_value1               =>  nvl(p_entry_value1,0),
				p_effective_start_date       => l_effective_start_date,
				p_effective_end_date         => l_effective_end_date,
				p_element_entry_id           => l_element_entry_id,
				p_object_version_number      => l_object_version_number,
				p_create_warning             => l_create_warning);
	hr_utility.set_location('After Calling API py_element_entry_api.create_element_entry ',2040);

	update pay_element_entries_f pee
	set    pee.creator_type          = 'B',
	       pee.target_entry_id          = NULL
	where  pee.element_entry_id      = l_element_entry_id
	and    p_eff_date between pee.effective_start_date and pee.effective_end_date;

	hr_utility.set_location('After updating pay_element_entries_f ',2050);
	-- Deal with the creation of Payroll and Assignment
	-- Action for the adjustment.  We call the existing
	-- routine to ensure that we get support for altering
	-- latest balances and creation of Action Contexts.
	hr_utility.set_location('Before calling hrassact.bal_adjust ',2060);

	hrassact.bal_adjust (consetid    => NULL,
				eentryid    => l_element_entry_id,
				effdate     => p_eff_date,
				prepay_flag => NULL,
				run_type_id => NULL);

	hr_utility.set_location('After calling hrassact.bal_adjust ',2060);

hr_utility.set_location('Leaving '||g_package||l_proc_name,2000);
END;

/*---------------------------------------------------------------------------*/
/*-------------------------- Medical_Validate_Commit ---------------------------*/
/*---------------------------------------------------------------------------*/
PROCEDURE Medical_Validate_Commit(errbuf OUT NOCOPY VARCHAR2,
					retcode OUT NOCOPY VARCHAR2,
					p_bg_id IN NUMBER,
					p_eff_date IN VARCHAR2,
					p_asg_id IN VARCHAR2,
					p_benefit_type IN VARCHAR2,
					p_validate_commit IN VARCHAR2)
IS
l_proc_name Varchar2(100) := 'Medical_Validate_Commit';
l_effective_date DATE;
l_ele_type_id number;
l_input_val_id_med number;
l_input_val_id_tax number;
l_assignment_id number := NULL;
l_assig_number per_all_assignments_f.assignment_number%TYPE;
l_report_item_type varchar(10) := NULL;
l_result_val varchar2(20);
l_result_val_l varchar2(20);
l_result_val_num number := 0;
l_full_name per_all_people_f.full_name%TYPE;
l_temp_assg_id number;
l_string varchar2(200);
counter number := 0;
l_assign_id varchar2(30);
l_instr_length number := 0;
l_under_line varchar2(130) := '----------------------------------------------------------------------------------------------------------------------------------';
l_asg_counter number :=0;
l_c_already_run number :=0;  -- (0 = NOT RUN  1 = RAN )

TYPE Med_Record is Record(l_m_asg_id per_all_assignments_f.assignment_id%TYPE,
				  l_m_Value  NUMBER);
l_Med_Record Med_Record;

TYPE Med_pl_table is table of Med_Record index by binary_integer;
l_Med_pl_table Med_pl_table;

-- Cursor to get element_type_id
cursor csr_get_ele_id IS
select distinct element_type_id
from pay_element_types_f
where element_name = 'IE BIK Other Reportable Item Details'
and legislation_code = 'IE';

-- Cursor to get input_val_id
cursor csr_get_input_val_id (p_ele_type_id in number,
                             p_input_val_name in varchar2) IS
select distinct input_value_id
from pay_input_values_f
where name = p_input_val_name
and legislation_code = 'IE'
and element_type_id = p_ele_type_id;

-- fetch all assigment_action_ids and corresponding
cursor csr_assig_act (p_assig_id in number,
                      p_input_val_id_med in number,
                      p_ele_type_id in number,
                      p_report_item_type in varchar2,
			    p_input_val_id_tax in number)  IS
select paa.assignment_id, sum(fnd_number.canonical_to_number(prrv1.result_value)) result_value  --paa.assignment_action_id, paa.payroll_action_id
from pay_assignment_actions paa,
     pay_payroll_actions ppa,
     pay_run_results prr,
     pay_run_result_values prrv,
     pay_run_result_values prrv1
where paa.action_status = 'C'
and paa.payroll_action_id = ppa.payroll_action_id
and paa.assignment_id = nvl(p_assig_id, paa.assignment_id)
and paa.assignment_action_id = prr.assignment_action_id
and prr.element_type_id = p_ele_type_id
and prr.run_result_id = prrv.run_result_id
and prrv.input_value_id = p_input_val_id_med
and prrv.result_value = p_report_item_type
and prr.run_result_id = prrv1.run_result_id
and prrv1.input_value_id = p_input_val_id_tax
and ppa.effective_date between  to_date('01/01/2007','DD/MM/RRRR') and l_effective_date
and ppa.action_type in ('R','Q','B','V')
group by paa.assignment_id
having sum(fnd_number.canonical_to_number(prrv1.result_value)) <> 0
order by paa.assignment_id;

-- Cursor to get result values
cursor csr_get_value (p_ele_type_id in number,
                      p_input_val_id in number,
                      p_assg_act_id in number) IS
select result_value from pay_run_result_values where
input_value_id = p_input_val_id
and run_result_id in (select run_result_id from pay_run_results
                        where assignment_action_id = p_assg_act_id
                        and element_type_id = p_ele_type_id) ;

-- Get person details
 Cursor csr_person_details (p_assg_id in number) IS
   select distinct ppf.full_name  ,
          paaf.assignment_number
   from per_all_people_f ppf,
   per_all_assignments_f paaf
   where paaf.assignment_id = p_assg_id
   and paaf.person_id = ppf.person_id
   and l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

-- Cursor to prevent this process running twice.
CURSOR c_already_run IS
SELECT 1
FROM   pay_patch_status
WHERE  patch_number     = 6506755
AND    patch_name       = 'IE_MED_BAL_ADJ'
AND    phase            = 'C'
AND    legislation_code = 'IE';

BEGIN
	hr_utility.set_location('Entering '||g_package||l_proc_name,1000);
	hr_utility.set_location('p_bg_id '||p_bg_id,1005);
	hr_utility.set_location('p_eff_date '||p_eff_date,1005);
	hr_utility.set_location('p_asg_id '||p_asg_id,1005);
	hr_utility.set_location('p_benefit_type '||p_benefit_type,1005);
	hr_utility.set_location('p_validate_commit '||p_validate_commit,1005);

	--fnd_file.put_line(fnd_file.log,'p_bg_id: '||p_bg_id||' p_eff_date: '||p_eff_date||' p_asg_id: '||p_asg_id||' p_benefit_type: '||p_benefit_type||' p_validate_commit: '||p_validate_commit);

	retcode := 0;
	l_effective_date := fnd_date.canonical_to_date(p_eff_date);

	hr_utility.set_location('l_effective_date'||to_char(l_effective_date),1010);
	hr_utility.set_location('Deleting PL table l_Med_pl_table',1010);
	l_Med_pl_table.delete;

	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	fnd_file.put_line(FND_FILE.OUTPUT,'Date:'||to_char(l_effective_date)||'                         IE Medical Insurance Upgrade Process');
	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	fnd_file.put_line(FND_FILE.OUTPUT,' ');

	fnd_file.put_line(FND_FILE.LOG,l_under_line);
	fnd_file.put_line(FND_FILE.LOG,'Date:'||to_char(l_effective_date)||'                         IE Medical Insurance Upgrade Process');
	fnd_file.put_line(FND_FILE.LOG,l_under_line);
	fnd_file.put_line(FND_FILE.LOG,' ');

	l_assignment_id    := p_asg_id;
	l_report_item_type := p_benefit_type;
/*
	IF l_assignment_id = -1 THEN
	   l_assignment_id := NULL;
	END IF;

	IF l_report_item_type = '-1' THEN
	   l_report_item_type := NULL;
	   fnd_file.put_line(FND_FILE.OUTPUT,'Reportable Item Type cannot be null. You must enter valid Reportable Item Type');
	   raise_application_error(-20001,'Reportable Item Type cannot be null. You must enter valid Reportable Item Type');
	END IF;
*/
	-- get element_type_Id;
	open csr_get_ele_id;
	fetch csr_get_ele_id into l_ele_type_id;
	close csr_get_ele_id;
	hr_utility.set_location('l_ele_type_id:'||l_ele_type_id,1020);

	-- get input_val_id of Taxable Value for Run
	open csr_get_input_val_id(l_ele_type_id, 'Taxable Value for Run');
	fetch csr_get_input_val_id into l_input_val_id_tax;
	close csr_get_input_val_id;
	hr_utility.set_location('l_input_val_id_tax:'||l_input_val_id_tax,1030);

	-- get input_val_id of Reportable Item Type
	open csr_get_input_val_id(l_ele_type_id, 'Reportable Item Type');
	fetch csr_get_input_val_id into l_input_val_id_med;
	close csr_get_input_val_id;
	hr_utility.set_location('l_input_val_id_med:'||l_input_val_id_med,1040);

	l_temp_assg_id := NULL;

	l_string := lpad('Person Full Name',35,' ')
	            || lpad('Assignment Number',25,' ')
		    ||lpad('Assignment ID',20,' ')
		    ||lpad('Report Item',20,' ')
		    ||lpad('Taxable Value',30,' ');
	fnd_file.put_line(FND_FILE.OUTPUT,l_string);
	fnd_file.put_line(FND_FILE.LOG,l_string);

	l_string := NULL;
	l_string := lpad('=========================',35,' ')
	            || lpad('=================',25,' ')
		    ||lpad('=============',20,' ')
		    ||lpad('===========',20,' ')
		    ||lpad('=====================',30,' ');
	fnd_file.put_line(FND_FILE.OUTPUT,l_string);
	fnd_file.put_line(FND_FILE.LOG,l_string);

	hr_utility.set_location('l_assignment_id:'||l_assignment_id,1050);
	hr_utility.set_location('l_input_val_id_med:'||l_input_val_id_med,1050);
	hr_utility.set_location('l_ele_type_id:'||l_ele_type_id,1050);
	hr_utility.set_location('l_report_item_type:'||l_report_item_type,1050);
	hr_utility.set_location('l_input_val_id_tax:'||l_input_val_id_tax,1050);
	hr_utility.set_location('l_c_already_run:'||l_c_already_run,1060);


-- Get all assignment_ids
	hr_utility.set_location('Before cursor loop csr_assig_act',1060);
	OPEN c_already_run;
	FETCH c_already_run INTO l_c_already_run;
	CLOSE c_already_run;

	hr_utility.set_location('l_c_already_run:'||l_c_already_run,1065);

    IF l_c_already_run <> 1 THEN
	FOR l_csr_assig_act in csr_assig_act (l_assignment_id,
							  l_input_val_id_med,
							  l_ele_type_id,
							  l_report_item_type,
							  l_input_val_id_tax)
	LOOP
		l_asg_counter := l_asg_counter + 1;
		hr_utility.set_location('Starting Loop counter l_asg_counter:'||l_asg_counter,1070);
		/*
		IF counter <> 0 and l_temp_assg_id <> l_csr_assig_act.assignment_id THEN
		-- Here display Emp Name, assignment number, assignment_id and total result value.
		l_string := null;
		l_string := lpad(nvl(l_full_name,' '),35,' ')|| lpad(nvl(l_assig_number,' '),25,' ')||lpad(nvl(l_assign_id,' '),20,' ')||lpad(nvl(l_report_item_type,' '),20,' ')||lpad(to_char(l_result_val_num),30,' ');
		fnd_file.put_line(FND_FILE.OUTPUT,l_string);
		dbms_output.put_line(l_string);
		  --utl_file.put_line (vOutHandle, l_string);
		END IF;

		counter := counter + 1;
		IF l_temp_assg_id <> l_csr_assig_act.assignment_id THEN
		 l_result_val_num := 0;
		END IF;

		l_temp_assg_id := l_csr_assig_act.assignment_id;

		open csr_get_value (l_ele_type_id,
					  l_input_val_id_tax,
					  l_csr_assig_act.assignment_action_id);
		fetch csr_get_value into l_result_val;
		close csr_get_value;

		l_result_val_num := l_result_val_num + to_number(l_result_val);
		l_result_val_num := l_result_val_num + fnd_number.canonical_to_number(l_result_val);
		*/
		-- get the Person_name, assignment_number
		open csr_person_details (l_csr_assig_act.assignment_id);
		fetch csr_person_details into l_full_name, l_assig_number;
		close csr_person_details;
		l_assign_id := to_char(l_csr_assig_act.assignment_id);

	-- Here display Emp Name, assignment number, assignment_id and total result value.
		l_string := null;
		l_string := lpad(nvl(l_full_name,' '),35,' ')|| lpad(nvl(l_assig_number,' '),25,' ')||lpad(nvl(l_assign_id,' '),20,' ')||lpad(nvl(l_report_item_type,' '),20,' ')||lpad(to_char(l_csr_assig_act.result_value),30,' ');
		fnd_file.put_line(FND_FILE.OUTPUT,l_string);

		fnd_file.put_line(FND_FILE.LOG,l_string);

		-- populate PL table only in Commit mode and
		IF p_validate_commit = 'IE_VALIDATE_COMMIT'
		AND l_c_already_run <> 1
		THEN
			l_Med_pl_table(l_asg_counter).l_m_asg_id	:= l_csr_assig_act.assignment_id;
			l_Med_pl_table(l_asg_counter).l_m_value	:= l_csr_assig_act.result_value;
		END IF;

		hr_utility.set_location('Ending Loop counter l_asg_counter:'||l_asg_counter,1070);
	END LOOP;

	--
	hr_utility.set_location('After cursor loop csr_assig_act',1060);
	--
	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	fnd_file.put_line(FND_FILE.LOG,l_under_line);
	hr_utility.set_location('p_validate_commit:'||p_validate_commit,1080);
	hr_utility.set_location('l_Med_pl_table.COUNT:'||l_Med_pl_table.COUNT,1080);
	--
	IF p_validate_commit = 'IE_VALIDATE_COMMIT' AND l_Med_pl_table.COUNT > 0
	THEN
		FOR l_index IN 1..l_Med_pl_table.COUNT
		LOOP
			BEGIN
			hr_utility.set_location('l_index:'||l_index,1090);
			hr_utility.set_location('l_Med_pl_table(l_index).l_m_asg_id:'||l_Med_pl_table(l_index).l_m_asg_id,1090);
			hr_utility.set_location('l_Med_pl_table(l_index).l_m_value:'||l_Med_pl_table(l_index).l_m_value,1090);
			hr_utility.set_location('Before calling Medical_Balance_Adjust:',1090);

			Medical_Balance_Adjust(p_bg_id,
						l_effective_date,
						l_Med_pl_table(l_index).l_m_asg_id,
						p_benefit_type,
						p_validate_commit,
						l_Med_pl_table(l_index).l_m_value);

			hr_utility.set_location('After calling procedure Medical_Balance_Adjust:',1090);
	/*
			EXCEPTION
			WHEN OTHERS THEN
				fnd_file.put_line(FND_FILE.LOG,' ');
				fnd_file.put_line(FND_FILE.LOG,'Error encountered for assignment ID:'||l_Med_pl_table(l_index).l_m_asg_id);
				fnd_file.put_line(FND_FILE.LOG,sqlerrm);
				Hr_Utility.set_location('Error encountered for assignment ID:'||l_Med_pl_table(l_index).l_m_asg_id,1100);
				Hr_Utility.set_location('SQLERRM :'||sqlerrm,1100);
				ROLLBACK;
	*/
			END;
		END LOOP;
		--
		INSERT INTO pay_patch_status(id
		,patch_number
		,patch_name
		,phase
		,applied_date
		,legislation_code)
		SELECT pay_patch_status_s.nextval
		,6506755
		,'IE_MED_BAL_ADJ'
		,'C'
		,sysdate
		,'IE'
		FROM  dual;
		--
	END IF;
    ELSE
	--
	fnd_file.put_line(FND_FILE.LOG,l_under_line);
	fnd_file.put_line(FND_FILE.log,'This process has already been run.');
	fnd_file.put_line(FND_FILE.LOG,l_under_line);
	--
	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	fnd_file.put_line(FND_FILE.OUTPUT,'This process has already been run.');
	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	--
    END IF;
	--hr_utility.trace_off;
    -- Display the last assignment picked, outside the loop
/*
	l_string  := null;
	l_string := lpad(nvl(l_full_name,' '),35,' ')|| lpad(nvl(l_assig_number,' '),25,' ')||lpad(nvl(l_assign_id,' '),20,' ')||lpad(nvl(l_report_item_type,' '),20,' ')||lpad(to_char(l_result_val_num),30,' ');
	fnd_file.put_line(FND_FILE.OUTPUT,l_string);
	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	dbms_output.put_line(l_string);
*/

	hr_utility.set_location('Leaving '||g_package||l_proc_name,1000);

EXCEPTION
  WHEN Others THEN
	fnd_file.put_line(FND_FILE.LOG,'..'||'SQL-ERRM :'||SQLERRM);
	fnd_file.put_line(FND_FILE.OUTPUT,l_under_line);
	Hr_Utility.set_location('..'||'SQL-ERRM :'||SQLERRM,1000);
	hr_utility.set_location('Leaving '||g_package||l_proc_name,1000);
	raise;
END;

END pay_ie_medical_adjust;

/
