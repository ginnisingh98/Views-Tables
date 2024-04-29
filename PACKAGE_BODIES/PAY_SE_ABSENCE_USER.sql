--------------------------------------------------------
--  DDL for Package Body PAY_SE_ABSENCE_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ABSENCE_USER" AS
/*$Header: pyseabsence.pkb 120.1 2007/06/28 12:47:02 rravi noship $*/

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
   --  P_INPUT_VALUE_NAME 1-4,6 - Output variable holds element input value name.
   --  P_INPUT_VALUE 1-4,6      - Output variable holds element input value.
   -- USES
   -- NOTES

-------------------------------------------------------------------------------------------------------------------------
Function Element_populate(p_assignment_id         in number,
                p_person_id 	in number,
        p_absence_attendance_id in number,
		        p_element_type_id 	    in number,
        p_absence_category 	    in varchar2,
        p_original_entry_id          OUT NOCOPY NUMBER,
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
		p_input_value15	    	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_start_date            date;
l_end_date              date;
l_days                  number;
l_hours                 number;
l_absent_reason         number;
l_start_time            varchar2(20);
l_end_time              varchar2(20);
l_abs_cat_meaning       varchar2(100);
l_start_time_char varchar2(5) := '00:00';
l_end_time_char varchar2(5) := '23:59';
l_Absence_Percentage Number(10,2);
l_wrk_start_date date;

l_absence_start_date date;
l_absence_end_date   date;

l_weekends number;
l_public_holidays number;
l_Total_absence_days number;

BEGIN




       -- Fetch absence attendance details
       BEGIN
          SELECT abs.date_start
                 ,abs.date_end
                 ,abs.ABS_ATTENDANCE_REASON_ID
--                 ,abs.TIME_START
  --               ,abs.TIME_END
                 ,abs.absence_Days
                 ,abs.absence_Hours
          INTO   l_start_date
                 ,l_end_date
                 ,l_absent_reason
--                 ,l_start_time
  --               ,l_end_time
                 ,l_days
                 ,l_hours
          FROM   per_absence_attendances      abs
          WHERE  abs.absence_attendance_id      = p_absence_attendance_id;
       EXCEPTION
          WHEN OTHERS THEN
               NULL;
       END;
    -- Check if absence category is S ( Sickness )
    IF p_absence_category in ('S') THEN
                p_input_value_name1 := 'Start Date';
		p_input_value1	    := 	l_start_date;
                p_input_value_name2 := 'End Date';
		p_input_value2	    := 	l_end_date;
		p_input_value_name3 := 'Entitlement Days';
		p_input_value3	    := 	l_days;
		p_input_value_name4 := 'Hours';
		p_input_value4	    := 	l_hours;
                --p_input_value_name5 := 'Absence Category';

		     -- To select absence category meaning by passing code
		     BEGIN
		        SELECT MEANING
			INTO   l_abs_cat_meaning
			FROM   hr_lookups
			WHERE  LOOKUP_TYPE = 'ABSENCE_CATEGORY'
			  AND  ENABLED_FLAG = 'Y'
			  AND  LOOKUP_CODE = p_absence_category;
		     EXCEPTION
		        WHEN OTHERS THEN
			       l_abs_cat_meaning := null;
		     END;
		p_input_value_name5 := 'Absence Category';
		p_input_value5	    := 	l_abs_cat_meaning;

		--p_input_value5	    := 	l_abs_cat_meaning;
		p_input_value_name6 := 'CREATOR_ID';
		p_input_value6	    := 	p_absence_attendance_id;

		SELECT fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  INTO
		l_absence_percentage
		FROM PER_ABSENCE_ATTENDANCES PAA
          	WHERE PAA.ABSENCE_ATTENDANCE_ID =p_absence_attendance_id;

		p_input_value_name7 := 'Absence Percentage';
		p_input_value7	    := 	l_absence_percentage;


		/*GET_WEEKEND_PUBLIC_HOLIDAYS(p_assignment_id
                            ,fnd_date.date_to_chardate(p_input_value1)
			    ,fnd_date.date_to_chardate(p_input_value2)
			    ,nvl(l_start_time,l_start_time_char)
			    ,nvl(l_end_time,l_end_time_char)
			    ,l_weekends
    			    ,l_public_holidays
    			    ,l_Total_absence_days);

  	       p_input_value3	    := 	l_Total_absence_days;
	       p_input_value7	    := 	l_Total_absence_days-(l_weekends+l_public_holidays);*/
    END IF;

-- Return Y indicating to process the element for the input assignment id.
RETURN 'Y';
END Element_populate;

PROCEDURE GET_WEEKEND_PUBLIC_HOLIDAYS(p_assignment_id in number
	,P_START_DATE in varchar2
	,P_END_DATE in varchar2
	,p_start_time in varchar2
	,p_end_time in varchar2
	,p_weekends OUT	NOCOPY NUMBER
	,p_public_holidays OUT NOCOPY NUMBER
	,p_Total_holidays OUT NOCOPY NUMBER
	) IS

l_return_frm_wrk_schd number;

l_DAYS_WTH_PUBLIC NUMBER;
l_DAYS_WTHOUT_PUBLIC NUMBER;

l_TOTAL_DAYS number;
l_CURRENT_PUBLIC_HOLIDAYS NUMBER;
l_CURRENT_WEEKENDS NUMBER;
l_start_date date;
l_end_date  date;

CURSOR get_total_days(csr_end_date date,csr_start_date date)
is
select floor(csr_end_date-csr_start_date) from dual;
--  select (TO_DATE(P_END_DATE)	||' '||replace(trim(to_char(p_end_time,'00.00')),'.',':'),'DD-MM-YYYY HH24:MI')) from dual;

--  select floor(TO_DATE(TO_DATE(P_END_DATE) ||' '||replace(trim(to_char(p_end_time,'00.00')),'.',':'),'DD-MM-YYYY HH24:MI')-
  --TO_DATE(TO_DATE(P_START_DATE) ||' '||replace(trim(to_char(p_start_time,'00.00')),'.',':'),'DD-MM-YYYY HH24:MI'))  from dual;

CURSOR get_time_format(l_time varchar2)	is
SELECT replace(trim(l_time),':','.') FROM dual;

  l_start_time	    VARCHAR2(5);
  l_end_time	    VARCHAR2(5);

BEGIN

-- Get Total days including Public Holidays including Weekends
--l_TOTAL_DAYS := 5.5;
--l_TOTAL_DAYS := to_number(floor(TO_DATE(TO_DATE(P_END_DATE) ||' '||to_char(p_end_time),'DD-MM-YYYY HH24:MI')-	TO_DATE(TO_DATE(P_START_DATE) ||' '||to_char(p_start_time),'DD-MM-YYYY HH24:MI')));
OPEN get_time_format(p_start_time);
	FETCH	get_time_format	INTO l_start_time;
CLOSE	get_time_format;

OPEN get_time_format(p_end_time);
	FETCH	get_time_format	INTO l_end_time;
CLOSE	get_time_format;

l_start_date :=	TO_DATE(TO_CHAR(TO_DATE(P_START_DATE,'DD-MON-YYYY'),'DD-MM-YYYY')||' '||l_start_time,'DD-MM-YYYY HH24:MI');
l_end_date := TO_DATE(TO_CHAR(TO_DATE(p_end_date,'DD-MON-YYYY'),'DD-MM-YYYY')||' '||l_end_time,'DD-MM-YYYY HH24:MI');

OPEN  get_total_days(l_end_date,l_start_date);
	FETCH get_total_days INTO l_TOTAL_DAYS;
CLOSE get_total_days;

-- Get Total days including Public Holidays exculding Weekends
l_return_frm_wrk_schd := hr_loc_work_schedule.calc_sch_based_dur
				( p_assignment_id,
				'D',
				'Y',
				P_START_DATE,
				P_END_DATE,
				l_start_time,
				l_end_time,
				l_DAYS_WTH_PUBLIC
				);

-- Get Total days Excluding Public Holidays exculding Weekends
l_return_frm_wrk_schd := hr_loc_work_schedule.calc_sch_based_dur
				( p_assignment_id,
				'D',
				'N',
				P_START_DATE,
				P_END_DATE,
				l_start_time,
				l_end_time,
				l_DAYS_WTHOUT_PUBLIC
				);

l_CURRENT_PUBLIC_HOLIDAYS := l_DAYS_WTH_PUBLIC - l_DAYS_WTHOUT_PUBLIC;
l_CURRENT_WEEKENDS:= l_TOTAL_DAYS - l_DAYS_WTH_PUBLIC;

p_weekends	  :=l_CURRENT_WEEKENDS;
p_public_holidays :=l_CURRENT_PUBLIC_HOLIDAYS;
p_Total_holidays  :=l_TOTAL_DAYS;




END GET_WEEKEND_PUBLIC_HOLIDAYS;

Function holiday_Element_populate(p_assignment_id         in number,
                p_person_id 		in number,
		p_absence_attendance_id in number,
		p_element_type_id 	in number,
		p_absence_category 	in varchar2,
		p_original_entry_id     OUT NOCOPY NUMBER,
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
		p_input_value15	    	OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

l_start_date            date;
l_end_date              date;
l_days                  number;
l_hours                 number;
l_absent_reason         number;
l_start_time            varchar2(5);
l_end_time              varchar2(5);
l_abs_cat_meaning       varchar2(100);
l_ABS_TYPE    varchar2(240);
l_ABS_CATEGORY  varchar2(240);
l_wrk_schd_return number;
l_wrk_duration number;
l_start_time_char varchar2(5) := '00:00';
l_end_time_char varchar2(5) := '23:59';
l_Absence_Percentage Number(10);
l_wrk_start_date date;

l_absence_start_date date;
l_absence_end_date   date;

l_weekends number;
l_public_holidays number;
l_Total_absence_days number;


CURSOR CSR_GET_ABSENCE  is   SELECT PAAT.NAME,--             PAAT.ABSENCE_ATTENDANCE_TYPE_ID,
             PAAT.ABSENCE_CATEGORY,
             PAA.date_start,
             PAA.date_end,
             PAA.absence_Days,
             PAA.absence_Hours,
             PAA.TIME_START,
             PAA.TIME_END,
             PAA.ABS_INFORMATION3
             FROM   per_absence_attendances      PAA,
	     per_absence_attendance_types PAAT
             WHERE  PAA.absence_attendance_id      = p_absence_attendance_id
             and PAA.ABSENCE_ATTENDANCE_TYPE_ID    =PAAT.ABSENCE_ATTENDANCE_TYPE_ID   ;

row_get_absence CSR_GET_ABSENCE%ROWTYPE;

CURSOR CSR_GET_ABCAT  is   SELECT MEANING
	     FROM   HR_LOOKUPS
	     WHERE  LOOKUP_TYPE = 'ABSENCE_CATEGORY'
             AND  ENABLED_FLAG = 'Y'
	     AND  LOOKUP_CODE = p_absence_category;

ROW_GET_ABCAT CSR_GET_ABCAT%ROWTYPE;



BEGIN

-- Fetch absence attendance details
OPEN  CSR_GET_ABSENCE;
	FETCH CSR_GET_ABSENCE INTO row_get_absence;
CLOSE CSR_GET_ABSENCE;

l_ABS_TYPE   := row_get_absence.NAME;
l_ABS_CATEGORY := row_get_absence.ABSENCE_CATEGORY;
l_start_date :=row_get_absence.date_start;
l_end_date :=row_get_absence.date_end;
l_days :=row_get_absence.absence_Days;
l_hours :=row_get_absence.absence_Hours;
l_Absence_Percentage :=row_get_absence.ABS_INFORMATION3;
l_start_time := row_get_absence.TIME_START;
l_end_time := row_get_absence.TIME_END ;


		     -- To select absence category meaning by passing code
OPEN  CSR_GET_ABCAT;
	FETCH CSR_GET_ABCAT INTO row_GET_ABCAT;
CLOSE CSR_GET_ABCAT;

l_abs_cat_meaning :=ROW_GET_ABCAT.MEANING;


    -- Check if absence category is S ( Sickness )
IF p_absence_category in ('V') THEN
        p_input_value_name1 := 'Absence Category';
	p_input_value1	    := 	l_abs_cat_meaning;

--        p_input_value_name2 := 'Absence Type';
--		p_input_value2	    := 	l_ABS_TYPE;

        p_input_value_name2 := 'Absence Percentage';
	p_input_value2	    := 	l_Absence_Percentage;

        p_input_value_name3 := 'Start Date';
	p_input_value3	    := 	l_start_date;

        p_input_value_name4 := 'End Date';
	p_input_value4	    := 	l_end_date;

	p_input_value_name5 := 'Days';
	p_input_value5	    := 	l_days;

	p_input_value_name6 := 'Hours';
	p_input_value6	    := 	l_hours;

	p_input_value_name7 := 'CREATOR_ID';
	p_input_value7	    := 	p_absence_attendance_id;

    END IF;


--    IF p_input_value7 IS NOT NULL or p_input_value6 IS NOT NULL
-- User entered the value manually
-- apply working perccentage and absence percentage and return
--THEN

--hr_utility.set_location(' Null ',10);
--ELSE
-- equivalent to p_input_value5 IS NULL and p_input_value6 IS NULL
/*l_absence_start_date :=fnd_date.date_to_chardate(p_input_value3);
l_absence_end_date   := fnd_date.date_to_chardate(p_input_value4);

--send starting date,time  and ending date,time to get weekends and public holidays
GET_WEEKEND_PUBLIC_HOLIDAYS(p_assignment_id
                            ,fnd_date.date_to_chardate(p_input_value3)
			    ,fnd_date.date_to_chardate(p_input_value4)
			    ,nvl(l_start_time,l_start_time_char)
			    ,nvl(l_end_time,l_end_time_char)
			    ,l_weekends
    			    ,l_public_holidays
    			    ,l_Total_absence_days);		   */

--END IF;

--		p_input_value5	    := 	l_Total_absence_days;


-- Return Y indicating to process the element for the input assignment id.

RETURN 'Y';

END holiday_Element_populate;

FUNCTION GET_DAYS_WITH_ABS_PERCENTAGE(
		p_date_earned in date,
		p_tax_unit_id in Number,
		p_assignment_action_id IN NUMBER,
		p_assignment_id IN NUMBER,
		p_business_group_id in NUMBER,
		p_days IN NUMBER,
		p_Absence_percentage IN Number,
		p_category_code IN VARCHAR2
		)

RETURN NUMBER IS

lr_Get_Defined_Balance_Id number;
l_generate char(1);
l_max_days number;
l_DAYS_IN_BALANCE number;
l_check_interrupted char(1);

l_absence_days NUMBER:=0;




     Cursor csr_Generate_Max_Days  IS
     SELECT hoi2.org_information2,hoi2.org_information3
     FROM HR_ORGANIZATION_UNITS hou
     ,HR_ORGANIZATION_INFORMATION hoi1
     ,HR_ORGANIZATION_INFORMATION hoi2
    WHERE hou.organization_id =p_tax_unit_id
    AND	hoi1.organization_id = hou.organization_id
    AND	hoi1.org_information_context = 'CLASS'
    AND hoi1.ORG_INFORMATION1='HR_LEGAL_EMPLOYER'
    AND	hoi2.ORG_INFORMATION_CONTEXT='SE_ABSENCE_CATEGORY_LIMIT'
    AND	hoi1.organization_id = hoi2.organization_id
    AND	hoi2.org_information1 IS NOT NULL
    AND hoi2.org_information1=p_category_code;

/*     SELECT hoi4.ORG_INFORMATION2,hoi4.ORG_INFORMATION3
     FROM HR_ORGANIZATION_UNITS o1
    ,HR_ORGANIZATION_INFORMATION hoi1
    ,HR_ORGANIZATION_INFORMATION hoi2
    ,HR_ORGANIZATION_INFORMATION hoi3
    ,HR_ORGANIZATION_INFORMATION hoi4
    ,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
    FROM PER_ALL_ASSIGNMENTS_F ASG
    ,HR_SOFT_CODING_KEYFLEX SCL
    WHERE ASG.ASSIGNMENT_ID = p_assignment_id
    AND	ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
    AND	p_date_earned BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE ) X
    WHERE o1.business_group_id = l_business_group_id
    AND	hoi1.organization_id = o1.organization_id
    AND	hoi1.organization_id = X.ORG_ID
    --AND	hoi1.org_information1 =	'SE_LOCAL_UNIT'
    AND	hoi1.org_information_context = 'CLASS'
    AND	o1.organization_id = hoi2.org_information1
    AND	hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
    AND	hoi2.organization_id =	hoi3.organization_id
    AND	hoi3.ORG_INFORMATION_CONTEXT='CLASS'
    AND	hoi3.org_information1 =	'HR_LEGAL_EMPLOYER'
    AND	hoi3.organization_id = hoi4.organization_id
    AND	hoi4.ORG_INFORMATION_CONTEXT='SE_ABSENCE_CATEGORY_LIMIT'
    AND	hoi4.org_information1 IS NOT NULL
    AND hoi4.org_information1=p_category_code;
*/
Cursor csr_Earning_Year is
	SELECT	substr(hoi2.ORG_INFORMATION2,4,2)
	FROM	HR_ORGANIZATION_UNITS o1
	,HR_ORGANIZATION_INFORMATION hoi1
	,HR_ORGANIZATION_INFORMATION hoi2
	WHERE
	hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id = p_tax_unit_id
	AND hoi1.ORG_INFORMATION_CONTEXT='CLASS'
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.organization_id = hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='SE_HOLIDAY_YEAR_DEFN'
	AND hoi2.org_information1 IS NOT NULL;

	Cursor csr_Get_Defined_Balance_Id(csr_v_Balance_Name FF_DATABASE_ITEMS.USER_NAME%TYPE) IS
      SELECT	  ue.creator_id
      FROM     ff_user_entities	 ue,
      ff_database_items	di
      WHERE	di.user_name = csr_v_Balance_Name
      AND     ue.user_entity_id	= di.user_entity_id
      AND     ue.legislation_code = 'SE'
      AND     ue.business_group_id is NULL
      AND     ue.creator_type =	'B';


BEGIN
		/*Check for the interruption of Sick Pay*/
	        l_check_interrupted:=CHECK_SICK_INTERUPTED(p_date_earned,p_assignment_id,p_tax_unit_id,p_business_group_id,p_category_code);

		IF  l_check_interrupted='Y' THEN
		/*If the sick leave is interupted*/
			OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_ABSENCE_DAYS_HOLIDAY_PAY_ASG_LE_ABS_CAT_HY_YEAR');
				FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
			CLOSE csr_Get_Defined_Balance_Id;

			pay_balance_pkg.set_context('SOURCE_TEXT',p_category_code);
			pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID',p_assignment_action_id);
			pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);

			l_DAYS_IN_BALANCE := pay_balance_pkg.get_value(
			P_DEFINED_BALANCE_ID      => lr_Get_Defined_Balance_Id,
			P_ASSIGNMENT_ACTION_ID    =>  p_assignment_action_id,
			P_TAX_UNIT_ID             => p_tax_unit_id,
			P_JURISDICTION_CODE       => null,
			P_SOURCE_ID               => null,
			P_SOURCE_TEXT             =>p_category_code,
			P_TAX_GROUP               => null,
			P_DATE_EARNED             =>p_date_earned  );

			OPEN csr_Generate_Max_Days;
				FETCH csr_Generate_Max_Days INTO l_generate,l_max_days;
			CLOSE csr_Generate_Max_Days;

	l_absence_days := 0;
			/* If generate is Y
		then value greater than the max is considered as absence,
		else whole value */
		IF l_generate='Y' THEN
		    /* If the Maxmimum days for this category has been already exceeded
		    In that case apply the absence percentage directly and return */
		    IF l_DAYS_IN_BALANCE+p_days <= l_max_days
		    THEN
					l_absence_days := p_days;
		    ELSIF l_DAYS_IN_BALANCE>=l_max_days THEN
		    /*When the absence has already crossed the limit in previous period*/
		          l_absence_days := round(p_days*p_Absence_percentage/100);
		    ELSE
		    /* Find the no of days with 100 perc tobe added to balance
		    till it exceeds Max days
		    for the rest , abscence percentage to be applied.            */
			l_absence_days := abs(l_max_days - l_DAYS_IN_BALANCE);
			l_absence_days := l_absence_days + round(abs(p_days - l_absence_days)*p_Absence_percentage/100);

		    END IF;
		ELSE
		/* If the generate is not set to 'Y' then consider the total absence days without applying absence percentage*/
			--l_absence_days:=l_absence_days + l_DAYS_IN_BALANCE;
			l_absence_days := p_days;
	        END IF;
	ELSE

	/*If the sick leave is not interupted*/
	l_absence_days := p_days;
	END if;

return l_absence_days;

END GET_DAYS_WITH_ABS_PERCENTAGE;

FUNCTION CHECK_SICK_INTERUPTED(p_date_earned IN date,
		p_assignment_id IN NUMBER,
		p_tax_unit_id IN NUMBER,
		p_business_group_id in NUMBER,
		p_category_code IN VARCHAR2
		)
RETURN VARCHAR2
IS
l_end_month NUMBER;
l_earn_year NUMBER;
l_earning_end_date DATE;
l_earning_start_date DATE;
l_prev_end_date DATE;
l_return VARCHAR2(1);
l_counter NUMBER:=0;

CURSOR csr_sick_interrupted(csr_v_assignment_id NUMBER,
csr_v_effective_date DATE,
csr_v_earn_start_date DATE,
csr_v_category_code VARCHAR2 ) --,
--csr_v_earn_end_date DATE)
IS
SELECT fnd_date.canonical_to_date(peevf1.SCREEN_ENTRY_VALUE) start_date
,fnd_date.canonical_to_date(peevf2.SCREEN_ENTRY_VALUE) end_date
,fnd_number.canonical_to_number(peevf4.SCREEN_ENTRY_VALUE) Absence_Percentage
FROM   per_all_assignments_f      paaf
,pay_element_types_f	      et
,pay_element_entries_f      ee
,pay_element_entry_values_f peevf1
,pay_element_entry_values_f peevf2
,pay_element_entry_values_f peevf3
,pay_element_entry_values_f peevf4
,pay_input_values_f pivf1
,pay_input_values_f pivf2
,pay_input_values_f pivf3
,pay_input_values_f pivf4
WHERE  paaf.assignment_id=csr_v_assignment_id
AND csr_v_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
AND et.element_name= 'Sickness Details'
AND et.legislation_code= 'SE'
AND ee.assignment_id= paaf.assignment_id
AND ee.ELEMENT_TYPE_ID=et.ELEMENT_TYPE_ID
AND ee.ELEMENT_ENTRY_ID=peevf1.ELEMENT_ENTRY_ID
AND pivf1.element_type_id= et.element_type_id
AND pivf1.name='Start Date'
AND peevf1.input_value_id=pivf1.input_value_id
and ee.ELEMENT_ENTRY_ID=peevf2.ELEMENT_ENTRY_ID
AND pivf2.element_type_id=et.element_type_id
AND pivf2.name='End Date'
AND peevf2.input_value_id=pivf2.input_value_id
AND ee.ELEMENT_ENTRY_ID =peevf3.ELEMENT_ENTRY_ID
AND pivf3.element_type_id=et.element_type_id
AND pivf3.name='Absence Category'
AND peevf3.input_value_id=pivf3.input_value_id
AND peevf3.SCREEN_ENTRY_VALUE=csr_v_category_code
AND ee.ELEMENT_ENTRY_ID=peevf4.ELEMENT_ENTRY_ID
AND pivf4.element_type_id=et.element_type_id
AND pivf4.name='Absence Percentage'
AND peevf4.input_value_id=pivf4.input_value_id
AND ee.effective_start_date<=csr_v_effective_date
AND ee.effective_end_date>=csr_v_earn_start_date
AND peevf1.effective_start_date<=csr_v_effective_date
AND peevf1.effective_end_date>=csr_v_earn_start_date
AND peevf2.effective_start_date<=csr_v_effective_date
AND peevf2.effective_end_date>=csr_v_earn_start_date
AND peevf3.effective_start_date<=csr_v_effective_date
AND peevf3.effective_end_date>=csr_v_earn_start_date
AND peevf4.effective_start_date<=csr_v_effective_date
AND peevf4.effective_end_date>=csr_v_earn_start_date
ORDER BY fnd_date.canonical_to_date(peevf1.SCREEN_ENTRY_VALUE);

CURSOR csr_end_earn_month(csr_v_assignment_id NUMBER,
csr_v_effective_date DATE,
csr_v_business_group_id NUMBER)
IS
SELECT substr(hoi4.ORG_INFORMATION2,4,2)
FROM HR_ORGANIZATION_UNITS o1
,HR_ORGANIZATION_INFORMATION hoi1
,HR_ORGANIZATION_INFORMATION hoi2
,HR_ORGANIZATION_INFORMATION hoi3
,HR_ORGANIZATION_INFORMATION hoi4
,( SELECT TRIM(SCL.SEGMENT2) AS ORG_ID
FROM PER_ALL_ASSIGNMENTS_F ASG
,HR_SOFT_CODING_KEYFLEX SCL
WHERE ASG.ASSIGNMENT_ID	= csr_v_assignment_id
AND ASG.SOFT_CODING_KEYFLEX_ID = SCL.SOFT_CODING_KEYFLEX_ID
AND csr_v_effective_date BETWEEN ASG.EFFECTIVE_START_DATE	AND ASG.EFFECTIVE_END_DATE ) X
WHERE o1.business_group_id = csr_v_business_group_id
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
AND hoi4.ORG_INFORMATION_CONTEXT='SE_HOLIDAY_YEAR_DEFN'
AND hoi4.org_information1 IS NOT NULL;

BEGIN
/*Get the Earn Year end date*/
l_earn_year:=PAY_SE_HOLIDAY_PAY.Get_Earning_Year(p_date_earned,p_tax_unit_id);
OPEN csr_end_earn_month(p_assignment_id,p_date_earned,p_business_group_id);
	FETCH csr_end_earn_month INTO l_end_month;
CLOSE csr_end_earn_month;
l_earning_end_date:=last_day(to_date('01/'||l_end_month|| '/' ||l_earn_year,'dd/mm/yyyy'));
/*find the starting date of the holiday year two years back*/
l_earning_start_date:=add_months(l_earning_end_date,-24)+1;
/*check for the sick pay whether it is interrupted*/
FOR csr_sick IN csr_sick_interrupted(p_assignment_id,l_earning_end_date,l_earning_start_date,p_category_code) LOOP
	l_counter:=l_counter+1;
	IF (csr_sick.start_date-(l_prev_end_date+1))>14 OR ((csr_sick.start_date-l_earning_start_date)>14 AND l_counter=1) OR (csr_sick.Absence_Percentage<>100) THEN
		l_return:='Y';
		EXIT;
	END IF;
        l_prev_end_date:=csr_sick.end_date;
END LOOP csr_sick_interrupted;

IF l_return IS NULL THEN
	l_return:='N';
END IF;
RETURN l_return;
END CHECK_SICK_INTERUPTED;

END PAY_SE_ABSENCE_USER;


/
