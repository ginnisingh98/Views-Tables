--------------------------------------------------------
--  DDL for Package Body GHR_MASS_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MASS_ACTIONS_PKG" AS
/* $Header: ghmasact.pkb 120.1.12000000.1 2007/03/27 10:07:50 managarw noship $ */

g_package  varchar2(32) := '  GHR_MASS_ACTIONS_PKG.' ;


procedure get_noa_id_desc
(
 p_noa_code	       in	ghr_nature_of_actions.code%type,
 p_effective_date	 in   date default trunc(sysdate),
 p_noa_id	       out  nocopy ghr_nature_of_actions.nature_of_action_id%type,
 p_noa_desc	       out  nocopy ghr_nature_of_actions.description%type
 )
 is

--
-- local variables
--

  l_proc   varchar2(72) :=   g_package || 'get_noa_id_desc';

  cursor c_noa is
	select  noa.nature_of_action_id, noa.description
	from    ghr_nature_of_actions noa
	where   noa.code = p_noa_code
	and     noa.enabled_flag = 'Y'
	and     nvl(p_effective_date,trunc(sysdate))
	between noa.date_from
	and     nvl(noa.date_to,nvl(p_effective_date,trunc(sysdate))) ;
--
begin
--
  hr_utility.set_location('Entering ' || l_proc,5);
  p_noa_id   :=  Null;
  p_noa_desc :=  Null;

  for noa_id_desc in c_noa loop
    hr_utility.set_location( l_proc,10);
    p_noa_id           := noa_id_desc.nature_of_action_id;
    p_noa_desc         := noa_id_desc.description;
  end loop;
  hr_utility.set_location('Leaving  ' || l_proc,15);
-- Nocopy Changes
Exception
   When others then
     p_noa_id := null;
     p_noa_desc :=  Null;
     RAISE;
end get_noa_id_desc ;


procedure get_remark_id_desc
(
 p_remark_code	       in	ghr_nature_of_actions.code%type,
 p_effective_date	 	 in   date default trunc(sysdate),
 p_remark_id	       out nocopy ghr_nature_of_actions.nature_of_action_id%type,
 p_remark_desc	       out nocopy ghr_nature_of_actions.description%type
 )
 is

--
-- local variables

 l_proc   varchar2(72) :=   g_package || 'get_remark_id_desc';

 Cursor  c_rem_desc is
   select   rem.remark_id,
            rem.description
   from     ghr_remarks  rem
   where    rem.code  =  p_remark_code
   and      rem.enabled_flag = 'Y'
   and      nvl(p_effective_date,sysdate)
   between  rem.date_from and nvl(rem.date_to,nvl(p_effective_date, trunc(sysdate)));

begin
--
  hr_utility.set_location('Entering ' || l_proc,5);
  p_remark_id :=  Null;
  p_remark_desc :=  Null;

  for rem_id_desc in c_rem_desc loop
    hr_utility.set_location( l_proc,10);
    p_remark_id           := rem_id_desc.remark_id;
    p_remark_desc         := rem_id_desc.description;
  end loop;
  hr_utility.set_location('Leaving  ' || l_proc,15);
-- Nocopy Changes
Exception
   When others then
  p_remark_id :=  Null;
  p_remark_desc :=  Null;
  RAISE;
end get_remark_id_desc ;


procedure emp_rec_to_sf52_rec
(p_emp_rec         in      ghr_mass_actions_pkg.emp_rec_type,
 p_sf52_rec        in out nocopy  ghr_pa_requests%rowtype
)
is
  l_proc           varchar2(72) := g_package || 'emp_rec_to_sf52_rec';
  l_sf52_rec       ghr_pa_requests%rowtype;

begin
  -- Nocopy Changes
  l_sf52_rec            := p_sf52_rec;
  --
  p_sf52_rec.person_id                    :=  p_emp_rec.person_id;
  p_sf52_rec.employee_first_name  		:=  p_emp_rec.first_name;
  p_sf52_rec.employee_last_name 		:=  p_emp_rec.last_name;
  p_sf52_rec.employee_middle_names		:=  p_emp_rec.middle_names;
  p_sf52_rec.employee_national_identifier	:=  p_emp_rec.national_identifier;
  p_Sf52_rec.employee_date_of_birth		:=  p_emp_rec.date_of_birth;
  p_sf52_rec.employee_assignment_id       :=  p_emp_rec.assignment_id;

  hr_utility.set_location('Leaving ' || l_proc,10);
-- Nocopy Changes
Exception
   When others then
       p_sf52_rec := l_sf52_rec;
       RAISE;
end emp_rec_to_sf52_rec;


procedure asg_sf52_rec_to_sf52_rec
(p_asg_sf52_rec    in      ghr_api.asg_sf52_type,
 p_sf52_rec        in out nocopy  ghr_pa_requests%rowtype
)
is

l_proc           varchar2(72) := g_package || 'asg_sf52_rec_to_sf52_rec';
l_sf52_rec       ghr_pa_requests%rowtype;
begin
  -- Nocopy Changes
  l_sf52_rec            := p_sf52_rec;
  --
  hr_utility.set_location('Entering ' || l_proc,5);

  p_sf52_rec.tenure      		:=   p_asg_sf52_rec.tenure;
  p_sf52_rec.to_step_or_rate 		:=   p_asg_sf52_rec.step_or_rate;
  p_sf52_rec.annuitant_indicator	:=   p_asg_sf52_rec.annuitant_indicator;
  p_sf52_rec.pay_rate_determinant   :=   p_asg_sf52_rec.pay_rate_determinant;
  p_sf52_rec.work_schedule          :=   p_asg_sf52_rec.work_schedule;
  p_sf52_rec.part_time_hours        :=   p_asg_sf52_rec.part_time_hours;



  hr_utility.set_location('Leaving ' || l_proc,10);
-- Nocopy Changes
Exception
   When others then
       p_sf52_rec := l_sf52_rec;
       RAISE;
end asg_sf52_rec_to_sf52_rec;


procedure pos_grp1_rec_to_sf52_rec
(p_pos_grp1_rec    in      ghr_api.pos_grp1_type,
 p_sf52_rec        in out nocopy  ghr_pa_requests%rowtype
)
is

l_proc           varchar2(72) := g_package || 'pos_grp1_rec_to_sf52_rec';
l_sf52_rec       ghr_pa_requests%rowtype;

begin
  -- Nocopy Changes
  l_sf52_rec            := p_sf52_rec;
  --
  hr_utility.set_location('Entering ' || l_proc,5);

  p_sf52_rec.flsa_category           :=  p_pos_grp1_rec.flsa_category;
  p_sf52_rec.bargaining_unit_status  :=  p_pos_grp1_rec.bargaining_unit_status;
  p_sf52_rec.functional_class        :=  p_pos_grp1_rec.functional_class;
  p_sf52_rec.supervisory_status      :=  p_pos_grp1_rec.supervisory_status;

  hr_utility.set_location('Leaving ' || l_proc,10);
-- Nocopy Changes
Exception
   When others then
       p_sf52_rec := l_sf52_rec;
       RAISE;
end pos_grp1_rec_to_sf52_rec;

procedure pay_calc_rec_to_sf52_rec
(p_pay_calc_rec  in      ghr_pay_calc.pay_calc_out_rec_type,
 p_sf52_rec      in out nocopy  ghr_pa_requests%rowtype
)
is

  l_proc           varchar2(72) := g_package || 'pos_grp1_rec_to_sf52_rec';
  l_sf52_rec       ghr_pa_requests%rowtype;

begin
  -- Nocopy Changes
  l_sf52_rec            := p_sf52_rec;
  --
  hr_utility.set_location('Entering ' || l_proc,5);
  p_sf52_rec.to_basic_pay            :=  p_pay_calc_rec.basic_pay;
  p_sf52_rec.to_locality_adj         :=  p_pay_calc_rec.locality_adj;
  p_sf52_rec.to_adj_basic_pay        :=  p_pay_calc_rec.adj_basic_pay;
  p_sf52_rec.to_total_salary         :=  p_pay_calc_rec.total_salary;
  p_sf52_rec.to_other_pay_amount     :=  p_pay_calc_rec.other_pay_amount;
  p_sf52_rec.to_au_overtime          :=  p_pay_calc_rec.au_overtime;
  p_sf52_rec.to_availability_pay     :=  p_pay_calc_rec.availability_pay;

--  l_sf52_rec.to_step_or_rate             /-- Can we store the new step / rate in this case since it is automated, or should we leave it to update_hr process
--  l_sf52_rec.pay_rate_determinant  := --/

  -- Should error out if pt_eff_start_date is not the same as the eff_date of the new pay table
  -- This should have been taken care even before this stage, I guess

-- If open_pay_fields then custom_pay_calc_flag should be set to 'Y' . Should we also consider the assignment of the
--  above pay elements based on the the boolean out parameter. ????

  hr_utility.set_location('Leaving ' || l_proc,10);

-- Nocopy Changes
Exception
   When others then
       p_sf52_rec := l_sf52_rec;
       RAISE;
end pay_calc_rec_to_sf52_rec;

procedure duty_station_rec_to_sf52_rec
(p_duty_station_rec         in      ghr_mass_actions_pkg.duty_station_rec_type,
 p_sf52_rec                 in out nocopy  ghr_pa_requests%rowtype
)
is
  l_proc           varchar2(72) := g_package || 'duty_station_rec_to_sf52_rec';
  l_sf52_rec       ghr_pa_requests%rowtype;

begin
  -- Nocopy Changes
  l_sf52_rec            := p_sf52_rec;
  --
  p_sf52_rec.duty_station_id              :=  p_duty_station_rec.duty_station_id;
  p_sf52_rec.duty_station_code  		:=  p_duty_station_rec.duty_station_code;
  p_sf52_rec.duty_station_desc 		:=  p_duty_station_rec.duty_station_desc;

  hr_utility.set_location('Leaving ' || l_proc,10);
-- Nocopy Changes
Exception
   When others then
       p_sf52_rec := l_sf52_rec;
       RAISE;
end duty_station_rec_to_sf52_rec;


 procedure replace_insertion_values
(p_desc                in varchar2,
 p_information1        in varchar2 default null,
 p_information2        in varchar2 default null,
 p_information3        in varchar2 default null,
 p_information4        in varchar2 default null,
 p_information5        in varchar2 default null,
 p_desc_out            out nocopy varchar2
)
is

 -- assuming that this procedure would ever be called if there is an insertion value for the desc.

l_ins_count   number   := 0;
l_desc        varchar2(2000);
l_length     number;
l_i           number;
l_count_of_dashes number := 0;
l_val_to_be_repl varchar2(30);
begin

  l_length := length(p_desc);
  l_i := 1;
  l_ins_count := 0;

  while l_i <= l_length loop
   if  nvl(substr(p_desc,l_i,1),hr_api.g_varchar2) <> '_' then
     l_desc := l_desc || nvl(substr(p_desc,l_i,1),' ');
     l_i := l_i + 1;
    else
      l_ins_count := l_ins_count + 1;
      l_count_of_dashes := 0;
      l_val_to_be_repl  := null;
      --l_i := l_i + 1;
      --l_count_of_dashes := l_count_of_dashes + 1;

      while nvl(substr(p_desc,l_i,1),hr_api.g_varchar2) = '_'  loop
      --  dbms_output.put_line('l_i is ' || to_char(l_i));
        l_desc := l_desc || nvl(substr(p_desc,l_i,1),' ');
        l_count_of_dashes := l_count_of_dashes + 1;
         --if nvl(substr(p_desc,l_i,1),hr_api.g_varchar2)  <>  '_'  then
         --   exit;
         --end if;
         l_i := l_i + 1;
      end loop;

      for i in 1..l_count_of_dashes loop
       -- dbms_output.put_line(to_char(l_ins_count) || l_val_to_be_repl);
        l_val_to_be_repl :=  l_val_to_be_repl || '_';
      end loop;

    --  dbms_output.put_line(to_char(l_ins_count) || '  ' ||  to_char(l_count_of_dashes) || l_val_to_be_repl);
      if l_ins_count = 1 then
         l_desc := replace(l_desc,l_val_to_be_repl,p_information1);
      elsif l_ins_count = 2 then
         l_desc := replace(l_desc,l_val_to_be_repl,p_information2);
      elsif l_ins_count = 3 then
         l_desc := replace(l_desc,l_val_to_be_repl,p_information3);
      end if;
    end if;
  end loop;
  p_desc_out := l_Desc;
-- NOCOPY CHANGES
EXCEPTION
   when others then
     p_desc_out := NULL;
     RAISE;
end replace_insertion_values;


Procedure get_personnel_off_groupbox
(p_position_id          in      ghr_pa_requests.from_position_id%type,
 p_effective_date      in       date default trunc(sysdate),
 p_groupbox_id         out nocopy      ghr_groupboxes.groupbox_id%type,
 p_routing_group_id    out nocopy      ghr_routing_groups.routing_group_id%type
)
is

  l_proc            	varchar2(72) :=  g_package  || 'get_personnel_off_groupbox';
  l_pos_ei_data     	per_position_extra_info%rowtype;
  l_groupbox_id     	ghr_groupboxes.groupbox_id%type;
  l_routing_group_id 	ghr_routing_groups.routing_group_id%type;
  l_personnel_office_id ghr_pa_requests.personnel_office_id%type;
  l_log_text            varchar2(2000);
  l_count               number;

  Cursor c_gbx is
    select  gbx.groupbox_id gpid, gbx.routing_group_id rgpid
    from    ghr_pois gpoi,
            ghr_groupboxes gbx,
            ghr_routing_groups rgp
    where   gbx.groupbox_id = gpoi.groupbox_id
    and     gpoi.personnel_office_id = l_personnel_office_id
    and     gbx.routing_group_id = rgp.routing_group_id;

  Cursor c_gpbox_users is
    select count(*) cnt
    from   ghr_groupbox_users gbu
    where  gbu.groupbox_id  =  l_groupbox_id;


begin
  savepoint get_personnel_off_groupbox;
  hr_utility.set_location('Entering   ' || l_proc,5);

 -- Find the groupbox of the personnelist, update ghr_pa_routing_history and then call work_flow


    l_log_text := 'Error while getting the groupbox of the personnel';

   -- get the personnel offfice id
    ghr_history_fetch.fetch_positionei
    (p_position_id                 =>   p_position_id    	               ,
     p_information_type            =>   'GHR_US_POS_GRP1'		         ,
     p_date_effective              =>   trunc(nvl(p_effective_date,sysdate)),
     p_pos_ei_data                 =>   l_pos_ei_data
    );

    l_personnel_office_id          :=  l_pos_ei_data.poei_information3;
    l_pos_ei_data                  :=  null;

      for rout_det in c_gbx loop
        l_groupbox_id             :=  rout_det.gpid;
        l_routing_group_id        :=  rout_det.rgpid;
      end loop;

  -- fetch groupbox_id as well as other routing group details

    if l_groupbox_id is null then
       -- Remember to create a new message and update the message number
      hr_utility.set_message(8301,'GHR_38479_INV_GBOX_FOR_PER_OFF');
      hr_utility.raise_error;
    else
      p_groupbox_id       :=  l_groupbox_id;
      p_routing_group_id  := l_routing_group_id;
     -- Make sure that this is a valid groupbox with atleast a single user
      l_count   :=  0;
      for gbusers in C_gpbox_users loop
        l_count := gbusers.cnt;
      end loop;
      If nvl(l_count,0) = 0 then
        -- Remember to create a new message and update the message number
        hr_utility.set_message(8301,'GHR_38480_NO_GBOX_USERS');
        hr_utility.raise_error;
      End if;
    end if;
-- NOCOPY CHANGES
EXCEPTION
   when others then
      p_groupbox_id := NULL;
      p_routing_group_id := NULL;
      RAISE;
end get_personnel_off_groupbox;

Procedure get_personnel_officer_name
(p_personnel_office_id  in  ghr_pa_requests.personnel_office_id%TYPE,
 p_person_full_name     out nocopy varchar2,
 p_approving_off_work_title  out nocopy varchar2)
IS

CURSOR c_get_person_id(c_personnel_office_id varchar2)
IS
       SELECT person_id
       FROM   ghr_pois
       WHERE  personnel_office_id = c_personnel_office_id;

l_person_id per_people_f.person_id%type;

BEGIN

   for c_get_person_rec in c_get_person_id(p_personnel_office_id) LOOP

       l_person_id := c_get_person_rec.person_id;

   END LOOP;

    p_approving_off_work_title     :=
           ghr_pa_requests_pkg.get_position_work_title
                (p_person_id  => l_person_id);

    p_person_full_name := ghr_pa_requests_pkg.get_full_name_fml
	                                         (l_person_id);
EXCEPTION
    WHEN OTHERS THEN
       p_person_full_name := NULL;
       p_approving_off_work_title := NULL;
       RAISE;
END;

end ghr_mass_actions_pkg;

/
