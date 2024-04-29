--------------------------------------------------------
--  DDL for Package Body GHR_MTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MTO_PKG" AS
/* $Header: ghmtoexe.pkb 120.1.12010000.3 2009/04/22 06:29:13 vmididho ship $ */

--
-- Global Declaration
--

g_no number := 0;
g_package  varchar2(32) := 'GHR_MTO_PKG';
g_proc     varchar2(32) := null;

l_log_text varchar2(2000) := null;
l_mass_errbuf   varchar2(2000) := null;



Procedure update_position_info
     (p_position_data_rec in ghr_sf52_pos_update.position_data_rec_type);

Procedure upd_per_extra_info_to_null(p_person_id in number) ;

-- Procedure to create remarks M67 Test Sundar 1295


PROCEDURE create_lac_remarks
            (p_pa_request_id  IN ghr_pa_requests.pa_request_id%type,
             p_new_pa_request_id  IN ghr_pa_requests.pa_request_id%type,
			 p_effective_date IN ghr_pa_requests.effective_date%type,
			 p_pa_request_rec IN ghr_pa_requests%rowtype) is

l_proc VARCHAR2(72) :=  g_package || '.create_lac_remarks';

CURSOR cur_pa_rem_cur is
SELECT * FROM ghr_pa_remarks
 WHERE pa_request_id = p_pa_request_id;

CURSOR cur_rem_code(c_effective_date ghr_pa_requests.effective_date%type) IS
SELECT  remark_id
FROM   ghr_remarks
WHERE code  =  'M67'
AND  enabled_flag = 'Y'
AND  nvl(c_effective_date,trunc(sysdate))
BETWEEN  date_from AND nvl(date_to,nvl(c_effective_date, trunc(sysdate)));

l_remarks_rec     ghr_pa_remarks%rowtype;
l_remark_id ghr_pa_remarks.remark_id%type;

BEGIN
  g_proc  := 'create_lac_remarks';
  hr_utility.set_location('Entering    ' || l_proc,5);

  pr('Inside '||l_proc,to_char(p_pa_request_id),to_char(p_new_pa_request_id));
	--hr_utility.trace_on(null,'sundar');
	FOR l_rem_code IN cur_rem_code(p_effective_date) LOOP
	   l_remark_id := l_rem_code.remark_id;
	END LOOP;

    FOR CUR_PA_REM_rec IN cur_pa_rem_cur
    LOOP

      l_remarks_rec := cur_pa_rem_rec;
	  -- If the remarks is M67, Then need to populate the address lines
	  hr_utility.set_location('Remark id ' || l_remarks_rec.remark_id,10);
	  hr_utility.set_location('Remark id ' || l_remark_id,10);
	  IF (l_remarks_rec.remark_id = l_remark_id) THEN

			IF p_pa_request_rec.forwarding_address_line1 IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := p_pa_request_rec.forwarding_address_line1;
			END IF;
			--hr_utility.set_location('1.l_remark_code_information1' || l_remark_code_information1,10);

			IF p_pa_request_rec.forwarding_address_line2 IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_address_line2;
			END IF;
			--hr_utility.set_location('2.l_remark_code_information1' || l_remark_code_information1,11);

			IF p_pa_request_rec.forwarding_address_line3 IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_address_line3;
			END IF;
			--hr_utility.set_location('3.l_remark_code_information1' || l_remark_code_information1,12);

			IF p_pa_request_rec.forwarding_town_or_city IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_town_or_city;
			END IF;
			--hr_utility.set_location('4.l_remark_code_information1' || l_remark_code_information1,13);

			IF p_pa_request_rec.forwarding_region_2 IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_region_2;
			END IF;
			--hr_utility.set_location('5.l_remark_code_information1' || l_remark_code_information1,14);

			IF p_pa_request_rec.forwarding_postal_code IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_postal_code;
			END IF;
			--hr_utility.set_location('6.l_remark_code_information1' || l_remark_code_information1,15);

			IF p_pa_request_rec.forwarding_country IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_country;
			END IF;
			--hr_utility.set_location('7.l_remark_code_information1' || l_remark_code_information1,16);

			IF p_pa_request_rec.forwarding_country_short_name IS NOT NULL THEN
				l_remarks_rec.remark_code_information1 := l_remarks_rec.remark_code_information1 || ', ' || p_pa_request_rec.forwarding_country_short_name;
			END IF;
			--hr_utility.set_location('8.l_remark_code_information1' || l_remark_code_information1,17);

			l_remarks_rec.remark_code_information2              :=  Null;
			l_remarks_rec.remark_code_information3              :=  Null;
			l_remarks_rec.remark_code_information4              :=  Null;
			l_remarks_rec.remark_code_information5              :=  Null;
			l_remarks_rec.description := 'Forwarding address: ' || l_remarks_rec.remark_code_information1;
			hr_utility.set_location('description ' || l_remarks_rec.description,10);
	  END IF;
	hr_utility.set_location('l_remarks_rec.object_version_number ' ||l_remarks_rec.object_version_number,10);
	pr('Rem id '||to_char(l_remarks_rec.remark_id));
    ghr_pa_remarks_api.create_pa_remarks
    (p_validate                 => false
    ,p_pa_request_id            => p_new_pa_request_id
    ,p_remark_id                => l_remarks_rec.remark_id
    ,p_description              => l_remarks_rec.description
    ,p_remark_code_information1 => l_remarks_rec.remark_code_information1
    ,p_remark_code_information2 => l_remarks_rec.remark_code_information2
    ,p_remark_code_information3 => l_remarks_rec.remark_code_information3
    ,p_remark_code_information4 => l_remarks_rec.remark_code_information4
    ,p_remark_code_information5 => l_remarks_rec.remark_code_information5
    ,p_pa_remark_id             => l_remarks_rec.pa_remark_id
    ,p_object_version_number    => l_remarks_rec.object_version_number
    );

  END LOOP;
	--hr_utility.trace_off;
  hr_utility.set_location('Exiting    ' || l_proc,10);

EXCEPTION
  WHEN OTHERS THEN
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm;
     raise mass_error;
END create_lac_remarks;

--
-- End Global declaration
--

procedure execute_mto (p_errbuf out NOCOPY varchar2,
                       p_retcode out NOCOPY number,
                       p_mass_transfer_id in number,
                       p_action in varchar2,
                       p_show_vacant_pos in varchar2 default 'NO') is

cursor child_orgs(cp_orgid      number,
                  child_fl      varchar2,
                  org_pos_fl    varchar2,
                  org_str_id    number) is
select a.organization_id_child      org_pos_id
from   per_org_structure_elements a,
       per_org_structure_versions b
where  a.org_structure_version_id = b.org_structure_version_id
and    a.org_structure_version_id = org_str_id
and    child_fl                   = 'Y'
and    org_pos_fl                 = 'O'
and    a.org_structure_element_id in
(
select  org_structure_element_id
from    per_org_structure_elements
-- VSM added nvl( .. to the start... clause
-- enhancement in selection criteria as org_id can be be null [Masscrit.doc]
start   with organization_id_parent    = cp_orgid
connect by prior organization_id_child = organization_id_parent
)
union
select b.ORGANIZATION_ID    org_pos_id
from   per_organization_units b
-- VSM added nvl( .. to the start... clause
-- enhancement in selection criteria as org_id can be be null [Masscrit.doc]
where  b.organization_id = nvl(cp_orgid, b.organization_id)
and    org_pos_fl        = 'O'
union
select a.subordinate_position_id      org_pos_id
from   per_pos_structure_elements a,
       per_pos_structure_versions b
where  a.pos_structure_version_id = b.pos_structure_version_id
and    a.pos_structure_version_id = org_str_id
and    child_fl                   = 'Y'
and    org_pos_fl                 = 'P'
and    a.pos_structure_element_id in
(
select  pos_structure_element_id
from    per_pos_structure_elements
start   with parent_position_id    = cp_orgid
connect by prior subordinate_position_id = parent_position_id
)
union
select b.position_id    org_pos_id
from   hr_positions_f b
where  b.position_id     = cp_orgid
and    org_pos_fl        = 'P';

/*  and child_fl = 'N';*/

-- Bug 4377361 included EMP_APL for person type condition
cursor cur_people (p_org_id       number,
                   org_pos_fl     varchar2,
                   effective_date date) is
select ppf.person_id    PERSON_ID,
       ppf.first_name   FIRST_NAME,
       ppf.last_name    LAST_NAME,
       ppf.middle_names MIDDLE_NAMES,
       ppf.full_name    FULL_NAME,
       ppf.date_of_birth DATE_OF_BIRTH,
       ppf.national_identifier NATIONAL_IDENTIFIER,
       paf.position_id  POSITION_ID,
       paf.assignment_id ASSIGNMENT_ID,
       paf.grade_id     GRADE_ID,
       paf.job_id       JOB_ID,
       paf.location_id  LOCATION_ID,
       paf.organization_id ORGANIZATION_ID,
       paf.business_group_id BUSINESS_GROUP_ID,
       punits.name        ORGANIZATION_NAME
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       per_organization_units punits
-- VSM added nvl( .. to the start... clause
-- enhancement in selection criteria as org_id can be be null [Masscrit.doc]
 where (paf.organization_id = nvl(p_org_id, paf.organization_id)
       and
       org_pos_fl = 'O')
   and ppf.person_id = paf.person_id
   and trunc(effective_date) between paf.effective_start_date
           and paf.effective_end_date
   and paf.primary_flag = 'Y'
   and paf.assignment_type <> 'B'
   and ppf.current_employee_flag = 'Y'
   and trunc(effective_date) between ppf.effective_start_date
           and ppf.effective_end_date
   and ppf.person_type_id = ppt.person_type_id
   and ppt.system_person_type IN ('EMP','EMP_APL')
   and paf.organization_id = punits.organization_id
   and paf.position_id is not null
union
select ppf.person_id    PERSON_ID,
       ppf.first_name   FIRST_NAME,
       ppf.last_name    LAST_NAME,
       ppf.middle_names MIDDLE_NAMES,
       ppf.full_name    FULL_NAME,
       ppf.date_of_birth DATE_OF_BIRTH,
       ppf.national_identifier NATIONAL_IDENTIFIER,
       paf.position_id  POSITION_ID,
       paf.assignment_id ASSIGNMENT_ID,
       paf.grade_id     GRADE_ID,
       paf.job_id       JOB_ID,
       paf.location_id  LOCATION_ID,
       paf.organization_id ORGANIZATION_ID,
       paf.business_group_id BUSINESS_GROUP_ID,
       punits.name        ORGANIZATION_NAME
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       per_organization_units punits
 where (paf.position_id = nvl(p_org_id,paf.position_id)
       and
       org_pos_fl = 'P')
   and ppf.person_id = paf.person_id
   and trunc(effective_date) between paf.effective_start_date
           and paf.effective_end_date
   and paf.primary_flag = 'Y'
   and paf.assignment_type <> 'B'
   and ppf.current_employee_flag = 'Y'
   and trunc(effective_date) between ppf.effective_start_date
           and ppf.effective_end_date
   and ppf.person_type_id = ppt.person_type_id
   and ppt.system_person_type IN ('EMP','EMP_APL')
   and paf.organization_id = punits.organization_id
   and paf.position_id is not null;

cursor unassigned_pos (p_org_id       number,
                       org_pos_fl     varchar2,
                       effective_date date) is
select null PERSON_ID,
       'VACANT' FIRST_NAME,
       'VACANT' LAST_NAME,
       'VACANT' FULL_NAME,
       null     MIDDLE_NAMES,
       null     DATE_OF_BIRTH,
       null     NATIONAL_IDENTIFIER,
       position_id POSITION_ID,
       null     ASSIGNMENT_ID,
       to_number(null)     GRADE_ID,
       JOB_ID,
       pop.LOCATION_ID,
       pop.ORGANIZATION_ID,
       pop.BUSINESS_GROUP_ID,
       punits.name        ORGANIZATION_NAME,
       pop.availability_status_id
  from hr_positions_f pop,
       per_organization_units punits
 where pop.position_id in
 (
	select position_id POSITION_ID
	from   hr_positions_f
	where  (organization_id = nvl(p_org_id,organization_id) and org_pos_fl = 'O'
	       or  position_id     = nvl(p_org_id,position_id) and org_pos_fl = 'P')
	and trunc(effective_date) between
		effective_start_date and effective_end_date
      MINUS
	select a.position_id
	from   per_people_f p, per_assignments_f a
	where  (a.organization_id = nvl(p_org_id,organization_id) and org_pos_fl = 'O'
	       or a.position_id   = nvl(p_org_id,position_id) and org_pos_fl = 'P')
	and trunc(effective_date) between a.effective_start_date
		and a.effective_end_date
	and a.primary_flag = 'Y'
	and a.assignment_type <> 'B'
	and p.current_employee_flag = 'Y'
	and p.person_id		=a.person_id
	and a.position_id	= pop.position_id
	and trunc(effective_date) between p.effective_start_date
		        and p.effective_end_date
)
and trunc(effective_date)
    between pop.effective_start_date and pop.effective_end_date
and pop.organization_id = punits.organization_id;
-- added Join for tables a,p. a.person_id=p.person_id and a.position_id=pop.position_id
-- Bug 3804526

cursor c_grade_kff (grd_id number) is
        select gdf.segment1
              ,gdf.segment2
          from per_grades grd,
               per_grade_definitions gdf
         where grd.grade_id = grd_id
           and grd.grade_definition_id = gdf.grade_definition_id;

cursor ghr_mto (p_mass_transfer_id number) is
select name, effective_date, old_organization_id,
       OLD_ORG_STRUCTURE_VERSION_ID, status,
       reason, org_structure_id, office_symbol,
       AGENCY_CODE_SUBELEMENT,
       PERSONNEL_OFFICE_ID, duty_station_code,duty_station_id,
       old_position_id,
       old_pos_structure_version_id,
       TO_AGENCY_CODE_SUBELEMENT,
       NVL(INTERFACE_FLAG,'N') INTERFACE_FLAG,
       PA_REQUEST_ID
  from ghr_mass_transfers
 where mass_transfer_id = p_mass_transfer_id
   and TRANSFER_TYPE    = 'OUT'
   for update of status nowait;

----- Added cursor by AVR
CURSOR PA_REQ_EXT_INFO_CUR (p_pa_request_id number) is
SELECT PA_REQUEST_EXTRA_INFO_ID,
       OBJECT_VERSION_NUMBER
  FROM GHR_PA_REQUEST_EXTRA_INFO
 WHERE INFORMATION_TYPE  = 'GHR_US_PAR_MASS_TERM'
   and pa_request_id = p_pa_request_id;



l_PA_REQUEST_EXTRA_INFO_ID   number;
l_pa_OBJECT_VERSION_NUMBER   number;
l_dummy                      varchar2(35);
l_agency_code                ghr_pa_requests.agency_code%type;
--------

l_assignment_id        per_assignments_f.assignment_id%type;
l_position_id          per_assignments_f.position_id%type;
l_grade_id             per_assignments_f.grade_id%type;
--l_grade_id             number;

l_business_group_id    per_assignments_f.business_group_id%type;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      varchar2(20);

l_mass_cnt              number := 0;
l_recs_failed          number := 0;

l_tenure               varchar2(35);
l_annuitant_indicator  varchar2(35);
l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);
l_part_time_hour       varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_grade_or_level       varchar2(30);
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
l_location_id          number;
l_duty_station_id      number;
l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
l_duty_station_code    ghr_pa_requests.duty_station_code%type;

l_check_child          varchar2(2);
l_check_org_pos             varchar2(2);
l_org_pos_id                number;
l_org_pos_str_id            number;

l_effective_date       date;
r_effective_date       date;
p_mass_transfer_name varchar2(80);
p_organization_id  number;
p_org_hierarchy_id  number;
p_position_id  number;
p_pos_hierarchy_id  number;
p_interface_flag  varchar2(1);
l_pa_request_id             number;

p_status               varchar2(1);
p_reason               varchar2(240);
p_org_structure_id     varchar2(30);
p_office_symbol        varchar2(30);
p_agency_sub_elem_code varchar2(30);
p_to_agency_code       varchar2(30);
p_personnel_office_id  varchar2(30);
p_duty_station_id      number(15);
p_duty_station_code    varchar2(10);
p_position_title       varchar2(240);
p_pay_plan	       varchar2(2);
p_occ_code             varchar2(9);

l_personnel_office_id  varchar2(300);
l_org_structure_id     varchar2(300);
l_office_symbol        varchar2(30);
l_occ_series           varchar2(30);
l_sub_element_code     varchar2(300);

l_payroll_office_id   varchar2(30);
l_org_func_code       varchar2(30);
l_appropriation_code1 varchar2(30);
l_appropriation_code2 varchar2(30);
l_position_organization varchar2(240);

t_personnel_office_id  varchar2(300);
t_sub_element_code     varchar2(300);
t_duty_station_id      number(15);
t_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
t_duty_station_code    ghr_pa_requests.duty_station_code%type;
t_office_symbol        varchar2(30);
t_payroll_office_id   varchar2(30);
t_org_func_code       varchar2(30);
t_appropriation_code1 varchar2(30);
t_appropriation_code2 varchar2(30);
t_position_organization varchar2(240);

l_auo_premium_pay_indicator varchar2(30);
l_ap_premium_pay_indicator  varchar2(30);
l_retention_allowance       number;
l_supervisory_differential  number;
l_staffing_differential     number;

l_out_step_or_rate          varchar2(30);
l_out_pay_rate_determinant  varchar2(30);
l_PT_eff_start_date         date;
l_open_pay_fields           boolean;
l_message_set               boolean;
l_calculated                boolean;

l_user_table_id             number;
l_executive_order_no        varchar2(30);
l_executive_order_date      date;

l_row_cnt                   number := 0;

l_sf52_rec                  ghr_pa_requests%rowtype;
l_lac_sf52_rec              ghr_pa_requests%rowtype;
l_errbuf                    varchar2(2000);

l_retcode                   number;

l_pos_ei_data               per_position_extra_info%rowtype;
l_pos_grp1_rec              per_position_extra_info%rowtype;
l_pos_grp2_rec              per_position_extra_info%rowtype;

l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
l_sel_flg                   varchar2(2);
l_sel_status                varchar2(32);

l_first_action_la_code1     varchar2(30);
l_first_action_la_code2     varchar2(30);

l_remark_code1              varchar2(30);
l_remark_code2              varchar2(30);
l_avail_status_id           hr_positions_f.availability_status_id%type;
--

REC_BUSY                    exception;
pragma exception_init(REC_BUSY,-54);

l_proc                      varchar2(72)
          :=  g_package || '.execute_mto';
l_ind number := 0;
l_break                     varchar2(1) := 'N';

--7533027
l_pos_ei_grade_data   	    per_position_extra_info%rowtype;
--7533027

BEGIN
  p_retcode  := 0;
  g_proc := 'execute_mto';
  --hr_utility.trace_on(null,'sundar');
  pr('Inside execute mto');
  pr('Mass Transfer id is '||p_mass_transfer_id,' Action is '|| p_action);
  hr_utility.set_location('Entering    ' || l_proc,5);
l_ind := 10;
  pr('Before set log');
  --ghr_mto_int.set_log_program_name('Mass Transfer OUT');
  pr('After set log');

  BEGIN
    FOR mto IN ghr_mto (p_mass_transfer_id)
    LOOP
        p_mass_transfer_name := mto.name;
        l_effective_date := mto.effective_date;
        p_organization_id := mto.old_organization_id;
        p_org_hierarchy_id := mto.OLD_ORG_STRUCTURE_VERSION_ID;
        p_status              := mto.status;
        p_reason              := mto.reason;
        p_org_structure_id    := mto.org_structure_id;
        p_office_symbol       := mto.office_symbol;
        p_agency_sub_elem_code:= mto.AGENCY_CODE_SUBELEMENT;
        p_personnel_office_id := mto.PERSONNEL_OFFICE_ID;
        p_duty_station_code   := mto.duty_station_code;
        --p_position_title    := mto.position_title;
        p_duty_station_id     := mto.duty_station_id;
        p_to_agency_code      := mto.TO_AGENCY_CODE_SUBELEMENT;
        p_position_id         := mto.old_position_id;
        p_pos_hierarchy_id    := mto.old_pos_structure_version_id;
        p_interface_flag      := mto.interface_flag;
        l_pa_request_id       := mto.pa_request_id;

       exit;
    END LOOP;

  EXCEPTION
    when REC_BUSY then
        hr_utility.set_location('Mass Transfer is in use',1);
        l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MTO');
        hr_utility.raise_error;
    when others then
        hr_utility.set_location('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
        l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        raise mass_error;
  END;

  IF upper(p_action) = 'CREATE' then
     ghr_mto_int.set_log_program_name('GHR_MTO_PKG');
  ELSE
     ghr_mto_int.set_log_program_name('MTO_'||p_mass_transfer_name);
  END IF;

  IF upper(p_action) = 'CREATE' then
    if l_pa_request_id is null then
       hr_utility.set_message(8301, 'GHR_38567_SELECT_LAC_REMARKS');
       hr_utility.raise_error;
    END IF;
  END IF;

  ghr_msl_pkg.get_lac_dtls(l_pa_request_id,
                           l_lac_sf52_rec);

  if upper(p_action) = 'CREATE'
        /* and p_interface_flag = 'N' */ then

      DECLARE
        l_loc_errbuf varchar2(2000);
        l_loc_retcode number;
      BEGIN
               --- Call dump out to make sure its interfaced
           pr('Before ghr_mto_pkg.execute mto for dump out');

           ghr_mto_pkg.execute_mto (l_loc_errbuf,
                                    l_loc_retcode,
                                    p_mass_transfer_id,
                                    'DUMP OUT');
           pr('After execute mto - for dump out Error is ',l_loc_errbuf);

           if l_loc_errbuf is not null then
                l_mass_errbuf := 'DUMP OUT Failed '||l_loc_errbuf;
                raise mass_error;
           else
               pr('No error in execute mto dump out ');
                commit;
                begin
                   FOR mto IN ghr_mto (p_mass_transfer_id)
                   LOOP
                       p_mass_transfer_name := mto.name;
                       p_interface_flag      := mto.interface_flag;
                      exit;
                   END LOOP;
                EXCEPTION
                   when REC_BUSY then
                       hr_utility.set_location('Mass Transfer is in use',1);
                       l_mass_errbuf := 'Error in '||l_proc||
                              ' This Mass Trasnfer is in use';
                       hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MTO');
                       hr_utility.raise_error;
                   when others then
                       hr_utility.set_location('Error in '||l_proc||
                              ' at select from mass tfr'||
                              ' Sql err is '||sqlerrm(sqlcode),1);
                       l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '||
                              sqlerrm(sqlcode);
                       raise mass_error;
                END;
           END IF;
      EXCEPTION
         when mass_error then raise;
         when others then
                hr_utility.set_location('Error in '||l_proc||
                              ' Sql err is '||sqlerrm(sqlcode),1);
                l_mass_errbuf := 'Error in '||l_proc||' at call for dump proc'||
                              '  Sql Err is '|| sqlerrm(sqlcode);
                raise mass_error;
      END;

      if p_interface_flag = 'N' then
          l_mass_errbuf := 'Interface has failed already - Cannot process';
          raise mass_error;
      end if;

  END IF; ---- End if for /*interface flag = 'N' and */ ACTION = 'CREATE'


l_ind := 20;
  --purge_old_data(p_mass_transfer_id);

l_ind := 30;
  hr_utility.set_location('After fetch mto '||to_char(l_effective_date),1);
  pr('After sel mass transfers',to_char(l_effective_date));

 if p_position_id is not null then
    l_check_org_pos  := 'P';
    l_org_pos_id     := p_position_id;
    l_org_pos_str_id := p_pos_hierarchy_id;
    if p_pos_hierarchy_id is null then
        l_check_child := 'N';
    else
        l_check_child := 'Y';
    end if;
 else
-- VSM [Enhancement Masscrit.doc]
-- if neither Org nor Position is entered then system will fetch records for all the organization
    --if p_organization_id is not null then
    l_check_org_pos  := 'O';
    l_org_pos_id     := p_organization_id;
    l_org_pos_str_id := p_org_hierarchy_id;
    if p_organization_id is null then
       l_break := 'Y';
    end if;
    if p_org_hierarchy_id is null then
        l_check_child := 'N';
    else
        l_check_child := 'Y';
    end if;
 end if;

    pr('Org id ',to_char(p_organization_id));
    pr('Org hier id',to_char(p_org_hierarchy_id));

    FOR org in child_orgs (l_org_pos_id,
                           l_check_child,
                           l_check_org_pos,
                           l_org_pos_str_id)
    LOOP
       if upper(p_action) = 'REPORT' and p_status = 'P' THEN
           r_effective_date := l_effective_date - 1;
       else
           r_effective_date := l_effective_date;
       end if;

        if l_break = 'Y' then
           org.org_pos_id := null;
        end if;

      BEGIN

        pr ('After child orgs ',to_char(org.org_pos_id));
        FOR per IN cur_people (org.org_pos_id,
                               l_check_org_pos,
                               r_effective_date)
        LOOP
          BEGIN
            pr('AFTER FET PEOPLE');

            savepoint execute_mto_sp;

l_ind := 40;
            l_assignment_id     := per.assignment_id;
            l_position_id       := per.position_id;
            l_grade_id          := per.grade_id;
            l_business_group_id := per.business_group_iD;
            l_location_id       := per.location_id;

     pr(' Assign Id/Pos ',to_char(per.assignment_id),to_char(per.position_id));
     pr(' Grade/Bus grp ',to_char(per.grade_id),to_char(per.business_group_id));
     pr(' Location/Eff dt ',to_char(per.location_id),to_char(l_effective_date));

l_ind := 50;
/******************
            if upper(p_action) = 'DUMP OUT' then
---------------------
               if check_select_flg(per.position_id,upper(p_action),
                                   l_effective_date,
                                   p_mass_transfer_id,
                                   l_sel_flg) then
             begin
                  l_errbuf := null;
                  ghr_mto_int.mass_transfer_out (
                                 l_errbuf,
                                 l_retcode,
                                 p_mass_transfer_id,
                                 per.person_id);

                  if l_errbuf is not null then
                      pr('Error in ghr_mto_int.mass_transfer_out'||l_errbuf);
                      hr_utility.set_location
                     ('Error in ghr_mto_int.mass_transfer_out'||
                              'Err is '||l_errbuf,20);
                    l_mass_errbuf := 'Error in ghr_mto_int.mass_transfer_out'||
                                   ' Err is '|| l_errbuf;
                     raise mass_error;
                  end if;
             exception
                 when mass_error then raise;
                 when others then  null;
                      pr('Error in create sf52 - Err is '||
                            l_errbuf||' '||to_char(l_retcode));
                      pr('Err is '||sqlerrm(sqlcode));
                 l_mass_errbuf := 'Error in ghr_mto_int.mass_transfer_out'||
                                   ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
             end;
                end if;
***************/
---------------------
            if upper(p_action) = 'REPORT' AND p_status = 'P' THEN
                pop_dtls_from_pa_req(per.person_id,l_effective_date,
                            p_mass_transfer_id);
            ELSE
               if check_select_flg(per.position_id,upper(p_action),
                                   l_effective_date,
                                   p_mass_transfer_id,
                                   l_sel_flg) then

                  pr('After check sel flg value is ',l_sel_flg,l_sel_status);
l_ind := 70;
                  begin
                     ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                       (p_location_id      => l_location_id
                       ,p_duty_station_id  => l_duty_station_id);
                  exception
                     when others then
                       pr('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details');
                       hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                              'Err is '||sqlerrm(sqlcode),20);
                       l_mass_errbuf := 'Error in get_sf52_loc_ddf_details Sql Err is '||
		                                 sqlerrm(sqlcode);
                      raise mass_error;
                  end;

                  get_pos_grp1_ddf(l_position_id,
                           l_effective_date,
                           l_personnel_office_id,
                           l_org_structure_id,
                           l_office_symbol,
                           l_position_organization,
                           l_pos_grp1_rec);

                  l_occ_series := ghr_api.get_job_occ_series_job
	                             (p_job_id              => per.job_id
	                             ,p_business_group_id   => per.business_group_id
                                     );

                  ghr_msl_pkg.get_sub_element_code_pos_title(l_position_id,
                           per.person_id,
                           l_business_group_id,
                           l_assignment_id,
                           l_effective_date,
                           l_sub_element_code,
                           l_position_title,
                           l_position_number,
                           l_position_seq_no);

pr('before check eleg Sub element code ',l_sub_element_code);

                  IF check_eligibility(
                               p_org_structure_id,
                               p_office_symbol,
                               p_personnel_office_id,
                               p_agency_sub_elem_code,
                               p_duty_station_id,

                               l_org_structure_id,
                               l_office_symbol,
                               l_personnel_office_id,
                               l_sub_element_code,
                               l_duty_station_id,
                               l_occ_series,
                               p_mass_transfer_id,
                               upper(p_action),
                               l_effective_date,
                               per.person_id) then

l_ind := 60;
                  BEGIN
                     ghr_pa_requests_pkg.get_sf52_asg_ddf_details
                               (l_assignment_id,
                           l_effective_date,
                           l_tenure,
                           l_annuitant_indicator,
                           l_pay_rate_determinant,
                           l_work_schedule,
                           l_part_time_hour);
                  EXCEPTION
                     when others then
                         pr('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details');
                         hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
                              'Err is '||sqlerrm(sqlcode),20);
                         l_mass_errbuf := 'Error in get_sf52_asgddf_details Sql Err is '||
                                       sqlerrm(sqlcode);
                         raise mass_error;
                  END;
--Bug#4126137 Moved get_pay_plan_and_table_id from line number 886
l_ind := 65;
              BEGIN
                  ghr_msl_pkg.get_pay_plan_and_table_id(l_pay_rate_determinant,
                           per.person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'SHOW',l_pay_plan,
                           l_pay_table_id,l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
               EXCEPTION
                  when ghr_msl_pkg.msl_error then
 		              l_mass_errbuf := hr_utility.get_message;
                      raise mass_error;
               END;

               get_pos_grp2_ddf(l_position_id,
                           l_effective_date,
                           l_org_func_code,
                           l_appropriation_code1,
                           l_appropriation_code2,
                           l_pos_grp2_rec);
l_ind := 90;
                     BEGIN
                       ghr_pa_requests_pkg.get_duty_station_details
                         (p_duty_station_id        => l_duty_station_id
                         ,p_effective_date        => l_effective_date
                         ,p_duty_station_code        => l_duty_station_code
                         ,p_duty_station_desc        => l_duty_station_desc);
                     EXCEPTION
                        when others then
                           pr('Error in Ghr_pa_requests_pkg.get_duty_station_details');
                           hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                                  'Err is '||sqlerrm(sqlcode),20);
                           l_mass_errbuf := 'Error in get_duty_station_details Sql Err is '||
                                             sqlerrm(sqlcode);
                           raise mass_error;

                     END;

l_ind := 130;
                     IF upper(p_action) IN ('SHOW','REPORT') THEN
                        pr('Bef create ghr cpdf temp');
                        create_mass_act_prev (
                                 l_effective_date,
                                 per.date_of_birth,
                                 per.full_name,
                                 per.national_identifier,
                                 l_duty_station_code,
                                 l_duty_station_desc,
                                 l_personnel_office_id,
                                 l_position_id,
                                 l_position_title,
                                 l_position_number,
                                 l_position_seq_no,
                                 l_org_structure_id,
                                 l_sub_element_code,
                                 per.person_id,
                                 p_mass_transfer_id,
                                 l_sel_flg,
                                 l_grade_or_level,
                                 l_step_or_rate,
                                 l_pay_plan,
                                 l_occ_series,
                                 l_office_symbol,
                                 per.organization_id,
                                 per.organization_name,
                                 null, null, null, null, null, null,
                                 null, null, null, null, null, null,
                                 p_to_agency_code,
/*

                                 l_position_organization,
                                 t_personnel_office_id,
                                 t_sub_element_code,
                                 t_duty_station_id,
                                 t_duty_station_code,
                                 t_duty_station_desc,
                                 t_office_symbol,
                                 t_payroll_office_id,
                                 t_org_func_code,
                                 t_appropriation_code1,
                                 t_appropriation_code2,
                                 t_position_organization,
*/
                                 l_tenure,
                                 l_pay_rate_determinant,
                                 p_action,
                                 l_assignment_id);

                     elsif upper(p_action) = 'DUMP OUT' then
                        begin
                          l_errbuf := null;
                          ghr_mto_int.mass_transfer_out (
                                 l_errbuf,
                                 l_retcode,
                                 p_mass_transfer_id,
                                 per.person_id);

                          if l_errbuf is not null then
                              pr('Error in ghr_mto_int.mass_transfer_out'||
                                       l_errbuf);
                              hr_utility.set_location
                             ('Error in ghr_mto_int.mass_transfer_out'||
                                      'Err is '||l_errbuf,20);
                              l_mass_errbuf :=
                                   'Error in ghr_mto_int.mass_transfer_out'||
                                   ' Err is '|| l_errbuf;
                             raise mass_error;
                          end if;
                        exception
                          when mass_error then raise;
                          when others then  null;
                               pr('Error in create sf52 - Err is '||
                                     l_errbuf||' '||to_char(l_retcode));
                               pr('Err is '||sqlerrm(sqlcode));
                          l_mass_errbuf :=
                                 'Error in ghr_mto_int.mass_transfer_out'||
                                 ' Sql Err is '|| sqlerrm(sqlcode);
                          raise mass_error;
                         end;
l_ind := 180;
                     ELSIF upper(p_action) = 'CREATE' then  ---- Not in Show, Report
                        pr('Bef get pay plan and table id');
l_ind := 190;
                       BEGIN
                          ghr_msl_pkg.get_pay_plan_and_table_id
                              (l_pay_rate_determinant,per.person_id,
                               l_position_id,l_effective_date,
                               l_grade_id, l_assignment_id,'CREATE',
                               l_pay_plan,l_pay_table_id,
                               l_grade_or_level, l_step_or_rate,
                               l_pay_basis);
                        EXCEPTION
                            when ghr_msl_pkg.msl_error then
			                    l_mass_errbuf := hr_utility.get_message;
                                raise mass_error;
                        END;
l_ind := 200;

--Added by Dinkar for quick fix.
                       ---declare  -- Commented by AVR
                       ---l_agency_code ghr_pa_requests.agency_code%type;
                       begin
                          get_to_agency (per.person_id,
                                         l_effective_date,
                                         l_agency_code);

                       hr_utility.set_location('Agency Code in quick fix    ' || l_agency_code,5);

                           if l_agency_code is null then
                              l_agency_code := p_to_agency_code;
                           end if;

                       hr_utility.set_location('Agency Code in Next    ' || l_agency_code,6);


            pr('Bef assign to sf52 rec');
                     assign_to_sf52_rec(
                       per.person_id,
                       per.first_name,
                       per.last_name,
                       per.middle_names,
                       per.national_identifier,
                       per.date_of_birth,
                       l_effective_date,
                       l_assignment_id,
                       l_tenure,
                       l_step_or_rate,
                       l_annuitant_indicator,
                       l_pay_rate_determinant,
                       l_work_schedule,
                       l_part_time_hour,
                       l_pos_ei_data.poei_information7, --FLSA Category
                       l_pos_ei_data.poei_information8, --Bargaining Unit Status
                       l_pos_ei_data.poei_information11,--Functional Class
                       l_pos_ei_data.poei_information16,--Supervisory Status,
                       l_personnel_office_id,
                       l_sub_element_code,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       l_office_symbol,
                       l_payroll_office_id,
                       l_org_func_code,
                       l_appropriation_code1,
                       l_appropriation_code2,
                       l_position_organization,
                        HR_GENERAL.DECODE_LOOKUP('GHR_US_AGENCY_CODE_2',substr(l_agency_code,1,2)), --AVR
                       l_agency_code, -- p_to_position_org_line1  -- AVR
            -------    l_agency_code, -- p_first_noa_information1  (in earlier version)
                       l_lac_sf52_rec,
                       l_sf52_rec);
                    end;

                        pr('Bef create sf52 for mass chgs');

--------------------Create SF-52 ---------------------------

            begin
            -- Adding the following code to keep track of the RPA type and Mass action id
	    --
	    l_sf52_rec.rpa_type            := 'MTO';
	    l_sf52_rec.mass_action_id      := p_mass_transfer_id;
	    --
             ghr_mass_changes.create_sf52_for_mass_changes
                        (p_mass_action_type => 'MASS_TRANSFER_OUT',
                         p_pa_request_rec  => l_sf52_rec,
                         p_errbuf           => l_errbuf,
                         p_retcode          => l_retcode);

------ Added by Dinkar for List reports problem

	 declare
	 l_pa_request_number ghr_pa_requests.request_number%TYPE;
         begin

         l_pa_request_number   :=
                 l_sf52_rec.request_number||'-'||p_mass_transfer_id;

         ghr_par_upd.upd
          (p_pa_request_id             => l_sf52_rec.pa_request_id,
           p_object_version_number     => l_sf52_rec.object_version_number,
      	   p_request_number            => l_pa_request_number
          );
         end;

---------------------------------------

----Added AVR
          begin
            for pa_rec in PA_REQ_EXT_INFO_CUR (l_sf52_rec.pa_request_id)
            loop
                l_PA_REQUEST_EXTRA_INFO_ID := pa_rec.PA_REQUEST_EXTRA_INFO_ID;
                l_pa_OBJECT_VERSION_NUMBER := pa_rec.OBJECT_VERSION_NUMBER;
                exit;
            end loop;

            if l_pa_request_extra_info_id is null then
              ghr_par_extra_info_api.create_pa_request_extra_info
               (p_validate                    => false,
                p_pa_request_id               => l_sf52_rec.pa_request_id,
                p_information_type            => 'GHR_US_PAR_MASS_TERM',
                p_rei_information_category    => 'GHR_US_PAR_MASS_TERM',
                p_rei_information3            => l_agency_code,
                p_pa_request_extra_info_id    => l_dummy,
                p_object_version_number       => l_dummy);
            else
              ghr_par_extra_info_api.update_pa_request_extra_info
               (p_validate                   => false,
                p_rei_information3           => l_agency_code,
                p_pa_request_extra_info_id   => l_PA_REQUEST_EXTRA_INFO_ID,
                p_object_version_number      => l_pa_OBJECT_VERSION_NUMBER);
            end if;
          -----    commit;
          exception
             when others then
                 hr_utility.set_location('Error in ghr_par_extra info.create pa req'||
                              ' Sql Err is '|| sqlerrm(sqlcode) || l_proc, 225);
                 l_mass_errbuf := 'Error in ghr_par_extra info.create pa req'||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
          end;
--------------------- Added AVR end

             if l_errbuf is null then
                   pr('No error in create sf52 sel flg is '||l_sel_flg);
                   hr_utility.set_location('Before commiting',2);

                   ghr_mto_int.log_message(
                        p_procedure => 'Successful Completion',
                        p_message   =>
                        'Name: '||per.full_name ||' SSN: '||
                      per.national_identifier|| ' Mass Transfer : '||
                      p_mass_transfer_name ||' SF52 Successfully completed');
					create_lac_remarks(l_pa_request_id,l_sf52_rec.pa_request_id,l_effective_date,l_sf52_rec);
                   /*ghr_msl_pkg.create_lac_remarks(l_pa_request_id,
                                              l_sf52_rec.pa_request_id);  */
				   --create_remarks(l_sf52_rec,'M67');
                   upd_ext_info_to_null(per.position_id);
                   upd_per_extra_info_to_null(per.person_id);

                   commit;
             else
                   pr('Error in create sf52',l_errbuf);
                   hr_utility.set_location('Error in '||to_char(per.position_id),20);
                   --l_recs_failed := l_recs_failed + 1;
                   raise mass_error;
             end if;
            exception
              when mass_error then raise;
              when others then  null;
                    pr('Error in create sf52 - Err is '||
                       l_errbuf||' '||to_char(l_retcode));
                     pr('Err is '||sqlerrm(sqlcode));
           l_mass_errbuf := 'Error in ghr_mass_chg.create_sf52 '||
                                   ' Sql Err is '|| sqlerrm(sqlcode);
                             raise mass_error;
             end;

         END IF;  ---- End if for p_action = 'CREATE' ----



       END IF; --- End if for Check Eligibility ----
       ELSE   ------ Else for Check Select flag ----
l_ind := 260;
               --update_SEL_FLG(PER.PERSON_ID,l_effective_date);
                null; ---commented
       END IF; ---- End if for check select flag ----
         END IF; ---- End if for p_action

l_ind := 270;
         L_row_cnt := L_row_cnt + 1;
         l_mass_cnt := l_mass_cnt +1;
         if upper(p_action) <> 'CREATE' THEN
           if L_row_cnt > 50 then
              commit;
              L_row_cnt := 0;
           end if;
         end if;
      EXCEPTION
         WHEN mass_ERROR THEN
               HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
               begin
                  ROLLBACK TO EXECUTE_MTO_SP;
               exception
                  when others then null;
               end;
               -- Bug 3718167 Added Person Full Name,SSN in the message.
               l_log_text  := 'Error in '||l_proc||' '||
                              ' For Mass Transfer Name : '||p_mass_transfer_name||
                              ' for Employee: '||per.full_name||
                              ' SSN: '||per.national_identifier||
                              l_mass_errbuf;
               hr_utility.set_location('before creating entry in log file',10);
               l_recs_failed := l_recs_failed + 1;
	       begin
                 ghr_mto_int.log_message(
                                  p_procedure => g_proc,
                                  p_message   => l_log_text);
               end;
         WHEN others then
               hr_utility.set_location('Error (Others) occurred in  '||l_proc||
                          ' Sql error '||sqlerrm(sqlcode),20);
               begin
                  ROLLBACK TO EXECUTE_MTO_SP;
               exception
                  when others then null;
               END;
               -- Bug 3718167 Added Person Full Name,SSN in the message.
               l_log_text  := 'Error (others) in '||l_proc||
                              'Line is '|| to_char(l_ind)||
                              ' For Mass Transfer Name : '||p_mass_transfer_name||
                              ' for Employee: '||per.full_name||
                              ' SSN: '||per.national_identifier||
                              ' Sql Err is '||sqlerrm(sqlcode);
               hr_utility.set_location('before creating entry in log file',20);
               l_recs_failed := l_recs_failed + 1;
               begin
                 ghr_mto_int.log_message(
                                  p_procedure => g_proc,
                                  p_message   => l_log_text);
               end;
         END;
      END LOOP;
      if (upper(p_action) = 'SHOW' or (upper(p_action) = 'REPORT' and
                       p_show_vacant_pos = 'YES' )) THEN
        FOR per IN unassigned_pos (org.org_pos_id,
                                   l_check_org_pos,
                                   l_effective_date)
        LOOP
   	    l_avail_status_id   := per.availability_status_id;

	    IF ( HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_avail_status_id)
	    not in ('Eliminated','Frozen','Deleted') ) THEN

            l_position_id       := per.position_id;
            l_grade_id          := per.grade_id;
            l_business_group_id := per.business_group_iD;
            l_location_id       := per.location_id;

            if check_select_flg(per.position_id,upper(p_action),
                                   l_effective_date,
                                   p_mass_transfer_id,
                                   l_sel_flg) then
                  pr('After check sel flg value is ',l_sel_flg,l_sel_status);
               null;
            end if;

            l_position_title := ghr_api.get_position_title_pos
	        (p_position_id            => l_position_id
	        ,p_business_group_id      => l_business_group_id ) ;

            l_sub_element_code := ghr_api.get_position_agency_code_pos
                   (l_position_id,l_business_group_id);

            l_occ_series := ghr_api.get_job_occ_series_job
	                    (p_job_id              => per.job_id
	                    ,p_business_group_id   => per.business_group_id
                            );

            l_position_number := ghr_api.get_position_desc_no_pos
	        (p_position_id         => l_position_id
	        ,p_business_group_id   => per.business_group_id
	        );

           l_position_seq_no := ghr_api.get_position_sequence_no_pos
	        (p_position_id         => l_position_id
	        ,p_business_group_id   => per.business_group_id
	        );

	  --Bug # 7533027 Added to fetch the grade id for vacant position
	  --from extra information
           ghr_history_fetch.fetch_positionei
                        (p_position_id      => l_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_date_effective   => l_effective_date
                        ,p_pos_ei_data      => l_pos_ei_grade_data
                        );

	   l_grade_id := l_pos_ei_grade_data.poei_information3;
	   l_pay_plan := NULL;
	   l_grade_or_level := NULL;
	   --7533027

           FOR c_grade_kff_rec IN c_grade_kff (l_grade_id)
           LOOP
              l_pay_plan          := c_grade_kff_rec.segment1;
              l_grade_or_level    := c_grade_kff_rec.segment2;
              exit;
           end loop;

            get_pos_grp1_ddf(l_position_id,
                       l_effective_date,
                       l_personnel_office_id,
                       l_org_structure_id,
                       l_office_symbol,
                       l_position_organization,
                       l_pos_grp1_rec);

            begin
                   ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                     (p_location_id      => l_location_id
                     ,p_duty_station_id  => l_duty_station_id);
            end;

            begin
                   ghr_pa_requests_pkg.get_duty_station_details
                      (p_duty_station_id   => l_duty_station_id
                      ,p_effective_date    => l_effective_date
                      ,p_duty_station_code => l_duty_station_code
                      ,p_duty_station_desc => l_duty_station_desc);
            end;

           pr(' Assign Id/Pos ',null, to_char(per.position_id));

           IF check_eligibility(
                       p_org_structure_id,
                       p_office_symbol,
                       p_personnel_office_id,
                       p_agency_sub_elem_code,
                       null,  -- p_duty_station_id, passed as null so that duty station
                                                  -- will not be validated

                       l_org_structure_id,
                       l_office_symbol,
                       l_personnel_office_id,
                       l_sub_element_code,
                       null,                ---- l_duty_station_id,
                       l_occ_series,
                       p_mass_transfer_id,
                       upper(p_action),
                       l_effective_date,
                       null,                ---- person_id
                       null) then

              create_mass_act_prev (
                     l_effective_date,
                     per.date_of_birth,
                     per.full_name,
                     per.national_identifier,
                     l_duty_station_code,
                     l_duty_station_desc,
                     l_personnel_office_id,
                     l_position_id,
                     l_position_title,
                     l_position_number,
                     l_position_seq_no,
                     l_org_structure_id,
                     l_sub_element_code,
                     per.person_id,
                     p_mass_transfer_id,
                     l_sel_flg,
                     l_grade_or_level,
                     null, ---l_step_or_rate,
                     l_pay_plan,
                     l_occ_series,
                     l_office_symbol,
                     per.organization_id,
                     per.organization_name,
                     l_position_organization,
                     null, ---t_personnel_office_id,
                     null, ---t_sub_element_code,
                     null, ---t_duty_station_id,
                     null, ---t_duty_station_code,
                     null, ---t_duty_station_desc,
                     null, ---t_office_symbol,
                     null, ---t_payroll_office_id,
                     null, ---t_org_func_code,
                     null, ---t_appropriation_code1,
                     null, ---t_appropriation_code2,
                     null, ---t_position_organization,
                     p_to_agency_code,
                     null, ---l_tenure,
                     null, ---l_pay_rate_determinant,
                     p_action,
                     null);
              l_mass_cnt := l_mass_cnt +1;
           end if;   ---------   if Check eligiblity
         End if; --- check for Eliminated, deleted and frozen positions
	END LOOP;  --------- Unassigned pos loop
      end if;  -------- If action = show or ( report and vacant pos = yes)

      if upper(p_action) = 'CREATE' then
--- For all the vacant positions. Once this program is called with
--  CREATE Option. The positions will be end date.
--  No 52s will be created
--  and it is agreed in the design review meeting by MACROSS and JMACGOY.
         DECLARE

         l_position_id  hr_positions_f.position_id%TYPE;
         l_position_data_rec ghr_sf52_pos_update.position_data_rec_type;

         BEGIN
             l_avail_status_id := NULL;
            FOR per_vacant IN unassigned_pos (org.org_pos_id,
                                   l_check_org_pos,
                                   l_effective_date)
            LOOP
	       -- Bug#4201666 Added the check to Restrict Eliminated, Frozen, Deleted Positions.
               l_avail_status_id   := per_vacant.availability_status_id;
	       IF ( HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_avail_status_id)
	           not in ('Eliminated','Frozen','Deleted') ) THEN

                 IF check_select_flg(per_vacant.position_id,upper(p_action),
                                   l_effective_date,
                                   p_mass_transfer_id,
                                   l_sel_flg) then

                  l_position_id       := per_vacant.position_id;
                  l_position_data_rec.position_id := l_position_id;
/*                l_position_data_rec.effective_end_date
                                   := l_effective_date;
               l_position_data_rec.effective_date
                                   := l_effective_date; */
			-- Bug 3531540 Need to end date only on the next date
               l_position_data_rec.effective_end_date
                                   := l_effective_date + 1;
               l_position_data_rec.effective_date
                                   := l_effective_date + 1;
			-- End Bug 3531540
               l_business_group_id := per_vacant.business_group_iD;

               l_position_title := ghr_api.get_position_title_pos
	        (p_position_id            => l_position_id
	        ,p_business_group_id      => l_business_group_id ) ;

---Added by AVR Check eligibility is missing 03/30/00
            l_sub_element_code := ghr_api.get_position_agency_code_pos
                   (l_position_id,l_business_group_id);

            get_pos_grp1_ddf(l_position_id,
                       l_effective_date,
                       l_personnel_office_id,
                       l_org_structure_id,
                       l_office_symbol,
                       l_position_organization,
                       l_pos_grp1_rec);

    hr_utility.set_location('Vac.POS-l_position_title '      || l_position_title,5);
    hr_utility.set_location('Vac.POS-l_personnel_office_id ' || l_personnel_office_id,5);
    hr_utility.set_location('Vac.POS-l_org_structure_id '    || l_org_structure_id,5);
    hr_utility.set_location('Vac.POS-l_office_symbol '       || l_office_symbol,5);
    hr_utility.set_location('Vac.POS-l_sub_element_code '    || l_sub_element_code,5);

           IF check_eligibility(
                       p_org_structure_id,
                       p_office_symbol,
                       p_personnel_office_id,
                       p_agency_sub_elem_code,
                       null,  -- p_duty_station_id, passed as null so that duty station
                                                  -- will not be validated
                       l_org_structure_id,
                       l_office_symbol,
                       l_personnel_office_id,
                       l_sub_element_code,
                       null,                ---- l_duty_station_id,
                       l_occ_series,
                       p_mass_transfer_id,
                       null,                --- Action sent as null for vacant position
                       l_effective_date,
                       null,                ---- person_id
                       null) then

       hr_utility.set_location('Vac Pos Selected         '      || l_position_title,5);
---AVR end
               -- VSM-  Bug # 758441
               -- Position history not created for Date end and org id
               -- Created wrapper procedure update_position_info for
               --  ghr_sf52_pos_update.update_position_info
               -- #### ghr_sf52_pos_update.update_position_info
               update_position_info
                   (l_position_data_rec);

               upd_ext_info_to_null(per_vacant.position_id);

               ghr_mto_int.log_message(
                       p_procedure => 'Successful Completion',
                       p_message   =>
                        'Vacant Position : '||l_position_title
                      || ' Mass Transfer : '||
                    p_mass_transfer_name ||' Vacant pos Successfully completed');

              END IF;  -- Check eligibility
            END IF;  -- Check select_flag
	   END IF;
            END LOOP;
         EXCEPTION
              WHEN OTHERS THEN
              l_mass_errbuf := 'Error in ghr_sf52_pos_update.update_position_info'||' Sql Err is '|| sqlerrm(sqlcode);
              raise mass_error;

         END;
      end if;  -------- If action = create

   END;
  if l_break = 'Y' then
     exit;
  end if;

  END LOOP;

    pr('Count is ',to_char(l_mass_cnt),'Failed recs '||to_char(l_recs_failed));

    if (l_recs_failed = 0 ) then
       IF upper(p_action) in ('CREATE','DUMP OUT') THEN
       begin
          update ghr_mass_transfers
             set status = decode(upper(p_action),'CREATE','P',status),
                 interface_flag = decode(upper(p_action),'DUMP OUT','Y',
                           interface_flag)
           where mass_transfer_id = p_mass_transfer_id;
       EXCEPTION
         when others then
           HR_UTILITY.SET_LOCATION('Error in Update ghr_mto  Sql error '||sqlerrm(sqlcode),30);
           hr_utility.set_message(8301, 'GHR_38571_UPD_GHR_MTO_FAILURE');
           hr_utility.raise_error;
       END;
     end if;
   ELSE
--  4215268
  IF upper(p_action) = 'DUMP OUT' and nvl(l_recs_failed,0) > 0 and nvl(l_recs_failed,0) < nvl(l_mass_cnt,0) THEN
       update ghr_mass_transfers
             set status = decode(upper(p_action),'CREATE','P',status),
                 interface_flag = decode(upper(p_action),'DUMP OUT','Y',
                           interface_flag)
           where mass_transfer_id = p_mass_transfer_id;

       l_log_text := ' Error(s) occurred during creation of the Interface Records for few employees.'||
	             ' To process the Mass Transfer Out for that employees, correct the error(s) reported' ||
                     ' in the Process Log ';
       ghr_mto_int.log_message(
                    p_procedure => 'Interface Generation Failed',
                    p_message   => l_log_text);

  ELSE
  --  4215268
    p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
    p_retcode  := 2;
    IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_transfers
            set status = 'E'
          where mass_transfer_id = p_mass_transfer_id;
    END IF;
    -- Bug#4183516/4201876 Added/Modified the message text and message name.
     IF upper(p_action) = 'DUMP OUT' THEN
          l_log_text := ' Error(s) occurred during creation of the Interface Records.'||
		        ' To process the Mass Transfer Out, correct the error(s) reported' ||
                        ' in the Process Log or deselect the employees from the' ||
                        ' Mass Transfer Out Preview before executing.';
           ghr_mto_int.log_message(
                    p_procedure => 'Interface Generation Failed',
                    p_message   => l_log_text);
      END IF;
   END IF;
  end if;
pr(' Recs failed '||to_char(l_recs_failed)||
        'mass cnt is '||to_char(l_mass_cnt));
COMMIT;

EXCEPTION
    when mass_error then
       begin
         ROLLBACK TO EXECUTE_MTO_SP;
       exception
          when others then null;
       end;
       IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_transfers
            set status = 'E'
          where mass_transfer_id = p_mass_transfer_id;
       END IF;
       HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
       p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
       p_retcode  := 2;
       hr_utility.set_location('before creating entry in log file',10);
       --Bug#4183516 Skip this process log entry as one entry is already
       --            written during DUMP OUT Process at l_recs_failed NOT NULL part .
       IF l_mass_errbuf NOT LIKE 'DUMP OUT Failed%' THEN
	       l_log_text  := 'Error in '||l_proc||' '||
                          ' For Mass Transfer Name : '||p_mass_transfer_name||
                          l_mass_errbuf;
           ghr_mto_int.log_message(
                    p_procedure => g_proc,
                    p_message   => l_log_text);
       END IF;
    when others then
       begin
         ROLLBACK TO EXECUTE_MTO_SP;
       exception
          when others then null;
       end;
       IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_transfers
            set status = 'E'
          where mass_transfer_id = p_mass_transfer_id;
       END IF;
      HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
      l_log_text  := 'Error in '||l_proc||
                     ' For Mass Transfer Name : '||p_mass_transfer_name||
                     ' Sql Err is '||sqlerrm(sqlcode);
      l_recs_failed := l_recs_failed + 1;
      p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      hr_utility.set_location('before creating entry in log file',30);
      begin
         ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);
     end;
END EXECUTE_MTO;

--
--
--
-- Procedure Deletes all records processed by the report
--

procedure purge_processed_recs(p_session_id in number,
                               p_err_buf out NOCOPY varchar2) is
begin
   p_err_buf := null;
   delete from ghr_mass_actions_preview
         where mass_action_type = 'TRANSFER'
           and session_id  = p_session_id;
   commit;

exception
   when others then
     p_err_buf := 'Sql err '|| sqlerrm(sqlcode);
end;

procedure pop_dtls_from_pa_req(p_person_id in number,p_effective_date in date,
         p_mass_transfer_id in number) is

cursor ghr_pa_req_cur is
select EMPLOYEE_DATE_OF_BIRTH,
       substr(EMPLOYEE_LAST_NAME||', '||EMPLOYEE_FIRST_NAME||' '||
              EMPLOYEE_MIDDLE_NAMES,1,240)  FULL_NAME,
       EMPLOYEE_NATIONAL_IDENTIFIER,
       DUTY_STATION_CODE,
       DUTY_STATION_DESC,
       PERSONNEL_OFFICE_ID,
       TO_POSITION_ID POSITION_ID,
       TO_POSITION_TITLE POSITION_TITLE,
       TO_POSITION_NUMBER POSITION_NUMBER,
       TO_POSITION_SEQ_NO POSITION_SEQ_NO,
       null org_structure_id,
       FROM_AGENCY_CODE,
       PERSON_ID,
       'Y'  Sel_flag,
       first_action_la_code1,
       first_action_la_code2,
       NULL REMARK_CODE1,
       NULL REMARK_CODE2,
       from_grade_or_level,
       from_step_or_rate,
       FROM_OFFICE_SYMBOL,
       from_pay_plan,
       FROM_OCC_CODE,
       TO_ORGANIZATION_ID ORGANIZATION_ID,
       ---B.NAME             ORGANIZATION_NAME,
       EMPLOYEE_ASSIGNMENT_ID
  from ghr_pa_requests /**, per_organization_units B*/
 where person_id = p_person_id
   and effective_date = p_effective_date
   and first_noa_code = '352'
-- Added by Dinkar for reports
   and substr(request_number,(instr(request_number,'-')+1))
				= to_char(p_mass_transfer_id);

l_proc                      varchar2(72)
          :=  g_package || '.pop_dtls_from_pa_req';
begin
    hr_utility.set_location('Entering    ' || l_proc,5);
    pr('Entering    ' || l_proc,to_char(p_person_id),to_char(p_effective_date));
    g_proc := 'pop_dtls_from_pa_req';
    for pa_req_rec in ghr_pa_req_cur
    loop
    pr('name is '||pa_req_rec.full_name);
     create_mass_act_prev (p_effective_date,
                           pa_req_rec.employee_date_of_birth,
                           pa_req_rec.full_name,
                           pa_req_rec.employee_national_identifier,
                           pa_req_rec.duty_station_code,
                           pa_req_rec.duty_station_desc,
                           pa_req_rec.personnel_office_id,
                           pa_req_rec.position_id,
                           pa_req_rec.position_title,
                           pa_req_rec.position_number,
                           pa_req_rec.position_seq_no,
                           pa_req_rec.org_structure_id,
                           pa_req_rec.from_agency_code,
                           pa_req_rec.person_id,
                           p_mass_transfer_id,
                           'Y', --- Sel flag
                           pa_req_rec.from_grade_or_level,
                           pa_req_rec.from_step_or_rate,
                           pa_req_rec.from_pay_plan,
                           pa_req_rec.from_occ_code,
                           pa_req_rec.from_office_symbol,
                           pa_req_rec.organization_id,
                           null,--pa_req_rec.organization_name,
                           null,
                           null, null, null, null, null,
                           null, null, null, null, null, null, null,
                           null, ---l_tenure,
                           null, ---l_pay_rate_determinant,
                           'REPORT',
                           pa_req_rec.EMPLOYEE_ASSIGNMENT_ID);
       exit;
     END LOOP;
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end pop_dtls_from_pa_req;

--
--
--

function check_select_flg(p_position_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mtfr_id      in number,
                          p_sel_flg in out NOCOPY varchar2)
return boolean IS
   l_comments varchar2(150);
   l_mtfr_id number;

l_proc  varchar2(72) :=  g_package || '.check_select_flg';
l_sel_flg  varchar2(3);
begin
l_sel_flg := p_sel_flg;
   hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'check_select_flg';
   get_extra_info_comments(p_position_id,p_effective_date,p_sel_flg,
                              l_comments,l_mtfr_id);
   --p_sel_status := l_sel_status;
   --pr('Sel Status ',l_sel_status,p_mtfr_name);

   if p_sel_flg is null then
      p_sel_flg := 'Y';
      --Bug#4126137 Commented ins_upd_pos_extra_info as this is invalidating all the positions.
      --  ins_upd_pos_extra_info(p_position_id,p_effective_date,'Y', null, p_mtfr_id);
   elsif p_sel_flg = 'Y' then
         if nvl(l_mtfr_id,0) <> nvl(p_mtfr_id,0) then
            p_sel_flg := 'N';
         end if;
   elsif p_sel_flg = 'N' then
         if nvl(l_mtfr_id,0) <> nvl(p_mtfr_id,0) then
            p_sel_flg := 'Y';
	    --Bug#4126137 Commented ins_upd_pos_extra_info as this is invalidating all the positions.
            -- ins_upd_pos_extra_info(p_position_id,p_effective_date,'Y', null, p_mtfr_id);
         end if;
   end if;

    pr('Sel flg is '||p_sel_flg||'position id is '|| to_char(p_position_id));

     if p_action IN ('SHOW','REPORT') THEN
         return TRUE;
     elsif p_action in ('CREATE','DUMP OUT') THEN
         if p_sel_flg = 'Y' THEN
            return TRUE;
         else
            return FALSE;
         end if;
     end if;
exception
  when mass_error then raise;
  when others then
     p_sel_flg := l_sel_flg;
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end;

--
--
--

procedure purge_old_data (p_mass_transfer_id in number) is
l_proc                      varchar2(72)
          :=  g_package || '.purge_old_data';
BEGIN
   hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'purge_old_data';
   pr('Mass Transfer id is '||to_char(p_mass_transfer_id));
   delete from ghr_mass_actions_preview
    where mass_action_type = 'TRANSFER'
      and session_id  = p_mass_transfer_id;
   commit;
   hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END;

procedure ins_upd_pos_extra_info
               (p_position_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,
                p_mtfr_id in number) is

   l_position_extra_info_id number;
   l_object_version_number number;
   l_pos_ei_data         per_position_extra_info%rowtype;

   CURSOR position_ext_cur (position number) is
   SELECT position_extra_info_id, object_version_number
     FROM PER_POSITION_EXTRA_INFO
    WHERE POSITION_ID = position
      and information_type = 'GHR_US_POS_MASS_ACTIONS';

    l_eff_date date;

l_proc                      varchar2(72)
          :=  g_package || '.ins_upd_pos_extra_info';
begin
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'ins_upd_pos_extra_info';
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_number := l_pos_ei_data.object_version_number;

   if l_position_extra_info_id is null then
      for pos_ext_rec in position_ext_cur(p_position_id)
      loop
         l_position_extra_info_id  := pos_ext_rec.position_extra_info_id;
         l_object_version_number := pos_ext_rec.object_version_number;
      end loop;
   end if;

   if l_position_extra_info_id is not null then
----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;
        ghr_position_extra_info_api.update_position_extra_info
                       (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                       ,P_EFFECTIVE_DATE           => trunc(l_eff_date)
                       ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
                       ,p_poei_INFORMATION15       => p_sel_flag
                       ,p_poei_INFORMATION16       => p_comment
                       ,p_poei_INFORMATION17       => to_char(p_mtfr_id)
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS');
----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;
   else
        -- Bug#4125231 Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;
        ghr_position_extra_info_api.create_position_extra_info
                       (P_POSITION_ID             => p_position_id
                       ,P_INFORMATION_TYPE        => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_date)
                       ,p_poei_INFORMATION15      => p_sel_flag
                       ,p_poei_INFORMATION16      => p_comment
                       ,p_poei_INFORMATION17      => to_char(p_mtfr_id)
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_POSITION_EXTRA_INFO_ID  => l_position_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER   => l_object_version_number);
         --Bug#4215231 Reset the global variable
         ghr_api.g_api_dml       := FALSE;
   end if;
     hr_utility.set_location('Exiting    ' || l_proc,10);

-- There is a trigger on Position extra Info. Whenever updated/created the
-- main position associated with it becomes invalid.
-- We shall call validate_perwsdpo procedure to set the status = VALID.
-- Actually there should be a global flag called fire_trigger in session_var
-- but it doesn't seem to be functional right now.

--- Commented the following two lines to remove Validation functionality on Position.
--   ghr_validate_perwsdpo.validate_perwsdpo(p_position_id);
--   ghr_validate_perwsdpo.update_posn_status(p_position_id);

exception
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end ins_upd_pos_extra_info;

--
--
--

procedure update_sel_flg (p_position_id in number,p_effective_date in date) is

   l_position_extra_info_id number;
   l_object_version_number number;
   l_pos_ei_data         per_position_extra_info%rowtype;
   l_eff_date date;
l_proc                      varchar2(72)
          :=  g_package || '.update_sel_flg';
begin
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'update_sel_flg';

  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_date_effective        => p_effective_date
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_number := l_pos_ei_data.object_version_number;

   if l_position_extra_info_id is not null then
----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;
        ghr_position_extra_info_api.update_position_extra_info
                       (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                       ,P_EFFECTIVE_DATE         => trunc(l_eff_date)
                       ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
                       ,p_poei_INFORMATION15       => NULL
                       ,p_poei_INFORMATION16       => NULL
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS');
----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;


--- Commented the following two lines to remove Validation functionality on Position.
--        ghr_validate_perwsdpo.validate_perwsdpo(p_position_id);
--        ghr_validate_perwsdpo.update_posn_status(p_position_id);

     end if;
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mass_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end update_sel_flg;

--
--
--

FUNCTION check_eligibility(p_org_structure_id in varchar2,
                           p_office_symbol    in varchar2,
                           p_personnel_office_id in varchar2,
                           p_agency_sub_element_code in varchar2,
                           p_duty_station_id in number,
                           p_l_org_structure_id in varchar2,
                           p_l_office_symbol    in varchar2,
                           p_l_personnel_office_id in varchar2,
                           p_l_agency_sub_element_code in varchar2,
                           p_l_duty_station_id in number,
                           p_occ_series_code   in varchar2,
                           p_mass_transfer_id in number,
                           p_action in varchar2,
                           p_effective_date in date,
                           p_person_id in number,
                           p_assign_type in varchar2 default 'ASSIGNED')
return boolean is

   CURSOR occ_cur (tfr_id number,p_occ_series varchar2) IS
   select occ_code
     from ghr_mass_transfer_criteria
    where MASS_TRANSFER_ID = tfr_id
      and occ_code = p_occ_series;

   CURSOR occ_cur_cnt (tfr_id number) is
   select count(*) COUNT
     from ghr_mass_transfer_criteria
    where MASS_TRANSFER_ID = tfr_id;

   l_cnt      number := 0;
   l_occ_code     varchar2(30) := null;
l_proc                      varchar2(72)
          :=  g_package || '.check_eligibility';
BEGIN
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'check_eligibility';

  if p_org_structure_id is not null then
      if p_org_structure_id <> nvl(p_l_org_structure_id,'NULL!~') then
         return false;
      end if;
  end if;

  if p_office_symbol is not null then
      if p_office_symbol <> nvl(p_l_office_symbol,'NULL!~') then
         return false;
      end if;
  end if;

  if p_personnel_office_id is not null then
      if p_personnel_office_id <> nvl(p_l_personnel_office_id,'NULL!~') then
         return false;
      end if;
  end if;

-- VSM - p_agency_sub_element_code can have 2 or 4 chars.
-- 2 char - Check for agency code only
-- 4 char - Check for agency code and subelement
  if p_agency_sub_element_code is not null then
      if substr(p_agency_sub_element_code, 1, 2) <> nvl(substr(p_l_agency_sub_element_code, 1, 2), 'NULL!~') then
         return false;
      end if;
  end if;

  if substr(p_agency_sub_element_code, 3, 2) is not null then
      if substr(p_agency_sub_element_code, 3, 2) <> nvl(substr(p_l_agency_sub_element_code, 3, 2), 'NULL!~') then
         return false;
      end if;
  end if;

  if p_duty_station_id is not null then
      if p_duty_station_id <> nvl(p_l_duty_station_id,0) then
         return false;
      end if;
  end if;

  --if p_assign_type = 'ASSIGNED' then
      for tfr_dtl_cnt in occ_cur_cnt (p_mass_transfer_id)
      loop
         l_cnt := tfr_dtl_cnt.count;
         exit;
      end loop;

      for tfr_dtl in occ_cur (p_mass_transfer_id, p_occ_series_code)
      loop
         l_occ_code := tfr_dtl.occ_code;
         exit;
      end loop;

      if l_cnt <> 0 then
         if l_occ_code is null then
            return false;
         end if;
      end if;
  --end if;

  if p_action = 'CREATE' THEN
    if GHR_MRE_PKG.person_in_pa_req_1noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_first_noa_code => '352'
           ) then
       return false;
    end if;
/*************
    if GHR_MRE_PKG.person_in_pa_req_2noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_second_noa_code => '352'
           ) then
       return false;
    end if;
**************/
  end if;

  pr('Eligible');
  return true;

exception
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END check_eligibility;

--
--
--

procedure get_pos_grp1_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_personnel_office_id out NOCOPY varchar2,
                            p_org_structure_id    out NOCOPY varchar2,
                            p_office_symbol       out NOCOPY varchar2,
                            p_position_organization out NOCOPY varchar2,
                            p_pos_ei_data     OUT NOCOPY per_position_extra_info%rowtype)
IS

l_personnel_office_id   per_position_Extra_info.poei_information3%type;
l_org_structure_id      per_position_Extra_info.poei_information5%type;
l_office_symbol         per_position_Extra_info.poei_information4%type;
l_position_organization per_position_Extra_info.POEI_INFORMATION21%type;

l_pos_ei_data           per_position_extra_info%rowtype;

l_proc                      varchar2(72)
          :=  g_package || '.get_pos_grp1_ddf';
--l_pos_ei_data         per_position_extra_info%type;

begin
l_personnel_office_id := p_personnel_office_id;
l_org_structure_id    := p_org_structure_id;
l_office_symbol       := p_office_symbol;
l_position_organization := p_position_organization;
l_pos_ei_data         := p_pos_ei_data;

  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'get_pos_grp1_ddf';
     ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP1'
                  ,p_date_effective        => p_effective_date
                  ,p_pos_ei_data           => l_pos_ei_data
                                        );
     l_personnel_office_id           :=  l_pos_ei_data.poei_information3;
     l_office_symbol                 :=  l_pos_ei_data.poei_information4;
     l_org_structure_id              :=  l_pos_ei_data.poei_information5;
     l_position_organization         :=  l_pos_ei_data.poei_information21;

     --- NOCOPY Changes
     p_pos_ei_data		     := l_pos_ei_data;
     p_personnel_office_id           :=  l_personnel_office_id;
     p_office_symbol                 :=  l_office_symbol;
     p_org_structure_id              :=  l_org_structure_id;
     p_position_organization         :=  l_position_organization;

     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mass_error then raise;
  when others then
  -- NOCOPY Changes
     p_pos_ei_data		     :=  NULL;
     p_personnel_office_id           :=  NULL;
     p_office_symbol                 :=  NULL;
     p_org_structure_id              :=  NULL;
     p_position_organization         :=  NULL;
-- NOCOPY changes end
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END get_pos_grp1_ddf;

--
--
--

procedure get_pos_grp2_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_org_func_code out NOCOPY varchar2,
                            p_appropriation_code1 out NOCOPY varchar2,
                            p_appropriation_code2 out NOCOPY varchar2,
                            p_pos_ei_data     OUT NOCOPY per_position_extra_info%rowtype)
IS

l_proc                      varchar2(72)
          :=  g_package || '.get_pos_grp2_ddf';

l_org_func_code		per_position_extra_info.POEI_INFORMATION4%type;
l_appropriation_code1   per_position_extra_info.POEI_INFORMATION13%type;
l_appropriation_code2   per_position_extra_info.POEI_INFORMATION13%type;
l_pos_ei_data           per_position_extra_info%rowtype;

begin

l_org_func_code		:= p_org_func_code;
l_appropriation_code1   := p_appropriation_code1;
l_appropriation_code2   := p_appropriation_code2;
l_pos_ei_data           := p_pos_ei_data;

  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'get_pos_grp2_ddf';
     ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP2'
                  ,p_date_effective        => p_effective_date
                  ,p_pos_ei_data           => l_pos_ei_data
                                        );
     l_org_func_code           :=  l_pos_ei_data.poei_information4;
     l_appropriation_code1     :=  l_pos_ei_data.poei_information13;
     l_appropriation_code2     :=  l_pos_ei_data.poei_information14;

---NOCOPY Changes
     p_pos_ei_data             :=  l_pos_ei_data;
     p_org_func_code           :=  l_org_func_code;
     p_appropriation_code1     :=  l_appropriation_code1;
     p_appropriation_code2     :=  l_appropriation_code2;
--- NOCOPY changes

     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mass_error then raise;
  when others then
  ---NOCOPY Changes
     p_pos_ei_data             :=  NULL;
     p_org_func_code           :=  NULL;
     p_appropriation_code1     :=  NULL;
     p_appropriation_code2     :=  NULL;
     ---NOCOPY Changes END

     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END get_pos_grp2_ddf;

--
--
--

PROCEDURE get_extra_info_comments
                (p_position_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out NOCOPY varchar2,
                 p_comments    in out NOCOPY varchar2,
                 p_mtfr_id  in out NOCOPY number) IS

  l_pos_ei_data        per_position_extra_info%rowtype;
  l_proc  varchar2(72) := g_package || '.get_extra_info_comments';
  l_eff_date date;

  l_sel_flag            varchar2(5);
  l_comments            varchar2(4000);
  l_mtfr_id             GHR_MASS_TRANSFERS.mass_transfer_id%type;
begin
  g_proc := 'get_extra_info_comments';

  -- NOCOPY Changes
  l_sel_flag            := p_sel_flag;
  l_comments            := p_comments;
  l_mtfr_id             := p_mtfr_id;
  -- NOCOPY Changes
    hr_utility.set_location('Entering    ' || l_proc,5);

    l_eff_date := p_effective_date;
     ghr_history_fetch.fetch_positionei
                  (p_position_id             => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_pos_ei_data           => l_pos_ei_data);

    l_sel_flag := l_pos_ei_data.poei_information15;
    l_comments := l_pos_ei_data.poei_information16;
    l_mtfr_id := to_number(l_pos_ei_data.poei_information17);

-- NOCOPY Changes
   p_sel_flag            := l_sel_flag;
   p_comments            := l_comments;
   p_mtfr_id             := l_mtfr_id;
-- NOCOPY Changes
    pr('position ext id',to_char(l_pos_ei_data.position_extra_info_id),
                  to_char(l_pos_ei_data.object_version_number));
exception
  when mass_error then raise;
  when others then
   p_sel_flag            := l_sel_flag;
   p_comments            := l_comments;
   p_mtfr_id             := l_mtfr_id;
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end;

--
--
--

procedure create_mass_act_prev (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_position_id in per_assignments_f.position_id%type,
 p_position_title in varchar2,
 p_position_number  in varchar2,
 p_position_seq_no  in varchar2,
 p_org_structure_id in varchar2,
 p_agency_sub_element_code in varchar2,
 p_person_id       in number,
 p_mass_transfer_id  in number,
 p_sel_flg         in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_occ_series in varchar2,
 p_office_symbol in varchar2,
 p_organization_id   in number,
 p_organization_name in varchar2,
 p_positions_organization in varchar2 default null,
 t_personnel_office_id in varchar2 default null,
 t_sub_element_code  in varchar2 default null,
 t_duty_station_id  in number default null,
 t_duty_station_code  in varchar2 default null,
 t_duty_station_desc  in varchar2 default null,
 t_office_symbol  in varchar2 default null,
 t_payroll_office_id  in varchar2 default null,
 t_org_func_code in varchar2 default null,
 t_appropriation_code1 in varchar2 default null,
 t_appropriation_code2 in varchar2 default null,
 t_position_organization in varchar2 default null,
 p_to_agency_code        in varchar2,
 p_tenure               in varchar2,
 p_pay_rate_determinant in varchar2,
 p_action in varchar2,
 p_assignment_id in number)
is

 l_comb_rem varchar2(30);
l_proc                      varchar2(72)
          :=  g_package || '.create_mass_act_prev';

l_agency_sub_elem_desc       varchar2(80);
t_sub_element_desc           varchar2(80);
t_appropriation_code1_desc   varchar2(80);
t_appropriation_code2_desc   varchar2(80);
l_pay_plan_desc              varchar2(80);
l_position_organization_name varchar2(240);
l_poi_desc                   varchar2(80);
t_poi_desc                   varchar2(80);
t_position_organization_name varchar2(240);
l_to_agency_code        varchar2(10);
l_agency_code varchar2(10);

 l_cust_rec     ghr_mass_act_custom.ghr_mass_custom_out_rec_type;
 l_cust_in_rec  ghr_mass_act_custom.ghr_mass_custom_in_rec_type;

----Temp Promo Changes.
 l_step_or_rate  varchar2(30);
 l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;

begin
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'create_mass_act_prev';

pr('Inside ghr_cpdf_temp insert Transfer id ',to_char(p_mass_transfer_id),null);
pr('t_pos_org is',t_position_organization);


  get_to_agency (p_person_id,
                 p_effective_date,
                 l_agency_code);

/*
  if l_agency_code is not null then
       l_to_agency_code := l_agency_code;
  else
       l_to_agency_code := p_to_agency_code;
  end if;
*/
if (p_person_id is not null ) then
     if l_agency_code is not null then
          l_to_agency_code := l_agency_code;
     elsif p_to_agency_code is not null then
          l_to_agency_code := p_to_agency_code;
     else
          l_to_agency_code := p_agency_sub_element_code;
     end if;
else
l_to_agency_code := null;
end if;


      ghr_mre_pkg.GET_FIELD_DESC (p_agency_sub_element_code,
                      l_to_agency_code,  ---t_sub_element_code,
                      t_appropriation_code1,
                      t_appropriation_code2,
                      p_pay_plan,
                      p_personnel_office_id,
                      t_personnel_office_id,
                      p_positions_organization,
                      t_position_organization,

                      l_agency_sub_elem_desc,
                      t_sub_element_desc,
                      t_appropriation_code1_desc,
                      t_appropriation_code2_desc,
                      l_pay_plan_desc,
                      l_poi_desc,
                      t_poi_desc,
                      l_position_organization_name,
                      t_position_organization_name);

  BEGIN
     l_cust_in_rec.person_id := p_person_id;
     l_cust_in_rec.position_id := p_position_id;
     l_cust_in_rec.assignment_id := p_assignment_id;
     l_cust_in_rec.national_identifier := p_national_identifier;
     l_cust_in_rec.mass_action_type := 'TRANSFER OUT';
     l_cust_in_rec.mass_action_id := p_mass_transfer_id;
     l_cust_in_rec.effective_date := p_effective_date;

     GHR_MASS_ACT_CUSTOM.pre_insert (
                       p_cust_in_rec => l_cust_in_rec,
                       p_cust_rec => l_cust_rec);

  exception
     when others then
     hr_utility.set_location('Error in Mass Act Custom '||
              'Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in Mass Act Custom '||
              'Err is '|| sqlerrm(sqlcode);
     raise mass_error;
  END;

  l_step_or_rate := p_step_or_rate;

  IF p_pay_rate_determinant in ('A','B','E','F') AND
     ghr_msl_pkg.check_grade_retention(p_pay_rate_determinant,p_person_id,p_effective_date) = 'REGULAR' THEN
     begin
          l_retained_grade_rec :=
            ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
            if l_retained_grade_rec.temp_step is not null then
               l_step_or_rate := l_retained_grade_rec.temp_step;
            end if;
     exception
        when others then
                l_mass_errbuf := 'Preview -  Others error in Get retained grade '||
                         'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                ghr_mre_pkg.pr('Person ID '||to_char(p_person_id),'ERROR 2',l_mass_errbuf);
                raise mass_error;
     end;
  END IF;

insert into GHR_MASS_ACTIONS_PREVIEW
(
 mass_action_type,
 --report_type,
 ui_type,
 session_id,
 effective_date,
 employee_date_of_birth,
 full_name,
 national_identifier,
 duty_station_code,
 duty_station_desc,
 personnel_office_id,
 position_id,
 position_title,
 position_number,
 position_seq_no,
 org_structure_id,
 agency_code,
 person_id,
 select_flag,
 first_noa_code,
 grade_or_level,
 step_or_rate,
 pay_plan,
 office_symbol,
 organization_id,
 organization_name,
 occ_code,
 positions_organization,
 to_personnel_office_id,
 to_agency_code,
 to_duty_station_id,
 to_duty_station_code,
 to_duty_station_desc,
 to_office_symbol,
 to_payroll_office_id,
 to_org_func_code,
 to_appropriation_code1,
 to_appropriation_code2,
 to_positions_organization,

 AGENCY_DESC,
 TO_AGENCY_DESC,
 TO_APPROPRIATION_CODE1_DESC,
 TO_APPROPRIATION_CODE2_DESC,
 PAY_PLAN_DESC,
 POI_DESC,
 TO_POI_DESC,
 POSITIONS_ORGANIZATION_NAME,
 TO_POSITIONS_ORG_NAME,

 TENURE,
 PAY_RATE_DETERMINANT,
 USER_ATTRIBUTE1,
 USER_ATTRIBUTE2,
 USER_ATTRIBUTE3,
 USER_ATTRIBUTE4,
 USER_ATTRIBUTE5,
 USER_ATTRIBUTE6,
 USER_ATTRIBUTE7,
 USER_ATTRIBUTE8,
 USER_ATTRIBUTE9,
 USER_ATTRIBUTE10,
 USER_ATTRIBUTE11,
 USER_ATTRIBUTE12,
 USER_ATTRIBUTE13,
 USER_ATTRIBUTE14,
 USER_ATTRIBUTE15,
 USER_ATTRIBUTE16,
 USER_ATTRIBUTE17,
 USER_ATTRIBUTE18,
 USER_ATTRIBUTE19,
 USER_ATTRIBUTE20
)
values
(
 'TRANSFER',
 /*--decode(p_action,'REPORT',userenv('SESSIONID'),p_mass_realignment_id),*/
 decode(p_action,'SHOW','FORM','REPORT'),
 userenv('SESSIONID'),
 p_effective_date,
 p_date_of_birth,
 p_full_name,
 p_national_identifier,
 p_duty_station_code,
 p_duty_station_desc,
 p_personnel_office_id,
 p_position_id,
 p_position_title,
 p_position_number,
 to_number(p_position_seq_no),
 p_org_structure_id,
 p_agency_sub_element_code,
 p_person_id,
 p_sel_flg,
 '352',
 p_grade_or_level,
 l_step_or_rate,
 p_pay_plan,
 p_office_symbol,
 p_organization_id,
 p_organization_name,
 p_occ_series,
 p_positions_organization,
 t_personnel_office_id,
 decode(p_sel_flg,'N',NULL,l_to_agency_code), --- t_sub_element_code,
 t_duty_station_id,
 t_duty_station_code,
 t_duty_station_desc,
 t_office_symbol,
 t_payroll_office_id,
 t_org_func_code,
 t_appropriation_code1,
 t_appropriation_code2,

 t_position_organization,
 l_agency_sub_elem_desc,
 decode(p_sel_flg,'N',NULL,t_sub_element_desc),
 t_appropriation_code1_desc,
 t_appropriation_code2_desc,
 l_pay_plan_desc,
 l_poi_desc,
 t_poi_desc,
 l_position_organization_name,
 t_position_organization_name,

 p_tenure,
 p_pay_rate_determinant,

 l_cust_rec.user_attribute1,
 l_cust_rec.user_attribute2,
 l_cust_rec.user_attribute3,
 l_cust_rec.user_attribute4,
 l_cust_rec.user_attribute5,
 l_cust_rec.user_attribute6,
 l_cust_rec.user_attribute7,
 l_cust_rec.user_attribute8,
 l_cust_rec.user_attribute9,
 l_cust_rec.user_attribute10,
 l_cust_rec.user_attribute11,
 l_cust_rec.user_attribute12,
 l_cust_rec.user_attribute13,
 l_cust_rec.user_attribute14,
 l_cust_rec.user_attribute15,
 l_cust_rec.user_attribute16,
 l_cust_rec.user_attribute17,
 l_cust_rec.user_attribute18,
 l_cust_rec.user_attribute19,
 l_cust_rec.user_attribute20
);

     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     pr('Position title is '||p_position_title||' Length is '||to_char(length(p_position_title)));
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end create_mass_act_prev;

--
--
--

function get_mto_name(p_mto_id in number) return varchar2 is

   CURSOR mto_cur is
   SELECT NAME
     FROM GHR_MASS_TRANSFERS
    WHERE MASS_TRANSFER_ID = p_mto_id;

  l_mto_name varchar2(150);
  l_proc  varchar2(72) :=  g_package || '.get_mre_name';
begin
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'get_mto_name';
  FOR mto_REC IN mto_cur
  LOOP
     l_mto_name := mto_rec.name;
     exit;
  END LOOP;
  return (l_mto_name);
end;

--
--

PROCEDURE assign_to_sf52_rec(
 p_person_id              in number,
 p_first_name             in varchar2,
 p_last_name              in varchar2,
 p_middle_names           in varchar2,
 p_national_identifier    in varchar2,
 p_date_of_birth          in date,
 p_effective_date         in date,
 p_assignment_id          in number,
 p_tenure                 in varchar2,
 p_step_or_rate           in varchar2,
 p_annuitant_indicator    in varchar2,
 p_pay_rate_determinant   in varchar2,
 p_work_schedule          in varchar2,
 p_part_time_hour         in varchar2,
 p_flsa_category          in varchar2,
 p_bargaining_unit_status in varchar2,
 p_functional_class       in varchar2,
 p_supervisory_status     in varchar2,
 p_personnel_office_id    in varchar2,
 p_sub_element_code       in varchar2,
 p_duty_station_id        in number,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
 p_office_symbol          in varchar2,
 p_payroll_office_id      in varchar2,
 p_org_func_code          in varchar2,
 p_appropriation_code1    in varchar2,
 p_appropriation_code2    in varchar2,
 p_position_organization  in varchar2,
 p_first_noa_information1 in varchar2,
 p_to_position_org_line1  in varchar2,   -- AVR
 p_lac_sf52_rec           in ghr_pa_requests%rowtype,
 p_sf52_rec               out NOCOPY ghr_pa_requests%rowtype) IS

l_proc                      varchar2(72)
          :=  g_package || '.assign_to_sf52_rec';
l_sf52_rec  ghr_pa_requests%rowtype;
begin

l_sf52_rec := p_sf52_rec;

  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'assign_to_sf52_rec';

 l_sf52_rec.person_id := p_person_id;
 l_sf52_rec.employee_first_name := p_first_name;
 l_sf52_rec.employee_last_name := p_last_name;
 l_sf52_rec.employee_middle_names := p_middle_names;
 l_sf52_rec.employee_national_identifier := p_national_identifier;
 l_sf52_rec.employee_date_of_birth := p_date_of_birth;
 l_sf52_rec.effective_date := p_effective_date;
 l_sf52_rec.employee_assignment_id := p_assignment_id;
 l_sf52_rec.tenure := p_tenure;
 l_sf52_rec.to_step_or_rate := p_step_or_rate;
 l_sf52_rec.annuitant_indicator  := p_annuitant_indicator;
 l_sf52_rec.pay_rate_determinant  := p_pay_rate_determinant;
 l_sf52_rec.work_schedule := p_work_schedule;
 l_sf52_rec.part_time_hours := p_part_time_hour;
 l_sf52_rec.flsa_category := p_flsa_category;
 l_sf52_rec.bargaining_unit_status := p_bargaining_unit_status;
 l_sf52_rec.functional_class := p_functional_class;
 l_sf52_rec.supervisory_status := p_supervisory_status;
 l_sf52_rec.personnel_office_id := p_personnel_office_id;
 l_sf52_rec.agency_code := p_sub_element_code;
 l_sf52_rec.duty_station_id := p_duty_station_id;
 l_sf52_rec.duty_station_code := p_duty_station_code;
 l_sf52_rec.duty_station_desc := p_duty_station_desc;
 l_sf52_rec.to_office_symbol := p_office_symbol;
 l_sf52_rec.appropriation_code1 := p_appropriation_code1;
 l_sf52_rec.appropriation_code2 := p_appropriation_code2;
 l_sf52_rec.first_noa_information1 := p_first_noa_information1;
 l_sf52_rec.to_position_org_line1  := p_to_position_org_line1;  -- AVR

 l_sf52_rec.FIRST_LAC1_INFORMATION1 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION1;
 l_sf52_rec.FIRST_LAC1_INFORMATION2 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION2;
 l_sf52_rec.FIRST_LAC1_INFORMATION3 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION3;
 l_sf52_rec.FIRST_LAC1_INFORMATION4 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION4;
 l_sf52_rec.FIRST_LAC1_INFORMATION5 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION5;
 l_sf52_rec.SECOND_LAC1_INFORMATION1 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION1;
 l_sf52_rec.SECOND_LAC1_INFORMATION2 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION2;
 l_sf52_rec.SECOND_LAC1_INFORMATION3 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION3;
 l_sf52_rec.SECOND_LAC1_INFORMATION4 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION4;
 l_sf52_rec.SECOND_LAC1_INFORMATION5 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION5;
 l_sf52_rec.FIRST_ACTION_LA_CODE1 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE1;
 l_sf52_rec.FIRST_ACTION_LA_CODE2 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE2;
 l_sf52_rec.FIRST_ACTION_LA_DESC1 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC1;
 l_sf52_rec.FIRST_ACTION_LA_DESC2 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC2;

     hr_utility.set_location('Exiting    ' || l_proc,10);

p_sf52_rec := l_sf52_rec;

exception
  when mass_error then raise;
  when others then
  --NOCOPY changes
  p_sf52_rec := l_sf52_rec;
  -- NOCOPY Changes
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end assign_to_sf52_rec;

--
--
--

procedure upd_ext_info_to_null(p_position_id in number) is

   CURSOR POSITION_EXT_CUR (p_position number) IS
   select position_extra_info_id, object_version_number
     from per_position_extra_info
    where position_id = (p_position)
      and INFORMATION_TYPE = 'GHR_US_POS_MASS_ACTIONS';

   l_Position_EXTRA_INFO_ID         NUMBER;
   l_OBJECT_VERSION_NUMBER        NUMBER;

   l_pos_ei_data         per_position_extra_info%rowtype;
   l_proc    varchar2(72) :=  g_package || '.upd_ext_info_api';
begin

  g_proc := 'upd_ext_info_to_null';
   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_date_effective        => trunc(sysdate)
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_number := l_pos_ei_data.object_version_number;

   if l_position_extra_info_id is not null then
----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;
          ghr_position_extra_info_api.update_position_extra_info
                      (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                      ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
                      ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                      ,P_EFFECTIVE_DATE          => trunc(sysdate)
                      ,P_POEI_INFORMATION15        => null
                      ,P_POEI_INFORMATION16        => null
                      ,P_POEI_INFORMATION17        => null);
----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;


--- Commented the following two lines to remove Validation functionality on Position.
--          ghr_validate_perwsdpo.validate_perwsdpo(p_position_id);
--          ghr_validate_perwsdpo.update_posn_status(p_position_id);

   end if;
end;

--
--
--

PROCEDURE get_to_agency (p_person_id in number,
                         p_effective_date in date,
                         p_agency_code out NOCOPY varchar2) is

   l_per_ei_data        per_people_extra_info%rowtype;
   l_proc    varchar2(72) :=  g_package || '.upd_ext_info_api';
   l_eff_date date;
   l_agency_code        varchar2(5);
begin
  hr_utility.set_location('Entering    ' || l_proc,5);

  -- NOCOPY changes
  l_agency_code    := p_agency_code;
  -- NOCOPY changes

  g_proc := 'get_to_agency';
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;
   -- VSM - Changes Bug # 752015 changed p_information type from
   --       GHR_US_PER_SEPARATE_RETIRE to GHR_US_PER_MASS_ACTIONS
   ghr_history_fetch.fetch_peopleei
                  (p_person_id           => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_per_ei_data           => l_per_ei_data);

   l_agency_code := l_per_ei_data.PEI_INFORMATION9;

   -- NOCOPY changes
   p_agency_code := l_agency_code;
   -- NOCOPY changes
  hr_utility.set_location('Agency Code     ' || p_agency_code,10);
  hr_utility.set_location('Leaving    ' || l_proc,15);
end;

PROCEDURE upd_ext_info_api (p_person_id in number,
                            p_agency_code in varchar2,
                            p_effective_date in date) IS

   -- VSM - Changes Bug # 752015 changed p_information type from
   --       GHR_US_PER_SEPARATE_RETIRE to GHR_US_PER_MASS_ACTIONS
   CURSOR PERSON_EXT_CUR (p_person number) IS
   select person_extra_info_id, object_version_number
     from per_people_extra_info
    where person_id = (p_person)
      and INFORMATION_TYPE = 'GHR_US_PER_MASS_ACTIONS';

l_cnt number;
l_person_id number;
l_person_EXTRA_INFO_ID         NUMBER;
l_OBJECT_VERSION_NUMBER        NUMBER;
l_object_version_no            number;

   l_per_ei_data        per_people_extra_info%rowtype;
   l_proc    varchar2(72) :=  g_package || '.upd_ext_info_api';
   l_eff_date date;

BEGIN
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'upd_ext_info_api';
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;

   -- VSM - Changes Bug # 752015 changed p_information type from
   --       GHR_US_PER_SEPARATE_RETIRE to GHR_US_PER_MASS_ACTIONS
   ghr_history_fetch.fetch_peopleei
                  (p_person_id           => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => trunc(l_eff_date)
                  ,p_per_ei_data           => l_per_ei_data);


pr ('Person id ',to_char(p_person_id));
   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
   l_object_version_number := l_per_ei_data.object_version_number;

pr ('Person ext info id ',to_char(l_person_extra_info_id));

   if l_person_extra_info_id is null then
      for per_ext_rec in person_ext_cur(p_person_id)
      loop
         l_person_extra_info_id  := per_ext_rec.person_extra_info_id;
         l_object_version_number := per_ext_rec.object_version_number;
      end loop;
   end if;

pr ('Person ext info id ',to_char(l_person_extra_info_id),to_char(l_object_version_number));

  if l_person_extra_info_id is null then
pr('Bef create pers ext info');
   -- VSM - Changes Bug # 752015 changed p_information type from
   --       GHR_US_PER_SEPARATE_RETIRE to GHR_US_PER_MASS_ACTIONS
        ghr_person_extra_info_api.create_person_extra_info
                       (p_person_id              => p_person_id
                       ,p_information_type       => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE         => trunc(l_eff_date)
                       ,P_PEI_information_category => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_PEI_INFORMATION9        => p_agency_code
                       ,p_PERSON_EXTRA_INFO_ID   => l_PERSON_EXTRA_INFO_ID
                       ,P_OBJECT_VERSION_NUMBER  => L_OBJECT_VERSION_NUMBER);

     else
pr('Bef update pers ext info');
   -- VSM - Changes Bug # 752015 changed p_information type from
   --       GHR_US_PER_SEPARATE_RETIRE to GHR_US_PER_MASS_ACTIONS
        ghr_person_extra_info_api.update_person_extra_info
                       (P_PERSON_EXTRA_INFO_ID   => l_PERSON_extra_info_id
                       ,P_EFFECTIVE_DATE         => trunc(l_eff_date)
                       ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
                       ,P_PEI_information_category => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_PEI_INFORMATION9        => p_agency_code);

     end if;
---Commented the following two lines to remove Validation functionality on Person.
--   ghr_validate_perwsepi.validate_perwsepi(p_person_id);
--   ghr_validate_perwsepi.update_person_user_type(p_person_id);
END;

--
--
--

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null) is
begin
  g_no := g_no +1;
--  insert into l_tmp values (g_no,substr(msg||'-'||par1||' -'||par2||'-',1,199));
--  DBMS_OUTPUT.PUT_LINE(msg||'-'||par1||' -'||par2||'-');
exception
  when others then
     pr('Error in '||'pr');
     hr_utility.set_location('Error in pr '||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in pr  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
end;

Procedure update_position_info
     (p_position_data_rec  in ghr_sf52_pos_update.position_data_rec_type) is
    l_proc    varchar2(30):='update_position_info';
Begin
    hr_utility.set_location('Entering ' || l_proc, 10);
   g_proc := 'update_position_info';
   ghr_session.set_session_var_for_core( p_position_data_rec.effective_end_date );
   ghr_sf52_pos_update.update_position_info
        ( p_pos_data_rec => p_position_data_rec);
    hr_utility.set_location('Calling Pust_update_process ' || l_proc, 50);
   g_proc := 'post_update_process';
    ghr_history_api.post_update_process;
    hr_utility.set_location('Leaving ' || l_proc, 100);

end;

Procedure upd_per_extra_info_to_null(p_person_id in number) is

   CURSOR PER_EXT_CUR (p_person number) IS
   select person_extra_info_id, object_version_number
     from per_people_extra_info
    where person_id = (p_person)
      and INFORMATION_TYPE = 'GHR_US_PER_MASS_ACTIONS';

   l_Person_EXTRA_INFO_ID         NUMBER;
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_per_ei_data         per_people_extra_info%rowtype;
   l_proc    varchar2(72) :=  g_package || '.upd_per_extra_info_to_null';
begin

  g_proc := 'upd_per_extra_info_to_null';
   ghr_history_fetch.fetch_peopleei
                  (p_person_id          => p_person_id
                  ,p_information_type   => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective     => trunc(sysdate)
                  ,p_per_ei_data        => l_per_ei_data);

   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;

   l_object_version_number := l_per_ei_data.object_version_number;

   if l_person_extra_info_id is not null then
----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;
          ghr_person_extra_info_api.update_person_extra_info
                      (P_PERSON_EXTRA_INFO_ID   => l_PERSON_extra_info_id
                      ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
                      ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS'
                      ,P_EFFECTIVE_DATE          => trunc(sysdate)
                      ,P_PEI_INFORMATION9        => null
                     );
--                      ,P_PEI_INFORMATION16        => null
--                      ,P_PEI_INFORMATION17        => null);
----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;
   end if;

End;
END GHR_MTO_PKG;

/
