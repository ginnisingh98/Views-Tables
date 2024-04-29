--------------------------------------------------------
--  DDL for Package Body PAY_NL_SI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_SI_PKG" AS
	/* $Header: pynlsoci.pkb 120.24.12010000.3 2008/08/06 08:01:59 ubhat ship $ */
	g_package                  varchar2(33) := '  pay_nl_si_pkg.';
	g_legislation_code         varchar2(2)  :='NL';
	g_udt_name VARCHAR2(50) := 'PQP_COMPANY_WORK_PATTERNS';
    	g_ptp_formula_exists  BOOLEAN := TRUE;
    	g_ptp_formula_cached  BOOLEAN := FALSE;
    	g_ptp_formula_id      ff_formulas_f.formula_id%TYPE;
   	    g_ptp_formula_name    ff_formulas_f.formula_name%TYPE;
  /* Global Variables for Standard SI Part Time Percentage */
     g_std_ptp_formula_exists  BOOLEAN := TRUE;
     g_std_ptp_formula_cached  BOOLEAN := FALSE;
     g_std_ptp_formula_id      ff_formulas_f.formula_id%TYPE;
   	 g_std_ptp_formula_name    ff_formulas_f.formula_name%TYPE;
  /* Global Variables for Pseudo SI Part Time Percentage */
     g_pse_ptp_formula_exists  BOOLEAN := TRUE;
     g_pse_ptp_formula_cached  BOOLEAN := FALSE;
     g_pse_ptp_formula_id      ff_formulas_f.formula_id%TYPE;
   	 g_pse_ptp_formula_name    ff_formulas_f.formula_name%TYPE;
  /* Global Variables for Standard SI Reporting Part Time Percentage */
     g_std_rep_ptp_formula_exists  BOOLEAN := TRUE;
     g_std_rep_ptp_formula_cached  BOOLEAN := FALSE;
     g_std_rep_ptp_formula_id      ff_formulas_f.formula_id%TYPE;
   	 g_std_rep_ptp_formula_name    ff_formulas_f.formula_name%TYPE;
  /* Global variables for Override Real SI Days */
     g_real_si_days_formula_exists  BOOLEAN := TRUE;
     g_real_si_days_formula_cached  BOOLEAN := FALSE;
     g_real_si_days_formula_id      ff_formulas_f.formula_id%TYPE;
     	g_real_si_days_formula_name    ff_formulas_f.formula_name%TYPE;
  /* Global Variables for Pseudo SI Reporting Part Time Percentage */
     g_pse_rep_ptp_formula_exists  BOOLEAN := TRUE;
     g_pse_rep_ptp_formula_cached  BOOLEAN := FALSE;
     g_pse_rep_ptp_formula_id      ff_formulas_f.formula_id%TYPE;
   	 g_pse_rep_ptp_formula_name    ff_formulas_f.formula_name%TYPE;
 /* Global Variables for Override SI Days */
     g_si_days_formula_exists  BOOLEAN := TRUE;
     g_si_days_formula_cached  BOOLEAN := FALSE;
     g_si_days_formula_id      ff_formulas_f.formula_id%TYPE;
     g_si_days_formula_name    ff_formulas_f.formula_name%TYPE;
     g_si_days		       NUMBER;
 /* Global Variables for Tax Proration Days */
     g_assignment_id	       per_all_assignments_f.assignment_id%TYPE;
     g_tax_proration_days      NUMBER;
     g_tax_proration_flag      VARCHAR2(1);

	cursor c_wp_dets(p_assignment_id NUMBER ) is
	select *
	from pqp_assignment_attributes_f paa,
	fnd_sessions ses
	where assignment_id = p_assignment_id
    and ses.session_id = userenv('sessionid')
    and ses.effective_date between paa.effective_start_date and paa.effective_end_date;
	--
	-- Returns the SI Status
	-- are entered for a employee
	Function get_si_status
	  ( p_assignment_id  in number,
	    p_date_earned    in date,
	    p_si_class       in    varchar2
	  ) return number IS
	  CURSOR Cur_SI_Status IS
	  SELECT paei.AEI_INFORMATION4 SI_Status,
	  paei.AEI_INFORMATION3 SI_Class,
	  DECODE(paei.AEI_INFORMATION3,'AMI',0,1) si_class_order
	  FROM
	  per_assignment_extra_info  paei
	  WHERE
	  assignment_id = p_assignment_id
	  and paei.aei_information_category='NL_SII'
	  and (paei.AEI_INFORMATION3 = p_si_class  or
	       paei.AEI_INFORMATION3 = DECODE(p_si_class,'ZFW','AMI','ZW','AMI','WW','AMI','WAO','AMI',
                                              'ZVW','AMI','WGA','AMI','IVA','AMI','UFO','AMI',p_si_class))
	  and p_date_earned between
	  FND_DATE.CANONICAL_TO_DATE(paei.AEI_INFORMATION1)
	  and nvl(FND_DATE.CANONICAL_TO_DATE(paei.AEI_INFORMATION2),hr_general.END_OF_TIME)
	  order by si_class_order desc;

      CURSOR Cur_ZVW_Excluded(p_dt_earned NUMBER)
      IS
	  SELECT nvl(paei.AEI_INFORMATION2,'N')    ZVW_Excluded
	  FROM
	  per_assignment_extra_info  paei
	  WHERE assignment_id = p_assignment_id
	  and   paei.aei_information_category='NL_EXCL_ZVW'
      and   (to_char(fnd_date.canonical_to_date(paei.AEI_INFORMATION1),'RRRR') <= p_dt_earned
             AND nvl(to_char(fnd_date.canonical_to_date(paei.AEI_INFORMATION3),'RRRR'),'4712') >= p_dt_earned);


	  vCur_SI_Status Cur_SI_Status%ROWTYPE;
      vCur_ZVW_Excluded  Cur_ZVW_Excluded%ROWTYPE;
      l_zvw_status           NUMBER;
      l_zvw_excluded         VARCHAR2(1);
      /*l_exclusion_date       VARCHAR2(4);*/
      l_date_earned          VARCHAR2(8);
	  l_proc varchar2(100) := g_package||'get_si_status';
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  hr_utility.set_location('p_assignment_id ' || p_assignment_id, 110);
	  hr_utility.set_location('p_si_class ' || p_si_class, 110);
	  hr_utility.set_location('p_date_earned ' || p_date_earned, 110);
      l_zvw_status := 1;
	  OPEN Cur_SI_Status;
	  FETCH Cur_SI_Status INTO vCur_SI_Status;
	  IF Cur_SI_Status%NOTFOUND THEN
            l_zvw_status := 0;
      END IF;
      CLOSE Cur_SI_Status;
	  -- If the

      IF p_si_class = 'ZVW' THEN
        l_date_earned := TO_CHAR(p_date_earned,'RRRR');
        OPEN Cur_ZVW_Excluded(l_date_earned);
        FETCH Cur_ZVW_Excluded INTO vCur_ZVW_Excluded;
        IF(Cur_ZVW_Excluded%NOTFOUND) THEN
          l_zvw_excluded := 'N';
         /* l_exclusion_date := l_date_earned;*/
        ELSE
          l_zvw_excluded := vCur_ZVW_Excluded.ZVW_Excluded;
         /* l_exclusion_date := vCur_ZVW_Excluded.Excluded_Year;*/
        END IF;
        CLOSE Cur_ZVW_Excluded;

        IF l_zvw_excluded = 'N' THEN
          IF l_zvw_status = 0 THEN
            RETURN -3;
          END IF;
        ELSE
          RETURN -5;
        END IF;
      END IF;

      IF (vCur_SI_Status.SI_Class='AMI' and p_si_class <>'ZFW') and
	     vCur_SI_Status.SI_Status='4' THEN
	  	 vCur_SI_Status.SI_Status:=1;
	  END IF;
	  IF vCur_SI_Status.SI_Status='4' and p_date_earned > to_date('31/12/2005', 'dd/mm/yyyy') THEN
	    	 vCur_SI_Status.SI_Status:=-4;
	  END IF;
	  IF vCur_SI_Status.SI_Status>0 and p_date_earned > to_date('31/12/2005', 'dd/mm/yyyy') and p_si_class ='ZFW' THEN
	     IF vCur_SI_Status.SI_Class='AMI' THEN
	    	 vCur_SI_Status.SI_Status:=0;
    	     ELSE
    	 	 vCur_SI_Status.SI_Status:=-1;
    	     END IF;
	  END IF;
 	  IF nvl(vCur_SI_Status.SI_Status, 0)<=0 and p_date_earned > to_date('31/12/2005', 'dd/mm/yyyy') and p_si_class ='ZVW' THEN
	    	 vCur_SI_Status.SI_Status:=-2;
	  END IF;

     /* IF vCur_SI_Status.SI_Class = 'AMI' and vCur_SI_Status.SI_Status > 0 THEN
         IF  hr_nl_org_info.Get_SI_Provider_Excl_Info(p_assignment_id,p_si_class,p_date_earned) = 0 THEN
            vCur_SI_Status.SI_Status := 0;
          END IF;
      END IF;*/

      hr_utility.set_location('Leaving' || l_proc, 500);
	  RETURN vCur_SI_Status.SI_Status;
	EXCEPTION
	   WHEN OTHERS THEN
	    hr_utility.set_location(' Others :' || SQLERRM(SQLCODE),900);
	END get_si_status;
	--
	-- Function to check if All Mandatory Insurances is chosen at the assignment level
	--
	  Function is_ami
	  ( p_assignment_id  in number,
	    p_date_earned    in date
	  ) return number IS
	  CURSOR Cur_SI_AMI IS
	  SELECT
	  DECODE(paei.AEI_INFORMATION3,'AMI',1,0) si_class_order
	  FROM
	  per_assignment_extra_info  paei
	  WHERE
	  assignment_id = p_assignment_id
	  and paei.aei_information_category='NL_SII'
	  and p_date_earned between
	  FND_DATE.CANONICAL_TO_DATE(paei.AEI_INFORMATION1)
	  and nvl(FND_DATE.CANONICAL_TO_DATE(paei.AEI_INFORMATION2),hr_general.END_OF_TIME)
	  order by si_class_order desc;
	  vCur_SI_AMI Cur_SI_AMI%ROWTYPE;
	  l_proc varchar2(100) := g_package||'get_si_status';
	BEGIN
	  hr_utility.set_location('Entering ' || l_proc, 100);
	  hr_utility.set_location('p_assignment_id ' || p_assignment_id, 110);
	  hr_utility.set_location('p_date_earned ' || p_date_earned, 110);
	  OPEN Cur_SI_AMI;
	  FETCH Cur_SI_AMI INTO vCur_SI_AMI;
	  CLOSE Cur_SI_AMI;
	  RETURN vCur_SI_AMI.si_class_order;
	EXCEPTION
	   WHEN OTHERS THEN
	    hr_utility.set_location(' Others :' || SQLERRM(SQLCODE),900);
	END is_ami;
	--
	-- Function to get payroll type
	--
	Function get_payroll_type
		(p_payroll_id      in   number
		) return varchar2 is
		--
		cursor cur_get_payroll is
		select period_type
		from   pay_all_payrolls_f pap
		where  payroll_id = p_payroll_id;
		v_period_type  varchar2(30);
	--
	begin
		open cur_get_payroll;
		fetch cur_get_payroll into v_period_type;
		close cur_get_payroll;
		return (v_period_type);
	end get_payroll_type;
	--
	-- Determines the Number if Week Days(Monday to Friday )
	-- between two dates
	FUNCTION Get_Week_Days(P_Start_Date Date,
							P_End_Date Date) return NUMBER IS
    v_st_date date :=P_Start_Date;
    v_en_date date :=P_End_Date;
    v_beg_of_week date;
    v_end_of_week date;
    v_days number := 0;
   begin
		if P_Start_Date > P_end_Date then
		return v_days;
		end if;
		--Determine the Beginning of Week Date for Start Date
		--and End of Week Date for End Date
		v_beg_of_week := v_st_date - (get_day_of_week(v_st_date)-1);
		v_end_of_week  := v_en_date;
		if get_day_of_week(v_en_date) NOT IN('1') then
			v_end_of_week := v_en_date + (7- get_day_of_week(v_en_date)+1);
		end if;
		--Calculate the Total Week Days @ of 5 per week
		v_days := ((v_end_of_week-v_beg_of_week)/7)*5;
		--Adjust the Total Week Days by subtracting
		--No of Days before the Start Date
		if (v_st_date > (v_beg_of_week+1)) then
			v_days := v_days - (v_st_date - (v_beg_of_week+1)) ;
		end if;
		if v_end_of_week <> v_en_date then
			v_end_of_week := v_end_of_week -2;
		else
			if v_st_date = v_en_date then
				v_days := 0;
			end if;
		end if;
		--Adjust the Total Week Days by subtracting
		--No of Days After the End Date
		if (v_end_of_week - v_en_date) >= 0 then
			v_days := v_days - (v_end_of_week - v_en_date) ;
		end if;
		return (v_days);
   end Get_Week_Days;
	--
	-- Determines the Maximum SI Days between two dates
	--  based on the method of 5 days per week
	FUNCTION Get_Max_SI_Days(P_Assignment_Id Number,
							P_Start_Date Date,
							P_End_Date Date) return NUMBER IS
		l_assgn_attr c_wp_dets%rowtype;
		l_curr_date           DATE;
		l_temp1               DATE;
		l_temp2               DATE;
		l_max_si_days         NUMBER:=0;
		l_error_code          NUMBER;
		l_counter             NUMBER:=0;
		l_error_msg           fnd_new_messages.message_text%TYPE;
		l_is_wrking_day       VARCHAR2(1);
	BEGIN
		OPEN c_wp_dets(P_Assignment_Id);
		FETCH c_wp_dets INTO l_assgn_attr;
		CLOSE c_wp_dets;
		l_temp1 :=p_start_date + (7 - get_day_of_week(p_start_date))+1;
		l_temp2 :=p_end_date - to_number(get_day_of_week(p_end_date))+1;
		IF  p_end_date <  l_temp1  THEN
		l_temp1 := p_end_date;
		end if;
		l_curr_date:=p_start_date;
		l_counter:=0;
		while l_curr_date <= l_temp1
		loop
			l_is_wrking_day:=PQP_SCHEDULE_CALCULATION_PKG.is_working_day
			(p_assignment_id      =>  l_assgn_attr.assignment_id
			,p_business_group_id  =>  l_assgn_attr. business_group_id
			,p_date               =>  l_curr_date
			,p_error_code         =>  l_error_code
			,p_error_message      =>  l_error_msg
			,p_default_wp         =>  null
			);
			if (l_is_wrking_day ='Y' and l_counter < 5) then
				l_counter:=l_counter+1;
			end if;
			l_curr_date:=l_curr_date+1;
		end loop;
		--3082046
		l_max_si_days:=l_max_si_days + l_counter;
		l_counter := 0;
		IF  p_end_date - l_temp1 + 1 >= 7 THEN
			l_curr_date := l_temp1 +1;
			while l_curr_date <= l_temp2
			loop
				l_is_wrking_day:= PQP_SCHEDULE_CALCULATION_PKG.is_working_day
				(p_assignment_id      =>  l_assgn_attr.assignment_id
				,p_business_group_id  =>  l_assgn_attr. business_group_id
				,p_date               =>  l_curr_date
				,p_error_code         =>  l_error_code
				,p_error_message      =>  l_error_msg
				,p_default_wp         =>  null
				);
				if l_is_wrking_day ='Y' then
					l_max_si_days := l_max_si_days +5;
					if get_day_of_week(l_curr_date) <> '1' then
						l_curr_date:=l_curr_date + (7 - get_day_of_week(l_curr_date) +2);
					else
						l_curr_date:=l_curr_date+1;
					end if;
				else
					l_curr_date := l_curr_date+1;
				end if;
			end loop;
		END IF;
		l_curr_date:=l_temp2 + 1;
		while l_curr_date <= P_End_Date
		loop
			l_is_wrking_day:= PQP_SCHEDULE_CALCULATION_PKG.is_working_day
			(p_assignment_id      =>  l_assgn_attr.assignment_id
			,p_business_group_id  =>  l_assgn_attr. business_group_id
			,p_date               =>  l_curr_date
			,p_error_code         =>  l_error_code
			,p_error_message      =>  l_error_msg
			,p_default_wp         =>  null
			);
			if (l_is_wrking_day ='Y' and l_counter < 5) then
				l_counter:=l_counter+1;
			end if;
			l_curr_date:=l_curr_date+1;
		end loop;
		l_max_si_days:=l_max_si_days + l_counter;
		return l_max_si_days;
   END Get_Max_SI_Days;
	--
	-- Determines the Number of Unpaid absence Days that reduce
	-- SI Days indicated by the segment on the Absence
	FUNCTION Get_Non_SI_Days(P_Assignment_Id Number,
							P_Start_Date Date,
							P_End_Date Date) return NUMBER IS
		CURSOR Get_Non_SI_Absence(p_person_id number) is
		select date_start,date_end,time_start,time_end
		from per_absence_attendances_v
		where person_id=p_person_id
		and ((ABS_INFORMATION_CATEGORY='NL' and ABS_INFORMATION1='Y')
		OR  (ABS_INFORMATION_CATEGORY='NL_S' and ABS_INFORMATION2='Y'))
		and (((p_start_date between date_start and date_end)
		or (p_end_date between date_start and date_end))
		or ((date_start between p_start_date and p_end_date)
		or (date_end between p_start_date and p_end_date)));
		l_hrs_wrked NUMBER;
		l_assgn_attr c_wp_dets%rowtype;
		l_error_code NUMBER;
		l_non_si_days NUMBER:=0;
		l_error_msg  fnd_new_messages.message_text%TYPE;
		l_person_id number;
		l_start_date per_absence_attendances_v.date_start%type;
		l_end_date per_absence_attendances_v.date_end%type;
		l_time_start per_absence_attendances_v.time_start%type;
		l_time_end per_absence_attendances_v.time_end%type;
		l_temp1 date;
		l_temp2 date;
		l_curr_date date;
		l_absence_hours per_absence_attendances_v.absence_hours%type;
		l_wrking_day varchar2(1):='N';
	BEGIN
		OPEN c_wp_dets(P_Assignment_Id);
		FETCH c_wp_dets INTO l_assgn_attr;
		CLOSE c_wp_dets;
		select person_id into l_person_id
		from per_all_assignments_f paa,
		fnd_sessions ses
		where paa.assignment_id =p_assignment_id
		and ses.session_id = userenv('sessionid')
		and ses.effective_date between paa.effective_start_date and paa.effective_end_date;
		for  l_absence_record in Get_Non_SI_Absence(l_person_id)
		loop
			--hr_utility.set_location(' date_start'||l_absence_record.date_start,100);
			--hr_utility.set_location(' date_end'||l_absence_record.date_end,100);
			/*Check whether the start date and end date of the abscence period are equal*/
			if l_absence_record.date_start = l_absence_record.date_end then
				l_hrs_wrked:=pqp_schedule_calculation_pkg.get_hours_worked
				(p_assignment_id   =>  l_assgn_attr.assignment_id
				,p_business_group_id   =>  l_assgn_attr.business_group_id
				,p_date_start          =>  l_absence_record.date_start
				,p_date_end            =>  l_absence_record.date_end
				,p_error_code          =>  l_error_code
				,p_error_message       =>  l_error_msg
				,p_default_wp          =>  NULL
				);
				--hr_utility.set_location('l_absence_record.time_end'||l_absence_record.time_end,110);
				--hr_utility.set_location('l_absence_record.time_start'||l_absence_record.time_start,110);
         			--Bug 3085937
         			--shveerab
         			/*Added code to check time_end and time_start is null for the abscence defined*/
				if  (l_absence_record.time_end is null and
				     l_absence_record.time_start is null ) then
                                /*If the time_end and time_start are null then l_absene_hours should be assigned
                                to the actual working hours of l_absence_record.date_start*/
					l_absence_hours := l_hrs_wrked;
				else
				/*Else the actual time difference between time_end and time_stard of the absence
				should be assigned*/
					l_absence_hours := (to_date('0001/01/01 '||l_absence_record.time_end,'yyyy/mm/dd hh24:mi') - to_date('0001/01/01 '||l_absence_record.time_start,'yyyy/mm/dd hh24:mi'))*24;
				end if;
				--hr_utility.set_location('l_absence_hours'||l_absence_hours,120);
				l_wrking_day:= pqp_schedule_calculation_pkg.is_working_day
				(p_assignment_id     => l_assgn_attr.assignment_id
				,p_business_group_id => l_assgn_attr.business_group_id
				,p_date              => l_absence_record.date_start
				,p_error_code        => l_error_code
				,p_error_message     => l_error_msg
				,p_default_wp        => NULL
				,p_override_wp       => NULL
				);
			        /*If the absence hours is greater than the actual working hours and its a
			        working day then non si absence days should be incremented by one*/
				if l_absence_hours >= l_hrs_wrked and l_wrking_day='Y' then
					l_non_si_days := l_non_si_days + 1;
				end if;
				--hr_utility.set_location('l_non_si_days'||l_non_si_days,150);
			else
				if l_absence_record.date_start > p_start_date then
					l_temp1:= l_absence_record.date_start;
				else
					l_temp1:=p_start_date;
				end if;
				if l_absence_record.date_end > p_end_date then
					l_temp2:=p_end_date;
				else
					l_temp2:=l_absence_record.date_end;
				end if;
				l_curr_date:=l_temp1;
				--Bug 3085937
				--shveerab
            			/* The Absence should be considered including the end date of the absence period*/
				while l_curr_date <= l_temp2
				loop
					l_wrking_day:= pqp_schedule_calculation_pkg.is_working_day
					(p_assignment_id     => l_assgn_attr.assignment_id
					,p_business_group_id => l_assgn_attr.business_group_id
					,p_date              => l_curr_date
					,p_error_code        => l_error_code
					,p_error_message     => l_error_msg
					,p_default_wp        => NULL
					,p_override_wp       => NULL
					);
					if l_wrking_day='Y' then
						l_non_si_days:=l_non_si_days + 1;
					end if;
					l_curr_date:=l_curr_date+1;
				end loop;
			end if;
		end loop; /*End of for  l_absence_record Loop*/
     return l_non_si_days;
   END  Get_Non_SI_Days;
	--
	-- Determines the Total Number of days a Work pattern has been
	-- setup for regardless of the work pattern start date on
	-- employee assignment or dates of payroll period.
	FUNCTION Get_Total_Work_Pattern_days(P_Assignment_Id Number) return NUMBER IS
		cursor c_get_days(p_wrk_pattern pqp_assignment_attributes_f.work_pattern%type,
				  p_business_group_id pqp_assignment_attributes_f.business_group_id%type ) is
		select count(uci.value)
		from pay_user_tables put,
		pay_user_columns puc,
		pay_user_column_instances_f uci,
		fnd_sessions ses
		where put.user_table_id = puc.user_table_id
		and puc.business_group_id = p_business_group_id      -- Fix for bug 3977437
		and uci.user_column_id = puc.user_column_id
		and put.user_table_name = g_udt_name
		and puc.user_column_name = p_wrk_pattern
		and ses.session_id = userenv('sessionid')
		and ses.effective_date between uci.effective_start_date and uci.effective_end_date;
		l_assgn_attr c_wp_dets%rowtype;
		l_wrk_pattern_days NUMBER;
   BEGIN
		OPEN c_wp_dets(P_Assignment_Id);
		FETCH c_wp_dets INTO l_assgn_attr;
		CLOSE c_wp_dets;
		OPEN c_get_days(l_assgn_attr.work_pattern , l_assgn_attr.business_group_id);
		FETCH c_get_days INTO l_wrk_pattern_days;
		CLOSE c_get_days;
		RETURN l_wrk_pattern_days;
	END Get_Total_Work_Pattern_days;
	--
	-- Determines the Total Number of days marked as Working Days in a
	-- work pattern regardless of the work pattern start date on
	-- employee assignment or dates of payroll period.
	FUNCTION Get_Working_Work_Pattern_days(P_Assignment_Id Number) return NUMBER IS
		cursor c_get_wrk_days	(p_wrk_pattern pqp_assignment_attributes_f.work_pattern%type ,
					p_business_group_id pqp_assignment_attributes_f.business_group_id%type) is
		select count(uci.value)
		from pay_user_tables put,
		pay_user_columns puc,
		pay_user_column_instances_f uci,
		fnd_sessions ses
		where put.user_table_id = puc.user_table_id
		and puc.business_group_id = p_business_group_id    -- Fix for bug 3977437
		and uci.user_column_id = puc.user_column_id
		and put.user_table_name = g_udt_name
		and puc.user_column_name = p_wrk_pattern
		and uci.value <> '0'
		and ses.session_id = userenv('sessionid')
		and ses.effective_date between uci.effective_start_date and uci.effective_end_date;
		l_assgn_attr c_wp_dets%rowtype;
		l_working_days number;
   BEGIN
		OPEN c_wp_dets(P_Assignment_Id);
		FETCH c_wp_dets INTO l_assgn_attr;
		CLOSE c_wp_dets;
		OPEN c_get_wrk_days(l_assgn_attr.work_pattern , l_assgn_attr.business_group_id);
		FETCH c_get_wrk_days INTO l_working_days;
		CLOSE c_get_wrk_days;
		RETURN l_working_days;
	END Get_Working_Work_Pattern_days;
       FUNCTION get_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number IS
       --
       CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
	   SELECT payroll_action_id
	   FROM   pay_assignment_actions
	   WHERE  assignment_action_id = c_assignment_action_id;
	   --
       l_payroll_action_id number;
       l_part_time_perc varchar2(35);
       l_inputs  ff_exec.inputs_t;
       l_outputs ff_exec.outputs_t;
       l_formula_exists  BOOLEAN := TRUE;
       l_formula_cached  BOOLEAN := FALSE;
       l_formula_id      ff_formulas_f.formula_id%TYPE;
       BEGIN
       g_ptp_formula_name := 'NL_PART_TIME_PERCENTAGE';
       --
       OPEN  csr_get_pay_action_id(p_assignment_action_id);
       FETCH csr_get_pay_action_id INTO l_payroll_action_id;
	   CLOSE csr_get_pay_action_id;
	   --
           IF g_ptp_formula_exists = TRUE THEN
               IF g_ptp_formula_cached = FALSE THEN
                   pay_nl_general.cache_formula('NL_PART_TIME_PERCENTAGE',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
                   g_ptp_formula_exists:=l_formula_exists;
                   g_ptp_formula_cached:=l_formula_cached;
                   g_ptp_formula_id:=l_formula_id;
               END IF;
   		--
               IF g_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
   		  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
   		  --
                   l_outputs(1).name := 'PART_TIME_PERCENTAGE';
   		  --
                   pay_nl_general.run_formula(p_formula_id       => g_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
   		  --
                   l_part_time_perc := l_outputs(1).value;
         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;
           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               END IF;
           ELSIF g_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;
           RETURN fnd_number.canonical_to_number(l_part_time_perc);
       END get_part_time_perc;
-------------------------------------------------------------------------------
-- Function : get_standard_si_part_time_perc
-- To get the Standard SI Part time Percentage using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
       FUNCTION get_standard_si_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number IS
       --
       CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
	   SELECT payroll_action_id
	   FROM   pay_assignment_actions
	   WHERE  assignment_action_id = c_assignment_action_id;
	   --
       l_payroll_action_id number;
       l_part_time_perc varchar2(35);
       l_inputs  ff_exec.inputs_t;
       l_outputs ff_exec.outputs_t;
       l_formula_exists  BOOLEAN := TRUE;
       l_formula_cached  BOOLEAN := FALSE;
       l_formula_id      ff_formulas_f.formula_id%TYPE;
       BEGIN
       g_std_ptp_formula_name := 'NL_STANDARD_SI_PART_TIME_PERCENTAGE';
       --
       OPEN  csr_get_pay_action_id(p_assignment_action_id);
       FETCH csr_get_pay_action_id INTO l_payroll_action_id;
	   CLOSE csr_get_pay_action_id;
	   --

           IF g_std_ptp_formula_exists = TRUE THEN
               IF g_std_ptp_formula_cached = FALSE THEN
                   pay_nl_general.cache_formula('NL_STANDARD_SI_PART_TIME_PERCENTAGE',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
                   g_std_ptp_formula_exists:=l_formula_exists;
                   g_std_ptp_formula_cached:=l_formula_cached;
                   g_std_ptp_formula_id:=l_formula_id;
               END IF;
   		--
               IF g_std_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
   		  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
   		  --
                   l_outputs(1).name := 'STANDARD_SI_PART_TIME_PERCENTAGE';
   		  --
                   pay_nl_general.run_formula(p_formula_id       => g_std_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_std_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
   		  --
                   l_part_time_perc := l_outputs(1).value;
         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;
           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               END IF;
           ELSIF g_std_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;
           RETURN fnd_number.canonical_to_number(l_part_time_perc);
       END get_standard_si_part_time_perc;
-------------------------------------------------------------------------------
-- Function : get_pseudo_si_part_time_perc
-- To get the Pseudo SI Part time Percentage  using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
       FUNCTION get_pseudo_si_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number IS
       --
       CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
	   SELECT payroll_action_id
	   FROM   pay_assignment_actions
	   WHERE  assignment_action_id = c_assignment_action_id;
	   --
       l_payroll_action_id number;
       l_part_time_perc varchar2(35);
       l_inputs  ff_exec.inputs_t;
       l_outputs ff_exec.outputs_t;
       l_formula_exists  BOOLEAN := TRUE;
       l_formula_cached  BOOLEAN := FALSE;
       l_formula_id      ff_formulas_f.formula_id%TYPE;
       BEGIN
       g_pse_ptp_formula_name := 'NL_PSEUDO_SI_PART_TIME_PERCENTAGE';
       --
       OPEN  csr_get_pay_action_id(p_assignment_action_id);
       FETCH csr_get_pay_action_id INTO l_payroll_action_id;
	   CLOSE csr_get_pay_action_id;
	   --

           IF g_pse_ptp_formula_exists = TRUE THEN
               IF g_pse_ptp_formula_cached = FALSE THEN
                   pay_nl_general.cache_formula('NL_PSEUDO_SI_PART_TIME_PERCENTAGE',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
                   g_pse_ptp_formula_exists:=l_formula_exists;
                   g_pse_ptp_formula_cached:=l_formula_cached;
                   g_pse_ptp_formula_id:=l_formula_id;
               END IF;
   		--
               IF g_pse_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
   		  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
   		  --
                   l_outputs(1).name := 'PSEUDO_SI_PART_TIME_PERCENTAGE';
   		  --
                   pay_nl_general.run_formula(p_formula_id       => g_pse_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_pse_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
   		  --
                   l_part_time_perc := l_outputs(1).value;
         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;
           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               END IF;
           ELSIF g_pse_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;
           RETURN fnd_number.canonical_to_number(l_part_time_perc);
       END get_pseudo_si_part_time_perc;
-------------------------------------------------------------------------------
-- Function : get_std_si_rep_part_time_perc
-- To get the Standard SI Part time Percentage for Reporting using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
         FUNCTION get_std_si_rep_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number IS
       --
       CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
	   SELECT payroll_action_id
	   FROM   pay_assignment_actions
	   WHERE  assignment_action_id = c_assignment_action_id;
	   --
       l_payroll_action_id number;
       l_part_time_perc varchar2(35);
       l_inputs  ff_exec.inputs_t;
       l_outputs ff_exec.outputs_t;
       l_formula_exists  BOOLEAN := TRUE;
       l_formula_cached  BOOLEAN := FALSE;
       l_formula_id      ff_formulas_f.formula_id%TYPE;
       BEGIN
       g_std_rep_ptp_formula_name := 'NL_STANDARD_SI_REPORTING_PART_TIME_PERCENTAGE';
       --
       OPEN  csr_get_pay_action_id(p_assignment_action_id);
       FETCH csr_get_pay_action_id INTO l_payroll_action_id;
	   CLOSE csr_get_pay_action_id;
	   --
           IF g_std_rep_ptp_formula_exists = TRUE THEN
               IF g_std_rep_ptp_formula_cached = FALSE THEN
                   pay_nl_general.cache_formula('NL_STANDARD_SI_REPORTING_PART_TIME_PERCENTAGE',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
                   g_std_rep_ptp_formula_exists:=l_formula_exists;
                   g_std_rep_ptp_formula_cached:=l_formula_cached;
                   g_std_rep_ptp_formula_id:=l_formula_id;
               END IF;
   		--
               IF g_std_rep_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
   		  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
   		  --
                   l_outputs(1).name := 'STANDARD_SI_REPORTING_PART_TIME_PERCENTAGE';
   		  --
                   pay_nl_general.run_formula(p_formula_id       => g_std_rep_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_std_rep_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
   		  --
                   l_part_time_perc := l_outputs(1).value;
         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;
           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               END IF;
           ELSIF g_std_rep_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;
           RETURN fnd_number.canonical_to_number(l_part_time_perc);
       END get_std_si_rep_part_time_perc;
 -------------------------------------------------------------------------------
-- Function : get_pse_si_rep_part_time_perc
-- To get the Pseudo SI Part time Percentage for reporting using
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
---------------------------------------------------------------------------------
 FUNCTION get_pse_si_rep_part_time_perc (p_assignment_id IN NUMBER
                                   ,p_date_earned IN DATE
                                   ,p_business_group_id IN NUMBER
                                   ,p_assignment_action_id IN NUMBER) RETURN number IS
       --
       CURSOR csr_get_pay_action_id(c_assignment_action_id NUMBER) IS
	   SELECT payroll_action_id
	   FROM   pay_assignment_actions
	   WHERE  assignment_action_id = c_assignment_action_id;
	   --
       l_payroll_action_id number;
       l_part_time_perc varchar2(35);
       l_inputs  ff_exec.inputs_t;
       l_outputs ff_exec.outputs_t;
       l_formula_exists  BOOLEAN := TRUE;
       l_formula_cached  BOOLEAN := FALSE;
       l_formula_id      ff_formulas_f.formula_id%TYPE;
       BEGIN
       g_pse_rep_ptp_formula_name := 'NL_PSEUDO_SI_REPORTING_PART_TIME_PERCENTAGE';
       --
       OPEN  csr_get_pay_action_id(p_assignment_action_id);
       FETCH csr_get_pay_action_id INTO l_payroll_action_id;
	   CLOSE csr_get_pay_action_id;
	   --
           IF g_pse_rep_ptp_formula_exists = TRUE THEN
               IF g_pse_rep_ptp_formula_cached = FALSE THEN
                   pay_nl_general.cache_formula('NL_PSEUDO_SI_REPORTING_PART_TIME_PERCENTAGE',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
                   g_pse_rep_ptp_formula_exists:=l_formula_exists;
                   g_pse_rep_ptp_formula_cached:=l_formula_cached;
                   g_pse_rep_ptp_formula_id:=l_formula_id;
               END IF;
   		--
               IF g_pse_rep_ptp_formula_exists = TRUE THEN
             --  hr_utility.trace('FORMULA EXISTS');
   		  --
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'DATE_EARNED';
                   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(4).value := p_assignment_action_id;
                   l_inputs(5).name := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := l_payroll_action_id;
                   l_inputs(6).name := 'BALANCE_DATE';
                   l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
   		  --
                   l_outputs(1).name := 'PSEUDO_SI_REPORTING_PART_TIME_PERCENTAGE';
   		  --
                   pay_nl_general.run_formula(p_formula_id       => g_pse_rep_ptp_formula_id,
                                              p_effective_date   => p_date_earned,
                                              p_formula_name     => g_pse_rep_ptp_formula_name,
                                              p_inputs           => l_inputs,
                                              p_outputs          => l_outputs);
   		  --
                   l_part_time_perc := l_outputs(1).value;
         --    hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               ELSE
           --  hr_utility.trace('FORMULA DOESNT EXISTS');
                   l_part_time_perc := NULL;
           --  hr_utility.trace('l_part_time_perc'||l_part_time_perc);
               END IF;
           ELSIF g_pse_rep_ptp_formula_exists = FALSE THEN
               l_part_time_perc := NULL;
           END IF;
           RETURN fnd_number.canonical_to_number(l_part_time_perc);
       END get_pse_si_rep_part_time_perc;
/* This Function returns the day of the week.
Sunday is considered to be the first day of the week*/
FUNCTION  get_day_of_week(p_date date)
return number is
l_reference_date date:=to_date('01/01/1984','DD/MM/YYYY');
v_index number;
begin
v_index:=abs(p_date - l_reference_date);
v_index:=mod(v_index,7);
return v_index+1;
end get_day_of_week;

-----------------------------------------------------------------------------------------------
-- Function : get_avg_part_time_percentage
-- To get the average Pseudo SI Part time Percentage
-- Assignment Id,Period Start Date,Period End Date
-----------------------------------------------------------------------------------------------
FUNCTION get_avg_part_time_percentage
	(	p_assignment_id		IN	per_all_assignments_f.assignment_id%type 	,
		p_period_start_date	IN	DATE	,
		p_period_end_date	IN	DATE
	)
	RETURN NUMBER IS
-- Cursor to retrieve part time percentages and effective start and end dates for an assignment.
CURSOR
	csr_get_part_time_per(	p_assignment_id 	per_all_assignments_f.assignment_id%type,
				p_period_start_date	DATE ,
				p_period_end_date	DATE
		             ) IS
SELECT 	FND_NUMBER.CANONICAL_TO_NUMBER(hs.segment29)	 	segment29	,
	pas.effective_start_date 				effective_start_date,
	pas.effective_end_date 					effective_end_date
FROM
	hr_soft_coding_keyflex hs 	,
	per_all_assignments_f pas
WHERE
     pas.assignment_id		  	=	p_assignment_id 			AND
     hs.soft_coding_keyflex_id	  	=	pas.soft_coding_keyflex_id 		AND
     pas.effective_start_date 		<=     	p_period_end_date   			AND
     pas.effective_end_date		>=	p_period_start_date ;
l_ef_start_date		per_all_assignments_f.effective_start_date%type;
l_ef_end_date		per_all_assignments_f.effective_end_date%type	;
l_period_start_date	DATE;
l_period_end_date	DATE;
l_asg_start_date	DATE;
l_asg_end_date		DATE;
l_days			NUMBER := 0;
l_part_time_perc	NUMBER := 0;
l_part_time_days	NUMBER := 0;
l_part_time_days_add	NUMBER := 0;
l_period_days		NUMBER := 0;
l_part_time_percentage	NUMBER := 0;
a			NUMBER;
BEGIN
a := PAY_NL_GENERAL.get_period_asg_dates
			(	p_assignment_id		=>  p_assignment_id
			,	p_period_start_date	=>  p_period_start_date
			,	p_period_end_date	=>  p_period_end_date
			,	p_asg_start_date	=>  l_asg_start_date
			,	p_asg_end_date		=>  l_asg_end_date
			);
l_period_start_date	:=	GREATEST( p_period_start_date , l_asg_start_date);
l_period_end_date	:=	LEAST( p_period_end_date   , l_asg_end_date  );

FOR  	l_part_time_parameters IN
	csr_get_part_time_per(p_assignment_id ,l_period_start_date,l_period_end_date)
LOOP
	l_ef_start_date		:=	l_part_time_parameters.effective_start_date;
	l_ef_end_date		:=	l_part_time_parameters.effective_end_date;
	l_ef_end_date  		:=      LEAST(l_period_end_date, l_ef_end_date ) ;
	l_ef_start_date		:=      GREATEST(l_period_start_date, l_ef_start_date);
	l_days			:=      (l_ef_end_date -l_ef_start_date ) + 1;
	l_part_time_perc 	:=	nvl(l_part_time_parameters.segment29 ,100);
	l_part_time_days 	:=	l_part_time_perc*l_days;
	l_part_time_days_add	:=	l_part_time_days_add + l_part_time_days;
END LOOP;
l_period_days		:= 	( l_period_end_date - l_period_start_date )+ 1;
l_part_time_percentage  := 	l_part_time_days_add/l_period_days;
RETURN ROUND(l_part_time_percentage,4);
END get_avg_part_time_percentage;

-----------------------------------------------------------------------------------------------
-- Function : get_real_si_days
-- To get the override for Real SI Days
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
FUNCTION get_real_si_days
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_business_group_id 	IN 	NUMBER
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	)
	RETURN NUMBER IS
l_real_si_days   varchar2(35);
l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
l_formula_exists  BOOLEAN := TRUE;
l_formula_cached  BOOLEAN := FALSE;
l_formula_id      ff_formulas_f.formula_id%TYPE;
BEGIN
g_real_si_days_formula_name := 'NL_REAL_SOCIAL_INSURANCE_DAYS';
   IF g_real_si_days_formula_exists = TRUE THEN
       IF g_real_si_days_formula_cached = FALSE THEN
	   pay_nl_general.cache_formula('NL_REAL_SOCIAL_INSURANCE_DAYS',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
	   g_real_si_days_formula_exists:=l_formula_exists;
	   g_real_si_days_formula_cached:=l_formula_cached;
	   g_real_si_days_formula_id:=l_formula_id;
       END IF;
	--
       IF g_real_si_days_formula_exists = TRUE THEN
 	  --
	   l_inputs(1).name  := 'ASSIGNMENT_ID';
	   l_inputs(1).value := p_assignment_id;
	   l_inputs(2).name  := 'DATE_EARNED';
	   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
	   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
	   l_inputs(3).value := p_business_group_id;
	   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
	   l_inputs(4).value := p_assignment_action_id;
	   l_inputs(5).name := 'PAYROLL_ACTION_ID';
	   l_inputs(5).value := p_payroll_action_id;
       l_inputs(6).name := 'BALANCE_DATE';
       l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
	  --
	   l_outputs(1).name := 'REAL_SOCIAL_INSURANCE_DAYS';
	  --
	   pay_nl_general.run_formula(p_formula_id       => g_real_si_days_formula_id,
				      p_effective_date   => p_date_earned,
				      p_formula_name     => g_real_si_days_formula_name,
				      p_inputs           => l_inputs,
				      p_outputs          => l_outputs);
	  --
	   l_real_si_days := l_outputs(1).value;
       ELSE
	   l_real_si_days := NULL;
       END IF;
   ELSIF g_real_si_days_formula_exists = FALSE THEN
       l_real_si_days := NULL;
   END IF;
   RETURN fnd_number.canonical_to_number(l_real_si_days);
END get_real_si_days;


Function IsLeapYear(p_year NUMBER) RETURN NUMBER IS
l_year NUMBER;
BEGIN
If (p_year  Mod 4 = 0) And
((p_year  Mod 100 <> 0) Or (p_year Mod 400 = 0)) Then
l_year :=1;
Else
l_year :=0;
End If;
return l_year;
End IsLeapYear ;


FUNCTION get_asg_ind_work_hours
	(	p_assignment_id		IN	per_all_assignments_f.assignment_id%type 	,
		p_period_start_date	IN	DATE	,
		p_period_end_date	IN	DATE
	)
	RETURN NUMBER IS
-- Cursor to retrieve part time percentages and effective start and end dates for an assignment.
CURSOR
	csr_get_ind_work_hrs(	p_assignment_id 	per_all_assignments_f.assignment_id%type,
				p_period_start_date	DATE ,
				p_period_end_date	DATE
		             ) IS
SELECT 	FND_NUMBER.CANONICAL_TO_NUMBER(scl.segment28)	 	segment28	,
        paa.frequency ,
	paa.effective_start_date 				effective_start_date,
	paa.effective_end_date 					effective_end_date
FROM
	hr_soft_coding_keyflex scl 	,
	per_all_assignments_f paa
WHERE
     paa.assignment_id		  	=	p_assignment_id 			AND
     scl.soft_coding_keyflex_id	  	=	paa.soft_coding_keyflex_id 		AND
     paa.effective_start_date 		<=     	p_period_end_date   			AND
     paa.effective_end_date		>=	p_period_start_date ;

TYPE days_month IS TABLE OF NUMBER;
 days_in  days_month;

l_ef_start_date		per_all_assignments_f.effective_start_date%type;
l_ef_end_date		per_all_assignments_f.effective_end_date%type	;
l_period_start_date	DATE;
l_period_end_date	DATE;
l_asg_start_date	DATE;
l_asg_end_date		DATE;
l_days			NUMBER := 0;
l_ind_wrk_hrs           NUMBER := 0;
l_cum_ind_wrk_hrs	NUMBER := 0;
l_part_time_days_add	NUMBER := 0;
l_temp			NUMBER;
l_mon_days              NUMBER := 0;
l_freq                  VARCHAR2(10);



BEGIN

l_mon_days := ( p_period_end_date - p_period_start_date )+ 1;

l_temp := PAY_NL_GENERAL.get_period_asg_dates
			(	p_assignment_id		=>  p_assignment_id
			,	p_period_start_date	=>  p_period_start_date
			,	p_period_end_date	=>  p_period_end_date
			,	p_asg_start_date	=>  l_asg_start_date
			,	p_asg_end_date		=>  l_asg_end_date
			);
l_period_start_date	:=	GREATEST( p_period_start_date , l_asg_start_date);
l_period_end_date	:=	LEAST( p_period_end_date   , l_asg_end_date  );

FOR  	l_ind_wrk_hrs_csr IN
	csr_get_ind_work_hrs (p_assignment_id ,l_period_start_date,l_period_end_date)
LOOP
	l_ef_start_date		:=	l_ind_wrk_hrs_csr.effective_start_date;
	l_ef_end_date		:=	l_ind_wrk_hrs_csr.effective_end_date;
	l_ef_end_date  		:=      LEAST(l_period_end_date, l_ef_end_date ) ;
	l_ef_start_date		:=      GREATEST(l_period_start_date, l_ef_start_date);
	l_days			:=      (l_ef_end_date -l_ef_start_date ) + 1;
	l_ind_wrk_hrs   	:=	nvl(l_ind_wrk_hrs_csr.segment28 ,0);
	l_freq                  :=      l_ind_wrk_hrs_csr.frequency;

	if l_freq = 'D' then
	l_cum_ind_wrk_hrs := l_cum_ind_wrk_hrs + (((l_ind_wrk_hrs*260)/12/l_mon_days)*l_days);
	end if;

	if l_freq = 'W' then
	l_cum_ind_wrk_hrs := l_cum_ind_wrk_hrs + (((l_ind_wrk_hrs*52)/12/l_mon_days)*l_days);
	end if;

	if l_freq = 'M' then
        l_cum_ind_wrk_hrs := l_cum_ind_wrk_hrs + (((l_ind_wrk_hrs)/l_mon_days)*l_days);
	end if;

	if l_freq = 'Y' then
         l_cum_ind_wrk_hrs := l_cum_ind_wrk_hrs + (((l_ind_wrk_hrs)/12/l_mon_days)*l_days);
	end if;

END LOOP;

RETURN  l_cum_ind_wrk_hrs;
END get_asg_ind_work_hours;

FUNCTION get_period_si_days(	 p_assignment_id 	NUMBER
				,p_payroll_id		NUMBER
				,p_effective_date       DATE
				,p_source_text		VARCHAR2
				,p_override_day_method 	VARCHAR2
				,p_override_day_value   VARCHAR2
				,p_avg_ws_si_days	NUMBER
				,p_override_si_days	NUMBER
 				,p_real_si_days		NUMBER
				,p_si_day_method	VARCHAR2
				,p_max_si_method	VARCHAR2
				,p_multi_asg_si_days	NUMBER
				,p_year_calc 		VARCHAR2
				,p_override_real_si_days NUMBER
				,p_override   OUT NOCOPY VARCHAR2
				,p_period_si_days_year_calc NUMBER
							    )
			    RETURN NUMBER
			    IS
l_number 		NUMBER;
l_period_start_date	DATE;
l_period_end_date	DATE;
period_start_date	DATE;
period_end_date		DATE;
l_asg_start_date 	DATE;
l_asg_end_date 		DATE;
l_period_type		VARCHAR2(50);
Average_SI_days 	NUMBER;
Total_Days		NUMBER;
Work_Days		NUMBER;
Override		VARCHAR2(10);
Period_SI_Days		NUMBER := 0;
Max_SI_Days		NUMBER;
Available_SI_Days	NUMBER;
Multi_Assign_Max_Days 	NUMBER;
l_si_day_method			VARCHAR2(10) := '0';
CURSOR get_payroll_period( p_payroll_id	     NUMBER
			   ,p_effective_date DATE  )   IS
select 	START_DATE
       ,END_DATE
from
per_time_periods
where payroll_id=p_payroll_id
and p_effective_date between START_DATE and END_DATE;
BEGIN

OPEN get_payroll_period(p_payroll_id,p_effective_date);
FETCH get_payroll_period INTO l_period_start_date, l_period_end_date;
CLOSE get_payroll_period;
l_number := pay_nl_general.get_period_asg_dates (p_assignment_id ,l_period_start_date ,l_period_end_date
		      				,l_asg_start_date , l_asg_end_date );


l_period_type := pay_nl_si_pkg.get_payroll_type(p_payroll_id);
IF l_period_type = 'Calendar Month' THEN
	Average_SI_days:= fnd_number.canonical_to_number(pay_nl_general.get_global_value(p_effective_date,'NL_SI_AVERAGE_DAYS_MONTHLY'));
END IF;
IF l_period_type = 'Week' THEN
	Average_SI_days:= fnd_number.canonical_to_number(pay_nl_general.get_global_value(p_effective_date,'NL_SI_AVERAGE_DAYS_WEEKLY'));
END IF;
IF l_period_type = 'Quarter' THEN
	Average_SI_days:= fnd_number.canonical_to_number(pay_nl_general.get_global_value(p_effective_date,'NL_SI_AVERAGE_DAYS_QUARTERLY'));
END IF;
IF l_period_type = 'Lunar Month' THEN
	Average_SI_days:= fnd_number.canonical_to_number(pay_nl_general.get_global_value(p_effective_date,'NL_SI_AVERAGE_DAYS_4WEEKLY'));
END IF;
IF l_asg_start_date > l_period_start_date THEN
	  Total_Days := fffunc.days_between(l_period_end_date, l_period_start_date) + 1;
	  IF l_Asg_End_Date < l_period_end_date THEN
	    Work_Days := fffunc.days_between(l_asg_end_date, l_asg_start_date) + 1;
	  ELSE
	    Work_Days := fffunc.days_between(l_period_end_date, l_asg_start_date) + 1;
	  END If;
	  Average_SI_Days := round((Average_SI_Days / Total_Days * Work_Days),2);

ELSE
	  IF l_asg_end_date < l_period_end_date THEN
		    Total_Days := fffunc.days_between(l_period_end_date, l_period_start_date) + 1;
		    Work_Days := fffunc.days_between(l_asg_end_date, l_period_start_date) + 1;
		    Average_SI_Days := round((Average_SI_Days / Total_Days * Work_Days),2);
	  END IF;
END IF;

Period_Start_Date	:=	GREATEST( l_period_start_date , l_asg_start_date);
Period_End_Date		:=	LEAST( l_period_end_date   , l_asg_end_date  );
IF p_max_si_method = '1' THEN
   /* If the selected method is the number of week days in a payroll period/year.  This is
   forced if there are multi assignments.  Then call relevant formula function.*/
  Max_SI_Days := GET_WEEK_DAYS (Period_Start_Date, Period_End_Date);
ELSE
  /* If the selected method is 5 days per week for the weeks worked. Then call relevant formula
   function */
  Max_SI_Days := GET_MAX_SI_DAYS (p_assignment_id,Period_Start_Date, Period_End_Date);
END IF;

Override := 'N';

IF p_override_si_days <> -1 THEN
   	Period_SI_Days := p_override_si_days;
   	Override := 'Y';
ELSE
      IF p_override_day_method = '0' THEN
         Period_SI_Days := to_number(p_override_day_value);
         Override := 'Y';
      ELSE
         IF p_override_day_method = '1' THEN
 	       	Period_SI_Days := (Average_SI_Days / 100) * to_number(p_override_day_value);
 	       	Period_SI_Days := Round(Period_SI_Days,2);
 	       	Override := 'Y';
         ELSE
 	     	IF p_override_day_method = '2' THEN
 			Period_SI_Days := (Max_SI_Days / 100) * to_number(p_override_day_value);
 			Period_SI_Days := Round(Period_SI_Days, 2);
 			Override := 'Y';
 		END IF;
 	 END IF;
      END IF;
END IF;

Multi_Assign_Max_Days := Max_SI_Days;

IF p_si_day_method = '0' AND p_year_calc= 'N' AND Override = 'N' THEN
 	/* Average Days */
   	Period_SI_Days := Average_SI_Days;
   	Period_SI_Days := Period_SI_Days - p_multi_asg_si_days  ;
   	IF (Period_SI_Days <0) THEN
   	   Period_SI_Days := 0 ;
   	END IF;
ELSE
   	IF p_si_day_method = '2' AND p_year_calc= 'N' AND Override = 'N' THEN
           	/* Average Days with Work Schedules*/
        	Period_SI_Days := p_avg_ws_si_days;
        	Period_SI_Days := Period_SI_Days - p_multi_asg_si_days  ;
        	IF (Period_SI_Days <0) THEN
   	   		Period_SI_Days :=0;
   		END IF;
   	ELSE
      		IF (p_si_day_method = '1' AND p_year_calc = 'N') AND Override = 'N' THEN
          		/*  Real SI Days */
         		 Period_SI_Days := p_real_si_days;
          		/* Check if override of real SI days was used.  If so then re-set override indicator */
          		IF p_override_real_si_days <> -1 THEN
          			Override := 'Y';
          		END IF;
       		ELSE
       			IF p_year_calc = 'Y' AND Override = 'N' AND p_si_day_method <> '3' THEN
				/* Adjusted year value */
				Period_SI_Days := p_period_si_days_year_calc;
				l_si_day_method := '1';
				/* Adjust Max SI Days for multi assignments*/
		 		Multi_Assign_Max_Days := Period_SI_Days;
		 	END IF;
       		END IF;
   	END IF;
END IF;
Available_SI_Days:= 0 ;
/*Max Si Days Rule is applicable only for Real SI Days*/
IF (p_si_day_method = '1' or l_si_day_method = '1') AND Override = 'N' THEN
     IF Multi_Assign_Max_Days > p_multi_asg_si_days THEN
         Available_SI_Days := Multi_Assign_Max_Days - p_multi_asg_si_days;
     ELSE
         Available_SI_Days := 0;
     END IF;
     IF Period_SI_Days > Available_SI_Days THEN
           Period_SI_Days := Available_SI_Days;
     END IF;
END IF;

p_override := Override;


RETURN Period_SI_Days;
END get_period_si_days;

FUNCTION get_ret_real_si_days    ( 	 p_assignment_id 		NUMBER
					,p_payroll_id			NUMBER
					,p_effective_date 		DATE
					,p_source_text			VARCHAR2
					,p_source_text2			VARCHAR2
					,p_real_si_days			NUMBER
					,p_override_real_si_days	NUMBER
					,p_max_si_method		VARCHAR2
					,p_real_si_sit_ytd		NUMBER
					,p_real_si_sit_ptd		NUMBER
					,p_ret_real_si_sit_ytd		NUMBER
					,p_real_si_per_pay_sitp_ptd	NUMBER
				 )
				 RETURN NUMBER IS
l_period_start_date		DATE;
l_period_end_date		DATE;
l_asg_start_date		DATE;
l_asg_end_date			DATE;
Period_Start_Date		DATE;
Period_End_Date			DATE;
p_ret_real_si_days		NUMBER  := 0;
l_number			NUMBER;
l_avail_real_si_days		NUMBER;
l_cum_real_si_days		NUMBER;
Max_SI_Days			NUMBER;
l_multi_asg_real_si		NUMBER;
l_si_avg_days_yr		NUMBER;
CURSOR get_payroll_period( p_payroll_id	     NUMBER
			   ,p_effective_date DATE  )   IS
select 	START_DATE
       ,END_DATE
from
per_time_periods
where payroll_id=p_payroll_id
and p_effective_date between START_DATE and END_DATE;
BEGIN
OPEN get_payroll_period(p_payroll_id,p_effective_date);
FETCH get_payroll_period INTO l_period_start_date, l_period_end_date;
CLOSE get_payroll_period;
l_number := pay_nl_general.get_period_asg_dates (p_assignment_id ,l_period_start_date ,l_period_end_date
		      				,l_asg_start_date , l_asg_end_date );


Period_Start_Date	:=	GREATEST( l_period_start_date , l_asg_start_date);
Period_End_Date		:=	LEAST( l_period_end_date   , l_asg_end_date  );

IF p_max_si_method = '1' THEN
   /* If the selected method is the number of week days in a payroll period/year.  This is
   forced if there are multi assignments.  Then call relevant formula function.*/
  Max_SI_Days := GET_WEEK_DAYS (Period_Start_Date, Period_End_Date);
ELSE
  /* If the selected method is 5 days per week for the weeks worked. Then call relevant formula
   function */
  Max_SI_Days := GET_MAX_SI_DAYS (p_assignment_id,Period_Start_Date, Period_End_Date);
END IF;
/* Set return value for real SI days */
p_ret_real_si_days  := p_real_si_days;
l_multi_asg_real_si := p_real_si_per_pay_sitp_ptd - p_real_si_sit_ptd;
IF p_override_real_si_days = -1 THEN
  IF Max_SI_Days >l_multi_asg_real_si THEN
    l_avail_real_si_days := Max_SI_Days - l_multi_asg_real_si ;
  ELSE
    l_avail_real_si_days := 0;
  END IF;
  IF p_real_si_days > l_avail_real_si_days THEN
    p_ret_real_si_days := l_avail_real_si_days;
  END IF;
END IF;
l_si_avg_days_yr := fnd_number.canonical_to_number(pay_nl_general.get_global_value(p_effective_date,'NL_SI_AVERAGE_DAYS_YEARLY'));
IF p_override_real_si_days = -1 THEN
  l_cum_real_si_days := (p_real_si_sit_ytd - p_real_si_sit_ptd) + p_ret_real_si_days + p_ret_real_si_sit_ytd;
	  IF l_cum_real_si_days > l_si_avg_days_yr THEN
	    p_ret_real_si_days := p_ret_real_si_days - (l_cum_real_si_days - l_si_avg_days_yr);
	  END IF;
END IF;
p_ret_real_si_days := p_ret_real_si_days - p_real_si_sit_ptd;
RETURN p_ret_real_si_days;
END get_ret_real_si_days;

FUNCTION get_thres_or_max_si  ( 	 p_assignment_id 	NUMBER
					,p_payroll_id		NUMBER
					,p_effective_date	DATE
					,p_calc_code		NUMBER
					,p_part_time_perc	NUMBER
					,p_si_days		NUMBER
					,p_thre_max_si		NUMBER
				  )
				  RETURN NUMBER IS

l_period_start_date		DATE;
l_period_end_date		DATE;
l_asg_start_date		DATE;
l_asg_end_date			DATE;
Period_Start_Date		DATE;
Period_End_Date			DATE;
l_number 			NUMBER;
Non_SI_Days			NUMBER;
Total_Days			NUMBER;
Work_Days			NUMBER;
Absence_Factor			NUMBER;
Threshold_or_Max_SI			NUMBER;
l_avg_si_days_monthly		NUMBER;

CURSOR get_payroll_period(  p_payroll_id	     NUMBER
			   ,p_effective_date DATE  )   IS
select 	START_DATE
       ,END_DATE
from
per_time_periods
where payroll_id=p_payroll_id
and p_effective_date between START_DATE and END_DATE;

BEGIN

OPEN get_payroll_period(p_payroll_id,p_effective_date);
FETCH get_payroll_period INTO l_period_start_date, l_period_end_date;
CLOSE get_payroll_period;
l_number := pay_nl_general.get_period_asg_dates (p_assignment_id ,l_period_start_date ,l_period_end_date
		      				,l_asg_start_date , l_asg_end_date );

Period_Start_Date	:=	GREATEST( l_period_start_date , l_asg_start_date);
Period_End_Date		:=	LEAST( l_period_end_date   , l_asg_end_date  );

l_avg_si_days_monthly := fnd_number.canonical_to_number(pay_nl_general.get_global_value(p_effective_date,'NL_SI_AVERAGE_DAYS_MONTHLY'));

IF (p_calc_code = 0 OR p_calc_code =1 OR p_calc_code = 3 ) then

		Threshold_or_Max_SI := p_si_days * to_number(p_thre_max_si);

ELSE

		Threshold_or_Max_SI := to_number(p_thre_max_si) * (p_part_time_perc / 100);

		/* Added Proration code for Bug 3412227
		Pro-rate SI base and threshold if employee started or left during the payroll period */
		IF l_Asg_Start_Date > l_period_start_date THEN

			Total_Days := fffunc.days_between(l_period_end_date, l_period_start_date) + 1;
			IF l_Asg_End_Date < l_period_end_date THEN
			  	Work_Days := fffunc.days_between(l_Asg_End_Date, l_Asg_Start_Date) + 1;
			ELSE
			  	Work_Days := fffunc.days_between(l_period_end_date, l_Asg_Start_Date) + 1;
			END IF;
			Threshold_or_Max_SI := round((Threshold_or_Max_SI / Total_Days * Work_Days),2);

		ELSE

			IF l_Asg_End_Date < l_period_end_date THEN

			  	Total_Days := fffunc.days_between(l_period_end_date, l_period_start_date) + 1;
			  	Work_Days := fffunc.days_between(l_Asg_End_Date, l_period_start_date) + 1;
			  	Threshold_or_Max_SI := round((Threshold_or_Max_SI / Total_Days * Work_Days),2) ;

			END IF;
		END IF;


		Non_SI_Days := GET_NON_SI_DAYS(p_assignment_id,Period_Start_Date, Period_End_Date);


		IF Non_SI_Days > 0 THEN

			/* Determine factor to reduce Maximum SI Salary and Thresholds by any non SI absences*/
			IF l_avg_si_days_monthly > Non_SI_Days then
				Absence_Factor := (l_avg_si_days_monthly - Non_SI_Days) / l_avg_si_days_monthly ;
			ELSE
				Absence_Factor := 0;
			END IF;

			Threshold_or_Max_SI := Threshold_or_Max_SI * Absence_Factor;

	   	END IF;

END IF;

RETURN Threshold_or_Max_SI;

END get_thres_or_max_si;

FUNCTION get_si_proration_days (p_assignment_id NUMBER
                               ,p_period_start_date DATE
                               ,p_period_end_date DATE
                               ,p_proration_start_date DATE
                               ,p_proration_end_date DATE
                               ,p_period_si_days NUMBER
                               )
                               RETURN NUMBER IS
CURSOR csr_asg_dates (p_other_assignment_id NUMBER) IS
       SELECT MIN(asg.effective_start_date) asg_start_date
              ,MAX(asg.effective_end_date) asg_end_date
       FROM PER_ASSIGNMENTS_F asg
            ,PER_ASSIGNMENT_STATUS_TYPES past
       WHERE asg.assignment_id = p_other_assignment_id
       AND   past.per_system_status = 'ACTIVE_ASSIGN'
       AND   asg.assignment_status_type_id = past.assignment_status_type_id
       AND   asg.effective_start_date <= p_period_end_date
       AND   NVL(asg.effective_end_date,p_period_end_date) >= p_period_start_date;

CURSOR csr_any_other_asg IS
       SELECT DISTINCT asg1.assignment_id asgid
       FROM per_assignments_f asg1
            ,per_assignments_f asg2
            ,pay_object_groups pog1
            ,pay_object_groups pog2
       WHERE asg1.person_id = asg2.person_id
       AND   asg2.assignment_id = p_assignment_id
       AND   asg1.assignment_id <> p_assignment_id
       AND   pog1.source_id = asg1.assignment_id
       AND   pog1.source_type = 'PAF'
       AND   pog2.source_id = asg2.assignment_id
       AND   pog2.source_type = 'PAF'
       AND   pog1.parent_object_group_id = pog2.parent_object_group_id;

CURSOR csr_person_dates IS
       SELECT MIN(asg.effective_start_date) per_start_date
              ,MAX(asg.effective_end_date) per_end_date
       FROM PER_ASSIGNMENTS_F asg,
            PER_ASSIGNMENT_STATUS_TYPES past,
            PAY_OBJECT_GROUPS pog
       WHERE asg.person_id in
       (select asg2.person_id from PER_ASSIGNMENTS_F asg2, PAY_OBJECT_GROUPS pog2
       where asg2.assignment_id = p_assignment_id
       and pog2.source_id = asg2.assignment_id
       and pog2.source_type = 'PAF'
       and pog.parent_object_group_id = pog2.parent_object_group_id)
       AND   past.per_system_status = 'ACTIVE_ASSIGN'
       AND   asg.assignment_status_type_id = past.assignment_status_type_id
       AND   asg.effective_start_date <= p_period_end_date
       AND   NVL(asg.effective_end_date,p_period_end_date) >= p_period_start_date
       AND   pog.source_id = asg.assignment_id
       AND   pog.source_type = 'PAF';


l_proration_start_date DATE;
l_proration_end_date DATE;
other_asg_start_date DATE;
other_asg_end_date DATE;
l_other_asg_start_date DATE;
l_other_asg_end_date DATE;
proration_days NUMBER := 0;
overlap_with_main VARCHAR2(10);
other_asg_no NUMBER := 0;
l_other_asg1_start_date DATE;
l_other_asg1_end_date DATE;
l_other_asg2_start_date DATE;
l_other_asg2_end_date DATE;

l_per_start_date DATE;
l_per_end_date   DATE;

--6887820
l_element_type_id pay_element_types_f.element_type_id%TYPE;
l_input_value_id pay_input_values_f.input_value_id%TYPE;
l_prorate_flag pay_element_entry_values_f.screen_entry_value%TYPE;

--6887820
CURSOR ele_typ_id
IS
select element_type_id
from pay_element_types_f
where
element_name = 'NL Tax and SI Proration Indicator'
and p_proration_start_date between effective_start_date and effective_end_date
and legislation_code = 'NL';

CURSOR inp_val_id(p_element_type_id NUMBER)
IS
select input_value_id from pay_input_values_f
where element_type_id = p_element_type_id
and p_proration_start_date between effective_start_date and effective_end_date
and legislation_code = 'NL';

/* Cursor to get the override value of proration flag from
seeded element "NL Tax and SI Proration Indicator" */

CURSOR part_time_prorate_flag
IS
SELECT EEV.screen_entry_value
FROM
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV
WHERE   INPUTV.input_value_id                  = l_input_value_id
AND     p_proration_start_date BETWEEN INPUTV.effective_start_date AND INPUTV.effective_end_date
AND     INPUTV.element_type_id		     = l_element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     p_proration_start_date BETWEEN LIV.effective_start_date AND LIV.effective_end_date
AND     EEV.input_value_id                     = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assignment_id
AND     p_proration_start_date BETWEEN EE.effective_start_date AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')                = 'E';
--6887820


BEGIN
--6887820
	OPEN ele_typ_id;
	FETCH ele_typ_id into l_element_type_id;
	CLOSE ele_typ_id;

	OPEN inp_val_id(l_element_type_id);
	FETCH inp_val_id INTO l_input_value_id;
	CLOSE inp_val_id;

	OPEN part_time_prorate_flag;
	FETCH part_time_prorate_flag INTO l_prorate_flag;
	CLOSE part_time_prorate_flag;

--6887820 % if seeded element exists with assignment
   IF l_prorate_flag = 'N' THEN
    l_proration_start_date := p_period_start_date;
    l_proration_end_date := p_period_end_date;
--6887820
   ELSE
    l_proration_start_date := p_proration_start_date;
    l_proration_end_date := p_proration_end_date;
   END IF;

   /* loop for other assignments for the employee */
   FOR c1rec IN csr_any_other_asg LOOP
    OPEN csr_asg_dates(c1rec.asgid);
    FETCH csr_asg_dates INTO l_other_asg_start_date, l_other_asg_end_date;
    CLOSE csr_asg_dates;

    /* If other assignment of the employee is active in the payroll period calculate working days using daily table */
    IF l_other_asg_start_date IS NOT NULL AND l_other_asg_end_date IS NOT NULL THEN
        other_asg_no := other_asg_no + 1;
        other_asg_start_date := GREATEST(p_period_start_date, l_other_asg_start_date);
        other_asg_end_date := LEAST(p_period_end_date, l_other_asg_end_date);
        IF other_asg_no = 1 THEN
           l_other_asg1_start_date := other_asg_start_date;
           l_other_asg1_end_date := other_asg_end_date;
        END IF;
        IF other_asg_no = 2 THEN
           l_other_asg2_start_date := other_asg_start_date;
           l_other_asg2_end_date := other_asg_end_date;
        END IF;
        IF other_asg_start_date < l_proration_start_date THEN
            IF other_asg_end_date < l_proration_start_date - 1 THEN
                IF other_asg_no = 1 THEN
                    overlap_with_main := 'N';
                END IF;
                proration_days := proration_days + Get_Week_Days (other_asg_start_date, other_asg_end_date);
             ELSE
                l_proration_start_date := other_asg_start_date;
             END IF;
        END IF;

        IF other_asg_end_date > l_proration_end_date THEN
            IF other_asg_start_date > l_proration_end_date + 1 THEN
                IF other_asg_no = 1 THEN
                    overlap_with_main := 'N';
                END IF;
                proration_days := proration_days + Get_Week_Days (other_asg_start_date, other_asg_end_date);
            ELSE
                l_proration_end_date := other_asg_end_date;
            END IF;
        END IF;
    END IF;
  END LOOP;

  /* If there are one or more days in the payroll period having no active assignments, then use daily table only*/
  IF l_proration_start_date = p_period_start_date and l_proration_end_date = p_period_end_date and p_period_si_days > 0 THEN
    proration_days := p_period_si_days;
    RETURN proration_days;
  END IF;
  proration_days := proration_days + Get_Week_Days (l_proration_start_date, l_proration_end_date);

  /* Remove overlaps between the first other assignment and second other assignment, if any */
  IF other_asg_no = 2 AND overlap_with_main = 'N' THEN
    IF l_other_asg2_start_date BETWEEN l_other_asg1_start_date AND l_other_asg1_end_date THEN
        proration_days := proration_days - Get_Week_Days (l_other_asg2_start_date, LEAST(l_other_asg2_end_date, l_other_asg1_end_date));
    ELSIF l_other_asg2_end_date BETWEEN l_other_asg1_start_date and l_other_asg1_end_date THEN
        proration_days := proration_days - Get_Week_Days (l_other_asg1_start_date, l_other_asg2_end_date);
    ELSIF l_other_asg1_start_date BETWEEN l_other_asg2_start_date AND l_other_asg2_end_date THEN
        proration_days := proration_days - Get_Week_Days (l_other_asg1_start_date, l_other_asg1_end_date);
    END IF;
  END IF;

  /*For more than 3 active assignments, proration days are returned with assumption that person
  is active for every day in the payroll period. Otherwise user feeds the days manually */
  IF other_asg_no > 2 THEN
    OPEN csr_person_dates;
    FETCH csr_person_dates INTO l_per_start_date, l_per_end_date;
    CLOSE csr_person_dates;
    l_per_start_date := GREATEST(p_period_start_date, l_per_start_date);
    l_per_end_date := LEAST(p_period_end_date, l_per_end_date);
    IF l_per_start_date = p_period_start_date and l_per_end_date = p_period_end_date and p_period_si_days > 0 THEN
	proration_days := p_period_si_days;
    ELSE
    	proration_days := Get_Week_Days (l_per_start_date, l_per_end_date);
    END IF;
  END IF;
RETURN proration_days;
END get_si_proration_days;

-----------------------------------------------------------------------------------------------
-- Function : get_override_si_days
-- To get the override for SI Days
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
FUNCTION get_override_si_days
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_business_group_id 	IN 	NUMBER
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	)
	RETURN NUMBER IS
l_override_si_days  varchar2(35);
l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
l_formula_exists    BOOLEAN := TRUE;
l_formula_cached    BOOLEAN := FALSE;
l_formula_id        ff_formulas_f.formula_id%TYPE;
BEGIN
g_si_days_formula_name := 'NL_OVERRIDE_SOCIAL_INSURANCE_DAYS';
   IF g_si_days_formula_exists = TRUE THEN
       IF g_si_days_formula_cached = FALSE THEN
	   pay_nl_general.cache_formula('NL_OVERRIDE_SOCIAL_INSURANCE_DAYS',p_business_group_id,p_date_earned,l_formula_id,l_formula_exists,l_formula_cached);
	   g_si_days_formula_exists:=l_formula_exists;
	   g_si_days_formula_cached:=l_formula_cached;
	   g_si_days_formula_id:=l_formula_id;
       END IF;
	--
       IF g_si_days_formula_exists = TRUE THEN
 	  --
	   l_inputs(1).name  := 'ASSIGNMENT_ID';
	   l_inputs(1).value := p_assignment_id;
	   l_inputs(2).name  := 'DATE_EARNED';
	   l_inputs(2).value := fnd_date.date_to_canonical(p_date_earned);
	   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
	   l_inputs(3).value := p_business_group_id;
	   l_inputs(4).name := 'ASSIGNMENT_ACTION_ID';
	   l_inputs(4).value := p_assignment_action_id;
	   l_inputs(5).name := 'PAYROLL_ACTION_ID';
	   l_inputs(5).value := p_payroll_action_id;
       l_inputs(6).name := 'BALANCE_DATE';
       l_inputs(6).value := fnd_date.date_to_canonical(p_date_earned);
	  --
	   l_outputs(1).name := 'OVERRIDE_SOCIAL_INSURANCE_DAYS';
	   l_outputs(2).name := 'PRORATION_FLAG';
	  --
	   pay_nl_general.run_formula(p_formula_id       => g_si_days_formula_id,
				      p_effective_date   => p_date_earned,
				      p_formula_name     => g_si_days_formula_name,
				      p_inputs           => l_inputs,
				      p_outputs          => l_outputs);
	  --
	   g_si_days := fnd_number.canonical_to_number(l_outputs(1).value);
	   g_tax_proration_days := fnd_number.canonical_to_number(l_outputs(1).value);
	   g_tax_proration_flag := l_outputs(2).value;
       ELSE
	   g_si_days := '-1';
	   g_tax_proration_days := '-1';
	   g_tax_proration_flag := 'X';
       END IF;
   ELSIF g_si_days_formula_exists = FALSE THEN
       g_si_days := '-1';
       g_tax_proration_days := '-1';
       g_tax_proration_flag := 'X';
   END IF;
   RETURN fnd_number.canonical_to_number(g_si_days);

END get_override_si_days;

-----------------------------------------------------------------------------------------------
-- Function : get_tax_proration_days
-- To get the number of days for tax proration by executing user formula
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
Function get_tax_proration_days
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	       ,p_business_group_id 	IN 	NUMBER
	)
	 RETURN number IS
l_override_si_days  varchar2(35);
BEGIN
	IF g_assignment_id = p_assignment_id THEN
		RETURN fnd_number.canonical_to_number(g_tax_proration_days);
	ELSE
		l_override_si_days := get_override_si_days
			(        p_assignment_id
			        ,p_date_earned
				,p_business_group_id
				,p_assignment_action_id
				,p_payroll_action_id
			);
		g_assignment_id := p_assignment_id;
		RETURN fnd_number.canonical_to_number(g_tax_proration_days);
	END IF;
END get_tax_proration_days;

-----------------------------------------------------------------------------------------------
-- Function : get_tax_proration_flag
-- To return the flag to determine whether proration is required or not by executing user formula
-- Assignment Id,Date Earned, Business Group Id and Assignment action Id.
-----------------------------------------------------------------------------------------------
Function get_tax_proration_flag
	(       p_assignment_id 	IN 	NUMBER
	       ,p_date_earned 		IN	DATE
	       ,p_assignment_action_id 	IN 	NUMBER
	       ,p_payroll_action_id 	IN 	NUMBER
	       ,p_business_group_id 	IN 	NUMBER
	)
         RETURN varchar2 IS
l_override_si_days  varchar2(35);

l_element_type_id pay_element_types_f.element_type_id%TYPE;
l_input_value_id pay_input_values_f.input_value_id%TYPE;
l_prorate_flag pay_element_entry_values_f.screen_entry_value%TYPE;

--6887820
CURSOR ele_typ_id
IS
select element_type_id
from pay_element_types_f
where
element_name = 'NL Tax and SI Proration Indicator'
and p_date_earned between effective_start_date and effective_end_date
and legislation_code = 'NL';

CURSOR inp_val_id(p_element_type_id NUMBER)
IS
select input_value_id from pay_input_values_f
where element_type_id = p_element_type_id
and p_date_earned between effective_start_date and effective_end_date
and legislation_code = 'NL';

/* Cursor to get the override value of proration flag from
seeded element "NL Tax and SI Proration Indicator" */

CURSOR part_time_prorate_flag
IS
SELECT EEV.screen_entry_value
FROM
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV
WHERE   INPUTV.input_value_id                  = l_input_value_id
AND     p_date_earned BETWEEN INPUTV.effective_start_date AND INPUTV.effective_end_date
AND     INPUTV.element_type_id		     = l_element_type_id
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     p_date_earned BETWEEN LIV.effective_start_date AND LIV.effective_end_date
AND     EEV.input_value_id                     = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = p_assignment_id
AND     p_date_earned BETWEEN EE.effective_start_date AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, 'E')                = 'E';
--6887820
BEGIN
--6887820
	OPEN ele_typ_id;
	FETCH ele_typ_id into l_element_type_id;
	CLOSE ele_typ_id;

	OPEN inp_val_id(l_element_type_id);
	FETCH inp_val_id INTO l_input_value_id;
	CLOSE inp_val_id;

	OPEN part_time_prorate_flag;
	FETCH part_time_prorate_flag INTO l_prorate_flag;
	CLOSE part_time_prorate_flag;
--6887820

	IF g_assignment_id = p_assignment_id THEN
		--6887820
		IF g_tax_proration_flag = 'X' THEN
		  g_tax_proration_flag := NVL(l_prorate_flag,g_tax_proration_flag);
		END IF;
		--6887820
		RETURN g_tax_proration_flag;
	ELSE
		l_override_si_days := get_override_si_days
			(        p_assignment_id
			        ,p_date_earned
				,p_business_group_id
				,p_assignment_action_id
				,p_payroll_action_id
			);
		g_assignment_id := p_assignment_id;
		--6887820
		IF g_tax_proration_flag = 'X' THEN
		  g_tax_proration_flag := NVL(l_prorate_flag,g_tax_proration_flag);
		END IF;
		--6887820
		RETURN g_tax_proration_flag;
	END IF;
END get_tax_proration_flag;

---------------------------------------------------------------------------------------
-- Function : get_tax_proration_cal_days
-- To return number of Tax Days for proration based on calender days
---------------------------------------------------------------------------------------

FUNCTION get_tax_proration_cal_days
	(	p_assignment_id		IN	NUMBER
                ,p_period_start_date	IN	DATE
                ,p_period_end_date	IN	DATE
                ,p_proration_start_date IN	DATE
                ,p_proration_end_date	IN	DATE
        )
        RETURN NUMBER IS
CURSOR csr_asg_dates (p_other_assignment_id NUMBER) IS
       SELECT MIN(asg.effective_start_date) asg_start_date
              ,MAX(asg.effective_end_date) asg_end_date
       FROM PER_ASSIGNMENTS_F asg
            ,PER_ASSIGNMENT_STATUS_TYPES past
       WHERE asg.assignment_id = p_other_assignment_id
       AND   past.per_system_status = 'ACTIVE_ASSIGN'
       AND   asg.assignment_status_type_id = past.assignment_status_type_id
       AND   asg.effective_start_date <= p_period_end_date
       AND   NVL(asg.effective_end_date,p_period_end_date) >= p_period_start_date;

CURSOR csr_any_other_asg IS
       SELECT DISTINCT asg1.assignment_id asgid
       FROM per_assignments_f asg1
            ,per_assignments_f asg2
            ,pay_object_groups pog1
            ,pay_object_groups pog2
       WHERE asg1.person_id = asg2.person_id
       AND   asg2.assignment_id = p_assignment_id
       AND   asg1.assignment_id <> p_assignment_id
       AND   pog1.source_id = asg1.assignment_id
       AND   pog1.source_type = 'PAF'
       AND   pog2.source_id = asg2.assignment_id
       AND   pog2.source_type = 'PAF'
       AND   pog1.parent_object_group_id = pog2.parent_object_group_id;


CURSOR csr_person_dates IS
       SELECT MIN(asg.effective_start_date) per_start_date
              ,MAX(asg.effective_end_date) per_end_date
       FROM PER_ASSIGNMENTS_F asg,
            PER_ASSIGNMENT_STATUS_TYPES past,
            PAY_OBJECT_GROUPS pog
       WHERE asg.person_id in
       (select asg2.person_id from PER_ASSIGNMENTS_F asg2, PAY_OBJECT_GROUPS pog2
       where asg2.assignment_id = p_assignment_id
       and pog2.source_id = asg2.assignment_id
       and pog2.source_type = 'PAF'
       and pog.parent_object_group_id = pog2.parent_object_group_id)
       AND   past.per_system_status = 'ACTIVE_ASSIGN'
       AND   asg.assignment_status_type_id = past.assignment_status_type_id
       AND   asg.effective_start_date <= p_period_end_date
       AND   NVL(asg.effective_end_date,p_period_end_date) >= p_period_start_date
       AND   pog.source_id = asg.assignment_id
       AND   pog.source_type = 'PAF';


l_proration_start_date DATE;
l_proration_end_date DATE;
other_asg_start_date DATE;
other_asg_end_date DATE;
l_other_asg_start_date DATE;
l_other_asg_end_date DATE;
proration_days NUMBER := 0;
overlap_with_main VARCHAR2(10);
other_asg_no NUMBER := 0;
l_other_asg1_start_date DATE;
l_other_asg1_end_date DATE;
l_other_asg2_start_date DATE;
l_other_asg2_end_date DATE;

l_per_start_date DATE;
l_per_end_date   DATE;


BEGIN

   l_proration_start_date := p_proration_start_date;
   l_proration_end_date := p_proration_end_date;

   /* loop for other assignments for the employee */
   FOR c1rec IN csr_any_other_asg LOOP
    OPEN csr_asg_dates(c1rec.asgid);
    FETCH csr_asg_dates INTO l_other_asg_start_date, l_other_asg_end_date;
    CLOSE csr_asg_dates;

    /* If other assignment of the employee is active in the payroll period calculate working days using daily table */
    IF l_other_asg_start_date IS NOT NULL AND l_other_asg_end_date IS NOT NULL THEN
        other_asg_no := other_asg_no + 1;
        other_asg_start_date := GREATEST(p_period_start_date, l_other_asg_start_date);
        other_asg_end_date := LEAST(p_period_end_date, l_other_asg_end_date);
        IF other_asg_no = 1 THEN
           l_other_asg1_start_date := other_asg_start_date;
           l_other_asg1_end_date := other_asg_end_date;
        END IF;
        IF other_asg_no = 2 THEN
           l_other_asg2_start_date := other_asg_start_date;
           l_other_asg2_end_date := other_asg_end_date;
        END IF;
        IF other_asg_start_date < l_proration_start_date THEN
            IF other_asg_end_date < l_proration_start_date - 1 THEN
                IF other_asg_no = 1 THEN
                    overlap_with_main := 'N';
                END IF;
                proration_days := proration_days + (other_asg_end_date - other_asg_start_date) + 1;
             ELSE
                l_proration_start_date := other_asg_start_date;
             END IF;
        END IF;

        IF other_asg_end_date > l_proration_end_date THEN
            IF other_asg_start_date > l_proration_end_date + 1 THEN
                IF other_asg_no = 1 THEN
                    overlap_with_main := 'N';
                END IF;
                proration_days := proration_days + (other_asg_end_date - other_asg_start_date) + 1;
            ELSE
                l_proration_end_date := other_asg_end_date;
            END IF;
        END IF;
    END IF;
  END LOOP;

  /* If there are one or more days in the payroll period having no active assignments, then use daily table only*/
  IF l_proration_start_date = p_period_start_date and l_proration_end_date = p_period_end_date THEN
    proration_days := (p_period_end_date - p_period_start_date) + 1;
    RETURN proration_days;
  END IF;
  proration_days := proration_days + (l_proration_end_date - l_proration_start_date) + 1;

  /* Remove overlaps between the first other assignment and second other assignment, if any */
  IF other_asg_no = 2 AND overlap_with_main = 'N' THEN
    IF l_other_asg2_start_date BETWEEN l_other_asg1_start_date AND l_other_asg1_end_date THEN
        proration_days := proration_days - (LEAST(l_other_asg2_end_date, l_other_asg1_end_date) - l_other_asg2_start_date);
    ELSIF l_other_asg2_end_date BETWEEN l_other_asg1_start_date and l_other_asg1_end_date THEN
        proration_days := proration_days - (l_other_asg2_end_date - l_other_asg1_start_date);
    ELSIF l_other_asg1_start_date BETWEEN l_other_asg2_start_date AND l_other_asg2_end_date THEN
        proration_days := proration_days - (l_other_asg1_end_date - l_other_asg1_start_date);
    END IF;
  END IF;

  /*For more than 3 active assignments, proration days are returned with assumption that person
  is active for every day in the payroll period. Otherwise user feeds the days manually */
  IF other_asg_no > 2 THEN
    OPEN csr_person_dates;
    FETCH csr_person_dates INTO l_per_start_date, l_per_end_date;
    CLOSE csr_person_dates;
    l_per_start_date := GREATEST(p_period_start_date, l_per_start_date);
    l_per_end_date := LEAST(p_period_end_date, l_per_end_date);
    proration_days := (l_per_end_date - l_per_start_date) + 1;
  END IF;
RETURN proration_days;
END get_tax_proration_cal_days;

END pay_nl_si_pkg;

/
