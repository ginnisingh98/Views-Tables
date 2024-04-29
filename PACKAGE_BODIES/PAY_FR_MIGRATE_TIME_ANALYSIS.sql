--------------------------------------------------------
--  DDL for Package Body PAY_FR_MIGRATE_TIME_ANALYSIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_MIGRATE_TIME_ANALYSIS" as
/* $Header: pyfrmgta.pkb 120.0 2005/05/29 05:04:11 appldev noship $ */
Procedure Migrate(errbuf              OUT NOCOPY VARCHAR2,
                  retcode             OUT NOCOPY NUMBER,
                  p_business_group_id IN NUMBER) Is

Cursor csr_get_all_asg IS
 Select  distinct asg.assignment_id
   From per_all_assignments_f asg
  Where asg.business_group_id = p_business_group_id
 order by asg.assignment_id;

Cursor csr_get_asg_datetrk(c_assignment_id number)IS
 Select  asg.effective_start_date
        ,asg.effective_end_date
        ,asg.normal_hours
        ,asg.frequency
        ,scl.segment15 work_days
        ,asg.person_id
        ,full_name
   From per_all_assignments_f asg
       ,hr_soft_coding_keyflex scl
       ,per_all_people_f per
  Where asg.business_group_id = p_business_group_id
    and asg.assignment_id = c_assignment_id
    and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    and asg.person_id = per.person_id
 Order by asg.effective_start_date;

 Cursor csr_get_all_contr(c_person_id number) is
  Select distinct contract_id
   from per_contracts_f
  where business_group_id = p_business_group_id
    and person_id = c_person_id ;

Cursor csr_all_contr_date(c_contract_id number,
                            c_previous_start_date date,
                            c_asg_start_date date) is
  Select contract_id,
         reference,
         type,
         status,
         effective_start_date,
         effective_end_date,
         person_id,
         object_version_number
   from per_contracts_f
  where business_group_id = p_business_group_id
    and contract_id = c_contract_id
    and effective_start_date
        between c_previous_start_date and c_asg_start_date
  order by  effective_start_date desc;

-- Cursor for checking if rows exist in pay_patch_status
Cursor csr_migr_script_run is
  Select count(*)
    from pay_patch_status
   where patch_number = p_business_group_id
     and patch_name = 'WORKING TIME'
     and legislation_code = 'FR';

 l_count_asg Number;
 l_count_contr_date Number;
 l_flg_same_date VARCHAR2(3);
 l_prev_frequency VARCHAR2(15);
 l_prev_work_days NUMBER;
 l_prev_num_hours NUMBER;
 l_prev_end_date DATE;
 l_prev_start_date DATE;
 l_effective_start_date DATE;
 l_effective_end_date   DATE;
 l_fixed_time VARCHAR2(3);
 l_frequency  VARCHAR2(10);
 l_units      VARCHAR2(10);
 l_amount_time NUMBER;
 l_ctr_ref     VARCHAR2(80);
 l_obj_version_number number;
 l_script_run  NUMBER;
 l_disp_start_date VARCHAR2(30);
 l_disp_end_date   VARCHAR2(30);
 l_disp_fixed_time VARCHAR2(10);
 l_disp_units      VARCHAR2(20);
 l_disp_frequency  VARCHAR2(30);
 l_disp_canon_amt  VARCHAR2(15);
 l_head_full_name  VARCHAR2(30);
 l_head_ctr_ref    VARCHAR2(30);
 l_head_start_date VARCHAR2(30);
 l_head_end_date   VARCHAR2(30);
 l_head_fixed_time VARCHAR2(30);
 l_head_amount     VARCHAR2(30);
 l_head_units      VARCHAR2(30);
 l_head_frequency  VARCHAR2(30);
 l_head_wrk_days   VARCHAR2(50);
 l_head_asg_hrs    VARCHAR2(50);
 l_head_asg_freq   VARCHAR2(50);
 --
Begin
-- Initializing variables
l_fixed_time := 'N';
l_frequency := 'NA';
l_units := 'NA';
/*
Identify employees with no data entered in the Working Hours and Frequency fields on the Standard Conditions Tab.
Set the new Fixed Working Time field to "No" for these employees and produce a listing of the employees that this has been done to.
*/
-- Check to see if the program has already been run for this business group
OPEN csr_migr_script_run;
FETCH csr_migr_script_run INTO l_script_run;
IF l_script_run = 0 THEN
  -- Update the required values
  -- Assign values to teh heading variables
  l_head_full_name   := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'FULL_NAME');
  l_head_ctr_ref     := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'CTR_REFERENCE');
  l_head_start_date  := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'CTR_START_DATE');
  l_head_end_date    := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'CTR_END_DATE');
  l_head_fixed_time  := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'FIXED_WORKING_TIME');
  l_head_amount      := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'FIXED_TIME_AMT');
  l_head_units       := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'FIXED_TIME_UNIT');
  l_head_frequency   := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'FIXED_TIME_FREQUENCY');
  l_head_wrk_days    := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'WORKING_TIME_YEAR');
  l_head_asg_hrs     := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'ASG_NORMAL_HR');
  l_head_asg_freq    := hr_general.decode_lookup('FR_TIME_MIGR_HEADINGS', 'ASG_FREQUENCY');
  --
  -- Print the heading for the columns
  -- Presently using the following format to display data in the log file
  -- Full Name Ctr reference Ctr_start_date Ctr_end_date Fixed_working_Time Amount Units Frequency Asg work days/yr   Asg hours  Asg freq
  FND_FILE.PUT(FND_FILE.LOG, l_head_full_name||' '||l_head_ctr_ref||' '||l_head_start_date||' '||l_head_end_date||' '||l_head_fixed_time);
  FND_FILE.PUT(FND_FILE.LOG,' '||l_head_amount||' '||l_head_units||' '||l_head_frequency||' '||l_head_wrk_days||' '||l_head_asg_hrs);
  FND_FILE.PUT(FND_FILE.LOG,' '||l_head_asg_freq);
  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '=====================================================================================================');
  --
  -- Get all assignments and persons for the business group
  -- and loop through them
  hr_utility.set_location('Getting all assignments',22);
  FOR asg_person_rec IN csr_get_all_asg LOOP
    --
    l_count_asg :=0;
    -- get the date track changes for each assignment
    hr_utility.set_location('getting date track data for assignments', 22);
    FOR asg_mod_rec IN csr_get_asg_datetrk(asg_person_rec.assignment_id) LOOP
      --
      hr_utility.set_location('Name is :'||asg_mod_rec.full_name, 22);
      --
      l_count_asg := l_count_asg +1;
      -- if it is the first row for the assignment
      hr_utility.set_location('l_count_asg is'||l_count_asg, 22);
      IF l_count_asg =1
      -- or the changes are for time
      OR (l_prev_work_days <> to_number(asg_mod_rec.work_days) OR
          l_prev_frequency <> asg_mod_rec.frequency OR
          l_prev_num_hours <> asg_mod_rec.normal_hours)THEN
          -- Assign values to variables according to data
          hr_utility.set_location('Assigning values to variables from asg data',22);
          If asg_mod_rec.Work_days Is Null Then
      	     If asg_mod_rec.Normal_hours Is Null then
      	        l_fixed_time := 'N';
      	        l_frequency := 'NA';
      	        l_amount_time := null;
      	        l_units := 'NA';
      	     Elsif asg_mod_rec.Normal_hours Is not Null then
      	        l_fixed_time := 'Y';
      	        l_frequency := asg_mod_rec.frequency;
      	        l_amount_time := asg_mod_rec.normal_hours;
      	        l_units := 'HOUR';
      	        If l_frequency not in('M', 'W') Then
		   l_amount_time := pay_fr_general.convert_hours
		                    (p_effective_date    => last_day(sysdate)
			            ,p_business_group_id => p_business_group_id
			            ,p_assignment_id     => asg_person_rec.assignment_id
			            ,p_hours             => asg_mod_rec.normal_hours
			            ,p_from_freq_code    => l_frequency
			            ,p_to_freq_code      => 'M');

	           l_frequency := 'M';
      	        End If;
      	     End If;
      	  Else
      	     l_fixed_time := 'Y';
      	     l_frequency  := 'Y';
      	     l_units      := 'DAY';
      	     l_amount_time := to_number(asg_mod_rec.work_days);
          End if;
          -- For all the contracts of this person
          hr_utility.set_location('getting all contracts for the person', 22);
          -- convert the value to canonical format(NLS issue)
          l_disp_canon_amt := fnd_number.number_to_canonical(l_amount_time);
          FOR person_contr_rec IN csr_get_all_contr(asg_mod_rec.person_id) LOOP
             l_count_contr_date :=0;
             -- IF rows are present
             -- Initialize the previous end date as start of time
             l_prev_end_date := hr_general.start_of_time;
             --
             -- Loop thru' all rows
             hr_utility.set_location('asg_mod_rec.effective_start_date is: '||asg_mod_rec.effective_start_date,22);
             hr_utility.set_location('getting date tracked data for contracts', 22);
             hr_utility.set_location('person_contr_rec.contract_id is: '||person_contr_rec.contract_id,22);
             hr_utility.set_location('l_prev_end_date is: '||l_prev_end_date, 22);
             --
             FOR contr_date_rec IN csr_all_contr_date(person_contr_rec.contract_id,
                                                      l_prev_end_date,
                                                      asg_mod_rec.effective_start_date) LOOP
                 --
                 l_count_contr_date := l_count_contr_date +1;
                 l_obj_version_number := contr_date_rec.object_version_number;
                 --
                 hr_utility.set_location('l_count_contr_date is :'||l_count_contr_date,22);
                 hr_utility.set_location('contr_date_rec.effective_start_date is: '||contr_date_rec.effective_start_date,22);
                 --
                 -- Check for matching effective dates for the first contract row
                 IF l_count_contr_date = 1
                   OR asg_mod_rec.effective_start_date = contr_date_rec.effective_start_date
                 THEN
                    hr_utility.set_location('Updating in correction mode',22);
                    -- update in 'CORRECTION' mode
                    hr_contract_api.update_contract
		    (P_VALIDATE               => false,
		     P_CONTRACT_ID            => contr_date_rec.contract_id,
		     P_EFFECTIVE_START_DATE   => l_effective_start_date,
		     P_EFFECTIVE_END_DATE     => l_effective_end_date,
		     P_OBJECT_VERSION_NUMBER  => l_obj_version_number,
		     P_PERSON_ID              => contr_date_rec.person_id,
		     P_REFERENCE              => contr_date_rec.reference,
		     P_TYPE                   => contr_date_rec.type,
		     P_STATUS                 => contr_date_rec.status,
		     P_CTR_INFORMATION10      => l_fixed_time,
		     P_CTR_INFORMATION11      => l_disp_canon_amt,
		     P_CTR_INFORMATION12      => l_units,
		     P_CTR_INFORMATION13      => l_frequency,
		     P_EFFECTIVE_DATE         => contr_date_rec.effective_start_date,
                     P_DATETRACK_MODE         => 'CORRECTION');
                    --
                    l_prev_end_date := l_effective_end_date;
                    l_ctr_ref := contr_date_rec.reference;
                    --
                 ELSE
                    -- insert a row in 'UPDATE' mode
                    hr_utility.set_location('Inserting a row in correction mode',22);
		    hr_contract_api.update_contract
		    (P_VALIDATE               => false,
		     P_CONTRACT_ID            => contr_date_rec.contract_id,
		     P_EFFECTIVE_START_DATE   => l_effective_start_date,
		     P_EFFECTIVE_END_DATE     => l_effective_end_date,
		     P_OBJECT_VERSION_NUMBER  => l_obj_version_number,
		     P_PERSON_ID              => contr_date_rec.person_id,
		     P_REFERENCE              => contr_date_rec.reference,
		     P_TYPE                   => contr_date_rec.type,
		     P_STATUS                 => contr_date_rec.status,
		     P_CTR_INFORMATION10      => l_fixed_time,
		     P_CTR_INFORMATION11      => l_disp_canon_amt,
		     P_CTR_INFORMATION12      => l_units,
		     P_CTR_INFORMATION13      => l_frequency,
		     P_EFFECTIVE_DATE         => asg_mod_rec.effective_start_date,
		     P_DATETRACK_MODE         => 'UPDATE');
		    --
		    l_prev_end_date := l_effective_end_date;
		    l_ctr_ref := contr_date_rec.reference;
                    --
                 END IF;
                 hr_utility.set_location('End of if for contr-asg date match',22);
             END LOOP;-- end loop for within date contracts
             --
             hr_utility.set_location('l_count_contr_date before the row check'||l_count_contr_date,22);
             -- If rows are not present
             IF l_count_contr_date =0  THEN
                -- insert a row in 'UPDATE' mode
                hr_utility.set_location('Before the before date loop start', 22);
                -- With some values the same as the previous datetracked row
                FOR contr_befdate_rec IN csr_all_contr_date(person_contr_rec.contract_id,
		                                            l_prev_start_date,
                                                            l_prev_end_date) LOOP
                   --
                   l_count_contr_date := l_count_contr_date +1;
                   l_obj_version_number := contr_befdate_rec.object_version_number;
                   hr_utility.set_location('Inserting a row where none exist', 22);
                   --
                   hr_contract_api.update_contract
	           (P_VALIDATE               => false,
	            P_CONTRACT_ID            => contr_befdate_rec.contract_id,
	            P_EFFECTIVE_START_DATE   => l_effective_start_date,
	            P_EFFECTIVE_END_DATE     => l_effective_end_date,
	            P_OBJECT_VERSION_NUMBER  => l_obj_version_number,
	            P_PERSON_ID              => contr_befdate_rec.person_id,
	            P_REFERENCE              => contr_befdate_rec.reference,
	            P_TYPE                   => contr_befdate_rec.type,
	            P_STATUS                 => contr_befdate_rec.status,
	            P_CTR_INFORMATION10      => l_fixed_time,
	            P_CTR_INFORMATION11      => l_disp_canon_amt,
	            P_CTR_INFORMATION12      => l_units,
	            P_CTR_INFORMATION13      => l_frequency,
	            P_EFFECTIVE_DATE         => asg_mod_rec.effective_start_date,
                    P_DATETRACK_MODE         => 'UPDATE');
                    --
                    l_prev_end_date:= l_effective_end_date;
                    l_ctr_ref := contr_befdate_rec.reference;
                    --
                    IF l_count_contr_date =1 THEN
                       EXIT;
                    END IF;
                --
                END LOOP;
                -- end loop for before date contracts
                hr_utility.set_location('Exiting loop for before date contracts',22);
             END IF;
             -- End if for count rows
             -- Assigning values for writing into log files
             l_disp_start_date := fnd_date.date_to_displaydt(DATEVAL=> l_effective_start_date);
             l_disp_end_date := fnd_date.date_to_displaydt(DATEVAL=> l_effective_end_date);
             l_disp_fixed_time:= hr_general.decode_lookup('YES_NO',l_fixed_time);
             l_disp_units:= hr_general.decode_lookup('FR_FIXED_TIME_UNITS',l_units);
             l_disp_frequency:= hr_general.decode_lookup('FR_FIXED_TIME_FREQUENCY',l_frequency);

             -- log the modified data
             FND_FILE.PUT(FND_FILE.LOG, asg_mod_rec.full_name||' '||l_ctr_ref||' '||l_disp_start_date||' '||l_disp_end_date);
             FND_FILE.PUT(FND_FILE.LOG, ' '||l_disp_fixed_time||' '||l_disp_canon_amt||' '||l_disp_units||' '||l_disp_frequency);
             FND_FILE.PUT(FND_FILE.LOG, ' '||asg_mod_rec.work_days||' '||to_char(asg_mod_rec.normal_hours)||' '||asg_mod_rec.frequency);
             FND_FILE.NEW_LINE(FND_FILE.LOG,2);
             --
             hr_utility.set_location('Written into log file, exiting loop for contracts',22);
          END LOOP; --end of loop for contracts
      END IF;-- end of if for asg changes
      -- Assign values to variables
      l_prev_frequency  := asg_mod_rec.frequency;
      l_prev_work_days  := to_number(asg_mod_rec.work_days);
      l_prev_num_hours  := asg_mod_rec.normal_hours;
      l_prev_start_date := asg_mod_rec.effective_start_date;
    END LOOP; -- End loop for date tracked changes
  END LOOP;-- End loop for assignments
  --
  -- Insert a row into pay_patch_status
  INSERT INTO pay_patch_status
          (id
          ,patch_number
          ,patch_name
          ,phase
          ,applied_date
          ,legislation_code)
  SELECT
           pay_patch_status_s.nextval
          ,p_business_group_id
          ,'WORKING TIME'
          ,Null
          ,sysdate
          ,'FR'
  FROM dual;
  --
END IF; -- end if for checking if migration script has already been run
CLOSE csr_migr_script_run;
--
Exception
  When others then
     hr_utility.set_location('Error:PAY_FR_MIGRATE_TIME_ANALYSIS.migrate',9999);
     Raise;
End Migrate;
End PAY_FR_MIGRATE_TIME_ANALYSIS;

/
