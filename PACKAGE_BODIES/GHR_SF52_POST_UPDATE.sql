--------------------------------------------------------
--  DDL for Package Body GHR_SF52_POST_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_POST_UPDATE" AS
/* $Header: gh52poup.pkb 120.3.12010000.3 2009/02/01 11:48:50 vmididho ship $ */

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Post_sf52_process>--------------------------|
-- ----------------------------------------------------------------------------


Procedure Post_sf52_process
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_object_version_number          in out NOCOPY number,
 p_from_position_id               in     number    default null,
 p_to_position_id                 in     number    default null,
 p_agency_code                    in     varchar2  default null,  -- to_agency_code
 p_sf52_data_result               in ghr_pa_requests%rowtype,
 p_called_from                    in varchar2 default null
 )
is

 l_proc                            varchar2(72):= 'Post_sf52_process';
 l_agency_code                     ghr_pa_requests.agency_code%type;
 l_from_agency_code                ghr_pa_requests.from_agency_code%type;
 l_from_agency_desc                ghr_pa_requests.from_agency_desc%type;
 l_from_symbol                     ghr_pa_requests.from_office_symbol%type;
 l_personnel_office_id             ghr_pa_requests.personnel_office_id%type;
 l_employee_dept_or_agency         ghr_pa_requests.employee_dept_or_agency%type;
 l_to_office_symbol                ghr_pa_requests.to_office_symbol%type;
 l_pa_notification_id              ghr_pa_requests.pa_notification_id%type;
 l_object_version_number           ghr_pa_requests.object_version_number%type;

 Cursor C_Sel1 is
   select ghr_pa_notifications_s.nextval from sys.dual;

-- Get all data pertaining to Notifications

begin
 hr_utility.set_location('Entering  ' || l_proc ,5);
 l_object_version_number := p_object_version_number;

 hr_utility.set_location(l_proc ,10);

-- Just get the notification_id  and update ghr_pa_requests
--
    open C_Sel1;
    Fetch C_Sel1 Into l_pa_notification_id;
    Close C_Sel1;

 hr_utility.set_location('to_position_id is '||p_sf52_data_result.to_position_id ,10);
IF nvl(p_called_from,hr_api.g_varchar2)  = 'CORRECTION_SF52' THEN
 ghr_par_upd.upd
 (p_pa_request_id          	     =>  p_pa_request_id
 ,p_object_version_number  	     =>  l_object_version_number
 ,p_pa_notification_id             =>  l_pa_notification_id
 ,p_to_position_id       => p_sf52_data_result.to_position_id
 ,p_to_position_title    => p_sf52_data_result.to_position_title
 ,p_to_position_number   => p_sf52_data_result.to_position_number
 ,p_to_position_seq_no   => p_sf52_data_result.to_position_seq_no
 ,p_to_pay_plan          => p_sf52_data_result.to_pay_plan
 ,p_to_occ_code          => p_sf52_data_result.to_occ_code
 ,p_to_step_or_rate      => p_sf52_data_result.to_step_or_rate
 ,p_to_grade_or_level    => p_sf52_data_result.to_grade_or_level
 ,p_to_total_salary      => p_sf52_data_result.to_total_salary
 ,p_to_pay_basis         => p_sf52_data_result.to_pay_basis
 ,p_to_basic_pay         => p_sf52_data_result.to_basic_pay
 ,p_to_locality_adj      => p_sf52_data_result.to_locality_adj
 ,p_to_adj_basic_pay     => p_sf52_data_result.to_adj_basic_pay
 ,p_to_other_pay_amount  => p_sf52_data_result.to_other_pay_amount
 ,p_TO_POSITION_ORG_LINE1  => p_sf52_data_result.TO_POSITION_ORG_LINE1
 ,p_TO_POSITION_ORG_LINE2  => p_sf52_data_result.TO_POSITION_ORG_LINE2
 ,p_TO_POSITION_ORG_LINE3  => p_sf52_data_result.TO_POSITION_ORG_LINE3
 ,p_TO_POSITION_ORG_LINE4  => p_sf52_data_result.TO_POSITION_ORG_LINE4
 ,p_TO_POSITION_ORG_LINE5  => p_sf52_data_result.TO_POSITION_ORG_LINE5
 ,p_TO_POSITION_ORG_LINE6  => p_sf52_data_result.TO_POSITION_ORG_LINE6
 ,p_VETERANS_PREFERENCE  => p_sf52_data_result.VETERANS_PREFERENCE
 ,p_TENURE  => p_sf52_data_result.TENURE
 ,p_VETERANS_PREF_FOR_RIF  => p_sf52_data_result.VETERANS_PREF_FOR_RIF
 ,p_ANNUITANT_INDICATOR  => p_sf52_data_result.ANNUITANT_INDICATOR
 ,p_ANNUITANT_INDICATOR_DESC  => p_sf52_data_result.ANNUITANT_INDICATOR_DESC
 ,p_RETIREMENT_PLAN  => p_sf52_data_result.RETIREMENT_PLAN
 ,p_SERVICE_COMP_DATE  => p_sf52_data_result.SERVICE_COMP_DATE
 ,p_POSITION_OCCUPIED  => p_sf52_data_result.POSITION_OCCUPIED
 ,p_FLSA_CATEGORY  => p_sf52_data_result.FLSA_CATEGORY
 ,p_APPROPRIATION_CODE1  => p_sf52_data_result.APPROPRIATION_CODE1
 ,p_APPROPRIATION_CODE2  => p_sf52_data_result.APPROPRIATION_CODE2
 ,p_BARGAINING_UNIT_STATUS  => p_sf52_data_result.BARGAINING_UNIT_STATUS
 ,p_CITIZENSHIP  => p_sf52_data_result.CITIZENSHIP
 ,p_DUTY_STATION_CODE  => p_sf52_data_result.DUTY_STATION_CODE
 ,p_duty_station_desc  => p_sf52_data_result.duty_station_desc
 ,p_duty_station_id    => p_sf52_data_result.duty_station_id
 ,p_duty_station_location_id  => p_sf52_data_result.duty_station_location_id
 ,p_EDUCATION_LEVEL  => p_sf52_data_result.EDUCATION_LEVEL
 ,p_FEGLI  => p_sf52_data_result.FEGLI
 ,p_FUNCTIONAL_CLASS  => p_sf52_data_result.FUNCTIONAL_CLASS
 ,p_work_schedule  => p_sf52_data_result.work_schedule
 ,p_work_schedule_desc  => p_sf52_data_result.work_schedule_desc
 ,p_PART_TIME_HOURS  => p_sf52_data_result.PART_TIME_HOURS
 ,p_PAY_RATE_DETERMINANT  => p_sf52_data_result.PAY_RATE_DETERMINANT
 --,p_SERVICE_COMP_DATE  => p_sf52_data_result.SERVICE_COMP_DATE

-- ,p_RETIREMENT_PLAN  => p_sf52_data_result.RETIREMENT_PLAN
 ,p_to_organization_id  => p_sf52_data_result.to_organization_id
 ,p_year_degree_attained => p_sf52_data_result.year_degree_attained
 ,p_academic_discipline  => p_sf52_data_result.academic_discipline
 ,p_veterans_status      => p_sf52_data_result.veterans_status
 ,p_supervisory_status   => p_sf52_data_result.supervisory_status
--start of  BUG # 6154523
 ,p_award_amount         => p_sf52_data_result.award_amount
 ,p_award_percentage     => p_sf52_data_result.award_percentage
--end of  BUG # 6154523
--start of BUG # 6983534
 ,p_to_grade_id          => p_sf52_data_result.to_grade_id
 --end of  BUG # 6983534
  );
ELSE
 ghr_par_upd.upd
 (p_pa_request_id          	     =>  p_pa_request_id,
  p_object_version_number  	     =>  l_object_version_number,
  p_pa_notification_id             =>  l_pa_notification_id
  );
END IF;
-- Get the Authentication Date for NFC processing

ghr_utility.process_nfc_auth_date(
p_effective_date => p_effective_date,
p_pa_request_id => p_pa_request_id);
   hr_utility.set_location(l_proc ,20);

--
--
-- Update status of ghr_pa_requests (in pa_routing_history - Action Taken is set to 'UPDATE_HR_COMPLETE'
--
hr_utility.set_location(l_proc,40);

ghr_sf52_api.end_sf52
(p_pa_request_id			=>   p_pa_request_id
,p_action_taken			=>   'UPDATE_HR_COMPLETE'
,p_par_object_version_number	=>   l_object_version_number
);
--
hr_utility.set_location('Leaving '||l_proc,45);

EXCEPTION
WHEN others THEN
  -- Reset IN OUT parameters and set OUT parameters
   p_object_version_number := l_object_version_number;
   raise;

end post_sf52_process;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< Post_sf52_cancel>--------------------------|
-- ----------------------------------------------------------------------------

Procedure post_sf52_cancel
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_object_version_number          in out NOCOPY number,
 p_from_position_id               in     number    default null,
 p_to_position_id                 in     number    default null,
 p_agency_code                    in     varchar2  default null  -- to_agency_code
 )
is

 l_proc                            varchar2(72):= 'Post_sf52_cancel';
 l_agency_code                     ghr_pa_requests.agency_code%type;
 l_from_agency_code                ghr_pa_requests.from_agency_code%type;
 l_from_agency_desc                ghr_pa_requests.from_agency_desc%type;
 l_from_symbol                     ghr_pa_requests.from_office_symbol%type;
 l_personnel_office_id             ghr_pa_requests.personnel_office_id%type;
 l_employee_dept_or_agency         ghr_pa_requests.employee_dept_or_agency%type;
 l_to_office_symbol                ghr_pa_requests.to_office_symbol%type;
 l_pa_notification_id              ghr_pa_requests.pa_notification_id%type;
 l_object_version_number           ghr_pa_requests.object_version_number%type;
 l_assignment_id                   ghr_pa_requests.employee_assignment_id%type;
 l_person_id                       ghr_pa_requests.person_id%type;
 l_exists                          boolean;

  Cursor C_Sel1 is
   select ghr_pa_notifications_s.nextval from sys.dual;

 Cursor C_person is
    select par.person_id,
           par.employee_assignment_id
    from   ghr_pa_requests par
    where  par.pa_request_id = p_pa_request_id;


Cursor C_asg_posn is
   select  asg1.assignment_id
   from    per_all_assignments_f asg1,
           per_all_assignments_f asg
   where   asg.person_id   = l_person_id
   and     asg1.person_id <> l_person_id
   and     p_effective_date
   between asg.effective_start_date  and asg.effective_end_date
   and     asg.assignment_type NOT IN ('A','B')
   and     asg1.assignment_type NOT IN ('A','B')
   and     asg1.position_id   = asg.position_id
   and     asg1.effective_start_date
   between asg.effective_start_date and asg.effective_end_date;

-- Get all data pertaining to Notifications

begin
 hr_utility.set_location('Entering  ' || l_proc ,5);
 l_object_version_number := p_object_version_number;

 hr_utility.set_location(l_proc ,10);
  --Check if the position is not already occupied
  for per_asg_rec in c_person loop
    l_person_id     := per_asg_rec.person_id;
    l_assignment_id := per_asg_rec.employee_assignment_id;
  end loop;
  If l_assignment_id is not null then
   l_exists := false;
   for asg_posn_rec in c_asg_posn loop
     l_exists := true;
     exit;
   end loop;
   If l_exists  then
     hr_utility.set_message(8301,'GHR_38620_POS_ASSIGNED');
     hr_utility.raise_error;
   End if;
  End if;


-- Update ghr_pa_requests with Notification Details

    open C_Sel1;
    Fetch C_Sel1 Into l_pa_notification_id;
    Close C_Sel1;
 ghr_par_upd.upd
 (p_pa_request_id          	     =>  p_pa_request_id,
  p_object_version_number  	     =>  l_object_version_number,
  p_pa_notification_id             =>  l_pa_notification_id
  );
   hr_utility.set_location(l_proc ,20);


--
-- Update status of ghr_pa_requests (in pa_routing_history - Action Taken is set to 'CANCELED'
--
hr_utility.set_location(l_proc,40);

ghr_sf52_api.end_sf52
(p_pa_request_id			=>   p_pa_request_id
,p_action_taken			=>   'UPDATE_HR_COMPLETE'
,p_par_object_version_number	=>   l_object_version_number
);
--
hr_utility.set_location('Leaving '||l_proc,45);

EXCEPTION
WHEN others THEN
  -- Reset IN OUT parameters and set OUT parameters
   p_object_version_number := l_object_version_number;
   raise;


end post_sf52_cancel;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< post_sf52_future >--------------------------|
-- ----------------------------------------------------------------------------
-- With the new enhancement to support elec. authentication, the approval date and
-- the approver's work title will already be available in the ghr_pa_requests table
-- and hence nothing needs to be done in this procedure.
--But leaving it as it is, so that , if later we identify any special routines to be
-- performed as a part of FUTURE actions, can be included here.

Procedure Post_sf52_future
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_object_version_number          in out NOCOPY number
)
is

 l_proc                            varchar2(72):= 'Post_sf52_future';

begin

  null;

 End post_sf52_future;


--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_Notification_Details>--------------------------|
-- ----------------------------------------------------------------------------

Procedure get_notification_details
(
 p_pa_request_id                  in     number,
 p_effective_date                 in     date,
 p_from_position_id               in     number    default null,
 p_to_position_id                 in     number    default null,
 p_agency_code                    in out NOCOPY varchar2, -- to_agency_code
 p_from_agency_code               out NOCOPY varchar2,
 p_from_agency_desc               out NOCOPY varchar2,
 p_from_office_symbol             out NOCOPY varchar2,
 p_personnel_office_id            out NOCOPY number,
 p_employee_dept_or_agency        out NOCOPY varchar2,
 p_to_office_symbol               out NOCOPY varchar2
 )
is

 l_proc                   varchar2(72):= 'get_other_data';
 l_bus_gp                 per_people_f.business_group_id%type;
 l_from_agency_code       ghr_pa_requests.from_agency_code%type;
 l_agency_code            ghr_pa_requests.agency_code%type;
 l_appr_person_id         per_people_f.person_id%type;
 l_personnel_office_id    ghr_pa_requests.personnel_office_id%type;
 l_altered_pa_request_id  ghr_pa_requests.pa_request_id%type;
 l_noa_code			  ghr_pa_requests.first_noa_code%type;
 l_pos_ei_data            per_position_extra_info%rowtype;
 -- Bug#4005843
 l_effective_date         date;


cursor     c_bus_gp(p_position_id number) is
  select pos.business_group_id
  from   hr_all_positions_f pos  -- Venkat
  where  pos.position_id = p_position_id
  and   p_effective_date between pos.effective_start_date and
                  pos.effective_end_date;

 cursor c_orig_par is
   select  par.noa_family_code,
           par.altered_pa_request_id,
	   par.second_noa_code                        --  Bug 3451929
   from    ghr_pa_requests par
   where   par.pa_request_id = p_pa_request_id;

cursor c_par is
   select  	par.noa_family_code,
		par.first_noa_code,
		par.second_noa_code
   from 	ghr_pa_requests par
   where	par.pa_request_id = p_pa_request_id;

cursor c_par_ei(p_information_type varchar2)  is
   select	parei.rei_information4,
                parei.rei_information5,                 -- Bug 3547836
		parei.rei_information6,                 -- Bug 3547836
		parei.rei_information10
   from	ghr_pa_request_extra_info parei
   where	parei.pa_request_id = p_pa_request_id
	and	parei.information_type = p_information_type;

 cursor  c_agency_det is
   select par.from_agency_code,
          par.from_agency_desc,
          par.agency_code,
          par.employee_dept_or_agency,
          par.from_office_symbol,
          par.to_office_symbol,
          par.personnel_office_id
   from   ghr_pa_requests par
   where  par.pa_request_id = l_altered_pa_request_id;

BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);
    --
    --
    l_agency_code := p_agency_code;  --NOCOPY Changes
    hr_utility.set_location(l_proc, 10);
    -- get the noa code to determine if it is an '800' or '790'.
    -- If it is, then we need to handle the agency_code as a special case
    -- and get it from extra information for the pa_request.
    FOR pa_req in c_par LOOP
        if (pa_req.noa_family_code = 'CORRECT') then
            l_noa_code := pa_req.second_noa_code;
        else
            l_noa_code := pa_req.first_noa_code;
        end if;
    end loop;
    hr_utility.set_location('PA Req ID : '||p_pa_request_id,10);
    hr_utility.set_location('l_noa_code is '||l_noa_code,20);
    -- Agency Desc
    if nvl(p_to_position_id,hr_api.g_number) <> hr_api.g_number then
        for bus_gp in c_bus_gp(p_to_position_id) loop
            l_bus_gp := bus_gp.business_group_id;
        end loop;
        hr_utility.set_location(l_proc, 15);

        if (l_noa_code = '800') then
            for p_parei in c_par_ei('GHR_US_PAR_CHG_DATA_ELEMENT') LOOP
                l_agency_code := p_parei.rei_information4;
            end LOOP;
        elsif (l_noa_code = '790') then
            for p_parei in c_par_ei('GHR_US_PAR_REALIGNMENT') LOOP
                l_agency_code := p_parei.rei_information10;
            end LOOP;
            -- Bug 3451929
            IF l_agency_code is NULL then
                l_agency_code  :=  ghr_api.get_position_agency_code_pos
                                    (p_position_id        => p_to_position_id,
                                     p_business_group_id  => l_bus_gp,
                                     p_effective_date     => p_effective_date
                                    );
            END IF;
            -- End of bug 3451929
        else
            l_agency_code  :=  ghr_api.get_position_agency_code_pos
                              (p_position_id        => p_to_position_id,
                               p_business_group_id  => l_bus_gp,
                               p_effective_date     => p_effective_date
                               );
        end if;
        p_agency_code := l_agency_code;
        hr_utility.set_location('agency code ' || l_agency_code,1);
        hr_utility.set_location(l_proc,20);

     -- Employee_dept_or_agency
     if p_agency_code is not null then
       p_employee_dept_or_agency := hr_general.decode_lookup
                                    (p_lookup_type       => 'GHR_US_AGENCY_CODE',
                                     p_lookup_code       => p_agency_code
                                    );
        hr_utility.set_location(l_proc, 30);
     end if;


     -- Personal_office_id and office_symbol

     l_personnel_office_id  := Null;
        ghr_history_fetch.fetch_positionei
        (p_position_id    =>   p_to_position_id,
         p_information_type => 'GHR_US_POS_GRP1',
         p_date_effective   =>  nvl(p_effective_date,trunc(sysdate)),
         p_pos_ei_data       =>  l_pos_ei_data
        );
        l_personnel_office_id  :=  l_pos_ei_data.poei_information3;
        p_to_office_symbol     :=  l_pos_ei_data.poei_information4;
     l_pos_ei_data := Null;

   End if;

   -- personnel_office_id and from_office_symbol
   if nvl(p_from_position_id,hr_api.g_number) <> hr_api.g_number then
       -- Bug#4005843 Added the IF condition.
        IF l_noa_code = '790' THEN
	   hr_utility.set_location('NOA Code is 790',20);
	     -- Bug#4344353 added the following code to get rid of ora-1841
	     IF p_effective_date = hr_api.g_date THEN
	        l_effective_date := trunc(sysdate) - 1;
	     ELSE
	        l_effective_date := p_effective_date - 1;
	     END IF;
	ELSE
	    l_effective_date := nvl(p_effective_date,trunc(sysdate));
	END IF;
        ghr_history_fetch.fetch_positionei
        (p_position_id      =>  p_from_position_id,
         p_information_type =>  'GHR_US_POS_GRP1',
         p_date_effective   =>  l_effective_date,
         p_pos_ei_data      =>  l_pos_ei_data
        );
	-- Bug#4005843
        IF l_personnel_office_id IS NULL THEN
          l_personnel_office_id  :=  l_pos_ei_data.poei_information3;
        END IF;
        p_from_office_symbol     :=  l_pos_ei_data.poei_information4;

     for bus_gp in c_bus_gp(p_from_position_id) loop
       l_bus_gp := bus_gp.business_group_id;
     end loop;
     l_from_agency_code  :=  ghr_api.get_position_agency_code_pos
                        (p_position_id        => p_from_position_id,
                         p_business_group_id  => l_bus_gp,
                         p_effective_date     => p_effective_date
                        );

     p_from_agency_code := l_from_agency_code;
          hr_utility.set_location(l_proc,50);

     if l_from_agency_code is not null then
       p_from_agency_desc := hr_general.decode_lookup
                             (p_lookup_type       => 'GHR_US_AGENCY_CODE',
                              p_lookup_code       => l_from_agency_code
                             );
            hr_utility.set_location(l_proc, 55);
     end if;
   end if;
      p_personnel_office_id      :=  l_personnel_office_id;

   -- If agency_code or the from_agency_code is null, which is likely to happen
   -- only on corrections , try to get the agency code
   -- from the original RPA.
   If p_to_position_id is null  or p_from_position_id is null then
     hr_utility.set_location('one of the positions is null',1);
     for orig_par in  c_orig_par loop
       If orig_par.noa_family_code = 'CORRECT' then
         l_altered_pa_request_id   :=  orig_par.altered_pa_request_id;
         for agency_det_rec in c_agency_det loop
           If p_to_position_id is null then
	     -- Bug 3451929  If second noa code is 790 then agency should be taken from extra information
	      IF orig_par.second_noa_code = '790' THEN
	        FOR p_parei in c_par_ei('GHR_US_PAR_REALIGNMENT') LOOP
			p_agency_code := p_parei.rei_information10;
			p_personnel_office_id   :=  p_parei.rei_information5;           -- Bug 3547836
			p_to_office_symbol      :=  p_parei.rei_information6;           -- Bug 3547836
		END LOOP;
	-- Start of Bug 3547836
		IF p_agency_code IS NOT NULL THEN
		   p_employee_dept_or_agency := hr_general.decode_lookup
                                    (p_lookup_type       => 'GHR_US_AGENCY_CODE',
                                     p_lookup_code       => p_agency_code
                                   );
                ELSE
                   p_agency_code              :=  agency_det_rec.agency_code;
         	   p_employee_dept_or_agency  :=  agency_det_rec.employee_dept_or_agency;
                END IF;

	        IF  p_personnel_office_id IS NULL then
                    p_personnel_office_id     :=  agency_det_rec.personnel_office_id;
                END IF;

                IF  p_to_office_symbol IS NULL then
		    p_to_office_symbol        :=  agency_det_rec.to_office_symbol;
                END IF;
        -- End of Bug 3547836

	    ELSE
	        p_agency_code              :=  agency_det_rec.agency_code;
                p_employee_dept_or_agency  :=  agency_det_rec.employee_dept_or_agency;
                p_to_office_symbol         :=  agency_det_rec.to_office_symbol;
		--Bug#6356071 Personnel Office id assigned with the altered Pa requests
		    -- personnel office id only if it is NULL
                IF  p_personnel_office_id IS NULL then
                    p_personnel_office_id  :=  agency_det_rec.personnel_office_id;
                END IF;
		--Bug#6356071
            End if;
           End if;
           If p_from_position_id is null then
             p_from_agency_code      :=  agency_det_rec.from_agency_code;
             p_from_agency_desc      :=  agency_det_rec.from_agency_desc;
             p_from_office_symbol    :=  agency_det_rec.from_office_symbol;
           End if;
         End Loop;
       End if;
     End loop;
   End if;

EXCEPTION
WHEN others THEN

    -- Reset IN OUT parameters and set OUT parameters
 p_from_agency_code            :=NULL;
 p_from_agency_desc            :=NULL;
 p_from_office_symbol          :=NULL;
 p_personnel_office_id         :=NULL;
 p_employee_dept_or_agency     :=NULL;
 p_to_office_symbol            :=NULL;
 p_agency_code                 :=l_agency_code;
 raise;

  end get_notification_details;
end ghr_sf52_post_update;


/
