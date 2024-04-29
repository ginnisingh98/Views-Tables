--------------------------------------------------------
--  DDL for Package Body GHR_MASS_CHANGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MASS_CHANGES" AS
/* $Header: ghmass52.pkb 120.9.12010000.2 2008/12/02 06:44:55 vmididho ship $ */

-- Begin declaration

g_package  varchar2(32) := 'GHR_MASS_CHANGES.' ;

Procedure  create_refreshed_sf52_shadow(
      p_action    in varchar2,
      p_sf52_data in ghr_pa_requests%rowtype);

--- End Declaration

Procedure create_sf52_for_mass_changes
(p_mass_action_type  in      varchar2,
 p_pa_request_rec    in out  NOCOPY ghr_pa_requests%rowtype,
 p_errbuf            out     NOCOPY varchar2, --\___  error log
 p_retcode           out     NOCOPY number    --/     in conc. manager.
)

is

l_proc              		varchar2(72) :=  g_package || 'create_sf52_for_mass_changes';
l_pa_request_rec    		ghr_pa_requests%rowtype;
l_noa_code          		ghr_pa_requests.first_noa_code%type;
l_scd_leave         		varchar2(30);
l_pa_remark_code1    		ghr_remarks.code%type;
l_pa_remark_code2    		ghr_remarks.code%type;
l_1_prh_object_version_number ghr_pa_requests.object_version_number%type;
l_1_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%type;
l_2_prh_object_version_number ghr_pa_requests.object_version_number%type;
l_2_pa_routing_history_id     ghr_pa_routing_history.pa_routing_history_id%type;
l_multiple_error_flag         boolean;
l_dummy                       varchar2(30);
l_remark_id                   ghr_remarks.remark_id%type;
l_description                 ghr_remarks.description%type;
l_pa_remark_id                ghr_pa_remarks.pa_remark_id%type;
l_object_version_number       ghr_pa_remarks.object_version_number%type;
l_message                     varchar2(2000);
l_error                       varchar2(30);
l_log_text                    varchar2(2000);
l_route_flag                  varchar2(1);
l_routing_group_id            ghr_pa_requests.routing_group_id%type;
l_groupbox_id                 ghr_groupboxes.groupbox_id%type;
l_pa_routing_history_id       ghr_pa_routing_history.pa_routing_history_id%type;
l_approving_off_work_title    ghr_pa_requests.APPROVING_OFFICIAL_WORK_TITLE%type;
l_personnel_office_id         ghr_pois.personnel_office_id%type;
l_personnel_officer_name      per_people_f.full_name%type;
l_remark_code_information1    ghr_pa_remarks.remark_code_information1%type;
l_remark_code_information2    ghr_pa_remarks.remark_code_information2%type;
l_remark_code_information3    ghr_pa_remarks.remark_code_information3%type;
l_remark_code_information4    ghr_pa_remarks.remark_code_information4%type;
l_remark_code_information5    ghr_pa_remarks.remark_code_information5%type;

l_au_overtime                 ghr_pa_requests.to_au_overtime%TYPE;
l_auo_premium_pay_indicator   ghr_pa_requests.to_auo_premium_pay_indicator%TYPE;
l_availability_pay            ghr_pa_requests.to_availability_pay%TYPE;
l_ap_premium_pay_indicator    ghr_pa_requests.to_ap_premium_pay_indicator%TYPE;
l_retention_allowance         ghr_pa_requests.to_retention_allowance%TYPE;
l_supervisory_differential    ghr_pa_requests.to_supervisory_differential%TYPE;
l_staffing_differential       ghr_pa_requests.to_staffing_differential%TYPE;
l_duty_station_location_id    hr_locations.location_id%TYPE;
l_duty_station_id             ghr_duty_stations_v.duty_station_id%TYPE;
l_duty_station_code           ghr_duty_stations_v.duty_station_code%TYPE;
l_duty_station_desc           ghr_duty_stations_v.duty_station_desc%TYPE;
l_appropriation_code1         varchar2(30);
l_appropriation_code2         varchar2(30);
l_position_id                 hr_positions_f.position_id%TYPE;
l_noa_family_code             ghr_families.noa_family_code%type;
-- Bug#4256022 Declared the variable l_desc_out
l_desc_out		      ghr_pa_requests.first_noa_desc%TYPE;

l_pa_request_num_prefix       varchar2(10);
groupbox_err                  exception;

l_sid                         number;

l_new_retention_allowance       number;     ---AVR
l_new_supervisory_differential  number;     ---AVR

l_dummy_char                  VARCHAR2(150);  --Bug 2013340 --AVR
l_full_name                   VARCHAR2(380);  -- Bug 3718167 --VN
l_ssn			      ghr_pa_requests.employee_national_identifier%TYPE; -- Bug 3718167 --VN

---SES Changes Start
l_user_table_id               pay_user_tables.user_table_id%type;

-- Bug#5089732
l_to_grade_id NUMBER;
-- Bug#5089732
cursor c_pay_tab_essl is
  select 1 from pay_user_tables
  where substr(user_table_name,1,4) = 'ESSL'
  and user_table_id = l_user_table_id;

l_essl_table  BOOLEAN := FALSE;

----SES Changes End

  cursor cur_sessionid is
  select userenv('sessionid') sesid  from dual;

  cursor get_sal_chg_fam is
    select NOA_FAMILY_CODE
    from ghr_families
    where NOA_FAMILY_CODE in
        (select NOA_FAMILY_CODE from ghr_noa_families
             where  nature_of_action_id =
                (select nature_of_action_id
                 from ghr_nature_of_actions
                 where code = '894')
        ) and proc_method_flag = 'Y';

  Cursor  c_routing_history is
    select prh.pa_routing_history_id,
           prh.object_version_number
    from   ghr_pa_routing_history prh
    where  prh.pa_request_id  =  l_pa_request_rec.pa_request_id
    order  by  1 desc;

     --7577249
    cursor get_family_code(p_effective_date  in date) is
    select NOA_FAMILY_CODE
    from ghr_families
    where NOA_FAMILY_CODE in
       (select NOA_FAMILY_CODE from ghr_noa_families
        where  nature_of_action_id =
            (select nature_of_action_id
             from ghr_nature_of_actions
             where code = nvl(ghr_msl_pkg.g_first_noa_code,'894') and  p_effective_date between date_from and nvl(date_to,p_effective_date))
        ) and proc_method_flag = 'Y';
----7577249

l_errbuf	VARCHAR2(2000);
l_retcode	NUMBER;

Begin
--INITIALIZE
 l_errbuf       := p_errbuf;
 l_retcode	:= p_retcode;
--
   for s_id in cur_sessionid
   loop
     l_sid  := s_id.sesid;
   exit;
   end loop;

  begin
      update fnd_sessions set SESSION_ID = l_sid
      where  SESSION_ID = l_sid;
      if sql%notfound then
         INSERT INTO fnd_sessions
            (SESSION_ID,EFFECTIVE_DATE)
         VALUES
            (l_sid,sysdate);
      end if;
  end;

   hr_utility.set_location('Entering    ' || l_proc,5);
   savepoint create_sf52_for_mass_changes;

   l_pa_request_rec       :=  p_pa_request_rec;
   -- Bug#3718167 Getting the employee_full name into l_full_name to use in the Log Text
   l_full_name  := l_pa_request_rec.employee_last_name||','|| l_pa_request_rec.employee_first_name||' '|| l_pa_request_rec.employee_middle_names;
   l_ssn        := l_pa_request_rec.employee_national_identifier;
 -- These will be the ones that will be common to all the mass actions.
 --

 -- The foll. would be common to all the mass actions

   l_pa_request_rec.additional_info_person_id          :=  Null;
   l_pa_request_rec.additional_info_tel_number         :=  Null;
   l_pa_request_rec.Proposed_Effective_Date            :=  Null;
   l_pa_request_rec.Proposed_Effective_ASAP_flag       :=  'N';
   l_pa_request_rec.requested_by_person_id             :=  Null;
   l_pa_request_rec.requested_by_title                 :=  Null;
   l_pa_request_rec.requested_date	                   :=  Null;
   l_pa_request_rec.authorized_by_person_id            :=  Null;
   l_pa_request_rec.authorized_by_title                :=  Null;
   l_pa_request_rec.concurrence_Date                   :=  Null;
--Bug #1295328 initialize
   l_pa_request_rec.forwarding_address_line1           :=  Null;
   l_pa_request_rec.forwarding_address_line2           :=  Null;
   l_pa_request_rec.forwarding_address_line3           :=  Null;
   l_pa_request_rec.forwarding_country                 :=  Null;
   l_pa_request_rec.forwarding_country_short_name      :=  Null;
   l_pa_request_rec.forwarding_postal_code             :=  Null;
   l_pa_request_rec.forwarding_region_2                :=  Null;
   l_pa_request_rec.forwarding_town_or_city            :=  Null;
   l_pa_request_rec.rpa_type				:= p_pa_request_rec.rpa_type;
   l_pa_request_rec.mass_action_id			:= p_pa_request_rec.mass_action_id;

   If  p_mass_action_type = 'MASS_SALARY_CHG' then
              hr_utility.set_location(l_proc,10);
      --7577249 commented hardcoding and added to fetch noa family code as
      -- for SES employees noa code changes by changing the lac code

       open get_family_code(p_effective_date       => l_pa_request_rec.effective_date);
       fetch get_family_code into l_pa_request_rec.noa_Family_Code;
       close get_family_code;
            --7577249

       l_pa_request_num_prefix		     := p_pa_request_rec.rpa_type;
--       l_pa_request_rec.noa_Family_Code      :=  'GHR_SAL_PAY_ADJ';
       l_pa_request_rec.first_noa_code       :=  nvl(ghr_msl_pkg.g_first_noa_code,'894');
   ElsIf  p_mass_action_type = 'MASS_LOCALITY_CHG' then
       hr_utility.set_location(l_proc,10);
     if ghr_msl_pkg.g_first_noa_code is not null then
       l_pa_request_rec.noa_family_code      := 'GHR_SAL_PAY_ADJ';
       l_pa_request_rec.first_noa_code       := ghr_msl_pkg.g_first_noa_code;
     else
       l_pa_request_rec.noa_family_code      := 'GHR_SAL_LOCAL_PAY';
       l_pa_request_rec.first_noa_code       := '895';
     end if;
       l_pa_request_num_prefix               := 'MLC';
   ElsIf  p_mass_action_type = 'MASS_TABLE_CHG' then
       hr_utility.set_location(l_proc,10);
       if l_pa_request_rec.from_basic_pay = l_pa_request_rec.to_basic_pay
       AND l_pa_request_rec.input_pay_rate_determinant <> l_pa_request_rec.pay_rate_determinant then
          l_pa_request_rec.noa_family_code  := 'CHG_DATA_ELEMENT';
          l_pa_request_rec.first_noa_code   :=  '800';
       else
          l_pa_request_rec.noa_family_code  := 'GHR_SAL_PAY_ADJ';
          l_pa_request_rec.first_noa_code   :=  '894';
       end if;
       l_pa_request_num_prefix               := 'MTC';
   Elsif p_mass_action_type = 'MASS_REALIGNMENT' then
      l_pa_request_rec.noa_family_code := 'REALIGNMENT'; -- Action requested
      l_pa_request_rec.first_noa_code  := 790;
      l_pa_request_num_prefix  := 'MRE';
   Elsif  p_mass_action_type = 'MASS_TRANSFER_OUT' Then
      l_pa_request_rec.noa_family_code := 'SEPARATION';
      l_pa_request_rec.first_noa_code  := 352;
      l_pa_request_num_prefix  := 'MTO';
   Elsif p_mass_action_type = 'MASS_TRANSFER_IN' Then
      l_pa_request_num_prefix := 'MTI';
   End if;

   hr_utility.set_location(l_proc,35);
   ghr_mass_actions_pkg.get_noa_id_desc
       (p_noa_code 	          => l_pa_request_rec.first_noa_code,
        p_effective_date       => l_pa_request_rec.effective_date,
        p_noa_id     	  => l_pa_request_rec.first_noa_id,
        p_noa_desc             => l_pa_request_rec.first_noa_desc
        );


  IF p_mass_action_type = 'MASS_TRANSFER_OUT' THEN

-- First NOA Code has insertion values. The insertion value will be
-- the To Agency Code the employee is transferring to.
          -- Bug#4256022 Passed the parameter l_desc_out and reassigned its value to
	  -- l_pa_request_rec.first_noa_desc to avoid NOCOPY related problems..
          ghr_mass_actions_pkg.replace_insertion_values
	    (p_desc                => l_pa_request_rec.first_noa_desc,
	     p_information1        => l_pa_request_rec.first_noa_information1,
	     p_desc_out            => l_desc_out
	    );
	  l_pa_request_rec.first_noa_desc := l_desc_out;
  END IF;

  hr_utility.set_location(l_proc,40);


   -- For Mass Transfer IN we don't have to fetch any information
   -- it is all passed in.


   -- From side and To side position information
   -- In case of the mass salary, pay calc identified as common
   -- b/w show and create and hence
   -- would have to_total_salary,to_basic_pay,to_locality_adj,
   -- to_adjusted_basic_pay,to_other_pay and its sub components.
   -- All the rest of the To side will be the same as the From Side.

   -- For Realignment the TO will be same as the FROM.
   -- For Transfer OUT the TO side will be NULL


   IF p_mass_action_type <> 'MASS_TRANSFER_IN' THEN

      hr_utility.set_location(l_proc,55);

      ghr_api.sf52_from_data_elements
        (p_person_id                 =>	l_pa_request_rec.person_id
        ,p_assignment_id        	=>	l_pa_request_rec.employee_assignment_id
        ,p_effective_date       	=>	l_pa_request_rec.effective_date
----added 3 parameters.
        ,p_altered_pa_request_id        =>      null
        ,p_noa_id_corrected             =>      null
        ,p_pa_history_id                =>      null
---
        ,p_position_title          	=>	l_pa_request_rec.from_position_title
        ,p_position_number         	=>      l_pa_request_rec.from_position_number
        ,p_position_seq_no         	=>	l_pa_request_rec.from_position_seq_no
        ,p_pay_plan                	=>	l_pa_request_rec.from_pay_plan
        ,p_job_id                  	=>	l_pa_request_rec.to_job_id
        ,p_occ_code                	=>	l_pa_request_rec.from_occ_code
        -- Bug#5089732 Passed local variable for grade_id. For MSL, we've to consider the grade_id passed
        -- from the execute_msl process.
        ,p_grade_id                	=>	l_to_grade_id
        ,p_grade_or_level          	=>	l_pa_request_rec.from_grade_or_level
        ,p_step_or_rate            	=>	l_pa_request_rec.from_step_or_rate
        ,p_total_salary            	=>	l_pa_request_rec.from_total_salary
        ,p_pay_basis               	=>	l_pa_request_rec.from_pay_basis
	-- FWFA Changes Bug#4444609
	,p_pay_table_identifier         =>      l_pa_request_rec.from_pay_table_identifier
	-- FWFA Changes
        ,p_basic_pay               	=>	l_pa_request_rec.from_basic_pay
        ,p_locality_adj            	=>	l_pa_request_rec.from_locality_adj
        ,p_adj_basic_pay           	=>	l_pa_request_rec.from_adj_basic_pay
        ,p_other_pay               	=>	l_pa_request_rec.from_other_pay_amount
     -- All these Other Pay comps. were put on the TO side. I think it is a BUG
      -- But confirm it with Rohini. It may be a BUG for Mass Salary.
        ,p_au_overtime               =>	l_au_overtime
        ,p_auo_premium_pay_indicator	=>	l_pa_request_rec.to_auo_premium_pay_indicator
        ,p_availability_pay         	=>	l_availability_pay
        ,p_ap_premium_pay_indicator 	=>	l_pa_request_rec.to_ap_premium_pay_indicator
        ,p_retention_allowance      	=>      l_new_retention_allowance
--
        ,p_retention_allow_percentage   =>      l_pa_request_rec.to_retention_allow_percentage
        ,p_supervisory_differential 	=>	l_new_supervisory_differential
--
        ,p_supervisory_diff_percentage  =>      l_pa_request_rec.to_supervisory_diff_percentage
        ,p_staffing_differential    	=>	l_pa_request_rec.to_staffing_differential
--
        ,p_staffing_diff_percentage     =>      l_pa_request_rec.to_staffing_diff_percentage
        ,p_organization_id          	=>	l_pa_request_rec.to_organization_id
        ,p_position_org_line1      	=>	l_pa_request_rec.from_position_org_line1
        ,p_position_org_line2       	=>	l_pa_request_rec.from_position_org_line2
        ,p_position_org_line3       	=>	l_pa_request_rec.from_position_org_line3
        ,p_position_org_line4        =>      l_pa_request_rec.from_position_org_line4
        ,p_position_org_line5        =>      l_pa_request_rec.from_position_org_line5
        ,p_position_org_line6       	=>	l_pa_request_rec.from_position_org_line6
        ,p_position_id             	=>	l_pa_request_rec.from_position_id
        ,p_duty_station_location_id 	=>	l_duty_station_location_id
---Bug 2013340
        ,p_pay_rate_determinant    	=>      l_dummy_char
        ,p_work_schedule		=>	l_pa_request_rec.work_schedule
      );
-- Bug#2850747 Added MASS_REALIGNMENT

       if  p_mass_action_type NOT IN ('MASS_SALARY_CHG','MASS_REALIGNMENT','MASS_LOCALITY_CHG',
                                      'MASS_TABLE_CHG')  then
           l_pa_request_rec.to_retention_allowance      := l_new_retention_allowance;
           l_pa_request_rec.to_supervisory_differential := l_new_supervisory_differential;
       end if;

        -- Bug#5089732 For mass salary don't assing the the grade id.
        IF  p_mass_action_type <> 'MASS_SALARY_CHG' then
            l_pa_request_rec.to_grade_id := l_to_grade_id;
        END IF;

-- In case of Mass realignment we don't need the value of duty station location
-- from the FROM side. This will be assigned the target duty station locn id.

      IF p_mass_action_type <> 'MASS_REALIGNMENT' OR l_pa_request_rec.duty_station_location_id is NULL THEN
         l_pa_request_rec.duty_station_location_id := l_duty_station_location_id;
      END IF;


      hr_utility.set_location(l_proc,60);

   -- populate to side with the from side except for Mass Transfer OUT.

      IF p_mass_action_type not in ('MASS_TRANSFER_OUT') THEN
         l_pa_request_rec.to_position_title :=   l_pa_request_rec.from_position_title;
         l_pa_request_rec.to_position_number := l_pa_request_rec.from_position_number;
         l_pa_request_rec.to_position_seq_no := l_pa_request_rec.from_position_seq_no;
         -- Bug#5089732 For mass salary don't assing the the grade id.
         IF  p_mass_action_type <> 'MASS_SALARY_CHG' then
             l_pa_request_rec.to_pay_plan        := l_pa_request_rec.from_pay_plan;
             l_pa_request_rec.to_grade_or_level  :=  l_pa_request_rec.from_grade_or_level;
         END IF;
         l_pa_request_rec.to_occ_code        := l_pa_request_rec.from_occ_code;

         l_pa_request_rec.to_pay_basis      	:= l_pa_request_rec.from_pay_basis;
--   l_pa_request_rec.to_organization_id          :=	l_pa_request_rec.to_organization_id;
         l_pa_request_rec.to_position_org_line1      	:=	l_pa_request_rec.from_position_org_line1;
         l_pa_request_rec.to_position_org_line2       :=	l_pa_request_rec.from_position_org_line2;
         l_pa_request_rec.to_position_org_line3       :=    l_pa_request_rec.from_position_org_line3;
         l_pa_request_rec.to_position_org_line4       :=    l_pa_request_rec.from_position_org_line4;
         l_pa_request_rec.to_position_org_line5       :=	l_pa_request_rec.from_position_org_line5;
         l_pa_request_rec.to_position_org_line6       :=	l_pa_request_rec.from_position_org_line6;
         l_pa_request_rec.to_position_id             	:=	l_pa_request_rec.from_position_id;
         ----SES PAY Changes...
         If  p_mass_action_type = 'MASS_SALARY_CHG' then
	   -- Pradeep added EE to the following if list for the Bug 3604377
             if l_pa_request_rec.to_pay_plan in  ('ES','EP','FE','IE','EE') then

                l_user_table_id := ghr_pay_calc.get_user_table_id(
                            p_position_id      => l_pa_request_rec.to_position_id
                           ,p_effective_date   => l_pa_request_rec.effective_date
                           );

                l_essl_table := FALSE;
                for c_pay_tab_essl_rec in c_pay_tab_essl loop
                    l_essl_table := TRUE;
                exit;
                end loop;

                if l_essl_table then
                   l_pa_request_rec.to_step_or_rate := '00';
                else
                   l_pa_request_rec.to_step_or_rate     := l_pa_request_rec.from_step_or_rate;
                end if;
             else
                l_pa_request_rec.to_step_or_rate     := l_pa_request_rec.from_step_or_rate;
             end if;

         else
            l_pa_request_rec.to_step_or_rate     := l_pa_request_rec.from_step_or_rate;
         end if;
         ----SES Pay CHanges...end..
      END IF; -- For Seperation action, the TO position details have to be NULL

END IF; -- If it is not Mass transfer IN condn.

-------------------------------For Mass Salary----------------------

 -- Assuming that the foll. blocked elements will be passed in , as the new pay calc would have been done in the
 -- Calling procedure

--   ,p_total_salary
--   ,p_basic_pay
--   ,p_locality_adj
--   ,p_adj_basic_pay
--   ,p_other_pay
--   ,p_au_overtime
--   ,p_auo_premium_pay_indicator
--   ,p_availability_pay
--   ,p_ap_premium_pay_indicator
--   ,p_retention_allowance
--   ,p_supervisory_differential
--   ,p_staffing_differential
--------------------------------------------------------------------

   -- Employee Data

   -- # Bug 711533 : Added the if condition
   IF p_mass_action_type <> 'MASS_TRANSFER_IN' THEN
     hr_utility.set_location(l_proc,65);
     ghr_pa_requests_pkg.get_SF52_person_ddf_details
        (p_person_id   		        =>      l_pa_request_rec.person_id,
         p_date_effective             	=> 	l_pa_request_rec.effective_date,
         p_citizenship  		   	=> 	l_pa_request_rec.citizenship,
         p_veterans_preference 	   	=> 	l_pa_request_rec.veterans_preference,
         p_veterans_pref_for_rif      	=> 	l_pa_request_rec.veterans_pref_for_rif,
         p_veterans_status 	       	=> 	l_pa_request_rec.veterans_status,
         p_scd_leave               	=>      l_scd_leave
        );

     -- populate service comp date
     hr_utility.set_location(l_proc,70);

      ---l_pa_request_rec.service_comp_date 	:= to_date(l_scd_leave, 'dd-mon-yyyy');
      l_pa_request_rec.service_comp_date 	:= fnd_date.canonical_to_date(l_scd_leave);

   -- get education details
     hr_utility.set_location(l_proc,75);
     ghr_api.return_education_Details
       (p_person_id                    =>  l_pa_request_rec.person_id,
        p_effective_date               =>  l_pa_request_rec.effective_date,
        p_education_level              =>  l_pa_request_rec.education_level,
        p_academic_discipline          =>  l_pa_request_rec.academic_discipline,
        p_year_degree_attained         =>  l_pa_request_rec.year_degree_attained
        );

     hr_utility.set_location(l_proc,80);
   End if;

   IF p_mass_action_type = 'MASS_TRANSFER_IN' THEN
      l_position_id := l_pa_request_rec.to_position_id;
   ELSE
      l_position_id := l_pa_request_rec.from_position_id;
   END IF;

   IF p_mass_action_type <> 'MASS_TRANSFER_IN' THEN

      ghr_pa_requests_pkg.get_sf52_pos_ddf_details
         (p_position_id               =>  l_position_id
         ,p_date_Effective            =>  l_pa_request_rec.effective_date
         ,p_flsa_category             =>  l_pa_request_rec.flsa_category
         ,p_bargaining_unit_status    =>  l_pa_request_rec.bargaining_unit_status
         ,p_work_schedule             =>  l_dummy
         ,p_functional_class          =>  l_pa_request_rec.functional_class
         ,p_supervisory_status        =>  l_pa_request_rec.supervisory_status
         ,p_position_occupied         =>  l_pa_request_rec.position_occupied
         ,p_appropriation_code1       =>  l_appropriation_code1
         ,p_appropriation_code2       =>  l_appropriation_code2
         ,p_personnel_office_id       =>  l_personnel_office_id
         ,p_office_symbol             =>  l_dummy
         ,p_part_time_hours           =>  l_dummy
         );

   END IF;

   IF p_mass_action_type = 'MASS_TRANSFER_IN' THEN

      ghr_pa_requests_pkg.get_sf52_pos_ddf_details
         (p_position_id               =>  l_position_id
         ,p_date_Effective            =>  l_pa_request_rec.effective_date
         ,p_flsa_category             =>  l_dummy
         ,p_bargaining_unit_status    =>  l_dummy
         ,p_work_schedule             =>  l_dummy
         ,p_functional_class          =>  l_dummy
         ,p_supervisory_status        =>  l_dummy
         ,p_position_occupied         =>  l_dummy
         ,p_appropriation_code1       =>  l_dummy
         ,p_appropriation_code2       =>  l_dummy
         ,p_personnel_office_id       =>  l_personnel_office_id
         ,p_office_symbol             =>  l_dummy
         ,p_part_time_hours           =>  l_dummy
         );
   END IF;


   IF l_pa_request_rec.appropriation_code1 is NULL THEN
      l_pa_request_rec.appropriation_code1 := l_appropriation_code1;
   END IF;

   IF l_pa_request_rec.appropriation_code2 is NULL THEN
      l_pa_request_rec.appropriation_code2 := l_appropriation_code2;
   END IF;

   If p_mass_action_type <> 'MASS_TRANSFER_IN' THEN

 -- get fegli,retirement_plan

       ghr_api.retrieve_element_entry_value
          (p_element_name        => 'FEGLI'
          ,p_input_value_name    => 'FEGLI'
          ,p_assignment_id       => l_pa_request_rec.employee_assignment_id
          ,p_effective_date      => l_pa_request_rec.effective_date
          ,p_value               => l_pa_request_rec.fegli
          ,p_multiple_error_flag => l_multiple_error_flag
          );

   --retirement_plan
       ghr_api.retrieve_element_entry_value
            (p_element_name        => 'Retirement Plan'
            ,p_input_value_name    => 'Plan'
            ,p_assignment_id       => l_pa_request_rec.employee_assignment_id
            ,p_effective_date      => l_pa_request_rec.effective_date
            ,p_value               => l_pa_request_rec.retirement_plan
            ,p_multiple_error_flag => l_multiple_error_flag
            );

   END IF; -- end for the condn. not = mass transfer in for retrieving elements.

       l_pa_request_rec.fegli_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_FEGLI'
                 ,l_pa_request_rec.fegli
                 );


       l_pa_request_rec.retirement_plan_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_RETIREMENT_PLAN'
                 ,l_pa_request_rec.retirement_plan
                 );


   IF p_mass_action_type = 'MASS_TRANSFER_IN' THEN
        -- Commented out following lines VBug # 701368
--      l_pa_request_rec.to_adj_basic_pay := 0;
--      l_pa_request_rec.to_basic_pay := 0;
--      l_pa_request_rec.to_total_salary := 0;
        null;

   ELSIF p_mass_action_type = 'MASS_TRANSFER_OUT' THEN
      l_pa_request_rec.to_step_or_rate := null;
      l_pa_request_rec.to_adj_basic_pay := null;
      l_pa_request_rec.to_basic_pay := null;
      l_pa_request_rec.to_total_salary := null;
      -- VSM  Bug # 714487
        l_pa_request_rec.to_other_pay_amount          := NULL;
        l_pa_request_rec.to_au_overtime               := NULL;
        l_pa_request_rec.to_auo_premium_pay_indicator := NULL;
        l_pa_request_rec.to_availability_pay          := NULL;
        l_pa_request_rec.to_ap_premium_pay_indicator  := NULL;
        l_pa_request_rec.to_retention_allowance       := NULL;
        l_pa_request_rec.to_supervisory_differential  := NULL;
        l_pa_request_rec.to_staffing_differential     := NULL;
        l_pa_request_rec.to_locality_adj              := NULL;
      -- R11.5 columns
        l_pa_request_rec.to_retention_allow_percentage  := NULL;
        l_pa_request_rec.to_supervisory_diff_percentage := NULL;
        l_pa_request_rec.to_staffing_diff_percentage    := NULL;
   END IF;



  -- Descriptions for the codes passed in

  -- Annuitant_indicator
    l_pa_request_rec.annuitant_indicator_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_ANNUITANT_INDICATOR'
                 ,l_pa_request_rec.annuitant_indicator
                 );

  --WORK_SCHEDULE
    l_pa_request_rec.work_schedule_desc := ghr_pa_requests_pkg.get_lookup_meaning
                 (800
                 ,'GHR_US_WORK_SCHEDULE'
                 ,l_pa_request_rec.work_schedule
                 );

    ghr_mass_actions_pkg.get_personnel_officer_name
            (p_personnel_office_id => l_personnel_office_id,
             p_person_full_name    => l_personnel_officer_name,
             p_approving_off_work_title => l_approving_off_work_title);


--Bug #1295328 initialize
  IF p_mass_action_type = 'MASS_TRANSFER_OUT' THEN
     ghr_pa_requests_pkg.get_address_details
         (p_person_id            => l_pa_request_rec.person_id
         ,p_effective_date       => l_pa_request_rec.effective_date
         ,p_address_line1        => l_pa_request_rec.forwarding_address_line1
         ,p_address_line2        => l_pa_request_rec.forwarding_address_line2
         ,p_address_line3        => l_pa_request_rec.forwarding_address_line3
         ,p_town_or_city         => l_pa_request_rec.forwarding_town_or_city
         ,p_region_2             => l_pa_request_rec.forwarding_region_2
         ,p_postal_code          => l_pa_request_rec.forwarding_postal_code
         ,p_country              => l_pa_request_rec.forwarding_country
         ,p_territory_short_name => l_pa_request_rec.forwarding_country_short_name);
  END IF;


   -- SF52_asg_rec_type already would have been passed ,
   -- so is the pos_grp1  --MS
   -- get person_ei data
   -- fetch pos_grp2
   -- Duty station  - passed in -- MS
   -- Create SF52

   l_log_text  := 'Error while creating / Updating the PA Request Rec. ';

   ghr_sf52_api.create_sf52
   (	p_noa_family_code                  => l_pa_request_rec.noa_family_code,
--   	p_routing_group_id                 => l_pa_request_rec.routing_group_id, -- This would be updated after creation.
    	p_proposed_effective_asap_flag     => l_pa_request_rec.proposed_effective_asap_flag,
    	p_academic_discipline              => l_pa_request_rec.academic_discipline,
    	p_additional_info_person_id        => l_pa_request_rec.additional_info_person_id,
    	p_additional_info_tel_number       => l_pa_request_rec.additional_info_tel_number,
--	p_altered_pa_request_id            => l_pa_request_rec.altered_pa_request_id,
	p_annuitant_indicator              => l_pa_request_rec.annuitant_indicator,
	p_annuitant_indicator_desc         => l_pa_request_rec.annuitant_indicator_desc,
	p_appropriation_code1              => l_pa_request_rec.appropriation_code1,
	p_appropriation_code2              => l_pa_request_rec.appropriation_code2,
	p_authorized_by_person_id          => l_pa_request_rec.authorized_by_person_id,
	p_authorized_by_title              => l_pa_request_rec.authorized_by_title,
	p_award_amount                     => l_pa_request_rec.award_amount,
	p_award_uom                        => l_pa_request_rec.award_uom,
	p_bargaining_unit_status           => l_pa_request_rec.bargaining_unit_status,
	p_citizenship                      => l_pa_request_rec.citizenship,
	p_concurrence_date             	   => l_pa_request_rec.concurrence_date,
	p_custom_pay_calc_flag             => l_pa_request_rec.custom_pay_calc_flag, -- Expecxt
	p_duty_station_code                => l_pa_request_rec.duty_station_code,
	p_duty_station_desc                => l_pa_request_rec.duty_station_desc,
	p_duty_station_id                  => l_pa_request_rec.duty_station_id,
	p_duty_station_location_id         => l_pa_request_rec.duty_station_location_id,
	p_education_level                  => l_pa_request_rec.education_level,
	p_effective_date                   => l_pa_request_rec.effective_date,
	p_employee_assignment_id           => l_pa_request_rec.employee_assignment_id,
	p_employee_date_of_birth           => l_pa_request_rec.employee_date_of_birth,
	p_employee_first_name              => l_pa_request_rec.employee_first_name,
	p_employee_last_name               => l_pa_request_rec.employee_last_name,
	p_employee_middle_names            => l_pa_request_rec.employee_middle_names,
	p_employee_national_identifier     => l_pa_request_rec.employee_national_identifier,
	p_fegli                            => l_pa_request_rec.fegli,
	p_fegli_desc                       => l_pa_request_rec.fegli_desc,
	p_first_action_la_code1            => l_pa_request_rec.first_action_la_code1,
	p_first_action_la_code2            => l_pa_request_rec.first_action_la_code2,
	p_first_action_la_desc1            => l_pa_request_rec.first_action_la_desc1,
	p_first_action_la_desc2            => l_pa_request_rec.first_action_la_desc2,
--	p_first_noa_cancel_or_correct      => l_pa_request_rec.first_noa_cancel_or_correct,
	p_first_noa_code                   => l_pa_request_rec.first_noa_code,
	p_first_noa_desc                   => l_pa_request_rec.first_noa_desc,
	p_first_noa_id                     => l_pa_request_rec.first_noa_id,
        p_first_noa_information1           => l_pa_request_rec.first_noa_information1,
	p_first_noa_pa_request_id          => l_pa_request_rec.first_noa_pa_request_id,
	p_flsa_category                    => l_pa_request_rec.flsa_category,
  	p_forwarding_address_line1         => l_pa_request_rec.forwarding_address_line1,
  	p_forwarding_address_line2         => l_pa_request_rec.forwarding_address_line2,
  	p_forwarding_address_line3         => l_pa_request_rec.forwarding_address_line3,
  	p_forwarding_country               => l_pa_request_rec.forwarding_country,
  	p_forwarding_country_short_nam     => l_pa_request_rec.forwarding_country_short_name,
  	p_forwarding_postal_code           => l_pa_request_rec.forwarding_postal_code,
  	p_forwarding_region_2              => l_pa_request_rec.forwarding_region_2,
  	p_forwarding_town_or_city          => l_pa_request_rec.forwarding_town_or_city,
	p_from_adj_basic_pay               => l_pa_request_rec.from_adj_basic_pay,
	p_from_basic_pay                   => l_pa_request_rec.from_basic_pay,
	p_from_grade_or_level              => l_pa_request_rec.from_grade_or_level,
	p_from_locality_adj                => l_pa_request_rec.from_locality_adj,
	p_from_occ_code                    => l_pa_request_rec.from_occ_code,
	p_from_other_pay_amount            => l_pa_request_rec.from_other_pay_amount,
	p_from_pay_basis                   => l_pa_request_rec.from_pay_basis,
	p_from_pay_plan                    => l_pa_request_rec.from_pay_plan,
	p_from_position_id                 => l_pa_request_rec.from_position_id,
	p_from_position_org_line1          => l_pa_request_rec.from_position_org_line1,
	p_from_position_org_line2          => l_pa_request_rec.from_position_org_line2,
	p_from_position_org_line3          => l_pa_request_rec.from_position_org_line3,
	p_from_position_org_line4          => l_pa_request_rec.from_position_org_line4,
	p_from_position_org_line5          => l_pa_request_rec.from_position_org_line5,
	p_from_position_org_line6          => l_pa_request_rec.from_position_org_line6,
	p_from_position_number             => l_pa_request_rec.from_position_number,
	p_from_position_seq_no             => l_pa_request_rec.from_position_seq_no,
	p_from_position_title              => l_pa_request_rec.from_position_title,
	p_from_step_or_rate                => l_pa_request_rec.from_step_or_rate,
	p_from_total_salary                => l_pa_request_rec.from_total_salary,
	p_functional_class                 => l_pa_request_rec.functional_class,
	p_notepad                          => l_pa_request_rec.notepad,
	p_part_time_hours                  => l_pa_request_rec.part_time_hours,
	p_pay_rate_determinant             => l_pa_request_rec.pay_rate_determinant,
	p_person_id                        => l_pa_request_rec.person_id,
	p_position_occupied                => l_pa_request_rec.position_occupied,
	p_proposed_effective_date          => l_pa_request_rec.proposed_effective_date,
	p_requested_by_person_id           => l_pa_request_rec.requested_by_person_id,
	p_requested_by_title               => l_pa_request_rec.requested_by_title,
	p_requested_date                   => l_pa_request_rec.requested_date,
	p_requesting_office_remarks_de     => l_pa_request_rec.requesting_office_remarks_desc,
      p_requesting_office_remarks_fl       => l_pa_request_rec.requesting_office_remarks_flag,
--	p_request_number                   => l_pa_request_rec.request_number,
	p_resign_and_retire_reason_des     => l_pa_request_rec.resign_and_retire_reason_desc,
	p_retirement_plan                  => l_pa_request_rec.retirement_plan,
	p_retirement_plan_desc             => l_pa_request_rec.retirement_plan_desc,
--	p_second_action_la_code1           => l_pa_request_rec.second_action_la_code1,
--	p_second_action_la_code2           => l_pa_request_rec.second_action_la_code2,
--	p_second_action_la_desc1           => l_pa_request_rec.second_action_la_desc1,
--	p_second_action_la_desc2           => l_pa_request_rec.second_action_la_desc2,
--	p_second_noa_cancel_or_correct
--	p_second_noa_code                  => l_pa_request_rec.second_noa_code,
--	p_second_noa_desc                  => l_pa_request_rec.second_noa_desc,
--	p_second_noa_id                    => l_pa_request_rec.second_noa_id,
--	p_second_noa_pa_request_id         => l_pa_request_rec.
	p_service_comp_date                => l_pa_request_rec.service_comp_date,
	p_supervisory_status               => l_pa_request_rec.supervisory_status,
	p_tenure                           => l_pa_request_rec.tenure,
	p_to_adj_basic_pay                 => l_pa_request_rec.to_adj_basic_pay,
	p_to_basic_pay                     => l_pa_request_rec.to_basic_pay,
	p_to_grade_id                      => l_pa_request_rec.to_grade_id,
	p_to_grade_or_level                => l_pa_request_rec.to_grade_or_level,
	p_to_job_id                        => l_pa_request_rec.to_job_id,
	p_to_locality_adj                  => l_pa_request_rec.to_locality_adj,
	p_to_occ_code                      => l_pa_request_rec.to_occ_code,
	p_to_organization_id               => l_pa_request_rec.to_organization_id,
	p_to_other_pay_amount              => l_pa_request_rec.to_other_pay_amount,
	p_to_au_overtime                   => l_pa_request_rec.to_au_overtime,
	p_to_auo_premium_pay_indicator     => l_pa_request_rec.to_auo_premium_pay_indicator,
	p_to_availability_pay              => l_pa_request_rec.to_availability_pay,
	p_to_ap_premium_pay_indicator      => l_pa_request_rec.to_ap_premium_pay_indicator,
	p_to_retention_allowance           => l_pa_request_rec.to_retention_allowance,
	p_to_supervisory_differential      => l_pa_request_rec.to_supervisory_differential,
	p_to_staffing_differential         => l_pa_request_rec.to_staffing_differential,
	p_to_pay_basis                     => l_pa_request_rec.to_pay_basis,
	p_to_pay_plan                      => l_pa_request_rec.to_pay_plan,
	p_to_position_id                   => l_pa_request_rec.to_position_id,
	p_to_position_org_line1            => l_pa_request_rec.to_position_org_line1,
	p_to_position_org_line2            => l_pa_request_rec.to_position_org_line2,
	p_to_position_org_line3            => l_pa_request_rec.to_position_org_line3,
	p_to_position_org_line4            => l_pa_request_rec.to_position_org_line4,
	p_to_position_org_line5            => l_pa_request_rec.to_position_org_line5,
	p_to_position_org_line6            => l_pa_request_rec.to_position_org_line6,
	p_to_position_number               => l_pa_request_rec.to_position_number,
 	p_to_position_seq_no               => l_pa_request_rec.to_position_seq_no,
	p_to_position_title                => l_pa_request_rec.to_position_title,
	p_to_step_or_rate                  => l_pa_request_rec.to_step_or_rate,
	p_to_total_salary                  => l_pa_request_rec.to_total_salary,
	p_veterans_preference              => l_pa_request_rec.veterans_preference,
	p_veterans_pref_for_rif            => l_pa_request_rec.veterans_pref_for_rif,
	p_veterans_status                  => l_pa_request_rec.veterans_status,
	p_work_schedule                    => l_pa_request_rec.work_schedule,
	p_work_schedule_desc               => l_pa_request_rec.work_schedule_desc,
	p_year_degree_attained             => l_pa_request_rec.year_degree_attained,
	p_first_lac1_information1          => l_pa_request_rec.first_lac1_information1,
	p_first_lac1_information2          => l_pa_request_rec.first_lac1_information2,
	p_first_lac1_information3          => l_pa_request_rec.first_lac1_information3,
	p_first_lac1_information4          => l_pa_request_rec.first_lac1_information4,
	p_first_lac1_information5          => l_pa_request_rec.first_lac1_information5,
	p_first_lac2_information1          => l_pa_request_rec.first_lac2_information1,
	p_first_lac2_information2          => l_pa_request_rec.first_lac2_information2,
	p_first_lac2_information3          => l_pa_request_rec.first_lac2_information3,
	p_first_lac2_information4          => l_pa_request_rec.first_lac2_information4,
	p_first_lac2_information5          => l_pa_request_rec.first_lac2_information5,
      p_second_lac1_information1           => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information2         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information3         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information4         => l_pa_request_rec.second_lac1_information1,
	p_second_lac1_information5         => l_pa_request_rec.second_lac1_information1,
      p_print_sf50_flag                    => 'N', -- true for all ??
	p_printer_name                     => Null,
	p_1_attachment_modified_flag       => 'N',
	p_1_approved_flag                  => 'N',
	p_1_user_name_acted_on             => Null,
	p_1_action_taken                   => 'NOT_ROUTED',
	p_2_user_name_routed_to            => Null,
	p_2_groupbox_id                    => Null,
	p_2_routing_list_id                => Null,
	p_2_routing_seq_number             => Null,
    p_to_retention_allow_percentag     => l_pa_request_rec.to_retention_allow_percentage,
    p_to_supervisory_diff_percenta     => l_pa_request_rec.to_supervisory_diff_percentage,
    p_to_staffing_diff_percentage      => l_pa_request_rec.to_staffing_diff_percentage ,
	p_pa_request_id                    => l_pa_request_rec.pa_request_id,
	p_par_object_version_number        => l_pa_request_rec.object_version_number,
	p_1_pa_routing_history_id          => l_1_pa_routing_history_id,
	p_1_prh_object_version_number      => l_1_prh_object_version_number,
	p_2_pa_routing_history_id          => l_2_pa_routing_history_id,
	p_2_prh_object_version_number      => l_2_prh_object_version_number
   ,p_approving_official_full_name     => l_personnel_officer_name
   ,p_approval_date                    => sysdate
   ,p_approving_official_work_titl     => l_approving_off_work_title
   ,p_1_approval_status                => 'APPROVE'
       --Added for 3843306
   ,p_rpa_type				           => l_pa_request_rec.rpa_type
   ,p_mass_action_id			       => l_pa_request_rec.mass_action_id
   -- FWFA changes bug#4444609
   ,p_from_pay_table_identifier        => l_pa_request_rec.from_pay_table_identifier
   ,p_to_pay_table_identifier          => l_pa_request_rec.to_pay_table_identifier
   ,p_input_pay_rate_determinant       => l_pa_request_rec.input_pay_rate_determinant
   -- FWFA Changes
    );





    -- Having got the l_1_pa_routing_history_id and l_1_prh_object_version_number
    --  from the above procedure, use it in the ghr_prh_upd.upd to  update the groupbox_id
    -- ( use ghr_mass_actions_pkg.get_personnel_off_groupbox to get the groupbox_id and
    --     the routing_group_id)
    -- Also update the ghr_pa_requests with the routing_group_id passed out
    -- ghr_par_upd.upd
    -- If the groupbox_id is null, then rollback to create_52_for_mass_changes and then nake an
    -- entry in the ghr_process_log  -- (not sure about this part)

       BEGIN

       ghr_mass_actions_pkg.get_personnel_off_groupbox(
				nvl(l_pa_request_rec.from_position_id,
          			    l_pa_request_rec.to_position_id),
	                            l_pa_request_rec.effective_date,
				    l_groupbox_id, -- Out put parameters
				    l_routing_group_id);

	EXCEPTION

	  WHEN OTHERS THEN
               -- Bug#4355764 Modified the Group box error message.
               l_log_text := 'Groupbox error for employee with SSN: '||l_ssn||'; Name:'||l_full_name
                            || '; Error: '||sqlerrm(sqlcode);
               RAISE groupbox_err;
	END;

	-- Call ghr_prh_upd.upd here

       ghr_prh_upd.upd(
                p_pa_routing_history_id   => l_1_pa_routing_history_id,
                p_groupbox_id             => l_groupbox_id,
                p_object_version_number   => l_1_prh_object_version_number);


	-- Call ghr_par_upd.upd here
       ghr_par_upd.upd(
	   p_pa_request_id   		=> l_pa_request_rec.pa_request_id,
           p_routing_group_id 		=> l_routing_group_id,
	   p_object_version_number      => l_pa_request_rec.object_version_number);

     l_pa_request_rec.to_retention_allowance      := l_new_retention_allowance;
     l_pa_request_rec.to_supervisory_differential := l_new_supervisory_differential;

     p_pa_request_rec := l_pa_request_rec;


    hr_utility.set_location('After creation of PA REQUEST '||to_char(l_pa_request_rec.pa_request_id),10);

-- Update the request number with a prefix to indicate what mass action it is.
-- and concatenate it with the request id.

-- Note :  I guess it is OK in case of mass actions
-- to write to the shadow after it has written
-- to the ghr_pa_requests table . If not we would have to
-- write to the shadow first
-- and then pass the pa_request_id into the create_sf52 procedure call

    l_log_text       :=      'Error while creating PA Request Shadow row ';

   IF p_mass_action_type = 'MASS_REALIGNMENT' THEN
  -- We need to put into the shadow table, the values that we are changing through
-- the 52 which are AP/UE so that, UPDATE HR will not refresh the values.

      ghr_pa_requests_pkg.get_SF52_loc_ddf_details
             (p_location_id      => l_duty_station_location_id
             ,p_duty_station_id  => l_pa_request_rec.duty_station_id);

	ghr_pa_requests_pkg.get_duty_station_details
             (p_duty_station_id          => l_pa_request_rec.duty_station_id
             ,p_effective_date           => l_pa_request_rec.effective_date
             ,p_duty_station_code        => l_pa_request_rec.duty_station_code
             ,p_duty_station_desc        => l_pa_request_rec.duty_station_desc);

-- Bug # 654126
      l_pa_request_rec.duty_station_location_id := l_duty_station_location_id;
      l_pa_request_rec.appropriation_code1 := l_appropriation_code1;
      l_pa_request_rec.appropriation_code2 := l_appropriation_code2;

    END IF;

   -- # Bug 51133
    create_refreshed_sf52_shadow(
           p_action => p_mass_action_type,
           p_sf52_data => l_pa_request_rec);
    --     ghr_process_sf52.create_shadow_row
    --    (P_SF52_DATA                          =>    l_pa_request_rec
    --    );
--dbms_output.put_line('after creating shadow row');


-- Update ghr_pa_requests with request_number and
--  approval_date / approving_off._work_title
-- which will then cause this SF52 to be
--  picked by the concurrent program that handles the FUTURE Action.

    l_log_text  := 'Error while creating / Updating  PA Request Rec. ';

--dbms_output.put_line('before updating par');
    -- Bug # 711220 (Field Employing Dept. or Agency, Agency Code, Per. office id
    ghr_sf52_post_update.get_notification_details(
        p_pa_request_id           =>  l_pa_request_rec.pa_request_id,
        p_effective_date          =>  l_pa_request_rec.effective_date,
        p_from_position_id        =>  l_pa_request_rec.from_position_id,
        p_to_position_id          =>  l_pa_request_rec.to_position_id,
        p_agency_code             =>  l_pa_request_rec.agency_code,
        p_from_agency_code        =>  l_pa_request_rec.from_agency_code,
        p_from_agency_desc        =>  l_pa_request_rec.from_agency_desc,
        p_from_office_symbol      =>  l_pa_request_rec.from_office_symbol,
        p_personnel_office_id     =>  l_pa_request_rec.personnel_office_id,
        p_employee_dept_or_agency =>  l_pa_request_rec.employee_dept_or_agency,
        p_to_office_symbol        =>  l_pa_request_rec.to_office_symbol);

-- VSM : Bug # 677880, Added sf50 parameters to populate the values.
    ghr_par_upd.upd
    (p_pa_request_id             => l_pa_request_rec.pa_request_id,
     p_object_version_number     => l_pa_request_rec.object_version_number,
     p_agency_code               =>  l_pa_request_rec.agency_code,
     p_from_agency_code          =>  l_pa_request_rec.from_agency_code,
     p_from_agency_desc          =>  l_pa_request_rec.from_agency_desc,
     p_from_office_symbol        =>  l_pa_request_rec.from_office_symbol,
     p_personnel_office_id       =>  l_pa_request_rec.personnel_office_id,
     p_employee_dept_or_agency   =>  l_pa_request_rec.employee_dept_or_agency,
     p_to_office_symbol          =>  l_pa_request_rec.to_office_symbol,
     p_request_number            => l_pa_request_num_prefix || to_char(l_pa_request_rec.pa_request_id),
     p_sf50_approving_ofcl_full_nam        => l_personnel_officer_name,
     p_sf50_approval_date                  => sysdate ,
     p_sf50_approving_ofcl_work_tit       => l_approving_off_work_title
    );

--dbms_output.put_line('after updating par');

   l_pa_request_rec.request_number    := l_pa_request_num_prefix|| to_char(l_pa_request_rec.pa_request_id);


   -- Since we are not calling the process_sf52 by passing
   -- 'FUTURE_ACTION' as the action_taken in the
   --  above procedure, updating it on the routing history table
   --  by using the row handler, just in
   --  case .

    for routing_history_id in c_routing_history loop
      l_pa_routing_history_id      :=   routing_history_id.pa_routing_history_id;
      l_object_version_number      :=   routing_history_id.object_version_number;
      exit;
    end loop;

    ghr_prh_upd.upd
    (p_pa_routing_history_id        =>   l_pa_routing_history_id,
     p_object_version_number        =>   l_object_version_number,
     p_action_taken                 =>   'FUTURE_ACTION'
    );
--dbms_output.put_line('after updating prh');

-- Sending Back the PA Request ID to the calling program to
-- create the extra info record.

     p_pa_request_rec := l_pa_request_rec;

Exception
  When groupbox_err then
    rollback to create_sf52_for_mass_changes;
    hr_utility.set_location('Error occured  in   ' || l_proc , 1);

    IF l_log_text is NULL THEN
       l_log_text   := 'Error while create / Update the PA Request Rec. ';
    END IF;
    p_errbuf   := substr(l_log_text || 'Details in GHR_PROCESS_LOG',1,2000);
    p_retcode  := 1;
    -- For group box error, name and SSN are added before raising this error.
    l_log_text := substr(l_log_text,1,2000);

     hr_utility.set_location('before creating entry in log file',10);
     ghr_mto_int.log_message( p_procedure => 'While Creating SF52'
                             ,p_message   => l_log_text);

     hr_utility.set_location('created entry in log file',20);
     COMMIT;
  WHEN others THEN
    p_pa_request_rec	:=  l_pa_request_rec;

    rollback to create_sf52_for_mass_changes;
    hr_utility.set_location('Error occured  in   ' || l_proc , 1);

    IF l_log_text is NULL THEN
       l_log_text   := 'Error while create / Update the PA Request Rec. ';
    END IF;
     p_errbuf   := l_log_text || 'Details in GHR_PROCESS_LOG';
     p_retcode  := 1;

     -- Bug#3718167 Added Full Name, SSN in the log text
    l_log_text := l_log_text ||' for '||l_full_name||' SSN: '||l_ssn||' Sql error : '||sqlerrm(sqlcode);

     hr_utility.set_location('before creating entry in log file',10);

               ghr_mto_int.log_message(
                               p_procedure => 'While Creating SF52'
                              ,p_message   => l_log_text);


     hr_utility.set_location('created entry in log file',20);

     commit;

end create_sf52_for_mass_changes;


Procedure create_remarks
(p_pa_request_rec        in   ghr_pa_requests%rowtype,
 p_remark_code 	       in   ghr_remarks.code%type
)
is

l_proc                        varchar2(72)  := g_package || 'create_remarks';
l_remark_id            		ghr_remarks.remark_id%type;
l_description          		ghr_pa_remarks.description%type;
-- Bug#4256022 Declared the variable l_description_out
l_description_out      	      ghr_pa_remarks.description%type;
l_remark_code_information1    ghr_pa_remarks.remark_code_information1%type;
l_remark_code_information2    ghr_pa_remarks.remark_code_information2%type;
l_remark_code_information3    ghr_pa_remarks.remark_code_information3%type;
l_remark_code_information4    ghr_pa_remarks.remark_code_information4%type;
l_remark_code_information5    ghr_pa_remarks.remark_code_information5%type;
l_retained_grade_rec          ghr_pay_calc.retained_Grade_rec_type;
l_pa_remark_id                ghr_pa_remarks.pa_remark_id%type;
l_object_version_number       ghr_pa_remarks.object_version_number%type;

begin

   -- get remark_id remark_desc, remark_code_information1, ...
  hr_utility.set_location('Entering   '  || l_proc,5);

  ghr_mass_actions_pkg.get_remark_id_desc
  (p_remark_code 	           => p_remark_code,
   p_effective_date          => trunc(nvl(p_pa_request_rec.effective_date,sysdate)),
   p_remark_id     	     => l_remark_id,
   p_remark_desc             => l_description
  );
  hr_utility.set_location(l_proc,10);
  l_remark_code_information1              :=  Null;
  l_remark_code_information2              :=  Null;
  l_remark_code_information3              :=  Null;
  l_remark_code_information4              :=  Null;
  l_remark_code_information5              :=  Null;

  If p_remark_code = 'X44' then
    hr_utility.set_location(l_proc,15);
  -- if there are entries for insertion values then alter the description accordingly.
    l_retained_grade_rec   :=  ghr_pc_basic_pay.get_retained_grade_details
                               (p_person_id          =>  p_pa_request_rec.person_id,
                                p_effective_Date     =>  trunc(nvl(p_pa_request_rec.effective_Date,sysdate))
                               );
      -- handle the exception if this fails. ??!!!!!
      -- get retention grade details
      l_remark_code_information1              :=  l_retained_grade_rec.step_or_rate;
      l_remark_code_information2              :=  l_retained_grade_rec.pay_plan;
    --  l_remark_code_information3              :=  l_retained_grade_rec.grade_or_level;
    -- Bug#4256022 Passed parameter l_description_out to the procedure call
    -- and reassigned it back to l_description to avoid NOCOPY related problems..
    ghr_mass_actions_pkg.replace_insertion_values
    (p_desc                => l_description,
     p_information1        => l_remark_code_information1,
     p_information2        => l_remark_code_information2,
     p_information3        => l_remark_code_information3,
     p_information4        => l_remark_code_information4,
     p_information5        => l_remark_code_information5,
     p_desc_out            => l_description_out
    );
    l_description := l_description_out;
  End if;

  ghr_pa_remarks_api.create_pa_remarks
  (
   p_PA_REQUEST_ID                     =>    p_pa_request_rec.pa_request_id,
   p_REMARK_ID                         =>    l_remark_id,
   p_DESCRIPTION                       =>    l_description,
   P_REMARK_CODE_INFORMATION1          =>    l_remark_code_information1,
   P_REMARK_CODE_INFORMATION2          =>    l_remark_code_information2,
   P_REMARK_CODE_INFORMATION3          =>    l_remark_code_information3,
   P_REMARK_CODE_INFORMATION4          =>    l_remark_code_information4,
   P_REMARK_CODE_INFORMATION5          =>    l_remark_code_information5,
   P_PA_REMARK_ID                      =>    l_pa_remark_id,
   p_OBJECT_VERSION_NUMBER             =>    l_object_version_number
   );
 End create_remarks;

 Procedure  create_refreshed_sf52_shadow(
        p_action in varchar2,
        p_sf52_data  in ghr_pa_requests%rowtype) is

   l_sf52_data      ghr_pa_requests%rowtype;
   l_service_comp_date   varchar2(20);
   l_dummy               varchar2(200);

 Begin

   l_sf52_data := p_sf52_data;

   if nvl(p_action, 'xXxX#$%') = 'MASS_TRANSFER_IN' then
     ghr_pa_requests_pkg.get_SF52_person_ddf_details
        (p_person_id             => l_sf52_data.person_id
        ,p_date_effective        => l_sf52_data.effective_date
        ,p_citizenship           => l_sf52_data.citizenship
        ,p_veterans_preference   => l_sf52_data.veterans_preference
        ,p_veterans_pref_for_rif => l_sf52_data.veterans_pref_for_rif
        ,p_veterans_status       => l_sf52_data.veterans_status
        ,p_scd_leave             => l_service_comp_date);

     -- l_sf52_data.citizenship		:=	l_citizenship;
     -- l_sf52_data.veterans_preference	:=	l_veterans_preference;
     -- l_sf52_data.veterans_pref_for_rif	:=	l_veterans_pref_for_rif;
     -- l_sf52_data.veterans_status		:=	l_veterans_status;
     ---l_sf52_data.service_comp_date	:= to_date(l_service_comp_date, 'DD-MON-YYYY');
     l_sf52_data.service_comp_date	:= fnd_date.canonical_to_date(l_service_comp_date);

     ghr_api.return_education_details(
	  p_person_id            => l_sf52_data.person_id
         ,p_effective_date       => l_sf52_data.effective_date
         ,p_education_level      => l_sf52_data.education_level
         ,p_academic_discipline  => l_sf52_data.academic_discipline
         ,p_year_degree_attained => l_sf52_data.year_degree_attained);

     -- l_sf52_data.education_level		:=	l_education_level;
     -- l_sf52_data.academic_discipline	:=	l_academic_discipline;
     -- l_sf52_data.year_degree_attained	:=	l_year_degree_attained;

          ghr_pa_requests_pkg.get_SF52_pos_ddf_details
                       (p_position_id            =>  l_sf52_data.to_position_id
                        ,p_date_effective         => l_sf52_data.effective_date
                        ,p_flsa_category          => l_sf52_data.flsa_category
                        ,p_bargaining_unit_status => l_sf52_data.bargaining_unit_status
                        ,p_work_schedule          => l_sf52_data.work_schedule
                        ,p_functional_class       => l_sf52_data.functional_class
                        ,p_supervisory_status     => l_sf52_data.supervisory_status
                        ,p_position_occupied      => l_sf52_data.position_occupied
                        ,p_appropriation_code1    => l_sf52_data.appropriation_code1
                        ,p_appropriation_code2    => l_sf52_data.appropriation_code2
                        ,p_personnel_office_id    => l_dummy
                        ,p_office_symbol          => l_dummy
                        ,p_part_time_hours        => l_sf52_data.part_time_hours);
      -- Bug#2708682  Set Tenure to Null
      l_sf52_data.tenure := null;
   End if;

   ghr_process_sf52.create_shadow_row
    (P_SF52_DATA                          =>    l_sf52_data);

 End create_refreshed_sf52_shadow;

end ghr_mass_changes;

/
