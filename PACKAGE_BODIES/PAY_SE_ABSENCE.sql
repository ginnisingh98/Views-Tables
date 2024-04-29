--------------------------------------------------------
--  DDL for Package Body PAY_SE_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ABSENCE" AS
/* $Header: pysesick.pkb 120.5 2007/08/20 15:18:16 rravi noship $ */
FUNCTION GET_HOURLY_RATE(
   p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_Monthly_Pay                 IN         NUMBER
  ,p_hourly_rate_option1	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option2	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option3	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option4	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option5	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option6	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option7	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option8	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option9	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate_option10	 OUT	    NOCOPY VARCHAR
  ,p_hourly_rate		 OUT        NOCOPY NUMBER
  ,p_normal_hours		 OUT        NOCOPY NUMBER
  ,p_working_perc		 OUT        NOCOPY NUMBER
  ,p_salary_rate_option1	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option2	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option3	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option4	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option5	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option6	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option7	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option8	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option9	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate_option10	 OUT	    NOCOPY VARCHAR
  ,p_salary_rate		 OUT	    NOCOPY NUMBER
  ,p_hour_sal			 OUT        NOCOPY VARCHAR
  )
  RETURN NUMBER IS

l_le_hourly_rate varchar2(20);
 l_pe_hourly_rate varchar2(20);
 l_ab_hourly_rate varchar2(20);
 l_gen_hourly_rate varchar2(20);
 l_le_salary_rate varchar2(20);
 l_pe_salary_rate varchar2(20);
 l_ab_salary_rate varchar2(20);
 l_gen_salary_rate varchar2(20);
 l_person_id NUMBER;
 l_working_percentage NUMBER;
 l_abs_attendance_id NUMBER;
 l_business_group_id NUMBER;
 l_normal_hours NUMBER;
 l_frequency CHAR(1);
 l_hour_sal CHAR(1);
 l_employee_category CHAR(2);
  --To Fetch the hourly rate from EIT for Legal Employer
CURSOR csr_Legal_Employer_Hourly_Rate IS
SELECT	hoi4.ORG_INFORMATION1

               FROM	HR_ORGANIZATION_UNITS o1
                    ,HR_ORGANIZATION_INFORMATION hoi1
                    ,HR_ORGANIZATION_INFORMATION hoi2
                    ,HR_ORGANIZATION_INFORMATION hoi3
                    ,HR_ORGANIZATION_INFORMATION hoi4
                    ,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
                         FROM PER_ALL_ASSIGNMENTS_F ASG
                              ,HR_SOFT_CODING_KEYFLEX SCL
                        WHERE ASG.ASSIGNMENT_ID = p_assignment_id
                          AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
                          AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE ) X
              WHERE o1.business_group_id = l_business_group_id
                AND hoi1.organization_id = o1.organization_id
                AND hoi1.organization_id = X.ORG_ID
                AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
                AND hoi1.org_information_context = 'CLASS'
                AND o1.organization_id = hoi2.org_information1
                AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
                AND hoi2.organization_id =  hoi3.organization_id
                AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
                AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
                AND hoi3.organization_id = hoi4.organization_id
                AND hoi4.ORG_INFORMATION_CONTEXT='SE_HOURLY_RATE_DETAILS'
                AND HOI4.org_information1 IS NOT NULL;

CURSOR csr_Legal_Employer_Salary_Rate IS
SELECT	hoi4.ORG_INFORMATION1

               FROM	HR_ORGANIZATION_UNITS o1
                    ,HR_ORGANIZATION_INFORMATION hoi1
                    ,HR_ORGANIZATION_INFORMATION hoi2
                    ,HR_ORGANIZATION_INFORMATION hoi3
                    ,HR_ORGANIZATION_INFORMATION hoi4
                    ,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
                         FROM PER_ALL_ASSIGNMENTS_F ASG
                              ,HR_SOFT_CODING_KEYFLEX SCL
                        WHERE ASG.ASSIGNMENT_ID = p_assignment_id
                          AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
                          AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE ) X
              WHERE o1.business_group_id = l_business_group_id
                AND hoi1.organization_id = o1.organization_id
                AND hoi1.organization_id = X.ORG_ID
                AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
                AND hoi1.org_information_context = 'CLASS'
                AND o1.organization_id = hoi2.org_information1
                AND hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
                AND hoi2.organization_id =  hoi3.organization_id
                AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
                AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
                AND hoi3.organization_id = hoi4.organization_id
                AND hoi4.ORG_INFORMATION_CONTEXT='SE_HOURLY_RATE_DETAILS'
                AND HOI4.org_information2 IS NOT NULL;

--To fetch the hourly rate from person form

CURSOR csr_Person_Hourly_Rate IS
SELECT PER_INFORMATION6   AS Hourly_Rate	 --Hourly/Salaried
              FROM PER_ALL_PEOPLE_F PER
      	      WHERE PER.PERSON_ID = l_person_id
     	      AND P_EFFECTIVE_DATE BETWEEN PER.EFFECTIVE_START_DATE
              AND PER.EFFECTIVE_END_DATE;

CURSOR csr_Person_Salary_Rate IS
SELECT PER_INFORMATION7   AS Salary_Rate	 --Hourly/Salaried
              FROM PER_ALL_PEOPLE_F PER
      	      WHERE PER.PERSON_ID = l_person_id
     	      AND P_EFFECTIVE_DATE BETWEEN PER.EFFECTIVE_START_DATE
              AND PER.EFFECTIVE_END_DATE;

CURSOR csr_Absence_Hourly_Rate IS
SELECT PAA.ABS_INFORMATION1   AS Hourly_Rate		--Daily Rate Calculation
		FROM PER_ABSENCE_ATTENDANCES PAA
          	WHERE PAA.ABSENCE_ATTENDANCE_ID =l_abs_attendance_id;


CURSOR csr_Absence_Salary_Rate IS
SELECT PAA.ABS_INFORMATION2   AS Salary_Rate		--Daily Rate Calculation
		FROM PER_ABSENCE_ATTENDANCES PAA
          	WHERE PAA.ABSENCE_ATTENDANCE_ID =l_abs_attendance_id;


CURSOR csr_abs_attendance_id (l_asg_id number, l_eff_dt date, l_inp_val_name varchar2, l_start_dt date, l_end_dt date) IS
    SELECT eev1.screen_entry_value  screen_entry_value
    FROM   per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
    WHERE  asg1.assignment_id    = l_asg_id
      AND l_eff_dt BETWEEN asg1.effective_start_date AND asg1.effective_end_date
      AND l_eff_dt BETWEEN asg2.effective_start_date AND asg2.effective_end_date
      AND  per.person_id         = asg1.person_id
      AND  asg2.person_id        = per.person_id
      --AND  asg2.primary_flag     = 'Y'
      AND  asg1.assignment_id=asg2.assignment_id
      AND  et.element_name       = 'Sickness Details'
      AND  et.legislation_code   = 'SE'
      --OR et.business_group_id=3261      ) --checking for the business group, it should be removed
      AND  iv1.element_type_id   = et.element_type_id
      AND  iv1.name              = l_inp_val_name
      AND  el.business_group_id  = per.business_group_id
      AND  el.element_type_id    = et.element_type_id
      AND  ee.assignment_id      = asg2.assignment_id
      AND  ee.element_link_id    = el.element_link_id
      AND  eev1.element_entry_id = ee.element_entry_id
      AND  eev1.input_value_id   = iv1.input_value_id
      AND  ee.effective_start_date  >= l_start_dt
      AND  ee.effective_end_date <= l_end_dt
      AND  eev1.effective_start_date <= l_start_dt
      AND  eev1.effective_end_date >= l_end_dt
      AND ROWNUM < 2 ;



  BEGIN

  BEGIN
		SELECT papf.person_id
		,papf.business_group_id
		,segment9
		,normal_hours
		,frequency
		,hourly_salaried_code
		,employee_category
		INTO l_person_id
		,l_business_group_id
		,l_working_percentage
		,l_normal_hours
		,l_frequency
		,l_hour_sal
		,l_employee_category
		FROM per_all_assignments_f paaf,
		per_all_people_f papf,
		hr_soft_coding_keyflex hsck
		WHERE paaf.assignment_id = p_assignment_id
		AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
		AND papf.person_id=paaf.person_id
                AND p_effective_date BETWEEN paaf.effective_start_date
                AND paaf.effective_end_date
		AND p_effective_date BETWEEN papf.effective_start_date
                AND papf.effective_end_date;


        EXCEPTION
		WHEN OTHERS THEN
		RETURN 0;
        END;

	OPEN csr_abs_attendance_id (p_assignment_id,p_effective_date,'CREATOR_ID',p_abs_start_date, p_abs_end_date);
		FETCH csr_abs_attendance_id INTO l_abs_attendance_id;
	CLOSE csr_abs_attendance_id;

	IF l_hour_sal='H' THEN
		OPEN csr_Absence_Hourly_Rate;
			FETCH csr_Absence_Hourly_Rate INTO l_ab_hourly_rate;
		CLOSE csr_Absence_Hourly_Rate;

		OPEN csr_Person_Hourly_Rate;
			FETCH csr_Person_Hourly_Rate INTO l_pe_hourly_rate;
		CLOSE csr_Person_Hourly_Rate;

		OPEN csr_Legal_Employer_Hourly_Rate;
			FETCH csr_Legal_Employer_Hourly_Rate INTO l_le_hourly_rate;
		CLOSE csr_Legal_Employer_Hourly_Rate;


		l_gen_hourly_rate:=nvl(nvl(l_ab_hourly_rate,l_pe_hourly_rate),l_le_hourly_rate);

		IF l_gen_hourly_rate='HRATE_OPTION1' THEN
			p_hourly_rate_option1:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION2' THEN
			p_hourly_rate_option2:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION3' THEN
			p_hourly_rate_option3:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION4' THEN
			p_hourly_rate_option4:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION5' THEN
			p_hourly_rate_option5:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION6' THEN
			p_hourly_rate_option6:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION7' THEN
			p_hourly_rate_option7:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION8' THEN
			p_hourly_rate_option8:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION9' THEN
			p_hourly_rate_option9:='Y';
		ELSIF l_gen_hourly_rate='HRATE_OPTION10' THEN
			p_hourly_rate_option10:='Y';
		ELSE
			p_hourly_rate_option1  := null;
			p_hourly_rate_option2  := null;
			p_hourly_rate_option3  := null;
			p_hourly_rate_option4  := null;
			p_hourly_rate_option5  := null;
			p_hourly_rate_option6  := null;
			p_hourly_rate_option7  := null;
			p_hourly_rate_option8  := null;
			p_hourly_rate_option9  := null;
			p_hourly_rate_option10 := null;
			/*IF l_hour_sal IS NULL THEN
				p_hourly_rate:=0;
			ELSIF (l_hour_sal='S' AND l_frequency='W') OR (l_employee_category='WC' AND l_frequency='W') THEN
				p_hourly_rate:=round(((p_Monthly_Pay*12)/(52*l_normal_hours)*l_working_percentage/100),2);
			ELSE
				p_hourly_rate:=0;*/
			END IF;
	ELSIF l_hour_sal='S' THEN

		OPEN csr_Absence_Salary_Rate;
			FETCH csr_Absence_Salary_Rate INTO l_ab_salary_rate;
		CLOSE csr_Absence_Salary_Rate;

		OPEN csr_Person_Salary_Rate;
			FETCH csr_Person_Salary_Rate INTO l_pe_salary_rate;
		CLOSE csr_Person_Salary_Rate;

		OPEN csr_Legal_Employer_Salary_Rate;
			FETCH csr_Legal_Employer_Salary_Rate INTO l_le_salary_rate;
		CLOSE csr_Legal_Employer_Salary_Rate;


		l_gen_salary_rate:=nvl(nvl(l_ab_salary_rate,l_pe_salary_rate),l_le_salary_rate);

		IF l_gen_salary_rate='OPTION1' THEN
			p_salary_rate_option1:='Y';
		ELSIF l_gen_salary_rate='OPTION2' THEN
			p_salary_rate_option2:='Y';
		ELSIF l_gen_salary_rate='OPTION3' THEN
			p_salary_rate_option3:='Y';
		ELSIF l_gen_salary_rate='OPTION4' THEN
			p_salary_rate_option4:='Y';
		ELSIF l_gen_salary_rate='OPTION5' THEN
			p_salary_rate_option5:='Y';
		ELSIF l_gen_salary_rate='OPTION6' THEN
			p_salary_rate_option6:='Y';
		ELSIF l_gen_salary_rate='OPTION7' THEN
			p_salary_rate_option7:='Y';
		ELSIF l_gen_salary_rate='OPTION8' THEN
			p_salary_rate_option8:='Y';
		ELSIF l_gen_salary_rate='OPTION9' THEN
			p_salary_rate_option9:='Y';
		ELSIF l_gen_salary_rate='OPTION10' THEN
			p_salary_rate_option10:='Y';
		ELSE
			p_salary_rate_option1  := null;
			p_salary_rate_option2  := null;
			p_salary_rate_option3  := null;
			p_salary_rate_option4  := null;
			p_salary_rate_option5  := null;
			p_salary_rate_option6  := null;
			p_salary_rate_option7  := null;
			p_salary_rate_option8  := null;
			p_salary_rate_option9  := null;
			p_salary_rate_option10 := null;
		    IF (l_hour_sal='S' AND l_frequency='W') OR (l_employee_category='WC' AND l_frequency='W') THEN
			 p_salary_rate:=round(((p_Monthly_Pay*12)/(52*l_normal_hours)*l_working_percentage/100),2);
		    END IF;
		END IF;

	ELSE
			p_hourly_rate_option1  := null;
			p_hourly_rate_option2  := null;
			p_hourly_rate_option3  := null;
			p_hourly_rate_option4  := null;
			p_hourly_rate_option5  := null;
			p_hourly_rate_option6  := null;
			p_hourly_rate_option7  := null;
			p_hourly_rate_option8  := null;
			p_hourly_rate_option9  := null;
			p_hourly_rate_option10 := null;
			p_salary_rate_option1  := null;
			p_salary_rate_option2  := null;
			p_salary_rate_option3  := null;
			p_salary_rate_option4  := null;
			p_salary_rate_option5  := null;
			p_salary_rate_option6  := null;
			p_salary_rate_option7  := null;
			p_salary_rate_option8  := null;
			p_salary_rate_option9  := null;
			p_salary_rate_option10 := null;
			p_hourly_rate:=0;
			p_salary_rate:=0;
	END IF;
	p_normal_hours:=nvl(l_normal_hours,0);
	p_working_perc:=nvl(l_working_percentage,0);
    p_hour_sal:=l_hour_sal;
  RETURN 1;
  EXCEPTION
  WHEN OTHERS THEN
  RETURN 0;
END GET_HOURLY_RATE;

FUNCTION GET_GROUP(
   p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_group_start_date1		 OUT	    NOCOPY DATE
  ,p_group_start_date2		 OUT	    NOCOPY DATE
  ,p_group_start_date3		 OUT	    NOCOPY DATE
  ,p_group_start_date4		 OUT	    NOCOPY DATE
  ,p_group_start_date5		 OUT	    NOCOPY DATE
  ,p_group_start_date6		 OUT	    NOCOPY DATE
  ,p_group_start_date7		 OUT	    NOCOPY DATE
  ,p_group_start_date8		 OUT	    NOCOPY DATE
  ,p_group_start_date9		 OUT	    NOCOPY DATE
  ,p_group_start_date10		 OUT	    NOCOPY DATE
  ,p_group_start_date11		 OUT	    NOCOPY DATE
  ,p_group_end_date1		 OUT	    NOCOPY DATE
  ,p_group_end_date2		 OUT	    NOCOPY DATE
  ,p_group_end_date3		 OUT	    NOCOPY DATE
  ,p_group_end_date4		 OUT	    NOCOPY DATE
  ,p_group_end_date5		 OUT	    NOCOPY DATE
  ,p_group_end_date6		 OUT	    NOCOPY DATE
  ,p_group_end_date7		 OUT	    NOCOPY DATE
  ,p_group_end_date8		 OUT	    NOCOPY DATE
  ,p_group_end_date9		 OUT	    NOCOPY DATE
  ,p_group_end_date10		 OUT	    NOCOPY DATE
  ,p_group_end_date11		 OUT	    NOCOPY DATE
  ,p_group_option1		 OUT	    NOCOPY VARCHAR2
  ,p_group_option2		 OUT	    NOCOPY VARCHAR2
  ,p_group_option3		 OUT	    NOCOPY VARCHAR2
  ,p_group_option4		 OUT	    NOCOPY VARCHAR2
  ,p_group_option5		 OUT	    NOCOPY VARCHAR2
  ,p_group_option6		 OUT	    NOCOPY VARCHAR2
  ,p_group_option7		 OUT	    NOCOPY VARCHAR2
  ,p_group_option8		 OUT	    NOCOPY VARCHAR2
  ,p_group_option9		 OUT	    NOCOPY VARCHAR2
  ,p_group_option10		 OUT	    NOCOPY VARCHAR2
  ,p_group_option11		 OUT	    NOCOPY VARCHAR2
  ,p_asg_hour_sal		 OUT        NOCOPY VARCHAR2
  )
RETURN NUMBER IS

l_st_date date;

CURSOR csr_absence(l_person_id Number) is
	/*SELECT paa.absence_attendance_id
        ,paa.date_start
        ,nvl(paa.date_end,p_abs_end_date) date_end
        ,paa.time_start
        ,paa.time_end
        ,DECODE(paa.date_start, paa.date_end, 1, (paa.date_end-paa.date_start)+1) AS days_diff
	FROM per_absence_attendances paa,
    per_absence_attendance_types pat
	WHERE paa.person_id = l_person_id
        AND ((paa.date_start between l_st_date and p_abs_end_date)
        OR  (paa.date_end between l_st_date and p_abs_end_date))
        AND paa.date_start IS NOT NULL /*AND paa.date_end IS NOT NULL*/
        /*AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
        ORDER BY paa.date_end  desc;*/

	--Fix for bug no. 5355937

SELECT paa.absence_attendance_id
        ,paa.date_start
        --,nvl(paa.date_end,'31-jan-2000') date_end
        ,least(nvl(paa.date_end,p_abs_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=l_person_id),p_abs_end_date)) date_end
        ,paa.time_start
        ,paa.time_end
        ,DECODE(paa.date_start,least(nvl(paa.date_end,p_abs_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=l_person_id),p_abs_end_date)), 1,
	(least(nvl(paa.date_end,p_abs_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=l_person_id),p_abs_end_date))-paa.date_start)+1) AS days_diff
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = l_person_id
        /*AND paa.date_start >=p_abs_start_date
	AND nvl(paa.date_end,p_abs_end_date)<=p_abs_end_date*/
	AND ((paa.date_start between l_st_date and p_abs_end_date)
        OR  (paa.date_end between l_st_date and p_abs_end_date))
        /*AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL*/
        AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
        AND paa.absence_attendance_id IN(
--        ORDER BY paa.date_end  ;


   SELECT eev1.screen_entry_value  screen_entry_value
    FROM   per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
    WHERE  asg1.assignment_id    = p_assignment_id --34040 --l_asg_id
      AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
      AND  p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
      AND  per.person_id         = asg1.person_id
      AND  asg2.person_id        = per.person_id
      --AND  asg2.primary_flag     = 'Y'
      AND asg1.assignment_id=asg2.assignment_id
      AND  et.element_name       = 'Sickness Details'
      AND  et.legislation_code   = 'SE'
      --OR et.business_group_id=3261      ) --checking for the business group, it should be removed
      AND  iv1.element_type_id   = et.element_type_id
      AND  iv1.name              = 'CREATOR_ID'
      AND  el.business_group_id  = per.business_group_id
      AND  el.element_type_id    = et.element_type_id
      AND  ee.assignment_id      = asg2.assignment_id
      AND  ee.element_link_id    = el.element_link_id
      AND  eev1.element_entry_id = ee.element_entry_id
      AND  eev1.input_value_id   = iv1.input_value_id
      /*AND  ee.effective_start_date  >= p_abs_start_date
      AND  ee.effective_end_date <= p_abs_end_date
      AND  eev1.effective_start_date >= p_abs_start_date
      AND  eev1.effective_end_date <= p_abs_end_date*/
      ) ORDER BY paa.date_end desc ;

TYPE l_date IS
      TABLE OF DATE
      INDEX BY BINARY_INTEGER;

TYPE l_char IS
      TABLE OF char
      INDEX BY BINARY_INTEGER;

      l_start_date l_date;
      l_end_date l_date;
      l_gp_char l_char;
      l_prev_start_date DATE :=NULL;
      l_group_start_date DATE;
      l_group_end_date DATE;
      l_person_id NUMBER;
      l_counter NUMBER :=1;

BEGIN
l_st_date :=to_date('01010001','DDMMYYYY');

FOR l_counter IN 1..10 LOOP
l_start_date(l_counter):=NULL;
l_end_date(l_counter):=NULL;
l_gp_char(l_counter):=NULL;
END LOOP;

	BEGIN
		SELECT papf.person_id ,
		hourly_salaried_code
		INTO l_person_id ,
		p_asg_hour_sal
		FROM per_all_assignments_f paaf,
		per_all_people_f papf,
		hr_soft_coding_keyflex hsck
		WHERE paaf.assignment_id = p_assignment_id
		AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
		AND papf.person_id=paaf.person_id
                AND p_effective_date BETWEEN paaf.effective_start_date
                AND paaf.effective_end_date
		AND p_effective_date BETWEEN papf.effective_start_date
                AND papf.effective_end_date;


	  EXCEPTION
		WHEN OTHERS THEN
		RETURN 0;
        END;



	FOR c_abs IN csr_absence(l_person_id) LOOP
		IF (l_prev_start_date-c_abs.date_end) <= 5 OR (l_prev_start_date-c_abs.date_end) IS NULL THEN
			IF (l_prev_start_date-c_abs.date_end) IS NULL THEN
				l_group_end_date:=c_abs.date_end;
			END IF;
		ELSE

		IF ((l_prev_start_date-c_abs.date_end) > 5) and (c_abs.date_end<p_abs_start_date) THEN
		  exit;
		END IF;
			l_group_start_date:=l_prev_start_date;
			l_start_date(l_counter):=l_group_start_date;
			l_end_date(l_counter):=l_group_end_date;
			l_gp_char(l_counter):='Y';
			l_group_end_date:=c_abs.date_end;
			l_counter:=l_counter+1;
		END IF;
		l_prev_start_date:=c_abs.date_start;
	END LOOP;
	l_group_start_date:=l_prev_start_date;
	l_start_date(l_counter):=l_group_start_date;
	l_end_date(l_counter):=l_group_end_date;
	l_gp_char(l_counter):='Y';
	/* Fix for bug 5985088 */
       	IF l_group_end_date>=p_abs_start_date THEN
	    if l_counter >=1 then
		p_group_start_date1:=l_start_date(1);
		   p_group_end_date1:=l_end_date(1);
		p_group_option1:=l_gp_char(1);

	    end if;
	    if l_counter>=2 then
		p_group_start_date2:=l_start_date(2);
		    p_group_end_date2:=l_end_date(2);
		p_group_option2:=l_gp_char(2);
		end if;
		if l_counter>=3 then
		    p_group_start_date3:=l_start_date(3);
		    p_group_end_date3:=l_end_date(3);
		    p_group_option3:=l_gp_char(3);
	    end if;
	    if l_counter>=4 then
		    p_group_start_date4:=l_start_date(4);
		    p_group_end_date4:=l_end_date(4);
		    p_group_option4:=l_gp_char(4);
	    end if;
	    if l_counter>=5 then
		   p_group_start_date5:=l_start_date(5);
		   p_group_end_date5:=l_end_date(5);
		   p_group_option5:=l_gp_char(5);
		end if;
		IF l_counter>=6 then
		   p_group_start_date6:=l_start_date(6);
		   p_group_end_date6:=l_end_date(6);
		   p_group_option6:=l_gp_char(6);
		end if;
		if l_counter>=7 then
		   p_group_start_date7:=l_start_date(7);
		   p_group_end_date7:=l_end_date(7);
		   p_group_option7:=l_gp_char(7);
	    end if;
	    if l_counter>=8 then
		   p_group_start_date8:=l_start_date(8);
		   p_group_end_date8:=l_end_date(8);
		   p_group_option8:=l_gp_char(8);
	    end if;
	    if l_counter>=9 then
		   p_group_start_date1:=l_start_date(9);
		   p_group_end_date1:=l_end_date(9);
		   p_group_option9:=l_gp_char(9);
	    end if;
	    if l_counter>=10 then
		   p_group_start_date1:=l_start_date(10);
		   p_group_end_date1:=l_end_date(10);
		   p_group_option10:=l_gp_char(10);
	    end if;
	END IF;
	RETURN 1;
    EXCEPTION
	WHEN OTHERS THEN
	RETURN 0;

END GET_GROUP;


FUNCTION GET_WAITING_HOURS(p_abs_hours IN VARCHAR2,
p_normal_hours IN VARCHAR2
)
RETURN NUMBER
IS
l_abs_hours number;
l_abs_mins number;
l_nor_hours number;
l_nor_mins number;
l_hours number;
l_mins number;
BEGIN

l_abs_hours:=substr(p_abs_hours,1,2);

l_abs_mins:=substr(p_abs_hours,4,2);
l_nor_hours:=substr(p_normal_hours,1,2);
l_nor_mins:=substr(p_normal_hours,4,2);

IF (l_abs_mins>l_nor_hours) THEN

	l_mins:=(60-l_abs_mins);
	l_hours:=(l_nor_hours-(l_abs_hours+1));
ELSE
	l_mins:=(l_nor_mins-l_abs_mins);
	l_hours:=(l_nor_hours-l_abs_hours);
END IF;

RETURN l_hours+(l_mins * .0167);
END GET_WAITING_HOURS;


FUNCTION CALCULATE_PAYMENT(
   p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
  ,p_assignment_action_id	 IN	    NUMBER
  ,p_pay_start_date		 IN	    DATE
  ,p_pay_end_date		 IN	    DATE
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_monthly_pay		 IN	    NUMBER
  ,p_hourly_rate		 IN	    OUT NOCOPY   NUMBER
  ,p_tot_waiting_day_hours	 OUT        NOCOPY NUMBER
  ,p_tot_waiting_day		 OUT	    NOCOPY NUMBER
  ,p_total_sickness_deduction    OUT	    NOCOPY NUMBER
  ,p_tot_sickness_ded_14_above   OUT	    NOCOPY NUMBER
  ,p_total_sick_pay		 OUT	    NOCOPY NUMBER
  ,p_total_sick_pay_14_above     OUT	    NOCOPY NUMBER
  ,p_tot_waiting_day_ded	 OUT	    NOCOPY NUMBER
  ,p_sickness_14_below_days      OUT        NOCOPY NUMBER
  ,p_sickness_above_14_days      OUT        NOCOPY NUMBER
  ,p_sickness_pay_hours_14_below OUT        NOCOPY NUMBER
  ,p_sickness_pay_hours_above_14 OUT        NOCOPY  NUMBER
  ,p_sex			 OUT	    NOCOPY VARCHAR2
  ,p_tot_sick_pay_days		 OUT	    NOCOPY NUMBER
  ,p_asg_hour_sal		 OUT        NOCOPY VARCHAR2
  ,p_waiting_date		 OUT	    NOCOPY DATE
  ,p_salary_rate		 IN OUT	    NOCOPY   NUMBER
  ,p_fourteenth_date		 OUT	    NOCOPY DATE
  ,p_full_days			 OUT	    NOCOPY NUMBER
  ,p_override_monthly_basic	 OUT	    NOCOPY NUMBER
  ,p_override_monthly_basic_day  OUT	    NOCOPY NUMBER
  ,p_exceeds_14_days		 OUT	    NOCOPY VARCHAR2
  ,p_sickness_after_14_days_month OUT	    NOCOPY NUMBER
  ,p_group_calendar_days          OUT       NOCOPY NUMBER
  ,p_group_working_days           OUT       NOCOPY NUMBER
  ,p_group_working_hours          OUT       NOCOPY NUMBER


  )
RETURN NUMBER IS

CURSOR csr_absence(l_person_id Number) is
	/*SELECT paa.absence_attendance_id
        ,paa.date_start
        ,nvl(paa.date_end,p_abs_end_date) date_end
        ,paa.time_start
        ,paa.time_end
        ,DECODE(paa.date_start, paa.date_end, 1, (paa.date_end-paa.date_start)+1) AS days_diff
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = l_person_id
        AND paa.date_start >=p_abs_start_date
	AND nvl(paa.date_end,p_abs_end_date)<=p_abs_end_date
        AND paa.date_start IS NOT NULL /*AND paa.date_end IS NOT NULL*/
        /*AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
        ORDER BY paa.date_end  ;*/

	SELECT paa.absence_attendance_id
        ,paa.date_start
        --,nvl(paa.date_end,'31-jan-2000') date_end
        ,least(nvl(paa.date_end,p_abs_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=l_person_id),p_abs_end_date)) date_end
        ,paa.time_start
        ,paa.time_end
        ,DECODE(paa.date_start,least(nvl(paa.date_end,p_abs_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=l_person_id),p_abs_end_date)), 1,
	(least(nvl(paa.date_end,p_abs_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=l_person_id),p_abs_end_date))-paa.date_start)+1) AS days_diff
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = l_person_id
        AND paa.date_start >=p_abs_start_date
	AND paa.date_start<=p_abs_end_date
	AND least(nvl(paa.date_end,p_abs_end_date),p_abs_end_date)<=p_abs_end_date
        /*AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL*/
        AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
	/* Fix for bug 5383707 */
	AND paa.absence_attendance_id IN(
--        ORDER BY paa.date_end  ;


   SELECT eev1.screen_entry_value  screen_entry_value
    FROM   per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
    WHERE  asg1.assignment_id    = p_assignment_id --34040 --l_asg_id
      AND  p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
      AND  p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
      AND  per.person_id         = asg1.person_id
      AND  asg2.person_id        = per.person_id
      --AND  asg2.primary_flag     = 'Y'
      AND asg1.assignment_id=asg2.assignment_id
      AND  et.element_name       = 'Sickness Details'
      AND  et.legislation_code   = 'SE'
      --OR et.business_group_id=3261      ) --checking for the business group, it should be removed
      AND  iv1.element_type_id   = et.element_type_id
      AND  iv1.name              = 'CREATOR_ID'
      AND  el.business_group_id  = per.business_group_id
      AND  el.element_type_id    = et.element_type_id
      AND  ee.assignment_id      = asg2.assignment_id
      AND  ee.element_link_id    = el.element_link_id
      AND  eev1.element_entry_id = ee.element_entry_id
      AND  eev1.input_value_id   = iv1.input_value_id
      /*AND  ee.effective_start_date  >= p_abs_start_date
      AND  ee.effective_end_date <= p_abs_end_date
      AND  eev1.effective_start_date >= p_abs_start_date
      AND  eev1.effective_end_date <= p_abs_end_date*/
      ) ORDER BY paa.date_end /*desc*/ ;  /*Bug Fix 5649509*/
        --ORDER BY paa.date_end  ;

CURSOR csr_check_override (l_asg_id number, l_eff_dt date, l_inp_val_name varchar2, l_start_dt date, l_end_dt date) IS
    SELECT eev1.screen_entry_value  screen_entry_value
    FROM   per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
    WHERE  asg1.assignment_id    = l_asg_id
      AND l_eff_dt BETWEEN asg1.effective_start_date AND asg1.effective_end_date
      AND l_eff_dt BETWEEN asg2.effective_start_date AND asg2.effective_end_date
      AND  per.person_id         = asg1.person_id
      AND  asg2.person_id        = per.person_id
      AND  asg2.primary_flag     = 'Y'
      AND  et.element_name       = 'Sickness Details'
      AND  et.legislation_code   = 'SE'
      --OR et.business_group_id=3261      ) --checking for the business group, it should be removed
      AND  iv1.element_type_id   = et.element_type_id
      AND  iv1.name              = l_inp_val_name
      AND  el.business_group_id  = per.business_group_id
      AND  el.element_type_id    = et.element_type_id
      AND  ee.assignment_id      = asg2.assignment_id
      AND  ee.element_link_id    = el.element_link_id
      AND  eev1.element_entry_id = ee.element_entry_id
      AND  eev1.input_value_id   = iv1.input_value_id
      AND  ee.effective_start_date  = l_start_dt
      AND  ee.effective_end_date = l_end_dt
      AND  eev1.effective_start_date = l_start_dt
      AND  eev1.effective_end_date = l_end_dt ;

Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
	IS
        SELECT      ue.creator_id
        FROM     ff_user_entities  ue,
        ff_database_items di
        WHERE     di.user_name = csr_v_Balance_Name
        AND     ue.user_entity_id = di.user_entity_id
        AND     ue.legislation_code = 'SE'
        AND     ue.business_group_id is NULL
        AND     ue.creator_type = 'B';

CURSOR csr_group_start_end_date
	( p_assignment_id NUMBER,
	p_element_type_id NUMBER,
	p_start_date_iv NUMBER,
	p_waiting_day_iv NUMBER,
	p_start_date DATE,
	p_end_date DATE
	) IS
  /*         (p_element_name varchar2,
            p_input_name varchar2,
            p_group_start_date DATE,
            p_group_end_date DATE,
            p_assignment_id NUMBER) IS

	    SELECT SUM(RESULT_VALUE)--prrv1.* ,paa.assignment_id
/*         prrv2.result_value fourteenth_date,
         prrv3.result_value end_date*/
  /*FROM   pay_assignment_actions paa,
         pay_payroll_actions ppa,
         pay_run_results prr,
         pay_run_result_values prrv1,
         pay_input_values_f pivf,
         pay_element_types_f petf
/*         pay_run_result_values prrv2,
         pay_run_result_values prrv3*/
  /*WHERE  ppa.effective_date BETWEEN p_group_start_date --'01-jun-1999' --p_report_start_date
   /* AND  p_group_end_date /*'01-jun-2000' */--p_report_end_date
   /* AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.assignment_id =p_assignment_id --21035 --p_assignment_id
    AND  paa.assignment_action_id = prr.assignment_action_id
    AND  prr.element_type_id = petf.element_type_id  --62358 -- p_element_type_id
    AND  petf.element_name=p_element_name	--'Sick Pay 1 to 14 days'
    AND  petf.element_type_id=pivf.element_type_id
    AND  pivf.element_type_id=prr.element_type_id
    AND  prr.run_result_id = prrv1.run_result_id
    AND  prrv1.input_value_id =pivf.input_value_id --139722 --p_input_value_id;
    AND  pivf.NAME=p_input_name; --'Waiting Day'*/

    SELECT SUM(prrv2.RESULT_VALUE) /*fnd_date.canonical_to_date(prrv1.RESULT_VALUE),prrv2.RESULT_VALUE,
ADD_MONTHS('15-nov-2000',-12), '15-nov-2000' --*, prrv1.result_value*/
  FROM   pay_assignment_actions paa,
         pay_payroll_actions ppa,
         pay_run_results prr,
         pay_run_result_values prrv1,
         pay_run_result_values prrv2--,
       --  pay_run_result_values prrv3
  WHERE  ppa.effective_date BETWEEN p_start_date --ADD_MONTHS('15-nov-2000',-12)
    AND  p_end_date --'15-nov-2000'
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.assignment_id = p_assignment_id --22145 -- p_assignment_id
    AND  paa.assignment_action_id = prr.assignment_action_id
    AND  prr.element_type_id = p_element_type_id--62358 --p_element_type_id
    AND  prr.run_result_id = prrv1.run_result_id
    AND  prrv1.input_value_id = p_start_date_iv --139718 --p_start_date_iv
    AND  prr.run_result_id = prrv2.run_result_id
    AND  prrv2.input_value_id = p_waiting_day_iv  --139722 --p_full_day_iv
    AND  fnd_date.canonical_to_date(prrv1.result_value) BETWEEN p_start_date --ADD_MONTHS('15-nov-2000',-12)
    AND  p_end_date ; --'15-nov-2000'


CURSOR csr_element(p_element_name VARCHAR2)
    IS
    SELECT element_type_id FROM
    pay_element_types_f
    WHERE element_name=p_element_name
    AND legislation_code='SE';

CURSOR csr_input(p_element_type_id number,p_input_value varchar2)
    IS
    SELECT input_value_id FROM
    pay_input_values_f
    WHERE name=p_input_value
    AND element_type_id=p_element_type_id;

CURSOR csr_run_result_value(csr_v_assignment_id NUMBER,
csr_v_element_type_id NUMBER,
csr_v_input_type_id1 NUMBER,
--csr_v_input_type_id2 NUMBER,
csr_v_start_date DATE,
csr_v_end_date DATE)
IS
SELECT nvl(SUM(prrv1.RESULT_VALUE),0)
FROM   pay_assignment_actions paa,
pay_payroll_actions ppa,
pay_run_results prr,
pay_run_result_values prrv1--,
--pay_run_result_values prrv2
WHERE  ppa.effective_date BETWEEN csr_v_start_date --ADD_MONTHS('15-nov-2000',-12)
AND  csr_v_end_date --'15-nov-2000'
AND  ppa.payroll_action_id = paa.payroll_action_id
AND  paa.assignment_id = csr_v_assignment_id --22145 -- p_assignment_id
AND  paa.assignment_action_id = prr.assignment_action_id
AND  prr.element_type_id = csr_v_element_type_id--62358 --p_element_type_id
AND  prr.run_result_id = prrv1.run_result_id
AND  prrv1.input_value_id = csr_v_input_type_id1; --139718 --p_start_date_iv
/*AND  prr.run_result_id = prrv2.run_result_id
AND  prrv2.input_value_id = csr_v_input_type_id2; --139718 --p_start_date_iv*/

CURSOR csr_global_value(csr_v_global_name VARCHAR2,csr_v_effective_date DATE )
IS
SELECT nvl(global_value,0) FROM ff_globals_f WHERE --ROWNUM<3
legislation_code='SE'
AND GLOBAL_NAME=csr_v_global_name --'SE_BASIC_AMOUNT'
AND csr_v_effective_date /*'28-feb-2007'*/ BETWEEN effective_start_date
AND effective_end_date;

CURSOR csr_absence_period(csr_v_assignment_id NUMBER,
csr_v_start_date DATE, csr_v_end_date DATE )
IS
   SELECT greatest(fnd_date.canonical_to_date(peevf1.SCREEN_ENTRY_VALUE),csr_v_start_date) date_start,
   least(fnd_date.canonical_to_date(peevf2.SCREEN_ENTRY_VALUE),csr_v_end_date) date_end
    FROM   per_all_assignments_f      paaf
	  ,pay_element_types_f	      et
	  ,pay_element_entries_f      ee
	  ,pay_element_entry_values_f peevf1
	  ,pay_element_entry_values_f peevf2
	  ,pay_input_values_f pivf1
	  ,pay_input_values_f pivf2
    WHERE  paaf.assignment_id	 = csr_v_assignment_id --38399 --p_assignment_id
      AND csr_v_end_date /*p_effective_date*/ BETWEEN paaf.effective_start_date AND paaf.effective_end_date
      AND  et.element_name	 = 'Sickness Details'
      AND  et.legislation_code	 = 'SE'
      AND  ee.assignment_id	 = paaf.assignment_id
      AND  ee.ELEMENT_TYPE_ID = et.ELEMENT_TYPE_ID
      AND  ee.effective_start_date <= csr_v_end_date--p_payroll_start_date
      AND  ee.effective_end_date >= csr_v_start_date--p_payroll_end_date
      and  ee.ELEMENT_ENTRY_ID =peevf1.ELEMENT_ENTRY_ID
      AND  pivf1.element_type_id	 = et.element_type_id
      AND  pivf1.name		 = 'Start Date'
      AND  peevf1.input_value_id	 = pivf1.input_value_id
--      AND  peevf1.SCREEN_ENTRY_VALUE='V'
      and  ee.ELEMENT_ENTRY_ID =peevf2.ELEMENT_ENTRY_ID
      AND  pivf2.element_type_id	 = et.element_type_id
      AND  pivf2.name		 = 'End Date'
      AND  peevf2.input_value_id	 = pivf2.input_value_id
      AND csr_v_end_date /*p_payroll_start_date*/ BETWEEN et.effective_start_date AND et.effective_end_date
      AND csr_v_end_date /*p_payroll_end_date*/ BETWEEN et.effective_start_date AND et.effective_end_date;

l_person_id number;
l_business_group_id number;
l_asg_hour_sal varchar2(10);
l_prev_start_date DATE :=NULL;
l_prev_end_date DATE:=NULL;
l_p_end_date DATE:=NULL;
l_prev_duration number:=0;
l_working_percentage NUMBER;
l_normal_start_date DATE;
l_normal_end_date DATE;
l_sickness_days NUMBER:=0;
l_total_sickness_days NUMBER:=0;
l_sickness_pay_days NUMBER:=0;
l_wrk_schd_return NUMBER;
l_start_time_char Varchar2(10) := '0';
l_end_time_char Varchar2(10) := '23.59';
l_duration NUMBER;
l_wrk_duration NUMBER;
l_include_event CHAR :='Y';
l_date_start DATE;
l_date_end DATE;
l_waiting_day NUMBER :=0;
l_employee_category varchar2(10);
l_normal_hours NUMBER;
l_sickness_deduction NUMBER :=0;
l_sick_pay NUMBER :=0;
l_waiting_day_deduction NUMBER :=0;
l_total_sickness_deduction NUMBER :=0;
l_total_sick_pay NUMBER :=0;
l_total_waiting_day_deduction NUMBER :=0;
l_normal_time_start varchar2(10);
l_normal_time_end varchar2(10);
l_time_start char(5);
l_prev_time_start char(5);
l_prev_time_end char(5);
l_prev_sicknness_days number;
l_time_end char(5);
l_return number;
l_waiting_date date;
l_waiting_day_hours number;
l_total_waiting_day NUMBER:=0;
l_total_waiting_day_hours number:=0;
l_loop_entered number:=0;
l_override_sickness_pay_hours NUMBER:=-1;
l_override_sickness_days NUMBER:=-1;
l_override_waiting_hours NUMBER:=-1;
l_sickness_deduction_14_above NUMBER:=0;
l_sickness_deduction_14_less NUMBER:=0;
l_sick_pay_14_above NUMBER:=0;
l_sick_pay_14_less NUMBER:=0;
l_tot_waiting_day_hours NUMBER:=0;
l_total_sickness_ded_14_above NUMBER:=0;
l_total_sick_pay_14_above NUMBER:=0;
l_prev_sickness_days NUMBER:=0;
l_curr_sickness_days NUMBER:=0;
l_sickness_14_below_days NUMBER:=0;
l_sick_pay_days_14_below_days NUMBER:=0;
l_sickness_above_14_days NUMBER :=0;
l_sickness_pay_hours_14_below NUMBER:=0;
l_sickness_pay_hours_above_14 NUMBER:=0;
l_sickness_pay_hours NUMBER:=0;
l_waiting_day_ded NUMBER:=0;
l_fourteenth_date DATE;
l_fourteenth_difference NUMBER;
l_sickness_last_date DATE;
l_group_start_date DATE;
lr_Get_Defined_Balance_Id NUMBER(10);
l_value NUMBER(10);
l_total_waiting_days NUMBER(10);
l_start_date_iv NUMBER;
l_waiting_day_iv NUMBER;
l_element_type_id NUMBER;
l_input_type_id NUMBER;
--l_input_type_id2 NUMBER;
l_days Char(1):='D';
l_hours Char(1):='H';
l_global_value NUMBER;
l_sick_after_14_year_limit NUMBER;
l_sick_after_14_year_taken NUMBER;
l_total_sick_after_14 NUMBER;
l_absence_period NUMBER:=0;
BEGIN

	BEGIN
		SELECT papf.person_id
                ,papf.business_group_id
                ,hourly_salaried_code
		,segment9
		,employee_category
		,normal_hours
		,time_normal_start
		,time_normal_finish
		,sex
		INTO l_person_id
                ,l_business_group_id
                ,l_asg_hour_sal
		,l_working_percentage
		,l_employee_category
		,l_normal_hours
		,l_normal_time_start
		,l_normal_time_end
		,p_sex
		FROM per_all_assignments_f paaf,
		per_all_people_f papf,
		hr_soft_coding_keyflex hsck
		WHERE paaf.assignment_id = p_assignment_id
		AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
		AND papf.person_id=paaf.person_id
                AND p_effective_date BETWEEN paaf.effective_start_date
                AND paaf.effective_end_date
		AND p_effective_date BETWEEN papf.effective_start_date
                AND papf.effective_end_date;
		p_asg_hour_sal:=l_asg_hour_sal;

        EXCEPTION
		WHEN OTHERS THEN
		l_person_id := null;
                l_business_group_id := null;
                l_asg_hour_sal := null;
        END;

	IF l_asg_hour_sal='S' THEN

	FOR c_abs IN csr_absence(l_person_id) LOOP

		--if the period falls in previous payroll period
		IF c_abs.date_end<p_pay_start_date THEN
			--first entry need to check for waiting day
			IF l_loop_entered=0 THEN
				l_waiting_date:=GET_WAITING_DAY(p_assignment_id,c_abs.date_start,c_abs.date_end);
				l_group_start_date:=l_waiting_date;
				--Sickness day calculation
				l_duration:=c_abs.date_end-l_waiting_date+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<14 THEN
					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>=14) THEN
					--l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=l_waiting_date+13;


					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;
				--sickness days greater than 14 days
				ELSE
					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;
				END IF;
				l_waiting_day_hours:=0;
			ELSE

				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN
					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN
					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start + l_fourteenth_difference;


					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE
					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

				END IF;
			END IF;
			/*l_sickness_days:=l_sickness_days+(cbs.date_end-l_waiting_date);
			l_waiting_day_hours:=0; */
		--if the absence start date falls in previous payroll period
		--and absence end date fall is current payroll period
		ELSIF c_abs.date_start<p_pay_start_date AND c_abs.date_end<p_pay_end_date THEN

			--first entry need to check for waiting day
			IF l_loop_entered=0 THEN

				l_waiting_date:=GET_WAITING_DAY(p_assignment_id,c_abs.date_start,c_abs.date_end);
				l_group_start_date:=l_waiting_date;
				--Sickness days calculation
				--l_duration:=c_abs.date_end-l_waiting_date;
				l_duration:=least(c_abs.date_end,p_abs_end_date) -l_waiting_date+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,l_waiting_date+1), c_abs.date_end, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							greatest(p_pay_start_date,l_waiting_date+1), c_abs.date_end, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>=14) THEN

					--l_fourteenth_difference:=14-l_sickness_14_below_days;
					--l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_fourteenth_date:=l_waiting_date+13;

					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								greatest(p_pay_start_date,l_waiting_date+1), (c_abs.date_start + 14-(l_sickness_days)+1),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);

							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						END IF;
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								greatest(p_pay_start_date,l_waiting_date+1), (c_abs.date_start + 14-(l_sickness_days)+1),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						--sickness pay hours calculation

						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest((c_abs.date_start + 14-l_sickness_days+1),p_pay_start_date) ,
							c_abs.date_end,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;
				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,l_waiting_date+1), c_abs.date_start,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
				IF l_waiting_date>=p_pay_start_date THEN
				    --Checking Override input value for waiting day
				    OPEN csr_check_override (p_assignment_id,p_effective_date,'Override Waiting Day in Hours',c_abs.date_start, c_abs.date_end);
					   FETCH csr_check_override INTO l_override_waiting_hours;
				    CLOSE csr_check_override;

				    IF l_override_waiting_hours =-1 OR l_override_waiting_hours IS NULL THEN
					IF (l_waiting_date<>c_abs.date_end) THEN
					   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
						  ( p_assignment_id, l_hours, l_include_event,
						  l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
						  nvl(l_normal_time_start,l_start_time_char)),':','.'),
						  replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
						  );
					ELSE
					   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
						  ( p_assignment_id, l_hours, l_include_event,
						  l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
						  nvl(l_normal_time_start,l_start_time_char)),':','.'),
						  replace(nvl(c_abs.time_end,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
						  );
					END IF;
					   l_waiting_day_hours:=l_wrk_duration;

				    ELSE

					   l_waiting_day_hours:=l_override_waiting_hours;
					   l_override_waiting_hours:=-1;
				    END IF;
                ELSE
                    l_waiting_day_hours:=0;
                END IF;

			ELSE
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,c_abs.date_start), c_abs.date_end, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							greatest(p_pay_start_date,c_abs.date_start), c_abs.date_end, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;

				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								greatest(p_pay_start_date,c_abs.date_start), (c_abs.date_start + 14-(l_sickness_days+1)),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_duration;
						END IF;
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								greatest(p_pay_start_date,c_abs.date_start), (c_abs.date_start + 14-(l_sickness_days+1)),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						--sickness pay hours calculation

						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest((c_abs.date_start + 14-l_sickness_days+1),p_pay_start_date) ,
							c_abs.date_end,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;
				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,c_abs.date_start), c_abs.date_start,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
			END IF;
		--if the absence start date falls in previous period and absence end date falls in
		--next payroll period
		ELSIF c_abs.date_start<p_pay_start_date AND c_abs.date_end>p_pay_end_date THEN

			--first entry need to check for waiting day
			IF l_loop_entered=0 THEN

				l_waiting_date:=GET_WAITING_DAY(p_assignment_id,c_abs.date_start,c_abs.date_end);
				l_group_start_date:=l_waiting_date;
				--Sickness days calculation
				l_duration:=c_abs.date_end-l_waiting_date+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,l_waiting_date+1), p_pay_end_date, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							greatest(p_pay_start_date,l_waiting_date+1), p_pay_end_date, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>=14) THEN

					--l_fourteenth_difference:=14-l_sickness_14_below_days;
					--l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_fourteenth_date:=l_waiting_date+13;

					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);
					--l_sickness_14_below_days:=14;
					--l_sickness_above_14_days:=(l_duration-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 or l_override_sickness_pay_hours is null THEN
						--check whether the end period for 14 days fall within payroll period
						IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								greatest(p_pay_start_date,l_waiting_date+1), (c_abs.date_start + 14-(l_sickness_days+1+(c_abs.date_end-p_pay_end_date))),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);

							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						END IF;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								greatest(p_pay_start_date,l_waiting_date+1), (c_abs.date_start + 14-(l_sickness_days+1+(c_abs.date_end-p_pay_end_date))),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL  THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest((l_waiting_date + 14-(l_sickness_days)),p_pay_start_date) ,
							p_pay_end_date,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,l_waiting_date+1), p_pay_end_date,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
				IF l_waiting_date>=p_pay_start_date THEN
				    --Checking Override input value for waiting day
				    OPEN csr_check_override (p_assignment_id,p_effective_date,'Override Waiting Day in Hours',c_abs.date_start, c_abs.date_end);
					   FETCH csr_check_override INTO l_override_waiting_hours;
				    CLOSE csr_check_override;

				    IF l_override_waiting_hours =-1 OR l_override_waiting_hours IS NULL THEN
					IF (l_waiting_date<>c_abs.date_end) THEN
					   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
						  ( p_assignment_id, l_hours, l_include_event,
						  l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
						  nvl(l_normal_time_start,l_start_time_char)),':','.'),
						  replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_duration
						  );
					ELSE
					   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
						  ( p_assignment_id, l_hours, l_include_event,
						  l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
						  nvl(l_normal_time_start,l_start_time_char)),':','.'),
						  replace(nvl(c_abs.time_end,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
						  );
					END IF;
					   l_waiting_day_hours:=l_wrk_duration;

				    ELSE

					   l_waiting_day_hours:=l_override_waiting_hours;
					   l_override_waiting_hours:=-1;
				    END IF;
                ELSE
                    l_waiting_day_hours:=0;
                END IF;

			ELSE
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,c_abs.date_start), p_pay_end_date, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							greatest(p_pay_start_date,c_abs.date_start), p_pay_end_date, replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						--check whether the end period for 14 days fall within payroll period
						IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								greatest(p_pay_start_date,c_abs.date_start), (c_abs.date_start + 14-(l_sickness_days+1)),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);

							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						END IF;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								greatest(p_pay_start_date,c_abs.date_start), (c_abs.date_start + 14-(l_sickness_days+1)),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest((c_abs.date_start + 14-l_sickness_days+1),p_pay_start_date) ,
							p_pay_end_date,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest(p_pay_start_date,c_abs.date_start), p_pay_end_date,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
			END IF;
		--if absence start date falls in the current payroll period and the absence end date
		--falls in next payroll period
		ELSIF c_abs.date_start > p_pay_start_date AND c_abs.date_end > p_pay_end_date THEN

			--first entry need to check for waiting day

			IF l_loop_entered=0 THEN

				l_waiting_date:=GET_WAITING_DAY(p_assignment_id,c_abs.date_start,c_abs.date_end);
				l_group_start_date:=l_waiting_date;
				--Sickness days calculation
				--l_duration:=c_abs.date_end-l_waiting_date;
				l_duration:=least(c_abs.date_end,p_pay_end_date)-l_waiting_date+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						IF l_waiting_date<p_pay_end_date THEN
							--sickness pay hours calculation

							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(l_waiting_date+1),p_pay_end_date, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(l_normal_time_end,
								l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						END IF;
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								(l_waiting_date+1),p_pay_end_date, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(l_normal_time_end,
								l_end_time_char),':','.'), l_wrk_duration
								);

					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>=14) THEN

					--l_fourteenth_difference:=14-l_sickness_14_below_days;
					--l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_fourteenth_date:=l_waiting_date+13;

					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						/*IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date then*/
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								l_waiting_date+1, least((l_waiting_date + 14-(l_sickness_days+1)),p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						/*END IF;*/
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								l_waiting_date+1, least((l_waiting_date + 14-(l_sickness_days+1)),p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						IF (l_waiting_date + 14-l_sickness_days+1)<=p_pay_end_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(l_waiting_date + 14-l_sickness_days+1),
								p_pay_end_date,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

							END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;

						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						IF l_waiting_date < p_pay_end_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								least(p_pay_start_date,l_waiting_date+1), p_pay_end_date,
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
				--Checking Override input value for waiting day
				OPEN csr_check_override (p_assignment_id,p_effective_date,'Override Waiting Day in Hours',c_abs.date_start, c_abs.date_end);
					FETCH csr_check_override INTO l_override_waiting_hours;
				CLOSE csr_check_override;

				IF (l_override_waiting_hours =-1 OR l_override_waiting_hours IS NULL ) AND (l_waiting_date<=p_pay_end_date) THEN

					if (l_waiting_date<>c_abs.date_end) then
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
							nvl(l_normal_time_start,l_start_time_char)),':','.'),
							replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
							);
					ELSE
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							  l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
							  nvl(l_normal_time_start,l_start_time_char)),':','.'),
							  replace(nvl(c_abs.time_end,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
							  );
					END IF;
					l_waiting_day_hours:=l_wrk_duration;

				ELSE
					l_waiting_day_hours:=l_override_waiting_hours;
					l_override_waiting_hours:=-1;
				END IF;

			ELSE
			l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						IF l_waiting_date<p_pay_end_date THEN
							--sickness pay hours calculation

							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(c_abs.date_start),p_pay_end_date, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(l_normal_time_end,
								l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						END IF;
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								(c_abs.date_start),p_pay_end_date, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(l_normal_time_end,
								l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						/*IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date then*/
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								c_abs.date_start, least((c_abs.date_start + 14-(l_sickness_days+1)),p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						/*END IF;*/
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								c_abs.date_start, least((c_abs.date_start + 14-(l_sickness_days+1)),p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						IF (l_waiting_date + 14-l_sickness_days+1)<=p_pay_end_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(c_abs.date_start + 14-l_sickness_days+1),
								p_pay_end_date,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


							END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						IF l_waiting_date < p_pay_end_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								least(p_pay_start_date,c_abs.date_start), p_pay_end_date,
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;


						END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
			END IF;
		--if the absence falls within the payroll period
	   	ELSE

			--first entry need to check for waiting day
			IF l_loop_entered=0 THEN

				l_waiting_date:=GET_WAITING_DAY(p_assignment_id,c_abs.date_start,c_abs.date_end);
				l_group_start_date:=l_waiting_date;
				--Sickness days calculation
				l_duration:=c_abs.date_end-l_waiting_date+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						/*IF l_waiting_day<p_pay_end_date THEN */
							--sickness pay hours calculation

							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(l_waiting_date+1),c_abs.date_end, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
								l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						/*END IF;*/
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								(l_waiting_date+1),c_abs.date_end, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
								l_end_time_char)),':','.'), l_wrk_duration
								);
 				        l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>=14) THEN

					--l_fourteenth_difference:=14-l_sickness_14_below_days;
					--l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_fourteenth_date:=l_waiting_date+13;

					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						/*IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date then*/
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								l_waiting_date+1, least(l_fourteenth_date/*(l_waiting_date + 14-(l_sickness_days+1))*/,p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						/*END IF;*/
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
				       /* Calculating the Sick Pay days less than 14 days*/
				       l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								l_waiting_date+1, least(l_fourteenth_date/*(l_waiting_date + 14-(l_sickness_days+1))*/,p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
				       l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						/*IF (l_waiting_day + 14-l_sickness_days+1)<=p_pay_end_date THEN */
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(l_fourteenth_date+1/*l_waiting_date + 14-l_sickness_days+1*/),
								c_abs.date_end,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						/*END IF;*/
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;
				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;


					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						IF l_waiting_date < p_pay_end_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(l_waiting_date+1), c_abs.date_end,
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;
				--Checking Override input value for waiting day
				OPEN csr_check_override (p_assignment_id,p_effective_date,'Override Waiting Day in Hours',c_abs.date_start, c_abs.date_end);
					FETCH csr_check_override INTO l_override_waiting_hours;
				CLOSE csr_check_override;

				IF (l_override_waiting_hours =-1 OR l_override_waiting_hours IS NULL) AND (l_waiting_date<=p_pay_end_date) THEN
					IF (l_waiting_date<>c_abs.date_end) THEN
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
							nvl(l_normal_time_start,l_start_time_char)),':','.'),
							replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
							);
					ELSE

					   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
						( p_assignment_id, l_hours, l_include_event,
						l_waiting_date, l_waiting_date, replace(nvl(c_abs.time_start,
						nvl(l_normal_time_start,l_start_time_char)),':','.'),
						replace(nvl(c_abs.time_end,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
						);
					END IF;

					l_waiting_day_hours:=l_wrk_duration;

				ELSE

					l_waiting_day_hours:=l_override_waiting_hours;
					l_override_waiting_hours:=-1;
				END IF;

			ELSE
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;
				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						/*IF l_waiting_day<p_pay_end_date THEN */
							--sickness pay hours calculation

							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(c_abs.date_start),c_abs.date_end, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
								l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						/*END IF;*/
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								(c_abs.date_start),c_abs.date_end, replace(nvl(l_normal_time_start,
								l_start_time_char),':','.'),replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
								l_end_time_char)),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						/*IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date then*/
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								c_abs.date_start, least(l_fourteenth_date/*(c_abs.date_start + 14-(l_sickness_days+2))*/,p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;

						/*END IF;*/
					ELSE

						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								c_abs.date_start, least(l_fourteenth_date/*(c_abs.date_start + 14-(l_sickness_days+2))*/,p_pay_end_date),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						/*IF (l_waiting_day + 14-l_sickness_days+1)<=p_pay_end_date THEN */
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(l_fourteenth_date/*c_abs.date_start + 14-l_sickness_days+2*/),
								c_abs.date_end,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						/*END IF;*/
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;
				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						IF l_waiting_date < p_pay_end_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								(c_abs.date_start), c_abs.date_end,
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
								nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

			    END IF;
			END IF;
		END IF;
   		l_loop_entered:=1;
	END LOOP;
	ELSE
		FOR c_abs IN csr_absence(l_person_id) LOOP
			IF l_loop_entered=0 THEN
			     l_group_start_date:=c_abs.date_start;
			END IF;
			--if the absence ends before the payroll start date
			IF c_abs.date_end <p_pay_start_date THEN

				--Sickness day calculation
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;

				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration+1)-14);
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE
					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;
				END IF;

			--if the absence start date falls in previous payroll period
			--and absence end date fall is current payroll period
			ELSIF c_abs.date_start<p_pay_start_date AND c_abs.date_end<p_pay_end_date THEN

				--Sickness days calculation
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;

				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN
						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							p_pay_start_date, c_abs.date_end, l_start_time_char,
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							p_pay_start_date, c_abs.date_end, l_start_time_char,
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end,
							l_end_time_char)),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration+1)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								p_pay_start_date, (c_abs.date_start + 14-l_sickness_days),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						END IF;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								p_pay_start_date, (c_abs.date_start + 14-l_sickness_days),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest((c_abs.date_start + 14-l_sickness_days+1),p_pay_start_date) ,
							c_abs.date_end,replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							p_pay_start_date, c_abs.date_start,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'), replace(nvl(c_abs.time_end,
							nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;

			--if the absence start date falls in previous period and absence end date falls in
			--next payroll period
			ELSIF c_abs.date_start<p_pay_start_date AND c_abs.date_end>p_pay_end_date THEN

				--Sickness days calculation
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;

				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							p_pay_start_date, p_pay_end_date, replace(nvl(l_normal_time_end,
							l_start_time_char),':','.'),replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
							);
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							p_pay_start_date, p_pay_end_date, replace(nvl(l_normal_time_end,
							l_start_time_char),':','.'),replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration+1)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						IF (c_abs.date_start + 14-l_sickness_days) > p_pay_start_date THEN

							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								p_pay_start_date, (c_abs.date_start + 14-l_sickness_days),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						END IF;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								p_pay_start_date, (c_abs.date_start + 14-l_sickness_days),
								replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							greatest((c_abs.date_start + 14-l_sickness_days+1),p_pay_start_date) ,
							c_abs.date_end,replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(l_normal_time_end, l_end_time_char),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							p_pay_start_date, p_pay_end_date,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(l_normal_time_end, l_end_time_char),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;


			--if absence start date falls in current payroll period and the absence end date
			--falls in next payroll period
			ELSIF c_abs.date_start > p_pay_start_date AND c_abs.date_end > p_pay_end_date THEN

				--Sickness days calculation
				l_duration:=least(c_abs.date_end,p_pay_end_date)-c_abs.date_start+1;

				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							c_abs.date_start, p_pay_end_date, replace(nvl(l_normal_time_end,
							l_start_time_char),':','.'),replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
							);
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							c_abs.date_start, p_pay_end_date, replace(nvl(l_normal_time_end,
							l_start_time_char),':','.'),replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration+1)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						/*IF (c_abs.date_start + 14-l_sickness_days) < p_pay_end_date then*/
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								c_abs.date_start, least((c_abs.date_start + 14-l_sickness_days),
								p_pay_end_date),replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						/*END IF;*/
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								c_abs.date_start, least((c_abs.date_start + 14-l_sickness_days),
								p_pay_end_date),replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end,l_end_time_char),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						IF (c_abs.date_start + 14-l_sickness_days+1) < p_pay_end_date THEN
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								c_abs.date_start + 14-l_sickness_days+1 ,
								p_pay_end_date,replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
								replace(nvl(l_normal_time_end, l_end_time_char),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						END IF;
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							c_abs.date_start, p_pay_end_date,
							replace(nvl(l_normal_time_start,l_start_time_char),':','.'),
							replace(nvl(l_normal_time_end, l_end_time_char),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;


			--if the absence falls within the payroll period
		   	ELSE

				--Sickness days calculation
				l_duration:=c_abs.date_end-c_abs.date_start+1;

				--if the sickness days is less than 14 days then
				IF (l_sickness_days+l_duration)<=14 THEN

					l_sickness_14_below_days:=l_sickness_14_below_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					l_sickness_last_date:=c_abs.date_end;

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							c_abs.date_start, c_abs.date_end, replace(nvl(c_abs.time_start,nvl(l_normal_time_end,
							l_start_time_char)),':','.'),replace(nvl(c_abs.time_end,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
							);
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							c_abs.date_start, c_abs.date_end, replace(nvl(c_abs.time_start,nvl(l_normal_time_end,
							l_start_time_char)),':','.'),replace(nvl(c_abs.time_end,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
							);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
				--if the period falls across 14 days
				ELSIF (l_sickness_days<=14) AND (l_sickness_days+l_duration>14) THEN

					l_fourteenth_difference:=13-l_sickness_14_below_days;
					l_fourteenth_date:=c_abs.date_start+l_fourteenth_difference;
					l_sickness_14_below_days:=l_sickness_14_below_days+(14-l_sickness_days);
					l_sickness_above_14_days:=l_sickness_above_14_days+(l_sickness_days+(l_duration+1)-14);

					--Checking Override input value for Sick Pay Days 14 days and below in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override below 14 day in Hour',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_pay_hours;
					CLOSE csr_check_override;

					IF l_override_sickness_pay_hours = -1 OR l_override_sickness_pay_hours IS NULL THEN

						--check whether the end period for 14 days fall within payroll period
						/*IF (c_abs.date_start + 14-l_sickness_days) < p_pay_end_date then*/
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								c_abs.date_start, (c_abs.date_start + 14-l_sickness_days),
								replace(nvl(c_abs.time_start,nvl(l_normal_time_start,l_start_time_char)),':','.'),
								replace(nvl(c_abs.time_start,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below + l_wrk_duration;
						/*END IF;*/
					ELSE
						l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					/* Calculating the Sick Pay days less than 14 days*/
					l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_days, l_include_event,
								c_abs.date_start, (c_abs.date_start + 14-l_sickness_days),
								replace(nvl(c_abs.time_start,nvl(l_normal_time_start,l_start_time_char)),':','.'),
								replace(nvl(c_abs.time_start,nvl(l_normal_time_end,l_end_time_char)),':','.'), l_wrk_duration
								);
					l_sick_pay_days_14_below_days:=l_sick_pay_days_14_below_days+ l_wrk_duration;
					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN

						/*IF (c_abs.date_start + 14-l_sickness_days+1) < p_pay_end_date THEN */
							--sickness pay hours calculation
							l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
								( p_assignment_id, l_hours, l_include_event,
								c_abs.date_start + 14-l_sickness_days+1 ,c_abs.date_end,
								replace(nvl(c_abs.time_start,nvl(l_normal_time_start,l_start_time_char)),':','.'),
								replace(nvl(c_abs.time_end,nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
								);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

						/*END IF;*/
					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-(l_sickness_days+(l_duration+1)-14);
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;
					l_sickness_days:=l_sickness_days+l_sickness_14_below_days+l_sickness_above_14_days;

				--sickness days greater than 14 days
				ELSE

					l_sickness_above_14_days:=l_sickness_above_14_days+l_duration;
					l_sickness_days:=l_sickness_days+l_duration;

					--Checking Override input value for Sick Pay Days above 14 days in Hours
					OPEN csr_check_override (p_assignment_id,p_effective_date,'Override beyond 14 day in Day',c_abs.date_start, c_abs.date_end);
						FETCH csr_check_override INTO l_override_sickness_days;
					CLOSE csr_check_override;

					IF l_override_sickness_days = -1 OR l_override_sickness_days IS NULL THEN
						--sickness pay hours calculation
						l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							c_abs.date_start, c_abs.date_end,
							replace(nvl(c_abs.time_start,nvl(l_normal_time_start,l_start_time_char)),':','.'),
							replace(nvl(c_abs.time_end,nvl(l_normal_time_end, l_end_time_char)),':','.'), l_wrk_duration
							);
							l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_wrk_duration;

					ELSE
						l_sickness_above_14_days:=l_sickness_above_14_days-l_duration;
						l_sickness_above_14_days:=l_sickness_above_14_days+l_override_sickness_days;
						l_sickness_pay_hours_above_14:=l_sickness_pay_hours_above_14 + l_override_sickness_pay_hours;
						l_override_sickness_pay_hours:=-1;
					END IF;

				END IF;

			END IF;
		END LOOP;
	END IF;

    /* Logic to change the Sick Pay and Sickness Deduction, if the waiting day has crossed  for bug 5718434 */
     /* Get the value from the balance */
    /*If balance value is less than 10 then waiting day can be one */

    pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id/*189398*/);
    OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_WAITING_DAY_ASG_13MONTH');
	FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;

    CLOSE csr_Get_Defined_Balance_Id;
    l_value:=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
    P_ASSIGNMENT_ID => p_assignment_id, --22145,
    P_VIRTUAL_DATE=> p_pay_end_date/*TO_DATE('28-feb-2000')*/);

    /*If the balance value is greater than 10 then check from the run results,
    whether it has actually crossed 10 waiting days by run results*/
    IF l_value>=10 THEN

	OPEN csr_element('Sick Pay 1 to 14 days');
		FETCH csr_element INTO l_element_type_id;
	CLOSE  csr_element;

	OPEN csr_input(l_element_type_id,'Waiting Day');
		FETCH csr_input INTO l_waiting_day_iv;
	CLOSE csr_input;

	OPEN csr_input(l_element_type_id,'Start Date');
		FETCH csr_input INTO l_start_date_iv;
	CLOSE csr_input;

	OPEN csr_group_start_end_date(p_assignment_id,l_element_type_id,l_start_date_iv,l_waiting_day_iv,add_months(p_abs_start_date,-12),p_abs_start_date);
		FETCH  csr_group_start_end_date INTO l_total_waiting_days;
	CLOSE csr_group_start_end_date;

    --ELSE

    END IF;
    /*checking whether the total waiting days before one year is greater than 10 */
    IF l_total_waiting_days>=10 THEN
	/* checking whether the absence has crossed 10 days */
	IF  l_sickness_above_14_days >0 THEN
		/* Increasing the sickness days above 14 by one */
		--l_sickness_above_14_days:=l_sickness_above_14_days+1;
		/* check whether it is one day absence, only waiting day */
		IF l_sickness_pay_hours_14_below<>0  THEN
			l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_waiting_day_hours;
		END IF;
		l_waiting_day_hours:=0;
	ELSE
		/*absence has not crossed 10 days */
		/*Increasing the sick pay 1 to 14 day  hours by waiting day hours*/
		/* check whether it is one day absence, only waiting day */
		IF l_sickness_pay_hours_14_below<>0  THEN
			l_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below+l_waiting_day_hours;
		END IF;
		l_waiting_day_hours:=0;
	END IF;
    END IF;

    OPEN csr_element('Sick Pay after 14 days');
		FETCH csr_element INTO l_element_type_id;
    CLOSE  csr_element;
    OPEN csr_input(l_element_type_id,'Sick Days in Period');
		FETCH csr_input INTO l_input_type_id;
    CLOSE csr_input;

    /*OPEN csr_input(l_element_type_id,'Start Date');
		FETCH csr_input INTO l_input_type_id2;
    CLOSE csr_input;
    hr_utility.set_location('l_input_type_id2'||l_input_type_id2,10);*/
    OPEN csr_global_value('SE_SICK_PAY_AFTER_14_DAYS_YEAR_LIMIT',p_effective_date);
	FETCH csr_global_value INTO l_global_value;
    CLOSE csr_global_value;

    l_sick_after_14_year_limit:=l_global_value;

    /* Get the values from run results one year before the processing date */
    OPEN csr_run_result_value(p_assignment_id,l_element_type_id,l_input_type_id,add_months(p_effective_date,-12)+1,p_abs_start_date-1);
	FETCH csr_run_result_value INTO l_sick_after_14_year_taken;
    CLOSE csr_run_result_value;
/*    FOR csr_run IN csr_run_result_value(p_assignment_id,l_element_type_id,l_input_type_id1,l_input_type_id2,add_months(p_effective_date,-12)+1,p_abs_start_date-1) LOOP

    END LOOP;*/


    l_total_sick_after_14:=(l_sick_after_14_year_taken+l_sickness_above_14_days);

    IF l_total_sick_after_14 > l_sick_after_14_year_limit THEN
	--l_sickness_above_14_days:=l_total_sick_after_14-l_sick_after_14_year_limit;
	/* Bug 5985088 fix */
	FOR csr_abs in csr_absence_period(p_assignment_id,p_pay_start_date,p_abs_end_date) LOOP
		l_absence_period:=l_absence_period+(csr_abs.date_end-csr_abs.date_start +1);
	END LOOP;

	IF l_sick_after_14_year_taken>=l_sick_after_14_year_limit THEN
	       p_sickness_after_14_days_month:=0;
	ELSIF (l_total_sick_after_14-l_absence_period>= l_sick_after_14_year_limit) THEN
	         p_sickness_after_14_days_month:=0;
   	         l_sickness_above_14_days:=0;
	ELSE
 	   /*p_sickness_after_14_days_month:=(p_pay_end_date-p_pay_start_date+1)-(l_sickness_above_14_days-l_sick_after_14_year_limit);
  	   l_sickness_above_14_days:=l_sick_after_14_year_limit-l_sick_after_14_year_taken; */
	   /*Fix for bug No. 5985088 */
	   p_sickness_after_14_days_month:=(p_pay_end_date-p_pay_start_date+1)- (l_total_sick_after_14-l_sick_after_14_year_limit); --l_sick_after_14_year_taken; -- (l_sickness_above_14_days-l_sick_after_14_year_limit);
	   /*If there is no absence before the current absence within the year*/
 	   IF l_sick_after_14_year_taken <>0 then
        	   l_sickness_above_14_days:=l_sick_after_14_year_limit-(l_total_sick_after_14-l_sick_after_14_year_limit)+1; --l_sick_after_14_year_taken;
	   /*If there is absence before the current absence within the year*/
  	   ELSE
          	   l_sickness_above_14_days:=l_sick_after_14_year_limit; --l_sick_after_14_year_taken;
  	   END IF;

    end if;
	p_exceeds_14_days:='Y';
    END IF;
    /* Check whether Sickness above 14 days exist, because when sickness is less than
    14 days also we have fourteenth date */
    --IF l_sickness_above_14_days > 0 THEN
	    /* check whether the absence days has exceeded the limit*/
	    /*If exceeded then same as l_sickness_above_14_days */
	    IF p_exceeds_14_days IS NULL  THEN
		    IF l_fourteenth_date IS NULL THEN


			p_sickness_after_14_days_month:=GET_SICKNESS_AFTER_14_PERIOD(l_person_id,p_assignment_id,
			p_pay_start_date,p_pay_end_date,p_pay_end_date);

			--p_fourteenth_date:=l_sickness_last_date;
		    ELSE

			p_sickness_after_14_days_month:=GET_SICKNESS_AFTER_14_PERIOD(l_person_id,p_assignment_id,
			p_pay_start_date,p_pay_end_date,l_fourteenth_date);


		--	p_sickness_after_14_days_month:=GET_SICKNESS_AFTER_14_PERIOD(l_person_id,p_pay_start_date,
		--	p_pay_end_date,p_fourteenth_date);
		--	hr_utility.set_location('p_sickness_after_14_days_month'||p_sickness_after_14_days_month,10);
		    END IF;
		    /* Checking if l_sickness_above_14_days less than the days in period then
		    assign it to days in the period*/
	   /* ELSIF l_sickness_above_14_days <=(p_pay_start_date-P_pay_end_date) THEN
		p_sickness_after_14_days_month:=l_sickness_above_14_days;*/
	    END IF;
--    END IF;
    l_return:=GET_SICKPAY_DETAILS(p_assignment_id,p_abs_start_date,p_abs_end_date,l_sickness_14_below_days,
    /*l_sickness_above_14_days*/p_sickness_after_14_days_month,l_sickness_pay_hours_14_below,l_sickness_pay_hours_above_14,
    p_monthly_pay,l_asg_hour_sal,l_working_percentage,l_normal_hours,p_hourly_rate,
    l_waiting_day_hours,l_waiting_day_deduction,l_waiting_day,l_sickness_deduction_14_above,
    l_sickness_deduction_14_less,l_sick_pay_14_above,l_sick_pay_14_less,p_salary_rate,p_effective_date,
    p_assignment_action_id,p_override_monthly_basic,p_override_monthly_basic_day);



    p_sickness_14_below_days:=l_sick_pay_days_14_below_days; /*l_sickness_14_below_days;*/
    p_sickness_above_14_days:=l_sickness_above_14_days;
    p_sickness_pay_hours_14_below:=l_sickness_pay_hours_14_below;
    p_sickness_pay_hours_above_14:=nvl(l_sickness_pay_hours_above_14,0);
    p_tot_waiting_day_hours:=l_waiting_day_hours;
    p_tot_waiting_day:=l_waiting_day;
    p_total_sick_pay:=l_sick_pay_14_less;
    p_total_sick_pay_14_above:=l_sick_pay_14_above;
    p_tot_waiting_day_ded:=l_waiting_day_deduction;
    p_tot_sick_pay_days:=1;
    p_total_sickness_deduction:=l_sickness_deduction_14_less;
    p_tot_sickness_ded_14_above:=l_sickness_deduction_14_above;
    p_waiting_date:=l_waiting_date;
    p_fourteenth_date:=l_fourteenth_date;
    p_override_monthly_basic:=nvl(p_override_monthly_basic,0);
    p_override_monthly_basic_day:=nvl(p_override_monthly_basic_day,0);

    IF l_total_waiting_days>=10 THEN
	/*waiting day is 0 */
	p_tot_waiting_day:=0;
	p_tot_waiting_day_hours:=0;
	/* making waiting date to be null*/
	p_waiting_date:=null;
    END IF;

    IF l_fourteenth_date IS NULL then
	p_fourteenth_date:=l_sickness_last_date;
	/* To get the sickness days after 14th day in the month*/
    /*ELSE
	p_sickness_after_14_days_month:=GET_SICKNESS_AFTER_14_PERIOD(l_person_id,p_pay_start_date,
	p_pay_end_date,p_fourteenth_date);
	hr_utility.set_location('p_sickness_after_14_days_month'||p_sickness_after_14_days_month,10);		        */
    END IF;
    /* Bug Fix for 5981860 */
    IF p_fourteenth_date <p_pay_start_date THEN
       p_tot_waiting_day_ded:=0;
       p_total_sickness_deduction:=0;
    END IF;
    l_asg_hour_sal:='D';
    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
	( p_assignment_id, l_asg_hour_sal, l_include_event,
	l_group_start_date, p_fourteenth_date,
	l_start_time_char,l_end_time_char, l_wrk_duration
	);
    p_full_days:=l_wrk_duration;
        /*Call the function to get the Sickness Group level values */
    l_return:=Get_Sickness_Group_Details(l_person_id,p_assignment_id,p_pay_start_date,
    p_pay_end_date,p_abs_start_date,p_abs_end_date,p_group_calendar_days,
    p_group_working_days,p_group_working_hours);



RETURN 1;
EXCEPTION
	WHEN OTHERS THEN
                l_person_id := null;
                l_business_group_id := null;
                l_asg_hour_sal := null;

END CALCULATE_PAYMENT;



FUNCTION GET_SICKPAY_DETAILS(p_assignment_id IN NUMBER,
p_abs_start_date IN DATE,
p_abs_end_date IN DATE,
p_sickness_14_below_days IN NUMBER,
--p_sickness_above_14_days IN NUMBER,
p_sickness_after_14_days_month IN NUMBER,
p_sickness_pay_hours_14_below IN NUMBER,
p_sickness_pay_hours_above_14 IN NUMBER,
p_monthly_pay IN NUMBER,
p_asg_hour_sal IN varchar2,
p_working_percentage IN NUMBER,
p_normal_hours IN NUMBER,
p_hourly_rate IN NUMBER,
p_waiting_day_hours IN OUT NOCOPY NUMBER,
p_waiting_day_deduction OUT NOCOPY NUMBER,
p_waiting_day OUT NOCOPY NUMBER,
p_sickness_deduction_14_above OUT NOCOPY NUMBER,
p_sickness_deduction_14_less OUT NOCOPY NUMBER,
p_sick_pay_14_above OUT NOCOPY NUMBER,
p_sick_pay_14_less OUT NOCOPY NUMBER,
p_salary_rate    IN   NUMBER,
p_effective_date IN DATE,
p_assignment_action_id IN NUMBER,
p_override_monthly_basic OUT NOCOPY NUMBER,
p_override_monthly_basic_day OUT NOCOPY NUMBER
)
RETURN NUMBER IS

CURSOR csr_get_schedule_id(
   b_schdl_cat      VARCHAR2,
   b_object_type    VARCHAR2,
   b_object_id      NUMBER,
   b_start_dt       DATE,
   b_end_dt         DATE
  )
IS
 SELECT CSSB.SCHEDULE_ID
    from
    CAC_SR_SCHDL_OBJECTS CSSO,
    CAC_SR_SCHEDULES_B CSSB
    where
    CSSO.OBJECT_TYPE = b_object_type
    AND CSSO.OBJECT_ID = b_object_id
    AND CSSO.START_DATE_ACTIVE <= b_end_dt
    AND CSSO.END_DATE_ACTIVE >= b_start_dt
    AND CSSO.SCHEDULE_ID = CSSB.SCHEDULE_ID
    AND CSSB.DELETED_DATE IS NULL
    AND (CSSB.SCHEDULE_CATEGORY = b_schdl_cat
         OR CSSB.SCHEDULE_ID IN (SELECT SCHEDULE_ID
                                 FROM CAC_SR_PUBLISH_SCHEDULES
                                 WHERE OBJECT_TYPE = b_object_type
                                 AND OBJECT_ID = b_object_id
                                 AND b_schdl_cat IS NULL
                                ));
CURSOR csr_get_template_details(b_schedule_id number)
IS
select CSTB.Template_Id,CSTB.TEMPLATE_LENGTH_DAYS from CAC_SR_SCHEDULES_B CSSB,
CAC_SR_TEMPLATES_B CSTB
where
CSSB.Template_Id=CSTB.Template_Id
and CSSB.Schedule_id=b_schedule_id; --10206

CURSOR csr_get_shift_duration(b_template_id number)
IS
select CSRB.DURATION from
CAC_SR_TEMPLATES_B CSTB,
CAC_SR_TMPL_DETAILS CSTD,
CAC_SR_PERIODS_B CSRB
where
CSTB.Template_id =CSTD.Template_Id
and CSTD.Child_Period_Id=CSRB.Period_ID
and CSTB.Template_Id=b_template_id; --10284

CURSOR csr_global_value(csr_v_global_name VARCHAR2,csr_v_effective_date DATE )
IS
SELECT nvl(global_value,0) FROM ff_globals_f WHERE --ROWNUM<3
legislation_code='SE'
AND GLOBAL_NAME=csr_v_global_name --'SE_BASIC_AMOUNT'
AND csr_v_effective_date /*'28-feb-2007'*/ BETWEEN effective_start_date
AND effective_end_date;

Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE)
IS
SELECT ue.creator_id
FROM ff_user_entities  ue,
ff_database_items di
WHERE di.user_name = csr_v_Balance_Name
AND ue.user_entity_id = di.user_entity_id
AND ue.legislation_code = 'SE'
AND ue.business_group_id is NULL
AND ue.creator_type = 'B';

l_weekly_working_hours NUMBER;
l_hourly_rate NUMBER;
l_hours_day NUMBER;
l_schedule_id NUMBER;
l_template_id NUMBER;
l_pattern_length NUMBER;
l_shift_duration NUMBER;
l_waiting_day_hours NUMBER;
l_curr_sickness_14_less NUMBER;
l_curr_sickness_14_above NUMBER;
l_global_value NUMBER;
l_basic_amount_month NUMBER;
l_monthly_salary NUMBER;
l_override_monthly_basic NUMBER;
l_override_monthly_basic_day NUMBER;
lr_Get_Defined_Balance_Id number(10);
l_value number(10);

BEGIN
--getting the hours per day

OPEN csr_get_schedule_id(NULL, 'PERSON_ASSIGNMENT', p_assignment_id,add_months(p_abs_start_date,-1),p_abs_end_date);
	FETCH csr_get_schedule_id INTO l_schedule_id;
CLOSE csr_get_schedule_id;

OPEN csr_get_template_details(l_schedule_id);
	FETCH csr_get_template_details --.Template_Id,csr_get_template_details.TEMPLATE_LENGTH_DAYS
	INTO l_template_id,l_pattern_length;
CLOSE csr_get_template_details;

OPEN csr_get_shift_duration(l_template_id);
	FETCH csr_get_shift_duration INTO l_hours_day;
CLOSE csr_get_shift_duration;

OPEN csr_global_value('SE_BASIC_AMOUNT',p_effective_date);
	FETCH csr_global_value INTO l_global_value;
CLOSE csr_global_value;

l_basic_amount_month:=(7.5*l_global_value/12);

/* Get the monthly Salary value from balance */
/*pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id/*1305752*/--);
/*pay_balance_pkg.set_context('DATE_EARNED',p_effective_date/*'28-feb-2000'*/--);

/*OPEN  csr_Get_Defined_Balance_Id( 'SICK_PAY_AFTER_14_MONTHLY_PAY_ASG_MONTH');
	FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
CLOSE csr_Get_Defined_Balance_Id;

l_value :=nvl(pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id,
	P_ASSIGNMENT_ACTION_ID =>p_assignment_action_id/*1305752*/--),0);
/*l_monthly_salary:=l_value;*/
l_monthly_salary:=p_monthly_pay;
--checking salaried person
IF p_asg_hour_sal='S' THEN
	/*l_hourly_rate:=round(nvl(((p_Monthly_Pay*12)/(52*p_normal_hours)*p_working_percentage/100),0),2);*/
	IF p_waiting_day_hours <> 0 then
		p_waiting_day:=1;
	ELSE
		p_waiting_day:=0;
	END IF;
	p_waiting_day_deduction:=round((p_waiting_day_hours*p_salary_rate),2);

	p_sick_pay_14_less:=round((0.8*p_sickness_pay_hours_14_below*p_salary_rate),2);

	IF l_monthly_salary>=l_basic_amount_month THEN
		l_override_monthly_basic_day:=round((((l_monthly_salary-l_basic_amount_month)*12)/365),2);
		l_override_monthly_basic:=round((0.8*l_override_monthly_basic_day*/*p_sickness_above_14_days*/p_sickness_after_14_days_month),2);

		p_override_monthly_basic:=l_override_monthly_basic;
		p_override_monthly_basic_day:=l_override_monthly_basic_day;
		p_sick_pay_14_above:=round((0.1*((p_monthly_pay*12)/365)*(/*p_sickness_above_14_days*/p_sickness_after_14_days_month)),2);
	ELSE
		p_sick_pay_14_above:=round((0.1*((p_monthly_pay*12)/365)*(/*p_sickness_above_14_days*/p_sickness_after_14_days_month)),2);
	END IF;

	p_sickness_deduction_14_less:=round((p_sickness_pay_hours_14_below * p_salary_rate),2);


	p_sickness_deduction_14_above:=round(((p_monthly_pay*12)/365)*(/*p_sickness_above_14_days*/p_sickness_after_14_days_month),2);

ELSE
	p_sick_pay_14_less:=round((0.8*(p_sickness_pay_hours_14_below)*p_hourly_rate),2);

END IF;
return 1;

END GET_SICKPAY_DETAILS;

FUNCTION GET_WAITING_DAY(p_assignment_id NUMBER, p_abs_start_date DATE, p_abs_end_date date)
RETURN DATE IS

l_starting_date DATE;
l_found BOOLEAN :=false;
l_asg_hour_sal CHAR :='D';
l_include_event CHAR :='Y';
l_start_time_char Varchar2(10) := '0';
l_end_time_char Varchar2(10) := '23.59';
l_duration Number;
l_wrk_schd_return NUMBER;
BEGIN
l_starting_date:=p_abs_start_date;

	WHILE (l_starting_date <=  p_abs_end_date) AND l_found = false LOOP
		l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
			( p_assignment_id, l_asg_hour_sal, l_include_event,
			l_starting_date,l_starting_date, l_start_time_char,
			l_end_time_char, l_duration
    			);

		IF l_duration=1 THEN
			l_found:=true;
		ELSE
			l_starting_date:=l_starting_date +1;
		END IF;
		IF l_starting_date>p_abs_end_date THEN
		  l_starting_date:=TO_DATE('01/01/0001','dd/mm/yyyy');
		  l_found:=true;
		END IF;
	END LOOP;
	RETURN l_starting_date;
END GET_WAITING_DAY;

FUNCTION Get_Entitlement_Days(
p_assignment_id in NUMBER,
p_effective_date IN DATE,
p_absence_start_date IN DATE,
p_absence_end_date IN DATE,
p_entitlement_days OUT NOCOPY NUMBER,
p_sickness_days OUT NOCOPY NUMBER
)
RETURN NUMBER IS
l_wrk_schd_return NUMBER;
l_start_time_char Varchar2(10) := '0';
l_end_time_char Varchar2(10) := '23.59';
l_include_event CHAR;
l_wrk_duration NUMBER;
l_asg_hour_sal CHAR:='D';

BEGIN

/*SELECT  hourly_salaried_code
		INTO
        l_asg_hour_sal
		FROM per_all_assignments_f paaf,
		per_all_people_f papf,
		hr_soft_coding_keyflex hsck
		WHERE paaf.assignment_id = p_assignment_id
		AND paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
		AND papf.person_id=paaf.person_id
                AND p_effective_date BETWEEN paaf.effective_start_date
                AND paaf.effective_end_date
		AND p_effective_date BETWEEN papf.effective_start_date
                AND papf.effective_end_date;*/
/*get the entitlement days with public holidays and weekends*/
--l_include_event:='Y';
/*l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_asg_hour_sal, l_include_event,
							p_absence_start_date, p_absence_end_date,l_start_time_char,
							l_end_time_char, l_wrk_duration
							); */

p_entitlement_days:=(p_absence_end_date-p_absence_start_date)+1;
/*get the sickness days without public holidays and weekends*/
l_include_event:='Y';
l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_asg_hour_sal, l_include_event,
							p_absence_start_date, p_absence_end_date,l_start_time_char,
							l_end_time_char, l_wrk_duration
							);

p_sickness_days:=l_wrk_duration;
RETURN 0;
END Get_entitlement_days;

FUNCTION GET_SICKNESS_AFTER_14_PERIOD(p_person_id IN NUMBER,
p_assignment_id IN NUMBER,
p_payroll_start IN DATE,
p_payroll_end IN DATE,
p_fourteenth_date IN DATE)
RETURN NUMBER IS
l_14_days_month NUMBER:=0;
CURSOR csr_sickness_after_14_period(csr_v_person_id NUMBER,
csr_v_assignment_id number,
csr_v_payroll_start_date DATE,
csr_v_payroll_end_date DATE,
csr_v_fourteenth_date DATE)
IS
SELECT paa.absence_attendance_id
        ,greatest(paa.date_start,csr_v_fourteenth_date,csr_v_payroll_start_date) date_start
        ,least(nvl(paa.date_end,csr_v_payroll_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=csr_v_person_id),csr_v_payroll_end_date)) date_end
        ,paa.time_start
        ,paa.time_end
	--,(date_end-date_start) date_diff
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = csr_v_person_id --37732
        AND paa.date_start <= csr_v_payroll_end_date--'31-mar-2000' --p_abs_end_date
	AND least(nvl(paa.date_end,csr_v_payroll_end_date),csr_v_payroll_end_date)>=greatest(paa.date_start,csr_v_fourteenth_date,csr_v_payroll_start_date)--'01-mar-2000' --p_abs_end_date
        /*AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL*/
        AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
	/*Fix for Bug No. 5383707*/
	AND paa.absence_attendance_id IN(
--        ORDER BY paa.date_end  ;


   SELECT eev1.screen_entry_value  screen_entry_value
    FROM   per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
    WHERE  asg1.assignment_id    = csr_v_assignment_id --34040 --l_asg_id
      AND  p_payroll_end BETWEEN asg1.effective_start_date AND asg1.effective_end_date
      AND  p_payroll_end BETWEEN asg2.effective_start_date AND asg2.effective_end_date
      AND  per.person_id         = asg1.person_id
      AND  asg2.person_id        = per.person_id
      --AND  asg2.primary_flag     = 'Y'
      AND asg1.assignment_id=asg2.assignment_id
      AND  et.element_name       = 'Sickness Details'
      AND  et.legislation_code   = 'SE'
      --OR et.business_group_id=3261      ) --checking for the business group, it should be removed
      AND  iv1.element_type_id   = et.element_type_id
      AND  iv1.name              = 'CREATOR_ID'
      AND  el.business_group_id  = per.business_group_id
      AND  el.element_type_id    = et.element_type_id
      AND  ee.assignment_id      = asg2.assignment_id
      AND  ee.element_link_id    = el.element_link_id
      AND  eev1.element_entry_id = ee.element_entry_id
      AND  eev1.input_value_id   = iv1.input_value_id
      /*AND  ee.effective_start_date  >= p_abs_start_date
      AND  ee.effective_end_date <= p_abs_end_date
      AND  eev1.effective_start_date >= p_abs_start_date
      AND  eev1.effective_end_date <= p_abs_end_date*/
      ) ORDER BY paa.date_end desc ;

--        ORDER BY paa.date_end  ;

BEGIN

	--OPEN csr_sickness_after_14_payroll_period(p_person_id,p_payroll_start,p_payroll_end,p_fourteenth_date);
	FOR csr_sick IN csr_sickness_after_14_period(p_person_id,p_assignment_id,p_payroll_start,p_payroll_end,p_fourteenth_date) LOOP
		/*check for whether the start_date is same as fourteenth date*/
		IF csr_sick.date_start=p_fourteenth_date THEN
			l_14_days_month:=l_14_days_month+(csr_sick.date_end-csr_sick.date_start);
		/*IF start_date is not equal to fourteenth date */
		ELSE
			l_14_days_month:=l_14_days_month+(csr_sick.date_end-csr_sick.date_start)+1;
		END IF;
	END LOOP csr_sickness_after_14_period;
	--	FETCH csr_sickness_after_14_payroll_period.date_diff INTO l_14_days_month
	--CLOSE csr_sickness_after_14_payroll_period;
	RETURN l_14_days_month;
END GET_SICKNESS_AFTER_14_PERIOD;
FUNCTION Get_Sickness_Group_Details(p_person_id IN NUMBER,
					p_assignment_id IN NUMBER,
					p_pay_start_date IN DATE,
					p_pay_end_date IN DATE,
					p_abs_group_start_date IN DATE,
					p_abs_group_end_date IN DATE,
					p_group_calendar_days OUT NOCOPY NUMBER,
					p_group_working_days OUT NOCOPY NUMBER,
					p_group_working_hours OUT NOCOPY NUMBER )
RETURN NUMBER IS

l_working_days	 NUMBER:=0;
l_calendar_days  NUMBER:=0;
l_working_hours  NUMBER:=0;
l_days Char(1):='D';
l_hours Char(1):='H';
l_include_event CHAR :='Y';
l_start_time_char Varchar2(10) := '0';
l_end_time_char Varchar2(10) := '23.59';
l_wrk_schd_return NUMBER;
l_hour_duration NUMBER;
l_day_duration NUMBER;

CURSOR csr_absence_period(csr_v_person_id NUMBER,
csr_v_start_date DATE, csr_v_end_date DATE )
IS
        SELECT paa.absence_attendance_id
        ,greatest(paa.date_start,csr_v_start_date) date_start
        ,least(nvl(paa.date_end,csr_v_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=csr_v_person_id),csr_v_end_date)) date_end
        ,paa.time_start
        ,paa.time_end
	--,(date_end-date_start) date_diff
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = csr_v_person_id --37732
        AND paa.date_start <= csr_v_end_date--'31-mar-2000' --p_abs_end_date
	AND least(nvl(paa.date_end,csr_v_end_date),csr_v_end_date)>=greatest(paa.date_start,csr_v_start_date)--'01-mar-2000' --p_abs_end_date
        /*AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL*/
        AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
	/*Fix for Bug No. 5383707*/
	AND paa.absence_attendance_id IN(
--        ORDER BY paa.date_end  ;


   SELECT eev1.screen_entry_value  screen_entry_value
    FROM   per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
    WHERE  asg1.assignment_id    = p_assignment_id --34040 --l_asg_id
      AND  p_pay_end_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
      AND  p_pay_end_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
      AND  per.person_id         = asg1.person_id
      AND  asg2.person_id        = per.person_id
      --AND  asg2.primary_flag     = 'Y'
      AND asg1.assignment_id=asg2.assignment_id
      AND  et.element_name       = 'Sickness Details'
      AND  et.legislation_code   = 'SE'
      --OR et.business_group_id=3261      ) --checking for the business group, it should be removed
      AND  iv1.element_type_id   = et.element_type_id
      AND  iv1.name              = 'CREATOR_ID'
      AND  el.business_group_id  = per.business_group_id
      AND  el.element_type_id    = et.element_type_id
      AND  ee.assignment_id      = asg2.assignment_id
      AND  ee.element_link_id    = el.element_link_id
      AND  eev1.element_entry_id = ee.element_entry_id
      AND  eev1.input_value_id   = iv1.input_value_id
      /*AND  ee.effective_start_date  >= p_abs_start_date
      AND  ee.effective_end_date <= p_abs_end_date
      AND  eev1.effective_start_date >= p_abs_start_date
      AND  eev1.effective_end_date <= p_abs_end_date*/
      ) ORDER BY paa.date_end desc ;

--        ORDER BY paa.date_end  ;

	/*SELECT paa.absence_attendance_id
        ,paa.date_start
        --,nvl(paa.date_end,'31-jan-2000') date_end
        ,least(nvl(paa.date_end,csr_v_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=csr_v_person_id),csr_v_end_date)) date_end
        ,paa.time_start
        ,paa.time_end
        ,DECODE(paa.date_start,least(nvl(paa.date_end,csr_v_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=csr_v_person_id),csr_v_end_date)), 1,
	(least(nvl(paa.date_end,csr_v_end_date),nvl((select actual_termination_date from per_periods_of_service where person_id=csr_v_person_id),csr_v_end_date))-paa.date_start)+1) AS days_diff
	FROM per_absence_attendances paa,
	per_absence_attendance_types pat
	WHERE paa.person_id = csr_v_person_id
        AND paa.date_start >=csr_v_start_date
	AND paa.date_start<=csr_v_end_date
	AND least(nvl(paa.date_end,csr_v_end_date),csr_v_end_date)<=csr_v_end_date
        /*AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL*/
        /*AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
        AND pat.absence_category IN ('S')
        ORDER BY paa.date_end  ;*/


BEGIN
	FOR csr_abs IN  csr_absence_period(p_person_id,greatest(p_pay_start_date,p_abs_group_start_date),least(p_pay_end_date,p_abs_group_end_date)) LOOP

	      l_calendar_days:=l_calendar_days+(csr_abs.date_end-csr_abs.date_start+1);

	      l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_days, l_include_event,
							csr_abs.date_start, csr_abs.date_end, replace(nvl(csr_abs.time_start,l_start_time_char),':','.'),
							replace(nvl(csr_abs.time_end,l_end_time_char),':','.'), l_day_duration
							);

	      l_working_days:=l_working_days+l_day_duration;

	      l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
							( p_assignment_id, l_hours, l_include_event,
							csr_abs.date_start, csr_abs.date_end, replace(l_start_time_char,':','.'),
							replace(l_end_time_char,':','.'), l_hour_duration
							);

	      l_working_hours:=l_working_hours+l_hour_duration;


	END LOOP csr_absence_period;

	p_group_calendar_days:=l_calendar_days;
	p_group_working_days:=l_working_days;
	p_group_working_hours:=l_working_hours;

	RETURN 1;
        EXCEPTION
	WHEN OTHERS THEN
	RETURN 0;

END Get_Sickness_Group_Details;
END PAY_SE_ABSENCE;

/
