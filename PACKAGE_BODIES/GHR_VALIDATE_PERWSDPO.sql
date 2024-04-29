--------------------------------------------------------
--  DDL for Package Body GHR_VALIDATE_PERWSDPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_VALIDATE_PERWSDPO" AS
/* $Header: ghrwsdpo.pkb 120.0.12000000.3 2007/10/15 13:11:48 utokachi noship $ */

        -- Created g_new_line to use instead of CHR(10)
        g_new_line      varchar2(1)    := substr('
',1,1);


	procedure update_posn_status (p_position_id    in number,
                                      p_effective_date in date ) IS
         l_ovn        number;
         l_esd        date;
         l_eed        date;
         l_name       varchar2(240);
         l_warning    boolean;
         l_pos_def_id number;
	BEGIN
                update hr_all_positions_f pos
                set status = 'VALID'
                where pos.position_id = p_position_id
                and p_effective_date between pos.effective_STart_date and pos.effective_end_date
                and pos.status <> 'VALID';

	END update_posn_status ;

	procedure validate_perwsdpo (p_position_id in number,
                                     p_effective_date in date ) IS

	l_pos_desc_id per_position_extra_info.poei_information5%type :=null;
	l_date_from per_position_extra_info.poei_information3%type :=null;
	l_date_to per_position_extra_info.poei_information4%type :=null;
	l_FLSA_DDF per_position_extra_info.poei_information7%type :=null;
	l_position_occ_DDF  per_position_extra_info.poei_information3%type :=null;
	l_super_status_DDF  per_position_extra_info.poei_information16%type :=null;
	l_position_sens_DDF  per_position_extra_info.poei_information13%type :=null;
	l_compet_level_DDF  per_position_extra_info.poei_information9%type :=null;
	l_working_title_DDF per_position_extra_info.poei_information12%type :=null;
	l_valide_grade_DDF per_position_extra_info.poei_information3%type :=null;
	l_job_id per_jobs.job_id%type:=null;
	l_business_group_id per_positions.business_group_id%type :=null;
	l_occ_series_KF varchar2(150) :=null;

	l_pay_table_id_DDF per_position_extra_info.poei_information5%type :=null;
	l_pay_basis_DDF per_position_extra_info.poei_information6%type :=null;
	l_Per_office_id_DDF per_position_extra_info.poei_information3%type :=null;
	l_BU_Status_DDF per_position_extra_info.poei_information8%type :=null;
	l_Work_Schedule_DDF per_position_extra_info.poei_information10%type :=null;

	l_FLSA_table ghr_position_descriptions.FLSA%type :=null;
	l_position_occ_table  ghr_position_descriptions.position_status%type :=null;
	l_super_status_table  ghr_position_descriptions.position_is%type :=null;
	l_position_sens_table  ghr_position_descriptions.position_sensitivity%type :=null;
	l_compet_level_table  ghr_position_descriptions.competitive_level%type :=null;
	l_working_title_table ghr_pd_classifications.official_title%type :=null;
	l_pay_plan_table ghr_pd_classifications.pay_plan%type :=null;
	l_valide_grade_table ghr_pd_classifications.grade_level%type :=null;
	l_payplan_grade_table varchar2(10) :=null;
	l_occ_series_table ghr_pd_classifications.occupational_code%type :=null;

      cursor c_pos_extra_info is
	select poei.poei_information3,poei.poei_information4,poei.poei_information5
	  from per_position_extra_info poei
	where poei.position_id=p_position_id and poei.information_type='GHR_US_POSITION_DESCRIPTION';

	cursor c_pos_extra_info_DDF1 is
	select poei.poei_information3,poei.poei_information7
				,poei.poei_information8,poei.poei_information10
				,poei.poei_information16,poei.poei_information13
				,poei.poei_information9,poei.poei_information12
	from per_position_extra_info poei
	where poei.position_id=p_position_id
				and poei.information_type='GHR_US_POS_GRP1';

	cursor c_pos_extra_info_DDF2 is
	select poei.poei_information3
	from per_position_extra_info poei
	where poei.position_id=p_position_id and poei.information_type='GHR_US_POS_GRP2';

	cursor c_pos_extra_info_DDF3 is
	select poei.poei_information3,poei.poei_information5,poei.poei_information6
	from per_position_extra_info poei
	where poei.position_id=p_position_id and poei.information_type='GHR_US_POS_VALID_GRADE';

	cursor c_pos_table is
	select pos.job_id, pos.business_group_id
	from hr_all_positions_f pos
	where pos.position_id= p_position_id
        and   p_effective_date between pos.effective_start_date and pos.effective_end_date;

	cursor c_pos_desc_table is
	select pd.flsa, pd.position_status, pd.position_is,pd.position_sensitivity,pd.competitive_level,
		 cl.official_title, cl.pay_plan, cl.grade_level, cl.occupational_code
	from ghr_position_descriptions pd, ghr_pd_classifications cl
	where pd.position_description_id = l_pos_desc_id
		and pd.position_description_id=cl.position_description_id;




	BEGIN
		FOR c_pos_extra_info_rec IN  c_pos_extra_info LOOP
     			l_date_from := c_pos_extra_info_rec.poei_information3;
     			l_date_to := c_pos_extra_info_rec.poei_information4;
     			l_pos_desc_id := c_pos_extra_info_rec.poei_information5;
			exit;
 		END LOOP;

		if l_pos_desc_id is not null then

		   if nvl(fnd_date.canonical_to_date(l_date_from),sysdate) > sysdate
				and nvl(fnd_date.canonical_to_date(l_date_to),sysdate) <= sysdate then

			/* get values from DDFs */

			FOR c_pos_extra_info_DDF1_rec IN  c_pos_extra_info_DDF1 LOOP
     				l_Per_office_id_DDF:= c_pos_extra_info_DDF1_rec.poei_information3;
     				l_FLSA_DDF:= c_pos_extra_info_DDF1_rec.poei_information7;
     				l_BU_Status_DDF:= c_pos_extra_info_DDF1_rec.poei_information8;
     				l_Work_Schedule_DDF:= c_pos_extra_info_DDF1_rec.poei_information10;
     				l_super_status_DDF:= c_pos_extra_info_DDF1_rec.poei_information16;
     				l_position_sens_DDF:= c_pos_extra_info_DDF1_rec.poei_information13;
     				l_compet_level_DDF:= c_pos_extra_info_DDF1_rec.poei_information9;
     				l_working_title_DDF:= c_pos_extra_info_DDF1_rec.poei_information12;
				exit;
 			END LOOP;

			FOR c_pos_extra_info_DDF2_rec IN  c_pos_extra_info_DDF2 LOOP
     				l_position_occ_DDF := c_pos_extra_info_DDF2_rec.poei_information3;
				exit;
 			END LOOP;


			FOR c_pos_extra_info_DDF3_rec IN  c_pos_extra_info_DDF3 LOOP
     				l_valide_grade_DDF:= c_pos_extra_info_DDF3_rec.poei_information3;
				l_pay_table_id_DDF:= c_pos_extra_info_DDF3_rec.poei_information5;
				l_pay_basis_DDF := c_pos_extra_info_DDF3_rec.poei_information6;
				exit;
 			END LOOP;


			FOR c_pos_table_rec IN  c_pos_table LOOP
     				l_job_id := c_pos_table_rec.job_id;
				l_business_group_id := c_pos_table_rec.business_group_id;
				exit;
 			END LOOP;

			if l_job_id is not null and l_business_group_id is not null then
				l_occ_series_KF := ghr_api.get_job_occ_series_job(l_job_id ,l_business_group_id);
			end if;


			/* get values from ghr_position_descriptions */

			FOR c_pos_desc_table_rec IN  c_pos_desc_table LOOP
     				l_FLSA_table:= c_pos_desc_table_rec.flsa;
				l_position_occ_table := c_pos_desc_table_rec.position_status;
     				l_super_status_table := c_pos_desc_table_rec.position_is;
				l_position_sens_table:= c_pos_desc_table_rec.position_sensitivity;
				l_compet_level_table:= c_pos_desc_table_rec.competitive_level;
     				l_working_title_table:= c_pos_desc_table_rec.official_title;
				l_pay_plan_table:= c_pos_desc_table_rec.pay_plan;
     				l_valide_grade_table:= c_pos_desc_table_rec.grade_level;
 				l_occ_series_table:= c_pos_desc_table_rec.occupational_code;
				exit;
 			END LOOP;
			l_payplan_grade_table := l_pay_plan_table ||'-'||l_valide_grade_table;


			/* check the null values for some required DDFs */
			if l_valide_grade_DDF is null or l_pay_table_id_DDF is null or l_pay_basis_DDF is null
			   or	l_Per_office_id_DDF is null or l_FLSA_DDF is null or l_BU_Status_DDF is null
			   or l_Work_Schedule_DDF is null or l_super_status_DDF is null or l_position_occ_DDF is null then
					hr_utility.set_message(8301, 'GHR_37910_POS_VALIDATE_FAIL');
       				hr_utility.raise_error;
			end if;

			/* compare values */
			   	if l_FLSA_DDF is not null and l_FLSA_table is not null then
					if l_FLSA_DDF <> l_FLSA_table  then
						hr_utility.set_message(8301, 'GHR_37911_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_position_occ_DDF is not null and l_position_occ_table  is not null then
					if l_position_occ_DDF <> l_position_occ_table then
						hr_utility.set_message(8301, 'GHR_37912_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_super_status_DDF is not null and l_super_status_table  is not null then
					if l_super_status_DDF <> l_super_status_table then
						hr_utility.set_message(8301, 'GHR_37913_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_position_sens_DDF is not null and l_position_sens_table is not null then
					if l_position_sens_DDF <> l_position_sens_table then
						hr_utility.set_message(8301, 'GHR_37914_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_compet_level_DDF is not null and l_compet_level_table  is not null then
					if l_compet_level_DDF <> l_compet_level_table then
						hr_utility.set_message(8301, 'GHR_37915_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_working_title_DDF is not null and l_working_title_table is not null then
					if l_working_title_DDF <> l_working_title_table then
						hr_utility.set_message(8301, 'GHR_37918_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_valide_grade_DDF is not null and l_pay_plan_table is not null and l_valide_grade_table is not null then
					if l_valide_grade_DDF <> l_valide_grade_table  then
						hr_utility.set_message(8301, 'GHR_37916_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;
				if l_occ_series_KF is not null and l_occ_series_table  is not null then
					if	l_occ_series_KF <> l_occ_series_table then
						hr_utility.set_message(8301, 'GHR_37917_POS_VALIDATE_FAIL');
       					hr_utility.raise_error;
					end if;
				end if;

		    end if;
		end if;

-- call GHRWSDPO_AGENCY.AGENCY_CHECK
	     GHR_WSDPO_AGENCY.AGENCY_CHECK (p_position_id);

		exception
				when no_data_found then
		null;

	END validate_perwsdpo;



-- ---------------------------------------------------------------------------
-- |--------------------------< chk_position_obligated >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_position_obligated (p_position_id in number
                                ,p_date        in date)
  RETURN BOOLEAN IS
--
l_chk_position_obligated boolean :=false;
l_expire_date            PER_POSITION_EXTRA_INFO.POEI_INFORMATION3%type;
l_obligate_type          PER_POSITION_EXTRA_INFO.POEI_INFORMATION4%type;
l_pos_ei_data            PER_POSITION_EXTRA_INFO%ROWTYPE;

BEGIN

  ghr_history_fetch.fetch_positionei (p_position_id      => p_position_id
                                     ,p_information_type => 'GHR_US_POS_OBLIG'
                                     ,p_date_effective   => p_date
                                     ,p_pos_ei_data      => l_pos_ei_data);

  l_expire_date   := l_pos_ei_data.POEI_INFORMATION3;
  l_obligate_type := l_pos_ei_data.POEI_INFORMATION4;
  if (l_expire_date IS NULL
      OR fnd_date.canonical_to_date(l_expire_date) >= p_date )
     and NVL(l_obligate_type,'U') <> 'U' then
    l_chk_position_obligated :=true;
  else
    l_chk_position_obligated :=false;
  end if;

  return l_chk_position_obligated;

end chk_position_obligated;

-- ---------------------------------------------------------------------------
-- |--------------------------< chk_PAR_Exists >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_par_exists (p_position_id in number)  RETURN BOOLEAN IS
l_chk_par_exists	boolean :=false;
l_par_found		boolean :=false;
l_chk 		number;

cursor c_par_exists is
select gpr.pa_request_id
from GHR_PA_REQUESTS gpr
where gpr.to_position_id = p_position_id;

begin

	FOR c_par_exists_rec IN  c_par_exists LOOP
     		l_chk := c_par_exists_rec.pa_request_id;
		l_par_found := TRUE;
		exit;
 	END LOOP;

	If l_par_found then
		l_chk_par_exists := TRUE;
	End If;

	return l_chk_par_exists;

end chk_par_exists;

-- Start of Bug 3501968
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_PAR_Exists_f_per >----------------|
-- This function is built similar to chk_PAR_Exists.             ------------
-- It returns true if a given person has atleast one PA request. ------------
-- --------------------------------------------------------------------------
FUNCTION chk_par_exists_f_per (p_person_id in number)  RETURN BOOLEAN IS
l_chk_par_exists	boolean :=false;
l_par_found		boolean :=false;
l_chk 		number;

cursor c_par_exists is
select gpr.pa_request_id
from GHR_PA_REQUESTS gpr
where gpr.person_id = p_person_id;

begin

	FOR c_par_exists_rec IN  c_par_exists LOOP
     		l_chk := c_par_exists_rec.pa_request_id;
		l_par_found := TRUE;
		exit;
 	END LOOP;

	If l_par_found then
		l_chk_par_exists := TRUE;
	End If;

	return l_chk_par_exists;

end chk_par_exists_f_per;

-- End of Bug 3501968.

-- ---------------------------------------------------------------------------
-- |--------------------------< chk_location_assigned >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_location_assigned (p_location_id in number)  RETURN BOOLEAN IS
l_chk_location_assigned boolean :=false;
l_count number;
begin
     select count(*) into l_count from PER_ASSIGNMENTS_F assign
     where assign.location_id=p_location_id  and assign.primary_flag='Y'
       and assign.assignment_type <> 'B';
     if l_count>0 then
         l_chk_location_assigned :=true;
     else
	   l_chk_location_assigned :=false;
     end if;
	return l_chk_location_assigned;

end chk_location_assigned;

-- ---------------------------------------------------------------------------
-- |--------------------------< chk_position_assigned >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_position_assigned (p_position_id in number)  RETURN BOOLEAN IS
l_chk_position_assigned boolean :=false;
l_count number;
begin
     select count(*) into l_count from PER_ASSIGNMENTS_F assign
     where assign.position_id=p_position_id and assign.assignment_type <> 'B';
     if l_count>0 then
         l_chk_position_assigned :=true;
     else
	   l_chk_position_assigned :=false;
     end if;
	return l_chk_position_assigned;

end chk_position_assigned;

-- ---------------------------------------------------------------------------
-- |--------------------------< chk_position_assigned_date >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_position_assigned_date (p_position_id in number
                                    ,p_date        in date)
  RETURN BOOLEAN IS
CURSOR c_asg IS
  select 1
  from   PER_ASSIGNMENTS_F asg
  where  asg.position_id = p_position_id
  and    asg.assignment_type <> 'B'
  and    NVL(p_date,trunc(sysdate))
     between asg.effective_start_date and asg.effective_end_date;
BEGIN
  FOR c_asg_rec IN c_asg LOOP
    RETURN(TRUE);
  END LOOP;

RETURN(FALSE);

END chk_position_assigned_date;

-- ---------------------------------------------------------------------------
-- |--------------------------< chk_position_assigned_other >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_position_assigned_other (p_position_id in number
                                     ,p_assignment_id in number
                                     ,p_date        in date)
  RETURN BOOLEAN IS
CURSOR c_asg IS
  select 1
  from   PER_ASSIGNMENTS_F asg
  where  asg.position_id = p_position_id
  and asg.assignment_id <> p_assignment_id  -- Exclude Current Assignment
  and asg.assignment_type <> 'B'
  and NVL(p_date,trunc(sysdate)) between asg.effective_start_date
                                 and asg.effective_end_date;

BEGIN
  FOR c_asg_rec IN c_asg LOOP
    RETURN(TRUE);
  END LOOP;

RETURN(FALSE);

END chk_position_assigned_other;

-- ---------------------------------------------------------------------------
-- |--------------------------< chk_position_assigned_cwk >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_position_assigned_cwk (p_position_id in number
                                    ,p_date        in date)
  RETURN BOOLEAN IS
CURSOR c_asg IS
  select 1
  from   PER_ASSIGNMENTS_F asg
  where  asg.position_id = p_position_id
  and asg.assignment_type = 'C'
  and NVL(p_date,trunc(sysdate)) between asg.effective_start_date
                                 and asg.effective_end_date;

BEGIN
  FOR c_asg_rec IN c_asg LOOP
    RETURN(TRUE);
  END LOOP;

RETURN(FALSE);

END chk_position_assigned_cwk;



-- ---------------------------------------------------------------------------
-- |--------------------------< return_upd_hr_vert_status >----------------|
-- --------------------------------------------------------------------------
FUNCTION return_upd_hr_vert_status RETURN BOOLEAN IS
	l_proc varchar2(72) := g_package||'return_upd_hr_vert_status' ;
begin
 	hr_utility.set_location('Entering:'||l_proc,5);
 	return (nvl(g_bypass_vert, false));
 	hr_utility.set_location(' Leaving:'||l_proc,10);
end return_upd_hr_vert_status;

-- This function checks if there are any future PA Request actions for a given position
-- that have been completed.
FUNCTION check_pend_future_pars (p_position_id    IN NUMBER
                                ,p_effective_date IN DATE)
RETURN VARCHAR2 IS

l_pend_future_list VARCHAR2(2000) := NULL;
--
CURSOR c_par IS
  SELECT 'Request Number:'||par.request_number||
        ', 1st NOA Code:'||par.first_noa_code||
        DECODE(par.second_noa_code,NULL,NULL, ', 2nd NOA Code:'||par.second_noa_code)||
        ', Effective Date:'||par.effective_date||
        ', Employee_Name:'||per.full_name||
        ', SSN:'||per.national_identifier||
        ', Updater:'||prh.user_name     list_info
  FROM   per_people_f           per
        ,ghr_pa_routing_history prh
        ,ghr_pa_requests        par
  WHERE  par.to_position_id      = p_position_id
  AND    par.effective_date >= p_effective_date
  AND    prh.pa_request_id  = par.pa_request_id
  AND    prh.pa_routing_history_id = (SELECT MAX(prh2.pa_routing_history_id)
                                      FROM   ghr_pa_routing_history prh2
                                      WHERE  prh2.pa_request_id = par.pa_request_id)
  AND    prh.action_taken IN ('FUTURE_ACTION')
  AND    par.person_id = per.person_id
  AND    par.effective_date between per.effective_start_date and per.effective_end_date
  ORDER BY par.effective_date, par.pa_request_id;


BEGIN
  -- loop around them all to build up a list
  FOR c_par_rec IN c_par LOOP
    l_pend_future_list := SUBSTR(l_pend_future_list||g_new_line||g_new_line||c_par%ROWCOUNT||'.'||c_par_rec.list_info,1,2000);
  END LOOP;

  RETURN(l_pend_future_list);

END check_pend_future_pars ;


--
-- ---------------------------------------------------------------------------
-- |---------------------------< IS_RPA_ELEMENT >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Checks whether element is created through RPA process or
--   entered through element entries screen on person form. If element is
--   created through RPA, function returns TRUE; Otherwise function returns
--   FALSE.
--
-- Prerequisites:
--   p_element_entry_value_id must be provided.
--
-- In Parameters:
--   p_element_entry_value_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--    None.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
FUNCTION is_rpa_element(p_element_entry_id IN NUMBER)
         RETURN BOOLEAN AS

	Cursor c_history_element is
	SELECT 'X' value
	FROM   ghr_pa_history
	WHERE  table_name = ghr_history_api.g_eleent_table
--	AND    information1 = p_element_entry_id
    --  Bug #5746242  vmididho  modified the above statement for performance
        AND    information1 = to_char(p_element_entry_id)
	AND    pa_request_id is not null;


	l_proc VARCHAR2(80) := 'is_rpa_element';
BEGIN
   hr_utility.set_location('Entering '||l_proc,0);
   hr_utility.set_location('Element entry id = '||to_char(p_element_entry_id),1);
	FOR C_rec IN c_history_element
	LOOP
		IF c_rec.value = 'X' THEN
		   hr_utility.set_location('Leaving '||l_proc,5);
		   Return True;
		   exit;
		END IF;
        END LOOP;
	hr_utility.set_location('Leaving '||l_proc,10);
	RETURN FALSE;

END is_rpa_element;

-- --------------------------------------------------------------------------
-- |--------------------------< chk_future_assigned >----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_future_assigned (p_position_id in number
                             ,p_date        in date)
  RETURN BOOLEAN IS
CURSOR c_asg IS
  select 1
  from   PER_ASSIGNMENTS_F asg
  where  asg.position_id = p_position_id
  and    asg.assignment_type <> 'B'
  and    asg.effective_start_date >= NVL(p_date,trunc(sysdate));

BEGIN
  FOR c_asg_rec IN c_asg LOOP
    RETURN(TRUE);
  END LOOP;

RETURN(FALSE);

END chk_future_assigned;

-- --------------------------------------------------------------------------
-- |--------------------------< chk_rpa_sourced_next>----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_rpa_sourced_next(p_position_id            in number
                             ,p_effective_end_date     in date)
RETURN BOOLEAN IS

CURSOR c_phv IS
  select 1
  from   GHR_POSITIONS_H_V phv
  where  phv.position_id = p_position_id
  and    phv.pa_request_id IS NOT NULL
  and    phv.availability_status_id = 1
  and    phv.effective_start_date = p_effective_end_date+1;

BEGIN

  FOR c_phv_rec IN c_phv LOOP
    -- If any rows returned were created by an RPA and the hiring/avail status is 'Active
    -- then prevent delete from occuring to avoid losing data and getting asg/posn out of sync.
    RETURN(TRUE);
  END LOOP;

  RETURN(FALSE);

END chk_rpa_sourced_next;

-- --------------------------------------------------------------------------
-- |--------------------------< chk_rpa_sourced_all>----------------|
-- --------------------------------------------------------------------------
FUNCTION chk_rpa_sourced_all(p_position_id            in number
                            ,p_effective_end_date     in date)
RETURN BOOLEAN IS

CURSOR c_phv IS
  select 1
  from   GHR_POSITIONS_H_V phv
  where  phv.position_id = p_position_id
  and    phv.pa_request_id IS NOT NULL
  and    phv.availability_status_id = 1
  and    phv.effective_start_date >= p_effective_end_date+1;

BEGIN

  FOR c_phv_rec IN c_phv LOOP
    -- If any rows returned were created by an RPA and the hiring/avail status is 'Active
    -- then prevent delete from occuring to avoid losing data and getting asg/posn out of sync.
    RETURN(TRUE);
  END LOOP;

  RETURN(FALSE);

END chk_rpa_sourced_all;

-- --------------------------------------------------------------------------
-- |-----------------------------< get_position_eff_date>-------------------|
-- --------------------------------------------------------------------------

FUNCTION get_position_eff_date(p_position_id   in number)
RETURN DATE IS

CURSOR c_pos IS
   SELECT date_effective
   FROM   per_all_positions pap
   WHERE  pap.position_id = p_position_id;

BEGIN

   FOR c_pos_rec IN c_pos LOOP
      RETURN(c_pos_rec.date_effective);
   END LOOP;

END get_position_eff_date;


END ghr_validate_perwsdpo;

/
