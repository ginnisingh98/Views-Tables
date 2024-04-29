--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINTS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINTS2_PKG" AS
/* $Header: ghrcomp2.pkb 120.0.12010000.1 2008/07/28 10:38:02 appldev ship $ */

-- Get Fullname and SSN
PROCEDURE get_fullname_ssn (p_complainant_person_id IN     NUMBER
                           ,p_effective_date        IN     DATE
                           ,p_full_name             IN OUT  NOCOPY VARCHAR2
                           ,p_ssn                   IN OUT  NOCOPY VARCHAR2) IS

l_full_name           per_people_f.full_name%TYPE := NULL;
l_ssn                 per_people_f.national_identifier%TYPE := NULL;
l_record_found        BOOLEAN := FALSE;

/*
CURSOR cur_cper IS
  SELECT per.full_name
        ,per.national_identifier
  FROM   per_people_v      per
  WHERE  p_complainant_person_id = per.person_id
  AND    p_effective_date between per.effective_start_date and per.effective_end_date; */
 -- Above commented by Sundar for performance changes
CURSOR cur_cper IS
  SELECT per.full_name
        ,per.national_identifier
  FROM   per_people_f      per
  WHERE per.person_id = p_complainant_person_id
  AND p_effective_date between per.effective_start_date and per.effective_end_date;
--  NOCOPY variables
l_nc_full_name per_people_f.full_name%TYPE;
l_nc_ssn per_people_f.national_identifier%TYPE;

BEGIN
	-- NOCOPY Changes
	l_nc_full_name := p_full_name;
	l_nc_ssn := p_ssn;

  FOR cur_cper_rec IN cur_cper LOOP
    IF not l_record_found THEN
      l_full_name          :=  cur_cper_rec.full_name;
      l_ssn                :=  cur_cper_rec.national_identifier;
      l_record_found       :=  TRUE;
    ELSE
      l_full_name          :=  null;
      l_ssn                :=  null;
      EXIT;
    END IF;
  END LOOP;

  p_full_name           := l_full_name;
  p_ssn                 := l_ssn;
EXCEPTION
	WHEN OTHERS THEN
		p_full_name := l_nc_full_name;
		p_ssn := l_nc_ssn;
END get_fullname_ssn;
--

-- Get Assignment IDs
PROCEDURE get_asg_ids  (p_complainant_person_id IN     NUMBER
                        ,p_effective_date        IN     DATE
                        ,p_asg_id                IN OUT NOCOPY NUMBER
                        ,p_posn_id               IN OUT NOCOPY NUMBER
                        ,p_grade_id              IN OUT NOCOPY NUMBER
                        ,p_job_id                IN OUT NOCOPY NUMBER)IS

l_asg_id              per_assignments_f.assignment_id%TYPE := NULL;
l_posn_id             per_assignments_f.position_id%TYPE := NULL;
l_grade_id            per_assignments_f.grade_id%TYPE := NULL;
l_job_id              per_assignments_f.job_id%TYPE := NULL;
l_record_found        BOOLEAN := FALSE;

CURSOR cur_casg IS
  SELECT pas.assignment_id, pas.position_id, pas.grade_id, pas.job_id
  FROM   per_assignments_f pas
  WHERE  p_complainant_person_id = pas.person_id
  AND    assignment_type <> 'B'
  AND    p_effective_date between pas.effective_start_date and pas.effective_end_date;

-- NOCOPY Variables
l_nc_asg_id NUMBER;
l_nc_posn_id NUMBER;
l_nc_grade_id NUMBER;
l_nc_job_id NUMBER;

BEGIN
	-- NOCOPY Changes
	l_nc_asg_id := p_asg_id;
	l_nc_posn_id := p_posn_id;
	l_nc_grade_id := p_grade_id;
	l_nc_job_id := p_job_id;

  FOR cur_casg_rec IN cur_casg LOOP
    IF not l_record_found THEN
      l_asg_id         :=  cur_casg_rec.assignment_id;
      l_posn_id        :=  cur_casg_rec.position_id;
      l_grade_id       :=  cur_casg_rec.grade_id;
      l_job_id         :=  cur_casg_rec.job_id;
      l_record_found   :=  TRUE;
      EXIT;
    ELSE
      l_asg_id         :=  null;
      l_posn_id        :=  null;
      l_grade_id       :=  null;
      l_job_id         :=  null;
      EXIT;
    END IF;
  END LOOP;

  p_asg_id             := l_asg_id;
  p_posn_id            := l_posn_id;
  p_grade_id           := l_grade_id;
  p_job_id             := l_job_id;
EXCEPTION
	WHEN OTHERS THEN
		p_asg_id := l_nc_asg_id;
		p_posn_id := l_nc_posn_id;
		p_grade_id := l_nc_grade_id;
		p_job_id := l_nc_job_id;
END get_asg_ids;
--

-- Fetch People EI
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
-- NOCOPY Variables
l_information1 per_people_extra_info.pei_information1%type:=   p_information1 ;
l_information2  per_people_extra_info.pei_information2%type:=  p_information2 ;
l_information3 per_people_extra_info.pei_information3%type:=   p_information3 ;
l_information4 per_people_extra_info.pei_information4%type:=   p_information4 ;
l_information5 per_people_extra_info.pei_information5%type:=   p_information5 ;
l_information6 per_people_extra_info.pei_information6%type:=   p_information6 ;
l_information7 per_people_extra_info.pei_information7%type:=   p_information7 ;
l_information8 per_people_extra_info.pei_information8%type:=   p_information8 ;
l_information9 per_people_extra_info.pei_information9%type:=   p_information9 ;
l_information10 per_people_extra_info.pei_information10%type:= p_information10;
l_information11 per_people_extra_info.pei_information11%type:= p_information11;
l_information12 per_people_extra_info.pei_information12%type:= p_information12;
l_information13 per_people_extra_info.pei_information13%type:= p_information13;
l_information14 per_people_extra_info.pei_information14%type:= p_information14;
l_information15 per_people_extra_info.pei_information15%type:= p_information15;
l_information16 per_people_extra_info.pei_information16%type:= p_information16;
l_information17 per_people_extra_info.pei_information17%type:= p_information17;
l_information18 per_people_extra_info.pei_information18%type:= p_information18;
l_information19 per_people_extra_info.pei_information19%type:= p_information19;
l_information20 per_people_extra_info.pei_information20%type:= p_information20;
l_information21 per_people_extra_info.pei_information21%type:= p_information21;
l_information22 per_people_extra_info.pei_information22%type:= p_information22;
l_information23 per_people_extra_info.pei_information23%type:= p_information23;
l_information24 per_people_extra_info.pei_information24%type:= p_information24;
l_information25 per_people_extra_info.pei_information25%type:= p_information25;
l_information26 per_people_extra_info.pei_information26%type:= p_information26;
l_information27 per_people_extra_info.pei_information27%type:= p_information27;
l_information28 per_people_extra_info.pei_information28%type:= p_information28;
l_information29 per_people_extra_info.pei_information29%type:= p_information29;
l_information30 per_people_extra_info.pei_information30%type:= p_information30;

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
EXCEPTION
	WHEN OTHERS THEN
		p_information1    :=  l_information1 ;
		p_information2    :=  l_information2 ;
		p_information3    :=  l_information3 ;
		p_information4    :=  l_information4 ;
		p_information5    :=  l_information5 ;
		p_information6    :=  l_information6 ;
		p_information7    :=  l_information7 ;
		p_information8    :=  l_information8 ;
		p_information9    :=  l_information9 ;
		p_information10   :=  l_information10;
		p_information11   :=  l_information11;
		p_information12   :=  l_information12;
		p_information13   :=  l_information13;
		p_information14   :=  l_information14;
		p_information15   :=  l_information15;
		p_information16   :=  l_information16;
		p_information17   :=  l_information17;
		p_information18   :=  l_information18;
		p_information19   :=  l_information19;
		p_information20   :=  l_information20;
		p_information21   :=  l_information21;
		p_information22   :=  l_information22;
		p_information23   :=  l_information23;
		p_information24   :=  l_information24;
		p_information25   :=  l_information25;
		p_information26   :=  l_information26;
		p_information27   :=  l_information27;
		p_information28   :=  l_information28;
		p_information29   :=  l_information29;
		p_information30   :=  l_information30;
END fetch_peopleei;
--

-- Fetch Assignment EI
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

-- NOCOPY Variables
l_information1 per_assignment_extra_info.aei_information1%type :=    p_information1 ;
l_information2 per_assignment_extra_info.aei_information2%type :=  	 p_information2  ;
l_information3 per_assignment_extra_info.aei_information3%type :=  	 p_information3  ;
l_information4 per_assignment_extra_info.aei_information4%type :=  	 p_information4  ;
l_information5 per_assignment_extra_info.aei_information5%type :=  	 p_information5  ;
l_information6 per_assignment_extra_info.aei_information6%type :=  	 p_information6  ;
l_information7 per_assignment_extra_info.aei_information7%type :=  	 p_information7  ;
l_information8 per_assignment_extra_info.aei_information8%type :=  	 p_information8  ;
l_information9 per_assignment_extra_info.aei_information9%type :=  	 p_information9  ;
l_information10 per_assignment_extra_info.aei_information10%type :=  p_information10 ;
l_information11	per_assignment_extra_info.aei_information11%type :=  p_information11 ;
l_information12	per_assignment_extra_info.aei_information12%type :=  p_information12 ;
l_information13	per_assignment_extra_info.aei_information13%type :=  p_information13 ;
l_information14	per_assignment_extra_info.aei_information14%type :=  p_information14 ;
l_information15	per_assignment_extra_info.aei_information15%type :=  p_information15 ;
l_information16	per_assignment_extra_info.aei_information16%type :=  p_information16 ;
l_information17	per_assignment_extra_info.aei_information17%type :=  p_information17 ;
l_information18	per_assignment_extra_info.aei_information18%type :=  p_information18 ;
l_information19 per_assignment_extra_info.aei_information19%type :=  p_information19 ;
l_information20	per_assignment_extra_info.aei_information20%type :=  p_information20 ;
l_information21	per_assignment_extra_info.aei_information21%type :=  p_information21 ;
l_information22	per_assignment_extra_info.aei_information22%type :=  p_information22 ;
l_information23	per_assignment_extra_info.aei_information23%type :=  p_information23 ;
l_information24	per_assignment_extra_info.aei_information24%type :=  p_information24 ;
l_information25	per_assignment_extra_info.aei_information25%type :=  p_information25 ;
l_information26	per_assignment_extra_info.aei_information26%type :=  p_information26 ;
l_information27	per_assignment_extra_info.aei_information27%type :=  p_information27 ;
l_information28 per_assignment_extra_info.aei_information28%type :=  p_information28 ;
l_information29	per_assignment_extra_info.aei_information29%type :=  p_information29 ;
l_information30	per_assignment_extra_info.aei_information30%type :=  p_information30 ;

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
EXCEPTION
	WHEN OTHERS THEN
		p_information1    :=  l_information1 ;
		p_information2    :=  l_information2 ;
		p_information3    :=  l_information3 ;
		p_information4    :=  l_information4 ;
		p_information5    :=  l_information5 ;
		p_information6    :=  l_information6 ;
		p_information7    :=  l_information7 ;
		p_information8    :=  l_information8 ;
		p_information9    :=  l_information9 ;
		p_information10   :=  l_information10;
		p_information11   :=  l_information11;
		p_information12   :=  l_information12;
		p_information13   :=  l_information13;
		p_information14   :=  l_information14;
		p_information15   :=  l_information15;
		p_information16   :=  l_information16;
		p_information17   :=  l_information17;
		p_information18   :=  l_information18;
		p_information19   :=  l_information19;
		p_information20   :=  l_information20;
		p_information21   :=  l_information21;
		p_information22   :=  l_information22;
		p_information23   :=  l_information23;
		p_information24   :=  l_information24;
		p_information25   :=  l_information25;
		p_information26   :=  l_information26;
		p_information27   :=  l_information27;
		p_information28   :=  l_information28;
		p_information29   :=  l_information29;
		p_information30   :=  l_information30;
END fetch_asgei;
--

-- Fetch Position EI
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
-- NOCOPY Changes
l_information1  per_position_extra_info.poei_information1%type :=    p_information1 ;
l_information2  per_position_extra_info.poei_information2%type := 	 p_information2  ;
l_information3  per_position_extra_info.poei_information3%type := 	 p_information3  ;
l_information4  per_position_extra_info.poei_information4%type := 	 p_information4  ;
l_information5  per_position_extra_info.poei_information5%type := 	 p_information5  ;
l_information6  per_position_extra_info.poei_information6%type :=	 p_information6  ;
l_information7 	per_position_extra_info.poei_information7%type :=	 p_information7  ;
l_information8 	per_position_extra_info.poei_information8%type :=	 p_information8  ;
l_information9 	per_position_extra_info.poei_information9%type :=	 p_information9  ;
l_information10	per_position_extra_info.poei_information10%type :=	 p_information10 ;
l_information11 per_position_extra_info.poei_information11%type :=	 p_information11 ;
l_information12	per_position_extra_info.poei_information12%type :=	 p_information12 ;
l_information13	per_position_extra_info.poei_information13%type :=	 p_information13 ;
l_information14	per_position_extra_info.poei_information14%type :=	 p_information14 ;
l_information15	per_position_extra_info.poei_information15%type :=	 p_information15 ;
l_information16 per_position_extra_info.poei_information16%type :=	 p_information16 ;
l_information17	per_position_extra_info.poei_information17%type :=	 p_information17 ;
l_information18	per_position_extra_info.poei_information18%type :=	 p_information18 ;
l_information19	per_position_extra_info.poei_information19%type :=	 p_information19 ;
l_information20	per_position_extra_info.poei_information20%type :=	 p_information20 ;
l_information21 per_position_extra_info.poei_information21%type :=	 p_information21 ;
l_information22	per_position_extra_info.poei_information22%type :=	 p_information22 ;
l_information23	per_position_extra_info.poei_information23%type :=	 p_information23 ;
l_information24	per_position_extra_info.poei_information24%type :=	 p_information24 ;
l_information25	per_position_extra_info.poei_information25%type :=	 p_information25 ;
l_information26 per_position_extra_info.poei_information26%type :=	 p_information26 ;
l_information27	per_position_extra_info.poei_information27%type :=	 p_information27 ;
l_information28	per_position_extra_info.poei_information28%type :=	 p_information28 ;
l_information29	per_position_extra_info.poei_information29%type :=	 p_information29 ;
l_information30	per_position_extra_info.poei_information30%type :=	 p_information30 ;

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

EXCEPTION
	WHEN OTHERS THEN
		p_information1    :=  l_information1 ;
		p_information2    :=  l_information2 ;
		p_information3    :=  l_information3 ;
		p_information4    :=  l_information4 ;
		p_information5    :=  l_information5 ;
		p_information6    :=  l_information6 ;
		p_information7    :=  l_information7 ;
		p_information8    :=  l_information8 ;
		p_information9    :=  l_information9 ;
		p_information10   :=  l_information10;
		p_information11   :=  l_information11;
		p_information12   :=  l_information12;
		p_information13   :=  l_information13;
		p_information14   :=  l_information14;
		p_information15   :=  l_information15;
		p_information16   :=  l_information16;
		p_information17   :=  l_information17;
		p_information18   :=  l_information18;
		p_information19   :=  l_information19;
		p_information20   :=  l_information20;
		p_information21   :=  l_information21;
		p_information22   :=  l_information22;
		p_information23   :=  l_information23;
		p_information24   :=  l_information24;
		p_information25   :=  l_information25;
		p_information26   :=  l_information26;
		p_information27   :=  l_information27;
		p_information28   :=  l_information28;
		p_information29   :=  l_information29;
		p_information30   :=  l_information30;
END fetch_positionei;
--

-- Get POI Desc
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

-- Get Grade Details
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
l_grade_name per_grades.name%type :=  p_grade_name;
l_pay_plan   per_grade_definitions.segment1%type :=   p_pay_plan;
l_grade_or_level per_grade_definitions.segment2%type := p_grade_or_level;

BEGIN

  FOR cur_grd_rec IN cur_grd LOOP
    p_grade_name     := cur_grd_rec.grade_name;
    p_pay_plan       := cur_grd_rec.pay_plan;
    p_grade_or_level := cur_grd_rec.grade_or_level;
  END LOOP;
EXCEPTION
	WHEN OTHERS THEN
		p_grade_name := l_grade_name;
		p_pay_plan   :=  l_pay_plan;
		p_grade_or_level := l_grade_or_level;

END get_grade_details;
--

-- Get Consolidated Count
FUNCTION get_consolidated_count (p_consolidated_complaint_id IN NUMBER
			        ,p_complaint_id              IN NUMBER)
  RETURN NUMBER IS
--
CURSOR cur_cmp IS
  SELECT count(*) rec_count
  FROM   ghr_complaints2 cmp
  WHERE  cmp.consolidated_complaint_id = p_consolidated_complaint_id
  AND    (cmp.complaint_id <> p_complaint_id OR p_complaint_id IS NULL);

BEGIN
  FOR cur_cmp_rec IN cur_cmp LOOP
    RETURN(cur_cmp_rec.rec_count);
  END LOOP;
  --
  RETURN(NULL);
  --
END get_consolidated_count;
--

-- Get Docket Number
FUNCTION get_docket_number (p_consolidated_complaint_id IN NUMBER)
  RETURN VARCHAR2 IS
--
CURSOR cur_cmp IS
  SELECT docket_number
  FROM   ghr_complaints2 cmp
  WHERE  cmp.consolidated_complaint_id = p_consolidated_complaint_id;

BEGIN
  FOR cur_cmp_rec IN cur_cmp LOOP
    RETURN(cur_cmp_rec.docket_number);
  END LOOP;
  --
  RETURN(NULL);
  --
END get_docket_number;
--

-- Mixed Complaint
FUNCTION mixed_complaint(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
CURSOR cur_clm IS
  SELECT 1
  FROM   ghr_compl_claims clm
  WHERE  clm.complaint_id = p_complaint_id
  AND    clm.mixed_flag   = 'Y';
--
BEGIN
  FOR cur_clm_rec IN cur_clm LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END mixed_complaint;
--

-- Remand Complaint
FUNCTION remand_complaint(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
-- Must use only Max Date Appeal for code test
CURSOR cur_rmd IS
SELECT 1
  FROM   ghr_compl_appeals cap
  WHERE  cap.complaint_id = p_complaint_id
  AND    cap.appeal_date  = (SELECT MAX(cmp.appeal_date)
                             FROM ghr_compl_appeals cmp
                             WHERE cmp.complaint_id = p_complaint_id)
  AND    cap.decision     IN ('30', '40');
--
BEGIN
  FOR cur_rmd_rec IN cur_rmd LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END remand_complaint;
--

-- Get Window Title
FUNCTION get_window_title(p_complaint_id IN NUMBER
                         ,p_effective_date IN DATE)
  RETURN VARCHAR2 IS
--
l_full_name               per_people_f.full_name%TYPE := NULL;
l_ssn                     per_people_f.national_identifier%TYPE := NULL;
l_complainant_person_id   ghr_complaints2.complainant_person_id%TYPE := NULL;
l_docket_number           ghr_complaints2.docket_number%TYPE := NULL;

CURSOR cur_cmp IS
  SELECT complainant_person_id,docket_number
  FROM   ghr_complaints2 cmp
  WHERE  cmp.complaint_id = p_complaint_id;
--
BEGIN

  FOR cur_cmp_rec IN cur_cmp LOOP
    l_complainant_person_id := cur_cmp_rec.complainant_person_id;
    l_docket_number := cur_cmp_rec.docket_number;
  END LOOP;
  --
  ghr_complaints2_pkg.get_fullname_ssn(l_complainant_person_id
                   ,p_effective_date
                   ,l_full_name
                   ,l_ssn);

  RETURN(l_docket_number||' '||l_full_name||' '||l_ssn);
  --
END get_window_title;
--

-- Get Lookup Code
FUNCTION get_lookup_code(
                  p_application_id fnd_common_lookups.application_id%TYPE
                 ,p_lookup_type    fnd_common_lookups.lookup_type%TYPE
                 ,p_meaning        fnd_common_lookups.meaning%TYPE
                 )
RETURN VARCHAR2 IS
--
l_ret_val fnd_common_lookups.lookup_code%TYPE := NULL;

CURSOR cur_loc IS
  SELECT loc.lookup_code
  FROM   fnd_common_lookups loc
  WHERE  loc.application_id = p_application_id
  AND    loc.lookup_type = p_lookup_type
  AND    loc.meaning     = p_meaning;
--
BEGIN

  FOR cur_loc_rec IN cur_loc LOOP
    l_ret_val :=  cur_loc_rec.lookup_code;
  END LOOP;
  --
  RETURN(l_ret_val);
  --
END get_lookup_code;

-- Get Lookup Meaning
FUNCTION get_lookup_meaning(
                  p_application_id fnd_common_lookups.application_id%TYPE
                 ,p_lookup_type    fnd_common_lookups.lookup_type%TYPE
                 ,p_lookup_code    fnd_common_lookups.lookup_code%TYPE
                 )
RETURN VARCHAR2 IS
--
l_ret_val fnd_common_lookups.meaning%TYPE := NULL;

CURSOR cur_loc IS
  SELECT loc.meaning
  FROM   fnd_common_lookups loc
  WHERE  loc.application_id = p_application_id
  AND    loc.lookup_type    = p_lookup_type
  AND    loc.lookup_code    = p_lookup_code;
--
BEGIN

  FOR cur_loc_rec IN cur_loc LOOP
    l_ret_val :=  cur_loc_rec.meaning;
  END LOOP;
  --
  RETURN(l_ret_val);
  --
END get_lookup_meaning;
--

-- Test Existence of Corrective Action Records.
FUNCTION ca_rec_exists(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
--
CURSOR cur_cdt IS
SELECT 1
 FROM  ghr_compl_ca_details cdt
 WHERE cdt.compl_ca_header_id in (select compl_ca_header_id
                                 from ghr_compl_ca_headers
                                 where complaint_id = p_complaint_id);
--
BEGIN
  FOR cur_cdt_rec IN cur_cdt LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END ca_rec_exists;


-- Test Existence of Claim for Letter Date.
FUNCTION ltr_claim_chk(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
--
CURSOR cur_clm IS
SELECT 1
 FROM  ghr_compl_claims clm, ghr_compl_bases cba
 WHERE clm.complaint_id = p_complaint_id
 AND clm.compl_claim_id = cba.compl_claim_id
 AND clm.phase in ('20','30')
 AND cba.basis is NOT NULL;
--
BEGIN
  FOR cur_clm_rec IN cur_clm LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END ltr_claim_chk;

-- Claim Check for RR Ltr Received and Pre-Com Initiated.
FUNCTION claim_chk(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
--
CURSOR cur_clm2 IS
SELECT 1
 FROM  ghr_compl_claims clm, ghr_compl_bases cba
 WHERE clm.complaint_id = p_complaint_id
 AND clm.compl_claim_id = cba.compl_claim_id
 AND clm.phase in ('10','30')
 AND cba.basis is NOT NULL;
--
BEGIN
  FOR cur_clm2_rec IN cur_clm2 LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END claim_chk;

-- Test if COMPLAINTS.PCOM_INIT is NOT NULL
FUNCTION pcom_init_chk(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
--
CURSOR cur_cmp IS
SELECT 1
 FROM  ghr_complaints2 cmp
 WHERE cmp.complaint_id = p_complaint_id
 AND cmp.pcom_init is NOT NULL;
--
BEGIN
  FOR cur_cmp_rec IN cur_cmp LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END pcom_init_chk;

-- Test bases exist for a claim
FUNCTION basis_chk(p_compl_claim_id IN NUMBER)
  RETURN BOOLEAN IS
--
--
CURSOR cur_cba IS
SELECT 1
 FROM  ghr_compl_bases cba
 WHERE cba.compl_claim_id = p_compl_claim_id;
--
BEGIN
  FOR cur_cba_rec IN cur_cba LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END basis_chk;

-- Return true if a claim exists for the complaint_id passed.
FUNCTION claim_exists(p_complaint_id IN NUMBER)
  RETURN BOOLEAN IS
--
--
CURSOR cur_clm IS
SELECT 1
 FROM  ghr_compl_claims clm
 WHERE clm.complaint_id = p_complaint_id;
--
BEGIN
  FOR cur_clm_rec IN cur_clm LOOP
    RETURN(TRUE);
  END LOOP;
  --
  RETURN(FALSE);
  --
END claim_exists;


END ghr_complaints2_pkg;

/
