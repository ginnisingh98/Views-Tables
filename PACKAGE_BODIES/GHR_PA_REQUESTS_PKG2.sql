--------------------------------------------------------
--  DDL for Package Body GHR_PA_REQUESTS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PA_REQUESTS_PKG2" AS
/* $Header: ghparqs2.pkb 120.5 2005/08/25 11:30:26 vravikan noship $ */

-- This function checks if there are any pending PA Request actions for a given person (not including the
-- given PA Request)
-- And returns a list of thoses that are pending.
-- The definition of pending is its current routing status is not 'CANCELED' or 'UPDATE_HR_COMPLETE'
-- To prevent listing those that got put in the 'black hole' (i.e. were saved but not routed) make sure
-- the routing history has a date notification sent (except for 'FUTURE_ACTIONS' as they may not have
-- been routed but are still pending)

FUNCTION check_pending_pars (p_person_id     IN NUMBER
                            ,p_pa_request_id IN NUMBER)
  RETURN VARCHAR2 IS

l_pending_list VARCHAR2(2000) := NULL;
l_new_line     VARCHAR2(1)    := substr('
',1,1);
--
CURSOR c_par IS
  SELECT 'Request Number:'||par.request_number||
        ', 1st NOA Code:'||par.first_noa_code||
        DECODE(par.second_noa_code,NULL,NULL, ', 2nd NOA Code:'||par.second_noa_code)||
  ------      ', Effective Date:'||TO_CHAR(par.effective_date,'DD-MON-YYYY')||
        ', Effective Date:'||fnd_date.date_to_chardate(par.effective_date)||
        DECODE(prh.action_taken,'FUTURE_ACTION', ', APPROVED',
               ', Routed To '||DECODE(gbx.name,null, 'User:'||prh.user_name, 'Groupbox:'||gbx.name))  list_info
  FROM   ghr_groupboxes         gbx
        ,ghr_pa_routing_history prh
        ,ghr_pa_requests        par
  WHERE  gbx.groupbox_id(+) = prh.groupbox_id
  AND    par.person_id = p_person_id
  AND    par.pa_request_id <> NVL(p_pa_request_id,-999)
  AND    prh.pa_request_id = par.pa_request_id
  AND    prh.pa_routing_history_id = (SELECT MAX(prh2.pa_routing_history_id)
                                      FROM   ghr_pa_routing_history prh2
                                      WHERE  prh2.pa_request_id = par.pa_request_id)
  AND    NVL(prh.action_taken,'==@@==') NOT IN ('CANCELED','UPDATE_HR_COMPLETE')
  AND    (prh.date_notification_sent is not null
     OR prh.action_taken = 'FUTURE_ACTION')
  ORDER BY par.pa_request_id;

BEGIN
  -- loop arounfd them all to build up a list
  FOR c_par_rec IN c_par LOOP

    l_pending_list := SUBSTR(l_pending_list||l_new_line || l_new_line ||c_par%ROWCOUNT||'.'||c_par_rec.list_info,1,2000);

  END LOOP;

  RETURN(l_pending_list);

END check_pending_pars;

-- This function checks if there are any processed or approved PA Requests for the given person
-- at the given date. The definition of 'Processed' is the lasting Routing history record is 'UPDATE_HR_COMPLETE'
-- and the definition of 'Approved' is the lasting Routing history record is 'FUTURE_ACTION'
FUNCTION check_proc_future_pars (p_person_id      IN NUMBER
                                ,p_effective_date IN DATE)
RETURN VARCHAR2 IS

l_proc_future_list VARCHAR2(2000) := NULL;
l_new_line VARCHAR2(1) := substr('
',1,1);
--
CURSOR c_par IS
  SELECT DECODE(prh.action_taken,'UPDATE_HR_COMPLETE', 'Processed:','FUTURE_ACTION', 'Pending:')||
        'Request Number:'||par.request_number||
        ', 1st NOA Code:'||par.first_noa_code||
        DECODE(par.first_noa_cancel_or_correct,'CANCEL','(CANCELED)')||
        DECODE(par.second_noa_code,NULL,NULL, ', 2nd NOA Code:'||par.second_noa_code)||
        DECODE(par.second_noa_cancel_or_correct,'CANCEL','(CANCELED)')||
   ---     ', Effective Date:'||TO_CHAR(par.effective_date,'DD-MON-YYYY') list_info
        ', Effective Date:'||fnd_date.date_to_chardate(par.effective_date) list_info
  FROM   ghr_pa_routing_history prh
        ,ghr_pa_requests        par
  WHERE  par.person_id      = p_person_id
  AND    par.effective_date >= p_effective_date
  AND    prh.pa_request_id  = par.pa_request_id
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
       )
  ORDER BY par.effective_date, par.pa_request_id;


BEGIN
  -- loop around them all to build up a list
  FOR c_par_rec IN c_par LOOP

    l_proc_future_list := SUBSTR(l_proc_future_list|| l_new_line || l_new_line ||c_par%ROWCOUNT||'.'||c_par_rec.list_info,1,2000);

  END LOOP;

  RETURN(l_proc_future_list);

END check_proc_future_pars;
--
-- This procedure is called from GHRWSREI form and was only written because when we did just
-- these 2 calls in the form it call an Error 306... bad 'BIND_I' in the pacakage body
-- ghr_non_sf52_extra_info!!! (Well I couldn't explain it!)
--
PROCEDURE refresh_par_extra_info (p_pa_request_id  IN NUMBER
                                 ,p_first_noa_id   IN NUMBER
                                 ,p_second_noa_id  IN NUMBER
                                 ,p_person_id      IN NUMBER
                                 ,p_assignment_id  IN NUMBER
                                 ,p_position_id    IN NUMBER
                                 ,p_effective_date IN DATE) IS
BEGIN
  ghr_non_sf52_extra_info.populate_noa_spec_extra_info(
                 p_pa_request_id  => p_pa_request_id
                ,p_first_noa_id   => p_first_noa_id
                ,p_second_noa_id  => p_second_noa_id
                ,p_person_id      => p_person_id
                ,p_assignment_id  => p_assignment_id
                ,p_position_id    => p_position_id
                ,p_effective_date => p_effective_date
                ,p_refresh_flag   => 'Y' );

  ghr_non_sf52_extra_info.fetch_generic_extra_info(
                 p_pa_request_id  => p_pa_request_id
                ,p_person_id      => p_person_id
                ,p_assignment_id  => p_assignment_id
                ,p_effective_date => p_effective_date
                ,p_refresh_flag   => 'Y' );

END;
--
-- This function is passed an altered Pa request id to check that it is not a request id that
-- is also a correction.
-- Returns TRUE if the pa request id passed is not a correction
--
FUNCTION check_first_correction (p_altered_pa_request_id IN NUMBER)
  RETURN BOOLEAN IS
--
CURSOR c_par IS
  SELECT par.noa_family_code
  FROM   ghr_pa_requests par
  WHERE  par.pa_request_id = p_altered_pa_request_id;

BEGIN
  -- get the noa_family code of the altered pa request id
  FOR c_par_rec IN c_par LOOP
    IF c_par_rec.noa_family_code <> 'CORRECT' THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;
  END LOOP;

  -- Shouldn't really get here as that means the PAR id passed in was invalid!!
  RETURN(FALSE);

END check_first_correction;
--
-- this function takes in a pa request id and gives back the 'Agency code Transfer from'
-- that is in the PAR EI (should only be called for Appointment transfers, since all these NOACs
-- are with APP PM family we will actually call it in the form for ALL NOAC's in the APP family)
-- it should then be used to go into field #14
FUNCTION get_agency_code_from (p_pa_request_id IN NUMBER
                              ,p_noa_id        IN NUMBER)
  RETURN VARCHAR2 IS
CURSOR c_rei IS
  SELECT rei.rei_information3 agency_code
  FROM   ghr_pa_request_extra_info rei
  WHERE  rei.pa_request_id = p_pa_request_id
  AND    rei.information_type = 'GHR_US_PAR_APPT_TRANSFER'
  AND EXISTS (SELECT 1
              FROM   ghr_noa_families          naf
                    ,ghr_pa_request_info_types rit
              WHERE  rei.information_type = rit.information_type
              AND    rit.noa_family_code = naf.noa_family_code
              AND    naf.nature_of_action_id = p_noa_id);
  --
BEGIN
  FOR c_rei_rec IN c_rei LOOP
    RETURN(c_rei_rec.agency_code);
  END LOOP;
  --
  -- Shouldn't really get here as that means the PAR id passed in was invalid!!
  RETURN(NULL);
  --
END get_agency_code_from;
--
-- this function takes in a pa request id and gives back the 'Agency code Transfer to'
-- that is in the PAR EI (should only be called for NOA 352)
-- it should then be used to go into field #22
FUNCTION get_agency_code_to (p_pa_request_id IN NUMBER
                            ,p_noa_id        IN NUMBER)
  RETURN VARCHAR2 IS
CURSOR c_rei IS
  SELECT rei.rei_information3 agency_code
  FROM   ghr_pa_request_extra_info rei
  WHERE  rei.pa_request_id = p_pa_request_id
  AND    rei.information_type = 'GHR_US_PAR_MASS_TERM'
  AND EXISTS (SELECT 1
              FROM   ghr_noa_families          naf
                    ,ghr_pa_request_info_types rit
              WHERE  rei.information_type = rit.information_type
              AND    rit.noa_family_code = naf.noa_family_code
              AND    naf.nature_of_action_id = p_noa_id);
  --
BEGIN
  FOR c_rei_rec IN c_rei LOOP
    RETURN(c_rei_rec.agency_code);
  END LOOP;
  --
  -- Shouldn't really get here as that means the PAR id passed in was invalid!!
  RETURN(NULL);
  --
END get_agency_code_to;
--
  FUNCTION get_position_nfc_agency_code(p_position_id IN NUMBER,
           p_effective_date IN DATE)
    RETURN VARCHAR2 IS
CURSOR cur_pp IS
--
 SELECT pdf.segment3 nfc_agency
       FROM per_position_definitions pdf, hr_all_positions_f pos
  WHERE pos.position_id = p_position_id
  AND   p_effective_date between pos.effective_start_date
        and pos.effective_end_date
  AND   pos.position_definition_id = pdf.position_definition_id;
BEGIN
  FOR cur_pp_rec IN cur_pp LOOP
    RETURN(cur_pp_rec.nfc_agency);
  END LOOP;

  RETURN (NULL);
END get_position_nfc_agency_code;

--

-- This function to be used only for NFC
  FUNCTION get_poi (p_position_id IN NUMBER,p_effective_date IN DATE)
    RETURN VARCHAR2 IS
CURSOR cur_pp(c_position_id IN NUMBER,c_effective_date IN DATE) IS
--
SELECT pdf.segment4 poi
       FROM per_position_definitions pdf, hr_all_positions_f pos
  WHERE pos.position_id = c_position_id
  AND   c_effective_date between pos.effective_start_date
        and pos.effective_end_date
  AND   pos.position_definition_id = pdf.position_definition_id;

BEGIN
  FOR cur_pp_rec IN cur_pp(p_position_id,p_effective_date) LOOP
    RETURN(cur_pp_rec.poi);
  END LOOP;

  RETURN (NULL);
END get_poi;

--
FUNCTION get_poi_eit (p_position_id IN NUMBER,
                      p_effective_date in date,
                      p_bg_id in number)
    RETURN VARCHAR2 IS
CURSOR cur_pp IS
--
select segment4 poi
 from per_position_definitions ppd,hr_all_positions_f pos
where ppd.position_definition_id = pos.position_definition_id
and pos.position_id = p_position_id
and p_effective_date between pos.effective_start_date and
   pos.effective_end_date;
CURSOR cur_nfc IS
SELECT hoi.org_information_context
            , hoi.org_information6
       FROM hr_organization_information hoi
       WHERE hoi.org_information_context = 'GHR_US_ORG_INFORMATION'
         AND hoi.organization_id = p_bg_id
         AND hoi.org_information6 = 'Y';
BEGIN
  FOR cur_nfc_rec in cur_nfc LOOP
  FOR cur_pp_rec IN cur_pp LOOP
    RETURN(cur_pp_rec.poi);
  END LOOP;
  END LOOP;

  RETURN (NULL);
END get_poi_eit;

--
FUNCTION get_nfc_agency_eit (p_position_id IN NUMBER,
                             p_effective_date in date,
                      p_bg_id in number)
    RETURN VARCHAR2 IS
CURSOR cur_pp IS
--
select segment3 nfc_agency
 from per_position_definitions ppd,hr_all_positions_f pos
where ppd.position_definition_id = pos.position_definition_id
and pos.position_id = p_position_id
and p_effective_date between pos.effective_start_date
and pos.effective_end_date;
CURSOR cur_nfc IS
SELECT hoi.org_information_context
            , hoi.org_information6
       FROM hr_organization_information hoi
       WHERE hoi.org_information_context = 'GHR_US_ORG_INFORMATION'
         AND hoi.organization_id = p_bg_id
         AND hoi.org_information6 = 'Y';
BEGIN
 FOR cur_nfc_rec IN cur_nfc LOOP
  FOR cur_pp_rec IN cur_pp LOOP
    RETURN(cur_pp_rec.nfc_agency);
  END LOOP;
  END LOOP;

  RETURN (NULL);
END get_nfc_agency_eit;

  --
  -- This function has to be called only for NFC
FUNCTION get_pay_plan_grade (p_position_id IN NUMBER
			      ,p_effective_date in date)
    RETURN VARCHAR2 IS
--
CURSOR cur_pp(c_position_id IN NUMBER
	     ,c_effective_date in date) IS
select segment7 grade_id
 from per_position_definitions ppd,hr_all_positions_f pos
where ppd.position_definition_id = pos.position_definition_id
and pos.position_id = p_position_id
and p_effective_date between pos.effective_start_date
and pos.effective_end_date;

CURSOR get_pay_plan(c_grade_id per_grades.grade_id%type) IS
select name grade_name
from per_grades
where grade_id = c_grade_id;

l_grade_id per_grades.grade_id%type;

BEGIN
  FOR cur_pp_rec IN cur_pp(p_position_id
			  ,p_effective_date) LOOP
	l_grade_id := cur_pp_rec.grade_id;
  END LOOP;

  FOR cur_get_pay_plan IN get_pay_plan(l_grade_id) LOOP
	RETURN(cur_get_pay_plan.grade_name);
  END LOOP;

  RETURN (NULL);

END get_pay_plan_grade;
  --
  FUNCTION get_pay_plan_grade_eit (p_position_id IN NUMBER,
                                   p_effective_date in date,
                      p_bg_id in number)
    RETURN VARCHAR2 IS
CURSOR cur_pp IS
--
 SELECT gdf.segment1 || '-' || gdf.segment2 pay_plan
  FROM  per_grade_definitions   gdf
       ,per_grades              grd
  WHERE   grd.grade_id in
(select segment7
 from per_position_definitions ppd,hr_all_positions_f pos
where ppd.position_definition_id = pos.position_definition_id
and pos.position_id = p_position_id
and p_effective_date between pos.effective_start_date and
pos.effective_end_date)
  AND   grd.grade_definition_id = gdf.grade_definition_id;
CURSOR cur_nfc IS
SELECT hoi.org_information_context
            , hoi.org_information6
       FROM hr_organization_information hoi
       WHERE hoi.org_information_context = 'GHR_US_ORG_INFORMATION'
         AND hoi.organization_id = p_bg_id
         AND hoi.org_information6 = 'Y';
BEGIN
  FOR cur_nfc_rec IN cur_nfc LOOP
  FOR cur_pp_rec IN cur_pp LOOP
    RETURN(cur_pp_rec.pay_plan);
  END LOOP;
  END LOOP;

  RETURN (NULL);

END get_pay_plan_grade_eit;
  --
FUNCTION get_pay_plan (p_position_id IN NUMBER)
  RETURN VARCHAR2 IS
CURSOR cur_pp IS
  SELECT gdf.segment1 pay_plan
  FROM  per_grade_definitions   gdf
       ,per_grades              grd
       ,per_position_extra_info poi
  WHERE poi.position_id = p_position_id
  AND   poi.information_type = 'GHR_US_POS_VALID_GRADE'
  AND   grd.grade_id = poi.poei_information3
  AND   grd.grade_definition_id = gdf.grade_definition_id;
BEGIN
  FOR cur_pp_rec IN cur_pp LOOP
    RETURN(cur_pp_rec.pay_plan);
  END LOOP;

  RETURN (NULL);

END get_pay_plan;
--
FUNCTION get_grade_or_level (p_position_id IN NUMBER)
  RETURN VARCHAR2 IS
--
CURSOR cur_pp IS
  SELECT gdf.segment2 grade_or_level
  FROM  per_grade_definitions   gdf
       ,per_grades              grd
       ,per_position_extra_info poi
  WHERE poi.position_id = p_position_id
  AND   poi.information_type = 'GHR_US_POS_VALID_GRADE'
  AND   grd.grade_id = poi.poei_information3
  AND   grd.grade_definition_id = gdf.grade_definition_id;
BEGIN
  FOR cur_pp_rec IN cur_pp LOOP
    RETURN(cur_pp_rec.grade_or_level);
  END LOOP;

  RETURN (NULL);

END get_grade_or_level;
--
FUNCTION get_pos_title_segment(p_business_group_id IN NUMBER)
  RETURN VARCHAR2 IS
--
CURSOR cur_org IS
  SELECT oi.org_information2
  FROM   hr_organization_information oi
  WHERE  oi.organization_id = p_business_group_id
  AND    oi.org_information_context = 'GHR_US_ORG_INFORMATION';
BEGIN
  FOR cur_org_rec IN cur_org LOOP
    RETURN(cur_org_rec.org_information2 );
  END LOOP;
  --
  RETURN (NULL);
  --
END get_pos_title_segment;

--
FUNCTION chk_position_obligated (p_position_id in number
                                ,p_date        in date)
  RETURN BOOLEAN IS
--
l_chk_position_obligated boolean :=false;
l_expire_date            PER_POSITION_EXTRA_INFO.POEI_INFORMATION3%type;
l_obligate_type          PER_POSITION_EXTRA_INFO.POEI_INFORMATION4%type;
l_pos_ei_data            PER_POSITION_EXTRA_INFO%ROWTYPE;

BEGIN

  ghr_history_fetch.fetch_positionei (p_position_id      =>  p_position_id
                                     ,p_information_type => 'GHR_US_POS_OBLIG'
                                     ,p_date_effective   => p_date
                                     ,p_pos_ei_data      => l_pos_ei_data);


  l_expire_date   := l_pos_ei_data.POEI_INFORMATION3;
  l_obligate_type := l_pos_ei_data.POEI_INFORMATION4;
  if (l_expire_date IS NULL
   --   OR to_date(l_expire_date,'DD-MON-YYYY') >=  p_date )
      OR fnd_date.canonical_to_date(l_expire_date) >= p_date )
     and NVL(l_obligate_type,'U') <> 'U' then
   l_chk_position_obligated :=true;
  else
    l_chk_position_obligated :=false;
  end if;

  return l_chk_position_obligated;

end chk_position_obligated;

FUNCTION opm_mandated_duty_stations
        (p_duty_station_code  in ghr_duty_stations_f.duty_station_code%TYPE)
  RETURN BOOLEAN IS
l_ret_val boolean := FALSE;
l_duty_station_code  ghr_duty_stations_f.duty_station_code%TYPE;
BEGIN
   l_duty_station_code := p_duty_station_code;
   if l_duty_station_code in
       ('040355019', '060920071', '181788003', '181789003', '195549095',
        '204891103', '211257115', '211758081', '211758187', '213397003',
        '220376047', '222431059', '240414031', '240931047', '241371003',
        '265260085', '296675179', '330043017', '343478025', '398961099',
        '421172125', '424275109', '424676109', '471348157',
        '484208013', '484209153', '485936303', '511566069', '530171061',
        '530533025', '541475079', '542325035', '542334035', '542857045',
        'UV0000000', 'CF0000000', 'CG0000000', 'PS0000000', 'TC0000000',
        'TC1000000', 'TC1030000', 'TC1040000', 'TC1050000', 'TC1200000',
        'TC1300000', 'TC1500000', 'WS0000000', '422760045')
      then
     l_ret_val := TRUE;
     hr_utility.set_location('duty station code is OPM Mandated change ' ,20);
   else
     l_ret_val := FALSE;
     hr_utility.set_location('duty station code is not OPM Mandated change ' ,20);
   end if;

  return l_ret_val;
END opm_mandated_duty_stations;

PROCEDURE duty_station_warn (p_first_noa_id   IN NUMBER
                            ,p_second_noa_id  IN NUMBER
                            ,p_person_id      IN NUMBER
                            ,p_form_ds_code   IN ghr_duty_stations_f.duty_station_code%TYPE
                            ,p_effective_date IN DATE
                            ,p_message_set    OUT NOCOPY BOOLEAN) IS

l_proc               varchar2(30) := 'duty_station_warn';

l_noa_family_code    ghr_families.noa_family_code%TYPE;
l_location_id        hr_locations.location_id%TYPE;
l_duty_station_id    VARCHAR2(150);
l_duty_station_code  ghr_duty_stations_f.duty_station_code%TYPE;
l_duty_station_desc  VARCHAR2(200);
l_exists             BOOLEAN  := FALSE;
l_message_set        BOOLEAN  := FALSE;
duty_sta_exp         EXCEPTION;

cursor   cur_loc is
select paf.location_id  location_id
from per_assignments_f           paf,
     per_assignment_status_types ast
where paf.person_id            = p_person_id
and   p_effective_date
      between paf.effective_start_date and paf.effective_end_date
and   ast.assignment_status_type_id = paf.assignment_status_type_id
and   ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN','TERM_ASSIGN');

cursor   cur_asg is
select 1 from per_assignments_f
Where person_id            = p_person_id
and   effective_start_date = to_date('19'||'99/01/01','YYYY/MM/DD');


BEGIN
  hr_utility.set_location('Entering ...' || l_proc,5);

  l_location_id     := null;
  l_noa_family_code := ghr_pa_requests_pkg.get_noa_pm_family(p_first_noa_id);

  for cur_loc_rec in cur_loc
  loop
      l_location_id := cur_loc_rec.location_id;
  end loop;

  IF  l_noa_family_code = 'CORRECT' then
      l_noa_family_code := ghr_pa_requests_pkg.get_noa_pm_family(p_second_noa_id);
  END IF;

      hr_utility.set_location('Location_id     ...' || l_location_id,10);
      hr_utility.set_location('noa_family_code ...' || l_noa_family_code,10);
      hr_utility.set_location('form ds code    ...' || p_form_ds_code,10);
  IF l_noa_family_code in
                 ('APP','CHG_DUTY_STATION','CONV_APP','POS_CHG','POS_ESTABLISH',
                  'REALIGNMENT','REASSIGNMENT','RECRUIT_FILL',
                  'RETURN_TO_DUTY','SALARY_CHG') then
     for cur_asg_rec in cur_asg
     loop
         l_exists := TRUE;
     end loop;
     if l_location_id is not null then
        ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                   (p_location_id      => l_location_id
                   ,p_duty_station_id  => l_duty_station_id);

         hr_utility.set_location('duty station id ...' || l_duty_station_id,15);

        ghr_pa_requests_pkg.get_duty_station_details
                  (p_duty_station_id   => l_duty_station_id
                  ,p_effective_date    => p_effective_date
                  ,p_duty_station_code => l_duty_station_code
                  ,p_duty_station_desc => l_duty_station_desc);

         hr_utility.set_location('duty station code..' || l_duty_station_code,20);
     else
         l_duty_station_code := null;
         hr_utility.set_location('duty station code..is null ' ,20);
     end if;

     if p_effective_date < to_date('19'||'99/01/01','YYYY/MM/DD') then
        if nvl(p_form_ds_code, '123456789') <> nvl(l_duty_station_code, '123456789') then
           if l_exists then
              if l_noa_family_code in
                 ('CHG_DUTY_STATION','CONV_APP','POS_CHG','POS_ESTABLISH',
                  'REALIGNMENT','REASSIGNMENT','RECRUIT_FILL',
                  'RETURN_TO_DUTY','SALARY_CHG')  then
                  hr_utility.set_location('GHR_38147_NOAC_RPA_900' ,25);
                  hr_utility.set_message(8301,'GHR_38147_NOAC_RPA_900');
                  raise duty_sta_exp;
              else
                 if l_noa_family_code = 'APP' then
                    if opm_mandated_duty_stations(p_form_ds_code) then
                       hr_utility.set_location('GHR_38148_RERUN_DUTYSTN_CONV' ,25);
                       hr_utility.set_message(8301,'GHR_38148_RERUN_DUTYSTN_CONV');
                       raise duty_sta_exp;
                    end if;
                 end if;
              end if;
           else
              if l_noa_family_code in
                 ('CHG_DUTY_STATION','CONV_APP','POS_CHG','POS_ESTABLISH',
                  'REALIGNMENT','REASSIGNMENT','RECRUIT_FILL',
                  'RETURN_TO_DUTY','SALARY_CHG')  then
                    if opm_mandated_duty_stations(p_form_ds_code) then
                       hr_utility.set_location('GHR_38148_RERUN_DUTYSTN_CONV' ,25);
                       hr_utility.set_message(8301,'GHR_38148_RERUN_DUTYSTN_CONV');
                       raise duty_sta_exp;
                    end if;
              else
                 if l_noa_family_code = 'APP' then
                    if opm_mandated_duty_stations(p_form_ds_code) then
                       hr_utility.set_location('GHR_38149_RERUN_CHECK_DUTYSTN' ,25);
                       hr_utility.set_message(8301,'GHR_38149_RERUN_CHECK_DUTYSTN');
                       raise duty_sta_exp;
                    end if;
                 end if;
              end if;
           end if;
        else
              if l_noa_family_code in
                 ('CHG_DUTY_STATION','CONV_APP','POS_CHG','POS_ESTABLISH',
                  'REALIGNMENT','REASSIGNMENT','RECRUIT_FILL',
                  'RETURN_TO_DUTY','SALARY_CHG')  then
                 if l_exists then
                    hr_utility.set_location('GHR_38147_NOAC_RPA_900' ,25);
                    hr_utility.set_message(8301,'GHR_38147_NOAC_RPA_900');
                    raise duty_sta_exp;
                 else
                    if opm_mandated_duty_stations(p_form_ds_code) then
                       hr_utility.set_location('GHR_38148_RERUN_DUTYSTN_CONV' ,25);
                       hr_utility.set_message(8301,'GHR_38148_RERUN_DUTYSTN_CONV');
                       raise duty_sta_exp;
                    end if;
                 end if;
              end if;

        end if;
     end if;
  END IF;
  hr_utility.set_location('Leaving ...' || l_proc,30);
           p_message_set := l_message_set;
 exception when duty_sta_exp then
           l_message_set := TRUE;
           p_message_set := l_message_set;
 END duty_station_warn;

--

FUNCTION get_corr_cop (p_altered_pa_request_id
                           IN ghr_pa_requests.altered_pa_request_id%type)
RETURN NUMBER IS

cursor cur_other is
select EMPLOYEE_ASSIGNMENT_ID,
       EFFECTIVE_DATE
from ghr_pa_requests
where pa_request_id = p_altered_pa_request_id;

l_assignment_id       NUMBER(15);
l_effective_date      DATE;
l_multiple_error_flag BOOLEAN;
l_capped_other_pay    NUMBER;
begin

for cur_other_rec in cur_other
loop
  l_assignment_id                   := cur_other_rec.employee_assignment_id;
  l_effective_date                  := cur_other_rec.effective_date;
end loop;

      ghr_api.retrieve_element_entry_value
                     (p_element_name        => 'Other Pay'
                     ,p_input_value_name    => 'Capped Other Pay'
                     ,p_assignment_id       => l_assignment_id
                     ,p_effective_date      => l_effective_date
                     ,p_value               => l_capped_other_pay
                     ,p_multiple_error_flag => l_multiple_error_flag);


RETURN (l_capped_other_pay);

END get_corr_cop;

FUNCTION get_cop ( p_assignment_id  IN per_assignments_f.assignment_id%type
                  ,p_effective_date IN date)

RETURN NUMBER IS
l_capped_other_pay    NUMBER;
l_multiple_error_flag BOOLEAN;
begin


      ghr_api.retrieve_element_entry_value
                     (p_element_name        => 'Other Pay'
                     ,p_input_value_name    => 'Capped Other Pay'
                     ,p_assignment_id       => p_assignment_id
                     ,p_effective_date      => nvl(p_effective_date,trunc(sysdate))
                     ,p_value               => l_capped_other_pay
                     ,p_multiple_error_flag => l_multiple_error_flag);

RETURN (l_capped_other_pay);

END get_cop;


--
PROCEDURE chk_position_end_date (p_position_id   IN NUMBER
                            ,p_business_group_id IN NUMBER
                            ,p_effective_date IN DATE
                            ,p_message_set    OUT NOCOPY BOOLEAN) IS

l_proc               varchar2(30) := 'chk_position_end_date';

l_effective_start_date date;
l_effective_end_date   date;
l_status               VARCHAR2(30);
l_message_set          BOOLEAN  := FALSE;

cursor   cur_pos is
select pos.effective_start_date,pos.effective_end_date,typ.system_type_cd status
from hr_all_positions_f pos, per_shared_types typ
where p_effective_date
      between pos.effective_start_date and pos.effective_end_date
and   pos.business_group_id = p_business_group_id
and   pos.position_id = p_position_id
and   pos.availability_status_id = typ.shared_type_id
union
select pos1.effective_start_date,pos1.effective_end_date,typ1.system_type_cd status
from hr_all_positions_f pos1, per_shared_types typ1
where p_effective_date <= pos1.effective_start_date
and   pos1.business_group_id = p_business_group_id
and   pos1.position_id = p_position_id
and   pos1.availability_status_id = typ1.shared_type_id
order by 1;

BEGIN
  hr_utility.set_location('Entering ...' || l_proc,5);

  for cur_pos_rec in cur_pos
  loop
      l_effective_start_date := cur_pos_rec.effective_start_date;
      l_effective_end_date   := cur_pos_rec.effective_end_date;
      l_status               := cur_pos_rec.status;

      if l_effective_end_date = to_date('4712/12/31','YYYY/MM/DD') then
         if l_status = 'ACTIVE' then
            p_message_set := l_message_set;
         else
            l_message_set := TRUE;
            p_message_set := l_message_set;
         end if;
      else
         if l_status = 'ACTIVE' then
            p_message_set := l_message_set;
         else
            l_message_set := TRUE;
            p_message_set := l_message_set;
         end if;
     end if;
  end loop;
  p_message_set := l_message_set;

  hr_utility.set_location('Leaving ...' || l_proc,30);

EXCEPTION
  WHEN OTHERS THEN
	p_message_set := NULL;

END chk_position_end_date;


--
PROCEDURE chk_position_hire_status (p_position_id   IN NUMBER
                            ,p_business_group_id IN NUMBER
                            ,p_effective_date IN DATE
                            ,p_message_set    OUT NOCOPY BOOLEAN) IS

l_proc               varchar2(30) := 'chk_position_hire_status';

l_effective_start_date date;
l_effective_end_date   date;
l_status               VARCHAR2(30);
l_message_set          BOOLEAN  := FALSE;

cursor   cur_pos is
select effective_start_date,effective_end_date,system_type_cd status
from hr_all_positions_f pos, per_shared_types typ
where p_effective_date
      between effective_start_date and effective_end_date
and   position_id = p_position_id
and   pos.business_group_id = p_business_group_id
and   pos.availability_status_id = typ.shared_type_id
order by 1;

BEGIN
  hr_utility.set_location('Entering ...' || l_proc,5);

  for cur_pos_rec in cur_pos
  loop
      l_effective_start_date := cur_pos_rec.effective_start_date;
      l_effective_end_date   := cur_pos_rec.effective_end_date;
      l_status               := cur_pos_rec.status;

         if l_status in ('FROZEN','PROPOSED') then
            l_message_set := TRUE;
            p_message_set := l_message_set;
         end if;

  end loop;
            p_message_set := l_message_set;

  hr_utility.set_location('Leaving ...' || l_proc,30);
EXCEPTION
  WHEN OTHERS THEN
	p_message_set := NULL;
END chk_position_hire_status;
  --
  -- This function is to display a warning message while processing 850 action
  -- whenever the sum of individual components versus the total value of mddds pay is
  -- having difference.
  --
  FUNCTION check_mddds_pay (p_pa_request_id IN NUMBER)
  RETURN BOOLEAN IS
--
CURSOR c_par_mddds IS
select (nvl(REI_INFORMATION9,0)  +
        nvl(REI_INFORMATION10,0) +
        nvl(REI_INFORMATION3,0)  +
        nvl(REI_INFORMATION4,0)  +
        nvl(REI_INFORMATION5,0)  +
        nvl(REI_INFORMATION6,0)  +
        nvl(REI_INFORMATION7,0)  +
        nvl(REI_INFORMATION8,0))  cal_amt,
        nvl(REI_INFORMATION11,0)  tot_amt
from ghr_pa_request_extra_info
where pa_request_id = p_pa_request_id
and information_type = 'GHR_US_PAR_MD_DDS_PAY';

BEGIN
  -- get the sum of all components values and the total value.
  FOR c_par_rec IN c_par_mddds LOOP
    IF c_par_rec.cal_amt <> c_par_rec.tot_amt THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;
  END LOOP;

  RETURN(FALSE);
  --
END check_mddds_pay;
  --
  --
END ghr_pa_requests_pkg2;

/
