--------------------------------------------------------
--  DDL for Package Body PAY_NO_ARCHIVE_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ARCHIVE_ABSENCE" as
/* $Header: pynoabsa.pkb 120.0.12000000.1 2007/05/22 05:24:58 rajesrin noship $ */
	 TYPE lock_rec IS RECORD (
	      archive_assact_id    NUMBER);
	 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;
	 g_debug   boolean   :=  hr_utility.debug_enabled;
	 g_lock_table   		          lock_table;
	 g_package           VARCHAR2(33) := ' PAY_NO_ARCHIVE_ABSENCE.';
	 g_err_num NUMBER;
	 g_errm VARCHAR2(150);
	 /* GET PARAMETER */
	 FUNCTION GET_PARAMETER(
		 p_parameter_string IN VARCHAR2
		,p_token            IN VARCHAR2
		,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
	 IS
		   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
		   l_start_pos  NUMBER;
		   l_delimiter  VARCHAR2(1):=' ';
		   l_proc VARCHAR2(40):= g_package||' get parameter ';
	BEGIN

		 IF g_debug THEN
			hr_utility.set_location(' Entering Function GET_PARAMETER',10);
		 END IF;
		 l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
		 --
		 IF l_start_pos = 0 THEN
			l_delimiter := '|';
			l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
		 END IF;
		 IF l_start_pos <> 0 THEN
			l_start_pos := l_start_pos + length(p_token||'=');
			l_parameter := substr(p_parameter_string,
			l_start_pos,
			instr(p_parameter_string||' ',
			l_delimiter,l_start_pos)
			- l_start_pos);
			 IF p_segment_number IS NOT NULL THEN
				l_parameter := ':'||l_parameter||':';
				l_parameter := substr(l_parameter,
				instr(l_parameter,':',1,p_segment_number)+1,
				instr(l_parameter,':',1,p_segment_number+1) -1
				- instr(l_parameter,':',1,p_segment_number));
			END IF;
		END IF;
		--
		IF g_debug THEN
			hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
		END IF;
		RETURN l_parameter;
	 END;
	/* GET ALL PARAMETERS */
	PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id         IN   NUMBER
       ,p_business_group_id         OUT  NOCOPY NUMBER
       ,p_legal_employer_id	    OUT  NOCOPY  NUMBER
       ,p_start_date                OUT NOCOPY DATE
       ,p_end_date		    OUT  NOCOPY DATE
       ,p_archive		    OUT NOCOPY VARCHAR2
       ,p_effective_date            OUT NOCOPY DATE
       	) IS
		CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
		SELECT PAY_NO_ARCHIVE_ABSENCE.GET_PARAMETER(legislative_parameters,
		'LEGAL_EMPLOYER')
		,FND_DATE.canonical_to_date(PAY_NO_ARCHIVE_ABSENCE.GET_PARAMETER
		(legislative_parameters,'START_DATE'))
		,FND_DATE.canonical_to_date(PAY_NO_ARCHIVE_ABSENCE.GET_PARAMETER
		(legislative_parameters,'END_DATE'))
		,PAY_NO_ARCHIVE_ABSENCE.GET_PARAMETER(legislative_parameters,'ARCHIVE')
		,effective_date
		,business_group_id
		FROM  pay_payroll_actions
		WHERE payroll_action_id = p_payroll_action_id;
		l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
		--
	BEGIN
	fnd_file.put_line (fnd_file.LOG, 'Entering Get all Parameters' );
		 OPEN csr_parameter_info (p_payroll_action_id);
		 FETCH csr_parameter_info
		 INTO	 p_legal_employer_id
			,p_start_date
          		,p_end_date
			,p_archive
			,p_effective_date
			,p_business_group_id;
		 CLOSE csr_parameter_info;
		 --
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
		 END IF;
	 END GET_ALL_PARAMETERS;

	/*Start of sum_no_absence*/
	 Procedure sum_no_absence(p_sex  in varchar2,
	 			p_absence_days in number,
	 			p_quater in varchar2,
	 			p_certificate_type in varchar2,
	 			p_occurence in number,
	 			p_absence_category in varchar2
	 			)
	 is
	  l_quater number:=0;
	 Begin
	 	 l_quater := to_number(substr(p_quater,2)) - 1;

	 	 IF p_absence_category in ('S','PTS') then
		   if p_sex = 'M' then
			absmale(l_quater).initialized:='Y';
			absmale(l_quater).quater:=p_quater;

			if p_absence_days <= 3 then
			    if p_certificate_type= 'SC' then
			 	absmale(l_quater).sick_1_3_ocr_sc := nvl(absmale(l_quater).sick_1_3_ocr_sc,0) + p_occurence;
				absmale(l_quater).sick_1_3_days_sc := nvl(absmale(l_quater).sick_1_3_days_sc,0) + p_absence_days;
			    elsif p_certificate_type = 'DC' then
				absmale(l_quater).sick_1_3_ocr_dc := nvl(absmale(l_quater).sick_1_3_ocr_dc,0) + p_occurence;
				absmale(l_quater).sick_1_3_days_dc := nvl(absmale(l_quater).sick_1_3_days_dc,0) + p_absence_days;
			    end if;
			elsif p_absence_days > 3 and p_absence_days <= 16 then
			    absmale(l_quater).sick_4_16_ocrs := nvl(absmale(l_quater).sick_4_16_ocrs,0) + p_occurence;
			    absmale(l_quater).sick_4_16_days := nvl(absmale(l_quater).sick_4_16_days,0) + p_absence_days;

			elsif p_absence_days > 16 then
			    absmale(l_quater).sick_more_16_ocrs := nvl(absmale(l_quater).sick_more_16_ocrs,0) + p_occurence;
			    absmale(l_quater).sick_more_16_days := nvl(absmale(l_quater).sick_more_16_days,0) + p_absence_days;
			    If p_absence_days > 40 then
			       	absmale(l_quater).sick_8_weeks_ocr := nvl(absmale(l_quater).sick_8_weeks_ocr,0) + p_occurence;
			    	absmale(l_quater).sick_8_weeks_days := nvl(absmale(l_quater).sick_8_weeks_days,0) + p_absence_days;
			    End if;
			end if;

		    elsif p_sex = 'F' then
			absfemale(l_quater).initialized:='Y';
			absfemale(l_quater).quater:=p_quater;

			if p_absence_days <= 3 then
			    if p_certificate_type = 'SC' then
				absfemale(l_quater).sick_1_3_ocr_sc := nvl(absfemale(l_quater).sick_1_3_ocr_sc,0) + p_occurence;
				absfemale(l_quater).sick_1_3_days_sc := nvl(absfemale(l_quater).sick_1_3_days_sc,0) + p_absence_days;
			    elsif p_certificate_type = 'DC' then
				absfemale(l_quater).sick_1_3_ocr_dc := nvl(absfemale(l_quater).sick_1_3_ocr_dc,0) + p_occurence;
				absfemale(l_quater).sick_1_3_days_dc := nvl(absfemale(l_quater).sick_1_3_days_dc,0) + p_absence_days;
			    end if;
			elsif p_absence_days > 3 and p_absence_days <= 16 then
			    absfemale(l_quater).sick_4_16_ocrs := nvl(absfemale(l_quater).sick_4_16_ocrs,0) + p_occurence;
			    absfemale(l_quater).sick_4_16_days := nvl(absfemale(l_quater).sick_4_16_days,0) + p_absence_days;
			elsif p_absence_days > 16 then
			    absfemale(l_quater).sick_more_16_ocrs := nvl(absfemale(l_quater).sick_more_16_ocrs,0) + p_occurence;
			    absfemale(l_quater).sick_more_16_days := nvl(absfemale(l_quater).sick_more_16_days,0) + p_absence_days;

			    If p_absence_days > 40 then
				absfemale(l_quater).sick_8_weeks_ocr := nvl(absfemale(l_quater).sick_8_weeks_ocr,0) + p_occurence;
				absfemale(l_quater).sick_8_weeks_days := nvl(absfemale(l_quater).sick_8_weeks_days,0) + p_absence_days;
			    End if;

			end if;
		     End if;
		ELSIF p_absence_category = 'CMS' then

			if p_sex = 'M' then
				absmale(l_quater).initialized:='Y';
				absmale(l_quater).quater:=p_quater;

				absmale(l_quater).cms_abs_ocrs := nvl(absmale(l_quater).cms_abs_ocrs,0) + p_occurence;
				absmale(l_quater).cms_abs_days := nvl(absmale(l_quater).cms_abs_days,0) + p_absence_days;
			elsif p_sex = 'F' then
				absfemale(l_quater).initialized:='Y';
				absfemale(l_quater).quater:=p_quater;

				absfemale(l_quater).cms_abs_ocrs := nvl(absfemale(l_quater).cms_abs_ocrs,0) + p_occurence;
				absfemale(l_quater).cms_abs_days := nvl(absfemale(l_quater).cms_abs_days,0) + p_absence_days;
			end if;

		ELSIF p_absence_category in ('PA','M','IE_AL','PTM','PTP','PTA') then

			if p_sex = 'M' then
				absmale(l_quater).initialized:='Y';
				absmale(l_quater).quater:=p_quater;

				absmale(l_quater).parental_abs_ocrs := nvl(absmale(l_quater).parental_abs_ocrs,0) + p_occurence;
				absmale(l_quater).parental_abs_days := nvl(absmale(l_quater).parental_abs_days,0) + p_absence_days;
			elsif p_sex = 'F' then
				absfemale(l_quater).initialized:='Y';
				absfemale(l_quater).quater:=p_quater;

				absfemale(l_quater).parental_abs_ocrs := nvl(absfemale(l_quater).parental_abs_ocrs,0) + p_occurence;
				absfemale(l_quater).parental_abs_days := nvl(absfemale(l_quater).parental_abs_days,0) + p_absence_days;
			end if;
		ELSIF p_absence_category in ('UN','ZZB','UL') then  --Need to add Unpaid Leave
					if p_sex = 'M' then
						absmale(l_quater).initialized:='Y';
						absmale(l_quater).quater:=p_quater;

						absmale(l_quater).other_abs_ocrs := nvl(absmale(l_quater).other_abs_ocrs,0) + p_occurence;
						absmale(l_quater).other_abs_days := nvl(absmale(l_quater).other_abs_days,0) + p_absence_days;
					elsif p_sex = 'F' then
						absfemale(l_quater).initialized:='Y';
						absfemale(l_quater).quater:=p_quater;

						absfemale(l_quater).other_abs_ocrs := nvl(absfemale(l_quater).other_abs_ocrs,0) + p_occurence;
						absfemale(l_quater).other_abs_days := nvl(absfemale(l_quater).other_abs_days,0) + p_absence_days;
					end if;
		ELSIF p_absence_category <> 'VAC' then
			if p_sex = 'M' then
				absmale(l_quater).initialized:='Y';
				absmale(l_quater).quater:=p_quater;

				absmale(l_quater).other_abs_paid_ocrs := nvl(absmale(l_quater).other_abs_paid_ocrs,0) + p_occurence;
				absmale(l_quater).other_abs_paid_days := nvl(absmale(l_quater).other_abs_paid_days,0) + p_absence_days;
			elsif p_sex = 'F' then
				absfemale(l_quater).initialized:='Y';
				absfemale(l_quater).quater:=p_quater;

				absfemale(l_quater).other_abs_paid_ocrs := nvl(absfemale(l_quater).other_abs_paid_ocrs,0) + p_occurence;
				absfemale(l_quater).other_abs_paid_days := nvl(absfemale(l_quater).other_abs_paid_days,0) + p_absence_days;
			end if;

		END IF;
	 End sum_no_absence;

	/*End of sum_no_absence*/

	/* RANGE CODE */
	PROCEDURE RANGE_CODE (p_payroll_action_id    IN    NUMBER
			     ,p_sql    OUT   NOCOPY VARCHAR2)
	IS
	Begin
		 p_sql := 'SELECT DISTINCT person_id
			     FROM  per_people_f ppf
			     ,pay_payroll_actions ppa
			     WHERE ppa.payroll_action_id = :payroll_action_id
			     AND   ppa.business_group_id = ppf.business_group_id
			     ORDER BY ppf.person_id';

		IF g_debug THEN
			hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
		-- Return cursor that selects no rows
		p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
	END RANGE_CODE;
	 /* ASSIGNMENT ACTION CODE */
	 PROCEDURE ASSIGNMENT_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS
	 BEGIN
--	 fnd_file.put_line (fnd_file.LOG, 'Entering Assignment Action Code' );
		IF g_debug THEN
			hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
		END IF;
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
		 END IF;
--		 	 fnd_file.put_line (fnd_file.LOG, 'Exiting Assignment Action Code' );
	END ASSIGNMENT_ACTION_CODE;
	 /* INITIALIZATION CODE */
	 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
	 IS
	 BEGIN
	 fnd_file.put_line (fnd_file.LOG, 'Entering Initialization Code' );
		 IF g_debug THEN
		      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
		 END IF;
		 IF g_debug THEN
		      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
		 END IF;
		  fnd_file.put_line (fnd_file.LOG, 'Existing Initialization Code' );
		 EXCEPTION WHEN OTHERS THEN
		 g_err_num := SQLCODE;
		 IF g_debug THEN
		      hr_utility.set_location('ORA_ERR: ' || g_err_num ||
		      'In INITIALIZATION_CODE',180);
		 END IF;
	 fnd_file.put_line (fnd_file.LOG, 'Error in Initialization Code' );
	 END INITIALIZATION_CODE;

	 PROCEDURE DEINITIALIZE_CODE(p_payroll_action_id IN NUMBER)
	 IS

	 	 l_business_group_id   NUMBER;
		 l_legal_employer_id   NUMBER;
		 l_start_date 	  date;
		 l_end_date	  date;
		 l_effective_date date;
		 l_archive varchar2(20);
		 l_count number;
		 l_action_info_id NUMBER;
		 l_ovn NUMBER;
		 l_quater_cnt NUMBER;
		 l_qtr_start_date date;
		 l_qtr_end_date date;
		 l_quater varchar2(4);
		 l_absence_days number;
		 l_possible_working_days number:=0;
		 l_quater_start date;
		 l_quater_end date;
		 l_full_time_percentage number;
		 l_hr_work_schedule number;
		 l_pos_assignment_id per_all_assignments_f.assignment_id%type;
		 l_total_possible_working_days number:=0;

				/* Cursors */


		Cursor csr_person_abs_details(csr_v_business_group_id number,
				csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE,
				csr_v_start_date  date,
				csr_v_end_date date,
				csr_v_effective_date date
				)is select papf.person_id,
					papf.full_name,
					papf.sex sex,
					'Q'||to_char(paa.date_start,'Q') quaterstart,
					'Q'||to_char(paa.date_end,'Q') quaterend,
					paa.date_start,
					paa.date_end,
					paaf.assignment_id,
					decode(paat.absence_category,'CMS',paa.abs_information1,'S',paa.abs_information1,'PTS',paa.abs_information1,null) certificate_type,
					paat.absence_category,
					paa.abs_information3,
					paa.abs_information4
				from   per_absence_attendances paa,
					per_all_people_f papf,
					per_all_assignments_f paaf,
					per_absence_attendance_types paat,
					hr_soft_coding_keyflex  hsc,
					hr_organization_information hoi
				where paa.person_id = papf.person_id
				and  paa.absence_attendance_type_id = paat.absence_attendance_type_id
				and  paaf.person_id = papf.person_id
				and papf.business_group_id = csr_v_business_group_id
				and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
				and hoi.org_information1 = hsc.segment2
				and hoi.organization_id = csr_v_legal_employer_id
				and hoi.ORG_INFORMATION_CONTEXT = 'NO_LOCAL_UNITS'
				and paaf.primary_flag = 'Y'
				and papf.per_information15 = 'N'
				and paat.absence_category <> 'VAC'
				and ((paa.date_start between csr_v_start_date and csr_v_end_date)
				or (paa.date_end between csr_v_start_date and csr_v_end_date))
				and csr_v_effective_date between papf.effective_start_date and papf.effective_end_date
				and csr_v_effective_date between paaf.effective_start_date and paaf.effective_end_date
				and not exists (select '1'
						from
						  pay_element_entries_f peef,
						  pay_element_types_f petf,
						  per_all_assignments_f paaf1
						where peef.element_type_id = petf.element_type_id
						and paaf1.person_id = papf.person_id
						and peef.assignment_id = paaf1.assignment_id
						and petf.element_name = 'Sickness Unpaid'
						and peef.effective_start_date between csr_v_start_date and csr_v_end_date);

				cursor csr_possible_wrk_days
					(csr_v_start_date date
					,csr_v_end_date date
					,csr_v_business_group_id number
					,csr_v_legal_employer_id number
					,csr_v_effective_date date
					,csr_v_sex varchar2) is
				select	paaf.assignment_id
				from    per_all_people_f papf,
					per_all_assignments_f paaf,
					hr_soft_coding_keyflex  hsc,
					hr_organization_information hoi
				where  paaf.person_id = papf.person_id
				and papf.business_group_id = csr_v_business_group_id
				and hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
				and hoi.org_information1 = hsc.segment2
				and hoi.organization_id = csr_v_legal_employer_id
				and hoi.ORG_INFORMATION_CONTEXT = 'NO_LOCAL_UNITS'
				and paaf.primary_flag = 'Y'
				and papf.per_information15 = 'N'
				and csr_v_effective_date between papf.effective_start_date and papf.effective_end_date
				and csr_v_effective_date between paaf.effective_start_date and paaf.effective_end_date
				and papf.sex = csr_v_sex
				and not exists (select '1'
						from
						  pay_element_entries_f peef,
						  pay_element_types_f petf,
						  per_all_assignments_f paaf1
						where peef.element_type_id = petf.element_type_id
						and paaf1.person_id = papf.person_id
						and peef.assignment_id = paaf1.assignment_id
						and petf.element_name = 'Sickness Unpaid'
						and peef.effective_start_date between csr_v_start_date and csr_v_end_date);

				cursor csr_full_time(csr_business_grp_id NUMBER,csr_assignment_id NUMBER,csr_v_effective_date date)
				is select value
				from PER_ASSIGNMENT_BUDGET_VALUES_F
				where business_group_id = csr_business_grp_id
				and assignment_id = csr_assignment_id and unit = 'PFT'
				and csr_v_effective_date between effective_start_date and effective_end_date;

								  /* End of Cursors */

	BEGIN


					hr_utility.set_location(' Entering Procedure RANGE_CODE',10);




				     PAY_NO_ARCHIVE_ABSENCE.GET_ALL_PARAMETERS(
						 p_payroll_action_id
						,l_business_group_id
						,l_legal_employer_id
						,l_start_date
						,l_end_date
						,l_archive
						,l_effective_date
						 );


			IF l_archive = 'Y' THEN

				 /** Insert report parameters                  **/

			    	pay_action_information_api.create_action_information (
					p_action_information_id	=> l_action_info_id,
					p_action_context_id	=> p_payroll_action_id,
					p_action_context_type	=> 'PA',
					p_object_version_number	=> l_ovn,
					p_effective_date	=> l_effective_date,
					p_source_id		=> NULL,
					p_source_text		=> NULL,
					p_action_information_category=> 'EMEA REPORT DETAILS',
					p_action_information1	=> 'PYNOABSA',
					p_action_information2	=> l_legal_employer_id,
					p_action_information3	=> fnd_date.date_to_canonical(l_start_date),
					p_action_information4	=> fnd_date.date_to_canonical(l_end_date),
					p_action_information5	=> fnd_date.date_to_canonical(l_effective_date)
					);

					SELECT count(*)  INTO l_count
					FROM pay_action_information
					WHERE action_information_category = 'EMEA REPORT INFORMATION'
					AND action_information1= 'PYNOABSA'
					AND action_context_id= p_payroll_action_id;

					hr_utility.set_location('****************Inside Archive ',10);

				IF l_count < 1 then

					absmale(0).initialized:='N';
					absmale(1).initialized:='N';
					absmale(2).initialized:='N';
					absmale(3).initialized:='N';

					absfemale(0).initialized:='N';
					absfemale(1).initialized:='N';
					absfemale(2).initialized:='N';
					absfemale(3).initialized:='N';

				     FOR csr_abs in csr_person_abs_details(l_business_group_id,l_legal_employer_id,l_start_date,l_end_date,l_effective_date)
				     Loop

				       l_full_time_percentage:=null;

				       open csr_full_time(l_business_group_id,csr_abs.assignment_id,l_effective_date);
				       fetch csr_full_time into l_full_time_percentage;
				       close csr_full_time;

				       IF l_full_time_percentage is null then

				            l_full_time_percentage:=100;

				       End if;

				       If csr_abs.quaterstart = csr_abs.quaterend then



					  l_hr_work_schedule:=hr_loc_work_schedule.calc_sch_based_dur(csr_abs.assignment_id,'D','Y',csr_abs.date_start,csr_abs.date_end,'00','23',l_absence_days);

					  l_absence_days := l_absence_days * l_full_time_percentage/100;

					  if csr_abs.absence_category in ('PTS') then
 						  l_absence_days := l_absence_days * nvl(csr_abs.abs_information4,100)/100;
 					  elsif  csr_abs.absence_category in ('PTM','PTP','PTA') then

						  l_absence_days := l_absence_days * nvl(csr_abs.abs_information3,100)/100;
					  end if;

					  l_quater:= 'Q'||to_number(to_char(csr_abs.date_start,'Q'));

					 sum_no_absence(csr_abs.sex,l_absence_days,l_quater,csr_abs.certificate_type,1,csr_abs.absence_category);


					else
						   hr_utility.set_location('*****Inside Else Archive******',20);
					   /* Modified for bug 5388892*/
						  If l_start_date > csr_abs.date_start then
							l_qtr_start_date := l_start_date;
						  Else
							l_qtr_start_date :=csr_abs.date_start;
						  End if;

					  /* Added for bug 5388892*/
					   If l_end_date < csr_abs.date_end or csr_abs.date_end is null then
					      	l_quater_cnt :=  to_number(to_char(l_end_date,'Q')) - to_number(to_char(l_qtr_start_date,'Q'));
					   Else
					   	l_quater_cnt := to_number(to_char(csr_abs.date_end,'Q')) - to_number(to_char(l_qtr_start_date,'Q'));
					   End if;



					   l_qtr_end_date :=trunc(csr_abs.date_end,'Q')-1;
					   --l_linked_quater := 'Q'||to_char(l_qtr_start_date,'Q');

					   hr_utility.set_location('*****Inside Else Archive**'||l_quater_cnt,20);

					   For qtrs in 0..l_quater_cnt
					   Loop

						if qtrs = l_quater_cnt then
						  /* Modified for bug 5388892*/
						  If l_end_date < csr_abs.date_end then
						  	l_qtr_end_date := l_end_date;
						  Else
						  	l_qtr_end_date := nvl(csr_abs.date_end,l_end_date);
						  End if;
						elsif qtrs <> 0 then
						   l_qtr_end_date :=trunc(add_months(l_qtr_start_date,3),'Q')-1;
						end if;
						l_hr_work_schedule:=hr_loc_work_schedule.calc_sch_based_dur(csr_abs.assignment_id,'D','Y',l_qtr_start_date,l_qtr_end_date,'00','23',l_absence_days);
						hr_utility.set_location(' ****1111Absence Days : '||l_absence_days||' : '||l_full_time_percentage,5);
						l_absence_days := l_absence_days * l_full_time_percentage/100;

						/*Added for Bugs 5409100,5409124*/
						if csr_abs.absence_category in ('PTS') then
						  l_absence_days := l_absence_days * nvl(csr_abs.abs_information4,100)/100;
						elsif  csr_abs.absence_category in ('PTM','PTP','PTA') then
						  l_absence_days := l_absence_days * nvl(csr_abs.abs_information3,100)/100;
						end if;

						if qtrs = 0 then
						  /* Added for Bug 5381390*/
						  l_quater:= 'Q'||to_number(to_char(l_qtr_start_date,'Q'));
						  If l_start_date > csr_abs.date_start then
							sum_no_absence(csr_abs.sex,l_absence_days,l_quater,csr_abs.certificate_type,0,csr_abs.absence_category);
						  Else
							sum_no_absence(csr_abs.sex,l_absence_days,l_quater,csr_abs.certificate_type,1,csr_abs.absence_category);
						  End if;

						else
						   l_quater:= 'Q'||to_number(to_char(l_qtr_start_date,'Q'));
						  sum_no_absence(csr_abs.sex,l_absence_days,l_quater,csr_abs.certificate_type,0,csr_abs.absence_category);
						end if;

						l_qtr_start_date :=l_qtr_end_date+1;
					      End loop;

					  End if;
				      End Loop;

				END IF;

				hr_utility.set_location('***Table Populated***',50);

				l_quater_start := trunc(l_start_date,'Q');
				l_quater_end := trunc(add_months(l_quater_start,3),'Q')-1;

				For itr in absmale.FIRST .. absmale.LAST
				Loop

					FOR csr_possible_wrk_days1 in csr_possible_wrk_days(l_quater_start,l_quater_end,l_business_group_id,l_legal_employer_id,l_effective_date,'M')
					Loop

					l_full_time_percentage:=null;

					       open csr_full_time(l_business_group_id,csr_possible_wrk_days1.assignment_id,l_effective_date);
					       fetch csr_full_time into l_full_time_percentage;
					       close csr_full_time;

				       IF l_full_time_percentage is null then

					    l_full_time_percentage:=100;

				       End if;

					   l_pos_assignment_id := csr_possible_wrk_days1.assignment_id;
					   l_hr_work_schedule:=hr_loc_work_schedule.calc_sch_based_dur(l_pos_assignment_id,'D','Y',l_quater_start,l_quater_end,'00','23',l_possible_working_days);
					   l_total_possible_working_days := nvl(l_total_possible_working_days,0) + (nvl(l_possible_working_days,0)*l_full_time_percentage/100);

					End loop;
					hr_utility.trace('Entered l_quater_end ******* '||l_quater_end);

				    If absmale(itr).initialized = 'Y' then
					pay_action_information_api.create_action_information (
						p_action_information_id         => l_action_info_id
						,p_action_context_id            => p_payroll_action_id
						,p_action_context_type          => 'PA'
						,p_object_version_number        => l_ovn
						,p_effective_date               => l_effective_date
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'EMEA REPORT INFORMATION'
						,p_action_information1          => 'PYNOABSA'
						,p_action_information2          => l_legal_employer_id
						,p_action_information3          => absmale(itr).quater
						,p_action_information4          => l_total_possible_working_days
						,p_action_information5          => 'M'
						,p_action_information6          => absmale(itr).sick_1_3_ocr_sc
						,p_action_information7          => absmale(itr).sick_1_3_days_sc
						,p_action_information8          => absmale(itr).sick_1_3_ocr_dc
						,p_action_information9          => absmale(itr).sick_1_3_days_dc
						,p_action_information10         => absmale(itr).sick_4_16_ocrs
						,p_action_information11         => absmale(itr).sick_4_16_days
						,p_action_information12         => absmale(itr).sick_more_16_ocrs
						,p_action_information13         => absmale(itr).sick_more_16_days
						,p_action_information14         => absmale(itr).cms_abs_ocrs
						,p_action_information15         => absmale(itr).cms_abs_days
						,p_action_information16         => absmale(itr).parental_abs_ocrs
						,p_action_information17         => absmale(itr).parental_abs_days
						,p_action_information18         => absmale(itr).other_abs_ocrs
						,p_action_information19         => absmale(itr).other_abs_days
						,p_action_information20		=> absmale(itr).sick_8_weeks_ocr
						,p_action_information21		=> absmale(itr).sick_8_weeks_days
						,p_action_information22         => absmale(itr).other_abs_paid_ocrs
						,p_action_information23         => absmale(itr).other_abs_paid_days
						,p_action_information24         => l_business_group_id);

					End if;

					l_quater_start := l_quater_end + 1;
					l_quater_end := trunc(add_months(l_quater_start,3),'Q')-1;
					/* Added for bug 5381141*/
					l_total_possible_working_days := 0;
				End loop;

				hr_utility.set_location('***Done with Male*** '||absmale.LAST,50);

				l_quater_start := trunc(l_start_date,'Q');
				l_quater_end := trunc(add_months(l_quater_start,3),'Q')-1;
				l_total_possible_working_days:=0;

				For itrf in absfemale.FIRST .. absfemale.LAST
				Loop
					For csr_possible_wrk_days1 in csr_possible_wrk_days(l_quater_start,l_quater_end,l_business_group_id,l_legal_employer_id,l_effective_date,'F')
					Loop

					l_full_time_percentage:=null;

					       open csr_full_time(l_business_group_id,csr_possible_wrk_days1.assignment_id,l_effective_date);
					       fetch csr_full_time into l_full_time_percentage;
					       close csr_full_time;

				       IF l_full_time_percentage is null then

					    l_full_time_percentage:=100;

				       End if;
				       l_pos_assignment_id := csr_possible_wrk_days1.assignment_id;
				       l_hr_work_schedule:=hr_loc_work_schedule.calc_sch_based_dur(l_pos_assignment_id,'D','Y',l_quater_start,l_quater_end,'00','23',l_possible_working_days);
					l_total_possible_working_days := nvl(l_total_possible_working_days,0) + (nvl(l_possible_working_days,0)*l_full_time_percentage/100);

				End loop;

				    If absfemale(itrf).initialized = 'Y' then
					pay_action_information_api.create_action_information (
						p_action_information_id         => l_action_info_id
						,p_action_context_id            => p_payroll_action_id
						,p_action_context_type          => 'PA'
						,p_object_version_number        => l_ovn
						,p_effective_date               => l_effective_date
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'EMEA REPORT INFORMATION'
						,p_action_information1          => 'PYNOABSA'
						,p_action_information2          => l_legal_employer_id
						,p_action_information3          => absfemale(itrf).quater
						,p_action_information4          => l_total_possible_working_days
						,p_action_information5          => 'F'
						,p_action_information6          => absfemale(itrf).sick_1_3_ocr_sc
						,p_action_information7          => absfemale(itrf).sick_1_3_days_sc
						,p_action_information8          => absfemale(itrf).sick_1_3_ocr_dc
						,p_action_information9          => absfemale(itrf).sick_1_3_days_dc
						,p_action_information10         => absfemale(itrf).sick_4_16_ocrs
						,p_action_information11         => absfemale(itrf).sick_4_16_days
						,p_action_information12         => absfemale(itrf).sick_more_16_ocrs
						,p_action_information13         => absfemale(itrf).sick_more_16_days
						,p_action_information14         => absfemale(itrf).cms_abs_ocrs
						,p_action_information15         => absfemale(itrf).cms_abs_days
						,p_action_information16         => absfemale(itrf).parental_abs_ocrs
						,p_action_information17         => absfemale(itrf).parental_abs_days
						,p_action_information18         => absfemale(itrf).other_abs_ocrs
						,p_action_information19         => absfemale(itrf).other_abs_days
						,p_action_information20		=> absfemale(itrf).sick_8_weeks_ocr
						,p_action_information21		=> absfemale(itrf).sick_8_weeks_days
						,p_action_information22         => absfemale(itrf).other_abs_paid_ocrs
						,p_action_information23         => absfemale(itrf).other_abs_paid_days
						,p_action_information24         => l_business_group_id);

				   End if;

					l_quater_start := l_quater_end + 1;
					l_quater_end := trunc(add_months(l_quater_start,3),'Q')-1;
					/* Added for bug 5381141*/
					l_total_possible_working_days := 0;
				End loop;

				hr_utility.set_location('***Done with Female*** '||absfemale.LAST,50);

		END IF;
	 		  fnd_file.put_line (fnd_file.LOG, 'Existing Initialization Code' );
	 EXCEPTION WHEN OTHERS THEN
		 g_err_num := SQLCODE;
		 IF g_debug THEN
		      hr_utility.set_location('ORA_ERR: ' || g_err_num ||
		      'In INITIALIZATION_CODE',180);
		 END IF;
	 	 fnd_file.put_line (fnd_file.LOG, 'Error in Initialization Code' );
	 END DEINITIALIZE_CODE;

 	 /* ARCHIVE CODE */
	 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
			      ,p_effective_date    IN DATE)
	 IS
	BEGIN
	fnd_file.put_line (fnd_file.LOG, 'entering archive code' );
		 IF g_debug THEN
				hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',80);
		 END IF;
		 IF g_debug THEN
				hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',90);
		 END IF;
    fnd_file.put_line (fnd_file.LOG, 'Exiting archive code' );
	END ARCHIVE_CODE;
 END PAY_NO_ARCHIVE_ABSENCE;

/
