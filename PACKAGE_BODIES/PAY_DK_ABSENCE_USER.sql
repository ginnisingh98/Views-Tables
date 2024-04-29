--------------------------------------------------------
--  DDL for Package Body PAY_DK_ABSENCE_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_ABSENCE_USER" AS
/*$Header: pydkabsence.pkb 120.2.12000000.4 2007/03/29 11:49:48 nprasath noship $*/

-------------------------------------------------------------------------------------------------------------------------
/*  Element populate function to return Input values of absence element */
   -- NAME
   --  Element_populate
   -- PURPOSE
   --  To populate element input values for absence recording.
   -- ARGUMENTS
   --  P_ASSIGNMENT_ID         - Assignment id
   --  P_PERSON_ID 	       - Person id,
   --  P_ABSENCE_ATTENDANCE_ID - Absence attendance id,
   --  P_ELEMENT_TYPE_ID       - Element type id,
   --  P_ABSENCE_CATEGORY      - Absence category ( Sickness ),
   --  P_INPUT_VALUE_NAME 1-15 - Output variable holds element input value name.
   --  P_INPUT_VALUE 1-15      - Output variable holds element input value.
   -- USES
   -- NOTES
   --  The procedure fetches absence information from absence table with input absence_attendance_id and absence
   --  category 'Sickness' and 'Vacation'. Then it assigns the values to output variables.
-------------------------------------------------------------------------------------------------------------------------
Function Element_populate(p_assignment_id         in number,
                p_person_id 	in number,
                p_absence_attendance_id in number,
                p_element_type_id 	    in number,
                p_absence_category 	    in varchar2,
                p_original_entry_id     OUT nocopy NUMBER,
                p_input_value_name1 	OUT NOCOPY VARCHAR2,
		p_input_value1	    	OUT NOCOPY VARCHAR2,
                p_input_value_name2 	OUT NOCOPY VARCHAR2,
		p_input_value2	    	OUT NOCOPY VARCHAR2,
                p_input_value_name3 	OUT NOCOPY VARCHAR2,
		p_input_value3	    	OUT NOCOPY VARCHAR2,
                p_input_value_name4 	OUT NOCOPY VARCHAR2,
		p_input_value4	    	OUT NOCOPY VARCHAR2,
                p_input_value_name5 	OUT NOCOPY VARCHAR2,
		p_input_value5	    	OUT NOCOPY VARCHAR2,
                p_input_value_name6 	OUT NOCOPY VARCHAR2,
		p_input_value6	    	OUT NOCOPY VARCHAR2,
                p_input_value_name7 	OUT NOCOPY VARCHAR2,
		p_input_value7	    	OUT NOCOPY VARCHAR2,
                p_input_value_name8 	OUT NOCOPY VARCHAR2,
		p_input_value8	    	OUT NOCOPY VARCHAR2,
                p_input_value_name9 	OUT NOCOPY VARCHAR2,
		p_input_value9	    	OUT NOCOPY VARCHAR2,
                p_input_value_name10 	OUT NOCOPY VARCHAR2,
		p_input_value10	    	OUT NOCOPY VARCHAR2,
                p_input_value_name11 	OUT NOCOPY VARCHAR2,
		p_input_value11	    	OUT NOCOPY VARCHAR2,
                p_input_value_name12 	OUT NOCOPY VARCHAR2,
		p_input_value12	    	OUT NOCOPY VARCHAR2,
                p_input_value_name13 	OUT NOCOPY VARCHAR2,
		p_input_value13	    	OUT NOCOPY VARCHAR2,
                p_input_value_name14 	OUT NOCOPY VARCHAR2,
		p_input_value14	    	OUT NOCOPY VARCHAR2,
                p_input_value_name15 	OUT NOCOPY VARCHAR2,
		p_input_value15	    	OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS


		/*Cursor to get the intial entry id*/
		CURSOR csr_get_intial_entry_id(p_creator_id IN VARCHAR2 ,p_assignment_id IN NUMBER ) IS
		SELECT
			peef.element_entry_id
		FROM
			pay_element_entry_values_f peevf
			,pay_input_values_f pivf
			,pay_element_entries_f peef
		WHERE
			peevf.screen_entry_value = p_creator_id
			AND pivf.input_value_id = peevf.input_value_id
			AND pivf.NAME = 'CREATOR_ID'
			AND pivf.legislation_code = 'DK'
			AND peef.element_entry_id  = peevf.element_entry_id
	AND peef.assignment_id = p_assignment_id;

l_start_date            date;
l_end_date              date;
l_absent_reason         number;
l_start_time            varchar2(20);
l_end_time              varchar2(20);
l_intial_absence        varchar2(3);
l_initial_abs_creator_id number;

BEGIN


 hr_utility.set_location('Entering: Element_populate ', 10);
  hr_utility.set_location('p_absence_attendance_id'|| p_absence_attendance_id, 10);

       -- Fetch absence attendance details
       BEGIN
          SELECT abs.date_start
                 ,abs.date_end
                 ,abs.ABS_ATTENDANCE_REASON_ID
                 ,abs.TIME_START
                 ,abs.TIME_END
                 ,abs.abs_information1
                 ,abs.abs_information2
          INTO   l_start_date
                 ,l_end_date
                 ,l_absent_reason
                 ,l_start_time
                 ,l_end_time
                 ,l_intial_absence
                 ,l_initial_abs_creator_id
          FROM   per_absence_attendances      abs
          WHERE  abs.absence_attendance_id      = p_absence_attendance_id;
       EXCEPTION
          WHEN OTHERS THEN
               NULL;
       END;
    -- Check if absence category is S ( Sickness )
    IF p_absence_category = 'S' THEN
                p_input_value_name1 := 'Start Date';
		p_input_value1	    := 	l_start_date;
                p_input_value_name2 := 'End Date';
		p_input_value2	    := 	l_end_date;
                p_input_value_name3 := 'Start Time';
		p_input_value3	    := 	l_start_time;
                p_input_value_name4 := 'End Time';
		p_input_value4	    := 	l_end_time;
                p_input_value_name5 := 'Absent Reason';
               -- Fetch absence reason from the lookup
    	       BEGIN
        		    SELECT Meaning
        		    INTO p_input_value5
        		    FROM FND_LOOKUP_VALUES_VL LKP
        			     ,PER_ABSENCE_ATTENDANCES PAA
        			     ,PER_ABS_ATTENDANCE_REASONS PAR
        		    WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID  = PAR.ABSENCE_ATTENDANCE_TYPE_ID
        		      AND PAA.ABSENCE_ATTENDANCE_ID = p_absence_attendance_id
        		      AND PAR.ABS_ATTENDANCE_REASON_ID = l_absent_reason
        		      AND LKP.lookup_type = 'ABSENCE_REASON'
        		      AND LOOKUP_CODE = PAR.NAME
                            -- Bug No 4994835. Group by clause introduced to avoid duplicate records
			    GROUP BY LKP.Meaning;
               EXCEPTION
    		        WHEN OTHERS THEN
    		             NULL;
    	       END;
                p_input_value_name6 := 'CREATOR_ID';
		p_input_value6	    := 	p_absence_attendance_id;

    -- Check if absence category is V ( Vacation or Holiday )
    ELSIF p_absence_category = 'V' THEN
                p_input_value_name1 := 'Start Date';
		p_input_value1	    := 	l_start_date;
                p_input_value_name2 := 'End Date';
		p_input_value2	    := 	l_end_date;
                p_input_value_name3 := 'Start Time';
		p_input_value3	    := 	l_start_time;
                p_input_value_name4 := 'End Time';
		p_input_value4	    := 	l_end_time;
                p_input_value_name5 := 'Absent Reason';
               -- Fetch absence reason from the lookup
    	       BEGIN
        		    SELECT Meaning
        		    INTO p_input_value5
        		    FROM FND_LOOKUP_VALUES_VL LKP
        			     ,PER_ABSENCE_ATTENDANCES PAA
        			     ,PER_ABS_ATTENDANCE_REASONS PAR
        		    WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID  = PAR.ABSENCE_ATTENDANCE_TYPE_ID
        		      AND PAA.ABSENCE_ATTENDANCE_ID = p_absence_attendance_id
        		      AND PAR.ABS_ATTENDANCE_REASON_ID = l_absent_reason
        		      AND LKP.lookup_type = 'ABSENCE_REASON'
        		      AND LOOKUP_CODE = PAR.NAME
                            -- Bug No 4994835. Group by clause introduced to avoid duplicate records
			    GROUP BY LKP.Meaning;
               EXCEPTION
    		        WHEN OTHERS THEN
    		             NULL;
    	       END;
                p_input_value_name8 := 'CREATOR_ID';
		p_input_value8	    := 	p_absence_attendance_id;

    -- Check if absence category is M ( Maternity )
    ELSIF p_absence_category in ('M','PA','IE_AL','IE_PL','PTM') THEN
                    p_input_value_name1 := 'Start Date';
    		p_input_value1	    := 	l_start_date;
                    p_input_value_name2 := 'End Date';
    		p_input_value2	    := 	l_end_date;
                    p_input_value_name3 := 'Start Time';
    		p_input_value3	    := 	l_start_time;
                    p_input_value_name4 := 'End Time';
    		p_input_value4	    := 	l_end_time;
                p_input_value_name10 := 'CREATOR_ID';
		p_input_value10	    := 	p_absence_attendance_id;
		/* Included for Maternity Linking*/
		If p_absence_category in ('M','PTM') then
	            p_input_value_name13 := 'Full or Part Time';
		    p_input_value13	 :=  hr_general.decode_lookup('DK_MAT_DURATION',p_absence_category);
		End if;

		 IF l_intial_absence = 'N' THEN
		       OPEN csr_get_intial_entry_id(l_initial_abs_creator_id,p_assignment_id);
		       FETCH csr_get_intial_entry_id INTO p_original_entry_id;
       			CLOSE csr_get_intial_entry_id;
       	         End if;
    END IF;


-- Return Y indicating to process the element for the input assignment id.
RETURN 'Y';
END Element_populate;

FUNCTION get_override_details
 (p_assignment_id               IN         NUMBER
 ,p_effective_date              IN         DATE
 ,p_abs_start_date              IN         DATE
 ,p_abs_end_date                IN         DATE
 ,p_pre_birth_duration          IN OUT NOCOPY NUMBER
 ,p_post_birth_duration         IN OUT NOCOPY NUMBER
 ,p_maternity_allowance_used    OUT NOCOPY NUMBER
 ,p_shared_allowance_used       OUT NOCOPY NUMBER
 ,p_holiday_override            OUT NOCOPY NUMBER
 ,p_part_time_hours             IN OUT NOCOPY NUMBER
 ,p_part_time_hrs_freq          IN OUT NOCOPY VARCHAR2
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.element_entry_id element_entry_id
          , eev1.screen_entry_value  screen_entry_value
          , iv1.name
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  et.element_name       = 'Maternity Override'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              in ('Start Date', 'End Date','Payment During Leave'
     ,'Pre Birth Duration Override','Post Birth Duration Override','Part Time Hours','Part Time Hours Frequency',
     'Maternity Weeks Used','Shared Maternity Weeks Used','Holiday Accrual to Supress')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date
     AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     ORDER BY ee.element_entry_id;
  --
  TYPE l_record is record (eeid    pay_element_entries_f.element_entry_id%TYPE,
                           eevalue pay_element_entry_values_f.screen_entry_value%TYPE,
                           eename  pay_input_values_f.name%TYPE );
  l_rec l_record;
  TYPE l_table  is table of l_record index by BINARY_INTEGER;
  l_tab l_table;
  l_start_date date;
  l_end_date date;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_check_nomatch number;
  l_start_time		      NUMBER;
  l_end_time		      NUMBER;
  l_pay_during_leave          VARCHAR2(40);
  l_pre_birth_duration        NUMBER;
  l_post_birth_duration       NUMBER;
  l_over_ride_frequency       NUMBER;
  l_part_time_hours           NUMBER;
  l_part_time_hrs_frequency   VARCHAR2(40);
  l_maternity_allowance_used  NUMBER;
  l_shared_allowance_used     NUMBER;
  l_holiday_override NUMBER;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;
  l_check_nomatch := 0;
  p_maternity_allowance_used := 0;
  p_shared_allowance_used    := 0;
  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;
  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        case l_tab(l_cur).eename
             when 'Start Date'            		  then     l_start_date              :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'End Date'              		  then     l_end_date                :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
           --  when 'Start Time'            		  then     l_start_time              :=l_tab(l_cur).eevalue;
          --   when 'End Time'              		  then     l_end_time   	     :=l_tab(l_cur).eevalue;
             when 'Payment During Leave'                  then     l_pay_during_leave        :=l_tab(l_cur).eevalue;
             when 'Pre Birth Duration Override'           then     l_pre_birth_duration      :=l_tab(l_cur).eevalue;
             when 'Post Birth Duration Override'          then     l_post_birth_duration     :=l_tab(l_cur).eevalue;
            -- when 'Override Frequency'              	  then     l_over_ride_frequency     :=l_tab(l_cur).eevalue;
             when 'Part Time Hours'                       then     l_part_time_hours         :=l_tab(l_cur).eevalue;
             when 'Part Time Hours Frequency'             then     l_part_time_hrs_frequency :=l_tab(l_cur).eevalue;
             when 'Maternity Weeks Used'                  then     l_maternity_allowance_used:=l_tab(l_cur).eevalue;
             when 'Shared Maternity Weeks Used'           then     l_shared_allowance_used   :=l_tab(l_cur).eevalue;
	     when 'Holiday Accrual to Supress'            then     l_holiday_override        :=l_tab(l_cur).eevalue;
        end case;
       -- Check no. of input values of override element is 12

        IF l_counter < 10 then
           l_counter := l_counter + 1;
        else
	   -- Check override element's start and end date matches with Absent element.
           if l_start_date = p_abs_start_date then
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
		--p_pre_birth_duration         := null;
		--p_post_birth_duration        := null;
		p_maternity_allowance_used   := 0;
		p_shared_allowance_used      := 0;
                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
		p_pre_birth_duration         := nvl(l_pre_birth_duration,p_pre_birth_duration) ;
		p_post_birth_duration        := nvl(l_post_birth_duration,p_post_birth_duration);
		p_maternity_allowance_used   := nvl(l_maternity_allowance_used,0);
		p_shared_allowance_used      := nvl(l_shared_allowance_used,0);
		p_holiday_override           := l_holiday_override;
                p_part_time_hours            := nvl(l_part_time_hours,p_part_time_hours) ;
		p_part_time_hrs_freq         := nvl(l_part_time_hrs_frequency,p_part_time_hrs_freq);
           end if;
           l_counter := 1;
       END if;
  END LOOP;
  RETURN 0;
 END get_override_details;
/* Function to get Maternity Absence */
  FUNCTION get_absence_details
        	 (p_assignment_id               IN         NUMBER
 		 ,p_date_earned                IN         DATE
 		 ,p_abs_attendance_id           IN         NUMBER
 		 ,p_expected_dob                OUT NOCOPY DATE
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_pre_birth_duration          OUT NOCOPY NUMBER
 		 ,p_post_birth_duration         OUT NOCOPY NUMBER
 		 ,p_frequency                   OUT NOCOPY VARCHAR2
		 ,p_normal_hours                OUT NOCOPY NUMBER
		 ,p_maternity_weeks_transfer    OUT NOCOPY NUMBER
                 ,p_holiday_accrual             OUT NOCOPY VARCHAR2
		) Return varchar2 is
     CURSOR csr_absence IS SELECT
	  fnd_date.canonical_to_date(abs_information4)  expected_dob,
	  fnd_date.canonical_to_date(abs_information5)  actual_dob,
	  abs_information8  pre_birth_duration,
	  abs_information9  post_birth_duration,
	  abs_information10 maternity_weeks_transfer,
          abs_information6  holiday_accrual
	 FROM PER_ABSENCE_ATTENDANCES PAA
     WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

     CURSOR csr_asg_le IS SELECT
   	       nvl(asg.normal_hours,hoi.org_information3) hours
	      ,nvl(asg.frequency,hoi.org_information4) frequency
	 FROM
	    hr_organization_information hoi
           ,HR_SOFT_CODING_KEYFLEX SCL
	   ,PER_ALL_ASSIGNMENTS_F ASG
     WHERE ASG.ASSIGNMENT_ID = p_assignment_id
	 AND hoi.organization_id = scl.segment1
     AND org_information_context = 'DK_EMPLOYMENT_DEFAULTS'
     AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
     AND fnd_date.canonical_to_date(p_date_earned)  BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE;
    l_count VARCHAR2(2):='N';
    l_duration_freq VARCHAR2(80);
  Begin
  hr_utility.trace('****************Inside***************');
     FOR csr_abs_details in csr_absence
     Loop
        hr_utility.trace('****csr_abs_details.expected_dob**'||csr_abs_details.expected_dob);
        p_expected_dob        := csr_abs_details.expected_dob;
        hr_utility.trace('****p_expected_dob**'||p_expected_dob);
 	p_actual_dob          := csr_abs_details.actual_dob;
 	p_pre_birth_duration  := csr_abs_details.pre_birth_duration;
 	p_post_birth_duration := csr_abs_details.post_birth_duration;
 	p_maternity_weeks_transfer := csr_abs_details.maternity_weeks_transfer;
	p_holiday_accrual     := csr_abs_details.holiday_accrual;
 	l_count := 'Y';
     End Loop;
     FOR csr_asg_le_details in csr_asg_le
     Loop
       p_normal_hours:= csr_asg_le_details.hours;
       p_frequency:= csr_asg_le_details.frequency;
       l_count := 'Y';
     End Loop;
     return l_count;
  End get_absence_details;


  FUNCTION get_assg_term_date(p_business_group_id IN NUMBER, p_assignment_id IN NUMBER)
  RETURN DATE IS

      CURSOR csr_asg IS
      SELECT MAX(paaf.effective_end_date) effective_end_date
        FROM per_all_assignments_f paaf
       WHERE paaf.business_group_id = p_business_group_id
         AND paaf.assignment_id = p_assignment_id
         AND paaf.assignment_status_type_id = 1;

      l_asg_trem_date DATE;
      l_asg_status csr_asg % rowtype;

      BEGIN

        OPEN csr_asg;
        FETCH csr_asg
        INTO l_asg_status;
        CLOSE csr_asg;
        l_asg_trem_date := l_asg_status.effective_end_date;
        RETURN l_asg_trem_date;

END get_assg_term_date;

/*Function to get paternity absence details*/
FUNCTION get_pat_abs_details
       	 (
	 p_abs_attendance_id           IN NUMBER,
	 p_override_weeks              OUT NOCOPY NUMBER,
 	 p_holiday_accrual	        OUT NOCOPY VARCHAR2
	 ) Return NUMBER IS

		 CURSOR get_abs_details IS
		 SELECT
		 ABS.abs_information7
                ,ABS.abs_information5
		 FROM per_absence_attendances ABS
		 WHERE ABS.absence_attendance_id = p_abs_attendance_id;
		 l_abs_details get_abs_details%ROWTYPE ;

	 BEGIN

		 OPEN get_abs_details;
		 FETCH get_abs_details INTO l_abs_details;
		 CLOSE get_abs_details;

		 p_override_weeks := nvl(l_abs_details.abs_information7,-999) ;
	         p_holiday_accrual := l_abs_details.abs_information5;

		 RETURN 1 ;
	 EXCEPTION WHEN OTHERS THEN
		 raise_application_error(-20001,SQLERRM);
END get_pat_abs_details;

 FUNCTION get_paternity_override
 (p_assignment_id               IN         NUMBER
 ,p_effective_date              IN         DATE
 ,p_abs_start_date              IN         DATE
 ,p_abs_end_date                IN         DATE
 ,p_duration_override           IN OUT NOCOPY NUMBER
 ,p_holiday_override            OUT NOCOPY NUMBER
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.element_entry_id element_entry_id
          , eev1.screen_entry_value  screen_entry_value
          , iv1.name
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  et.element_name       = 'Paternity Override'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              in ('Start Date', 'End Date','Duration Override Weeks'
     ,'Holiday Accrual to Supress')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date
     AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     ORDER BY ee.element_entry_id;
  --
  TYPE l_record is record (eeid    pay_element_entries_f.element_entry_id%TYPE,
                           eevalue pay_element_entry_values_f.screen_entry_value%TYPE,
                           eename  pay_input_values_f.name%TYPE );
  l_rec l_record;
  TYPE l_table  is table of l_record index by BINARY_INTEGER;
  l_tab l_table;
  l_start_date date;
  l_end_date date;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_check_nomatch number;
  l_start_time		      NUMBER;
  l_end_time		      NUMBER;
  l_duration_override  NUMBER;
  l_shared_mat_allowance_used     NUMBER;
  l_shared_adopt_allowance_used     NUMBER;
  l_holiday_override NUMBER;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;
  l_check_nomatch := 0;
  --p_shared_duration := 0;

  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;
  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        case l_tab(l_cur).eename
             when 'Start Date'            		  then     l_start_date                  :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'End Date'              		  then     l_end_date                    :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'Duration Override Weeks'                     then     l_duration_override           :=l_tab(l_cur).eevalue;
             when 'Holiday Accrual to Supress'            then     l_holiday_override            :=l_tab(l_cur).eevalue;
        end case;
       -- Check no. of input values of override element is 12
        IF l_counter < 4  then
           l_counter := l_counter + 1;
        else
	   -- Check override element's start and end date matches with Absent element.
           if l_start_date = p_abs_start_date then
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
		--p_shared_duration   := 0;

                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
		p_duration_override   := nvl(l_duration_override,p_duration_override);
		p_holiday_override := l_holiday_override;

           end if;
           l_counter := 1;
       END if;
  END LOOP;



  RETURN 0;
 END get_paternity_override;

FUNCTION get_adopt_abs_details
        	 (p_assignment_id               IN         NUMBER
 		 ,p_date_earned                IN         DATE
 		 ,p_abs_attendance_id           IN         NUMBER
 		 ,p_expected_dob                OUT NOCOPY DATE
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_pre_adopt_duration          OUT NOCOPY NUMBER
 		 ,p_post_adopt_duration         OUT NOCOPY NUMBER
		 ,p_adopt_weeks_transfer        OUT NOCOPY NUMBER
 		 ,p_weeks_from_mother           OUT NOCOPY NUMBER
		 ,p_sex                         OUT NOCOPY VARCHAR2
		 ,p_holiday_accrual	        OUT NOCOPY VARCHAR2
		) Return NUMBER is
     CURSOR csr_absence IS SELECT
	  fnd_date.canonical_to_date(abs_information4)  expected_dob,
	  fnd_date.canonical_to_date(abs_information5)  actual_dob,
	  abs_information8  pre_adopt_duration,
	  abs_information9  post_adopt_duration,
	  abs_information10 adoption_weeks_transfer,
	  abs_information11 weeks_from_mother,
  	  abs_information6  hol_accrual_elig
	 FROM PER_ABSENCE_ATTENDANCES PAA
     WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

     CURSOR csr_person_details IS
      SELECT  papf.sex FROM per_all_people_f papf,per_all_assignments_f paaf
      WHERE
      paaf.assignment_id = p_assignment_id
      AND p_date_earned BETWEEN paaf.effective_start_date AND paaf.effective_end_date
      AND papf.person_id = paaf.person_id
      AND p_date_earned BETWEEN papf.effective_start_date AND papf.effective_end_date;
  Begin
     FOR csr_abs_details in csr_absence
     Loop
        p_expected_dob        := csr_abs_details.expected_dob;
 	p_actual_dob          := csr_abs_details.actual_dob;
 	p_pre_adopt_duration  := csr_abs_details.pre_adopt_duration;
 	p_post_adopt_duration := csr_abs_details.post_adopt_duration;
 	p_adopt_weeks_transfer := nvl(csr_abs_details.adoption_weeks_transfer,0);
	p_weeks_from_mother    := nvl(csr_abs_details.weeks_from_mother,0);
	p_holiday_accrual      := csr_abs_details.hol_accrual_elig;
     End Loop;

    OPEN csr_person_details;
        FETCH csr_person_details INTO p_sex;
    CLOSE csr_person_details;

     RETURN 1 ;
    EXCEPTION WHEN OTHERS THEN
	 raise_application_error(-20001,SQLERRM);
  End get_adopt_abs_details;


FUNCTION get_adopt_override_details
 (p_assignment_id               IN         NUMBER
 ,p_effective_date              IN         DATE
 ,p_abs_start_date              IN         DATE
 ,p_abs_end_date                IN         DATE
 ,p_pre_adopt_duration          IN OUT NOCOPY NUMBER
 ,p_post_adopt_duration         IN OUT NOCOPY NUMBER
 ,p_adoption_allowance_used    OUT NOCOPY NUMBER
 ,p_shared_allowance_used       OUT NOCOPY NUMBER
  ,p_holiday_override            OUT NOCOPY NUMBER
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.element_entry_id element_entry_id
          , eev1.screen_entry_value  screen_entry_value
          , iv1.name
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  et.element_name       = 'Adoption Override'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              in ('Start Date', 'End Date','Payment During Leave'
     ,'Pre Adopt Duration Override','Post Adopt Duration Override','Adoption Weeks Used','Shared Adoption Weeks Used','Holiday Accrual to Supress')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date
     AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     ORDER BY ee.element_entry_id;
  --
  TYPE l_record is record (eeid    pay_element_entries_f.element_entry_id%TYPE,
                           eevalue pay_element_entry_values_f.screen_entry_value%TYPE,
                           eename  pay_input_values_f.name%TYPE );
  l_rec l_record;
  TYPE l_table  is table of l_record index by BINARY_INTEGER;
  l_tab l_table;
  l_start_date date;
  l_end_date date;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_check_nomatch number;
  l_start_time		      NUMBER;
  l_end_time		      NUMBER;
  l_pay_during_leave          VARCHAR2(40);
  l_pre_adopt_duration        NUMBER;
  l_post_adopt_duration       NUMBER;
  l_over_ride_frequency       NUMBER;
  l_adoption_allowance_used  NUMBER;
  l_shared_allowance_used     NUMBER;
  l_holiday_override NUMBER;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;
  l_check_nomatch := 0;
  p_adoption_allowance_used := 0;
  p_shared_allowance_used    := 0;
  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;
  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        case l_tab(l_cur).eename
             when 'Start Date'            		  then     l_start_date              :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'End Date'              		  then     l_end_date                :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'Payment During Leave'                  then     l_pay_during_leave        :=l_tab(l_cur).eevalue;
             when 'Pre Adopt Duration Override'           then     l_pre_adopt_duration      :=l_tab(l_cur).eevalue;
             when 'Post Adopt Duration Override'          then     l_post_adopt_duration     :=l_tab(l_cur).eevalue;
             when 'Adoption Weeks Used'                   then     l_adoption_allowance_used :=l_tab(l_cur).eevalue;
             when 'Shared Adoption Weeks Used'            then     l_shared_allowance_used   :=l_tab(l_cur).eevalue;
             when 'Holiday Accrual to Supress'            then     l_holiday_override        :=l_tab(l_cur).eevalue;
        end case;
       -- Check no. of input values of override element is 12
        IF l_counter < 8 then
           l_counter := l_counter + 1;
        else
	   -- Check override element's start and end date matches with Absent element.
           if l_start_date = p_abs_start_date then
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
		--p_pre_adopt_duration         := null;
		--p_post_adopt_duration        := null;
		p_adoption_allowance_used   := 0;
		p_shared_allowance_used      := 0;
                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
		p_pre_adopt_duration         := nvl(l_pre_adopt_duration,p_pre_adopt_duration) ;
		p_post_adopt_duration        := nvl(l_post_adopt_duration,p_post_adopt_duration);
		p_adoption_allowance_used    := nvl(l_adoption_allowance_used,0);
		p_shared_allowance_used      := nvl(l_shared_allowance_used,0);
		p_holiday_override           := l_holiday_override;
           end if;
           l_counter := 1;
       END if;
  END LOOP;
  RETURN 0;
 EXCEPTION WHEN OTHERS THEN
	 raise_application_error(-20001,SQLERRM);
 END get_adopt_override_details;

FUNCTION get_parental_details
        	 (p_abs_attendance_id           IN         NUMBER
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_duration_override           OUT NOCOPY NUMBER
		 ,p_parental_type               OUT NOCOPY VARCHAR2
		 ,p_holiday_accrual	        OUT NOCOPY VARCHAR2
 		 ) Return varchar2 is
     CURSOR csr_absence IS SELECT
	  fnd_date.canonical_to_date(abs_information4)  actual_dob,
	  abs_information7  duration_override,
	  abs_information10 parental_type,
	  abs_information5 holiday_accrual
	 FROM PER_ABSENCE_ATTENDANCES PAA
     WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;
    l_count VARCHAR2(2):='N';
  Begin
     FOR csr_abs_details in csr_absence
     Loop
        p_actual_dob          := csr_abs_details.actual_dob;
 	p_duration_override   := csr_abs_details.duration_override;
	p_parental_type       := csr_abs_details.parental_type;
	p_holiday_accrual     := csr_abs_details.holiday_accrual;
 	l_count := 'Y';
     End Loop;
     return l_count;
End get_parental_details;

 FUNCTION get_parental_override
 (p_assignment_id               IN         NUMBER
 ,p_effective_date              IN         DATE
 ,p_abs_start_date              IN         DATE
 ,p_abs_end_date                IN         DATE
 ,p_shared_duration          IN OUT NOCOPY NUMBER
 ,p_shared_mat_allowance_used   OUT NOCOPY NUMBER
 ,p_shared_adopt_allowance_used OUT NOCOPY NUMBER
 ,p_holiday_override            OUT NOCOPY NUMBER
 ) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.element_entry_id element_entry_id
          , eev1.screen_entry_value  screen_entry_value
          , iv1.name
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  et.element_name       = 'Parental Leave Override'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              in ('Start Date', 'End Date','Duration Override'
     ,'Shared Maternity Weeks Used','Shared Adoption Weeks Used','Holiday Accrual to Supress')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  p_effective_date BETWEEN el.effective_start_date AND el.effective_end_date
     AND  p_effective_date BETWEEN per.effective_start_date AND per.effective_end_date
     ORDER BY ee.element_entry_id;
  --
  TYPE l_record is record (eeid    pay_element_entries_f.element_entry_id%TYPE,
                           eevalue pay_element_entry_values_f.screen_entry_value%TYPE,
                           eename  pay_input_values_f.name%TYPE );
  l_rec l_record;
  TYPE l_table  is table of l_record index by BINARY_INTEGER;
  l_tab l_table;
  l_start_date date;
  l_end_date date;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_check_nomatch number;
  l_start_time		      NUMBER;
  l_end_time		      NUMBER;
  l_duration_override  NUMBER;
  l_shared_mat_allowance_used     NUMBER;
  l_shared_adopt_allowance_used     NUMBER;
  l_holiday_override NUMBER;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;
  l_check_nomatch := 0;
  --p_shared_duration := 0;
  p_shared_mat_allowance_used := 0;
  p_shared_adopt_allowance_used :=0;
  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;
  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        case l_tab(l_cur).eename
             when 'Start Date'            		  then     l_start_date                  :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'End Date'              		  then     l_end_date                    :=to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
             when 'Duration Override'                     then     l_duration_override           :=l_tab(l_cur).eevalue;
             when 'Shared Maternity Weeks Used'           then     l_shared_mat_allowance_used   :=l_tab(l_cur).eevalue;
             when 'Shared Adoption Weeks Used'            then     l_shared_adopt_allowance_used :=l_tab(l_cur).eevalue;
             when 'Holiday Accrual to Supress'            then     l_holiday_override            :=l_tab(l_cur).eevalue;
        end case;
       -- Check no. of input values of override element is 12
        IF l_counter < 6  then
           l_counter := l_counter + 1;
        else
	   -- Check override element's start and end date matches with Absent element.
           if l_start_date = p_abs_start_date then
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
		--p_shared_duration   := 0;
		p_shared_mat_allowance_used  := 0;
                p_shared_adopt_allowance_used := 0;

                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
		p_shared_duration   := nvl(l_duration_override,p_shared_duration);
		p_holiday_override := l_holiday_override;
                p_shared_mat_allowance_used  := nvl(l_shared_mat_allowance_used,0);
                p_shared_adopt_allowance_used := nvl(l_shared_adopt_allowance_used,0);
           end if;
           l_counter := 1;
       END if;
  END LOOP;



  RETURN 0;
 END get_parental_override;

/* Added for Holiday Accrual impact of Maternity and related absences */

/* Function to get the effective working days based on work pattern between two given dates*/
FUNCTION get_wrk_days_hol_accr
 (p_wrk_pattern                 IN         VARCHAR2
 ,p_hrs_in_day                  IN         NUMBER
 ,p_abs_start_date              IN         DATE
 ,p_abs_end_date                IN         DATE
 ,p_abs_start_time              IN         VARCHAR2
 ,p_abs_end_time                IN         VARCHAR2
 ) RETURN NUMBER IS

l_time_diff NUMBER;
l_days_diff NUMBER;
l_rem_num_diff NUMBER;
l_start_day VARCHAR2(10);
l_end_day VARCHAR2(10);
l_start_day_num NUMBER;
l_end_day_num NUMBER;
l_no_weeks NUMBER;
l_count_weekend NUMBER;


BEGIN

l_time_diff	:= 0;
l_days_diff	:= 0;
l_rem_num_diff	:= 0;
l_start_day	:= ' ';
l_end_day	:= ' ';
l_start_day_num := 0;
l_end_day_num	:= 0;
l_no_weeks	:= 0;
l_count_weekend := 0;

l_days_diff := p_abs_end_date - p_abs_start_date + 1;

/* Calculate the number of whole weeks involved */
l_no_weeks := TRUNC(l_days_diff/7);

/* 5 Day pattern means Saturday and Sunday off */
/* 5 Day pattern means Sunday off */

IF(p_wrk_pattern ='5DAY') THEN
l_count_weekend := l_no_weeks*2;
ELSIF(p_wrk_pattern ='6DAY') THEN
l_count_weekend := l_no_weeks;
END IF;

/* Count the number of weekends between the remaining days */
l_start_day := to_char(p_abs_start_date,'DY','NLS_DATE_LANGUAGE = English');
l_end_day := to_char(p_abs_end_date,'DY','NLS_DATE_LANGUAGE = English');

l_start_day_num := conv_day_to_num(l_start_day);
l_end_day_num := conv_day_to_num(l_end_day);

l_rem_num_diff :=  l_end_day_num - l_start_day_num;

/* If diff is -1 means one week covered*/
IF (l_rem_num_diff <-1 ) THEN
	IF(p_wrk_pattern ='5DAY') THEN
		IF(l_start_day_num = 7) THEN
		l_count_weekend := l_count_weekend + 1;
		ELSE
		l_count_weekend := l_count_weekend + 2;
		END IF;
	ELSIF(p_wrk_pattern ='6DAY') THEN
	l_count_weekend := l_count_weekend + 1;
	END IF;
ELSE IF( l_rem_num_diff > 0 AND l_end_day_num = 6 ) THEN
	IF(p_wrk_pattern ='5DAY') THEN
	l_count_weekend := l_count_weekend + 1;
	ELSIF(p_wrk_pattern ='6DAY') THEN
	l_count_weekend := l_count_weekend + 0;
	END IF;
     ELSE IF ( l_rem_num_diff > 0 AND l_end_day_num = 7) THEN
		IF(p_wrk_pattern ='5DAY') THEN
			IF(l_start_day_num = 7) THEN
			l_count_weekend := l_count_weekend + 1 ;
			ELSE
			l_count_weekend := l_count_weekend + 2 ;
			END IF;
		ELSIF(p_wrk_pattern ='6DAY') THEN
			IF(l_start_day_num = 7) THEN
			l_count_weekend := l_count_weekend + 1 ;
			ELSE
			l_count_weekend := l_count_weekend + 1 ;
			END IF;
		END IF;
	   ELSIF (l_rem_num_diff = 0 ) THEN
	        IF(l_end_day_num IN(6,7)) THEN
		l_count_weekend := l_count_weekend + 1 ;
		END IF;
	   END IF;
     END IF;
END IF;


RETURN (l_days_diff - l_count_weekend);

END get_wrk_days_hol_accr;

/* Function to convert the day of the week to a number to be used in logic processing */
/* Cannot rely on to_char with format as 'D' to return the same value as dependent on NLS_TERRITORY */
FUNCTION conv_day_to_num( p_day VARCHAR2) RETURN NUMBER IS
l_return NUMBER;
BEGIN

IF (p_day ='MON') THEN
l_return := 1;
ELSIF (p_day ='TUE') THEN
l_return := 2;
ELSIF (p_day ='WED') THEN
l_return := 3;
ELSIF (p_day ='THU') THEN
l_return := 4;
ELSIF (p_day ='FRI') THEN
l_return := 5;
ELSIF (p_day ='SAT') THEN
l_return := 6;
ELSIF (p_day ='SUN') THEN
l_return := 7;
END IF;

RETURN l_return;

END conv_day_to_num;

/* Function to get Part Time Maternity Details */
FUNCTION get_ptm_abs_details
        	 (p_abs_attendance_id           IN         NUMBER
 		 ,p_actual_dob                  OUT NOCOPY DATE
 		 ,p_part_time_hours             OUT NOCOPY NUMBER
		 ,p_part_time_hrs_freq          OUT NOCOPY VARCHAR2
		 ,p_holiday_accrual	        OUT NOCOPY VARCHAR2
 		 ) Return varchar2 is
     CURSOR csr_absence IS SELECT
	  fnd_date.canonical_to_date(abs_information4)  actual_dob,
	  fnd_number.canonical_to_number(abs_information7)  part_time_hours,
	  abs_information8  part_time_hrs_freq,
	  abs_information5 holiday_accrual
	 FROM PER_ABSENCE_ATTENDANCES PAA
     WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;
    l_count VARCHAR2(2):='N';
  Begin
     FOR csr_abs_details in csr_absence
     Loop
        p_actual_dob          := csr_abs_details.actual_dob;
 	p_part_time_hours     := csr_abs_details.part_time_hours;
	p_part_time_hrs_freq  := csr_abs_details.part_time_hrs_freq;
	p_holiday_accrual     := csr_abs_details.holiday_accrual;
 	l_count := 'Y';
     End Loop;
     return l_count;
End get_ptm_abs_details;

/* End of Function to get Part Time Maternity Details */
/* Function to Get worked Hrs for PTM*/
Function get_part_time_worked_hrs
  (p_assignment_id               IN         NUMBER
  ,p_date_earned                 IN         DATE
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_start_time                  IN         VARCHAR2
  ,p_end_time                    IN         VARCHAR2
  ,p_worked_hours                OUT NOCOPY NUMBER
  ,p_weekly_worked_days          OUT NOCOPY NUMBER
  ) return Varchar2 is

   CURSOR csr_asg_le IS SELECT
   	       fnd_number.canonical_to_number(nvl(asg.normal_hours,hoi.org_information3)) hours
	      ,nvl(asg.frequency,hoi.org_information4) frequency
	      ,segment10 work_pattern
	 FROM
	    hr_organization_information hoi
           ,HR_SOFT_CODING_KEYFLEX SCL
	   ,PER_ALL_ASSIGNMENTS_F ASG
     WHERE ASG.ASSIGNMENT_ID = p_assignment_id
	 AND hoi.organization_id = scl.segment1
     AND org_information_context = 'DK_EMPLOYMENT_DEFAULTS'
     AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
     AND p_date_earned BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE;

   l_count NUMBER;
   l_abs_start date;
   l_abs_end date;
   l_abs_hours_returned NUMBER;
   l_hours NUMBER;
   l_hours_rate NUMBER;
   l_mul_factor NUMBER;
   l_work_pattern Varchar2(40);
   l_freq VARCHAR2(3);
 Begin

        l_abs_start:= p_abs_start_date - to_number(to_char(p_abs_start_date,'D'))+1;
        l_abs_end   := l_abs_start+6;

	hr_utility.trace(' l_abs_start : '||l_abs_start||'  l_abs_end :'||l_abs_end);

     l_count := hr_loc_work_schedule.calc_sch_based_dur(p_assignment_id,'H','N',l_abs_start,l_abs_end,'00','00',l_abs_hours_returned);
     l_count := hr_loc_work_schedule.calc_sch_based_dur(p_assignment_id,'D','N',l_abs_start,l_abs_end,'00','00',p_weekly_worked_days);

     FOR csr_asg_le_details in csr_asg_le
     Loop
           l_hours_rate:= csr_asg_le_details.hours;
           l_freq:= csr_asg_le_details.frequency;
	   l_work_pattern := csr_asg_le_details.work_pattern;
     End Loop;

     If l_abs_hours_returned = 0 then
	If l_hours_rate is not null and l_freq is not null then

		IF(l_freq = 'D') THEN
		   l_mul_factor:= 5;
		ELSIF (l_freq = 'W') THEN
		   l_mul_factor := 1;
		ELSIF (l_freq = 'M') THEN
		   l_mul_factor := 5/22;
		ELSIF (l_freq = 'Y') THEN
		   l_mul_factor :=5/260;
		End if;

		 /* Prorate Employee Hours for new starters and leavers in the period */
		  l_hours := ROUND(l_hours_rate * l_mul_factor,2);
        Else
	     p_worked_hours := 0;
	     return 'N';
	End if;

    Else
	 l_hours := l_abs_hours_returned;
    End if;
    p_worked_hours := l_hours;
    return 'Y';
 End get_part_time_worked_hrs;
 /* End of Function to Get worked Hrs for PTM*/

END PAY_DK_ABSENCE_USER;

/
