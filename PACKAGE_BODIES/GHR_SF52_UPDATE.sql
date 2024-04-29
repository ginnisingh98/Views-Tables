--------------------------------------------------------
--  DDL for Package Body GHR_SF52_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_UPDATE" AS
/* $Header: ghsf52up.pkb 120.22.12010000.16 2009/09/18 11:25:12 vmididho ship $ */
g_effective_date      date;

--- *****************************
--- procedure Populate_Remarks
---- ****************************
/* This is a procedure introduced to auto populate the remarks 'P05' and
   'p07' for GS Equivalent and special rate pay table or populate the remarks 'X37'
    for pay rate determinants('A','B','E','F','U','V')*/
-- 6398933 Added parameter p_first_noa_code,p_second_noa_code to populate remark X37 for specific NOA codes
PROCEDURE Populate_Remarks(p_pa_request_id            in number
                          ,p_to_pay_plan              in varchar2
			  ,p_to_pay_table_identifier  in number
			  ,p_person_id                in number
			  ,p_pay_rate_determinant     in varchar2
			  ,p_effective_date           in date
			  ,p_first_noa_code           in varchar2 -- 6398933
			  ,p_second_noa_code          in varchar2 -- 6398933
			  ,p_leo_indicator            in varchar2
			  ,p_fegli                    in varchar2
			   )
is
  CURSOR c1(p_remark_code in varchar2) is
      SELECT 1
      FROM   GHR_PA_REMARKS parem,
             GHR_REMARKS  grem
      WHERE  parem.remark_id  = grem.remark_id
      AND    grem.code = p_remark_code
      AND    parem.pa_request_id = p_pa_request_id;

  CURSOR C2(p_remark_code in varchar2) is
      SELECT *
      FROM   GHR_REMARKS
      WHERE  code = p_remark_code
      and    p_effective_date between date_from and nvl(date_to,p_effective_date);

  CURSOR C3 is
      select 1
      from   ghr_pay_plans
      where  pay_plan = p_to_pay_plan
      and    equivalent_pay_plan = 'GS';

  CURSOR C4 is
      select SUBSTR(user_table_name,0,4)
      from   pay_user_tables
      where  user_table_id = p_to_pay_table_identifier;

--  Bug# 7269520  Added the below cursor to check pay plan
  -- and valid grade combination for auto population of P11 remarks
   CURSOR C5 is
      select to_pay_plan, to_grade_or_level
      from   ghr_pa_requests
      where  pa_request_id = p_pa_request_id;

  --Bug #  7573846 Added the below cursor to fetch lac codes
  CURSOR get_pa_det
      IS
      select first_action_la_code1,first_action_la_code2
            ,second_action_la_code1,second_action_la_code2,
	    first_noa_code,
	    second_noa_code
      from  ghr_pa_requests
      where  pa_request_id = p_pa_request_id;





  l_proc                 varchar2(100) := 'Populate_Remarks';
  l_found     varchar2(1);
  l_remark   c2%rowtype;
  l_pa_remark_id          ghr_pa_remarks.pa_remark_id%type;
  l_object_version_number ghr_pa_remarks.object_version_number%type;
  l_description           ghr_remarks.description%type;
  l_user_table_name       pay_user_tables.user_table_name%type;
  l_retained_grade_info   ghr_pay_calc.retained_grade_rec_type;
  l_retained_grade        varchar2(10);
  -- Bug # 7269520
  l_to_pay_plan           ghr_pa_requests.to_pay_plan%type;
  l_to_grade_or_level     ghr_pa_requests.to_grade_or_level%type;
  -- Bug # 7269520

begin
  hr_utility.set_location('Entering  ' ||l_proc,5);
--Added Condition for the bug 6398933
 If NOT (p_first_noa_code in ('840','841','842','843','844','845','846','847','848','849','878','879','885','886','887','889')
          or (p_first_noa_code = '002' and
              p_second_noa_code in ('840','841','842','843','844','845','846','847','848','849','878','879','885','886','887','889'))
        ) Then
  If p_pay_rate_determinant in ('A','B','E','F','U','V') then
     If c1%isopen then
        close c1;
     End if;
     open c1(p_remark_code => 'X37');
     fetch c1 into l_found;
     If c1%notfound then
        If c2%isopen then
           close c2;
        End If;
        open c2(p_remark_code => 'X37');
        fetch c2 into l_remark;
	if c2%found then


--   l_retained_grade_info := ghr_pc_basic_pay.get_retained_grade_details(p_person_id => p_person_id
--                       ,p_effective_date => p_effective_date);

  hr_utility.set_location('From Global varaible Fetchig the retained Grade details  ' ||l_proc,20);

        l_retained_grade_info := ghr_sf52_do_update.g_retained_grade_info;
--        l_retained_grade := l_retained_grade_info.grade_or_level||'-'||l_retained_grade_info.pay_plan;

	--Bug# 6075814   vmididho   to display PayPlan-Gradeorlevel
	l_retained_grade := l_retained_grade_info.pay_plan||'-'||l_retained_grade_info.grade_or_level;

        hr_utility.set_location('l_retained_grade  ' || l_retained_grade, 30);

	/*l_description := REPLACE(SUBSTR(l_remark.description,0,INSTR(l_remark.description,'_',1)-1)||l_retained_grade||
	                 SUBSTR(l_remark.description,INSTR(l_remark.description,'_',1)+ LENGTH(l_retained_grade),
			 (INSTR(l_remark.description,'_',INSTR(l_remark.description,'_',1)+10))- (INSTR(l_remark.description,'_',1)+ LENGTH(l_retained_grade)))||
			 TO_CHAR(l_retained_grade_info.date_to,'DD-MON-RRRR'),'_',' ');*/

        ghr_mass_actions_pkg.replace_insertion_values
           (p_desc              => l_remark.description,
            p_information1      => l_retained_grade,
            p_information2      => TO_CHAR(l_retained_grade_info.date_to,'DD-MON-RRRR'),
            p_information3      => NULL,
            p_information4      => NULL,
            p_information5      => NULL,
            p_desc_out          => l_description
				);

        hr_utility.set_location('l_description  ' || l_description, 40);

        ghr_pa_remarks_api.create_pa_remarks
          (p_validate            => false
          ,p_pa_request_id 	 => p_pa_request_id
          ,p_remark_id           => l_remark.remark_id
          ,p_description         => l_description
          ,p_remark_code_information1 => l_retained_grade
          ,p_remark_code_information2 => TO_CHAR(l_retained_grade_info.date_to,'DD-MON-RRRR')
          ,p_pa_remark_id             => l_pa_remark_id
          ,p_object_version_number    => l_object_version_number
	  );
        End if; -- cursor c2
        close c2;
      End If;
      Close c1;
    End IF;
      If C3%isopen then
         Close C3;
      End If;

      Open C3;
      Fetch C3 into l_found;
      -- If Equivalent code is 'GS'
      If C3%found then
         If C4%isopen then
	       Close C4;
	     End If;

	     Open C4;
         Fetch C4 into l_user_table_name;
	     Close C4;
	 -- special pay rate table
	 If l_user_table_name not in ('0000','0491') THEN

	    If c1%isopen then
              close c1;
            End if;


            open c1(p_remark_code => 'P05');
            fetch c1 into l_found;
            If c1%notfound then

               If c2%isopen then
                  close c2;
               End If;
               open c2(p_remark_code => 'P05');
               fetch c2 into l_remark;
	       if c2%found then

               ghr_pa_remarks_api.create_pa_remarks
                   (p_validate           => false
                   ,p_pa_request_id 	 => p_pa_request_id
                   ,p_remark_id          => l_remark.remark_id
                   ,p_description         => l_remark.description
                   ,p_pa_remark_id             => l_pa_remark_id
                   ,p_object_version_number    => l_object_version_number
               	  );
		end if; -- cursor c2
               close c2;
             End If;
             Close c1;

	     If c1%isopen then
               close c1;
             End if;
             open c1(p_remark_code => 'P07');
             fetch c1 into l_found;
             If c1%notfound then

                If c2%isopen then
                   close c2;
                End If;
                open c2(p_remark_code => 'P07');
                fetch c2 into l_remark;
		if c2%found then

                --l_description := replace(l_remark.description,'_',' ')||l_user_table_name;

		ghr_mass_actions_pkg.replace_insertion_values
                   (p_desc              => l_remark.description,
                    p_information1      => l_user_table_name,
                    p_information2      => NULL,
                    p_information3      => NULL,
                    p_information4      => NULL,
                    p_information5      => NULL,
                    p_desc_out          => l_description
	           );

                ghr_pa_remarks_api.create_pa_remarks
                    (p_validate           =>false
                    ,p_pa_request_id 	 => p_pa_request_id
                    ,p_remark_id          => l_remark.remark_id
                    ,p_description         => l_description
                    ,p_remark_code_information1 => l_user_table_name
                    ,p_pa_remark_id             => l_pa_remark_id
                    ,p_object_version_number    => l_object_version_number
               	    );
		 end if; -- cursor c2
                close c2;
              End If;
              Close c1;
           End If; --special pay rate table
	 End If; -- Equivalent GS
	 close c3;
  end if; /* validation related to NOA Actions before populating X37,P05 and P07 remarks --6398933*/

-- Bug # 7269520 Added the validation of pay plan and Grade or level before populating p11 remarks
  Open C5;
  Fetch C5 into l_to_pay_plan, l_to_grade_or_level;
  Close C5;
  If l_to_pay_plan = 'GL' and l_to_grade_or_level in ('03','04','05','06','07','08','09','10') then
  /*Bug #5919713 Auto population of remark code P11 for leo employees*/
  -- it should be autopopulated other than Awards , LWOP and Non Pay Actions
     If NOT (p_first_noa_code in ('840','841','842','843','844','845','846','847','848','849','878','879','885','886','887','889',
                                 '430','450','452','460','471','472','473','480','773')
         or (p_first_noa_code = '002' and
             p_second_noa_code in ('840','841','842','843','844','845','846','847','848','849','878','879','885','886','887','889',
	                            '430','450','452','460','471','472','473','480','773'))
            ) Then

         If p_leo_indicator <> '0' then
            If c1%isopen then
               close c1;
            End if;

	    open c1(p_remark_code => 'P11');
            fetch c1 into l_found;
            If c1%notfound then

               If c2%isopen then
                  close c2;
               End If;
               open c2(p_remark_code => 'P11');
               fetch c2 into l_remark;
	       if c2%found then

               ghr_pa_remarks_api.create_pa_remarks
                   (p_validate           => false
                   ,p_pa_request_id 	 => p_pa_request_id
                   ,p_remark_id          => l_remark.remark_id
                   ,p_description         => l_remark.description
                   ,p_pa_remark_id             => l_pa_remark_id
                   ,p_object_version_number    => l_object_version_number
               	  );
		end if; -- cursor c2
                close c2;
             End If;
             Close c1;
          End If;
      End If;
  /*End of Bug #5919713*/
 End If; -- Checking pay plan and Grade

--Bug # 7573846

--Need to add remark code B76 for 473 and LAC code is Q3K or 353
-- Fegli is other than A0,A1,B0.

If (p_first_noa_code in ('353','473'))	then

 for get_pa_det_rec in get_pa_det
 loop

  if ((get_pa_det_rec.first_noa_code = '473') and
      (get_pa_det_rec.first_action_la_code1 = 'Q3K' or get_pa_det_rec.first_action_la_code2 = 'Q3K') and
      (p_fegli not in ('A0','A1','B0')))  OR
     ((get_pa_det_rec.first_noa_code = '353') and
      (p_fegli not in ('A0','A1','B0'))) OR
     ((get_pa_det_rec.first_noa_code = '002' and get_pa_det_rec.second_noa_code = '473') and
      (get_pa_det_rec.second_action_la_code1 = 'Q3K' or get_pa_det_rec.second_action_la_code2 = 'Q3K') and
      (p_fegli not in ('A0','A1','B0'))) OR
     ((get_pa_det_rec.first_noa_code = '002' and get_pa_det_rec.second_noa_code = '353') and
      (p_fegli not in ('A0','A1','B0'))) then

       	 open c1(p_remark_code => 'B76');
         fetch c1 into l_found;
          If c1%notfound then
	    If c2%isopen then
               close c2;
            End If;
            open c2(p_remark_code => 'B76');
            fetch c2 into l_remark;
	    if c2%found then

            ghr_pa_remarks_api.create_pa_remarks
                   (p_validate           => false
                   ,p_pa_request_id 	 => p_pa_request_id
                   ,p_remark_id          => l_remark.remark_id
                   ,p_description         => l_remark.description
                   ,p_pa_remark_id        => l_pa_remark_id
                   ,p_object_version_number=> l_object_version_number
               	  );
            end if; -- cursor c2
            close c2;
           End If;
           Close c1;
    end if;
  end loop;
  end if;
  -- Bug # 7573846

    hr_utility.set_location('Leaving ' || l_proc,100);
end Populate_Remarks;




--
--  ********************************
--  procedure  Process_Immediate_Update
--  ********************************
--

procedure  Process_Immediate_Update
( p_imm_pa_request_rec 	      in  out nocopy ghr_pa_requests%rowtype,
  p_imm_pa_request_ei_rec     in      ghr_pa_request_extra_info%rowtype,
  p_imm_generic_ei_rec        in      ghr_pa_request_extra_info%rowtype,
  p_capped_other_pay          in out nocopy number
)
 is

 l_session                              ghr_history_api.g_session_var_type;
 l_imm_pa_request_rec                   ghr_pa_requests%rowtype;
 l_imm_pa_request_rec_in                ghr_pa_requests%rowtype; /* Added for NOCOPY changes  */
 l_capped_other_pay_in                  number; /* Added for NOCOPY changes  */
 l_imm_asg_sf52                    	ghr_api.asg_sf52_type;
 l_imm_asg_non_sf52                	ghr_api.asg_non_sf52_type;
 l_imm_asg_nte_dates               	ghr_api.asg_nte_dates_type;
 l_imm_per_sf52                   	ghr_api.per_sf52_type;
 l_imm_per_group1                	ghr_api.per_group1_type;
 l_imm_per_group2                	ghr_api.per_group2_type;
 l_imm_per_scd_info                	ghr_api.per_scd_info_type;
 l_imm_per_retained_grade              	ghr_api.per_retained_grade_type;
 l_imm_per_probations             	ghr_api.per_probations_type;
 l_imm_per_sep_retire             	ghr_api.per_sep_retire_type;
 l_imm_per_security		      	    ghr_api.per_security_type;
 -- Bug#4486823 RRR changes
 l_imm_per_service_oblig            ghr_api.per_service_oblig_type;
 l_imm_per_conversions		        ghr_api.per_conversions_type;
 -- 4352589 BEN_EIT Changes
 l_imm_per_benefit_info			    ghr_api.per_benefit_info_type;
 l_imm_per_uniformed_services   	ghr_api.per_uniformed_services_type;
 l_imm_pos_oblig                   	ghr_api.pos_oblig_type;
 l_imm_pos_grp2                   	ghr_api.pos_grp2_type;
 l_imm_pos_grp1                    	ghr_api.pos_grp1_type;
 l_imm_pos_valid_grade              	ghr_api.pos_valid_grade_type;
 l_imm_pos_car_prog                     ghr_api.pos_car_prog_type;
 l_imm_loc_info                        	ghr_api.loc_info_type;
 l_imm_wgi     	                        ghr_api.within_grade_increase_type;
 l_imm_gov_awards                       ghr_api.government_awards_type;
 l_imm_recruitment_bonus	        ghr_api.recruitment_bonus_type;
 l_imm_relocation_bonus		      	ghr_api.relocation_bonus_type;
 l_imm_student_loan_repay               ghr_api.student_loan_repay_type;

 l_imm_extra_info_rec	 	      	ghr_api.extra_info_rec_type ;
 l_imm_sf52_from_data                   ghr_api.prior_sf52_data_type;
 l_imm_personal_info		       	ghr_api.personal_info_type;
 l_imm_generic_extra_info_rec	       	ghr_api.generic_extra_info_rec_type ;
 l_imm_agency_sf52		      	ghr_api.agency_sf52_type;
 l_agency_code			      	varchar2(50);
 l_imm_perf_appraisal                   ghr_api.performance_appraisal_type;
 l_imm_conduct_performance              ghr_api.conduct_performance_type;
 l_imm_payroll_type                     ghr_api.government_payroll_type;
 l_imm_par_term_retained_grade          ghr_api.par_term_retained_grade_type;
 l_imm_entitlement                        ghr_api.entitlement_type;
 -- Bug#2759379 Added FEGLI Record
 l_imm_fegli                            ghr_api.fegli_type;
 l_imm_foreign_lang_prof_pay              ghr_api.foreign_lang_prof_pay_type;
 -- Bug#3385386
 l_imm_fta                                ghr_api.fta_type;
 l_imm_edp_pay                            ghr_api.edp_pay_type;
 l_imm_hazard_pay                         ghr_api.hazard_pay_type;
 l_imm_health_benefits                    ghr_api.health_benefits_type;
 l_imm_danger_pay                         ghr_api.danger_pay_type;
 l_imm_imminent_danger_pay                ghr_api.imminent_danger_pay_type;
 l_imm_living_quarters_allow              ghr_api.living_quarters_allow_type;
 l_imm_post_diff_amt                      ghr_api.post_diff_amt_type;
 l_imm_post_diff_percent                  ghr_api.post_diff_percent_type;
 l_imm_sep_maintenance_allow              ghr_api.sep_maintenance_allow_type;
 l_imm_supplemental_post_allow            ghr_api.supplemental_post_allow_type;
 l_imm_temp_lodge_allow                   ghr_api.temp_lodge_allow_type;
 l_imm_premium_pay                        ghr_api.premium_pay_type;
 l_imm_retirement_annuity                 ghr_api.retirement_annuity_type;
 l_imm_severance_pay                      ghr_api.severance_pay_type;
 l_imm_thrift_saving_plan                 ghr_api.thrift_saving_plan;
 l_imm_retention_allow_review             ghr_api.retention_allow_review_type;
 l_imm_health_ben_pre_tax                 ghr_api.health_ben_pre_tax_type;
 l_imm_mddds_special_pay                  ghr_api.mddds_special_pay_type;
 l_imm_premium_pay_ind                    ghr_api.premium_pay_ind_type;
 l_imm_per_race_ethnic_info 		  ghr_api.per_race_ethnic_type; -- Race or National Origin changes
 -- bug # 6312144 RPA EIT Benefits
 l_imm_ipa_benefits_cont                  ghr_api.per_ipa_ben_cont_info_type;
 l_imm_retirement_info                    ghr_api.per_retirement_info_type;


--
  l_proc                                varchar2(70) := 'Process_Immediate_Update';
--
 l_noa_family_name			varchar2(150);
 l_person_type				varchar2(50);
 l_hr_applicant_api_create_sec   	varchar2(1);
 l_employee_api_update_criteria                                  varchar2(1);
--
 l_health_plan                            pay_element_entry_values.screen_entry_value%type;
 l_error_flag                             boolean;
--
 l_pa_request_id		                  ghr_pa_requests.pa_request_id%type;
 l_pay_calc_in_rec                        ghr_pay_calc.pay_calc_in_rec_type;
 l_pay_calc_out_rec                       ghr_pay_calc.pay_calc_out_rec_type;
 l_message_set                            boolean;
 l_calculated                             boolean;
-- Benefits EIT Sundar
 l_errbuf varchar2(2000);
 l_retcode number;
 l_amount_or_rate VARCHAR2(100);
 l_opt_val number;
 l_bg_id per_all_people_f.business_group_id%type;
 l_temp_appt VARCHAR2(5);
 l_warning  boolean;
-- Cursors declaration
--
Cursor    c_bg_id(c_person_id per_all_people_f.person_id%type,
				  c_effective_date per_all_people_f.effective_start_date%type) is
  select   business_group_id bg_id
  from     per_all_people_f
  where    person_id = c_person_id
  and c_effective_date between effective_start_date and effective_end_date;

--Start of Bug # 5195518 added to check current enrollment
cursor get_current_enrollment (p_asg_id in NUMBER,
                               p_business_group_id in NUMBER,
			       p_effective_date in DATE)
    is
    SELECT ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id, 'Enrollment', eef.effective_start_date) enrollment,
           eef.element_entry_id ,
	   eef.object_version_number
    FROM   pay_element_entries_f eef,
           pay_element_types_f elt
    WHERE  assignment_id = p_asg_id
    AND    elt.element_type_id = eef.element_type_id
    AND    eef.effective_start_date BETWEEN elt.effective_start_date  AND
           elt.effective_end_date
    AND    p_effective_date between eef.effective_start_date and eef.effective_end_date
    AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                                                                   p_business_group_id,
                                                                   p_effective_date))
              IN  ('HEALTH BENEFITS','HEALTH BENEFITS PRE TAX');



    l_object_version_number    pay_element_entries_f.object_version_number%type;
    l_effective_start_date     date;
    l_effective_end_date       date;
    l_delete_warning           boolean;
    l_exists            BOOLEAN := FALSE;
    l_pgm_id            ben_pgm_f.pgm_id%type;

  -- Cursor to get Program
 CURSOR c_get_pgm_id(c_prog_name ben_pgm_f.name%type,
                     c_business_group_id ben_pgm_f.business_group_id%type,
		     c_effective_date ben_pgm_f.effective_start_date%type) is
    SELECT pgm.pgm_id
    FROM   ben_pgm_f pgm
    WHERE  pgm.name = c_prog_name
    AND    pgm.business_group_id  = c_business_group_id
    AND    c_effective_date between effective_start_date and effective_end_date;

 CURSOR c_emp_in_ben(c_person_id ben_prtt_enrt_rslt_f.person_id%type,
                     c_pgm_id ben_prtt_enrt_rslt_f.pgm_id%type,
		     c_effective_date ben_pgm_f.effective_start_date%type) is
    SELECT 1
    FROM   ben_prtt_enrt_rslt_f
    WHERE  person_id = c_person_id
    AND    pgm_id    = c_pgm_id
    AND    prtt_enrt_rslt_stat_cd IS NULL
    AND    c_effective_date between effective_start_date and effective_end_date;

--end of Bug # 5195518
--Begin Bug# 4691288
l_grade_or_level ghr_pa_requests.to_grade_or_level%type;
l_pay_plan       ghr_pa_requests.to_pay_plan%type;
l_record_found      BOOLEAN := FALSE;


CURSOR cur_grd1 IS
    SELECT  gdf.segment1 pay_plan,
            gdf.segment2 grade_or_level
    FROM    per_grade_definitions gdf,
            per_grades grd
    WHERE   grd.grade_id            =  l_imm_pos_valid_grade.valid_grade
    AND     grd.grade_definition_id =   gdf.grade_definition_id
    AND     grd.business_group_id   =   FND_PROFILE.value('PER_BUSINESS_GROUP_ID');

CURSOR cur_pay IS
          SELECT cin.value basic_pay
          FROM   pay_user_column_instances_f cin
                ,pay_user_rows_f             urw
                ,pay_user_columns            col
          WHERE col.user_table_id = l_imm_pos_valid_grade.pay_table_id
          AND   urw.user_table_id = col.user_table_id
          AND   urw.row_low_range_or_name = l_pay_plan||'-'||l_grade_or_level
          AND   NVL(p_imm_pa_request_rec.effective_date,TRUNC(SYSDATE)) BETWEEN urw.effective_start_date AND urw.effective_end_date
          AND   cin.user_row_id = urw.user_row_id
          AND   cin.user_column_id = col.user_column_id
          AND   NVL(p_imm_pa_request_rec.effective_date,TRUNC(SYSDATE)) BETWEEN cin.effective_start_date AND cin.effective_end_date;
--End Bug# 4691288

--8267598 added this cursor for checking dual actions
-- 8676371 modified the below cursor

cursor chk_dual
    is
    select noa_family_code,
           second_noa_id,
	   second_action_la_code1,
	   second_action_la_code2
    from   ghr_pa_requests
    where  pa_request_id = l_session.pa_request_id
    and    second_noa_code is not null
    and    first_noa_code not in ('001','002')
    and    first_noa_id = p_imm_pa_request_rec.first_noa_id;

--8850376
cursor chk_sec_dual
    is
    select noa_family_code
    from   ghr_pa_requests
    where  pa_request_id = l_session.pa_request_id
    and    second_noa_code is not null
    and    first_noa_code not in ('001','002')
    and    second_noa_id = p_imm_pa_request_rec.first_noa_id;

cursor chk_dual_corr
    is
    select mass_action_id
    from   ghr_pa_requests
    where  pa_request_id = l_session.pa_request_id
    and    first_noa_code = '002'
    and    rpa_type = 'DUAL'
    and    mass_action_id is not null;


cursor get_root_dtls
    is
    select pa_request_id,first_noa_code,second_noa_code,
           first_noa_id,second_noa_id,second_action_la_code1,second_action_la_code2,
	   noa_family_code
    from ghr_pa_requests
    where pa_request_id = (select     min(pa_request_id)
                           from       ghr_pa_requests
                           where      pa_notification_id is not null
                           connect by pa_request_id = prior altered_pa_request_id
	                   start with pa_request_id = l_session.altered_pa_request_id)
    and second_noa_code is not null;

cursor c_dual_sec_family_code(p_second_noa_id in number)
    is
    Select fam.noa_family_code
        from   ghr_noa_families nof,
               ghr_families fam
        where  nof.nature_of_action_id =  p_second_noa_id
        and    fam.noa_family_code     = nof.noa_family_code
        and    nvl(fam.proc_method_flag,hr_api.g_varchar2) = 'Y'
        and    p_imm_pa_request_rec.effective_date
        between nvl(fam.start_date_active,p_imm_pa_request_rec.effective_date)
        and     nvl(fam.end_date_active,p_imm_pa_request_rec.effective_date);


l_noa_id  ghr_pa_requests.second_noa_id%type;
l_altered_pa_request_id ghr_pa_requests.pa_request_id%type;
l_asg_ei_data  per_assignment_extra_info%rowtype;
l_prev_info_type  per_position_extra_info.information_type%type;
--End of 8267598


Begin
  hr_utility.set_location('Entering  ' ||l_proc,5);

 l_imm_pa_request_rec_in := p_imm_pa_request_rec; /* Added for NOCOPY changes  */
 l_capped_other_pay_in   := p_capped_other_pay; /* Added for NOCOPY changes  */

  hr_utility.set_location(l_proc,10);
  ghr_history_api.get_g_session_var(l_session);
  IF l_session.noa_id_correct is null  and
     p_imm_pa_request_rec.first_noa_code = '866'  THEN
    g_effective_date := p_imm_pa_request_rec.effective_date + 1;
    l_session.date_effective := g_effective_date;
    ghr_history_api.set_g_session_var( l_session);
  ELSE
  g_effective_date := p_imm_pa_request_rec.effective_date;
  END IF;

-- Before performing validation, recalculate pay  (don't calculate if first_noa_code / second_noa_code = 899)

   ghr_process_sf52.redo_pay_calc
   (p_sf52_rec                => p_imm_pa_request_rec,
    p_capped_other_pay        => p_capped_other_pay
   );

ghr_sf52_post_update.get_notification_details
 (p_pa_request_id                  =>  p_imm_pa_request_rec.pa_request_id,
  p_effective_date                 =>  p_imm_pa_request_rec.effective_date,
 -- p_object_version_number          =>  p_imm_pa_request_rec.object_version_number,
  p_from_position_id               =>  p_imm_pa_request_rec.from_position_id,
  p_to_position_id                 =>  p_imm_pa_request_rec.to_position_id,
  p_agency_code                    =>  p_imm_pa_request_rec.agency_code,
  p_from_agency_code               =>  p_imm_pa_request_rec.from_agency_code,
  p_from_agency_desc               =>  p_imm_pa_request_rec.from_agency_desc,
  p_from_office_symbol             =>  p_imm_pa_request_rec.from_office_symbol,
  p_personnel_office_id            =>  p_imm_pa_request_rec.personnel_office_id,
  p_employee_dept_or_agency        =>  p_imm_pa_request_rec.employee_dept_or_agency,
  p_to_office_symbol               =>  p_imm_pa_request_rec.to_office_symbol
  );
--
--  Calling validation package to validate pa_request data
  ghr_sf52_validn_pkg.perform_validn
  (p_rec				=>	P_imm_Pa_Request_Rec
  );
--
--
 l_imm_asg_sf52.asg_sf52_flag                    	:=   'N';
 l_imm_asg_non_sf52.asg_non_sf52_flag     			:=   'N';
 l_imm_asg_nte_dates.asg_nte_dates_flag				:=   'N';
 l_imm_per_sf52.per_sf52_flag				       	:=   'N';
 l_imm_per_group1.per_group1_flag			        :=   'N';
 l_imm_per_group2.per_group2_flag			       	:=   'N';
 l_imm_per_scd_info.per_scd_info_flag				:=   'N';
 l_imm_per_retained_grade.per_retained_grade_flag	:=   'N';
 l_imm_per_probations.per_probation_flag			:=   'N';
 l_imm_per_sep_retire.per_sep_retire_flag			:=   'N';
 l_imm_per_security.per_security_flag				:=   'N';
 --Bug#4486823 RRR Changes
 l_imm_per_service_oblig.per_service_oblig_flag		:=   'N';
 l_imm_per_conversions.per_conversions_flag			:=   'N';
 l_imm_per_uniformed_services.per_uniformed_services_flag	:=   'N';
 l_imm_pos_oblig.pos_oblig_flag					    :=   'N';
 l_imm_pos_grp2.pos_grp2_flag				        :=   'N';
 l_imm_pos_grp1.pos_grp1_flag				       	:=   'N';
 l_imm_pos_valid_grade.pos_valid_grade_flag			:=   'N';
 l_imm_pos_car_prog.pos_car_prog_flag				:=   'N';
 l_imm_loc_info.loc_info_flag				       	:=   'N';
 l_imm_gov_awards.award_flag                        :=   'N';
 l_imm_conduct_performance.cond_perf_flag           :=   'N';
 l_imm_par_term_retained_grade.par_term_retained_grade_flag :=   'N';
 l_imm_entitlement.entitlement_flag                 :=   'N';
 -- Bug#2759379
 l_imm_fegli.fegli_flag                                     :=   'N';
 l_imm_foreign_lang_prof_pay.for_lang_flag                  :=   'N';
 -- Bug#3385386
 l_imm_fta.fta_flag                                         :=   'N';
 l_imm_edp_pay.edp_flag                                     :=   'N';
 l_imm_health_benefits.health_benefits_flag                 :=   'N';
 l_imm_danger_pay.danger_flag                               :=   'N';
 l_imm_imminent_danger_pay.imminent_danger_flag             :=   'N';
 l_imm_living_quarters_allow.living_quarters_allow_flag     :=   'N';
 l_imm_post_diff_amt.post_diff_amt_flag                     :=   'N';
 l_imm_post_diff_percent.post_diff_percent_flag             :=   'N';
 l_imm_sep_maintenance_allow.sep_maint_allow_flag           :=   'N';
 l_imm_supplemental_post_allow.sup_post_allow_flag          :=   'N';
 l_imm_temp_lodge_allow.temp_lodge_allow_flag               :=   'N';
 l_imm_premium_pay.premium_pay_flag                         :=   'N';
 l_imm_retirement_annuity.retirement_annuity_flag           :=   'N';
 l_imm_severance_pay.severance_pay_flag                     :=   'N';
 l_imm_thrift_saving_plan.tsp_flag                          :=   'N';
 l_imm_retention_allow_review.retention_allow_review_flag   :=   'N';
 l_imm_health_ben_pre_tax.health_ben_pre_tax_flag           :=   'N';
 l_imm_per_race_ethnic_info.p_race_ethnic_info_flag			:=   'N'; -- Race and National origin changes

--
--

-- (Procedures reside in GHR_SF52_PRE_UPDATE package).

-- Populate all necessary record groups , for CPDF Valdiation,update/create extra infos, for agency specific edits
--

hr_utility.set_location(l_proc,15);

 hr_utility.set_location('person id   ' || to_char(p_imm_pa_request_rec.person_id),1);
 ghr_sf52_pre_update.populate_record_groups
(
 p_pa_request_rec                => p_imm_pa_request_rec,
 p_generic_ei_rec                => p_imm_generic_ei_rec,
 p_imm_asg_sf52                  => l_imm_asg_sf52,
 p_imm_asg_non_sf52              => l_imm_asg_non_sf52,
 p_imm_asg_nte_dates             => l_imm_asg_nte_dates,
 p_imm_per_sf52                  => l_imm_per_sf52,
 p_imm_per_group1                => l_imm_per_group1,
 p_imm_per_group2                => l_imm_per_group2,
 p_imm_per_scd_info              => l_imm_per_scd_info,
 p_imm_per_retained_grade        => l_imm_per_retained_grade,
 p_imm_per_probations            => l_imm_per_probations,
 p_imm_per_sep_retire            => l_imm_per_sep_retire,
 p_imm_per_security              => l_imm_per_security,
 --Bug#4486823 RRR Changes
 p_imm_per_service_oblig         => l_imm_per_service_oblig,
 p_imm_per_conversions           => l_imm_per_conversions,
 -- 4352589 BEN_EIT Changes
 p_imm_per_benefit_info          => l_imm_per_benefit_info,
 p_imm_per_uniformed_services    => l_imm_per_uniformed_services,
 p_imm_pos_oblig                 => l_imm_pos_oblig,
 p_imm_pos_grp2                  => l_imm_pos_grp2,
 p_imm_pos_grp1                  => l_imm_pos_grp1,
 p_imm_pos_valid_grade           => l_imm_pos_valid_grade,
 p_imm_pos_car_prog              => l_imm_pos_car_prog,
 p_imm_loc_info                  => l_imm_loc_info,
 p_imm_wgi                       => l_imm_wgi,
 p_imm_gov_awards                => l_imm_gov_awards,
 p_imm_recruitment_bonus         => l_imm_recruitment_bonus,
 p_imm_relocation_bonus          => l_imm_relocation_bonus,
 p_imm_student_loan_repay        => l_imm_student_loan_repay,
 --Pradeep
 p_imm_per_race_ethnic_info		 => l_imm_per_race_ethnic_info, -- Race and National Origin changes
 p_imm_mddds_special_pay         => l_imm_mddds_special_pay,
 p_imm_premium_pay_ind          => l_imm_premium_pay_ind,

 p_imm_perf_appraisal            => l_imm_perf_appraisal,
 p_imm_conduct_performance       => l_imm_conduct_performance,
 p_imm_payroll_type              => l_imm_payroll_type,
 p_imm_extra_info_rec	         => l_imm_extra_info_rec,
 p_imm_sf52_from_data            => l_imm_sf52_from_data,
 p_imm_personal_info	         => l_imm_personal_info,
 p_imm_generic_extra_info_rec    => l_imm_generic_extra_info_rec,
 p_imm_agency_sf52               => l_imm_agency_sf52,
 p_agency_code                   => l_agency_code,
 p_imm_par_term_retained_grade   => l_imm_par_term_retained_grade,
 p_imm_entitlement               => l_imm_entitlement,
 -- Bug#2759379  Added parameter p_imm_fegli
 p_imm_fegli                     => l_imm_fegli,
 p_imm_foreign_lang_prof_pay     => l_imm_foreign_lang_prof_pay,
 -- Bug#3385386 Added parameter p_imm_fta
 p_imm_fta                       => l_imm_fta,
 p_imm_edp_pay                   => l_imm_edp_pay,
 p_imm_hazard_pay                => l_imm_hazard_pay,
 p_imm_health_benefits           => l_imm_health_benefits,
 p_imm_danger_pay                => l_imm_danger_pay,
 p_imm_imminent_danger_pay       => l_imm_imminent_danger_pay,
 p_imm_living_quarters_allow     => l_imm_living_quarters_allow,
 p_imm_post_diff_amt             => l_imm_post_diff_amt,
 p_imm_post_diff_percent         => l_imm_post_diff_percent,
 p_imm_sep_maintenance_allow     => l_imm_sep_maintenance_allow,
 p_imm_supplemental_post_allow   => l_imm_supplemental_post_allow,
 p_imm_temp_lodge_allow          => l_imm_temp_lodge_allow,
 p_imm_premium_pay               => l_imm_premium_pay,
 p_imm_retirement_annuity        => l_imm_retirement_annuity,
 p_imm_severance_pay             => l_imm_severance_pay,
 p_imm_thrift_saving_plan        => l_imm_thrift_saving_plan,
 p_imm_retention_allow_review    => l_imm_retention_allow_review,
 p_imm_health_ben_pre_tax        => l_imm_health_ben_pre_tax,
 -- Bug # 6312144 added new parameters to the procedure for RPA -- EIT Benefits
 p_imm_ipa_benefits_cont         => l_imm_ipa_benefits_cont,
 p_imm_retirement_info           => l_imm_retirement_info
 );
--8267598 added this code to maintain prior work schedule as a global variable
--for dual actions otherwise this will contain null value
hr_utility.set_location('g_dual_prior_ws'||ghr_process_sf52.g_dual_prior_ws,100);
if l_session.pa_request_id is not null and l_session.noa_id_correct is null then
  -- for identifying First action of Dual Action
  for rec_chk_dual in chk_dual
  loop
    ghr_process_sf52.g_dual_prior_ws := l_imm_sf52_from_data.work_schedule;

    -- Added Return to Duty validation to get the prior PRD
    if rec_chk_dual.noa_family_code = 'RETURN_TO_DUTY' then
       ghr_process_sf52.g_dual_prior_prd := l_imm_sf52_from_data.pay_rate_determinant;--Bug# 8268353
       -- Bug 8676371 for fetching appointment authority of second NOA
       for rec_noa_famly_code in c_dual_sec_family_code(p_second_noa_id => rec_chk_dual.second_noa_id)
       loop
         If  rec_noa_famly_code.noa_family_code = 'CONV_APP' then
	    l_imm_per_group1.org_appointment_auth_code1 := rec_chk_dual.second_action_la_code1;
	    l_imm_per_group1.org_appointment_auth_code2 := rec_chk_dual.second_action_la_code2;
         end if;
       end loop;
     end if;
   end loop;

  -- 8850376 for identifying Second action of Dual Action Assigned to details to From Details
  -- as all the latest details are considered in Return to Duty First Action and
  -- for second action to details will become the from details for validation
  for rec_sec_chk_dual in chk_sec_dual
  loop
     if rec_sec_chk_dual.noa_family_code = 'RETURN_TO_DUTY' then
        l_imm_sf52_from_data.position_title          :=  p_imm_pa_request_rec.to_position_title;
        l_imm_sf52_from_data.position_number         :=  p_imm_pa_request_rec.to_position_number;
	l_imm_sf52_from_data.position_seq_no         :=  p_imm_pa_request_rec.to_position_seq_no;
	l_imm_sf52_from_data.pay_plan                :=  p_imm_pa_request_rec.to_pay_plan;
	l_imm_sf52_from_data.occ_code                :=  p_imm_pa_request_rec.to_occ_code;
	l_imm_sf52_from_data.grade_or_level          :=  p_imm_pa_request_rec.to_grade_or_level;
	l_imm_sf52_from_data.step_or_rate            :=  p_imm_pa_request_rec.to_step_or_rate;
	l_imm_sf52_from_data.total_salary            :=  p_imm_pa_request_rec.to_total_salary;
	l_imm_sf52_from_data.pay_basis               :=  p_imm_pa_request_rec.to_pay_basis;
	l_imm_sf52_from_data.basic_pay               :=  p_imm_pa_request_rec.to_basic_pay;
	l_imm_sf52_from_data.locality_adj            :=  p_imm_pa_request_rec.to_locality_adj;
	l_imm_sf52_from_data.adj_basic_pay           :=  p_imm_pa_request_rec.to_adj_basic_pay;
	l_imm_sf52_from_data.other_pay               :=  p_imm_pa_request_rec.to_other_pay_amount;
	l_imm_sf52_from_data.position_org_line1      :=  p_imm_pa_request_rec.to_position_org_line1;
	l_imm_sf52_from_data.position_org_line2      :=  p_imm_pa_request_rec.to_position_org_line2;
	l_imm_sf52_from_data.position_org_line3      :=  p_imm_pa_request_rec.to_position_org_line3;
	l_imm_sf52_from_data.position_org_line4      :=  p_imm_pa_request_rec.to_position_org_line4;
	l_imm_sf52_from_data.position_org_line5      :=  p_imm_pa_request_rec.to_position_org_line5;
	l_imm_sf52_from_data.position_org_line6      :=  p_imm_pa_request_rec.to_position_org_line6;
	l_imm_sf52_from_data.position_id             :=  p_imm_pa_request_rec.to_position_id;
     end if;
   end loop;

elsif l_session.altered_pa_request_id is not null and l_session.noa_id_correct is not null then
    for rec_chk_dual in chk_dual_corr
    loop
     for rec_root_details in get_root_dtls
     loop
       -- second correction
       if rec_chk_dual.mass_action_id < p_imm_pa_request_rec.pa_request_id
       and p_imm_pa_request_rec.first_noa_code = rec_root_details.second_noa_code then
          l_prev_info_type  := Ghr_History_Fetch.g_info_type;
	  -- Assigned to NULL before fetching as by this it is fetching for latest effective date
          Ghr_History_Fetch.g_info_type := NULL;
          Ghr_History_Fetch.Fetch_ASGEI_prior_root_sf50
           (
           p_assignment_id         => p_imm_pa_request_rec.employee_assignment_id,
           p_information_type      => 'GHR_US_ASG_SF52',
           p_date_effective        => p_imm_pa_request_rec.effective_date,
           p_altered_pa_request_id => rec_root_details.pa_request_id,
           p_noa_id_corrected      => rec_root_details.first_noa_id,
           p_get_ovn_flag          => 'Y',
           p_asgei_data            => l_asg_ei_data
           );
          ghr_process_sf52.g_dual_prior_ws := l_asg_ei_data.aei_information7;
	  Ghr_History_Fetch.g_info_type := l_prev_info_type;
	  if rec_root_details.noa_family_code = 'RETURN_TO_DUTY' then
            ghr_process_sf52.g_dual_prior_prd := l_asg_ei_data.aei_information6;--Bug# 8268353
          end if;

	  --first correction
    --8286910 added to get authority codes when return to duty with conversion to appointment is processed
       elsif rec_chk_dual.mass_action_id > p_imm_pa_request_rec.pa_request_id
       and p_imm_pa_request_rec.first_noa_code = rec_root_details.first_noa_code then
	  if p_imm_pa_request_rec.noa_family_code = 'RETURN_TO_DUTY' then
	     for rec_noa_famly_code in c_dual_sec_family_code(p_second_noa_id => rec_root_details.second_noa_id)
	     loop
                If  rec_noa_famly_code.noa_family_code = 'CONV_APP' then
		    l_imm_per_group1.org_appointment_auth_code1 := rec_root_details.second_action_la_code1;
		    l_imm_per_group1.org_appointment_auth_code2 := rec_root_details.second_action_la_code2;
	        end if;
	     end loop;
	   end if;
 	 end if;

      end loop;
    end loop;
end if;

hr_utility.set_location('g_dual_prior_ws'||ghr_process_sf52.g_dual_prior_ws,100);
-- End of 8267598

hr_utility.set_location(l_proc,20);

-- FWFA Changes Bug#4444609
-- Bug#4701896
IF ghr_pay_calc.g_pay_table_upd_flag THEN
    IF p_imm_pa_request_rec.input_pay_rate_determinant IN ('A','B','E','F','U','V')
       AND l_imm_per_retained_grade.temp_step IS NULL THEN
       --Begin Bug# 4691288
        BEGIN
            IF l_imm_per_retained_grade.retain_pay_table_id = l_imm_pos_valid_grade.pay_table_id
                and l_imm_pos_valid_grade.pay_table_id <> p_imm_pa_request_rec.to_pay_table_identifier THEN
                FOR p_cur_grd1 in  cur_grd1 LOOP
                    l_grade_or_level := p_cur_grd1.grade_or_level;
                    l_pay_plan := p_cur_grd1.pay_plan;
                END LOOP;
                FOR cur_pay_rec IN cur_pay LOOP
                    l_record_found      := TRUE;
                    EXIT;
                END LOOP;
                IF NOT l_record_found THEN
                    l_imm_pos_valid_grade.pay_table_id := p_imm_pa_request_rec.to_pay_table_identifier;
                    l_imm_pos_valid_grade.valid_grade  := p_imm_pa_request_rec.to_grade_id;
                    l_imm_pos_valid_grade.pos_valid_grade_flag	:=   'Y';
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
       --end Bug# 4691288
        l_imm_per_retained_grade.retain_pay_plan := nvl(ghr_pay_calc.g_out_to_pay_plan,l_imm_per_retained_grade.retain_pay_plan);
        l_imm_per_retained_grade.retain_pay_table_id := p_imm_pa_request_rec.to_pay_table_identifier;
        l_imm_per_retained_grade.per_retained_grade_flag	:=   'Y';
    ELSE
        l_imm_pos_valid_grade.pay_table_id := p_imm_pa_request_rec.to_pay_table_identifier;
        l_imm_pos_valid_grade.valid_grade  := p_imm_pa_request_rec.to_grade_id;
        l_imm_pos_valid_grade.pos_valid_grade_flag	:=   'Y';
    END IF;
END IF;
-- FWFA Changes
-- check that the required SF52 and the Non SF52 data is entered

ghr_upd_hr_validation.main_validation
(p_pa_requests_type                     => p_imm_pa_request_rec
,p_asg_non_sf52_type                    => l_imm_asg_non_sf52
,p_asg_nte_dates_type                   => l_imm_asg_nte_dates
,p_per_group1_type                      => l_imm_per_group1
,p_per_uniformed_services_type          => l_imm_per_uniformed_services
,p_per_retained_grade_type              => l_imm_per_retained_grade
,p_per_sep_retire_type                  => l_imm_per_sep_retire
,p_per_probations_type                  => l_imm_per_probations
,p_pos_grp1_type                        => l_imm_pos_grp1
,p_pos_grp2_type                        => l_imm_pos_grp2
,p_recruitment_bonus_type               => l_imm_recruitment_bonus
,p_relocation_bonus_type                => l_imm_relocation_bonus
,p_student_loan_repay_type              => l_imm_student_loan_repay
--Pradeep
 ,p_mddds_special_pay                   => l_imm_mddds_special_pay
 ,p_premium_pay_ind                     => l_imm_premium_pay_ind

,p_within_grade_increase_type           => l_imm_wgi
,p_government_awards_type               => l_imm_gov_awards
,p_government_payroll_type              => l_imm_payroll_type
,p_performance_appraisal_type           => l_imm_perf_appraisal
,p_per_conversions_type                 => l_imm_per_conversions
,p_conduct_performance_type             => l_imm_conduct_performance
-- Sun 4582970 - Added 3 parameters for benefits eit validation
,p_thrift_savings_plan                  => l_imm_thrift_saving_plan
,p_per_benefit_info                     => l_imm_per_benefit_info
,p_per_scd_info_type                    => l_imm_per_scd_info
);


--Fetch Health Plan

hr_utility.set_location('Health Plan  ' ,20);

ghr_api.retrieve_element_entry_value
( p_element_name                          =>  'Health Benefits'
 ,p_input_value_name                      =>  'Health Plan'
 ,p_assignment_id                         =>   p_imm_pa_request_rec.employee_assignment_id
 ,p_effective_date                        =>   trunc(p_imm_pa_request_rec.effective_date)
 ,p_value                                 =>   l_health_plan
 ,p_multiple_error_flag                   =>   l_error_flag
 );

-- Agency Check hook

GHR_AGENCY_CHECK.AGENCY_CHECK
(
 p_pa_request_rec                         => p_imm_pa_request_rec,
 p_asg_sf52                    			  => l_imm_asg_sf52,
 p_asg_non_sf52		             		  => l_imm_asg_non_sf52,
 p_asg_nte_dates                          => l_imm_asg_nte_dates,
 p_per_sf52                            	  => l_imm_per_sf52,
 p_per_group1                 			  => l_imm_per_group1,
 p_per_group2                 		      => l_imm_per_group2,
 p_per_scd_info                        	  => l_imm_per_scd_info,
 p_per_retained_grade                  	  => l_imm_per_retained_grade,
 p_per_probations                         => l_imm_per_probations,
 p_per_sep_Retire 	            	      => l_imm_per_sep_retire,
 p_per_security                        	  => l_imm_per_security,
 p_per_conversions	             		  => l_imm_per_conversions,
 p_per_uniformed_services             	  => l_imm_per_uniformed_services,
 p_pos_oblig                           	  => l_imm_pos_oblig,
 p_pos_grp2                               => l_imm_pos_grp2,
 p_pos_grp1                               => l_imm_pos_grp1,
 p_pos_valid_grade                     	  => l_imm_pos_valid_grade,
 p_pos_car_prog                        	  => l_imm_pos_car_prog,
 p_loc_info                            	  => l_imm_loc_info,
 p_wgi                                 	  => l_imm_wgi,
 p_recruitment_bonus	               	  => l_imm_recruitment_bonus,
 p_relocation_bonus	             		  => l_imm_relocation_bonus ,
 p_sf52_from_data                      	  => l_imm_sf52_from_data,
 p_personal_info                          => l_imm_personal_info,
 p_gov_awards_type                        => l_imm_gov_awards,
 p_perf_appraisal_type                 	  => l_imm_perf_appraisal,
 p_payroll_type                        	  => l_imm_payroll_type,
 p_conduct_perf_type                   	  => l_imm_conduct_performance,
 p_agency_code		             		  => l_agency_code,
 p_agency_sf52			       			  => l_imm_agency_sf52,
 p_health_plan                        	  => l_health_plan,
 p_entitlement                            => l_imm_entitlement,
 p_foreign_lang_prof_pay                  => l_imm_foreign_lang_prof_pay,
 p_edp_pay                                => l_imm_edp_pay,
 p_hazard_pay                             => l_imm_hazard_pay,
 p_health_benefits                        => l_imm_health_benefits,
 p_danger_pay                             => l_imm_danger_pay,
 p_imminent_danger_pay                    => l_imm_imminent_danger_pay,
 p_living_quarters_allow                  => l_imm_living_quarters_allow,
 p_post_diff_amt                          => l_imm_post_diff_amt,
 p_post_diff_percent                      => l_imm_post_diff_percent,
 p_sep_maintenance_allow                  => l_imm_sep_maintenance_allow,
 p_supplemental_post_allow                => l_imm_supplemental_post_allow,
 p_temp_lodge_allow                       => l_imm_temp_lodge_allow,
 p_premium_pay                            => l_imm_premium_pay,
 p_retirement_annuity                     => l_imm_retirement_annuity,
 p_severance_pay                          => l_imm_severance_pay,
 p_thrift_saving_plan                     => l_imm_thrift_saving_plan,
 p_retention_allow_review                 => l_imm_retention_allow_review,
 p_health_ben_pre_tax                     => l_imm_health_ben_pre_tax,
 -- TAR 4646592.993
 p_per_benefit_info                       => l_imm_per_benefit_info,
 p_imm_retirement_info                    => l_imm_retirement_info --Bug# 7131104
 );
 hr_utility.set_location('3 l_imm_per_group1'||l_imm_per_group1.org_appointment_auth_code1,1000);
-- GHR Validations

GHR_Validate_CHECK.Validate_CHECK
(
  p_imm_pa_request_rec
 ,l_imm_per_group1
 ,l_imm_per_retained_grade
 ,l_imm_per_sep_retire
 ,l_imm_per_conversions
 ,l_imm_per_uniformed_services
 ,l_imm_pos_grp1
 ,l_imm_pos_valid_grade
 ,l_imm_loc_info
 ,l_imm_sf52_from_data
 ,l_imm_personal_info
 ,l_agency_code
 ,l_imm_gov_awards
 ,l_imm_perf_appraisal
 ,l_health_plan
 ,l_imm_asg_non_sf52
 ,l_imm_premium_pay
 -- Bug#5036370
 ,l_imm_per_service_oblig
 ,l_imm_wgi  --Bug 5527363
);

-- Call to CPDF Validation

hr_utility.set_location('Call to CPDF  ' ,21);
hr_utility.set_location('Gov Award id ' || l_imm_gov_awards.group_award,1);
hr_utility.set_location('Prior Pay Plan ' || l_imm_sf52_from_data.pay_plan,1);
--hr_utility.set_location('Prior Pay Plan ' || l_imm_sf52_from_data.duty_station_id,1);

--Pradeep.
--Bypassing the edits for 850 and 855 actions.
 If NOT ( p_imm_pa_request_rec.first_noa_code in ( '850', '855' ) or
    ( p_imm_pa_request_rec.first_noa_code = '002'  and
      p_imm_pa_request_rec.second_noa_code in ( '850', '855' )
    ) ) Then

ghr_ghrws52l.ghrws52l
( p_pa_request_rec 	             	=>	p_imm_pa_request_rec
 ,p_per_group1                		=>	l_imm_per_group1
 ,p_per_retained_grade              =>	l_imm_per_retained_grade
 ,p_per_sep_retire                  =>	l_imm_per_sep_retire
 ,p_per_conversions	                =>	l_imm_per_conversions
 ,p_per_uniformed_services          =>	l_imm_per_uniformed_services
 ,p_pos_grp1                   		=>	l_imm_pos_grp1
 ,p_pos_valid_grade                 =>	l_imm_pos_valid_grade
 ,p_loc_info                   		=>	l_imm_loc_info
 ,p_sf52_from_data                  =>	l_imm_sf52_from_data
 ,p_personal_info        	        =>	l_imm_personal_info
 ,p_gov_awards_type                 =>  l_imm_gov_awards
 ,p_perf_appraisal_type             =>  l_imm_perf_appraisal
 ,p_health_plan                     =>  l_health_plan
 ,p_agency_code		              	=>	l_agency_code
 ,p_race_ethnic_info				=>  l_imm_per_race_ethnic_info -- Bug 4724337 Race or National Origin changes
 );

END IF;

-- Call position Rules

  ghr_posn_rules.ghr_posn_drv
  (
   p_pos_grp1_type         =>  l_imm_pos_grp1
  ,p_pos_grp2_type         =>  l_imm_pos_grp2
  ,p_pos_oblig_type        =>  l_imm_pos_oblig
  ,p_pos_valid_grade_type  =>  l_imm_pos_valid_grade
  ,p_ghr_pa_requests       =>  p_imm_pa_request_rec
  ,p_asg_sf52_type         =>  l_imm_asg_sf52
   );


-- Calling creation of life events procedure
      -- Apr 25,2005  Commented the call to create TSP Life events
      /*
      hr_utility.set_location(l_proc,120);
      ghr_create_ptnl_life_events.create_ptnl_tsp_ler_for_per
      (p_pa_request_rec      => p_imm_pa_request_rec
      );
      */
       hr_utility.set_location(l_proc,125);
      ghr_create_ptnl_life_events.create_ptnl_ler_for_per
      (p_pa_request_rec      => p_imm_pa_request_rec
      );
       hr_utility.set_location(l_proc,125);

-- Do database update steps.
-- (procedures reside in GHR_SF52_DO_UPDATE package.

--
-- Calling Process family procedure

hr_utility.set_location(l_proc,70);

GHR_SF52_DO_UPDATE.Process_Family
 (P_Pa_request_Rec    =>  p_imm_pa_request_rec,
  P_agency_code       =>  l_agency_code );
  hr_utility.set_location('assignmentid aft proc fam ' || to_char(p_imm_pa_request_rec.employee_assignment_id),2);
--
-- calling call_extra_info_api
--

 hr_utility.set_location(l_proc,90);

--hr_utility.set_location('after populate rec gps ' ||to_char(l_imm_pos_gpr2.position_extra_info_id),1);
GHR_SF52_DO_UPDATE.call_extra_info_api
 (P_PA_REQUEST_REC                 	=> p_imm_PA_REQUEST_REC
 ,P_Asg_Sf52                   		=> l_imm_Asg_Sf52
, P_Asg_non_Sf52                   	=> l_imm_Asg_non_Sf52
, P_Asg_nte_dates                  	=> l_imm_Asg_nte_dates
, P_Per_Sf52                   		=> l_imm_Per_Sf52
, P_Per_Group1                		=> l_imm_Per_Group1
, P_Per_Group2                		=> l_imm_Per_Group2
, P_Per_scd_info                   	=> l_imm_Per_scd_info
, P_Per_retained_grade             	=> l_imm_Per_retained_grade
, P_Per_probations                 	=> l_imm_Per_probations
, P_Per_sep_retire                 	=> l_imm_Per_sep_retire
, P_Per_security	                => l_imm_Per_security
--Bug#4486823 RRR Changes
, P_Per_service_oblig               => l_imm_Per_service_oblig
, P_Per_conversions	            	=> l_imm_Per_conversions
-- 4352589 BEN_EIT Changes
, p_per_benefit_info				=> l_imm_per_benefit_info
, P_Per_uniformed_services         	=> l_imm_Per_uniformed_services
, P_Pos_oblig                  		=> l_imm_Pos_oblig
, P_Pos_Grp2                   		=> l_imm_Pos_Grp2
, P_Pos_Grp1                   		=> l_imm_Pos_Grp1
, P_Pos_valid_grade                	=> l_imm_Pos_valid_grade
, P_Pos_car_prog                  	=> l_imm_Pos_car_prog
, p_perf_appraisal                	=> l_imm_perf_appraisal
, p_conduct_performance             => l_imm_conduct_performance
, P_Loc_Info                  		=> l_imm_Loc_Info
, P_generic_Extra_Info_Rec          => l_imm_generic_Extra_Info_Rec
, P_par_term_retained_grade         => l_imm_par_term_retained_grade
, p_per_race_ethnic_info	  => l_imm_per_race_ethnic_info	-- Bug 4724337 Race or National Origin changes
, p_ipa_benefits_cont             => l_imm_ipa_benefits_cont --Bug # 6312144 RPA - EIT Benefits
, p_retirement_info               => l_imm_retirement_info
 );





--
--
-- Calling process_Salary_Info
--
--
 hr_utility.set_location(l_proc,100);

 GHR_SF52_DO_UPDATE.Process_salary_Info
	(p_pa_request_rec     => p_imm_pa_request_rec
	 ,p_wgi               => l_imm_wgi
      ,p_retention_allow_review     => l_imm_retention_allow_review
      ,p_capped_other_pay     => p_capped_other_pay );

--
--  calling Process Non_salary info
--
-- Process_Non_Salary_Info
     hr_utility.set_location(l_proc,110);
  	GHR_SF52_DO_UPDATE.Process_non_salary_Info
	(p_pa_request_rec             => p_imm_pa_request_rec
	,p_recruitment_bonus          => l_imm_recruitment_bonus
	,p_relocation_bonus	      => l_imm_relocation_bonus
	,p_student_loan_repay         => l_imm_student_loan_repay
	--Pradeep
	,p_mddds_special_pay          => l_imm_mddds_special_pay
        ,p_premium_pay_ind            => l_imm_premium_pay_ind

      ,p_gov_award                  => l_imm_gov_awards
      ,p_entitlement                => l_imm_entitlement
      -- Bug#2759379 Added parameter p_fegli
      ,p_fegli                      => l_imm_fegli
      ,p_foreign_lang_prof_pay      => l_imm_foreign_lang_prof_pay
      -- Bug#3385386 Added parameter p_fta
      ,p_fta                        => l_imm_fta
      ,p_edp_pay                    => l_imm_edp_pay
      ,p_hazard_pay                 => l_imm_hazard_pay
      ,p_health_benefits            => l_imm_health_benefits
      ,p_danger_pay                 => l_imm_danger_pay
      ,p_imminent_danger_pay        => l_imm_imminent_danger_pay
      ,p_living_quarters_allow      => l_imm_living_quarters_allow
      ,p_post_diff_amt              => l_imm_post_diff_amt
      ,p_post_diff_percent          => l_imm_post_diff_percent
      ,p_sep_maintenance_allow      => l_imm_sep_maintenance_allow
      ,p_supplemental_post_allow    => l_imm_supplemental_post_allow
      ,p_temp_lodge_allow           => l_imm_temp_lodge_allow
      ,p_premium_pay                => l_imm_premium_pay
      ,p_retirement_annuity         => l_imm_retirement_annuity
      ,p_severance_pay              => l_imm_severance_pay
      ,p_thrift_saving_plan         => l_imm_thrift_saving_plan
      ,p_health_ben_pre_tax            => l_imm_health_ben_pre_tax
      );


-- Benefits processing

		-- Get BG ID
		FOR l_cur_bg_id IN c_bg_id(p_imm_pa_request_rec.person_id, p_imm_pa_request_rec.effective_date) LOOP
			l_bg_id := l_cur_bg_id.bg_id;
		END LOOP;

       hr_utility.set_location(l_proc,120);
       hr_utility.set_location(' noa_family_code ' || p_imm_pa_request_rec.noa_family_code,120);
	   hr_utility.set_location(' Person ID ' || p_imm_pa_request_rec.person_id,120);
       hr_utility.set_location(' Eff. date ' || p_imm_pa_request_rec.effective_date,120);
       hr_utility.set_location(' p_business_group_id ' || l_bg_id,120);
       hr_utility.set_location(' p_pl_code ' || l_imm_health_benefits.health_plan,120);
       hr_utility.set_location(' p_opt_code ' || l_imm_health_benefits.enrollment,120);
       hr_utility.set_location(' p_pre_tax ' || l_imm_health_benefits.pre_tax_waiver,120);
       hr_utility.set_location(' pa_request_id ' || to_char(p_imm_pa_request_rec.pa_request_id),121);


 Populate_Remarks(p_pa_request_id            => p_imm_pa_request_rec.pa_request_id
                 ,p_to_pay_plan              => p_imm_pa_request_rec.to_pay_plan
                 ,p_to_pay_table_identifier  => p_imm_pa_request_rec.to_pay_table_identifier
	         ,p_person_id                => p_imm_pa_request_rec.person_id
		 ,p_pay_rate_determinant     => p_imm_pa_request_rec.pay_rate_determinant
		 ,p_effective_date           => p_imm_pa_request_rec.effective_date
		 ,p_first_noa_code           => p_imm_pa_request_rec.first_noa_code
		 ,p_second_noa_code          => p_imm_pa_request_rec.second_noa_code
		 ,p_leo_indicator            => l_imm_Pos_Grp2.leo_position_indicator
		 ,p_fegli                    => p_imm_pa_request_rec.fegli
		 ); --6398933



--
-- Agency Updates
ghr_agency_update.ghr_agency_upd
(p_pa_request_rec               => p_imm_pa_request_rec,
 p_asg_sf52                     => l_imm_asg_sf52,
 p_asg_non_sf52                 => l_imm_asg_non_sf52,
 p_asg_nte_dates                => l_imm_asg_nte_dates,
 p_per_sf52                     => l_imm_per_sf52,
 p_per_group1                   => l_imm_per_group1,
 p_per_group2                   => l_imm_per_group2,
 p_per_scd_info                 => l_imm_per_scd_info,
 p_per_retained_grade           => l_imm_per_retained_grade,
 p_per_probations               => l_imm_per_probations,
 p_per_sep_Retire               => l_imm_per_sep_retire,
 p_per_security                 => l_imm_per_security,
 p_per_conversions              => l_imm_per_conversions,
 p_per_uniformed_services       => l_imm_per_uniformed_services,
 p_pos_oblig                    => l_imm_pos_oblig,
 p_pos_grp2                     => l_imm_pos_grp2,
 p_pos_grp1                     => l_imm_pos_grp1,
 p_pos_valid_grade              => l_imm_pos_valid_grade,
 p_pos_car_prog                 => l_imm_pos_car_prog,
 p_loc_info                     => l_imm_loc_info,
 p_wgi                          => l_imm_wgi,
 p_recruitment_bonus            => l_imm_recruitment_bonus,
 p_relocation_bonus             => l_imm_relocation_bonus ,
 p_sf52_from_data               => l_imm_sf52_from_data,
 p_personal_info                => l_imm_personal_info,
 p_gov_awards_type              => l_imm_gov_awards,
 p_perf_appraisal_type          => l_imm_perf_appraisal,
 p_payroll_type                 => l_imm_payroll_type,
 p_conduct_perf_type            => l_imm_conduct_performance,
 p_agency_code                  => l_agency_code,
 p_agency_sf52                  => l_imm_agency_sf52,
 p_entitlement                  => l_imm_entitlement,
 p_foreign_lang_prof_pay        => l_imm_foreign_lang_prof_pay,
 p_edp_pay                      => l_imm_edp_pay,
 p_hazard_pay                   => l_imm_hazard_pay,
 p_health_benefits              => l_imm_health_benefits,
 p_danger_pay                   => l_imm_danger_pay,
 p_imminent_danger_pay          => l_imm_imminent_danger_pay,
 p_living_quarters_allow        => l_imm_living_quarters_allow,
 p_post_diff_amt                => l_imm_post_diff_amt,
 p_post_diff_percent            => l_imm_post_diff_percent,
 p_sep_maintenance_allow        => l_imm_sep_maintenance_allow,
 p_supplemental_post_allow      => l_imm_supplemental_post_allow,
 p_temp_lodge_allow             => l_imm_temp_lodge_allow,
 p_premium_pay                  => l_imm_premium_pay,
 p_retirement_annuity           => l_imm_retirement_annuity,
 p_severance_pay                => l_imm_severance_pay,
 p_thrift_saving_plan           => l_imm_thrift_saving_plan,
 p_retention_allow_review       => l_imm_retention_allow_review,
 p_health_ben_pre_tax           => l_imm_health_ben_pre_tax,
 p_per_benefit_info		=> l_imm_per_benefit_info,
 p_imm_retirement_info          => l_imm_retirement_info --Bug# 7131104
);
--
-- Start of Bug # 5195518 modified related to handling of Conversion to Appointment
l_temp_appt := 'N';
IF ghr_utility.is_ghr_ben_fehb = 'TRUE' and p_imm_pa_request_rec.noa_family_code IN ('CONV_APP') THEN
  IF l_imm_health_benefits.health_plan IS NOT NULL THEN
     IF l_imm_health_benefits.health_plan <> 'ZZ' AND l_imm_health_benefits.enrollment NOT IN ('W','X','Y','Z') THEN

        for enr in  get_current_enrollment (p_asg_id => p_imm_pa_request_rec.employee_assignment_id,
                                            p_business_group_id => l_bg_id ,
               			            p_effective_date => p_imm_pa_request_rec.effective_date)
        LOOP
	   IF enr.enrollment = 'Z' then
              ghr_element_api.process_sf52_element
		 (p_assignment_id        =>    p_imm_pa_request_rec.employee_assignment_id
                 ,p_element_name         =>    'Health Benefits'
   	         ,p_input_value_name1    =>    'Enrollment'
                 ,p_value1               =>    'X'
                 ,p_input_value_name2    =>    'Health Plan'
                 ,p_value2               =>    'ZZ'
           	 ,p_effective_date       =>    p_imm_pa_request_rec.effective_date
                 ,p_process_warning      =>    l_warning
		 );
		 l_temp_appt := 'Y';
	    END IF;
	  END LOOP;
        END IF;
      END IF;
    END IF;

-- Modified to move post_update_process after benefits processing as
-- to maintain history
      -- Call Benefits processing Bug 4582970
IF p_imm_pa_request_rec.noa_family_code in ('APP','CONV_APP','SEPARATION') THEN
--   l_temp_appt := 'N';
  IF ghr_utility.is_ghr_ben_fehb = 'TRUE' THEN
     -- Will be uncommented later
     IF p_imm_pa_request_rec.noa_family_code in ('SEPARATION')  THEN
     --Added this code to validate whether HB is already enrolled before processing separation life event
     -- Get Program ID
        FOR pgm_rec in c_get_pgm_id('Federal Employees Health Benefits', l_bg_id, p_imm_pa_request_rec.effective_date)
	LOOP -- Eff date and BG ID
           l_pgm_id := pgm_rec.pgm_id;
           EXIT;
        END LOOP;

	IF l_pgm_id is not null THEN
  	  for emp_ben_rec in c_emp_in_ben(p_imm_pa_request_rec.person_id, l_pgm_id, p_imm_pa_request_rec.effective_date)
	  LOOP
            l_exists := TRUE;
	    exit;
          end loop;
        END IF;
	If l_exists then
          ghr_benefits_eit.ghr_benefits_fehb
	       (errbuf => l_errbuf,
	   	retcode => l_retcode,
		p_person_id => p_imm_pa_request_rec.person_id,
		p_effective_date => fnd_date.date_to_canonical(p_imm_pa_request_rec.effective_date),
		p_business_group_id => l_bg_id,
		p_pl_code => NULL,
		p_opt_code => NULL,
		p_pre_tax => l_imm_health_benefits.pre_tax_waiver,
		p_assignment_id => p_imm_pa_request_rec.employee_assignment_id,
	        p_temps_total_cost => l_imm_health_benefits.temps_total_cost,
		p_temp_appt => l_temp_appt
		);
         End If;
     ELSE
       IF l_imm_health_benefits.health_plan IS NOT NULL THEN
  	  IF l_imm_health_benefits.health_plan = 'ZZ' AND l_imm_health_benefits.enrollment IN ('W','X','Y','Z') THEN
               ghr_element_api.process_sf52_element
		(p_assignment_id        =>    p_imm_pa_request_rec.employee_assignment_id
                ,p_element_name         =>    'Health Benefits'
		,p_input_value_name1    =>    'Enrollment'
		,p_value1               =>    l_imm_health_benefits.enrollment
                ,p_input_value_name2    =>    'Health Plan'
		,p_value2               =>    l_imm_health_benefits.health_plan
		,p_input_value_name3    =>    'Temps Total Cost'
                ,p_value3               =>    l_imm_health_benefits.temps_total_cost
		,p_input_value_name4    =>    'Pre tax Waiver'
                ,p_value4               =>    l_imm_health_benefits.pre_tax_waiver
		,p_effective_date       =>    p_imm_pa_request_rec.effective_date
                ,p_process_warning      =>    l_warning
		);
	  ELSE
	    ghr_benefits_eit.ghr_benefits_fehb
	       (errbuf => l_errbuf,
	   	retcode => l_retcode,
		p_person_id => p_imm_pa_request_rec.person_id,
		p_effective_date => fnd_date.date_to_canonical(p_imm_pa_request_rec.effective_date),
		p_business_group_id => l_bg_id,
		p_pl_code => l_imm_health_benefits.health_plan,
		p_opt_code => l_imm_health_benefits.enrollment,
		p_pre_tax => l_imm_health_benefits.pre_tax_waiver,
		p_assignment_id => p_imm_pa_request_rec.employee_assignment_id,
	        p_temps_total_cost => l_imm_health_benefits.temps_total_cost,
		p_temp_appt => l_temp_appt
		);
	   END IF;
	END IF;
      END IF;
END IF; -- IF ghr_utility.is_ghr_ben_fehb = 'TRUE

IF ghr_utility.is_ghr_ben_tsp = 'TRUE' THEN
   IF l_imm_thrift_saving_plan.amount > 0 THEN
      l_amount_or_rate := 'Amount';
      l_opt_val := l_imm_thrift_saving_plan.amount;
   ELSIF l_imm_thrift_saving_plan.rate > 0 THEN
      l_amount_or_rate := 'Percentage';
      l_opt_val := l_imm_thrift_saving_plan.rate;
   ELSE
      l_amount_or_rate := NULL;
   END IF;
   hr_utility.set_location(' tsp status ' || l_imm_thrift_saving_plan.status,120);
   hr_utility.set_location(' l_amount_or_rate ' || l_amount_or_rate,120);
   hr_utility.set_location(' l_opt_val ' || l_opt_val,120);
      IF l_amount_or_rate IS NOT NULL OR l_imm_thrift_saving_plan.status IN ('T','S') THEN
         ghr_benefits_eit.ghr_benefits_tsp(errbuf => l_errbuf,
					retcode => l_retcode,
					p_person_id  => p_imm_pa_request_rec.person_id,
					p_effective_date  => fnd_date.date_to_canonical(p_imm_pa_request_rec.effective_date),
					p_business_group_id => l_bg_id,
					p_tsp_status => l_imm_thrift_saving_plan.status,
					p_opt_name => l_amount_or_rate,
					p_opt_val => l_opt_val
					);
       END IF;
   END IF; -- IF ghr_utility.is_ghr_ben_tsp = 'TRUE' T
 END IF; -- IF p_imm_pa_request_rec.noa_family_code = 'APP'
 -- End of Bug # 5195518

ghr_history_api.post_update_process;

exception when others then
  --
  -- Reset IN OUT parameters and set OUT parameters
  -- /* Added for NOCOPY changes  */
     p_imm_pa_request_rec := l_imm_pa_request_rec_in;
     p_capped_other_pay   := l_capped_other_pay_in;
     raise;

End Process_Immediate_Update;
--

-- Parameters for the foll.procedure
--  p_pa_request_rec         - To hold data of the current SF52 / in case of correction (correction + changes)
--  p_pa_request_extra_info  - pa_request_extra_info for the current pa_Request
--

PROCEDURE MAIN
      (p_pa_request_rec     in out nocopy   ghr_pa_requests%rowtype,
       p_pa_request_ei_rec  in     ghr_pa_request_extra_info%rowtype,
       p_generic_ei_rec     in     ghr_pa_request_extra_info%rowtype,
       p_capped_other_pay   in number default null
      )
 IS

 l_proc    		  varchar2(70) := 'Main';
 --l_rec     		  ghr_pa_requests%rowtype ;
 l_notification_id        ghr_pa_requests.pa_notification_id%type;
 l_person_type            per_person_types.system_person_type%type;
 l_pa_request_rec         ghr_pa_requests%rowtype;
 l_pa_request_rec_in      ghr_pa_requests%rowtype; /* Added for NOCOPY changes  */
 l_position_id            per_positions.position_id%type;
 l_date_end               per_positions.date_end%type;

 Cursor c_sf50 is
   select pa_notification_id
   from   ghr_pa_requests par
   where  par.pa_request_id =  p_pa_request_rec.pa_request_id;

 Cursor c_pos_end_date is
   select date_end
   from   hr_all_positions_f pos  -- Venkat -- Position DT
   where  pos.position_id = l_position_id
   and p_pa_request_rec.effective_date between
         pos.effective_start_date and pos.effective_end_date;


l_capped_other_pay number;

Begin
--
   hr_utility.set_location('Entering ' || l_proc,10);
   hr_utility.set_location(l_proc || p_pa_request_rec.to_position_number,12);


  l_pa_request_rec_in := p_pa_request_rec;   /* Added for NOCOPY changes  */
  g_effective_date := p_pa_request_rec.effective_date;


  l_capped_other_pay  := p_capped_other_pay;

  hr_utility.set_location(l_proc,20);
  l_pa_request_rec           :=   p_pa_request_rec;

  -- The foll. check ensures that the RPA is not processed
  -- if the TO_position(or From Position) is end dated
  If l_pa_request_rec.to_position_id is not null then
    l_position_id  :=  l_pa_request_rec.to_position_id;
  Else
    l_position_id  :=  l_pa_request_rec.from_position_id;
  End if;
  If l_position_id is not null then
    for c_pos_rec in c_pos_end_date loop
       l_date_end := c_pos_rec.date_end;
    end loop;
    if nvl(l_date_end,l_pa_request_rec.effective_date) < l_pa_request_rec.effective_date then
      -- raise error;
      hr_utility.set_message(8301,'GHR_38594_POSN_END_DATED');
      hr_utility.raise_error;
    end if;
  End if;

  Process_Immediate_Update
  (p_imm_pa_request_rec      =>  l_pa_request_rec,
   p_imm_pa_request_ei_rec   =>  p_pa_request_ei_rec,
   p_imm_generic_ei_rec      =>  p_generic_ei_rec,
   p_capped_other_pay        =>  l_capped_other_pay
  );
 p_pa_request_rec  :=  l_pa_request_rec;
 hr_utility.set_location('Assignment Id ' || to_char(p_pa_request_rec.employee_assignment_id),2);

--
--
  hr_utility.set_location('Leaving  ' ||l_proc,40);

  exception when others then
  --
  -- Reset IN OUT parameters and set OUT parameters
  --
     p_pa_request_rec := l_pa_request_rec_in ;   /* Added for NOCOPY changes  */
     raise;

end MAIN;

end  GHR_SF52_UPDATE;


/
