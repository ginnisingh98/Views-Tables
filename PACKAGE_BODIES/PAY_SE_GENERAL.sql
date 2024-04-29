--------------------------------------------------------
--  DDL for Package Body PAY_SE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_GENERAL" AS
/* $Header: pysegen.pkb 120.5 2007/02/13 05:53:49 rravi noship $ */
 --
 /*
----------------------------------------------------------------------------

	FUNCTION NAME	: get_Tax_Amount
	PARAMATERS	:
			  p_DATE_EARNED		Date on which the payroll run
			  p_ASSIGNMENT_ID	Assignment Id of the person

	PURPOSE		: To get Tax Amount.
	EXCEPTIONS
	HANDLED		: When Date of Birth not found Age is
			  assigned to Zero.
----------------------------------------------------------------------------

*/
  FUNCTION get_Tax_Amount
  		(
                 p_DATE_EARNED 		in  Date,
                 p_ASSIGNMENT_ID      	in  Number,
                 p_Period_Type  	in  varchar2,
                 p_Tax_Table_No 	in  Number,
                 p_Taxable_Base 	in  Number,
                 p_Tax_Column   	in  Number
                 )
                     RETURN Number
IS


	 l_amount1 PAY_RANGES_F.amount1%type;
	 l_amount2 PAY_RANGES_F.amount1%type;
 	 l_amount3 PAY_RANGES_F.amount1%type;
	 l_amount4 PAY_RANGES_F.amount1%type;
 	 l_amount5 PAY_RANGES_F.amount1%type;

	 cursor csr_amount(ROM char,PERIOD Number,Tax_Base Number)
	 is
	    select amount1,amount2,amount3,amount4,amount5
	    INTO  l_amount1,l_amount2,l_amount3,l_amount4,l_amount5
	    from  pay_range_tables_f PRTF ,pay_ranges_f PRF,per_all_assignments_f  PAAF
	    where PAAF.ASSIGNMENT_ID = p_ASSIGNMENT_ID
            --and   PAAF.BUSINESS_GROUP_ID =  PRTF.BUSINESS_GROUP_ID
            and   PRTF.LEGISLATION_CODE='SE'
            and   PRTF.range_table_id = PRF.range_table_id
	    and   PRTF.range_table_number = TO_NUMBER(TO_CHAR(p_Tax_Table_No))
	    and   PRTF.period_frequency = PERIOD
	    and   PRTF.row_value_uom = ROM
	    and   Tax_Base
	                   between PRF.low_band
	                   and     PRF.high_band
	    and     p_DATE_EARNED between
	                                  PRTF.EFFECTIVE_START_DATE
	                              and PRTF.EFFECTIVE_END_DATE
	    and     p_DATE_EARNED between
	                                  PAAF.EFFECTIVE_START_DATE
	                              and PAAF.EFFECTIVE_END_DATE
	    and     p_DATE_EARNED between
	                                  PRF.EFFECTIVE_START_DATE
	                              and PRF.EFFECTIVE_END_DATE;


	cursor csr_Get_Age
	is
	    select  floor((months_between(TRUNC(p_DATE_EARNED,'yyyy') ,PAPF.DATE_OF_BIRTH ))/12)
	    from    per_all_assignments_f  PAAF,per_all_people_f PAPF
	    where   PAAF.ASSIGNMENT_ID =p_ASSIGNMENT_ID
	    and     PAAF.PERSON_ID = PAPF.PERSON_ID
	    and     PAAF.BUSINESS_GROUP_ID= PAPF.BUSINESS_GROUP_ID
	    and     p_DATE_EARNED between
	                                  PAPF.EFFECTIVE_START_DATE
	                              and PAPF.EFFECTIVE_END_DATE
	    and     p_DATE_EARNED between
	                                  PAAF.EFFECTIVE_START_DATE
	                              and PAAF.EFFECTIVE_END_DATE;


	 l_csr_amount       csr_amount%rowtype;
	 l_Period_Frequency Number;
	 l_Not_found        Number;
	 l_Age              Number;
	 l_Return           Number;
	 l_Taxable_Base     Number;
	 l_NO_RECORD        Number; -- Tax Table Number is Null so return Zero
 BEGIN
            -- Flag to find that value cant be find for the tax table given
            l_NO_RECORD := 0;

	    /* flag to find if the row found or not */
	    l_Not_found := 0;

	    /* Check to find out 14 0r 30 Using the Period Type */
	    IF p_Period_Type in ('Bi-Week','Week')
	    THEN
	    	l_Period_Frequency := 14;
	    ELSIF p_Period_Type in ('Calendar Month','Bi-Month')
	    THEN
	    	l_Period_Frequency := 30;
	     END IF;
	/*Adjusting the Taxable base if Pay Period type is Week or Bi-Month*/
         IF p_Period_Type='Week'
	     then l_Taxable_Base:=p_Taxable_Base*2;
	     elsif p_Period_Type='Bi-Month'
	     then l_Taxable_Base:=p_Taxable_Base/2;
	     else l_Taxable_Base:=p_Taxable_Base;
         end if;

	 /* first pick up with the B type if anything found Use this If not set the flag to not found*/
	    open  csr_amount('B',l_Period_Frequency,l_Taxable_Base);
	        fetch csr_amount into l_csr_amount;
	        IF csr_amount%NOTFOUND THEN
	            l_Not_found := 1;
		    END IF;
	    close csr_amount;

	    /* If the flag is set to not found then try with % Type */
	    IF    l_Not_found = 1
	    THEN
	        open  csr_amount('%',l_Period_Frequency,l_Taxable_Base);
	            fetch csr_amount into l_csr_amount;
	             IF csr_amount%NOTFOUND THEN
	               l_NO_RECORD := 1;
		     END IF;
	        close csr_amount;

	    END IF;
      IF l_NO_RECORD = 0
      THEN
	/* Calculate the Age Here */


	    OPEN  csr_Get_Age;
	        FETCH csr_Get_Age INTO l_Age;
	        IF csr_Get_Age%NOTFOUND THEN
			l_Age := 0;
		END IF;
	    CLOSE csr_Get_Age;


	    /* Check For Age*/
	    /* Age less than or equal to 65 */
	    IF l_Age <=65
	    THEN
	        l_Return := l_csr_amount.amount1;
	    /*ELSE
	        l_Return := l_csr_amount.amount2;*/
	    /* Age between 66 and 69 */
	    ELSIF l_Age <70 THEN
		l_Return := l_csr_amount.amount3;
	    /* Age 70 and above */
	    ELSE
		l_Return := l_csr_amount.amount4;
	    END IF;

	    /* Check for Default Tax Column. It Overrides the calculation based on age*/
	    IF p_Tax_Column='1'
	    THEN
	        l_Return := l_csr_amount.amount1;
	    ELSIF p_Tax_Column='2' THEN
		l_Return := l_csr_amount.amount3;
	    ELSIF p_Tax_Column='3' THEN
		l_Return := l_csr_amount.amount4;
	    /*END IF;
	    IF p_Tax_Column='2'
	    THEN
	        l_Return := l_csr_amount.amount2;*/
	    END IF;

	    /* Calculate the Taxable value on that Taxable Base */
	    IF l_Not_found = 1
	    THEN
	        l_Return := (l_Return * p_Taxable_Base)/100;
	    END IF;

	    /*Check for the Weekly and Bi-Monthly Pay period*/
           IF p_Period_Type='Week'
           THEN
              l_Return :=l_Return/2;
           ELSIF p_Period_Type='Bi-Month'
           THEN
             l_Return:=l_Return*2;
           END IF;

      ELSE
           l_Return  := 0; -- As no record found for the given combination of TT no,Period freq.etc...
      END IF; -- No record If stmt

    return l_Return;


 end get_Tax_Amount;

 /*
----------------------------------------------------------------------------

	FUNCTION NAME	: get_Tax_Card_Details
	PARAMATERS	:
			  p_ASSIGNMENT_ID	Assignment Id of the person
	                  p_DATE_EARNED 		Date

	PURPOSE		: To get Details of Tax Card.
	EXCEPTIONS
	HANDLED		: None.

----------------------------------------------------------------------------

*/
 FUNCTION get_tax_card_details
		(

		P_ASSIGNMENT_ID        IN	NUMBER
                ,p_DATE_EARNED 		IN  DATE
		,p_tax_card_type	OUT     NOCOPY VARCHAR2
		,p_Tax_Percentage	OUT 	NOCOPY NUMBER
		,p_Tax_Table_Number	OUT 	NOCOPY NUMBER
		,p_Tax_Column         	OUT     NOCOPY VARCHAR2
 		,p_Tax_Free_Threshold	OUT	NOCOPY NUMBER
 		,p_Calculation_Code 	OUT 	NOCOPY VARCHAR2
 		,p_Calculation_Sum 	OUT 	NOCOPY NUMBER
		 )
		 RETURN NUMBER
 IS
  --
  CURSOR get_details(csr_v_input_value VARCHAR2  ) IS
  SELECT eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = P_ASSIGNMENT_ID
     AND p_DATE_EARNED BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_DATE_EARNED BETWEEN per.effective_start_date AND per.effective_end_date
     AND p_DATE_EARNED BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Tax Card'
     AND  et.legislation_code   = 'SE'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = csr_v_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_DATE_EARNED BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_DATE_EARNED BETWEEN eev1.effective_start_date AND eev1.effective_end_date;


	  l_rec get_details%ROWTYPE;
	  l_Not_found        Number;
  --
 BEGIN
	    /* flag to find if the row found or not */
	    l_Not_found := 0;
	  --
	  OPEN  get_details('Tax Card Type');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;
	  --

	  p_tax_card_type         	:= l_rec.screen_entry_value;

	  	  OPEN  get_details('Tax Percentage');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;

	  p_Tax_Percentage          	:= NVL(l_rec.screen_entry_value,0);

	   OPEN  get_details('Tax Table Number');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;
	  p_Tax_Table_Number		:=NVL(l_rec.screen_entry_value,0);


	     OPEN  get_details('Tax Column');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;
	  p_Tax_Column			:= l_rec.screen_entry_value;

	  	     OPEN  get_details('Tax Free Threshold');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;

	  p_Tax_Free_Threshold		:=NVL(l_rec.screen_entry_value,0);

	  	  	     OPEN  get_details('Calculation Code');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;
	  p_Calculation_Code		:= NVL(l_rec.screen_entry_value,0);

	  	  	  	     OPEN  get_details('Calculation Sum');
	  FETCH get_details INTO l_rec;
		IF get_details%NOTFOUND THEN
	            l_Not_found := 0;
		ELSE
	            l_Not_found := 1;
		END IF;
	  CLOSE get_details;
	  p_Calculation_Sum		:= NVL(l_rec.screen_entry_value,0);
  --
  RETURN l_Not_found;
 EXCEPTION
	WHEN OTHERS THEN
	RETURN 0 ;
  --
 END get_tax_card_details;

  FUNCTION Get_no_of_payroll
                (
                 p_PAYROLL_ID     in Number,
                 p_EMP_START_DATE in Date,
		  p_CURR_PAY_END_DATE iN date
                )
           RETURN Number
IS

CURSOR csr_first_end_date
IS
select end_date from per_time_periods
where payroll_id = p_PAYROLL_ID
and to_char(end_date,'YYYY') = to_char(p_CURR_PAY_END_DATE,'YYYY')
and rownum < 2
order by end_date;

cursor csr_Get_pay_run(l_mdate date,l_first_end_date date)
	is
select count(*) from per_time_periods
where payroll_id = p_PAYROLL_ID
and to_char(end_date,'YYYY') = to_char(l_first_end_date,'YYYY')
and p_CURR_PAY_END_DATE >= end_date --DBI Item, Current Payroll End Date
and l_mdate <= end_date; --Variable, Current Year First Period End Date OR Join Date, whichever is Max

l_payroll_run number;
l_max_date date;
l_first_pay_end_date date;

Begin

 open  csr_first_end_date ;
       fetch csr_first_end_date into l_first_pay_end_date;
 close csr_first_end_date ;

IF p_EMP_START_DATE >= l_first_pay_end_date
THEN
l_max_date  := p_EMP_START_DATE;
ELSE
l_max_date  := l_first_pay_end_date;
END IF;

 open  csr_Get_pay_run(l_max_date,l_first_pay_end_date) ;
       fetch csr_Get_pay_run into l_payroll_run;
       IF csr_Get_pay_run%NOTFOUND THEN
           l_payroll_run := 0;
       END IF;
close csr_Get_pay_run ;

return l_payroll_run;
END Get_no_of_payroll;

FUNCTION Get_Absence_Detail(
		p_ASG_Id	IN 	Number,
		p_Effective_Date IN	Date,
		p_ASG_Absent_days	IN	Number,
		p_ASG_Absent_hours IN	Number,
		p_Gross_Pay_ASG_Run IN  Number
			   )
		RETURN NUMBER IS

Cursor csr_Hourly_Salaried
(
	p_ASG_Id Number,
	p_Effective_Date Date,
	p_ASG_Absent_days Number,
	p_ASG_Absent_hours Number
)
IS
select Hourly_Salaried_Code,segment9 from
per_all_assignments_f paaf,
hr_soft_coding_keyflex hsck
where
paaf.assignment_id= p_ASG_id  --20805
and paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
and p_Effective_Date between
paaf.effective_start_date and paaf.effective_end_date;

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



l_Mtly_Hrly_Emp Char(1);
--l_Work_Perc_Emp Number;
l_NOR_Days_Month Number;
l_NOR_Days_Week Number;
--l_return=-1
--l_shift_duration Number;
l_pattern_length Number;
l_working_days Number;
l_working_hours Number;
l_deduction_working_day Number;
l_deduction_working_hours Number;
l_absence_deduction_amount Number;
l_deduction_calendar_day Number;
l_schedule_id Number;
l_template_id Number;
l_shift_duration Number;
l_Working_Perc Number;
l_Monthly_Salary Number;

BEGIN
l_Monthly_Salary:=p_Gross_Pay_ASG_Run;

OPEN csr_get_schedule_id(NULL, 'PERSON_ASSIGNMENT', p_ASG_id,trunc(p_effective_date,'MON'),p_effective_date);
	FETCH csr_get_schedule_id INTO l_schedule_id;
CLOSE csr_get_schedule_id;

OPEN csr_get_template_details(l_schedule_id);
	FETCH csr_get_template_details --.Template_Id,csr_get_template_details.TEMPLATE_LENGTH_DAYS
	INTO l_template_id,l_pattern_length;
CLOSE csr_get_template_details;

OPEN csr_get_shift_duration(l_template_id);
	FETCH csr_get_shift_duration INTO l_shift_duration;
CLOSE csr_get_shift_duration;

IF (l_pattern_length=5) THEN
	l_NOR_Days_Month:=21;
	l_NOR_Days_Week:=5;
ELSIF (l_pattern_length=6) THEN
	l_NOR_Days_Month:=25;
	l_NOR_Days_Week:=6;
END IF;

IF (p_ASG_Absent_days=l_NOR_Days_Month) THEN
	l_absence_deduction_amount:=l_Monthly_Salary;
	RETURN l_absence_deduction_amount;
END IF;
OPEN csr_Hourly_Salaried(p_ASG_Id,p_Effective_Date,p_ASG_Absent_days,p_ASG_Absent_hours );
	FETCH csr_Hourly_Salaried INTO l_Mtly_Hrly_Emp,l_Working_Perc;
CLOSE csr_Hourly_Salaried;

IF l_Mtly_Hrly_Emp='S' THEN
	IF l_working_perc=0 THEN
		IF p_ASG_absent_days<=5 THEN
			l_deduction_working_day:=l_Monthly_Salary/l_NOR_Days_Month;
			l_absence_deduction_amount:=l_deduction_working_day * p_Asg_Absent_days;
		ELSE
			l_deduction_calendar_day:=l_Monthly_Salary *12/365;
			l_absence_deduction_amount:=l_deduction_calendar_day * p_Asg_Absent_days;
		END IF;
	ELSE
		l_deduction_working_day:=l_Monthly_Salary/((l_NOR_Days_Week/(l_working_perc/100*l_NOR_Days_Week))
		* l_NOR_Days_Month);
		l_absence_deduction_amount:=l_deduction_working_day * p_ASG_Absent_days;
	END IF;
ELSE
	IF (l_NOR_Days_Week * l_shift_duration)=40 THEN
		l_deduction_working_hours:=l_Monthly_Salary/175;
		l_absence_deduction_amount:=l_deduction_working_hours* p_ASG_Absent_hours;
	END IF;
END IF;
RETURN l_absence_deduction_amount;
END Get_Absence_Detail;



 END pay_se_general;

/
