--------------------------------------------------------
--  DDL for Package Body GHR_RIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_RIF_PKG" AS
/* $Header: ghrifpkg.pkb 120.1.12010000.2 2008/08/05 15:12:39 ubhat ship $ */

Procedure return_ratings
(p_person_id       in  number
,p_structure_name  in  varchar2
,p_effective_date  in  date
,p_special_info1   out nocopy  ghr_api.special_information_type
,p_special_info2   out nocopy  ghr_api.special_information_type
,p_special_info3   out nocopy  ghr_api.special_information_type
)
is
l_proc           varchar2(72)  := 'return_special_information ';
l_id_flex_num    fnd_id_flex_structures.id_flex_num%type;

Cursor c_flex_num is
  select    flx.id_flex_num
  from      fnd_id_flex_structures_tl flx
  where     flx.id_flex_code           = 'PEA'  --
  and       flx.application_id         =  800   --
  and       flx.id_flex_structure_name =  p_structure_name
  and       flx.language	       = 'US';

Cursor    cur_sit      is
   select  pea.segment2 segment2,
           pea.segment3 segment3,
           pan.date_from date_from
   from    per_analysis_criteria pea,
           per_person_analyses   pan
   where   pan.person_id            =  p_person_id
   and     decode(pan.id_flex_num,l_id_flex_num,1,2) = 1
   and     pea.analysis_criteria_id =  pan.analysis_criteria_id
   and     add_months(p_effective_date,-48) < ghr_general.return_rif_date(pea.segment3)
 order   by  3 desc ;


begin

  for flex_num in c_flex_num loop
    l_id_flex_num  :=  flex_num.id_flex_num;
    exit;
  End loop;

  If l_id_flex_num is null then
    hr_utility.set_message(8301,'GHR_38275_INV_SP_INFO_TYPE');
    hr_utility.raise_error;
  End if;


  for cur_sit_rec in cur_sit loop
    if cur_sit%rowcount = 1 then
      p_special_info1.segment2 := cur_sit_rec.segment2;
      p_special_info1.segment3 := cur_sit_rec.segment3;
    elsif cur_sit%rowcount = 2 then
      p_special_info2.segment2 := cur_sit_rec.segment2;
      p_special_info2.segment3 := cur_sit_rec.segment3;
    elsif cur_sit%rowcount = 3 then
      p_special_info3.segment2 := cur_sit_rec.segment2;
      p_special_info3.segment3 := cur_sit_rec.segment3;
    end if;
  end loop;

Exception
    When Others then
        p_special_info1 := NULL;
	p_special_info2 := NULL;
	p_special_info3 := NULL;
	raise;
end return_ratings;



procedure purge_register(p_session_id in ghr_rif_registers.session_id%TYPE) is
BEGIN
  delete from ghr_rif_registers
   where session_id = p_session_id;
END;



procedure get_grd (
                   p_grade_id in varchar2
                  ,p_pay_plan out nocopy  varchar2
                  ,p_grade_or_level out nocopy  varchar2
                )
IS

CURSOR cur_grd IS
  SELECT gdf.segment1 pay_plan
        ,gdf.segment2 grade_or_level
  FROM  per_grade_definitions gdf
       ,per_grades            grd
  WHERE grd.grade_id = p_grade_id
  AND   grd.grade_definition_id = gdf.grade_definition_id;

BEGIN

  FOR cur_grd_rec IN cur_grd LOOP
    p_pay_plan :=  cur_grd_rec.pay_plan;
    p_grade_or_level    :=  cur_grd_rec.grade_or_level;
    exit;
  END LOOP;

EXCEPTION
    -- NOCOPY Changes
    WHEN OTHERS THEN
         p_pay_plan := NULL;
	 p_grade_or_level := NULL;
	 raise;
END ;


function get_entered_grade_date(p_asg_id    in  number,
                                p_start_date in date )

  return date is
  cursor cur_egd is
 select  effective_start_date,
           gdf.segment2 grade
     from per_assignments_f asg,
          per_grades  grd,
          per_grade_definitions gdf
   where grd.grade_id (+)  =  asg.grade_id
   and  asg.assignment_id = p_asg_id
   and  asg.assignment_type <> 'B'
   and  grd.grade_definition_id    = gdf.grade_definition_id (+)
   and  gdf.segment2 is not null
   and  trunc(asg.effective_start_date) <= trunc(p_start_date)
   order by asg.effective_start_date desc,
            gdf.segment2;


l_start_date  date;
l_temp_start_date date;
l_temp_grade  varchar2(60);
l_m_start_date date;
l_m_grade    varchar2(60);
l_temp_id   number := 0;

begin


for  cur_rec in cur_egd
 loop
    l_temp_start_date := cur_rec.effective_start_date;
    l_temp_grade      := cur_rec.grade;
  if l_temp_id = 0 then
    l_m_start_date := l_temp_start_date;
    l_m_grade      := l_temp_grade;
    l_temp_id := 1;
  end if;
  if l_temp_id = 1 then
   if l_m_grade = l_temp_grade then
      if trunc(l_m_start_date) = trunc(l_temp_start_date) then
         null;
      else
         l_m_start_date := l_temp_start_date;
      end if;
    else
     exit;
  end if;
 end if;
end loop;
      return l_m_start_date;
end;

procedure get_lookup_meaning_desc (
                 p_application_id IN  number
                ,p_lookup_type    IN  hr_lookups.lookup_type%TYPE
                ,p_lookup_code    IN  hr_lookups.lookup_code%TYPE
                ,p_lookup_meaning OUT NOCOPY  hr_lookups.meaning%TYPE
                ,p_lookup_desc    OUT NOCOPY  hr_lookups.description%TYPE
                ) IS
CURSOR cur_loc IS
--bug 760715 even though application id is passed in no longer need to use when
-- using hr_lookups view
  SELECT loc.meaning,
         loc.description
  FROM   hr_lookups loc
  WHERE  loc.lookup_type    = p_lookup_type
  AND    loc.lookup_code    = p_lookup_code;

BEGIN

  FOR cur_loc_rec IN cur_loc LOOP
    p_lookup_meaning :=  cur_loc_rec.meaning;
    p_lookup_desc    :=  cur_loc_rec.description;
    exit;
  END LOOP;
-- NOCOPY Changes
EXCEPTION
    WHEN OTHERS THEN
        p_lookup_meaning := NULL;
        p_lookup_desc    := NULL;
	raise;
END get_lookup_meaning_desc;

procedure run_register (
                    p_rif_criteria_id  IN  ghr_rif_criteria.rif_criteria_id%TYPE
                   ,p_organization_id  in  ghr_rif_criteria.organization_id%TYPE
                   ,p_org_structure_id  in  ghr_rif_criteria.org_structure_id%TYPE
                   ,p_office_symbol  in  ghr_rif_criteria.office_symbol%TYPE
                   ,p_agency_code_subelement  in  ghr_rif_criteria.agency_code_subelement%TYPE
                   ,p_comp_area  in  ghr_rif_criteria.comp_area%TYPE
                   ,p_comp_level  in  ghr_rif_criteria.comp_level%TYPE
                   ,p_effective_date in date
                       )  IS

-- Bug 4377361 included EMP_APL for person type condition
cursor cur_people (p_effective_date date) is
select per.person_id    PERSON_ID,
       per.first_name   FIRST_NAME,
       per.last_name    LAST_NAME,
       per.full_name    FULL_NAME,
       per.middle_names MIDDLE_NAMES,
       per.date_of_birth DATE_OF_BIRTH,
       per.national_identifier NATIONAL_IDENTIFIER,
       asg.position_id  POSITION_ID,
       asg.assignment_id ASSIGNMENT_ID,
       asg.grade_id     GRADE_ID,
       asg.job_id       JOB_ID,
       asg.business_group_id BUSINESS_GROUP_ID,
       asg.organization_id   ORGANIZATION_ID,
       asg.effective_start_date EFFECTIVE_START_DATE
  from per_assignments_f   asg,
       per_people_f        per,
       per_person_types    ppt
 where per.person_id    = asg.person_id
   and asg.primary_flag = 'Y'
   and asg.assignment_type <> 'B'
   and p_effective_date between asg.effective_start_date
             and asg.effective_end_date
   and per.person_type_id = ppt.person_type_id
   and ppt.system_person_type IN ('EMP','EMP_APL')
   and p_effective_date between per.effective_start_date
             and per.effective_end_date
   and asg.position_id is not null;

cursor   cur_criteria(p_rif_criteria_id  ghr_rif_criteria.rif_criteria_id%TYPE)
  is
    select   rif.comp_area  comp_area,
             rif.comp_level comp_level,
             rif.effective_date,
             rif.organization_id,
             rif.org_structure_id,
             rif.office_symbol,
             rif.agency_code_subelement
      from   ghr_rif_criteria rif
      where  rif.rif_criteria_id = p_rif_criteria_id;

cursor   job_name(p_job_id per_jobs.job_id%TYPE)
  is
    select jobs.name
      from per_jobs jobs
      where jobs.job_id = p_job_id;

cursor position_name(p_position_id hr_positions_f.position_id%TYPE,p_effective_date date )
  is
    select name
      from hr_positions_f pos
      where pos.position_id = p_position_id
      and p_effective_date between pos.effective_start_date
      and pos.effective_end_date;

cursor cur_rif_reg_seq is
  Select ghr_rif_registers_s.nextval from dual;

l_rif_reg                          ghr_rif_registers%rowtype;

l_c_comp_area                      varchar2(30);
l_c_comp_level                     varchar2(30);
l_c_effective_date                 date;
l_c_organization_id                number(15);
l_c_org_structure_id               varchar2(20);
--Start of Bug # 5632674 changed from varchar2(8) to varchar2(18)
l_c_office_symbol                  varchar2(18);
--End of Bug#5632674

l_c_agency_code_se                 varchar2(30);

l_asg_cnt                          number;
l_grd_cnt                          number;

l_comp_area                        varchar2(30);
l_comp_level                       varchar2(30);
l_multiple_error_flag              boolean;
l_dummy_parameter                  varchar2(30);
l_value                            varchar2(30);
l_effective_date                   date;

l_rating1                          varchar2(80);
l_rating2                          varchar2(80);
l_rating3                          varchar2(80);

l_pos_ei_data1                     per_position_extra_info%rowtype;
l_pos_ei_data2                     per_position_extra_info%rowtype;
l_pos_ei_data3                     per_position_extra_info%rowtype;

l_asg_ei_data                      per_assignment_extra_info%rowtype;

l_people_ei_data1                  per_people_extra_info%rowtype;
l_people_ei_data2                  per_people_extra_info%rowtype;

l_perf_appraisal1                  ghr_api.special_information_type;
l_perf_appraisal2                  ghr_api.special_information_type;
l_perf_appraisal3                  ghr_api.special_information_type;

BEGIN
hr_utility.set_location('Enter Rif' ,1);

   if p_comp_area  is null and
      p_comp_level is null and
      p_effective_date is null and
      p_organization_id is null and
      p_org_structure_id is null and
      p_office_symbol is null   and
      p_agency_code_subelement is null
  then
    open cur_criteria(p_rif_criteria_id);
    fetch cur_criteria into l_c_comp_area,
                          l_c_comp_level,
                          l_c_effective_date,
                          l_c_organization_id,
           		  l_c_org_structure_id,
                          l_c_office_symbol,
                          l_c_agency_code_se;
    if cur_criteria%NOTFOUND then
      hr_utility.set_message(8301,'GHR_38485_NULL_RIF_CRITERIA');
      hr_utility.raise_error;
    end if;

    close cur_criteria;

  else
    l_c_comp_area := p_comp_area;
    l_c_comp_level:= p_comp_level;
    l_c_effective_date := p_effective_date;
    l_c_organization_id := p_organization_id;
    l_c_org_structure_id := p_org_structure_id;
    l_c_office_symbol := p_office_symbol;
    l_c_agency_code_se := p_agency_code_subelement;
  end if;

/* Comp_area is used to be required field but with Bug 691379 it become optional */

    if l_c_comp_level is null then
      hr_utility.set_message(8301,'GHR_38484_NO_COMP_AREA_LEVEL');
      hr_utility.raise_error;
    end if;

  l_effective_date := trunc(sysdate); -- In the future l_effective_date may set to p_effective_date

  DELETE FROM ghr_rif_registers reg
  WHERE reg.session_id =  userenv('SESSIONID')
   and rif_criteria_id =  p_rif_criteria_id;

hr_utility.set_location('Purged rif_registers' ,2);

  FOR per_rec IN cur_people (l_effective_date)

    LOOP

--Get the  Person  Comp Area, Comp Level,Org Structure Id, Office Symbol

hr_utility.set_location('Getting position EI',3);
       ghr_history_fetch.fetch_positionei
         (p_position_id           => per_rec.position_id
         ,p_information_type      => 'GHR_US_POS_GRP1'
         ,p_date_effective        => l_effective_date
         ,p_pos_ei_data           => l_pos_ei_data1
         );

         l_comp_area                := l_pos_ei_data1.poei_information20;
         l_comp_level               := l_pos_ei_data1.poei_information9;
         l_rif_reg.org_structure_id := l_pos_ei_data1.poei_information5;
         l_rif_reg.office_symbol    := l_pos_ei_data1.poei_information4;

-- Agency Code
hr_utility.set_location('Getting Agency Code',4);

       l_rif_reg.agency_code_subelement :=	ghr_api.get_position_agency_code_pos
	  (p_position_id         => per_rec.position_id
	   ,p_business_group_id  => per_rec.business_group_id
           ,p_effective_date     => l_effective_date);

--Check the Criteria

hr_utility.set_location('Checking the Criteria',5);
         if  nvl(l_comp_area,hr_api.g_varchar2)  = nvl(l_c_comp_area,nvl(l_comp_area,hr_api.g_varchar2))  and
             nvl(l_comp_level,hr_api.g_varchar2) = l_c_comp_level  and
             nvl(l_rif_reg.org_structure_id,hr_api.g_varchar2 ) = nvl(l_c_org_structure_id,nvl(l_rif_reg.org_structure_id,hr_api.g_varchar2 )) and
             nvl(l_rif_reg.office_symbol,hr_api.g_varchar2) = nvl(l_c_office_symbol,nvl(l_rif_reg.office_symbol,hr_api.g_varchar2)) and
            nvl(l_rif_reg.agency_code_subelement,hr_api.g_varchar2 ) = nvl(l_c_agency_code_se,nvl(l_rif_reg.agency_code_subelement,hr_api.g_varchar2))  and
            nvl(per_rec.organization_id,hr_api.g_number ) = nvl(l_c_organization_id,nvl(per_rec.organization_id,hr_api.g_number))
         then

-- Populate the details into ghr_rif_registers

-- Tenure and Step_or_rate
hr_utility.set_location('Getting Tenure and Ster_or_rate',5);

        ghr_history_fetch.fetch_asgei
                        (p_assignment_id         => per_rec.assignment_id
                        ,p_information_type      => 'GHR_US_ASG_SF52'
                        ,p_date_effective        => l_effective_date
                        ,p_asg_ei_data           => l_asg_ei_data
                        );
        l_rif_reg.tenure := l_asg_ei_data.aei_information4;
        l_rif_reg.step_or_rate := l_asg_ei_data.aei_information3;

-- Tenure Description  and Group


hr_utility.set_location('Getting the Tenure Description and Group',6);
       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_TENURE',
            p_lookup_code    => l_rif_reg.tenure,
            p_lookup_meaning => l_rif_reg.tenure_desc,
            p_lookup_desc    => l_rif_reg.tenure_group);

-- Tenure Group Order

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_TENURE_GROUP',
            p_lookup_code    => l_rif_reg.tenure_group,
            p_lookup_meaning => l_rif_reg.tenure_group_desc,
            p_lookup_desc    => l_rif_reg.tenure_group_order);

-- Vets info
hr_utility.set_location('Getting Vets Info',7);

        ghr_history_fetch.fetch_peopleei
                       (p_person_id              =>  per_rec.person_id,
                        p_information_type       => 'GHR_US_PER_SF52',
                        p_date_effective         =>  l_effective_date,
                        p_per_ei_data            => l_people_ei_data1
                       );

	l_rif_reg.veterans_pref_for_rif := l_people_ei_data1.pei_information5;
	l_rif_reg.veterans_preference   := l_people_ei_data1.pei_information4;

-- VETERANS DESCRIPTION and SUB GROUP

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_VETERANS_PREF_FOR_RIF',
            p_lookup_code    => l_rif_reg.veterans_pref_for_rif,
            p_lookup_meaning => l_dummy_parameter,
            p_lookup_desc    => l_rif_reg.veterans_pref_sub_group);

--  if veterans_pref_sub_group is null then use GHR_US_VETERANS_PREFERENCE looking type

      if l_rif_reg.veterans_pref_sub_group is null
        then
         get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_VETERANS_PREF',
            p_lookup_code    => l_rif_reg.veterans_preference,
            p_lookup_meaning => l_rif_reg.veterans_preference_desc,
            p_lookup_desc    => l_rif_reg.veterans_pref_sub_group);
      end if;

-- VETERANS PREFERENCE SUB GROUP DESC AND ORDER

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_VETERANS_PREF_SUB_GROUP',
            p_lookup_code    => l_rif_reg.veterans_pref_sub_group,
            p_lookup_meaning => l_rif_reg.veterans_pref_sub_group_desc,
            p_lookup_desc    => l_rif_reg.veterans_pref_sub_group_order);

-- SCD info

        ghr_history_fetch.fetch_peopleei
                       (p_person_id              =>  per_rec.person_id,
                        p_information_type           => 'GHR_US_PER_SCD_INFORMATION',
                        p_date_effective             =>  l_effective_date,
                        p_per_ei_data                => l_people_ei_data2
                       );

        l_rif_reg.service_comp_date_rif := fnd_date.canonical_to_date(l_people_ei_data2.pei_information5);
        l_rif_reg.service_comp_date_civilian := fnd_date.canonical_to_date(l_people_ei_data2.pei_information4);

-- Series (Occ_code)
hr_utility.set_location('Getting OCC Code' ,8);

        l_rif_reg.occ_code := ghr_api.get_job_occ_series_job
                       (p_job_id  => per_rec.job_id,
                        p_business_group_id => per_rec.business_group_id
                       );

-- Series Decription

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_OCC_SERIES',
            p_lookup_code    => l_rif_reg.occ_code,
            p_lookup_meaning => l_rif_reg.occ_code_desc,
            p_lookup_desc    => l_dummy_parameter);

-- Job name - select from per_jobs - in job_id,business_group_id

         if per_rec.job_id is not null then
           for job_name_rec in job_name(per_rec.job_id) loop
               l_rif_reg.job_name := job_name_rec.name;
               exit;
           end loop;
         end if;

-- Pay plan and Grade id


get_grd(p_grade_id => per_rec.grade_id,
                  p_pay_plan => l_rif_reg.pay_plan,
                  p_grade_or_level => l_rif_reg.grade_or_level);


-- Getting Entered Present grade date

       l_rif_reg.entered_grade_date :=
	 get_entered_grade_date(p_asg_id         => per_rec.assignment_id,
                                p_start_date     => per_rec.effective_start_date);

--WGI Due Date
hr_utility.set_location('Getting WGI Due Date',9);

  	     ghr_api.retrieve_element_entry_value
           (p_element_name         => 'Within Grade Increase',
            p_input_value_name     => 'Date Due',
            p_assignment_id        =>  per_rec.assignment_id,                                                 p_effective_date       =>  l_effective_date,
            p_value                =>  l_value,
            p_multiple_error_flag  =>  l_multiple_error_flag
           );
hr_utility.set_location('After Getting WGI Due Date',9);
            l_rif_reg.wgi_due_date := fnd_date.canonical_to_date(l_value);

-- Ratings 1

hr_utility.set_location('Getting return ratings',10);

         return_ratings
         (p_person_id            => per_rec.person_id,
          p_structure_name       => 'US Fed Perf Appraisal',
          p_effective_date       => l_effective_date,
          p_special_info1        => l_perf_appraisal1,
          p_special_info2        => l_perf_appraisal2,
          p_special_info3        => l_perf_appraisal3
         );

         l_rif_reg.rating_of_record1       := l_perf_appraisal1.segment2;
         l_rif_reg.rating_of_record1_date  := fnd_date.canonical_to_date(l_perf_appraisal1.segment3);

         l_rif_reg.rating_of_record2       := l_perf_appraisal2.segment2;
         l_rif_reg.rating_of_record2_date  := fnd_date.canonical_to_date(l_perf_appraisal2.segment3);

         l_rif_reg.rating_of_record3       := l_perf_appraisal3.segment2;
         l_rif_reg.rating_of_record3_date  := fnd_date.canonical_to_date(l_perf_appraisal3.segment3);

-- Rating Description 1

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_RATING_OF_RECORD',
            p_lookup_code    => l_rif_reg.rating_of_record1,
            p_lookup_meaning => l_rif_reg.rating_of_record1_desc,
            p_lookup_desc    => l_rating1);

-- Rating Description 2

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_RATING_OF_RECORD',
            p_lookup_code    => l_rif_reg.rating_of_record2,
            p_lookup_meaning => l_rif_reg.rating_of_record2_desc,
            p_lookup_desc    => l_rating2);


-- Rating Description 3

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_RATING_OF_RECORD',
            p_lookup_code    => l_rif_reg.rating_of_record3,
            p_lookup_meaning => l_rif_reg.rating_of_record3_desc,
            p_lookup_desc    => l_rating3);

-- Performance score

            l_rif_reg.performance_score := ceil(((nvl(to_number(l_rating1),12) + nvl(to_number(l_rating2),12) + nvl(to_number(l_rating3),12) ) / 3));

-- Adjusted SCD
hr_utility.set_location('Getting Adjusterd SCD',11);

        if l_rif_reg.service_comp_date_rif is null then
           l_rif_reg.adjusted_service_comp_date := null;
        else
           l_rif_reg.adjusted_service_comp_date := add_months(l_rif_reg.service_comp_date_rif,  -12*l_rif_reg.performance_score);
        end if;



-- Position Occupied

   ghr_history_fetch.fetch_positionei
                       (p_position_id       => per_rec.position_id,
                        p_information_type  => 'GHR_US_POS_GRP2',
                        p_date_effective    => l_effective_date,
                        p_pos_ei_data       => l_pos_ei_data2
                       );

    l_rif_reg.position_occupied := l_pos_ei_data2.poei_information3;

-- Position Occupied Description

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_POSITION_OCCUPIED',
            p_lookup_code    => l_rif_reg.position_occupied,
            p_lookup_meaning => l_rif_reg.position_occupied_desc,
            p_lookup_desc    => l_dummy_parameter);

-- Position Title
hr_utility.set_location('Getting Position Title',12);

        l_rif_reg.position_title := ghr_api.get_position_title_pos
                       (p_position_id       => per_rec.position_id,
                        p_business_group_id => per_rec.business_group_id,
                        p_effective_date    => l_effective_date
                       );

-- Position Name

         for pos_name_rec in position_name(per_rec.position_id,l_effective_date)
           loop
             l_rif_reg.position_name := pos_name_rec.name;
             exit;
           end loop;

-- Obligated Position

   ghr_history_fetch.fetch_positionei
                       (p_position_id       => per_rec.position_id,
                        p_information_type  => 'GHR_US_POS_OBLIG',
                        p_date_effective    => l_effective_date,
                        p_pos_ei_data       => l_pos_ei_data3
                       );

         l_rif_reg.obligated_posn_type       :=  l_pos_ei_data3.poei_information4;
         l_rif_reg.obligated_expiration_date :=  fnd_date.canonical_to_date(l_pos_ei_data3.poei_information3);

-- Obligated Postition Description

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_OBLIGATED_POSN_TYPE',
            p_lookup_code    => l_rif_reg.obligated_posn_type,
            p_lookup_meaning => l_rif_reg.obligated_posn_type_desc,
            p_lookup_desc    => l_dummy_parameter);


-- Organization Name

            l_rif_reg.organization_name := get_org_name(per_rec.organization_id);


-- Agency Code description

       get_lookup_meaning_desc (
            p_application_id => '800',
            p_lookup_type    => 'GHR_US_AGENCY_CODE',
            p_lookup_code    => l_rif_reg.agency_code_subelement,
            p_lookup_meaning => l_rif_reg.agency_code_subelement_desc,
            p_lookup_desc    => l_dummy_parameter);

-- RIF Register ID

	open  cur_rif_reg_seq;
        fetch cur_rif_reg_seq into l_rif_reg.rif_register_id;
        close cur_rif_reg_seq;


hr_utility.set_location('Inserting into ghr_rif_registers',13);
        INSERT INTO ghr_rif_registers
           (rif_register_id
           ,session_id
           ,rif_criteria_id
           ,effective_date
           ,person_id
           ,position_id
           ,full_name
           ,last_name
           ,first_name
           ,middle_names
           ,national_identifier
           ,tenure
	   ,tenure_desc
  	   ,tenure_group
           ,tenure_group_desc
           ,tenure_group_order
           ,veterans_pref_for_rif
           ,veterans_preference
           ,veterans_preference_desc
           ,veterans_pref_sub_group
           ,veterans_pref_sub_group_order
           ,veterans_pref_sub_group_desc
           ,service_comp_date_rif
           ,performance_score
           ,adjusted_service_comp_date
           ,occ_code
           ,occ_code_desc
           ,job_name
           ,pay_plan
           ,grade_or_level
	   ,wgi_due_date
           ,step_or_rate
          ,service_comp_date_civilian
           ,rating_of_record1
	   ,rating_of_record1_desc
	   ,rating_of_record1_date
           ,rating_of_record2
	   ,rating_of_record2_desc
	   ,rating_of_record2_date
           ,rating_of_record3
	   ,rating_of_record3_desc
	   ,rating_of_record3_date
           ,position_occupied
           ,position_occupied_desc
           ,position_title
           ,position_name
           ,obligated_posn_type
           ,obligated_posn_type_desc
	   ,organization_id
	   ,organization_name
	   ,org_structure_id
	   ,office_symbol
	   ,agency_code_subelement
	   ,agency_code_subelement_desc
           ,entered_grade_date
	   ,obligated_expiration_date
	   ,comp_area
	   ,comp_level
           )
         VALUES
           (l_rif_reg.rif_register_id
           ,userenv('SESSIONID')
           ,p_rif_criteria_id
           ,l_effective_date
           ,per_rec.person_id
           ,per_rec.position_id
           ,per_rec.full_name
           ,per_rec.last_name
           ,per_rec.first_name
           ,per_rec.middle_names
           ,per_rec.national_identifier
           ,l_rif_reg.tenure
	   ,l_rif_reg.tenure_desc
  	   ,l_rif_reg.tenure_group
	   ,l_rif_reg.tenure_group_desc
           ,l_rif_reg.tenure_group_order
           ,l_rif_reg.veterans_pref_for_rif
           ,l_rif_reg.veterans_preference
           ,l_rif_reg.veterans_preference_desc
           ,l_rif_reg.veterans_pref_sub_group
           ,l_rif_reg.veterans_pref_sub_group_order
           ,l_rif_reg.veterans_pref_sub_group_desc
           ,l_rif_reg.service_comp_date_rif
           ,l_rif_reg.performance_score
           ,l_rif_reg.adjusted_service_comp_date
           ,l_rif_reg.occ_code
           ,l_rif_reg.occ_code_desc
           ,l_rif_reg.job_name
           ,l_rif_reg.pay_plan
           ,l_rif_reg.grade_or_level
	   ,l_rif_reg.wgi_due_date
           ,l_rif_reg.step_or_rate
           ,l_rif_reg.service_comp_date_civilian
           ,l_rif_reg.rating_of_record1
	   ,l_rif_reg.rating_of_record1_desc
	   ,l_rif_reg.rating_of_record1_date
           ,l_rif_reg.rating_of_record2
	   ,l_rif_reg.rating_of_record2_desc
	   ,l_rif_reg.rating_of_record2_date
           ,l_rif_reg.rating_of_record3
	   ,l_rif_reg.rating_of_record3_desc
	   ,l_rif_reg.rating_of_record3_date
           ,l_rif_reg.position_occupied
           ,l_rif_reg.position_occupied_desc
           ,l_rif_reg.position_title
           ,l_rif_reg.position_name
           ,l_rif_reg.obligated_posn_type
           ,l_rif_reg.obligated_posn_type_desc
	   ,per_rec.organization_id
	   ,l_rif_reg.organization_name
	   ,l_rif_reg.org_structure_id
	   ,l_rif_reg.office_symbol
	   ,l_rif_reg.agency_code_subelement
	   ,l_rif_reg.agency_code_subelement_desc
           ,l_rif_reg.entered_grade_date
	   ,l_rif_reg.obligated_expiration_date
	   ,l_comp_area
	   ,l_comp_level
          );

         END IF;
-- Come here if person doesn't match all criteria and loop to get next person

   END LOOP;
hr_utility.set_location('Leaving run_register',50);


END run_register;


PROCEDURE purge_register IS
BEGIN
  DELETE
  FROM   ghr_rif_registers reg
  WHERE  reg.session_id = USERENV('SESSIONID');
  -- It really doesn't matter if it didn't actually delete any!
  COMMIT;
  --
END purge_register;
--
PROCEDURE check_unique_name (p_rif_criteria_id IN ghr_rif_criteria.rif_criteria_id%TYPE
                            ,p_name            IN ghr_rif_criteria.name%TYPE) IS
--
CURSOR cur_rif  IS
  SELECT 1
  FROM   ghr_rif_criteria rif
  WHERE  rif.name = p_name
  AND    rif.rif_criteria_id <> NVL(p_rif_criteria_id,-1);
--
BEGIN
  FOR cur_rif_rec IN cur_rif LOOP
    hr_utility.set_message(8301,'GHR_99999_RIF_NAME_NOT_UNIQUE');
    hr_utility.raise_error;
  END LOOP;
  --
END check_unique_name;


function get_org_name(p_organization_id IN per_organization_units.organization_id%TYPE)
  return varchar2 is
cursor org_units is
  select name
    from per_organization_units porg
    where porg.organization_id = p_organization_id;

l_name per_organization_units.name%TYPE;

begin
for org_units_rec in org_units
  loop
   l_name := org_units_rec.name;
   exit;
  end loop;
return l_name;
end;

FUNCTION num_of_vacancies(
                   p_organization_id           in  ghr_rif_criteria.organization_id%TYPE
                   ,p_org_structure_id         in  ghr_rif_criteria.org_structure_id%TYPE
                   ,p_office_symbol            in  ghr_rif_criteria.office_symbol%TYPE
                   ,p_agency_code_subelement   in  ghr_rif_criteria.agency_code_subelement%TYPE
                   ,p_comp_area                in  ghr_rif_criteria.comp_area%TYPE
                   ,p_comp_level               in  ghr_rif_criteria.comp_level%TYPE
                   ,p_effective_date           in  date
                       )
  return number is


cursor unassigned_pos(p_effective_date date ) is
select position_id,organization_id,business_group_id
  from hr_positions_f pos
  where not exists
      ( select 1
          from per_assignments_f asg
          where asg.position_id = pos.position_id
          and  asg.assignment_type <> 'B'
          and  p_effective_date between asg.effective_start_date
          and  asg.effective_end_date )
  and organization_id = nvl(p_organization_id,organization_id)
  and p_effective_date between pos.effective_start_date
  and pos.effective_end_date;




l_num_of_vac   number := 0;
l_pos_ei_data  per_position_extra_info%rowtype;
l_comp_area                        varchar2(30);
l_comp_level                       varchar2(30);
l_org_structure_id                 varchar2(30);
l_office_symbol                    varchar2(30);
l_agency_code_se                   varchar2(30);
l_effective_date                   date;

begin

l_effective_date := trunc(sysdate); -- In the future l_effective_date may set to p_effective_date

      for vac_rec in unassigned_pos(l_effective_date) loop

       ghr_history_fetch.fetch_positionei
         (p_position_id           => vac_rec.position_id
         ,p_information_type      => 'GHR_US_POS_GRP1'
         ,p_date_effective        => l_effective_date
         ,p_pos_ei_data           => l_pos_ei_data
         );

         l_comp_area         :=  l_pos_ei_data.poei_information20;
         l_comp_level        :=  l_pos_ei_data.poei_information9;
         l_org_structure_id  :=  l_pos_ei_data.poei_information5;
         l_office_symbol     :=  l_pos_ei_data.poei_information4;


       l_agency_code_se :=	ghr_api.get_position_agency_code_pos
	  (p_position_id         => vac_rec.position_id
	   ,p_business_group_id  => vac_rec.business_group_id
           ,p_effective_date     => l_effective_date);

--Check the Criteria

   if  nvl(l_comp_area,hr_api.g_varchar2)           =  nvl(p_comp_area,nvl(l_comp_area,hr_api.g_varchar2))        and
   nvl(l_comp_level,hr_api.g_varchar2)         =  nvl(p_comp_level,nvl(l_comp_level,hr_api.g_varchar2))       and
   nvl(l_org_structure_id,hr_api.g_varchar2)   =  nvl(p_org_structure_id,nvl(l_org_structure_id,hr_api.g_varchar2) ) and
   nvl(l_office_symbol,hr_api.g_varchar2)      =  nvl(p_office_symbol,nvl(l_office_symbol,hr_api.g_varchar2)    )    and
   nvl(l_agency_code_se,hr_api.g_varchar2 )    =  nvl(p_agency_code_subelement,nvl(l_agency_code_se,hr_api.g_varchar2 )   )
   then
             l_num_of_vac := l_num_of_vac + 1;
        end if;

end loop;

return l_num_of_vac;

end;


END ghr_rif_pkg;

/
