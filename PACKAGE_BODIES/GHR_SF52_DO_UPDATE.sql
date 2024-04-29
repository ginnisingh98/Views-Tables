--------------------------------------------------------
--  DDL for Package Body GHR_SF52_DO_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SF52_DO_UPDATE" AS
/* $Header: gh52doup.pkb 120.61.12010000.6 2009/08/11 10:53:46 utokachi ship $ */
g_effective_date      date;
g_old_user_status      per_assignment_status_types.user_status%type;
--
-- Removed all cursors required to fetch noa_code, as it is already passed from ghr_pa_requests (FRONT END)
--
-- *******************************
-- procedure Generic_Update_Extra_Info
-- *******************************
--

--      This procedure call the appropriate API to update DDF extra information.

Procedure Generic_Update_Extra_Info
(P_PA_REQUEST_REC               IN    GHR_PA_REQUESTS%ROWTYPE
,p_l_information_type           IN        varchar2
,p_extra_info_id                IN      number
,p_l_object_version_number      IN out nocopy number
,p_information1                 IN      varchar2 default hr_api.g_varchar2
,p_information2                 IN      varchar2 default hr_api.g_varchar2
,p_information3                 IN      varchar2 default hr_api.g_varchar2
,p_information4                 IN      varchar2 default hr_api.g_varchar2
,p_information5                 IN      varchar2 default hr_api.g_varchar2
,p_information6                 IN      varchar2 default hr_api.g_varchar2
,p_Information7                 IN      varchar2 default hr_api.g_varchar2
,p_information8                 IN      varchar2 default hr_api.g_varchar2
,p_information9                 IN      varchar2 default hr_api.g_varchar2
,p_information10                      IN        varchar2 default hr_api.g_varchar2
,p_information11                        IN      varchar2 default hr_api.g_varchar2
,p_information12                        IN      varchar2 default hr_api.g_varchar2
,p_information13                        IN      varchar2 default hr_api.g_varchar2
,p_information14                        IN      varchar2 default hr_api.g_varchar2
,p_information15                        IN      varchar2 default hr_api.g_varchar2
,p_information16                        IN      varchar2 default hr_api.g_varchar2
,p_information17                        IN      varchar2 default hr_api.g_varchar2
,p_information18                        IN      varchar2 default hr_api.g_varchar2
,p_information19                        IN      varchar2 default hr_api.g_varchar2
,p_information20                        IN      varchar2 default hr_api.g_varchar2
,p_information21                        IN      varchar2 default hr_api.g_varchar2
,p_information22                        IN      varchar2 default hr_api.g_varchar2
,p_information23                        IN      varchar2 default hr_api.g_varchar2
,p_information24                        IN      varchar2 default hr_api.g_varchar2
,p_information25                        IN      varchar2 default hr_api.g_varchar2
,p_information26                        IN      varchar2 default hr_api.g_varchar2
,p_information27                        IN      varchar2 default hr_api.g_varchar2
,p_information28                        IN      varchar2 default hr_api.g_varchar2
,p_information29                        IN      varchar2 default hr_api.g_varchar2
,p_information30                        IN      varchar2 default hr_api.g_varchar2)  is

--
  l_proc            varchar2(70) := 'Generic Update  Extra Info';
  l_id            number;
  l_ovn             number;
  l_initial_ovn             number;
  l_index                 varchar2(10);
  l_extra_info_id   number(15);
  l_extra_info_rec  ghr_api.extra_info_rec_type;
--
  l_asg_cre_extra_info_id       per_assignment_extra_info.assignment_extra_info_id%type;
  l_asg_cre_ovn                         per_assignment_extra_info.object_version_number%type;
  l_per_cre_extra_info_id       per_people_extra_info.person_extra_info_id%type;
  l_per_cre_ovn                         per_people_extra_info.object_version_number%type;
  l_pos1_cre_extra_info_id      per_position_extra_info.position_extra_info_id%type;
  l_pos1_cre_ovn                        per_position_extra_info.object_version_number%type;
--
  l_information1           varchar2(150);
  l_information2           varchar2(150);
  l_information3           varchar2(150);
  l_information4           varchar2(150);
  l_information5           varchar2(150);
  l_information6           varchar2(150);
  l_information7           varchar2(150);
  l_information8           varchar2(150);
  l_information9           varchar2(150);
  l_information10          varchar2(150);
  l_information11          varchar2(150);
  l_information12          varchar2(150);
  l_information13          varchar2(150);
  l_information14          varchar2(150);
  l_information15          varchar2(150);
  l_information16          varchar2(150);
  l_information17          varchar2(150);
  l_information18          varchar2(150);
  l_information19          varchar2(150);
  l_information20          varchar2(150);
  l_information21          varchar2(150);
  l_information22          varchar2(150);
  l_information23          varchar2(150);
  l_information24          varchar2(150);
  l_information25          varchar2(150);
  l_information26          varchar2(150);
  l_information27          varchar2(150);
  l_information28          varchar2(150);
  l_information29          varchar2(150);
  l_information30          varchar2(150);
--

-- Cursor to select the primary key of the respective Extra info tables for the specific
-- entity Id and the InformationType

   Cursor c_asg_ei is
     select assignment_extra_info_id,
            object_version_number
     from   per_assignment_extra_info
     where  assignment_id    = l_id
     and    information_type = p_l_information_type;

   Cursor c_per_ei is
     select person_extra_info_id,
            object_version_number
     from   per_people_extra_info
     where  person_id        = l_id
     and    information_type = p_l_information_type;

   Cursor c_pos_ei is
     select position_extra_info_id,
            object_version_number
     from   per_position_extra_info
     where  position_id      = l_id
     and    information_type = p_l_information_type;

begin
--
  hr_utility.set_location('Entering ' || l_proc,5);
  l_initial_ovn := p_l_object_version_number;

  l_extra_info_id := NULL;

  If upper(substr(P_l_Information_Type,8,3))   = 'ASG' then
    l_index     := 'aei';
    l_id        := P_Pa_request_rec.Employee_Assignment_id;
    l_extra_info_id  := p_extra_info_id;
  hr_utility.set_location('Assignment id is ' ||l_id || '  ' || l_proc,6);
  hr_utility.set_location('l_extra_info_id is ' ||l_extra_info_id || '  ' || l_proc,7);
  Elsif upper(substr(P_l_Information_Type,8,3))   = 'PER' then
    l_index     := 'pei';
    l_id        := P_Pa_request_rec.person_id;
    l_extra_info_id  := p_extra_info_id;
  Elsif upper(substr(P_l_Information_Type,8,3))   = 'POS' then
    l_index     := 'poei';
    l_id        := nvl(P_Pa_request_rec.to_position_id,p_pa_request_rec.from_position_id);
    hr_utility.set_location('EXTRA INFO ID  '||  to_char(p_extra_info_id),1);
    l_extra_info_id  := p_extra_info_id;
 -- Rohini
 Elsif upper(p_l_information_type )= 'GHR_US_RETAINED_GRADE' then
    l_index     :=  'pei';
    l_id        :=  P_Pa_request_rec.person_id;
    l_extra_info_id  := p_extra_info_id;
 -- Rohini

  Else
    hr_utility.set_message(8301,'GHR_38132_INVALID_INFO_TYPE');
    hr_utility.raise_error;
  End if;

  hr_utility.set_location(l_proc,10);

-- The foll. code sets the information<n> to null , if they get passed in as null
-- and is then used in case of create Extr Info .This was done so that
-- we could work with just one procedure for both update as well as create of
-- extra information, with all the parameters defaulted to hr_api.g_varchar2
-- therby ensuring that while updating, none of the existing data gets over-written.

  l_extra_info_id := p_extra_info_id;
  hr_utility.set_location('l_extra_info_id is ' ||l_extra_info_id || '  ' || l_proc,8);
  If p_information1 = hr_api.g_varchar2 THEN
    l_information1 := null;
  Else
    l_information1 := p_information1;
  End if;
  IF p_information2 = hr_api.g_varchar2 THEN
    l_information2 := null;
  Else
    l_information2 := p_information2;
  End if;
  IF p_information3 = hr_api.g_varchar2 THEN
    l_information3 := null;
  ELSE
    l_information3 := p_information3;
  END IF;
  IF p_information4 = hr_api.g_varchar2 THEN
    l_information4 := null;
  ELSE
    l_information4 := p_information4;
        END IF;
  IF p_information5 = hr_api.g_varchar2 THEN
    l_information5 := null;
  ELSE
    l_information5 := p_information5;
  END IF;
  IF p_information6 = hr_api.g_varchar2 THEN
    l_information6 := null;
  ELSE
    l_information6 := p_information6;
  END IF;
  IF p_information7 = hr_api.g_varchar2 THEN
    l_information7 := null;
  ELSE
    l_information7 := p_information7;
  END IF;
  IF p_information8 = hr_api.g_varchar2 THEN
    l_information8 := null;
  ELSE
    l_information8 := p_information8;
  END IF;
  IF p_information9 = hr_api.g_varchar2 THEN
   l_information9 := null;
  ELSE
   l_information9 := p_information9;
  END IF;
  IF p_information10 = hr_api.g_varchar2 THEN
    l_information10 := null;
  ELSE
    l_information10 := p_information10;
  END IF;
  IF p_information11 = hr_api.g_varchar2 THEN
    l_information11 := null;
  ELSE
   l_information11 := p_information11;
  END IF;
  IF p_information12 = hr_api.g_varchar2 THEN
    l_information12 := null;
  ELSE
    l_information12 := p_information12;
  END IF;
  IF p_information13 = hr_api.g_varchar2 THEN
    l_information13 := null;
  ELSE
    l_information13 := p_information13;
  END IF;
  IF p_information14 = hr_api.g_varchar2 THEN
    l_information14 := null;
  ELSE
    l_information14 := p_information14;
  END IF;
  IF p_information15 = hr_api.g_varchar2 THEN
    l_information15 := null;
  ELSE
    l_information15 := p_information15;
  END IF;
  IF p_information16 = hr_api.g_varchar2 THEN
   l_information16 := null;
  ELSE
    l_information16 := p_information16;
  END IF;
  IF p_information17 = hr_api.g_varchar2 THEN
    l_information17 := null;
  ELSE
    l_information17 := p_information17;
  END IF;
  IF p_information18 = hr_api.g_varchar2 THEN
   l_information18 := null;
  ELSE
   l_information18 := p_information18;
  END IF;
  IF p_information19 = hr_api.g_varchar2 THEN
   l_information19 := null;
  ELSE
   l_information19 := p_information19;
  END IF;
  IF p_information20 = hr_api.g_varchar2 THEN
   l_information20 := null;
  ELSE
    l_information20 := p_information20;
  END IF;
  IF p_information21 = hr_api.g_varchar2 THEN
    l_information21 := null;
  ELSE
    l_information21 := p_information21;
  END IF;
  IF p_information22 = hr_api.g_varchar2 THEN
    l_information22 := null;
  ELSE
    l_information22 := p_information22;
  END IF;
  IF p_information23 = hr_api.g_varchar2 THEN
    l_information23 := null;
  ELSE
    l_information23 := p_information23;
  END IF;
  IF p_information24 = hr_api.g_varchar2 THEN
    l_information24 := null;
  ELSE
    l_information24 := p_information24;
  END IF;
  IF p_information25 = hr_api.g_varchar2 THEN
    l_information25 := null;
  ELSE
   l_information25 := p_information25;
  END IF;
  IF p_information26 = hr_api.g_varchar2 THEN
    l_information26 := null;
  ELSE
    l_information26 := p_information26;
  END IF;
  IF p_information27 = hr_api.g_varchar2 THEN
    l_information27 := null;
  ELSE
    l_information27 := p_information27;
  END IF;
  IF p_information28 = hr_api.g_varchar2 THEN
    l_information28 := null;
  ELSE
    l_information28 := p_information28;
  END IF;
  IF p_information29 = hr_api.g_varchar2 THEN
    l_information29 := null;
  ELSE
    l_information29 := p_information29;
  END IF;
  IF p_information30 = hr_api.g_varchar2 THEN
   l_information30 := null;
  ELSE
    l_information30 := p_information30;
  END IF;

 If l_index = 'aei' then
-- There are chances that the history table didn't have date corresponding to an
-- Extra info, as of the given effective_date , but the extra info table itself might have
-- the data. This cursor fetches the extra info id  of the information_type to be updated
-- to ensure that the correct procedure is then called to create/udpate EI.
  hr_utility.set_location('l_extra_info_id is ' ||l_extra_info_id || '  ' || l_proc,9);
   If l_Extra_Info_Id  is null then
     for asg_ei in c_asg_ei loop
       l_extra_info_id := asg_ei.assignment_extra_info_id;
       l_ovn           := asg_ei.object_version_number;
     end loop;
  hr_utility.set_location('l_extra_info_id is ' ||l_extra_info_id || '  ' || l_proc,10);
   Else
       l_ovn      := p_l_object_version_number;
  hr_utility.set_location('l_extra_info_id is ' ||l_extra_info_id || '  ' || l_proc,11);
   End if;

   If l_extra_info_id is null then
     hr_utility.set_location(l_proc,15);
     hr_assignment_extra_info_api.create_assignment_extra_info
     ( p_assignment_id              =>    P_Pa_request_rec.Employee_Assignment_id
      ,p_Information_type               =>    p_l_information_type
      ,p_aei_information_category   =>    p_l_information_type
      , p_aei_information1              =>    l_information1
      , p_aei_information2              =>    l_information2
      , p_aei_information3              =>    l_information3
      , p_aei_information4              =>    l_information4
      , p_aei_information5              =>    l_information5
        , p_aei_information6            =>    l_information6
        , p_aei_information7            =>    l_information7
        , p_aei_information8            =>    l_information8
        , p_aei_information9            =>    l_information9
      , p_aei_information10             =>    l_information10
        , p_aei_information11           =>    l_information11
        , p_aei_information12           =>    l_information12
        , p_aei_information13           =>    l_information13
        , p_aei_information14         =>    l_information14
        , p_aei_information15           =>    l_information15
      , p_aei_information16             =>    l_information16
        , p_aei_information17           =>    l_information17
        , p_aei_information18           =>    l_information18
        , p_aei_information19           =>    l_information19
        , p_aei_information20           =>    l_information20
        , p_aei_information21           =>    l_information21
        , p_aei_information22           =>    l_information22
        , p_aei_information23           =>    l_information23
        , p_aei_information24           =>    l_information24
        , p_aei_information25           =>    l_information25
        , p_aei_information26           =>    l_information26
        , p_aei_information27           =>    l_information27
        , p_aei_information28           =>    l_information28
        , p_aei_information29           =>    l_information29
        , p_aei_information30           =>    l_information30
        , p_assignment_extra_info_id  =>    l_asg_cre_extra_info_id
        , p_object_version_number     =>    l_asg_cre_ovn );
   Else
     hr_utility.set_location(l_proc,20);
     hr_assignment_extra_info_api.update_assignment_extra_info
     ( p_assignment_extra_info_id =>    l_Extra_Info_Id
     , p_object_version_number    =>    l_ovn
     , p_aei_information1           =>    p_information1
     , p_aei_information2           =>    p_information2
     , p_aei_information3           =>    p_information3
     , p_aei_information4           =>    p_information4
     , p_aei_information5           =>    p_information5
     , p_aei_information6         =>    p_information6
     , p_aei_information7           =>    p_information7
     , p_aei_information8           =>    p_information8
     , p_aei_information9           =>    p_information9
     , p_aei_information10          =>    p_information10
     , p_aei_information11          =>    p_information11
     , p_aei_information12          =>    p_information12
     , p_aei_information13        =>    p_information13
     , p_aei_information14          =>    p_information14
     , p_aei_information15        =>    p_information15
     , p_aei_information16          =>    p_information16
     , p_aei_information17        =>    p_information17
     , p_aei_information18          =>    p_information18
     , p_aei_information19          =>    p_information19
     , p_aei_information20          =>    p_information20
     , p_aei_information21          =>    p_information21
     , p_aei_information22          =>    p_information22
     , p_aei_information23          =>    p_information23
     , p_aei_information24          =>    p_information24
     , p_aei_information25          =>    p_information25
     , p_aei_information26          =>    p_information26
     , p_aei_information27          =>    p_information27
     , p_aei_information28          =>    p_information28
     , p_aei_information29          =>    p_information29
     , p_aei_information30          =>    p_information30);
--
  End if;
End if;
--

-- Update/Create Person Extra Info
--
--
If l_index = 'pei' then
  hr_utility.set_location(l_proc,25);

   If l_Extra_Info_Id  is null then
     hr_utility.set_location(to_char(l_id),1);
     hr_utility.set_location(p_l_information_type,2);
     for per_ei in c_per_ei loop
       l_extra_info_id := per_ei.person_extra_info_id;
       l_ovn           := per_ei.object_version_number;
     end loop;
    Else
       l_ovn    :=  p_l_object_version_number;
   End if;
   hr_utility.set_location('pei_ovn is '  || to_char(l_ovn),1);
   -- Bug#5045806 For Service Obligation EIT, Always create new EIT Record.
   IF  P_l_Information_Type  = 'GHR_US_PER_SERVICE_OBLIGATION' THEN
        l_extra_info_id := NULL;
   END IF;
   -- Bug#5045806
   If l_extra_info_id is null then
     hr_utility.set_location(l_proc,30);
     hr_person_extra_info_api.create_person_extra_info
     (p_Person_id                             =>    P_Pa_request_rec.Person_id
     ,p_Information_type                =>    p_l_information_type
     ,p_pei_information_category    =>    p_l_information_type
     ,p_pei_information1                =>    l_information1
     , p_pei_information2               =>    l_information2
     , p_pei_information3               =>    l_information3
     , p_pei_information4               =>    l_information4
     , p_pei_information5               =>    l_information5
     , p_pei_information6               =>    l_information6
     , p_pei_information7               =>    l_information7
     , p_pei_information8               =>    l_information8
     , p_pei_information9               =>    l_information9
     , p_pei_information10              =>    l_information10
     , p_pei_information11              =>    l_information11
     , p_pei_information12              =>    l_information12
     , p_pei_information13              =>    l_information13
     , p_pei_information14          =>    l_information14
     , p_pei_information15              =>    l_information15
     , p_pei_information16              =>    l_information16
     , p_pei_information17              =>    l_information17
     , p_pei_information18              =>    l_information18
     , p_pei_information19              =>    l_information19
     , p_pei_information20              =>    l_information20
     , p_pei_information21              =>    l_information21
     , p_pei_information22              =>    l_information22
     , p_pei_information23              =>    l_information23
     , p_pei_information24              =>    l_information24
     , p_pei_information25              =>    l_information25
     , p_pei_information26              =>    l_information26
     , p_pei_information27              =>    l_information27
     , p_pei_information28              =>    l_information28
     , p_pei_information29              =>    l_information29
     , p_pei_information30              =>    l_information30
     ,p_person_extra_info_id        =>    l_per_cre_extra_info_id
     ,p_object_version_number           =>    l_per_cre_ovn );
  Else
--
    hr_utility.set_location(l_proc,35);
    hr_person_extra_info_api.update_person_extra_info
    ( p_person_extra_info_id    =>    l_Extra_Info_Id
    , p_object_version_number   =>    l_ovn
    , p_pei_information1                =>    p_information1
    , p_pei_information2                =>    p_information2
    , p_pei_information3                =>    p_information3
    , p_pei_information4                =>    p_information4
    , p_pei_information5                =>    p_information5
    , p_pei_information6                =>    p_information6
    , p_pei_information7                =>    p_information7
    , p_pei_information8                =>    p_information8
    , p_pei_information9                =>    p_information9
    , p_pei_information10               =>    p_information10
    , p_pei_information11               =>    p_information11
    , p_pei_information12               =>    p_information12
    , p_pei_information13               =>    p_information13
    , p_pei_information14               =>    p_information14
    , p_pei_information15               =>    p_information15
    , p_pei_information16               =>    p_information16
    , p_pei_information17               =>    p_information17
    , p_pei_information18               =>    p_information18
    , p_pei_information19               =>    p_information19
    , p_pei_information20               =>    p_information20
    , p_pei_information21               =>    p_information21
    , p_pei_information22               =>    p_information22
    , p_pei_information23               =>    p_information23
    , p_pei_information24               =>    p_information24
    , p_pei_information25               =>    p_information25
    , p_pei_information26               =>    p_information26
    , p_pei_information27               =>    p_information27
    , p_pei_information28               =>    p_information28
    , p_pei_information29               =>    p_information29
    , p_pei_information30               =>    p_information30);
--
   End if;
 End if;
--
--
-- Update/Create Position group1 Extra Info
--
--
If l_index = 'poei' then
  hr_utility.set_location(l_proc,40);
  If l_Extra_Info_Id  is null then
    for pos_ei in c_pos_ei loop
      l_extra_info_id := pos_ei.position_extra_info_id;
      l_ovn := pos_ei.object_version_number;
    end loop;
  Else
      l_ovn  :=  p_l_object_version_number;
  End if;
  hr_utility.set_location(l_proc,45);
  If l_extra_info_id is null then
    hr_position_extra_info_api.create_position_extra_info
   ( p_position_id                      =>    P_Pa_request_rec.to_position_id
   , p_Information_type               =>    p_l_information_type
   , p_poei_information_category    =>    p_l_information_type
   , p_poei_information1                =>    l_information1
   , p_poei_information2                =>    l_information2
   , p_poei_information3                =>    l_information3
   , p_poei_information4                =>    l_information4
   , p_poei_information5                =>    l_information5
   , p_poei_information6                =>    l_information6
   , p_poei_information7                =>    l_information7
   , p_poei_information8                =>    l_information8
   , p_poei_information9                =>    l_information9
   , p_poei_information10               =>    l_information10
   , p_poei_information11               =>    l_information11
   , p_poei_information12               =>    l_information12
   , p_poei_information13               =>    l_information13
   , p_poei_information14           =>    l_information14
   , p_poei_information15               =>    l_information15
   , p_poei_information16           =>    l_information16
   , p_poei_information17               =>    l_information17
   , p_poei_information18               =>    l_information18
   , p_poei_information19               =>    l_information19
   , p_poei_information20               =>    l_information20
   , p_poei_information21               =>    l_information21
   , p_poei_information22               =>    l_information22
   , p_poei_information23               =>    l_information23
   , p_poei_information24               =>    l_information24
   , p_poei_information25               =>    l_information25
   , p_poei_information26               =>    l_information26
   , p_poei_information27               =>    l_information27
   , p_poei_information28               =>    l_information28
   , p_poei_information29               =>    l_information29
   , p_poei_information30               =>    l_information30
   ,p_position_extra_info_id    =>    l_pos1_cre_extra_info_id
   ,p_object_version_number     =>    l_pos1_cre_ovn
   );
--
 Else
--
   hr_utility.set_location(l_proc,50);
   hr_utility.set_location('GEN UPD' || to_char(l_Extra_Info_Id ),1);
   hr_utility.set_location('GEN UPD' || to_char(p_l_Object_Version_Number ),1);

   hr_position_extra_info_api.update_position_extra_info
  ( p_position_extra_info_id    =>    l_Extra_Info_Id
  , p_object_version_number             =>    l_ovn
  , p_poei_information1                 =>    p_information1
  , p_poei_information2                 =>    p_information2
  , p_poei_information3                 =>    p_information3
  , p_poei_information4                 =>    p_information4
  , p_poei_information5                 =>    p_information5
  , p_poei_information6                 =>    p_information6
  , p_poei_information7                 =>    p_information7
  , p_poei_information8                 =>    p_information8
  , p_poei_information9                 =>    p_information9
  , p_poei_information10                =>    p_information10
  , p_poei_information11                =>    p_information11
  , p_poei_information12                =>    p_information12
  , p_poei_information13                =>    p_information13
  , p_poei_information14                =>    p_information14
  , p_poei_information15                =>    p_information15
  , p_poei_information16                =>    p_information16
  , p_poei_information17                =>    p_information17
  , p_poei_information18                =>    p_information18
  , p_poei_information19                =>    p_information19
  , p_poei_information20                =>    p_information20
  , p_poei_information21                =>    p_information21
  , p_poei_information22                =>    p_information22
  , p_poei_information23                =>    p_information23
  , p_poei_information24                =>    p_information24
  , p_poei_information25                =>    p_information25
  , p_poei_information26                =>    p_information26
  , p_poei_information27                =>    p_information27
  , p_poei_information28                =>    p_information28
  , p_poei_information29                =>    p_information29
  , p_poei_information30                =>    p_information30
  );
--
 End if;
End if;
--
--
  hr_utility.set_location('Leaving ' ||l_proc,60);
 Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_l_object_version_number := l_initial_ovn;
          raise;

End Generic_Update_Extra_Info;

Procedure Update_Retained_Grade
(P_PA_REQUEST_REC               IN     GHR_PA_REQUESTS%ROWTYPE ,
 P_Per_retained_grade           IN OUT NOCOPY GHR_API.Per_retained_grade_TYPE) IS
--
--
cursor c_702_rec is
 select rei_information3,pei_information1,
        pei.object_version_number ovn
  from ghr_pa_request_extra_info rei,
       per_people_extra_info pei
 where pa_request_id = p_pa_request_rec.pa_request_id
 and pei.person_extra_info_id = rei.rei_information3
 and pei.information_type = 'GHR_US_RETAINED_GRADE'
 and rei.information_type = 'GHR_US_PAR_TERM_RG_PROMO'
 and nvl(rei.rei_information30,hr_api.g_varchar2) <> 'Original RPA';
--
cursor c_740_rec is
 select rei_information3,pei_information1,
        pei.object_version_number ovn
  from ghr_pa_request_extra_info rei,
       per_people_extra_info pei
 where pa_request_id = p_pa_request_rec.pa_request_id
 and pei.person_extra_info_id = rei.rei_information3
 and pei.information_type = 'GHR_US_RETAINED_GRADE'
 and rei.information_type = 'GHR_US_PAR_TERM_RG_POSN_CHG'
 and (rei.rei_information5 is null or rei.rei_information5 = 'Y')
 and nvl(rei.rei_information30,hr_api.g_varchar2) <> 'Original RPA';


l_retained_grade_rec          ghr_pay_calc.retained_grade_rec_type;
l_ret_grade_rec               ghr_pay_calc.retained_grade_rec_type;
-- Bug#4698321 created l_cur_date_from variable.
l_cur_date_from               per_people_extra_info.pei_information1%type;
l_new_date_to                 per_people_extra_info.pei_information1%type;
l_new_grade_or_level          per_people_extra_info.pei_information3%type;
l_new_pay_plan                per_people_extra_info.pei_information3%type;
l_new_pay_table               per_people_extra_info.pei_information3%type;
l_new_loc_percent             per_people_extra_info.pei_information3%type;
l_new_pay_basis               per_people_extra_info.pei_information3%type;
l_temp_step                   per_people_extra_info.pei_information9%type;
l_new_temp_step               per_people_extra_info.pei_information9%type;
l_new_step_or_rate            per_people_extra_info.pei_information4%type;
l_step_or_rate                per_people_extra_info.pei_information4%type;
l_ret_object_version_number   ghr_pa_requests.object_version_number%type;
l_ovn                         ghr_pa_requests.object_version_number%type;


CURSOR cur_temp_step
IS
SELECT  rei_information3 temp_step
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_rec.pa_request_id
AND     information_type = 'GHR_US_PAR_RG_TEMP_PROMO';

l_session                   ghr_history_api.g_session_var_type;
l_proc            varchar2(70) := 'Update_Retained_Grade';
l_per_retained_grade GHR_API.Per_retained_grade_TYPE;
 -- Bug#4698321 Added pei_information1 to the cursor.
 Cursor c_retained_grade_ovn  is
   select object_version_number,
          pei_information1,
          pei_information2,
          pei_information3,
          pei_information4,
          pei_information5,
          pei_information6,
          pei_information7,
          pei_information8,
          pei_information9
   from   per_people_extra_info
where  person_extra_info_id = l_retained_grade_rec.person_extra_info_id;

l_effective_date Date;
BEGIN
    hr_utility.set_location('Entering '||l_proc,5);
    l_per_retained_grade := P_Per_retained_grade;
    ghr_history_api.get_g_session_var(l_session); -- Bug 3021003
    hr_utility.set_location('Effective Date '||p_pa_request_rec.effective_date,1);
    IF p_pa_request_rec.first_noa_code = '702' THEN
        --702 Processing
        hr_utility.set_location('702 RG Processing '||l_proc,10);
        FOR rg_rec in c_702_rec LOOP
            hr_utility.set_location('Effective Date '||p_pa_request_rec.effective_date,1);
            hr_utility.set_location('702 RG Processing '||rg_rec.rei_information3,11);
            IF fnd_date.canonical_to_date(rg_rec.pei_information1) >
              (p_pa_request_rec.effective_date - 1) THEN
                hr_utility.set_message(8301,'GHR_38692_RG_TO_DATE_LESSER');
                hr_utility.raise_error;
            END IF;
            Generic_Update_Extra_Info
              (p_pa_request_rec          =>   P_PA_REQUEST_REC
              ,p_l_information_type      =>   'GHR_US_RETAINED_GRADE'
              ,p_extra_info_id           =>   rg_rec.rei_information3
              ,p_l_object_version_number =>   rg_rec.ovn
              ,p_information2            =>   fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
              );
        END LOOP;
    ELSIF p_pa_request_rec.first_noa_code = '740' THEN
        --740 Processing
        hr_utility.set_location('740 RG Processing '||l_proc,15);
        FOR rg_rec in c_740_rec LOOP
            hr_utility.set_location('Effective Date '||p_pa_request_rec.effective_date,1);
            hr_utility.set_location('740 RG Processing '||rg_rec.rei_information3,12);
            IF fnd_date.canonical_to_date(rg_rec.pei_information1) >
            (p_pa_request_rec.effective_date - 1) THEN
                hr_utility.set_message(8301,'GHR_38692_RG_TO_DATE_LESSER');
                hr_utility.raise_error;
            END IF;
            Generic_Update_Extra_Info
            (p_pa_request_rec          =>   P_PA_REQUEST_REC
            ,p_l_information_type      =>   'GHR_US_RETAINED_GRADE'
            ,p_extra_info_id           =>   rg_rec.rei_information3
            ,p_l_object_version_number =>   rg_rec.ovn
            ,p_information2            =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
            );
        END LOOP;
-------Bug 5913362 -- Adding 890
    ELSIF p_pa_request_rec.first_noa_code IN ('866', '890') THEN
        -- 866 Processing
        IF p_per_retained_grade.per_retained_grade_flag =  'Y' THEN
           IF p_pa_request_rec.first_noa_code = '890' THEN
                 l_effective_date := p_pa_request_rec.effective_date - 1;
           ELSE
                 l_effective_date := p_pa_request_rec.effective_date;
           END IF;
            --
            hr_utility.set_location('866 RG Processing '||l_proc,15);
            hr_utility.set_location('Inside 866 processing '||p_per_retained_grade.person_extra_info_id,1);
            Generic_Update_Extra_Info
            (p_pa_request_rec          =>   P_PA_REQUEST_REC
            ,p_l_information_type      =>   'GHR_US_RETAINED_GRADE'
            ,p_extra_info_id           =>   p_per_retained_grade.person_extra_info_id
            ,p_l_object_version_number =>   p_per_retained_grade.object_version_number
            ,p_information2            =>   fnd_date.date_to_canonical(l_effective_date)
            );
            FOR cur_temp_step_rec IN cur_temp_step LOOP
                l_new_temp_step  := cur_temp_step_rec.temp_step;
            END LOOP;
            IF  l_new_temp_step is not null  THEN
                l_retained_grade_rec :=
                ghr_pc_basic_pay.get_retained_grade_details
                (p_person_id      =>   p_pa_request_rec.person_id,
                p_effective_date  =>   p_pa_request_rec.effective_date,
                p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                );
                IF l_retained_grade_rec.person_extra_info_id is not null then
                    hr_utility.set_location('Inside 866 processing '||l_retained_grade_rec.person_extra_info_id,1);
                    FOR retained_grade_ovn IN c_retained_grade_ovn LOOP
                        l_ret_object_version_number := retained_grade_ovn.object_version_number;
                        l_new_date_to             := retained_grade_ovn.pei_information2;
                        l_new_grade_or_level      := retained_grade_ovn.pei_information3;
                        l_new_step_or_rate        := retained_grade_ovn.pei_information4;
                        l_new_pay_plan            := retained_grade_ovn.pei_information5;
                        l_new_pay_table           := retained_grade_ovn.pei_information6;
                        l_new_loc_percent         := retained_grade_ovn.pei_information7;
                        l_new_pay_basis           := retained_grade_ovn.pei_information8;
                        exit;
                    END LOOP;
                    ghr_history_api.get_g_session_var(l_session);
                    hr_utility.set_location('Inside 866 processing ',2);
                    IF l_session.noa_id_correct is null then
                        -- End date the existing RG record
                        hr_person_extra_info_api.update_person_extra_info
                        (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
                        p_object_version_number     =>  l_ret_object_version_number,
                        p_pei_information2          =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date )
                        );
                        hr_utility.set_location('Inside 866 processing ',3);
                        -- Create the new RG Record with Temporary Promotion Step Value
                        hr_person_extra_info_api.create_person_extra_info
                        (p_person_id                =>  p_pa_request_rec.person_id,
                        p_information_type         =>  'GHR_US_RETAINED_GRADE',
                        p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
                        p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
                        p_object_version_number    =>  l_ret_object_version_number,
                        p_pei_information1         =>
                        fnd_date.date_to_canonical(p_pa_request_rec.effective_date + 1),
                        p_pei_information2         =>  l_new_date_to,
                        p_pei_information3         =>  l_new_grade_or_level,
                        p_pei_information4         =>  l_new_step_or_rate,
                        p_pei_information5         =>  l_new_pay_plan,
                        p_pei_information6         =>  l_new_pay_table,
                        p_pei_information7         =>  l_new_loc_percent,
                        p_pei_information8         =>  l_new_pay_basis,
                        p_pei_information9         =>  l_new_temp_step
                        );
                        hr_utility.set_location('Inside 866 processing ',3);
                    ELSE
                        -- Update the TPS in Retain Grade record
                        hr_person_extra_info_api.update_person_extra_info
                        (p_person_extra_info_id      => l_retained_grade_rec.person_extra_info_id,
                        p_object_version_number     =>  l_ret_object_version_number,
                        p_pei_information9          =>  l_new_temp_step
                        );
                    END IF;
                END IF;
            END IF;
        END IF;
    -- Sundar 3021003 Need to update Person EI with the retained grade for WGI, QSI actions, if Step is different
    -- from Person EI.
    ELSIF p_pa_request_rec.first_noa_code IN ('867','892','893') AND  l_session.noa_id_correct IS NOT NULL
      AND p_pa_request_rec.PAY_RATE_DETERMINANT in ('A','B','E','F','U','V') THEN    -- Bug 3500132
        l_retained_grade_rec :=
        ghr_pc_basic_pay.get_retained_grade_details
        (p_person_id      =>   p_pa_request_rec.person_id,
        p_effective_date  =>   p_pa_request_rec.effective_date,
        p_pa_request_id   =>   p_pa_request_rec.altered_pa_request_id
        );
        hr_utility.set_location('Inside Sun processing '||l_retained_grade_rec.person_extra_info_id,1);
        IF l_retained_grade_rec.person_extra_info_id IS NOT NULL THEN
            FOR retained_grade_ovn IN c_retained_grade_ovn LOOP
                l_ret_object_version_number := retained_grade_ovn.object_version_number;
                EXIT;
            END LOOP;
			hr_utility.set_location('P_Per_retained_grade.step_or_rate '||P_Per_retained_grade.retain_step_or_rate,1);
			hr_utility.set_location('l_retained_grade_rec.step_or_rate '||l_retained_grade_rec.step_or_rate,1);
			IF (NVL(P_Per_retained_grade.retain_step_or_rate,-1) <> NVL(l_retained_grade_rec.step_or_rate,-1)) THEN
                hr_person_extra_info_api.update_person_extra_info
                  (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
                   p_object_version_number     =>  l_ret_object_version_number,
                   p_pei_information4          =>  P_Per_retained_grade.retain_step_or_rate
                  );
			END IF;
			hr_utility.set_location('P_Per_retained_grade.temp_step '||P_Per_retained_grade.temp_step,1);
			hr_utility.set_location('l_retained_grade_rec.temp_step '||l_retained_grade_rec.temp_step,1);
			IF (NVL(P_Per_retained_grade.temp_step,-1) <> NVL(l_retained_grade_rec.temp_step,-1)) THEN
				hr_person_extra_info_api.update_person_extra_info
				  (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
				   p_object_version_number     =>  l_ret_object_version_number,
				   p_pei_information9          =>  P_Per_retained_grade.temp_step
				  );
			END IF;
		END IF;
    END IF;
    --
    -- SKIP the following process for NOA Code 866 as it is already handled in the above code.
    -- However, don't skip NOACs 702,740 as they may not terminate RG. In some cases, they
    -- may have effective RG record.
-------Bug 5913362 -- Adding 890
    IF (ghr_pay_calc.g_fwfa_pay_calc_flag) and
        p_pa_request_rec.first_noa_code NOT IN ('866', '890')THEN

        BEGIN
            -- FWFA Changes Bug#4444609 Added the IF Condition.
            l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details
                                         (p_person_id      =>   p_pa_request_rec.person_id,
                                         p_effective_date  =>   p_pa_request_rec.effective_date,
                                         p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                                         );

            IF l_retained_grade_rec.person_extra_info_id is not null then
                hr_utility.set_location('Inside FWFA RG processing '||l_retained_grade_rec.person_extra_info_id,1);
                FOR retained_grade_ovn IN c_retained_grade_ovn LOOP
                    l_ret_object_version_number := retained_grade_ovn.object_version_number;
                    l_cur_date_from            := retained_grade_ovn.pei_information1;
                    l_new_date_to               := retained_grade_ovn.pei_information2;
                    l_new_grade_or_level        := retained_grade_ovn.pei_information3;
                    l_new_step_or_rate          := retained_grade_ovn.pei_information4;
                    l_new_pay_plan              := retained_grade_ovn.pei_information5;
                    l_new_pay_table             := retained_grade_ovn.pei_information6;
                    l_new_loc_percent           := retained_grade_ovn.pei_information7;
                    l_new_pay_basis             := retained_grade_ovn.pei_information8;
                    l_new_temp_step             := retained_grade_ovn.pei_information9;
                    exit;
                END LOOP;

                IF ghr_pay_calc.g_pay_table_upd_flag THEN
                    l_new_pay_table  := p_per_retained_grade.retain_pay_table_id;
                    p_per_retained_grade.per_retained_grade_flag :=  'Y';
                END IF;

                IF p_pa_request_rec.first_noa_code in ('867','892','893') AND
                   l_session.noa_id_correct IS NULL THEN
                    -- Handled the retained step and temp.step cases separately
                   p_per_retained_grade.per_retained_grade_flag :=  'Y';

		            IF l_new_temp_step IS NOT NULL THEN
                        IF TO_NUMBER(l_new_temp_step) < 9 THEN
                            l_temp_step     :=  '0' ||(l_new_temp_step + 1 );
                            l_new_temp_step :=  l_temp_step;
                        ELSE
                            l_temp_step :=   l_new_temp_step + 1 ;
                            l_new_temp_step :=  l_temp_step;
                        END IF;
                    ELSE -- For Retained Grade
                        if to_number(l_new_step_or_rate) < 9 then
                            l_step_or_rate   := '0' ||(l_new_step_or_rate + 1 );
                            l_new_step_or_rate := l_step_or_rate;
                        ELSE
                            l_step_or_rate   :=  l_new_step_or_rate + 1;
                            l_new_step_or_rate := l_step_or_rate;
                        END IF;
                    END IF; -- If l_retained_grade_rec.temp_step is not null
                    hr_utility.set_location('FWFA New Step or Rate for Ret Grd Rec. is  ' || l_new_step_or_rate,3);
                    hr_utility.set_location('FWFA temp_step is  ' || l_new_temp_step,2);
                END IF;

                  ---BUG# 4999237 HANDLED FOR 894 TERMINATION OF PAY RETENTION
                  -- Bug#5679022 Pass the g_step_or_rate in case of 894 for pay retention termination.
                  IF p_pa_request_rec.first_noa_code = '894' THEN
                     IF ghr_process_sf52.g_step_or_rate IS NOT NULL THEN
                         l_new_step_or_rate := ghr_process_sf52.g_step_or_rate;
                         p_per_retained_grade.per_retained_grade_flag :=  'Y';
                     END IF;
                  END IF;
                  --END BUG 4999237

                hr_utility.set_location('new Pay table id :'||p_per_retained_grade.retain_pay_table_id,20);
                -- Bug#4698321 IF the retained grade record starts on the same day of the action,
                -- update the same record. Otherwise, end date current record and create new record.
                -- Bug#4719037 RG record created unnecessarily where g_pay_table_upd_flag is FALSE.
                -- So, added the per_retained_grade_flag condition to avoid it.
                IF p_per_retained_grade.per_retained_grade_flag = 'Y' THEN
                    IF TRUNC(fnd_date.canonical_to_date(l_cur_date_from)) = TRUNC(p_pa_request_rec.effective_date) THEN
                        hr_utility.set_location('RG Start date Equal to RPA Effective Date ',22);
                        Generic_Update_Extra_Info
                        (p_pa_request_rec          =>   P_PA_REQUEST_REC
                        ,p_l_information_type      =>   'GHR_US_RETAINED_GRADE'
                        ,p_extra_info_id           =>   l_retained_grade_rec.person_extra_info_id
                        ,p_l_object_version_number =>   l_ret_object_version_number
                        ,p_information1            =>   l_cur_date_from
                        ,p_information2            =>   l_new_date_to
                        ,p_information3            =>   l_new_grade_or_level
                        ,p_information4            =>   l_new_step_or_rate
                        ,p_information5            =>   l_new_pay_plan
                        ,p_information6            =>   l_new_pay_table
                        ,p_Information7            =>   l_new_loc_percent
                        ,p_information8            =>   l_new_pay_basis
                        ,p_information9            =>   l_new_temp_step
                       );
                    ELSE
                        hr_utility.set_location('RG Start date NOT EQUAL to RPA Effective Date ',27);
                        Generic_Update_Extra_Info
                        (p_pa_request_rec          =>   P_PA_REQUEST_REC
                        ,p_l_information_type      =>   'GHR_US_RETAINED_GRADE'
                        ,p_extra_info_id           =>   l_retained_grade_rec.person_extra_info_id
                        ,p_l_object_version_number =>   l_ret_object_version_number
                        ,p_information2            =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
                        );

                        -- Create the new RG Record with Temporary Promotion Step Value
                        hr_person_extra_info_api.create_person_extra_info
                        (p_person_id                =>  p_pa_request_rec.person_id,
                        p_information_type         =>  'GHR_US_RETAINED_GRADE',
                        p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
                        p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
                        p_object_version_number    =>  l_ovn,
                        p_pei_information1         =>
                        fnd_date.date_to_canonical(p_pa_request_rec.effective_date),
                        p_pei_information2         =>  l_new_date_to,
                        p_pei_information3         =>  l_new_grade_or_level,
                        p_pei_information4         =>  l_new_step_or_rate,
                        p_pei_information5         =>  l_new_pay_plan,
                        p_pei_information6         =>  l_new_pay_table,
                        p_pei_information7         =>  l_new_loc_percent,
                        p_pei_information8         =>  l_new_pay_basis,
                        p_pei_information9         =>  l_new_temp_step
                        );
                    END IF;
                    hr_utility.set_location('Inside FWFA processing ',3);
                END IF; -- per_retained_grade_flag
            END IF;  -- l_retained_grade_rec.person_extra_info_id NOT NULL
        EXCEPTION
            -- IF No RG Record Exists, skip this updation.
            WHEN ghr_pay_calc.pay_calc_message THEN
                NULL;
            WHEN OTHERS THEN
                RAISE;
        END;
    END IF;
    -- FWFA Changes
Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          P_Per_retained_grade := l_per_retained_grade;
          raise;

END Update_Retained_Grade;
--
------------------------------
-- Procedure Update_edu_sit -- To create/Update Education Sp. Info Type
-------------------------------

Procedure update_edu_sit
(p_pa_request_rec    in ghr_pa_requests%rowtype
) is

l_proc                      varchar2(72) := 'Generic Sit';
l_business_group_id         per_people_f.business_group_id%type;
l_id_flex_num               fnd_id_flex_structures.id_flex_num%type;
l_analysis_criteria_id      per_analysis_criteria.analysis_criteria_id%type;
l_personal_analysis_id      per_person_analyses.person_analysis_id%type;
l_education_level           ghr_pa_requests.education_level%type;
l_year_degree_attained      ghr_pa_requests.year_degree_attained%type;
l_academic_discipline       ghr_pa_requests.academic_discipline%type;
l_object_version_number     number(9);
l_multiple                  varchar2(1);
l_session                   ghr_history_api.g_session_var_type;
l_special_info              ghr_api.special_information_type;



-- Cursor to fetch the id_flex_num for the "US Fed Education" structure

Cursor c_flex_num is
  select id_flex_num
  from   fnd_id_flex_structures_tl
  where  id_flex_structure_name = 'US Fed Education'
  and    language = 'US';
--  and    id_flex_code           = 'PEA'  --??
--  and    application_id         =  800   --??

-- Cursor to check if  the Special info type record already exists for the person

Cursor c_person_sit is
  select analysis_criteria_id ,
         person_analysis_id   ,
         object_version_number
  from   per_person_analyses
  where  person_id    =  p_pa_request_rec.person_id
  and    id_flex_num  =  l_id_flex_num;

--  Cursor to return the record with the highest education level (segment1) for the person for the specific id_flex_num

Cursor     c_special_info is
  select   pea.analysis_criteria_id,
           pea.segment1 education_level,
           pea.segment2 academic_discipline,
           pea.segment3 year_degree_attained,
           pan.person_analysis_id,
           pan.object_version_number
  from     per_analysis_criteria pea,
           per_person_analyses pan
  where    pan.person_id             =  p_pa_request_rec.person_id
            and     pan.id_flex_num           =  l_id_flex_num
                and     pea.id_flex_num           =  pan.id_flex_num
            and     p_pa_request_rec.effective_date
                between nvl(pan.date_from,p_pa_request_rec.effective_date)
                and     nvl(pan.date_to,p_pa_request_rec.effective_date)
                and     p_pa_request_rec.effective_date
                between nvl(pea.start_date_active,p_pa_request_rec.effective_date)
                and     nvl(pea.end_date_active,p_pa_request_rec.effective_date)
                and     pan.analysis_criteria_id        =  pea.analysis_criteria_id
  order by pea.segment1 desc;


--
Cursor c_edu_sit is
  select  segment1 education_level,
          segment2 academic_discipline,
          segment3 year_degree_attained
  from    per_analysis_criteria
  where   analysis_criteria_id = l_analysis_criteria_id
  and     id_flex_num          = l_id_flex_num;

-- Cursor to select the business_group_id that the person belongs to

Cursor  c_bgpid is
  select business_group_id
  from   per_all_people_f
  where  person_id = p_pa_request_rec.person_id
  and    p_pa_request_rec.effective_date
  between  effective_start_date and effective_end_date;

-- Cursor to check if the specific special info. type is Multiple Occurring, depending on which
-- we can then determine whether a record has to be created / Updated

Cursor   c_multiple_occur is
  select multiple_occurrences_flag
  from   per_special_info_types sit
  where  business_group_id = l_business_group_id
  and    id_flex_num       = l_id_flex_num;


 -- determine whether to create or update sit
 -- 1 Get the id_flex_num for the id_flex_structure 'US Fed Education'

begin
    hr_utility.set_location('Entering ' || l_proc,5);

    for bgp in c_bgpid loop
      hr_utility.set_location(l_proc,10);
      l_business_group_id := bgp.business_group_id;
    End loop;

    for flex_num in c_flex_num loop
      hr_utility.set_location(l_proc,12);
      l_id_flex_num  :=  flex_num.id_flex_num;
    end loop;
    hr_utility.set_location(l_proc,15);

 -- Check to see if the person already has an entry for the SIT

    for person_sit in c_person_sit loop
      hr_utility.set_location(l_proc,20);
      l_analysis_criteria_id  := person_sit.analysis_criteria_id;
      l_personal_analysis_id  := person_sit.person_analysis_id;
      l_object_version_number := person_sit.object_version_number;
    End loop;

-- If l_analysis_Criteria_id is null, then create a sit.
-- If it exists, and multiple_occurences allowed
-- If it exists check if the values have to updated at all. If they are the same do not update
-- else update_sit


-- Note : If multiple_occurences are allowed, for the special_info_type, then
--        Update only in case of a 'CORRECTION' ,else create new rows in pan and pea
--        Also while retrieving , fetch the row that has the highest education level -??


   If l_analysis_criteria_id is null then
     hr_utility.set_location(l_proc,25);
     hr_sit_api.create_sit
     (p_person_id                  => p_pa_request_rec.person_id,
      p_business_group_id          => l_business_group_id,
      p_id_flex_num                => l_id_flex_num,
      p_effective_date             => p_pa_request_rec.effective_date,
      p_date_from                  => p_pa_request_rec.effective_date,
      p_segment1                   => p_pa_request_rec.education_level,
      p_segment2                   => p_pa_request_rec.academic_discipline,
      p_segment3                   => p_pa_request_rec.year_degree_attained,
      p_analysis_criteria_id       => l_analysis_criteria_id, --out
      p_person_analysis_id         => l_personal_analysis_id,
      p_pea_object_version_number  => l_object_version_number
     );
     hr_utility.set_location(l_proc,30);

   Else
     -- If sit already exists for the person and it can be multiple occurring, then
     -- if it is not a correction, then create  a new one, else update
        hr_utility.set_location(l_proc,35);
     /*
        Commented out nocopy by skutteti for bug # 655203 as multiple occurences flag need not be checked for edu sit.
     for  multiple_occur in c_multiple_occur loop
       hr_utility.set_location(l_proc,36);
       l_multiple :=  multiple_occur.multiple_occurrences_flag;
     end loop;
     */

    ghr_history_api.get_g_session_var(l_session);
     If l_session.noa_id_correct  is null then
       l_personal_analysis_id := Null;
       for special_info in c_special_info loop
         hr_utility.set_location(l_proc,40);
         l_education_level       := special_info.education_level;
         l_academic_discipline   := special_info.academic_discipline;
         l_year_degree_attained  :=  special_info.year_degree_attained;
         l_personal_analysis_id  :=   special_info.person_analysis_id;
         l_object_version_number :=  special_info.object_version_number;
         exit;
       End loop;
      Else -- read from history
        l_personal_analysis_id := Null;
        ghr_history_fetch.return_special_information
        (p_person_id          => p_pa_request_rec.person_id,
         p_structure_name     => 'US Fed Education',
         p_effective_date     => p_pa_request_rec.effective_date,
         p_special_info       => l_special_info
         );
         l_education_level       :=  l_special_info.segment1;
         l_academic_discipline   :=  l_special_info.segment2;
         l_year_degree_attained  :=  l_special_info.segment3;
         l_personal_analysis_id  :=  l_special_info.person_analysis_id;
         l_object_version_number :=  l_special_info.object_version_number;
     End if;

     hr_utility.set_location(l_proc,45);
hr_utility.set_location('l_education_level is  '||l_education_level,46);
    hr_utility.set_location('l_academic_discipline is  '||l_academic_discipline,47);
    hr_utility.set_location('l_year_degree_attained is  '||l_year_degree_attained,48);

    hr_utility.set_location('p_pa_request_rec.education_level is  '||p_pa_request_rec.education_level,46);
    hr_utility.set_location('p_pa_request_rec.academic_discipline is  '||p_pa_request_rec.academic_discipline,46);
    hr_utility.set_location('p_pa_request_rec.year_degree_attained is  '||p_pa_request_rec.year_degree_attained,46);

     If nvl(l_education_level,hr_api.g_varchar2)     <> nvl(p_pa_request_rec.education_level,hr_api.g_varchar2)     or
        nvl(l_academic_discipline,hr_api.g_varchar2) <> nvl(p_pa_request_rec.academic_discipline,hr_api.g_varchar2) or
        to_char(nvl(l_year_degree_attained,hr_api.g_number))  <> to_char(nvl(p_pa_request_rec.year_degree_attained,hr_api.g_number)) then

        -- Commented out by skutteti for bug # 655203 as multiple occurences flag need not be checked for edu sit.
        -- If nvl(l_multiple,'Y') = 'Y' and l_session.noa_id_correct is null then

        If l_session.noa_id_correct is null or l_personal_analysis_id is null then
           hr_utility.set_location(l_proc,37);
      l_analysis_criteria_id  := null;
           hr_sit_api.create_sit
          (p_person_id                  => p_pa_request_rec.person_id,
           p_business_group_id          => l_business_group_id,
           p_id_flex_num                => l_id_flex_num,
           p_effective_date             => p_pa_request_rec.effective_date,
           p_date_from                  => p_pa_request_rec.effective_date,
           p_segment1                   => p_pa_request_rec.education_level,
           p_segment2                   => p_pa_request_rec.academic_discipline,
           p_segment3                   => to_char(p_pa_request_rec.year_degree_attained),
           p_analysis_criteria_id       => l_analysis_criteria_id, --out
           p_person_analysis_id         => l_personal_analysis_id,
           p_pea_object_version_number  => l_object_version_number
          );
        Else
      l_analysis_criteria_id  := null;
           hr_sit_api.update_sit
          (p_person_analysis_id         => l_personal_analysis_id,
           p_pea_object_version_number  => l_object_version_number,
           p_date_from                  => p_pa_request_rec.effective_date,   ---??
           p_segment1                   => p_pa_request_rec.education_level,
           p_segment2                   => p_pa_request_rec.academic_discipline,
           p_segment3                   => p_pa_request_rec.year_degree_attained,
           p_analysis_criteria_id       => l_analysis_criteria_id
           );
           hr_utility.set_location(l_proc,55);
        End if;
     End if;
  End if;
End update_edu_sit;
--


--


-- *************************
-- Procedure  call_extra_info_api
-- *************************
--
Procedure  call_extra_info_api
 (P_PA_REQUEST_REC                IN  GHR_PA_REQUESTS%ROWTYPE,
 P_Asg_Sf52                       IN OUT NOCOPY GHR_API.Asg_Sf52_TYPE,
 P_Asg_non_Sf52                   IN OUT NOCOPY GHR_API.Asg_non_Sf52_TYPE,
 P_Asg_nte_dates                  IN OUT NOCOPY GHR_API.Asg_nte_dates_TYPE,
 P_Per_Sf52                       IN OUT NOCOPY GHR_API.Per_Sf52_TYPE,
 P_Per_Group1                     IN OUT NOCOPY GHR_API.Per_Group1_TYPE,
 P_Per_Group2                     IN OUT NOCOPY GHR_API.Per_Group2_TYPE,
 P_Per_scd_info                   IN OUT NOCOPY GHR_API.Per_scd_info_TYPE,
 P_Per_retained_grade             IN OUT NOCOPY GHR_API.Per_retained_grade_TYPE,
 P_Per_probations                 IN OUT NOCOPY GHR_API.Per_probations_TYPE,
 P_Per_sep_retire                 IN OUT NOCOPY GHR_API.Per_sep_retire_TYPE,
 P_Per_security                   IN OUT NOCOPY GHR_API.Per_security_TYPE,
 --Bug#4486823 RRR Changes
 p_per_service_oblig              IN OUT NOCOPY GHR_API.Per_service_oblig_TYPE,
 P_Per_conversions                IN OUT NOCOPY GHR_API.Per_conversions_TYPE,
 -- BEN_EIT Changes
 p_per_benefit_info	          IN OUT nocopy ghr_api.per_benefit_info_type,
 P_Per_uniformed_services         IN OUT NOCOPY GHR_API.Per_uniformed_services_TYPE,
 P_Pos_oblig                      IN OUT NOCOPY GHR_API.Pos_oblig_TYPE,
 P_Pos_Grp2                       IN OUT NOCOPY GHR_API.Pos_Grp2_TYPE,
 P_Pos_Grp1                       IN OUT NOCOPY GHR_API.Pos_Grp1_TYPE,
 P_Pos_valid_grade                IN OUT NOCOPY GHR_API.Pos_valid_grade_TYPE,
 P_Pos_car_prog                   IN OUT NOCOPY GHR_API.Pos_car_prog_TYPE,
 p_Perf_appraisal                 IN out nocopy ghr_api.performance_appraisal_type,
 p_conduct_performance            IN out nocopy ghr_api.conduct_performance_type,
 P_Loc_Info                       IN OUT NOCOPY GHR_API.Loc_Info_TYPE,
 P_generic_Extra_Info_Rec         IN out nocopy GHR_api.generic_Extra_Info_Rec_Type,
 P_par_term_retained_grade        IN out nocopy GHR_api.par_term_retained_grade_type,
 p_per_race_ethnic_info      	  IN out nocopy ghr_api.per_race_ethnic_type,
 -- Bug #6312144 New RPA EIT Benefits
 p_ipa_benefits_cont              IN out nocopy ghr_api.per_ipa_ben_cont_info_type,
 p_retirement_info                IN out nocopy ghr_api.per_retirement_info_type)  is

--
 l_proc             varchar2(70) := 'Call Extra Info';
 l_segment_rec      ghr_api.special_information_type;
 l_form_field_name  varchar2(50);
 l_posn_title_pm    varchar2(50);
 l_WS_pm            varchar2(50);
 l_DS_pm            varchar2(50);
 l_personnel_office_id   ghr_pa_requests.personnel_office_id%type;       --\
 l_org_structure_id      per_position_extra_info.poei_information5%type; -------bug#2623692
 l_Organ_Component       per_position_extra_info.poei_information5%type; --/
-- JH Get To Position Title PM for Noa Code being updated. Bug 773851
  Cursor get_to_posn_title_pm is
    select  fpm.process_method_code
    from    ghr_noa_families         nof
           ,ghr_families             fam
           ,ghr_noa_fam_proc_methods fpm
           ,ghr_pa_data_fields       pdf
    where   nof.nature_of_action_id = p_pa_request_rec.first_noa_id
    and     nof.noa_family_code     = fam.noa_family_code
    and     nof.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(nof.start_date_active,p_pa_request_rec.effective_date)
    and     nvl(nof.end_date_active,p_pa_request_rec.effective_date )
    and     fam.proc_method_flag = 'Y'
    and     fam.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(fam.start_date_active,p_pa_request_rec.effective_date)
    and     nvl(fam.end_date_active,p_pa_request_rec.effective_date)
    and     fam.noa_family_code = fpm.noa_family_code
    and     fpm.pa_data_field_id = pdf.pa_data_field_id
    and     fpm.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(fpm.start_date_active,p_pa_request_rec.effective_date)
    and     nvl(fpm.end_date_active,p_pa_request_rec.effective_date)
    and     pdf.form_field_name = l_form_field_name
    and     pdf.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(pdf.date_from,p_pa_request_rec.effective_date)
    and     nvl(pdf.date_to,p_pa_request_rec.effective_date );

------------------ cursor created to handle Null Org Struct id for MRE Correction
Cursor c_pei_null_OPM(p_position_id number) is
select poei_information5 l_org_structure_id
from per_position_extra_info
where information_type='GHR_US_POS_GRP1' and position_id=p_position_id;

----------------------------------- cursor to handle changes to LAC codes for Correction to Apptmt action 1274541
Cursor c_Corr_LAC_Codes(p_pa_request_id number) is
select second_action_la_code1,second_action_la_code2,first_noa_code,second_noa_code,
second_action_la_desc1,second_action_la_desc2 --Bug# 4941984(AFHR2)
from ghr_pa_requests
where pa_request_id=p_pa_request_id and first_noa_code='002';


Cursor fam_code(p_second_noa_id number) is
select noa_family_code from ghr_noa_families
where nature_of_action_id=p_second_noa_id and noa_family_code='APP'
AND
nature_of_action_id not in (select nature_of_action_id from ghr_noa_families
where noa_family_code='APPT_TRANS');

--
-- 2839332
--
Cursor Cur_Par_Asg(p_ssn VARCHAR2) is
select par.first_noa_code
from
ghr_pa_requests par,
per_Assignments_f asg
where asg.assignment_id=par.employee_assignment_id
and par.employee_national_identifier=p_ssn
and noa_family_code not in
('NON_PAY_DUTY_STATUS','RETURN_TO_DUTY','CANCEL','CORRECT')
and par.effective_date=asg.effective_start_date
Order by effective_date asc;

-- 2839332 Madhuri
-- 3263014 Sundar Datatype of the parameters have been changed to table.column_name%type
/*Cursor Cur_NTE_dates(p_ssn ghr_pa_requests.employee_national_identifier%type, p_noa_code ghr_pa_requests.first_noa_code%type) is
select first_noa_information1 NTE_Dates
from ghr_pa_requests
where first_noa_code=p_noa_code
and noa_family_code not in
('NON_PAY_DUTY_STATUS','RETURN_TO_DUTY','CANCEL','CORRECT')
and employee_national_identifier=p_ssn;
*/
-- Sundar Bug 3390876
-- Get the effective date of Non-Pay duty status
CURSOR cur_eff_date_non_pay(c_person_id ghr_pa_requests.person_id%type,c_eff_date ghr_pa_requests.effective_date%type)
IS
SELECT
  MAX(par.effective_date) eff_date
FROM
  ghr_pa_requests par
WHERE
  par.person_id= c_person_id  AND
  par.noa_family_code = 'NON_PAY_DUTY_STATUS' AND
  par.pa_notification_id IS NOT NULL AND
  NVL(par.first_noa_cancel_or_correct,'NULL') <> 'CANCEL' AND
  par.effective_date < c_eff_date;

CURSOR cur_nte_date_aft_np(c_person_id ghr_pa_requests.person_id%type,
                           c_eff_date ghr_pa_requests.effective_date%type, c_rtd_date ghr_pa_requests.effective_date%type)
IS
SELECT
  par.first_noa_information1 nte_date
FROM
  ghr_pa_requests par
WHERE
  par.person_id= c_person_id  AND
  par.effective_date BETWEEN c_eff_date AND c_rtd_date AND
  par.pa_notification_id IS NOT NULL  AND
  NVL(par.first_noa_cancel_or_correct, 'NULL') <> 'CANCEL' AND
  par.first_noa_code IN ('508','515','517','522','548','549','553','554','571','590','750','760','761','762','765','769','770');

/*CURSOR Cur_NTE_date_bef_np(c_person_id ghr_pa_requests.person_id%type,c_eff_date ghr_pa_requests.effective_date%type)
IS
SELECT
  first_noa_information1 NTE_Dates
FROM
  ghr_pa_requests par,
  per_Assignments_f asg
WHERE
  asg.assignment_id= par.employee_assignment_id AND
  asg.effective_start_date = par.effective_date AND
  par.person_id= c_person_id AND
  par.effective_date < c_eff_date AND
  par.noa_family_code NOT IN ('NON_PAY_DUTY_STATUS','RETURN_TO_DUTY','CANCEL','CORRECT')  AND
  par.pa_notification_id IS NOT NULL AND
  NVL(par.first_noa_cancel_or_correct, 'NULL') <> 'CANCEL'
  ORDER BY effective_date ASC;
*/
l_noa_code              VARCHAR2(80);
l_NTE_Dates             per_assignment_extra_info.aei_information4%TYPE;

--
-- for bug 3191704
CURSOR cur_rei_poi(p_par_id in NUMBER)
IS
SELECT rei_information5
FROM   ghr_pa_request_extra_info
WHERE  pa_request_id=p_par_id
AND    information_type='GHR_US_PAR_REALIGNMENT';

target_poi              ghr_pa_requests.personnel_office_id%type;
-- for bug 3191704

--l_NTE_Dates   per_assignment_extra_info.aei_information4%TYPE;
---------------------------------------------------------- added 2 cursors for 1274541
--Begin Bug 5919705
l_grade_or_level ghr_pa_requests.to_grade_or_level%type;
l_pay_plan       ghr_pa_requests.to_pay_plan%type;

CURSOR cur_grd1 IS
    SELECT  gdf.segment1 pay_plan,
            gdf.segment2 grade_or_level
    FROM    per_grade_definitions gdf,
            per_grades grd
    WHERE   grd.grade_id            =   p_pos_valid_grade.target_grade
    AND     grd.grade_definition_id =   gdf.grade_definition_id
    AND     grd.business_group_id   =   FND_PROFILE.value('PER_BUSINESS_GROUP_ID');

CURSOR cur_grd2 IS
    SELECT  grd.grade_id
    FROM    per_grade_definitions gdf,
            per_grades grd
    WHERE   grd.grade_definition_id = gdf.grade_definition_id
    and     gdf.segment1            = l_pay_plan
    and     gdf.segment2            = l_grade_or_level
    and     grd.business_group_id   = FND_PROFILE.value('PER_BUSINESS_GROUP_ID');
--End Bug 5919705
l_first_noa_code ghr_pa_requests.first_noa_code%type;
l_second_noa_code ghr_pa_requests.second_noa_code%type;
l_fam_code ghr_pa_requests.noa_family_code%type;

l_Cur_Appt_Auth_1                       per_people_extra_info.pei_information8%type;
l_Cur_Appt_Auth_2                       per_people_extra_info.pei_information9%type;
--Bug# 4941984(AFHR2)
l_Cur_Appt_Auth_desc1                   per_people_extra_info.pei_information22%type;
l_Cur_Appt_Auth_desc2                   per_people_extra_info.pei_information23%type;
--Bug# 4941984(AFHR2)

-- No copy Changes variables.
 l_Asg_Sf52                         GHR_API.Asg_Sf52_TYPE;
 l_Asg_non_Sf52                     GHR_API.Asg_non_Sf52_TYPE;
 l_Asg_nte_dates                    GHR_API.Asg_nte_dates_TYPE;
 l_Per_Sf52                         GHR_API.Per_Sf52_TYPE;
 l_Per_Group1                       GHR_API.Per_Group1_TYPE;
 l_Per_Group2                       GHR_API.Per_Group2_TYPE;
 l_Per_scd_info                     GHR_API.Per_scd_info_TYPE;
 l_Per_retained_grade               GHR_API.Per_retained_grade_TYPE;
 l_Per_probations                   GHR_API.Per_probations_TYPE;
 l_Per_sep_retire                   GHR_API.Per_sep_retire_TYPE;
 l_Per_security                     GHR_API.Per_security_TYPE;
 --Bug#4486823 RRR Changes
 l_per_service_oblig                GHR_API.Per_service_oblig_TYPE;
 l_Per_conversions                  GHR_API.Per_conversions_TYPE;
 l_per_race_ethnic_info             ghr_api.per_race_ethnic_type; -- Race or National Origin changes
 -- BEN_EIT Changes
 l_per_benefit_info		    GHR_API.per_benefit_info_type;
 l_Per_uniformed_services           GHR_API.Per_uniformed_services_TYPE;
 l_Pos_oblig                        GHR_API.Pos_oblig_TYPE;
 l_Pos_Grp2                         GHR_API.Pos_Grp2_TYPE;
 l_Pos_Grp1                         GHR_API.Pos_Grp1_TYPE;
 l_Pos_valid_grade                  GHR_API.Pos_valid_grade_TYPE;
 l_Pos_car_prog                     GHR_API.Pos_car_prog_TYPE;
 l_Perf_appraisal                   ghr_api.performance_appraisal_type;
 l_conduct_performance              ghr_api.conduct_performance_type;
 l_Loc_Info                         GHR_API.Loc_Info_TYPE;
 l_generic_Extra_Info_Rec           GHR_api.generic_Extra_Info_Rec_Type;
 l_par_term_retained_grade          GHR_api.par_term_retained_grade_type;
---for bug 3267632
 l_agency_code_transfer_to          ghr_pa_requests.agency_code%type;
--
-- Bug 3390876
 l_np_eff_date ghr_pa_requests.effective_date%type;
 l_asg_ei_data per_assignment_extra_info%rowtype;
Begin
--
  hr_utility.set_location('Entering  ' ||l_proc,5);
  hr_utility.set_location('CALL EXT INFOper_serv_oblig_flag '||p_per_service_oblig.per_service_oblig_flag,10);
  --
  -- Remember IN OUT parameter IN values
  --
 l_Asg_Sf52                         := P_Asg_Sf52;
 l_Asg_non_Sf52                     := P_Asg_non_Sf52;
 l_Asg_nte_dates                    := P_Asg_nte_dates;
 l_Per_Sf52                         := P_Per_Sf52;
 l_Per_Group1                       := P_Per_Group1;
 l_Per_Group2                       := P_Per_Group2;
 l_Per_scd_info                     := P_Per_scd_info;
 l_Per_retained_grade               := P_Per_retained_grade;
 l_Per_probations                   := P_Per_probations;
 l_Per_sep_retire                   := P_Per_sep_retire;
 l_Per_security                     := P_Per_security;
 -- Bug#4486823 RRR changes
 l_per_service_oblig                := P_per_service_oblig;
 l_Per_conversions                  := P_Per_conversions;
 -- BEN_EIT Changes
 l_per_benefit_info                 := P_Per_benefit_info;
 l_Per_uniformed_services           := P_Per_uniformed_services;
 l_Pos_oblig                        := P_Pos_oblig;
 l_Pos_Grp2                         := P_Pos_Grp2;
 l_Pos_Grp1                         := P_Pos_Grp1;
 l_Pos_valid_grade                  := P_Pos_valid_grade;
 l_Pos_car_prog                     := P_Pos_car_prog;
 l_Perf_appraisal                   := P_Perf_appraisal;
 l_conduct_performance              := P_conduct_performance;
 l_Loc_Info                         := P_Loc_Info;
 l_generic_Extra_Info_Rec           := P_generic_Extra_Info_Rec;
 l_par_term_retained_grade          := P_par_term_retained_grade;
 l_per_race_ethnic_info		    := p_per_race_ethnic_info;

  IF P_asg_sf52.asg_sf52_flag  =  'Y'
  OR ghr_process_sf52.g_prd is not null THEN
  -- FWFA Changes
--
    hr_utility.set_location(l_proc,10);
    Generic_Update_Extra_Info
    (
     p_pa_request_rec                   =>    P_PA_REQUEST_REC
    ,p_l_information_type               =>    'GHR_US_ASG_SF52'
    ,p_extra_info_id                    =>    p_asg_sf52.assignment_extra_info_id
    ,p_l_object_version_number          =>    p_asg_sf52.object_version_number
    ,p_information3                     =>    p_asg_sf52.step_or_rate
    ,p_information4                     =>    p_asg_sf52.tenure
    ,p_information5                     =>    p_asg_sf52.annuitant_indicator
    ,p_information6                     =>    nvl(ghr_process_sf52.g_prd,p_asg_sf52.pay_rate_determinant)
    ,p_information7                     =>    p_asg_sf52.work_schedule
    ,p_information8                     =>    p_asg_sf52.part_time_hours
    -- FWFA Changes Bug#4444609. Added NVL condition to handle the families that doesn't trigger pay calc.
    ,p_information9                     =>    P_Asg_Sf52.calc_pay_table
    -- FWFA Changes
    );
  End if;
--
  If P_asg_non_sf52.asg_non_sf52_flag  =  'Y' then
--
    hr_utility.set_location(l_proc,15);
    Generic_Update_Extra_Info
    (
     p_pa_request_rec                   =>      P_PA_REQUEST_REC
    ,p_l_information_type               =>      'GHR_US_ASG_NON_SF52'
    ,p_extra_info_id                    =>      p_asg_non_sf52.assignment_extra_info_id
    ,p_l_object_version_number          =>      p_asg_non_sf52.object_version_number
    ,p_information3                     =>      p_asg_non_sf52.date_arr_personnel_office
 -- ,p_information4                     =>      p_asg_non_sf52.duty_status
    ,p_information5                     =>      p_asg_non_sf52.key_emer_essential_empl
    ,p_information6                     =>      p_asg_non_sf52.non_disc_agmt_status
 -- ,p_information7                     =>      p_asg_non_sf52.date_wtop_exemp_expires
    ,p_information8                     =>      p_asg_non_sf52.parttime_indicator
    ,p_information9                     =>      p_asg_non_sf52.qualification_standard_waiver
 -- ,p_information10            =>      p_asg_non_sf52.trainee_promotion_id
 -- ,p_information11            =>      p_asg_non_sf52.date_trainee_promotion_expt
     );
   End if;
--

   hr_utility.set_location('NTE DATES FLAG  ' || p_asg_nte_dates.asg_nte_dates_flag,1);
   If p_asg_nte_dates.asg_nte_dates_flag  =  'Y' then
--
--

   IF (p_pa_request_rec.noa_family_code =  'RETURN_TO_DUTY') THEN
	/*  For PAR_ASG in Cur_Par_Asg(p_pa_request_rec.employee_national_identifier)
	  Loop
				  hr_utility.trace('Inside EMP SSN CURSOR');
						 l_noa_code := PAR_ASG.first_noa_code;
	  End Loop;

	  hr_utility.set_location('NOA Code for NTE' || l_noa_code , 38);
	  FOR NTE_Dates_rec in Cur_NTE_Dates(p_pa_request_rec.employee_national_identifier,l_noa_code) LOOP
		  l_NTE_Dates := NTE_Dates_rec.NTE_Dates;
	  END LOOP; */
		-- Above Commented by Sundar Replaced it by the below code - Bug 3390876
		-- Get effective date of the Non-Pay duty action.
		FOR l_cur_eff_date_non_pay IN cur_eff_date_non_pay(p_pa_request_rec.person_id, NVL(p_pa_request_rec.effective_date,sysdate)) LOOP
			l_np_eff_date := l_cur_eff_date_non_pay.eff_date;
		END LOOP;
		-- Get NTE Date (i.e. first_noa_information1) If any extension actions are done
		-- after Non-Pay duty status
		FOR l_cur_nte_date IN cur_nte_date_aft_np(p_pa_request_rec.person_id, l_np_eff_date, NVL(p_pa_request_rec.effective_date,sysdate)) LOOP
			l_NTE_Dates := l_cur_nte_date.nte_date;
		END LOOP;
		-- If No record is found in the above cursor, then take NTE date from the assignment
		-- prior to Non-pay-duty status
		IF l_NTE_Dates IS NULL THEN
/*			FOR l_Cur_NTE_date_bef_np in Cur_NTE_date_bef_np(p_pa_request_rec.person_id,l_np_eff_date) LOOP
			  l_NTE_Dates := l_Cur_NTE_date_bef_np.NTE_Dates;
			END LOOP; */
			ghr_history_fetch.fetch_asgei ( p_assignment_id => p_pa_request_rec.employee_assignment_id,
                        p_information_type  => 'GHR_US_ASG_NTE_DATES',
                        p_date_effective    => (l_np_eff_date-1),
                        p_asg_ei_data       => l_asg_ei_data
                      );
	-- Bug 3655891 Need to fetch Asg. NTE date from information 4 for Asg. NTE date.
--                l_NTE_Dates := l_asg_ei_data.aei_information3;
	              l_NTE_Dates := l_asg_ei_data.aei_information4;
		END IF;
		-- End Bug 3390876
		IF l_NTE_Dates IS NOT NULL THEN
			p_asg_nte_dates.assignment_nte := l_NTE_Dates;
		END IF;
	END IF;
 --
 --
 hr_utility.set_location(l_proc,20);
     Generic_Update_Extra_Info
     (
      p_pa_request_rec                  =>      P_PA_REQUEST_REC
     ,p_l_information_type              =>      'GHR_US_ASG_NTE_DATES'
     ,p_extra_info_id                   =>      p_asg_nte_dates.assignment_extra_info_id
     ,p_l_object_version_number         =>      p_asg_nte_dates.object_version_number
     ,p_information3                    =>      p_asg_nte_dates.asg_nte_start_date
     ,p_information4					  =>    p_asg_nte_dates.assignment_nte
     ,p_information5                    =>      p_asg_nte_dates.lwop_nte_start_date
     ,p_information6                    =>      p_asg_nte_dates.lwop_nte
     ,p_information7                    =>      p_asg_nte_dates.suspension_nte_start_date
     ,p_information8                    =>      p_asg_nte_dates.suspension_nte
     ,p_information9                    =>      p_asg_nte_dates.furlough_nte_start_date
     ,p_information10                   =>      p_asg_nte_dates.furlough_nte
     ,p_information11               =>    p_asg_nte_dates.lwp_nte_start_date
     ,p_information12               =>    p_asg_nte_dates.lwp_nte
     ,p_information13               =>    p_asg_nte_dates.sabatical_nte_start_date
     ,p_information14               =>    p_asg_nte_dates.sabatical_nte
 -- ,p_information15                =>    p_asg_nte_dates.assignment_number
 -- ,p_information16                  =>        p_asg_nte_dates.position_nte
     );
--
end if;
--
--
--
If p_per_sf52.per_sf52_flag  =  'Y' then
--
  hr_utility.set_location(l_proc,30);
  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_PER_SF52'
  ,p_extra_info_id                      =>      p_per_sf52.person_extra_info_id
  ,p_l_object_version_number    =>      p_per_sf52.object_version_number
  ,p_information3                       =>      p_per_sf52.citizenship
  ,p_information4                       =>      p_per_sf52.veterans_preference
  ,p_information5                       =>      p_per_sf52.veterans_preference_for_rif
  ,p_information6                       =>      p_per_sf52.veterans_status
  );
 --
end if;
--

----------------------------------------------------------------------------------- code added for 1274541

FOR corr_lac IN c_Corr_LAC_Codes(p_pa_request_rec.pa_request_id) LOOP
l_first_noa_code := corr_lac.first_noa_code;
l_second_noa_code:= corr_lac.second_noa_code;
END LOOP;
IF l_first_noa_code = '002' then
    If l_second_noa_code = p_pa_request_rec.first_noa_code then
        FOR fam_code_rec IN fam_code(p_pa_request_rec.first_noa_id)
        LOOP
            l_fam_code              := fam_code_rec.noa_family_code;
        END LOOP;
    end if;
end if;

If p_per_group1.per_group1_flag =  'Y' then
--

IF (l_first_noa_code='002' AND l_fam_code='APP') THEN

        FOR corr_lac_rec in c_Corr_LAC_Codes(p_pa_request_rec.pa_request_id)
        LOOP

         l_Cur_Appt_Auth_1             :=corr_lac_rec.second_action_la_code1;
         l_Cur_Appt_Auth_2             :=corr_lac_rec.second_action_la_code2;
         --Bug# 4941984(AFHR2)
         l_Cur_Appt_Auth_desc1         :=corr_lac_rec.second_action_la_desc1;
         l_Cur_Appt_Auth_desc2         :=corr_lac_rec.second_action_la_desc2;
         --Bug# 4941984(AFHR2)
        END LOOP;
ELSE
        l_Cur_Appt_Auth_1             :=p_per_group1.org_appointment_auth_code1;
        l_Cur_Appt_Auth_2             :=p_per_group1.org_appointment_auth_code2;
        --Bug# 4941984(AFHR2)
        l_Cur_Appt_Auth_desc1         :=p_per_group1.org_appointment_desc1;
        l_Cur_Appt_Auth_desc2         :=p_per_group1.org_appointment_desc2;
        --Bug# 4941984(AFHR2)
END IF;

---------------------------------------------------------------------------------- code added for 1274541


  hr_utility.set_location(l_proc,35);
  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_PER_GROUP1'
  ,p_extra_info_id            =>        p_per_group1.person_extra_info_id
  ,p_l_object_version_number  =>        p_per_group1.object_version_number
  ,p_information3                       =>      p_per_group1.appointment_type
  ,p_information4                       =>      p_per_group1.type_of_employment
  ,p_information5                       =>      p_per_group1.race_national_origin
--,p_information6                     =>        p_per_group1.date_last_promotion
  ,p_information7                       =>      p_per_group1.agency_code_transfer_from
  ,p_information8                       =>      l_Cur_Appt_Auth_1
  ,p_information22                      =>      l_Cur_Appt_Auth_desc1--Bug# 4941984(AFHR2)
  ,p_information9                       =>      l_Cur_Appt_Auth_2
  ,p_information23                      =>      l_Cur_Appt_Auth_desc2--Bug# 4941984(AFHR2)
--,p_information10            =>        p_per_group1.country_world_citizenship
  ,p_information11              =>      p_per_group1.handicap_code
--,p_information12            =>        p_per_group1.consent_id
--,p_information13              =>      p_per_group1.date_fehb_eligibility_expires
--,p_information14            =>        p_per_group1.date_temp_eligibility_fehb
--,p_information15            =>        p_per_group1.date_febh_dependent_cert_exp
--,p_information16            =>        p_per_group1.family_member_emp_pref
--,p_information17            =>        p_per_group1.family_member_status
  ,p_information21            =>        p_per_group1.retention_inc_review_date
   );
--
end if;
--

/* Note :  Since none of this data is currently being updated, why call the generic_update at all ??? */

/*If p_per_group2.per_group2_flag   =  'Y' then
--
-- included date_stat_return_rights_expire for p_information7 and named the others correctly.
  hr_utility.set_location(l_proc,40);
  Generic_Update_Extra_Info
 (
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_GROUP2'
 ,p_extra_info_id                       =>      p_per_group2.person_extra_info_id
 ,p_l_object_version_number     =>      p_per_group2.object_version_number
 ,p_information3                        =>      p_per_group2.obligated_position_number
 ,p_information4                        =>      p_per_group2.obligated_position_type
 ,p_information5                        =>      p_per_group2.date_overseas_tour_expires
 ,p_information6                        =>      p_per_group2.date_return_rights_expires
 ,p_information7              =>    p_per_group2.date_stat_return_rights_expir
 ,p_information8                        =>      p_per_group2.civilian_duty_stat_contigency
 ,p_information9                        =>      p_per_group2.date_travel_agmt_pcs_expires
 ,p_information10                       =>      p_per_group2.draw_down_action_id
 );
--
end if;
*/
--
If p_per_scd_info.per_scd_info_flag   =  'Y' then
--
  hr_utility.set_location(l_proc,45);
  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_PER_SCD_INFORMATION'
  ,p_extra_info_id              =>      p_per_scd_info.person_extra_info_id
  ,p_l_object_version_number    =>      p_per_scd_info.object_version_number
  ,p_information3                       =>      p_per_scd_info.scd_leave
  ,p_information4                       =>      p_per_scd_info.scd_civilian
  ,p_information5                       =>      p_per_scd_info.scd_rif
  ,p_information6                       =>      p_per_scd_info.scd_tsp
  ,p_information7                       =>      p_per_scd_info.scd_retirement
  -- Bug 4164083 eHRI New Attribution Changes
  ,p_information8                       =>      p_per_scd_info.scd_ses
  ,p_information9                       =>      p_per_scd_info.scd_spl_retirement
  -- End eHRI New Attribution Changes
   --bug 4443968
   ,p_information12                      =>    p_per_scd_info.scd_creditable_svc_annl_leave
   );
--
end if;
--
If p_per_probations.per_probation_flag   =  'Y' then
--
  hr_utility.set_location(l_proc,50);

  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_PER_PROBATIONS'
  ,p_extra_info_id              =>      p_per_probations.person_extra_info_id
  ,p_l_object_version_number    =>      p_per_probations.object_version_number
  ,p_information3                       =>      p_per_probations.date_prob_trial_period_begin
  ,p_information4                       =>      p_per_probations.date_prob_trial_period_ends
  --,p_information8                       =>      p_per_probations.date_spvr_mgr_prob_begins --Bug 4588575
  ,p_information5                       =>      p_per_probations.date_spvr_mgr_prob_ends
  ,p_information6                       =>      p_per_probations.spvr_mgr_prob_completion
  ,p_information7                       =>      p_per_probations.date_ses_prob_expires
   );
--
end if;
--
-- added for 3267632
 If ( p_pa_request_rec.noa_family_code in ('APP','CONV_APP') ) Then
  l_agency_code_transfer_to            := NULL;
  p_per_sep_retire.per_sep_retire_flag :=  'Y';
 else
  l_agency_code_transfer_to            := p_per_sep_retire.agency_code_transfer_to;
 End if;
-- added for 3267632
--
If p_per_sep_retire.per_sep_retire_flag =  'Y' then
--
  hr_utility.set_location(l_proc,55);
  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_PER_SEPARATE_RETIRE'
  ,p_extra_info_id              =>      p_per_sep_retire.person_extra_info_id
  ,p_l_object_version_number    =>      p_per_sep_retire.object_version_number
  ,p_information3                       =>      p_per_sep_retire.fers_coverage
  ,p_information4                       =>      p_per_sep_retire.prev_retirement_coverage
  ,p_information5                       =>      p_per_sep_retire.frozen_service
  ,p_information6                       =>      p_per_sep_retire.naf_retirement_indicator
  ,p_information7                       =>      p_per_sep_retire.reason_for_separation
  ,p_information8                       =>      l_agency_code_transfer_to
--,p_information9                       =>      p_per_sep_retire.date_projected_retirement
--,p_information10              =>      p_per_sep_retire.mandatory_retirement_date
  ,p_information11              =>      p_per_sep_retire.separate_pkg_status_indicator -- Bug 1359482
--,p_information12              =>      p_per_sep_retire.separate_pkg_register_number
--,p_information13              =>      p_per_sep_retire.separate_pkg_pay_office_id
--,p_information14              =>      p_per_sep_retire.date_ret_appl_received
--,p_information15              =>      p_per_sep_retire.date_ret_pkg_sent_to_payroll
--,p_information16              =>      p_per_sep_retire.date_ret_pkg_recv_payroll
--,p_information17              =>      p_per_sep_retire.date_ret_pkg_to_opm
  );
--
end if;
--

 /* Note :  Since none of this data is currently being updated, why call the generic_update at all ??? */

/*If p_per_security.per_security_flag  =  'Y' then
--
hr_utility.set_location(l_proc,60);
Generic_Update_Extra_Info(
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_SECURITY'
 ,p_extra_info_id                       =>      p_per_security.person_extra_info_id
 ,p_l_object_version_number     =>      p_per_security.object_version_number
 ,p_information3                        =>      p_per_security.sec_investigation_basis
 ,p_information4                        =>      p_per_security.type_of_sec_investigation
 ,p_information5                        =>      p_per_security.date_sec_invest_required
 ,p_information6                        =>      p_per_security.date_sec_invest_completed
 ,p_information7                        =>      p_per_security.personnel_sec_clearance
 ,p_information8                        =>      p_per_security.sec_clearance_eligilb_date
 ,p_information9                        =>      p_per_security.prp_sci_status_employment
);
--
end if;
*/
  hr_utility.set_location('2. CALL EXT INFOper_serv_oblig_flag '||p_per_service_oblig.per_service_oblig_flag,20);
-- Bug#4486823 RRR Changes
IF p_per_service_oblig.per_service_oblig_flag  =  'Y' THEN
--
hr_utility.set_location('NAR'||l_proc,60);
Generic_Update_Extra_Info(
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_SERVICE_OBLIGATION'
 ,p_extra_info_id               =>      p_per_service_oblig.person_extra_info_id
 ,p_l_object_version_number     =>      p_per_service_oblig.object_version_number
 ,p_information3                =>      p_per_service_oblig.service_oblig_type_code
 ,p_information4                =>      p_per_service_oblig.service_oblig_end_date
 ,p_information5                =>      p_per_service_oblig.service_oblig_start_date
);
--
END IF;
--
-- Added for a patch -- ( for the enhancement)
If p_per_conversions.per_conversions_flag =  'Y' then
--
  hr_utility.set_location(l_proc,65);

 Generic_Update_Extra_Info
 (
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_CONVERSIONS'
 ,p_extra_info_id                       =>      p_per_conversions.person_extra_info_id
 ,p_l_object_version_number     =>      p_per_conversions.object_version_number
 ,p_information3                        =>      p_per_conversions.date_conv_career_begins
 ,p_information4                        =>      p_per_conversions.date_conv_career_due
 ,p_information5                        =>      p_per_conversions.date_recmd_conv_begins
 ,p_information7              =>    p_per_conversions.date_recmd_conv_due
 ,p_information6                        =>      p_per_conversions.date_vra_conv_due
 );
--
end if;
--
-- BEN_EIT Changes
If p_per_benefit_info.per_benefit_info_flag =  'Y' then
--
  hr_utility.set_location(l_proc,65);

 Generic_Update_Extra_Info
 (
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_BENEFIT_INFO'
 ,p_extra_info_id               =>      p_per_benefit_info.person_extra_info_id
 ,p_l_object_version_number     =>      p_per_benefit_info.object_version_number
 ,p_information3                =>      p_per_benefit_info.FEGLI_Date_Eligibility_Expires
 ,p_information4            => p_per_benefit_info.FEHB_Date_Eligibility_expires
 ,p_information5             => p_per_benefit_info.FEHB_Date_temp_eligibility
            ,p_information6        => p_per_benefit_info.FEHB_Date_dependent_cert_expir
            ,p_information7        => p_per_benefit_info.FEHB_LWOP_contingency_st_date
            ,p_information8        => p_per_benefit_info.FEHB_LWOP_contingency_end_date
            ,p_information10       => p_per_benefit_info.FEHB_Child_equiry_court_date
            ,p_information11       => p_per_benefit_info.FERS_Date_eligibility_expires
            ,p_information12       => p_per_benefit_info.FERS_Election_Date
            ,p_information13       => p_per_benefit_info.FERS_Election_Indicator
            ,p_information14       => p_per_benefit_info.TSP_Agncy_Contrib_Elig_date
            ,p_information15       => p_per_benefit_info.TSP_Emp_Contrib_Elig_date
	      -- 6312144 Added the following RPA -- EIT Benefits segments
	    ,p_information16       => p_per_benefit_info.FEGLI_Assignment_Ind
            ,p_information17       => p_per_benefit_info.FEGLI_Post_Elec_Basic_Ins_Amt
            ,p_information18       => p_per_benefit_info.FEGLI_Court_Order_Ind
            ,p_information19       => p_per_benefit_info.Desg_FEGLI_Benf_Ind
            ,p_information20       => p_per_benefit_info.FEHB_Event_Code
  );
--
end if;

-- Race or National Origin changes
If p_per_race_ethnic_info.p_race_ethnic_info_flag =  'Y' then
--
  hr_utility.set_location(l_proc,68);

 Generic_Update_Extra_Info
 (
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_ETHNICITY_RACE'
 ,p_extra_info_id               =>      p_per_race_ethnic_info.person_extra_info_id
 ,p_l_object_version_number     =>      p_per_race_ethnic_info.object_version_number
 ,p_information3                =>      p_per_race_ethnic_info.p_hispanic
 ,p_information4            	=> 		p_per_race_ethnic_info.p_american_indian
 ,p_information5             	=> 		p_per_race_ethnic_info.p_asian
,p_information6        			=> 		p_per_race_ethnic_info.p_black_afr_american
,p_information7        			=> 		p_per_race_ethnic_info.p_hawaiian_pacific
,p_information8        			=> 		p_per_race_ethnic_info.p_white
  );
--
end if;



--
If p_per_uniformed_services.per_uniformed_services_flag  =  'Y' then
--
  hr_utility.set_location(l_proc,70);

  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_PER_UNIFORMED_SERVICES'
  ,p_extra_info_id              =>      p_per_uniformed_services.person_extra_info_id
  ,p_l_object_version_number    =>      p_per_uniformed_services.object_version_number
--,p_information3                       =>      p_per_uniformed_services.reserve_category
--,p_information4                       =>      p_per_uniformed_services.military_recall_status
  ,p_information5                       =>      p_per_uniformed_services.creditable_military_service
--,p_information6                       =>      p_per_uniformed_services.date_retired_uniform_service
--,p_information7                       =>      p_per_uniformed_services.uniform_service_component
--,p_information8                       =>      p_per_uniformed_services.uniform_service_designation
--,p_information9                       =>      p_per_uniformed_services.retirement_grade
--,p_information10              =>      p_per_uniformed_services.military_retire_waiver_ind
--,p_information11              =>      p_per_uniformed_services.exception_retire_pay_ind
  );
--
end if;
--
If p_pos_valid_grade.pos_valid_grade_flag =  'Y' then
--
  hr_utility.set_location(l_proc,75);
    --Begin Bug 5919705
    FOR p_cur_grd1 in  cur_grd1 LOOP
        l_grade_or_level := p_cur_grd1.grade_or_level;
        l_pay_plan := p_cur_grd1.pay_plan;
    END LOOP;
    --BEGIN Bug# 7499540
    /*IF (p_pa_request_rec.first_noa_code ='890' OR p_pa_request_rec.second_noa_code ='890') AND
        p_pa_request_rec.from_pay_plan ='GM' and p_pa_request_rec.to_pay_plan='GS' AND
        l_pay_plan ='GM' THEN

        l_pay_plan := 'GS';*/
    IF (substr(p_pa_request_rec.first_noa_code,1,2) ='89' OR
        SUBSTR(p_pa_request_rec.second_noa_code,1,2) ='89') AND
        p_pa_request_rec.from_pay_plan = l_pay_plan AND
        p_pa_request_rec.from_pay_plan <> p_pa_request_rec.to_pay_plan AND
        SUBSTR(p_pa_request_rec.from_pay_plan,1,1) = SUBSTR(p_pa_request_rec.to_pay_plan,1,1) AND
        SUBSTR(p_pa_request_rec.from_pay_plan,1,1) IN('W','G','Y') THEN

         l_pay_plan := p_pa_request_rec.to_pay_plan;
     --END Bug# 7499540
        FOR p_cur_grd2 in  cur_grd2 LOOP
            p_pos_valid_grade.target_grade := p_cur_grd2.grade_id;
        END LOOP;
    END IF;
    --End Bug 5919705
  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_POS_VALID_GRADE'
  ,p_extra_info_id              =>      p_pos_valid_grade.position_extra_info_id
  ,p_l_object_version_number    =>      p_pos_valid_grade.object_version_number
  ,p_information3                       =>      p_pos_valid_grade.valid_grade
  ,p_information4                       =>      p_pos_valid_grade.target_grade
  ,p_information5                       =>      p_pos_valid_grade.pay_table_id
  ,p_information6                       =>      p_pos_valid_grade.pay_basis
  ,p_information7                       =>      p_pos_valid_grade.employment_category_group
  );
-- Bug#4699682
IF ghr_pay_calc.g_pay_table_upd_flag THEN
    ghr_mlc_pkg.position_history_update (p_position_id    => P_PA_REQUEST_REC.to_position_id,
                                         p_effective_date => P_PA_REQUEST_REC.effective_date,
                                         p_table_id       => P_PA_REQUEST_REC.from_pay_table_identifier,
                                         p_upd_tableid    => p_pos_valid_grade.pay_table_id);
END IF;

--
end if;
--

If p_Pos_grp1.pos_grp1_flag =  'Y' then
--
  hr_utility.set_location(l_proc,80);
  hr_utility.set_location('bef upd ' || 'PEID' || to_char(p_pos_grp1.position_extra_info_id),1);
  hr_utility.set_location('bef upd ' || 'PEOVN' || to_char(p_pos_grp1.object_version_number),1);

-- JH Include WS/PTH if To Position PM is UE or APUE and to_posn <> from_posn. Bug 773851
-- Bug 2462929 If WS pm in APUE or UE then update WS/PTH.
  hr_utility.set_location('To Posn ID ' || p_pa_request_rec.to_position_id ,81);
  hr_utility.set_location('From Posn ID ' || p_pa_request_rec.from_position_id ,81);

  l_form_field_name := 'TO_POSITION_TITLE';
  FOR pm_rec in get_to_posn_title_pm LOOP
    l_posn_title_pm := pm_rec.process_method_code;
  END Loop;

  l_form_field_name := 'WORK_SCHEDULE';
  FOR pm_rec in get_to_posn_title_pm LOOP
    l_WS_pm := pm_rec.process_method_code;
  END Loop;

  hr_utility.set_location('To Posn PM ' || l_posn_title_pm ,81);
  IF p_pa_request_rec.to_position_id IS NOT NULL AND l_posn_title_pm in ('APUE','UE')
    AND nvl(p_pa_request_rec.to_position_id,hr_api.g_number) <>
    nvl(p_pa_request_rec.from_position_id,hr_api.g_number)
    OR p_pa_request_rec.to_position_id IS NOT NULL AND l_WS_pm in ('APUE','UE')
    OR nvl(p_pa_request_rec.first_noa_code,hr_api.g_number) = '782'
    OR nvl(p_pa_request_rec.second_noa_code,hr_api.g_number) = '782'
 THEN
    hr_utility.set_location('Posn Update With WS/PTH' || l_posn_title_pm ,81);

---------------------------- bug#2623692

if( p_pos_grp1.organization_structure_id is null) then
                FOR OPM_CUR IN c_pei_null_OPM(p_pa_request_rec.from_position_id) LOOP
                        l_Organ_Component              :=OPM_CUR.l_org_structure_id;
                END LOOP;
else
 l_Organ_Component              :=p_pos_grp1.organization_structure_id;
end if;

if (p_pa_request_rec.first_noa_code='790' or p_pa_request_rec.second_noa_code='790') then
--l_personnel_office_id:=p_pa_request_rec.personnel_office_id;
-- bug 3191704
	FOR poi_rec IN cur_rei_poi(p_pa_request_rec.pa_request_id)
	LOOP
	 target_poi := poi_rec.rei_information5;
	END LOOP;
	--
	IF target_poi IS NOT NULL THEN
	  l_personnel_office_id:=target_poi;
	ELSE
	  l_personnel_office_id:=p_pa_request_rec.personnel_office_id;
	END IF;
	-- IF target POI is not null check
else
l_personnel_office_id:=p_pos_grp1.personnel_office_id;
end if;
---------------------------------- bug#2623692

    Generic_Update_Extra_Info
    (p_pa_request_rec               => P_PA_REQUEST_REC
    ,p_l_information_type           => 'GHR_US_POS_GRP1'
    ,p_extra_info_id              => p_pos_grp1.position_extra_info_id
    ,p_l_object_version_number    => p_pos_grp1.object_version_number
    ,p_information3                 => l_personnel_office_id
    ,p_information4                 => p_pos_grp1.office_symbol
    ,p_information5                 => l_Organ_Component
    -- Bug#3816651 Uncommented p_information6.
    ,p_information6                 => p_pos_grp1.occupation_category_code  -- This is actually the occ_series  on the DDf and not occ_code
    ,p_information7                 => p_pos_grp1.flsa_category
    ,p_information8                 => p_pos_grp1.bargaining_unit_status
--Bug #6356058
  --  ,p_information9                 => p_pos_grp1.competitive_level
    ,p_information10              => p_pos_grp1.work_schedule
    ,p_information11              => p_pos_grp1.functional_class
    ,p_information12              => p_pos_grp1.position_working_title
  --,p_information13              => p_pos_grp1.position_sensitivity
  --,p_information14              => p_pos_grp1.security_access
  --,p_information15              => p_pos_grp1.prp_sci
    ,p_information16              => p_pos_grp1.supervisory_status
  --,p_information17              => p_pos_grp1.type_employee_supervised
    ,p_information18              => p_pos_grp1.payroll_office_id
  --,p_information19              => p_pos_grp1.timekeeper
  --,p_information20              => p_pos_grp1.competitive_area
    ,p_information21              => p_pos_grp1.positions_organization
    ,p_information23              => p_pos_grp1.part_time_hours
    );
  ELSE
    -- Standard Update
    hr_utility.set_location('Posn Update Without WS/PTH' || l_posn_title_pm ,81);
    Generic_Update_Extra_Info
    (p_pa_request_rec             => P_PA_REQUEST_REC
    ,p_l_information_type         => 'GHR_US_POS_GRP1'
    ,p_extra_info_id              => p_pos_grp1.position_extra_info_id
    ,p_l_object_version_number    => p_pos_grp1.object_version_number
    ,p_information3                 => p_pos_grp1.personnel_office_id
    ,p_information4                 => p_pos_grp1.office_symbol
    ,p_information5                 => p_pos_grp1.organization_structure_id
    -- Bug#3816651 Uncommented p_information6
    ,p_information6                 => p_pos_grp1.occupation_category_code  -- This is actually the occ_series  on the DDf and not occ_code
    ,p_information7                 => p_pos_grp1.flsa_category
    ,p_information8                 => p_pos_grp1.bargaining_unit_status
--Bug #6356058
  --  ,p_information9                 => p_pos_grp1.competitive_level
  --,p_information10              => p_pos_grp1.work_schedule
    ,p_information11              => p_pos_grp1.functional_class
    ,p_information12              => p_pos_grp1.position_working_title
  --,p_information13              => p_pos_grp1.position_sensitivity
  --,p_information14              => p_pos_grp1.security_access
  --,p_information15              => p_pos_grp1.prp_sci
    ,p_information16              => p_pos_grp1.supervisory_status
  --,p_information17              => p_pos_grp1.type_employee_supervised
    ,p_information18              => p_pos_grp1.payroll_office_id
  --,p_information19              => p_pos_grp1.timekeeper
  --,p_information20              => p_pos_grp1.competitive_area
    ,p_information21              => p_pos_grp1.positions_organization
  --,p_information23              => p_pos_grp1.part_time_hours
    );
  END IF;
--
end if;

If p_pos_grp2.pos_grp2_flag =  'Y' then
--
  hr_utility.set_location('bef upd ' || 'PEID 2 ' || to_char(p_pos_grp2.position_extra_info_id),1);
  hr_utility.set_location('bef upd ' || 'PEOVN 2' || to_char(p_pos_grp2.object_version_number),1);

  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_POS_GRP2'
  ,p_extra_info_id              =>      p_pos_grp2.position_extra_info_id
  ,p_l_object_version_number    =>      p_pos_grp2.object_version_number
  ,p_information3               =>      p_pos_grp2.position_occupied
  ,p_information4               =>      p_pos_grp2.organization_function_code
--,p_information5               =>      p_pos_grp2.date_position_classified
--,p_information6               =>      p_pos_grp2.date_last_position_audit
--,p_information7               =>      p_pos_grp2.classification_official
--,p_information8               =>      p_pos_grp2.language_required
--,p_information9               =>      p_pos_grp2.drug_test
--,p_information10              =>      p_pos_grp2.financial_statement
--,p_information11              =>      p_pos_grp2.training_program_id
--,p_information12              =>      p_pos_grp2.key_emergency_essential
  ,p_information13              =>      p_pos_grp2.appropriation_code1
  ,p_information14              =>      p_pos_grp2.appropriation_code2
--,p_information15              =>      p_pos_grp2.intelligence_position_ind
--,p_information16              =>      p_pos_grp2.leo_position_indicator
);
--
end if;
--
 /* Note :  Since none of this data is currently being updated, why call the generic_update at all ??? */

/*
If p_pos_oblig.pos_oblig_flag =  'Y' then
--
  hr_utility.set_location(l_proc,90);
  Generic_Update_Extra_Info
  (
   p_pa_request_rec             =>      P_PA_REQUEST_REC
  ,p_l_information_type         =>      'GHR_US_POS_OBLIG'
  ,p_extra_info_id              =>      p_pos_oblig.position_extra_info_id
  ,p_l_object_version_number    =>      p_pos_oblig.object_version_number
  ,p_information3               =>      p_pos_oblig.expiration_date
  ,p_information4               =>      p_pos_oblig.obligation_type
  ,p_information5               =>      p_pos_oblig.employee_ssn
  );
--
end if;
*/
--

 /* Note :  Since none of this data is currently being updated, why call the generic_update at all ??? */

/*
If p_pos_car_prog.pos_car_prog_flag =  'Y' then
--
hr_utility.set_location(l_proc,95);
Generic_Update_Extra_Info(
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_POS_CAR_PROG'
 ,p_extra_info_id               =>      p_pos_car_prog.position_extra_info_id
 ,p_l_object_version_number     =>      p_pos_car_prog.object_version_number
 ,p_information3                =>      p_pos_car_prog.career_program_id
 ,p_information4                =>      p_pos_car_prog.career_program_type
 ,p_information5                =>      p_pos_car_prog.change_reasons
 ,p_information6                =>      p_pos_car_prog.career_field_id
 ,p_information7                =>      p_pos_car_prog.career_program_code
 ,p_information8                =>      p_pos_car_prog.acteds_key_position);
--
end if;
*/

hr_utility.set_location(l_proc,100);


-- Bug # 6312144 changes related to benefits continuation
If p_ipa_benefits_cont.per_ben_cont_info_flag =  'Y' then
   hr_utility.set_location(l_proc,65);

 Generic_Update_Extra_Info
 (
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_BENEFITS_CONT'
 ,p_extra_info_id               =>      p_ipa_benefits_cont.person_extra_info_id
 ,p_l_object_version_number     =>      p_ipa_benefits_cont.object_version_number
 ,p_information1                =>      p_ipa_benefits_cont.FEGLI_Indicator
 ,p_information2                =>      p_ipa_benefits_cont.FEGLI_Election_Date
 ,p_information3                =>      p_ipa_benefits_cont.FEGLI_Elec_Not_Date
 ,p_information4                =>      p_ipa_benefits_cont.FEHB_Indicator
 ,p_information5                =>      p_ipa_benefits_cont.FEHB_Election_Date
 ,p_information6                =>      p_ipa_benefits_cont.FEHB_Elec_Notf_Date
 ,p_information7                =>      p_ipa_benefits_cont.Retirement_Indicator
 ,p_information12               =>      p_ipa_benefits_cont.Retirement_Elec_Date
 ,p_information8                =>      p_ipa_benefits_cont.Retirement_Elec_Notf_Date
 ,p_information9                =>      p_ipa_benefits_cont.Cont_Term_Insuff_Pay_Elec_Date
 ,p_information10               =>      p_ipa_benefits_cont.Cont_Term_Insuff_Pay_Notf_Date
 ,p_information11               =>      p_ipa_benefits_cont.Cont_Term_Insuff_Pmt_Type_Code);

End IF;

-- Bug # 6312144 changes related to retirement system information
If p_retirement_info.per_retirement_info_flag =  'Y' then
   hr_utility.set_location(l_proc,65);

 Generic_Update_Extra_Info
 (
  p_pa_request_rec              =>      P_PA_REQUEST_REC
 ,p_l_information_type          =>      'GHR_US_PER_RETIRMENT_SYS_INFO'
 ,p_extra_info_id               =>      p_retirement_info.person_extra_info_id
 ,p_l_object_version_number     =>      p_retirement_info.object_version_number
 ,p_information1                =>      p_retirement_info.special_population_code
 ,p_information2                =>      p_retirement_info.App_Exc_CSRS_Ind
 ,p_information3                =>      p_retirement_info.App_Exc_FERS_Ind
 ,p_information4                =>      p_retirement_info.FICA_Coverage_Ind1
 ,p_information5                =>      p_retirement_info.FICA_Coverage_Ind2);

End IF;
--

-- Call special info type api to update education details

If p_pa_request_rec.education_level      is not null or
   p_pa_request_rec.academic_discipline  is not null or
   p_pa_request_rec.year_degree_attained is not null then

  hr_utility.set_location(l_proc,102);
  update_edu_sit(p_pa_request_rec     => p_pa_request_rec);

End if;

--
-- Call special info type api to update performance_appraisal details
--
If p_perf_appraisal.perf_appr_flag = 'Y' then

  hr_utility.set_location(l_proc,104);
  l_segment_rec.segment1              :=  p_perf_appraisal.appraisal_type;
  l_segment_rec.segment2              :=  p_perf_appraisal.rating_rec;
  l_segment_rec.segment3              :=  p_perf_appraisal.date_effective;
  l_segment_rec.segment4              :=  p_perf_appraisal.rating_rec_pattern;
  l_segment_rec.segment5              :=  p_perf_appraisal.rating_rec_level;
  l_segment_rec.segment6              :=  p_perf_appraisal.date_appr_ends;
    --Bug# 4753117 28-Feb-07	Veeramani  assigning appraisal start date
  l_segment_rec.segment17             :=  p_perf_appraisal.date_appr_starts;
  l_segment_rec.segment7              :=  p_perf_appraisal.unit;
  l_segment_rec.segment8              :=  p_perf_appraisal.org_structure_id;
  l_segment_rec.segment9              :=  p_perf_appraisal.office_symbol;
  l_segment_rec.segment10             :=  p_perf_appraisal.pay_plan;
  l_segment_rec.segment11             :=  p_perf_appraisal.grade;
  l_segment_rec.segment12             :=  p_perf_appraisal.date_due;
  l_segment_rec.segment13             :=  p_perf_appraisal.appraisal_system_identifier;
  l_segment_rec.segment14             :=  p_perf_appraisal.date_init_appr_due;
  l_segment_rec.segment15             :=  p_perf_appraisal.optional_information;
  l_segment_rec.person_analysis_id    :=  p_perf_appraisal.person_analysis_id;
  l_segment_rec.object_version_number :=  p_perf_appraisal.object_version_number;
  l_segment_rec.segment16             :=  p_perf_appraisal.performance_rating_points;

  hr_utility.set_location(l_proc||'  l_segment_rec.segment16       '||  l_segment_rec.segment16,101);

  generic_update_sit
  (p_segment_rec              =>  l_segment_rec,
   p_special_information_type =>  'US Fed Perf Appraisal',
   p_pa_request_rec           =>  p_pa_request_rec
   );

End if;

-- Call special info type api to update conduct_performance details

If p_conduct_performance.cond_perf_flag = 'Y' then

  l_segment_rec.segment1              :=  p_conduct_performance.cause_of_disc_action;
  l_segment_rec.segment2              :=  p_conduct_performance.date_of_adverse_action;
  l_segment_rec.segment3              :=  p_conduct_performance.days_suspended;
  l_segment_rec.segment4              :=  p_conduct_performance.date_suspension_over_30;
  l_segment_rec.segment5              :=  p_conduct_performance.date_suspension_under_30;
  l_segment_rec.segment6              :=  p_conduct_performance.pip_action_taken;
  l_segment_rec.segment7              :=  p_conduct_performance.pip_begin_date;
  l_segment_rec.segment8              :=  p_conduct_performance.pip_end_date;
  l_segment_rec.segment9              :=  p_conduct_performance.pip_extensions;
  l_segment_rec.segment10             :=  p_conduct_performance.pip_length;
  l_segment_rec.segment11             :=  p_conduct_performance.date_reprimand_expires;
  l_segment_rec.segment12             :=  p_conduct_performance.adverse_action_noac;
  l_segment_rec.person_analysis_id    :=  p_conduct_performance.person_analysis_id;
  l_segment_rec.object_version_number :=  p_conduct_performance.object_version_number;

  generic_update_sit
 (p_pa_request_rec               => p_pa_request_rec,
  p_special_information_type     => 'US Fed Conduct Perf',
  p_segment_rec                  => l_segment_rec
  );
End if;
--
--
  update_retained_grade
  (p_pa_request_rec           => p_pa_request_rec,
   p_per_retained_grade       => p_per_retained_grade );
--
--
hr_utility.set_location('Leaving  ' || l_proc,110);
Exception when others then
 --
 -- Reset IN OUT parameters and set OUT parameters
 --
 P_Asg_Sf52                         := l_Asg_Sf52;
 P_Asg_non_Sf52                     := l_Asg_non_Sf52;
 P_Asg_nte_dates                    := l_Asg_nte_dates;
 P_Per_Sf52                         := l_Per_Sf52;
 P_Per_Group1                       := l_Per_Group1;
 P_Per_Group2                       := l_Per_Group2;
 P_Per_scd_info                     := l_Per_scd_info;
 P_Per_retained_grade               := l_Per_retained_grade;
 P_Per_probations                   := l_Per_probations;
 P_Per_sep_retire                   := l_Per_sep_retire;
 P_Per_security                     := l_Per_security;
 --Bug#4486823
 P_per_service_oblig                := l_per_service_oblig;
 P_Per_conversions                  := l_Per_conversions;
 P_Per_uniformed_services           := l_Per_uniformed_services;
 P_Pos_oblig                        := l_Pos_oblig;
 P_Pos_Grp2                         := l_Pos_Grp2;
 P_Pos_Grp1                         := l_Pos_Grp1;
 P_Pos_valid_grade                  := l_Pos_valid_grade;
 P_Pos_car_prog                     := l_Pos_car_prog;
 P_Perf_appraisal                   := l_Perf_appraisal;
 P_conduct_performance              := l_conduct_performance;
 P_Loc_Info                         := l_Loc_Info;
 P_generic_Extra_Info_Rec           := l_generic_Extra_Info_Rec;
 P_par_term_retained_grade          := l_par_term_retained_grade;
 p_per_race_ethnic_info				:= l_per_race_ethnic_info; -- Race or National Origin changes
 raise;

end call_extra_info_api;



--  ********************************
--  Function get_asg_status_type
--  ********************************
--- Bug# 4672772 added Parameter p_assignment_id
 Procedure get_asg_status_type
 (p_noa_code           in  ghr_nature_of_actions.code%type,
  p_business_group_id  in  per_people_f.business_group_id%type,
  p_assignment_id	in  number,
  p_pa_request_id	in ghr_pa_requests.pa_request_id%type, --Bug# 8724192
  p_status_type_id     out nocopy per_assignment_status_types.assignment_status_type_id%type,
  p_activate_flag      out nocopy varchar2,
  p_suspend_flag       out nocopy varchar2,
  p_terminate_flag     out nocopy varchar2
 )
 is

 l_proc                varchar2(70) := 'get_asg_status_type';
 l_system_status       per_assignment_status_types.per_system_status%type;
 l_user_status         per_assignment_status_types.user_status%type;
 l_asg_status_type_id  number;
 l_active_flag         varchar2(1) := 'N';


 cursor    c_asg_status_type is
   select  ast.assignment_status_type_id,
           ast.active_flag
   from    per_assignment_status_types ast
   where   ast.per_system_status                      =    l_system_status
   and     ast.user_status                            like '%' || l_user_status || '%'
   and     nvl(ast.business_group_id,hr_api.g_number) =  hr_api.g_number
   and     ast.legislation_code                       =  'US';

 cursor    c_asg_status_type_471 is
   select  ast.assignment_status_type_id,
           ast.active_flag
   from    per_assignment_status_types ast
   where   ast.per_system_status                      =    l_system_status
   and     ast.user_status                            like '%' || l_user_status || '%'
   and     instr(ast.user_status,'NTE')               = 0
   and     nvl(ast.business_group_id,hr_api.g_number) =  hr_api.g_number
   and     ast.legislation_code                       =  'US';
-- Bug# 4672772 Begin
	l_user_apnt_status			per_assignment_status_types.user_status%type;
	l_user_apnt_eff_date		date;
	CURSOR	c_user_apnt_status IS
	select 	ast.user_status,asg.effective_start_date
	from	per_assignment_status_types ast,
			per_all_assignments_f asg
	where	ast.assignment_status_type_id = asg.assignment_status_type_id
	and		asg.assignment_id = p_assignment_id
	and 	asg.primary_flag = 'Y'
	order by asg.effective_start_date;

-- Bug# 4672772 End
--Begin Bug# 6083404
    l_user_actv_apnt_status			per_assignment_status_types.user_status%type;
    CURSOR c_user_actv_appt IS
    select 	ast.user_status
    from	per_assignment_status_types ast,
            per_all_assignments_f asg
    where	ast.assignment_status_type_id = asg.assignment_status_type_id
    and		asg.assignment_id = p_assignment_id
    and 	asg.primary_flag = 'Y'
    and user_status='Active Appointment';
--end Bug# 6083404
--Begin Bug# 8724192
  l_appointment_type  varchar2(10);
CURSOR cur_get_app_type IS
    SELECT rei_information4 appointment_type
    FROM ghr_pa_request_extra_info
    WHERE rei_information_category='GHR_US_PAR_APPT_TRANSFER'
    AND   pa_request_id =  p_pa_request_id;
--End Bug# 8724192

-- to include , the dates and active_flag in the where clause -- ??

-- The follwing code , decides the User status and the System Status for
--  the person's assignment depending on the NOA, and then identifies the
--  Assignment_status_type_id associated with it. Also it passes the
-- respective flag parameters to indicate whether the assignment has to be
-- activated, terminated or suspended

 begin
   If p_noa_code is not null then
	if p_noa_code in
		('100','101','107','120','124','130','132','140','141','142','143','145','146','147','150','151','155',
		'156','157','170','198','199','280','292','293','500','501','507','520','524','540','541','542','543',
		'546','550','551','555','570','702','713') then

		IF ( p_noa_code in ('702','713') AND g_old_user_status = 'Term Limited Appt' ) THEN
			--Bug# 4602352 Modified Temp. Appointment NTE to Term Limited Appt
			l_system_status :=  'ACTIVE_ASSIGN'; -- 'ACTIVE'
			l_user_status    := g_old_user_status;
			p_activate_flag :=  'Y';
			--Fix for 3698464
			-- Begin Bug# 4672772
		ELSIF ( p_noa_code in ('702','713') AND g_old_user_status = 'Temp. Promotion NTE' ) THEN
			FOR user_apnt_status_rec IN c_user_apnt_status
			LOOP
				l_user_apnt_status := user_apnt_status_rec.user_status;
				l_user_apnt_eff_date := user_apnt_status_rec.effective_start_date;
				EXIT;
			END LOOP;
			--Begin Bug#6083404
			FOR user_actv_appt_rec IN c_user_actv_appt
			LOOP
				l_user_actv_apnt_status := user_actv_appt_rec.user_status;
			EXIT;
			END LOOP;
			--End Bug# 6083404
			IF l_user_apnt_status = 'Temp. Appointment NTE'
				and nvl(l_user_actv_apnt_status,'XXX') <>'Active Appointment' THEN
				--Bug# 6083404 added l_user_actv_apnt_status condition
				l_system_status :=  'ACTIVE_ASSIGN'; -- 'ACTIVE'
				l_user_status   :=  l_user_apnt_status;
				p_activate_flag :=  'Y';
			ELSE
				l_system_status :=  'ACTIVE_ASSIGN'; -- 'ACTIVE'
				l_user_status   :=  'Active Appointment'; -- Active Appointment'
				p_activate_flag :=  'Y';
			END IF;
			-- End Bug# 4672772
		--Begin Bug# 8724192
		ELSIF p_noa_code in ('132') THEN
			FOR l_cur_get_app_type IN cur_get_app_type LOOP
				l_appointment_type := l_cur_get_app_type.appointment_type;
			END LOOP;
			hr_utility.set_location('Appointment Type ' || l_appointment_type,11);
			IF l_appointment_type IN ('20','40','41','42','43','44','45','46','47','48') THEN
				l_system_status  := 'ACTIVE_ASSIGN';
				l_user_status    := 'Temp. Appointment NTE';
				p_activate_flag :=  'Y';
			ELSIF l_appointment_type IN ('60','61','62','63','64','65') THEN
				l_system_status  := 'ACTIVE_ASSIGN';
				l_user_status    := 'Term Limited Appt';
				p_activate_flag :=  'Y';
			ELSE
				l_system_status :=  'ACTIVE_ASSIGN';
				l_user_status   :=  'Active Appointment';
				p_activate_flag :=  'Y';
			END IF;
		--End Bug# 8724192

		ELSE -- 3698464 Madhuri
			l_system_status :=  'ACTIVE_ASSIGN'; -- 'ACTIVE'
			l_user_status   :=  'Active Appointment'; -- Active Appointment'
			p_activate_flag :=  'Y';
		END IF;

      elsif p_noa_code = '471' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Furlough';
        p_suspend_flag   :=  'Y';
      elsif p_noa_code = '472' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Furlough NTE';
        p_suspend_flag :=  'Y';
      elsif p_noa_code = '462' then
        l_system_status  := 'ACTIVE_ASSIGN';
        l_user_status    := 'Leave With Pay NTE';
        p_activate_flag :=  'Y';
      elsif p_noa_code = '460' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Leave Without Pay NTE';
        p_suspend_flag :=  'Y';
      elsif p_noa_code = '473' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Leave Without Pay US'; --instead of Mil
        p_suspend_flag :=  'Y';
      elsif p_noa_code = '430' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Non Pay';
        p_suspend_flag :=  'Y';
      elsif p_noa_code = '480' then
        l_system_status  := 'ACTIVE_ASSIGN';
        l_user_status    := 'Sabbatical NTE';
        p_activate_flag :=  'Y';
      elsif p_noa_code in
        ('300','301','302','303','304','312','317','330','350','356','390') then
        l_system_status  := 'TERM_ASSIGN';
        l_user_status    := 'Separated';
        p_terminate_flag :=  'Y';
      elsif p_noa_code = '450' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Suspension NTE';
        p_suspend_flag :=  'Y';
      elsif p_noa_code = '452' then
        l_system_status  := 'SUSP_ASSIGN';
        l_user_status    := 'Suspension Indefinite';
        p_suspend_flag :=  'Y';
      elsif p_noa_code in --Bug# 4602352 Removed 108,508
        ('112','115','117','122','148','149','153','154','171','190',
         '512','515','517','522','548','549','553','554','571','590','750') then
        l_system_status  := 'ACTIVE_ASSIGN';
        l_user_status    := 'Temp. Appointment NTE';
        p_activate_flag :=  'Y';
      --Begin Bug# 4602352
      elsif p_noa_code in ('108','508') then
        l_system_status  := 'ACTIVE_ASSIGN';
        l_user_status    := 'Term Limited Appt';
        p_activate_flag :=  'Y';
      --End Bug# 4602352
      elsif p_noa_code = '703' then
        --Begin Bug# 4602352
        IF (g_old_user_status = 'Term Limited Appt' ) THEN
                l_system_status  := 'ACTIVE_ASSIGN';
                l_user_status    := 'Term Limited Appt';
                p_activate_flag :=  'Y';
        ELSE --End Bug# 4602352
            l_system_status  := 'ACTIVE_ASSIGN';
            l_user_status    := 'Temp. Promotion NTE';
            p_activate_flag :=  'Y';
        END IF;--Bug# 4602352
      elsif p_noa_code in ('351','352','353','355','357','385') then
        l_system_status  := 'TERM_ASSIGN';  -- TERM_???????
        l_user_status    := 'Terminate Appointment'; -- 'Termination Appointment'
        p_terminate_flag :=  'Y';
        -- Start Bug 3048114
      elsif p_noa_code in ('740') THEN
        IF g_old_user_status = 'Temp. Promotion NTE' THEN
	        l_system_status :=  'ACTIVE_ASSIGN'; -- 'ACTIVE'
		    l_user_status   :=  'Active Appointment'; -- Active Appointment'
	        p_activate_flag :=  'Y';
            -- End Bug 3048114
	    ELSIF g_old_user_status = 'Term Limited Appt'  THEN --Bug# 4602352
            l_system_status :=  'ACTIVE_ASSIGN'; -- 'ACTIVE'
            l_user_status    := g_old_user_status;
            p_activate_flag :=  'Y';
	    END IF; --Fix for 3698464
      elsif p_noa_code = '721' then           -- for Temp Appointmt NTE, bug# 3215526
        l_system_status  := 'ACTIVE_ASSIGN';  -- 'ACTIVE'
        l_user_status    := g_old_user_status;
        p_activate_flag :=  'Y';
      end if;
    end if;
    If l_system_status is not null and
      l_user_status   is not null then
       hr_utility.set_location('user_status ' || l_user_status,1);
       hr_utility.set_location('System status  ' || l_system_status,2);
      If p_noa_code = '471' then
      ----------- changed cursor name from c_Asg_status_type to c_Asg_status_type_471 for bug#2139010
        for asg_status_type_471 in c_asg_status_type_471 loop
          l_asg_status_type_id  :=  asg_status_type_471.assignment_status_type_id;
          l_active_flag         :=  asg_status_type_471.active_flag;
        end loop;
      Else
        for asg_status_type in c_asg_status_type loop
          l_asg_status_type_id  :=  asg_status_type.assignment_status_type_id;
          l_active_flag         :=  asg_status_type.active_flag;
        end loop;
      End if;
      If l_asg_status_type_id is null then
        hr_utility.set_message(8301,'GHR_38180_STATUS_TYPE_UNDEF');
        hr_utility.raise_error;
      End if;
      If l_active_flag   = 'N' then
        hr_utility.set_message(8301,'GHR_38181_STATUS_TYPE_INACTIVE');
        hr_utility.raise_error;
      End if;
    End if;
    p_status_type_id := l_asg_status_type_id;
 Exception when others then
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_status_type_id     := null;
    p_activate_flag      := null;
    p_suspend_flag       := null;
    p_terminate_flag     := null;
    raise;

 End get_asg_status_type;


------------------------------------------------------------------------------------------
-------------------------------- < return_update_mode > ----------------------------------
------------------------------------------------------------------------------------------

--This function returns the update_mode to be used while calling the apis, depending on
-- the effective_date the SF52 is processed.


  Function return_update_mode
  (p_id              in     per_people_f.person_id%type,
   p_effective_date  in     date,
   p_table_name      in     varchar2
  ) return varchar2 is

  l_proc     varchar2(72) := 'return_update_mode';
  l_eed      date;
  l_esd      date;
  l_mode     varchar2(20) := 'CORRECTION';
  l_exists  boolean := FALSE;


  cursor     c_update_mode_p is
    select   per.effective_start_date ,
             per.effective_end_date
    from     per_all_people_f per
    where    per.person_id = p_id
    and      p_effective_date
    between  per.effective_start_date
    and      per.effective_end_date;

  cursor     c_update_mode_p1 is
    select   per.effective_start_date ,
             per.effective_end_date
    from     per_all_people_f per
    where    per.person_id = p_id
    and      p_effective_date  <  per.effective_start_date;


   cursor     c_update_mode_a is
    select   asg.effective_start_date ,
             asg.effective_end_date
    from     per_all_assignments_f asg
    where    asg.assignment_id = p_id
    and      p_effective_date
    between  asg.effective_start_date
    and      asg.effective_end_date;

   cursor     c_update_mode_a1 is
    select   asg.effective_start_date ,
             asg.effective_end_date
    from     per_all_assignments_f asg
    where    asg.assignment_id = p_id
    and      p_effective_date  <  asg.effective_start_date;



  cursor     c_update_mode_pos is
    select   pos.effective_start_date ,
             pos.effective_end_date
    from     hr_all_positions_f pos
    where    pos.position_id = p_id
    and      p_effective_date
    between  pos.effective_start_date
    and      pos.effective_end_date;

  cursor     c_update_mode_pos1 is
    select   pos.effective_start_date ,
             pos.effective_end_date
    from     hr_all_positions_f pos
    where    pos.position_id = p_id
    and      p_effective_date  <  pos.effective_start_date;


  Begin
    hr_utility.set_location('Entering  ' || l_proc,5);
    If p_table_name = 'PER_PEOPLE_F' then --per
      hr_utility.set_location(l_proc,10);
      for update_mode in c_update_mode_p loop
        hr_utility.set_location(l_proc,15);
        l_esd := update_mode.effective_start_date;
        l_eed := update_mode.effective_end_date;
      end loop;
      hr_utility.set_location(l_proc,20);
      If l_esd = p_effective_date then
        hr_utility.set_location(l_proc,25);
        l_mode := 'CORRECTION';
      Elsif l_esd < p_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
        hr_utility.set_location(l_proc,30);
        l_mode := 'UPDATE';
      -- end if;
      Elsif  l_esd <  p_effective_date  then
        hr_utility.set_location(l_proc,35);
        for update_mode1 in c_update_mode_p1 loop
          hr_utility.set_location(l_proc,40);
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          hr_utility.set_location(l_proc,45);
          l_mode := 'UPDATE_CHANGE_INSERT';
        Else
          hr_utility.set_location(l_proc,50);
          l_mode := 'CORRECTION';
        End if;
      End if;
        If l_mode is null then
          hr_utility.set_message(8301,'GHR_GET_DATE_TRACK_FAILED');
          hr_utility.set_message_token('TABLE_NAME','per_people_f');
          hr_utility.raise_error;
        End if;
        hr_utility.set_location(l_proc,55);
    Elsif p_table_name = 'PER_ASSIGNMENTS_F' then
      hr_utility.set_location(l_proc,60);
      for update_mode in c_update_mode_a loop
        hr_utility.set_location(l_proc,65);
        l_esd := update_mode.effective_start_date;
        l_eed := update_mode.effective_end_date;
      end loop;
      If l_esd = p_effective_date then
        hr_utility.set_location(l_proc,70);
        l_mode := 'CORRECTION';
      Elsif l_esd < p_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
        hr_utility.set_location(l_proc,75);
        l_mode := 'UPDATE';                           --  to end date a row and then create a new row
      Elsif  l_esd <  p_effective_date  then
        hr_utility.set_location(l_proc,80);
        for update_mode1 in c_update_mode_a1 loop
          hr_utility.set_location(l_proc,85);
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          hr_utility.set_location(l_proc,90);
          l_mode := 'UPDATE_CHANGE_INSERT';              -- to insert a row between 2 existing rows
        Else
          hr_utility.set_location(l_proc,95);
          l_mode := 'CORRECTION';
        End if;
        hr_utility.set_location(l_proc,100);
      End if;
      hr_utility.set_location(l_proc,105);
      hr_utility.set_location('UPDATE_MODE  :   ' || l_mode,2);
      If l_mode is null then
        hr_utility.set_message(8301,'GHR_GET_DATE_TRACK_FAILED');
        hr_utility.set_message_token('TABLE_NAME','per_assignments_f');
        hr_utility.raise_error;
      End if;
    Elsif p_table_name = 'HR_ALL_POSITIONS_F' then
      hr_utility.set_location(l_proc,110);
      for update_mode in c_update_mode_pos loop
        hr_utility.set_location(l_proc,115);
        l_esd := update_mode.effective_start_date;
        l_eed := update_mode.effective_end_date;
      end loop;
      If l_esd = p_effective_date then
        hr_utility.set_location(l_proc,120);
        l_mode := 'CORRECTION';
      Elsif l_esd < p_effective_date and
            to_char(l_eed,'YYYY/MM/DD') = '4712/12/31' then
        hr_utility.set_location(l_proc,125);
        l_mode := 'UPDATE';                           --  to end date a row and then create a new row
      Elsif  l_esd <  p_effective_date  then
        hr_utility.set_location(l_proc,130);
        for update_mode1 in c_update_mode_pos1 loop
          hr_utility.set_location(l_proc,135);
          l_exists := true;
          exit;
        end loop;
        If l_exists then
          hr_utility.set_location(l_proc,140);
          l_mode := 'UPDATE_CHANGE_INSERT';              -- to insert a row between 2 existing rows
        Else
          hr_utility.set_location(l_proc,145);
          l_mode := 'CORRECTION';
        End if;
        hr_utility.set_location(l_proc,150);
      End if;
      hr_utility.set_location(l_proc,155);
      hr_utility.set_location('UPDATE_MODE  :   ' || l_mode,2);
      If l_mode is null then
        hr_utility.set_message(8301,'GHR_GET_DATE_TRACK_FAILED');
        hr_utility.set_message_token('TABLE_NAME','HR_ALL_POSITIONS_F');
        hr_utility.raise_error;
      End if;
    End if;
    return l_mode;
    hr_utility.set_location('Leaving ' ||l_proc,160);
End return_update_mode;




--  ***********************
--  procedure Process_Family
--  ***********************
--
procedure  Process_Family
(P_PA_REQUEST_REC             IN OUT NOCOPY  GHR_PA_REQUESTS%ROWTYPE,
 P_AGENCY_CODE                IN      varchar2 )   is

l_noa_code                     ghr_nature_of_actions.code%type;
--
l_pa_request_rec               ghr_pa_requests%rowtype;
l_proc                         varchar2(70)   := 'Process_family';
l_hr_person_api_update         varchar2(1)    := 'N';
l_hr_applicant_api_hire        varchar2(1)    := 'N';
l_employee_api_update_criteria varchar2(1)    := 'N';
l_hr_employee_api_hire_ex      varchar2(1)    := 'N';
l_hr_applicant_api_create_sec  varchar2(1)    := 'N';
l_hire_employee                varchar2(1)    := 'N';
l_create_address                 varchar2(1)    := 'N';
l_update_address               varchar2(1)    := 'N';
l_update_person                varchar2(1)    := 'N';
l_secondary_asg                varchar2(1)    := 'N';
l_address_line1                          per_addresses.address_line1%type;
l_address_line2                          per_addresses.address_line2%type;
l_address_line3                  per_addresses.address_line3%type;
l_town_or_city                    per_addresses.town_or_city%type;
l_region_2                        per_addresses.region_2%type;
l_city                           per_addresses.town_or_city%type;
l_state                                  per_addresses.region_2%type;
l_postal_code                    per_addresses.postal_code%type;
l_country                                per_addresses.country%type;
l_noa_family_name                      varchar2(60);
l_noa_family_code              ghr_noa_families.noa_family_code%type;
--
-- hr_person_api.update_person out variables
--
l_per_upd_employee_number        per_people_f.employee_number%type;
l_per_upd_effective_start_date   per_people_f.effective_start_date%type;
l_per_upd_effective_end_date     per_people_f.effective_end_date%type;
l_per_upd_full_name              per_people_f.full_name%type;
l_per_upd_comment_id             per_people_f.comment_id%type;
l_per_upd_name_comb_warn         boolean;
l_per_upd_assgn_payroll_warn     boolean;
l_per_person_type_id             per_people_f.person_type_id%type;
l_per_national_identifier        per_people_f.national_identifier%type;
l_per_first_name                 per_people_f.first_name%type;
l_per_last_name                  per_people_f.last_name%type;
l_per_middle_names               per_people_f.middle_names%type;
l_per_date_of_birth              per_people_f.date_of_birth%type;

--
l_concatenated_segments          hr_soft_coding_keyflex.concatenated_segments%type;
l_asg_upd_effective_start_date   per_assignments_f.effective_start_date%type;
l_asg_upd_effective_end_date     per_assignments_f.effective_end_date%type;
l_asg_upd_special_ceil_step_id   per_assignments_f.special_ceiling_step_id%type;
l_asg_upd_people_group_id        per_assignments_f.people_group_id%type;
l_asg_upd_group_name             pay_people_groups.group_name%type;
l_asg_upd_org_now_man_warn         boolean;
l_asg_upd_other_manager_warn       boolean ;
l_asg_upd_spp_delete_warning     boolean;
l_asg_upd_entries_chan_warn      varchar2(10);
l_asg_upd_tax_dist_chan_warn     boolean;
--
-- Hire applicant out variables

--
 l_per_hire_employee_number        per_people_f.employee_number%type;
 l_per_hire_eff_start_date         per_people_f.effective_start_date%type;
 l_per_hire_eff_end_date           per_people_f.effective_end_date%type;
 l_per_hire_un_asg_del_warn        boolean;
 l_per_hire_asg_pay_warn           boolean;
 l_per_hire_oversubs_vac_id  number;
--

-- Return to duty (active) out variables
--
l_asg_act_eff_start_date          per_assignments_f.effective_start_date%type;
l_asg_act_eff_end_date            per_assignments_f.effective_end_date%type;
--
--Suspend employee out variables
--
l_asg_sus_eff_start_date          per_assignments_f.effective_start_date%type;
l_asg_sus_eff_end_date            per_assignments_f.effective_end_date%type;--

-- Create addresses out variables
--
l_per_add_address_id              per_addresses.address_id%type;
l_per_add_ovr_number              per_addresses.object_version_number%type;
--

-- Final Process out variables
--
l_asg_fnl_eff_start_date          per_assignments_f.effective_start_date%type;
l_asg_fnl_eff_end_date            per_assignments_f.effective_end_date%type;
l_asg_fnl_org_now_no_manager      boolean;
l_asg_fnl_future_chan_warn        boolean;
l_asg_fnl_entries_chan_warn       varchar2(1);
--
--
l_per_object_version_number       per_people_f.object_version_number%type;
l_asg_object_version_number     per_assignments_f.object_version_number%type;
l_add_object_version_number       per_addresses.object_version_number%type;
l_person_id                             per_people_f.person_id%type;
l_person_type_id                per_people_f.person_type_id%type;
l_date1                         ghr_pa_requests.effective_date%type;
l_address_id                      per_addresses.address_id%type;
l_person_type                     per_person_types.system_person_type%type;
--l_sec_assignmemt_id             per_assignments_f.assignment_id%type;
--l_assignment_status_type_id   per_assignment_status_types.assignment_status_type_id%type;
--
l_asg_trm_eff_start_date          per_assignments_f.effective_start_date%type;
l_asg_trm_eff_end_date            per_assignments_f.effective_end_date%type;
l_emp_trm_eff_end_date          per_assignments_f.effective_end_date%type;
l_asg_future_changes_warning    boolean;
l_supervisor_warning            boolean;
l_event_warning                 boolean;
l_interview_warning             boolean;
l_review_warning                boolean;
l_recruiter_warning             boolean;
l_entries_changed_warning       varchar2(1);
l_dod_warning                   boolean;
l_pay_proposal_warning          boolean;
l_org_now_no_manager_warning    boolean;
--asg_future_changes_warning    boolean;
--l_entries_changed_warning     boolean;
l_pds_object_version_number     number;

l_assignment_id                 per_assignments_f.assignment_id%type;
l_asg_status_type_id            number(9);
l_update_mode                   varchar2(30) := 'UPDATE';
l_activate_flag                 varchar2(1)  := 'N';
l_suspend_flag                  varchar2(1)  := 'N';
l_terminate_flag                varchar2(1)  := 'N';
l_employee_update_flag          varchar2(1)  := 'N';
l_update_gre                    varchar2(1)  := 'N';
l_rehire_ex_emp                 varchar2(1 ) := 'N';
l_period_of_service_id          number;
l_payroll_id                    pay_payrolls_f.payroll_id%type;
l_payroll_name                  pay_payrolls_f.payroll_name%type;
l_business_group_id             per_people_f.business_group_id%type;
l_orig_hire_warning             boolean;

l_working_hours                 per_assignments_f.normal_hours%type;

l_SOFT_CODING_KEYFLEX_ID        NUMBER;
l_COMMENT_ID                    NUMBER;
l_EFFECTIVE_START_DATE          DATE  ;
l_EFFECTIVE_END_DATE            DATE  ;
l_CONCATENNATED_SEGMENTS        VARCHAR2(150) ;
l_NO_MANAGERS_WARNING           BOOLEAN  ;
l_OTHER_MANAGER_WARNING         BOOLEAN  ;
l_tax_unit_id                   number;

l_del_ovn                       number(9);
l_asg_id                        number(15);
l_v_start_date                  date;
l_v_end_date                    date;
l_county_name                   per_addresses.region_1%type;
l_count_rec                     number;

l_session                       ghr_history_api.g_session_var_type;

-- POSITION ABOLISH out parameters
l_val_grd_chg_wng               boolean;
l_pos_definition_id             number;
l_name                          varchar2(240);
l_pos_object_version_number     per_addresses.object_version_number%type;


l_asg_payroll_id                number;
-- added for ds change
l_asg_location_id               number;
l_temp_asg_loc_id               number;
l_dum_char                      varchar2(240);
l_dum_number                    number;
l_position_data_rec_type        ghr_sf52_pos_update.position_data_rec_type;
-- Variables used for Update GRE
l_from_org_id                   hr_organization_units.organization_id%type;
l_to_org_id                     hr_organization_units.organization_id%type;
l_result_code                   varchar2(100);
l_address_data                  per_addresses%rowtype;
l_hr_user_type                  varchar2(20);

l_old_system_status             per_assignment_status_types.per_system_status%type;

l_remark_id                     ghr_remarks.remark_id%type;
l_remark_description            ghr_remarks.description%type;
l_pa_remark_id                  ghr_pa_remarks.pa_remark_id%type;
l_rem_ovn                       ghr_pa_remarks.OBJECT_VERSION_NUMBER%type;
l_form_field_name               varchar2(50);
l_posn_title_pm                 varchar2(50);
l_WS_pm                         varchar2(50);
l_DS_pm                         varchar2(50);
l_old_effective_start_date      date;

-- Cursors declaration
--
-- Family Code

 Cursor c_noa_family_code IS
   Select fam.noa_family_code
   from   ghr_noa_families    nfa,
   ghr_families               fam
   where  nfa.nature_of_action_id  = p_pa_request_rec.first_noa_id
   and    nfa.noa_family_code      = fam.noa_family_code
   and    fam.update_hr_flag       = 'Y';

-- Business group of the person

 Cursor  c_bus_gp is
   select per.business_group_id
   from   per_all_people_f per
  where   per.person_id = p_pa_request_rec.person_id
  and     g_effective_date between
          per.effective_start_date
  and     per.effective_end_date;

-- Period of service

 Cursor  c_pds is
   select pds.period_of_service_id,
          pds.object_version_number
   from   per_periods_of_service pds
   where  pds.person_id   = p_pa_request_rec.person_id
   and    pds.date_start  <= g_effective_date
   and    pds.actual_termination_date is null
   order by 1 asc;


-- Person Type

cursor c_person_type is
  Select ppt.system_person_type,
         ppf.person_type_id
  from   per_person_types ppt,
         per_all_people_f     ppf
  where  ppf.person_id      = P_pa_request_rec.person_id
  and    ppt.person_type_id = ppf.person_type_id
  and    g_effective_date  between ppf.effective_start_date
  and    ppf.effective_end_date;


-- Cursor to fetch all the assignment (pertaining to applications) records,
-- except the one that gets passed from the Form
-- The foll. cursor is currently not being used.

  Cursor c_other_asg is
    select asg.assignment_id,
           asg.object_version_number
    from   per_all_assignments_f asg
    where  asg.person_id         =  p_pa_request_rec.person_id
    and    asg.assignment_id    <>  p_pa_request_rec.employee_assignment_id;


--  EX_Employee person type

  Cursor c_ex_emp_per_type is
    select ppt.person_type_id
    from   per_person_types ppt
    where  ppt.business_group_id  = l_business_group_id
    and    ppt.system_person_type = 'EX_EMP'
--    and    ppt.user_person_type   = 'Ex-employee'
    and    ppt.active_flag        = 'Y'
    order by ppt.person_type_id asc;

--

-- Person Address
--
--May have to read from History depending on the action and effective date
cursor c_address_type is
select
          pad.address_id,
        pad.object_version_number,
          pad.address_line1,
          pad.address_line2,
          pad.address_line3,
          pad.town_or_city,
          pad.region_2,
          pad.postal_code,
          pad.country
from
          per_addresses pad
where
          pad.person_id = p_pa_request_rec.person_id
and     g_effective_date + 1
between pad.date_from and nvl(pad.date_to,g_effective_date + 1)
and     pad.primary_flag = 'Y';
--
-- Start Bug 1316321
-- Cursor for  selecting corresponding secondary addresses for the primay
-- address for end dating -- same cursor used for creating new secondary addresses
cursor c_sec_address is
select
          pad.address_id,
        pad.object_version_number,
          pad.address_line1 ,
          pad.address_line2 ,
          pad.address_line3 ,
          pad.town_or_city ,
          pad.region_2 ,
          pad.region_1 ,
          pad.postal_code ,
          pad.country ,
          pad.address_type,
          pad.primary_flag
from
          per_addresses pad
where
          pad.person_id = p_pa_request_rec.person_id
and     g_effective_date
between pad.date_from and nvl(pad.date_to,g_effective_date)
and pad.primary_flag <> 'Y';

cursor c_upd_primary_address(p_pa_request_id IN NUMBER,
                             p_address_id    IN NUMBER)
       is
  SELECT pah.information1
  FROM ghr_pa_history pah
  WHERE pah.table_name = 'PER_ADDRESSES'
    AND pah.information1 = p_address_id
    AND pah.pa_request_id IN
         (
          SELECT pa_request_id
            FROM ghr_pa_requests
          CONNECT BY prior pa_request_id = altered_pa_request_id
           START WITH pa_request_id = p_pa_request_id
         );
--
cursor  county_name is
 select  c.county_name
 from    pay_us_counties   c ,
         pay_us_city_names t ,
         pay_us_states     s,
         pay_us_zip_codes  z
 where   s.state_abbrev = p_pa_request_rec.forwarding_region_2
 and     t.city_name   =  p_pa_request_rec.forwarding_town_or_city
 and     t.state_code  = s.state_code
 and     t.state_code  = c.state_code
 and     t.county_code = c.county_code
 and     z.city_code   = t.city_code
 and     substr(p_pa_request_rec.forwarding_postal_code,1,5)
 between z.zip_start and z.zip_end
 and     z.state_code  =  t.state_code
 and     z.county_code = t.county_code;

--

-- Object_version_number and Normal Hours  - Asg

cursor    asg_ovn(p_assignment_id in number) is
  select  paf.object_version_number,
          paf.business_group_id,
          paf.normal_hours,
          paf.location_id,
          paf.payroll_id
  from    per_all_assignments_f  paf
  where   paf.assignment_id = p_assignment_id
  and     g_effective_date
  between paf.effective_start_date
  and     paf.effective_end_date;

-- Object_version_number  - Person

cursor per_ovn is
  select ppf.object_version_number,
         ppf.business_group_id ,
         ppf.employee_number,
         ppf.national_identifier,
         ppf.date_of_birth,
         ppf.first_name,
         ppf.last_name,
         ppf.middle_names
  from   per_all_people_f  ppf
  where  ppf.person_id = P_pa_request_rec.person_id
  and    g_effective_date between ppf.effective_start_date
         and ppf.effective_end_date;

-- payroll id

 Cursor   c_payroll_name is
  select  rei_information3 payroll_id
  from    ghr_pa_request_extra_info
  where   pa_request_id       =   p_pa_request_rec.pa_request_id
  and     information_type    =   'GHR_US_PAR_PAYROLL_TYPE';

 Cursor    c_payroll_id is
   select  payroll_id
   from    pay_payrolls_f
   where   period_type        = 'Bi-Week'
   and     payroll_name       = l_payroll_name
   and     business_group_id  = l_business_group_id
   and     p_pa_request_rec.effective_date
   between effective_start_date and effective_end_date;

 Cursor    c_bw_payroll is
   select  pay.payroll_id
   from    pay_payrolls_f pay
   where   pay.payroll_name = 'Biweekly Payroll'
   and     g_effective_date
   between pay.effective_start_date and pay.effective_end_date
   and     business_group_id  = l_business_group_id;

-- position object_version_number

  Cursor  c_pos_ovn is
    select pos.object_version_number
    from   hr_all_positions_f pos -- Venkat
    where  pos.position_id = p_pa_request_rec.from_position_id
    and p_pa_request_rec.effective_date between
    pos.effective_start_date and pos.effective_end_date;

-- Tax Unit Id - GRE

 Cursor   c_tax_unit_org is
   select tax.tax_unit_id
   from   hr_tax_units_v tax
   where  tax_unit_id = p_pa_request_rec.to_organization_id;

 Cursor  c_tax_unit_bg is
   select tax.tax_unit_id
   from   hr_tax_units_v tax
   where  tax_unit_id = l_business_group_id;

-- Getting from Organization_id

  Cursor  c_from_org_id is
    select pos.organization_id
    from   hr_all_positions_f pos
    where  pos.position_id = p_pa_request_rec.from_position_id
    and p_pa_request_rec.effective_date between
    pos.effective_start_date and pos.effective_end_date;

-- Getting to Organization_id

  Cursor  c_to_org_id is
    select pos.organization_id
    from   hr_all_positions_f pos
    where  pos.position_id = p_pa_request_rec.to_position_id
    and p_pa_request_rec.effective_date between
    pos.effective_start_date and pos.effective_end_date;

-- Getting Old User Status

  Cursor c_user_status is
  select ast.user_status,
         ast.per_system_status,
         asg.effective_start_date
  from
    per_assignment_status_types ast,
    per_all_assignments_f asg
    where asg.assignment_id = l_assignment_id
    and ast.assignment_status_type_id = asg.assignment_status_type_id
    and     g_effective_date
    between asg.effective_start_date
    and     asg.effective_end_date;

-- Bug#2839332 Cursor to get the Assignment Status
-- before NON_PAY_DUTY_STATUS Action for "RETURN TO DUTY" action.

/****** Bug 5923426 Commented the cursor and wrote a modified one.
   Cursor c_user_old_status is
   Select asg.assignment_status_type_id
    from   per_assignments_f asg
    where  asg.assignment_id = l_assignment_id
    and    l_old_effective_start_date between asg.effective_start_date
                                          and asg.effective_end_date;
********/
--- Bug 5923426 start

    Cursor c_user_old_status is
    Select past.per_system_status ,asg.assignment_status_type_id
    from   per_assignments_f asg,per_assignment_status_types past
    where  asg.assignment_id = l_assignment_id
    and asg.assignment_status_type_id = past.assignment_status_type_id
    order by  asg.effective_start_date desc;

--- Bug 5923426 end

-- JH Get To Position Title PM for Noa Code being updated.
  Cursor get_to_posn_title_pm is
    select  fpm.process_method_code
    from    ghr_noa_families         nof
           ,ghr_families             fam
           ,ghr_noa_fam_proc_methods fpm
           ,ghr_pa_data_fields       pdf
    where   nof.nature_of_action_id = p_pa_request_rec.first_noa_id
    and     nof.noa_family_code     = fam.noa_family_code
    and     nof.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(nof.start_date_active,p_pa_request_rec.effective_date)
    and     nvl(nof.end_date_active,p_pa_request_rec.effective_date)
    and     fam.proc_method_flag = 'Y'
    and     fam.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(fam.start_date_active,p_pa_request_rec.effective_date)
    and     nvl(fam.end_date_active,p_pa_request_rec.effective_date)
    and     fam.noa_family_code = fpm.noa_family_code
    and     fpm.pa_data_field_id = pdf.pa_data_field_id
    and     fpm.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(fpm.start_date_active,p_pa_request_rec.effective_date)
    and     nvl(fpm.end_date_active,p_pa_request_rec.effective_date)
    and     pdf.form_field_name = l_form_field_name
    and     pdf.enabled_flag = 'Y'
    and     p_pa_request_rec.effective_date between nvl(pdf.date_from,p_pa_request_rec.effective_date)
    and     nvl(pdf.date_to,p_pa_request_rec.effective_date);
--
-- 3324737
CURSOR RTD_asg_status( p_asg_id    NUMBER,
                p_eff_date  DATE  )
IS
SELECT effective_date
FROM   ghr_pa_Requests
WHERE effective_date        <= p_eff_Date
and   person_id = p_pa_request_rec.person_id
--and   employee_assignment_id = p_Asg_id
-- for performance reasons
and pa_notification_id is not null
and   noa_family_code        = 'NON_PAY_DUTY_STATUS'
ORDER BY pa_request_id desc;

l_rtd_date              DATE;
--3324737
--
--
l_assgn_id             NUMBER;
l_eff_date             DATE;
l_NTE_Dates            per_assignment_extra_info.aei_information4%TYPE;
l_active_flag          varchar2(1);
l_RTD_noa_code         VARCHAR2(80);
l_bg_id                NUMBER;

--
-- 2839332
--

-- Bug 3215139
CURSOR get_occ_code(c_position_id hr_all_positions_f.position_id%type, c_effective_date hr_all_positions_f.effective_start_date%type) IS
   SELECT pos.job_id
   FROM hr_all_positions_f pos
   WHERE pos.position_id = c_position_id
   AND c_effective_date BETWEEN pos.effective_start_date and pos.effective_end_date;

CURSOR	get_segment(c_business_group_id per_people_f.business_group_id%type) IS
  SELECT	ORG_INFORMATION5
    FROM  	HR_ORGANIZATION_INFORMATION
   WHERE  	ORG_INFORMATION_CONTEXT = 'GHR_US_ORG_INFORMATION'
    	  AND	ORGANIZATION_ID = c_business_group_id;

l_agency_segment hr_organization_information.org_information5%type;
l_pos_agency_code VARCHAR2(30);

CURSOR c_get_agency_code(c_segment hr_organization_information.org_information5%type,
						 c_position_id hr_all_positions_f.position_id%type,
						 c_effective_date hr_all_positions_f.effective_start_date%type) IS
	SELECT DECODE(c_segment,'SEGMENT1',SEGMENT1,
                                'SEGMENT2',SEGMENT2,
                                'SEGMENT3',SEGMENT3,
                                'SEGMENT4',SEGMENT4,
                                'SEGMENT5',SEGMENT5,
                                'SEGMENT6',SEGMENT6,
                                'SEGMENT7',SEGMENT7,
                                'SEGMENT8',SEGMENT8,
                                'SEGMENT9',SEGMENT9,
                                'SEGMENT10',SEGMENT10,
                                'SEGMENT11',SEGMENT11,
                                'SEGMENT12',SEGMENT12,
                                'SEGMENT13',SEGMENT13,
                                'SEGMENT14',SEGMENT14,
                                'SEGMENT15',SEGMENT15,
                                'SEGMENT16',SEGMENT16,
                                'SEGMENT17',SEGMENT17,
                                'SEGMENT18',SEGMENT18,
                                'SEGMENT19',SEGMENT19,
                                'SEGMENT20',SEGMENT20,
                                'SEGMENT21',SEGMENT21,
                                'SEGMENT22',SEGMENT22,
                                'SEGMENT23',SEGMENT23,
                                'SEGMENT24',SEGMENT24,
                                'SEGMENT25',SEGMENT25,
                                'SEGMENT26',SEGMENT26,
                                'SEGMENT27',SEGMENT27,
                                'SEGMENT28',SEGMENT28,
                                'SEGMENT29',SEGMENT29,
                                'SEGMENT30',SEGMENT30) agency_code
    FROM per_position_definitions ppd, hr_all_positions_f pos
	WHERE pos.position_definition_id = ppd.position_definition_id
	AND pos.position_id = c_position_id
	AND c_effective_date BETWEEN pos.effective_start_date AND pos.effective_end_date;

------------------------

l_update_occ_code VARCHAR2(1) := 'N';
l_pos_job_id hr_all_positions_f.job_id%type;


--Bug 3381960
-- Get Assignment position for the person
CURSOR c_get_asg_position(c_assignment_id per_all_assignments_f.assignment_id%type,
						  c_effective_date per_all_assignments_f.effective_start_date%type) IS
SELECT position_id
FROM per_all_assignments_f asg
WHERE asg.assignment_id = c_assignment_id
AND c_effective_date BETWEEN asg.effective_start_date AND asg.effective_end_date;
l_asg_position per_all_assignments_f.position_id%type;


--Pradeep
CURSOR cur_get_nte_date IS
    SELECT rei_information12 nte_date, rei_information11 amount
    FROM ghr_pa_request_extra_info
    WHERE rei_information_category='GHR_US_PAR_MD_DDS_PAY'
    AND   pa_request_id =  p_pa_request_rec.pa_request_id;

 CURSOR check_remarks is
    SELECT remark_id
    FROM   ghr_pa_remarks
    WHERE  pa_request_id = p_pa_request_rec.pa_request_id
    AND    remark_id =
           (select remark_id from ghr_remarks
            where code = 'BBB');




 Cursor  cur_get_remark_code(p_remark_id ghr_remarks.remark_id%TYPE) is
   select   rem.code
   from     ghr_remarks  rem
   where    rem.remark_id  =  p_remark_id
   and      rem.enabled_flag = 'Y'
   and      nvl(p_pa_request_rec.effective_date,sysdate)
   between  rem.date_from and nvl(rem.date_to,nvl(p_pa_request_rec.effective_date, trunc(sysdate)));

 l_mddds_special_pay_nte_date ghr_pa_request_extra_info.rei_information12%TYPE;
 l_mddds_total_special_pay    ghr_pa_request_extra_info.rei_information11%TYPE;
 l_check_remarks	      BOOLEAN := FALSE;
 l_rpa_remark_code            ghr_remarks.code%TYPE;
 l_rpa_remark_id	      ghr_remarks.remark_id%TYPE;

 --bug 4542437
 l_position_id                ghr_pa_requests.from_position_id%TYPE  :=NULL;
 l_job_id                     per_all_assignments_f.job_id%TYPE      :=NULL;
 l_org_id                     per_all_assignments_f.organization_id%TYPE :=NULL;
 l_grade_id                   per_position_extra_info.poei_information3%TYPE :=NULL;
 l_pos_ei_data                per_position_extra_info%ROWTYPE;
Begin
    --
    -- Remember IN OUT parameter IN values
    --
    l_pa_request_rec := p_pa_request_rec;

 g_effective_date  :=  nvl(p_pa_request_rec.effective_date,sysdate);
 hr_utility.set_location('g_eff_date ' || to_char(g_effective_date),1);

 -- if Realignment then change the organization name in position
 if p_pa_request_rec.first_noa_code = '790' then
    l_position_data_rec_type.position_id            := p_pa_request_rec.to_position_id;
    l_position_data_rec_type.organization_id        := p_pa_request_rec.to_organization_id;
    l_position_data_rec_type.agency_code_subelement := p_agency_code;
    l_position_data_rec_type.effective_date   :=  g_effective_date;
    hr_utility.set_location('realign -pos ' || p_pa_request_rec.to_organization_id,1);
    ----l_position_data_rec_type.datetrack_mode := return_update_mode
    ----               (p_id                 => p_pa_request_rec.to_position_id,
    ----                p_effective_date     => p_pa_request_rec.effective_date,
    ----                p_table_name         => 'HR_ALL_POSITIONS_F'
    ----               );
   -- Start Bug 1613367
    For ovn in asg_ovn(p_pa_request_rec.employee_assignment_id) loop
      l_temp_asg_loc_id           := ovn.location_id;
    End loop;
    IF nvl(p_pa_request_rec.duty_station_location_id,hr_api.g_number)
         <> nvl(l_temp_asg_loc_id,hr_api.g_number) then
      l_position_data_rec_type.location_id        := p_pa_request_rec.duty_station_location_id;
    ELSE
      l_position_data_rec_type.location_id        := NULL;
    END IF;
    -- End Bug 1613367

    ghr_sf52_pos_update.update_position_info
                        (p_pos_data_rec   =>  l_position_data_rec_type
                        );
/* -- SEt flag to update assignment with the targer org.
    l_employee_api_update_criteria := 'Y';
*/

 end if;

    -- Start Inserting AAA Remark

 hr_utility.set_location('Before the Remark creation - From PB '||p_pa_request_rec.from_pay_basis,3);
 hr_utility.set_location('Before the Remark creation - To PB '||p_pa_request_rec.to_pay_basis,3);
 hr_utility.set_location('Before the Remark creation - PRD  '||p_pa_request_rec.pay_rate_determinant,3);

IF p_pa_request_rec.from_pay_basis <> p_pa_request_rec.to_pay_basis and
   p_pa_request_rec.pay_rate_determinant in ('A','B','E','F','U','V') THEN

 hr_utility.set_location('Inside the Remark creation ',3);
 ghr_mass_actions_pkg.get_remark_id_desc
      (p_remark_code     =>  'AAA',
       p_effective_date  =>  g_effective_date,
       p_remark_id       =>  l_remark_id,
       p_remark_desc     =>  l_remark_description
       );


  ghr_pa_remarks_api.create_pa_remarks
  (
   p_PA_REQUEST_ID                     =>    p_pa_request_rec.pa_request_id,
   p_REMARK_ID                         =>    l_remark_id,
   p_DESCRIPTION                       =>    l_remark_description,
   P_PA_REMARK_ID                      =>    l_pa_remark_id,
   p_OBJECT_VERSION_NUMBER             =>    l_rem_ovn
   );
END IF;
 hr_utility.set_location('Passed  Remark creation ',5);
    -- End Inserting AAA Remark

-- Start Populating BBB Remark
 IF p_pa_request_rec.first_noa_code = '850' THEN
    hr_utility.set_location('Inside the Remark creation ',3);
    --Check if user has entered any comments. If so do not populate BBB.
    hr_utility.set_location('Pa Request Id'||p_pa_request_rec.pa_request_id,3);

  FOR check_remarks_rec in check_remarks
  LOOP
	l_check_remarks := TRUE;
	l_rpa_remark_id  := check_remarks_rec.remark_id;
	EXIT;
  END LOOP;

  FOR cur_get_nte_date_rec IN  cur_get_nte_date
  LOOP
    l_mddds_special_pay_nte_date := cur_get_nte_date_rec.nte_date;
    l_mddds_total_special_pay    :=  cur_get_nte_date_rec.amount;
  END LOOP;

  IF NOT l_check_remarks THEN

	  ghr_mass_actions_pkg.get_remark_id_desc
	       (p_remark_code     =>  'BBB',
		p_effective_date  =>  g_effective_date,
		p_remark_id       =>  l_remark_id,
		p_remark_desc     =>  l_remark_description
		);

	  l_remark_description := replace(l_remark_description,'_')
				  ||to_char(fnd_date.canonical_to_date(l_mddds_special_pay_nte_date),'DD-MON-RRRR');

	  --while terminating the MDDDS_SPECIAL_PAY element it should delete the  remarks also.
	  IF ( l_mddds_total_special_pay <> 0 )
	     and ( l_mddds_total_special_pay IS NOT NULL ) THEN

		   ghr_pa_remarks_api.create_pa_remarks
		   (
		    p_PA_REQUEST_ID                     =>    p_pa_request_rec.pa_request_id,
		    p_REMARK_ID                         =>    l_remark_id,
		    p_DESCRIPTION                       =>    l_remark_description,
		    P_PA_REMARK_ID                      =>    l_pa_remark_id,
		    p_OBJECT_VERSION_NUMBER             =>    l_rem_ovn,
		    p_remark_code_information1          =>    l_mddds_special_pay_nte_date
		    );


	   END IF;
     ELSE
	  --while terminating the MDDDS_SPECIAL_PAY element it should delete the  remarks also.
	  IF ( l_mddds_total_special_pay = 0 )
	     OR ( l_mddds_total_special_pay IS NULL ) THEN

		hr_utility.set_location('Inside else'||l_rpa_remark_id ,10);
		FOR get_remark_code_rec IN cur_get_remark_code(l_rpa_remark_id)
		LOOP
		   l_rpa_remark_code := get_remark_code_rec.code;
		END LOOP;
		hr_utility.set_location('Remark Code already entered ' ||l_rpa_remark_code,11);
		IF l_rpa_remark_code='BBB' THEN
			-- While terminating the element if BBB remark is present then
			hr_utility.set_message(8301,'GHR_38877_850_REMARK');
			hr_utility.raise_error;
		END IF;
	END IF;

    END IF;
 END IF;
 --End of Populating BBB remark.



 hr_utility.set_location('Entering  ' ||l_proc,5);

 l_noa_family_code := null;
 for family_code in c_noa_family_code loop
   l_noa_family_code := family_code.noa_family_code;
 End loop;

 l_person_type   :=  null;

  -- fetch person_type
 l_person_type    := null;
 for person_type in c_person_type loop
   l_person_type    :=  person_type.system_person_type;
   l_person_type_id := person_type.person_type_id;
   exit;
 end loop;

 if l_person_type is null then
   hr_utility.set_message(8301,'GHR_38133_INVALID_PERSON');
   hr_utility.raise_error;
 end if;
 hr_utility.set_location(l_proc,10);

--

for  bus_gp in c_bus_gp loop
  l_business_group_id      := bus_gp.business_group_id;
end loop;

-- if Change in data element then change the job id in position
 if p_pa_request_rec.first_noa_code = '800' then
	-- Bug 3786467
	-- Get Agency code segment from ORG EI
	FOR l_get_segment IN get_segment(l_business_group_id) LOOP
		l_agency_segment := l_get_segment.org_information5;
	END LOOP;
	-- Get Agency code from Position
	FOR l_get_agency_code IN c_get_agency_code(l_agency_segment,p_pa_request_rec.to_position_id,p_pa_request_rec.effective_date) LOOP
		l_pos_agency_code := l_get_agency_code.agency_code;
	END LOOP;
	-- Get Job id value from the Core Position form
	-- Bug 3215139 Sundar
	FOR l_get_occ_code IN get_occ_code(p_pa_request_rec.to_position_id,nvl(p_pa_request_rec.effective_date,trunc(sysdate))) LOOP
	   l_pos_job_id := l_get_occ_code.job_id;
	END LOOP;
	hr_utility.set_location('p_agency_code' ||p_agency_code,1);
	hr_utility.set_location('Position agency_code' ||l_pos_agency_code,1);
	-- Need to update Position only if OCC_CODE is different in RPA form than the Position.
	-- Commented for testing
	IF (p_pa_request_rec.to_job_id <> l_pos_job_id) OR (p_agency_code <> l_pos_agency_code) THEN
		l_position_data_rec_type.position_id            := p_pa_request_rec.to_position_id;
		l_position_data_rec_type.job_id                 := p_pa_request_rec.to_job_id;
		l_position_data_rec_type.agency_code_subelement := p_agency_code;
		l_position_data_rec_type.effective_date         := g_effective_date;
		hr_utility.set_location('change in data element-pos ' || p_pa_request_rec.to_job_id,1);
		l_position_data_rec_type.datetrack_mode := return_update_mode
					   (p_id                 => p_pa_request_rec.to_position_id,
						p_effective_date     => p_pa_request_rec.effective_date,
						p_table_name         => 'HR_ALL_POSITIONS_F'
					   );

		ghr_sf52_pos_update.update_position_info
							(p_pos_data_rec   =>  l_position_data_rec_type
							);
			l_update_occ_code := 'Y';
	END IF; -- If p_pa_request_rec.to_job_id <> l_pos_job_id
	-- End 3215139
 end if;



  ghr_history_api.get_g_session_var(l_session);
  hr_utility.set_location('NOA ID CORRECT  :  ' || l_session.noa_id_correct,1);

If l_noa_family_code  =   'APP' then
  hr_utility.set_location(l_proc,15);
  l_per_object_version_number   := null;
  for ovn  in per_ovn loop
    l_business_group_id         := ovn.business_group_id;
    l_per_object_version_number := ovn.object_version_number;
    l_per_upd_employee_number   := ovn.employee_number;
  end loop;
  if l_per_object_version_number is null then
    hr_utility.set_message(8301,'GHR_38133_INVALID_PERSON');
    hr_utility.raise_error;
  end if;

  If l_person_type = 'APL' then    -- and the action is not correction
    hr_utility.set_location(l_proc,20);
    l_hr_applicant_api_hire              := 'Y';
    l_update_mode                        := 'CORRECTION';
    l_activate_flag                      := 'Y';
  End if;
   --Bug# 6711759 Included the person type EX_EMP_APL
  If l_person_type in ('EX_EMP','EX_EMP_APL') then
    hr_utility.set_location(l_proc,21);
      l_rehire_ex_emp                      := 'Y';
      l_activate_flag                      := 'Y';
  End if;

  -- Code added by skutteti on 13-jul-98 bug #699856
  If nvl(p_pa_request_rec.From_Position_Id, hr_api.g_number) <>
     nvl(p_pa_request_rec.to_position_id,   hr_api.g_number) then
     l_employee_api_update_criteria := 'Y';
     l_update_gre              := 'Y';
  end if;

--End of  cases exclusive case for Appointment family
 Else   -- If noa_family_code <> 'APP'
  If l_person_type = 'EX_EMP' then
    hr_utility.set_location(l_proc,25);
    l_rehire_ex_emp            :=  'Y';
    l_activate_flag              :=  'Y';
    l_employee_api_update_criteria := 'Y';
    l_update_gre              := 'Y'; -- Added Venkat Bug # 1239688
  End if;
  If p_pa_request_rec.to_position_id is not null then
    If nvl(p_pa_request_rec.From_Position_Id,hr_api.g_number) <>  P_pa_request_rec.to_position_id
     then
     hr_utility.set_location('Non Appointment -- To pos <> From Pos - GRE  ' ||l_proc,41);
     l_employee_api_update_criteria := 'Y';
     l_update_gre       := 'Y';
     l_update_mode      := 'UPDATE';  -- If action is Correction,then update_mode = 'CORRECTION'
   end if;
  End if;

	-- Bug 3381960
	IF p_pa_request_rec.to_position_id IS NOT NULL THEN
		-- Get Assignment Position. If it's not equal to To position of RPA, then assignment
		-- should be updated

		FOR l_get_asg_position IN c_get_asg_position(p_pa_request_rec.employee_assignment_id,
													p_pa_request_rec.effective_date) LOOP
			l_asg_position := l_get_asg_position.position_id;
		END LOOP;
		hr_utility.set_location('Assg Pos   ' ||l_asg_position,41);
		IF l_asg_position IS NOT NULL AND (p_pa_request_rec.to_position_id <> l_asg_position) THEN
			hr_utility.set_location('To pos <> Assg Pos   ' ||l_proc,41);
			l_employee_api_update_criteria := 'Y';
		END IF;

	END IF;

   --
   --  Added by subbu on 25-Feb-98. Assignment information has to be updated irrespective
   --  of the change in position for REALIGNMENT
   --
   if l_noa_family_code = 'REALIGNMENT' then
      hr_utility.set_location('realign' || p_pa_request_rec.to_organization_id,1);
      l_employee_api_update_criteria := 'Y';
      l_update_gre                   := 'Y';
   end if;
   --
   --  Added by subbu on 13-Jul-98. Assignment information has to be updated irrespective
   --  of the change in position for NOA 713 (change to lower grade)
   --
   --if l_noa_family_code = 'SALARY_CHG' then
        if p_pa_request_rec.to_grade_or_level is not null and
       nvl(p_pa_request_rec.from_grade_or_level,hr_api.g_varchar2) <> p_pa_request_rec.to_grade_or_level then
      l_employee_api_update_criteria := 'Y';
   end if;
   --
   -- Update of Pay Plan GG to Assignmentn 855 processing.
   -- Added by AVR on 07-APR-2004.
   -- Bug#5089732 Added the l_noa_family_code condition.
     IF p_pa_request_rec.first_noa_code = '855'
        OR
        p_pa_request_rec.second_noa_code = '855'
        OR
        l_noa_family_code = 'REASSIGNMENT' --Bug# 7209120
        OR
        l_noa_family_code like 'GHR_SAL%' THEN

        IF nvl(p_pa_request_rec.from_pay_plan,hr_api.g_varchar2) <> p_pa_request_rec.to_pay_plan then
             l_employee_api_update_criteria := 'Y';
        END IF;
     END IF;
   --
   --  Added by Dan on 09-Jun-98. Assignment information has to be updated irrespective
   --  of the change in position for NOA 800 (change in data element)
   --
   if l_noa_family_code = 'CHG_DATA_ELEMENT' then
      hr_utility.set_location('realign' || p_pa_request_rec.to_job_id,3);
	  IF (l_update_occ_code = 'Y') THEN -- Sundar 3215139 Need to update assignment only if position is updated
      l_employee_api_update_criteria := 'Y';
	  END IF;
   end if;

--BUG 4542437
if l_noa_family_code = 'NON_PAY_DUTY_STATUS' then
    hr_utility.set_location('Family code Non pay duty status ',500);
    IF p_pa_request_rec.to_position_id  IS  NULL THEN
        hr_utility.set_location('To position id is null but position id is changed by a retro',519);
        l_position_id  := p_pa_request_rec.from_position_id;
        hr_utility.set_location('l_position id '||l_position_id,525);
        --Getting job id
        FOR l_get_occ_code IN   get_occ_code(p_pa_request_rec.from_position_id,nvl(p_pa_request_rec.effective_date,trunc(sysdate))) LOOP
            l_job_id := l_get_occ_code.job_id;
        END LOOP;
        hr_utility.set_location('job_id '||l_job_id,545);
        ---Getting organization id
        for get_org_id in c_from_org_id loop
            l_org_id := get_org_id.organization_id;
        end loop;
        hr_utility.set_location('l_oraganization id '||l_org_id,575);
        -- Get Assignment Position. If it's not equal to To position of RPA, then assignment
        -- should be updated
        FOR l_get_asg_position IN c_get_asg_position(p_pa_request_rec.employee_assignment_id, p_pa_request_rec.effective_date) LOOP
            l_asg_position := l_get_asg_position.position_id;
        END LOOP;
        hr_utility.set_location('Assg Pos   ' ||l_asg_position,599);

        --Getting Grade id
        ghr_history_fetch.fetch_positionei
            (p_position_id         => l_position_id
            ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
            ,p_date_effective      => p_pa_request_rec.effective_date
            ,p_pos_ei_data         => l_pos_ei_data);

        l_grade_id := l_pos_ei_data.poei_information3;

        hr_utility.set_location('l_grade id for the new position '||l_grade_id,875);
	    --Bug# 6010971, added grade_id condition
        IF l_asg_position IS NOT NULL
             AND ((l_position_id <> l_asg_position)
                    OR (nvl(P_pa_request_rec.to_grade_id,hr_api.g_number) <> nvl(l_grade_id,hr_api.g_number)))
             THEN
                hr_utility.set_location('To pos <> Assg Pos   ' ||l_proc,650);
                l_employee_api_update_criteria := 'Y';
        END IF;
        --Bug# 6010971

   END IF; --p_pa_request_rec.to_position_id  IS  NULL
END IF; --l_noa_family_code = 'NON_PAY_DUTY_STATUS'


   -- Name change
   if l_noa_family_code = 'CHG_NAME' then
     l_update_person              := 'Y';
   elsif  l_noa_family_code  = 'RETURN_TO_DUTY' then
     hr_utility.set_location(l_proc,45);
     l_activate_flag  := 'Y';
   elsif l_noa_family_code  =  'NON_PAY_DUTY_STATUS' then
     hr_utility.set_location(l_proc,50);
     l_suspend_flag   := 'Y';
   elsif l_noa_family_code  =  'SEPARATION' then
     hr_utility.set_location(l_proc,55);
     l_terminate_flag := 'Y';
     IF  P_pa_request_rec.FORWARDING_ADDRESS_LINE1      is not null or
       P_pa_request_rec.FORWARDING_ADDRESS_LINE2        is not null or
       P_pa_request_rec.FORWARDING_ADDRESS_LINE3        is not null or
       P_pa_request_rec.FORWARDING_TOWN_OR_CITY         is not null or
       P_pa_request_rec.FORWARDING_REGION_2         is not null or
       P_pa_request_rec.FORWARDING_POSTAL_CODE      is not null or
       P_pa_request_rec.FORWARDING_COUNTRY          is not null  THEN
       hr_utility.set_location(l_proc,60);
       FOR address in c_address_type LOOP
         l_address_id                := address.address_id;
         l_add_object_version_number := address.object_version_number;
         l_address_line1             := address.address_line1;
         l_address_line2             := address.address_line2;
         l_address_line3             := address.address_line3;
         l_town_or_city              := address.town_or_city;
         l_region_2                  := address.region_2;
         l_postal_code               := address.postal_code;
         l_country                   := address.country;
       END LOOP;
       hr_utility.set_location('Dump Address data' || l_proc,61);
       hr_utility.set_location('p_pa_request_rec.FORWARDING_ADDRESS_LINE1 ' ||substr(p_pa_request_rec.FORWARDING_ADDRESS_LINE1,1,40),62 );
       hr_utility.set_location('p_pa_request_rec.FORWARDING_ADDRESS_LINE2 ' ||substr(p_pa_request_rec.FORWARDING_ADDRESS_LINE2,1,40),63 );
       hr_utility.set_location('p_pa_request_rec.FORWARDING_ADDRESS_LINE3 ' ||substr(p_pa_request_rec.FORWARDING_ADDRESS_LINE3,1,40),64 );
       hr_utility.set_location('p_pa_request_rec.FORWARDING_TOWN_OR_CITY ' ||p_pa_request_rec.FORWARDING_TOWN_OR_CITY,65 );
       hr_utility.set_location('p_pa_request_rec.FORWARDING_REGION_2 ' ||substr(p_pa_request_rec.FORWARDING_REGION_2,1,40),66 );
       hr_utility.set_location('p_pa_request_rec.FORWARDING_POSTAL_CODE ' ||p_pa_request_rec.FORWARDING_POSTAL_CODE,67 );
       hr_utility.set_location('p_pa_request_rec.FORWARDING_COUNTRY ' ||substr(p_pa_request_rec.FORWARDING_COUNTRY,1,40),68 );
       hr_utility.set_location('l_ADDRESS_LINE1 ' ||substr(l_ADDRESS_LINE1,1,40),69 );
       hr_utility.set_location('l_ADDRESS_LINE2 ' ||substr(l_ADDRESS_LINE2,1,40),70 );
       hr_utility.set_location('l_ADDRESS_LINE3 ' ||substr(l_ADDRESS_LINE3,1,40),71 );
       hr_utility.set_location('l_TOWN_OR_CITY ' ||l_TOWN_OR_CITY,72 );
       hr_utility.set_location('l_REGION_2 ' ||substr(l_REGION_2,1,40),73 );
       hr_utility.set_location('l_POSTAL_CODE ' ||l_POSTAL_CODE,74 );
       hr_utility.set_location('l_COUNTRY ' ||substr(l_COUNTRY,1,40),75 );
       IF l_session.noa_id_correct is null THEN
         IF  nvl(p_pa_request_rec.FORWARDING_ADDRESS_LINE1,hr_api.g_varchar2) = nvl(l_address_line1 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_ADDRESS_LINE2 ,hr_api.g_varchar2)= nvl(l_address_line2 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_ADDRESS_LINE3 ,hr_api.g_varchar2)= nvl(l_address_line3 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_TOWN_OR_CITY ,hr_api.g_varchar2) = nvl(l_town_or_city ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_REGION_2 ,hr_api.g_varchar2)     = nvl(l_region_2 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_POSTAL_CODE ,hr_api.g_varchar2)  = nvl(l_postal_code ,hr_api.g_varchar2) and
             nvl(P_pa_request_rec.FORWARDING_COUNTRY ,hr_api.g_varchar2)      = nvl(l_country ,hr_api.g_varchar2) THEN
           null;
           hr_utility.set_location('Non Correction -- No Action ' || l_proc,76);
         ELSE
           l_create_address  := 'Y';
           hr_utility.set_location('Non Correction -- Create Address ' || l_proc,77);
         END IF;
       ELSE
         hr_utility.set_location('altered_pa_request_id is ' ||l_session.altered_pa_request_id ,65);
         hr_utility.set_location('noa_id_correct is ' ||l_session.noa_id_correct ,66);
         hr_utility.set_location('address_id is ' || l_address_id, 66);
         open c_upd_primary_address(l_session.altered_pa_request_id, l_address_id);
         fetch c_upd_primary_address into l_address_id;
         hr_utility.set_location('address_id is ' || l_address_id, 66);

         IF c_upd_primary_address%NOTFOUND then
           IF  nvl(p_pa_request_rec.FORWARDING_ADDRESS_LINE1,hr_api.g_varchar2) = nvl(l_address_line1 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_ADDRESS_LINE2 ,hr_api.g_varchar2)= nvl(l_address_line2 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_ADDRESS_LINE3 ,hr_api.g_varchar2)= nvl(l_address_line3 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_TOWN_OR_CITY ,hr_api.g_varchar2) = nvl(l_town_or_city ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_REGION_2 ,hr_api.g_varchar2)     = nvl(l_region_2 ,hr_api.g_varchar2) and
             nvl(p_pa_request_rec.FORWARDING_POSTAL_CODE ,hr_api.g_varchar2)  = nvl(l_postal_code ,hr_api.g_varchar2) and
             nvl(P_pa_request_rec.FORWARDING_COUNTRY ,hr_api.g_varchar2)      = nvl(l_country ,hr_api.g_varchar2) THEN
             NULL;
             hr_utility.set_location('Correction -- No Action ' || l_proc,69);
           ELSE
             l_create_address := 'Y';
             hr_utility.set_location('Correction -- Create Address ' || l_proc,71);
           END IF;
         ELSE
           l_update_address := 'Y';
           hr_utility.set_location('Correction -- Update Address ' || l_proc,68);
         END IF;
         close c_upd_primary_address;
       END IF;
     END IF;
   ELSE
     hr_utility.set_location(l_proc,78);
   END IF;
END IF;


--   ***********
--   Calling APIs
--   ***********

-- Fetch OVN for per_people_f, while processing hire_applicant and name change

If  l_hr_applicant_api_hire  = 'Y' or
    l_rehire_ex_emp          = 'Y' or
    l_update_person          = 'Y' then
  l_per_object_version_number   := null;
  For ovn  in per_ovn loop
    l_business_group_id         := ovn.business_group_id;
    l_per_object_version_number := ovn.object_version_number;
    l_per_upd_employee_number   := ovn.employee_number;
  End loop;
  If l_per_object_version_number is null then
    hr_utility.set_message(8301,'GHR_38133_INVALID_PERSON');
    hr_utility.raise_error;
  End if;
End if;
--
-- An Appointment Family can now only have 'APL's and hence only hire_applicants can be called.

--  Before calling the hire_applicant, should delete all the other assignments for the person
--  except the one that has been passed in. Call per_asg_del.del in 'ZAP' mode.
--  If it's a CORRECTION to an Appointment , then should not call it

-- Hire Applicant


If l_hr_applicant_api_hire              = 'Y'  and l_session.noa_id_correct is null    then
  hr_utility.set_location(l_proc,75);
  hr_utility.set_location('Emp number is   ' || l_per_hire_employee_number,1);
 begin
  savepoint hire_app;
  hr_applicant_api.hire_applicant
 (P_HIRE_DATE                                   => g_effective_date
 ,P_PERSON_ID                                   => p_pa_request_rec.person_id
 ,P_ASSIGNMENT_ID                               => l_assignment_id
 ,P_PER_OBJECT_VERSION_NUMBER                 => l_per_object_version_number
 ,P_EMPLOYEE_NUMBER                             => l_per_hire_employee_number
 ,P_PER_EFFECTIVE_START_DATE                    => l_per_hire_eff_start_date
 ,P_PER_EFFECTIVE_END_DATE                      => l_per_hire_eff_end_date
 ,P_UNACCEPTED_ASG_DEL_WARNING                => l_per_hire_un_asg_del_warn
 ,P_ASSIGN_PAYROLL_WARNING                      => l_per_hire_asg_pay_warn
, p_oversubscribed_vacancy_id                   => l_per_hire_oversubs_vac_id -- Bug# 1316490 -- Venkat --6/19
 );
  Exception
 when others then
   if substr(sqlerrm(sqlcode),1,19) = 'ORA-20001: APP-7975' then
    rollback to hire_app;
    hr_utility.set_message(8301,'GHR_38555_HIRE_ON_ACC_DATE') ;
    hr_utility.raise_error;
   Else
     rollback to hire_app;
     raise;
   End if;
 End;
End if;

 l_assignment_id   := p_pa_request_rec.employee_assignment_id;

If l_rehire_ex_emp = 'Y' and l_session.noa_id_correct is null then
  hr_utility.set_location(l_proc,76);
   Begin
    savepoint rehire_ex;
   hr_employee_api.re_hire_ex_employee
   (p_hire_date                  =>  p_pa_request_rec.effective_date
   ,p_person_id                  =>  p_pa_request_rec.person_id
   ,p_per_object_version_number  =>  l_per_object_version_number
 --  ,p_person_type_id           =>
   ,p_rehire_reason              =>  'Rehire'
   ,p_assignment_id              =>  l_assignment_id
   ,p_asg_object_version_number  =>  l_asg_object_version_number
   ,p_per_effective_start_date   =>  l_per_hire_eff_start_date
   ,p_per_effective_end_date     =>  l_per_hire_eff_end_date
   ,p_assignment_sequence        =>  l_dum_number
   ,p_assignment_number          =>  l_dum_char
   ,p_assign_payroll_warning     =>  l_per_hire_asg_pay_warn
   );
-- Fix for 655045
   -- Start Changes for 3150551
   /*
   delete from per_person_list_changes
   where person_id =  p_pa_request_rec.person_id
   and  nvl(termination_flag,hr_api.g_varchar2) = 'Y';
   */
   hr_security_internal.clear_from_person_list_changes
   ( p_person_id => p_pa_request_rec.person_id );
   -- End Changes for 3150551
   Exception
   when others then
    rollback to rehire_ex;
    raise;
  End;
End if;

--Note : It looks like if the person_type_id is not passed in, then it defaults to the system_person_type of 'EMP' anyway .
--       and therefore not passing it in.
p_pa_request_rec.employee_assignment_id     :=   l_assignment_id;
-- Bug# 1235958: Update of l_assignment_id for history records.
ghr_history_api.get_g_session_var(l_session);
l_session.assignment_id := l_assignment_id;
ghr_history_api.set_g_session_var(l_session);


-- fetch assignment Business_group, Object_version_number and Normal Hours

l_asg_object_version_number   := null;
For ovn in asg_ovn(l_assignment_id) loop
  l_business_group_id         := ovn.business_group_id;
  l_asg_object_version_number := ovn.object_version_number;
  l_working_hours             := ovn.normal_hours;
  l_asg_payroll_id            := ovn.payroll_id;
-- added for duty_station change
  l_asg_location_id           := ovn.location_id;
End loop;
hr_utility.set_location(l_proc,95);
If l_asg_object_version_number is null then
  hr_utility.set_message(8301,'GHR_38135_INVALID_ASGN');
  hr_utility.raise_error;
End if;

-- Bug 2082615
-- Store the old Asg Status Type in g_old_user_status for using in later stages

    for asg_stat_rec in c_user_status loop
      g_old_user_status   := asg_stat_rec.user_status;
      l_old_system_status := asg_stat_rec.per_system_status;
      l_old_effective_start_date := asg_stat_rec.effective_start_date -1; --bug 2839332
      hr_utility.set_location('Old User status is '||g_old_user_status,96);
      hr_utility.set_location('Old system status '|| l_old_system_status,999);
      exit;
    end loop;

 If l_old_system_status <> 'SUSP_ASSIGN' or
  (l_noa_family_code = 'SEPARATION' or l_noa_family_code = 'RETURN_TO_DUTY' ) then

-- Bug 2839332
    IF (l_noa_family_code = 'RETURN_TO_DUTY') THEN
        FOR rtd_rec in RTD_asg_status(p_pa_request_rec.employee_assignment_id,p_pa_request_rec.effective_date)
        LOOP
            l_old_effective_start_date := rtd_rec.effective_date-1;
            exit;
        END LOOP;

        for asg_stat_old_rec in c_user_old_status loop
            --- Bug 5923426 start
            IF asg_stat_old_rec.per_system_status <>'SUSP_ASSIGN' THEN
                l_asg_status_type_id := asg_stat_old_rec.assignment_status_type_id;
                exit;
            END IF;
            --- Bug 5923426 end
        end loop;
        hr_utility.set_location('Assignment status type id '|| l_asg_status_type_id,997);
	    l_activate_flag := 'Y';
	    -- Bug 2839332
        --Bug# 6010971
        IF nvl(P_pa_request_rec.to_grade_id,hr_api.g_number) <> nvl(l_grade_id,hr_api.g_number) then
            l_employee_api_update_criteria := 'Y';
        end if;
        --Bug# 6010971
    ELSE --(l_noa_family_code = 'RETURN_TO_DUTY')
		-- Added p_assigment_id for Bug#4672772
        get_asg_status_type(p_noa_code       => p_pa_request_rec.first_noa_code,
                        p_business_group_id  => l_business_group_id,
                        p_assignment_id      => p_pa_request_rec.employee_assignment_id,
			p_pa_request_id	     => p_pa_request_rec.pa_request_id, --Bug# 8724192
                        p_status_type_id     => l_asg_status_type_id,
                        p_activate_flag      => l_activate_flag,
                        p_suspend_flag       => l_suspend_flag,
                        p_terminate_flag     => l_terminate_flag
                         );
    END IF; --(l_noa_family_code = 'RETURN_TO_DUTY')
 End if; -- l_old_system_status <> 'SUSP_ASSIGN'

--
-- fetch payroll_id
-- Note  : Fetch has to be done only in cases where the user has not input a value in the
--         specific  DDF.

l_payroll_id   := null;

For payroll in c_payroll_name loop
  l_payroll_id := payroll.payroll_id;
End loop;

If l_payroll_id is null then

  -- If payroll_id in the assignment record is null then
  If l_asg_payroll_id is null then
    For bw_payroll in c_bw_payroll loop
      l_payroll_id  := bw_payroll.payroll_id;
       exit;
    End loop;
  Else
    l_payroll_id := l_asg_payroll_id;
  End if;
End if;

If l_payroll_id is null then
  hr_utility.set_message(8301,'GHR_38183_PAY_NOT_EXISTS');
  hr_utility.raise_error;
End if;

--Pradeep start of bug #4148743
If l_payroll_id  <> l_asg_payroll_id THEN
    l_employee_api_update_criteria := 'Y';
end if;
--Pradeep end of bug #4148743


If nvl(p_pa_request_rec.duty_station_location_id,hr_api.g_number) <> nvl(l_asg_location_id,hr_api.g_number) then
   l_employee_api_update_criteria     := 'Y';
End if;

--
--  calling hr_assignment_api.update_emp_asg_criteria
--
If l_employee_api_update_criteria  = 'Y' or l_update_gre = 'Y' then
 -- Function to determine update_mode
  l_update_mode := return_update_mode
                   (p_id                 => p_pa_request_rec.employee_assignment_id,
                    p_effective_date     => p_pa_request_rec.effective_date,
                    p_table_name         => 'PER_ASSIGNMENTS_F'
                   );
  hr_utility.set_location(l_proc,90);
  hr_utility.set_location('Asg id ' || to_char(l_assignment_id),3);
  hr_utility.set_location('pay id ' || to_char(l_payroll_id),4);
  hr_utility.set_location('l_update_gre is '||l_update_gre,91);

 If l_update_gre = 'Y' then
   -- get the GRE . Passed into the foll. api as the p_tax_unit
   for tax_unit in c_tax_unit_org loop
     l_tax_unit_id := tax_unit.tax_unit_id;
   end loop;
   If l_tax_unit_id is null then
    for tax_unit in c_tax_unit_bg loop
      l_tax_unit_id := tax_unit.tax_unit_id;
    end loop;
   End if;

  hr_utility.set_location(l_proc,92);
  begin
   savepoint update_emp_asg;
   hr_assignment_api.update_us_emp_asg
   (p_assignment_id          => p_pa_request_rec.employee_assignment_id,
    p_object_version_number  => l_asg_object_version_number,
    p_effective_date         => g_effective_date,
    p_datetrack_update_mode  => l_update_mode,
    p_comment_id             => l_comment_id,
    p_tax_unit               => l_tax_unit_id, -- gre
    p_soft_coding_keyflex_id => l_soft_coding_keyflex_id,
    p_effective_start_date   => l_asg_upd_effective_start_date,
    p_effective_end_date     => l_asg_upd_effective_end_date,
    p_concatenated_segments  => l_concatenated_segments,
    p_no_managers_warning    => l_asg_upd_org_now_man_warn,
    p_other_manager_warning  => l_asg_upd_other_manager_warn
   );
    l_update_mode    := 'CORRECTION';
   Exception
    When others then
      rollback to update_emp_asg;
      raise;
   End;
 End if;
  hr_utility.set_location('After update_us_emp_asg '||l_proc,93);
 If l_employee_api_update_criteria = 'Y' then
  hr_utility.set_location('Before  update_emp_asg_criteria ',94);
hr_utility.set_location('checking how correction updates the record',500);
hr_utility.set_location('the to position id passed',500);
  hr_assignment_api.update_emp_asg_criteria
     (p_effective_date                          => g_effective_date
     ,p_datetrack_update_mode                   => l_update_mode
     ,p_assignment_id                           => l_assignment_id
     ,p_object_version_number                   => l_asg_object_version_number
     ,P_PAYROLL_ID                              => l_payroll_id
     ,p_position_id                             => nvl(P_pa_request_rec.to_position_id,l_position_id) --nvl added for bug 4542437
     ,p_job_id                                  => nvl(P_pa_request_rec.to_job_id,l_job_id) --nvl added for bug 4542437
     ,p_location_id                             => P_pa_request_rec.duty_station_location_id
     ,p_organization_id                         => nvl(P_pa_request_rec.to_organization_id,l_org_id)--nvl added for bug 4542437
     ,p_grade_id                                => nvl(P_pa_request_rec.to_grade_id,l_grade_id) --nvl added for bug 4542437
     ,p_effective_start_date                    => l_asg_upd_effective_start_date
     ,p_effective_end_date                      => l_asg_upd_effective_end_date
     ,p_special_ceiling_step_id                 => l_asg_upd_special_ceil_step_id
     ,p_people_group_id                         => l_asg_upd_people_group_id
     ,p_group_name                              => l_asg_upd_group_name
     ,p_org_now_no_manager_warning              => l_asg_upd_org_now_man_warn
     ,p_other_manager_warning                   => l_asg_upd_other_manager_warn
     ,p_spp_delete_warning                      => l_asg_upd_spp_delete_warning
     ,p_entries_changed_warning                 => l_asg_upd_entries_chan_warn
     ,p_tax_district_changed_warning            => l_asg_upd_tax_dist_chan_warn
     );
 End if;
End if;
--
  hr_utility.set_location('After update_emp_asg_criteria '||l_proc,95);
 If l_activate_flag = 'Y' and l_session.noa_id_correct is null  then
   hr_utility.set_location(l_proc,120);
   l_update_mode := return_update_mode
                   (p_id                 => p_pa_request_rec.employee_assignment_id,
                    p_effective_date     => p_pa_request_rec.effective_date,
                    p_table_name         => 'PER_ASSIGNMENTS_F'
                   );
   Begin
    savepoint activate;

   hr_assignment_api.activate_emp_asg
   (p_effective_date                  => g_effective_date
   ,p_datetrack_update_mode             => l_update_mode
   ,p_assignment_id                   => l_assignment_id
   ,p_assignment_status_type_id         => l_asg_status_type_id
   ,p_object_version_number             => l_asg_object_version_number
   ,p_effective_start_date            => l_asg_act_eff_start_date
   ,p_effective_end_date              => l_asg_act_eff_end_date
   );
  Exception
   when others then
     rollback to activate;
    raise;
  end;
 Elsif l_suspend_flag = 'Y' and l_session.noa_id_correct is null then  -- is a suspension and not a correction
   hr_utility.set_location(l_proc,125);
    l_update_mode := return_update_mode
                    (p_id                 => p_pa_request_rec.employee_assignment_id,
                     p_effective_date     => p_pa_request_rec.effective_date,
                     p_table_name         => 'PER_ASSIGNMENTS_F'
                    );
    Begin
     savepoint suspend;
    hr_assignment_api.suspend_emp_asg
   (p_effective_date                    => g_effective_date
   ,p_datetrack_update_mode             => l_update_mode
   ,p_assignment_id                     => l_assignment_id
   ,p_object_version_number             => l_asg_object_version_number
   ,p_assignment_status_type_id         => l_asg_status_type_id
   ,p_effective_start_date              => l_asg_sus_eff_start_date
   ,p_effective_end_date                => l_asg_sus_eff_end_date
   );
   Exception
    when others then
      rollback to suspend;
     raise;
   End;
--        elsif l_terminate_asg_flag = 'Y' then
 Elsif l_terminate_flag = 'Y' then

   hr_utility.set_location(l_proc,130);
   hr_utility.set_location('NOA ID CORRECT  :  ' || l_session.noa_id_correct,1);
   If l_session.noa_id_correct is  null then
     hr_utility.set_location(l_proc,132);
     l_emp_trm_eff_end_date :=  null;

     for pds in c_pds loop
       l_period_of_service_id      := pds.period_of_service_id;
       l_pds_object_version_number := pds.object_version_number;
       exit;
     end loop;

     for ex_emp_type in c_ex_emp_per_type  loop
       l_person_type_id := ex_emp_type.person_type_id;
       exit;
     end loop;
     begin
      savepoint terminate;
     l_date1 := g_effective_date;
     hr_ex_employee_api.actual_termination_emp
    (p_effective_date                 => g_effective_date
    ,p_period_of_service_id           => l_period_of_service_id
    ,p_object_version_number          => l_pds_object_version_number
    ,p_actual_termination_date        => g_effective_date
    ,p_last_standard_process_date     => l_date1
    ,p_person_type_id                 => l_person_type_id
    ,p_assignment_status_type_id      => l_asg_status_type_id    -- the one derived using the fn. get_asg_status_type
    ,p_supervisor_warning             => l_supervisor_warning
    ,p_event_warning                  => l_event_warning
    ,p_interview_warning              => l_interview_warning
    ,p_review_warning                 => l_review_warning
    ,p_recruiter_warning              => l_recruiter_warning
    ,p_asg_future_changes_Warning     => l_asg_future_changes_warning
    ,p_entries_changed_warning        => l_entries_changed_warning
    ,p_pay_proposal_warning           => l_pay_proposal_warning
    ,p_dod_warning                    => l_dod_warning
    );
    -- Start Changes for 3150551
    /*
    insert into per_person_list_changes
       (person_id
       ,security_profile_id
       ,include_flag
       ,termination_flag)
       select l.person_id
       ,l.security_profile_id
       ,'Y'
       ,'Y'
       from per_person_list l
       where l.person_id =  p_pa_request_rec.person_id
         and not exists
              (Select 1
               From   per_person_list_changes pplc
               Where  pplc.person_id           = p_pa_request_rec.person_id
               And    pplc.security_profile_id = l.security_profile_id
              );
    */
    hr_security_internal.copy_to_person_list_changes
   (p_person_id => p_pa_request_rec.person_id );
    -- End Changes for 3150551
   Exception
    when others then
      rollback to terminate;
      raise;
   End;

    l_emp_trm_eff_end_date           := null;
 -- g_effective_date + 1;
   -- Checking whether Payroll installed or not. Skipping Final Process if the the Payrol
   -- Installed. If there is no payroll installed then doing Finall process.
   -- Assuming HR_USER_TYPE will be 'PER' if the payroll is not installed, so doing Final
   -- Process for HR user
    l_hr_user_type := fnd_profile.value('HR_USER_TYPE');
    IF l_hr_user_type = 'PER' THEN
      begin

        savepoint final_process;
        hr_ex_employee_api.final_process_emp
        (p_period_of_service_id          => l_period_of_service_id
        ,p_object_version_number         => l_pds_object_version_number
        ,p_final_process_date            => g_effective_date
        ,p_org_now_no_manager_warning    => l_org_now_no_manager_warning
        ,p_asg_future_changes_warning    => l_asg_future_changes_warning
        ,p_entries_changed_warning       => l_entries_changed_warning
        );
      EXCEPTION
        WHEN OTHERS THEN
        rollback to final_process;
        raise;
      END;
    END IF;
  END IF;
   --if 352 then need to end date position as well -- Rohini
   -- Bug 2835138 Sundar End date position only for MTO.
    IF (p_pa_request_rec.first_noa_code  = '352') AND (UPPER(SUBSTR(p_pa_request_rec.request_number,1,3)) = 'MTO') THEN
     l_position_data_rec_type.position_id   :=  p_pa_request_rec.from_position_id;
--since in case of a SEPARATION, the to fields are all closed
	-- Bug 3431540 Need to end date only on the next date of separation.
     l_position_data_rec_type.effective_date       :=  g_effective_date + 1;
     l_position_data_rec_type.effective_end_date   :=  g_effective_date + 1;
	 -- End Bug 3431540
     l_position_data_rec_type.datetrack_mode := return_update_mode
                   (p_id                 => p_pa_request_rec.to_position_id,
                    p_effective_date     => p_pa_request_rec.effective_date,
                    p_table_name         => 'HR_ALL_POSITIONS_F'
                   );
     ghr_sf52_pos_update.update_position_info
     (p_pos_data_rec    =>  l_position_data_rec_type);
   END IF; -- If NOA is 352

END IF;


-- Name change  -- The same should cope up with both normal and correction actions
If l_update_person  = 'Y' then
  hr_utility.set_location(l_proc,138);
  l_update_mode := return_update_mode
                   (p_id                 => p_pa_request_rec.person_id,
                    p_effective_date     => p_pa_request_rec.effective_date,
                    p_table_name         => 'PER_PEOPLE_F'
                   );

  hr_person_api.update_person
  (p_effective_date           =>  g_effective_date
  ,p_datetrack_update_mode    =>  l_update_mode
  ,p_person_id                =>  p_pa_request_rec.person_id
  ,p_object_version_number    =>  l_per_object_version_number
  ,p_employee_number          =>  l_per_upd_employee_number
  ,p_last_name                =>  p_pa_request_rec.employee_last_name
  ,p_first_name               =>  p_pa_request_rec.employee_first_name
  ,p_middle_names             =>  p_pa_request_rec.employee_middle_names
  ,p_national_identifier      =>  p_pa_request_rec.employee_national_identifier
  ,p_date_of_birth            =>  p_pa_request_rec.employee_date_of_birth
  ,p_effective_start_date     =>  l_per_upd_effective_start_date
  ,p_effective_end_date       =>  l_per_upd_effective_end_date
  ,p_full_name                =>  l_per_upd_full_name
  ,p_comment_id               =>  l_per_upd_comment_id
  ,p_name_combination_warning =>  l_per_upd_name_comb_warn
  ,p_assign_payroll_warning   =>  l_per_upd_assgn_payroll_warn
  ,p_orig_hire_warning        =>  l_orig_hire_warning
  );

End if;
--

-- Address creation
l_hr_user_type := fnd_profile.value('HR_USER_TYPE');
hr_utility.set_location('in address'||l_hr_user_type,1000);
IF l_hr_user_type = 'INT' THEN
hr_utility.set_location('in per addresses',1000);
If l_create_address = 'Y' or l_update_address = 'Y' then
hr_utility.set_location('in upd addresses',1000);
   for county in county_name loop
      l_county_name := county.county_name;
   end loop;
   If   l_create_address  = 'Y' then
      -- 6919898 End dating the primary and secondary address
      -- only if exists If primary address does not exists just creating the new primary address
      -- to a person
      If l_address_id is not null  then
         hr_utility.set_location(l_proc,145);
        --- End dating all the secondary addresses for existing primary address
         for sec_address in c_sec_address loop

           hr_person_address_api.update_us_person_address
           (p_effective_date              => g_effective_date
           ,p_date_to                     => g_effective_date
	   ,p_address_id                  => sec_address.address_id
	   ,p_object_version_number       => sec_address.object_version_number
	   );
	 end loop;
	   hr_utility.set_location('l_address_id'||l_address_id,1000);
	    -- End dating the existing primary address
	   hr_person_address_api.update_us_person_address
	     (p_effective_date              => g_effective_date
	     ,p_date_to                     => g_effective_date
	     ,p_address_id                  => l_address_id
	     ,p_object_version_number       => l_add_object_version_number
	     );
       End If;	 -- l_address_id is not null
      -- Creating new primary address for forwarding address
      hr_person_address_api.create_us_person_address
     (p_effective_date              => g_effective_date
     ,p_person_id                   => p_pa_request_rec.person_id
     ,p_primary_flag                => 'Y'
     ,p_date_from                   => g_effective_date + 1
     ,p_address_line1               => p_pa_request_rec.forwarding_address_line1
     ,p_address_line2               => p_pa_request_rec.forwarding_address_line2
     ,p_address_line3               => p_pa_request_rec.forwarding_address_line3
     ,p_city                        => p_pa_request_rec.forwarding_town_or_city
     ,p_state                       => p_pa_request_rec.forwarding_region_2
     ,p_county                      => l_county_name
     ,p_zip_code                    => p_pa_request_rec.forwarding_postal_code
     ,p_country                     => p_pa_request_rec.forwarding_country
     ,p_address_id                  => l_per_add_address_id
     ,p_object_version_number       => l_per_add_ovr_number
     );
     --Creating new secondary addresses
     for sec_address in c_sec_address loop
     hr_person_address_api.create_us_person_address
     (p_effective_date              => g_effective_date
     ,p_person_id                   => p_pa_request_rec.person_id
     ,p_primary_flag                => 'N'
     ,p_date_from                   => g_effective_date + 1
     ,p_address_line1               => sec_address.address_line1
     ,p_address_line2               => sec_address.address_line2
     ,p_address_line3               => sec_address.address_line3
     ,p_city                        => sec_address.town_or_city
     ,p_state                       => sec_address.region_2
     ,p_county                      => sec_address.region_1
     ,p_zip_code                    => sec_address.postal_code
     ,p_country                     => sec_address.country
     ,p_address_type                => sec_address.address_type
     ,p_address_id                  => l_per_add_address_id
     ,p_object_version_number       => l_per_add_ovr_number
     );
     end loop;
   End if;

--Update address -- In case of a correction, may be updating some entry in the address

  If l_update_address = 'Y' then
    hr_utility.set_location(l_proc,150);
    hr_person_address_api.update_us_person_address
   (p_address_id                      => l_address_id
   ,p_object_version_number           => l_add_object_version_number
   ,p_effective_date                  => g_effective_date
   ,p_address_line1                   => p_pa_request_rec.forwarding_address_line1
   ,p_address_line2                     => p_pa_request_rec.forwarding_address_line2
   ,p_address_line3                     => p_pa_request_rec.forwarding_address_line3
   ,p_city                              => p_pa_request_rec.forwarding_town_or_city
   ,p_state                             => p_pa_request_rec.forwarding_region_2
   ,p_county                        => l_county_name
   ,p_zip_code                      => p_pa_request_rec.forwarding_postal_code
   ,p_country                       => p_pa_request_rec.forwarding_country
   );
  End if;
End if;
ELSIF l_hr_user_type = 'PER' THEN
If l_create_address = 'Y' or l_update_address = 'Y' then
   for county in county_name loop
          l_county_name := county.county_name;
   end loop;
   If   l_create_address  = 'Y' then
    -- 6919898 End dating the primary and secondary address
      -- only if exists If primary address does not exists just creating the new primary address
      -- to a person
      If l_address_id is not null  then
       hr_utility.set_location(l_proc,145);
       --- End dating all the secondary addresses for existing primary address
       for sec_address in c_sec_address loop
          hr_person_address_api.update_person_address
	  (p_effective_date              => g_effective_date
	  ,p_date_to                     => g_effective_date
	  ,p_address_id                  => sec_address.address_id
	  ,p_object_version_number       => sec_address.object_version_number
	  );
       end loop;
	  -- End dating the existing primary address
	  hr_person_address_api.update_person_address
	  (p_effective_date              => g_effective_date
	  ,p_date_to                     => g_effective_date
	  ,p_address_id                  => l_address_id
	  ,p_object_version_number       => l_add_object_version_number
	  );
      End If;
     -- Creating new primary address for forwarding address
     hr_person_address_api.create_person_address
     (p_effective_date              => g_effective_date
     ,p_person_id                   => p_pa_request_rec.person_id
     ,p_primary_flag                => 'Y'
     ,p_style                       => 'US_GLB_FED'  -- Bug# 4725292
     ,p_date_from                   => g_effective_date + 1
     ,p_address_line1               => p_pa_request_rec.forwarding_address_line1
     ,p_address_line2               => p_pa_request_rec.forwarding_address_line2
     ,p_address_line3               => p_pa_request_rec.forwarding_address_line3
     ,p_town_or_city                => p_pa_request_rec.forwarding_town_or_city
     ,p_region_1                    => l_county_name
     ,p_region_2                    => p_pa_request_rec.forwarding_region_2
     ,p_postal_code                    => p_pa_request_rec.forwarding_postal_code
     ,p_country                     => p_pa_request_rec.forwarding_country
     ,p_address_id                  => l_per_add_address_id
     ,p_object_version_number       => l_per_add_ovr_number
     );
     --Creating new secondary addresses
     for sec_address in c_sec_address loop
     hr_person_address_api.create_person_address
     (p_effective_date              => g_effective_date
     ,p_person_id                   => p_pa_request_rec.person_id
     ,p_primary_flag                => 'N'
     ,p_style                       => 'US_GLB_FED'  -- Bug# 4725292
     ,p_date_from                   => g_effective_date + 1
     ,p_address_line1               => sec_address.address_line1
     ,p_address_line2               => sec_address.address_line2
     ,p_address_line3               => sec_address.address_line3
     ,p_town_or_city                => sec_address.town_or_city
     ,p_region_2                    => sec_address.region_2
     ,p_region_1                    => sec_address.region_1
     ,p_postal_code                 => sec_address.postal_code
     ,p_country                     => sec_address.country
     ,p_address_type                => sec_address.address_type
     ,p_address_id                  => l_per_add_address_id
     ,p_object_version_number       => l_per_add_ovr_number
     );
     end loop;
   End if;

--Update address -- In case of a correction, may be updating some entry in the address

  If l_update_address = 'Y' then
    hr_utility.set_location(l_proc,150);
    hr_person_address_api.update_person_address
   (p_address_id                      => l_address_id
   ,p_object_version_number           => l_add_object_version_number
   ,p_effective_date                  => g_effective_date
   ,p_address_line1                   => p_pa_request_rec.forwarding_address_line1
   ,p_address_line2                   => p_pa_request_rec.forwarding_address_line2
   ,p_address_line3                   => p_pa_request_rec.forwarding_address_line3
   ,p_town_or_city                    => p_pa_request_rec.forwarding_town_or_city
   ,p_region_2                        => p_pa_request_rec.forwarding_region_2
   ,p_region_1                        => l_county_name
   ,p_postal_code                     => p_pa_request_rec.forwarding_postal_code
   ,p_country                         => p_pa_request_rec.forwarding_country
   );
  End if;
End if;
END IF;


-- The foll. is to determine whether or not there are changes in either -- SSN / DOB /NAMES of
-- the employee , while doing a CORRECTION action only.

If l_session.noa_id_correct is not null then
  for per in per_ovn loop
    l_business_group_id            :=  per.business_group_id;
    l_per_object_version_number    :=  per.object_version_number;
    l_per_upd_employee_number      :=  per.employee_number;
    l_per_national_identifier      :=  per.national_identifier;
    l_per_first_name               :=  per.first_name;
    l_per_last_name                :=  per.last_name;
    l_per_middle_names             :=  per.middle_names;
    l_per_date_of_birth            :=  per.date_of_birth;
  end loop;
  hr_utility.set_location(l_proc,138);

  if  nvl(p_pa_request_rec.employee_national_identifier,hr_api.g_varchar2) <>  nvl(l_per_national_identifier,hr_api.g_varchar2) or
      nvl(p_pa_request_rec.employee_date_of_birth,hr_api.g_date)           <> nvl(l_per_date_of_birth,hr_api.g_date) or
      nvl(p_pa_request_rec.employee_last_name,hr_api.g_varchar2)           <> nvl(l_per_last_name,hr_api.g_varchar2) or
        nvl(p_pa_request_rec.employee_first_name,hr_api.g_varchar2)          <> nvl(l_per_first_name,hr_api.g_varchar2)or
      nvl(p_pa_request_rec.employee_middle_names,hr_api.g_varchar2)        <> nvl(l_per_middle_names,hr_api.g_varchar2) then

    l_update_mode := return_update_mode
                   (p_id                 => p_pa_request_rec.person_id,
                    p_effective_date     => p_pa_request_rec.effective_date,
                    p_table_name         => 'PER_PEOPLE_F'
                   );

    hr_person_api.update_person
    (p_effective_date           =>  g_effective_date
    ,p_datetrack_update_mode    =>  l_update_mode
    ,p_person_id                =>  p_pa_request_rec.person_id
    ,p_object_version_number    =>  l_per_object_version_number
    ,p_employee_number          =>  l_per_upd_employee_number
    ,p_last_name                =>  p_pa_request_rec.employee_last_name
    ,p_first_name               =>  p_pa_request_rec.employee_first_name
    ,p_middle_names             =>  p_pa_request_rec.employee_middle_names
    ,p_national_identifier      =>  p_pa_request_rec.employee_national_identifier
    ,p_date_of_birth            =>  p_pa_request_rec.employee_date_of_birth
    ,p_effective_start_date     =>  l_per_upd_effective_start_date
    ,p_effective_end_date       =>  l_per_upd_effective_end_date
    ,p_full_name                =>  l_per_upd_full_name
    ,p_comment_id               =>  l_per_upd_comment_id
    ,p_name_combination_warning =>  l_per_upd_name_comb_warn
    ,p_assign_payroll_warning   =>  l_per_upd_assgn_payroll_warn
    ,p_orig_hire_warning        =>  l_orig_hire_warning
    );

  End if;
End if;

--
/* -- Not supported for the September Release
If l_noa_family_code = 'POS_ABOLISH' then
  for pos_ovn in c_pos_ovn loop
     l_pos_object_version_number :=  pos_ovn.object_version_number;
  end loop;
  hr_position_api.update_position
 (p_position_id                  => p_pa_request_rec.from_position_id,
  p_date_end                     => p_pa_request_rec.effective_date,
  p_object_version_number        => l_pos_object_version_number,
  p_position_definition_id       => l_pos_definition_id,
  p_name                         => l_name,
  p_valid_grades_changed_warning => l_val_grd_chg_wng
 );
End if;
*/

----
-- JH Adding update to Position's Location bug 773795
-- This update is irrespective of family and is based on to_position being not null
-- and the To Position process method
-- Bug 2462929 For change in DS we must consider DS process method, if APUE/UE update Position.
----
hr_utility.set_location('Update Positions Location  ' || l_proc,151);
IF p_pa_request_rec.to_position_id IS NOT NULL THEN

  l_form_field_name := 'TO_POSITION_TITLE';
  FOR pm_rec in get_to_posn_title_pm LOOP
    l_posn_title_pm := pm_rec.process_method_code;
  END Loop;

  l_form_field_name := 'DUTY_STATION_CODE';
  FOR pm_rec in get_to_posn_title_pm LOOP
    l_DS_pm := pm_rec.process_method_code;
  END Loop;

  hr_utility.set_location('To Posn PM ' || l_posn_title_pm ,151);
  IF l_posn_title_pm = 'UE' OR
     (l_posn_title_pm = 'APUE' AND
                       nvl(p_pa_request_rec.to_position_id,hr_api.g_number) <> nvl(p_pa_request_rec.from_position_id,hr_api.g_number)) OR
     l_DS_pm in ('APUE','UE') OR
     (p_pa_request_rec.effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND p_pa_request_rec.first_noa_code = '894') THEN
    ghr_sf52_pos_update.update_positions_location(
      p_position_id    => p_pa_request_rec.to_position_id,
      p_location_id    => p_pa_request_rec.duty_station_location_id,
      p_effective_date => p_pa_request_rec.effective_date);
  END IF;
END IF;
----

hr_utility.set_location('Leaving  ' || l_proc,155);
Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_pa_request_rec := l_pa_request_rec;
          raise;

End Process_Family;
--

--  ********************************
--  procedure  Process_Salary_Info
--  ********************************
--
Procedure Process_salary_Info
(p_pa_request_rec         in      ghr_pa_requests%rowtype
 ,p_wgi             in out nocopy  ghr_api.within_grade_increase_type
,p_retention_allow_review         in out nocopy ghr_api.retention_allow_review_type
 ,p_capped_other_pay      in number default null
) is

l_proc                        varchar2(70)  := 'Process_salary_info';
l_noa_family_code             ghr_families.noa_family_code%type;
l_adj_basic_pay_warn            boolean;
l_element_entry_id            number;
l_basic_pay_warn              boolean;
l_locality_adj_warn           boolean;
l_total_salary_warn           Boolean;
l_within_grade_increase_warn  boolean;
l_wgi_due_date                date;
l_wgi_pay_date                date;
l_lei_date                    varchar2(60);                 -- Bug 3111719
v_payroll_id                  number;
v_asg_effective_start_date    date;
v_asg_effective_end_date      date;
l_retained_grade_rec          ghr_pay_calc.retained_grade_rec_type;
l_ret_grade_rec               ghr_pay_calc.retained_grade_rec_type;
l_new_date_to                 per_people_extra_info.pei_information1%type;
l_new_grade_or_level          per_people_extra_info.pei_information3%type;
l_new_pay_plan                per_people_extra_info.pei_information3%type;
l_new_pay_table               per_people_extra_info.pei_information3%type;
l_new_loc_percent             per_people_extra_info.pei_information3%type;
l_new_pay_basis               per_people_extra_info.pei_information3%type;
l_new_step_or_rate            per_people_extra_info.pei_information4%type;
l_cur_step_or_rate            per_people_extra_info.pei_information4%type;
l_new_temp_step               per_people_extra_info.pei_information9%type;
l_ret_object_version_number   ghr_pa_requests.object_version_number%type;
l_effective_date              date;
l_session                   ghr_history_api.g_session_var_type;
l_value               varchar2(30);
l_multiple_error_flag boolean;
l_entitled_other_pay         number;



-- Cursor declarations

Cursor     c_ele_entry(ele_name varchar2,
                       ipv_name varchar2,
                       eff_date date,
                       bg_id   number
                      ) is
   select  eev.screen_entry_value screen_entry_value,
           ele.element_entry_id
   from    pay_element_types_f elt,
           pay_input_values_f ipv,
           pay_element_entries_f ele,
           pay_element_entry_values_f eev
   where   trunc(eff_date)
   between elt.effective_start_date  and     elt.effective_end_date
   and     trunc(eff_date)
   between ipv.effective_start_date  and ipv.effective_end_date
   and     trunc(eff_date)
   between ele.effective_start_date  and ele.effective_end_date
   and     trunc(eff_date)
   between eev.effective_start_date  and eev.effective_end_date
   and     elt.element_type_id       = ipv.element_type_id
   and     upper(elt.element_name)   = upper(ele_name)
   and     ipv.input_value_id        = eev.input_value_id
   and     ele.assignment_id         = p_pa_request_rec.employee_assignment_id
   and     ele.element_entry_id + 0  = eev.element_entry_id
   and     upper(ipv.name)           = upper( ipv_name)
--   and     NVL(elt.business_group_id,0)     = NVL(ipv.business_group_id,0)    -- modified by Ashley
   and    (elt.business_group_id is null or elt.business_group_id = bg_id);


 Cursor c_retained_grade_ovn  is
   select object_version_number,
          pei_information2,
          pei_information3,
          pei_information4,
          pei_information5,
          pei_information6,
          pei_information7,
          pei_information8,
          pei_information9
   from   per_people_extra_info
   where  person_extra_info_id = l_retained_grade_rec.person_extra_info_id;

l_wgi                      ghr_api.within_grade_increase_type;
l_retention_allow_review   ghr_api.retention_allow_review_type;


CURSOR cur_temp_step
IS
SELECT  rei_information3 temp_step
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_rec.pa_request_id
AND     information_type = 'GHR_US_PAR_RG_TEMP_PROMO';

-- Start of code for Payroll Integration
-- Payroll Integration
Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;

Cursor Cur_Sal_Basis_name(p_bg_id NUMBER,p_ele_name VARCHAR2)
 IS
Select pb.pay_basis_id
From pay_element_types_f ele,
     pay_input_values_f inp,
     per_pay_bases pb
where ele.business_group_id=p_bg_id
and upper(element_name)=upper(p_ele_name)
and ele.business_group_id=inp.business_group_id
and ele.element_type_id=inp.element_type_id
and inp.input_value_id=pb.input_value_id;

Cursor Cur_asg_det_for_SB_upd(p_asg_id NUMBER,
                                p_eff_date DATE)
is
select object_version_number   ovn,
         people_group_id         ppl_grp_id,
         special_ceiling_step_id spcl_clng_stp_id,
         soft_coding_keyflex_id  scl_kff_id,
         effective_start_date    start_date,
         effective_end_date      end_date,
         payroll_id
from  per_assignments_f
where assignment_id=p_asg_id
-- and  position_id = p_pa_request_rec.to_position_id
and  p_eff_date
     between effective_start_date and effective_end_date;

l_SB_ovn                      per_assignments_f.object_version_number%type;
l_ppl_grp_id               per_assignments_f.people_group_id%type;
l_spcl_clng_stp_id         per_assignments_f.special_ceiling_step_id%type;
l_scl_kff_id               per_assignments_f.soft_coding_keyflex_id%type;
l_eff_start_date           per_assignments_f.effective_start_date%type;
l_eff_end_date             per_assignments_f.effective_end_date%type;
l_payroll_id               per_assignments_f.payroll_id%type;
l_group_name               pay_people_groups.group_name%type;
l_org_now_man_warn         boolean;
l_other_manager_warn       boolean;
l_spp_delete_warning       boolean;
l_entries_chan_warn        varchar2(10);
l_tax_dist_chan_warn       boolean;

-- sal admin fields
l_pay_proposal_id number;
l_sal_admin_ovn number;
l_ele_entry_id number;
l_payroll_warn boolean;
l_approve_warn  boolean;
l_sal_warn  boolean;
l_date_warn  boolean;

l_bg_id                    NUMBER;
l_sal_basis                VARCHAR2(80);
l_sal_basis_type           VARCHAR2(80);
l_sal_basis_id             NUMBER;
l_basic_sal_rate           VARCHAR2(80);
l_inp_val_id               VARCHAR2(80);
l_pay_basis                VARCHAR2(80);
-- to map pay basis to sal basis

l_new_element_name         VARCHAR2(80);
l_eff_Date                 DATE;

Cursor Cur_proposal_exists (p_assignment_id IN NUMBER,
                            p_eff_date IN DATE) is
Select ppp.pay_proposal_id       proposal_id,
       ppp.object_version_number ovn
from   per_pay_proposals ppp
where  ppp.assignment_id = p_assignment_id
and    change_date       = p_eff_date;

l_proposal_id          NUMBER;
l_pay_intg             BOOLEAN:=FALSE;

ll_element_link_id        pay_element_links_f.element_link_id%type;
ll_input_value_id         pay_input_values_f.input_value_id%type;
ll_element_entry_id       pay_element_entries_f.element_entry_id%type;
ll_value                  pay_element_entry_values_f.screen_entry_value%type;
ll_object_version_number  pay_element_entries_f.object_version_number%type;
ll_multiple_error_flag    varchar2(50);
l_error_text              varchar2(4000);
l_dt_mode                 varchar2(200);

cursor cur_ex_emp (p_person_id IN Number, p_effective_date IN Date)  is
select 1
from  per_person_types pet,
      per_people_f     per
where pet.person_type_id = per.person_type_id
and   per.person_id      = p_person_id
and   p_effective_date
      between per.effective_start_date and per.effective_end_date
and   pet.system_person_type = 'EX_EMP';

l_asg_del_ovn                  NUMBER;
l_org_now_no_manager_warning   BOOLEAN;
l_validation_start_date        DATE;
l_validation_end_date          DATE;
l_effective_start_date         DATE;
l_effective_end_date           DATE;
l_payroll_value                NUMBER;
l_fam_code                     VARCHAR2(80);
ll_payroll_value               NUMBER;
l_del_pay_prop                 BOOLEAN:=FALSE;
l_ex_emp                       BOOLEAN := FALSE;
l_ovn   NUMBER;
--
-- Payroll Integration
-- End of variable declaration for Payroll Integration
--

-- No need for this cursor
-- The values are properly passed
-- Bug 3263140
CURSOR cur_wgi_due
IS
SELECT  rei_information4 wgi_due
FROM    ghr_pa_request_extra_info
WHERE   pa_request_id = p_pa_request_rec.pa_request_id
AND     information_type = 'GHR_US_PAR_SALARY_CHG';
--
-- Bug 3953455 Cursor to fetch the To step for both normal and correction actions.
CURSOR cur_get_step(c_pa_request_id ghr_pa_requests.pa_request_id%type)
IS
SELECT par_orig.from_step_or_rate step1, par_corr.from_step_or_rate step2
FROM ghr_pa_requests par_orig , ghr_pa_requests par_corr
where par_orig.pa_request_id = par_corr.altered_pa_request_id
and par_corr.pa_request_id = c_pa_request_id;

l_orig_pa_from_step ghr_pa_requests.to_step_or_rate%type;
l_corr_pa_from_step ghr_pa_requests.to_step_or_rate%type;
l_call_wgi_dates BOOLEAN;

-- End Bug 3953455

-- -- Bug 4031919 Cursor to check if pay plan is eligible for WGI or not.
l_is_wgi_eligible BOOLEAN;
l_wgi_cleared BOOLEAN;
l_to_pay_plan ghr_pa_requests.to_pay_plan%type;
l_wgi_exists BOOLEAN;
l_wgi_new_name VARCHAR2(250);

CURSOR c_wgi_pay_plan(c_pay_plan ghr_pa_requests.to_pay_plan%TYPE)  IS
  SELECT 1
  FROM   ghr_pay_plans gpp
  WHERE  gpp.pay_plan         =  c_pay_plan
  AND    gpp.wgi_enabled_flag = 'Y';

CURSOR c_get_pay_plan(c_pa_request_id ghr_pa_requests.pa_request_id%type) IS
SELECT to_pay_plan
FROM ghr_pa_requests par
WHERE par.pa_request_id = c_pa_request_id;

-----GPPA Update46 Start.
cursor cur_eq_ppl (c_pay_plan ghr_pay_plans.pay_plan%type)
IS
select EQUIVALENT_PAY_PLAN
from ghr_pay_plans
where pay_plan = c_pay_plan;

l_equ_pay_plan ghr_pay_plans.equivalent_pay_plaN%type;
-----GPPA Update46 End.

CURSOR c_check_ele(c_element_name pay_element_types_f.element_name%type,
		   c_effective_date pay_element_entries_f.effective_start_date%type,
		   c_assignment_id pay_element_entries_f.assignment_id%type) IS
SELECT 1
FROM pay_element_entries_f pee, pay_element_types_f pet
WHERE pee.element_type_id = pet.element_type_id
AND c_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
AND c_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
AND pet.element_name = c_element_name
AND pee.assignment_id = c_assignment_id;

--Pradeep start of Bug 3306515
l_retention_allow_percentage    ghr_pa_requests.to_retention_allow_percentage%type;
l_retention_allowance           ghr_pa_requests.to_retention_allowance%type;
l_multi_error_flag              boolean;
--Pradeep end of Bug 3306515

Begin


    --
    hr_utility.set_location('Entering  ' ||l_proc,5);
    -- Remember IN OUT parameter IN values
    --
    l_wgi                      := p_wgi;
    l_retention_allow_review   := p_retention_allow_review;
    l_call_wgi_dates := FALSE;
    l_is_wgi_eligible := FALSE; -- Bug 4031919
    l_wgi_cleared := FALSE;-- Bug 4031919
    l_wgi_exists := FALSE;-- Bug 4031919

     --Pradeep start of Bug 3306515
     -- Get the session variables.
     ghr_history_api.get_g_session_var(l_session);
     --Pradeep end of Bug 3306515

--
-- Processing  Basic pay
--
-- Code added/ Modified for Payroll Integration
--
----**********************************************************************
--           CHECK # :- Existence of PAYROLL Product
----**********************************************************************
IF (hr_utility.chk_product_install('GHR','US')  = TRUE
 and hr_utility.chk_product_install('PAY', 'US') = TRUE
 and fnd_profile.value('HR_USER_TYPE')='INT')
THEN
l_pay_intg:=TRUE;
ELSE
l_pay_intg:=FALSE;
END IF;
----**********************************************************************
--
   If p_pa_request_rec.first_noa_code = '866' then
     l_effective_date  :=   trunc(p_pa_request_rec.effective_date + 1 );
   Else
     l_effective_date  :=   trunc(p_pa_request_rec.effective_date);
   End if;
-------Bug 5913362 -- Adding 890
/**** Here for 890 date is not like 866.
   if p_pa_request_rec.first_noa_code = '890' AND
      p_pa_request_rec.input_pay_rate_determinant in ('A','B','E','F','U','V') then
     l_effective_date  :=   trunc(p_pa_request_rec.effective_date + 1 );
   Else
     l_effective_date  :=   trunc(p_pa_request_rec.effective_date);
   End if;
*****/
   --
   -----Find out the Person system person type
   --

   FOR cur_ex_emp_rec IN cur_ex_emp (p_pa_request_rec.person_id, l_effective_date)
   LOOP
     l_ex_emp := TRUE;
     hr_utility.set_location('Person is an Ex employee for the given date  ' ||l_proc,5);
    END LOOP;

  hr_utility.set_location(to_char(l_effective_date),1);
-- Processing  Basic pay
--
  hr_utility.set_location('Entering  ' ||l_proc,5);

-- pick business group id
          For BG_rec in Cur_BG(p_pa_request_rec.employee_assignment_id,
                                 l_effective_date)
          Loop
          l_bg_id:=BG_rec.bg;
          End Loop;
--
-- When to_basic_pay is not null
  If p_pa_request_rec.to_basic_pay  is not null then
      hr_utility.set_location(l_proc || to_char(p_pa_request_rec.effective_date),10);
--
-- Code added for Payroll Integration
--
   IF l_pay_intg
   -- Only when GHR and Payroll are installed can the following be performed
   THEN
    -- Salary Basis Type can be Monthly,Annual,Hourly
        If (p_pa_request_rec.from_pay_basis is NULL and
               p_pa_request_rec.to_pay_basis is not NULL) then
           l_pay_basis:=p_pa_request_rec.to_pay_basis;
         elsif (p_pa_request_rec.from_pay_basis is NOT NULL and
             p_pa_request_rec.to_pay_basis is NULL) then
           l_pay_basis:=p_pa_request_rec.from_pay_basis;
         elsif (p_pa_request_rec.from_pay_basis is NOT NULL and
              p_pa_request_rec.to_pay_basis is NOT NULL) then
           l_pay_basis:=p_pa_request_rec.to_pay_basis;
         End If;

       -- Picking the new Basic Salary Rate Element
          l_new_element_name:=pqp_fedhr_uspay_int_utils.return_new_element_name(
                            p_fedhr_element_name => 'Basic Salary Rate',
                            p_business_group_id  => l_bg_id,
                            p_effective_date     => l_effective_date,
                            p_pay_basis          => NVL(l_pay_basis,'PA'));

           hr_utility.trace('The New Element Name is :'||l_new_element_name);

           --
        -- Update the Assignment id with the Salary Basis Obtained in above step
        -- If not for this step Salary Admin form wont pick the Basic Sal Value
        --
         hr_utility.trace('NOA FAMILY CODE :'||p_pa_request_rec.noa_family_code);
         -- Check# 1
         IF (p_pa_request_rec.first_noa_cancel_or_correct ='CORRECT') THEN

           -- Check# 2
           -- the following if condition is to avoid error of deleting salary proposal
           -- for correction actions not involving pay changes. Ex - realignment, Other pay etc
           IF ( nvl(p_pa_request_rec.to_basic_pay,0) <> nvl(p_pa_request_rec.from_basic_pay,0)
             OR nvl(p_pa_request_rec.from_pay_basis,'NPB') <> nvl(p_pa_request_rec.to_pay_basis,'NPB'))
           THEN

              For Proposal_rec IN Cur_proposal_exists
               (p_pa_request_rec.employee_assignment_id,l_effective_date)
              Loop
                l_pay_proposal_id   := proposal_rec.proposal_id;
                l_sal_admin_ovn     := proposal_rec.ovn;
              End Loop;

              hr_utility.trace('Before call to Delete Salary Proposal :'||l_dt_mode);
--            if p_pa_request_rec.noa_family_code in ('APP','CONV_APP') then
              -- Check# 3
              IF (l_pay_proposal_id is not null ) THEN

                hr_maintain_proposal_api.delete_salary_proposal
                  (
                  p_pay_proposal_id      => l_pay_proposal_id ,
                  p_business_group_id    => l_bg_id             ,
                  p_object_version_number => l_sal_admin_ovn            ,
                  p_validate              => FALSE            ,
                  p_salary_warning        => l_sal_warn
                  );
                l_del_pay_prop :=TRUE;
              END IF;
             -- End of Check# 3
           END IF;
           -- End of Check# 2
         END IF;
         -- End of Check# 1

           -- Picking the Salary Basis based on the to_pay_basis during RPA
          For Sal_Basis_Name in Cur_Sal_Basis_name(l_bg_id,l_new_element_name)
          Loop
          l_sal_basis_id := Sal_Basis_Name.pay_basis_id;
          hr_utility.trace('The sal basis id is :'||to_char(l_sal_basis_id));
          End Loop;
         --
         --
         l_dt_mode := return_update_mode
                   (p_id                 => p_pa_request_rec.employee_assignment_id,
                    p_effective_date     => l_effective_date,
                    p_table_name         => 'PER_ASSIGNMENTS_F'
                   );

          hr_utility.trace('l_dt_mode is :'||l_dt_mode);

         -- collecting details for salary basis updation
         For SB_upd in Cur_asg_det_for_SB_upd(p_pa_request_rec.employee_assignment_id,
                                              l_effective_Date)
         Loop
         l_SB_ovn           := SB_upd.ovn;
         l_ppl_grp_id       := SB_upd.ppl_grp_id;
         l_spcl_clng_stp_id := SB_upd.spcl_clng_stp_id;
         l_scl_kff_id       := SB_upd.scl_kff_id;
         l_eff_start_date   := SB_upd.start_date;
         l_eff_end_date     := SB_upd.end_date;
         l_payroll_id       := SB_upd.payroll_id;
         End Loop;

        --
        -- Update the Assignment id with the Salary Basis Obtained in above step
        -- If not for this step Salary Admin form wont pick the Basic Sal Value
        hr_utility.trace('assignment id is :'||p_pa_request_rec.employee_assignment_id);
        hr_utility.trace('EFF DATE :'||l_effective_date);
        hr_utility.trace('l_sb_ovn:'||l_SB_ovn);
        hr_utility.trace('l_payroll_id:'||l_payroll_id);
        hr_utility.trace('l_sal_basis_id:'||l_sal_basis_id);

        hr_assignment_api.update_emp_asg_criteria
          (p_effective_date               => l_effective_date
          ,p_datetrack_update_mode        => l_dt_mode
          ,p_assignment_id                => p_pa_request_rec.employee_assignment_id
          ,p_object_version_number        => l_SB_ovn
          ,P_PAYROLL_ID                   => l_payroll_id
          ,p_pay_basis_id                 => l_sal_basis_id
          ,p_position_id                  => P_pa_request_rec.to_position_id
          ,p_job_id                       => P_pa_request_rec.to_job_id
          ,p_location_id                  => P_pa_request_rec.duty_station_location_id
          ,p_organization_id              => P_pa_request_rec.to_organization_id
          ,p_grade_id                     => P_pa_request_rec.to_grade_id
          ,p_effective_start_date         => l_eff_start_date
          ,p_effective_end_date           => l_eff_end_date
          ,p_special_ceiling_step_id      => l_spcl_clng_stp_id
          ,p_people_group_id              => l_ppl_grp_id
          ,p_group_name                   => l_group_name
          ,p_org_now_no_manager_warning   => l_org_now_man_warn
          ,p_other_manager_warning        => l_other_manager_warn
          ,p_spp_delete_warning           => l_spp_delete_warning
          ,p_entries_changed_warning      => l_entries_chan_warn
          ,p_tax_district_changed_warning => l_tax_dist_chan_warn
           );
          --
       hr_utility.trace('After Update Person record under gh52doup.pkb');
       --

      -- Blocking the call to use Core call for salary admin creation
        For Proposal_rec IN Cur_proposal_exists
             (p_pa_request_rec.employee_assignment_id,l_effective_date)
        Loop
        l_pay_proposal_id   := proposal_rec.proposal_id;
        l_sal_admin_ovn     := proposal_rec.ovn;
        End Loop;


         if ((p_pa_request_rec.noa_family_code <> 'APP')
           OR
          (p_pa_request_rec.noa_family_code = 'CONV_APP' and NOT l_ex_emp)) then
           ghr_element_api.retrieve_element_info
          (p_element_name          => 'Basic Salary Rate'
          ,p_input_value_name      => 'Rate'
          ,p_assignment_id         => p_pa_request_rec.employee_assignment_id
          ,p_effective_date        => l_effective_date
          ,p_processing_type       => 'R'
          ,p_element_link_id       => ll_element_link_id
          ,p_input_value_id        => ll_input_value_id
          ,p_element_entry_id      => ll_element_entry_id
          ,p_value                 => ll_value
          ,p_object_version_number => ll_object_version_number
          ,p_multiple_error_flag   => ll_multiple_error_flag
          );
        end if;

        hr_utility.trace('employee Asg id  before proposal ..:'||
                                    to_char(p_pa_request_rec.employee_assignment_id));
        hr_utility.trace('Element entry id before proposal ..:'||to_char(ll_element_entry_id));
        hr_utility.trace('Business grp  id before proposal ..:'||to_char(l_bg_id));

     IF l_pay_proposal_id is null then
        if (nvl(p_pa_request_rec.from_basic_pay, 0) <> nvl(p_pa_request_rec.to_basic_pay,0)) then
        hr_maintain_proposal_api.insert_salary_proposal
        (
         p_pay_proposal_id           => l_pay_proposal_id
        ,p_assignment_id             => p_pa_request_rec.employee_assignment_id
        ,p_business_group_id         => l_bg_id
        ,p_change_date               => l_effective_date
        ,p_proposed_salary_n         => p_pa_request_rec.to_basic_pay
        ,p_object_version_number     => l_sal_admin_ovn
        ,p_element_entry_id          => ll_element_entry_id
        ,p_inv_next_sal_date_warning => l_date_warn
        ,p_proposed_salary_warning   => l_sal_warn
        ,p_approved_warning          => l_approve_warn
        ,p_payroll_warning           => l_payroll_warn
        ,p_multiple_components       => 'N'
        ,p_approved                  => 'Y'
        );
        end if;
     ELSE
        if (nvl(p_pa_request_rec.from_basic_pay, 0) <> nvl(p_pa_request_rec.to_basic_pay,0)) then
        -- if the pay proposal is not deleted in the above step then delete, no otherwise
          if (not l_del_pay_prop) then
            hr_maintain_proposal_api.delete_salary_proposal(
                                 p_pay_proposal_id       =>  l_pay_proposal_id
                                ,p_business_group_id     =>  l_bg_id
                                ,p_object_version_number =>  l_sal_admin_ovn
                                ,p_validate              =>  FALSE
                                ,p_salary_warning        =>  l_sal_warn);
           end if;
        hr_maintain_proposal_api.insert_salary_proposal
        (
         p_pay_proposal_id           => l_pay_proposal_id
        ,p_assignment_id             => p_pa_request_rec.employee_assignment_id
        ,p_business_group_id         => l_bg_id
        ,p_change_date               => l_effective_date
        ,p_proposed_salary_n         => p_pa_request_rec.to_basic_pay
        ,p_object_version_number     => l_sal_admin_ovn
        ,p_element_entry_id          => ll_element_entry_id
        ,p_inv_next_sal_date_warning => l_date_warn
        ,p_proposed_salary_warning   => l_sal_warn
        ,p_approved_warning          => l_approve_warn
        ,p_payroll_warning           => l_payroll_warn
        ,p_multiple_components       => 'N'
        ,p_approved                  => 'Y'
        );

       end if;

      END IF;
   -- if Payroll is not installed
   ELSIF NOT l_pay_intg
   THEN
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>      'Basic Salary Rate'
        ,p_input_value_name1    =>      'Rate'
        ,p_value1               =>      to_char(p_pa_request_rec.to_basic_pay)
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>      l_adj_basic_pay_warn
      );
   END IF;
  -- if Payroll integration not being used.
--
-- Code added/ Modified for Payroll Integration
--

  /* To be included after Martin Reid's element api handles the create and update warning
   if l_adj_basic_pay_warn = FALSE then
      hr_utility.set_message(8301,'GHR_38136_FAIL_TO_UPD_SALARY');
      hr_utility.raise_error;
   end if;
   */
 end if;
--
--
-- Processing  Adjusted basic pay
--
If p_pa_request_rec.to_adj_basic_pay  is not null then
    hr_utility.set_location(l_proc,20);

    ghr_element_api.process_sf52_element
        (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>      'Adjusted Basic Pay'
        ,p_input_value_name1    =>      'Amount'
        ,p_value1               =>      to_char(p_pa_request_rec.to_adj_basic_pay)
        ,p_effective_date       =>      l_effective_date
        ,p_process_warning      =>      l_basic_pay_warn
      );
--
--

/*if l_adj_basic_pay_warn = FALSE then
     hr_utility.set_message(8301,'GHR_38137_FL_TO_UPD_ADJ_BS_PY');
     hr_utility.raise_error;
   end if;
*/
end if;
--
-- Bug 2333719 GM IT pay calculations. Pay calc will set a global variable for
--             Unadjusted Basic Pay.
--
-- Processing  Unadjusted Basic Pay
--
If p_pa_request_rec.to_adj_basic_pay  is not null then
   if ghr_pay_calc.g_gm_unadjd_basic_pay is not null and ghr_pay_calc.g_gm_unadjd_basic_pay <> 0 then
    hr_utility.set_location(l_proc,21);

    ghr_element_api.process_sf52_element
        (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>      'Unadjusted Basic Pay'
        ,p_input_value_name1    =>      'Amount'
        ,p_value1               =>      to_char(ghr_pay_calc.g_gm_unadjd_basic_pay)
        ,p_effective_date       =>      l_effective_date
        ,p_process_warning      =>      l_basic_pay_warn
      );
   end if;
--
--
end if;
--
-- Bug 2333719 GM IT Code End.
--
-- Processing  Locality adjustment
--
If p_pa_request_rec.to_locality_adj is not null then
   hr_utility.set_location(l_proc,30);
   -- FWFA Changes Bug#4444609: Modify 'Locality Pay' to 'Locality Pay or SR Supplement'
   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'Locality Pay or SR Supplement'
   ,p_input_value_name1 =>      'Rate'
-- 'Rate' was put by Ashu Gupta in place of 'Amount'
   ,p_value1          =>        to_char(p_pa_request_rec.to_locality_adj)
   ,p_effective_date    =>      l_effective_date
   ,p_process_warning   =>      l_locality_adj_warn
    );
    -- FWFA Changes
End if;

--

/*if l_locality_adj_warn  = FALSE then
    hr_utility.set_message(8301,'GHR_38138_FAIL_TO_UPD_LOC_ADJ');
    hr_utility.raise_error;
  end if;
*/
--end if;
--

--
-- Processing  Total Salary
--
If p_pa_request_rec.to_total_salary is not null then
   -- Bug#4486823 RRR Changes. Added the IF Condition to Restrict the element updation
   -- for GHR_INCENTIVE Family.
   IF p_pa_request_rec.first_noa_code IN ('815','816','825','827') OR
      p_pa_request_rec.second_noa_code IN ('815','816','825','827')  THEN
      NULL;
   ELSE
     hr_utility.set_location(l_proc,45);
    ghr_element_api.process_sf52_element
    (p_assignment_id     =>     p_pa_request_rec.employee_assignment_id
    ,p_element_name      =>   'Total Pay'
    ,p_input_value_name1 =>     'Amount'
    ,p_value1            =>     to_char(p_pa_request_rec.to_total_salary)
    ,p_effective_date    =>     l_effective_date
    ,p_process_warning   =>     l_total_salary_warn
    );
   END IF;
 --
/*  if l_total_salary_warn = FALSE then
    hr_utility.set_message(8301,'GHR_38139_FAIL_TO_UPD_TOT_SAL');
    hr_utility.raise_error;
  end if;
*/
end if;
--
--  Processing Other Pay

--If p_pa_request_rec.noa_family_code  = 'OTHER_PAY' then

  If p_pa_request_rec.to_other_pay_amount  is not null then
    -- Code to calculate Entitled Other Pay for Pay capped actions
    l_entitled_other_pay := p_pa_request_rec.to_other_pay_amount;
    IF p_capped_other_pay is not null THEN
                l_entitled_other_pay := nvl(p_pa_request_rec.to_au_overtime, 0) +
                        nvl(p_pa_request_rec.to_availability_pay        , 0) +
                        nvl(p_pa_request_rec.to_retention_allowance     , 0) +
                        nvl(p_pa_request_rec.to_supervisory_differential, 0) +
                        nvl(p_pa_request_rec.to_staffing_differential   , 0);
    END IF;
    hr_utility.set_location(l_proc,55);
    ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'Other Pay'
   ,p_input_value_name1 =>      'Amount'
   ,p_value1          =>        to_char(l_entitled_other_pay)
   ,p_input_value_name2 =>      'Capped Other Pay'
   ,p_value2          =>        to_char(p_capped_other_pay)
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
    );
  Else  --if p_pa_request_rec.other_pay_amount is null
     -- According to John, any other pay and its sub elements can be nullified only by processing an 'OTHER_PAY' action
    If p_pa_request_rec.noa_family_code = 'OTHER_PAY' then
      hr_utility.set_location(l_proc,32);

      l_new_element_name := pqp_fedhr_uspay_int_utils.return_new_element_name(
                  p_fedhr_element_name => 'Other Pay',
                  p_business_group_id  => l_bg_id,
                  p_effective_date     => p_pa_request_rec.effective_date,
                  p_pay_basis          => NULL);

      l_element_entry_id := NULL;
      for ele_entry in  c_ele_entry(ele_name      => l_new_element_name,
                                    ipv_name      => 'Amount',
                                    eff_date      =>  l_effective_date,
                                    bg_id         =>  l_bg_id
                                    ) loop

        l_element_entry_id := ele_entry.element_entry_id;
      End loop;
      If l_element_entry_id is not null then
        ghr_element_api.process_sf52_element
       (p_assignment_id         =>      p_pa_request_rec.employee_assignment_id
       ,p_element_name        =>        'Other Pay'
       ,p_input_value_name1     =>      'Amount'
       ,p_value1                    =>  to_char(p_pa_request_rec.to_other_pay_amount)
       ,p_effective_date        =>    l_effective_date
       ,p_process_warning       =>      l_adj_basic_pay_warn
       );
      End if;
    End if;
  End if;


--  Processing  AUO

 If p_pa_request_rec.to_auo_premium_pay_indicator  is not null or
    p_pa_request_rec.to_au_overtime               is not null  then
   hr_utility.set_location(l_proc,60);
   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'AUO'
   ,p_input_value_name1 =>      'Premium Pay Ind'
   ,p_value1          =>    p_pa_request_rec.to_auo_premium_pay_indicator
   ,p_input_value_name2 =>    'Amount'
   ,p_value2            =>    to_char(p_pa_request_rec.to_au_overtime)
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
   );

   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>     'Premium Pay'
   ,p_input_value_name1 =>      'Premium Pay Ind'
   ,p_value1          =>    p_pa_request_rec.to_auo_premium_pay_indicator
   ,p_input_value_name2 =>    'Amount'
   ,p_value2            =>    to_char(p_pa_request_rec.to_au_overtime)
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
   );
 Else  --if p_pa_request_rec.auo is null

   If p_pa_request_rec.first_noa_code = '818' then
     hr_utility.set_location(l_proc,32);
     l_element_entry_id := NULL;

     l_new_element_name :=
         pqp_fedhr_uspay_int_utils.return_new_element_name(
                    p_fedhr_element_name => 'AUO',
                    p_business_group_id  => l_bg_id,
                    p_effective_date     => p_pa_request_rec.effective_date,
                    p_pay_basis          => NULL);

     for ele_entry in  c_ele_entry(ele_name      => l_new_element_name,
                                   ipv_name      => 'Amount',
                                   eff_date      =>  l_effective_date,
                                   bg_id         =>  l_bg_id
                                   ) loop

       l_element_entry_id := ele_entry.element_entry_id;
     End loop;
     if l_element_entry_id is not null then
        ghr_element_api.process_sf52_element
       (p_assignment_id         =>      p_pa_request_rec.employee_assignment_id
       ,p_element_name        =>        'AUO'
       ,p_input_value_name1     =>      'Premium Pay Ind'
       ,p_value1                    =>    p_pa_request_rec.to_auo_premium_pay_indicator
       ,p_input_value_name2   =>    'Amount'
       ,p_value2              =>    to_char(p_pa_request_rec.to_au_overtime)
       ,p_effective_date        =>    l_effective_date
       ,p_process_warning       =>      l_adj_basic_pay_warn
       );

      ghr_element_api.process_sf52_element
      (p_assignment_id          =>      p_pa_request_rec.employee_assignment_id
      ,p_element_name         =>        'Premium Pay'
      ,p_input_value_name1      =>      'Premium Pay Ind'
      ,p_value1             =>    p_pa_request_rec.to_auo_premium_pay_indicator
      ,p_input_value_name2    =>    'Amount'
      ,p_value2               =>    to_char(p_pa_request_rec.to_au_overtime)
      ,p_effective_date         =>    l_effective_date
      ,p_process_warning        =>      l_adj_basic_pay_warn
      );
     End if;
   End if;
 End if;

-- Processing Availability pay

-- Note : The sequences of the Inp. Values 1 and 2 for the element, 'Availability Pay' has
--  been swapped. According to Jon's list in new changes after September:
-- Can change only when the seed data changes.

If p_pa_request_rec.to_ap_premium_pay_indicator  is not null or
   p_pa_request_rec.to_availability_pay         is not null  then
   hr_utility.set_location(l_proc,65);
   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'Availability Pay'
   ,p_input_value_name1 =>      'Premium Pay Ind'
   ,p_value1          =>    p_pa_request_rec.to_ap_premium_pay_indicator
   ,p_input_value_name2 =>    'Amount'
   ,p_value2            =>    to_char(p_pa_request_rec.to_availability_pay)
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
   );

   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'Premium Pay'
   ,p_input_value_name1 =>    'Premium Pay Ind'
   ,p_value1            =>    p_pa_request_rec.to_ap_premium_pay_indicator
   ,p_input_value_name2 =>      'Amount'
   ,p_value2          =>    to_char(p_pa_request_rec.to_availability_pay)
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
   );
 Else  --if p_pa_request_rec.avaiability_pay is null
   If p_pa_request_rec.first_noa_code = '819' then
     hr_utility.set_location(l_proc,32);
     l_element_entry_id := NULL;

     l_new_element_name :=
          pqp_fedhr_uspay_int_utils.return_new_element_name(
                p_fedhr_element_name => 'Availability Pay',
                p_business_group_id  => l_bg_id,
                p_effective_date     => p_pa_request_rec.effective_date,
                p_pay_basis          => NULL);


     for ele_entry in  c_ele_entry(ele_name      => l_new_element_name,
                                   ipv_name      => 'Amount',
                                   eff_date      =>  l_effective_date,
                                   bg_id         =>  l_bg_id
                                  ) loop

       l_element_entry_id := ele_entry.element_entry_id;
     End loop;
     if l_element_entry_id is not null then
       hr_utility.set_location(l_proc,33);
       ghr_element_api.process_sf52_element
      (p_assignment_id          =>      p_pa_request_rec.employee_assignment_id
      ,p_element_name         =>        'Availability Pay'
      ,p_input_value_name1  =>  'Premium Pay Ind'
      ,p_value1             =>    p_pa_request_rec.to_ap_premium_pay_indicator
      ,p_input_value_name2  =>  'Amount'
      ,p_value2             =>  to_char(p_pa_request_rec.to_availability_pay)
      ,p_effective_date     =>    l_effective_date
      ,p_process_warning    =>  l_adj_basic_pay_warn
      );

       ghr_element_api.process_sf52_element
       (p_assignment_id         =>      p_pa_request_rec.employee_assignment_id
       ,p_element_name        =>        'Premium Pay'
       ,p_input_value_name1     =>      'Premium Pay Ind'
         ,p_value1                  =>    p_pa_request_rec.to_ap_premium_pay_indicator
         ,p_input_value_name2   =>    'Amount'
         ,p_value2              =>    to_char(p_pa_request_rec.to_availability_pay)
       ,p_effective_date        =>    l_effective_date
         ,p_process_warning     =>      l_adj_basic_pay_warn
       );
     End if;
   End if;
 End if;

-- Processing Supervisory Differential
--
-- Code added/ Modified for Payroll Integration
-- Modifying the input value name from Percent to Percentage
-- this change is done only for Supervisory diff and Retention Allowance
--

hr_utility.trace('Element Name (new) is :'||l_new_element_name);
hr_utility.trace('Supv Diff Amt process_sf52 :'||p_pa_request_rec.to_supervisory_differential);
hr_utility.trace('Supv Diff % Process_sf52 :'||p_pa_request_rec.to_supervisory_diff_percentage);

 If p_pa_request_rec.to_supervisory_differential is not null or
    p_pa_request_rec.to_supervisory_diff_percentage is not null then
    hr_utility.set_location(l_proc,70);
    ghr_element_api.process_sf52_element
    (p_assignment_id     =>     p_pa_request_rec.employee_assignment_id
    ,p_element_name      =>     'Supervisory Differential'
    ,p_input_value_name1 =>     'Amount'
    ,p_value1          =>       to_char(p_pa_request_rec.to_supervisory_differential)
    ,p_input_value_name2 =>     'Percentage'
    ,p_value2          =>       to_char(p_pa_request_rec.to_supervisory_diff_percentage)
    ,p_effective_date    =>    l_effective_date
    ,p_process_warning   =>     l_adj_basic_pay_warn
    );

 Else  --if p_pa_request_rec.superv. diff is null
    If p_pa_request_rec.noa_family_code = 'OTHER_PAY' then
      hr_utility.set_location(l_proc,32);
      l_element_entry_id := NULL;
      l_new_element_name :=
              pqp_fedhr_uspay_int_utils.return_new_element_name(
             p_fedhr_element_name => 'Supervisory Differential',
             p_business_group_id  => l_bg_id,
             p_effective_date     => p_pa_request_rec.effective_date,
             p_pay_basis          => NULL);

      for ele_entry in  c_ele_entry(
                                    ele_name      => l_new_element_name,
                                    ipv_name      => 'Amount',
                                    eff_date      =>  l_effective_date,
                                    bg_id         =>  l_bg_id
                                    ) loop

        l_element_entry_id := ele_entry.element_entry_id;
      End loop;
      If l_element_entry_id is not null then
        ghr_element_api.process_sf52_element
       (p_assignment_id         =>      p_pa_request_rec.employee_assignment_id
       ,p_element_name        =>        'Supervisory Differential'
       ,p_input_value_name1     =>      'Amount'
       ,p_value1                    =>  to_char(p_pa_request_rec.to_supervisory_differential)
       ,p_input_value_name2   =>        'Percentage'
       ,p_value2                    =>  to_char(p_pa_request_rec.to_supervisory_diff_percentage)
       ,p_effective_date        =>    l_effective_date
       ,p_process_warning       =>      l_adj_basic_pay_warn
       );
      End if;
   End if;
 End if;
--
-- Code added/ Modified for Payroll Integration
-- Modifying the input value name from Percent to Percentage
-- this change is done only for Supervisory diff and Retention Allowance
--
------------------------------------------------------------------------------
/************* Commenting the Staffing Differetial code... 05-AUG-2003 by AVR.
--Processing Staffing Differential

If p_pa_request_rec.to_staffing_differential is not null or
   p_pa_request_rec.to_staffing_diff_percentage is not null then

   hr_utility.set_location(l_proc,75);
   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'Staffing Differential'
   ,p_input_value_name1 =>      'Amount'
   ,p_value1          =>        to_char(p_pa_request_rec.to_staffing_differential)
   ,p_input_value_name2 =>      'Percent'
   ,p_value2          =>        to_char(p_pa_request_rec.to_staffing_diff_percentage)
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
   );
Else  --if p_pa_request_rec.staff. diff is null
    If p_pa_request_rec.noa_family_code = 'OTHER_PAY' then
      hr_utility.set_location(l_proc,32);
      l_element_entry_id := NULL;
      l_new_element_name :=
                 pqp_fedhr_uspay_int_utils.return_new_element_name(
                      p_fedhr_element_name => 'Staffing Differential',
                      p_business_group_id  => l_bg_id,
                      p_effective_date     => p_pa_request_rec.effective_date,
                      p_pay_basis          => NULL);

      for ele_entry in  c_ele_entry(ele_name      =>  l_new_element_name,
                                    ipv_name      => 'Amount',
                                    eff_date      =>  l_effective_date,
                                     bg_id         =>  l_bg_id
                                    ) loop

        l_element_entry_id := ele_entry.element_entry_id;
      End loop;
      If l_element_entry_id is not null then
        ghr_element_api.process_sf52_element
       (p_assignment_id         =>      p_pa_request_rec.employee_assignment_id
       ,p_element_name        =>        'Staffing Differential'
       ,p_input_value_name1     =>      'Amount'
       ,p_value1                    =>  to_char(p_pa_request_rec.to_staffing_differential)
       ,p_input_value_name2     =>      'Percent'
       ,p_value2                    =>  to_char(p_pa_request_rec.to_staffing_diff_percentage)
       ,p_effective_date        =>    l_effective_date
       ,p_process_warning       =>      l_adj_basic_pay_warn
       );
      End if;
   End if;
End if;
***********************/


-- Processing retention Allowance
--
-- Code added/ Modified for Payroll Integration
-- Modifying the input value name from Percent to Percentage
-- this change is done only for Supervisory diff and Retention Allowance
--
hr_utility.trace('Element Name (new) is :'||l_new_element_name);
hr_utility.trace('Ret Allw Amt process_sf52 :'||p_pa_request_rec.to_retention_allowance);
hr_utility.trace('Ret Allw % Process_sf52 :'||p_pa_request_rec.to_retention_allow_percentage);


--Pradeep start of Bug 3306515 - Ret All % Pay Cap.
--Get the Retention Allowance and calculate % based on the Percentage.
hr_utility.trace('Pradeep p_pa_request_rec.noa_family_code:'||p_pa_request_rec.noa_family_code);

IF  p_pa_request_rec.to_retention_allow_percentage is null
  AND p_pa_request_rec.to_retention_allowance is not null THEN

	-- Bug 4689374
	IF p_pa_request_rec.pay_rate_determinant IN ('3','4','J','K','U','V') AND
		p_pa_request_rec.effective_date >= to_date('01/05/2005','dd/mm/yyyy') THEN
			l_retention_allow_percentage := NULL;
			hr_utility.trace('Inside fwfa');
	ELSE
		IF ( p_pa_request_rec.noa_family_code like 'GHR_SAL%'
		 OR p_pa_request_rec.noa_family_code ='OTHER_PAY' )
		 THEN

			 hr_utility.trace('Pradeep l_session.noa_id_correct:'||l_session.noa_id_correct);
			 IF l_session.noa_id_correct is null THEN

			  ghr_api.retrieve_element_entry_value (p_element_name    =>  'Retention Allowance'
						   ,p_input_value_name      => 'Amount'
						   ,p_assignment_id         =>  p_pa_request_rec.employee_assignment_id
						   ,p_effective_date        => l_effective_date
						   ,p_value                 => l_retention_allowance
						   ,p_multiple_error_flag   => l_multi_error_flag);

				l_retention_allow_percentage :=
				   trunc((l_retention_allowance/p_pa_request_rec.from_basic_pay)*100,2);
			 ELSE

			--Get the  To side Retention Allowance for corrections.
				hr_utility.trace('Pradeep Correction RA Amount:'||p_pa_request_rec.to_retention_allowance);
				l_retention_allow_percentage :=
				   trunc((p_pa_request_rec.to_retention_allowance/p_pa_request_rec.to_basic_pay)*100,2);
			 END IF; -- IF l_session.noa_id_corr
		END IF;-- IF ( p_pa_request_rec.noa_f
    END IF; -- IF p_pa_request_rec.pay_rate_determinant IN ('3','4',

END IF;
--Pradeep End of Bug 3306515 - Ret All % Pay Cap.

If p_pa_request_rec.to_retention_allowance is not null or
   p_pa_request_rec.to_retention_allow_percentage is not null then

-- Bug 2627003
 IF p_pa_request_rec.to_retention_allowance=0 THEN
    p_retention_allow_review.review_date:=NULL;
 END IF;
-- Bug 2627003

   hr_utility.set_location(l_proc,80);
   ghr_element_api.process_sf52_element
   (p_assignment_id     =>      p_pa_request_rec.employee_assignment_id
   ,p_element_name      =>      'Retention Allowance'
   ,p_input_value_name1 =>      'Amount'
   ,p_value1          =>        to_char(p_pa_request_rec.to_retention_allowance)
   ,p_input_value_name2 =>      'Percentage'
   --3306515 added l_retention_allow_percentage
   ,p_value2          =>        to_char(nvl(p_pa_request_rec.to_retention_allow_percentage,l_retention_allow_percentage))

   ,p_input_value_name3 =>      'Date'
   ,p_value3          =>        fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_retention_allow_review.review_date))
   ,p_effective_date    =>    l_effective_date
   ,p_process_warning   =>      l_adj_basic_pay_warn
   );
Else  --if p_pa_request_rec.ret. allowance is null
    If p_pa_request_rec.noa_family_code = 'OTHER_PAY' then
      hr_utility.set_location(l_proc,32);
      l_element_entry_id := NULL;

      l_new_element_name :=
          pqp_fedhr_uspay_int_utils.return_new_element_name(
                p_fedhr_element_name => 'Retention Allowance',
                p_business_group_id  => l_bg_id,
                p_effective_date     => p_pa_request_rec.effective_date,
                p_pay_basis          => NULL);

      for ele_entry in  c_ele_entry(ele_name      => l_new_element_name,
                                    ipv_name      => 'Amount',
                                    eff_date      =>  l_effective_date,
                                     bg_id         =>  l_bg_id
                                    ) loop

         l_element_entry_id := ele_entry.element_entry_id;
      End loop;

      If l_element_entry_id is not null then

-- Bug 2627003
	IF p_pa_request_rec.to_retention_allowance IS NULL THEN
           p_retention_allow_review.review_date:=NULL;
        END IF;
-- Bug 2627003 Adding inp val date for processing

	ghr_element_api.process_sf52_element
       (p_assignment_id         =>      p_pa_request_rec.employee_assignment_id
       ,p_element_name        =>      'Retention Allowance'
       ,p_input_value_name1     =>      'Amount'
       ,p_value1                    =>  to_char(p_pa_request_rec.to_retention_allowance)
       ,p_input_value_name2     =>      'Percentage'
       ,p_value2              =>        to_char(p_pa_request_rec.to_retention_allow_percentage)
       ,p_input_value_name3     =>      'Date'
       ,p_value3              =>     fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_retention_allow_review.review_date))
       ,p_effective_date        =>    l_effective_date
       ,p_process_warning       =>      l_adj_basic_pay_warn
       );
      End if;
   End if;
End if;
--
-- Code added/ Modified for Payroll Integration
-- Modifying the input value name from Percent to Percentage
-- this change is done only for Supervisory diff and Retention Allowance
--
---------------------------------------------------------------------------------------------
-- Processing  Within Grade Increase
--
l_wgi_due_date := null;
---- Bug 3263140
-- No need for this cursor as the values are properly passed.
-- Instead of the cursor the below written statement is enough
/*FOR ctr_wgi_due IN cur_wgi_due LOOP
   l_wgi_due_date := fnd_date.canonical_to_date(ctr_wgi_due.wgi_due);
END LOOP; */

   l_wgi_due_date := fnd_date.canonical_to_date(p_wgi.p_date_wgi_due);

   hr_utility.set_location('WGI Due date ' || l_wgi_due_date,150);
   hr_utility.set_location('p_pa_request_rec.noa_family_code ' || p_pa_request_rec.noa_family_code,150);
     -- GPPA 46 Update. l_to_pay_plan is not getting initialized. So, added the
     -- following code to initialize the l_to_pay_plan value.

    g_retained_grade_info := null;
    --BUG # 6628794 Added to update to pay plan with pa request pay plan before updating with
     -- retained grade pay plan if temp step is null
    l_to_pay_plan := p_pa_request_rec.to_pay_plan;
    IF p_pa_request_rec.pay_rate_determinant in ('A','B','E','F','U','V') THEN
	    l_retained_grade_rec :=  ghr_pc_basic_pay.get_retained_grade_details
                              (p_person_id       =>   p_pa_request_rec.person_id,
                               p_effective_date  =>   p_pa_request_rec.effective_date,
                               p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                              );
        hr_utility.set_location('l_retained_pay_plan:'||l_retained_grade_rec.pay_plan,155);
	--BUG # 6628749
	IF l_retained_grade_rec.temp_step is NULL THEN
             l_to_pay_plan := l_retained_grade_rec.pay_plan;
        END IF;

            g_retained_grade_info := l_retained_grade_rec;
    END IF;
    --BUG # 6628749 as already defaulted with pa request rec to_pay_plan above
    -- commented the below code
  /*  IF l_retained_grade_rec.temp_step is NULL THEN
        l_to_pay_plan := l_retained_grade_rec.pay_plan;
    ELSE
        l_to_pay_plan := p_pa_request_rec.to_pay_plan;
    END IF;*/
    hr_utility.set_location('l_to_pay_plan:'||l_to_pay_plan,156);
   FOR cur_eq_ppl_rec IN cur_eq_ppl(l_to_pay_plan)
   LOOP
          l_equ_pay_plan   := cur_eq_ppl_rec.EQUIVALENT_PAY_PLAN;
          exit;
   END LOOP;
   hr_utility.set_location('l_equ_pay_plan:'||l_equ_pay_plan,157);
------GPPA Update 46 changes - For SES employees WGI element should not be created for 891, 892 , 890 and 897 NOACs.
-- OR condition for Pay Plan FE is added as FE is nomore ES equ pay plan
IF NOT ((l_equ_pay_plan = 'ES' OR l_to_pay_plan='FE')
        AND p_pa_request_rec.first_noa_code IN ('891', '892', '890', '897')) THEN

  IF  nvl(p_pa_request_rec.noa_family_code,hr_api.g_varchar2) IN
         ('APP',
          'APP_TRANSFER',
          'RETURN_TO_DUTY',
          'CHG_WORK_SCHED',
          'CHG_HOURS',
          'CHG_SCD',
          'DENIAL_WGI',
          'CONV_APP')
     OR
     (
        nvl(p_pa_request_rec.noa_family_code,hr_api.g_varchar2) LIKE 'GHR_SAL%' AND
        nvl(p_pa_request_rec.first_noa_code,hr_api.g_varchar2) NOT IN ('894','895','850')
     ) THEN

       IF nvl(p_pa_request_rec.noa_family_code,hr_api.g_varchar2) IN
          ('APP',
           'APP_TRANSFER',
           'RETURN_TO_DUTY',
           'CHG_WORK_SCHED',
           'CHG_HOURS',
           'CHG_SCD',
           'DENIAL_WGI',
	   'CONV_APP') THEN
	 -- Bug 4031919 If Conversion to appointment and we're moving from WGI to Non-WGI position
	 -- End date the WGI element
	  IF nvl(p_pa_request_rec.noa_family_code,hr_api.g_varchar2) = 'CONV_APP' THEN
		-- If Correction action, then take pay plan from Original action
		IF l_session.noa_id_correct IS NOT NULL AND p_pa_request_rec.to_pay_plan IS NULL THEN
			FOR l_get_pay_plan IN c_get_pay_plan(p_pa_request_rec.altered_pa_request_id) LOOP
				l_to_pay_plan := l_get_pay_plan.to_pay_plan;
			END LOOP;
		ELSE
			l_to_pay_plan := p_pa_request_rec.to_pay_plan;
		END IF;


		IF l_to_pay_plan IS NOT NULL THEN
			--
			FOR l_wgi_pay_plan IN c_wgi_pay_plan(l_to_pay_plan) LOOP
				l_is_wgi_eligible := TRUE;
			END LOOP;


		-- If Pay plan is not eligible, update with NULL
			IF l_is_wgi_eligible = FALSE THEN
				-- Check if WGI element is present or not. If present only we need to update
				-- Get Element Name
				l_wgi_new_name := pqp_fedhr_uspay_int_utils.return_new_element_name(
										p_fedhr_element_name =>'Within Grade Increase',
										p_business_group_id => l_bg_id,
										p_effective_date => p_pa_request_rec.effective_date);
				FOR l_check_wgi IN c_check_ele(l_wgi_new_name,p_pa_request_rec.effective_date,	p_pa_request_rec.employee_assignment_id) LOOP
					l_wgi_exists := TRUE;
				END LOOP;

				IF l_wgi_exists = TRUE THEN
					ghr_element_api.process_sf52_element
					   (p_assignment_id        =>   p_pa_request_rec.employee_assignment_id
					   ,p_element_name         =>  'Within Grade Increase'
					   ,p_input_value_name2    =>   'Date Due'
					   ,p_value2               =>   NULL
					   ,p_input_value_name3    =>   'Pay Date'
					   ,p_value3               =>   NULL
					   ,p_input_value_name4    =>   'Last Equivalent Increase'
					   ,p_value4               =>   NULL
					   ,p_input_value_name5    =>   'Postponmt Effective'
					   ,p_value5               =>   NULL
					   ,p_effective_date       =>    l_effective_date
					   ,p_process_warning      =>    l_within_grade_increase_warn
					    );
					    l_wgi_cleared := TRUE;
				END IF;
			END IF; -- IF l_is_wgi_eligible = FALSE
		END IF;
	  END IF; -- IF nvl(p_pa_request_rec.noa_family_code,hr_api.g_varchar2) = 'CONV_APP'

        -- proceed only if date_wgi_due is not null
          l_wgi_due_date := fnd_date.canonical_to_date(p_wgi.p_date_wgi_due);
          IF l_wgi_due_date IS NOT NULL AND l_wgi_cleared = FALSE THEN
            ghr_sf52_do_update.get_wgi_dates
            (p_pa_request_rec     => p_pa_request_rec,
             p_wgi_due_date       => l_wgi_due_date,
             p_wgi_pay_date       => l_wgi_pay_date,
             p_retained_grade_rec => l_retained_grade_rec,
	     p_dlei  => NULL
             );
	     hr_utility.set_location('Inside If loop',511);
            ghr_element_api.process_sf52_element
           (p_assignment_id        =>   p_pa_request_rec.employee_assignment_id
           ,p_element_name         =>  'Within Grade Increase'
           ,p_input_value_name2    =>   'Date Due'
           ,p_value2               =>   fnd_date.date_to_displaydate(l_wgi_due_date)     --AVR
           ,p_input_value_name3    =>   'Pay Date'
           ,p_value3               =>   fnd_date.date_to_displaydate(l_wgi_pay_date)  --AVR
           ,p_input_value_name4    =>   'Last Equivalent Increase'
           ,p_value4               =>   fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_last_equi_incr))
           ,p_input_value_name5    =>   'Postponmt Effective'
           ,p_value5               =>
                      fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_date_wgi_postpone_effective)) --AVR
           ,p_effective_date       =>    l_effective_date
           ,p_process_warning      =>    l_within_grade_increase_warn
            );
	 -- If WGI Due date is not entered for Appointment and Conversion to Appointment, atleast create
	 -- WGI element with Last equivalent increase.
	 -- Bug 3998686 In correction action, if DLEI is present and WGI Due date is cleared,
	 -- it comes here. Need to update NULL in that case. .
	 ELSIF nvl(p_pa_request_rec.noa_family_code,hr_api.g_varchar2) IN ('APP','CONV_APP')
		AND p_wgi.p_last_equi_incr IS NOT NULL AND l_wgi_cleared = FALSE THEN
	     hr_utility.set_location('Inside elsif loop',511);
            ghr_element_api.process_sf52_element
           (p_assignment_id        =>   p_pa_request_rec.employee_assignment_id
           ,p_element_name         =>  'Within Grade Increase'
	   ,p_input_value_name2    =>   'Date Due'
           ,p_value2               =>   NULL  -- Bug 3998686
           ,p_input_value_name3    =>   'Pay Date'
           ,p_value3               =>   NULL -- Bug 3998686
           ,p_input_value_name4    =>   'Last Equivalent Increase'
           ,p_value4               =>   fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_last_equi_incr))
           ,p_input_value_name5    =>   'Postponmt Effective'
           ,p_value5               =>
                      fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_date_wgi_postpone_effective)) --AVR
           ,p_effective_date       =>    l_effective_date
           ,p_process_warning      =>    l_within_grade_increase_warn
            );
         END IF; -- IF l_wgi_due_date IS NOT NULL THEN
        ELSE
	      -- Bug 3953455
	      -- If it's a correction action, and not in 702,703,713 then
	      -- check for the To step. if it's different then need to call get_wgi_dates.
              IF (l_session.noa_id_correct is not null and
	          p_pa_request_rec.first_noa_code NOT in ('702','703','713')) THEN
		     -- Get the To step values
		     FOR l_get_step IN cur_get_step(p_pa_request_rec.pa_request_id) LOOP
			l_orig_pa_from_step := l_get_step.step1;
			l_corr_pa_from_step := l_get_step.step2;
		     END LOOP;

		     IF l_corr_pa_from_step IS NOT NULL THEN
			IF l_orig_pa_from_step <> l_corr_pa_from_step THEN
				l_call_wgi_dates := TRUE;
			END IF;
		     END IF;
		     -- Bug 4025190
		     IF p_wgi.p_date_wgi_due IS NOT NULL OR p_wgi.p_last_equi_incr IS NOT NULL THEN
			l_call_wgi_dates := TRUE;
		     END IF;
		     -- Bug 4025190
	      END IF;
	      -- End Bug 3953455

          -- CALL only if not a CORRECTION Action
          -- Bug#2099054 added OR Condition to handle
          -- a CORRECTION Action for noa codes 702,703,713 (Bug 3263140)
              If (l_session.noa_id_correct is null) OR
                (l_session.noa_id_correct is not null and
                    p_pa_request_rec.first_noa_code in ('702','703','713')) OR
			l_call_wgi_dates = TRUE
		    THEN

               IF p_pa_request_rec.first_noa_code in ( '702','703','713') THEN
                 l_wgi_due_date := fnd_date.canonical_to_date(p_wgi.p_date_wgi_due);
                 hr_utility.set_location('702 -- l_wgi_due_date is ' || l_wgi_due_date,1);
               END IF;

               IF not (p_pa_request_rec.first_noa_code = '702' AND
                  g_old_user_status = 'Temp. Promotion NTE' )THEN
			-- Call get_wgi_dates irrespective of whether Due date is entered or not.
			-- Removed the condition which checked for Due date not null condition
			-- Bug 3940682, 3941877, 3617295, TAR 4141454.995
			ghr_sf52_do_update.get_wgi_dates
			(p_pa_request_rec    => p_pa_request_rec,
			p_wgi_due_date      => l_wgi_due_date,
			p_wgi_pay_date      => l_wgi_pay_date,
			p_retained_grade_rec => l_retained_grade_rec,
			p_dlei  => fnd_date.canonical_to_date(p_wgi.p_last_equi_incr)
			);
		     -- Start of  3111719
		     -- For QSI action get the current LEI date.
		     -- Bug 3993664 - Included NOA 867...
             -- Bug#5666880 - Included NOA 896, 897
             IF (p_pa_request_rec.first_noa_code  IN ('892','867','896','897') OR
                         p_pa_request_rec.second_noa_code IN ('892','867','896','897')) THEN
                hr_utility.set_location('inside NOA Code 897',9999999);
       			ghr_history_fetch.fetch_element_entry_value
                          (p_element_name          =>  'Within Grade Increase',
                           p_input_value_name      =>  'Last Equivalent Increase',
                           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
                           p_date_effective        =>  p_pa_request_rec.effective_date,
                           p_screen_entry_value    =>  l_lei_date
                           );
                         p_wgi.p_last_equi_incr := l_lei_date;
		     END IF;
           -- End of 3111719
		-- Bug 3709414 Retrieving Last equivalent increase date if it's not entered in RPA EIT.
		hr_utility.set_location('p_wgi.p_last_equi_incr is ' || p_wgi.p_last_equi_incr,1);
		   IF (p_pa_request_rec.first_noa_code = '713' OR p_pa_request_rec.second_noa_code = '713')
						AND p_wgi.p_last_equi_incr IS NULL THEN
			   ghr_history_fetch.fetch_element_entry_value
                          (p_element_name          =>  'Within Grade Increase',
                           p_input_value_name      =>  'Last Equivalent Increase',
                           p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
                           p_date_effective        =>  p_pa_request_rec.effective_date,
                           p_screen_entry_value    =>  l_lei_date
                           );
                         p_wgi.p_last_equi_incr := l_lei_date;
		   END IF;

		   -- Bug 3617295 DLEI should be updated with RPA effective date
		   IF p_pa_request_rec.first_noa_code = '855' OR p_pa_request_rec.second_noa_code = '855' THEN
			p_wgi.p_last_equi_incr := fnd_date.date_to_canonical(p_pa_request_rec.effective_date); -- Bug 3991240
		   END IF;
		   -- End Bug 3617295

		   hr_utility.set_location('l_wgi_due_date calculated is ' || l_wgi_due_date,1);
           hr_utility.set_location('lei date calculated is ' || p_wgi.p_last_equi_incr,2);
           hr_utility.set_location('l_wgi_pay_date calculated is ' || l_wgi_pay_date,3);

             ghr_element_api.process_sf52_element
               (p_assignment_id        =>  p_pa_request_rec.employee_assignment_id
               ,p_element_name         =>  'Within Grade Increase'
               ,p_input_value_name2    =>  'Date Due'
               ,p_value2               =>  fnd_date.date_to_displaydate(l_wgi_due_date)  --AVR
               ,p_input_value_name3    =>  'Pay Date'
               ,p_value3               =>   fnd_date.date_to_displaydate(l_wgi_pay_date) --AVR
               ,p_input_value_name4    =>  'Last Equivalent Increase'
               ,p_value4               =>   fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_last_equi_incr))
               ,p_input_value_name5    =>   'Postponmt Effective'
               ,p_value5               =>
                fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_date_wgi_postpone_effective)) --AVR
               ,p_effective_date       =>    l_effective_date
               ,p_process_warning      =>    l_within_grade_increase_warn
                );
            END IF; -- IF not (p_pa_request_rec.first_noa_code = '702'
       End if; -- If (l_session.noa_id_correct is null) OR
     End if;
   Else
     If p_wgi.p_date_wgi_due                is not null or
       p_wgi.p_wgi_pay_date                 is not null  or
       p_wgi.p_date_wgi_postpone_effective  is not null  then
       hr_utility.set_location(l_proc,85);
       hr_utility.set_location('date due  ' || p_wgi.p_date_wgi_due,1);
       hr_utility.set_location('determ due' || p_wgi.p_date_wgi_postpone_effective,2);

       ghr_element_api.process_sf52_element
       (p_assignment_id      =>    p_pa_request_rec.employee_assignment_id
       ,p_element_name       =>   'Within Grade Increase'
       ,p_input_value_name2  =>   'Date Due'
       ,p_value2             =>
               fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_date_wgi_due)) --AVR
       ,p_input_value_name3  =>  'Pay Date'
       ,p_value3             =>
               fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_wgi_pay_date)) --AVR
           ,p_input_value_name4    =>  'Last Equivalent Increase'
           ,p_value4               =>   fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_last_equi_incr))
       ,p_input_value_name5  =>   'Postponmt Effective'
       ,p_value5             =>
           fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_wgi.p_date_wgi_postpone_effective)) ---AVR
       ,p_effective_date     =>    l_effective_date
       ,p_process_warning    =>    l_within_grade_increase_warn
       );
    end if;
 End if;
END IF;    ------l_equ_pay_plan = 'ES'

 -- FWFA Changes. Restrict this update if the update happens already in call_extra_info_api.



IF NOT(ghr_pay_calc.g_fwfa_pay_calc_flag) AND
      NOT(ghr_pay_calc.g_gl_upd_flag) THEN
         ghr_history_api.get_g_session_var(l_session);
    IF p_pa_request_rec.first_noa_code = '894' and
         ghr_process_sf52.g_prd IS NOT NULL AND
         l_session.noa_id_correct IS NULL THEN
         IF ghr_process_sf52.g_prd in ('A','B','E','F','U','V') THEN
	     l_new_step_or_rate := ghr_process_sf52.g_step_or_rate;
             l_retained_grade_rec :=  ghr_pc_basic_pay.get_retained_grade_details
                              (p_person_id       =>   p_pa_request_rec.person_id,
                               p_effective_date  =>   p_pa_request_rec.effective_date,
                               p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                              );
        END IF;
     END IF;
       hr_utility.set_location('ret person extra info id : ' || l_retained_grade_rec.person_extra_info_id,1);

-------Bug 5913362 -- Adding 890
       If l_retained_grade_rec.person_extra_info_id is not null
       and p_pa_request_rec.first_noa_code NOT IN ('866', '890')  then
          hr_utility.set_location('update retained grade info',1);
          for retained_grade_ovn in c_retained_grade_ovn loop
            l_ret_object_version_number := retained_grade_ovn.object_version_number;
            if p_pa_request_rec.first_noa_code in ('867','892','893','894')
               then
              l_new_date_to             := retained_grade_ovn.pei_information2;
              l_new_grade_or_level      := retained_grade_ovn.pei_information3;
              l_new_pay_plan            := retained_grade_ovn.pei_information5;
              l_new_pay_table           := retained_grade_ovn.pei_information6;
              l_new_loc_percent         := retained_grade_ovn.pei_information7;
              l_new_pay_basis           := retained_grade_ovn.pei_information8;
              l_cur_step_or_rate        := retained_grade_ovn.pei_information4;
              l_new_temp_step        := retained_grade_ovn.pei_information9;
            end if;
          end loop;
          If p_pa_request_rec.first_noa_code in ('867','892','893','894') then
           hr_utility.set_location('procesing 867,892,893,894',1);
           ghr_history_api.get_g_session_var(l_session);
           If l_session.noa_id_correct is null then
           hr_utility.set_location('procesing 867,892,893,894 not a corr',1);
----Bug 6193571 start
             if p_pa_request_rec.first_noa_code = '894'
                AND l_new_step_or_rate is not null
                    AND ghr_process_sf52.g_prd IS NOT NULL then
              hr_person_extra_info_api.update_person_extra_info
              (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
               p_object_version_number     =>  l_ret_object_version_number,
               p_pei_information2          =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
               );
             end if;
             If p_pa_request_rec.first_noa_code in ('867','892','893') then
--- Bug 6193571  end
              hr_person_extra_info_api.update_person_extra_info
              (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
               p_object_version_number     =>  l_ret_object_version_number,
               p_pei_information2          =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
               );
             end if;
           IF p_pa_request_rec.first_noa_code in ('867','892','893') THEN
             l_new_step_or_rate := l_retained_grade_rec.step_or_rate;
             l_new_temp_step := l_retained_grade_rec.temp_step;
           hr_utility.set_location('TPS 1 ',1);
           END IF;
           hr_utility.set_location('TPS 1a '||l_new_temp_step,1);
           IF l_new_temp_step is NOT NULL THEN
           hr_utility.set_location('TPS 1b '||l_new_temp_step,1);
              hr_person_extra_info_api.create_person_extra_info
              (p_person_id                =>  p_pa_request_rec.person_id,
               p_information_type         =>  'GHR_US_RETAINED_GRADE',
               p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
               p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
               p_object_version_number    =>  l_ret_object_version_number,
               p_pei_information1         =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date),
               p_pei_information2         =>  l_new_date_to,
               p_pei_information3         =>  l_new_grade_or_level,
               p_pei_information4         =>  l_cur_step_or_rate,
               p_pei_information5         =>  l_new_pay_plan,
               p_pei_information6         =>  l_new_pay_table,
               p_pei_information7         =>  l_new_loc_percent,
               p_pei_information8         =>  l_new_pay_basis,
               p_pei_information9         =>  l_new_temp_step
              );
           ELSE
           hr_utility.set_location('TPS 2 '||l_new_step_or_rate,2);
---Bug 6024225 Added nvl value for 894 action. Need to check this at a later time.

--- Bug 6193571 start
             if p_pa_request_rec.first_noa_code = '894'
                AND l_new_step_or_rate is not null
                    AND ghr_process_sf52.g_prd IS NOT NULL then
              hr_person_extra_info_api.create_person_extra_info
              (p_person_id                =>  p_pa_request_rec.person_id,
               p_information_type         =>  'GHR_US_RETAINED_GRADE',
               p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
               p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
               p_object_version_number    =>  l_ret_object_version_number,
               p_pei_information1         =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date),
               p_pei_information2         =>  l_new_date_to,
               p_pei_information3         =>  l_new_grade_or_level,
               p_pei_information4         =>  nvl(l_new_step_or_rate,l_cur_step_or_rate),
               p_pei_information5         =>  l_new_pay_plan,
               p_pei_information6         =>  l_new_pay_table,
               p_pei_information7         =>  l_new_loc_percent,
               p_pei_information8         =>  l_new_pay_basis
              );
             end if;
             IF p_pa_request_rec.first_noa_code in ('867','892','893') THEN
----Bug 6193571 end
              hr_person_extra_info_api.create_person_extra_info
              (p_person_id                =>  p_pa_request_rec.person_id,
               p_information_type         =>  'GHR_US_RETAINED_GRADE',
               p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
               p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
               p_object_version_number    =>  l_ret_object_version_number,
               p_pei_information1         =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date),
               p_pei_information2         =>  l_new_date_to,
               p_pei_information3         =>  l_new_grade_or_level,
               p_pei_information4         =>  nvl(l_new_step_or_rate,l_cur_step_or_rate),
               p_pei_information5         =>  l_new_pay_plan,
               p_pei_information6         =>  l_new_pay_table,
               p_pei_information7         =>  l_new_loc_percent,
               p_pei_information8         =>  l_new_pay_basis
              );
             end if;
            END IF;
          End if;
        Else
           hr_utility.set_location('TPS 3 '||l_new_step_or_rate,3);
          hr_person_extra_info_api.update_person_extra_info
          (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
           p_object_version_number     =>  l_ret_object_version_number,
           p_pei_information4          =>  l_retained_grade_rec.step_or_rate
          );
       End if;
     End if;
END IF;
--
-- Temp. Promo RG processing for 703 Actions
-- Create a new RG row with the Temporary promotion step value
-- and End date the current RG row with effective date minus one
    -- Get the Temporary Promotion Step Value
  l_new_temp_step := NULL;
  IF p_pa_request_rec.first_noa_code in ('703') THEN
    FOR cur_temp_step_rec IN cur_temp_step LOOP
      l_new_temp_step  := cur_temp_step_rec.temp_step;
    END LOOP;
    hr_utility.set_location('TPS 4 '||l_new_temp_step,4);
    IF  l_new_temp_step is not null  THEN
      l_retained_grade_rec :=
       ghr_pc_basic_pay.get_retained_grade_details
         (p_person_id      =>   p_pa_request_rec.person_id,
         p_effective_date  =>   p_pa_request_rec.effective_date,
         p_pa_request_id   =>   p_pa_request_rec.pa_request_id
         );
      IF l_retained_grade_rec.person_extra_info_id is not null then
        hr_utility.set_location('Inside 703 processing '||l_retained_grade_rec.person_extra_info_id,1);
        FOR retained_grade_ovn IN c_retained_grade_ovn LOOP
          l_ret_object_version_number := retained_grade_ovn.object_version_number;
          l_new_date_to             := retained_grade_ovn.pei_information2;
          l_new_grade_or_level      := retained_grade_ovn.pei_information3;
          l_new_step_or_rate        := retained_grade_ovn.pei_information4;
          l_new_pay_plan            := retained_grade_ovn.pei_information5;
          l_new_pay_table           := retained_grade_ovn.pei_information6;
          l_new_loc_percent         := retained_grade_ovn.pei_information7;
          l_new_pay_basis           := retained_grade_ovn.pei_information8;
          exit;
        END LOOP;
        ghr_history_api.get_g_session_var(l_session);
        hr_utility.set_location('Inside 703 processing ',2);
        IF l_session.noa_id_correct is null then
          -- End date the existing RG record
          hr_person_extra_info_api.update_person_extra_info
          (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
          p_object_version_number     =>  l_ret_object_version_number,
          p_pei_information2          =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
          );
          hr_utility.set_location('Inside 703 processing ',3);
          -- Create the new RG Record with Temporary Promotion Step Value
          hr_person_extra_info_api.create_person_extra_info
          (p_person_id                =>  p_pa_request_rec.person_id,
          p_information_type         =>  'GHR_US_RETAINED_GRADE',
          p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
          p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
          p_object_version_number    =>  l_ret_object_version_number,
          p_pei_information1         =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date),
          p_pei_information2         =>  l_new_date_to,
          p_pei_information3         =>  l_new_grade_or_level,
          p_pei_information4         =>  l_new_step_or_rate,
          p_pei_information5         =>  l_new_pay_plan,
          p_pei_information6         =>  l_new_pay_table,
          p_pei_information7         =>  l_new_loc_percent,
          p_pei_information8         =>  l_new_pay_basis,
          p_pei_information9         =>  l_new_temp_step
          );
          hr_utility.set_location('Inside 703 processing ',3);
        ELSE
          -- Update the current RG
          hr_utility.set_location('Inside 703 correction processing '||l_new_temp_step,4);
          hr_person_extra_info_api.update_person_extra_info
          (p_person_extra_info_id     =>  l_retained_grade_rec.person_extra_info_id,
          p_object_version_number     =>  l_ret_object_version_number,
          p_pei_information9          =>  l_new_temp_step
          );
        END IF;
      END IF;
    END IF;
  END IF;
--
-- Temp. Promo RG processing for 740 action
-- Create a new RG record with the null Temporary promotion step value
-- and End date the current RG row withe effective date minus one
   -- Get the Temporary Promotion Step Value
   IF p_pa_request_rec.first_noa_code in ('740') THEN
    BEGIN --Bug 3941836 added being and end for this.
      l_retained_grade_rec :=
       ghr_pc_basic_pay.get_retained_grade_details
         (p_person_id      =>   p_pa_request_rec.person_id,
         p_effective_date  =>   p_pa_request_rec.effective_date,
         p_pa_request_id   =>   p_pa_request_rec.pa_request_id
         );
     EXCEPTION
       WHEN OTHERS THEN
          NULL;
     END;
     IF l_retained_grade_rec.person_extra_info_id is not null then
       hr_utility.set_location('Inside 740 processing '||l_retained_grade_rec.person_extra_info_id,1);
       FOR retained_grade_ovn IN c_retained_grade_ovn LOOP
         l_ret_object_version_number := retained_grade_ovn.object_version_number;
         l_new_date_to             := retained_grade_ovn.pei_information2;
         l_new_grade_or_level      := retained_grade_ovn.pei_information3;
         l_new_step_or_rate        := retained_grade_ovn.pei_information4;
         l_new_pay_plan            := retained_grade_ovn.pei_information5;
         l_new_pay_table           := retained_grade_ovn.pei_information6;
         l_new_loc_percent         := retained_grade_ovn.pei_information7;
         l_new_pay_basis           := retained_grade_ovn.pei_information8;
         l_new_temp_step           := retained_grade_ovn.pei_information9;
         exit;
       END LOOP;
       hr_utility.set_location('Inside 740 processing ',2);
       ghr_history_api.get_g_session_var(l_session);
       IF l_new_temp_step IS NOT NULL and l_session.noa_id_correct IS NULL THEN
         -- End date the existing RG record
         hr_person_extra_info_api.update_person_extra_info
         (p_person_extra_info_id      =>  l_retained_grade_rec.person_extra_info_id,
         p_object_version_number     =>  l_ret_object_version_number,
         p_pei_information2          =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date - 1)
         );
         hr_utility.set_location('Inside 740 processing ',3);
         -- Create the new RG Record with null Temporary Promotion Step Value
         hr_person_extra_info_api.create_person_extra_info
         (p_person_id                =>  p_pa_request_rec.person_id,
         p_information_type         =>  'GHR_US_RETAINED_GRADE',
         p_pei_information_category =>  'GHR_US_RETAINED_GRADE',
         p_person_extra_info_id     =>  l_ret_grade_rec.person_extra_info_id,
         p_object_version_number    =>  l_ret_object_version_number,
         p_pei_information1         =>  fnd_date.date_to_canonical(p_pa_request_rec.effective_date),
         p_pei_information2         =>  l_new_date_to,
         p_pei_information3         =>  l_new_grade_or_level,
         p_pei_information4         =>  l_new_step_or_rate,
         p_pei_information5         =>  l_new_pay_plan,
         p_pei_information6         =>  l_new_pay_table,
         p_pei_information7         =>  l_new_loc_percent,
         p_pei_information8         =>  l_new_pay_basis
         );
         hr_utility.set_location('Inside 740 processing ',3);
       END IF;
     END IF;
   END IF;
hr_utility.set_location('Leaving  ' ||l_proc,100);
Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_wgi                      := l_wgi;
          p_retention_allow_review   := l_retention_allow_review;
          raise;

end Process_salary_Info;
--
--
--
--  ********************************
--  procedure  Process_Non_Salary_Info
--  ********************************
--
Procedure Process_non_salary_Info
(p_pa_request_rec             in            ghr_pa_requests%rowtype
,p_recruitment_bonus          in out nocopy ghr_api.recruitment_bonus_type
,p_relocation_bonus           in out nocopy ghr_api.relocation_bonus_type
,p_student_loan_repay         in out nocopy ghr_api.student_loan_repay_type
 --Pradeep
 ,p_mddds_special_pay          in out nocopy ghr_api.mddds_special_pay_type
,p_premium_pay_ind             in out nocopy ghr_api.premium_pay_ind_type
,p_gov_award                  in out nocopy ghr_api.government_awards_type
,p_entitlement                in out nocopy ghr_api.entitlement_type
-- Bug#2759379 Added FEGLI parameter
,p_fegli                      in out nocopy ghr_api.fegli_type
,p_foreign_lang_prof_pay      in out nocopy ghr_api.foreign_lang_prof_pay_type
-- Bug# 3385386 Added FTA parameter
,p_fta                        in out nocopy ghr_api.fta_type
,p_edp_pay                    in out nocopy ghr_api.edp_pay_type
,p_hazard_pay                 in out nocopy ghr_api.hazard_pay_type
,p_health_benefits            in out nocopy ghr_api.health_benefits_type
,p_danger_pay                 in out nocopy ghr_api.danger_pay_type
,p_imminent_danger_pay        in out nocopy ghr_api.imminent_danger_pay_type
,p_living_quarters_allow      in out nocopy ghr_api.living_quarters_allow_type
,p_post_diff_amt              in out nocopy ghr_api.post_diff_amt_type
,p_post_diff_percent          in out nocopy ghr_api.post_diff_percent_type
,p_sep_maintenance_allow      in out nocopy ghr_api.sep_maintenance_allow_type
,p_supplemental_post_allow    in out nocopy ghr_api.supplemental_post_allow_type
,p_temp_lodge_allow           in out nocopy ghr_api.temp_lodge_allow_type
,p_premium_pay                in out nocopy ghr_api.premium_pay_type
,p_retirement_annuity         in out nocopy ghr_api.retirement_annuity_type
,p_severance_pay              in out nocopy ghr_api.severance_pay_type
,p_thrift_saving_plan         in out nocopy ghr_api.thrift_saving_plan
,p_health_ben_pre_tax         in out nocopy ghr_api.health_ben_pre_tax_type
) is

l_proc                        varchar2(70) := 'Process_Non_salary_info';
l_warning                     boolean;
l_effective_date              date;
--
-- No copy Changes.
l_recruitment_bonus           ghr_api.recruitment_bonus_type;
l_relocation_bonus            ghr_api.relocation_bonus_type;
l_gov_award                   ghr_api.government_awards_type;
l_entitlement                 ghr_api.entitlement_type;
l_foreign_lang_prof_pay       ghr_api.foreign_lang_prof_pay_type;
-- Bug# 3385386 Added l_fta variable
l_fta                         ghr_api.fta_type;
l_edp_pay                     ghr_api.edp_pay_type;
l_hazard_pay                  ghr_api.hazard_pay_type;
l_health_benefits             ghr_api.health_benefits_type;
l_danger_pay                  ghr_api.danger_pay_type;
l_imminent_danger_pay         ghr_api.imminent_danger_pay_type;
l_living_quarters_allow       ghr_api.living_quarters_allow_type;
l_post_diff_amt               ghr_api.post_diff_amt_type;
l_post_diff_percent           ghr_api.post_diff_percent_type;
l_sep_maintenance_allow       ghr_api.sep_maintenance_allow_type;
l_supplemental_post_allow     ghr_api.supplemental_post_allow_type;
l_temp_lodge_allow            ghr_api.temp_lodge_allow_type;
l_premium_pay                 ghr_api.premium_pay_type;
l_retirement_annuity          ghr_api.retirement_annuity_type;
l_severance_pay               ghr_api.severance_pay_type;
l_thrift_saving_plan          ghr_api.thrift_saving_plan;
l_health_ben_pre_tax          ghr_api.health_ben_pre_tax_type;
l_student_loan_repay          ghr_api.student_loan_repay_type;
-- Bug#4486823 RRR Changes
l_total_salary                ghr_pa_requests.to_total_salary%TYPE;
--
        PROCEDURE Create_incentive_Remark(p_pa_request_id  IN NUMBER,
                                          p_effective_date IN DATE,
                                          p_category   IN VARCHAR2,
                                          p_noa_code   IN VARCHAR2,
                                          p_percent    IN NUMBER,
                                          p_amount     IN NUMBER,
                  			              p_payment_date IN DATE,
                                          p_end_date     IN DATE) IS

                l_remark_id           ghr_remarks.remark_id%TYPE;
                l_pa_remark_id        ghr_pa_remarks.pa_remark_id%TYPE;
                l_object_version_nbr  ghr_pa_remarks.object_version_number%TYPE;
                l_remark_desc         ghr_remarks.description%TYPE;
                l_remark_information1 ghr_pa_remarks.remark_code_information1%TYPE;
                l_remark_information2 ghr_pa_remarks.remark_code_information2%TYPE;
                l_remark_information3 ghr_pa_remarks.remark_code_information3%TYPE;
                l_remark_information4 ghr_pa_remarks.remark_code_information4%TYPE;
                l_remark_information5 ghr_pa_remarks.remark_code_information5%TYPE;
                l_remark_desc_out     ghr_remarks.description%TYPE;
                l_end_date            DATE;


            BEGIN
                l_end_date := p_end_date;
                ghr_mass_actions_pkg.get_remark_id_desc
                (p_remark_code       => 'ZZZ',
                p_effective_date    => p_effective_date,
                p_remark_id         => l_remark_id,
                p_remark_desc       => l_remark_desc);

                l_remark_information1 := NULL;
                l_remark_information2 := NULL;
                l_remark_information3 := NULL;
                l_remark_information4 := NULL;
                l_remark_information5 := NULL;

                IF p_percent IS NOT NULL THEN
                    IF p_category = 'Biweekly' THEN

                        -- Bug#5039100
                        IF p_percent = 0 THEN
                            -- Change the remark from 'As on' to 'As of' : Bug:5170178
                            l_remark_information1 := 'Retention Incentive Biweekly is terminated as of '||fnd_date.date_to_displaydate(p_payment_date);
                        ELSE
                            -- Added this IF condition to remove the end date if end date is '4712/12/31' : Bug#5170178
                            IF l_end_date IS NULL THEN
                                l_remark_information1 := p_category||' is '||p_percent||'% of Earned Basic Pay to be paid from '
                                               ||fnd_date.date_to_displaydate(p_payment_date);
                            ELSE
                                l_remark_information1 := p_category||' is '||p_percent||'% of Earned Basic Pay to be paid from '
                                               ||fnd_date.date_to_displaydate(p_payment_date) ||' to '
                                               ||fnd_date.date_to_displaydate(l_end_date);
                            END IF;
                        END IF;
                    ELSE
                        l_remark_information1 := p_category||' is '||p_percent||'% of Earned Basic Pay to be paid '
                                            ||fnd_date.date_to_displaydate(p_payment_date);
                    END IF;
                ELSE
                    IF p_category = 'Biweekly' THEN
                        -- Added this IF condition to remove the end date if end date is '4712/12/31' : Bug#5170178
                        IF l_end_date IS NULL THEN
                            l_remark_information1 := p_category||' of $'||p_amount||' to be paid from '
                                            ||fnd_date.date_to_displaydate(p_payment_date);
                            ELSE
                            l_remark_information1 := p_category||' of $'||p_amount||' to be paid from '
                                            ||fnd_date.date_to_displaydate(p_payment_date) ||' to '
                                            ||fnd_date.date_to_displaydate(l_end_date);

                        END IF;
                   ELSE
                        l_remark_information1 := p_category||' of $'||p_amount||' to be paid '
                                            ||fnd_date.date_to_displaydate(p_payment_date);
                    END IF;
                END IF;


                --Pradeep commented l_remark_desc and added l_remark_desc_out for the Bug#3974979.
                ghr_mass_actions_pkg.replace_insertion_values
                (p_desc              => l_remark_desc,
                p_information1      => l_remark_information1,
                p_information2      => l_remark_information2,
                p_information3      => l_remark_information3,
                p_information4      => l_remark_information4,
                p_information5      => l_remark_information5,
                p_desc_out          => l_remark_desc_out
                    );
                l_remark_desc := l_remark_desc_out;

                ghr_pa_remarks_api.create_pa_remarks
                     (p_pa_request_id            => p_pa_request_id,
                      p_remark_id                => l_remark_id,
                      p_description              => l_remark_desc,
                      p_remark_code_information1 => l_remark_information1,
                      p_remark_code_information2 => l_remark_information2,
                      p_remark_code_information3 => l_remark_information3,
                      p_remark_code_information4 => l_remark_information4,
                      p_remark_code_information5 => l_remark_information5,
                      p_pa_remark_id             => l_pa_remark_id,
                      p_object_version_number    => l_object_version_nbr);
            END create_incentive_remark;

            PROCEDURE Upd_sep_incn_elements(p_pa_request_id   IN ghr_pa_requests.pa_request_id%TYPE
                                            ,p_assignment_id   IN ghr_pa_requests.employee_assignment_id%TYPE
                                            ,p_effective_date  IN ghr_pa_requests.effective_date%TYPE
                                            ,p_payment_option  IN ghr_pa_requests.pa_incentive_payment_option%TYPE
                                            ,p_first_noa_code  IN ghr_pa_requests.first_noa_code%TYPE
                                            ,p_second_noa_code IN ghr_pa_requests.second_noa_code%TYPE) IS

               Cursor c_inc_catg_details(l_pa_request_id NUMBER) IS
                SELECT pa_incentive_category_amount amount,
                       pa_incentive_category_pmnt_dt payment_date
                FROM   ghr_pa_incentives
                where  pa_request_id = l_pa_request_id
                order by pa_incentive_category_pmnt_dt;


                CURSOR c_nonrec_incntv_ele_info (ele_name    in varchar2
                                                ,asg_id      in number
                                                ,eff_date    in date
                                                ,bg_id       in number) is
                select       ele.element_entry_id,
                             ipv.name,
                             ipv.input_value_id,
                             ipv.uom,
                             eev.screen_entry_value screen_entry_value,
                             ele.object_version_number
                      from pay_element_types_f elt,
                           pay_input_values_f ipv,
                           pay_element_entries_f ele,
                           pay_element_entry_values_f eev
                     where trunc(eff_date) between elt.effective_start_date
                                   and elt.effective_end_date
                       and trunc(eff_date) between ipv.effective_start_date
                                   and ipv.effective_end_date
                       and trunc(eff_date) between ele.effective_start_date
                                   and ele.effective_end_date
                       and trunc(eff_date) between eev.effective_start_date
                                   and eev.effective_end_date
                       and elt.element_type_id = ipv.element_type_id
                       and upper(elt.element_name) = upper(ele_name)
                       and ipv.input_value_id = eev.input_value_id
                       and ele.assignment_id = asg_id
                       and ele.element_entry_id + 0 = eev.element_entry_id
                       and (elt.business_group_id is null or elt.business_group_id = bg_id)
                    order by ele.element_entry_id,ipv.input_value_id;

                    cursor c_business_group (asg_id number, eff_date date) is
                    select asg.business_group_id
                    from per_all_assignments_f asg
                    where asg.assignment_id = asg_id
                    and eff_date between asg.effective_start_date
                    and asg.effective_end_date;


                    l_value1              pay_element_entry_values_f.screen_entry_value%type;
                    l_value2              pay_element_entry_values_f.screen_entry_value%type;
                    l_value3              pay_element_entry_values_f.screen_entry_value%type;
                    l_amount1             pay_element_entry_values_f.screen_entry_value%type;
                    l_amount2             pay_element_entry_values_f.screen_entry_value%type;
                    l_date1               pay_element_entry_values_f.screen_entry_value%type;
                    l_date2               pay_element_entry_values_f.screen_entry_value%type;
                    l_business_group_id   per_business_groups.business_group_id%type;
                    l_input_value_id1     pay_input_values_f.input_value_id%type;
                    l_input_value_id2     pay_input_values_f.input_value_id%type;
                    l_input_value_id3     pay_input_values_f.input_value_id%type;
                    l_element_entry_id      pay_element_entries_f.element_entry_id%type;
                    l_object_version_number pay_element_entries_f.object_version_number%type;
                    l_update_mode          VARCHAR2(25);
                    l_ctr		           NUMBER;
                    l_element_ctr	       NUMBER;
                    l_update_warning        boolean;
                    l_effective_start_date  date;
                    l_effective_end_date    date;

                BEGIN

                    l_ctr := 0;
                    for c_business_group_rec in c_business_group (p_assignment_id, p_effective_date)
                    loop
                        l_business_group_id    := c_business_group_rec.business_group_id;
                        exit;
                    end loop;

                    FOR c_incdet_rec IN c_inc_catg_details(p_pa_request_id)
                    LOOP
                        l_ctr := l_ctr + 1;
                        IF l_ctr = 1 THEN
                            l_amount1 := c_incdet_rec.amount;
                            l_date1   := fnd_date.date_to_displaydate(c_incdet_rec.payment_date);
                        ELSE -- ie. l_ctr =2
                            l_amount2 := c_incdet_rec.amount;
                            l_date2   :=  fnd_date.date_to_displaydate(c_incdet_rec.payment_date);
                        END IF;
                    END LOOP;

                    l_ctr := 0;
                    l_element_ctr := 0;

                    FOR c_ele_info_rec IN c_nonrec_incntv_ele_info('Separation Incentive Lump Sum'
                                                                   ,p_assignment_id
                                                                   ,p_effective_date
                                                                   ,l_business_group_id)
                    LOOP
                        l_ctr := l_ctr + 1;
                        IF l_ctr <= 3 THEN
                            l_element_entry_id      := c_ele_info_rec.element_entry_id;
                            l_object_version_number := c_ele_info_rec.object_version_number;

                            IF c_ele_info_rec.name = 'Amount'  THEN
                                l_input_value_id1 := c_ele_info_rec.input_value_id;
                                l_value1          := c_ele_info_rec.screen_entry_value;
                            ELSIF c_ele_info_rec.name = 'Payment Date' THEN
                                l_input_value_id2 := c_ele_info_rec.input_value_id;
                                l_value2          := c_ele_info_rec.screen_entry_value;
                            ELSIF c_ele_info_rec.name = 'Payment Option' THEN
                                l_input_value_id3 := c_ele_info_rec.input_value_id;
                                l_value3          := c_ele_info_rec.screen_entry_value;
                            END IF;

                            IF l_ctr = 3 THEN

                                BEGIN
                                   l_element_ctr := l_element_ctr + 1;
                                   IF l_element_ctr = 1 THEN
                                        l_value1  := NVL(l_amount1,l_value1);
                                        l_value2  := NVL(l_date1, l_value2);
                                    ELSIF l_element_ctr = 2 THEN
                                        l_value1  := NVL(l_amount2,l_value1);
                                        l_value2  := NVL(l_date2, l_value2);
                                    END IF;
                                    savepoint upd_ent;
                                    l_update_mode  :=  'CORRECTION';
                                    py_element_entry_api.update_element_entry
                                        (p_datetrack_update_mode        => l_update_mode
                                        ,p_effective_date               => p_effective_date
                                        ,p_business_group_id            => l_business_group_id
                                        ,p_element_entry_id             => l_element_entry_id
                                        ,p_object_version_number        => l_object_version_number
                                        ,p_input_value_id1              => l_input_value_id1
                                        ,p_entry_value1                 => l_value1
                                        ,p_input_value_id2              => l_input_value_id2
                                        ,p_entry_value2                 => l_value2
                                        ,p_input_value_id3              => l_input_value_id3
                                        ,p_entry_value3                 => l_value3
                                        ,p_effective_start_date         => l_effective_start_date
                                        ,p_effective_end_date           => l_effective_end_date
                                        ,p_update_warning               => l_update_warning);

                                         create_incentive_remark(p_pa_request_id => p_pa_request_id,
                                            p_effective_date => p_effective_date,
                                            p_category      => 'Installment '||to_char(l_element_ctr),
                                            p_noa_code      => '825',
                                            p_percent       => NULL,
                                            p_amount        => l_value1,
                                            p_payment_date  => l_value2,
                                            p_end_date      => NULL);
                                Exception
                                    when others then
                                    rollback to upd_ent;
                                    raise;
                                End;
                                l_ctr := 0;
                            END IF;
                        END IF;
                    END LOOP;
                END Upd_sep_incn_elements;


        -- Bug#4486823   RRR Changes
        -- This procedure processes the elements for Incentive Family.
        --  Depending on the user entry, the related elements will be processed.
        PROCEDURE process_incentive_elements(p_pa_request_id   IN ghr_pa_requests.pa_request_id%TYPE
                                            ,p_assignment_id   IN ghr_pa_requests.employee_assignment_id%TYPE
                                            ,p_effective_date  IN ghr_pa_requests.effective_date%TYPE
                                            ,p_payment_option  IN ghr_pa_requests.pa_incentive_payment_option%TYPE
                                            ,p_first_noa_code  IN ghr_pa_requests.first_noa_code%TYPE
                                            ,p_second_noa_code IN ghr_pa_requests.second_noa_code%TYPE
                                            ,p_total_amount    IN ghr_pa_requests.to_total_salary%TYPE
                                           ) IS

             Cursor c_inc_catg_details(l_pa_request_id NUMBER) IS
            SELECT pa_incentive_category,
                   pa_incentive_category_amount,
                   pa_incentive_category_percent,
                   pa_incentive_category_pmnt_dt,
                   pa_incentive_category_end_date
            FROM   ghr_pa_incentives
            where  pa_request_id = l_pa_request_id
            order by pa_incentive_category_pmnt_dt;

            l_installment_ctr NUMBER(10);
            l_payment_type    VARCHAR2(150);
            l_noa_code        VARCHAR2(150);
            l_session         ghr_history_api.g_session_var_type;

        BEGIN
	        hr_utility.set_location('Entering process_incentive_elements'||p_pa_request_id,0);
            l_installment_ctr := 0;
            ghr_history_api.get_g_session_var(l_session);
            IF l_session.noa_id_correct IS NOT NULL and
               p_payment_option = 'H' and
               (p_first_noa_code = '825' OR p_second_noa_code ='825') THEN
                    Upd_sep_incn_elements(p_pa_request_id
                                            ,p_assignment_id
                                            ,p_effective_date
                                            ,p_payment_option
                                            ,p_first_noa_code
                                            ,p_second_noa_code);
            ELSE
                FOR c_incdet_rec IN c_inc_catg_details(p_pa_request_id)
                LOOP
                    hr_utility.set_location('Inside For Loop, Category: '||c_incdet_rec.pa_incentive_category,10);
                    hr_utility.set_location('Inside For Loop, NOA Code: '||p_first_noa_code,20);
                    hr_utility.set_location('Inside For Loop, ASG ID  : '||p_assignment_id,30);
                    -- This is a special case. Till now, we have never created the same element twice in a
                    -- single RPA action. If process_sf52_element is called, only one of these two elements
                    -- will be updated with both the values.And the latest values will retain. To avoid that,
                    -- update the elements separately here itself.


                    IF c_incdet_rec.pa_incentive_category = 'Biweekly' THEN
                        l_payment_type := c_incdet_rec.pa_incentive_category;
                        IF  p_first_noa_code = '815' OR
                            (p_first_noa_code = '002' AND p_second_noa_code = '815') THEN
                             ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Recruitment Incentive Biweekly'
                            ,p_input_value_name1    =>    'Biweekly Amount'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_amount
                            ,p_input_value_name2    =>    'Total Amount'
                            ,p_value2               =>    p_total_amount
                            ,p_input_value_name3    =>    'Payment Option'
                            ,p_value3               =>    p_payment_option
                            ,p_input_value_name4    =>    'Payment Type'
                            ,p_value4               =>    l_payment_type
                            ,p_value15              =>    c_incdet_rec.pa_incentive_category_end_date
                            ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;
                        IF (p_first_noa_code = '816') OR
                            (p_first_noa_code = '002' AND p_second_noa_code = '816') THEN
                            ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Relocation Incentive Biweekly'
                            ,p_input_value_name1    =>    'Biweekly Amount'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_amount
                            ,p_input_value_name2    =>    'Total Amount'
                            ,p_value2               =>    p_total_amount
                            ,p_input_value_name3    =>    'Payment Option'
                            ,p_value3               =>    p_payment_option
                            ,p_input_value_name4    =>    'Payment Type'
                            ,p_value4               =>    l_payment_type
                            ,p_value15              =>    c_incdet_rec.pa_incentive_category_end_date
                            ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;

                        -- Bug#3941541 Separation Incentive Elements.
                        IF (p_first_noa_code = '825') OR
                           (p_second_noa_code = '825') OR
                           (p_first_noa_code = '002' AND p_second_noa_code = '825') THEN
                            ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Separation Incentive Biweekly'
                            ,p_input_value_name1    =>    'Biweekly Amount'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_amount
                            ,p_input_value_name2    =>    'Total Amount'
                            ,p_value2               =>    p_total_amount
                            ,p_input_value_name3    =>    'Payment Start Date'
                            ,p_value3               =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_input_value_name4    =>    'Payment End Date'
                            ,p_value4               =>    c_incdet_rec.pa_incentive_category_end_date
                            ,p_effective_date       =>    p_effective_date
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;
                        -- End of Bug#3941541

                        IF (p_first_noa_code = '827') OR
                           (p_first_noa_code = '002' AND p_second_noa_code = '827') THEN
                           -- Bug#5039100
        --This code is commented for the bug#5307606
/*                           IF p_payment_option = 'B' AND c_incdet_rec.pa_incentive_category_percent = 0 THEN
                                ghr_element_api.process_sf52_element
                                (p_assignment_id        =>    p_assignment_id
                                ,p_element_name         =>    'Retention Incentive Biweekly'
                                ,p_input_value_name1    =>    'Percent'
                                ,p_value1               =>    c_incdet_rec.pa_incentive_category_percent
                                ,p_input_value_name2    =>    'Payment Option'
                                ,p_value2               =>    p_payment_option
                                ,p_input_value_name3    =>    'Payment Type'
                                ,p_value3               =>    l_payment_type
                                ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                                ,p_process_warning      =>    l_warning
                                );

                           ELSE*/
        --This code is commented for the bug#5307606

                                ghr_element_api.process_sf52_element
                                (p_assignment_id        =>    p_assignment_id
                                ,p_element_name         =>    'Retention Incentive Biweekly'
                                ,p_input_value_name1    =>    'Percent'
                                ,p_value1               =>    c_incdet_rec.pa_incentive_category_percent
                                ,p_input_value_name2    =>    'Payment Option'
                                ,p_value2               =>    p_payment_option
                                ,p_input_value_name3    =>    'Payment Type'
                                ,p_value3               =>    l_payment_type
                                ,p_value15              =>    c_incdet_rec.pa_incentive_category_end_date
                                ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                                ,p_process_warning      =>    l_warning
                                );
--                            END IF;  --This code is commented for the bug#5307606
                        END IF;
                    ELSE
                        IF c_incdet_rec.pa_incentive_category = 'Installment' THEN
                            l_installment_ctr := l_installment_ctr + 1;
                            l_payment_type := c_incdet_rec.pa_incentive_category ||' '|| to_char(l_installment_ctr);
                        ELSE
                            l_payment_type := c_incdet_rec.pa_incentive_category ;
                        END IF;
                        IF  p_first_noa_code = '815' OR
                            (p_first_noa_code = '002' AND p_second_noa_code = '815') THEN
                             ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Recruitment Incentive Lump Sum'
                            ,p_input_value_name1    =>    'Percent'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_percent
                            ,p_input_value_name2    =>    'Amount'
                            ,p_value2               =>    c_incdet_rec.pa_incentive_category_amount
                            ,p_input_value_name3    =>    'Payment Option'
                            ,p_value3               =>    p_payment_option
                            ,p_input_value_name4    =>    'Payment Type'
                            ,p_value4               =>    l_payment_type
                            ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;
                        IF (p_first_noa_code = '816') OR
                            (p_first_noa_code = '002' AND p_second_noa_code = '816') THEN
                            ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Relocation Incentive Lump Sum'
                            ,p_input_value_name1    =>    'Percent'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_percent
                            ,p_input_value_name2    =>    'Amount'
                            ,p_value2               =>    c_incdet_rec.pa_incentive_category_amount
                            ,p_input_value_name3    =>    'Payment Option'
                            ,p_value3               =>    p_payment_option
                            ,p_input_value_name4    =>    'Payment Type'
                            ,p_value4               =>    l_payment_type
                            ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;

                         -- Bug#3941541 Separation Incentive Elements.
                        IF (p_first_noa_code = '825') OR
                           (p_second_noa_code = '825') OR
                           (p_first_noa_code = '002' AND p_second_noa_code = '825') THEN
                            ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Separation Incentive Lump Sum'
                            ,p_input_value_name1    =>    'Amount'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_amount
                            ,p_input_value_name2    =>    'Payment Date'
                            ,p_value2               =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_input_value_name3    =>    'Payment Option'
                            ,p_value3               =>    p_payment_option
                            ,p_effective_date       =>    p_effective_date
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;
                        -- End of Bug#3941541

                        IF (p_first_noa_code = '827') OR
                           (p_first_noa_code = '002' AND p_second_noa_code = '827') THEN
                            ghr_element_api.process_sf52_element
                            (p_assignment_id        =>    p_assignment_id
                            ,p_element_name         =>    'Retention Incentive Lump Sum'
                            ,p_input_value_name1    =>    'Percent'
                            ,p_value1               =>    c_incdet_rec.pa_incentive_category_percent
                            ,p_input_value_name2    =>    'Payment Option'
                            ,p_value2               =>    p_payment_option
                            ,p_input_value_name3    =>    'Payment Type'
                            ,p_value3               =>    l_payment_type
                            ,p_effective_date       =>    c_incdet_rec.pa_incentive_category_pmnt_dt
                            ,p_process_warning      =>    l_warning
                            );
                        END IF;
                    END IF;
                    IF p_first_noa_code IN ('001','002') THEN
                        l_noa_code := p_second_noa_code;
                    ELSE
                        l_noa_code := p_first_noa_code;
                    END IF;
                    create_incentive_remark(p_pa_request_id => p_pa_request_id,
                                            p_effective_date => p_effective_date,
                                            p_category      => l_payment_type,
                                            p_noa_code      => l_noa_code,
                                            p_percent       => c_incdet_rec.pa_incentive_category_percent,
                                            p_amount        => c_incdet_rec.pa_incentive_category_amount,
                                            p_payment_date  => c_incdet_rec.pa_incentive_category_pmnt_dt,
                                            p_end_date      => c_incdet_rec.pa_incentive_category_end_date);

                END LOOP;
            END IF;
        END process_incentive_elements;

Begin

 --
 -- Remember IN OUT parameter IN values
 --
 l_recruitment_bonus           := p_recruitment_bonus;
 l_relocation_bonus            := p_relocation_bonus;
 l_student_loan_repay          := p_student_loan_repay;

 l_gov_award                   := p_gov_award;
 l_entitlement                 := p_entitlement;
 l_foreign_lang_prof_pay       := p_foreign_lang_prof_pay;
 -- Bug# 3385386
 l_fta                         := p_fta;
 l_edp_pay                     := p_edp_pay;
 l_hazard_pay                  := p_hazard_pay;
 l_health_benefits             := p_health_benefits;
 l_danger_pay                  := p_danger_pay;
 l_imminent_danger_pay         := p_imminent_danger_pay;
 l_living_quarters_allow       := p_living_quarters_allow;
 l_post_diff_amt               := p_post_diff_amt;
 l_post_diff_percent           := p_post_diff_percent;
 l_sep_maintenance_allow       := p_sep_maintenance_allow;
 l_supplemental_post_allow     := p_supplemental_post_allow;
 l_temp_lodge_allow            := p_temp_lodge_allow;
 l_premium_pay                 := p_premium_pay;
 l_retirement_annuity          := p_retirement_annuity;
 l_severance_pay               := p_severance_pay;
 l_thrift_saving_plan          := p_thrift_saving_plan;
 l_health_ben_pre_tax          := p_health_ben_pre_tax;

--
--
  If p_pa_request_rec.first_noa_code = '866' then
    l_effective_date  :=   trunc(p_pa_request_rec.effective_date + 1 );
  Else
    l_effective_date  :=   trunc(p_pa_request_rec.effective_date);
  End if;
-------Bug 5913362 -- Adding 890
/**** Here for 890 date is not like 866.
   if p_pa_request_rec.first_noa_code = '890' AND
      p_pa_request_rec.input_pay_rate_determinant in ('A','B','E','F','U','V') then
     l_effective_date  :=   trunc(p_pa_request_rec.effective_date + 1 );
   Else
     l_effective_date  :=   trunc(p_pa_request_rec.effective_date);
   End if;
****/

  hr_utility.set_location('Entering  ' || l_proc,5);
  -- Processing  FEGLI

  --
  If p_pa_request_rec.fegli is not null then
     hr_utility.set_location(l_proc,10);
         -- BEN_EIT Changes Commented the following code
	     -- as input value2 is moved to Benefits EIT
	    /* -- Bug 3238026 Added condition for CHG_FEGLI
         IF (p_pa_request_rec.noa_family_code = 'CHG_FEGLI') THEN
                hr_utility.set_location('Entering IF fegli',123456);
                  ghr_element_api.process_sf52_element
                (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
                ,p_element_name         =>      'FEGLI'
                ,p_input_value_name1    =>      'FEGLI'
                        -- Bug#2759379  Added Input Value2 here.
                ,p_input_value_name2    =>      'Eligibility Expiration'
                ,p_value2               =>
                fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_fegli.eligibility_expiration))
                ,p_value1               =>      p_pa_request_rec.fegli
                ,p_effective_date       =>      l_effective_date
                ,p_process_warning      =>      l_warning
                );
        ELSE
	    */
                hr_utility.set_location('Entering ELSE fegli',123456);
                  ghr_element_api.process_sf52_element
                (p_assignment_id          =>    p_pa_request_rec.employee_assignment_id
                ,p_element_name           =>    'FEGLI'
                ,p_input_value_name1      =>    'FEGLI'
                ,p_value1                 =>    p_pa_request_rec.fegli
                ,p_effective_date         =>      l_effective_date
                ,p_process_warning        =>    l_warning
                  );
        -- END IF;
        -- End Bug 3238026

  /* To be included after Martin Reid's element api handles the create and update warning
    if l_fegli_warn = FALSE then
       hr_utility.set_message(8301,'GHR_38141_FAIL_TO_UPD_FEGLI');
         hr_utility.raise_error;
    end if;
  */
  END IF;
  --
  -- Processing  retirement plan
  --
  If p_pa_request_rec.retirement_plan is not null then
      hr_utility.set_location(l_proc,20);
      ghr_element_api.process_sf52_element
        (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>      'Retirement Plan'
        ,p_input_value_name1    =>      'Plan'
        ,p_value1                     =>         p_pa_request_rec.retirement_plan
        ,p_effective_date               =>      l_effective_date
        ,p_process_warning      =>      l_warning
      );
  --
     /*
     if l_retirement_plan_warn = FALSE then
        hr_utility.set_message(8301,'GHR_38142_FAIL_TO_UPD_RET_PLN');
          hr_utility.raise_error;
     end if;
     */
  end if;
  --
  --
  -- Processing  recruitment bonus
  --
  If p_recruitment_bonus.p_recruitment_bonus is not null or
     p_recruitment_bonus.p_date_recruit_exp  is not null  then
      hr_utility.set_location(l_proc,30);
      hr_utility.set_location(l_proc || p_recruitment_bonus.p_date_recruit_exp,31);
      hr_utility.set_location(l_proc ||to_char(p_pa_request_rec.employee_assignment_id),35);
      ghr_element_api.process_sf52_element
      (p_assignment_id          =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>      'Recruitment Bonus'
        ,p_input_value_name1    =>      'Amount'
        ,p_value1                       =>      p_recruitment_bonus.p_recruitment_bonus
        ,p_input_value_name2    =>      'Expiration Date'
        ,p_value2                       =>
             fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_recruitment_bonus.p_date_recruit_exp)) --AVR
		  ,p_input_value_name3    =>      'Percentage'
        ,p_value3               =>      p_recruitment_bonus.p_percentage

        ,p_effective_date               =>      l_effective_date
        ,p_process_warning      =>      l_warning
      );

    /*
    if l_recruitment_bonus_warn = FALSE then
      hr_utility.set_message(8301,'GHR_38143_FAIL_TO_UPD_RCRT_BON');
        hr_utility.raise_error;
    end if;
    */
  end if;
  --
  -- Processing  relocation bonus
  --
  hr_utility.set_location('Rel. Bonus' || p_relocation_bonus.p_relocation_bonus,1);
  If p_relocation_bonus.p_relocation_bonus  is not null or
    p_relocation_bonus.p_date_reloc_exp    is not null  then
     hr_utility.set_location(l_proc,40);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name       =>        'Relocation Bonus'
        ,p_input_value_name1    =>      'Amount'
        ,p_value1                       =>       p_relocation_bonus.p_relocation_bonus
        ,p_input_value_name2    =>      'Expiration Date'
        ,p_value2                     =>
            fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_relocation_bonus.p_date_reloc_exp)) --AVR
		  ,p_input_value_name3    =>      'Percentage'
        ,p_value3               =>      p_relocation_bonus.p_percentage
        ,p_effective_date               =>      l_effective_date
        ,p_process_warning      =>      l_warning
     );
  --
  /*
   if l_relocation_bonus_warn = FALSE then
      hr_utility.set_message(8301,'GHR_38144_FAIL_TO_UPD_REL_BON');
      hr_utility.raise_error;
   end if;
  */
  end if;
  --
-- Student Loan Repayment Changes
  If p_pa_request_rec.first_noa_code = '817' or p_pa_request_rec.second_noa_code = '817' then
  If p_student_loan_repay.p_amount is not null or
    p_student_loan_repay.p_review_date is not null  then
         IF (p_student_loan_repay.p_repay_schedule = 'L') THEN
	     hr_utility.set_location(l_proc,40);
	     ghr_element_api.process_sf52_element
		(p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
	        ,p_element_name       =>        'Student Loan Repayment LumpSum'
		,p_input_value_name1    =>      'Amount'
	        ,p_value1               =>       p_student_loan_repay.p_amount
		,p_input_value_name2    =>      'Review Date'
	        ,p_value2                     =>
		    fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_student_loan_repay.p_review_date))
	        ,p_effective_date               =>      l_effective_date
		,p_process_warning      =>      l_warning
	     );
         ELSIF (p_student_loan_repay.p_repay_schedule = 'R') THEN
	     hr_utility.set_location(l_proc,40);
	     ghr_element_api.process_sf52_element
		(p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
	        ,p_element_name       =>        'Student Loan Repayment'
		,p_input_value_name1    =>      'Amount'
	        ,p_value1               =>       (p_student_loan_repay.p_amount)
		,p_input_value_name2    =>      'Review Date'
	        ,p_value2                     =>
		    fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_student_loan_repay.p_review_date))
	        ,p_effective_date               =>      l_effective_date
		,p_process_warning      =>      l_warning
	     );
	 END IF;
  --
  end if;
 END IF;
 --
  -- processing awards_bonus
  --
  If  p_gov_award.award_flag = 'Y' then
     hr_utility.set_location(l_proc,50);
     hr_utility.set_location('Date awRd' || p_gov_award.date_award_earned,1);
     hr_utility.set_location('Award Agency ' || p_gov_award.award_Agency,1);
     hr_utility.set_location('Award Percentage ' || p_pa_request_rec.award_percentage,1);
     hr_utility.set_location('Date Exemp' || p_gov_award.date_exemp_award,1);
-- Bug # 1061084
     hr_utility.set_location('Appropriation Code' || p_gov_award.award_appropriation_code,1);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>      p_pa_request_rec.employee_assignment_id
        ,p_element_name         => 'Federal Awards'
        ,p_input_value_name1    =>      'Award Agency'
        ,p_value1               =>       p_gov_award.award_agency
        ,p_input_value_name2    =>      'Award Type'
        ,p_value2               =>      p_gov_award.award_type
      ,p_input_value_name3    =>    'Amount or Hours'
      ,p_value3               =>    p_pa_request_rec.award_amount
      ,p_input_value_name4      =>      'Percentage'
        ,p_value4                       =>      p_pa_request_rec.award_percentage
        ,p_input_value_name5    =>      'Group Award'
        ,p_value5                     =>        p_gov_award.group_award
        ,p_input_value_name6    =>      'Tangible Benefit Dollars'
        ,p_value6                     =>        p_gov_award.tangible_benefit_dollars
      ,p_input_value_name8    =>    'Date Award Earned'
      ,p_value8               =>
             fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_gov_award.date_award_earned)) --AVR
        ,p_input_value_name9    =>      'Appropriation Code'
        ,p_value9                     =>        p_gov_award.award_appropriation_code
      ,p_input_value_name10   =>    'Date Ex Emp Award Paid'
      ,p_value10              =>
             fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_gov_award.date_exemp_award))
        ,p_effective_date               =>      l_effective_date
        ,p_process_warning      =>      l_warning
      );
  End if;
  --
  -- process entitlement
  --
  if p_entitlement.entitlement_flag = 'Y' then
     hr_utility.set_location(l_proc,60);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'Entitlement'
        ,p_input_value_name1    =>    'Code'
        ,p_value1               =>    p_entitlement.entitlement_code
        ,p_input_value_name2    =>    'Amount or Percent'
        ,p_value2               =>    p_entitlement.entitlement_amt_percent
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process foreign lang profiency pay
  --
  if p_foreign_lang_prof_pay.for_lang_flag = 'Y' then
     hr_utility.set_location(l_proc,70);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Foreign Lang Proficiency Pay'
        ,p_input_value_name1    =>    'Certification Date'
        ,p_value1               =>
         fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_foreign_lang_prof_pay.certification_date)) --AVR
        ,p_input_value_name2    =>    'Pay Level or Rate'
        ,p_value2               =>    p_foreign_lang_prof_pay.pay_level_or_rate
        ,p_effective_date             =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- Bug#3385386 process foreign Transfer Allowance(FTA) element
  --
  if p_fta.fta_flag = 'Y' then
     hr_utility.set_location(l_proc,75);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Foreign Transfer Allowance'
        ,p_input_value_name1    =>    'Last Action Code'
        ,p_value1               =>     p_fta.last_action_code
        ,p_input_value_name2    =>    'Number Family Members'
        ,p_value2               =>    p_fta.number_family_members
        ,p_input_value_name3    =>    'Miscellaneous Expense'
        ,p_value3               =>    p_fta.Miscellaneous_Expense
        ,p_input_value_name4    =>    'Wardrobe Expense'
        ,p_value4               =>    p_fta.Wardrobe_Expense
        ,p_input_value_name5    =>    'Pre Departure Sub Expense'
        ,p_value5               =>    p_fta.Pre_Departure_Subs_Expense
        ,p_input_value_name6    =>    'Lease Penalty Expense'
        ,p_value6               =>   p_fta.Lease_Penalty_Expense
        ,p_input_value_name7    =>    'Amount'
        ,p_value7               =>    p_fta.amount
	,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process edp pay
  --
  if p_edp_pay.edp_flag = 'Y' then
     hr_utility.set_location(l_proc,80);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'EDP Pay'
        ,p_input_value_name1    =>    'Premium Pay Ind'
        ,p_value1               =>    p_edp_pay.premium_pay_indicator
        ,p_input_value_name2    =>    'EDP Type'
        ,p_value2               =>    p_edp_pay.edp_type
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  --
  -- process hazard pay
  --
  if p_hazard_pay.hazard_flag = 'Y' then
     hr_utility.set_location(l_proc,85);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'Hazard Pay'
        ,p_input_value_name1    =>    'Premium Pay Ind'
        ,p_value1               =>    p_hazard_pay.premium_pay_indicator
        ,p_input_value_name2    =>    'Hazard Type'
        ,p_value2               =>    p_hazard_pay.hazard_type
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process health benefits
  -- Sundar Benefits EIT Enhancement
  if p_health_benefits.health_benefits_flag = 'Y' then
     hr_utility.set_location(l_proc,90);
	 IF ghr_utility.is_ghr_ben_fehb = 'TRUE' THEN
			NULL;
	 ELSE
			 ghr_element_api.process_sf52_element
				(p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
				,p_element_name         =>    'Health Benefits'
				,p_input_value_name1    =>    'Enrollment'
				,p_value1               =>    p_health_benefits.enrollment
				,p_input_value_name2    =>    'Health Plan'
				,p_value2               =>    p_health_benefits.health_plan
				,p_input_value_name3    =>    'Temps Total Cost'
				,p_value3               =>    p_health_benefits.temps_total_cost
				,p_input_value_name4    =>    'Pre tax Waiver'
				,p_value4               =>    p_health_benefits.pre_tax_waiver
				,p_effective_date       =>    l_effective_date
				,p_process_warning      =>    l_warning
			  );
	END IF; -- IF ghr_utility.is_ghr_ben_fehb THEN
  end if;
  --
  --
  -- process health benefits pre tax
  --
  if p_health_ben_pre_tax.health_ben_pre_tax_flag = 'Y' then
     hr_utility.set_location(l_proc,90);
	 IF ghr_utility.is_ghr_ben_fehb = 'TRUE' THEN
		NULL;
	 ELSE
			 ghr_element_api.process_sf52_element
				(p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
				,p_element_name         =>    'Health Benefits Pre tax'
				,p_input_value_name1    =>    'Enrollment'
				,p_value1               =>    p_health_ben_pre_tax.enrollment
				,p_input_value_name2    =>    'Health Plan'
				,p_value2               =>    p_health_ben_pre_tax.health_plan
				,p_input_value_name3    =>    'Temps Total Cost'
				,p_value3               =>    p_health_ben_pre_tax.temps_total_cost
				,p_effective_date       =>    l_effective_date
				,p_process_warning      =>    l_warning
			  );
	  END IF; -- IF ghr_utility.is_ghr_ben_fehb = TRUE THEN
  end if;
  --
  -- process danger pay
  --
  if p_danger_pay.danger_flag = 'Y' then
     hr_utility.set_location(l_proc,100);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Danger Pay'
        ,p_input_value_name1    =>    'Last Action Code'
        ,p_value1               =>    p_danger_pay.last_action_code
        ,p_input_value_name2    =>    'Location'
        ,p_value2               =>    p_danger_pay.location
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process imminent danger pay
  --
  if p_imminent_danger_pay.imminent_danger_flag = 'Y' then
     hr_utility.set_location(l_proc,110);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'Imminent Danger Pay'
        ,p_input_value_name1    =>    'Amount'
        ,p_value1               =>    p_imminent_danger_pay.amount
        ,p_input_value_name2    =>    'Last Action Code'
        ,p_value2               =>    p_imminent_danger_pay.last_action_code
        ,p_input_value_name3    =>    'Location'
        ,p_value3               =>    p_imminent_danger_pay.location
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process living_quarters_allow
  --
  if p_living_quarters_allow.living_quarters_allow_flag = 'Y' then
     hr_utility.set_location(l_proc,120);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'Living Quarters Allowance'
        ,p_input_value_name1    =>    'Purchase Amount'
        ,p_value1               =>    p_living_quarters_allow.purchase_amount
        ,p_input_value_name2    =>    'Purchase Date'
        ,p_value2               =>
         fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_living_quarters_allow.purchase_date)) --AVR
        ,p_input_value_name3    =>    'Rent Amount'
        ,p_value3               =>    p_living_quarters_allow.rent_amount
        ,p_input_value_name4    =>    'Utility Amount'
        ,p_value4               =>    p_living_quarters_allow.utility_amount
        ,p_input_value_name5    =>    'Last Action Code'
        ,p_value5               =>    p_living_quarters_allow.last_action_code
        ,p_input_value_name6    =>    'Location'
        ,p_value6               =>    p_living_quarters_allow.location
        ,p_input_value_name7    =>    'Quarters Type'
        ,p_value7               =>    p_living_quarters_allow.quarters_type
        ,p_input_value_name8    =>    'Shared Percent'
        ,p_value8               =>    p_living_quarters_allow.shared_percent
        ,p_input_value_name9    =>    'Num Family Members'
        ,p_value9               =>    p_living_quarters_allow.no_of_family_members
        ,p_input_value_name10    =>   'Summer Record Ind'
        ,p_value10               =>   p_living_quarters_allow.summer_record_ind
        ,p_input_value_name11    =>   'Quarters Group'
        ,p_value11               =>   p_living_quarters_allow.quarters_group
        ,p_input_value_name12    =>   'Currency'
        ,p_value12               =>   p_living_quarters_allow.currency
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process post differential amount
  --
  if p_post_diff_amt.post_diff_amt_flag  = 'Y' then
     hr_utility.set_location(l_proc,130);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
   --     ,p_element_name         =>    'Post Differential Amount' -- Bug 2645878 Elements renamed
        ,p_element_name         =>    'Post Allowance'
        ,p_input_value_name1    =>    'Amount'
        ,p_value1               =>    p_post_diff_amt.amount
        ,p_input_value_name2    =>    'Last Action Code'
        ,p_value2               =>    p_post_diff_amt.last_action_code
        ,p_input_value_name3    =>    'Location'
        ,p_value3               =>    p_post_diff_amt.location
        ,p_input_value_name4    =>    'Num Family Members'
        ,p_value4               =>    p_post_diff_amt.no_of_family_members
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process post differential percent
  --
  if p_post_diff_percent.post_diff_percent_flag  = 'Y' then
     hr_utility.set_location(l_proc,140);
     hr_utility.set_location('subbu'||p_post_diff_percent.percent,141);
     hr_utility.set_location('subbu'||p_post_diff_percent.last_action_code,142);
     hr_utility.set_location('subbu'||p_post_diff_percent.location,143);

     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
--        ,p_element_name         =>    'Post Differential Percent' -- Bug 2645878 Element renamed
        ,p_element_name         =>    'Post Differential'
        ,p_input_value_name1    =>    'Percentage'
        ,p_value1               =>    p_post_diff_percent.percent
        ,p_input_value_name2    =>    'Last Action Code'
        ,p_value2               =>    p_post_diff_percent.last_action_code
        ,p_input_value_name3    =>    'Location'
        ,p_value3               =>    p_post_diff_percent.location
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process sep_maintenance_allow
  --
  if p_sep_maintenance_allow.sep_maint_allow_flag  = 'Y' then
     hr_utility.set_location(l_proc,150);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'Separate Maintenance Allowance'
        ,p_input_value_name1    =>    'Amount'
        ,p_value1               =>    p_sep_maintenance_allow.amount
        ,p_input_value_name2    =>    'Last Action Code'
        ,p_value2               =>    p_sep_maintenance_allow.last_action_code
        ,p_input_value_name3    =>    'Category'
        ,p_value3               =>    p_sep_maintenance_allow.category
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process supplemental_post_allow
  --
  if p_supplemental_post_allow.sup_post_allow_flag  = 'Y' then
     hr_utility.set_location(l_proc,160);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Supplemental Post Allowance'
        ,p_input_value_name1    =>    'Amount'
        ,p_value1               =>    p_supplemental_post_allow.amount
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process temp_lodge_allow
  --
  if p_temp_lodge_allow.temp_lodge_allow_flag  = 'Y' then
     hr_utility.set_location(l_proc,170);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Temporary Lodging Allowance'
        ,p_input_value_name1    =>    'Allowance Type'
        ,p_value1               =>    p_temp_lodge_allow.allowance_type
        ,p_input_value_name2    =>    'Daily Rate'
        ,p_value2               =>    p_temp_lodge_allow.daily_rate
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process premium_pay
  --
  if p_premium_pay.premium_pay_flag  = 'Y' then
     hr_utility.set_location(l_proc,180);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Premium Pay'
        ,p_input_value_name1    =>    'Premium Pay Ind'
        ,p_value1               =>    p_premium_pay.premium_pay_ind
        ,p_input_value_name2    =>    'Amount'
        ,p_value2               =>    p_premium_pay.amount
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process retirement_annuity
  --
  if p_retirement_annuity.retirement_annuity_flag  = 'Y' then
     hr_utility.set_location(l_proc,190);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>   'Retirement Annuity'
        ,p_input_value_name1    =>    'Sum'
        ,p_value1               =>    p_retirement_annuity.annuity_sum
        ,p_input_value_name2    =>    'Eligibility Expires'
        ,p_value2               =>
         fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_retirement_annuity.eligibility_expires)) --AVR
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process severance_pay
  --
  if p_severance_pay.severance_pay_flag  = 'Y' then
     hr_utility.set_location(l_proc,200);
     ghr_element_api.process_sf52_element
        (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
        ,p_element_name         =>    'Severance Pay'
        ,p_input_value_name1    =>    'Amount'
        ,p_value1               =>    p_severance_pay.amount
        ,p_input_value_name2    =>    'Total Entitlement Weeks'
        ,p_value2               =>    p_severance_pay.total_entitlement_weeks
        ,p_input_value_name3    =>    'Number Weeks Paid'
        ,p_value3               =>    p_severance_pay.number_weeks_paid
        ,p_input_value_name4    =>    'Weekly Amount'
        ,p_value4               =>    p_severance_pay.weekly_amount
        ,p_effective_date       =>    l_effective_date
        ,p_process_warning      =>    l_warning
      );
  end if;
  --
  -- process thrift_saving_plan
  --
  if p_thrift_saving_plan.tsp_flag  = 'Y' then
     hr_utility.set_location(l_proc,210);
	 IF ghr_utility.is_ghr_ben_tsp = 'TRUE' THEN
			 NULL;
	 ELSE
             -- Bug#4582970 Removed Agncy Elig Date, Emp Elig Date values.
			 ghr_element_api.process_sf52_element
				(p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
				,p_element_name         =>  'TSP'
				,p_input_value_name1    =>    'Amount'
				,p_value1               =>    p_thrift_saving_plan.amount
				,p_input_value_name2    =>    'Rate'
				,p_value2               =>    p_thrift_saving_plan.rate
				,p_input_value_name6    =>    'Status'
				,p_value6               =>    p_thrift_saving_plan.status
				,p_input_value_name7    =>    'Status Date'
				,p_value7               =>
				 fnd_date.date_to_displaydate(fnd_date.canonical_to_date(p_thrift_saving_plan.status_date)) --AVR
				,p_effective_date       =>    l_effective_date
				,p_process_warning      =>    l_warning
			  );
	  END IF; -- IF ghr_utility.is_ghr_ben_tsp
  end if;
  --
  --Pradeep.
     --Process MDDDS Special Pay
      if p_mddds_special_pay.mddds_special_pay_flag = 'Y' then
        hr_utility.set_location(l_proc,215);

	--Bug 3531369
	p_mddds_special_pay.amount := NVL(p_mddds_special_pay.Full_Time_Status,0) + NVL(p_mddds_special_pay.Length_of_Service,0) +
					 NVL(p_mddds_special_pay.Scarce_Specialty,0) + NVL(p_mddds_special_pay.Specialty_or_Board_Cert,0) +
					 NVL(p_mddds_special_pay.Geographic_Location,0) + NVL(p_mddds_special_pay.Exceptional_Qualifications,0) +
					 NVL(p_mddds_special_pay.Executive_Position,0) + NVL(p_mddds_special_pay.Dentist_post_graduate_training,0);
        --Bug 3531369
        ghr_element_api.process_sf52_element
           (p_assignment_id        =>    p_pa_request_rec.employee_assignment_id
           ,p_element_name         =>    'MDDDS Special Pay'
           ,p_input_value_name1    =>    'Full Time Status'
           ,p_value1               =>    p_mddds_special_pay.Full_Time_Status
           ,p_input_value_name2    =>    'Length of Service'
           ,p_value2               =>    p_mddds_special_pay.Length_of_Service
           ,p_input_value_name3    =>    'Scarce Specialty'
           ,p_value3               =>    p_mddds_special_pay.Scarce_Specialty
           ,p_input_value_name4    =>    'Specialty or Board Certification'
           ,p_value4               =>    p_mddds_special_pay.Specialty_or_Board_Cert
           ,p_input_value_name5    =>    'Geographic Location'
           ,p_value5               =>    p_mddds_special_pay.Geographic_Location
           ,p_input_value_name6    =>    'Exceptional Qualifications'
           ,p_value6               =>    p_mddds_special_pay.Exceptional_Qualifications
           ,p_input_value_name7    =>    'Executive Position'
           ,p_value7               =>    p_mddds_special_pay.Executive_Position
           ,p_input_value_name8    =>    'Dentist Post Graduate Training'
           ,p_value8               =>    p_mddds_special_pay.Dentist_post_graduate_training
	   ,p_input_value_name9    =>    'Amount'
           ,p_value9               =>    p_mddds_special_pay.amount
           ,p_input_value_name10    =>    'MDDDS Special Pay NTE Date'
           ,p_value10               =>    fnd_date.date_to_displaydate(p_mddds_special_pay.mddds_special_pay_date)
           ,p_effective_date       =>    l_effective_date
           ,p_process_warning      =>    l_warning
         );
     end if;

     --
     --Pradeep
     If p_mddds_special_pay.premium_pay_ind is not null then
        hr_utility.set_location(l_proc,220);
        ghr_element_api.process_sf52_element
   	   (p_assignment_id     =>    p_pa_request_rec.employee_assignment_id
   	   ,p_element_name      =>    'Premium Pay'
   	   ,p_input_value_name1 =>    'Premium Pay Ind'
   	   --,p_value1            =>    p_premium_pay.premium_pay_ind
	   --Pradeep changed this as one EIT for both Premium pay and MD/DDS Special Pay
            ,p_value1            =>    p_mddds_special_pay.premium_pay_ind
   	   ,p_effective_date    =>    l_effective_date
   	   ,p_process_warning   =>    l_warning
   	   );
   end if;
  --

     --
     --Pradeep
     If p_premium_pay_ind.premium_pay_ind is not null then
        hr_utility.set_location(l_proc,225);
        ghr_element_api.process_sf52_element
   	   (p_assignment_id     =>    p_pa_request_rec.employee_assignment_id
   	   ,p_element_name      =>    'Premium Pay'
   	   ,p_input_value_name1 =>    'Premium Pay Ind'
   	   ,p_value1            =>    p_premium_pay_ind.premium_pay_ind
           ,p_effective_date    =>    l_effective_date
   	   ,p_process_warning   =>    l_warning
   	   );
     end if;


     -- Bug#4486823 RRR Changes
     -- Process Incentive elements
     hr_utility.set_location('first noa '||p_pa_request_rec.first_noa_code ||';second noa :'||p_pa_request_rec.second_noa_code,50);
     hr_utility.set_location('noa family :'||p_pa_request_rec.noa_family_code,55);
     IF (p_pa_request_rec.noa_family_code = 'GHR_INCENTIVE') OR
        (p_pa_request_rec.first_noa_code = '002' AND p_pa_request_rec.second_noa_desc like '%Incentive%') OR
	(p_pa_request_rec.first_noa_code = '825' OR p_pa_request_rec.second_noa_code = '825' ) THEN
        hr_utility.set_location('before calling process_incentive_elements'||p_pa_request_rec.pa_request_id,10);
        IF p_pa_request_rec.pa_incentive_payment_option = 'B' THEN
            l_total_salary := p_pa_request_rec.to_total_salary;
        ELSE
            l_total_salary := NULL;
        END IF;
        process_incentive_elements(p_pa_request_id => p_pa_request_rec.pa_request_id,
                                   p_assignment_id => p_pa_request_rec.employee_assignment_id,
                                   p_effective_date => p_pa_request_rec.effective_date,
                                   p_payment_option => p_pa_request_rec.pa_incentive_payment_option,
                                   p_first_noa_code => p_pa_request_rec.first_noa_code,
                                   p_second_noa_code => p_pa_request_rec.second_noa_code,
                                   p_total_amount    => l_total_salary
                                   );
     END IF;
  --

  hr_utility.set_location('Leaving ' ||l_proc,60);
  --
  Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_recruitment_bonus           := l_recruitment_bonus;
          p_relocation_bonus            := l_relocation_bonus;
	  p_student_loan_repay          := l_student_loan_repay;
          p_gov_award                   := l_gov_award;
          p_entitlement                 := l_entitlement;
          p_foreign_lang_prof_pay       := l_foreign_lang_prof_pay;
	  p_fta                         := l_fta;
          p_edp_pay                     := l_edp_pay;
          p_hazard_pay                  := l_hazard_pay;
          p_health_benefits             := l_health_benefits;
          p_danger_pay                  := l_danger_pay;
          p_imminent_danger_pay         := l_imminent_danger_pay;
          p_living_quarters_allow       := l_living_quarters_allow;
          p_post_diff_amt               := l_post_diff_amt;
          p_post_diff_percent           := l_post_diff_percent;
          p_sep_maintenance_allow       := l_sep_maintenance_allow;
          p_supplemental_post_allow     := l_supplemental_post_allow;
          p_temp_lodge_allow            := l_temp_lodge_allow;
          p_premium_pay                 := l_premium_pay;
          p_retirement_annuity          := l_retirement_annuity;
          p_severance_pay               := l_severance_pay;
          p_thrift_saving_plan          := l_thrift_saving_plan;
          p_health_ben_pre_tax          := l_health_ben_pre_tax;
          raise;

END Process_non_salary_Info;
--
--
--
Procedure get_wgi_dates
(p_pa_request_rec        in      ghr_pa_requests%rowtype,
 p_wgi_due_date          in out nocopy  date,
 p_wgi_pay_date          out nocopy     date,
 p_retained_grade_rec    out nocopy     ghr_pay_calc.retained_grade_rec_type,
 p_dlei			 in date
)
is

l_proc                varchar2(72) := 'get_wgi_dates';
l_initial_wgi_due_date date;
l_payroll_id          pay_payrolls_f.payroll_id%type;
l_eq_pay_plan         ghr_pay_plans.pay_plan%type;
l_from_step           ghr_pa_requests.to_step_or_rate%type;
l_wgi_due_Date        varchar2(60);
l_wgi_pay_date        date;
l_wait_period         ghr_pay_plan_waiting_periods.waiting_period%type;
l_pay_plan                  ghr_pay_plans.pay_plan%type;
l_step_or_rate        ghr_pa_requests.to_step_or_rate%type;
l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
l_maximum_step        ghr_pa_requests.to_step_or_rate%type;
l_grade_or_level      ghr_pa_requests.to_grade_or_level%type;
l_user_table_id       pay_user_tables.user_table_id%TYPE;

l_lei_date                    varchar2(60); -- Bug 3709414

Cursor c_payroll is
  select rei_information3 payroll_type
  from   ghr_pa_request_extra_info
  where  pa_request_id       =   p_pa_request_rec.pa_request_id
  and    information_type    =   'GHR_US_PAR_PAYROLL_TYPE';

Cursor c_payroll_id is
  select asg.payroll_id
  from   per_all_assignments_f asg
  where  asg.assignment_id = p_pa_request_rec.employee_assignment_id;

Cursor   c_equiv_pay_plan  is
  select gpp.equivalent_pay_plan,gpp.maximum_Step
  from   ghr_pay_plans gpp
  where  gpp.pay_plan         =  l_pay_plan
  and    gpp.wgi_enabled_flag = 'Y';                   -- **also check for WGI enabled flag
                                                     -- **calculate WGI only for eligible pay_plans and PRD
Cursor   c_next_step is                             -- ** WGI due date is null if the person has reached the max. step
  select gpw.to_step    -- l_from_step
  from   ghr_pay_plan_waiting_periods gpw
  where  gpw.from_Step  =  l_step_or_rate
  and    gpw.pay_plan   =  l_eq_pay_plan;  -- pay plan -????

Cursor   c_waiting_period is
  select gpw.waiting_period   -- l_wait_period
  from   ghr_pay_plan_waiting_periods gpw
  where  gpw.pay_plan  = l_eq_pay_plan
  and    gpw.from_step = l_from_step; -- p_pa_request_rec.to_step_or_rate


Cursor  c_next_pay_date is
  select ptp.start_Date
  from   per_time_periods ptp
  where  ptp.payroll_id = l_payroll_id  -- in case of p_wgi_due_date not null also get the payroll id
  and    ptp.start_date >= p_wgi_due_date
  order  by ptp.start_date asc ;

--

equiv_pay_plan  c_equiv_pay_plan%rowtype;

Procedure get_gm_wgi_dates
is

l_proc         varchar2(72) := 'get_gm_wgi_dates';
l_step4value   varchar2(80);
l_step7value   varchar2(80);
l_step10value  varchar2(80);
l_dummy_date   date;
l_pos_ei_data   per_position_extra_info%ROWTYPE;

Begin
  hr_utility.set_location('entering  ' || l_proc,5);
  If nvl(p_pa_request_rec.pay_Rate_determinant,hr_api.g_varchar2) in ('A','B','E','F') then
    for next_from_step in c_next_Step loop
      hr_utility.set_location(l_proc,34);
      l_step_or_rate  := next_from_step.to_step;
    end loop;
  Else
   -- get the user table id for the position in all other cases .
    ghr_history_fetch.fetch_positionei
    (
     p_position_id         => p_pa_request_rec.to_position_id
    ,p_information_type    => 'GHR_US_POS_VALID_GRADE'
    ,p_date_effective      => p_pa_request_rec.effective_date
    ,p_pos_ei_data         => l_pos_ei_data
    );
  --
    l_user_table_id := l_pos_ei_data.poei_information5;
  End if;
  -- get table values for the given payplan.,grade or level, step or rate, pay table combination.
  ghr_pay_calc.get_pay_table_value
  (p_user_table_id     =>  l_user_table_id,
   p_pay_plan          =>  'GS',
   p_grade_or_level    =>  l_grade_or_level,
   p_step_or_rate      =>  '04',
   p_effective_date    =>  p_pa_request_rec.effective_date,
   p_pt_value          =>  l_step4value,
   p_pt_eff_start_date => l_dummy_date,
   p_pt_eff_end_date   => l_dummy_date
  );
  If p_pa_request_rec.to_basic_pay  < l_step4value then
     p_wgi_due_date :=  p_pa_request_rec.effective_date + 364;
  Else
    ghr_pay_calc.get_pay_table_value
    (p_user_table_id     =>  l_user_table_id,
     p_pay_plan          =>  'GS',
     p_grade_or_level    =>  l_grade_or_level,
     p_step_or_rate      =>  '07',
     p_effective_date    =>  p_pa_request_rec.effective_date,
     p_pt_value          =>  l_step7value,
     p_pt_eff_start_date => l_dummy_date,
     p_pt_eff_end_date   => l_dummy_date
    );
    If p_pa_request_rec.to_basic_pay between l_step4value and l_step7value then
      p_wgi_due_date := p_pa_request_rec.effective_date + 728;
    Else
      ghr_pay_calc.get_pay_table_value
      (p_user_table_id     =>  l_user_table_id,
       p_pay_plan          =>  'GS',
       p_grade_or_level    =>  l_grade_or_level,
       p_step_or_rate      =>  '10',
       p_effective_date    =>  p_pa_request_rec.effective_date,
       p_pt_value          =>  l_step10value,
       p_pt_eff_start_date => l_dummy_date,
       p_pt_eff_end_date   => l_dummy_date
       );
       If p_pa_request_rec.to_basic_pay < l_step10value then
         p_wgi_due_date := p_pa_request_rec.effective_date + 1092;
       Else
         p_wgi_due_date := Null;
       End if;
    End if;
 End if;
End get_gm_wgi_dates;

begin

  hr_utility.set_location('Entering   ' || l_proc,5);
  l_initial_wgi_due_date := p_wgi_due_date;

  p_wgi_pay_date := null;

  for payroll in c_payroll loop
    l_payroll_id  := payroll.payroll_type;
  end loop;

  If l_payroll_id is null then
    for payroll in c_payroll_id  loop
      l_payroll_id  :=  payroll.payroll_id;
    End loop;
  End if;

  If l_payroll_id is null then
    hr_utility.set_location(l_proc,20);
    hr_utility.set_message(8301,'GHR_38268_ASG_NO_PAYROLL');
    hr_utility.raise_error;
  End if;

  hr_utility.set_location('PAYROLLID  '  || to_char(l_payroll_id),1);

  -- Calculate WGI only when  PRD is one of the foll.

  If p_pa_request_rec.pay_rate_determinant in ('0','5','6','7','M') then
    l_pay_plan       := p_pa_request_rec.to_pay_plan;
    l_step_or_rate   := p_pa_request_rec.to_step_or_rate;
    l_grade_or_level := p_pa_request_rec.to_grade_or_level;
  Elsif p_pa_request_rec.pay_rate_determinant in ('A','B','E','F') then
    Begin
       l_retained_grade_rec :=  ghr_pc_basic_pay.get_retained_grade_details
                              (p_person_id       =>   p_pa_request_rec.person_id,
                               p_effective_date  =>   p_pa_request_rec.effective_date,
                               p_pa_request_id   =>   p_pa_request_rec.pa_request_id
                              );
     l_pay_plan        :=  l_retained_grade_rec.pay_plan;
     hr_utility.set_location('temp_step is  ' || l_retained_grade_rec.temp_step,1);
     If l_retained_grade_rec.temp_step is not null
     then
      l_step_or_rate    :=  l_retained_grade_rec.temp_step;
      l_pay_plan        :=  p_pa_request_rec.to_pay_plan; -- Fix for bug 3023252
      hr_utility.set_location('New Step or Rate for Ret Grd Rec. is  ' || l_step_or_rate,1);
      hr_utility.set_location('New pay plan is  ' || l_pay_plan,1);
     else
      l_step_or_rate    :=  l_retained_grade_rec.step_or_rate;
        hr_utility.set_location('New Step or Rate for Ret Grd Rec. is  ' || l_step_or_rate,2);
     end if; -- If l_retained_grade_rec.temp_step is not null
     l_grade_or_level  :=  l_retained_grade_rec.grade_or_level;
     l_user_table_id   :=  l_retained_grade_rec.user_table_id;
     If p_pa_request_rec.first_noa_code in ('867','892','893')
     OR p_pa_request_rec.second_noa_code in ('867','892','893') then -- Bug 3953455 added second noa code to condition
       -- Bug#3304788 Modified the following if condition.
       -- Handled the retained step and temp.step cases separately
        If l_retained_grade_rec.temp_step is not null then
            if to_number(l_retained_grade_rec.temp_step) < 9 then
                p_retained_grade_rec.temp_step :=   '0' ||(l_retained_grade_rec.temp_step + 1 );
                l_step_or_rate :=  p_retained_grade_rec.temp_step;
            ELSE
                p_retained_grade_rec.temp_step :=   l_retained_grade_rec.temp_step + 1 ;
                l_step_or_rate :=  p_retained_grade_rec.temp_step;
            END IF;
        ELSE -- For Retained Grade
            if to_number(l_retained_grade_rec.step_or_rate) < 9 then
                l_step_or_rate   := '0' ||(l_retained_grade_Rec.step_or_rate + 1 );
            ELSE
                l_step_or_rate   :=  l_retained_grade_rec.step_or_rate + 1;
            END IF;
        END IF; -- If l_retained_grade_rec.temp_step is not null
        hr_utility.set_location('New Step or Rate for Ret Grd Rec. is  ' || l_step_or_rate,3);
        hr_utility.set_location('temp_step is  ' || p_retained_grade_rec.temp_step,2);
        p_retained_grade_rec.step_or_rate := l_step_or_rate;
        p_retained_Grade_rec.person_extra_info_id := l_retained_grade_rec.person_extra_info_id;
     End if; --  If p_pa_request_rec.first_noa_code in ('867',

     Exception
       when  ghr_pay_calc.pay_calc_message then
        Null;
     End;

  Else -- else for -- If p_pa_request_rec.pay_rate_de
    l_pay_plan := null;
    p_wgi_due_date := null;
    p_wgi_pay_date := null;
  End if; -- If p_pa_request_rec.pay_rate_determinant in ('0','


  If l_pay_plan is not null then
   If p_wgi_due_date is null then
      hr_utility.set_location(l_proc,10);
      If l_pay_plan = 'GM' then
        get_gm_wgi_dates;
  --        Null;
      Else
        hr_utility.set_location(l_proc,15);
        -- Changed FOR LOOP, and showing error message conditionally. Dinesh Jan 12, 98
        open c_equiv_pay_plan;
        fetch c_equiv_pay_plan into equiv_pay_plan;
        l_eq_pay_plan  := equiv_pay_plan.equivalent_pay_plan;
        l_maximum_step := equiv_pay_plan.maximum_step;
        if c_equiv_pay_plan%FOUND then
          If l_eq_pay_plan is null then
            hr_utility.set_location(l_proc,26);
            hr_utility.set_message(8301,'GHR_38269_NO_EQ_PAY_PLAN');
            hr_utility.raise_error;
          End if;
        else
          hr_utility.set_location(l_proc,25);
          close c_equiv_pay_plan;
          return;
        end if;
        close c_equiv_pay_plan;


        hr_utility.set_location(l_proc,30);

        -- proceed only if the to_step_or_rate is less than the maximum step

        hr_utility.set_location('Step or rate ' || l_step_or_rate,1);
        hr_utility.set_location('Max. Step or rate ' || l_maximum_step,1);
        l_from_step := l_step_or_rate;

         If  to_number(l_step_or_rate) <  to_number(l_maximum_step) then
           hr_utility.set_location('step or rate less than max.   ' || l_step_or_rate,1);

            IF (p_pa_request_rec.first_noa_code = '892' or p_pa_request_rec.second_noa_code = '892')  AND
               (p_retained_grade_rec.step_or_rate not in (4,7,10)  or l_from_step not  in (4,7,10))
                      THEN
               hr_utility.set_location('Do not calc. WGI Dates for all steps in QSI ',1);
         -- Start of Bug 3111719
	 -- Return the current WGI due date for steps other than 4,7,10 in QSI.
               ghr_history_fetch.fetch_element_entry_value
                   (p_element_name          =>  'Within Grade Increase',
                    p_input_value_name      =>  'Date Due',
                    p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
                    p_date_effective        =>  p_pa_request_rec.effective_date,
                    p_screen_entry_value    =>  l_wgi_due_date
                   );

                p_wgi_due_date  :=   fnd_date.canonical_to_date(l_wgi_due_date);
         -- End of Bug 3111719.
	 -- Bug 3709414 New Approach-- For 713 actions take from element entry
  	 -- If DLEI is entered, use that to calculate Due Date, else retain the old date
	    ELSIF (p_pa_request_rec.first_noa_code  = '713'  OR p_pa_request_rec.second_noa_code  = '713') AND p_dlei IS NULL THEN
		ghr_history_fetch.fetch_element_entry_value
			  (p_element_name          =>  'Within Grade Increase',
			   p_input_value_name      =>  'Date Due',
			   p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
			   p_date_effective        =>  p_pa_request_rec.effective_date,
			   p_screen_entry_value    =>  l_lei_date
			   );
		p_wgi_due_date := fnd_date.canonical_to_date(l_lei_date);
            ELSE
               hr_utility.set_location(l_proc,40);
               If l_from_Step is not null then
                 for waiting_period in c_waiting_period loop
                   hr_utility.set_location(l_proc,45);
                   l_wait_period := waiting_period.waiting_period;
                 end loop;
                 If (p_pa_request_rec.first_noa_code = '892' or  p_pa_request_rec.second_noa_code = '892') and
                    (p_retained_grade_rec.step_or_rate in (4,7)  or l_from_step in (4,7)) then
                   -- get current WGI Due Date
                   ghr_history_fetch.fetch_element_entry_value
                   (p_element_name          =>  'Within Grade Increase',
                    p_input_value_name      =>  'Date Due',
                    p_assignment_id         =>  p_pa_request_rec.employee_assignment_id,
                    p_date_effective        =>  p_pa_request_rec.effective_date,
                    p_screen_entry_value    =>  l_wgi_due_date
                   );

                   hr_utility.set_location(l_proc,25);
                    p_wgi_due_date  :=   fnd_date.canonical_to_date(l_wgi_due_date) + 364;
		-- If it's NOA 713 and DLEI is entered, it enters here
		-- Need to use DLEI to calculate WGI due date instead of effective date
		-- Code added as part of WGI Enhancments/Bug fixes
		ELSIF (p_pa_request_rec.first_noa_code = '713' or  p_pa_request_rec.second_noa_code = '713') THEN
			hr_utility.set_location('Entering 713 - dlei is not null',333);
			p_wgi_due_date := p_dlei + l_wait_period;
		-- End WGI Changes for NOA 713
                ELSE
                   If l_wait_period is not null then
                     hr_utility.set_location(l_proc,26);
                     p_wgi_due_date  :=  p_pa_request_rec.effective_date + l_wait_period;
                 END IF;
               END IF;
             END IF;
           END IF; -- Case 892 --01/Feb
         Else   -- else for l_step_or_rate <  l_maximum_step
           -- if the employee has reached the max. step
           hr_utility.set_location('emp. has reached the max. step',2);
            p_wgi_due_date := null;  -- Venkat -- Uncommented bug #954104
            p_wgi_pay_date := null;
         End if;
       End if; -- GM pay plan check
     End if; -- WGI due date is Null

      hr_utility.set_location('DUE DATE ' || to_char(p_wgi_due_date),1);
      If p_wgi_due_date is not null then
        hr_utility.set_location(l_proc,55);
        for next_pay_date  in c_next_pay_date loop
          hr_utility.set_location(l_proc,60);
          p_wgi_pay_date :=  next_pay_date.start_date;
          exit;
         end loop;
      End if;
    hr_utility.set_location('Leaving   ' ||l_proc,65);
  End if;
Exception when others then
          --
          -- Reset IN OUT parameters and set OUT parameters
          --
          p_wgi_due_date := l_initial_wgi_due_date;
          p_wgi_pay_date := null;
          p_retained_grade_rec := null;
          raise;


End get_wgi_dates;
--
Procedure generic_update_sit
(p_pa_request_rec           in   ghr_pa_requests%rowtype,
 p_special_information_type in   fnd_id_flex_structures_tl.id_flex_structure_name%type,
 p_segment_rec              in   ghr_api.special_information_type
)
is

l_proc                  varchar2(72) := 'Generic Update  SIT';
l_object_version_number per_people_f.object_version_number%type;
l_session               ghr_history_api.g_session_var_type;
l_multiple              varchar2(1);
l_analysis_criteria_id  per_analysis_criteria.analysis_criteria_id%type;
l_person_analysis_id    per_person_analyses.person_analysis_id%type;
l_business_group_id     per_people_f.business_group_id%type;
l_id_flex_num           fnd_id_flex_structures.id_flex_num%type;
-- Bug#4054110,4069798 Added l_date_from variable
l_date_from             DATE;

 Cursor    c_bgpid is
  select   business_group_id
  from     per_all_people_f
  where    person_id = p_pa_request_rec.person_id;

Cursor   c_flex_num is
  select id_flex_num
  from   fnd_id_flex_structures_tl
  where  id_flex_structure_name =  p_special_information_type
  and    id_flex_code           = 'PEA'  --??
  and    application_id         =  800
  and    language               = 'US';   --??

Cursor   c_multiple_occur is
  select multiple_occurrences_flag
  from   per_special_info_types sit
  where  business_group_id = l_business_group_id
  and    id_flex_num       = l_id_flex_num;

-- Bug#4054110,4069798 Added cursor c_date_from to fetch the
-- start date of SIT record.
Cursor c_date_from is
Select date_from
from per_person_analyses
where person_analysis_id = p_segment_rec.person_analysis_id;

BEGIN

    hr_utility.set_location('Entering   ' || l_proc,5);

    for bgpid in c_bgpid loop
       l_business_group_id := bgpid.business_group_id;
    end loop;

    -- Get the id_flex_num
    for flex_num in c_flex_num loop
       hr_utility.set_location(l_proc,12);
       l_id_flex_num  :=  flex_num.id_flex_num;
    end loop;
    hr_utility.set_location(l_proc,15);

    for  multiple_occur in c_multiple_occur loop
         hr_utility.set_location(l_proc,36);
         l_multiple :=  multiple_occur.multiple_occurrences_flag;
    end loop;

    l_object_version_number := p_segment_rec.object_version_number;
    l_person_analysis_id    := p_segment_rec.person_analysis_id;


    if p_segment_rec.person_analysis_id is null then
       hr_utility.set_location(l_proc,25);
       begin
          savepoint cr_sit;
          hr_sit_api.create_sit
          (p_person_id                  => p_pa_request_rec.person_id,
           p_business_group_id          => l_business_group_id,
           p_id_flex_num                => l_id_flex_num,
           p_effective_date             => p_pa_request_rec.effective_date,
           p_date_from                  => p_pa_request_rec.effective_date,
           p_segment1                   => p_segment_rec.segment1,
           p_segment2                   => p_segment_rec.segment2,
           p_segment3                   => p_segment_rec.segment3,
           p_segment4                   => p_segment_rec.segment4,
           p_segment5                   => p_segment_rec.segment5,
           p_segment6                   => p_segment_rec.segment6,
           p_segment7                   => p_segment_rec.segment7,
           p_segment8                   => p_segment_rec.segment8,
           p_segment9                   => p_segment_rec.segment9,
           p_segment10                  => p_segment_rec.segment10,
           p_segment11                  => p_segment_rec.segment11,
           p_segment12                  => p_segment_rec.segment12,
           p_segment13                  => p_segment_rec.segment13,
           p_segment14                  => p_segment_rec.segment14,
           p_segment15                  => p_segment_rec.segment15,
           p_segment16                  => p_segment_rec.segment16,
           p_segment17                  => p_segment_rec.segment17,
           p_segment18                  => p_segment_rec.segment18,
           p_segment19                  => p_segment_rec.segment19,
           p_segment20                  => p_segment_rec.segment20,
           p_segment21                  => p_segment_rec.segment21,
           p_segment22                  => p_segment_rec.segment22,
           p_segment23                  => p_segment_rec.segment23,
           p_segment24                  => p_segment_rec.segment24,
           p_segment25                  => p_segment_rec.segment25,
           p_segment26                  => p_segment_rec.segment26,
           p_segment27                  => p_segment_rec.segment27,
           p_segment28                  => p_segment_rec.segment28,
           p_segment29                  => p_segment_rec.segment29,
           p_segment30                  => p_segment_rec.segment30,
           p_person_analysis_id         => l_person_analysis_id,
           p_pea_object_version_number  => l_object_version_number,
           p_analysis_criteria_id       => l_analysis_criteria_id
           );
           Exception when others then
           rollback to cr_sit;
           raise;
       End;
       hr_utility.set_location(l_proc,30);
    Else
       Begin
          -- Bug#4054110,4069798 Fetching the SIT start date for SIT US Fed Perf Apprisal.
          IF p_special_information_type = 'US Fed Perf Appraisal' THEN
              Open c_date_from;
   	      Fetch c_date_from into l_date_from;
	      Close c_date_from;
	  ELSE
	    l_date_from := p_pa_request_rec.effective_date;
	  End IF;

          savepoint upd_sit;
          hr_sit_api.update_sit
          (p_person_analysis_id         => p_segment_rec.person_analysis_id,
           p_date_from                  => l_date_from,
           p_segment1                   => p_segment_rec.segment1,
           p_segment2                   => p_segment_rec.segment2,
           p_segment3                   => p_segment_rec.segment3,
           p_segment4                   => p_segment_rec.segment4,
           p_segment5                   => p_segment_rec.segment5,
           p_segment6                   => p_segment_rec.segment6,
           p_segment7                   => p_segment_rec.segment7,
           p_segment8                   => p_segment_rec.segment8,
           p_segment9                   => p_segment_rec.segment9,
           p_segment10                  => p_segment_rec.segment10,
           p_segment11                  => p_segment_rec.segment11,
           p_segment12                  => p_segment_rec.segment12,
           p_segment13                  => p_segment_rec.segment13,
           p_segment14                  => p_segment_rec.segment14,
           p_segment15                  => p_segment_rec.segment15,
           p_segment16                  => p_segment_rec.segment16,
           p_segment17                  => p_segment_rec.segment17,
           p_segment18                  => p_segment_rec.segment18,
           p_segment19                  => p_segment_rec.segment19,
           p_segment20                  => p_segment_rec.segment20,
           p_segment21                  => p_segment_rec.segment21,
           p_segment22                  => p_segment_rec.segment22,
           p_segment23                  => p_segment_rec.segment23,
           p_segment24                  => p_segment_rec.segment24,
           p_segment25                  => p_segment_rec.segment25,
           p_segment26                  => p_segment_rec.segment26,
           p_segment27                  => p_segment_rec.segment27,
           p_segment28                  => p_segment_rec.segment28,
           p_segment29                  => p_segment_rec.segment29,
           p_segment30                  => p_segment_rec.segment30,
           p_analysis_criteria_id       => l_analysis_criteria_id,
           p_pea_object_version_number  => l_object_version_number
          );
          Exception
          when others then
               rollback to upd_sit;
               raise;
       End;
    End if;

end; -- END OF generic_update_sit
end  GHR_SF52_DO_UPDATE;

/
