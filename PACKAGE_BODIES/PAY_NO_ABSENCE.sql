--------------------------------------------------------
--  DDL for Package Body PAY_NO_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ABSENCE" AS
/* $Header: pynoabsence.pkb 120.1 2007/07/10 05:38:01 pdavidra noship $ */
Function CALCULATE_PAYMENT
 ( p_assignment_id               IN         NUMBER
  ,p_effective_date              IN         DATE
--  ,p_absence_category            IN         VARCHAR2
  ,p_abs_categorycode            IN         VARCHAR
  ,p_abs_start_date              IN         DATE
  ,p_abs_end_date                IN         DATE
  ,p_prorate_start               IN         DATE
  ,p_prorate_end                 IN         DATE
  ,p_abs_attendance_id           IN         NUMBER
-- Balance Variables
  ,p_sickabs_paybase             IN         NUMBER
  ,p_sickabs_totaldays           IN         NUMBER
-- Sickness Benefit variables
  ,p_abs_empr_days               OUT NOCOPY NUMBER
  ,p_abs_ss_days                 OUT NOCOPY NUMBER
  ,p_abs_total_days              OUT NOCOPY NUMBER
  ,p_abs_daily_rate              OUT NOCOPY NUMBER
  ,p_abs_sick_days               OUT NOCOPY NUMBER
-- Earnings adjustment values
  ,p_ear_value                   OUT NOCOPY NUMBER
  ,p_ear_startdt                 OUT NOCOPY DATE
  ,p_ear_enddt                   OUT NOCOPY DATE
-- Global values
  ,p_abs_link_period             IN         NUMBER
  ,p_abs_min_gap                 IN         NUMBER
  ,p_abs_month                   IN         NUMBER
  ,p_abs_annual_days             IN         NUMBER
  ,p_abs_work_days               IN         NUMBER
  ,p_abs_cal_days                IN         NUMBER
-- pay earned start and end date
  ,p_pay_start_date              IN         DATE
  ,p_pay_end_date                IN         DATE
-- To determine actual payroll period. Mainly for proration calculation.
  ,p_hourly_paid                 IN         Varchar2
-- Balance Variables
  ,p_4weeks_paybase              IN         NUMBER
  ,p_3years_paybase              IN         NUMBER
-- Reclaimable benefit output variables
  ,p_rec_empr_days               OUT NOCOPY NUMBER
  ,p_rec_ss_days                 OUT NOCOPY NUMBER
  ,p_rec_total_days              OUT NOCOPY NUMBER
  ,p_rec_daily_rate              OUT NOCOPY NUMBER
  ,p_ss_daily_rate               OUT NOCOPY NUMBER
-- User defined daily rate calculation logic option
  ,p_rate_option1                OUT NOCOPY VARCHAR
  ,p_rate_option2                OUT NOCOPY VARCHAR
  ,p_rate_option3                OUT NOCOPY VARCHAR
  ,p_rate_option4                OUT NOCOPY VARCHAR
  ,p_rate_option5                OUT NOCOPY VARCHAR
  ,p_rate_option6                OUT NOCOPY VARCHAR
  ,p_rate_option7                OUT NOCOPY VARCHAR
  ,p_rate_option8                OUT NOCOPY VARCHAR
  ,p_rate_option9                OUT NOCOPY VARCHAR
  ,p_rate_option10               OUT NOCOPY VARCHAR
 -- ,p_abs_categorycode            OUT NOCOPY VARCHAR
  ,p_abs_error                   OUT NOCOPY VARCHAR
  ,p_adopt_bal_days              IN NUMBER
  ,p_parental_bal_days           IN NUMBER
  ,p_abs_child_emp_days_limit    IN NUMBER
  ,p_child_emp_days              IN NUMBER
  ,p_child_ss_days               IN NUMBER
  ,p_pts_percentage              OUT NOCOPY NUMBER
  ,p_abs_total_cal_days          OUT NOCOPY NUMBER
  ,p_sickbal_total_caldays       IN NUMBER
  ,p_abs_ear_adj_base            IN NUMBER
   ) RETURN NUMBER IS

    -- Cursor to fetch previous absences exists with sickness and part-time sickness for calculating
    -- Continuous linking period. It will not consider overlapping sickness. It will pick absences
    -- that are started and ended before the start date of the current absence.
    CURSOR CSR_CONT_LINK (l_person_id number) IS
    SELECT paa.absence_attendance_id
           ,paa.date_start
           ,paa.date_end,
           DECODE(paa.date_start, paa.date_end, 1, (paa.date_end-paa.date_start)+1) AS days_diff
      FROM per_absence_attendances paa, per_absence_attendance_types pat
     WHERE paa.person_id = l_person_id
       AND paa.date_start < p_abs_start_date
       AND paa.date_end < p_abs_start_date
       AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
       AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
       AND pat.absence_category IN ('S','PTS')
     ORDER BY paa.date_end desc ;

    CURSOR CSR_ELE_ENT_VAL_FETCH (l_asg_id number, l_eff_dt date, l_inp_val_name varchar2, l_start_dt date, l_end_dt date) IS
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
      AND  et.element_name       = 'Absence Detail'
      AND  et.legislation_code   = 'NO'
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

CURSOR CSR_RUN_RESULT_FETCH (p_input_name varchar2, stdate date, enddate date) IS
SELECT result_value
FROM  pay_element_types_f pet
      , pay_element_entries_f pee
	  , pay_run_results prr
	  , pay_run_result_values prrv
	  , pay_input_values_f piv
WHERE pet.element_type_id  = pee.element_type_id
  AND pet.element_type_id = prr.element_type_id
  AND pee.element_entry_id = prr.element_entry_id
  AND prr.run_result_id = prrv.run_result_id
  AND pet.element_type_id = piv.element_type_id
  AND piv.input_value_id = prrv.input_value_id
  AND pet.element_name LIKE 'Absence Detail'
  AND piv.NAME = p_input_name
  AND pee.effective_start_date = stdate
  AND pee.effective_end_date = enddate ;

CURSOR CSR_CUR_ABS_PRORATED (P_ASSIGNMENT_ID NUMBER, P_EFFECTIVE_DATE DATE, P_ST_DT DATE, P_EN_DT DATE) IS
SELECT DATE_EARNED
FROM PER_ALL_ASSIGNMENTS_F PAA
     ,PAY_PAYROLL_ACTIONS PPA
     ,PAY_ASSIGNMENT_ACTIONS PASG
WHERE PAA.PAYROLL_ID = PPA.PAYROLL_ID
  AND PAA.ASSIGNMENT_ID = P_ASSIGNMENT_ID
  AND PAA.ASSIGNMENT_ID  = PASG.ASSIGNMENT_ID
  AND PPA.PAYROLL_ACTION_ID = PASG.PAYROLL_ACTION_ID
  AND PASG.SOURCE_ACTION_ID IS NOT NULL
  AND P_EFFECTIVE_DATE BETWEEN PAA.EFFECTIVE_START_DATE
                       AND PAA.EFFECTIVE_END_DATE
  AND DATE_EARNED BETWEEN P_ST_DT AND P_EN_DT
GROUP BY DATE_EARNED
ORDER BY DATE_EARNED ASC;

CURSOR child_prev_emp (personid NUMBER, stdate DATE) IS
SELECT START_DATE
       ,END_DATE
       ,fnd_number.canonical_to_number(PEM_INFORMATION1) AS PEM_INFORMATION1
  FROM PER_PREVIOUS_EMPLOYERS
 WHERE person_id = personid
   AND end_date BETWEEN TO_DATE('01/01/'|| TO_CHAR(stdate,'yyyy'), 'mm/dd/yyyy' )
                AND stdate
ORDER BY end_date DESC;

CURSOR child_contact ( personid NUMBER, contacttype VARCHAR2, abs_stdt DATE) IS
SELECT pap.date_of_birth
       ,ROUND(MONTHS_BETWEEN( abs_stdt, pap.date_of_birth ) / 12, 2)  AS AGE
       ,pcr.contact_type
	   ,pcr.cont_information1
	   ,pcr.cont_information2
  FROM per_all_people_f pap
       ,per_contact_relationships pcr
 WHERE pap.person_id = pcr.contact_person_id
   AND pcr.person_id = personid
   AND pcr.contact_type = contacttype
   AND (pcr.date_start is null or pcr.date_start <= abs_stdt)
   AND (pcr.date_end is null or pcr.date_end >= abs_stdt ); /* 5413738 */

    -- Cursor to fetch previous absences exists with child minder sickness category for calculating
    -- employer and social security days. It will not consider overlapping sickness. It will pick absences
    -- that are started and ended before the start date of the current absence.
    CURSOR child_link (l_person_id number) IS
    SELECT paa.absence_attendance_id
           ,paa.date_start
           ,paa.date_end,
           DECODE(paa.date_start, paa.date_end, 1, (paa.date_end-paa.date_start)+1) AS days_diff
      FROM per_absence_attendances paa, per_absence_attendance_types pat
     WHERE paa.person_id = l_person_id
       AND paa.date_start < p_abs_start_date
       AND paa.date_end < p_abs_start_date
       AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
       AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
       AND pat.absence_category IN ('CMS')
     ORDER BY paa.date_end desc ;

/*Pgopal - Bug 5393827 and 5349713 fix*/
CURSOR csr_get_intial_abs_st_date( p_intial_abs_attend_id IN NUMBER ) IS
SELECT
	paa.date_start
FROM
	PER_ABSENCE_ATTENDANCES  paa
WHERE
	PAA.ABSENCE_ATTENDANCE_ID = p_intial_abs_attend_id;

/* Cursor to get the initial absence start date for sickness */
CURSOR csr_get_intial_sick_abs_st_dt(p_abs_attn_id IN VARCHAR2 ) IS
SELECT nvl(peef2.effective_start_date,peef1.effective_start_date)
  FROM pay_element_entry_values_f peevf
      ,pay_input_values_f pivf
      ,pay_element_entries_f peef1
      ,pay_element_entries_f peef2
WHERE peevf.screen_entry_value = p_abs_attn_id
  AND pivf.input_value_id = peevf.input_value_id
  AND pivf.NAME = 'CREATOR_ID'
  AND pivf.legislation_code = 'NO'
  AND peef1.element_entry_id  = peevf.element_entry_id
  AND peef2.element_entry_id(+) = peef1.original_entry_id;

/* Cursor to get the initial absence payroll start date */
CURSOR csr_intial_abs_pay_stdt (p_assignment_id in number, p_initial_abs_start_date in date) is
SELECT ptp.start_date
  FROM per_all_assignmeNts_f paaf, PER_TIME_PERIODS ptp
 WHERE paaf.assignment_id = p_assignment_id
   AND ptp.payroll_id = paaf.payroll_id
   AND p_initial_abs_start_date between ptp.start_date and ptp.end_date;

p_adopt_days     Number := 0;
p_adopt_rate     Number := 0;
p_adopt_comprate Number := 0;

l_abs_category_code     Varchar2(50);
p_person_id             Number;
p_business_group_id     Number;
l_rate                  Number;
l_error_message         Varchar2(1000);
l_return                Number;
l_social_security_rate  Number;
l_g_rate                Number;
l_empr_daily_rate       Number;
l_ben_payvalue          Number;
l_benreclaim_payvalue   Number;
l_asg_hour_sal          Varchar2(10);
l_abs_worked_days       Number;
p_dbi_26week_stdt       Date;
p_dbi_26week_endt       Date;
l_social_security_days  Number;
p_work_pattern          Varchar2(100);

-- To keep the net value after checking the null value with 3 priority levels absence, person and legal employer
l_gen_hour_sal          Varchar2(10);
l_gen_entitled_sc       Varchar2(10);
l_gen_exempt_empr       Varchar2(10);
l_gen_reimb_ss          Varchar2(10);
l_gen_restrict_dr_ss    Varchar2(10);
l_gen_restrict_empr_sl  Varchar2(10);
l_gen_restrict_ss_sl    Varchar2(10);

l_gen_totalabs_days     Number;
l_gen_pro_days          Number;
l_gen_empr_days         Number;
l_gen_ss_days           Number;
l_gen_empr_st_date      Date;
l_gen_ss_st_date        Date;
l_gen_rate_option       Varchar2(10);

-- Validating Override element
l_override_start_date   Date;
l_override_end_date     Date;
l_override_empr_days    Number;
l_override_ss_days      Number;
l_override_empr_rate    Number;
l_override_ss_rate      Number;
l_override_reclaim_rate Number;
l_over_return           Number;
l_msg_error             varchar2(500) := '';
-- Calculation of Absence Days based on Work schedule
l_days_or_hours         Varchar2(10) := 'D';
l_include_event         Varchar2(10) := 'Y';
l_start_time_char       Varchar2(10) := '0';
l_end_time_char         Varchar2(10) := '23.59';
l_duration              Number;
l_wrk_schd_return       Number;

-- Person form absence payment details
l_hourly_salaried       Varchar2(10);
l_entitled_sc           Varchar2(10);
l_exempt_empr           Varchar2(10);
l_reimb_ss              Varchar2(10);
l_restrict_dr_ss        Varchar2(10);
l_restrict_empr_sl      Varchar2(10);
l_restrict_ss_sl        Varchar2(10);
l_dateofjoin            Date;
l_per_daily_rate        Varchar2(10);

-- Absence form absence payment details
l_cert_type             Varchar2(10);
l_cert_stdt             Date;
l_cert_endt             Date;
l_follow_due            Date;
l_follow_created        Date;
l_follow_sent           Date;
l_abs_reimb_ss          Varchar2(10);
l_abs_restrict_dr_ss    Varchar2(10);
l_abs_restrict_empr_sl  Varchar2(10);
l_abs_restrict_ss_sl    Varchar2(10);
l_abs_pts_percent       Number;
l_abs_daily_rate        Varchar2(10);
-- Legal employer EIT absence details
l_le_reimb_ss          Varchar2(10);
l_le_restrict_dr_ss    Varchar2(10);
l_le_restrict_empr_sl  Varchar2(10);
l_le_restrict_ss_sl    Varchar2(10);
l_le_hour_sal          Varchar2(10);
l_le_entitled_sc       Varchar2(10);
l_le_exempt_empr       Varchar2(10);
l_le_daily_rate        Varchar2(10);

-- Sickness payment variables
l_abs_unauthor          Number;
l_dateofjoin_28         Date;
l_abs_reason            Varchar2(100);
l_abs_count             Number(5);
l_actual_days           Number;
l_loop_start_date       Date;
l_loop_empr_days        Number;
l_loop_empr_work_days   Number;
l_actual_cal_days       Number;
l_reimb_ss_val          Varchar2(100);
-- Payment Result variables
l_empr_days             Number;
l_ss_days               Number;
l_total_days            Number;
l_daily_rate            Number;

l_reclaim_empr_days     Number;
l_reclaim_ss_days       Number;
l_reclaim_total_days    Number;
l_reclaim_daily_rate    Number;

-- Override check for continuous link period
l_cont_start_date       Date;
l_cont_end_date         Date;
l_cont_empr_rate        Number;
l_cont_ss_rate          Number;
l_cont_reclaim_rate     Number;
l_cont_empr_days        Number;
l_cont_ss_days          Number;

l_counter               Number;
l_prev_paydate          Date;

-- Adoption variables
l_adopt_days            Number;
l_eligibility           Boolean;
l_adopt_doa             Date;
l_adopt_dob             Date;
l_adopt_comprate        Number;
l_dummy                 Varchar2(100);
l_adopt_sum             Number;
l_adopt_glb_80          Number;
l_adopt_glb_100         Number;

/* Bug Fix 5380091 : Start */

l_no_of_children	NUMBER ;
l_gen_no_of_children    NUMBER ;

/* Bug Fix 5380091 : End */


/* Bug Fix 5346832 : Start */

l_adopt_glb_80_add_child	Number;
l_adopt_glb_100_add_child       Number;

/* Bug Fix 5346832 : End */

-- Part Time Adoption variables
l_adopt_ptp            Number;
l_adopt_reimb_ss       Varchar2(10);
l_adopt_restrict_dr_ss Varchar2(10);
l_adopt_restrict_empr_sl Varchar2(10);
l_adopt_daily_rate      Varchar2(40);

-- Child minder variables
l_child_1_13            Number;
l_child_2_13            Number;
l_child_1_19            Number;
l_childsg_1_13          Number;
l_childsg_2_13          Number;
l_childsg_1_19          Number;
l_child_prev_stdt       Date;
l_child_prev_endt       Date;
l_child_prev_value      Number;
l_gen_child_limit       Number;
l_child_cnt_ab          Number;
l_child_cnt_c           Number;
l_child_cnt_sgab        Number;
l_child_cnt_sgc         Number;

--Parental benefits
l_max_parental_days_100 number;
l_max_parental_days_80 number;
l_parental_days_add_child number;
l_parental_days_remaining number;

-- Maternity variables
l_m_expected_dob	date;
l_m_dob			date;
l_m_no_of_babies_born	number;
l_m_compensation_rate	number;
l_m_spouse              varchar2(10);
l_m_paternity_days	number;
l_m_pt_paternity_days	number;
l_m_reimurse_from_ss    varchar2(10);
l_m_use_ss_daily_rate	varchar2(10);
l_m_reclaimable_pay_max_6g varchar2(10);
l_m_hol_acc_ent         varchar2(10);
l_m_daily_rate_calc	varchar2(10);
l_m_date_stillborn	date;
l_maternity_sum		number;
l_maternity_days	number;
p_parental_days     Number := 0;
p_parental_rate     Number := 0;
p_parental_comprate Number := 0;

-- Part Time Maternity variables
l_ptm_expected_dob	date;
l_ptm_dob		date;
l_ptm_percentage	number;
l_ptm_compensation_rate	number;
l_ptm_paternity_days	number;
l_ptm_pt_paternity_days	number;
l_ptm_no_of_babies_born number;
l_ptm_use_ss_daily_rate	varchar2(10);
l_ptm_daily_rate_calc	varchar2(10);
l_ptm_hol_acc_ent	varchar2(20);
l_pt_maternity_sum	number;
l_pt_maternity_days	number;
l_ptm_reimburse_from_ss varchar2(10);
l_ptm_reclaim_pay_max_6g varchar2(10);

-- Paternity variables
l_p_expected_dob	date;
l_p_dob			date;
l_p_maternity_days      number;
l_p_pt_maternity_days   number;
l_p_no_of_babies_born	number;
l_p_compensation_rate	number;
l_p_paternity_days	number;
l_p_pt_paternity_days	number;
l_p_use_ss_daily_rate	varchar2(10);
l_p_daily_rate_calc	varchar2(10);
l_p_date_stillborn	date;
l_paternity_sum		number;
l_paternity_days	number;
l_p_reimburse_from_ss   varchar2(10);

l_p_reclaimable_pay_max_6g varchar2(10);
l_p_hol_acc_ent         varchar2(10);

-- Part Time Paternity variables
l_ptp_expected_dob	date;
l_ptp_dob		date;
l_ptp_percentage	number;
l_ptp_paternity_percent number;
l_ptp_compensation_rate	number;
l_ptp_pt_paternity_days	number;
l_ptp_no_of_babies_born number;
l_ptp_use_ss_daily_rate	varchar2(10);
l_ptp_daily_rate_calc	varchar2(10);
l_ptp_hol_acc_ent	varchar2(20);
l_ptp_maternity_sum	number;
l_ptp_maternity_days	number;
l_ptp_percent           number;
l_ptp_days_spouse_mat_leave  number;
l_ptp_mat_compensation_rate  number;
l_ptp_days_pt_maternity      number;
l_ptp_reimburse_from_ss      varchar2(10);
l_ptp_reclaimable_pay_max_6g varchar2(10);
l_pt_paternity_sum           number;
l_pt_paternity_days          number;
curr_year_cms_emp_days number;
curr_year_cms_ss_days  number;
l_emp_end_date         date;

/*Pgopal - Bug 5393827 and 5349713 fix*/
l_initial_absence CHAR ;
l_initial_abs_attend_id NUMBER ;
l_initial_abs_st_date DATE ;
l_initial_abs_pay_stdt DATE ;

BEGIN
hr_utility.set_location('Entering into absence package: ', 1);
p_abs_sick_days := 0;
        -- To select absence category code by passing absence category meaning.
	/* pgopal - passing the abs category code directly by attaching a value set to the element i/p value*/
       /*  BEGIN
        	 SELECT LOOKUP_CODE
        	   INTO l_abs_category_code
        	   FROM HR_LOOKUPS /* Bug fix 5263714 used hr_lookups instead of fnd_lookup_values
		   FROM FND_LOOKUP_VALUES
      	      WHERE LOOKUP_TYPE = 'ABSENCE_CATEGORY'
       	        AND ENABLED_FLAG = 'Y'
       	        AND MEANING = p_absence_category;
         EXCEPTION
           WHEN others THEN
    	        l_abs_category_code := null;
         END;*/
	 l_abs_category_code := p_abs_categorycode;
--         p_abs_categorycode := l_abs_category_code;
         -- Selecting person id, business group id through assignment id
         BEGIN
            SELECT PERSON_ID
                   ,BUSINESS_GROUP_ID
                   ,HOURLY_SALARIED_CODE
              INTO p_person_id
                   ,p_business_group_id
                   ,l_asg_hour_sal
              FROM PER_ALL_ASSIGNMENTS_F ASG
             WHERE ASG.ASSIGNMENT_ID = p_assignment_id
               AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE
                                    AND ASG.EFFECTIVE_END_DATE;
         EXCEPTION
            WHEN OTHERS THEN
                  p_person_id := null;
                  p_business_group_id := null;
                  l_asg_hour_sal := null;
         END;

        -- To get legal employer level EIT details
         BEGIN
             SELECT	hoi4.ORG_INFORMATION1
                    ,hoi4.ORG_INFORMATION2
                    ,hoi4.ORG_INFORMATION3
                    ,hoi4.ORG_INFORMATION4
                    ,hoi4.ORG_INFORMATION5
                    ,hoi4.ORG_INFORMATION6
                    ,hoi4.ORG_INFORMATION7
                    ,hoi4.ORG_INFORMATION8
               INTO l_le_reimb_ss
                    ,l_le_restrict_dr_ss
                    ,l_le_restrict_empr_sl
                    ,l_le_restrict_ss_sl
                    ,l_le_hour_sal
        	        ,l_le_entitled_sc
        	        ,l_le_exempt_empr
        	        ,l_le_daily_rate
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
                          AND P_EFFECTIVE_DATE BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE ) X
              WHERE o1.business_group_id = p_business_group_id
                AND hoi1.organization_id = o1.organization_id
                AND hoi1.organization_id = X.ORG_ID
                AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
                AND hoi1.org_information_context = 'CLASS'
                AND o1.organization_id = hoi2.org_information1
                AND hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
                AND hoi2.organization_id =  hoi3.organization_id
                AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
                AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
                AND hoi3.organization_id = hoi4.organization_id
                AND hoi4.ORG_INFORMATION_CONTEXT='NO_ABSENCE_PAYMENT_DETAILS';
         EXCEPTION
           WHEN OTHERS THEN
                l_le_reimb_ss         := NULL;
                l_le_restrict_dr_ss   := NULL;
                l_le_restrict_empr_sl := NULL;
                l_le_restrict_ss_sl   := NULL;
                l_le_hour_sal         := NULL;
       	        l_le_entitled_sc      := NULL;
        	    l_le_exempt_empr      := NULL;
        	    l_le_daily_rate       := NULL;
         END;
        -- To get absence payment details under person form.
         BEGIN
        	 SELECT PER_INFORMATION6   AS HOURLY_SALARIED
        	        ,PER_INFORMATION7  AS ENTITLE_SC
        	        ,PER_INFORMATION8  AS EXEMPT_EMPR
        	        ,PER_INFORMATION9  AS REIMB_SS
        	        ,PER_INFORMATION10 AS RESTRICT_DR_SS
                    ,PER_INFORMATION11 AS RESTRICT_EMPR_SL
                    ,PER_INFORMATION12 AS RESTRICT_SS_SL
                    ,PER_INFORMATION14 AS DAILY_RATE   /* knelli changed from PER_INFORMATION13*/
                    ,START_DATE        AS DATEOFJOIN
        	   INTO l_hourly_salaried
        	        ,l_entitled_sc
        	        ,l_exempt_empr
        	        ,l_reimb_ss
        	        ,l_restrict_dr_ss
        	        ,l_restrict_empr_sl
        	        ,l_restrict_ss_sl
        	        ,l_per_daily_rate
        	        ,l_dateofjoin
        	   FROM PER_ALL_PEOPLE_F PER
      	      WHERE PER.PERSON_ID = p_person_id
     	        AND P_EFFECTIVE_DATE BETWEEN PER.EFFECTIVE_START_DATE
                                     AND PER.EFFECTIVE_END_DATE;
         EXCEPTION
           WHEN others THEN
        	    l_hourly_salaried  := NULL;
        	    l_entitled_sc      := NULL;
        	    l_exempt_empr      := NULL;
        	    l_reimb_ss         := NULL;
        	    l_restrict_dr_ss   := NULL;
        	    l_restrict_empr_sl := NULL;
        	    l_restrict_ss_sl   := NULL;
       	            l_dateofjoin       := NULL;
       	            l_per_daily_rate   := NULL;
         END;

/***************************************************************************
    SICKNESS - PART TIME SICKNESS ABSENCE CATEGORY
****************************************************************************/

        IF l_abs_category_code in ( 'S', 'PTS' ) THEN
               IF l_abs_category_code = 'S' THEN
                     -- Fetch EIT values from absence payment details form
        	       BEGIN
            		    SELECT PAA.ABS_INFORMATION1   AS Cert_type
            		           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss') AS Cert_stdt
            		           ,to_date(PAA.ABS_INFORMATION3,'yyyy/mm/dd hh24:mi:ss')  AS Cert_endt
            		           ,to_date(PAA.ABS_INFORMATION4,'yyyy/mm/dd hh24:mi:ss')  AS Follow_due
            		           ,to_date(PAA.ABS_INFORMATION5,'yyyy/mm/dd hh24:mi:ss')  AS Follow_created
            		           ,PAA.ABS_INFORMATION6  AS reimb_ss
            		           ,PAA.ABS_INFORMATION7  AS dailyrate_ss
            		           ,PAA.ABS_INFORMATION8  AS employer_6g
            		           ,PAA.ABS_INFORMATION9  AS socialsec_6g
            		           ,to_date(PAA.ABS_INFORMATION10,'yyyy/mm/dd hh24:mi:ss') AS Follow_sent
            		           ,PAA.ABS_INFORMATION11 AS Daily_rate
            		      INTO l_cert_type
                               ,l_cert_stdt
                               ,l_cert_endt
                               ,l_follow_due
                               ,l_follow_created
                               ,l_abs_reimb_ss
                               ,l_abs_restrict_dr_ss
                               ,l_abs_restrict_empr_sl
                               ,l_abs_restrict_ss_sl
                               ,l_follow_sent
                               ,l_abs_daily_rate
            		      FROM PER_ABSENCE_ATTENDANCES PAA
          		         WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;
                   EXCEPTION
        		        WHEN OTHERS THEN
                             l_cert_type            := null;
                             l_cert_stdt            := null;
                             l_cert_endt            := null;
                             l_follow_due           := null;
                             l_follow_created       := null;
                             l_abs_reimb_ss         := null;
                             l_abs_restrict_dr_ss   := null;
                             l_abs_restrict_empr_sl := null;
                             l_abs_restrict_ss_sl   := null;
                             l_follow_sent          := null;
                             l_abs_daily_rate       := null;
         	       END;

                ELSE
                   -- Fetch EIT values from absence payment details form
        	       BEGIN
            		    SELECT PAA.ABS_INFORMATION1   AS Cert_type
            		           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  AS Cert_stdt
            		           ,to_date(PAA.ABS_INFORMATION3,'yyyy/mm/dd hh24:mi:ss')  AS Cert_endt
            		           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION4)  AS PT_Percent
            		           ,to_date(PAA.ABS_INFORMATION5,'yyyy/mm/dd hh24:mi:ss')  AS Follow_due
            		           ,to_date(PAA.ABS_INFORMATION6,'yyyy/mm/dd hh24:mi:ss')  AS Follow_created
            		           ,PAA.ABS_INFORMATION7  AS reimb_ss
            		           ,PAA.ABS_INFORMATION8  AS dailyrate_ss
            		           ,PAA.ABS_INFORMATION9  AS employer_6g
            		           ,PAA.ABS_INFORMATION10 AS socialsec_6g
            		           ,to_date(PAA.ABS_INFORMATION11,'yyyy/mm/dd hh24:mi:ss') AS Follow_sent
            		           ,PAA.ABS_INFORMATION12 AS Daily_rate
            		      INTO l_cert_type
                               ,l_cert_stdt
                               ,l_cert_endt
                               ,l_abs_pts_percent
                               ,l_follow_due
                               ,l_follow_created
                               ,l_abs_reimb_ss
                               ,l_abs_restrict_dr_ss
                               ,l_abs_restrict_empr_sl
                               ,l_abs_restrict_ss_sl
                               ,l_follow_sent
                               ,l_abs_daily_rate
            		      FROM PER_ABSENCE_ATTENDANCES PAA
          		         WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;
                   EXCEPTION
        		        WHEN OTHERS THEN
                             l_cert_type            := null;
                             l_cert_stdt            := null;
                             l_cert_endt            := null;
                             l_abs_pts_percent      := null;
                             l_follow_due           := null;
                             l_follow_created       := null;
                             l_abs_reimb_ss         := null;
                             l_abs_restrict_dr_ss   := null;
                             l_abs_restrict_empr_sl := null;
                             l_abs_restrict_ss_sl   := null;
                             l_follow_sent          := null;
                             l_abs_daily_rate       := null;
         	       END;

                END IF;
               /* Identifying the input values based on the Priority levels. If none of the level has been
                  set then default value will be assigned. Refer mail dated 20th Feb 06 from Borge.*/
               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_entitled_sc       := nvl(nvl(l_entitled_sc, l_le_entitled_sc), 'Y');
               l_gen_exempt_empr       := nvl(nvl(l_exempt_empr, l_le_exempt_empr), 'N');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               l_gen_restrict_empr_sl  := nvl(nvl(nvl(l_abs_restrict_empr_sl, l_restrict_empr_sl), l_le_restrict_empr_sl), 'Y');
               l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_abs_restrict_ss_sl, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');
               l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);

               p_pts_percentage := l_abs_pts_percent ; /* 5410901 */
               /* This Message has been handled at Absence Recording Level itself
               -- Entitled to self certificate is set to no with self certificate has chosen then a warning message should be generated
               IF l_gen_entitled_sc = 'N' AND l_cert_type = 'SC' THEN

		 / knelli commented code and added one line of code
		 IF length(l_msg_error) > 1 THEN
                     l_msg_error := 'Error7';
                  END IF;
		  /

		l_msg_error := to_char(7);



               END IF;*/

               -- If current absence is a self certificate sickness and there are any
               -- sc sickness of total 3 days in the previous 14 days then warning message will be generated.
               /* This Message has been handled at Absence Recording Level itself
               IF l_abs_category_code IN ('S','PTS') AND l_cert_type = 'SC' THEN
                  BEGIN
                        SELECT SUM( PAA.DATE_END - PAA.DATE_START )
                          INTO l_abs_count
                          FROM PER_ABSENCE_ATTENDANCES PAA
                         WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id
                           AND PAA.DATE_END BETWEEN (p_abs_start_date - (p_abs_link_period+1)) AND (p_abs_start_date -1)
                           AND PAA.ABS_INFORMATION1 = 'SC'
                           AND PAA.DATE_START IS NOT NULL
                           AND PAA.DATE_END IS NOT NULL;
                  EXCEPTION
                      WHEN OTHERS THEN
                           NULL;
                  END;
                  IF l_abs_count > 3 THEN
                      / knelli
		      IF length(l_msg_error) > 1 THEN
                         l_msg_error := 'Error1';
                      END IF;/
		      l_msg_error := to_char(1);

                     -- Message to throw an warning message. No self certificate absences are allowed within 14 days of more than 3 days.
                  END IF;
               END IF; */
               /* This Message has been handled at Absence Recording Level itself
               l_abs_count := null;
               -- If current absence is a self certificate sickness and there are more than 4
               -- sc sickness in the previous 12 months then a warining message should be thrown.
               IF l_abs_category_code IN ('S','PTS') AND l_cert_type = 'SC' THEN
                  BEGIN
                        SELECT count(1)
                          INTO l_abs_count
                          FROM PER_ABSENCE_ATTENDANCES PAA
                         WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id
                           AND PAA.DATE_END BETWEEN add_months(p_abs_start_date, -12) AND (p_abs_start_date-1)
                           AND PAA.ABS_INFORMATION1 = 'SC'
                           AND PAA.DATE_START IS NOT NULL
                           AND PAA.DATE_END IS NOT NULL;
                  EXCEPTION
                      WHEN OTHERS THEN
                           NULL;
                  END;
                  IF l_abs_count > 0 THEN
                      / knelli
		      IF length(l_msg_error) = 1 THEN
                         l_msg_error := 'Error2';
                      END IF;/
		      l_msg_error := to_char(2);


                     -- Message to throw an warning message. Only 4 self certificate absences are allowed for an year.
                  END IF;
               END IF; */

               l_abs_count := null;
               -- Fetch absence reason from the lookup
    	       BEGIN
        		    SELECT LKP.Meaning
        		    INTO l_abs_reason
        		    FROM FND_LOOKUP_VALUES LKP
        			     ,PER_ABSENCE_ATTENDANCES PAA
        			     ,PER_ABS_ATTENDANCE_REASONS PAR
        		    WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID  = PAR.ABSENCE_ATTENDANCE_TYPE_ID
                      AND PAA.ABS_ATTENDANCE_REASON_ID  = PAR.ABS_ATTENDANCE_REASON_ID
        		      AND PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id
        		      AND LKP.lookup_type = 'ABSENCE_REASON'
        		      AND LOOKUP_CODE = PAR.NAME
                    GROUP BY LKP.Meaning;
               EXCEPTION
    		        WHEN OTHERS THEN
    		             l_abs_reason := NULL;
    	       END;

            -- Condition 1. First sick is allowed after 28 days of Join.
            /*5475038 - This message has been moved to recording level
            l_dateofjoin_28 := l_dateofjoin + p_abs_min_gap ;
            IF (l_abs_reason is Null or l_abs_reason <> 'Work Accident' ) THEN
                BEGIN
		/pdavidra - bug no 5330109 - Unauthorised absence count should be taken
		                              form DOJ to current absence date
					      instead of  DOJ to DOJ+28 days.
                    SELECT SUM ( CASE WHEN PAA.DATE_END > l_dateofjoin_28 THEN
                                           ( l_dateofjoin_28 - PAA.DATE_START)
                    				  WHEN PAA.DATE_START = PAA.DATE_END THEN
                    				       1
                    				  ELSE (PAA.DATE_END - PAA.DATE_START) END ) AS DAYS
                      INTO l_abs_unauthor
                      FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
                     WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
                       AND PAT.ABSENCE_CATEGORY = 'UN'
                       AND PAA.DATE_START <= l_dateofjoin_28
                       AND PAA.DATE_END   >= l_dateofjoin
                       AND PAA.DATE_START IS NOT NULL
                       AND PAA.DATE_END IS NOT NULL
                       AND PAA.PERSON_ID = p_person_id;/
                   SELECT SUM ( CASE WHEN PAA.DATE_END > (p_abs_start_date-1) THEN
                                           ( (p_abs_start_date-1) - PAA.DATE_START) + 1
                    		      WHEN PAA.DATE_START = PAA.DATE_END THEN
                    				       1
                    		      ELSE (PAA.DATE_END - PAA.DATE_START) + 1 END ) AS DAYS
                      INTO l_abs_unauthor
                      FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
                     WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
                       AND PAT.ABSENCE_CATEGORY = 'UN'
                       AND PAA.DATE_START <= (p_abs_start_date-1)
                       AND PAA.DATE_END   >= l_dateofjoin
                       AND PAA.DATE_START IS NOT NULL
                       AND PAA.DATE_END IS NOT NULL
                       AND PAA.PERSON_ID = p_person_id;
                EXCEPTION
                   WHEN OTHERS THEN
                        l_abs_unauthor := 0;
                END;

                IF ( p_abs_start_date - l_dateofjoin ) < (p_abs_min_gap + nvl(l_abs_unauthor,0) ) THEN

		      / knelli
		      IF length(l_msg_error) > 1 THEN
                         l_msg_error := 'Error3';
                      END IF;/
		      l_msg_error := to_char(3);

                END IF;

            -- Condition 2. Minimum 28 days employment is required to avail sick pay except sickness or holiday
	        -- within 28 days from start of the current absence. If any other absence exists with more than
	        -- 14 days within 28 days then no sickness will be paid.
                    BEGIN
                        SELECT COUNT(1)
                          INTO l_abs_count
                          FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
                         WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
                           AND PAT.ABSENCE_CATEGORY IN ( 'CMS','PA','PTP','M','PTM','IE_AL' ,'PTA')
                           AND PAA.DATE_END BETWEEN (p_abs_start_date - (p_abs_min_gap+1)) AND p_abs_start_date
			               AND ( PAA.DATE_END - PAA.DATE_START ) > p_abs_link_period
                           AND PAA.DATE_START IS NOT NULL
                           AND PAA.DATE_END IS NOT NULL
                           AND PAA.PERSON_ID = p_person_id;
                    EXCEPTION
                       WHEN OTHERS THEN
                            l_abs_count := 0;
                    END;

                -- There are sickness exists within 28days of current sickness start date with more than 14 days
		        -- except absence categories Sickness, Part-time sickness and Vacation.
		        IF l_abs_count > 0 THEN
                      / knelli
		      IF length(l_msg_error) > 1 THEN
                         l_msg_error := 'Error4';
                      END IF;/
		      l_msg_error := to_char(4);

                END IF;
            END IF; -- Work accident end if */

           -- Calling override to get override days and daily rate
           l_over_return := get_override_details
                            ( p_assignment_id,p_effective_date,p_abs_start_date,
                              p_abs_end_date, p_abs_categorycode, l_override_start_date,
                              l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                              l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                             );

	    /* Multiple override element attached against one absence element. ie)  *
             * One or more override entry exists with same start and end date       */
            IF (l_over_return = -1) THEN
              /* knelli
	      IF length(l_msg_error) > 1 THEN
                 l_msg_error := 'Error5';
              END IF;*/
	      l_msg_error := to_char(5);
              p_abs_error := l_msg_error;
              RETURN 1;
            END IF;
            IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start  + 1) THEN
               l_msg_error := to_char(13);
            END IF;
            l_include_event := 'N';
            -- Calculating actual sickness days through work schedule
            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                   l_end_time_char, l_duration
                                  );

               l_actual_cal_days := nvl(l_duration,0);

            -- Calculate Earnings Adjustment value
             IF l_abs_category_code = 'PTS' THEN /* 5437889 */
               --p_ear_value      := ( ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * (nvl(l_abs_pts_percent,0)/100) ) * l_actual_cal_days; 5925652
	       p_ear_value      := round(( ( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ) * (nvl(l_abs_pts_percent,0)/100) ),2) * l_actual_cal_days;
             ELSE
               --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days;  5925652
	       p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * l_actual_cal_days;
             END IF;
               p_ear_startdt    := p_prorate_start;
               p_ear_enddt      := p_prorate_end;
               p_ear_value      := nvl(p_ear_value,0);

           -- Calculate total absence days
           l_gen_totalabs_days := (p_abs_end_date - p_abs_start_date ) + 1;
           -- Calculate total prorated day(s) of the current payroll
           l_gen_pro_days      := (p_prorate_end - p_prorate_start ) + 1;
           -- Calculate Employer's period start date
           l_gen_empr_st_date  := p_prorate_start;
           -- Seeking the start of the Social Security start date.

           IF l_gen_totalabs_days > p_abs_cal_days THEN
              l_gen_ss_st_date := (p_abs_start_date + p_abs_cal_days);
           ELSE
              l_gen_ss_st_date := null;
           END IF;

           p_abs_total_cal_days :=  (p_prorate_end - p_prorate_start) + 1 ;

           l_return := null;
           -- To fetch the 26week rule period values
           l_return := get_sick_unpaid (p_assignment_id, p_effective_date, p_dbi_26week_stdt, p_dbi_26week_endt);
/*====================================================================================================
	    -- Implementation of top logic to calculate actual days using proration and finding
            -- the continuous linking period.
            IF p_abs_start_date between p_pay_start_date AND p_pay_end_date
               AND p_abs_end_date between p_pay_start_date AND p_pay_end_date THEN

               -- Condition 3 - Calculate continuous linking period of sickness
               -- If there are multiple sickness exists within 14 days before start date then
               -- include those sickness in calculating employer days.
                l_loop_empr_days := 0;
                l_loop_empr_work_days := 0;
                l_loop_start_date := p_abs_start_date ;
                FOR i in CSR_CONT_LINK (p_person_id) LOOP
                    IF ( i.date_start = i.date_end ) THEN
                        l_loop_empr_days := l_loop_empr_days + 1;
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);
                    ELSIF ( l_loop_start_date - i.date_end ) <= p_abs_link_period then
                        l_duration := 0;
                        l_duration := (i.date_end - i.date_start) +1;
                        l_loop_empr_days := (l_loop_empr_days + nvl(l_duration,0));
                       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element exists for the continuous absences then override the work days.
                        IF l_cont_empr_days IS NULL THEN
                           l_duration := 0;
                           l_include_event := 'N';
                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));
                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;
                    ELSE -- No linking absence exists.
                          EXIT;
                    END IF;
                    l_loop_start_date := i.date_start;
                END LOOP;

               -- Calculation of Employer Days in terms of calendar days
               -- If continuous linked cal days exceeds maximum 16 days then for current absence empr period will be 0
               IF l_loop_empr_days >= p_abs_cal_days THEN
                  l_empr_days := 0;
                  l_gen_ss_st_date := p_prorate_start ;
                  IF l_gen_reimb_ss = 'N' THEN
                     l_msg_error := to_char(12); / Legislative limit exhausted Message /
                  END IF;
                  -- Update the element input value Employer Cal Days with existing plus current empr days.
                  -- ie) existing := existing + l_empr_days
               ELSE
		  / pdavidra commented
                  IF l_gen_totalabs_days > (p_abs_cal_days - l_loop_empr_days) THEN
                       -- Absence lies within a payroll period
                       -- Calculating actual sickness days through work schedule
                        l_gen_ss_st_date := p_prorate_start + (p_abs_cal_days - l_loop_empr_days);

                        -- Ignore public holidays if the one present in between absence start and end dates.
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                             ( p_assignment_id, l_days_or_hours, l_include_event,
                                               p_prorate_start, (l_gen_ss_st_date - 1), l_start_time_char,
                                               l_end_time_char, l_duration
                                              );
                        l_actual_days := l_duration;
			p_abs_sick_days := (l_gen_ss_st_date - p_prorate_start);

                  -- Update the element input value Employer Cal Days with existing plus current empr days.
                  -- ie) existing := existing + (p_abs_cal_days - l_loop_empr_days)
                  ELSE
                       -- Calculation of Employer Days
                       -- Absence lies within a payroll period
                       -- Calculating actual sickness days through work schedule
                        l_gen_ss_st_date := null;

                        -- Ignore public holidays if the one present in between absence start and end dates.
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                             ( p_assignment_id, l_days_or_hours, l_include_event,
                                               p_prorate_start, p_prorate_end, l_start_time_char,
                                               l_end_time_char, l_duration
                                              );
                        l_actual_days := nvl(l_duration,0);
                        p_abs_sick_days := (p_prorate_end - p_prorate_start) + 1;

                  -- Update the element input value Employer Cal Days with existing plus current empr days.
                  -- ie) existing := existing + l_gen_totalabs_days
                  END IF; /

		      / pdavidra added code start - Bug no: 5277080/
		      l_include_event := 'N';
                      l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                      l_actual_days := l_duration;
		      / pdavidra added code end/

                  -- Continuous sickness work days greater than 12 working days so no more empr days will be paid.
                  IF l_loop_empr_work_days >= p_abs_work_days THEN

		     l_empr_days := 0;
                     IF l_gen_reimb_ss = 'N' THEN
                        l_msg_error := to_char(12); / Legislative limit exhausted Message /
                     END IF;
                  ELSE -- Continuous sickness days is less than 12 working days
                        -- if actual working days  > remaning available then social security days will be paid

			IF l_actual_days > ( p_abs_work_days - l_loop_empr_work_days ) THEN
                           l_empr_days := ( p_abs_work_days - l_loop_empr_work_days );
                           IF l_gen_reimb_ss = 'N' THEN
                             l_msg_error := to_char(12); / Legislative limit exhausted Message /
                           END IF;
                           -- if override employer days is present calculate actual days through continuous linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;
                           -- Update the element input value Employer work Days with existing plus current empr days.
                           -- ie) existing := existing + l_empr_days;
                        ELSE
                           l_empr_days := l_actual_days;
                           -- if override employer days is present calculate actual days through continuous linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;
                           -- Update the element input value Employer work Days with existing plus current empr days.
                           -- ie) existing := existing + l_empr_days;
                        END IF;

                  END IF;
               END IF;
                           / 5277080 start - Calculate the Social Security Start Date /
                           l_gen_ss_st_date := p_prorate_start + l_empr_days ;
                           loop
                                l_include_event := 'N';
                                l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                ( p_assignment_id, l_days_or_hours, l_include_event,
                                  p_prorate_start, l_gen_ss_st_date, l_start_time_char,
                                  l_end_time_char, l_duration
                                 );

                                 IF l_duration = (l_empr_days +1) THEN
                                    exit;
                                 END IF;
                                 l_gen_ss_st_date := l_gen_ss_st_date + 1;
                           end loop;
                           / 5277080 End /

                -- CALCULATION OF SOCIAL SECURITY DAYS
                   -- Calculate social security days if reimburse from social security is set to Yes at any level

		   IF l_gen_reimb_ss = 'Y' THEN
                       -- IF social security start date is within the current payroll period then
                       IF l_gen_ss_st_date >= p_prorate_start and l_gen_ss_st_date <= p_prorate_end then
                     -- If the 26week rule element input value's start date and end date are set then
			IF l_return = 0 THEN
                   	     -- If Current absence is withing the 26week rule period then throw a warning message
                             IF l_gen_ss_st_date <= p_dbi_26week_endt AND p_prorate_end >= p_dbi_26week_stdt THEN
                                l_social_security_days := null;
                                l_msg_error := to_char(9);
                                 --Throw warning message that no social security days will be paid due to 26week rule.
                             ELSE
				p_work_pattern := '5DAY';
                                l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                -- if exempt from employer period id set to no
                                IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                   IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE
                                      l_social_security_days := l_duration;
                                   END IF;
                                ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                   IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE -- user can avail the actual ss days as it is within 260 limit
                                      l_social_security_days := l_duration;
                                   END IF;
                                END IF; -- l_gen_exempt_empr = 'N'
                             END IF; -- Current absence is beyond the 26week rule period

                          ELSE -- 26week rule element not attached to this assignment
                            p_work_pattern := '5DAY';
                            l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                            -- if exempt from employer period id set to no
                            IF l_gen_exempt_empr = 'N' THEN -- 248 days
                               IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                  l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                  l_msg_error := to_char(12); / Legislative limit exhausted Message /
                               ELSE
                                  l_social_security_days := l_duration;
                               END IF;
                            ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                               IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                  l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                  l_msg_error := to_char(12); / Legislative limit exhausted Message /
                               ELSE -- user can avail the actual ss days as it is within 260 limit
                                  l_social_security_days := l_duration;
                               END IF;

                            END IF; -- l_gen_exempt_empr = 'N'
                          END IF; -- If the 26week rule element input value's start date and end date are set then
                       ELSE

			  / knelli changed code /
			  l_social_security_days := 0;
			  /l_social_security_days := l_actual_days - l_empr_days;/
                       END IF; -- IF social security start date is within the absence period or prorated period then

		   END IF; --Calculate social security days if reimburse from social security is set to Yes at any level
                   -- if override social security days is present calculate actual days with the override days.

		   IF l_override_ss_days IS NOT NULL THEN
                      l_social_security_days := least(l_override_ss_days, l_social_security_days);
                   END IF;
                       -- If social security days availed from this absence exeeecs 220 days then a warning message should be thrown.
                       IF ( nvl(l_social_security_days,0) + nvl(p_3years_paybase,0) ) > 220 THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error6';
                          END IF;/
			  l_msg_error := to_char(6);

                       END IF;
------------------------------------------------------------------------------
------------------------------------------------------------------------------

            Else -- Absences lies more than one payroll period
               -- Absence start date lies in between the payroll period st dt and end dt.
               IF p_abs_start_date between p_pay_start_date and p_pay_end_date THEN

		 -- Condition 3 - Calculate continuous linking period of sickness
                 -- If there are multiple sickness exists within 14 days before start date then
                 -- include those sickness in calculating employer days.
                  l_loop_empr_days := 0;
                  l_loop_empr_work_days := 0;
                  l_loop_start_date := p_abs_start_date ;
                  FOR i in CSR_CONT_LINK (p_person_id) LOOP
                    IF ( i.date_start = i.date_end ) THEN
                        l_loop_empr_days := l_loop_empr_days + 1;
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);
                    ELSIF ( l_loop_start_date - i.date_end ) <= p_abs_link_period then
                        l_duration := 0;
                        l_duration := (i.date_end - i.date_start) +1;
                        l_loop_empr_days := (l_loop_empr_days + nvl(l_duration,0));
                       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element exists for the continuous absences then override the work days.
                        IF l_cont_empr_days IS NULL THEN
                           l_duration := 0;
                           l_include_event := 'N';
                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));
                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;
                    ELSE -- No linking absence exists.
                          EXIT;
                    END IF;
                      l_loop_start_date := i.date_start;
                  END LOOP;

                  -- Calculation of employer days if proration was enabled
                  l_counter := 1;
                  FOR I IN CSR_CUR_ABS_PRORATED(p_assignment_id, p_effective_date, p_abs_start_date, p_abs_end_date) LOOP
                    -- It means absences crosses between one payroll period
                    IF l_counter = 1 THEN
                       -- Newly introduced to knock off calendar and work days variables of employers period already taken.
                       -- As it is a start of the proration period.
                       l_loop_empr_days := nvl(l_loop_empr_days,0) + 0;
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + 0;

                    ELSE
                       -- Calculating calendar days with prorated period
                       l_loop_empr_days := nvl(l_loop_empr_days,0) + ( i.date_earned - l_prev_paydate);
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (l_prev_paydate+1), i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    END IF;
                       l_counter := l_counter + 1;
                       l_prev_paydate := i.date_earned;
                   END LOOP;

                   -- Calculation of Employer Days in terms of calendar days
                   -- If continuous linked cal days exceeds maximum 16 days then for current absence empr period will be 0

		   IF l_loop_empr_days >= p_abs_cal_days THEN
                      l_empr_days := 0;
                      l_gen_ss_st_date := p_prorate_start ;
                      IF l_gen_reimb_ss = 'N' THEN
                         l_msg_error := to_char(12); / Legislative limit exhausted Message /
                      END IF;
                      -- Update the element input value Employer Cal Days with existing plus current empr days.
                      -- ie) existing := existing + l_empr_days
                   ELSE

		      / knelli commented
		      IF l_gen_totalabs_days > (p_abs_cal_days - l_loop_empr_days) THEN
                           -- Absence lies within a payroll period
                           -- Calculating actual sickness days through work schedule
                            l_gen_ss_st_date := p_prorate_start + (p_abs_cal_days - l_loop_empr_days);
                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'N';
                            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, (l_gen_ss_st_date - 1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                            l_actual_days := l_duration;
                      -- Update the element input value Employer Cal Days with existing plus current empr days.
                      -- ie) existing := existing + (p_abs_cal_days - l_loop_empr_days)
                      ELSE
                           -- Calculation of Employer Days
                           -- Absence lies within a payroll period
                           -- Calculating actual sickness days through work schedule
                            l_gen_ss_st_date := null;
                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'N';
                            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                            l_actual_days := l_duration;
                      END IF;
		      /

		      / knelli added code start/
		      l_include_event := 'N';
                      l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                      l_actual_days := l_duration;
		      / knelli added code end/

                      -- Continuous sickness work days greater than 12 working days so no more empr days will be paid.
                      IF l_loop_empr_work_days >= p_abs_work_days THEN
                         l_empr_days := 0;
                         IF l_gen_reimb_ss = 'N' THEN
                            l_msg_error := to_char(12); / Legislative limit exhausted Message /
                         END IF;
                      ELSE -- Continuous sickness days is less than 12 working days
                            -- if actual working days  > remaning available then social security days will be paid
                            IF l_actual_days > ( p_abs_work_days - l_loop_empr_work_days ) THEN
                               l_empr_days := ( p_abs_work_days - l_loop_empr_work_days );
                               IF l_gen_reimb_ss = 'N' THEN
                                  l_msg_error := to_char(12); / Legislative limit exhausted Message /
                               END IF;
                               -- if override employer days is present calculate actual days through continuous linking sickness
                               -- and then override that with the override days.
                               IF l_override_empr_days IS NOT NULL THEN
                                  l_empr_days := least(l_override_empr_days, l_empr_days);
                               END IF;
                            ELSE
                               l_empr_days := l_actual_days;
                               -- if override employer days is present calculate actual days through continuous linking sickness
                               -- and then override that with the override days.
                               IF l_override_empr_days IS NOT NULL THEN
                                  l_empr_days := least(l_override_empr_days, l_empr_days);
                               END IF;
                            END IF;
                      END IF;
                   END IF;
                               / 5277080 start - Calculate the Social Security Start Date /
                               l_gen_ss_st_date := p_prorate_start + l_empr_days ;
                               loop
                                   l_include_event := 'N';
                                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                   ( p_assignment_id, l_days_or_hours, l_include_event,
                                     p_prorate_start, l_gen_ss_st_date, l_start_time_char,
                                     l_end_time_char, l_duration
                                   );

                                   IF l_duration = (l_empr_days +1) THEN
                                      exit;
                                   END IF;
                                   l_gen_ss_st_date := l_gen_ss_st_date + 1;
                              end loop;
                              / 5277080 End /

                    -- CALCULATION OF SOCIAL SECURITY DAYS
                       -- Calculate social security days if reimburse from social security is set to Yes at any level
                       IF l_gen_reimb_ss = 'Y' THEN
                           -- IF social security start date is within the current payroll period then
                           IF l_gen_ss_st_date >= p_prorate_start and l_gen_ss_st_date <= p_prorate_end then
                              -- If the 26week rule element input value's start date and end date are set then
                              IF l_return = 0 THEN
                                 -- If Current absence is withing the 26week rule period then throw a warning message
                                 IF l_gen_ss_st_date <= p_dbi_26week_endt AND p_prorate_end >= p_dbi_26week_stdt THEN
                                    l_social_security_days := null;
                                      / knelli
				      IF length(l_msg_error) > 1 THEN
                                         l_msg_error := 'Error9';
                                      END IF;/
				      l_msg_error := to_char(9);
                                     --Throw warning message that no social security days will be paid due to 26week rule.
                                 ELSE
                                    p_work_pattern := '5DAY';
                                    l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                    -- if exempt from employer period id set to no
                                    IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                       IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                          l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                          l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                       ELSE
                                          l_social_security_days := l_duration;
                                       END IF;
                                    ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                       IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                          l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                          l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                       ELSE -- user can avail the actual ss days as it is within 260 limit
                                          l_social_security_days := l_duration;
                                       END IF;
                                    END IF; -- l_gen_exempt_empr = 'N'
                                 END IF; -- Current absence is beyond the 26week rule period

                              ELSE -- 26week rule element not attached to this assignment
                                p_work_pattern := '5DAY';
                                l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                -- if exempt from employer period id set to no
                                IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                   IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE
                                      l_social_security_days := l_duration;
                                   END IF;
                                ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                   IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE -- user can avail the actual ss days as it is within 260 limit
                                      l_social_security_days := l_duration;
                                   END IF;
                                END IF; -- l_gen_exempt_empr = 'N'
                              END IF; -- If the 26week rule element input value's start date and end date are set then
                           ELSE
                              l_social_security_days := 0;
                           END IF; -- IF social security start date is within the absence period or prorated period then

                       END IF; --Calculate social security days if reimburse from social security is set to Yes at any level
                       -- if override social security days is present calculate actual days with the override days.
                       IF l_override_ss_days IS NOT NULL THEN
                          l_social_security_days := least(l_override_ss_days, l_social_security_days);
                       END IF;

                       -- If social security days availed from this absence exeeecs 220 days then a warning message should be thrown.
                       IF ( nvl(l_social_security_days,0) + nvl(p_3years_paybase,0) ) > 220 THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error6';
                          END IF;/
			  l_msg_error := to_char(6);

                       END IF;
-------------------------------------------------------------------------
-------------------------------------------------------------------------

               -- Refer the previous payroll period's element input value for Empr and SS days calc.
               -- Absence end date lies in between the payroll period st dt and end dt.
               ELSIF p_abs_end_date between p_pay_start_date and p_pay_end_date THEN

		 -- Condition 3 - Calculate continuous linking period of sickness
                 -- If there are multiple sickness exists within 14 days before start date then
                 -- include those sickness in calculating employer days.
                  l_loop_empr_days := 0;
                  l_loop_empr_work_days := 0;
                  l_loop_start_date := p_abs_start_date ;
                  FOR i in CSR_CONT_LINK (p_person_id) LOOP

                    IF ( i.date_start = i.date_end ) THEN
                        l_loop_empr_days := l_loop_empr_days + 1;
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);

                    ELSIF ( l_loop_start_date - i.date_end ) <= p_abs_link_period then
                        -- Calculate the employer period days in terms of calendar days.
                        l_duration := 0;
                        l_duration := (i.date_end - i.date_start) +1;
                        l_loop_empr_days := (l_loop_empr_days + nvl(l_duration,0));
                        -- Calculate the employer period days in terms of actual working days.
                       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element exists for the continuous absences then override the work days.
                        IF l_cont_empr_days IS NULL THEN
                           l_duration := 0;
                           l_include_event := 'N';
                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));
                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;
                    ELSE -- No linking absence exists.
                          EXIT;
                    END IF;
                      l_loop_start_date := i.date_start;
                  END LOOP;

                  -- Calculation of employer days if proration was enabled
                  l_counter := 1;
                  FOR I IN CSR_CUR_ABS_PRORATED(p_assignment_id, p_effective_date, p_abs_start_date, p_abs_end_date) LOOP
                    -- It means absences crosses between one payroll period
                    IF l_counter = 1 THEN
                       -- Calculating calendar days with prorated period
                       l_loop_empr_days := nvl(l_loop_empr_days,0) + (i.date_earned - p_abs_start_date)+1;
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           p_abs_start_date, i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    ELSE
                       -- Calculating calendar days with prorated period
                       l_loop_empr_days := nvl(l_loop_empr_days,0) + ( i.date_earned - l_prev_paydate);
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (l_prev_paydate+1), i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    END IF;
                       l_counter := l_counter + 1;
                       l_prev_paydate := i.date_earned;
                   END LOOP;

                   -- Calculation of Employer Days in terms of calendar days
                   -- If continuous linked cal days exceeds maximum 16 days then for current absence empr period will be 0

		   IF l_loop_empr_days >= p_abs_cal_days THEN
                      l_empr_days := 0;
                      l_gen_ss_st_date := p_prorate_start ;
                      IF l_gen_reimb_ss = 'N' THEN
                         l_msg_error := to_char(12); / Legislative limit exhausted Message /
                      END IF;
                   ELSE

		      / knelli commented
		      IF l_gen_totalabs_days > (p_abs_cal_days - l_loop_empr_days) THEN
                           -- Absence lies within a payroll period
                           -- Calculating actual sickness days through work schedule
                            l_gen_ss_st_date := p_prorate_start + (p_abs_cal_days - l_loop_empr_days);
                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'N';
                            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, (l_gen_ss_st_date - 1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                            l_actual_days := l_duration;
                      ELSE
                           -- Calculation of Employer Days
                           -- Absence lies within a payroll period
                           -- Calculating actual sickness days through work schedule
                            l_gen_ss_st_date := null;
                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'N';
                            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                            l_actual_days := l_duration;
                      END IF;
		      /

		      / knelli added code start/
		      l_include_event := 'N';
                      l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                      l_actual_days := l_duration;
		      / knelli added code end /

                      -- Continuous sickness work days greater than 12 working days so no more empr days will be paid.
                      IF l_loop_empr_work_days >= p_abs_work_days THEN
                         l_empr_days := 0;
                         IF l_gen_reimb_ss = 'N' THEN
                            l_msg_error := to_char(12); / Legislative limit exhausted Message /
                         END IF;
                      ELSE -- Continuous sickness days is less than 12 working days
                            -- if actual working days  > remaning available then social security days will be paid
                            IF l_actual_days > ( p_abs_work_days - l_loop_empr_work_days ) THEN
                               l_empr_days := ( p_abs_work_days - l_loop_empr_work_days );
                               IF l_gen_reimb_ss = 'N' THEN
                                  l_msg_error := to_char(12); / Legislative limit exhausted Message /
                               END IF;
                               -- if override employer days is present calculate actual days through continuous linking sickness
                               -- and then override that with the override days.
                               IF l_override_empr_days IS NOT NULL THEN
                                  l_empr_days := least(l_override_empr_days, l_empr_days);
                               END IF;
                            ELSE
                               l_empr_days := l_actual_days;
                               -- if override employer days is present calculate actual days through continuous linking sickness
                               -- and then override that with the override days.
                               IF l_override_empr_days IS NOT NULL THEN
                                  l_empr_days := least(l_override_empr_days, l_empr_days);
                               END IF;
                            END IF;
                      END IF;
                   END IF;
                               / 5277080 start - Calculate the Social Security Start Date /
                               l_gen_ss_st_date := p_prorate_start + l_empr_days ;
                               loop
                                   l_include_event := 'N';
                                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                   ( p_assignment_id, l_days_or_hours, l_include_event,
                                     p_prorate_start, l_gen_ss_st_date, l_start_time_char,
                                     l_end_time_char, l_duration
                                   );

                                   IF l_duration = (l_empr_days +1) THEN
                                      exit;
                                   END IF;
                                   l_gen_ss_st_date := l_gen_ss_st_date + 1;
                              end loop;
                              / 5277080 End /

                -- CALCULATION OF SOCIAL SECURITY DAYS
                   -- Calculate social security days if reimburse from social security is set to Yes at any level
                       IF l_gen_reimb_ss = 'Y' THEN
                           -- IF social security start date is within the current payroll period then
                           IF l_gen_ss_st_date >= p_prorate_start and l_gen_ss_st_date <= p_prorate_end then
                              -- If the 26week rule element input value's start date and end date are set then
                              IF l_return = 0 THEN
                                 -- If Current absence is withing the 26week rule period then throw a warning message
                                 IF l_gen_ss_st_date <= p_dbi_26week_endt AND p_prorate_end >= p_dbi_26week_stdt THEN
                                    l_social_security_days := null;
                                      / knelli
				      IF length(l_msg_error) > 1 THEN
                                         l_msg_error := 'Error9';
                                      END IF;/
				      l_msg_error := to_char(9);
                                     --Throw warning message that no social security days will be paid due to 26week rule.
                                 ELSE
                                    p_work_pattern := '5DAY';
                                    l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                    -- if exempt from employer period id set to no
                                    IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                       IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                          l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                          l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                       ELSE
                                          l_social_security_days := l_duration;
                                       END IF;
                                    ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                       IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                          l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                          l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                       ELSE -- user can avail the actual ss days as it is within 260 limit
                                          l_social_security_days := l_duration;
                                       END IF;
                                    END IF; -- l_gen_exempt_empr = 'N'
                                 END IF; -- Current absence is beyond the 26week rule period

                              ELSE -- 26week rule element not attached to this assignment
                                p_work_pattern := '5DAY';
                                l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                -- if exempt from employer period id set to no
                                IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                   IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE
                                      l_social_security_days := l_duration;
                                   END IF;
                                ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                   IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE -- user can avail the actual ss days as it is within 260 limit
                                      l_social_security_days := l_duration;
                                   END IF;
                                END IF; -- l_gen_exempt_empr = 'N'
                              END IF; -- If the 26week rule element input value's start date and end date are set then
                           ELSE
                              l_social_security_days := 0;
                           END IF; -- IF social security start date is within the absence period or prorated period then

                       END IF; --Calculate social security days if reimburse from social security is set to Yes at any level
                       -- if override social security days is present calculate actual days with the override days.
                       IF l_override_ss_days IS NOT NULL THEN
                          l_social_security_days := least(l_override_ss_days, l_social_security_days);
                       END IF;
                       -- If social security days availed from this absence exeeecs 220 days then a warning message should be thrown.
                       IF ( nvl(l_social_security_days,0) + nvl(p_3years_paybase,0) ) > 220 THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error6';
                          END IF;/
			  l_msg_error := to_char(6);

                       END IF;
----------------------------------------------------------------------
----------------------------------------------------------------------
               ELSE -- Absence start and end date, both not lying in between the payroll period st dt and end dt.
                 -- Condition 3 - Calculate continuous linking period of sickness
                 -- If there are multiple sickness exists within 14 days before start date then
                 -- include those sickness in calculating employer days.

		  l_loop_empr_days := 0;
                  l_loop_empr_work_days := 0;
                  l_loop_start_date := p_abs_start_date ;
                  FOR i in CSR_CONT_LINK (p_person_id) LOOP

                    IF ( i.date_start = i.date_end ) THEN

                        l_loop_empr_days := l_loop_empr_days + 1;
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);
                    ELSIF ( l_loop_start_date - i.date_end ) <= p_abs_link_period then
                        -- Calculate the employer period days in terms of calendar days.
                        l_duration := 0;
                        l_duration := (i.date_end - i.date_start) +1;
                        l_loop_empr_days := (l_loop_empr_days + nvl(l_duration,0));
                        -- Calculate the employer period days in terms of actual working days.
                       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element exists for the continuous absences then override the work days.
                        IF l_cont_empr_days IS NULL THEN
                           l_duration := 0;
                           l_include_event := 'N';
                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));
                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;
                    ELSE -- No linking absence exists.
                          EXIT;
                    END IF;
                      l_loop_start_date := i.date_start;
                  END LOOP;

                  -- Calculation of employer days if proration was enabled
                  l_counter := 1;
                  FOR I IN CSR_CUR_ABS_PRORATED(p_assignment_id, p_effective_date, p_abs_start_date, p_abs_end_date) LOOP
                    -- It means absences crosses between one payroll period
                    IF l_counter = 1 THEN
                       -- Calculating calendar days with prorated period
                       l_loop_empr_days := nvl(l_loop_empr_days,0) + (i.date_earned - p_abs_start_date)+1;
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           p_abs_start_date, i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    ELSE
                       -- Calculating calendar days with prorated period
                       l_loop_empr_days := nvl(l_loop_empr_days,0) + ( i.date_earned - l_prev_paydate);
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (l_prev_paydate+1), i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    END IF;
                       l_counter := l_counter + 1;
                       l_prev_paydate := i.date_earned;
                   END LOOP;

		   / knelli added code start /
		      l_include_event := 'N';
                      l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                      l_actual_days := l_duration;

		      IF l_loop_empr_work_days > 0 THEN
			l_loop_empr_work_days := l_loop_empr_work_days - l_actual_days;
		      END IF;
		      / knelli added code end /

                   -- Calculation of Employer Days in terms of calendar days
                   -- If continuous linked cal days exceeds maximum 16 days then for current absence empr period will be 0
                   / knelli changed check condition
		   IF l_loop_empr_days >= p_abs_cal_days THEN/
		   IF l_loop_empr_work_days >= p_abs_work_days THEN
                      l_empr_days := 0;
                      l_gen_ss_st_date := p_prorate_start ;
                      IF l_gen_reimb_ss = 'N' THEN
                         l_msg_error := to_char(12); / Legislative limit exhausted Message /
                      END IF;
                   ELSE
                      / knelli commented code
		      IF l_gen_totalabs_days > (p_abs_cal_days - l_loop_empr_days) THEN
                           -- Absence lies within a payroll period
                           -- Calculating actual sickness days through work schedule
                            l_gen_ss_st_date := p_prorate_start + (p_abs_cal_days - l_loop_empr_days);
                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'N';
                            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, (l_gen_ss_st_date - 1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                            l_actual_days := l_duration;
                      ELSE
                           -- Calculation of Employer Days
                           -- Absence lies within a payroll period
                           -- Calculating actual sickness days through work schedule
                            l_gen_ss_st_date := null;
                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'N';
                            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                                   l_end_time_char, l_duration
                                                  );
                            l_actual_days := l_duration;
                      END IF;
		      /


                      -- Continuous sickness work days greater than 12 working days so no more empr days will be paid.
                      IF l_loop_empr_work_days >= p_abs_work_days THEN
                         l_empr_days := 0;
                         IF l_gen_reimb_ss = 'N' THEN
                            l_msg_error := to_char(12); / Legislative limit exhausted Message /
                         END IF;
                      ELSE -- Continuous sickness days is less than 12 working days
                            -- if actual working days  > remaning available then social security days will be paid
                            IF l_actual_days > ( p_abs_work_days - l_loop_empr_work_days ) THEN
                               l_empr_days := ( p_abs_work_days - l_loop_empr_work_days );
                               IF l_gen_reimb_ss = 'N' THEN
                                  l_msg_error := to_char(12); / Legislative limit exhausted Message /
                               END IF;
                               -- if override employer days is present calculate actual days through continuous linking sickness
                               -- and then override that with the override days.
                               IF l_override_empr_days IS NOT NULL THEN
                                  l_empr_days := least(l_override_empr_days, l_empr_days);
                               END IF;
                            ELSE
                               l_empr_days := l_actual_days;
                               -- if override employer days is present calculate actual days through continuous linking sickness
                               -- and then override that with the override days.
                               IF l_override_empr_days IS NOT NULL THEN
                                  l_empr_days := least(l_override_empr_days, l_empr_days);
                               END IF;
                            END IF;
                      END IF;
                   END IF;
                               / 5277080 start - Calculate the Social Security Start Date/
                               l_gen_ss_st_date := p_prorate_start + l_empr_days ;
                               loop
                                   l_include_event := 'N';
                                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                   ( p_assignment_id, l_days_or_hours, l_include_event,
                                     p_prorate_start, l_gen_ss_st_date, l_start_time_char,
                                     l_end_time_char, l_duration
                                   );

                                   IF l_duration = (l_empr_days +1) THEN
                                      exit;
                                   END IF;
                                   l_gen_ss_st_date := l_gen_ss_st_date + 1;
                              end loop;
                              / 5277080 End /

                -- CALCULATION OF SOCIAL SECURITY DAYS
                   -- Calculate social security days if reimburse from social security is set to Yes at any level

		       IF l_gen_reimb_ss = 'Y' THEN
                            -- IF social security start date is within the current payroll period then
                              IF l_gen_ss_st_date >= p_prorate_start and l_gen_ss_st_date <= p_prorate_end then
                              -- If the 26week rule element input value's start date and end date are set then

			      IF l_return = 0 THEN
                                 -- If Current absence is within the 26week rule period then throw a warning message
                                  IF l_gen_ss_st_date <= p_dbi_26week_endt AND p_prorate_end >= p_dbi_26week_stdt THEN
                                    l_social_security_days := null;
                                      / knelli
				      IF length(l_msg_error) > 1 THEN
                                         l_msg_error := 'Error9';
                                      END IF;/
				      l_msg_error := to_char(9);

                                     --Throw warning message that no social security days will be paid due to 26week rule.
                                 ELSE
                                    p_work_pattern := '5DAY';
                                    l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                    -- if exempt from employer period id set to no
                                    IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                       IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                          l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                          l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                       ELSE
                                          l_social_security_days := l_duration;
                                       END IF;
                                    ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                       IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                          l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                          l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                       ELSE -- user can avail the actual ss days as it is within 260 limit
                                          l_social_security_days := l_duration;
                                       END IF;
                                    END IF; -- l_gen_exempt_empr = 'N'
                                 END IF; -- Current absence is beyond the 26week rule period

                              ELSE -- 26week rule element not attached to this assignment
                                p_work_pattern := '5DAY';
                                l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                -- if exempt from employer period id set to no
                                IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                   IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE
                                      l_social_security_days := l_duration;
                                   END IF;
                                ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                   IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); / Legislative limit exhausted Message /
                                   ELSE -- user can avail the actual ss days as it is within 260 limit
                                      l_social_security_days := l_duration;
                                   END IF;
                                END IF; -- l_gen_exempt_empr = 'N'
                              END IF; -- If the 26week rule element input value's start date and end date are set then
                           ELSE
                              l_social_security_days := 0;
                           END IF; -- IF social security start date is within the absence period or prorated period then

                       END IF; --Calculate social security days if reimburse from social security is set to Yes at any level
                       -- if override social security days is present calculate actual days with the override days.
                       IF l_override_ss_days IS NOT NULL THEN
                          l_social_security_days := least(l_override_ss_days, l_social_security_days);
                       END IF;

                       -- If social security days availed from this absence exeeecs 220 days then a warning message should be thrown.
                       IF ( nvl(l_social_security_days,0) + nvl(p_3years_paybase,0) ) > 220 THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error6';
                          END IF;/
			  l_msg_error := to_char(6);

                       END IF;
               END IF; -- Prorated Absences calculation ends
            END IF; -- Outer if - identifying absence st and end both lies inside payroll period
====================================================================================================*/
               /* calculating employer days and Social Security days based on the Total Calender days.
	       First 16 cal days are consider as a employer days remaining day are social security days*/
	       IF p_sickbal_total_caldays >= p_abs_cal_days THEN
                  l_empr_days := 0;
                  l_gen_ss_st_date := p_prorate_start ;
                  IF l_gen_reimb_ss = 'N' THEN
                     l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                  END IF;
               ELSE
	            l_emp_end_date := p_prorate_start + (p_abs_cal_days - p_sickbal_total_caldays) - 1 ;
                    l_gen_ss_st_date := p_prorate_start + (p_abs_cal_days - p_sickbal_total_caldays);

                    IF l_emp_end_date >= p_prorate_end THEN
		       l_emp_end_date := p_prorate_end  ;
		    ELSE
                       IF l_gen_reimb_ss = 'N' THEN
                          l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                       END IF;
		    END IF;

                    -- Ignore public holidays if the one present in between absence start and end dates.
                    l_include_event := 'N';
                    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           p_prorate_start, l_emp_end_date, l_start_time_char,
                                           l_end_time_char, l_duration
                                           );
                    l_empr_days := l_duration;
                    /*IF l_override_empr_days IS NOT NULL THEN
                       /l_empr_days := least(l_override_empr_days, l_empr_days);  5380130/
                       l_empr_days := l_override_empr_days;
                    END IF;*/
               END IF;


                   -- CALCULATION OF SOCIAL SECURITY DAYS
                   -- Calculate social security days if reimburse from social security is set to Yes at any level
		   IF l_gen_reimb_ss = 'Y' THEN
                       -- IF social security start date is within the current payroll period then
                       IF l_gen_ss_st_date >= p_prorate_start and l_gen_ss_st_date <= p_prorate_end then
                     -- If the 26week rule element input value's start date and end date are set then
			IF l_return = 0 THEN
                   	     -- If Current absence is withing the 26week rule period then throw a warning message
                             IF l_gen_ss_st_date <= p_dbi_26week_endt AND p_prorate_end >= p_dbi_26week_stdt THEN
                                l_social_security_days := null;
                                l_msg_error := to_char(9);
                                 --Throw warning message that no social security days will be paid due to 26week rule.
                             ELSE
				p_work_pattern := '5DAY';
                                l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                                -- if exempt from employer period id set to no
                                IF l_gen_exempt_empr = 'N' THEN -- 248 days
                                   IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                                   ELSE
                                      l_social_security_days := l_duration;
                                   END IF;
                                ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                                   IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                      l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                      l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                                   ELSE -- user can avail the actual ss days as it is within 260 limit
                                      l_social_security_days := l_duration;
                                   END IF;
                                END IF; -- l_gen_exempt_empr = 'N'
                             END IF; -- Current absence is beyond the 26week rule period

                          ELSE -- 26week rule element not attached to this assignment
                            p_work_pattern := '5DAY';
                            l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                            -- if exempt from employer period id set to no
                            IF l_gen_exempt_empr = 'N' THEN -- 248 days
                               IF l_duration > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0)) THEN
                                  l_social_security_days := ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0));
                                  l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                               ELSE
                                  l_social_security_days := l_duration;
                               END IF;
                            ELSE -- Exempt from employer period is set to yes ie) eligible for 260 days
                               IF l_duration > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                                  l_social_security_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                                  l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                               ELSE -- user can avail the actual ss days as it is within 260 limit
                                  l_social_security_days := l_duration;
                               END IF;

                            END IF; -- l_gen_exempt_empr = 'N'
                          END IF; -- If the 26week rule element input value's start date and end date are set then
                       ELSE
			  l_social_security_days := 0;
                       END IF; -- IF social security start date is within the absence period or prorated period then
                   END IF; --Calculate social security days if reimburse from social security is set to Yes at any level

		   -- if override social security days is present calculate actual days with the override days.
		   /*IF l_override_ss_days IS NOT NULL THEN
                      /l_social_security_days := least(l_override_ss_days, l_social_security_days); 5380130 /
                      l_social_security_days := l_override_ss_days;
                   END IF;*/
                   IF l_social_security_days < 0 THEN
                      l_social_security_days := 0 ;
                   END IF;
		   -- If social security days availed from this absence exeeecs 220 days then a warning message should be thrown.
                   IF (( nvl(l_social_security_days,0) + nvl(p_3years_paybase,0) ) > 220 ) AND
		      (l_msg_error is NULL or l_msg_error <> '12') THEN
		      l_msg_error := to_char(6);
                   END IF;


            -- Calculated result are assigned to output variables except daily rate
            p_abs_empr_days  := nvl(l_empr_days,0) ;
            p_abs_ss_days    := nvl(l_social_security_days,0) ;
            p_abs_total_days := (p_abs_empr_days + p_abs_ss_days);
            p_rec_empr_days  := nvl(l_empr_days,0) ;
            p_rec_ss_days    := nvl(l_social_security_days,0) ;
            p_rec_total_days := (p_rec_empr_days + p_rec_ss_days);

            OPEN  csr_get_intial_sick_abs_st_dt(to_char(p_abs_attendance_id));
            FETCH csr_get_intial_sick_abs_st_dt INTO l_initial_abs_st_date;
            CLOSE csr_get_intial_sick_abs_st_dt;

            --OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date); /* 5762854 pass the current absence start date */
	    OPEN  csr_intial_abs_pay_stdt(p_assignment_id,p_abs_start_date);
            FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
            CLOSE csr_intial_abs_pay_stdt;

	    -- Get the daily rate value
            -- Calculation of G rate

	    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
	       the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

            -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);
            --l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id); /* 5762854 pass the current absence start date */
	    l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);
	    /* End Bug Fix : 5380121 */

            -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
            IF l_gen_hour_sal = 'S' THEN

               /*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                            (p_assignment_id, p_effective_date, 'Contractual Earnings',
                             'R', 'D', l_rate, l_error_message, null, null);*/

		/*pgopal - Bug 5441078 fix - Passing absence start date*/
		l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                            (p_assignment_id, p_abs_start_date, 'Contractual Earnings',
                             'R', 'D', l_rate, l_error_message, null, null);

                -- Override social security date was present.
                IF l_override_ss_rate IS NOT NULL THEN
                   l_social_security_rate := l_override_ss_rate;
                ELSE
                   l_social_security_rate := l_rate;
                END IF;
               -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
               IF l_gen_restrict_ss_sl = 'Y' THEN
                  IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                     l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                  END IF;
               END IF;
                -- if restrict daily rate to social security is not set then
                IF l_gen_restrict_dr_ss = 'N' THEN
                   -- (absence pay base * 12) / 260;
                   l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;
                   -- if override employer daily rate was present then take that for sick pay.
                   IF l_override_empr_rate IS NOT NULL THEN
                      l_empr_daily_rate := l_override_empr_rate ;
                   END IF;
                   -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                   IF l_gen_restrict_empr_sl = 'Y' THEN
                      IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                         l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                      END IF;
                   END IF;

                   -- if restrict daily rate to social security is no then pick whichever is
                   -- less between historic and daily rate.
                   IF l_social_security_rate > l_empr_daily_rate THEN
                      l_reclaim_daily_rate := l_empr_daily_rate;
                   ELSE
                      l_reclaim_daily_rate := l_social_security_rate;
                   END IF;
                -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                ELSE
                      l_empr_daily_rate := l_social_security_rate;
                      l_reclaim_daily_rate := l_social_security_rate;

                      IF l_override_empr_rate IS NOT NULL THEN
                         l_empr_daily_rate := l_override_empr_rate ;
                      END IF;
                      -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                      IF l_gen_restrict_empr_sl = 'Y' THEN
                         IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                            l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                         END IF;
                      END IF;
                END IF;

           -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
           ELSIF l_gen_hour_sal = 'H' THEN
                 p_ear_value := 0;
		 IF p_hourly_paid IN ('W', 'B') THEN
                    -- Ignore public holidays if the one present in between absence start and end dates.
                    l_include_event := 'Y';
                    -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
		    /* pgopal - Bug 5393827 and 5349713 fix - taking the absence start date instead
		    of payroll start date to get the last 4 weeks worked days*/
                 /* condition added by pdavidra for Bug 5330188*/
	         /*5475038 IF (l_abs_reason = 'Work Accident') AND
		    ( (p_abs_start_date - p_abs_min_gap) < l_dateofjoin ) THEN
                         l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           l_dateofjoin, (p_abs_start_date-1), l_start_time_char,
                                           l_end_time_char, l_duration
                                                           );
                 ELSE
                         / pdavidra - bug 5330066 - redused the start date parameter by 1/
		         l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (p_abs_start_date - p_abs_min_gap), (p_abs_start_date-1), l_start_time_char,
                                           l_end_time_char, l_duration
                                           );
                 END IF; */
                 l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                 ( p_assignment_id, l_days_or_hours, l_include_event,
                 greatest(l_dateofjoin,((l_initial_abs_pay_stdt) - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                 l_end_time_char, l_duration
                 );
                    -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
                    BEGIN
                        SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                          ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                    WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                          ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                    WHEN date_end = date_start THEN
                        	  	          1
                                    ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                          INTO l_abs_worked_days
                          FROM per_absence_attendances
                         WHERE person_id = p_person_id
			   AND date_start < (l_initial_abs_pay_stdt-1)
                           AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                           AND date_start IS NOT NULL
                           AND date_end IS NOT NULL ;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            l_abs_worked_days := 0;
                       WHEN OTHERS THEN
                            l_abs_worked_days := 0;
                    END;

                    l_duration := l_duration - nvl(l_abs_worked_days, 0);

                    /* Bug Fix 5263714 added check condition */
		    IF l_duration > 0 THEN
		    l_social_security_rate := ( p_4weeks_paybase / l_duration);
		    ELSE
		    l_social_security_rate := 0;
		    END IF;
                    -- Override social security date was present.
                    IF l_override_ss_rate IS NOT NULL THEN
                       l_social_security_rate := l_override_ss_rate;
                    END IF;
                    -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                    IF l_gen_restrict_ss_sl = 'Y' THEN
                       IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                          l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                       END IF;
                    END IF;

                       -- if override employer daily rate was present then take that for sick pay.
                       IF l_override_empr_rate IS NOT NULL THEN
                          l_empr_daily_rate := l_override_empr_rate ;
                       ELSE
                          l_empr_daily_rate := l_social_security_rate;
                       END IF;

                       -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                       IF l_gen_restrict_empr_sl = 'Y' THEN
                          IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;
                       END IF;

                       l_reclaim_daily_rate := l_social_security_rate;

                 ELSIF p_hourly_paid = 'M' THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error7';
                          END IF;*/
			  l_msg_error := to_char(7);
                       -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                       -- Previous 4 weeks period logic will not work.
                 END IF;
           END IF;

           IF l_abs_category_code = 'PTS' THEN
              p_abs_daily_rate := l_empr_daily_rate * (nvl(l_abs_pts_percent,0)/100);
              p_ss_daily_rate  := l_social_security_rate * (nvl(l_abs_pts_percent,0)/100);
           ELSE
              p_abs_daily_rate := nvl(l_empr_daily_rate,0);
              p_ss_daily_rate  := nvl(l_social_security_rate,0);

           END IF;
           -- If reclaimable daily rate is set on override element then use the value to reclaim
           -- from social security else use social security rate calculated.
           IF l_override_reclaim_rate IS NOT NULL THEN
              p_rec_daily_rate := l_override_reclaim_rate;
           ELSE
              p_rec_daily_rate := p_ss_daily_rate;
           END IF;

            -- Calculate Employer and social security periods
            -- If exempt from employer is set and reimburse from social security is not set
            -- then 12 working days are allowed to be paid and reimbursed
            IF l_gen_exempt_empr = 'Y' AND l_gen_reimb_ss = 'N' THEN
                  /*pdavidra 5330536 - if Exempt empr is Y, all absence days should be consider as a SS days
		                       and reimp_ss is N, max 12 working days are allowed to paid and reimbursed
                  p_abs_empr_days := nvl(l_empr_days,0);
                  p_abs_ss_days   := 0;*/
		  p_abs_empr_days := 0;
                  p_abs_ss_days   := nvl(l_empr_days,0);
                  p_abs_total_days := (p_abs_empr_days + p_abs_ss_days) ;

                  p_rec_empr_days  := p_abs_empr_days ;
                  p_rec_ss_days    := p_abs_ss_days ;
                  p_rec_total_days := (p_rec_empr_days + p_rec_ss_days);
            END IF;
            IF l_gen_exempt_empr = 'Y' AND l_gen_reimb_ss = 'Y' THEN
                  /*pdavidra 5330536 - if Exempt empr is Y, all absence days should be consider as a SS days
		                       and reimp_ss is Y, max 12 + 248 working days are allowed to paid and reimbursed*/
		  p_abs_empr_days := 0;
                  p_abs_ss_days   := nvl(l_empr_days,0) + nvl(p_abs_ss_days,0);
                  IF p_abs_ss_days > (p_abs_annual_days - nvl(p_3years_paybase,0)) THEN
                       p_abs_ss_days := (p_abs_annual_days - nvl(p_3years_paybase,0));
                       l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                  END IF;
                  p_abs_total_days := (p_abs_empr_days + p_abs_ss_days) ;
            END IF;
            -- If exempt from employer is not set and reimburse from social security is not set
            -- then 16 calendar days are allowed to be paid including continuous linking sick period.
            IF l_gen_exempt_empr = 'N' AND l_gen_reimb_ss = 'N' THEN
                  p_abs_empr_days := nvl(l_empr_days,0);
                  p_abs_ss_days   := 0;
                  p_abs_total_days := (p_abs_empr_days + p_abs_ss_days) ;

                  p_rec_empr_days  := 0 ;
                  p_rec_ss_days    := 0 ;
                  p_rec_total_days := (p_rec_empr_days + p_rec_ss_days);
--                  p_rec_daily_rate := 0;
--                  p_ss_daily_rate  := 0;
            END IF;

                    IF l_override_empr_days IS NOT NULL THEN
                       p_abs_empr_days := l_override_empr_days;
                       p_abs_total_days := (nvl(p_abs_empr_days,0) + nvl(p_abs_ss_days,0)) ;
                    END IF;
		   -- if override social security days is present calculate actual days with the override days.
		   IF l_override_ss_days IS NOT NULL THEN
                      p_abs_ss_days := l_override_ss_days;
                      p_abs_total_days := (nvl(p_abs_empr_days,0) + nvl(p_abs_ss_days,0)) ;
                      IF ( (nvl(p_abs_ss_days,0)  + nvl(p_3years_paybase,0)) > 220 ) AND  (l_msg_error is NULL or l_msg_error <> '12') THEN
                         l_msg_error := to_char(6);
                      END IF;
                   END IF;
                   IF (l_gen_exempt_empr = 'N' AND l_gen_reimb_ss = 'N' AND nvl(p_abs_ss_days,0) > 0 ) OR
  		      (l_gen_exempt_empr = 'Y' AND l_gen_reimb_ss = 'N' AND nvl(p_abs_empr_days,0) > 0 ) OR
		      (l_gen_exempt_empr = 'Y' AND l_gen_reimb_ss = 'Y' AND (nvl(p_abs_ss_days,0) > (p_abs_annual_days - nvl(p_3years_paybase,0))) ) OR
		      (l_gen_exempt_empr = 'N' AND l_gen_reimb_ss = 'Y' AND (nvl(p_abs_ss_days,0) > ((p_abs_annual_days - p_abs_work_days) - nvl(p_3years_paybase,0))) ) THEN
                        l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                   END IF;

            IF l_gen_rate_option = 'DRATE_OPT1' THEN
               p_rate_option1 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
               p_rate_option2 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
               p_rate_option3 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
               p_rate_option4 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
               p_rate_option5 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
               p_rate_option6 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
               p_rate_option7 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
               p_rate_option8 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
               p_rate_option9 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
               p_rate_option10 := 'Y';
            ELSE
               p_rate_option1  := null;
               p_rate_option2  := null;
               p_rate_option3  := null;
               p_rate_option4  := null;
               p_rate_option5  := null;
               p_rate_option6  := null;
               p_rate_option7  := null;
               p_rate_option8  := null;
               p_rate_option9  := null;
               p_rate_option10 := null;
               -- If calculated employer daily rate is less than 50% of G daily rate then no social security period will be paid.
           IF l_abs_category_code = 'PTS' THEN
               IF p_abs_daily_rate < ( ((l_g_rate / p_abs_annual_days) / 2) * (nvl(l_abs_pts_percent,0)/100) ) THEN
                  --Employers period alone can be paid. No social security period will be paid.
    	          p_rec_empr_days  := 0;
    	          p_rec_ss_days    := 0;
    	          p_rec_total_days := 0;
    	          p_rec_daily_rate := 0;
                  p_ss_daily_rate  := 0;
                  IF p_abs_ss_days > 0 then
                    l_msg_error := to_char(11); /* 50% G Message */
                  END IF;
                  p_abs_ss_days    := 0;
                  p_abs_total_days := (nvl(p_abs_empr_days,0) + nvl(p_abs_ss_days,0)) ;
               END IF;
            ELSE
               IF p_abs_daily_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  --Employers period alone can be paid. No social security period will be paid.
    	          p_rec_empr_days  := 0;
    	          p_rec_ss_days    := 0;
    	          p_rec_total_days := 0;
    	          p_rec_daily_rate := 0;
                  p_ss_daily_rate  := 0;
                  IF p_abs_ss_days > 0 then
                    l_msg_error := to_char(11); /* 50% G Message */
                  END IF;
                  p_abs_ss_days    := 0;
                  p_abs_total_days := (nvl(p_abs_empr_days,0) + nvl(p_abs_ss_days,0)) ;
               END IF;
	    END IF;
            END IF;

            p_abs_error := l_msg_error ;

/*****************************************************************************
CHILD MINDER'S SICKNESS ABSENCE CATEGORY
*****************************************************************************/

        ELSIF l_abs_category_code = 'CMS' THEN

		   -- Fetch EIT values from absence payment details form
        	       BEGIN
            		    SELECT PAA.ABS_INFORMATION1   AS Cert_type
            		           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  AS Cert_stdt
            		           ,to_date(PAA.ABS_INFORMATION3,'yyyy/mm/dd hh24:mi:ss')  AS Cert_endt
            		           ,PAA.ABS_INFORMATION4  AS reimb_ss
            		           ,PAA.ABS_INFORMATION5  AS dailyrate_ss
            		           ,PAA.ABS_INFORMATION6  AS employer_6g
            		           ,PAA.ABS_INFORMATION7  AS socialsec_6g
            		           ,PAA.ABS_INFORMATION8  AS Daily_rate
            		      INTO l_cert_type
                               ,l_cert_stdt
                               ,l_cert_endt
                               ,l_abs_reimb_ss
                               ,l_abs_restrict_dr_ss
                               ,l_abs_restrict_empr_sl
                               ,l_abs_restrict_ss_sl
                               ,l_abs_daily_rate
            		      FROM PER_ABSENCE_ATTENDANCES PAA
          		         WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;
                   EXCEPTION
        		        WHEN OTHERS THEN
                             l_cert_type            := null;
                             l_cert_stdt            := null;
                             l_cert_endt            := null;
                             l_abs_reimb_ss         := null;
                             l_abs_restrict_dr_ss   := null;
                             l_abs_restrict_empr_sl := null;
                             l_abs_restrict_ss_sl   := null;
                             l_abs_daily_rate       := null;
         	       END;
               /* Identifying the input values based on the Priority levels. If none of the level has been
                  set then default value will be assigned. Refer mail dated 20th Feb 06 from Borge.*/
               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_entitled_sc       := nvl(nvl(l_entitled_sc, l_le_entitled_sc), 'Y');
               l_gen_exempt_empr       := nvl(nvl(l_exempt_empr, l_le_exempt_empr), 'N');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               l_gen_restrict_empr_sl  := nvl(nvl(nvl(l_abs_restrict_empr_sl, l_restrict_empr_sl), l_le_restrict_empr_sl), 'Y');
               l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_abs_restrict_ss_sl, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');
               l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);
               /* This Message has been handled at Absence Recording Level itself
	       -- Entitled to self certificate is set to no with self certificate has chosen then a warning message should be generated
               IF l_gen_entitled_sc = 'N' AND l_cert_type = 'SC' THEN
                  / knelli
		  IF length(l_msg_error) > 1 THEN
                     l_msg_error := 'Error7';
                  END IF;/
		  l_msg_error := to_char(7);
               END IF;*/

            -- Condition 1. First sick is allowed after 28 days of Join.
            /*5475038 - This message has been moved to recording level
            l_dateofjoin_28 := l_dateofjoin + p_abs_min_gap ;
                BEGIN
                /pdavidra - bug no 5330109 - Unauthorised absence count should be taken
                                              form DOJ to current absence date
                                              instead of  DOJ to DOJ+28 days.
                    SELECT SUM ( CASE WHEN PAA.DATE_END > l_dateofjoin_28 THEN
                                           ( l_dateofjoin_28 - PAA.DATE_START)
                    				  WHEN PAA.DATE_START = PAA.DATE_END THEN
                    				       1
                    				  ELSE (PAA.DATE_END - PAA.DATE_START) END ) AS DAYS
                      INTO l_abs_unauthor
                      FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
                     WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
                       AND PAT.ABSENCE_CATEGORY = 'UN'
                       AND PAA.DATE_START <= l_dateofjoin_28
                       AND PAA.DATE_END   >= l_dateofjoin
                       AND PAA.DATE_START IS NOT NULL
                       AND PAA.DATE_END IS NOT NULL
                       AND PAA.PERSON_ID = p_person_id;/
                   SELECT SUM ( CASE WHEN PAA.DATE_END > (p_abs_start_date-1) THEN
                                           ( (p_abs_start_date-1) - PAA.DATE_START) + 1
                    		      WHEN PAA.DATE_START = PAA.DATE_END THEN
                    				       1
                    		      ELSE (PAA.DATE_END - PAA.DATE_START) + 1 END ) AS DAYS
                      INTO l_abs_unauthor
                      FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
                     WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
                       AND PAT.ABSENCE_CATEGORY = 'UN'
                       AND PAA.DATE_START <= (p_abs_start_date-1)
                       AND PAA.DATE_END   >= l_dateofjoin
                       AND PAA.DATE_START IS NOT NULL
                       AND PAA.DATE_END IS NOT NULL
                       AND PAA.PERSON_ID = p_person_id;
                EXCEPTION
                   WHEN OTHERS THEN
                        l_abs_unauthor := 0;
                END;

                IF ( p_abs_start_date - l_dateofjoin ) < (p_abs_min_gap + nvl(l_abs_unauthor,0) ) THEN
                  / knelli
		  IF length(l_msg_error) > 1 THEN
                     l_msg_error := 'Error3';
                  END IF;/
		  l_msg_error := to_char(3);
                END IF;

            -- Condition 2. Minimum 28 days employment is required to avail Child Minder Sick pay except sickness or holiday
	        -- within 28 days from start of the current absence. If any other absence exists with more than
	        -- 14 days within 28 days then no Child Minder Sickness will be paid.
                    BEGIN
                        SELECT COUNT(1)
                          INTO l_abs_count
                          FROM PER_ABSENCE_ATTENDANCES PAA, PER_ABSENCE_ATTENDANCE_TYPES PAT
                         WHERE PAA.ABSENCE_ATTENDANCE_TYPE_ID = PAT.ABSENCE_ATTENDANCE_TYPE_ID
                           AND PAT.ABSENCE_CATEGORY IN ( 'S','PTS','PA','PTP','M','PTM','IE_AL','PTA' )
                           AND PAA.DATE_END BETWEEN (p_abs_start_date - (p_abs_min_gap+1)) AND p_abs_start_date
			               AND ( PAA.DATE_END - PAA.DATE_START ) > p_abs_link_period
                           AND PAA.DATE_START IS NOT NULL
                           AND PAA.DATE_END IS NOT NULL
                           AND PAA.PERSON_ID = p_person_id;
                    EXCEPTION
                       WHEN OTHERS THEN
                            l_abs_count := 0;
                    END;

                -- There are Child Minder sickness exists within 28days of current Child Minder sickness start date with more than 14 days
		        -- except absence categories Sickness, Part-time sickness and Vacation.
		        IF l_abs_count > 0 THEN
                  / knelli
		  IF length(l_msg_error) > 1 THEN
                     l_msg_error := 'Error4';
                  END IF;/
		  l_msg_error := to_char(4);
                END IF; */

           -- Calling override to get override days and daily rate
           l_over_return := get_override_details
                            ( p_assignment_id,p_effective_date,p_abs_start_date,
                              p_abs_end_date, p_abs_categorycode, l_override_start_date,
                              l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                              l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                             );

            /* Multiple override element attached against one absence element. ie)  *
             * One or more override entry exists with same start and end date       */
            IF (l_over_return = -1) THEN
              /* knelli
	      IF length(l_msg_error) > 1 THEN
                 l_msg_error := 'Error5';
              END IF;*/
	      l_msg_error := to_char(5);
              p_abs_error := l_msg_error;
              RETURN 1;
            END IF;
            IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
               l_msg_error := to_char(13);
            END IF;
            l_include_event := 'N';
            -- Calculating actual sickness days through work schedule
            l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                   p_prorate_start, p_prorate_end, l_start_time_char,
                                   l_end_time_char, l_duration
                                  );

               l_actual_cal_days := nvl(l_duration,0);
            -- Calculate Earnings Adjustment value
               --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
               p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * l_actual_cal_days;
               p_ear_startdt    := p_prorate_start;
               p_ear_enddt      := p_prorate_end;
               p_ear_value      := nvl(p_ear_value,0);

               -- To get slab values for child minder sickness.
               -- One child with less than 13 years of age.
               l_child_1_13 := PAY_NO_ABSENCE.GET_USERTABLE (p_effective_date, p_business_group_id,
                               'NO_CHILDMINDER_SICK_DURATION','Duration','A');


               -- Two children with less than 13 years of age.
               l_child_2_13 := PAY_NO_ABSENCE.GET_USERTABLE (p_effective_date, p_business_group_id,
                               'NO_CHILDMINDER_SICK_DURATION','Duration','B');


               -- More than One child with less than 19 years of age.
               l_child_1_19 := PAY_NO_ABSENCE.GET_USERTABLE (p_effective_date, p_business_group_id,
                               'NO_CHILDMINDER_SICK_DURATION','Duration','C');


               -- One Sole Guardian child with less than 13 years of age.
               l_childsg_1_13 := PAY_NO_ABSENCE.GET_USERTABLE (p_effective_date, p_business_group_id,
                               'NO_CHILDMINDER_SICK_DURATION','Duration','A_SG');


               -- Two Sole Guardian children with less than 13 years of age.
               l_childsg_2_13 := PAY_NO_ABSENCE.GET_USERTABLE (p_effective_date, p_business_group_id,
                               'NO_CHILDMINDER_SICK_DURATION','Duration','B_SG');


               -- More than One Sole Guardian child with less than 19 years of age.
               l_childsg_1_19 := PAY_NO_ABSENCE.GET_USERTABLE (p_effective_date, p_business_group_id,
                               'NO_CHILDMINDER_SICK_DURATION','Duration','C_SG');


           -- Calculate total absence days
           l_gen_totalabs_days := (p_abs_end_date - p_abs_start_date ) + 1;
           -- Calculate total prorated day(s) of the current payroll
           l_gen_pro_days      := (p_prorate_end - p_prorate_start ) + 1;
           -- Calculate Employer's period start date
           l_gen_empr_st_date  := p_prorate_start;

           -- To fetch previous employment's child minder sickness value
           OPEN child_prev_emp (p_person_id, p_abs_start_date);
           FETCH child_prev_emp INTO l_child_prev_stdt, l_child_prev_endt, l_child_prev_value;
           CLOSE child_prev_emp;
           l_child_cnt_ab := 0;
           l_child_cnt_c  := 0;
           l_child_cnt_sgab := 0;
           l_child_cnt_sgc  := 0;
           -- To fetch dependent child information
           FOR I IN child_contact ( p_person_id, 'DC', p_abs_start_date )
           LOOP


               /* knelli commented code
	       IF I.AGE < 13 AND i.CONT_INFORMATION1 = 'N' AND i.CONT_INFORMATION2 = 'N' THEN
                  l_child_cnt_ab := l_child_cnt_ab + 1;
               -- 1+ child exists with < 19 years with chronic as Yes and Sole guardian as No
               ELSIF I.AGE < 19 AND i.CONT_INFORMATION1 = 'Y' AND i.CONT_INFORMATION2 = 'N' THEN
                  l_child_cnt_c := l_child_cnt_c + 1;
               -- 1 or 2 child exists with < 13 years with chronic as No and Sole guardian as Yes
               ELSIF I.AGE < 13 AND i.CONT_INFORMATION1 = 'N' AND i.CONT_INFORMATION2 = 'Y' THEN
                  l_child_cnt_sgab := l_child_cnt_sgab + 1;
               -- 1+ child exists with < 19 years with chronic as Yes and Sole guardian as Yes
               ELSIF I.AGE < 19 AND i.CONT_INFORMATION1 = 'Y' AND i.CONT_INFORMATION2 = 'Y' THEN
                  l_child_cnt_sgc := l_child_cnt_sgc + 1;
	       END IF:
		commnted code ends here */

               /*knelli changed code */

	       i.CONT_INFORMATION1 := nvl(i.CONT_INFORMATION1,'N');
	       i.CONT_INFORMATION2 := nvl(i.CONT_INFORMATION2,'N');

	       IF I.AGE < 13 AND i.CONT_INFORMATION1 = 'N' AND i.CONT_INFORMATION2 = 'N' THEN
                  l_child_cnt_ab := l_child_cnt_ab + 1;
               -- 1+ child exists with < 19 years with chronic as Yes and Sole guardian as No
               ELSIF I.AGE < 19 AND i.CONT_INFORMATION1 = 'N' AND i.CONT_INFORMATION2 = 'Y' THEN
                  l_child_cnt_c := l_child_cnt_c + 1;
               -- 1 or 2 child exists with < 13 years with chronic as No and Sole guardian as Yes
               ELSIF I.AGE < 13 AND i.CONT_INFORMATION1 = 'Y' AND i.CONT_INFORMATION2 = 'N' THEN
                  l_child_cnt_sgab := l_child_cnt_sgab + 1;
               -- 1+ child exists with < 19 years with chronic as Yes and Sole guardian as Yes
               ELSIF I.AGE < 19 AND i.CONT_INFORMATION1 = 'Y' AND i.CONT_INFORMATION2 = 'Y' THEN
                  l_child_cnt_sgc := l_child_cnt_sgc + 1;
	       END IF;
           END LOOP;
/* pdavidra 5360031 - The highest eligibility limit of multiple options/combinations should be considered
	   -- To identify the maximum limit
           IF l_child_cnt_ab = 1 THEN
              l_gen_child_limit := l_child_1_13;
           ELSIF l_child_cnt_ab >= 2 THEN  / knelli changed from = 2 /
              l_gen_child_limit := l_child_2_13;
           ELSIF l_child_cnt_c >= 1 THEN  / knelli changed from > to >= /
              l_gen_child_limit := l_child_1_19;
           ELSIF l_child_cnt_sgab = 1 THEN
              l_gen_child_limit := l_childsg_1_13;
           ELSIF l_child_cnt_sgab >= 2 THEN  / knelli changed from = 2 /
              l_gen_child_limit := l_childsg_2_13;
           ELSIF l_child_cnt_sgc >= 1 THEN / knelli changed from > 1 /
              l_gen_child_limit := l_childsg_1_19;
           ELSE
              l_gen_child_limit := 0;
	      /l_gen_child_limit := l_child_1_13;  knelli changed to l_child_1_13 from 0 , but check/
           END IF;  */
	   -- To identify the maximum limit

	   l_gen_child_limit := 0;
           IF l_child_cnt_ab = 1 THEN
              l_gen_child_limit := l_child_1_13;
           END IF;
           IF l_child_cnt_ab >= 2 THEN
              l_gen_child_limit := l_child_2_13;
           END IF;
           IF l_child_cnt_c >= 1 THEN
              l_gen_child_limit := l_child_1_19;
           END IF;
           IF l_child_cnt_sgab = 1 THEN
              l_gen_child_limit := l_childsg_1_13;
           END IF;
           IF l_child_cnt_sgab >= 2 THEN
              l_gen_child_limit := l_childsg_2_13;
           END IF;
           IF l_child_cnt_sgc >= 1 THEN
              l_gen_child_limit := l_childsg_1_19;
           END IF;

           -- If no record exists with dependent child status then throw an error.
           IF l_gen_child_limit = 0 THEN
             /* knelli commented code */
	     /*IF length(l_msg_error) > 1 THEN
                 l_msg_error := 'Error10';
             END IF;*/
	     /* knelli added code */
	     l_msg_error := to_char(10);
	     p_abs_error := l_msg_error;
	     RETURN 1;

           END IF;

--=========================================================================================================================
--5392465 and 5360031 Taking the Employer / Social Security days from Balance (ASG_YTD)
--instead of calculating full employee period
            -- Implementation of top logic to calculate actual days using proration and finding
            -- the continuous linking period.
/*            IF p_abs_start_date between p_pay_start_date AND p_pay_end_date
               AND p_abs_end_date between p_pay_start_date AND p_pay_end_date THEN

               -- Condition 3 - Calculate continuous linking period of sickness
               -- If there are multiple sickness exists within 14 days before start date then
               -- include those sickness in calculating employer days.
                l_loop_empr_work_days := 0;
                l_loop_start_date := p_abs_start_date ;
                FOR i in child_link (p_person_id) LOOP
                    IF ( i.date_start = i.date_end ) THEN
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);

                    -- start date and end date are different then calculate working days between them
                    ELSE
                       -- Calling override to get override days and daily rate

		       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;

                        -- If override element not exists for the continuous absences then calculate actual work days.
                        IF l_cont_empr_days IS NULL THEN
                           l_duration := 0;
                           l_include_event := 'N';

                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));
                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;

                    END IF;
                    l_loop_start_date := i.date_start;
                END LOOP;

                -- Calculation of actual working days present with the current absence.
                -- Ignore public holidays if the one present in between absence start and end dates.
                l_include_event := 'N';
                l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                     ( p_assignment_id, l_days_or_hours, l_include_event,
                                       p_prorate_start, p_prorate_end, l_start_time_char,
                                       l_end_time_char, l_duration
                                      );
                l_actual_days := nvl(l_duration,0);

                -- Recalculate employer days with previous employment child minder days.
                l_loop_empr_work_days :=  nvl(l_loop_empr_work_days,0) + nvl(l_child_prev_value,0);

                  -- Child minder sickness already taken is greater than 10 working days so no more empr days will be paid.
                  IF l_loop_empr_work_days >= l_child_1_13 THEN
                     l_empr_days := 0;
                     -- If total days taken is < the entitlement limit then remaining days will be taken
                     IF l_loop_empr_work_days < l_gen_child_limit THEN
                        -- If current absence days is > limit then restrict it to limit
                        IF  l_actual_days > ( l_gen_child_limit - l_loop_empr_work_days ) THEN
                            l_social_security_days := ( l_gen_child_limit - l_loop_empr_work_days );
                        ELSE
                            l_social_security_days := l_actual_days;
                        END IF;
                     ELSE -- If all the absences are exhausted earlier then no social security will be entertained.
                            l_social_security_days := 0;
                     END IF;
                     -- Override element exists then override the calculated value
                     IF l_override_ss_days IS NOT NULL THEN
                        l_social_security_days := least(l_override_ss_days, l_social_security_days);
                     END IF;
                  ELSE -- Continuous sickness days is less than 12 working days
                        -- if actual working days  > remaning available then social security days will be paid
                        IF l_actual_days > ( l_child_1_13 - l_loop_empr_work_days ) THEN
                           l_empr_days := ( l_child_1_13 - l_loop_empr_work_days );
                           l_social_security_days := (l_actual_days - l_empr_days);
                           /pdavidra - 5260950  /
                           IF  l_social_security_days > (l_gen_child_limit - l_loop_empr_work_days - l_empr_days) THEN
                               l_social_security_days := (l_gen_child_limit - l_loop_empr_work_days - l_empr_days);
                           END IF;
                           -- if override employer days is present calculate actual days through linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;

                           IF l_override_ss_days IS NOT NULL THEN
                              l_social_security_days := least(l_override_ss_days, l_social_security_days);
                           END IF;
                        ELSE
                           l_empr_days := l_actual_days;
                           l_social_security_days := 0;
                           -- if override employer days is present calculate actual days through continuous linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;
                        END IF;
                  END IF;
                   -- If reimburse from social security is not set
                  / knelli removed check
		   IF l_gen_reimb_ss = 'N' THEN
                         l_social_security_days := 0;
                   END IF;/


------------------------------------------------------------------------------
------------------------------------------------------------------------------
            Else -- Absences lies more than one payroll period

	       -- Absence start date lies in between the payroll period st dt and end dt.

 	       IF p_abs_start_date between p_pay_start_date and p_pay_end_date THEN

		 -- Condition 3 - Calculate continuous linking period of sickness
                 -- If there are multiple sickness exists within 14 days before start date then
                 -- include those sickness in calculating employer days.
                  l_loop_empr_work_days := 0;
                  l_loop_start_date := p_abs_start_date ;
                  FOR i in child_link (p_person_id) LOOP

		    IF ( i.date_start = i.date_end ) THEN
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);

                    ELSE

		       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element not exists for the continuous absences then calculate actual work days.
                        IF l_cont_empr_days IS NULL THEN

                           l_duration := 0;
                           l_include_event := 'N';

			   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));

                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;

                    END IF;
                      l_loop_start_date := i.date_start;
                  END LOOP;

                  -- Calculation of employer days if proration was enabled
                  l_counter := 1;
                  FOR I IN CSR_CUR_ABS_PRORATED(p_assignment_id, p_effective_date, p_abs_start_date, p_abs_end_date) LOOP
                    -- It means absences crosses between one payroll period

		    IF l_counter = 1 THEN
                       -- Newly introduced to knock off calendar and work days variables of employers period already taken.
                       -- As it is a start of the proration period.
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + 0;

                    ELSE
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (l_prev_paydate+1), i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    END IF;
                       l_counter := l_counter + 1;
                       l_prev_paydate := i.date_earned;
                   END LOOP;

                -- Calculation of actual working days present with the current absence.
                -- Ignore public holidays if the one present in between absence start and end dates.
                l_include_event := 'N';

                l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                     ( p_assignment_id, l_days_or_hours, l_include_event,
                                       p_prorate_start, p_prorate_end, l_start_time_char,
                                       l_end_time_char, l_duration
                                      );
                l_actual_days := nvl(l_duration,0);

                -- Recalculate employer days with previous employment child minder days.
                l_loop_empr_work_days :=  nvl(l_loop_empr_work_days,0) + nvl(l_child_prev_value,0);


                  -- Child minder sickness already taken is greater than 10 working days so no more empr days will be paid.
                  IF l_loop_empr_work_days >= l_child_1_13 THEN
                     l_empr_days := 0;
                     -- If total days taken is < the entitlement limit then remaining days will be taken
                     IF l_loop_empr_work_days < l_gen_child_limit THEN
                        -- If current absence days is > limit then restrict it to limit
                        IF  l_actual_days > ( l_gen_child_limit - l_loop_empr_work_days ) THEN
                            l_social_security_days := ( l_gen_child_limit - l_loop_empr_work_days );
                        ELSE
                            l_social_security_days := l_actual_days;
                        END IF;
                     ELSE -- If all the absences are exhausted earlier then no social security will be entertained.
                            l_social_security_days := 0;
                     END IF;
                     -- Override element exists then override the calculated value
                     IF l_override_ss_days IS NOT NULL THEN
                        l_social_security_days := least(l_override_ss_days, l_social_security_days);
                     END IF;
                  ELSE -- Continuous sickness days is less than 12 working days
                        -- if actual working days  > remaning available then social security days will be paid
                        IF l_actual_days > ( l_child_1_13 - l_loop_empr_work_days ) THEN
                           l_empr_days := ( l_child_1_13 - l_loop_empr_work_days );
                           l_social_security_days := (l_actual_days - l_empr_days);
                           /pdavidra - 5260950  /
                           IF  l_social_security_days > (l_gen_child_limit - l_loop_empr_work_days - l_empr_days) THEN
                               l_social_security_days := (l_gen_child_limit - l_loop_empr_work_days - l_empr_days);
                           END IF;
                           -- if override employer days is present calculate actual days through linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;

                           IF l_override_ss_days IS NOT NULL THEN
                              l_social_security_days := least(l_override_ss_days, l_social_security_days);
                           END IF;
                        ELSE
                           l_empr_days := l_actual_days;
                           l_social_security_days := 0;
                           -- if override employer days is present calculate actual days through continuous linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;
                        END IF;
                  END IF;

		  -- If reimburse from social security is not set
                   / knelli following check not valied
		   IF l_gen_reimb_ss = 'N' THEN
                         l_social_security_days := 0;
                   END IF;/

-------------------------------------------------------------------------
-------------------------------------------------------------------------
               -- Refer the previous payroll period's element input value for Empr and SS days calc.
               -- Absence end date lies in between the payroll period st dt and end dt.
               ELSIF p_abs_end_date between p_pay_start_date and p_pay_end_date THEN

		 -- Condition 3 - Calculate continuous linking period of sickness
                 -- If there are multiple sickness exists within 14 days before start date then
                 -- include those sickness in calculating employer days.
                  l_loop_empr_work_days := 0;
                  l_loop_start_date := p_abs_start_date ;
                  FOR i in child_link (p_person_id) LOOP

		    IF ( i.date_start = i.date_end ) THEN
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);

                    ELSE

		       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element not exists for the continuous absences then calculate actual work days.
                        IF l_cont_empr_days IS NULL THEN

			   l_duration := 0;
                           l_include_event := 'N';

                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );
                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));
                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;

                    END IF;
                      l_loop_start_date := i.date_start;
                  END LOOP;

                  -- Calculation of employer days if proration was enabled
                  l_counter := 1;
                  FOR I IN CSR_CUR_ABS_PRORATED(p_assignment_id, p_effective_date, p_abs_start_date, p_abs_end_date) LOOP
                    -- It means absences crosses between one payroll period

		    IF l_counter = 1 THEN
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           p_abs_start_date, i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    ELSE
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';

			/ knelli bug  5261106 added check/
			IF p_abs_end_date NOT BETWEEN l_prev_paydate+1 AND i.date_earned THEN
                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (l_prev_paydate+1), i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
			END IF;
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);
                    END IF;
                       l_counter := l_counter + 1;
                       l_prev_paydate := i.date_earned;
                   END LOOP;

                -- Calculation of actual working days present with the current absence.
                -- Ignore public holidays if the one present in between absence start and end dates.
                l_include_event := 'N';
                l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                     ( p_assignment_id, l_days_or_hours, l_include_event,
                                       p_prorate_start, p_prorate_end, l_start_time_char,
                                       l_end_time_char, l_duration
                                      );
                l_actual_days := nvl(l_duration,0);

                -- Recalculate employer days with previous employment child minder days.
                l_loop_empr_work_days :=  nvl(l_loop_empr_work_days,0) + nvl(l_child_prev_value,0);

                  /knelli added logic -- not required for this case/
	          /IF l_loop_empr_work_days > 0 THEN
			l_loop_empr_work_days := l_loop_empr_work_days - l_actual_days;
		  END IF;/

		  -- Child minder sickness already taken is greater than 10 working days so no more empr days will be paid.
                  IF l_loop_empr_work_days >= l_child_1_13 THEN
                     l_empr_days := 0;
                     -- If total days taken is < the entitlement limit then remaining days will be taken
                     IF l_loop_empr_work_days < l_gen_child_limit THEN
                        -- If current absence days is > limit then restrict it to limit
                        IF  l_actual_days > ( l_gen_child_limit - l_loop_empr_work_days ) THEN
                            l_social_security_days := ( l_gen_child_limit - l_loop_empr_work_days );
                        ELSE
                            l_social_security_days := l_actual_days;
                        END IF;
                     ELSE -- If all the absences are exhausted earlier then no social security will be entertained.
                            l_social_security_days := 0;
                     END IF;
                     -- Override element exists then override the calculated value
                     IF l_override_ss_days IS NOT NULL THEN
                        l_social_security_days := least(l_override_ss_days, l_social_security_days);
                     END IF;
                  ELSE -- Continuous sickness days is less than 12 working days
                        -- if actual working days  > remaning available then social security days will be paid
                        IF l_actual_days > ( l_child_1_13 - l_loop_empr_work_days ) THEN
                           l_empr_days := ( l_child_1_13 - l_loop_empr_work_days );
                           l_social_security_days := (l_actual_days - l_empr_days);
                           /pdavidra - 5260950  /
                           IF  l_social_security_days > (l_gen_child_limit - l_loop_empr_work_days - l_empr_days) THEN
                               l_social_security_days := (l_gen_child_limit - l_loop_empr_work_days - l_empr_days);
                           END IF;
                           -- if override employer days is present calculate actual days through linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;

                           IF l_override_ss_days IS NOT NULL THEN
                              l_social_security_days := least(l_override_ss_days, l_social_security_days);
                           END IF;
                        ELSE
                           l_empr_days := l_actual_days;
                           l_social_security_days := 0;
                           -- if override employer days is present calculate actual days through continuous linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;
                        END IF;
                  END IF;
                   -- If reimburse from social security is not set
                   / knelli removed the check
		   IF l_gen_reimb_ss = 'N' THEN
                         l_social_security_days := 0;
                   END IF;/

----------------------------------------------------------------------
----------------------------------------------------------------------
               ELSE -- Absence start and end date, both not lying in between the payroll period st dt and end dt.
                 -- Condition 3 - Calculate continuous linking period of sickness
                 -- If there are multiple sickness exists within 14 days before start date then
                 -- include those sickness in calculating employer days.

		  l_loop_empr_work_days := 0;
                  l_loop_start_date := p_abs_start_date ;
                  FOR i in child_link (p_person_id) LOOP

		    IF ( i.date_start = i.date_end ) THEN
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           i.date_start, i.date_end, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                        l_loop_empr_work_days := l_loop_empr_work_days + nvl(l_duration,0);

                    ELSE

		       -- Calling override to get override days and daily rate
                       l_over_return := get_override_details
                                        ( p_assignment_id,p_effective_date,i.date_start,
                                          i.date_end, p_abs_categorycode, l_cont_start_date,
                                          l_cont_end_date,l_cont_empr_rate, l_cont_ss_rate,
                                          l_cont_reclaim_rate, l_cont_empr_days, l_cont_ss_days
                                         );
                        / Multiple override element attached against one absence element. ie)  *
                         * One or more override entry exists with same start and end date       /
                        IF (l_over_return = -1) THEN
                          / knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;/
			  l_msg_error := to_char(5);
                        END IF;
                        -- If override element not exists for the continuous absences then calculate actual work days.
                        IF l_cont_empr_days IS NULL THEN

			   l_duration := 0;
                           l_include_event := 'N';

                           l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                            ( p_assignment_id, l_days_or_hours, l_include_event,
                                              i.date_start, i.date_end, l_start_time_char,
                                              l_end_time_char, l_duration
                                             );

                           l_loop_empr_work_days := (l_loop_empr_work_days + nvl(l_duration,0));

                        ELSE
                           l_loop_empr_work_days := l_loop_empr_work_days + l_cont_empr_days;
                        END IF;

                    END IF;
                      l_loop_start_date := i.date_start;
                  END LOOP;
		  -- Calculation of employer days if proration was enabled
                  l_counter := 1;
                  FOR I IN CSR_CUR_ABS_PRORATED(p_assignment_id, p_effective_date, p_abs_start_date, p_abs_end_date) LOOP
                    -- It means absences crosses between one payroll period

		    IF l_counter = 1 THEN
                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           p_abs_start_date, i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);

                    ELSE

                       -- Calculating actual days with prorated period
                        l_duration := 0;
                        l_include_event := 'N';

                        l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           (l_prev_paydate+1), i.date_earned, l_start_time_char,
                                           l_end_time_char, l_duration
                                          );
                       l_loop_empr_work_days := nvl(l_loop_empr_work_days,0) + nvl(l_duration,0);

                    END IF;
                       l_counter := l_counter + 1;
                       l_prev_paydate := i.date_earned;
                   END LOOP;

                  / knelli call work schedule /
		  l_include_event := 'N';
                  l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                     ( p_assignment_id, l_days_or_hours, l_include_event,
                                       p_prorate_start, p_prorate_end, l_start_time_char,
                                       l_end_time_char, l_duration
                                      );
                  l_actual_days := nvl(l_duration,0);
		  / knelli call work schedule /
		  -- Child minder sickness already taken is greater than 10 working
                  -- days so no more empr days will be paid.

		  / knelli replaced logic /

		  -- Child minder sickness already taken is greater than 10 working days so no more empr days will be paid.
                  /knelli added logic/
	          IF l_loop_empr_work_days > 0 THEN
			l_loop_empr_work_days := l_loop_empr_work_days - l_actual_days;
		  END IF;
                  -- Recalculate employer days with previous employment child minder days.
                  l_loop_empr_work_days :=  nvl(l_loop_empr_work_days,0) + nvl(l_child_prev_value,0);
		  IF l_loop_empr_work_days >= l_child_1_13 THEN
                     l_empr_days := 0;
                     -- If total days taken is < the entitlement limit then remaining days will be taken
                     IF l_loop_empr_work_days < l_gen_child_limit THEN
                        -- If current absence days is > limit then restrict it to limit
                        IF  l_actual_days > ( l_gen_child_limit - l_loop_empr_work_days ) THEN
                            l_social_security_days := ( l_gen_child_limit - l_loop_empr_work_days );
                        ELSE
                            l_social_security_days := l_actual_days;
                        END IF;
                     ELSE -- If all the absences are exhausted earlier then no social security will be entertained.
                            l_social_security_days := 0;
                     END IF;
                     -- Override element exists then override the calculated value
                     IF l_override_ss_days IS NOT NULL THEN
                        l_social_security_days := least(l_override_ss_days, l_social_security_days);
                     END IF;
                  ELSE -- Continuous sickness days is less than 12 working days
                        -- if actual working days  > remaning available then social security days will be paid
                        IF l_actual_days > ( l_child_1_13 - l_loop_empr_work_days ) THEN
                           l_empr_days := ( l_child_1_13 - l_loop_empr_work_days );
                           l_social_security_days := (l_actual_days - l_empr_days);
                           /pdavidra - 5260950  /
                           IF  l_social_security_days > (l_gen_child_limit - l_loop_empr_work_days - l_empr_days) THEN
                               l_social_security_days := (l_gen_child_limit - l_loop_empr_work_days - l_empr_days);
                           END IF;
                           -- if override employer days is present calculate actual days through linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;

                           IF l_override_ss_days IS NOT NULL THEN
                              l_social_security_days := least(l_override_ss_days, l_social_security_days);
                           END IF;
                        ELSE
                           l_empr_days := l_actual_days;
                           l_social_security_days := 0;
                           -- if override employer days is present calculate actual days through continuous linking sickness
                           -- and then override that with the override days.
                           IF l_override_empr_days IS NOT NULL THEN
                              l_empr_days := least(l_override_empr_days, l_empr_days);
                           END IF;
                        END IF;
                  END IF;


                  /knelli this check is not required , means always we have SS days/
		   /IF l_gen_reimb_ss = 'N' THEN
                         l_social_security_days := 0;
                   END IF;/
              END IF; -- Current absence is prorated.
           END IF; -- Main logic end */

--=========================================================================================================================

		curr_year_cms_emp_days := nvl(p_child_emp_days,0);
                curr_year_cms_ss_days  := nvl(p_child_ss_days,0);
                l_child_prev_value := nvl(l_child_prev_value,0);
                -- Calculation of actual working days present with the current absence.
                -- Ignore public holidays if the one present in between absence start and end dates.
                l_include_event := 'N';

                l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                     ( p_assignment_id, l_days_or_hours, l_include_event,
                                       p_prorate_start, p_prorate_end, l_start_time_char,
                                       l_end_time_char, l_duration
                                      );
                l_actual_days := nvl(l_duration,0);
                -- Recalculate employer/social security days with previous employment child minder days.
                IF l_child_prev_value <= p_abs_child_emp_days_limit THEN
                   curr_year_cms_emp_days := curr_year_cms_emp_days + l_child_prev_value;
                ELSE
                  curr_year_cms_emp_days := p_abs_child_emp_days_limit;
                  curr_year_cms_ss_days := curr_year_cms_ss_days +  (l_child_prev_value - p_abs_child_emp_days_limit) ;
                END IF;

                --Check if the current year emp days is >= entitlement limit then
                IF curr_year_cms_emp_days >= p_abs_child_emp_days_limit THEN
                   l_empr_days := 0;
                   l_gen_ss_st_date := p_prorate_start ;
                   -- If total days taken is < the entitlement limit then remaining days will be SS days
                  IF (curr_year_cms_emp_days + curr_year_cms_ss_days) < l_gen_child_limit THEN
                    p_work_pattern := '5DAY';
                    l_duration := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                    -- If current absence days is > total limit then restrict it to limit
                    IF l_duration > ( l_gen_child_limit - (curr_year_cms_emp_days + curr_year_cms_ss_days) ) THEN
                       l_social_security_days := ( l_gen_child_limit - (curr_year_cms_emp_days + curr_year_cms_ss_days) );
                       l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                    ELSE
                       l_social_security_days := l_duration;
                    END IF;
                  ELSE -- If all the absences are exhausted earlier then no social security will be entertained.
                    l_social_security_days := 0;
                    l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                  END IF;
                ELSE
                  -- if actual working days  > remaning available
                  IF l_actual_days > ( p_abs_child_emp_days_limit - curr_year_cms_emp_days ) THEN
                     l_empr_days := ( p_abs_child_emp_days_limit -  curr_year_cms_emp_days );
                     l_gen_ss_st_date := p_prorate_start + nvl(l_empr_days,0) ;
                      LOOP
                          l_include_event := 'N';
                          l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                          ( p_assignment_id, l_days_or_hours, l_include_event,
                            p_prorate_start, l_gen_ss_st_date, l_start_time_char,
                            l_end_time_char, l_duration );
                           IF l_duration = (l_empr_days +1) THEN
                             exit;
                           END IF;
                             l_gen_ss_st_date := l_gen_ss_st_date + 1;
                       END LOOP;
                     p_work_pattern := '5DAY';
                     l_social_security_days := get_weekdays(l_gen_ss_st_date, p_prorate_end, p_work_pattern);
                     --l_social_security_days := (l_actual_days - l_empr_days);
                     -- if Social Security days > total limit
                     IF l_social_security_days > (l_gen_child_limit - (curr_year_cms_emp_days + curr_year_cms_ss_days) - l_empr_days) THEN
                        l_social_security_days := (l_gen_child_limit - (curr_year_cms_emp_days + curr_year_cms_ss_days) - l_empr_days);
                        l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                     END IF;
                  ELSE
                    l_empr_days := l_actual_days;
                    l_social_security_days := 0;
                  END IF;
                  IF l_empr_days > ( l_gen_child_limit - (curr_year_cms_emp_days + curr_year_cms_ss_days) ) THEN
                       l_empr_days := ( l_gen_child_limit - (curr_year_cms_emp_days + curr_year_cms_ss_days) );
                       l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                       IF l_empr_days < 0 THEN
                          l_empr_days := 0;
                       END IF;
                  END IF;
                END IF;

                IF l_social_security_days < 0 THEN
                   l_social_security_days := 0;
                END IF;

                -- if override employer days is present calculate actual days through linking sickness
                -- and then override that with the override days.
                IF l_override_empr_days IS NOT NULL THEN
                   /*l_empr_days := least(l_override_empr_days, l_empr_days); 5380130 */
                   l_empr_days := l_override_empr_days;
		   IF (curr_year_cms_emp_days + l_empr_days) > p_abs_child_emp_days_limit THEN
		     l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                   END IF;
                END IF;
                IF l_override_ss_days IS NOT NULL THEN
                   /*l_social_security_days := least(l_override_ss_days, l_social_security_days); 5380130 */
                   l_social_security_days := l_override_ss_days;
		   IF (curr_year_cms_emp_days + l_empr_days + curr_year_cms_ss_days + l_social_security_days) > l_gen_child_limit THEN
		     l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                   END IF;
                END IF;

            -- Calculated result are assigned to output variables except daily rate
            p_abs_empr_days  := nvl(l_empr_days,0) ;
            p_abs_ss_days    := nvl(l_social_security_days,0) ;
            p_abs_total_days := (p_abs_empr_days + p_abs_ss_days);
            p_rec_empr_days  := nvl(l_empr_days,0) ;
            p_rec_ss_days    := nvl(l_social_security_days,0) ;
            p_rec_total_days := (p_rec_empr_days + p_rec_ss_days);

            OPEN  csr_intial_abs_pay_stdt(p_assignment_id,p_abs_start_date);
            FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
            CLOSE csr_intial_abs_pay_stdt;

            -- Get the daily rate value
            -- Calculation of G rate

	    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
		the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

            -- l_g_rate := GET_GRATE ( p_effective_date, p_assignment_id, p_business_group_id);
	    l_g_rate := GET_GRATE ( p_abs_start_date, p_assignment_id, p_business_group_id);

	    /* End Bug Fix : 5380121 */

            -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
            IF l_gen_hour_sal = 'S' THEN

		/*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                            (p_assignment_id, p_effective_date, 'Contractual Earnings',
                             'R', 'D', l_rate, l_error_message, null, null);*/
		/*pgopal - Bug 5441078 fix - Passing absence start date*/
		l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                            (p_assignment_id, p_abs_start_date, 'Contractual Earnings',
                             'R', 'D', l_rate, l_error_message, null, null);

                -- Override social security date was present.
                IF l_override_ss_rate IS NOT NULL THEN
                   l_social_security_rate := l_override_ss_rate;
                ELSE
                   l_social_security_rate := l_rate;
                END IF;
               -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
               IF l_gen_restrict_ss_sl = 'Y' THEN
                  IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                     l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                  END IF;
               END IF;
                -- if restrict daily rate to social security is not set then
                IF l_gen_restrict_dr_ss = 'N' THEN
                   -- (absence pay base * 12) / 260;
                   l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;
                   -- if override employer daily rate was present then take that for sick pay.
                   IF l_override_empr_rate IS NOT NULL THEN
                      l_empr_daily_rate := l_override_empr_rate ;
                   END IF;
                   -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                   IF l_gen_restrict_empr_sl = 'Y' THEN
                      IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                         l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                      END IF;
                   END IF;

                   -- if restrict daily rate to social security is no then pick whichever is
                   -- less between historic and daily rate.
                   IF l_social_security_rate > l_empr_daily_rate THEN
                      l_reclaim_daily_rate := l_empr_daily_rate;
                   ELSE
                      l_reclaim_daily_rate := l_social_security_rate;
                   END IF;
                -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                ELSE
                      l_empr_daily_rate := l_social_security_rate;
                      l_reclaim_daily_rate := l_social_security_rate;

                      IF l_override_empr_rate IS NOT NULL THEN
                         l_empr_daily_rate := l_override_empr_rate ;
                      END IF;
                      -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                      IF l_gen_restrict_empr_sl = 'Y' THEN
                         IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                            l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                         END IF;
                      END IF;
                END IF;

           -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
           ELSIF l_gen_hour_sal = 'H' THEN
                 p_ear_value := 0;
		 IF p_hourly_paid IN ('W', 'B') THEN
                    -- Ignore public holidays if the one present in between absence start and end dates.
                    l_include_event := 'Y';
                    -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
		    /* pgopal - Bug 5393827 and 5349713 fix - taking the absence start date instead
		    of payroll start date to get the last 4 weeks worked days*/

		    /* knelli changed date_start parameter, reduced date by 1 */
		    /* 5475038 l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                         ( p_assignment_id, l_days_or_hours, l_include_event,
                                           ((p_abs_start_date) - p_abs_min_gap), (p_abs_start_date-1), l_start_time_char,
                                           l_end_time_char, l_duration
                                           );*/
                     l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                     ( p_assignment_id, l_days_or_hours, l_include_event,
                      greatest(l_dateofjoin,((l_initial_abs_pay_stdt) - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                      l_end_time_char, l_duration );
                    -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.


		    BEGIN
                        SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                          ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                    WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                          ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                    WHEN date_end = date_start THEN
                        	  	          1
                                    ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                          INTO l_abs_worked_days
                          FROM per_absence_attendances
                         WHERE person_id = p_person_id
			   AND date_start < (l_initial_abs_pay_stdt-1)
                           AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                           AND date_start IS NOT NULL
                           AND date_end IS NOT NULL ;
                    EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            l_abs_worked_days := 0;

                       WHEN OTHERS THEN
                            l_abs_worked_days := 0;

                    END;

		    l_duration := l_duration - nvl(l_abs_worked_days, 0);
		    /* Bug Fix 5263714 added check condition*/
		    IF l_duration > 0 THEN
		    l_social_security_rate := ( p_4weeks_paybase / l_duration);
		    ELSE
		    l_social_security_rate := 0;
		    END IF;
                    -- Override social security date was present.
                    IF l_override_ss_rate IS NOT NULL THEN
                       l_social_security_rate := l_override_ss_rate;
                    END IF;
                    -- If social security rate is greater than 6g then restrict it to 6g if the flag is set

		    IF l_gen_restrict_ss_sl = 'Y' THEN
                       IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                          l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                       END IF;
                    END IF;

                       -- if override employer daily rate was present then take that for sick pay.
                       IF l_override_empr_rate IS NOT NULL THEN
                          l_empr_daily_rate := l_override_empr_rate ;
                       ELSE
                          l_empr_daily_rate := l_social_security_rate;
                       END IF;

                       -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set

		       IF l_gen_restrict_empr_sl = 'Y' THEN
                          IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;
                       END IF;

                       l_reclaim_daily_rate := l_social_security_rate;

                 ELSIF p_hourly_paid = 'M' THEN
			/* knelli
		      IF length(l_msg_error) > 1 THEN
                         l_msg_error := 'Error7';
                      END IF;*/
		      l_msg_error := to_char(7);
                       -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                       -- Previous 4 weeks period logic will not work.
                 END IF;
           END IF;

              p_abs_daily_rate := nvl(l_empr_daily_rate,0);
              p_ss_daily_rate  := nvl(l_social_security_rate,0);


           -- If reclaimable daily rate is set on override element then use the value to reclaim
           -- from social security else use social security rate calculated.
           IF l_override_reclaim_rate IS NOT NULL THEN
              p_rec_daily_rate := l_override_reclaim_rate;
           ELSE
              p_rec_daily_rate := p_ss_daily_rate;
           END IF;

            IF l_gen_rate_option = 'DRATE_OPT1' THEN
               p_rate_option1 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
               p_rate_option2 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
               p_rate_option3 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
               p_rate_option4 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
               p_rate_option5 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
               p_rate_option6 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
               p_rate_option7 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
               p_rate_option8 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
               p_rate_option9 := 'Y';
            ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
               p_rate_option10 := 'Y';
            ELSE
               p_rate_option1  := null;
               p_rate_option2  := null;
               p_rate_option3  := null;
               p_rate_option4  := null;
               p_rate_option5  := null;
               p_rate_option6  := null;
               p_rate_option7  := null;
               p_rate_option8  := null;
               p_rate_option9  := null;
               p_rate_option10 := null;
               -- If calculated employer daily rate is less than 50% of G daily rate then no social security period will be paid.
               IF p_abs_daily_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  --Employers period alone can be paid. No social security period will be paid.
    	          p_rec_empr_days  := 0;
    	          p_rec_ss_days    := 0;
    	          p_rec_total_days := 0;
    	          p_rec_daily_rate := 0;
                  p_ss_daily_rate  := 0;
                  IF p_abs_ss_days > 0 then
                    l_msg_error := to_char(11); /* 50% G Message */
                  END IF;
                  p_abs_ss_days    := 0;
                  p_abs_total_days := (nvl(p_abs_empr_days,0) + nvl(p_abs_ss_days,0)) ;
               END IF;
            END IF;
            p_abs_error := l_msg_error ;

        ELSIF l_abs_category_code = 'PA' THEN

		 -- Fetch EIT values from absence payment details form
                 -- 9 segments
		 BEGIN
          	    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   --AS l_p_dob
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION2)  --AS l_p_compensation_rate
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  --AS l_p_maternity_days
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION4)  --AS l_p_pt_maternity_days
          	           ,PAA.ABS_INFORMATION5             --AS l_p_reimburse_from_ss
        	           ,PAA.ABS_INFORMATION6             --AS l_p_use_ss_daily_rate
        	           ,PAA.ABS_INFORMATION7             --AS l_p_reclaimable_pay_max_6g
        	           ,PAA.ABS_INFORMATION8             --AS l_p_hol_acc_ent
        	           ,PAA.ABS_INFORMATION9             --AS l_p_daily_rate_calc
  			   ,PAA.ABS_INFORMATION15             --AS intial_absence
			   ,PAA.ABS_INFORMATION16             -- AS intial_abs_attend_id
	   	      INTO l_p_dob
                          ,l_p_compensation_rate
			  ,l_p_maternity_days
			  ,l_p_pt_maternity_days
                          ,l_p_reimburse_from_ss
                          ,l_p_use_ss_daily_rate
                          ,l_p_reclaimable_pay_max_6g
                          ,l_p_hol_acc_ent
			  ,l_p_daily_rate_calc
			   ,l_initial_absence
		           ,l_initial_abs_attend_id
        	      FROM PER_ABSENCE_ATTENDANCES PAA
        	      WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

                 EXCEPTION
        	        WHEN OTHERS THEN

                         l_p_dob	              := null;
                         l_p_compensation_rate        := null;
			 l_p_maternity_days           := null;
			 l_p_pt_maternity_days        := null;
                         l_p_reimburse_from_ss        := null;
                         l_p_use_ss_daily_rate	      := null;
                         l_p_reclaimable_pay_max_6g   := null;
			 l_p_hol_acc_ent	      := null;
			 l_p_daily_rate_calc	      := null;
		         l_initial_absence        :=NULL;
		         l_initial_abs_attend_id  := NULL ;

                 END;
               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);
	       /*pgopal -Bug 5380065 fix*/
               l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_p_reclaimable_pay_max_6g, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');
               -- If reimburse from social security is set then adoption leave will be paid.
               IF l_gen_reimb_ss = 'Y' THEN
                   -- Calling override to get override days and daily rate
                   l_over_return := get_override_details
                                    ( p_assignment_id,p_effective_date,p_abs_start_date,
                                      p_abs_end_date, p_abs_categorycode, l_override_start_date,
                                      l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                                      l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                                     );
                    /* Multiple override element attached against one absence element. ie)  *
                     * One or more override entry exists with same start and end date       */
                    IF (l_over_return = -1) THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;*/
			  l_msg_error := to_char(5);
                          p_abs_error := l_msg_error;
                          RETURN 1;
                    END IF;
                    IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
                       l_msg_error := to_char(13);
                    END IF;
                    IF nvl(l_override_empr_days,0) > 0 THEN
                       l_msg_error := to_char(14);
                       p_abs_error := l_msg_error;
                       RETURN 1;
                    END IF;
                   p_work_pattern := '5DAY';
                   -- To find out number of days adoption leave has been taken in the current payroll period
                   BEGIN
                        SELECT SUM(DECODE(paa.date_start, paa.date_end, 1,
                                          get_weekdays(greatest(p_pay_start_date, paa.date_start), paa.date_end, p_work_pattern) )) AS days_diff
                          INTO l_paternity_sum
                          FROM per_absence_attendances paa, per_absence_attendance_types pat
                         WHERE paa.person_id = p_person_id
                           AND paa.date_end BETWEEN p_pay_start_date AND p_pay_end_date
                           AND paa.date_end < p_abs_start_date
                           AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
                           AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
                           AND pat.absence_category = 'M'
                         ORDER BY paa.date_end DESC ;
                    EXCEPTION
                         WHEN OTHERS THEN
                              l_paternity_sum := null;
                    END;


                      -- Calculate actual days based on 5 day week pattern.
                      p_work_pattern := '5DAY';
                      l_duration := get_weekdays(p_prorate_start, p_prorate_end, p_work_pattern);

                      -- If override element exists for the adoption absence then use the override value.
                      /*IF l_override_ss_days IS NOT NULL THEN
                         l_duration := l_override_ss_days;
                      END IF;*/


                         IF l_p_compensation_rate = 100 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_100_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_100;
                             CLOSE GLB_VALUE;
			     /*
                             IF nvl(l_m_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_100_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
			        l_max_parental_days_100 := l_max_parental_days_100 + (l_parental_days_add_child*l_m_no_of_babies_born);
			     END IF;*/

			     l_parental_days_remaining := l_max_parental_days_100 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_m_paternity_days,0) - nvl(l_m_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_maternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
			     IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                             ELSE
                                p_parental_days := l_duration;
                             END IF;

                         ELSIF l_p_compensation_rate = 80 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_80_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_80;
                             CLOSE GLB_VALUE;
			     /*
			     IF nvl(l_m_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_80_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
			        l_max_parental_days_80 := l_max_parental_days_80 + (l_parental_days_add_child*l_m_no_of_babies_born);
			     END IF;*/

			     l_parental_days_remaining := l_max_parental_days_80 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_m_paternity_days,0) - nvl(l_m_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_maternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     /*IF l_duration > ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum));*/
                             IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
			     ELSE
                                p_parental_days := l_duration;
                             END IF;
                         END IF;

                         -- If override element exists for the adoption absence then use the override value.
                         IF l_override_ss_days IS NOT NULL THEN
                            p_parental_days := l_override_ss_days;
                            IF p_parental_days > l_parental_days_remaining THEN
                               l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                            END IF ;
                          END IF;

                     -- Daily Rate calculation
                    -- Calculation of G rate

		    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
			the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

                    -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    -- l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);

		    /* End Bug Fix : 5380121 */

			/* pgopal - to get the initial absence start date*/
			IF ( l_initial_absence = 'N') THEN
			OPEN  csr_get_intial_abs_st_date(l_initial_abs_attend_id);
			FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
			CLOSE csr_get_intial_abs_st_date;
			ELSE
			l_initial_abs_st_date := p_abs_start_date;
			END IF ;

                        OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date);
                        FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
                        CLOSE csr_intial_abs_pay_stdt;

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id);

                    -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
                    IF l_gen_hour_sal = 'S' THEN
    		       /* l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, p_effective_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);*/
		        /*pgopal - Bug 5441078 fix - Passing initial absence start date*/
    		        l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, l_initial_abs_st_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);

                       -- Override social security date was present.
                       IF l_override_ss_rate IS NOT NULL THEN
                          l_social_security_rate := l_override_ss_rate;
                       ELSE
                          l_social_security_rate := l_rate;
                       END IF;

                       -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                       IF l_gen_restrict_ss_sl = 'Y' THEN
                          IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;
                       END IF;

                        -- if restrict daily rate to social security is not set then
                        IF l_gen_restrict_dr_ss = 'N' THEN
		           -- (absence pay base * 12) / 260;
                           l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;

                           -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                           IF l_gen_restrict_empr_sl = 'Y' THEN
                              IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                 l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                              END IF;
                           END IF;

                           -- if restrict daily rate to social security is no then pick whichever is
                           -- less between historic and daily rate.
                           IF l_social_security_rate > l_empr_daily_rate THEN
                              l_reclaim_daily_rate := l_empr_daily_rate;
                           ELSE
                              l_reclaim_daily_rate := l_social_security_rate;
                           END IF;
                        -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                        ELSE
                              l_empr_daily_rate := l_social_security_rate;
                              l_reclaim_daily_rate := l_social_security_rate;

		        END IF;

                   -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
                   ELSIF l_gen_hour_sal = 'H' THEN
       		            p_ear_value := 0;
			    IF p_hourly_paid IN ('W', 'B') THEN

                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'Y';
                            -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
			    /* pgopal - Bug 5393827 and 5349713 fix - taking the initial absence start date instead
			    of payroll start date to get the last 4 weeks worked days*/

			    /* BUG Fix 5346832 : Start
				   Changing the start date from (l_initial_abs_st_date - p_abs_min_gap)
				   to greatest(l_dateofjoin,(l_initial_abs_st_date - p_abs_min_gap))
				   for hr_loc_work_schedule.calc_sch_based_dur */

			    /*
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   ((l_initial_abs_st_date) - p_abs_min_gap), (l_initial_abs_st_date-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );
			    */
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   greatest(l_dateofjoin,((l_initial_abs_pay_stdt) - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );

			    /* BUG Fix 5346832 : End */


                            -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
                            BEGIN
                                SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                                  ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                            WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                                  ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                            WHEN date_end = date_start THEN
                                	  	          1
                                            ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                                  INTO l_abs_worked_days
                                  FROM per_absence_attendances
                                 WHERE person_id = p_person_id
				   AND date_start < (l_initial_abs_pay_stdt-1)
                                   AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                                   AND date_start IS NOT NULL
                                   AND date_end IS NOT NULL ;
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    l_abs_worked_days := 0;
                               WHEN OTHERS THEN
                                    l_abs_worked_days := 0;
                            END;

                            l_duration := l_duration - nvl(l_abs_worked_days, 0);
			    /* Bug fix 5263714 */
			    IF l_duration > 0 THEN
                            l_social_security_rate := ( p_4weeks_paybase / l_duration);
			    ELSE
			    l_social_security_rate := 0;
			    END IF;
                            -- Override social security date was present.
                            IF l_override_ss_rate IS NOT NULL THEN
                               l_social_security_rate := l_override_ss_rate;
                            END IF;
                            -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                            IF l_gen_restrict_ss_sl = 'Y' THEN
                               IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                  l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                               END IF;
                            END IF;

                            l_empr_daily_rate := l_social_security_rate;
                            l_reclaim_daily_rate := l_social_security_rate;
                         ELSIF p_hourly_paid = 'M' THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error7';
                          END IF;*/
			  l_msg_error := to_char(7);
                               -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                               -- Previous 4 weeks period logic will not work.
                         END IF;
                   END IF;

                   p_parental_rate     := l_reclaim_daily_rate ;
		   /* knelli added logic */
		   /*pgopal Bug 5353824 fix*/
		   /*IF l_m_compensation_rate = 80 THEN*/
		   IF l_p_compensation_rate = 80 THEN
		   p_parental_rate := p_parental_rate * 0.8;
		   END IF;
                   p_parental_comprate := l_p_compensation_rate ;
                   -- Reusing the existing siciness output variables for adoption
                   p_rec_total_days := p_parental_days;
                   p_rec_daily_rate := p_parental_comprate;
                   p_ss_daily_rate  := p_parental_rate;


                   l_include_event := 'N';
                   -- Calculating actual sickness days through work schedule
                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                        ( p_assignment_id, l_days_or_hours, l_include_event,
                                          p_prorate_start, p_prorate_end, l_start_time_char,
                                          l_end_time_char, l_duration
                                         );
                      l_actual_cal_days := nvl(l_duration,0);
                   -- Calculate Earnings Adjustment value
                      --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
		      p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * l_actual_cal_days;
                      p_ear_startdt    := p_prorate_start;
                      p_ear_enddt      := p_prorate_end;
                      p_ear_value      := nvl(p_ear_value,0);

			IF l_gen_hour_sal = 'H' THEN
			       p_ear_value := 0;
			END IF;

                        IF l_gen_rate_option = 'DRATE_OPT1' THEN
                           p_rate_option1 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
                           p_rate_option2 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
                           p_rate_option3 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
                           p_rate_option4 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
                           p_rate_option5 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
                           p_rate_option6 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
                           p_rate_option7 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
                           p_rate_option8 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
                           p_rate_option9 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
                           p_rate_option10 := 'Y';
                        ELSE
                           p_rate_option1  := null;
                           p_rate_option2  := null;
                           p_rate_option3  := null;
                           p_rate_option4  := null;
                           p_rate_option5  := null;
                           p_rate_option6  := null;
                           p_rate_option7  := null;
                           p_rate_option8  := null;
                           p_rate_option9  := null;
                           p_rate_option10 := null;
                        END IF;
              p_abs_error := l_msg_error ;

		/* Bug Fix 5349636 : Start */

	       -- If calculated daily rate is less than 50% of G daily rate then no social security period will be paid.
               IF p_parental_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  -- No social security period will be paid.
		   p_rec_total_days := 0;
		   p_rec_daily_rate := 0;
		   p_ss_daily_rate  := 0;
		   p_ear_value      := 0;
                   l_msg_error := to_char(11); /* 50% G Message */
		   p_abs_error := l_msg_error ;
               END IF;

		/* Bug Fix 5349636 : End */

              ELSE -- if reimburse from social security is set to No then no adoption will be paid.
                   -- Reusing the existing siciness output variables for adoption

                   p_rec_total_days := 0;
                   p_rec_daily_rate := 0;
                   p_ss_daily_rate  := 0;
                   p_ear_value      := 0;
                   p_abs_error := l_msg_error ;

               END IF; -- Reimburse from social security

        ELSIF l_abs_category_code = 'PTP' THEN


                 -- Fetch EIT values from absence payment details form
                 -- 9 segments
		 BEGIN
          	    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   --AS l_ptp_dob
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION2)  --AS l_ptp_mat_compensation_rate
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  --AS l_ptp_paternity_percent
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION4)  --AS l_ptp_days_spouse_mat_leave
        	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION5)  --AS l_ptp_days_pt_maternity
        	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION6)  --AS l_ptp_no_of_babies_born
        	           ,PAA.ABS_INFORMATION7             --AS l_ptp_reimburse_from_ss
           	           ,PAA.ABS_INFORMATION8             --AS l_ptp_use_ss_daily_rate
        	           ,PAA.ABS_INFORMATION9             --AS l_ptp_reclaimable_pay_max_6g
        	           ,PAA.ABS_INFORMATION10            --AS l_ptp_hol_acc_ent
        	           ,PAA.ABS_INFORMATION11            --AS l_ptp_daily_rate_calc
  			   ,PAA.ABS_INFORMATION15             --AS intial_absence
			   ,PAA.ABS_INFORMATION16             -- AS intial_abs_attend_id
        	      INTO l_ptp_dob
                          ,l_ptp_mat_compensation_rate
			  ,l_ptp_paternity_percent
                          ,l_ptp_days_spouse_mat_leave
                          ,l_ptp_days_pt_maternity
                          ,l_ptp_no_of_babies_born
			  ,l_ptp_reimburse_from_ss
			  ,l_ptp_use_ss_daily_rate
			  ,l_ptp_reclaimable_pay_max_6g
			  ,l_ptp_hol_acc_ent
			  ,l_ptp_daily_rate_calc
			   ,l_initial_absence
		           ,l_initial_abs_attend_id
        	      FROM PER_ABSENCE_ATTENDANCES PAA
        	      WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

                 EXCEPTION
        	        WHEN OTHERS THEN

                         l_ptp_dob	              := null;
                         l_ptp_mat_compensation_rate  := null;
                         l_ptp_paternity_percent      := null;
			 l_ptp_days_spouse_mat_leave  := null;
                         l_ptp_days_pt_maternity      := null;
			 l_ptp_no_of_babies_born      := null;
			 l_ptp_reimburse_from_ss      := null;
			 l_ptp_use_ss_daily_rate      := null;
 			 l_ptp_reclaimable_pay_max_6g := null;
 			 l_ptp_hol_acc_ent	      := null;
			 l_ptp_daily_rate_calc	      := null;
		         l_initial_absence             :=NULL;
		         l_initial_abs_attend_id       := NULL ;

                 END;
               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);
	       /*pgopal -Bug 5380065 fix*/
               l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_ptp_reclaimable_pay_max_6g, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');


               -- If reimburse from social security is set then adoption leave will be paid.
               IF l_gen_reimb_ss = 'Y' THEN

                   -- Calling override to get override days and daily rate
                   l_over_return := get_override_details
                                    ( p_assignment_id,p_effective_date,p_abs_start_date,
                                      p_abs_end_date, p_abs_categorycode, l_override_start_date,
                                      l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                                      l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                                     );
                    /* Multiple override element attached against one absence element. ie)  *
                     * One or more override entry exists with same start and end date       */
                    IF (l_over_return = -1) THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;*/
			  l_msg_error := to_char(5);
                          p_abs_error := l_msg_error;
                          RETURN 1;
		    END IF;
                    IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
                       l_msg_error := to_char(13);
                    END IF;
                    IF nvl(l_override_empr_days,0) > 0 THEN
                       l_msg_error := to_char(14);
                       p_abs_error := l_msg_error;
                       RETURN 1;
                    END IF;
		   p_work_pattern := '5DAY';
                   -- To find out number of days adoption leave has been taken in the current payroll period
                   BEGIN
                        SELECT SUM(DECODE(paa.date_start, paa.date_end, 1,
                                          get_weekdays(greatest(p_pay_start_date, paa.date_start), paa.date_end, p_work_pattern) )) AS days_diff
                          INTO l_pt_paternity_sum
                          FROM per_absence_attendances paa, per_absence_attendance_types pat
                         WHERE paa.person_id = p_person_id
                           AND paa.date_end BETWEEN p_pay_start_date AND p_pay_end_date
                           AND paa.date_end < p_abs_start_date
                           AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
                           AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
                           AND pat.absence_category = 'PTM'
                         ORDER BY paa.date_end DESC ;
                    EXCEPTION
                         WHEN OTHERS THEN
                              l_pt_paternity_sum := null;
                    END;


                      -- Calculate actual days based on 5 day week pattern.
                      p_work_pattern := '5DAY';
                      l_duration := get_weekdays(p_prorate_start, p_prorate_end, p_work_pattern);

                      -- If override element exists for the adoption absence then use the override value.
                      /*IF l_override_ss_days IS NOT NULL THEN
                         l_duration := l_override_ss_days;
                      END IF;*/


                         IF l_ptp_mat_compensation_rate = 100 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_100_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_100;
                             CLOSE GLB_VALUE;

                             IF nvl(l_ptp_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_100_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
			        l_max_parental_days_100 := l_max_parental_days_100 + (l_parental_days_add_child*l_ptp_no_of_babies_born);
			     END IF;

			     l_parental_days_remaining := l_max_parental_days_100 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_m_paternity_days,0) - nvl(l_m_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_pt_paternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     IF nvl(l_ptp_paternity_percent,0) > 0 THEN
				l_parental_days_remaining := trunc(l_parental_days_remaining * 100/(100-l_ptp_paternity_percent));

			     END IF;
			     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
			     IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                             ELSE
                                p_parental_days := l_duration;
                             END IF;


                         ELSIF l_ptp_mat_compensation_rate = 80 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_80_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_80;
                             CLOSE GLB_VALUE;

			     IF nvl(l_ptp_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_80_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
			        l_max_parental_days_80 := l_max_parental_days_80 + (l_parental_days_add_child*l_ptp_no_of_babies_born);
			     END IF;

			     l_parental_days_remaining := l_max_parental_days_80 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_m_paternity_days,0) - nvl(l_m_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_pt_paternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     IF nvl(l_ptp_paternity_percent,0) > 0 THEN
				l_parental_days_remaining := trunc(l_parental_days_remaining * 100/(100-l_ptp_paternity_percent));
			     END IF;
			     /*IF l_duration > ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum));*/
                             IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
			     ELSE
                                p_parental_days := l_duration;
                             END IF;

                         END IF;

		   /* pgopal - Bug 5355902 fix*/
		    --p_parental_days := p_parental_days * trunc((l_ptp_paternity_percent/100),2);
                    p_parental_days := round(p_parental_days * (l_ptp_paternity_percent/100),2);
			 -- If override element exists for the adoption absence then use the override value.
                         IF l_override_ss_days IS NOT NULL THEN
                            p_parental_days := l_override_ss_days;
                            IF p_parental_days > l_parental_days_remaining THEN
                               l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                            END IF ;
                          END IF;
			-- Daily Rate calculation
                    -- Calculation of G rate

		    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
			the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

                    -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    -- l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);

		    /* End Bug Fix : 5380121 */

			/* pgopal - to get the initial absence start date*/
			IF ( l_initial_absence = 'N') THEN
			OPEN  csr_get_intial_abs_st_date(l_initial_abs_attend_id);
			FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
			CLOSE csr_get_intial_abs_st_date;
			ELSE
			l_initial_abs_st_date := p_abs_start_date;
			END IF ;

                        OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date);
                        FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
                        CLOSE csr_intial_abs_pay_stdt;

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		     l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id);

		     -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
                    IF l_gen_hour_sal = 'S' THEN

                        /*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, p_effective_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);*/
		        /*pgopal - Bug 5441078 fix - Passing initial absence start date*/
                        l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, l_initial_abs_st_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);


                       -- Override social security date was present.
                       IF l_override_ss_rate IS NOT NULL THEN
                          l_social_security_rate := l_override_ss_rate;
                       ELSE
                          l_social_security_rate := l_rate;
                       END IF;

                       -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                       IF l_gen_restrict_ss_sl = 'Y' THEN
                          IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;
                       END IF;

                        -- if restrict daily rate to social security is not set then
                        IF l_gen_restrict_dr_ss = 'N' THEN

                           -- (absence pay base * 12) / 260;
                           l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;

                           -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                           IF l_gen_restrict_empr_sl = 'Y' THEN
                              IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                 l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                              END IF;
                           END IF;

                           -- if restrict daily rate to social security is no then pick whichever is
                           -- less between historic and daily rate.
                           IF l_social_security_rate > l_empr_daily_rate THEN
                              l_reclaim_daily_rate := l_empr_daily_rate;
                           ELSE
                              l_reclaim_daily_rate := l_social_security_rate;
                           END IF;
                        -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                        ELSE
                              l_empr_daily_rate := l_social_security_rate;
                              l_reclaim_daily_rate := l_social_security_rate;


                        END IF;

                   -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
                   ELSIF l_gen_hour_sal = 'H' THEN
       		         p_ear_value := 0;
                         IF p_hourly_paid IN ('W', 'B') THEN

                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'Y';
                            -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
                            /* pdavidra - bug 5330066 - redused the start date parameter by 1*/
			    /* pgopal - Bug 5393827 and 5349713 fix - taking the initial absence start date instead
			    of payroll start date to get the last 4 weeks worked days*/

			    /* BUG Fix 5346832 : Start
				   Changing the start date from (l_initial_abs_st_date - p_abs_min_gap)
				   to greatest(l_dateofjoin,(l_initial_abs_st_date - p_abs_min_gap))
				   for hr_loc_work_schedule.calc_sch_based_dur */

			   /*
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   (l_initial_abs_st_date - p_abs_min_gap), (l_initial_abs_st_date-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );
			   */
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   greatest(l_dateofjoin,(l_initial_abs_pay_stdt - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );

			   /* BUG Fix 5346832 : End */


                            -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
                            BEGIN
                                SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                                  ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                            WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                                  ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                            WHEN date_end = date_start THEN
                                	  	          1
                                            ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                                  INTO l_abs_worked_days
                                  FROM per_absence_attendances
                                 WHERE person_id = p_person_id
				   AND date_start < (l_initial_abs_pay_stdt-1)
                                   AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                                   AND date_start IS NOT NULL
                                   AND date_end IS NOT NULL ;
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    l_abs_worked_days := 0;
                               WHEN OTHERS THEN
                                    l_abs_worked_days := 0;
                            END;

                            l_duration := l_duration - nvl(l_abs_worked_days, 0);

                            /* BUG Fix 5346832 : Start */

			    IF (l_duration > 0) THEN
				l_social_security_rate := ( p_4weeks_paybase / l_duration);
			    ELSE
				l_social_security_rate := 0 ;
			    END IF;

			    /* BUG Fix 5346832 : End */

			    -- Override social security date was present.
                            IF l_override_ss_rate IS NOT NULL THEN
                               l_social_security_rate := l_override_ss_rate;
                            END IF;
                            -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                            IF l_gen_restrict_ss_sl = 'Y' THEN
                               IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                  l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                               END IF;
                            END IF;

                            l_empr_daily_rate := l_social_security_rate;
                            l_reclaim_daily_rate := l_social_security_rate;
                         ELSIF p_hourly_paid = 'M' THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error7';
                          END IF;*/
			  l_msg_error := to_char(7);
                               -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                               -- Previous 4 weeks period logic will not work.
                         END IF;
                   END IF;

                   p_parental_rate     := l_reclaim_daily_rate ;

		   /* knelli added logic */
		   /*IF l_m_compensation_rate = 80 THEN*/
		   /*pgopal - Bug 5355902 fix*/
		   IF l_ptp_mat_compensation_rate = 80 THEN
		   p_parental_rate := p_parental_rate * 0.8;
		   END IF;
                   p_parental_comprate := l_ptp_mat_compensation_rate ;
                   -- Reusing the existing siciness output variables for adoption
                   p_rec_total_days := p_parental_days;
                   p_rec_daily_rate := p_parental_comprate;
                   p_ss_daily_rate  := p_parental_rate;


                   l_include_event := 'N';
                   -- Calculating actual sickness days through work schedule
                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                        ( p_assignment_id, l_days_or_hours, l_include_event,
                                          p_prorate_start, p_prorate_end, l_start_time_char,
                                          l_end_time_char, l_duration
                                         );
                      l_actual_cal_days := nvl(l_duration,0);
                   -- Calculate Earnings Adjustment value
                      --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
		      p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * p_parental_days;
                      p_ear_startdt    := p_prorate_start;
                      p_ear_enddt      := p_prorate_end;
                      p_ear_value      := nvl(p_ear_value,0);

                        IF l_gen_hour_sal = 'H' THEN
			       p_ear_value := 0;
			END IF;

                        IF l_gen_rate_option = 'DRATE_OPT1' THEN
                           p_rate_option1 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
                           p_rate_option2 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
                           p_rate_option3 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
                           p_rate_option4 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
                           p_rate_option5 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
                           p_rate_option6 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
                           p_rate_option7 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
                           p_rate_option8 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
                           p_rate_option9 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
                           p_rate_option10 := 'Y';
                        ELSE
                           p_rate_option1  := null;
                           p_rate_option2  := null;
                           p_rate_option3  := null;
                           p_rate_option4  := null;
                           p_rate_option5  := null;
                           p_rate_option6  := null;
                           p_rate_option7  := null;
                           p_rate_option8  := null;
                           p_rate_option9  := null;
                           p_rate_option10 := null;
                        END IF;
              p_abs_error := l_msg_error ;

		/* Bug Fix 5349636 : Start */

	       -- If calculated daily rate is less than 50% of G daily rate then no social security period will be paid.
               IF p_parental_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  -- No social security period will be paid.
		   p_rec_total_days := 0;
		   p_rec_daily_rate := 0;
		   p_ss_daily_rate  := 0;
		   p_ear_value      := 0;
                   l_msg_error := to_char(11); /* 50% G Message */
		   p_abs_error := l_msg_error ;
               END IF;

		/* Bug Fix 5349636 : End */

              ELSE -- if reimburse from social security is set to No then no adoption will be paid.
                   -- Reusing the existing siciness output variables for adoption

                   p_rec_total_days := 0;
                   p_rec_daily_rate := 0;
                   p_ss_daily_rate  := 0;
                   p_ear_value      := 0;
                   p_abs_error := l_msg_error ;

               END IF; -- Reimburse from social security

        ELSIF l_abs_category_code = 'M' THEN
                -- Fetch EIT values from absence payment details form
                 -- 9 segments, 12 segments, now 13 segments, 14 segments, 14th not used for calc
		 BEGIN
          	    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   --AS l_m_expected_dob
          	           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  --AS l_m_dob
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  --AS l_m_no_of_babies_born
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION4)  --AS l_m_compensation_rate
        	           ,PAA.ABS_INFORMATION5             --AS l_m_spouse
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION6)  --AS l_m_paternity_days
        	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION7)  --AS l_m_pt_paternity_days
               	           ,PAA.ABS_INFORMATION8             --AS l_m_reimurse_from_ss
			   ,PAA.ABS_INFORMATION9             --AS l_m_use_ss_daily_rate
        	           ,PAA.ABS_INFORMATION10            --AS l_m_reclaimable_pay_max_6g
        	           ,PAA.ABS_INFORMATION11            --AS l_m_hol_acc_ent
        	           ,PAA.ABS_INFORMATION12            --AS l_m_daily_rate_calc
			   ,to_date(PAA.ABS_INFORMATION13,'yyyy/mm/dd hh24:mi:ss')  --AS l_m_date_stillborn
  			   ,PAA.ABS_INFORMATION15             --AS intial_absence
			   ,PAA.ABS_INFORMATION16             -- AS intial_abs_attend_id
        	      INTO l_m_expected_dob
                          ,l_m_dob
                          ,l_m_no_of_babies_born
                          ,l_m_compensation_rate
                          ,l_m_spouse
			  ,l_m_paternity_days
                          ,l_m_pt_paternity_days
			  ,l_m_reimurse_from_ss
			  ,l_m_use_ss_daily_rate
			  ,l_m_reclaimable_pay_max_6g
			  ,l_m_hol_acc_ent
			  ,l_m_daily_rate_calc
			  ,l_m_date_stillborn
			   ,l_initial_absence
		           ,l_initial_abs_attend_id
        	      FROM PER_ABSENCE_ATTENDANCES PAA
        	      WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;
		 EXCEPTION
        	        WHEN OTHERS THEN

                         l_m_expected_dob        := null;
                         l_m_dob	         := null;
                         l_m_no_of_babies_born   := null;
                         l_m_compensation_rate   := null;
                         l_m_spouse              := null;
			 l_m_paternity_days	 := null;
			 l_m_pt_paternity_days	 := null;
			 l_m_reimurse_from_ss    := null;
			 l_m_use_ss_daily_rate	 := null;
			 l_m_reclaimable_pay_max_6g := null;
			 l_m_hol_acc_ent         := null;
			 l_m_daily_rate_calc	 := null;
			 l_m_date_stillborn	 := null;
		         l_initial_absence        :=NULL;
		         l_initial_abs_attend_id  := NULL ;
                 END;

               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               /* knelli change replace l_abs_daily_rate by l_m_daily_rate_calc
	       l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);*/
	       /*pgopal - Bug 5380057 fix*/
               l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_m_reclaimable_pay_max_6g, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');


               -- If reimburse from social security is set then adoption leave will be paid.
               IF l_gen_reimb_ss = 'Y' THEN
		   -- Calling override to get override days and daily rate
                   l_over_return := get_override_details
                                    ( p_assignment_id,p_effective_date,p_abs_start_date,
                                      p_abs_end_date, p_abs_categorycode, l_override_start_date,
                                      l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                                      l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                                     );
                    /* Multiple override element attached against one absence element. ie)  *
                     * One or more override entry exists with same start and end date       */
                    IF (l_over_return = -1) THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;*/
			  l_msg_error := to_char(5);
                          p_abs_error := l_msg_error;
                          RETURN 1;
                    END IF;
                    IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
                       l_msg_error := to_char(13);
                    END IF;
                    IF nvl(l_override_empr_days,0) > 0 THEN
                       l_msg_error := to_char(14);
                       p_abs_error := l_msg_error;
                       RETURN 1;
                    END IF;
                   p_work_pattern := '5DAY';
                   -- To find out number of days maternity leave has been taken in the current payroll period
                   BEGIN
                        SELECT SUM(DECODE(paa.date_start, paa.date_end, 1,
                                          get_weekdays(greatest(p_pay_start_date, paa.date_start), paa.date_end, p_work_pattern) )) AS days_diff
                          INTO l_maternity_sum
                          FROM per_absence_attendances paa, per_absence_attendance_types pat
                         WHERE paa.person_id = p_person_id
                           AND paa.date_end BETWEEN p_pay_start_date AND p_pay_end_date
                           AND paa.date_end < p_abs_start_date
                           AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
                           AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
                           AND pat.absence_category = 'M'
                         ORDER BY paa.date_end DESC ;
                    EXCEPTION
                         WHEN OTHERS THEN
                              l_maternity_sum := null;
                    END;

                      -- Calculate actual days based on 5 day week pattern.
                      p_work_pattern := '5DAY';
                      l_duration := get_weekdays(p_prorate_start, p_prorate_end, p_work_pattern);

                      -- If override element exists for the adoption absence then use the override value.
                      /*IF l_override_ss_days IS NOT NULL THEN
                         l_duration := l_override_ss_days;
                      END IF;*/

			IF l_m_compensation_rate = 100 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_100_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_100;
                             CLOSE GLB_VALUE;

                             IF nvl(l_m_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_100_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
				/*pgopal - Bug 5351991 fix*/
			        /*l_max_parental_days_100 := l_max_parental_days_100 + (l_parental_days_add_child*l_m_no_of_babies_born);*/
				l_max_parental_days_100 := l_max_parental_days_100 + (l_parental_days_add_child * (l_m_no_of_babies_born -1));
			     END IF;
			     l_parental_days_remaining := l_max_parental_days_100 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_m_paternity_days,0) - nvl(l_m_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_maternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
			     IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                             ELSE
                                p_parental_days := l_duration;
                             END IF;


                      ELSIF l_m_compensation_rate = 80 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_80_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_80;
                             CLOSE GLB_VALUE;

			     IF nvl(l_m_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_80_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
				/*pgopal - Bug 5351991 fix*/
			        /*l_max_parental_days_80 := l_max_parental_days_80 + (l_parental_days_add_child*l_m_no_of_babies_born);*/
				l_max_parental_days_80 := l_max_parental_days_80 + (l_parental_days_add_child * (l_m_no_of_babies_born-1));
			     END IF;
			     l_parental_days_remaining := l_max_parental_days_80 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_m_paternity_days,0) - nvl(l_m_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_maternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     /*IF l_duration > ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum));*/
                             IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
			     ELSE
                                p_parental_days := l_duration;
                             END IF;
                      END IF;

                         -- If override element exists for the adoption absence then use the override value.
                         IF l_override_ss_days IS NOT NULL THEN
                            p_parental_days := l_override_ss_days;
                            IF p_parental_days > l_parental_days_remaining THEN
                               l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                            END IF ;
                          END IF;

                    -- Daily Rate calculation
                    -- Calculation of G rate

		  /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
			the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

                    -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    -- l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);

		/* Pgopal - to get the initial absence start date*/
			IF ( l_initial_absence = 'N') THEN
			OPEN  csr_get_intial_abs_st_date(l_initial_abs_attend_id);
			FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
			CLOSE csr_get_intial_abs_st_date;
			ELSE
			l_initial_abs_st_date := p_abs_start_date;
			END IF ;

                        OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date);
                        FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
                        CLOSE csr_intial_abs_pay_stdt;

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id);

		    /* End Bug Fix : 5380121 */

		        -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
                    IF l_gen_hour_sal = 'S' THEN

                        /*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, p_effective_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);*/
		/*pgopal - Bug 5441078 fix - Passing initial absence start date*/
		     l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
				  (p_assignment_id, l_initial_abs_st_date, 'Contractual Earnings',
				  'R', 'D', l_rate, l_error_message, null, null);


                       -- Override social security date was present.
                       IF l_override_ss_rate IS NOT NULL THEN
                          l_social_security_rate := l_override_ss_rate;
                       ELSE
                          l_social_security_rate := l_rate;
                       END IF;

                       -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                       IF l_gen_restrict_ss_sl = 'Y' THEN
                          IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;
                       END IF;

                        -- if restrict daily rate to social security is not set then
                        IF l_gen_restrict_dr_ss = 'N' THEN

                           -- (absence pay base * 12) / 260;
                           l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;

                           -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                           IF l_gen_restrict_empr_sl = 'Y' THEN
                              IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                 l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                              END IF;
                           END IF;

                           -- if restrict daily rate to social security is no then pick whichever is
                           -- less between historic and daily rate.
                           IF l_social_security_rate > l_empr_daily_rate THEN
                              l_reclaim_daily_rate := l_empr_daily_rate;
                           ELSE
                              l_reclaim_daily_rate := l_social_security_rate;
                           END IF;
                        -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                        ELSE
                              l_empr_daily_rate := l_social_security_rate;
                              l_reclaim_daily_rate := l_social_security_rate;

                        END IF;

                   -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
                   ELSIF l_gen_hour_sal = 'H' THEN
       		        p_ear_value := 0;
                         IF p_hourly_paid IN ('W', 'B') THEN


			    -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'Y';
                            -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
                            /* knelli changed absence start date */
			    /* pgopal - Bug 5393827 and 5349713 fix - taking the initial absence start date instead
			    of payroll start date to get the last 4 weeks worked days*/

			    /* BUG Fix 5346832 : Start
				   Changing the start date from (l_initial_abs_st_date - p_abs_min_gap)
				   to greatest(l_dateofjoin,(l_initial_abs_st_date - p_abs_min_gap))
				   for hr_loc_work_schedule.calc_sch_based_dur */

			    /*
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   ((l_initial_abs_st_date) - p_abs_min_gap), (l_initial_abs_st_date-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );
			    */

			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   greatest(l_dateofjoin,((l_initial_abs_pay_stdt) - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );

			    /* BUG Fix 5346832 : End */

                            -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
                            BEGIN
                                SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                                  ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                            WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                                  ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                            WHEN date_end = date_start THEN
                                	  	          1
                                            ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                                  INTO l_abs_worked_days
                                  FROM per_absence_attendances
                                 WHERE person_id = p_person_id
				   AND date_start < (l_initial_abs_pay_stdt-1)
                                   AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                                   AND date_start IS NOT NULL
                                   AND date_end IS NOT NULL ;
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    l_abs_worked_days := 0;
                               WHEN OTHERS THEN
                                    l_abs_worked_days := 0;
                            END;

			    l_duration := l_duration - nvl(l_abs_worked_days, 0);

			    /* knelli added logic */
			    IF l_duration > 0 THEN
                            l_social_security_rate := ( p_4weeks_paybase / l_duration);
			    ELSE
			    l_social_security_rate := 0;
			    END IF;

                            -- Override social security date was present.
                            IF l_override_ss_rate IS NOT NULL THEN
                               l_social_security_rate := l_override_ss_rate;
                            END IF;
                            -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                            IF l_gen_restrict_ss_sl = 'Y' THEN
                               IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                  l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                               END IF;
                            END IF;

                            l_empr_daily_rate := l_social_security_rate;
                            l_reclaim_daily_rate := l_social_security_rate;

                         ELSIF p_hourly_paid = 'M' THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error7';
                          END IF;*/
			  l_msg_error := to_char(7);
                               -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                               -- Previous 4 weeks period logic will not work.
                         END IF;
                   END IF;

                   p_parental_rate     := l_reclaim_daily_rate ;
		   /* knelli added logic */
		   IF l_m_compensation_rate = 80 THEN
		   p_parental_rate := p_parental_rate * 0.8;
		   END IF;

                   p_parental_comprate := l_m_compensation_rate ;
                   -- Reusing the existing siciness output variables for adoption
                   p_rec_total_days := p_parental_days;
                   p_rec_daily_rate := p_parental_comprate;
                   p_ss_daily_rate  := p_parental_rate;


                   l_include_event := 'N';
                   -- Calculating actual sickness days through work schedule
                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                        ( p_assignment_id, l_days_or_hours, l_include_event,
                                          p_prorate_start, p_prorate_end, l_start_time_char,
                                          l_end_time_char, l_duration
                                         );
                      l_actual_cal_days := nvl(l_duration,0);

                   -- Calculate Earnings Adjustment value
                      --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
		      p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * l_actual_cal_days;
                      p_ear_startdt    := p_prorate_start;
                      p_ear_enddt      := p_prorate_end;
                      p_ear_value      := nvl(p_ear_value,0);

			IF l_gen_hour_sal = 'H' THEN
			       p_ear_value := 0;
			END IF;

                        IF l_gen_rate_option = 'DRATE_OPT1' THEN
                           p_rate_option1 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
                           p_rate_option2 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
                           p_rate_option3 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
                           p_rate_option4 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
                           p_rate_option5 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
                           p_rate_option6 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
                           p_rate_option7 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
                           p_rate_option8 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
                           p_rate_option9 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
                           p_rate_option10 := 'Y';
                        ELSE
                           p_rate_option1  := null;
                           p_rate_option2  := null;
                           p_rate_option3  := null;
                           p_rate_option4  := null;
                           p_rate_option5  := null;
                           p_rate_option6  := null;
                           p_rate_option7  := null;
                           p_rate_option8  := null;
                           p_rate_option9  := null;
                           p_rate_option10 := null;
                        END IF;


              p_abs_error := l_msg_error ;

		/* Bug Fix 5349636 : Start */

	       -- If calculated daily rate is less than 50% of G daily rate then no social security period will be paid.
               IF p_parental_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  -- No social security period will be paid.
		   p_rec_total_days := 0;
		   p_rec_daily_rate := 0;
		   p_ss_daily_rate  := 0;
		   p_ear_value      := 0;
                   l_msg_error := to_char(11); /* 50% G Message */
		   p_abs_error := l_msg_error ;
               END IF;

		/* Bug Fix 5349636 : End */

              ELSE -- if reimburse from social security is set to No then no adoption will be paid.
                   -- Reusing the existing siciness output variables for adoption

                   p_rec_total_days := 0;
                   p_rec_daily_rate := 0;
                   p_ss_daily_rate  := 0;
                   p_ear_value      := 0;
                   p_abs_error := l_msg_error ;

               END IF; -- Reimburse from social security
        ELSIF l_abs_category_code = 'PTM' THEN


                 -- Fetch EIT values from absence payment details form
                 -- 9 segments, 13 segments
		 BEGIN
          	    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   --AS l_ptm_expected_dob
          	           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  --AS l_ptm_dob
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  --AS l_ptm_percentage
          	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION4)  --AS l_ptm_compensation_rate
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION5)  --AS l_ptm_paternity_days
        	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION6)  --AS l_ptm_pt_paternity_days
        	           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION7)  --AS l_ptm_no_of_babies_born
        	           ,PAA.ABS_INFORMATION8   --AS l_ptm_reimburse_from_ss
			   ,PAA.ABS_INFORMATION9   --AS l_ptm_use_ss_daily_rate
			   ,PAA.ABS_INFORMATION10  --AS l_ptm_reclaim_pay_max_6g
        	           ,PAA.ABS_INFORMATION11  --AS l_ptm_hol_acc_ent
        	           ,PAA.ABS_INFORMATION12  --AS l_ptm_daily_rate_calc
  			   ,PAA.ABS_INFORMATION15             --AS intial_absence
			   ,PAA.ABS_INFORMATION16             -- AS intial_abs_attend_id
        	      INTO l_ptm_expected_dob
                          ,l_ptm_dob
                          ,l_ptm_percentage
                          ,l_ptm_compensation_rate
			  ,l_ptm_paternity_days
                          ,l_ptm_pt_paternity_days
                          ,l_ptm_no_of_babies_born
			  ,l_ptm_reimburse_from_ss
			  ,l_ptm_use_ss_daily_rate
			  ,l_ptm_reclaim_pay_max_6g
			  ,l_ptm_hol_acc_ent
			  ,l_ptm_daily_rate_calc
			   ,l_initial_absence
		           ,l_initial_abs_attend_id
        	      FROM PER_ABSENCE_ATTENDANCES PAA
        	      WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

                 EXCEPTION
        	        WHEN OTHERS THEN

                         l_ptm_expected_dob        := null;
                         l_ptm_dob	           := null;
                         l_ptm_percentage	   := null;
                         l_ptm_compensation_rate   := null;
                         l_ptm_pt_paternity_days   := null;
                         l_ptm_no_of_babies_born   := null;
			 l_ptm_use_ss_daily_rate   := null;
			 l_ptm_daily_rate_calc	   := null;
			 l_ptm_hol_acc_ent	   := null;
		         l_initial_absence          :=NULL;
		         l_initial_abs_attend_id    := NULL ;
                 END;
               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);
	       /*pgopal - Bug 5380057 fix*/
               l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_ptm_reclaim_pay_max_6g, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');

               -- If reimburse from social security is set then adoption leave will be paid.
               IF l_gen_reimb_ss = 'Y' THEN

                   -- Calling override to get override days and daily rate
                   l_over_return := get_override_details
                                    ( p_assignment_id,p_effective_date,p_abs_start_date,
                                      p_abs_end_date, p_abs_categorycode, l_override_start_date,
                                      l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                                      l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                                     );
                    /* Multiple override element attached against one absence element. ie)  *
                     * One or more override entry exists with same start and end date       */
                    IF (l_over_return = -1) THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;*/
			  l_msg_error := to_char(5);
                          p_abs_error := l_msg_error;
                          RETURN 1;
                    END IF;
                    IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
                       l_msg_error := to_char(13);
                    END IF;
                    IF nvl(l_override_empr_days,0) > 0 THEN
                       l_msg_error := to_char(14);
                       p_abs_error := l_msg_error;
                       RETURN 1;
                    END IF;

                   p_work_pattern := '5DAY';
                   -- To find out number of days adoption leave has been taken in the current payroll period
                   BEGIN
                        SELECT SUM(DECODE(paa.date_start, paa.date_end, 1,
                                          get_weekdays(greatest(p_pay_start_date, paa.date_start), paa.date_end, p_work_pattern) )) AS days_diff
                          INTO l_pt_maternity_sum
                          FROM per_absence_attendances paa, per_absence_attendance_types pat
                         WHERE paa.person_id = p_person_id
                           AND paa.date_end BETWEEN p_pay_start_date AND p_pay_end_date
                           AND paa.date_end < p_abs_start_date
                           AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
                           AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
                           AND pat.absence_category = 'M'
                         ORDER BY paa.date_end DESC ;
                    EXCEPTION
                         WHEN OTHERS THEN
                              l_pt_maternity_sum := null;
                    END;




                      -- Calculate actual days based on 5 day week pattern.
                      p_work_pattern := '5DAY';
                      l_duration := get_weekdays(p_prorate_start, p_prorate_end, p_work_pattern);

                      -- If override element exists for the adoption absence then use the override value.
                      /*IF l_override_ss_days IS NOT NULL THEN
                         l_duration := l_override_ss_days;
                      END IF;*/

                      IF l_ptm_compensation_rate = 100 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_100_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_100;
                             CLOSE GLB_VALUE;

                             IF nvl(l_ptm_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_100_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
			        l_max_parental_days_100 := l_max_parental_days_100 + (l_parental_days_add_child*l_ptm_no_of_babies_born);
			     END IF;

			     l_parental_days_remaining := l_max_parental_days_100 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_ptm_paternity_days,0) - nvl(l_ptm_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_pt_maternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     IF nvl(l_ptm_percentage,0) > 0 THEN
				l_parental_days_remaining := trunc(l_parental_days_remaining * 100/(100-l_ptm_percentage));

			     END IF;
			     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
			     IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                             ELSE
                                p_parental_days := l_duration;
                             END IF;


                      ELSIF l_ptm_compensation_rate = 80 THEN
                             -- To fetch parental days limit based on the compensation rate chosen.

			     OPEN GLB_VALUE ('NO_80_MAX_PARENTAL_BENEFIT_DAYS', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_max_parental_days_80;
                             CLOSE GLB_VALUE;

			     IF nvl(l_ptm_no_of_babies_born,1) > 1 THEN
				OPEN GLB_VALUE ('NO_80_MAX_MAT_DAYS_PER_ADDITIONAL_CHILD', p_abs_start_date );
                                FETCH GLB_VALUE INTO l_parental_days_add_child;
                                CLOSE GLB_VALUE;
			        l_max_parental_days_80 := l_max_parental_days_80 + (l_parental_days_add_child*l_ptm_no_of_babies_born);
			     END IF;

			     l_parental_days_remaining := l_max_parental_days_80 - nvl(p_parental_bal_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_ptm_paternity_days,0) - nvl(l_ptm_pt_paternity_days,0);
			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_pt_maternity_sum,0);

			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     IF nvl(l_ptm_percentage,0) > 0 THEN
				l_parental_days_remaining := trunc(l_parental_days_remaining * 100/(100-l_ptm_percentage));

			     END IF;
			     /*IF l_duration > ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum)) THEN
                                p_parental_days := ( l_max_parental_days_80 - ( p_parental_bal_days + l_maternity_sum));*/
                             IF l_duration > l_parental_days_remaining THEN
				p_parental_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
			     ELSE
                                p_parental_days := l_duration;
                             END IF;

                      END IF;
		      --p_parental_days := p_parental_days * trunc((l_ptm_percentage/100),2);
                      p_parental_days := round(p_parental_days * (l_ptm_percentage/100),2);
                         -- If override element exists for the adoption absence then use the override value.
                         IF l_override_ss_days IS NOT NULL THEN
                            p_parental_days := l_override_ss_days;
                            IF p_parental_days > l_parental_days_remaining THEN
                               l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                            END IF ;
                          END IF;


                    -- Daily Rate calculation
                    -- Calculation of G rate

		    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
			the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

                    -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    -- l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);

		    /* End Bug Fix : 5380121 */
		/* Pgopal - to get the initial absence start date*/
			IF ( l_initial_absence = 'N') THEN
			OPEN  csr_get_intial_abs_st_date(l_initial_abs_attend_id);
			FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
			CLOSE csr_get_intial_abs_st_date;
			ELSE
			l_initial_abs_st_date := p_abs_start_date;
			END IF ;

                        OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date);
                        FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
                        CLOSE csr_intial_abs_pay_stdt;

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id);

                    -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
                    IF l_gen_hour_sal = 'S' THEN

                        /*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, p_effective_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);*/
		/*pgopal - Bug 5441078 fix - Passing initial absence start date*/
                        l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, l_initial_abs_st_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);


                       -- Override social security date was present.
                       IF l_override_ss_rate IS NOT NULL THEN
                          l_social_security_rate := l_override_ss_rate;
                       ELSE
                          l_social_security_rate := l_rate;
                       END IF;

                       -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                       IF l_gen_restrict_ss_sl = 'Y' THEN
                          IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;
                       END IF;

                        -- if restrict daily rate to social security is not set then
                        IF l_gen_restrict_dr_ss = 'N' THEN

                           -- (absence pay base * 12) / 260;
                           l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;

                           -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                           IF l_gen_restrict_empr_sl = 'Y' THEN
                              IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                 l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                              END IF;
                           END IF;

                           -- if restrict daily rate to social security is no then pick whichever is
                           -- less between historic and daily rate.
                           IF l_social_security_rate > l_empr_daily_rate THEN
                              l_reclaim_daily_rate := l_empr_daily_rate;
                           ELSE
                              l_reclaim_daily_rate := l_social_security_rate;
                           END IF;
                        -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                        ELSE
                              l_empr_daily_rate := l_social_security_rate;
                              l_reclaim_daily_rate := l_social_security_rate;


                        END IF;

                   -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
                   ELSIF l_gen_hour_sal = 'H' THEN
       		        p_ear_value := 0;
                         IF p_hourly_paid IN ('W', 'B') THEN


                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'Y';
                            -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
                            /* pdavidra - bug 5330066 - redused the start date parameter by 1*/
			    /* pgopal - Bug 5393827 and 5349713 fix - taking the initial absence start date instead
			    of payroll start date to get the last 4 weeks worked days*/

			    /* BUG Fix 5346832 : Start
				   Changing the start date from (l_initial_abs_st_date - p_abs_min_gap)
				   to greatest(l_dateofjoin,(l_initial_abs_st_date - p_abs_min_gap))
				   for hr_loc_work_schedule.calc_sch_based_dur */

			   /*
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   (l_initial_abs_st_date - p_abs_min_gap), (l_initial_abs_st_date-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );
			   */

			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   greatest(l_dateofjoin,(l_initial_abs_pay_stdt - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );

			    /* BUG Fix 5346832 : End */

                            -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
                            BEGIN
                                SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                                  ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                            WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                                  ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                            WHEN date_end = date_start THEN
                                	  	          1
                                             ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                                  INTO l_abs_worked_days
                                  FROM per_absence_attendances
                                 WHERE person_id = p_person_id
				   AND date_start < (l_initial_abs_pay_stdt-1)
                                   AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                                   AND date_start IS NOT NULL
                                   AND date_end IS NOT NULL ;
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    l_abs_worked_days := 0;
                               WHEN OTHERS THEN
                                    l_abs_worked_days := 0;
                            END;

                            l_duration := l_duration - nvl(l_abs_worked_days, 0);

			    /* BUG Fix 5346832 : Start */

			    IF (l_duration > 0) THEN
				l_social_security_rate := ( p_4weeks_paybase / l_duration);
			    ELSE
				l_social_security_rate := 0 ;
                            END IF;

			    /* BUG Fix 5346832 : End */


			    -- Override social security date was present.
                            IF l_override_ss_rate IS NOT NULL THEN
                               l_social_security_rate := l_override_ss_rate;
                            END IF;
                            -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                            IF l_gen_restrict_ss_sl = 'Y' THEN
                               IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                  l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                               END IF;
                            END IF;

                            l_empr_daily_rate := l_social_security_rate;
                            l_reclaim_daily_rate := l_social_security_rate;
                         ELSIF p_hourly_paid = 'M' THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error7';
                          END IF;*/
			  l_msg_error := to_char(7);
                               -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                               -- Previous 4 weeks period logic will not work.
                         END IF;
                   END IF;

                   p_parental_rate     := l_reclaim_daily_rate ;
		   /* knelli added logic */
		   /*IF l_m_compensation_rate = 80 THEN*/
		   /*pgopal Bug 5355910 fix*/
		   IF l_ptm_compensation_rate = 80 THEN
		   p_parental_rate := p_parental_rate * 0.8;
		   END IF;
                   p_parental_comprate := l_ptm_compensation_rate ;
                   -- Reusing the existing siciness output variables for adoption
                   p_rec_total_days := p_parental_days;
                   p_rec_daily_rate := p_parental_comprate;
                   p_ss_daily_rate  := p_parental_rate;


                   l_include_event := 'N';
                   -- Calculating actual sickness days through work schedule
                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                        ( p_assignment_id, l_days_or_hours, l_include_event,
                                          p_prorate_start, p_prorate_end, l_start_time_char,
                                          l_end_time_char, l_duration
                                         );
                      l_actual_cal_days := nvl(l_duration,0);
                   -- Calculate Earnings Adjustment value
                      --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
		      p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * p_parental_days;
                      p_ear_startdt    := p_prorate_start;
                      p_ear_enddt      := p_prorate_end;
                      p_ear_value      := nvl(p_ear_value,0);

			IF l_gen_hour_sal = 'H' THEN
			       p_ear_value := 0;
			END IF;

                        IF l_gen_rate_option = 'DRATE_OPT1' THEN
                           p_rate_option1 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
                           p_rate_option2 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
                           p_rate_option3 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
                           p_rate_option4 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
                           p_rate_option5 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
                           p_rate_option6 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
                           p_rate_option7 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
                           p_rate_option8 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
                           p_rate_option9 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
                           p_rate_option10 := 'Y';
                        ELSE
                           p_rate_option1  := null;
                           p_rate_option2  := null;
                           p_rate_option3  := null;
                           p_rate_option4  := null;
                           p_rate_option5  := null;
                           p_rate_option6  := null;
                           p_rate_option7  := null;
                           p_rate_option8  := null;
                           p_rate_option9  := null;
                           p_rate_option10 := null;
                        END IF;
              p_abs_error := l_msg_error ;

		/* Bug Fix 5349636 : Start */

	       -- If calculated daily rate is less than 50% of G daily rate then no social security period will be paid.
               IF p_parental_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  -- No social security period will be paid.
		   p_rec_total_days := 0;
		   p_rec_daily_rate := 0;
		   p_ss_daily_rate  := 0;
		   p_ear_value      := 0;
                   l_msg_error := to_char(11); /* 50% G Message */
		   p_abs_error := l_msg_error ;
               END IF;

		/* Bug Fix 5349636 : End */

              ELSE -- if reimburse from social security is set to No then no adoption will be paid.
                   -- Reusing the existing siciness output variables for adoption

                   p_rec_total_days := 0;
                   p_rec_daily_rate := 0;
                   p_ss_daily_rate  := 0;
                   p_ear_value      := 0;
                   p_abs_error := l_msg_error ;

               END IF; -- Reimburse from social security

/***************************************************************************
    ADOPTION ABSENCE CATEGORY
****************************************************************************/

        ELSIF l_abs_category_code = 'IE_AL' THEN
                 -- Fetch EIT values from absence payment details form

		 BEGIN
          		/* Bug Fix 5380091 : Start */

			    -- Commenting the cursor for changes in the segments

			/*
			    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   AS Dateofadoption
          		           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  AS Dateofbirth
          		           ,to_number(PAA.ABS_INFORMATION3)  AS Comprate
          		           ,PAA.ABS_INFORMATION4  AS Use_ss_rate
        		           ,PAA.ABS_INFORMATION5  AS Daily_rate_option
        		           ,PAA.ABS_INFORMATION6  AS dummy
        		      INTO l_adopt_doa
                           ,l_adopt_dob
                           ,l_adopt_comprate
                           ,l_abs_restrict_dr_ss
                           ,l_abs_daily_rate
                           ,l_dummy
        		      FROM PER_ABSENCE_ATTENDANCES PAA
        	         WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

                 EXCEPTION
        	        WHEN OTHERS THEN

                         l_adopt_doa            := null;
                         l_adopt_dob            := null;
                         l_adopt_comprate       := null;
                         l_restrict_dr_ss       := null;
                         l_abs_daily_rate       := null;
                 END;

		*/

			-- rewriting cursor for changed segments
		             SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   AS Dateofadoption
          		           ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  AS Dateofbirth
          		           ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  AS Comprate
          		           ,PAA.ABS_INFORMATION4  AS reimb_ss
        		           ,PAA.ABS_INFORMATION5  AS Use_ss_rate
        		           ,PAA.ABS_INFORMATION6  AS restrict_ss_sl
				   ,PAA.ABS_INFORMATION7  AS dummy
			           ,PAA.ABS_INFORMATION8  AS Daily_rate_option
				   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION9)  AS NumOfChildren
	     			   ,PAA.ABS_INFORMATION15 AS intial_absence
				   ,PAA.ABS_INFORMATION16 AS intial_abs_attend_id
			       INTO l_adopt_doa
				   ,l_adopt_dob
				   ,l_adopt_comprate
				   ,l_abs_reimb_ss
				   ,l_abs_restrict_dr_ss
				   ,l_abs_restrict_ss_sl
				   ,l_dummy
				   ,l_abs_daily_rate
				   ,l_no_of_children
				   ,l_initial_absence
				   ,l_initial_abs_attend_id
        		       FROM PER_ABSENCE_ATTENDANCES PAA
        	               WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

		EXCEPTION
        	        WHEN OTHERS THEN

                         l_adopt_doa            := null;
                         l_adopt_dob            := null;
                         l_adopt_comprate       := null;
			 l_abs_reimb_ss		:= null;
                         l_abs_restrict_dr_ss	:= null;
			 l_abs_restrict_ss_sl	:= null;
			 l_dummy		:= null;
			 --l_restrict_dr_ss     := null;
                         l_abs_daily_rate       := null;
		         l_no_of_children	:= null;
		         l_initial_absence        :=NULL;
		         l_initial_abs_attend_id  := NULL ;

                 END;

		/* Bug Fix 5380091 : End */

               l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
               l_gen_reimb_ss          := nvl(nvl(nvl(l_abs_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
               l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_abs_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
               l_gen_rate_option       := nvl(nvl(l_abs_daily_rate, l_per_daily_rate), l_le_daily_rate);

	       /* Start Bug Fix : 5282895 */

               l_adopt_comprate := nvl(l_adopt_comprate,100) ;

               /* End Bug Fix : 5282895 */


		/* Bug Fix 5380091 : Start -- Defaulting value for l_gen_restrict_ss_sl (Reclaimable Pay Maximum 6G). */

		l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_abs_restrict_ss_sl, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');
		l_gen_no_of_children    := nvl(l_no_of_children , 1 ) ;

		/* Bug Fix 5380091 : End */

               -- If reimburse from social security is set then adoption leave will be paid.
               IF l_gen_reimb_ss = 'Y' THEN
                   -- Calling override to get override days and daily rate
                   l_over_return := get_override_details
                                    ( p_assignment_id,p_effective_date,p_abs_start_date,
                                      p_abs_end_date, p_abs_categorycode, l_override_start_date,
                                      l_override_end_date,l_override_empr_rate, l_override_ss_rate,
                                      l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
                                     );
                    /* Multiple override element attached against one absence element. ie)  *
                     * One or more override entry exists with same start and end date       */
                    IF (l_over_return = -1) THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error5';
                          END IF;*/
			  l_msg_error := to_char(5);
                          p_abs_error := l_msg_error;
                          RETURN 1;
                    END IF;
                    IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
                       l_msg_error := to_char(13);
                    END IF;
                    IF nvl(l_override_empr_days,0) > 0 THEN
                       l_msg_error := to_char(14);
                       p_abs_error := l_msg_error;
                       RETURN 1;
                    END IF;
                   p_work_pattern := '5DAY';
                   -- To find out number of days adoption leave has been taken in the current payroll period
                   BEGIN
                        SELECT SUM(DECODE(paa.date_start, paa.date_end, 1,
                                          get_weekdays(greatest(p_pay_start_date, paa.date_start), paa.date_end, p_work_pattern) )) AS days_diff
                          INTO l_adopt_sum
                          FROM per_absence_attendances paa, per_absence_attendance_types pat
                         WHERE paa.person_id = p_person_id
                           AND paa.date_end BETWEEN p_pay_start_date AND p_pay_end_date
                           AND paa.date_end < p_abs_start_date
                           AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
                           AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
                           AND pat.absence_category = 'IE_AL'
                         ORDER BY paa.date_end DESC ;
                    EXCEPTION
                         WHEN OTHERS THEN
                              l_adopt_sum := null;
                    END;



                      -- Calculate actual days based on 5 day week pattern.
                      p_work_pattern := '5DAY';
                      l_duration := get_weekdays(p_prorate_start, p_prorate_end, p_work_pattern);
		      -- If override element exists for the adoption absence then use the override value.
                      /*IF l_override_ss_days IS NOT NULL THEN
                         l_duration := l_override_ss_days;
                      END IF;*/

                      IF l_adopt_comprate = 80 THEN
                             -- To fetch adoption maximum limit based on the compensation rate chosen.
                             OPEN GLB_VALUE ('NO_ADOPTION_EIGHTY', p_abs_start_date );
                             FETCH GLB_VALUE INTO l_adopt_glb_80;
                             CLOSE GLB_VALUE;

                             /* Bug Fix 5346832 : Start */

                             -- To fetch adoption days for each additional child based on the compensation rate chosen.
                             OPEN GLB_VALUE ('NO_ADOPTION_EIGHTY_ADDITIONAL_CHILD', p_abs_start_date);
                             FETCH GLB_VALUE INTO l_adopt_glb_80_add_child;
                             CLOSE GLB_VALUE;

			     /* knelli commented
			     IF l_duration > ( l_adopt_glb_80 - ( p_adopt_bal_days + l_adopt_sum)) THEN
                                p_adopt_days := ( l_adopt_glb_80 - ( p_adopt_bal_days + l_adopt_sum));
                             ELSE
                                p_adopt_days := l_duration;
                             END IF;*/
			     /* knelli added code */

			     -- l_parental_days_remaining := l_adopt_glb_80 - nvl(p_adopt_bal_days,0);

			     l_parental_days_remaining := l_adopt_glb_80 + (l_adopt_glb_80_add_child * (l_gen_no_of_children - 1)) - nvl(p_adopt_bal_days,0);
			     /* Bug Fix 5346832 : End */

			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_adopt_sum,0);
			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
				p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
			     IF l_duration > l_parental_days_remaining THEN
				p_adopt_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
			     ELSE
				p_adopt_days := l_duration;
			     END IF;

                      ELSIF l_adopt_comprate = 100 THEN
                             -- To fetch adoption maximum limit based on the compensation rate chosen.
                             OPEN GLB_VALUE ('NO_ADOPTION_HUNDRED', p_abs_start_date);
                             FETCH GLB_VALUE INTO l_adopt_glb_100;
                             CLOSE GLB_VALUE;

                             /* Bug Fix 5346832 : Start */

			     -- To fetch adoption days for each additional child based on the compensation rate chosen.
                             OPEN GLB_VALUE ('NO_ADOPTION_HUNDRED_ADDITIONAL_CHILD', p_abs_start_date);
                             FETCH GLB_VALUE INTO l_adopt_glb_100_add_child;
                             CLOSE GLB_VALUE;

			     /* knelli commented code
			     IF l_duration > ( l_adopt_glb_100 - ( p_adopt_bal_days + l_adopt_sum)) THEN
                                p_adopt_days := ( l_adopt_glb_100 - ( p_adopt_bal_days + l_adopt_sum));
                             ELSE
                                p_adopt_days := l_duration;
                             END IF;*/
			     /* knelli added code */

			     -- l_parental_days_remaining := l_adopt_glb_100 - nvl(p_adopt_bal_days,0);

			     l_parental_days_remaining := l_adopt_glb_100 + (l_adopt_glb_100_add_child * (l_gen_no_of_children - 1)) - nvl(p_adopt_bal_days,0);
			     /* Bug Fix 5346832 : End */

			     l_parental_days_remaining := l_parental_days_remaining - nvl(l_adopt_sum,0);
			     IF l_parental_days_remaining < 0 THEN
			     l_parental_days_remaining := 0;
			     END IF;

			     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
				p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
			     IF l_duration > l_parental_days_remaining THEN
				p_adopt_days := l_parental_days_remaining;
                                l_msg_error := to_char(12); /* Legislative limit exhausted Message */
			     ELSE
				p_adopt_days := l_duration;
			     END IF;

                      END IF;
                         -- If override element exists for the adoption absence then use the override value.
                         IF l_override_ss_days IS NOT NULL THEN
                            p_adopt_days := l_override_ss_days;
                            IF p_adopt_days > l_parental_days_remaining THEN
                               l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                            END IF ;
                          END IF;
                    -- Daily Rate calculation
                    -- Calculation of G rate

		    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
			the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

                    -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		    -- l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);

		    /* End Bug Fix : 5380121 */
			/* pgopal - to get the initial absence start date*/
			IF ( l_initial_absence = 'N') THEN
			OPEN  csr_get_intial_abs_st_date(l_initial_abs_attend_id);
			FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
			CLOSE csr_get_intial_abs_st_date;
			ELSE
			l_initial_abs_st_date := p_abs_start_date;
			END IF ;

                        OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date);
                        FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
                        CLOSE csr_intial_abs_pay_stdt;

		    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
		     l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id);


                    -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
                    IF l_gen_hour_sal = 'S' THEN

			/*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, p_effective_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);*/
		       /*pgopal - Bug 5441078 fix - Passing initial absence start date*/
			l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
                                    (p_assignment_id, l_initial_abs_st_date, 'Contractual Earnings',
                                     'R', 'D', l_rate, l_error_message, null, null);

                       -- Override social security date was present.
                       IF l_override_ss_rate IS NOT NULL THEN
                          l_social_security_rate := l_override_ss_rate;
                       ELSE
                          l_social_security_rate := l_rate;
                       END IF;

                       -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                       IF l_gen_restrict_ss_sl = 'Y' THEN
		          IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                             l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                          END IF;

                       END IF;
                        -- if restrict daily rate to social security is not set then
                        IF l_gen_restrict_dr_ss = 'N' THEN

                           -- (absence pay base * 12) / 260;
                           l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;
                           -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
                           IF l_gen_restrict_empr_sl = 'Y' THEN
                              IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                 l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                              END IF;
                           END IF;

                           -- if restrict daily rate to social security is no then pick whichever is
                           -- less between historic and daily rate.
                           IF l_social_security_rate > l_empr_daily_rate THEN
                              l_reclaim_daily_rate := l_empr_daily_rate;
                           ELSE
                              l_reclaim_daily_rate := l_social_security_rate;
                           END IF;
                        -- if restrict daily rate to social security is set then both ss and empr rate will be same.
                        ELSE
                              l_empr_daily_rate := l_social_security_rate;
                              l_reclaim_daily_rate := l_social_security_rate;

                        END IF;

                   -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
                   ELSIF l_gen_hour_sal = 'H' THEN
                         p_ear_value := 0;
			 IF p_hourly_paid IN ('W', 'B') THEN


                            -- Ignore public holidays if the one present in between absence start and end dates.
                            l_include_event := 'Y';
                            -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
                            /* pdavidra - bug 5330066 - redused the start date parameter by 1*/
			    /* pgopal - Bug 5393827 and 5349713 fix - taking the initial absence start date instead
			    of payroll start date to get the last 4 weeks worked days*/

			    /* BUG Fix 5346832 : Start
				   Changing the start date from (l_initial_abs_st_date - p_abs_min_gap)
				   to greatest(l_dateofjoin,(l_initial_abs_st_date - p_abs_min_gap))
				   for hr_loc_work_schedule.calc_sch_based_dur */

			   /*
			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   (l_initial_abs_st_date - p_abs_min_gap), (l_initial_abs_st_date-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );
			   */

			    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                                 ( p_assignment_id, l_days_or_hours, l_include_event,
                                                   greatest(l_dateofjoin,(l_initial_abs_pay_stdt - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
                                                   l_end_time_char, l_duration
                                                   );

			    /* BUG Fix 5346832 : End */

                            -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
                            BEGIN
                                SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
                                                  ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
                                            WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
                                                  ( (l_initial_abs_pay_stdt-1) - date_start )+1
                                            WHEN date_end = date_start THEN
                                	  	          1
                                            ELSE  (date_end - date_start) + 1 END ) AS Days_diff
                                  INTO l_abs_worked_days
                                  FROM per_absence_attendances
                                 WHERE person_id = p_person_id
				   AND date_start < (l_initial_abs_pay_stdt-1)
                                   AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
                                   AND date_start IS NOT NULL
                                   AND date_end IS NOT NULL ;
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    l_abs_worked_days := 0;
                               WHEN OTHERS THEN
                                    l_abs_worked_days := 0;
                            END;
                            l_duration := l_duration - nvl(l_abs_worked_days, 0);


			    /* BUG Fix 5346832 : Start */

			    IF (l_duration > 0) THEN
				l_social_security_rate := ( p_4weeks_paybase / l_duration);
			    ELSE
				l_social_security_rate := 0 ;
			    END IF;

			   /* BUG Fix 5346832 : End */


			    -- Override social security date was present.
                            IF l_override_ss_rate IS NOT NULL THEN
                               l_social_security_rate := l_override_ss_rate;
                            END IF;
                            -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
                            IF l_gen_restrict_ss_sl = 'Y' THEN
                               IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
                                  l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
                               END IF;
                            END IF;

                            l_empr_daily_rate := l_social_security_rate;
                            l_reclaim_daily_rate := l_social_security_rate;

                         ELSIF p_hourly_paid = 'M' THEN
                          /* knelli
			  IF length(l_msg_error) > 1 THEN
                             l_msg_error := 'Error7';
                          END IF;*/
			  l_msg_error := to_char(7);
                               -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
                               -- Previous 4 weeks period logic will not work.
                         END IF;
                   END IF;

		   p_adopt_rate     := l_reclaim_daily_rate ;
		   /* knelli added logic for bug fix 5284260 */
		   IF l_adopt_comprate = 80 THEN
		   p_adopt_rate := p_adopt_rate * 0.8;
		   END IF;
                   p_adopt_comprate := l_adopt_comprate ;
                   -- Reusing the existing siciness output variables for adoption
                   p_rec_total_days := p_adopt_days;
                   p_rec_daily_rate := p_adopt_comprate;
                   p_ss_daily_rate  := p_adopt_rate;

		   l_include_event := 'N';
                   -- Calculating actual sickness days through work schedule
                   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
                                        ( p_assignment_id, l_days_or_hours, l_include_event,
                                          p_prorate_start, p_prorate_end, l_start_time_char,
                                          l_end_time_char, l_duration
                                         );
                      l_actual_cal_days := nvl(l_duration,0);
                   -- Calculate Earnings Adjustment value
                      --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
		      p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * l_actual_cal_days;
                      p_ear_startdt    := p_prorate_start;
                      p_ear_enddt      := p_prorate_end;
                      p_ear_value      := nvl(p_ear_value,0);

			IF l_gen_hour_sal = 'H' THEN
			       p_ear_value := 0;
			END IF;

                        IF l_gen_rate_option = 'DRATE_OPT1' THEN
                           p_rate_option1 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
                           p_rate_option2 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
                           p_rate_option3 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
                           p_rate_option4 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
                           p_rate_option5 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
                           p_rate_option6 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
                           p_rate_option7 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
                           p_rate_option8 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
                           p_rate_option9 := 'Y';
                        ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
                           p_rate_option10 := 'Y';
                        ELSE
                           p_rate_option1  := null;
                           p_rate_option2  := null;
                           p_rate_option3  := null;
                           p_rate_option4  := null;
                           p_rate_option5  := null;
                           p_rate_option6  := null;
                           p_rate_option7  := null;
                           p_rate_option8  := null;
                           p_rate_option9  := null;
                           p_rate_option10 := null;
                        END IF;
              p_abs_error := l_msg_error ;

		/* Bug Fix 5349636 : Start */

	       -- If calculated daily rate is less than 50% of G daily rate then no social security period will be paid.
               IF p_adopt_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
                  -- No social security period will be paid.
		   p_rec_total_days := 0;
		   p_rec_daily_rate := 0;
		   p_ss_daily_rate  := 0;
		   p_ear_value      := 0;
                   l_msg_error := to_char(11); /* 50% G Message */
		   p_abs_error := l_msg_error ;
               END IF;

		/* Bug Fix 5349636 : End */

	      ELSE -- if reimburse from social security is set to No then no adoption will be paid.
                   -- Reusing the existing siciness output variables for adoption
                   p_rec_total_days := 0;
                   p_rec_daily_rate := 0;
                   p_ss_daily_rate  := 0;
                   p_ear_value      := 0;
                   p_abs_error := l_msg_error ;
               END IF; -- Reimburse from social security

	ELSIF l_abs_category_code = 'PTA' THEN
	 -- Fetch EIT values from absence payment details form

	 BEGIN
		    /* Bug Fix 5346832 : Start */
		    /*
		    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   AS Dateofadoption
			   ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  AS Dateofbirth
			   ,to_number(PAA.ABS_INFORMATION3)  AS PartTimePercent
			   ,to_number(PAA.ABS_INFORMATION4)  AS Comprate
			   ,PAA.ABS_INFORMATION5  AS reimurse_ss--Use_ss_rate
			   ,PAA.ABS_INFORMATION6  AS use_ss_rate
			   ,PAA.ABS_INFORMATION7  AS reclaim_6g
			   ,PAA.ABS_INFORMATION9  AS dailtrate
		      INTO l_adopt_doa
		   ,l_adopt_dob
		   ,l_adopt_ptp
		   ,l_adopt_comprate
		   ,l_adopt_reimb_ss
		   ,l_adopt_restrict_dr_ss
		   ,l_adopt_restrict_empr_sl
		   ,l_adopt_daily_rate
		      FROM PER_ABSENCE_ATTENDANCES PAA
		 WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

	 EXCEPTION
		WHEN OTHERS THEN

		 l_adopt_doa := NULL;
		 l_adopt_dob := NULL;
		 l_adopt_ptp := NULL;
		 l_adopt_comprate := NULL;
		 l_adopt_reimb_ss := NULL;
		 l_adopt_restrict_dr_ss := NULL;
		 l_adopt_restrict_empr_sl := NULL;
		 l_adopt_daily_rate := NULL;
	 END;
	 */

		    SELECT to_date(PAA.ABS_INFORMATION1,'yyyy/mm/dd hh24:mi:ss')   AS Dateofadoption
			   ,to_date(PAA.ABS_INFORMATION2,'yyyy/mm/dd hh24:mi:ss')  AS Dateofbirth
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION3)  AS PartTimePercent
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION4)  AS Comprate
			   ,PAA.ABS_INFORMATION5  AS reimurse_ss--Use_ss_rate
			   ,PAA.ABS_INFORMATION6  AS use_ss_rate
			   ,PAA.ABS_INFORMATION7  AS reclaim_6g
			   ,PAA.ABS_INFORMATION9  AS dailtrate
			   ,fnd_number.canonical_to_number(PAA.ABS_INFORMATION10)  AS NumOfChildren
  			   ,PAA.ABS_INFORMATION15    AS intial_absence
			   ,PAA.ABS_INFORMATION16    AS intial_abs_attend_id
		      INTO l_adopt_doa
		   ,l_adopt_dob
		   ,l_adopt_ptp
		   ,l_adopt_comprate
		   ,l_adopt_reimb_ss
		   ,l_adopt_restrict_dr_ss
		   ,l_adopt_restrict_empr_sl
		   ,l_adopt_daily_rate
		   ,l_no_of_children
		   ,l_initial_absence
		   ,l_initial_abs_attend_id
		      FROM PER_ABSENCE_ATTENDANCES PAA
		 WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

	 EXCEPTION
		WHEN OTHERS THEN

		 l_adopt_doa := NULL;
		 l_adopt_dob := NULL;
		 l_adopt_ptp := NULL;
		 l_adopt_comprate := NULL;
		 l_adopt_reimb_ss := NULL;
		 l_adopt_restrict_dr_ss := NULL;
		 l_adopt_restrict_empr_sl := NULL;
		 l_adopt_daily_rate := NULL;
		 l_no_of_children  := null;
		 l_initial_absence        :=NULL;
		 l_initial_abs_attend_id  := NULL ;
	END;

	/* Bug Fix 5346832 : End */

	 /* knelli check for l_adopt_restrict_empr_sl */
       l_gen_hour_sal          := nvl(nvl(nvl(l_asg_hour_sal,l_hourly_salaried), l_le_hour_sal), 'S');
       l_gen_reimb_ss          := nvl(nvl(nvl(l_adopt_reimb_ss, l_reimb_ss), l_le_reimb_ss), 'N');
       l_gen_restrict_dr_ss    := nvl(nvl(nvl(l_adopt_restrict_dr_ss, l_restrict_dr_ss), l_le_restrict_dr_ss), 'Y');
       l_gen_rate_option       := nvl(nvl(l_adopt_daily_rate, l_per_daily_rate), l_le_daily_rate);

        /* Start Bug Fix : 5282895 */

	l_adopt_comprate := nvl(l_adopt_comprate,100) ;

	/* End Bug Fix : 5282895 */

	/* Bug Fix 5380091 : Start -- Defaulting value for l_gen_restrict_ss_sl (Reclaimable Pay Maximum 6G). */

	l_gen_restrict_ss_sl    := nvl(nvl(nvl(l_adopt_restrict_empr_sl, l_restrict_ss_sl), l_le_restrict_ss_sl), 'Y');

	/* Bug Fix 5380091 : End */

	/* Bug Fix 5346832 : Start */
	l_gen_no_of_children    := nvl(l_no_of_children , 1 ) ;
	/* Bug Fix 5346832 : End */


       -- If reimburse from social security is set then adoption leave will be paid.
       IF l_gen_reimb_ss = 'Y' THEN
	   -- Calling override to get override days and daily rate
	   l_over_return := get_override_details
			    ( p_assignment_id,p_effective_date,p_abs_start_date,
			      p_abs_end_date, p_abs_categorycode, l_override_start_date,
			      l_override_end_date,l_override_empr_rate, l_override_ss_rate,
			      l_override_reclaim_rate, l_override_empr_days, l_override_ss_days
			     );
	    /* Multiple override element attached against one absence element. ie)  *
	     * One or more override entry exists with same start and end date       */
	    IF (l_over_return = -1) THEN
		  /* knelli
		  IF length(l_msg_error) > 1 THEN
		     l_msg_error := 'Error5';
		  END IF;*/
		  l_msg_error := to_char(5);
                  p_abs_error := l_msg_error;
                  RETURN 1;
	    END IF;
            IF (nvl(l_override_empr_days,0) + nvl(l_override_ss_days,0)) > (p_prorate_end - p_prorate_start + 1) THEN
               l_msg_error := to_char(13);
            END IF;
            IF nvl(l_override_empr_days,0) > 0 THEN
               l_msg_error := to_char(14);
               p_abs_error := l_msg_error;
               RETURN 1;
            END IF;
	   -- To find out number of days adoption leave has been taken in the current payroll period
	   BEGIN
		SELECT SUM(DECODE(paa.date_start, paa.date_end, 1,
				  get_weekdays(greatest(p_pay_start_date, paa.date_start), paa.date_end, p_work_pattern) )) AS days_diff
		  INTO l_adopt_sum
		  FROM per_absence_attendances paa, per_absence_attendance_types pat
		 WHERE paa.person_id = p_person_id
		   AND paa.date_end BETWEEN p_pay_start_date AND p_pay_end_date
		   AND paa.date_end < p_abs_start_date
		   AND paa.date_start IS NOT NULL AND paa.date_end IS NOT NULL
		   AND paa.absence_attendance_type_id = pat.absence_attendance_type_id
		   AND pat.absence_category = 'PTA'
		 ORDER BY paa.date_end DESC ;
	    EXCEPTION
		 WHEN OTHERS THEN
		      l_adopt_sum := null;
	    END;



	      -- Calculate actual days based on 5 day week pattern.
	      p_work_pattern := '5DAY';
	      l_duration := get_weekdays(p_prorate_start, p_prorate_end, p_work_pattern);
	      -- If override element exists for the adoption absence then use the override value.
	      /*IF l_override_ss_days IS NOT NULL THEN
		 l_duration := l_override_ss_days;
	      END IF;*/

	      IF l_adopt_comprate = 80 THEN
		     -- To fetch adoption maximum limit based on the compensation rate chosen.
		     OPEN GLB_VALUE ('NO_ADOPTION_EIGHTY', p_abs_start_date );
		     FETCH GLB_VALUE INTO l_adopt_glb_80;
		     CLOSE GLB_VALUE;

		     /* Bug Fix 5346832 : Start */

                     -- To fetch adoption days for each additional child based on the compensation rate chosen.
                     OPEN GLB_VALUE ('NO_ADOPTION_EIGHTY_ADDITIONAL_CHILD', p_abs_start_date);
                     FETCH GLB_VALUE INTO l_adopt_glb_80_add_child;
                     CLOSE GLB_VALUE;

		     /* knelli commented
		     IF l_duration > ( l_adopt_glb_80 - ( p_adopt_bal_days + l_adopt_sum)) THEN
			p_adopt_days := ( l_adopt_glb_80 - ( p_adopt_bal_days + l_adopt_sum));
		     ELSE
			p_adopt_days := l_duration;
		     END IF;*/
		     /* knelli added code */

		     -- l_parental_days_remaining := l_adopt_glb_80 - nvl(p_adopt_bal_days,0);

		     l_parental_days_remaining := l_adopt_glb_80 + (l_adopt_glb_80_add_child * (l_gen_no_of_children - 1)) - nvl(p_adopt_bal_days,0);
		     /* Bug Fix 5346832 : End */

		     l_parental_days_remaining := l_parental_days_remaining - nvl(l_adopt_sum,0);
		     IF l_parental_days_remaining < 0 THEN
		     l_parental_days_remaining := 0;
		     END IF;

		     IF nvl(l_adopt_ptp,0) > 0 THEN

			/* Bug Fix 5380082 : Start */

			-- l_parental_days_remaining := trunc(l_parental_days_remaining * 100/(100-l_adopt_ptp));
			-- l_duration := trunc(l_duration * l_adopt_ptp / 100 );
			l_duration := round((l_duration * l_adopt_ptp / 100 ),2) ;

			/* Bug Fix 5380082 : End */

		     END IF;

		     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
			p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
		     IF l_duration > l_parental_days_remaining THEN
			p_adopt_days := l_parental_days_remaining;
                       l_msg_error := to_char(12); /* Legislative limit exhausted Message */
		     ELSE
			p_adopt_days := l_duration;
		     END IF;

	      ELSIF l_adopt_comprate = 100 THEN
		     -- To fetch adoption maximum limit based on the compensation rate chosen.
		     OPEN GLB_VALUE ('NO_ADOPTION_HUNDRED', p_abs_start_date);
		     FETCH GLB_VALUE INTO l_adopt_glb_100;
		     CLOSE GLB_VALUE;

		     /* Bug Fix 5346832 : Start */

                     -- To fetch adoption days for each additional child based on the compensation rate chosen.
                     OPEN GLB_VALUE ('NO_ADOPTION_HUNDRED_ADDITIONAL_CHILD', p_abs_start_date);
                     FETCH GLB_VALUE INTO l_adopt_glb_100_add_child;
                     CLOSE GLB_VALUE;

		     /* knelli commented code
		     IF l_duration > ( l_adopt_glb_100 - ( p_adopt_bal_days + l_adopt_sum)) THEN
			p_adopt_days := ( l_adopt_glb_100 - ( p_adopt_bal_days + l_adopt_sum));
		     ELSE
			p_adopt_days := l_duration;
		     END IF;*/
		     /* knelli added code */

		     -- l_parental_days_remaining := l_adopt_glb_100 - nvl(p_adopt_bal_days,0);

		     l_parental_days_remaining := l_adopt_glb_100 + (l_adopt_glb_100_add_child * (l_gen_no_of_children - 1)) - nvl(p_adopt_bal_days,0);
		     /* Bug Fix 5346832 : End */

		     l_parental_days_remaining := l_parental_days_remaining - nvl(l_adopt_sum,0);
		     IF l_parental_days_remaining < 0 THEN
		     l_parental_days_remaining := 0;
		     END IF;

		     IF nvl(l_adopt_ptp,0) > 0 THEN

			/* Bug Fix 5380082 : Start */

			-- l_parental_days_remaining := trunc(l_parental_days_remaining * 100/(100-l_adopt_ptp));
			-- l_duration := trunc(l_duration * l_adopt_ptp / 100 );
			l_duration := round((l_duration * l_adopt_ptp / 100 ),2) ;

			/* Bug Fix 5380082 : End */

		     END IF;

		     /*IF l_duration > ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum)) THEN
			p_parental_days := ( l_max_parental_days_100 - ( p_parental_bal_days + l_maternity_sum));*/
		     IF l_duration > l_parental_days_remaining THEN
			p_adopt_days := l_parental_days_remaining;
                        l_msg_error := to_char(12); /* Legislative limit exhausted Message */
		     ELSE
			p_adopt_days := l_duration;
		     END IF;

	      END IF;
                         -- If override element exists for the adoption absence then use the override value.
                         IF l_override_ss_days IS NOT NULL THEN
                            p_adopt_days := l_override_ss_days;
                            IF p_adopt_days > l_parental_days_remaining THEN
                               l_msg_error := to_char(12); /* Legislative limit exhausted Message */
                            END IF ;
                          END IF;
	    -- Daily Rate calculation
	    -- Calculation of G rate

	    /* Start Bug Fix : 5380121 - Even if there is a change in the G rate during an absence period because of legislation changes,
		the G rate at the beginning of the particular absence only should be considered for calculation of the 6G */

	    -- l_g_rate := GET_GRATE(p_effective_date, p_assignment_id, p_business_group_id);

	    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
	    -- l_g_rate := GET_GRATE(p_abs_start_date, p_assignment_id, p_business_group_id);

	    /* End Bug Fix : 5380121 */

		/* pgopal - to get the initial absence start date*/
		IF ( l_initial_absence = 'N') THEN
		OPEN  csr_get_intial_abs_st_date(l_initial_abs_attend_id);
		FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
		CLOSE csr_get_intial_abs_st_date;
		ELSE
		l_initial_abs_st_date := p_abs_start_date;
		END IF ;

                OPEN  csr_intial_abs_pay_stdt(p_assignment_id,l_initial_abs_st_date);
                FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
                CLOSE csr_intial_abs_pay_stdt;

	    -- BUG 5380121 reopened : G rate at the initial absence of the particular absence should be considered
	     l_g_rate := GET_GRATE(l_initial_abs_st_date, p_assignment_id, p_business_group_id);

	    -- Calculation of daily rate for salaried employees (based on input value not actual payroll)
	    IF l_gen_hour_sal = 'S' THEN

		/*l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
			    (p_assignment_id, p_effective_date, 'Contractual Earnings',
			     'R', 'D', l_rate, l_error_message, null, null);*/
		/*pgopal - Bug 5441078 fix - Passing initial absence start date*/
		l_return :=  PQP_RATES_HISTORY_CALC.RATES_HISTORY
			    (p_assignment_id, l_initial_abs_st_date, 'Contractual Earnings',
			     'R', 'D', l_rate, l_error_message, null, null);

	       -- Override social security date was present.
	       IF l_override_ss_rate IS NOT NULL THEN
		  l_social_security_rate := l_override_ss_rate;
	       ELSE
		  l_social_security_rate := l_rate;
	       END IF;

	       -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
	       IF l_gen_restrict_ss_sl = 'Y' THEN
		  IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
		     l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
		  END IF;

	       END IF;
		-- if restrict daily rate to social security is not set then
		IF l_gen_restrict_dr_ss = 'N' THEN

		   -- (absence pay base * 12) / 260;
		   l_empr_daily_rate := ( p_sickabs_paybase * p_abs_month ) / p_abs_annual_days ;
		   -- IF employers pay is greater than 6g then restrict it to 6g if the flag is set
		   IF l_gen_restrict_empr_sl = 'Y' THEN
		      IF l_empr_daily_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
			 l_empr_daily_rate := ((l_g_rate * 6)/ p_abs_annual_days);
		      END IF;
		   END IF;

		   -- if restrict daily rate to social security is no then pick whichever is
		   -- less between historic and daily rate.
		   IF l_social_security_rate > l_empr_daily_rate THEN
		      l_reclaim_daily_rate := l_empr_daily_rate;
		   ELSE
		      l_reclaim_daily_rate := l_social_security_rate;
		   END IF;
		-- if restrict daily rate to social security is set then both ss and empr rate will be same.
		ELSE
		      l_empr_daily_rate := l_social_security_rate;
		      l_reclaim_daily_rate := l_social_security_rate;

		END IF;

	   -- Calculation of Daily rate for Hourly paid employees ( based on input value not actual payroll)
	   ELSIF l_gen_hour_sal = 'H' THEN
		 p_ear_value := 0;
		 IF p_hourly_paid IN ('W', 'B') THEN

		    -- Ignore public holidays if the one present in between absence start and end dates.
		    l_include_event := 'Y';
		    -- Calculate actual days in the previous 4 weeks skipping holidays and weekends.
                    /* pdavidra - bug 5330066 - redused the start date parameter by 1*/

		    /* BUG Fix 5346832 : Start
			   Changing the start date from (l_initial_abs_st_date - p_abs_min_gap)
			   to greatest(l_dateofjoin,(l_initial_abs_st_date - p_abs_min_gap))
			   for hr_loc_work_schedule.calc_sch_based_dur */

		  /*
		    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
					 ( p_assignment_id, l_days_or_hours, l_include_event,
					   (l_initial_abs_st_date - p_abs_min_gap), (l_initial_abs_st_date-1), l_start_time_char,
					   l_end_time_char, l_duration
					   );
		  */

		    l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
					 ( p_assignment_id, l_days_or_hours, l_include_event,
					   greatest(l_dateofjoin,(l_initial_abs_pay_stdt - p_abs_min_gap)), (l_initial_abs_pay_stdt-1), l_start_time_char,
					   l_end_time_char, l_duration
					   );

		 /* BUG Fix 5346832 : End */


		    -- Calculating actual number of absence days in the previous 4 weeks (payroll) periods.
		    BEGIN
			SELECT SUM( CASE WHEN date_start < (l_initial_abs_pay_stdt - p_abs_min_gap) THEN
					  ( date_end - (l_initial_abs_pay_stdt - p_abs_min_gap) ) +1
				    WHEN date_end > (l_initial_abs_pay_stdt-1) THEN
					  ( (l_initial_abs_pay_stdt-1) - date_start )+1
				    WHEN date_end = date_start THEN
						  1
                                    ELSE  (date_end - date_start) + 1 END ) AS Days_diff
			  INTO l_abs_worked_days
			  FROM per_absence_attendances
			 WHERE person_id = p_person_id
			   AND date_start < (l_initial_abs_pay_stdt-1)
			   AND date_end   > (l_initial_abs_pay_stdt - p_abs_min_gap)
			   AND date_start IS NOT NULL
			   AND date_end IS NOT NULL ;
		    EXCEPTION
		       WHEN NO_DATA_FOUND THEN
			    l_abs_worked_days := 0;
		       WHEN OTHERS THEN
			    l_abs_worked_days := 0;
		    END;
		    l_duration := l_duration - nvl(l_abs_worked_days, 0);

		    /* BUG Fix 5346832 : Start */

		    IF (l_duration > 0) THEN
			l_social_security_rate := ( p_4weeks_paybase / l_duration);
		    ELSE
			l_social_security_rate := 0 ;
		    END IF;

		    /* BUG Fix 5346832 : End */

		    -- Override social security date was present.
		    IF l_override_ss_rate IS NOT NULL THEN
		       l_social_security_rate := l_override_ss_rate;
		    END IF;
		    -- If social security rate is greater than 6g then restrict it to 6g if the flag is set
		    IF l_gen_restrict_ss_sl = 'Y' THEN
		       IF l_social_security_rate > ((l_g_rate * 6)/ p_abs_annual_days) THEN
			  l_social_security_rate := ((l_g_rate * 6)/ p_abs_annual_days);
		       END IF;
		    END IF;

		    l_empr_daily_rate := l_social_security_rate;
		    l_reclaim_daily_rate := l_social_security_rate;

		 ELSIF p_hourly_paid = 'M' THEN
		  /* knelli
		  IF length(l_msg_error) > 1 THEN
		     l_msg_error := 'Error7';
		  END IF;*/
		  l_msg_error := to_char(7);
		       -- Throw a warning message that the person in monthly payroll with hourly flag chosen and
		       -- Previous 4 weeks period logic will not work.
		 END IF;
	   END IF;

	   p_adopt_rate     := l_reclaim_daily_rate ;
	   /* knelli added logic for bug fix 5284260 */
	   IF l_adopt_comprate = 80 THEN
	   p_adopt_rate := p_adopt_rate * 0.8;
	   END IF;
	   p_adopt_comprate := l_adopt_comprate ;
	   -- Reusing the existing siciness output variables for adoption
	   p_rec_total_days := p_adopt_days;
	   p_rec_daily_rate := p_adopt_comprate;
	   p_ss_daily_rate  := p_adopt_rate;

	   l_include_event := 'N';
	   -- Calculating actual sickness days through work schedule
	   l_wrk_schd_return := hr_loc_work_schedule.calc_sch_based_dur
				( p_assignment_id, l_days_or_hours, l_include_event,
				  p_prorate_start, p_prorate_end, l_start_time_char,
				  l_end_time_char, l_duration
				 );
	      l_actual_cal_days := nvl(l_duration,0);
	   -- Calculate Earnings Adjustment value
	      --p_ear_value      := ( ( p_sickabs_paybase * p_abs_month) / p_abs_annual_days ) * l_actual_cal_days; 5925652
	      p_ear_value      := round(( ( p_abs_ear_adj_base * p_abs_month) / p_abs_annual_days ),2) * p_adopt_days;
	      p_ear_startdt    := p_prorate_start;
	      p_ear_enddt      := p_prorate_end;
	      p_ear_value      := nvl(p_ear_value,0);

		IF l_gen_hour_sal = 'H' THEN
		       p_ear_value := 0;
		END IF;

		IF l_gen_rate_option = 'DRATE_OPT1' THEN
		   p_rate_option1 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT2' THEN
		   p_rate_option2 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT3' THEN
		   p_rate_option3 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT4' THEN
		   p_rate_option4 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT5' THEN
		   p_rate_option5 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT6' THEN
		   p_rate_option6 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT7' THEN
		   p_rate_option7 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT8' THEN
		   p_rate_option8 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT9' THEN
		   p_rate_option9 := 'Y';
		ELSIF l_gen_rate_option = 'DRATE_OPT10' THEN
		   p_rate_option10 := 'Y';
		ELSE
		   p_rate_option1  := null;
		   p_rate_option2  := null;
		   p_rate_option3  := null;
		   p_rate_option4  := null;
		   p_rate_option5  := null;
		   p_rate_option6  := null;
		   p_rate_option7  := null;
		   p_rate_option8  := null;
		   p_rate_option9  := null;
		   p_rate_option10 := null;
		END IF;
      p_abs_error := l_msg_error ;

	/* Bug Fix 5349636 : Start */

       -- If calculated daily rate is less than 50% of G daily rate then no social security period will be paid.
       IF p_adopt_rate < ((l_g_rate / p_abs_annual_days) / 2) THEN
	  -- No social security period will be paid.
	   p_rec_total_days := 0;
	   p_rec_daily_rate := 0;
	   p_ss_daily_rate  := 0;
	   p_ear_value      := 0;
           l_msg_error := to_char(11); /* 50% G Message */
	   p_abs_error      := l_msg_error ;
       END IF;

	/* Bug Fix 5349636 : End */

      ELSE -- if reimburse from social security is set to No then no adoption will be paid.
	   -- Reusing the existing siciness output variables for adoption
	   p_rec_total_days := 0;
	   p_rec_daily_rate := 0;
	   p_ss_daily_rate  := 0;
	   p_ear_value      := 0;
	   p_abs_error := l_msg_error ;
       END IF; -- Reimburse from social security
  END IF;
hr_utility.set_location('Leaving absence package: ', 2);
return 1;
END CALCULATE_PAYMENT;

PROCEDURE GET_SICKPAY
 (p_person_id                   IN      NUMBER
  ,p_assignment_id              IN      NUMBER
  ,p_effective_date             IN      DATE
  ,p_dateofjoin                 IN      DATE
 )
AS
BEGIN
  null;
END GET_SICKPAY;

FUNCTION get_override_details
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_abs_start_date              IN      DATE
 ,p_abs_end_date                IN      DATE
 ,p_abs_categorycode            IN      VARCHAR2
 ,p_start_date                  OUT NOCOPY DATE
 ,p_end_date                    OUT NOCOPY DATE
 ,p_over_empr_rate              OUT NOCOPY NUMBER
 ,p_over_ss_rate                OUT NOCOPY NUMBER
 ,p_over_reclaim_rate           OUT NOCOPY NUMBER
 ,p_over_empr_days              OUT NOCOPY NUMBER
 ,p_over_ss_days                OUT NOCOPY NUMBER ) RETURN NUMBER IS
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
     AND  et.element_name       = 'Absence Detail Override'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              in ('Start Date', 'End Date', 'Employer Period Daily Rate', 'Social Security Daily Rate', 'Reclaimable Daily Rate', 'Employer Period Days', 'Social Security Period Days', 'Absence Category')
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

  l_over_empr_rate number;
  l_over_ss_rate number;
  l_over_reclaim_rate number;
  l_over_empr_days number;
  l_over_ss_days number;

  l_over_category Varchar2(50);
  l_abs_category_code varchar2(50);
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_check_nomatch number;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;
  l_check_nomatch := 0;

  -- To select absence category code by passing absence category meaning.
 /*    BEGIN
	 SELECT LOOKUP_CODE
	 INTO   l_abs_category_code
	 FROM HR_LOOKUPS /* Bug Fix 5263714 referred hr_lookups instead of fnd_lookup_values
	 FROM   FND_LOOKUP_VALUES
	 WHERE  LOOKUP_TYPE = 'ABSENCE_CATEGORY'
	   AND  ENABLED_FLAG = 'Y'
	   AND  MEANING = p_abs_category;
     EXCEPTION
       WHEN others THEN
	  l_abs_category_code := null;
     END;*/
   l_abs_category_code := p_abs_categorycode;

  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;

  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        IF l_tab(l_cur).eename = 'Start Date' THEN
           l_start_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss') ;
        elsif l_tab(l_cur).eename = 'End Date' THEN
           l_end_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
        elsif l_tab(l_cur).eename = 'Employer Period Daily Rate' THEN
           l_over_empr_rate := fnd_number.canonical_to_number(l_tab(l_cur).eevalue);
        elsif l_tab(l_cur).eename = 'Social Security Daily Rate' THEN
           l_over_ss_rate := fnd_number.canonical_to_number(l_tab(l_cur).eevalue);
        elsif l_tab(l_cur).eename = 'Reclaimable Daily Rate' THEN
           l_over_reclaim_rate := fnd_number.canonical_to_number(l_tab(l_cur).eevalue);
        elsif l_tab(l_cur).eename = 'Employer Period Days' THEN
           l_over_empr_days := fnd_number.canonical_to_number(l_tab(l_cur).eevalue);
        elsif l_tab(l_cur).eename = 'Social Security Period Days' THEN
             l_over_ss_days := fnd_number.canonical_to_number(l_tab(l_cur).eevalue);
        elsif l_tab(l_cur).eename = 'Absence Category' THEN
           l_over_category := l_tab(l_cur).eevalue;
	end if;
        -- Check no. of input values of override element is 5
        IF l_counter < 8 then
           l_counter := l_counter + 1;
        else
	  -- Check the absence category of parent element matches with override element. If so then check for
          -- matching override element to override the absence days and daily rate.
	  IF l_over_category = l_abs_category_code THEN
	   -- Check override element's start and end date matches with Absent element.
           if l_start_date = p_abs_start_date then -- and l_end_date = p_abs_end_date 5380130
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
                 p_start_date := null;
                 p_end_date := null;
                 p_over_empr_rate := null;
                 p_over_ss_rate := null;
                 p_over_reclaim_rate := null;
                 p_over_empr_days := null;
                 p_over_ss_days := null;
                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
              p_start_date := l_start_date;
              p_end_date := l_end_date;
              p_over_empr_rate := l_over_empr_rate;
              p_over_ss_rate := l_over_ss_rate;
              p_over_reclaim_rate := l_over_reclaim_rate;
              p_over_empr_days := l_over_empr_days;
              p_over_ss_days := l_over_ss_days;
           end if;
           l_counter := 1;
        -- Override element exists for the category with start date and end date are not matching
	else
	   l_check_nomatch := l_check_nomatch + 1;
        end if;
       END if;
  END LOOP;

  -- Match found successfully
  IF p_start_date is not null then
     RETURN 1;
  -- Override element exists but date doesnt match.
  elsif p_start_date is null and l_check_nomatch > 0 then
     RETURN 2;
  -- No override element attached
  else
     RETURN 0;
  end if;
  --
 END get_override_details;

FUNCTION get_weekdays(p_period_start_date IN DATE
		     ,p_period_end_date   IN DATE
		     ,p_work_pattern      IN VARCHAR) RETURN NUMBER IS

/* Commented to add new logic
l_abs_start_date  date;
l_abs_end_date    date;
l_loop_start_date date;
l_days    number;
l_start_d number;
l_end_d   number;
l_work_pattern varchar2(6);
l_index     number;
l_weekdays  number;
l_curr_date date;
l_d         number;
begin
l_abs_start_date := p_period_start_date;
l_abs_end_date := p_period_end_date;
l_days := (l_abs_end_date - l_abs_start_date) + 1;
l_weekdays := 0;
l_curr_date := l_abs_start_date;
l_work_pattern := p_work_pattern;
IF l_work_pattern = '5DAY' then
FOR l_index IN 1..l_days
loop
    l_curr_date := l_abs_start_date + (l_index - 1);
    l_d := to_number(to_char(l_curr_date,'d'));
    IF l_d NOT IN (7,1) then
	l_weekdays := l_weekdays +1;
    END IF;
END loop;
END if;

IF l_work_pattern = '6DAY' then
FOR l_index IN 1..l_days
loop
    l_curr_date := l_abs_start_date + (l_index - 1);
    l_d := to_number(to_char(l_curr_date,'d'));
    IF l_d <> 1 then
       l_weekdays := l_weekdays +1;
    END IF;
END  loop;
END if;
*/

/* New Logic */
v_st_date date;
v_en_date date;
v_beg_of_week date;
v_end_of_week date;
l_weekdays number;
v_work_pattern varchar2(20);
begin
	v_st_date :=p_period_start_date;
	v_en_date :=p_period_end_date;
	l_weekdays    := 0;
	v_work_pattern := p_work_pattern;
	if p_period_start_date > p_period_end_date then
		return l_weekdays;
	end if;
	--Determine the Beginning of Week Date for Start Date
	--and End of Week Date for End Date
	v_beg_of_week := v_st_date - (get_day_of_week(v_st_date)-1);
	v_end_of_week  := v_en_date;
	if get_day_of_week(v_en_date) NOT IN('1') then
		v_end_of_week := v_en_date + (7- get_day_of_week(v_en_date)+1);
	end if;
	IF v_work_pattern = '5DAY' THEN
		--Calculate the Total Week Days @ of 5 per week
		l_weekdays := ((v_end_of_week-v_beg_of_week)/7)*5;
		--Adjust the Total Week Days by subtracting
		--No of Days before the Start Date
		if (v_st_date > (v_beg_of_week+1)) then
			l_weekdays := l_weekdays - (v_st_date - (v_beg_of_week+1)) ;
		end if;
		if v_end_of_week <> v_en_date then
			v_end_of_week := v_end_of_week -2;
		else
			if v_st_date = v_en_date then
				l_weekdays := 0;
			end if;
		end if;
		--Adjust the Total Week Days by subtracting
		--No of Days After the End Date
		if (v_end_of_week - v_en_date) >= 0 then
			l_weekdays := l_weekdays - (v_end_of_week - v_en_date) ;
		end if;

	ELSE
		--Calculate the Total Week Days @ of 6 per week
		l_weekdays := ((v_end_of_week-v_beg_of_week)/7)*6;
		--Adjust the Total Week Days by subtracting
		--No of Days before the Start Date
		if (v_st_date > (v_beg_of_week+1)) then
			l_weekdays := l_weekdays - (v_st_date - (v_beg_of_week+1)) ;
		end if;
		if v_end_of_week <> v_en_date then
			v_end_of_week := v_end_of_week -1;
		else
			if v_st_date = v_en_date then
				l_weekdays := 0;
			end if;
		end if;
		--Adjust the Total Week Days by subtracting
		--No of Days After the End Date
		if (v_end_of_week - v_en_date) >= 0 then
			l_weekdays := l_weekdays - (v_end_of_week - v_en_date) ;
		end if;
	END IF;

RETURN l_weekdays;

END get_weekdays;

/* added function get_day_of_week
This Function returns the day of the week.
Sunday is considered to be the first day of the week*/
FUNCTION  get_day_of_week(p_date DATE) RETURN NUMBER IS
l_reference_date date:=to_date('01/01/1984','DD/MM/YYYY');
v_index number;

BEGIN
v_index := abs(p_date - l_reference_date);
v_index := mod(v_index,7);
v_index := v_index + 1;
RETURN v_index;

END get_day_of_week;

FUNCTION get_sick_unpaid
 (p_assignment_id               IN      NUMBER
 ,p_effective_date              IN      DATE
 ,p_start_date                  OUT NOCOPY DATE
 ,p_end_date                    OUT NOCOPY DATE) RETURN NUMBER IS
  --
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE, effdt DATE ) IS
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
     AND  et.element_name       = 'Sickness Unpaid'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              IN ('Start Date', 'End Date')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  effdt BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  effdt BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  effdt BETWEEN el.effective_start_date AND el.effective_end_date
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
  l_over_hours number;
  l_over_days number;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_effective_date date;
  l_assignment_id number;
  l_max_date date;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;

    BEGIN
        SELECT MAX(ee.effective_end_date)
          INTO l_max_date
          FROM pay_element_types_f        et
               ,pay_element_links_f        el
               ,pay_input_values_f         iv1
               ,pay_element_entries_f      ee
               ,pay_element_entry_values_f eev1
         WHERE et.element_name       = 'Sickness Unpaid'
           AND et.legislation_code   = 'NO'
           AND iv1.element_type_id   = et.element_type_id
           AND iv1.NAME              = 'End Date'
           AND el.element_type_id    = et.element_type_id
           AND ee.element_link_id    = el.element_link_id
           AND eev1.element_entry_id = ee.element_entry_id
           AND eev1.input_value_id   = iv1.input_value_id
           AND ee.effective_end_date <= p_effective_date
           AND ee.assignment_id = p_assignment_id;
    EXCEPTION
        WHEN OTHERS THEN
             l_max_date := NULL;
    END;
  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date, l_max_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;

  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        IF l_tab(l_cur).eename = 'Start Date' THEN
           p_start_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss') ;
        elsif l_tab(l_cur).eename = 'End Date' THEN
           p_end_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
        end if;
  END LOOP;
  -- Match found successfully
  IF p_start_date is not null and p_end_date is not null then
     RETURN 0;
  ELSE
     RETURN -1;
  end if;
  --
 END get_sick_unpaid;
--

FUNCTION GET_GRATE ( p_effective_date              IN         DATE
                     ,p_assignment_id              IN         NUMBER
                     ,p_business_group_id          IN         NUMBER) RETURN NUMBER IS
l_g_rate   Number;
BEGIN
            -- Get the daily rate value
            -- Check daily rate is < 50% of G Per day then no social security amount will be paid.
            -- Calculation of G rate
            BEGIN

	    /*
		select pucf.VALUE
                into  l_g_rate
                from pay_user_tables	put
                	,pay_user_rows_f	pur
                	,pay_user_columns	puc
                	,pay_user_column_instances_f	pucf
                where	put.USER_TABLE_NAME = 'NO_GLOBAL_CONSTANTS'
                and 	pur.ROW_LOW_RANGE_OR_NAME = 'NATIONAL_INSURANCE_BASE_RATE'
                and 	puc.USER_COLUMN_NAME = 'Value'
                and 	put.legislation_code = 'NO'
                and 	pur.legislation_code = 'NO'
                and 	puc.legislation_code = 'NO'
                and 	( pucf.business_group_id = p_business_group_id OR pucf.business_group_id is NULL )
                and 	put.user_table_id = pur.user_table_id
                and 	put.user_table_id = puc.user_table_id
                and		pucf.user_row_id = pur.user_row_id
                and 	pucf.user_column_id = puc.user_column_id
                and		p_effective_date between pur.effective_start_date and pur.effective_end_date
                and		p_effective_date between pucf.effective_start_date and pucf.effective_end_date ;

	    */

		-- Bug Fix 5566622 : Value of G (National Insurance Base Rate) to be taken
		-- from Global (NO_NATIONAL_INSURANCE_BASE_RATE) and not user table (NATIONAL_INSURANCE_BASE_RATE).

             select fnd_number.canonical_to_number(GLOBAL_VALUE)
             into  l_g_rate
             from ff_globals_f
             where global_name = 'NO_NATIONAL_INSURANCE_BASE_RATE'
             and LEGISLATION_CODE = 'NO'
             and BUSINESS_GROUP_ID IS NULL
             and p_effective_date between EFFECTIVE_START_DATE and EFFECTIVE_END_DATE ;

            EXCEPTION
                when no_data_found then
                     l_g_rate := null;
            END;

RETURN l_g_rate;
END GET_GRATE;

FUNCTION GET_SOURCEID (p_source_id        IN         NUMBER) return number
is
begin
return p_source_id;
end get_sourceid;

FUNCTION GET_26WEEK (P_ASSIGNMENT_ACTION_ID        IN         NUMBER)
RETURN DATE
IS
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE, effdt DATE ) IS
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
     AND  et.element_name       = 'Sickness Unpaid'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = 'End Date'
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  effdt BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  effdt BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  p_effective_date BETWEEN iv1.effective_start_date AND iv1.effective_end_date
     AND  p_effective_date BETWEEN et.effective_start_date AND et.effective_end_date
     AND  effdt BETWEEN el.effective_start_date AND el.effective_end_date
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
  l_over_hours number;
  l_over_days number;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  l_effective_date date;
  l_assignment_id number;
  l_max_date date;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;

  -- To fetch the effective date and assignment id for the given assignment action id.
  BEGIN
      SELECT PPA.EFFECTIVE_DATE
             ,PAA.ASSIGNMENT_ID
        INTO l_effective_date
             ,l_assignment_id
        FROM PAY_PAYROLL_ACTIONS PPA
             ,PAY_ASSIGNMENT_ACTIONS PAA
       WHERE PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
         AND PAA.ASSIGNMENT_ACTION_ID = P_ASSIGNMENT_ACTION_ID;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           l_effective_date := NULL;
           l_assignment_id  := NULL;
      WHEN OTHERS THEN
           l_effective_date := NULL;
           l_assignment_id  := NULL;
  END;

    BEGIN
        SELECT MAX(ee.effective_end_date)
          INTO l_max_date
          FROM pay_element_types_f        et
               ,pay_element_links_f        el
               ,pay_input_values_f         iv1
               ,pay_element_entries_f      ee
               ,pay_element_entry_values_f eev1
         WHERE et.element_name       = 'Sickness Unpaid'
           AND et.legislation_code   = 'NO'
           AND iv1.element_type_id   = et.element_type_id
           AND iv1.NAME              = 'End Date'
           AND el.element_type_id    = et.element_type_id
           AND ee.element_link_id    = el.element_link_id
           AND eev1.element_entry_id = ee.element_entry_id
           AND eev1.input_value_id   = iv1.input_value_id
           AND ee.effective_end_date <= l_effective_date
           AND ee.assignment_id = l_assignment_id;
    EXCEPTION
        WHEN OTHERS THEN
             NULL;
    END;
  -- Open cursor to fetch all screen entry values of Override Holiday Duration element.
  OPEN  get_details(l_assignment_id , l_effective_date, l_max_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;

  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        IF l_tab(l_cur).eename = 'Start Date' THEN
           l_start_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss') ;
        elsif l_tab(l_cur).eename = 'End Date' THEN
           l_end_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
        end if;
  END LOOP;
  IF l_end_date IS NULL THEN
     l_end_date := to_date('01/01/0001 00:00:00','dd/mm/yyyy hh24:mi:ss');
  END IF;
  RETURN l_end_date;
END GET_26WEEK;

FUNCTION GET_USERTABLE (p_effective_date        IN         DATE
                        ,p_business_group_id    IN         NUMBER
                        ,p_usertable_name       IN         VARCHAR2
                        ,p_usertable_colname    IN         VARCHAR2
                        ,p_exact_text           IN         VARCHAR2 )
RETURN NUMBER IS
l_value NUMBER;
BEGIN
    BEGIN
        SELECT pucf.VALUE
          INTO l_value
          FROM pay_user_tables	put
        	   ,pay_user_rows_f	pur
        	   ,pay_user_columns	puc
        	   ,pay_user_column_instances_f	pucf
         WHERE put.USER_TABLE_NAME = p_usertable_name
           AND pur.ROW_LOW_RANGE_OR_NAME = p_exact_text
           AND puc.USER_COLUMN_NAME = p_usertable_colname
           AND put.legislation_code = 'NO'
           AND pur.legislation_code = 'NO'
           AND puc.legislation_code = 'NO'
           AND ( pucf.business_group_id = p_business_group_id OR pucf.business_group_id IS NULL )
           AND put.user_table_id = pur.user_table_id
           AND put.user_table_id = puc.user_table_id
           AND pucf.user_row_id = pur.user_row_id
           AND pucf.user_column_id = puc.user_column_id
           AND p_effective_date BETWEEN pur.effective_start_date AND pur.effective_end_date
           AND p_effective_date BETWEEN pucf.effective_start_date AND pucf.effective_end_date ;
    EXCEPTION
           WHEN OTHERS THEN
                l_value := NULL;
    END;
RETURN l_value;
END GET_USERTABLE;

FUNCTION get_months_employed(p_person_id          IN         NUMBER
			    ,p_check_start_date   IN         DATE
			    ,p_check_end_date     IN         DATE   ) return NUMBER IS

l_min_start_date date;
l_max_end_date date;
l_fjob_start_date date;
l_ljob_end_date date;
l_start_date date;
l_end_date date;
l_person_id number;
l_months_employed number;
l_records number;

TYPE l_rec IS TABLE OF date INDEX BY binary_integer;
--TYPE l_rec IS TABLE OF varchar2(50) INDEX BY binary_integer;

CURSOR csr_prev_emplr_start_date(p_person_id number, p_check_start_date date,p_check_end_date date) is
SELECT start_date FROM per_previous_employers
WHERE person_id = p_person_id
AND   end_date >= p_check_start_date
AND   start_date <= p_check_end_date
ORDER BY start_date;

CURSOR csr_prev_emplr_end_date(p_person_id number, p_check_start_date date,p_check_end_date date) IS
SELECT end_date FROM per_previous_employers
WHERE person_id = p_person_id
AND   end_date >= p_check_start_date
AND   start_date <= p_check_end_date
ORDER BY start_date;

CURSOR csr_get_fjob_start_date(p_person_id number, p_check_start_date date,p_check_end_date date) IS
SELECT min(start_date) FROM per_previous_employers
WHERE person_id = p_person_id
AND   end_date >= p_check_start_date
AND   start_date <= p_check_end_date;

CURSOR csr_get_ljob_end_date(p_person_id number, p_check_start_date date,p_check_end_date date) IS
SELECT max(end_date) FROM per_previous_employers
WHERE person_id = p_person_id
AND   end_date >= p_check_start_date
AND   start_date <= p_check_end_date;

l_start_date_rec l_rec;
l_end_date_rec l_rec;
l_effective_date date;
l_person_hire_date date;
l_10_month_start_date date;
l_months number;
l_check_start_date date;
l_check_end_date date;

BEGIN

l_months_employed := 0;
l_person_id := p_person_id;
l_check_start_date := p_check_start_date;
l_check_end_date := p_check_end_date - 1;
l_10_month_start_date := p_check_start_date;


OPEN csr_prev_emplr_start_date(l_person_id,l_check_start_date,l_check_end_date);
FETCH csr_prev_emplr_start_date BULK COLLECT INTO l_start_date_rec;
CLOSE csr_prev_emplr_start_date;

OPEN csr_prev_emplr_end_date(l_person_id,l_check_start_date,l_check_end_date);
FETCH csr_prev_emplr_end_date BULK COLLECT INTO l_end_date_rec;
CLOSE csr_prev_emplr_end_date;

OPEN csr_get_fjob_start_date(l_person_id,l_check_start_date,l_check_end_date);
FETCH csr_get_fjob_start_date INTO l_fjob_start_date;
CLOSE csr_get_fjob_start_date;

OPEN csr_get_ljob_end_date(l_person_id,l_check_start_date,l_check_end_date);
FETCH csr_get_ljob_end_date INTO l_ljob_end_date;
CLOSE csr_get_ljob_end_date;

l_records := l_start_date_rec.count;

IF l_records > 0 THEN
	IF l_start_date_rec(1) = l_fjob_start_date AND l_end_date_rec(1) = l_ljob_end_date THEN
		IF l_start_date_rec(1) < l_10_month_start_date THEN
			l_fjob_start_date := l_10_month_start_date;
		END IF;
		IF l_end_date_rec(1) > l_check_end_date THEN
			l_fjob_start_date := l_check_end_date;
		END IF;
		l_months_employed := trunc(months_between(l_ljob_end_date+1,l_fjob_start_date),2);

	ELSE
		FOR i IN 1..l_records LOOP
			l_start_date := l_start_date_rec(i);
			l_end_date := l_end_date_rec(i);

			IF l_start_date < l_10_month_start_date THEN
				l_start_date := l_10_month_start_date;
			END IF;
			IF l_end_date > l_check_end_date THEN
				l_end_date := l_check_end_date;
			END IF;

			IF i > 1 AND l_start_date < l_end_date_rec(i-1) THEN
				l_start_date := l_end_date_rec(i-1) + 1;
			END IF;

			l_months := trunc(months_between(l_end_date+1,l_start_date),2);
			l_months_employed := l_months_employed + l_months;

		END LOOP;

	END IF;

END IF;

RETURN l_months_employed;
END get_months_employed;


FUNCTION get_parental_ben_sd(p_assignment_action_id        IN         NUMBER
                            ,p_element_entry_id            IN         NUMBER)
RETURN  DATE IS

  --
  CURSOR csr_get_person_id(p_assignment_action_id NUMBER) IS
  SELECT pap.person_id FROM
  pay_assignment_actions paa, per_all_assignments_f asgmt, per_all_people_f pap
  WHERE paa.assignment_action_id = p_assignment_action_id
  AND   paa.assignment_id = asgmt.assignment_id
  AND   asgmt.person_id = pap.person_id;

  CURSOR csr_get_maternity_sd(p_person_id NUMBER, p_dob VARCHAR2 ) IS
  SELECT min(date_start) from
  per_absence_attendances
  where person_id = p_person_id
  AND   ABS_INFORMATION_CATEGORY = 'NO_M'
  AND   abs_information2 = p_dob;

  CURSOR csr_get_baby_dob(p_abs_attendance_id NUMBER) IS
  SELECT abs_information2 from
  per_absence_attendances
  WHERE ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

  CURSOR csr_get_element_type_id(p_element_entry_id NUMBER) IS
  SELECT element_type_id from
  pay_element_entries_f
  WHERE  element_entry_id = p_element_entry_id;

  CURSOR csr_get_input_value_id(p_element_type_id NUMBER) IS
  SELECT input_value_id from
  pay_input_values_f
  WHERE element_type_id = p_element_type_id
  AND   NAME = 'CREATOR_ID';

  CURSOR csr_get_screen_value(p_element_entry_id NUMBER
                             ,p_input_value_id   NUMBER ) IS
  SELECT screen_entry_value
  FROM pay_element_entry_values_f
  WHERE element_entry_id = p_element_entry_id
  AND   input_value_id = p_input_value_id;


  l_start_date date;
  l_person_id  number;
  l_elt_type_id number;
  l_ip_value_id number;
  l_creator_id varchar2(20);
  l_creator_id_num number;
  l_dob varchar2(60);

  BEGIN

  OPEN csr_get_person_id(p_assignment_action_id);
  FETCH csr_get_person_id INTO l_person_id;
  CLOSE csr_get_person_id;

  OPEN csr_get_element_type_id(p_element_entry_id);
  FETCH csr_get_element_type_id INTO l_elt_type_id;
  CLOSE csr_get_element_type_id;

  OPEN csr_get_input_value_id(l_elt_type_id);
  FETCH csr_get_input_value_id INTO l_ip_value_id;
  CLOSE csr_get_input_value_id;

  OPEN csr_get_screen_value(p_element_entry_id,l_ip_value_id);
  FETCH csr_get_screen_value INTO l_creator_id;
  CLOSE csr_get_screen_value;

  l_creator_id_num := fnd_number.canonical_to_number(l_creator_id);

  OPEN csr_get_baby_dob(l_creator_id_num);
  FETCH csr_get_baby_dob INTO l_dob;
  CLOSE csr_get_baby_dob;

  OPEN csr_get_maternity_sd(l_person_id,l_dob);
  FETCH csr_get_maternity_sd INTO l_start_date;
  CLOSE csr_get_maternity_sd;


  RETURN l_start_date;
END get_parental_ben_sd;

/* Added function */
FUNCTION get_adoption_ben_sd(p_assignment_action_id        IN         NUMBER
                            ,p_element_entry_id            IN         NUMBER)
RETURN  DATE IS

  --
  CURSOR csr_get_person_id(p_assignment_action_id NUMBER) IS
  SELECT pap.person_id FROM
  pay_assignment_actions paa, per_all_assignments_f asgmt, per_all_people_f pap
  WHERE paa.assignment_action_id = p_assignment_action_id
  AND   paa.assignment_id = asgmt.assignment_id
  AND   asgmt.person_id = pap.person_id;

  /* Bug Fix 5380111 : Start */

  /*
  CURSOR csr_get_adoption_sd(p_person_id NUMBER, p_dob VARCHAR2 ) IS
  SELECT min(date_start) from
  per_absence_attendances
  where person_id = p_person_id
  AND   ABS_INFORMATION_CATEGORY = 'NO_IE_AL'
  AND   abs_information2 = p_dob;
  */

  CURSOR csr_get_adoption_sd(p_person_id NUMBER, p_dob VARCHAR2 ) IS
  SELECT min(date_start) from
  per_absence_attendances
  where person_id = p_person_id
  AND   ABS_INFORMATION_CATEGORY IN ('NO_IE_AL','NO_PTA')
  AND   abs_information2 = p_dob;

  /* Bug Fix 5380111 : End */


  CURSOR csr_get_baby_dob(p_abs_attendance_id NUMBER) IS
  SELECT abs_information2 from
  per_absence_attendances
  WHERE ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

  CURSOR csr_get_element_type_id(p_element_entry_id NUMBER) IS
  SELECT element_type_id from
  pay_element_entries_f
  WHERE  element_entry_id = p_element_entry_id;

  CURSOR csr_get_input_value_id(p_element_type_id NUMBER) IS
  SELECT input_value_id from
  pay_input_values_f
  WHERE element_type_id = p_element_type_id
  AND   NAME = 'CREATOR_ID';

  CURSOR csr_get_screen_value(p_element_entry_id NUMBER
                             ,p_input_value_id   NUMBER ) IS
  SELECT screen_entry_value
  FROM pay_element_entry_values_f
  WHERE element_entry_id = p_element_entry_id
  AND   input_value_id = p_input_value_id;


  l_start_date date;
  l_person_id  number;
  l_elt_type_id number;
  l_ip_value_id number;
  l_creator_id varchar2(20);
  l_creator_id_num number;
  l_dob varchar2(60);

  BEGIN

  OPEN csr_get_person_id(p_assignment_action_id);
  FETCH csr_get_person_id INTO l_person_id;
  CLOSE csr_get_person_id;

  OPEN csr_get_element_type_id(p_element_entry_id);
  FETCH csr_get_element_type_id INTO l_elt_type_id;
  CLOSE csr_get_element_type_id;

  OPEN csr_get_input_value_id(l_elt_type_id);
  FETCH csr_get_input_value_id INTO l_ip_value_id;
  CLOSE csr_get_input_value_id;

  OPEN csr_get_screen_value(p_element_entry_id,l_ip_value_id);
  FETCH csr_get_screen_value INTO l_creator_id;
  CLOSE csr_get_screen_value;

  l_creator_id_num := fnd_number.canonical_to_number(l_creator_id);

  OPEN csr_get_baby_dob(l_creator_id_num);
  FETCH csr_get_baby_dob INTO l_dob;
  CLOSE csr_get_baby_dob;

  OPEN csr_get_adoption_sd(l_person_id,l_dob);
  FETCH csr_get_adoption_sd INTO l_start_date;
  CLOSE csr_get_adoption_sd;


  RETURN l_start_date;
END get_adoption_ben_sd;

/*Bug 5393827 and 5349713 fixes -  Added funtion get_initial_abs_sd*/
/* Bug 5762854, Sickness and Part Time Sickness absences the daily rate should be calculated as the
  previous four weeks earnings / working days of current absence not initial absence . So this function
  should pass the curr abs payroll st dt for S and PTS, for other category should pass initial abs payroll st dt */
FUNCTION get_initial_abs_sd(p_org_entry_id IN NUMBER, p_elem_entry_id IN NUMBER)
RETURN  DATE IS

  CURSOR csr_get_ele_details(p_original_entry_id IN NUMBER ) IS
  SELECT peef.effective_start_date,peef.assignment_id
    FROM pay_element_entries_f peef
   WHERE peef.element_entry_id = p_original_entry_id;

  /* Cursor to get the payroll start date given absence*/
  CURSOR csr_intial_abs_pay_stdt (p_assignment_id number, p_initial_abs_start_date date) is
  SELECT ptp.start_date
    FROM per_all_assignments_f paaf, per_time_periods ptp
   WHERE paaf.assignment_id = p_assignment_id
     AND ptp.payroll_id = paaf.payroll_id
     AND p_initial_abs_start_date between ptp.start_date and ptp.end_date;

  /* Cursor to get the absence category based on the given element entry id*/
  CURSOR csr_abs_category (p_element_entry_id number) is
  SELECT screen_entry_value
    FROM pay_element_entries_f peef,
         pay_input_values_f pivf,
         pay_element_entry_values_f peevf
   WHERE peef.element_entry_id  = p_element_entry_id
     AND pivf.element_type_id   = peef.element_type_id
     AND pivf.name              = 'Absence Category'
     AND pivf.legislation_code  = 'NO'
     AND peevf.input_value_id   = pivf.input_value_id
     AND peevf.element_entry_id = peef.element_entry_id;

  l_get_ele_details csr_get_ele_details%ROWTYPE ;
  l_initial_abs_pay_stdt  DATE;
  l_abs_category varchar2(10);
BEGIN

  /* Findout the absence category */
  OPEN csr_abs_category(p_elem_entry_id);
  FETCH csr_abs_category INTO l_abs_category;
  CLOSE csr_abs_category;

  IF l_abs_category IN ('S','PTS') THEN
    /* getting the start date of the absence based on the element entry id context*/
    OPEN csr_get_ele_details(p_elem_entry_id);
    FETCH csr_get_ele_details INTO l_get_ele_details;
    CLOSE csr_get_ele_details;
  ELSE
    /* getting the start date of the initial absence based on the original entry id context*/
    OPEN csr_get_ele_details(p_org_entry_id);
    FETCH csr_get_ele_details INTO l_get_ele_details;
    CLOSE csr_get_ele_details;
  END IF;

  /* geting the payroll start date of the given assignment and date */
  OPEN  csr_intial_abs_pay_stdt(l_get_ele_details.assignment_id,l_get_ele_details.effective_start_date);
  FETCH csr_intial_abs_pay_stdt INTO l_initial_abs_pay_stdt;
  CLOSE csr_intial_abs_pay_stdt;

   RETURN l_initial_abs_pay_stdt;

END get_initial_abs_sd;

/* 5261223 Added function for get the Assignment termination date */
FUNCTION get_assg_trem_date(p_business_group_id IN NUMBER, p_asg_id IN NUMBER,
         p_pay_proc_period_start_date IN DATE, p_pay_proc_period_end_date IN DATE) RETURN DATE IS

    CURSOR csr_asg IS
    SELECT MAX(paaf.effective_end_date) effective_end_date
      FROM per_all_assignments_f paaf
     WHERE paaf.business_group_id = p_business_group_id
       AND paaf.assignment_id = p_asg_id
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

END get_assg_trem_date;

FUNCTION get_restrict_hol_to_6g(p_business_group_id in number ,
                                p_assignment_id in NUMBER,
				p_effective_date IN DATE ,
                                p_restrict_hol_to_6G OUT nocopy VARCHAR2) RETURN NUMBER IS
	CURSOR csr_person_id IS
            SELECT PERSON_ID
              FROM PER_ALL_ASSIGNMENTS_F ASG
             WHERE ASG.ASSIGNMENT_ID = p_assignment_id
               AND p_effective_date BETWEEN ASG.EFFECTIVE_START_DATE
                                    AND ASG.EFFECTIVE_END_DATE;


         CURSOR csr_person_details(p_person_id IN NUMBER ) is
       	 SELECT PER_INFORMATION22 AS restrict_hol_to_6G
        	   FROM PER_ALL_PEOPLE_F PER
      	      WHERE PER.PERSON_ID = p_person_id
     	        AND P_EFFECTIVE_DATE BETWEEN PER.EFFECTIVE_START_DATE
                                     AND PER.EFFECTIVE_END_DATE;



    CURSOR csr_le_details is
            SELECT	hoi4.ORG_INFORMATION10 AS restrict_hol_to_6G
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
                          AND P_EFFECTIVE_DATE BETWEEN ASG.EFFECTIVE_START_DATE AND ASG.EFFECTIVE_END_DATE ) X
              WHERE o1.business_group_id = p_business_group_id
                AND hoi1.organization_id = o1.organization_id
                AND hoi1.organization_id = X.ORG_ID
                AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
                AND hoi1.org_information_context = 'CLASS'
                AND o1.organization_id = hoi2.org_information1
                AND hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
                AND hoi2.organization_id =  hoi3.organization_id
                AND hoi3.ORG_INFORMATION_CONTEXT='CLASS'
                AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
                AND hoi3.organization_id = hoi4.organization_id
                AND hoi4.ORG_INFORMATION_CONTEXT='NO_ABSENCE_PAYMENT_DETAILS';

l_person_id NUMBER ;
csr_person_details_rec csr_person_details%ROWTYPE ;
csr_le_details_rec csr_le_details%ROWTYPE ;
BEGIN

OPEN csr_person_id;
FETCH csr_person_id INTO l_person_id;
CLOSE  csr_person_id;

OPEN csr_person_details(l_person_id);
FETCH csr_person_details INTO csr_person_details_rec;
CLOSE  csr_person_details;

OPEN csr_le_details;
FETCH csr_le_details INTO csr_le_details_rec;
CLOSE  csr_le_details;

p_restrict_hol_to_6G := NVL(NVL(csr_person_details_rec.restrict_hol_to_6G,csr_le_details_rec.restrict_hol_to_6G),'Y');


RETURN 1 ;
EXCEPTION WHEN OTHERS THEN
RETURN 0 ;
END get_restrict_hol_to_6g;


FUNCTION get_holiday_days (p_abs_category in varchar2,
                           p_abs_attendance_id IN NUMBER,
			   p_hol_days OUT nocopy NUMBER ) RETURN NUMBER IS

        CURSOR csr_mat_get_hol_days IS
	    SELECT paa.abs_information14 hol_days
        FROM PER_ABSENCE_ATTENDANCES PAA
        WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

        CURSOR csr_pt_mat_get_hol_days IS
	    SELECT paa.abs_information13 hol_days
        FROM PER_ABSENCE_ATTENDANCES PAA
        WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

        CURSOR csr_pat_get_hol_days IS
	    SELECT paa.abs_information10 hol_days
        FROM PER_ABSENCE_ATTENDANCES PAA
        WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

        CURSOR csr_pt_pat_get_hol_days IS
	    SELECT paa.abs_information12 hol_days
        FROM PER_ABSENCE_ATTENDANCES PAA
        WHERE PAA.ABSENCE_ATTENDANCE_ID = p_abs_attendance_id;

BEGIN

IF p_abs_category = 'M' THEN
OPEN csr_mat_get_hol_days;
FETCH csr_mat_get_hol_days INTO p_hol_days;
CLOSE csr_mat_get_hol_days;

ELSIF p_abs_category = 'PTM' THEN
OPEN csr_pt_mat_get_hol_days;
FETCH csr_pt_mat_get_hol_days INTO p_hol_days;
CLOSE csr_pt_mat_get_hol_days;

ELSIF p_abs_category = 'PA' THEN
OPEN csr_pat_get_hol_days;
FETCH csr_pat_get_hol_days INTO p_hol_days;
CLOSE csr_pat_get_hol_days;

ELSIF p_abs_category = 'PTP' THEN
OPEN csr_pt_pat_get_hol_days;
FETCH csr_pt_pat_get_hol_days INTO p_hol_days;
CLOSE csr_pt_pat_get_hol_days;
END IF ;

RETURN 1 ;

EXCEPTION WHEN OTHERS THEN
RETURN 0 ;

END get_holiday_days;

/* 5413738 Added function for get the CMS contact start and end date if singale contact attached to the person*/
FUNCTION get_cms_contact_date(p_assignment_id IN NUMBER, p_abs_start_date IN DATE,
         p_cms_contact_start_date OUT nocopy DATE, p_cms_contact_end_date OUT nocopy DATE,
	 p_cms_contact_count OUT nocopy NUMBER) RETURN NUMBER IS

	CURSOR csr_person_id IS
            SELECT PERSON_ID
              FROM PER_ALL_ASSIGNMENTS_F ASG
             WHERE ASG.ASSIGNMENT_ID = p_assignment_id
               AND p_abs_start_date BETWEEN ASG.EFFECTIVE_START_DATE
                                    AND ASG.EFFECTIVE_END_DATE;

CURSOR child_contact ( personid NUMBER, contacttype VARCHAR2, abs_stdt DATE) IS
SELECT pap.date_of_birth
       ,ROUND(MONTHS_BETWEEN( abs_stdt, pap.date_of_birth ) / 12, 2)  AS AGE
       ,pcr.contact_type
       ,pcr.cont_information1
       ,pcr.cont_information2
       ,pcr.date_start
       ,pcr.date_end
  FROM per_all_people_f pap
       ,per_contact_relationships pcr
 WHERE pap.person_id = pcr.contact_person_id
   AND pcr.person_id = personid
   AND pcr.contact_type = contacttype
   AND (pcr.date_start is null or pcr.date_start <= abs_stdt)
   AND (pcr.date_end is null or pcr.date_end >= abs_stdt );

   l_person_id NUMBER ;
  BEGIN

   OPEN csr_person_id;
   FETCH csr_person_id INTO l_person_id;
   CLOSE  csr_person_id;

	   P_cms_contact_count := 0 ;
           p_cms_contact_start_date := NULL ;
           p_cms_contact_end_date   := NULL ;
           FOR I IN child_contact ( l_person_id, 'DC', p_abs_start_date )
           LOOP
	       i.CONT_INFORMATION2 := nvl(i.CONT_INFORMATION2,'N');
	       -- Age is less than 13 years (or) Age is less than 19 years with chronic flag as Yes
	       IF (I.AGE < 13) OR (I.AGE < 19 AND i.CONT_INFORMATION2 = 'Y') THEN
                  P_cms_contact_count := P_cms_contact_count + 1 ;
		  p_cms_contact_start_date := i.date_start;
                  p_cms_contact_end_date := i.date_end;
               END IF;
           END LOOP;
	   /* if more than one contact is available */
           IF P_cms_contact_count <> 1 THEN
              p_cms_contact_start_date := NULL ;
              p_cms_contact_end_date   := NULL ;
	   END IF;

      RETURN 1 ;
      EXCEPTION WHEN OTHERS THEN
      RETURN 0 ;
END get_cms_contact_date;

FUNCTION get_init_abs_st_date (p_abs_attendance_id IN NUMBER) RETURN DATE IS

CURSOR csr_get_intial_abs_st_date(p_abs_attn_id IN VARCHAR2 ) IS
SELECT nvl(peef2.effective_start_date,peef1.effective_start_date)
  FROM pay_element_entry_values_f peevf
      ,pay_input_values_f pivf
      ,pay_element_entries_f peef1
      ,pay_element_entries_f peef2
WHERE peevf.screen_entry_value = p_abs_attn_id
  AND pivf.input_value_id = peevf.input_value_id
  AND pivf.NAME = 'CREATOR_ID'
  AND pivf.legislation_code = 'NO'
  AND peef1.element_entry_id  = peevf.element_entry_id
  AND peef2.element_entry_id(+) = peef1.original_entry_id;

l_initial_abs_st_date DATE ;

BEGIN

  OPEN  csr_get_intial_abs_st_date(to_char(p_abs_attendance_id));
  FETCH csr_get_intial_abs_st_date INTO l_initial_abs_st_date;
  CLOSE csr_get_intial_abs_st_date;
  RETURN l_initial_abs_st_date ;

END get_init_abs_st_date;

/* fetch the current absence start date */
FUNCTION get_abs_st_date (p_abs_attendance_id IN NUMBER) RETURN DATE IS

CURSOR csr_get_abs_st_date(p_abs_attn_id IN VARCHAR2 ) IS
SELECT date_start
  FROM per_absence_attendances
WHERE absence_attendance_id = p_abs_attn_id ;

l_abs_st_date DATE ;

BEGIN

  OPEN  csr_get_abs_st_date(p_abs_attendance_id);
  FETCH csr_get_abs_st_date INTO l_abs_st_date;
  CLOSE csr_get_abs_st_date;
  RETURN l_abs_st_date ;

END get_abs_st_date;


END PAY_NO_ABSENCE;

/
