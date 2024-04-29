--------------------------------------------------------
--  DDL for Package Body GHR_PER_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PER_SUM" AS
/* $Header: ghpersum.pkb 120.1.12010000.2 2008/08/05 15:09:51 ubhat ship $ */
--
PROCEDURE fetch_peopleei(
    p_person_id         IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT NOCOPY VARCHAR2
   ,p_information2      IN OUT NOCOPY VARCHAR2
   ,p_information3      IN OUT NOCOPY VARCHAR2
   ,p_information4      IN OUT NOCOPY VARCHAR2
   ,p_information5      IN OUT NOCOPY VARCHAR2
   ,p_information6      IN OUT NOCOPY VARCHAR2
   ,p_information7      IN OUT NOCOPY VARCHAR2
   ,p_information8      IN OUT NOCOPY VARCHAR2
   ,p_information9      IN OUT NOCOPY VARCHAR2
   ,p_information10     IN OUT NOCOPY VARCHAR2
   ,p_information11     IN OUT NOCOPY VARCHAR2
   ,p_information12     IN OUT NOCOPY VARCHAR2
   ,p_information13     IN OUT NOCOPY VARCHAR2
   ,p_information14     IN OUT NOCOPY VARCHAR2
   ,p_information15     IN OUT NOCOPY VARCHAR2
   ,p_information16     IN OUT NOCOPY VARCHAR2
   ,p_information17     IN OUT NOCOPY VARCHAR2
   ,p_information18     IN OUT NOCOPY VARCHAR2
   ,p_information19     IN OUT NOCOPY VARCHAR2
   ,p_information20     IN OUT NOCOPY VARCHAR2
   ,p_information21     IN OUT NOCOPY VARCHAR2
   ,p_information22     IN OUT NOCOPY VARCHAR2
   ,p_information23     IN OUT NOCOPY VARCHAR2
   ,p_information24     IN OUT NOCOPY VARCHAR2
   ,p_information25     IN OUT NOCOPY VARCHAR2
   ,p_information26     IN OUT NOCOPY VARCHAR2
   ,p_information27     IN OUT NOCOPY VARCHAR2
   ,p_information28     IN OUT NOCOPY VARCHAR2
   ,p_information29     IN OUT NOCOPY VARCHAR2
   ,p_information30     IN OUT NOCOPY VARCHAR2) IS

l_per_ei_data      per_people_extra_info%rowtype;
BEGIN
  ghr_history_fetch.fetch_peopleei(
    p_person_id         => p_person_id
   ,p_information_type  => p_information_type
   ,p_date_effective    => p_date_effective
   ,p_per_ei_data       => l_per_ei_data);

  p_information1  := l_per_ei_data.pei_information1;
  p_information2  := l_per_ei_data.pei_information2;
  p_information3  := l_per_ei_data.pei_information3;
  p_information4  := l_per_ei_data.pei_information4;
  p_information5  := l_per_ei_data.pei_information5;
  p_information6  := l_per_ei_data.pei_information6;
  p_information7  := l_per_ei_data.pei_information7;
  p_information8  := l_per_ei_data.pei_information8;
  p_information9  := l_per_ei_data.pei_information9;
  p_information10 := l_per_ei_data.pei_information10;
  p_information11 := l_per_ei_data.pei_information11;
  p_information12 := l_per_ei_data.pei_information12;
  p_information13 := l_per_ei_data.pei_information13;
  p_information14 := l_per_ei_data.pei_information14;
  p_information15 := l_per_ei_data.pei_information15;
  p_information16 := l_per_ei_data.pei_information16;
  p_information17 := l_per_ei_data.pei_information17;
  p_information18 := l_per_ei_data.pei_information18;
  p_information19 := l_per_ei_data.pei_information19;
  p_information20 := l_per_ei_data.pei_information20;
  p_information21 := l_per_ei_data.pei_information21;
  p_information22 := l_per_ei_data.pei_information22;
  p_information23 := l_per_ei_data.pei_information23;
  p_information24 := l_per_ei_data.pei_information24;
  p_information25 := l_per_ei_data.pei_information25;
  p_information26 := l_per_ei_data.pei_information26;
  p_information27 := l_per_ei_data.pei_information27;
  p_information28 := l_per_ei_data.pei_information28;
  p_information29 := l_per_ei_data.pei_information29;
  p_information30 := l_per_ei_data.pei_information30;

END fetch_peopleei;

PROCEDURE fetch_asgei(
    p_assignment_id     IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT NOCOPY VARCHAR2
   ,p_information2      IN OUT NOCOPY VARCHAR2
   ,p_information3      IN OUT NOCOPY VARCHAR2
   ,p_information4      IN OUT NOCOPY VARCHAR2
   ,p_information5      IN OUT NOCOPY VARCHAR2
   ,p_information6      IN OUT NOCOPY VARCHAR2
   ,p_information7      IN OUT NOCOPY VARCHAR2
   ,p_information8      IN OUT NOCOPY VARCHAR2
   ,p_information9      IN OUT NOCOPY VARCHAR2
   ,p_information10     IN OUT NOCOPY VARCHAR2
   ,p_information11     IN OUT NOCOPY VARCHAR2
   ,p_information12     IN OUT NOCOPY VARCHAR2
   ,p_information13     IN OUT NOCOPY VARCHAR2
   ,p_information14     IN OUT NOCOPY VARCHAR2
   ,p_information15     IN OUT NOCOPY VARCHAR2
   ,p_information16     IN OUT NOCOPY VARCHAR2
   ,p_information17     IN OUT NOCOPY VARCHAR2
   ,p_information18     IN OUT NOCOPY VARCHAR2
   ,p_information19     IN OUT NOCOPY VARCHAR2
   ,p_information20     IN OUT NOCOPY VARCHAR2
   ,p_information21     IN OUT NOCOPY VARCHAR2
   ,p_information22     IN OUT NOCOPY VARCHAR2
   ,p_information23     IN OUT NOCOPY VARCHAR2
   ,p_information24     IN OUT NOCOPY VARCHAR2
   ,p_information25     IN OUT NOCOPY VARCHAR2
   ,p_information26     IN OUT NOCOPY VARCHAR2
   ,p_information27     IN OUT NOCOPY VARCHAR2
   ,p_information28     IN OUT NOCOPY VARCHAR2
   ,p_information29     IN OUT NOCOPY VARCHAR2
   ,p_information30     IN OUT NOCOPY VARCHAR2) IS

l_asg_ei_data      per_assignment_extra_info%rowtype;
BEGIN
  ghr_history_fetch.fetch_asgei(
    p_assignment_id     => p_assignment_id
   ,p_information_type  => p_information_type
   ,p_date_effective    => p_date_effective
   ,p_asg_ei_data       => l_asg_ei_data);

  p_information1  := l_asg_ei_data.aei_information1;
  p_information2  := l_asg_ei_data.aei_information2;
  p_information3  := l_asg_ei_data.aei_information3;
  p_information4  := l_asg_ei_data.aei_information4;
  p_information5  := l_asg_ei_data.aei_information5;
  p_information6  := l_asg_ei_data.aei_information6;
  p_information7  := l_asg_ei_data.aei_information7;
  p_information8  := l_asg_ei_data.aei_information8;
  p_information9  := l_asg_ei_data.aei_information9;
  p_information10 := l_asg_ei_data.aei_information10;
  p_information11 := l_asg_ei_data.aei_information11;
  p_information12 := l_asg_ei_data.aei_information12;
  p_information13 := l_asg_ei_data.aei_information13;
  p_information14 := l_asg_ei_data.aei_information14;
  p_information15 := l_asg_ei_data.aei_information15;
  p_information16 := l_asg_ei_data.aei_information16;
  p_information17 := l_asg_ei_data.aei_information17;
  p_information18 := l_asg_ei_data.aei_information18;
  p_information19 := l_asg_ei_data.aei_information19;
  p_information20 := l_asg_ei_data.aei_information20;
  p_information21 := l_asg_ei_data.aei_information21;
  p_information22 := l_asg_ei_data.aei_information22;
  p_information23 := l_asg_ei_data.aei_information23;
  p_information24 := l_asg_ei_data.aei_information24;
  p_information25 := l_asg_ei_data.aei_information25;
  p_information26 := l_asg_ei_data.aei_information26;
  p_information27 := l_asg_ei_data.aei_information27;
  p_information28 := l_asg_ei_data.aei_information28;
  p_information29 := l_asg_ei_data.aei_information29;
  p_information30 := l_asg_ei_data.aei_information30;

END fetch_asgei;

PROCEDURE fetch_positionei(
    p_position_id       IN     NUMBER
   ,p_information_type  IN     VARCHAR2
   ,p_date_effective    IN     DATE
   ,p_information1      IN OUT NOCOPY VARCHAR2
   ,p_information2      IN OUT NOCOPY VARCHAR2
   ,p_information3      IN OUT NOCOPY VARCHAR2
   ,p_information4      IN OUT NOCOPY VARCHAR2
   ,p_information5      IN OUT NOCOPY VARCHAR2
   ,p_information6      IN OUT NOCOPY VARCHAR2
   ,p_information7      IN OUT NOCOPY VARCHAR2
   ,p_information8      IN OUT NOCOPY VARCHAR2
   ,p_information9      IN OUT NOCOPY VARCHAR2
   ,p_information10     IN OUT NOCOPY VARCHAR2
   ,p_information11     IN OUT NOCOPY VARCHAR2
   ,p_information12     IN OUT NOCOPY VARCHAR2
   ,p_information13     IN OUT NOCOPY VARCHAR2
   ,p_information14     IN OUT NOCOPY VARCHAR2
   ,p_information15     IN OUT NOCOPY VARCHAR2
   ,p_information16     IN OUT NOCOPY VARCHAR2
   ,p_information17     IN OUT NOCOPY VARCHAR2
   ,p_information18     IN OUT NOCOPY VARCHAR2
   ,p_information19     IN OUT NOCOPY VARCHAR2
   ,p_information20     IN OUT NOCOPY VARCHAR2
   ,p_information21     IN OUT NOCOPY VARCHAR2
   ,p_information22     IN OUT NOCOPY VARCHAR2
   ,p_information23     IN OUT NOCOPY VARCHAR2
   ,p_information24     IN OUT NOCOPY VARCHAR2
   ,p_information25     IN OUT NOCOPY VARCHAR2
   ,p_information26     IN OUT NOCOPY VARCHAR2
   ,p_information27     IN OUT NOCOPY VARCHAR2
   ,p_information28     IN OUT NOCOPY VARCHAR2
   ,p_information29     IN OUT NOCOPY VARCHAR2
   ,p_information30     IN OUT NOCOPY VARCHAR2) IS

l_pos_ei_data      per_position_extra_info%rowtype;
BEGIN
  ghr_history_fetch.fetch_positionei(
    p_position_id       => p_position_id
   ,p_information_type  => p_information_type
   ,p_date_effective    => p_date_effective
   ,p_pos_ei_data       => l_pos_ei_data);

  p_information1  := l_pos_ei_data.poei_information1;
  p_information2  := l_pos_ei_data.poei_information2;
  p_information3  := l_pos_ei_data.poei_information3;
  p_information4  := l_pos_ei_data.poei_information4;
  p_information5  := l_pos_ei_data.poei_information5;
  p_information6  := l_pos_ei_data.poei_information6;
  p_information7  := l_pos_ei_data.poei_information7;
  p_information8  := l_pos_ei_data.poei_information8;
  p_information9  := l_pos_ei_data.poei_information9;
  p_information10 := l_pos_ei_data.poei_information10;
  p_information11 := l_pos_ei_data.poei_information11;
  p_information12 := l_pos_ei_data.poei_information12;
  p_information13 := l_pos_ei_data.poei_information13;
  p_information14 := l_pos_ei_data.poei_information14;
  p_information15 := l_pos_ei_data.poei_information15;
  p_information16 := l_pos_ei_data.poei_information16;
  p_information17 := l_pos_ei_data.poei_information17;
  p_information18 := l_pos_ei_data.poei_information18;
  p_information19 := l_pos_ei_data.poei_information19;
  p_information20 := l_pos_ei_data.poei_information20;
  p_information21 := l_pos_ei_data.poei_information21;
  p_information22 := l_pos_ei_data.poei_information22;
  p_information23 := l_pos_ei_data.poei_information23;
  p_information24 := l_pos_ei_data.poei_information24;
  p_information25 := l_pos_ei_data.poei_information25;
  p_information26 := l_pos_ei_data.poei_information26;
  p_information27 := l_pos_ei_data.poei_information27;
  p_information28 := l_pos_ei_data.poei_information28;
  p_information29 := l_pos_ei_data.poei_information29;
  p_information30 := l_pos_ei_data.poei_information30;

END fetch_positionei;
--
PROCEDURE return_special_information(
    p_person_id         IN     NUMBER
   ,p_structure_name    IN     VARCHAR2
   ,p_effective_date    IN     DATE
   ,p_segment1          IN OUT NOCOPY VARCHAR2
   ,p_segment2          IN OUT NOCOPY VARCHAR2
   ,p_segment3          IN OUT NOCOPY VARCHAR2
   ,p_segment4          IN OUT NOCOPY VARCHAR2
   ,p_segment5          IN OUT NOCOPY VARCHAR2
   ,p_segment6          IN OUT NOCOPY VARCHAR2
   ,p_segment7          IN OUT NOCOPY VARCHAR2
   ,p_segment8          IN OUT NOCOPY VARCHAR2
   ,p_segment9          IN OUT NOCOPY VARCHAR2
   ,p_segment10         IN OUT NOCOPY VARCHAR2
   ,p_segment11         IN OUT NOCOPY VARCHAR2
   ,p_segment12         IN OUT NOCOPY VARCHAR2
   ,p_segment13         IN OUT NOCOPY VARCHAR2
   ,p_segment14         IN OUT NOCOPY VARCHAR2
   ,p_segment15         IN OUT NOCOPY VARCHAR2
   ,p_segment16         IN OUT NOCOPY VARCHAR2
   ,p_segment17         IN OUT NOCOPY VARCHAR2
   ,p_segment18         IN OUT NOCOPY VARCHAR2
   ,p_segment19         IN OUT NOCOPY VARCHAR2
   ,p_segment20         IN OUT NOCOPY VARCHAR2
   ,p_segment21         IN OUT NOCOPY VARCHAR2
   ,p_segment22         IN OUT NOCOPY VARCHAR2
   ,p_segment23         IN OUT NOCOPY VARCHAR2
   ,p_segment24         IN OUT NOCOPY VARCHAR2
   ,p_segment25         IN OUT NOCOPY VARCHAR2
   ,p_segment26         IN OUT NOCOPY VARCHAR2
   ,p_segment27         IN OUT NOCOPY VARCHAR2
   ,p_segment28         IN OUT NOCOPY VARCHAR2
   ,p_segment29         IN OUT NOCOPY VARCHAR2
   ,p_segment30         IN OUT NOCOPY VARCHAR2
   ,p_person_analysis_id    IN OUT NOCOPY NUMBER
   ,p_object_version_number IN OUT NOCOPY NUMBER) IS

l_special_information_type ghr_api.special_information_type;
BEGIN
  ghr_api.return_special_information(p_person_id
                                    ,p_structure_name
                                    ,p_effective_date
                                    ,l_special_information_type);
  --
  p_segment1              := l_special_information_type.segment1;
  p_segment2              := l_special_information_type.segment2;
  p_segment3              := l_special_information_type.segment3;
  p_segment4              := l_special_information_type.segment4;
  p_segment5              := l_special_information_type.segment5;
  p_segment6              := l_special_information_type.segment6;
  p_segment7              := l_special_information_type.segment7;
  p_segment8              := l_special_information_type.segment8;
  p_segment9              := l_special_information_type.segment9;
  p_segment10             := l_special_information_type.segment10;
  p_segment11             := l_special_information_type.segment11;
  p_segment12             := l_special_information_type.segment12;
  p_segment13             := l_special_information_type.segment13;
  p_segment14             := l_special_information_type.segment14;
  p_segment15             := l_special_information_type.segment15;
  p_segment16             := l_special_information_type.segment16;
  p_segment17             := l_special_information_type.segment17;
  p_segment18             := l_special_information_type.segment18;
  p_segment19             := l_special_information_type.segment19;
  p_segment20             := l_special_information_type.segment20;
  p_segment21             := l_special_information_type.segment21;
  p_segment22             := l_special_information_type.segment22;
  p_segment23             := l_special_information_type.segment23;
  p_segment24             := l_special_information_type.segment24;
  p_segment25             := l_special_information_type.segment25;
  p_segment26             := l_special_information_type.segment26;
  p_segment27             := l_special_information_type.segment27;
  p_segment28             := l_special_information_type.segment28;
  p_segment29             := l_special_information_type.segment29;
  p_segment30             := l_special_information_type.segment30;
  p_person_analysis_id    := l_special_information_type.person_analysis_id;
  p_object_version_number := l_special_information_type.object_version_number;

END return_special_information;
--
PROCEDURE get_grade_details (p_grade_id       IN  NUMBER
                            ,p_grade_name     IN OUT NOCOPY VARCHAR2
                            ,p_pay_plan       IN OUT NOCOPY VARCHAR2
                            ,p_grade_or_level IN OUT NOCOPY VARCHAR2) IS
--
CURSOR cur_grd IS
  SELECT gdf.segment1 pay_plan
        ,gdf.segment2 grade_or_level
        ,grd.name     grade_name
  FROM  per_grade_definitions gdf
       ,per_grades            grd
  WHERE grd.grade_id = p_grade_id
  AND   grd.grade_definition_id = gdf.grade_definition_id;
--
BEGIN

  FOR cur_grd_rec IN cur_grd LOOP
    p_grade_name     := cur_grd_rec.grade_name;
    p_pay_plan       := cur_grd_rec.pay_plan;
    p_grade_or_level := cur_grd_rec.grade_or_level;
  END LOOP;

END get_grade_details;
--
PROCEDURE get_retained_grade_details (p_person_id            IN     NUMBER
                                     ,p_effective_date       IN     DATE
                                     ,p_person_extra_info_id IN OUT NOCOPY NUMBER
                                     ,p_date_from            IN OUT NOCOPY DATE
                                     ,p_date_to              IN OUT NOCOPY DATE
                                     ,p_grade_or_level       IN OUT NOCOPY VARCHAR2
                                     ,p_step_or_rate         IN OUT NOCOPY VARCHAR2
                                     ,p_pay_plan             IN OUT NOCOPY VARCHAR2
                                     ,p_pay_table_id         IN OUT NOCOPY VARCHAR2
                                     ,p_pay_basis            IN OUT NOCOPY VARCHAR2
                                     ,p_temp_step            IN OUT NOCOPY VARCHAR2
                                      ) IS
CURSOR cur_pei IS
  SELECT pei.pei_information1 date_from
        ,pei.pei_information2 date_to
  FROM   per_people_extra_info pei
  WHERE  pei.person_extra_info_id = p_person_extra_info_id;

l_retained_grade_rec ghr_pay_calc.retained_grade_rec_type;

BEGIN
  l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details
                                             (p_person_id      => p_person_id
                                             ,p_effective_date => p_effective_date);

  IF l_retained_grade_rec.person_extra_info_id IS NOT NULL THEN
    p_person_extra_info_id := l_retained_grade_rec.person_extra_info_id;
    FOR cur_pei_rec IN cur_pei LOOP
      p_date_from := fnd_date.canonical_to_date(cur_pei_rec.date_from);
      p_date_to   := fnd_date.canonical_to_date(cur_pei_rec.date_to);
    END LOOP;
    p_grade_or_level       := l_retained_grade_rec.grade_or_level;
    p_step_or_rate         := l_retained_grade_rec.step_or_rate;
    p_pay_plan             := l_retained_grade_rec.pay_plan;
    p_pay_table_id         := SUBSTR(ghr_pay_calc.get_user_table_name(l_retained_grade_rec.user_table_id),1,4);
    p_pay_basis            := l_retained_grade_rec.pay_basis;
    p_temp_step            := l_retained_grade_rec.temp_step;
  END IF;
EXCEPTION
  WHEN ghr_pay_calc.pay_calc_message THEN
    -- This just means nothing was returned, no need to worry about this!
    NULL;
END ;
--
FUNCTION further_retained_details_exist(p_person_id            IN NUMBER
                                       ,p_person_extra_info_id IN NUMBER)
  RETURN BOOLEAN IS
--
CURSOR cur_pei IS
  SELECT 1
  FROM   per_people_extra_info pei
  WHERE  pei.person_id             = p_person_id
  AND    pei.information_type      = 'GHR_US_RETAINED_GRADE'
  AND    pei.person_extra_info_id <> NVL(p_person_extra_info_id,-999);
--
BEGIN
  FOR cur_pei_rec IN cur_pei LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END further_retained_details_exist;
--
FUNCTION get_poi_desc (p_personnel_office_id IN NUMBER)
  RETURN VARCHAR2 IS
--
CURSOR cur_poi IS
  SELECT poi.description
  FROM   ghr_pois poi
  WHERE  poi.personnel_office_id = p_personnel_office_id;

BEGIN
  FOR cur_poi_rec IN cur_poi LOOP
    RETURN(cur_poi_rec.description);
  END LOOP;
  --
  RETURN(NULL);
  --
END get_poi_desc;
--
PROCEDURE get_duty_station_details (p_location_id                  IN     NUMBER
                                   ,p_effective_date               IN     DATE
                                   ,p_duty_sation_code             IN OUT NOCOPY VARCHAR2
                                   ,p_duty_station_desc            IN OUT NOCOPY VARCHAR2
                                   ,p_locality_pay_area            IN OUT NOCOPY VARCHAR2
                                   ,p_locality_pay_area_percentage IN OUT NOCOPY NUMBER
                                    ) IS
CURSOR cur_ds IS
  SELECT dst.duty_station_code
        ,dstv.duty_station_desc
        ,lpa.short_name
        ,lpa.adjustment_percentage
  FROM   ghr_locality_pay_areas_f lpa
        ,ghr_duty_stations_v      dstv
        ,ghr_duty_stations_f      dst
        ,hr_location_extra_info   lei
  WHERE lei.location_id = p_location_id
  AND   lei.information_type = 'GHR_US_LOC_INFORMATION'
  AND   dst.duty_station_id = lei.lei_information3
  AND   NVL(p_effective_date,TRUNC(sysdate)) BETWEEN dst.effective_start_date AND dst.effective_end_date
  AND   dstv.duty_station_id = dst.duty_station_id
  AND   NVL(p_effective_date,TRUNC(sysdate)) BETWEEN dstv.effective_start_date AND dstv.effective_end_date
  AND   dst.locality_pay_area_id = lpa.locality_pay_area_id
  AND   NVL(p_effective_date,TRUNC(sysdate)) BETWEEN lpa.effective_start_date AND lpa.effective_end_date;

BEGIN
  FOR cur_ds_rec IN cur_ds LOOP
    p_duty_sation_code             := cur_ds_rec.duty_station_code;
    p_duty_station_desc            := cur_ds_rec.duty_station_desc;
    p_locality_pay_area            := cur_ds_rec.short_name;
    p_locality_pay_area_percentage := cur_ds_rec.adjustment_percentage;
  END LOOP;
--
END get_duty_station_details;
--
PROCEDURE get_org_details (p_org_id    IN     NUMBER
                          ,p_org_name  IN OUT NOCOPY VARCHAR2
                          ,p_org_line1 IN OUT NOCOPY VARCHAR2
                          ,p_org_line2 IN OUT NOCOPY VARCHAR2
                          ,p_org_line3 IN OUT NOCOPY VARCHAR2
                          ,p_org_line4 IN OUT NOCOPY VARCHAR2
                          ,p_org_line5 IN OUT NOCOPY VARCHAR2
                          ,p_org_line6 IN OUT NOCOPY VARCHAR2) IS
--
CURSOR cur_org IS
  SELECT org.name
  FROM   hr_organization_units org
  WHERE  org.organization_id = p_org_id;

CURSOR cur_oi IS
  SELECT oi.org_information5  org_line1
        ,oi.org_information6  org_line2
        ,oi.org_information7  org_line3
        ,oi.org_information8  org_line4
        ,oi.org_information9  org_line5
        ,oi.org_information10 org_line6
  FROM  hr_organization_information oi
  WHERE oi.organization_id = p_org_id
  AND   oi.org_information_context = 'GHR_US_ORG_REPORTING_INFO';
--
BEGIN
  FOR cur_org_rec IN cur_org LOOP
    p_org_name := cur_org_rec.name;
  END LOOP;
  --
  FOR cur_oi_rec IN cur_oi LOOP
    p_org_line1 := cur_oi_rec.org_line1;
    p_org_line2 := cur_oi_rec.org_line2;
    p_org_line3 := cur_oi_rec.org_line3;
    p_org_line4 := cur_oi_rec.org_line4;
    p_org_line5 := cur_oi_rec.org_line5;
    p_org_line6 := cur_oi_rec.org_line6;
  END LOOP;
--
END get_org_details;
--
PROCEDURE get_element_details (p_element_name         IN     VARCHAR2
                              ,p_input_value_name     IN     VARCHAR2
                              ,p_assignment_id        IN     NUMBER
                              ,p_effective_date       IN     DATE
                              ,p_value                IN OUT NOCOPY VARCHAR2
                              ,p_effective_start_date IN OUT NOCOPY DATE
			      ,p_business_group_id    IN     NUMBER) IS
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
  WHERE  p_effective_date BETWEEN elt.effective_start_date AND elt.effective_end_date
  AND    p_effective_date BETWEEN ipv.effective_start_date AND ipv.effective_end_date
  AND    p_effective_date BETWEEN ele.effective_start_date AND ele.effective_end_date
  AND    p_effective_date BETWEEN eev.effective_start_date AND eev.effective_end_date
  AND    elt.element_type_id    = ipv.element_type_id
  AND    upper(elt.element_name)= upper(p_element_name)
  AND    ipv.input_value_id     = eev.input_value_id
  AND    ele.assignment_id      = p_assignment_id
  AND    ele.element_entry_id+0 = eev.element_entry_id
  AND    upper(ipv.name )       = upper(p_input_value_name)
--  AND    NVL(elt.business_group_id,0)  = NVL(ipv.business_group_id,0)
  AND    (elt.business_group_id is NULL or elt.business_group_id  = p_bg_id);
  --

-- Commented the below cursor as a part of bug 4016362
/*Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;
--
 ll_bg_id                    NUMBER; */

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

-- Commented this code as a part of Bug 4016362
/*  For BG_rec in Cur_BG(p_assignment_id,ll_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;*/

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
                                           p_business_group_id  => p_business_group_id,  -- Bug 4016362
	                                   p_effective_date     => ll_effective_date);

-- Bug 4016362 : Commented this ELSEIF condition as the condition in IF and ELSIF clauses are mutually exclusive.

/* ELSIF (fnd_profile.value('HR_USER_TYPE') <> 'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE') = 'INT'))) THEN*/
 ELSE                                                                                -- Bug 4016362
    hr_utility.set_location('HR USER or PAYROLL User without BSR element -- from elt name -- ', 1);
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => p_business_group_id,  -- Bug 4016362
	                                   p_effective_date     => ll_effective_date,
	                                   p_pay_basis          => NULL);

 END IF;

--
--
  FOR cur_ele_rec IN cur_ele(l_new_element_name,p_business_group_id) LOOP   -- Bug 4016362
    p_value                := cur_ele_rec.screen_entry_value;
    p_effective_start_date := cur_ele_rec.effective_start_date;
    Exit;                                                                   -- Bug 4016362
  END LOOP;
  --
END get_element_details;
--
PROCEDURE get_status_code (p_status         IN   VARCHAR2
                          ,p_status_code    OUT NOCOPY  VARCHAR2) IS

  CURSOR cur_status IS
    SELECT fcl.lookup_code
    FROM   fnd_common_lookups fcl
    WHERE  fcl.APPLICATION_ID = 800
    AND fcl.LOOKUP_TYPE = 'GHR_US_TSP_STATUS'
    AND fcl.meaning = p_status;

  BEGIN
  --

  FOR cur_status_rec IN cur_status LOOP
      p_status_code := cur_status_rec.lookup_code;
  END LOOP;

END get_status_code;
--
PROCEDURE get_element_entry_values (p_element_entry_id     IN     NUMBER
                                   ,p_input_value_name     IN     VARCHAR2
                                   ,p_effective_date       IN     DATE
                                   ,p_value                IN OUT NOCOPY VARCHAR2
                                   ,p_effective_start_date IN OUT NOCOPY DATE) IS
--
-- NOTE: The effective date we get is that of the individual input value not the effective
-- date of the whole element as seen in the element screen.
--
CURSOR cur_ele_values IS
  SELECT  eev.screen_entry_value
         ,eev.effective_start_date
  FROM   pay_element_entry_values_f eev
         ,pay_input_values_f ipv
  WHERE  p_input_value_name = ipv.name
  AND    p_effective_date BETWEEN ipv.effective_start_date AND ipv.effective_end_date
  AND    ipv.input_value_id = eev.input_value_id
  AND    p_element_entry_id = eev.element_entry_id
  AND    p_effective_date BETWEEN eev.effective_start_date AND eev.effective_end_date;

BEGIN
  --
  FOR cur_ele_values_rec IN cur_ele_values LOOP
    p_value                := cur_ele_values_rec.screen_entry_value;
    p_effective_start_date := cur_ele_values_rec.effective_start_date;
  END LOOP;
  --
END get_element_entry_values;
--
--
FUNCTION info_type_is_valid (p_application_id       IN NUMBER
                            ,p_responsibility_id    IN NUMBER
                            ,p_info_type_table_name IN VARCHAR2
                            ,p_information_type     IN VARCHAR2)
  RETURN BOOLEAN IS
--
CURSOR cur_its IS
  SELECT 1
  FROM   per_info_type_security its
  WHERE  its.application_id       = p_application_id
  AND    its.responsibility_id    = p_responsibility_id
  AND    its.info_type_table_name = p_info_type_table_name
  AND    its.information_type     = p_information_type;
--
BEGIN
--
  FOR cur_its_rec IN cur_its LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
END info_type_is_valid;
--
FUNCTION get_workflow_id(p_workflow_name IN VARCHAR2)
  RETURN NUMBER IS

  CURSOR cur_workflow_id IS
    SELECT hrw.workflow_id
    FROM   hr_workflows hrw
    WHERE  hrw.workflow_name = p_workflow_name;

  BEGIN
  --

  FOR cur_workflow_id_rec IN cur_workflow_id LOOP
      RETURN(cur_workflow_id_rec.workflow_id);
  END LOOP;

END get_workflow_id;
--
PROCEDURE get_noa_code (p_pa_request_id  IN   NUMBER
                       ,p_noa_code       OUT NOCOPY  VARCHAR2) IS

  CURSOR cur_noa_code IS
    SELECT rpa.first_noa_code
    FROM   ghr_pa_requests rpa
    WHERE  rpa.pa_request_id = p_pa_request_id;

  BEGIN
  --

  FOR cur_noa_code_rec IN cur_noa_code LOOP
      p_noa_code := cur_noa_code_rec.first_noa_code;
  END LOOP;

END get_noa_code;

--Begin Bug# 6850492
PROCEDURE get_second_noa_code (p_pa_request_id  IN   NUMBER
                       ,p_second_noa_code       OUT NOCOPY  VARCHAR2) IS

  CURSOR cur_second_noa_code IS
    SELECT rpa.second_noa_code
    FROM   ghr_pa_requests rpa
    WHERE  rpa.pa_request_id = p_pa_request_id;

  BEGIN
  --

  FOR cur_second_noa_code_rec IN cur_second_noa_code LOOP
      p_second_noa_code := cur_second_noa_code_rec.second_noa_code;
  END LOOP;

END get_second_noa_code;
--End Bug# 6850492
--
PROCEDURE get_dob_asgstat(p_assignment_id    IN     NUMBER
                          ,p_effective_date  IN     DATE
                          ,p_dob             OUT NOCOPY    DATE
                          ,p_system_status   OUT NOCOPY    VARCHAR2) IS

CURSOR cur_dob_asgstat IS
 SELECT per.date_of_birth
,ast.per_system_status
FROM per_assignment_status_types ast
,per_assignments_f           asg
,per_people_f                per
WHERE asg.assignment_id = p_assignment_id
AND asg.person_id = per.person_id
AND p_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date
AND ast.assignment_status_type_id = asg.assignment_status_type_id
AND asg.primary_flag = 'Y'
AND asg.assignment_type = 'E';

BEGIN
  --
  FOR cur_dob_asgstat_rec IN cur_dob_asgstat LOOP
    p_dob                := cur_dob_asgstat_rec.date_of_birth;
    p_system_status      := cur_dob_asgstat_rec.per_system_status;
  END LOOP;

null;
END get_dob_asgstat;
--
PROCEDURE get_current_emp_flag (p_effective_date     IN         DATE
                               ,p_person_id          IN         NUMBER
                               ,p_current_emp_flag   OUT NOCOPY VARCHAR2) IS

CURSOR cur_emp_flag IS
 select current_employee_flag from per_all_people_f
 where person_id = p_person_id
 and p_effective_date
  between effective_start_date and effective_end_date;

BEGIN
  --
  FOR cur_emp_flag_rec IN cur_emp_flag LOOP
    p_current_emp_flag := cur_emp_flag_rec.current_employee_flag;
  END LOOP;

null;
END get_current_emp_flag;
--

PROCEDURE get_assignment_id(p_effective_date     IN         DATE
                           ,p_person_id          IN         NUMBER
                           ,p_assignment_id      OUT NOCOPY NUMBER) IS

CURSOR cur_emp_assignment IS
 select assignment_id from per_all_assignments_f paf
 where paf.person_id = p_person_id
 and p_effective_date
  between paf.effective_start_date and paf.effective_end_date;

BEGIN
  --
  FOR cur_emp_assignment_rec IN cur_emp_assignment LOOP
    p_assignment_id := cur_emp_assignment_rec.assignment_id;
  END LOOP;

null;
END get_assignment_id;
--

FUNCTION get_payroll_period_start_date (p_assignment_id IN NUMBER
                                       ,p_effective_date IN DATE)
  RETURN DATE IS

CURSOR cur_payroll_start IS
 select start_date
 from per_time_periods ptp
 where payroll_id in (select payroll_id
                      from per_assignments_f
                      where assignment_id = p_assignment_id
                      and trunc(p_effective_date) between effective_start_date
                                                  and     effective_end_date)
 and trunc(p_effective_date) between start_date and end_date;

BEGIN
--
  FOR cur_payroll_start_rec IN cur_payroll_start LOOP
    RETURN(cur_payroll_start_rec.start_date);
  END LOOP;

END get_payroll_period_start_date;
--

END ghr_per_sum;

/
