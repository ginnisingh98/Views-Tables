--------------------------------------------------------
--  DDL for Package Body GHR_CREATE_PTNL_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CREATE_PTNL_LIFE_EVENTS" AS
/* $Header: ghcrplle.pkb 120.1 2005/09/07 08:25:14 bgarg noship $ */
--
--

PROCEDURE create_ptnl_ler_for_per
(p_pa_request_rec     in ghr_pa_requests%rowtype
)

is


l_exists               boolean   := FALSE;
l_life_event           varchar2(80);
l_prior_duty_station   ghr_duty_stations_f.duty_station_code%type;
l_ptnl_ler_for_per_id  number;
l_ovn                  number;
l_business_group_id    number;
l_ler_id               number;
l_ptnl_le_exists       varchar2(1) := 'N';
l_prior_work_schedule  per_assignment_extra_info.aei_information7%type;
l_asg_ei_data          per_assignment_extra_info%rowtype;
l_session              ghr_history_api.g_session_var_type;
l_proc                 varchar2(75) := 'create_ptnl_ler_for_per';
l_assignment_id        per_all_assignments_f.assignment_id%type;
l_hire                 Boolean;


l_prog_count           number;
l_plan_count           number;
l_oipl_count           number;
l_person_count         number;
l_plan_nip_count       number;
l_oipl_nip_count       number;
l_errbuf               varchar2(2000);
l_retcode              number;
l_benefit_action_id    number;
l_hr_user_type         varchar2(20);
l_last_separation_date DATE;
l_emp_exemp            BOOLEAN;
l_current_enrollment   VARCHAR2(3);
l_current_element      VARCHAR2(10);




Cursor c_get_ds_code is
  select lei.lei_information3,
         dut.duty_station_code
  from   hr_location_extra_info lei,
         per_all_assignments_f asg,
         ghr_duty_stations_v dut
  where  p_pa_request_rec.employee_assignment_id = asg.assignment_id
  and    p_pa_request_rec.effective_date between
         asg.effective_Start_date and asg.effective_end_date
  and    asg.location_id = lei.location_id
  and    lei.information_type = 'GHR_US_LOC_INFORMATION'
  and    lei.lei_information3 =  dut.duty_station_id
  and    p_pa_request_rec.effective_date between
         dut.effective_start_date and asg.effective_end_date;



-- Cursor to get the Business Group Id of the Employee
Cursor c_bgp_id is
  select business_group_id
  from   per_all_people_f
  where  person_id = p_pa_request_rec.person_id
  and    p_pa_request_rec.effective_date
  between effective_start_date and effective_end_date;

-- Cursor to get the ler_id for a given ler_name as identified in the procedure below

Cursor c_ler_id is
  select ler.ler_id
  from   ben_ler_f ler
  where  ler.business_group_id = l_business_group_id
  and    upper(ler.name)       = upper(l_life_event) ;

--  This name comparision  could be replaced by the ler_short_code comparision once available.

cursor c_chk_ptnl_ler is
  select 1 from ben_ptnl_ler_for_per
  where person_id       =  p_pa_request_rec.person_id
  and lf_evt_ocrd_dt    =  p_pa_request_rec.effective_date
  and ler_id            =  l_ler_id
  and PTNL_LER_FOR_PER_STAT_CD = 'UNPROCD'
  and business_group_id = l_business_group_id;



Cursor c_get_current_enrollment is
     SELECT ghr_ss_views_pkg.get_ele_entry_value_ason_date (eef.element_entry_id,
                                                           'Enrollment',
                                                            p_pa_request_rec.effective_date) enrollment,
       decode(upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                    l_business_group_id,
                    p_pa_request_rec.effective_date)),'HEALTH BENEFITS','After','HEALTH BENEFITS PRE TAX','Pre') ben_type

     FROM   pay_element_entries_f eef,
            pay_element_types_f elt
     WHERE  assignment_id = p_pa_request_rec.employee_assignment_id
     AND    elt.element_type_id = eef.element_type_id
     AND    eef.effective_start_date BETWEEN elt.effective_start_date  AND
            elt.effective_end_date
     and    p_pa_request_rec.effective_date  between eef.effective_start_date
                                   and eef.effective_end_date
     AND    upper(pqp_fedhr_uspay_int_utils.return_old_element_name(elt.element_name,
                                                               l_business_group_id,
                                                               p_pa_request_rec.effective_date))
                          IN  ('HEALTH BENEFITS','HEALTH BENEFITS PRE TAX')  ;

Cursor c_chk_emp_exemp is
     select 1
     from   per_all_people_f , per_person_types
     where  person_id = p_pa_request_rec.person_id
     and    trunc (p_pa_request_rec.effective_date - 1) between
            effective_start_date and effective_end_date
     and    per_all_people_f.business_group_id = per_person_types.business_group_id
     and    per_all_people_f.person_type_id = per_person_types.person_type_id
     and    system_person_type = 'EX_EMP';

Cursor c_chk_separated is
     select 1
     from   ghr_pa_requests pa
     where  pa.noa_family_code = 'SEPARATION'
     and    pa.effective_date = p_pa_request_rec.effective_date - 1
     and    pa.person_id = p_pa_request_rec.person_id
     and    exists (select '1'
	             from ghr_pa_history pah
  		     where pah.pa_request_id = pa.pa_request_id);



  Cursor c_prior_pa_details is
   select  pa.duty_station_code, pa.work_schedule, pa.effective_date
   from    ghr_pa_requests pa
   where   pa.noa_family_code = 'SEPARATION'
     and   pa.effective_date < p_pa_request_rec.effective_date
     and   pa.person_id = p_pa_request_rec.person_id
     and   exists (select '1'
	             from ghr_pa_history pah
  		     where pah.pa_request_id = pa.pa_request_id)
   order by pa.effective_date desc ;


begin
     ghr_history_api.get_g_session_var(l_session);
     hr_utility.set_location('Entering    ' || l_proc,10 );

     FOR bgp_id in  c_bgp_id LOOP
             l_business_group_id := bgp_id.business_group_id;
     END LOOP;

       -- Check if person exists as 'Ex Employee'
     l_emp_exemp  := FALSE;
     For i in c_chk_emp_exemp Loop
                 l_emp_exemp  := TRUE;
     END LOOP;
     -- Added an extra check if Emp is rehired next day
     If not l_emp_exemp Then
           for chk_separated in c_chk_separated Loop
               l_emp_exemp  := TRUE;
               exit;
           End Loop;
     End If;
     --
     hr_utility.set_location(l_proc,20 );
     IF l_emp_exemp THEN
          hr_utility.set_location(l_proc,30 );
	  FOR prior_pa_details IN c_prior_pa_details LOOP
	           l_prior_duty_station       :=  prior_pa_details.duty_station_code;
		   l_prior_work_schedule      :=  prior_pa_details.work_schedule;
		   l_last_separation_date     :=  prior_pa_details.effective_date;
		   EXIT;
	  END LOOP;
     ELSE
          hr_utility.set_location(l_proc,40 );
          FOR get_ds_code IN c_get_ds_code LOOP
                   hr_utility.set_location( l_proc,80 );
                   l_prior_duty_station := get_ds_code.duty_Station_code;
          END LOOP;

          Ghr_History_Fetch.Fetch_asgei (
                       p_assignment_id         => p_pa_request_rec.employee_assignment_id,
                       p_information_type      => 'GHR_US_ASG_SF52',
                       p_date_effective        => p_pa_request_rec.effective_date,
                       p_asg_ei_data           => l_asg_ei_data);
          l_prior_work_schedule    :=  l_asg_ei_data.aei_information7;
     END IF;


     hr_utility.set_location(l_proc,40 );
     hr_utility.trace('Family Code  ' ||p_pa_request_rec.noa_family_code);

     IF p_pa_request_rec.noa_family_code = 'APP' THEN
        IF  l_session.noa_id_correct is null THEN

            IF p_pa_request_rec.first_noa_code not in ('115','122','130','132','145', '147', '149', '171', '140', '141', '143') THEN
                l_life_event := 'Initial Opportunity to Enroll' ;
            ELSIF  p_pa_request_rec.first_noa_code IN ('115', '122', '149', '171') THEN
                   if nvl(p_pa_request_rec.tenure,hr_api.g_varchar2) <> '0' Then
		        l_life_event := 'Continued Coverage';
                   end if;
            ELSIF  p_pa_request_rec.first_noa_code IN ('140', '141', '143') THEN
	        IF l_emp_exemp THEN
	           IF l_last_separation_date  < (p_pa_request_rec.effective_date - 3)  THEN
	              l_life_event := 'Initial Opportunity to Enroll' ;
	           ELSE
	              IF l_prior_duty_station = p_pa_request_rec.duty_station_code THEN
	                IF NVL(l_prior_work_schedule,hr_api.g_varchar2) = NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) THEN
		           l_life_event := 'Continued Coverage';
                        ELSE
		           IF (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('P', 'Q', 'S', 'T') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('P', 'Q', 'S', 'T') )
		        OR
                              (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('F', 'G', 'B') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('F', 'G', 'B') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('I', 'J') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('I', 'J') )  THEN

	                      FOR current_enrollment_rec in c_get_current_enrollment LOOP
	                          l_current_element  := current_enrollment_rec.ben_type;
                              END LOOP;
                              If l_current_element = 'After' Then
                                 l_life_event := 'Change in Employment Status Affecting Entitlement to Coverage';
                              Else
                                 l_life_event := 'Change in Employment Status Affecting Cost of Insurance' ;
                              End If;

		     END IF;
		  END IF;

	       ELSIF ((SUBSTR(l_prior_duty_station,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_Station_code,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0'))
                  OR
                   (SUBSTR(l_prior_duty_station,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0')))  THEN

		  l_life_event := 'Transfer from a post of duty within US to post of duty outside US or vice versa';

               ELSIF SUBSTR(p_pa_request_rec.duty_Station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
	             (SUBSTR(l_prior_duty_station,1,2) <> SUBSTR(p_pa_request_rec.duty_station_code,1,2)) THEN

	          l_life_event := 'Employee/Family Member Loses coverage under FEHB or Another Group Plan' ;

               END IF;
              END IF;
           ELSE
	      l_life_event := 'Initial Opportunity to Enroll' ;
	   END IF;

       ELSIF  p_pa_request_rec.first_noa_code IN ('130', '132', '145', '147') THEN
      	   IF l_emp_exemp THEN
	       IF l_prior_duty_station = p_pa_request_rec.duty_station_code THEN

	          IF NVL(l_prior_work_schedule,hr_api.g_varchar2) = NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) THEN
		     l_life_event := 'Continued Coverage';
                  ELSE
		     IF (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('P', 'Q', 'S', 'T') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('P', 'Q', 'S', 'T') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('F', 'G', 'B') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('F', 'G', 'B') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('I', 'J') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('I', 'J') )  THEN

	                      FOR current_enrollment_rec in c_get_current_enrollment LOOP
	                          l_current_element  := current_enrollment_rec.ben_type;
                              END LOOP;
                              If l_current_element = 'After' Then
                                 l_life_event := 'Change in Employment Status Affecting Entitlement to Coverage';
                              Else
                                 l_life_event := 'Change in Employment Status Affecting Cost of Insurance' ;
                              End If;

		     END IF;
		  END IF;

	       ELSIF ((SUBSTR(l_prior_duty_station,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_Station_code,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0'))
                  OR
                   (SUBSTR(l_prior_duty_station,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0')))  THEN

		  l_life_event := 'Transfer from a post of duty within US to post of duty outside US or vice versa';

               ELSIF SUBSTR(p_pa_request_rec.duty_Station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
	             (SUBSTR(l_prior_duty_station,1,2) <> SUBSTR(p_pa_request_rec.duty_station_code,1,2)) THEN

	          l_life_event := 'Employee/Family Member Loses coverage under FEHB or Another Group Plan' ;

               END IF;
           ELSE
	          l_life_event := 'Continued Coverage';
	   END IF;
	END IF;
    END IF;
ELSIF p_pa_request_rec.noa_family_code = 'CONV_APP' THEN
      IF  l_session.noa_id_correct is null THEN
          IF p_pa_request_rec.first_noa_code IN ('540', '541', '543')  THEN
	     IF l_emp_exemp THEN
	       IF l_prior_duty_station = p_pa_request_rec.duty_station_code THEN

	          IF NVL(l_prior_work_schedule,hr_api.g_varchar2) = NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) THEN
		     l_life_event := 'Continued Coverage';
                  ELSE
		     IF (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('P', 'Q', 'S', 'T') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('P', 'Q', 'S', 'T') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('F', 'G', 'B') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('F', 'G', 'B') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('I', 'J') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('I', 'J') )  THEN

	                      FOR current_enrollment_rec in c_get_current_enrollment LOOP
	                          l_current_element  := current_enrollment_rec.ben_type;
                              END LOOP;
                              If l_current_element = 'After' Then
                                 l_life_event := 'Change in Employment Status Affecting Entitlement to Coverage';
                              Else
                                 l_life_event := 'Change in Employment Status Affecting Cost of Insurance' ;
                              End If;

		     END IF;
		  END IF;

	       ELSIF ((SUBSTR(l_prior_duty_station,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_Station_code,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0'))
                  OR
                   (SUBSTR(l_prior_duty_station,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0')))  THEN

		  l_life_event := 'Transfer from a post of duty within US to post of duty outside US or vice versa';

               ELSIF SUBSTR(p_pa_request_rec.duty_Station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
	             (SUBSTR(l_prior_duty_station,1,2) <> SUBSTR(p_pa_request_rec.duty_station_code,1,2)) THEN

	          l_life_event := 'Employee/Family Member Loses coverage under FEHB or Another Group Plan' ;

               END IF;
             End If;
          ElsIF p_pa_request_rec.first_noa_code NOT IN ('515', '522', '549', '571')  THEN

	     FOR current_enrollment_rec in c_get_current_enrollment LOOP
	         l_current_enrollment  := current_enrollment_rec.enrollment;
             END LOOP;

	     IF l_current_enrollment = 'Z' THEN
	           l_life_event := 'Initial Opportunity to Enroll' ;
	     END IF;
	     NULL;
          END IF;
      END IF;

ELSIF p_pa_request_rec.noa_family_code = 'SEPARATION' THEN
      IF l_session.noa_id_correct is null THEN
         l_life_Event := 'Termination of Appointment' ;
      END IF;

ELSIF  (SUBSTR(l_prior_duty_station,1,2) <> SUBSTR(p_pa_request_rec.duty_Station_code,1,2) ) THEN

     IF ((SUBSTR(l_prior_duty_station,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_Station_code,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0'))
         OR
         (SUBSTR(l_prior_duty_station,1,1) NOT IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0'))) THEN



	   l_life_Event := 'Transfer from a post of duty within US to post of duty outside US or vice versa';
     ELSIF SUBSTR(l_prior_duty_station,1,1) IN ('1','2','3','4','5','6','7','8','9','0') AND
                    SUBSTR(p_pa_request_rec.duty_Station_code,1,1) IN ('1','2','3','4','5','6','7','8','9','0') THEN

           l_life_Event := 'Employee/Family Member Loses coverage under FEHB or Another Group Plan' ;

     END IF;

ELSIF NVL(l_prior_work_schedule,hr_api.g_varchar2) <>  NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) THEN

     IF (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('P', 'Q', 'S', 'T') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('P', 'Q', 'S', 'T') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('F', 'G', 'B') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('F', 'G', 'B') )
		        OR
                        (NVL(p_pa_request_rec.work_schedule,hr_api.g_varchar2) IN ('I', 'J') AND
                                    NVL(l_prior_work_schedule,hr_api.g_varchar2) NOT IN ('I', 'J') )  THEN

	                      FOR current_enrollment_rec in c_get_current_enrollment LOOP
	                          l_current_element  := current_enrollment_rec.ben_type;
                              END LOOP;
                              If l_current_element = 'After' Then
                                 l_life_event := 'Change in Employment Status Affecting Entitlement to Coverage';
                              Else
                                 l_life_event := 'Change in Employment Status Affecting Cost of Insurance' ;
                              End If;

     END IF;
END IF;

     hr_utility.set_location(l_proc,90 );
     hr_utility.trace('Life Event   ' ||l_life_event);
     -- Now create the relevant potential life event for the Employee

     IF l_life_event is not null THEN
       hr_utility.set_location( l_proc,140 );

     -- get the Business Group Id
     FOR bgp_id in  c_bgp_id LOOP
        hr_utility.set_location( l_proc,150 );
        l_business_group_id := bgp_id.business_group_id;
     END LOOP;


     --get the ler_id
     for ler_id in c_ler_id loop
        hr_utility.set_location( l_proc,160 );
       l_ler_id := ler_id.ler_id;
     end loop;
     l_ptnl_le_exists := 'N';
     for ptnl_ler_id in c_chk_ptnl_ler loop
       l_ptnl_le_exists := 'Y';
       exit;
     end loop;
     if l_ler_id is not null and l_ptnl_le_exists = 'N' then
        hr_utility.set_location( l_proc,170 );
           ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
              (p_ptnl_ler_for_per_id      => l_ptnl_ler_for_per_id
              ,p_lf_evt_ocrd_dt           => p_pa_request_rec.effective_date
              ,p_ptnl_ler_for_per_stat_cd => 'UNPROCD'
              ,p_ler_id                   => l_ler_id
              ,p_person_id                => p_pa_request_rec.person_id
              ,p_business_group_id        => l_business_group_id
              ,p_unprocd_dt               => p_pa_request_rec.effective_date
              ,p_object_version_number    => l_ovn
              ,p_effective_date           => p_pa_request_rec.effective_date
            );
     ELSE
        hr_utility.set_location( l_proc,180 );
       -- Should this be an error condition. For now leaving it at null
       null;
     END IF;
   END IF;
   hr_utility.set_location('Leaving ' ||  l_proc ,200 );
END create_ptnl_ler_for_per;


  PROCEDURE create_ptnl_tsp_ler_for_per
        (p_pa_request_rec     in ghr_pa_requests%rowtype) as

    l_session                ghr_history_api.g_session_var_type;
    l_proc                   Varchar2(75) := 'create_ptnl_tsp_ler_for_per';
Begin
  hr_utility.set_location('Entering  ' || l_proc,5 );
  hr_utility.set_location('Leaving ' ||  l_proc ,500 );

End create_ptnl_tsp_ler_for_per;

end ghr_create_ptnl_life_events;

/
