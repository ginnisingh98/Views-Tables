--------------------------------------------------------
--  DDL for Package Body GHR_VALIDATE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_VALIDATE_CHECK" AS
/* $Header: ghrvalid.pkb 120.31.12010000.5 2009/09/22 09:16:05 utokachi ship $ */

procedure Validate_CHECK(p_pa_request_rec             IN ghr_pa_requests%ROWTYPE
                            ,p_per_group1             IN ghr_api.per_group1_type
                            ,p_per_retained_grade     IN ghr_api.per_retained_grade_type
                            ,p_per_sep_retire         in ghr_api.per_sep_retire_type
                            ,p_per_conversions	      in ghr_api.per_conversions_type
                            ,p_per_uniformed_services in ghr_api.per_uniformed_services_type
                            ,p_pos_grp1               in ghr_api.pos_grp1_type
                            ,p_pos_valid_grade        in ghr_api.pos_valid_grade_type
                            ,p_loc_info               in ghr_api.loc_info_type
                            ,p_sf52_from_data         in ghr_api.prior_sf52_data_type
                            ,p_personal_info		  in ghr_api.personal_info_type
                            ,p_agency_code            in varchar2
                            ,p_gov_awards_type        in ghr_api.government_awards_type
                            ,p_perf_appraisal_type    in ghr_api.performance_appraisal_type
                            ,p_health_plan            in varchar2
                            ,p_asg_non_sf52           in ghr_api.asg_non_sf52_type
                            --Pradeep
 			                ,p_premium_pay            in ghr_api.premium_pay_type
                            --Bug#5036370
                            ,p_per_service_oblig      in ghr_api.per_service_oblig_type
                            ,p_within_grade_incr      in ghr_api.within_grade_increase_type --Bug 5527363
                           )  IS
	l_assignment_found      boolean := FALSE;
	l_per_system_status	VARCHAR2(30);

	/* Get Person Type */
	l_person_type_id		per_people_f.person_type_id%type;
	l_person_usr_type    	per_person_types.user_person_type%type;
	l_person_sys_type		per_person_types.system_person_type%type;
	l_psn_status 		per_positions.status%type;

	l_part_time_hr          ghr_pa_requests.part_time_hours%type;
	l_work_schedule_code	ghr_pa_requests.WORK_SCHEDULE%type;

	l_To_Pay_Basis          ghr_pa_requests.TO_PAY_BASIS%type;
	l_To_Basic_Pay          ghr_pa_requests.TO_BASIC_PAY%type;
	l_To_Locality_Adj       ghr_pa_requests.TO_LOCALITY_ADJ%type;
	l_To_adj_basic_pay      ghr_pa_requests.TO_ADJ_BASIC_PAY%type;
	l_To_other_pay      	ghr_pa_requests.TO_OTHER_PAY_AMOUNT%type;
	l_To_total_pay      	ghr_pa_requests.TO_TOTAL_SALARY%type;

    l_to_step_or_rate       ghr_pa_requests.to_step_or_rate%type;
    l_from_step_or_rate     ghr_pa_requests.from_step_or_rate%type;

	l_Retention_Allowance   ghr_pa_requests.TO_RETENTION_ALLOWANCE%type;
	l_staffing_differential ghr_pa_requests.TO_STAFFING_DIFFERENTIAL%type;

	l_effective_date		ghr_pa_requests.EFFECTIVE_DATE%type;

	l_AUO                   varchar2(30):=null;
	l_Availablility		    varchar2(30):=null;
	l_assignment_id		    ghr_pa_requests.EMPLOYEE_ASSIGNMENT_ID%type;
      l_prem_pay              varchar2(30);
      l_amount                number;
	l_multiple_error_flag   boolean;
      l_session               ghr_history_api.g_session_var_type;
      l_message_set           boolean;
      l_open_pay_fields       boolean;
      l_for_810_count         number;
      l_op_810                number;
      l_op_818                number;
      l_op_819                number;
      l_reta_amount           number;
      l_supv_amount           number;
      l_stad_amount           number;
      l_ap_amount           number;
      l_auo_amount           number;
      l_exists                boolean;
      l_noa_family_code       ghr_families.noa_family_code%type;
      l_to_agency_code      per_people_extra_info.pei_information8%type;
      l_to_supervisor_diff   ghr_pa_requests.TO_SUPERVISORY_DIFFERENTIAL%type ;
      l_award_salary    ghr_pa_requests.from_basic_pay%type ;   -- Bug 3376761

      l_slr_recur_amount     number;
      l_slr_lumpsum          number;

 --Pradeep
      l_mddds_special_pay_amount number;
      l_mddds_specia_pay_nte_date date;
      l_mddds_pay_amount_old number;
      l_mddds_pay_nte_date_old ghr_pa_request_extra_info.rei_information12%TYPE;

      l_premium_pay_ind VARCHAR2(30);
      l_hz_ind            VARCHAR2(30);
      l_edp_ind           VARCHAR2(30);

      l_eff_start_date Date;
      l_hz_eff_start_date Date;
      l_edp_eff_start_date Date;
      l_null_list  varchar2(2000);
      l_new_line  VARCHAR2(1) := substr('
	   ',1,1);
      -- Bug#5036370
      l_serv_oblig_code       per_people_extra_info.pei_information3%type;
      l_serv_oblig_stdt       DATE;
      l_serv_oblig_enddt      DATE;
--Open Pay Range variables.
      l_row_high              number;
      l_row_low               number;
      l_user_table_id         number;
      l_pay_plan              VARCHAR2(30);
      l_grade_or_level        VARCHAR2(60);
      l_retained_grade        ghr_pay_calc.retained_grade_rec_type;

------- Retrieve Position Status --
cursor c_get_psn_status(p_position_id number) is
	select pps.status from hr_all_positions_f pps  -- Venkat - Position DT
	where pps.position_id = p_position_id
        and p_pa_request_rec.effective_date between pps.effective_start_date
               and pps.effective_end_date;
-------

------- Retrieve Person Types (System/User) --
cursor c_get_person_types(p_person_id number, p_eff_date date) is
	select ppt.system_person_type, ppt.user_person_type  from PER_PERSON_TYPES ppt, PER_PEOPLE_F ppf
	where ppf.person_id = p_person_id
	and trunc(p_eff_date) between ppf.effective_start_date and ppf.effective_end_date
	and   ppt.person_type_id = ppf.person_type_id;
-------

-------
cursor c_asg_posn_check(p_To_Position_id number, p_person_id number, p_eff_date date) is
   select  asg1.assignment_id
   from    per_assignments_f asg1
   where
   asg1.person_id            <> p_person_id
   and     asg1.position_id   = p_to_position_id
   and     asg1.assignment_type NOT IN ('B','A')
   and     (asg1.effective_start_date >= p_eff_date
            or p_eff_date
            between asg1.effective_start_date and asg1.effective_end_date);

cursor c_asg_posn_check1(p_To_Position_id number, p_person_id number, p_eff_date date) is
   select  asg1.assignment_id
   from    per_assignments_f asg1
   where   asg1.person_id            <> p_person_id
   and     asg1.position_id   = p_to_position_id
   and     asg1.assignment_type NOT IN ('B','A')
   and     (p_eff_date
	    between asg1.effective_start_date and asg1.effective_end_date);

-------

------- Retrieve Person Sytem Status --
cursor c_asg_stat_type (p_asg_id number, p_eff_date date, p_status char) is
	Select per_system_status from per_assignment_status_types pst, per_assignments_f paf
	where paf.assignment_status_type_id = pst.assignment_status_type_id
        and   paf.assignment_type <> 'B'
	and   paf.assignment_id = p_asg_id
	and   pst.per_system_status = p_status
	and trunc(p_eff_date) between paf.effective_start_date and paf.effective_end_date;
-------
--Bug# 883594 -- Venkat
--Begin Bug# 7501214. added the SUBSTR condition for lac_lookup_code for all the 4 cursors
-- to avoid the error while checking the LAC codes which are duplicated. Like VWN and VWN1 etc.
cursor c_first_la_code1 is
    select  1
    from   ghr_noac_las       nla
    where   nla.nature_of_action_id  = p_pa_request_rec.first_noa_id
    and     SUBSTR(nla.lac_lookup_code,1,3) = p_pa_request_rec.first_action_la_code1
    and     nla.valid_first_lac_flag = 'Y'
    and     nvl(p_pa_request_rec.effective_date,trunc(sysdate))
    between nvl(nla.date_from,nvl(p_pa_request_rec.effective_date,trunc(sysdate)))
    and     nvl(nla.date_to,nvl(p_pa_request_rec.effective_date,trunc(sysdate)));

cursor c_first_la_code2 is
    select  1
    from   ghr_noac_las       nla
    where   nla.nature_of_action_id  = p_pa_request_rec.first_noa_id
    and     SUBSTR(nla.lac_lookup_code,1,3) = p_pa_request_rec.first_action_la_code2
    and     nla.valid_second_lac_flag = 'Y'
    and     nvl(p_pa_request_rec.effective_date,trunc(sysdate))
    between nvl(nla.date_from,nvl(p_pa_request_rec.effective_date,trunc(sysdate)))
    and     nvl(nla.date_to,nvl(p_pa_request_rec.effective_date,trunc(sysdate)));

cursor c_second_la_code1 is
    select  1
    from   ghr_noac_las       nla
    where   nla.nature_of_action_id  = p_pa_request_rec.second_noa_id
    and     SUBSTR(nla.lac_lookup_code,1,3)  = p_pa_request_rec.second_action_la_code1
    and     nla.valid_first_lac_flag = 'Y'
    and     nvl(p_pa_request_rec.effective_date,trunc(sysdate))
    between nvl(nla.date_from,nvl(p_pa_request_rec.effective_date,trunc(sysdate)))
    and     nvl(nla.date_to,nvl(p_pa_request_rec.effective_date,trunc(sysdate)));

cursor c_second_la_code2 is
    select  1
    from   ghr_noac_las       nla
    where   nla.nature_of_action_id  = p_pa_request_rec.second_noa_id
    and     SUBSTR(nla.lac_lookup_code,1,3) = p_pa_request_rec.second_action_la_code2
    and     nla.valid_second_lac_flag = 'Y'
    and     nvl(p_pa_request_rec.effective_date,trunc(sysdate))
    between nvl(nla.date_from,nvl(p_pa_request_rec.effective_date,trunc(sysdate)))
    and     nvl(nla.date_to,nvl(p_pa_request_rec.effective_date,trunc(sysdate)));
--end Bug# 7501214
CURSOR cur_temp_step IS
SELECT  rei_information3 temp_step
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_rec.pa_request_id
AND     information_type = 'GHR_US_PAR_RG_TEMP_PROMO';
l_temp_step     per_people_extra_info.pei_information9%type := hr_api.g_varchar2;

-- Family Code
-- Bug # 1145963
-- Bug#3941541 Added effective date condition.
 Cursor c_noa_family_code(l_effective_date DATE) IS
   Select fam.noa_family_code
   from   ghr_noa_families    nfa,
   ghr_families               fam
   where  nfa.nature_of_action_id  = p_pa_request_rec.first_noa_id
   and    nfa.noa_family_code      = fam.noa_family_code
   and    fam.update_hr_flag       = 'Y'
   and    l_effective_date between NVL(nfa.start_date_active,l_effective_date)
                               and NVL(nfa.end_date_active,l_effective_date);



 CURSOR check_for_supervisory IS
        select eev.screen_entry_value
          from pay_element_types_f elt,
               pay_input_values_f ipv,
               pay_element_entries_f ele,
               pay_element_entry_values_f eev
         where trunc(p_pa_request_rec.effective_date) between elt.effective_start_date
                                   and elt.effective_end_date
           and trunc(p_pa_request_rec.effective_date) between ipv.effective_start_date
                                   and ipv.effective_end_date
           and trunc(p_pa_request_rec.effective_date) between ele.effective_start_date
                                   and ele.effective_end_date
           and trunc(p_pa_request_rec.effective_date) between eev.effective_start_date
                                   and eev.effective_end_date
           and elt.element_type_id = ipv.element_type_id
           and ele.assignment_id = p_pa_request_rec.employee_assignment_id
           and elt.element_name IN ('Supervisory Differential','AUO','Availability Pay')
           and ipv.input_value_id = eev.input_value_id
           and ele.element_entry_id + 0 = eev.element_entry_id ;

	-- Sundar 3263109 To find out if any future actions exist.
 CURSOR c_future_actions(c_person_id ghr_pa_requests.person_id%type, c_effective_date ghr_pa_requests.effective_date%type) IS
    SELECT par.pa_request_id futr_rpa
    FROM ghr_pa_routing_history prh
		,ghr_pa_requests        par
    WHERE prh.pa_request_id  = par.pa_request_id
	AND par.person_id = c_person_id
	AND par.effective_date > c_effective_date
	AND    prh.pa_routing_history_id = (SELECT MAX(prh2.pa_routing_history_id)
                                      FROM   ghr_pa_routing_history prh2
                                      WHERE  prh2.pa_request_id = par.pa_request_id)
	AND    prh.action_taken IN ('FUTURE_ACTION','UPDATE_HR_COMPLETE')
	AND    par.NOA_FAMILY_CODE <> 'CANCEL'
	AND (   ( par.second_noa_code IS NULL
        AND NVL(par.first_noa_cancel_or_correct,'X') <> 'CANCEL'
          )
     OR  (  par.second_noa_code IS NOT NULL
        AND  par.NOA_FAMILY_CODE <> 'CORRECT'
        AND ( NVL(par.first_noa_cancel_or_correct,'X') <> 'CANCEL'
          OR NVL(par.second_noa_cancel_or_correct,'X') <> 'CANCEL'
            )
         )
     OR  (  par.second_noa_code IS NOT NULL
        AND  par.NOA_FAMILY_CODE = 'CORRECT'
        AND  NVL(par.second_noa_cancel_or_correct,'X') <> 'CANCEL'
         )
       );

 l_futr_actions ghr_pa_requests.pa_request_id%type;

       --
       -- Madhuri 3417859 Start fix of variables and cursor
       --
  l_user_tab_id         pay_user_tables.user_table_id%type;

  cursor c_pay_tab_essl
  is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) = 'ESSL'
  and user_table_id = l_user_tab_id;

  l_essl_table          BOOLEAN := FALSE;

       --
       -- Madhuri 3417859 End fix of variables and cursors
       --
CURSOR  cur_mddds_pay IS
 SELECT  NVL(rei_information3,0)+NVL(rei_information4,0)+NVL(rei_information5,0)+NVL(rei_information6,0)
	+NVL(rei_information7,0)+NVL(rei_information8,0)+NVL(rei_information9,0)+NVL(rei_information10,0) amount,
	 rei_information12 nte_date,rei_information13 premium_pay_ind

 FROM    ghr_pa_request_extra_info
 WHERE   pa_request_id = p_pa_request_rec.pa_request_id
 AND     information_type = 'GHR_US_PAR_MD_DDS_PAY';

CURSOR  cur_premium_pay IS
 SELECT  NVL(rei_information3,0) premium_pay_ind
 FROM    ghr_pa_request_extra_info
 WHERE   pa_request_id = p_pa_request_rec.pa_request_id
 AND     information_type = 'GHR_US_PAR_PREMIUM_PAY';


CURSOR  cur_premium_pay_ind IS
 SELECT  NVL(rei_information3,0) premium_pay_ind
 FROM    ghr_pa_request_extra_info
 WHERE   pa_request_id = p_pa_request_rec.pa_request_id
 AND     information_type = 'GHR_US_PAR_PREMIUM_PAY_IND';

 CURSOR cur_job_code is
 SELECT from_occ_code
 FROM   ghr_pa_requests
 WHERE  pa_request_id = p_pa_request_rec.pa_request_id;

 l_occ_code    ghr_pa_requests.from_occ_code%TYPE;

--
--
CURSOR  cur_repay_sch IS
SELECT  rei_information8 repay_sch,
	rei_information9 review_Date
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_rec.pa_request_id
AND     information_type = 'GHR_US_PAR_STUDENT_LOAN';

l_repay_sch   varchar2(2);
l_review_date date;

CURSOR cur_studloan_ele_end_date(
     p_ele_name  pay_element_types_f.element_name%type,
     p_asg_id    ghr_pa_requests.employee_assignment_id%type)
IS
    select ele.effective_end_date
    from pay_element_types_f   elt,
         pay_element_links_f   ell,
         pay_element_entries_f ele
    where p_pa_request_rec.effective_date between elt.effective_start_date and elt.effective_end_date
      and p_pa_request_rec.effective_date between ell.effective_start_date and ell.effective_end_date
      and p_pa_request_rec.effective_date between ele.effective_start_date and ele.effective_end_date
    and elt.element_type_id = ell.element_type_id
    and ell.element_link_id = ele.element_link_id
    and ele.assignment_id = p_asg_id
    and elt.element_name  = p_ele_name;

/**** Commented because FP.F level DB is not having the element_type_id column
   in pay_element_entries_f.

SELECT effective_end_date
FROM   pay_element_entries_f
WHERE  element_type_id = (SELECT element_type_id
                          FROM   pay_element_types_f
			  WHERE  element_name = p_ele_name
			  and    p_pa_request_rec.effective_date between effective_start_Date and effective_end_date )
  and  assignment_id  = p_asg_id;
****/
-- 3562069

--Start of 3604377
l_pos_ei_grade_data per_position_extra_info%rowtype;

CURSOR cur_grd(p_grade_id per_grades.grade_id%TYPE) IS
  SELECT gdf.segment1 pay_plan
        ,gdf.segment2 grade_or_level
  FROM  per_grade_definitions gdf
       ,per_grades            grd
  WHERE grd.grade_id = p_grade_id
  AND   grd.grade_definition_id = gdf.grade_definition_id;
--End of 3604377

l_appt_type     PER_PEOPLE_EXTRA_INFO.pei_information3%type;
l_ele_name      pay_element_types_f.element_name%type;
l_ele_end_date  pay_element_entries_f.effective_end_date%type;

l_per_ei_data   PER_PEOPLE_EXTRA_INFO%rowtype;
-- Bug#3928110
--l_percent NUMBER(8,2);

l_max_allowed_amount NUMBER;
l_min_allowed_amount NUMBER;
l_temp varchar2(100);


-- Start of bug 4016362

/***** Added Cursor BG_rec to get business group id given asg_id ****/

Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;

ll_bg_id                    per_all_assignments_f.business_group_id%type;

--  End of bug 4016362
--  Start of 3563491
l_asg_ei_data		per_assignment_extra_info%rowtype;
l_nte_date_flg		BOOLEAN:=FALSE;

--
CURSOR cur_nte_check(p_asg_id	per_assignments_f.assignment_id%TYPE,
		     p_eff_date ghr_pa_requests.effective_date%TYPE)
IS
SELECT user_status
FROM   per_assignment_status_types pst, per_assignments_f paf
WHERE  paf.assignment_status_type_id = pst.assignment_status_type_id
AND    paf.assignment_type <> 'B'
AND    paf.assignment_id = p_asg_id
AND   (p_eff_date) BETWEEN paf.effective_start_date AND paf.effective_end_date;

l_asg_status	per_assignment_status_types.user_status%type;
--
--Begin Bug# 4748927
l_award_amount NUMBER;
--End Bug# 4748927

    -- Bug#5039997 RRR Changes. Added variables, cursors.
	-- Begin Bug# 5039100
	l_inct_ctgy_pcnt	   NUMBER;
	-- End Bug# 5039100
    l_biweekly_end_date    DATE;
    l_futr_incentive_cnt   NUMBER;
    l_cnt                  NUMBER(2);
    l_min_date             DATE;
    l_max_date             DATE;
    l_min_months           NUMBER;
    l_max_months           NUMBER;

    CURSOR c_incentives IS
    SELECT pa_incentive_category_end_date,pa_incentive_category_percent
    FROM   ghr_pa_incentives
    WHERE  pa_request_id = p_pa_request_rec.pa_request_id
    AND    pa_incentive_category = 'Biweekly';

    CURSOR c_incentive_cnt IS
    SELECT count(*) cnt
    FROM   ghr_pa_incentives
    WHERE  pa_request_id = p_pa_request_rec.pa_request_id;

    -- Bug#5041985
    CURSOR c_futr_incentives(l_asg_id NUMBER, l_effective_date DATE) IS
    SELECT  count(*) cnt
    FROM    pay_element_entries_f ee, pay_element_types_f et
    WHERE   ee.assignment_id = l_asg_id
      AND   ee.element_type_id = et.element_type_id
      AND   et.element_name like '%Incentive%'
      AND   ee.effective_start_date > l_effective_date;

   CURSOR    cur_noa_id(l_noa_id NUMBER,l_noa_fam_code VARCHAR2, l_eff_date DATE) is
   SELECT   1
    FROM    ghr_noa_families  noa
    WHERE   noa.nature_of_action_id = l_noa_id
    AND     noa.noa_family_code     = l_noa_fam_code
    AND     l_eff_date BETWEEN nvl(noa.start_date_active,l_eff_date)
                                 AND nvl(noa.end_date_active,l_eff_date)
    AND     noa.enabled_flag        = 'Y';
   -- RRR Changes

 --bug 5482191
   l_psi   VARCHAR2(10);


    /* Bug#5132121  Service Obligation for Student Loan and MD/DDS */
    l_serv_oblg_type       VARCHAR2(2);
    l_serv_oblg_start_date VARCHAR2(22);
    l_serv_oblg_end_date   VARCHAR2(22);

    CURSOR cur_service_oblg_ei IS
      SELECT rei_information3 srvc_oblg_type,
             rei_information4 srvc_oblg_st_date,
             rei_information5 srvc_oblg_end_date
        FROM ghr_pa_request_extra_info
       WHERE pa_request_id = p_pa_request_rec.pa_request_id AND
             information_type = 'GHR_US_PAR_SERVICE_OBLIGATION';
    /* Bug#5132121  Service Obligation for Student Loan and MD/DDS */

    --8528195
    l_adj_basic_pay_amt       NUMBER;
    l_special_info_type       ghr_api.special_information_type;
    l_value                   VARCHAR2(60);
    l_multi_error_flag        BOOLEAN;
    --8528195

Begin

     ghr_history_api.get_g_session_var(l_session);

/* Do not allow update to HR if Position_Status is Invalid */

	FOR v_get_psn_status IN
		c_get_psn_status(p_pa_request_rec.to_position_id) LOOP
		l_psn_status    :=  v_get_psn_status.status;
	END LOOP;

	If l_psn_status = 'INVALID' then
        -- If position is invalid instead of erroring out straight away,
        -- validate it and if valid, update the status, else give out the error
          begin
            ghr_validate_perwsdpo.validate_perwsdpo(p_pa_request_rec.to_position_id,p_pa_request_rec.effective_date);
            ghr_validate_perwsdpo.update_posn_status(p_pa_request_rec.to_position_id,p_pa_request_rec.effective_date);
          exception
            when others then
       	      hr_utility.set_message(8301,'GHR_38288_POSITION_INVALID');
 	      hr_utility.raise_error;
          end;
	End If;
    l_psi := ghr_pa_requests_pkg.get_personnel_system_indicator(p_pa_request_rec.to_position_id,
                                                                           p_pa_request_rec.effective_date);

/* Get Person Status and last of DDF retrivals.

/* Produce a warning if Person_User_Type is Invalid */
/* Best solution would offer a prompt of continue Y/N */
	FOR v_get_person_types IN
		c_get_person_types(p_pa_request_rec.person_id,p_pa_request_rec.effective_date) LOOP
		l_person_sys_type	   := v_get_person_types.system_person_type;
		l_person_usr_type    := v_get_person_types.user_person_type;
	END LOOP;
	-- Bug 4377361 included EMP_APL for person type condition
	If l_person_sys_type IN ('EMP','EMP_APL') and l_person_usr_type = 'Invalid Employee' then
		hr_utility.set_message(8301,'GHR_38289_PERSON_INVALID');
   	 	--hr_utility.show_error;
	End If;

  FOR c_noa_family_code_rec in c_noa_family_code(p_pa_request_rec.effective_date) LOOP
    l_noa_family_code := c_noa_family_code_rec.noa_family_code;
    --exit;
  END LOOP;

/*Bug 5909274 :-Throw an error message when NOAC is 890 , Legal Authority codes are QUM/QUA and the prior Pay Plan in block 8 is not 'GM' */

  IF p_pa_request_rec.first_action_la_code1 = 'QUM' AND
     p_pa_request_rec.first_action_la_code2 = 'QUA' AND
     p_pa_request_rec.first_noa_code = '890'        AND
     p_pa_request_rec.from_pay_plan <> 'GM' 		THEN
	hr_utility.set_message(8301, 'GHR_38553_GM_QUM_QUA');
        hr_utility.raise_error;
  END IF;

/* Do not allow creation of assignment if Position is Primary Assignment of another Person */
/* Cursor includes check to exclude from Position. */
	/* only do this check if this is not a future action.*/
/* Bug 3454993: Check the following condition only if it is a cancellation action. (as a temp soln)*/
/* (Also we have to confirm that is it specific to separation cancellation action) */

 --Start of Bug 3751864
    --In case of Appointment only we need to check whether any Assginment is found in future.
    IF  (p_pa_request_rec.effective_date <= SYSDATE) THEN
        IF ( l_noa_family_code IN (
				'APP'         , 'CONV_APP'     , 'EXT_NTE'      , 'GHR_SAL_CHG_LG',
				'GHR_SAL_PROM', 'POS_ABOLISH'  , 'POS_CHG'      , 'POS_ESTABLISH',
				'POS_REVIEW'  , 'REASSIGNMENT' , 'RECRUIT_FILL' , 'RETURN_TO_DUTY')
        -- Bug#5063298 Restrict this validation for Correction actions.
        AND l_session.noa_id_correct is NULL
	    ) THEN
            FOR v_asg_posn_check IN c_asg_posn_check(p_pa_request_rec.TO_Position_id,
                                                     p_pa_request_rec.person_id,
                                                     p_pa_request_rec.effective_date)
            LOOP
                l_assignment_found := TRUE;
            END LOOP;

            IF l_assignment_found THEN
                hr_utility.set_message(8301,'GHR_38290_POSITION_ENCUMBERED');
                hr_utility.raise_error;
            END IF;

            -- For other than Appt. we need to check whether any assignment is existing as on that date.

        ELSE
            FOR v_asg_posn_check1 IN c_asg_posn_check1(p_pa_request_rec.TO_Position_id,
                                                       p_pa_request_rec.person_id,
                                                       p_pa_request_rec.effective_date)
            LOOP
                l_assignment_found := TRUE;
            END LOOP;

            IF l_assignment_found THEN
                hr_utility.set_message(8301,'GHR_38290_POSITION_ENCUMBERED');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
--End of Bug 3751864

/* If Family is appointment then employee_assignment_type must be ACCEPTED */
/* If Family is Return to Duty then employee_assignment_type must be SUSP_ASSIGN */
/* If Family is other than 2 above then employee_assignment_type must be ACTIVE_ASSIGN */
		/* NOA_Family will not be coded as below */

l_assignment_found := FALSE;
If l_person_sys_type = 'APL' then
    for c_asg_stat_type_rec in c_asg_stat_type (p_pa_request_rec.employee_assignment_id
                                               ,p_pa_request_rec.effective_date
                                               ,'ACCEPTED') loop
      l_assignment_found := TRUE;
    end loop;
    if not l_assignment_found then
      hr_utility.set_message(8301, 'GHR_38291_NOT_ACCEPTED');
      hr_utility.raise_error;
    end if;
-- Bug 4377361 included EMP_APL for person type condition
Elsif l_person_sys_type IN ('EMP','EMP_APL') then
  -- If employees are added to APP family then may need to change this!!
  -- Bug# 1145963 -- Fetching noa_family_code based on current first_noa_id since
  -- p_pa_request_rec.noa_family_code always point to family code of original first_noa_id
  hr_utility.set_location('GHRVALID-passed family code'||p_pa_request_rec.noa_family_code,1);
  hr_utility.set_location('GHRVALID-current family code'||l_noa_family_code,2);
  hr_utility.set_location('GHRVALID-noa code'||p_pa_request_rec.first_noa_code,3);

  IF l_noa_family_code = 'RETURN_TO_DUTY' and l_session.noa_id_correct is  null THEN
    for c_asg_stat_type_rec in c_asg_stat_type (p_pa_request_rec.employee_assignment_id
                                               ,p_pa_request_rec.effective_date
                                               ,'SUSP_ASSIGN') LOOP
      l_assignment_found := TRUE;
    END LOOP;
    IF not l_assignment_found THEN
      hr_utility.set_message(8301, 'GHR_38292_NOT_SUSP_ASSIGN');
      hr_utility.raise_error;
    END IF;
/*
-- Note : Commenting the following 'Else part' as a temporary fix to bug 637083
-- Should be revisiting this code when we have the NOA specific Bus. rules in place
  Else
    for c_asg_stat_type_rec in c_asg_stat_type (p_pa_request_rec.employee_assignment_id
                                               ,p_pa_request_rec.effective_date
                                               ,'ACTIVE_ASSIGN') loop
      l_assignment_found := TRUE;
    end loop;
    if not l_assignment_found then
      hr_utility.set_message(8301, 'GHR_38293_NOT_ACTIVE_ASSIGN');
      hr_utility.raise_error;
    end if;
*/
  End If;
End If;

/* Sundar  Bug 3263109/3263096 If doing separation, check if any future actions exist. If it exist
	throw an error */
	IF (l_noa_family_code = 'SEPARATION') THEN
		FOR v_future_actions IN c_future_actions(p_pa_request_rec.person_id,p_pa_request_rec.effective_date) LOOP
		   l_futr_actions := v_future_actions.futr_rpa;
		   EXIT;
		END LOOP;
        IF (l_futr_actions IS NOT NULL) THEN
				hr_utility.set_message(8301,'GHR_38847_NO_SEP_WITH_FUTR');
		        hr_utility.raise_error;
        END IF;
	END IF;
	-- End Sundar Bug 3263109/3263096


    --- Start fix Code 3417859
    IF ( p_pa_request_rec.effective_date >= to_date('2004/01/11','YYYY/MM/DD') ) THEN
       IF  ( p_pa_request_rec.to_pay_plan in ('ES','EP','IE','FE') ) THEN

	   If  p_pa_request_rec.first_noa_code ='893' THEN
	       hr_utility.set_message(8301, 'GHR_38889_SES_WGI_NO');
	       hr_utility.raise_error;
	   END IF;

           l_user_tab_id := ghr_pay_calc.get_user_table_id(
                            p_position_id      => p_pa_request_rec.to_position_id
                           ,p_effective_date   => p_pa_request_rec.effective_date
                           );

           l_essl_table := FALSE;
           FOR essl_rec IN c_pay_tab_essl
           LOOP
               l_essl_table := TRUE;
           END LOOP;

           IF ( l_essl_table and p_pa_request_rec.to_step_or_rate <>'00' ) THEN
             hr_utility.set_message(8301, 'GHR_38849_SES_TO_STEP_OR_RATE');
             hr_utility.raise_error;
           END IF;
       END IF;
    END IF;
    --- End fix code 3417859
    --Start of Bug#3604377
    IF ( p_pa_request_rec.effective_date >= to_date('2004/01/11','YYYY/MM/DD') ) THEN
       IF  ( p_pa_request_rec.to_pay_plan in ('EE') ) THEN

	   IF  p_pa_request_rec.first_noa_code ='893' THEN
	       hr_utility.set_message(8301, 'GHR_38897_EE_WGI_NO');
	       hr_utility.raise_error;
	   END IF;

           l_user_tab_id := ghr_pay_calc.get_user_table_id(
                            p_position_id      => p_pa_request_rec.to_position_id
                           ,p_effective_date   => p_pa_request_rec.effective_date
                           );

           l_essl_table := FALSE;
           FOR essl_rec IN c_pay_tab_essl
           LOOP
               l_essl_table := TRUE;
           END LOOP;

           IF ( l_essl_table and p_pa_request_rec.to_step_or_rate <>'00' ) THEN
             hr_utility.set_message(8301, 'GHR_38895_EE_TO_STEP_OR_RATE');
             hr_utility.raise_error;
           END IF;
       END IF;
    END IF;
    --End of Bug#3604377
-- Bug# 1893483
/* Check whether agency code transferred to entered or not in case of 352 separation actions */
   l_to_agency_code := p_per_sep_retire.agency_code_transfer_to;
   If p_pa_request_rec.first_noa_code = '352' and
      l_to_agency_code is NULL THEN
       hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
       fnd_message.set_token('REQUIRED_LIST','Agency Code Transferred to');
       hr_utility.raise_error;
   End If;
-- Bug# 1893483

/* check part hours if work schedule is not F,G,B */
	l_work_schedule_code:=p_pa_request_rec.WORK_SCHEDULE;
      l_part_time_hr      :=p_pa_request_rec.part_time_hours;
    If l_work_schedule_code not in ('F','G','B','I','J') and
	 l_part_time_hr is null then
		      hr_utility.set_message(8301, 'GHR_38333_PART_TIME_HR_REQ');
      		hr_utility.raise_error;
    end if;

-- Bug#5036370 RRR Changes
/* Check whether Service Obligation Information is entered for GHR_INCENTIVE Family or Not */
   l_serv_oblig_code := p_per_service_oblig.service_oblig_type_code;
          hr_utility.set_location('RRR 0'||p_per_service_oblig.service_oblig_start_date,10);
          hr_utility.set_location('RRR 0'||p_per_service_oblig.service_oblig_end_date,10);
   l_serv_oblig_stdt := fnd_date.canonical_to_date(p_per_service_oblig.service_oblig_start_date);
   l_serv_oblig_enddt := fnd_date.canonical_to_date(p_per_service_oblig.service_oblig_end_date);

    IF (l_noa_family_code = 'GHR_INCENTIVE'  OR
         (p_pa_request_rec.first_noa_code = '002' AND p_pa_request_rec.second_noa_code IN ('815','816','827'))
        ) THEN
        -- Bug#5040179
        ghr_process_sf52.g_total_pay_check := 'N';
       FOR  incentive_rec IN c_incentive_cnt
       LOOP
            l_cnt := incentive_rec.cnt;
       END LOOP;
       IF l_cnt <= 0 THEN
          hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
          fnd_message.set_token('REQUIRED_LIST','Incentive Category Details');
          hr_utility.raise_error;
       END IF;
       IF  (p_pa_request_rec.first_noa_code <> '825' OR  p_pa_request_rec.second_noa_code <> '825') THEN --bug# 5983639 removed the NOT
           IF NOT (p_pa_request_rec.first_noa_code = '827' AND p_pa_request_rec.pa_incentive_payment_option = 'B') THEN
               hr_utility.set_location('first noa code '||p_pa_request_rec.first_noa_code,10);
               IF ((l_serv_oblig_code IS NULL OR l_serv_oblig_stdt IS NULL) AND l_session.noa_id_correct IS NULL ) THEN
                   hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
                   fnd_message.set_token('REQUIRED_LIST','Service Obligation Code, Service Obligation Start Date');
                   hr_utility.raise_error;
               End If;
           END IF;
           IF l_serv_oblig_code IS NOT NULL AND l_serv_oblig_stdt IS NOT NULL THEN
               /* Check the Service Obligation Period.*/
		/*Bug # 6738306 "=" added in the below if condition and Token is set for the
		error message*/
               IF l_serv_oblig_stdt >= NVL(l_serv_oblig_enddt,to_date('4712/12/31','YYYY/MM/DD')) THEN
                    hr_utility.set_message(8301,'GHR_38999_STDT_GRTR_ENDDT');
		    FND_MESSAGE.SET_TOKEN('MESSAGE','Service Obligation End Date must be
                         			     greater than Service Obligation Start Date');
                    hr_utility.raise_error;
                END IF;
                IF p_pa_request_rec.first_noa_code = '815' THEN
                    l_min_months := 6;
                    l_max_months := 48;
                ELSIF p_pa_request_rec.first_noa_code = '816' THEN
                    l_min_months := 0;
                    l_max_months := 48;
                END IF;

                l_min_date := ADD_MONTHS(l_serv_oblig_stdt,l_min_months);
                l_max_date := ADD_MONTHS(l_serv_oblig_stdt,l_max_months);
                IF NOT (NVL(l_serv_oblig_enddt,to_date('4712/12/31','YYYY/MM/DD')) BETWEEN l_min_date AND l_max_date) THEN
                    hr_utility.set_message(8301,'GHR_38998_INV_SERVOBL_PERIOD');
                    fnd_message.set_token('NOAC',p_pa_request_rec.first_noa_code);
                    fnd_message.set_token('MIN_PERIOD', to_char(l_min_months)||' Months');
                    fnd_message.set_token('MAX_PERIOD', ' 4 Years');
                    hr_utility.raise_error;
                END IF;
            END IF;
        END IF;
    END IF;
-- Bug#5039997
/*Check whether the Retention Incentive Review Date is entered for NOAC 827 where payment option "B" and
  Effective End Date is NOT NULL */
  IF p_pa_request_rec.first_noa_code = '827' AND p_pa_request_rec.pa_incentive_payment_option = 'B' THEN
      l_cnt := 0;
      For incentive_rec IN c_incentives
      LOOP
            l_biweekly_end_date := incentive_rec.pa_incentive_category_end_date;
			l_inct_ctgy_pcnt := incentive_rec.pa_incentive_category_percent;
            l_cnt := 1;
      END LOOP;
	  -- Begin Bug# 5039100
	  IF l_inct_ctgy_pcnt <> 0 THEN
	  -- End Bug# 5039100
		  IF l_cnt = 1 AND l_biweekly_end_date IS NULL THEN
			IF p_per_group1.retention_inc_review_date IS NULL THEN
				hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
				fnd_message.set_token('REQUIRED_LIST','Retention Incentive Review Date');
				hr_utility.raise_error;
			END IF;
		  END IF;
	  END IF;
  END IF;
  /* Bug 5041985 -- If doing separation, check if any future Incentive elements exists.
     If it exists, throw an error */
	IF (l_noa_family_code = 'SEPARATION') THEN
		FOR v_future_incentives IN c_futr_incentives(p_pa_request_rec.employee_assignment_id,
                                                     p_pa_request_rec.effective_date)
        LOOP
		   l_futr_incentive_cnt := v_future_incentives.cnt;
		   EXIT;
		END LOOP;
        IF (l_futr_incentive_cnt > 0) THEN
				hr_utility.set_message(8301,'GHR_38120_NO_SEP_FUTR_INCN_ELT');
		        hr_utility.raise_error;
        END IF;
	END IF;
 /* Bug#5039691  Verify whether the NOA Code is Valid or not as on the effective date.
    Verify this for all actions EXCEPT correction, cancellation. */
    IF p_pa_request_rec.first_noa_code NOT IN ('001','002') THEN
        l_exists := false;
        FOR noa_id in cur_noa_id(p_pa_request_rec.first_noa_id,
                                 l_noa_family_code,
                                 p_pa_request_rec.effective_date)
        LOOP
            l_exists := true;
            exit;
        END LOOP;
        -- to include logic to check if not valid as of the effective date
        IF NOT l_exists THEN
            hr_utility.set_message(8301, 'GHR_38167_INV_NAT_OF_ACT_FAM');
            hr_utility.raise_error;
        END IF;
    END IF;
-- Bug#5036370 RRR Changes

/* check total pay when pay basis is 'PA' */
	l_To_Pay_Basis:=p_pa_request_rec.TO_PAY_BASIS;
	l_To_Locality_Adj:= p_pa_request_rec.TO_LOCALITY_ADJ;
	l_To_Basic_Pay 	:=p_pa_request_rec.TO_BASIC_PAY;
	l_To_adj_basic_pay  :=  p_pa_request_rec.TO_ADJ_BASIC_PAY;
	l_To_other_pay      :=	p_pa_request_rec.TO_OTHER_PAY_AMOUNT;
	l_To_total_pay      :=	p_pa_request_rec.TO_TOTAL_SALARY;
	l_to_supervisor_diff := p_pa_request_rec.TO_SUPERVISORY_DIFFERENTIAL ;

	if l_To_Pay_Basis ='PA' and
	   nvl(l_To_adj_basic_pay,0) <> nvl(l_To_Basic_Pay,0) + nvl(l_To_Locality_Adj,0) then
		      hr_utility.set_message(8301, 'GHR_38334_ADJ_BASIC_PAY');
      		hr_utility.raise_error;
	end if;
--bug 3584511
      IF (p_pa_request_rec.noa_family_code <> 'GHR_STUDENT_LOAN' and ghr_process_sf52.g_total_pay_check = 'Y') THEN
	if l_To_Pay_Basis ='PA' and
	   nvl(l_To_total_pay,0)  <> nvl(l_To_adj_basic_pay,0)  + nvl(l_To_other_pay,0)  then
		      hr_utility.set_message(8301, 'GHR_38335_TOTAL_PAY');
      		hr_utility.raise_error;
	end if;
      END IF;
/* check staffing diff. */
	l_staffing_differential:=p_pa_request_rec.TO_STAFFING_DIFFERENTIAL;
	If l_staffing_differential is not null and
	   ghr_pay_calc.convert_amount(
               l_staffing_differential,
               'PA',
               p_pa_request_rec.to_pay_basis)
	   > round((nvl(l_To_Basic_Pay,0) * 0.05)) then
		hr_utility.set_message(8301, 'GHR_38344_INVALID_STAFF_DIFF');
      		hr_utility.raise_error;
	end if;

/* check retention allowance */
	l_Retention_Allowance:=p_pa_request_rec.TO_RETENTION_ALLOWANCE;
	-- Code added for Student Loan
	IF p_pa_request_rec.noa_family_code <> 'GHR_STUDENT_LOAN' then
        if l_Retention_Allowance is not null and
        l_Retention_Allowance > (nvl(l_To_Basic_Pay,0) * 0.25) then      -- Bug 3067420 Removed 'ROUND'
		hr_utility.set_message(8301, 'GHR_38345_INVALID_RET_ALLOW');
      		hr_utility.raise_error;
		end if;
	END IF;

-- Modified for FWS

 IF p_pa_request_rec.to_pay_basis ='PH' AND
    (p_pa_request_rec.first_noa_code IN ('818','819') or NVL(l_to_supervisor_diff,0) > 0) THEN
     hr_utility.set_message(8301, 'GHR_38844_NOT_ENTITLED_OTH_PAY');
     hr_utility.raise_error;
 END IF;

 IF p_pa_request_rec.from_pay_basis ='PA' and p_pa_request_rec.to_pay_basis ='PH' THEN
   FOR chk_for_sup_rec IN check_for_supervisory LOOP
      IF nvl(chk_for_sup_rec.screen_entry_value,0) > 0 THEN
         hr_utility.set_message(8301, 'GHR_38844_NOT_ENTITLED_OTH_PAY');
         hr_utility.raise_error;
      END IF;
   END LOOP;
 END IF;

--Modified for FWS

/*  commented it for bug 3218900 by Ashley
   Added for bug 3067420 check supervisiry differential by Ashley
      l_to_supervisor_diff := p_pa_request_rec.TO_SUPERVISORY_DIFFERENTIAL ;

      if l_to_supervisor_diff is not null and
	   ghr_pay_calc.convert_amount(
               l_to_supervisor_diff,
               'PA',
               p_pa_request_rec.to_pay_basis)
                 > (nvl(l_To_Basic_Pay,0) * 0.25) then
   			hr_utility.set_message(8301, 'GHR_SUP_DIFF_AMT_TOO_BIG');
      		hr_utility.raise_error;
	end if;
*/

/* check effective date */
/* Bug# 923276 - Remove 90-day limitation on effective date - Hence commented out - 24th July,1999
  	l_effective_date	:=p_pa_request_rec.EFFECTIVE_DATE;
  	l_effective_date	:=p_pa_request_rec.EFFECTIVE_DATE;
  	if (l_effective_date-sysdate) > 90 then
			hr_utility.set_message(8301, 'GHR_38379_INV_EFFECT_DATE');
      		hr_utility.raise_error;
 	end if;
*/


/* check that AUO and Availability Pay are mutually exclusive for a person */


    If p_pa_request_rec.first_noa_code = '818'  then -- if AUo
       -- check  if the person already gets an AP
      ghr_api.retrieve_element_entry_value
      (P_ELEMENT_NAME          => 'Availability Pay',
 	 P_INPUT_VALUE_NAME      => 'Premium Pay Ind',
	 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
	 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
	 P_VALUE                 => l_Prem_pay,
	 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
       );

      ghr_api.retrieve_element_entry_value
      (P_ELEMENT_NAME          => 'Availability Pay',
 	 P_INPUT_VALUE_NAME      => 'Amount',
	 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
	 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
	 P_VALUE                 => l_amount,
	 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
       );

       If l_prem_pay is not null or
          l_amount   is not null then
         hr_utility.set_message(8301,'GHR_38387_AP_EXISTS');
         hr_utility.raise_error;
       End if;

    Elsif p_pa_request_rec.first_noa_code = '819'  then  -- if AP
        -- check  if the person already gets an AUO
      ghr_api.retrieve_element_entry_value
      (P_ELEMENT_NAME          => 'AUO',
 	 P_INPUT_VALUE_NAME      => 'Premium Pay Ind',
	 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
	 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
	 P_VALUE                 => l_Prem_pay,
	 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
       );

      ghr_api.retrieve_element_entry_value
      (P_ELEMENT_NAME          => 'AUO',
 	 P_INPUT_VALUE_NAME      => 'Amount',
	 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
	 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
	 P_VALUE                 => l_amount,
	 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
       );

       If l_prem_pay is not null or
          l_amount   is not null then
         hr_utility.set_message(8301,'GHR_38388_AUO_EXISTS');
         hr_utility.raise_error;
       End if;
    End if;


/*---- Removed for Bug 708295  Check pay caps
  ghr_pay_caps.do_pay_caps_sql
  (p_effective_date       =>    p_pa_request_rec.effective_date
  ,p_pay_rate_determinant =>    p_pa_request_rec.pay_rate_determinant
  ,p_pay_plan             =>    p_pa_request_rec.to_pay_plan
  ,p_pay_basis            =>    p_pa_request_rec.to_pay_basis
  ,p_to_position_id       =>    p_pa_request_rec.to_position_id
  ,p_basic_pay            =>    p_pa_request_rec.to_basic_pay
  ,p_locality_adj         =>    p_pa_request_rec.to_locality_adj
  ,p_adj_basic_pay        =>    p_pa_request_rec.to_adj_basic_pay
  ,p_total_salary         =>    p_pa_request_rec.to_total_salary
  ,p_other_pay_amount     =>    p_pa_request_rec.to_other_pay_amount
  ,p_au_overtime          =>    p_pa_request_rec.to_au_overtime
  ,p_availability_pay     =>    p_pa_request_rec.to_availability_pay
  ,p_open_pay_fields      =>    l_open_pay_fields
  ,p_message_set          =>    l_message_set
   );
*/

   --
   -- check that the UOM entered on a 872 is Hours.
   -- added for bug#705411
   --
   -- Start Bug 1379280
   if p_pa_request_rec.first_noa_code  in ('846','847','872')  and
      p_pa_request_rec.award_uom <> 'H' then
      hr_utility.set_message(8301,'GHR_38595_INVALID_AWARD_UOM');
      hr_utility.raise_error;
   end if;
   if p_pa_request_rec.first_noa_code  in ('840','841','842','843','844','845','848',
                                           '849','815','816','825','878','879') and
      p_pa_request_rec.award_uom <> 'M' then
      hr_utility.set_message(8301,'GHR_38597_INVALID_AWARD_UOM');
      hr_utility.raise_error;
   end if;
   -- End Bug 1379280

  --Pradeep for 3934195.
  IF p_pa_request_rec.noa_family_code = 'AWARD' THEN
	-- Begin Bug# 4748927
	-- Begin Bug# 5020754
	IF p_pa_request_rec.award_salary IS NULL THEN

	   --8528195
	   l_adj_basic_pay_amt := p_pa_request_rec.from_adj_basic_pay;
  	   IF ((p_pa_request_rec.first_noa_code = '879') OR (p_pa_request_rec.first_noa_code = '002' and
	        p_pa_request_rec.second_noa_code = '879')) THEN

  	      ghr_history_fetch.return_special_information
                        (p_person_id         =>  p_pa_request_rec.person_id,
                         p_structure_name    =>  'US Fed Perf Appraisal',
                         p_effective_date    =>  p_pa_request_rec.effective_date,
                         p_special_info      =>  l_special_info_type
                        );
              if l_special_info_type.segment6 is not null then
                     ghr_api.retrieve_element_entry_value (p_element_name       => 'Adjusted Basic Pay'
                                                          ,p_input_value_name   => 'Amount'
                                                          ,p_assignment_id      => p_pa_request_rec.employee_assignment_id
                                                          ,p_effective_date     => fnd_date.canonical_to_date(l_special_info_type.segment6)
                                                          ,p_value              => l_value
                                                          ,p_multiple_error_flag=> l_multi_error_flag);
                     l_adj_basic_pay_amt := l_value;
              end if;
           END IF;
	   --8528195

		ghr_pay_calc.award_amount_calc (
						 p_position_id		=> p_pa_request_rec.to_position_id
						,p_pay_plan		=> p_pa_request_rec.from_pay_plan
						,p_award_percentage     => NULL
						,p_user_table_id	=> p_pa_request_rec.from_pay_table_identifier
						,p_grade_or_level	=> p_pa_request_rec.from_grade_or_level
						,p_effective_date	=> p_pa_request_rec.effective_date
						,p_basic_pay		=> p_pa_request_rec.from_basic_pay
						,p_adj_basic_pay	=> l_adj_basic_pay_amt
						,p_duty_station_id	=> p_pa_request_rec.duty_station_id
						,p_prd			=> p_pa_request_rec.pay_rate_determinant
						,p_pay_basis		=> p_pa_request_rec.from_pay_basis
						,p_person_id		=> p_pa_request_rec.person_id
						,p_award_amount		=> l_award_amount
						,p_award_salary		=> l_award_salary
						);
	ELSE
		l_award_salary := p_pa_request_rec.award_salary;
	END IF;

	-- End Bug# 5020754
	/*l_award_salary :=  ghr_pay_calc.convert_amount(p_pa_request_rec.from_basic_pay
                                   ,p_pa_request_rec.from_pay_basis,'PA');*/
	-- end Bug# 4748927
	--Use the same Message Name for All.
	hr_utility.set_message(8301,'GHR_38904_AWARD_AMT_TOO_BIG5');

     --bug#5482191


	IF ( p_pa_request_rec.first_noa_code='844'
		OR p_pa_request_rec.second_noa_code='844' ) THEN

		l_max_allowed_amount := 5*l_award_salary/100;
		hr_utility.set_message_token('ALLOWED','5%');

	ELSIF ( p_pa_request_rec.first_noa_code IN ('840','841')
		OR p_pa_request_rec.second_noa_code IN ('840','841')
                OR p_pa_request_rec.first_noa_code IN ('885','886') AND l_psi = '00'
                OR p_pa_request_rec.second_noa_code IN ('885','886') AND l_psi = '00' ) THEN

		l_max_allowed_amount := 25*l_award_salary/100;
		hr_utility.set_message_token('ALLOWED','25%');
	--8528195
	ELSIF (p_pa_request_rec.first_noa_code='879'
		OR p_pa_request_rec.second_noa_code='879') THEN

		l_max_allowed_amount := 20*l_award_salary/100;
		hr_utility.set_message_token('ALLOWED','20%');
	--8528195
	ELSIF ( p_pa_request_rec.first_noa_code IN ('878')
		OR p_pa_request_rec.second_noa_code IN ('878') ) THEN

		l_max_allowed_amount := 35*l_award_salary/100;
		hr_utility.set_message_token('ALLOWED','35%');

        --bug#5482191
	ELSIF (( p_pa_request_rec.first_noa_code IN ('849')
		OR p_pa_request_rec.second_noa_code IN ('849')) and l_psi = '00' ) THEN

		l_max_allowed_amount := 35*l_award_salary/100;
		hr_utility.set_message_token('ALLOWED','35%');



	ELSIF ( p_pa_request_rec.first_noa_code IN ('825','842','843','848')
		OR p_pa_request_rec.second_noa_code IN ('825','842','843','848') ) THEN

		l_max_allowed_amount := 25000;
		hr_utility.set_message(8301,'GHR_38905_AWARD_AMT_TOO_BIG6');
		hr_utility.set_message_token('ALLOWED','$25000');

	END IF;


	IF ( p_pa_request_rec.first_noa_code='816'
		OR p_pa_request_rec.second_noa_code='816' ) THEN

		IF p_pa_request_rec.from_pay_plan = 'EE' THEN
			IF (50*l_award_salary/100) > 50000 THEN
				l_max_allowed_amount := 50000;
			ELSE
				l_max_allowed_amount := 50*l_award_salary/100;
			END IF;
			IF p_pa_request_rec.award_amount > round(l_max_allowed_amount) THEN
				hr_utility.set_message(8301, 'GHR_38898_AWARD_AMT_TOO_BIG3');
				hr_utility.raise_error;
			END IF;
       --3818297 Added NVL
		ELSIF ( ghr_pay_calc.LEO_position( p_prd =>  l_temp
			      ,p_position_id  => NVL(p_pa_request_rec.to_position_id,p_pa_request_rec.from_position_id)
			      ,p_retained_user_table_id => l_temp
			      ,p_duty_station_id => l_temp
			      ,p_effective_date => p_pa_request_rec.effective_date
			      )
		 )  THEN
			l_max_allowed_amount := 25*l_award_salary/100;
			IF l_max_allowed_amount < 15000 THEN
				l_max_allowed_amount := 15000;
			END IF;
			IF p_pa_request_rec.award_amount > round(l_max_allowed_amount) THEN
				hr_utility.set_message(8301, 'GHR_38896_AWARD_AMT_TOO_BIG2');
				hr_utility.raise_error;
			END IF;
       --3818297 Added NVL
		ELSIF (NOT ghr_pay_calc.LEO_position( p_prd =>  l_temp
			      ,p_position_id  => NVL(p_pa_request_rec.to_position_id,p_pa_request_rec.from_position_id)
			      ,p_retained_user_table_id => l_temp
			      ,p_duty_station_id => l_temp
			      ,p_effective_date => p_pa_request_rec.effective_date
			       ) )THEN

			l_max_allowed_amount := 25*l_award_salary/100;
			IF p_pa_request_rec.award_amount > round(l_max_allowed_amount) THEN
				hr_utility.set_message(8301, 'GHR_AWARD_AMT_TOO_BIG');
				hr_utility.raise_error;
			END IF;
		END IF;

	 ELSIF  ( p_pa_request_rec.first_noa_code='815'
		 OR p_pa_request_rec.second_noa_code='815' ) THEN

		IF p_pa_request_rec.from_pay_plan = 'EE' THEN

			IF (50*l_award_salary/100) > 50000 THEN
				l_max_allowed_amount := 50000;
			ELSE
				l_max_allowed_amount := 50*l_award_salary/100;
			END IF;
			IF p_pa_request_rec.award_amount > round(l_max_allowed_amount) THEN
				hr_utility.set_message(8301, 'GHR_38898_AWARD_AMT_TOO_BIG3');
				hr_utility.raise_error;
			END IF;
		ELSE
			l_max_allowed_amount := 25*l_award_salary/100;
			hr_utility.set_message_token('ALLOWED','25%');

		END IF;
	END IF;

	-- Raise an Error if Award Amount is Greater than the Maximum Allowed Amount.
	IF p_pa_request_rec.award_amount > round(l_max_allowed_amount) THEN
		 --Name is already set.
		 hr_utility.raise_error;
	ELSE

		 --If there is no error then clear the message stack.
		 hr_utility.clear_message;

	END IF;

	--Check for Minimum Amount.

	--Use the same Message Name for All.
	hr_utility.set_message(8301, 'GHR_38903_AWARD_AMT_TOO_LESS');

	--Getting the Minimum Allowed Amount.
	IF ( p_pa_request_rec.first_noa_code='879'
		 OR p_pa_request_rec.second_noa_code='879' ) THEN

		l_min_allowed_amount := 5*l_award_salary/100;
		hr_utility.set_message_token('ALLOWED','5%');
	END IF;

	--Raise an Error if Award Amount is Less than the Minimum Allowed Amount.
	IF p_pa_request_rec.award_amount < trunc(nvl(l_min_allowed_amount,0)) THEN
		hr_utility.raise_error;
	ELSE
		-- If there is no error then clear the message stack.
		 hr_utility.clear_message;
	END IF;

   END IF; -- End if of p_pa_request_rec.noa_family_code = 'AWARD'
--Pradeep end of Bug 3934195
   --
   -- Wherever part-time indicator is enterable,
   -- if the Work Schedule is either B, F, G, I, or J,
   -- then the Part-Time Indicator must be null.
   --
   if p_pa_request_rec.noa_family_code in ('APP', 'CHG_HOURS', 'CHG_WORK_SCHED', 'CONV_APP'
                                           ,'REASSIGNMENT', 'RETURN_TO_DUTY') and
      p_pa_request_rec.work_schedule in ('B','F','G','I','J') and
      p_asg_non_sf52.parttime_indicator is not null then
      hr_utility.set_message(8301,'GHR_38621_PART_TIME_IND_NR');
      hr_utility.raise_error;
   end if;
--
-- START fix for 3563491 Madhuri
--
   IF (p_pa_request_rec.noa_family_code = 'EXT_NTE') THEN
       ghr_history_fetch.fetch_asgei (
                      p_assignment_id    =>p_pa_request_rec.employee_assignment_id ,
                      p_information_type => 'GHR_US_ASG_NTE_DATES' ,
                      p_date_effective   => nvl(p_pa_request_rec.effective_date,trunc(sysdate)) ,
                      p_asg_ei_data      =>  l_asg_ei_data
                      );
--   LWOP NTE
      IF p_pa_request_rec.FIRST_NOA_CODE ='773' THEN
	   IF (l_asg_ei_data.aei_information5 is not null and l_asg_ei_data.aei_information6 is not null) Then
	   l_nte_date_flg := TRUE;
	   END IF;
-- Suspension NTE
	   IF (l_asg_ei_data.aei_information7 is not null and l_asg_ei_data.aei_information8 is not null) Then
	   l_nte_date_flg := TRUE;
	   END IF;
--      END IF;
--Furlough NTE
      ELSIF p_pa_request_rec.FIRST_NOA_CODE ='772' THEN
	   IF (l_asg_ei_data.aei_information9 is not null and l_asg_ei_data.aei_information10 is not null) Then
	   l_nte_date_flg := TRUE;
	   END IF;
--
-- CONVERSION TO APPT, POSITION CHANGE NTE etc..
--
      ELSIF p_pa_request_rec.FIRST_NOA_CODE in ('750','760','761','762','765','769','770') THEN
	   IF (l_asg_ei_data.AEI_INFORMATION4 is not null) THEN
	   l_nte_date_flg := TRUE;
	   END IF;
       ELSE
-- LWP NTE
	   IF (l_asg_ei_data.aei_information11 is not null and l_asg_ei_data.aei_information12 is not null) Then
	   l_nte_date_flg := TRUE;
	   END IF;
-- Sabbatical NTE
	   IF (l_asg_ei_data.aei_information13 is not null and l_asg_ei_data.aei_information14 is not null) Then
	   l_nte_date_flg := TRUE;
	   END IF;
      END IF;

	   IF NOT l_nte_date_flg THEN
		FOR cur_nte_check_rec in cur_nte_check (p_pa_request_rec.employee_assignment_id,
							nvl(p_pa_request_rec.effective_date,trunc(sysdate)) )
		LOOP
			l_asg_status	:= cur_nte_check_rec.user_status;
		END LOOP;
            hr_utility.set_message(8301,'GHR_38920_NO_NTE_DATE');
	    hr_utility.set_message_token('ASG_STATUS',l_asg_status);
	    hr_utility.raise_error;
	   END IF;

   END IF;
-- END of fix for 3563491
--

 -- New Termination of RG processing
   -- For 866 actions
   -- The To Position cannot be changed for this nature of action.  Please
   -- process a separate action to change the To Position.
   IF p_pa_request_rec.first_noa_code  = '866'
    AND p_pa_request_rec.from_position_id <> p_pa_request_rec.to_position_id
   THEN
      hr_utility.set_message(8301,'GHR_38693_NO_UPDATE_TO_POS');
      hr_utility.raise_error;
   END IF;
   --
   -- Added the following by skutteti on 08-Nov-99 for bug #983824
   --
   -- For change in work schedule and change in hours,
   -- if the work schedule is P,Q,S or T then the Parttime indicator must not be null
   --
   if p_pa_request_rec.noa_family_code in ('CHG_HOURS', 'CHG_WORK_SCHED') and
      p_pa_request_rec.work_schedule in ('P','Q','S','T') and
      p_asg_non_sf52.parttime_indicator is null then
      hr_utility.set_message(8301,'GHR_PART_TIME_IND_IS_NULL');
      hr_utility.raise_error;
   end if;
-- Student Loan Repayment Code Changes start
-- added for Student Loan Repayment Changes - 3494728 bug
   IF ( p_pa_request_rec.first_noa_code = '817' or p_pa_request_rec.second_noa_code = '817') THEN

     --3562069
      ghr_history_fetch.fetch_peopleei
       (p_person_id          =>  p_pa_request_rec.person_id,
        p_information_type   =>  'GHR_US_PER_GROUP1',
        p_date_effective     =>  nvl(p_pa_request_rec.effective_date,trunc(sysdate)),
        p_per_ei_data        =>  l_per_ei_data
       );


      l_appt_type := l_per_ei_data.pei_information3;

      hr_utility.set_location('The Appointment Type is:  '||l_appt_type,12345);

      IF l_appt_type in ('34','44') THEN
       hr_utility.set_message(8301,'GHR_38878_APPT_TYPE_SCH_C');
       hr_utility.raise_error;
      END IF;

      FOR cur_repay_sch_rec in cur_repay_sch
      LOOP
       l_repay_sch   := cur_repay_sch_rec.repay_sch;
       l_review_date := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(cur_repay_sch_rec.review_date));
      END LOOP;

      IF ( p_pa_request_rec.award_amount > 10000 ) then
       hr_utility.set_message(8301,'GHR_38862_AMT_EXCEEDS_LIMIT');
       hr_utility.raise_error;
      END IF;

      IF l_repay_sch IS NULL THEN
       hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
       hr_utility.set_message_token('REQUIRED_LIST','Repayment Schedule' );
       hr_utility.raise_error;
      END IF;

      IF l_review_date is not null THEN
      IF (l_review_date < p_pa_request_rec.effective_date) THEN
       hr_utility.set_message(8301,'GHR_38863_REVIEW_DATE_LESS');
       hr_utility.raise_error;
      END IF;
      END IF;

      IF l_repay_sch = 'L' THEN
         ghr_api.retrieve_element_entry_value (p_element_name  => 'Student Loan Repayment'
                                      ,p_input_value_name      => 'Amount'
                                      ,p_assignment_id         => p_pa_request_rec.employee_assignment_id
                                      ,p_effective_date        => p_pa_request_rec.effective_date
                                      ,p_value                 => l_slr_recur_amount
                                      ,p_multiple_error_flag   => l_multiple_error_flag);
         if l_slr_recur_amount is not null then
            hr_utility.set_message(8301,'GHR_38864_ERR_CHG_REPAYMNT');
            hr_utility.raise_error;
         end if;
      else
         ghr_api.retrieve_element_entry_value (p_element_name  => 'Student Loan Repayment LumpSum'
                                      ,p_input_value_name      => 'Amount'
                                      ,p_assignment_id         => p_pa_request_rec.employee_assignment_id
                                      ,p_effective_date        => p_pa_request_rec.effective_date
                                      ,p_value                 => l_slr_lumpsum
                                      ,p_multiple_error_flag   => l_multiple_error_flag);

	l_ele_name := 'Student Loan Repayment LumpSum';

	 FOR cur_ele_end_date_rec IN cur_studloan_ele_end_date(l_ele_name,
	                                                       p_pa_request_rec.employee_assignment_id)
	 LOOP
	 l_ele_end_date := cur_ele_end_date_rec.effective_end_date;
	 END LOOP;

	 if (l_slr_lumpsum is not null  and l_session.noa_id_correct is NOT NULL) then
            hr_utility.set_message(8301,'GHR_38864_ERR_CHG_REPAYMNT');
            hr_utility.raise_error;
         elsif (p_pa_request_rec.effective_date <= l_ele_end_date) then
            hr_utility.set_message(8301,'GHR_38867_ERR_ELE_OVERLAPS');
	    hr_utility.set_message_token('EFF_DATE',l_ele_end_date);
            hr_utility.raise_error;
         end if;

      end if;
   end if;
-- Student Loan Repayment Code Changes end here
   --- Start Bug 1551311
   --- check for other pay null for first time 810,818,819 actions

   IF p_pa_request_rec.first_noa_code = '810'
      and l_session.noa_id_correct is NULL THEN
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Retention Allowance',
               p_input_value_name      => 'Amount',
               p_assignment_id         => p_pa_request_rec.employee_assignment_id,
               p_effective_date        => p_pa_request_rec.effective_date,
               p_value                 => l_reta_amount,
               p_multiple_error_flag   => l_multiple_error_flag
               );
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Supervisory Differential',
               p_input_value_name      => 'Amount',
               p_assignment_id         => p_pa_request_rec.employee_assignment_id,
               p_effective_date        => p_pa_request_rec.effective_date,
               p_value                 => l_supv_amount,
               p_multiple_error_flag   => l_multiple_error_flag
               );
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Staffing Differential',
               p_input_value_name      => 'Amount',
               p_assignment_id         => p_pa_request_rec.employee_assignment_id,
               p_effective_date        => p_pa_request_rec.effective_date,
               p_value                 => l_stad_amount,
               p_multiple_error_flag   => l_multiple_error_flag
               );
         hr_utility.set_location('Ret Amount '||l_reta_amount,4);
         hr_utility.set_location('Supv Amount '||l_supv_amount,5);
         hr_utility.set_location('Stad Amount '||l_stad_amount,6);
/* Pradeep commented this for 3306515.

     IF (l_reta_amount is NULL  and
         l_supv_amount is NULL  and
         l_stad_amount is NULL )
       and
       (p_pa_request_rec.to_other_pay_amount is null or
           p_pa_request_rec.to_other_pay_amount = 0 ) THEN
             hr_utility.set_message(8301,'GHR_38589_NULL_OTHER_PAY');
             hr_utility.raise_error;
     END IF;
*/
   END IF;

   --Pradeep.
   IF p_pa_request_rec.first_noa_code = '850'
      OR ( p_pa_request_rec.first_noa_code='002' and p_pa_request_rec.second_noa_code ='850') THEN

	  FOR cur_mddds_pay_rec in cur_mddds_pay
          LOOP
            l_mddds_special_pay_amount := cur_mddds_pay_rec.amount;
            l_mddds_specia_pay_nte_date := fnd_date.canonical_to_date(cur_mddds_pay_rec.nte_date);
	    l_premium_pay_ind           := cur_mddds_pay_rec.premium_pay_ind;
          END LOOP;

	  IF l_premium_pay_ind IS NULL THEN

	    ghr_api.retrieve_element_entry_value
                  (p_element_name          => 'Premium Pay',
                   p_input_value_name      => 'Premium Pay Ind',
                   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                   p_effective_date        => p_pa_request_rec.effective_date,
                   p_value                 => l_premium_pay_ind,
                   p_multiple_error_flag   => l_multiple_error_flag
                   );
             hr_utility.set_location('Premium Pay Ind '|| l_premium_pay_ind,4);

	  END IF;

/*	 IF l_premium_pay_ind IS NOT NULL and p_premium_pay.premium_pay_ind IS NOT NULL THEN

            hr_utility.set_message(8301, 'GHR_38861_PREM_PAY_IND_ALREADY');
            hr_utility.raise_error;

         END IF;

         IF p_premium_pay.premium_pay_ind IS NOT NULL THEN
    	    l_premium_pay_ind := p_premium_pay.premium_pay_ind;
    	    hr_utility.set_location('Premium Pay Ind '|| l_premium_pay_ind,5);
         END IF; --Premium Pay Ind is not coming from p_premium_pay.premium_pay_ind.
*/
         IF ( l_premium_pay_ind IS NULL ) THEN
            l_null_list := 'Premium Pay Indicator';
            hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
    	    fnd_message.set_token('REQUIRED_LIST',l_null_list);
    	    hr_utility.raise_error;
         END IF;

	 --Pradeep. Bug# 3562063 New Business Rules for Title 38
	 IF l_premium_pay_ind NOT IN ( 'K','X' ) THEN
	    hr_utility.set_message(8301,'GHR_38871_850_PREM_PAY');
    	    hr_utility.raise_error;
         END IF;


	 l_occ_code := p_pa_request_rec.from_occ_code;
	 --Bug# 3562063
	 --If Nature of Action is 850 and Occupation Series is 0610, then Premium Pay Indicator can only be K.
	 If ( l_occ_code = '0610' )
	   AND ( l_premium_pay_ind <> 'K' ) THEN

	   hr_utility.set_message(8301,'GHR_38875_850_OCC_SERIES1');
           hr_utility.raise_error;

	 End If;

	 --If Nature of Action is 850 and Occupation Series is 0660, then Premium Pay Indicator can not be K.
	 If ( l_occ_code = '0660' )
	   AND ( l_premium_pay_ind = 'K' ) THEN

	   hr_utility.set_message(8301,'GHR_38876_850_OCC_SERIES2');
           hr_utility.raise_error;

	 End If;
	 ----Bug# 3562063

         If l_premium_pay_ind='K' and l_occ_code NOT IN  ('0602','0603','0610','0680','0681','0682','0683') THEN

           hr_utility.set_message(8301,'GHR_38859_OCC_CD_PREM_PAY_IND');
           hr_utility.raise_error;

         End If;

         If l_premium_pay_ind='X' and l_occ_code NOT IN ('0180','0602','0620','0631','0633','0651','0660','0680') THEN

            hr_utility.set_message(8301, 'GHR_38860_OCC_CD_PREM_PAY_IND');
            hr_utility.raise_error;

         End If;

	 ghr_api.retrieve_element_entry_value
	      (P_ELEMENT_NAME          => 'Availability Pay',
		 P_INPUT_VALUE_NAME      => 'Amount',
		 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
		 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
		 P_VALUE                 => l_ap_amount,
		 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
	       );
	 hr_utility.set_location('AP Amount '||l_ap_amount,7);

         ghr_api.retrieve_element_entry_value
	      (P_ELEMENT_NAME          => 'AUO',
		 P_INPUT_VALUE_NAME      => 'Amount',
		 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
		 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
		 P_VALUE                 => l_auo_amount,
		 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
	       );
	 hr_utility.set_location('AUO Amount '||l_auo_amount,7);
-- Start of bug 4016362
/********* Added Cursor BG_rec to get business group id
           to be passed to get_element_details procedure  *************/

         For BG_rec in Cur_BG(p_pa_request_rec.employee_assignment_id,p_pa_request_rec.effective_date)
         Loop
            ll_bg_id  :=  BG_rec.bg;
	    Exit;
         End Loop;
-- End of Bug 4016362

	 ghr_per_sum.get_element_details
	      (P_ELEMENT_NAME          => 'Hazard Pay',
		 P_INPUT_VALUE_NAME      => 'Premium Pay Ind',
		 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
		 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
		 P_VALUE                 => l_hz_ind,
		 P_EFFECTIVE_START_DATE  => l_hz_eff_start_date,
		 P_BUSINESS_GROUP_ID     => ll_bg_id              -- Bug 4016362
	       );

         ghr_per_sum.get_element_details
	      (P_ELEMENT_NAME            => 'EDP Pay',
		 P_INPUT_VALUE_NAME      => 'Premium Pay Ind',
		 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
		 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
		 P_VALUE                 => l_edp_ind,
		 P_EFFECTIVE_START_DATE  => l_edp_eff_start_date,
		 P_BUSINESS_GROUP_ID     => ll_bg_id             --  Bug 4016362
	       );





        IF ( l_auo_amount is NOT NULL )
	    or ( l_ap_amount IS NOT NULL )
	    or ( l_edp_eff_start_date IS NOT NULL )
	    or ( l_hz_eff_start_date IS NOT NULL ) THEN
             hr_utility.set_message(8301,'GHR_38858_PREM_PAY_OTH_PAY');
             hr_utility.raise_error;
         END IF;

	 --Check whether the elements AUO, AP, Hazard and EDP pay are existing in Future.

	 get_element_details_future(p_element_name         => 'AUO'
                                               ,p_input_value_name     => 'Amount'
                                               ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
                                               ,p_effective_date       => p_pa_request_rec.effective_date
                                               ,p_value                => l_auo_amount
                                               ,p_effective_start_date => l_eff_start_date);

	hr_utility.set_location('AUO Amount '||l_auo_amount,8);
	 get_element_details_future(p_element_name         => 'Availability Pay'
                                               ,p_input_value_name     => 'Amount'
                                               ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
                                               ,p_effective_date       => p_pa_request_rec.effective_date
                                               ,p_value                => l_ap_amount
                                               ,p_effective_start_date => l_eff_start_date);

	 hr_utility.set_location('AP Amount '||l_ap_amount,8);
	 get_element_details_future(p_element_name         => 'Hazard Pay'
                                               ,p_input_value_name     => 'Premium Pay Ind'
                                               ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
                                               ,p_effective_date       => p_pa_request_rec.effective_date
                                               ,p_value                => l_hz_ind
                                               ,p_effective_start_date => l_hz_eff_start_date);

	hr_utility.set_location('Hz Amount '||l_hz_ind,8);
	 get_element_details_future(p_element_name         => 'EDP Pay'
                                               ,p_input_value_name     => 'Premium Pay Ind'
                                               ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
                                               ,p_effective_date       => p_pa_request_rec.effective_date
                                               ,p_value                => l_edp_ind
                                               ,p_effective_start_date => l_edp_eff_start_date);
	hr_utility.set_location('EDP Pay amount'||l_edp_ind,8);

	 IF ( l_auo_amount is NOT NULL )
	    or ( l_ap_amount IS NOT NULL )
	    or ( l_hz_eff_start_date IS NOT NULL )
	    or ( l_edp_eff_start_date IS NOT NULL ) THEN
             hr_utility.set_message(8301,'GHR_38865_PREM_PAY_OTH_PAY_FUT');
             hr_utility.raise_error;
         END IF;


         --To check whether nre date and at least one special pay amount is entered or not

         l_null_list := null;

         If l_mddds_special_pay_amount is NULL or l_mddds_special_pay_amount = 0 THEN

	     ghr_api.retrieve_element_entry_value
                  (p_element_name          => 'MDDDS Special Pay',
                   p_input_value_name      => 'Amount',
                   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                   p_effective_date        => p_pa_request_rec.effective_date,
                   p_value                 => l_mddds_pay_amount_old,
                   p_multiple_error_flag   => l_multiple_error_flag
                   );
             hr_utility.set_location('Amount l_mddds_pay_amount_old '|| l_mddds_pay_amount_old,5);
	     IF  l_mddds_pay_amount_old IS NULL THEN
               l_null_list := 'MD/DDS Special Pay Amount';
             END IF;

         END IF;

	 If  l_mddds_specia_pay_nte_date is  NULL THEN

	     ghr_api.retrieve_element_entry_value
                  (p_element_name          => 'MDDDS Special Pay',
                   p_input_value_name      => 'MDDDS Special Pay NTE Date',
                   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                   p_effective_date        => p_pa_request_rec.effective_date,
                   p_value                 => l_mddds_pay_nte_date_old,
                   p_multiple_error_flag   => l_multiple_error_flag
                   );
	     hr_utility.set_location('MDDDS Special Pay NTE Date old '|| l_mddds_pay_nte_date_old,6);

	    IF l_mddds_pay_nte_date_old IS NULL THEN
	      l_null_list := l_null_list||l_new_line||'MD/DDS Special Pay NTE Date';
	    END IF;

         END IF;

	 IF l_null_list IS NOT NULL THEN

            hr_utility.set_message(8301,'GHR_38237_REQUIRED_ITEMS');
            fnd_message.set_token('REQUIRED_LIST',l_null_list);
            hr_utility.raise_error;

         End If;

      IF l_mddds_specia_pay_nte_date IS NOT NULL
	and l_mddds_specia_pay_nte_date
	    < p_pa_request_rec.effective_date THEN
	 hr_utility.set_message(8301,'GHR_38853_NTE_DATE_<_EFF_DATE');
	 hr_utility.raise_error;
      END IF;

    END IF; -- End of If .. 850.

    --Pradeep. New Business Rules for Title 38
    --Bug# 3562063
   IF p_pa_request_rec.first_noa_code = '855'
      OR ( p_pa_request_rec.first_noa_code='002' and p_pa_request_rec.second_noa_code ='855') THEN

      FOR cur_premium_pay_ind_rec IN cur_premium_pay_ind
      LOOP
        l_premium_pay_ind := cur_premium_pay_ind_rec.premium_pay_ind;
      END LOOP;

      hr_utility.set_location('Premium Pay Ind '|| l_premium_pay_ind,3);
      IF l_premium_pay_ind IS NULL THEN
	    ghr_api.retrieve_element_entry_value
                  (p_element_name          => 'Premium Pay',
                   p_input_value_name      => 'Premium Pay Ind',
                   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                   p_effective_date        => p_pa_request_rec.effective_date,
                   p_value                 => l_premium_pay_ind,
                   p_multiple_error_flag   => l_multiple_error_flag
                   );

      END IF;

	 IF ( l_premium_pay_ind ) IS NULL
	    OR ( l_premium_pay_ind <> 'K' ) THEN
	    hr_utility.set_message(8301,'GHR_38872_855_PREM_PAY');
    	    hr_utility.raise_error;
         END IF;

	 l_occ_code := p_pa_request_rec.from_occ_code;

         If ( l_occ_code <> '0610' ) THEN

           hr_utility.set_message(8301,'GHR_38873_855_OCC_SERIES');
           hr_utility.raise_error;

         End If;
     --Bug# 3562063

   END IF; --End of If ... 855

     --Pradeep.
    -- Bug 3528461
    --Not only for 800 but also for any other noac, it should check the validation between Premium Pay and OCC Code.
 --  IF p_pa_request_rec.first_noa_code = '800' THEN
 --Bug#3579579
   FOR cur_premium_pay_rec IN cur_premium_pay
   LOOP
      l_premium_pay_ind := cur_premium_pay_rec.premium_pay_ind;
   END LOOP;
   hr_utility.set_location('Premium Pay Ind '|| l_premium_pay_ind,3);

   IF l_premium_pay_ind IS NULL THEN
   --Bug#3579579
	ghr_api.retrieve_element_entry_value
		  (p_element_name          => 'Premium Pay',
		   p_input_value_name      => 'Premium Pay Ind',
		   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
		   p_effective_date        => p_pa_request_rec.effective_date,
		   p_value                 => l_premium_pay_ind,
		   p_multiple_error_flag   => l_multiple_error_flag
		   );
	     hr_utility.set_location('Premium Pay Ind '|| l_premium_pay_ind,4);
   END IF;

	 l_occ_code := p_pa_request_rec.to_occ_code;
	 hr_utility.set_location('Occ Code '|| l_occ_code,5);
	 IF l_occ_code IS NULL THEN
	    l_occ_code := p_pa_request_rec.from_occ_code;
         END IF;

	 If l_premium_pay_ind='K' and l_occ_code NOT IN  ('0602','0603','0610','0680','0681','0682','0683') THEN

	   hr_utility.set_message(8301,'GHR_38859_OCC_CD_PREM_PAY_IND');
	   hr_utility.raise_error;

	 End If;

	 If l_premium_pay_ind='X' and l_occ_code NOT IN ('0180','0602','0620','0631','0633','0651','0660','0680') THEN

	   hr_utility.set_message(8301, 'GHR_38860_OCC_CD_PREM_PAY_IND');
	   hr_utility.raise_error;

	 End If;

       get_element_details_future(p_element_name         => 'Premium Pay'
				       ,p_input_value_name     => 'Premium Pay Ind'
				       ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
				       ,p_effective_date       => p_pa_request_rec.effective_date
				       ,p_value                => l_premium_pay_ind
				       ,p_effective_start_date => l_eff_start_date);

	 hr_utility.set_location('Premium Pay Ind future'|| l_premium_pay_ind,4);

	 If l_premium_pay_ind='K' and l_occ_code NOT IN  ('0602','0603','0610','0680','0681','0682','0683') THEN

	   hr_utility.set_message(8301,'GHR_38859_OCC_CD_PREM_PAY_IND');
	   hr_utility.raise_error;

	 End If;

	 If l_premium_pay_ind='X' and l_occ_code NOT IN ('0180','0602','0620','0631','0633','0651','0660','0680') THEN

	   hr_utility.set_message(8301, 'GHR_38860_OCC_CD_PREM_PAY_IND');
	   hr_utility.raise_error;

	 End If;


 -- END IF;

   IF p_pa_request_rec.first_noa_code = '819'
      and l_session.noa_id_correct is NULL THEN
      ghr_api.retrieve_element_entry_value
      (P_ELEMENT_NAME          => 'Availability Pay',
 	 P_INPUT_VALUE_NAME      => 'Amount',
	 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
	 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
	 P_VALUE                 => l_ap_amount,
	 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
       );
         hr_utility.set_location('AP Amount '||l_ap_amount,7);
      IF l_ap_amount is NULL and
       (p_pa_request_rec.to_other_pay_amount is null or
           p_pa_request_rec.to_other_pay_amount = 0 ) THEN
             hr_utility.set_message(8301,'GHR_38589_NULL_OTHER_PAY');
             hr_utility.raise_error;
     END IF;

     --Pradeep
     --Title 38 Employess should not get Avaialability Pay.
     ghr_api.retrieve_element_entry_value
                  (p_element_name          => 'Premium Pay',
                   p_input_value_name      => 'Premium Pay Ind',
                   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                   p_effective_date        => p_pa_request_rec.effective_date,
                   p_value                 => l_premium_pay_ind,
                   p_multiple_error_flag   => l_multiple_error_flag
                   );
      hr_utility.set_location('Premium Pay Ind '|| l_prem_pay,7);

      IF l_premium_pay_ind IN ( 'K','L','M','X'	) THEN

	hr_utility.set_message(8301,'GHR_38857_OTH_PAY_PREM_PAY');
	hr_utility.raise_error;

      END IF;

      --To check if premium pay element is existing in the future
      get_element_details_future(p_element_name         => 'Premium Pay'
                                               ,p_input_value_name     => 'Premium Pay Ind'
                                               ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
                                               ,p_effective_date       => p_pa_request_rec.effective_date
                                               ,p_value                => l_premium_pay_ind
                                               ,p_effective_start_date => l_eff_start_date);

      hr_utility.set_location('Premium Pay Ind '|| l_prem_pay,8);

      IF l_premium_pay_ind IN ( 'K','L','M','X'	) THEN

	hr_utility.set_message(8301,'GHR_38866_OTH_PAY_PREM_PAY_FUT');
	hr_utility.raise_error;

      END IF;

   END IF;

   IF p_pa_request_rec.first_noa_code = '818'
      and l_session.noa_id_correct is NULL THEN
      ghr_api.retrieve_element_entry_value
      (P_ELEMENT_NAME          => 'AUO',
 	 P_INPUT_VALUE_NAME      => 'Amount',
	 P_ASSIGNMENT_ID         => p_pa_request_rec.employee_assignment_id,
	 P_EFFECTIVE_DATE        => p_pa_request_rec.effective_date,
	 P_VALUE                 => l_auo_amount,
	 P_MULTIPLE_ERROR_FLAG   => l_multiple_error_flag
       );
         hr_utility.set_location('AUO Amount '||l_auo_amount,7);
      IF l_auo_amount is NULL and
       (p_pa_request_rec.to_other_pay_amount is null or
           p_pa_request_rec.to_other_pay_amount = 0 ) THEN
             hr_utility.set_message(8301,'GHR_38589_NULL_OTHER_PAY');
             hr_utility.raise_error;
     END IF;

     --Pradeep
     --Title 38 Employess should not get AUO.
     ghr_api.retrieve_element_entry_value
                  (p_element_name          => 'Premium Pay',
                   p_input_value_name      => 'Premium Pay Ind',
                   p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                   p_effective_date        => p_pa_request_rec.effective_date,
                   p_value                 => l_premium_pay_ind,
                   p_multiple_error_flag   => l_multiple_error_flag
                   );
      hr_utility.set_location('Premium Pay Ind '|| l_prem_pay,7);

      IF l_premium_pay_ind IN ( 'K','L','M','X'	) THEN

	hr_utility.set_message(8301,'GHR_38857_OTH_PAY_PREM_PAY');
	hr_utility.raise_error;

      END IF;

      --To check if premium pay element is existing in the future
      get_element_details_future(p_element_name         => 'Premium Pay'
                                               ,p_input_value_name     => 'Premium Pay Ind'
                                               ,p_assignment_id        => p_pa_request_rec.employee_assignment_id
                                               ,p_effective_date       => p_pa_request_rec.effective_date
                                               ,p_value                => l_premium_pay_ind
                                               ,p_effective_start_date => l_eff_start_date);

      hr_utility.set_location('Premium Pay Ind '|| l_prem_pay,8);

      IF l_premium_pay_ind IN ( 'K','L','M','X'	) THEN

	hr_utility.set_message(8301,'GHR_38866_OTH_PAY_PREM_PAY_FUT');
	hr_utility.raise_error;

      END IF;

   END IF;

   IF p_pa_request_rec.first_noa_code = '855'
      OR ( p_pa_request_rec.first_noa_code='002' and p_pa_request_rec.second_noa_code ='855') THEN

     IF p_pa_request_rec.pay_rate_determinant IN ('A','B','E','F','U','V') THEN
        begin
             hr_utility.set_location('Check 855 Retained Grade ...get open pay range ' ,20);

             l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (p_pa_request_rec.person_id
                                                 ,NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)));

             IF p_pa_request_rec.pay_rate_determinant IN ('A','B','E','F') THEN
                if l_retained_grade.temp_step is not null then
                   l_to_step_or_rate := l_retained_grade.temp_step;
                else
                   l_to_step_or_rate   := l_retained_grade.step_or_rate;
                end if;
             ELSE
                   l_to_step_or_rate   := l_retained_grade.step_or_rate;
             END IF;

             hr_utility.set_location(' check 855 Retained to step  ' || l_to_step_or_rate,22);

             l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (p_pa_request_rec.person_id
                                                 ,(p_pa_request_rec.effective_date - 1));

             IF p_pa_request_rec.pay_rate_determinant IN ('A','B','E','F') THEN
                if l_retained_grade.temp_step is not null then
                   l_from_step_or_rate := l_retained_grade.temp_step;
                else
                   l_from_step_or_rate   := l_retained_grade.step_or_rate;
                end if;
             ELSE
                   l_from_step_or_rate   := l_retained_grade.step_or_rate;
             END IF;

             hr_utility.set_location(' check 855 Retained from step  ' || l_from_step_or_rate,24);

	 exception
            when others then
              hr_utility.set_location('Retained Exception raised ' || sqlerrm(sqlcode),25);
              hr_utility.set_message(8301,'GHR_38255_MISSING_RETAINED_DET');
              hr_utility.raise_error;
        end;

	     IF ABS(l_to_step_or_rate - l_from_step_or_rate) > 2 THEN
                hr_utility.set_message(8301,'GHR_38852_TO_STEP_OR_RATE');
                hr_utility.raise_error;
            END IF;

      END IF;
    END IF;


   --- End Bug 1551311
   --
   --
   -- check whether more than one other pay is changed for NOA 810
   --
   if p_pa_request_rec.first_noa_code = '810' then
      l_for_810_count := 0;
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Retention Allowance',
               p_input_value_name      => 'Amount',
               p_assignment_id         => p_pa_request_rec.employee_assignment_id,
               p_effective_date        => p_pa_request_rec.effective_date,
               p_value                 => l_amount,
               p_multiple_error_flag   => l_multiple_error_flag
               );
      if  NVL(p_pa_request_rec.to_retention_allowance,0) <> NVL(l_amount,0) then
          l_for_810_count := l_for_810_count + 1;
      end if;
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Supervisory Differential',
               p_input_value_name      => 'Amount',
               p_assignment_id         => p_pa_request_rec.employee_assignment_id,
               p_effective_date        => p_pa_request_rec.effective_date,
               p_value                 => l_amount,
               p_multiple_error_flag   => l_multiple_error_flag
               );
      if  NVL(p_pa_request_rec.to_supervisory_differential,0) <> NVL(l_amount,0) then
          l_for_810_count := l_for_810_count + 1;
      end if;
      ghr_api.retrieve_element_entry_value
              (p_element_name          => 'Staffing Differential',
               p_input_value_name      => 'Amount',
               p_assignment_id         => p_pa_request_rec.employee_assignment_id,
               p_effective_date        => p_pa_request_rec.effective_date,
               p_value                 => l_amount,
               p_multiple_error_flag   => l_multiple_error_flag
               );
      if  NVL(p_pa_request_rec.to_staffing_differential,0) <> NVL(l_amount,0) then
          l_for_810_count := l_for_810_count + 1;
      end if;
      --
      if l_for_810_count > 1 then
         hr_utility.set_message(8301,'GHR_ONE_OP_UPDATE_ONLY');
         hr_utility.raise_error;
      end if;
   end if;
         hr_utility.set_location('GHRVALID-Before LAC Validation',3);
-- Bug # 941255 --Venkat-- Check that LACs are Valid when Update HR
-- in progress and give a Error message if NOAC/LAC combination is invalid
--
 -- Check if  first_action_la_code1 is valid
    --
    l_exists := false;
    If p_pa_request_rec.first_action_la_code1 is not null then
      for la_code  in c_first_la_code1 loop
        l_exists := true;
        exit;
      end loop;
  --
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38105_INV_FIRST_LA_CODE1');
        hr_utility.raise_error;
      end if;
    end if;

    l_exists := false;
 -- Check if  first_action_la_code2 is valid
    --
    If p_pa_request_rec.first_action_la_code2 is not null then
      for la_code  in c_first_la_code2 loop
        l_exists := true;
        exit;
      end loop;
  --
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38106_INV_FIRST_LA_CODE2');
        hr_utility.raise_error;
      end if;
    end if;
    l_exists := false;
--
 -- Check if  second_action_la_code1 is valid
    --
    If p_pa_request_rec.second_action_la_code1 is not null then
      for la_code  in c_second_la_code1 loop
        l_exists := true;
        exit;
      end loop;
  --
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38107_INV_SECOND_LA_CODE1');
        hr_utility.raise_error;
      end if;
    end if;
    l_exists := false;
--
 -- Check if  second_action_la_code2 is valid
    --
    If p_pa_request_rec.second_action_la_code2 is not null then
      for la_code  in c_second_la_code2 loop
        l_exists := true;
        exit;
      end loop;
  --
      if not l_exists then
        hr_utility.set_message(8301, 'GHR_38108_INV_SECOND_LA_CODE2');
        hr_utility.raise_error;
      end if;
    end if;
         hr_utility.set_location('GHRVALID-After LAC Validation',4);
--
--
--  Validate if the open pay range basic pay is entered by user.
--
--
IF p_pa_request_rec.noa_family_code not in ('AWARD'
					                       ,'GHR_INCENTIVE'
                                           ,'NON_PAY_DUTY_STATUS'
                                           ,'POS_ABOLISH'
                                           ,'POS_ESTABLISH'
                                           ,'POS_REVIEW'
                                           ,'RECRUIT_FILL'
                                           ,'SEPARATION'
                                           ,'GHR_STUDENT_LOAN') THEN
  IF p_pa_request_rec.to_position_id is not null THEN
    IF ghr_pay_calc.get_open_pay_range
        (p_pa_request_rec.to_position_id
        ,p_pa_request_rec.person_id
        ,p_pa_request_rec.pay_rate_determinant
        ,p_pa_request_rec.pa_request_id
        ,NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)) ) THEN

         hr_utility.set_location('GHRVALID-Open Pay Range get table_id' ,5);



     IF p_pa_request_rec.pay_rate_determinant IN ('A','B','E','F','U','V') THEN
        begin
             hr_utility.set_location('Retained Grade ...get open pay range ' ,20);

             l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details (p_pa_request_rec.person_id
                                                 ,NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)));
             l_user_table_id  := l_retained_grade.user_table_id;
             l_pay_plan       := l_retained_grade.pay_plan;
             l_grade_or_level := l_retained_grade.grade_or_level;
             hr_utility.set_location(' Retained user table id ' || to_char(l_user_table_id),22);
        exception
            when others then
              hr_utility.set_location('Retained Exception raised ' || sqlerrm(sqlcode),25);
              hr_utility.set_message(8301,'GHR_38255_MISSING_RETAINED_DET');
              hr_utility.raise_error;
        end;

     ELSE


	   l_user_table_id := ghr_pay_calc.get_user_table_id (p_pa_request_rec.to_position_id
                                           ,NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)) );
         --Start of the Bug 3604377
	   -- Retive the Grade info from the POI history table
	  ghr_history_fetch.fetch_positionei(
	    p_position_id      => p_pa_request_rec.to_position_id,
	    p_information_type => 'GHR_US_POS_VALID_GRADE',
	    p_date_effective   => NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)),
	    p_pos_ei_data      => l_pos_ei_grade_data);
	--Based on Grade id Get the Pay Plan.
	    IF l_pos_ei_grade_data.poei_information3 IS NOT NULL THEN
		FOR cur_grd_rec IN cur_grd(l_pos_ei_grade_data.poei_information3) LOOP
		      l_pay_plan         := NVL(cur_grd_rec.pay_plan,l_pay_plan);
		      l_grade_or_level := NVL(cur_grd_rec.grade_or_level,l_grade_or_level);
		END LOOP;
	    END IF;
           --End of the Bug 3604377
	    /*
	    l_pay_plan       := p_pa_request_rec.to_pay_plan;
           l_grade_or_level := p_pa_request_rec.to_grade_or_level;
	   */

     END IF;



--hr_utility.set_location('GHRVALID-l_user_table_id ' || to_char(l_user_table_id) ,5);
--hr_utility.set_location('GHRVALID-l_pay_plan ' || to_char(l_pay_plan) ,5);
--hr_utility.set_location('GHRVALID-l_grade_or_level ' || to_char(l_grade_or_level) ,5);

	 hr_utility.set_location('GHRVALID-l_user_table_id ' || to_char(l_user_table_id) ,5);
         hr_utility.set_location('GHRVALID-Open Pay Range get values' ,5);

       ghr_pay_calc.get_open_pay_table_values
                          (p_user_table_id     =>  l_user_table_id
                          ,p_pay_plan          =>  l_pay_plan
                          ,p_grade_or_level    =>  l_grade_or_level
                          ,p_effective_date    =>  NVL(p_pa_request_rec.effective_date,TRUNC(sysdate))
                          ,p_row_high          =>  l_row_high
                          ,p_row_low           =>  l_row_low );


          hr_utility.set_location('GHRVALID-Open Pay Ranges found',5);

        IF l_row_low is null and l_row_high is null then
           ---Raise Error
           hr_utility.set_message(8301, 'GHR_38715_OPEN_PAY_RANGE_NF');
           hr_utility.raise_error;
        END IF;

        -- 5482191 Start
        --Bug 5658361 IF NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)) >= to_date('07/01/2007','DD/MM/YYYY') AND
            --Bug 5658361 p_pa_request_rec.first_noa_code in ('891','892','893','894','890','896','897') AND
        --Bug# 6073655 Brought out this code from the l_psi<>'00' condition
        IF p_pa_request_rec.first_noa_code = '897'
            AND p_pa_request_rec.to_basic_pay >= p_pa_request_rec.from_basic_pay THEN
            hr_utility.set_message(8301, 'GHR_38513_AFHR_VAL_CHK');
            hr_utility.raise_error;
        END IF;
        --Bug# 6073655
        IF l_psi <> '00' THEN
            IF NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)) >= to_date('30/04/2006','DD/MM/YYYY') THEN  --Bug 5658361
                IF p_pa_request_rec.pay_rate_determinant IN ('4','R') AND
                        l_row_high >= p_pa_request_rec.to_basic_pay THEN
                    hr_utility.set_message(8301, 'GHR_38506_AFHR_PRD_CHK');
                    hr_utility.raise_error;
                ELSIF p_pa_request_rec.pay_rate_determinant = 'T' AND
                        l_row_low  <= p_pa_request_rec.to_basic_pay THEN
                    hr_utility.set_message(8301, 'GHR_38508_AFHR_PRD_CHK');
                    hr_utility.raise_error;
                ELSIF p_pa_request_rec.pay_rate_determinant = '0' AND
                        (l_row_low > p_pa_request_rec.to_basic_pay OR l_row_high < p_pa_request_rec.to_basic_pay) THEN
                    hr_utility.set_message(8301, 'GHR_38507_AFHR_PAY_CHK');
                    hr_utility.raise_error;
                END IF;
                IF p_pa_request_rec.to_step_or_rate <> '00' THEN   --Bug 5657572
                    hr_utility.set_message(8301, 'GHR_38474_AFH_TO_STEP_OR_RATE');
                    hr_utility.raise_error;
                END IF;
            END IF;
        ELSE
	--6489042 No validation is needed for PRD 2
        --Bug# 7557159, added PRD D, basic pay can enter more than the limit
         -- Pay cap is different for PRD D. Eg pay plan ES.
	  IF p_pa_request_rec.pay_rate_determinant NOT IN ('2','D') then
            IF l_row_low  <= p_pa_request_rec.to_basic_pay AND
                 l_row_high >= p_pa_request_rec.to_basic_pay  then
                null;
            ELSE
                ---Raise Error
                hr_utility.set_message(8301, 'GHR_38714_OPEN_PAY_RANGE_VAL');
                hr_utility.set_message_token('MIN',to_char(l_row_low));
                hr_utility.set_message_token('MAX',to_char(l_row_high));
                hr_utility.raise_error;
            END IF;
	  END IF;
        END IF;
        -- 5482191 End

    END IF;

    -- Bug 5657572
/**** As per GPPA update 46 req. for 890 any employee is fine
    IF NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)) >= to_date('07/01/2007','DD/MM/YYYY') AND
            p_pa_request_rec.first_noa_code = '890' THEN
        IF l_psi = '00' THEN
            hr_utility.set_message(8301, 'GHR_38462_AFHR_POS_SEL');
            hr_utility.raise_error;
        END IF;
    END IF;
*******/
  END IF;
 END IF;

 --Bug 5657733, 5662254
 --IF NVL(p_pa_request_rec.effective_date,TRUNC(sysdate)) >= to_date('07/01/2007','DD/MM/YYYY') AND
 --Removed 894 NOAC for rating of record check as part of GPPA U46 Req.
 IF p_pa_request_rec.first_noa_code in ('891','892') AND l_psi <> '00' THEN
     IF p_pa_request_rec.first_noa_code = '891' AND
           nvl(p_perf_appraisal_type.rating_rec_level,'X') NOT IN ('3','4','5') THEN
         hr_utility.set_message(8301, 'GHR_38457_AFHR_NOA_CHK');
         hr_utility.raise_error;
     END IF;
     IF p_pa_request_rec.first_noa_code = '892' AND
           nvl(p_perf_appraisal_type.rating_rec_level,'X') IN ('1','2') THEN
         hr_utility.set_message(8301, 'GHR_38510_AFHR_NOA_CHK');
         hr_utility.raise_error;
     END IF;
/****GPPA U46
     IF p_pa_request_rec.first_noa_code = '894' AND
           nvl(p_perf_appraisal_type.rating_rec_level,'X') = '1' THEN
         hr_utility.set_message(8301, 'GHR_38511_AFHR_NOA_CHK');
         hr_utility.raise_error;
     END IF;
*****GPPA ****/
 END IF;

-- For 703 actions give error message if the Temporary Promotion Step value
-- is null
-- and Employee has a valid retained grade record

IF p_pa_request_rec.first_noa_code in ('703') THEN
  BEGIN
    l_retained_grade := ghr_pc_basic_pay.get_retained_grade_details
                         (p_pa_request_rec.person_id
                          ,NVL(p_pa_request_rec.effective_date,TRUNC(sysdate))
                          ,p_pa_request_rec.pa_request_id);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
  END;
  IF l_retained_grade.person_extra_info_id is not null and
     l_retained_grade.temp_step is null THEN
    hr_utility.set_message(8301,'GHR_38824_RG_TPS_REQUIRED');
    hr_utility.raise_error;
  END IF;
END IF;
--Bug 5527363
IF p_pa_request_rec.noa_family_code = 'CONV_APP' AND p_within_grade_incr.p_date_wgi_due IS NOT NULL
      AND p_within_grade_incr.p_last_equi_incr IS NULL THEN
   hr_utility.set_message(8301,'GHR_37740_CONV_APP_NULL_DLEI');
   hr_utility.raise_error;
END IF;

    /* Bug#5132121  Service Obligation for Student Loan and MD/DDS */
    IF p_pa_request_rec.first_noa_code IN ('817', '850', '480') OR
       (p_pa_request_rec.second_noa_code IN ('817', '850', '480') AND
       p_pa_request_rec.first_noa_code IN ('002')) THEN
      FOR l_cur_service_oblg_ei IN cur_service_oblg_ei LOOP
        l_serv_oblg_type       := l_cur_service_oblg_ei.srvc_oblg_type;
        l_serv_oblg_start_date := l_cur_service_oblg_ei.srvc_oblg_st_date;
        l_serv_oblg_end_date   := l_cur_service_oblg_ei.srvc_oblg_end_date;
        IF l_serv_oblg_type IS NOT NULL AND
           (l_serv_oblg_start_date IS NULL OR l_serv_oblg_end_date IS NULL) THEN
          hr_utility.set_message(8301,
                                 'GHR_38454_SRVC_OBLG_TYPE_CHK');
          hr_utility.raise_error;
        END IF;

        IF l_serv_oblg_start_date IS NOT NULL AND
           (l_serv_oblg_end_date IS NULL OR l_serv_oblg_type IS NULL) THEN
          hr_utility.set_message(8301,
                                 'GHR_38455_SRVC_OBLG_ST_DT_CHK');
          hr_utility.raise_error;
        END IF;
      END LOOP;
    END IF;
    /* Bug#5132121  Service Obligation for Student Loan and MD/DDS */

end Validate_CHECK;

PROCEDURE get_element_details_future (p_element_name         IN     VARCHAR2
                              ,p_input_value_name     IN     VARCHAR2
                              ,p_assignment_id        IN     NUMBER
                              ,p_effective_date       IN     DATE
                              ,p_value                IN OUT NOCOPY VARCHAR2
                              ,p_effective_start_date IN OUT NOCOPY DATE) IS
--
-- NOTE: The effective date we get is that of the individual input value not the effective
-- date of the whole element as seen in the element screen.
--
CURSOR cur_ele(p_element_name IN VARCHAR2,
               p_bg_id        IN NUMBER)
 IS
  SELECT  eev.screen_entry_value
         ,eev.effective_start_date
  FROM    pay_element_types_f        elt
         ,pay_input_values_f         ipv
         ,pay_element_entries_f      ele
         ,pay_element_entry_values_f eev
  WHERE  p_effective_date <  eev.effective_start_date
  AND    eev.effective_end_date IS NULL
  AND    elt.element_type_id    = ipv.element_type_id
  AND    upper(elt.element_name)= upper(p_element_name)
  AND    ipv.input_value_id     = eev.input_value_id
  AND    ele.assignment_id      = p_assignment_id
  AND    ele.element_entry_id+0 = eev.element_entry_id
  AND    upper(ipv.name )       = upper(p_input_value_name)
--  AND    NVL(elt.business_group_id,0)  = NVL(ipv.business_group_id,0)
  AND    (elt.business_group_id is NULL or elt.business_group_id  = p_bg_id);
  --
Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;
--
 ll_bg_id                    NUMBER;
 ll_pay_basis                VARCHAR2(80);
 ll_effective_date           DATE;
 l_new_element_name          VARCHAR2(80);
 l_session                  ghr_history_api.g_session_var_type;
--
BEGIN
--
--
  -- Initialization
  -- Pick the business group id and also pay basis for later use
  ll_effective_date := p_effective_Date;

  For BG_rec in Cur_BG(p_assignment_id,ll_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;

----
---- The New Changes after 08/22 patch
---- For all elements in HR User old function will fetch the same name.
----     because of is_script will be FALSE
----
---- For all elements (except BSR) in Payroll user old function.
----     for BSR a new function which will fetch from assignmnet id.
----

IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE') = 'INT')) THEN
    hr_utility.set_location('PAYROLL User -- BSR -- from asgid-- ', 1);
           l_new_element_name :=
	           pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => ll_bg_id,
	                                   p_effective_date     => ll_effective_date);
 ELSIF (fnd_profile.value('HR_USER_TYPE') <> 'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE') = 'INT'))) THEN
    hr_utility.set_location('HR USER or PAYROLL User without BSR element -- from elt name -- ', 1);
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => ll_bg_id,
	                                   p_effective_date     => ll_effective_date,
	                                   p_pay_basis          => NULL);

 END IF;

--
--
  FOR cur_ele_rec IN cur_ele(l_new_element_name,ll_bg_id) LOOP
    p_value                := cur_ele_rec.screen_entry_value;
    p_effective_start_date := cur_ele_rec.effective_start_date;
  END LOOP;
  --
END get_element_details_future;

end GHR_Validate_CHECK;

/
