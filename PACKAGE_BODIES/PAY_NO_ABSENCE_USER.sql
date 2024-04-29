--------------------------------------------------------
--  DDL for Package Body PAY_NO_ABSENCE_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ABSENCE_USER" AS
/*$Header: pynoabsusr.pkb 120.0.12010000.2 2008/08/06 08:03:53 ubhat ship $*/
Function Element_populate(p_assignment_id   in number,
                p_person_id 	            in number,
                p_absence_attendance_id     in number,
		p_element_type_id 	    in number,
                p_absence_category 	    in varchar2,
                p_original_entry_id     OUT nocopy NUMBER, --pgopal
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
	AND pivf.legislation_code = 'NO'
	AND peef.element_entry_id  = peevf.element_entry_id
	AND peef.assignment_id = p_assignment_id;

-- Cursor to fetch previous sickness and part-time sickness absences for
-- find out the starting linking absence.
CURSOR CSR_CONT_LINK (l_person_id IN number,l_abs_st_date IN date) IS
SELECT paa.absence_attendance_id
       ,paa.date_start
       ,paa.date_end
  FROM per_absence_attendances paa, per_absence_attendance_types pat
 WHERE paa.person_id = l_person_id
   AND paa.date_start < l_abs_st_date
   AND paa.date_end < l_abs_st_date
   AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
   AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
   AND pat.absence_category IN ('S','PTS')
 ORDER BY paa.date_end desc ;

-- Cursor to fetch global values
CURSOR csr_get_glb_value(p_global_name IN VARCHAR2, p_effective_date IN DATE) IS
SELECT to_number(global_value)
FROM  ff_globals_f
WHERE global_name = p_global_name
AND   legislation_code = 'NO'
AND   p_effective_date BETWEEN effective_start_date AND effective_end_date;

l_start_date            date;
l_end_date              date;
l_absent_reason         number;
l_start_time            varchar2(20);
l_end_time              varchar2(20);
l_abs_cat_meaning       varchar2(100);
--l_initial_abs_creator_id NUMBER ;
l_initial_abs_creator_id varchar2(60) ;
l_intial_absence      CHAR;
l_loop_start_date       date;
prev_link_abs_exist     varchar2(10);
l_abs_attn_id           number;
l_abs_link_period       number;

BEGIN

       -- Fetch absence attendance details
       BEGIN
          SELECT abs.date_start
                 ,abs.date_end
                 ,abs.ABS_ATTENDANCE_REASON_ID
                 ,abs.TIME_START
                 ,abs.TIME_END
                 ,abs.abs_information15
                 ,abs.abs_information16
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

    IF p_absence_category in ('S', 'PTS') AND
       nvl(l_intial_absence,'Y') = 'Y' THEN
       OPEN csr_get_glb_value('NO_ABS_LINK_PERIOD',l_start_date);
       FETCH csr_get_glb_value INTO l_abs_link_period;
       CLOSE csr_get_glb_value;

       l_loop_start_date := l_start_date ; /* assign the current absence start date */
       prev_link_abs_exist := 'N';
       FOR i in CSR_CONT_LINK (p_person_id, l_start_date) LOOP
           IF ( l_loop_start_date - i.date_end ) <= l_abs_link_period then
             prev_link_abs_exist := 'Y';
             l_abs_attn_id := i.absence_attendance_id;
           ELSE -- No linking absence exists.
                 EXIT;
           END IF;
           l_loop_start_date := i.date_start;
       END LOOP;

       IF prev_link_abs_exist = 'Y' THEN
	   OPEN csr_get_intial_entry_id(to_char(l_abs_attn_id),p_assignment_id);
          FETCH csr_get_intial_entry_id INTO p_original_entry_id;
          CLOSE csr_get_intial_entry_id;
	END IF;
    ELSE -- Other than S and PTS Categories
       IF l_intial_absence = 'N' THEN
       OPEN csr_get_intial_entry_id(l_initial_abs_creator_id,p_assignment_id);
       FETCH csr_get_intial_entry_id INTO p_original_entry_id;
       CLOSE csr_get_intial_entry_id;
       /*  Commented Setting original entry id for initial absences*/
       /*ELSE
        If initial absence = 'Y' then set the element entry id as original entry id
       OPEN csr_get_intial_entry_id(p_absence_attendance_id);
       FETCH csr_get_intial_entry_id INTO p_original_entry_id;
       CLOSE csr_get_intial_entry_id;*/
       END IF ;
    END IF;
    -- Check if absence category is S ( Sickness )
    IF p_absence_category in ('S', 'PTS', 'CMS', 'PA', 'PTP', 'M', 'PTM', 'IE_AL', 'VAC','PTA') THEN
                p_input_value_name1 := 'Start Date';
		p_input_value1	    := 	fnd_date.date_to_displaydate(l_start_date);  -- date conversion for 6850183
                p_input_value_name2 := 'End Date';
		p_input_value2	    := 	fnd_date.date_to_displaydate(l_end_date);   -- date conversion for 6850183
                p_input_value_name5 := 'Absence Category';

		     -- To select absence category meaning by passing code
		     BEGIN
		        SELECT MEANING
			INTO   l_abs_cat_meaning
			--FROM   FND_LOOKUP_VALUES
			-- Version 115.1 , Changed query to get value from hr_lookups
			FROM   HR_LOOKUPS
			WHERE  LOOKUP_TYPE = 'ABSENCE_CATEGORY'
			  AND  ENABLED_FLAG = 'Y'
			  AND  LOOKUP_CODE = p_absence_category;
		     EXCEPTION
		        WHEN OTHERS THEN
			       l_abs_cat_meaning := null;
		     END;

		p_input_value5	    := 	l_abs_cat_meaning;
		p_input_value_name6 := 'CREATOR_ID';
		p_input_value6	    := 	p_absence_attendance_id;

    END IF;

-- Return Y indicating to process the element for the input assignment id.
RETURN 'Y';
END Element_populate;

END PAY_NO_ABSENCE_USER;

/
