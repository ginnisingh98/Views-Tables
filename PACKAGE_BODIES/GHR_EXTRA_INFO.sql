--------------------------------------------------------
--  DDL for Package Body GHR_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_EXTRA_INFO" AS
/* $Header: ghexinfo.pkb 120.0.12010000.2 2009/05/26 10:39:18 utokachi noship $ */

   g_package   VARCHAR2(30) := 'GHR_EXTRA_INFO.';


-- -----------------------
  PROCEDURE CLOSE_CURSOR(c_extra_info IN OUT NOCOPY c_extra_info_type)
-- -----------------------
  IS
     l_proc   VARCHAR2(61)  := g_package || 'CLOSE_CURSOR';
  begin
     hr_utility.set_location('Entering :' || l_proc, 10);
     IF c_extra_info%ISOPEN THEN
        hr_utility.set_location('Cursor Closed :' || l_proc, 10);
        CLOSE c_extra_info;
     END IF;
     hr_utility.set_location('Leaving :' || l_proc, 10);
  END;

-- -----------------------
  FUNCTION OPEN_FETCH_CURSOR (
-- -----------------------
    p_form_name            in         varchar2
   ,p_date_effective       in out NOCOPY date
   ,p_id                   in out NOCOPY number
   ,p_information_type     in out NOCOPY varchar2
   )
   RETURN NUMBER
  IS
    l_proc   VARCHAR2(61)  := g_package || 'OPEN_FETCH_CURSOR';
    l_result_code         varchar2(30);
    c_extra_info          c_extra_info_type;
    r_short_extra_info    r_short_extra_info_type;
  BEGIN

      hr_utility.set_location('Entering :' || l_proc, 10);
      hr_utility.set_location('ID :' || to_char(p_id) || l_proc, 11);
      hr_utility.set_location('Date Effective : ' || to_char(p_date_effective, 'YYYY/MM/DD') || l_proc, 12);
      hr_utility.set_location('Form Name :' || p_form_name || l_proc, 13);
      hr_utility.set_location('Info Type :' || p_information_type || l_proc, 14);
      g_records_fetched := 0;
      g_current_record  := 1;
      IF p_form_name IN ('PERWSPOI','GHRWSPOC') THEN
        open c_extra_info for
          select
            poi.position_extra_info_id      extra_info_id
           ,poi.position_id                 id
           ,poi.information_type            information_type
           ,poi.object_version_number       object_version_number
           ,poi.last_update_date            last_update_date
           ,poi.last_updated_by             last_updated_by
           ,poi.last_update_login           last_update_login
           ,poi.created_by                  created_by
           ,poi.creation_date               creation_date
          from per_position_extra_info poi
          where poi.position_id = p_id
          and poi.information_type = p_information_type;
      ELSIF p_form_name = 'PERWSPEI' THEN
        open c_extra_info for
          select
            pei.person_extra_info_id        extra_info_id
           ,pei.person_id                   id
           ,pei.information_type            information_type
           ,pei.object_version_number       object_version_number
           ,pei.last_update_date            last_update_date
           ,pei.last_updated_by             last_updated_by
           ,pei.last_update_login           last_update_login
           ,pei.created_by                  created_by
           ,pei.creation_date               creation_date
          from per_people_extra_info pei
          where pei.person_id = p_id
          and pei.information_type = p_information_type;
      ELSIF p_form_name = 'PERWSAEI' THEN
        open c_extra_info for
          select
            aei.assignment_extra_info_id    extra_info_id
           ,aei.assignment_id               id
           ,aei.information_type            information_type
           ,aei.object_version_number       object_version_number
           ,aei.last_update_date            last_update_date
           ,aei.last_updated_by             last_updated_by
           ,aei.last_update_login           last_update_login
           ,aei.created_by                  created_by
           ,aei.creation_date               creation_date
          from per_assignment_extra_info aei
          where aei.assignment_id = p_id
          and aei.information_type = p_information_type;
      END IF;
      LOOP
         g_records_fetched := g_records_fetched + 1;
         FETCH c_extra_info INTO r_short_extra_info;
--
         IF c_extra_info%NOTFOUND THEN
            g_records_fetched := g_records_fetched - 1;
            close_cursor(c_extra_info);
            return g_records_fetched;
         END IF;
--
         r_extra_info_tab(g_records_fetched).extra_info_id    := r_short_extra_info.extra_info_id;
         r_extra_info_tab(g_records_fetched).information_type := r_short_extra_info.information_type;
         r_extra_info_tab(g_records_fetched).id               := r_short_extra_info.id;

         hr_utility.set_location('Calling ghr_history_fetch.fetch_.....ei' || l_proc, 20);

         IF p_form_name IN ('PERWSPOI','GHRWSPOC') THEN

            ghr_history_fetch.fetch_positionei(
            p_position_extra_info_id              => r_extra_info_tab(g_records_fetched).extra_info_id
           ,p_date_effective                      => p_date_effective
           ,p_position_id                         => r_extra_info_tab(g_records_fetched).id
           ,p_information_type                    => r_extra_info_tab(g_records_fetched).information_type
           ,p_request_id                          => r_extra_info_tab(g_records_fetched).request_id
           ,p_program_application_id              => r_extra_info_tab(g_records_fetched).program_application_id
           ,p_program_id                          => r_extra_info_tab(g_records_fetched).program_id
           ,p_program_update_date                 => r_extra_info_tab(g_records_fetched).program_update_date
           ,p_poei_attribute_category             => r_extra_info_tab(g_records_fetched).attribute_category
           ,p_poei_attribute1                     => r_extra_info_tab(g_records_fetched).attribute1
           ,p_poei_attribute2                     => r_extra_info_tab(g_records_fetched).attribute2
           ,p_poei_attribute3                     => r_extra_info_tab(g_records_fetched).attribute3
           ,p_poei_attribute4                     => r_extra_info_tab(g_records_fetched).attribute4
           ,p_poei_attribute5                     => r_extra_info_tab(g_records_fetched).attribute5
           ,p_poei_attribute6                     => r_extra_info_tab(g_records_fetched).attribute6
           ,p_poei_attribute7                     => r_extra_info_tab(g_records_fetched).attribute7
           ,p_poei_attribute8                     => r_extra_info_tab(g_records_fetched).attribute8
           ,p_poei_attribute9                     => r_extra_info_tab(g_records_fetched).attribute9
           ,p_poei_attribute10                    => r_extra_info_tab(g_records_fetched).attribute10
           ,p_poei_attribute11                    => r_extra_info_tab(g_records_fetched).attribute11
           ,p_poei_attribute12                    => r_extra_info_tab(g_records_fetched).attribute12
           ,p_poei_attribute13                    => r_extra_info_tab(g_records_fetched).attribute13
           ,p_poei_attribute14                    => r_extra_info_tab(g_records_fetched).attribute14
           ,p_poei_attribute15                    => r_extra_info_tab(g_records_fetched).attribute15
           ,p_poei_attribute16                    => r_extra_info_tab(g_records_fetched).attribute16
           ,p_poei_attribute17                    => r_extra_info_tab(g_records_fetched).attribute17
           ,p_poei_attribute18                    => r_extra_info_tab(g_records_fetched).attribute18
           ,p_poei_attribute19                    => r_extra_info_tab(g_records_fetched).attribute19
           ,p_poei_attribute20                    => r_extra_info_tab(g_records_fetched).attribute20
           ,p_poei_information_category           => r_extra_info_tab(g_records_fetched).information_category
           ,p_poei_information1                   => r_extra_info_tab(g_records_fetched).information1
           ,p_poei_information2                   => r_extra_info_tab(g_records_fetched).information2
           ,p_poei_information3                   => r_extra_info_tab(g_records_fetched).information3
           ,p_poei_information4                   => r_extra_info_tab(g_records_fetched).information4
           ,p_poei_information5                   => r_extra_info_tab(g_records_fetched).information5
           ,p_poei_information6                   => r_extra_info_tab(g_records_fetched).information6
           ,p_poei_information7                   => r_extra_info_tab(g_records_fetched).information7
           ,p_poei_information8                   => r_extra_info_tab(g_records_fetched).information8
           ,p_poei_information9                   => r_extra_info_tab(g_records_fetched).information9
           ,p_poei_information10                  => r_extra_info_tab(g_records_fetched).information10
           ,p_poei_information11                  => r_extra_info_tab(g_records_fetched).information11
           ,p_poei_information12                  => r_extra_info_tab(g_records_fetched).information12
           ,p_poei_information13                  => r_extra_info_tab(g_records_fetched).information13
           ,p_poei_information14                  => r_extra_info_tab(g_records_fetched).information14
           ,p_poei_information15                  => r_extra_info_tab(g_records_fetched).information15
           ,p_poei_information16                  => r_extra_info_tab(g_records_fetched).information16
           ,p_poei_information17                  => r_extra_info_tab(g_records_fetched).information17
           ,p_poei_information18                  => r_extra_info_tab(g_records_fetched).information18
           ,p_poei_information19                  => r_extra_info_tab(g_records_fetched).information19
           ,p_poei_information20                  => r_extra_info_tab(g_records_fetched).information20
           ,p_poei_information21                  => r_extra_info_tab(g_records_fetched).information21
           ,p_poei_information22                  => r_extra_info_tab(g_records_fetched).information22
           ,p_poei_information23                  => r_extra_info_tab(g_records_fetched).information23
           ,p_poei_information24                  => r_extra_info_tab(g_records_fetched).information24
           ,p_poei_information25                  => r_extra_info_tab(g_records_fetched).information25
           ,p_poei_information26                  => r_extra_info_tab(g_records_fetched).information26
           ,p_poei_information27                  => r_extra_info_tab(g_records_fetched).information27
           ,p_poei_information28                  => r_extra_info_tab(g_records_fetched).information28
           ,p_poei_information29                  => r_extra_info_tab(g_records_fetched).information29
           ,p_poei_information30                  => r_extra_info_tab(g_records_fetched).information30
           ,p_object_version_number               => r_extra_info_tab(g_records_fetched).object_version_number
           ,p_last_update_date                    => r_extra_info_tab(g_records_fetched).last_update_date
           ,p_last_updated_by                     => r_extra_info_tab(g_records_fetched).last_updated_by
           ,p_last_update_login                   => r_extra_info_tab(g_records_fetched).last_update_login
           ,p_created_by                          => r_extra_info_tab(g_records_fetched).created_by
           ,p_creation_date                       => r_extra_info_tab(g_records_fetched).creation_date
           ,p_result_code                         => l_result_code
           );
         ELSIF p_form_name = 'PERWSPEI' THEN

            ghr_history_fetch.fetch_peopleei(
            p_person_extra_info_id                => r_extra_info_tab(g_records_fetched).extra_info_id
           ,p_date_effective                      => p_date_effective
           ,p_person_id                           => r_extra_info_tab(g_records_fetched).id
           ,p_information_type                    => r_extra_info_tab(g_records_fetched).information_type
           ,p_request_id                          => r_extra_info_tab(g_records_fetched).request_id
           ,p_program_application_id              => r_extra_info_tab(g_records_fetched).program_application_id
           ,p_program_id                          => r_extra_info_tab(g_records_fetched).program_id
           ,p_program_update_date                 => r_extra_info_tab(g_records_fetched).program_update_date
           ,p_pei_attribute_category              => r_extra_info_tab(g_records_fetched).attribute_category
           ,p_pei_attribute1                      => r_extra_info_tab(g_records_fetched).attribute1
           ,p_pei_attribute2                      => r_extra_info_tab(g_records_fetched).attribute2
           ,p_pei_attribute3                      => r_extra_info_tab(g_records_fetched).attribute3
           ,p_pei_attribute4                      => r_extra_info_tab(g_records_fetched).attribute4
           ,p_pei_attribute5                      => r_extra_info_tab(g_records_fetched).attribute5
           ,p_pei_attribute6                      => r_extra_info_tab(g_records_fetched).attribute6
           ,p_pei_attribute7                      => r_extra_info_tab(g_records_fetched).attribute7
           ,p_pei_attribute8                      => r_extra_info_tab(g_records_fetched).attribute8
           ,p_pei_attribute9                      => r_extra_info_tab(g_records_fetched).attribute9
           ,p_pei_attribute10                     => r_extra_info_tab(g_records_fetched).attribute10
           ,p_pei_attribute11                     => r_extra_info_tab(g_records_fetched).attribute11
           ,p_pei_attribute12                     => r_extra_info_tab(g_records_fetched).attribute12
           ,p_pei_attribute13                     => r_extra_info_tab(g_records_fetched).attribute13
           ,p_pei_attribute14                     => r_extra_info_tab(g_records_fetched).attribute14
           ,p_pei_attribute15                     => r_extra_info_tab(g_records_fetched).attribute15
           ,p_pei_attribute16                     => r_extra_info_tab(g_records_fetched).attribute16
           ,p_pei_attribute17                     => r_extra_info_tab(g_records_fetched).attribute17
           ,p_pei_attribute18                     => r_extra_info_tab(g_records_fetched).attribute18
           ,p_pei_attribute19                     => r_extra_info_tab(g_records_fetched).attribute19
           ,p_pei_attribute20                     => r_extra_info_tab(g_records_fetched).attribute20
           ,p_pei_information_category            => r_extra_info_tab(g_records_fetched).information_category
           ,p_pei_information1                    => r_extra_info_tab(g_records_fetched).information1
           ,p_pei_information2                    => r_extra_info_tab(g_records_fetched).information2
           ,p_pei_information3                    => r_extra_info_tab(g_records_fetched).information3
           ,p_pei_information4                    => r_extra_info_tab(g_records_fetched).information4
           ,p_pei_information5                    => r_extra_info_tab(g_records_fetched).information5
           ,p_pei_information6                    => r_extra_info_tab(g_records_fetched).information6
           ,p_pei_information7                    => r_extra_info_tab(g_records_fetched).information7
           ,p_pei_information8                    => r_extra_info_tab(g_records_fetched).information8
           ,p_pei_information9                    => r_extra_info_tab(g_records_fetched).information9
           ,p_pei_information10                   => r_extra_info_tab(g_records_fetched).information10
           ,p_pei_information11                   => r_extra_info_tab(g_records_fetched).information11
           ,p_pei_information12                   => r_extra_info_tab(g_records_fetched).information12
           ,p_pei_information13                   => r_extra_info_tab(g_records_fetched).information13
           ,p_pei_information14                   => r_extra_info_tab(g_records_fetched).information14
           ,p_pei_information15                   => r_extra_info_tab(g_records_fetched).information15
           ,p_pei_information16                   => r_extra_info_tab(g_records_fetched).information16
           ,p_pei_information17                   => r_extra_info_tab(g_records_fetched).information17
           ,p_pei_information18                   => r_extra_info_tab(g_records_fetched).information18
           ,p_pei_information19                   => r_extra_info_tab(g_records_fetched).information19
           ,p_pei_information20                   => r_extra_info_tab(g_records_fetched).information20
           ,p_pei_information21                   => r_extra_info_tab(g_records_fetched).information21
           ,p_pei_information22                   => r_extra_info_tab(g_records_fetched).information22
           ,p_pei_information23                   => r_extra_info_tab(g_records_fetched).information23
           ,p_pei_information24                   => r_extra_info_tab(g_records_fetched).information24
           ,p_pei_information25                   => r_extra_info_tab(g_records_fetched).information25
           ,p_pei_information26                   => r_extra_info_tab(g_records_fetched).information26
           ,p_pei_information27                   => r_extra_info_tab(g_records_fetched).information27
           ,p_pei_information28                   => r_extra_info_tab(g_records_fetched).information28
           ,p_pei_information29                   => r_extra_info_tab(g_records_fetched).information29
           ,p_pei_information30                   => r_extra_info_tab(g_records_fetched).information30
           ,p_object_version_number               => r_extra_info_tab(g_records_fetched).object_version_number
           ,p_last_update_date                    => r_extra_info_tab(g_records_fetched).last_update_date
           ,p_last_updated_by                     => r_extra_info_tab(g_records_fetched).last_updated_by
           ,p_last_update_login                   => r_extra_info_tab(g_records_fetched).last_update_login
           ,p_created_by                          => r_extra_info_tab(g_records_fetched).created_by
           ,p_creation_date                       => r_extra_info_tab(g_records_fetched).creation_date
           ,p_result_code                         => l_result_code
           );

         ELSIF p_form_name = 'PERWSAEI' THEN

            ghr_history_fetch.fetch_asgei(
            p_assignment_extra_info_id            => r_extra_info_tab(g_records_fetched).extra_info_id
           ,p_date_effective                      => p_date_effective
           ,p_assignment_id                       => r_extra_info_tab(g_records_fetched).id
           ,p_information_type                    => r_extra_info_tab(g_records_fetched).information_type
           ,p_request_id                          => r_extra_info_tab(g_records_fetched).request_id
           ,p_program_application_id              => r_extra_info_tab(g_records_fetched).program_application_id
           ,p_program_id                          => r_extra_info_tab(g_records_fetched).program_id
           ,p_program_update_date                 => r_extra_info_tab(g_records_fetched).program_update_date
           ,p_aei_attribute_category              => r_extra_info_tab(g_records_fetched).attribute_category
           ,p_aei_attribute1                      => r_extra_info_tab(g_records_fetched).attribute1
           ,p_aei_attribute2                      => r_extra_info_tab(g_records_fetched).attribute2
           ,p_aei_attribute3                      => r_extra_info_tab(g_records_fetched).attribute3
           ,p_aei_attribute4                      => r_extra_info_tab(g_records_fetched).attribute4
           ,p_aei_attribute5                      => r_extra_info_tab(g_records_fetched).attribute5
           ,p_aei_attribute6                      => r_extra_info_tab(g_records_fetched).attribute6
           ,p_aei_attribute7                      => r_extra_info_tab(g_records_fetched).attribute7
           ,p_aei_attribute8                      => r_extra_info_tab(g_records_fetched).attribute8
           ,p_aei_attribute9                      => r_extra_info_tab(g_records_fetched).attribute9
           ,p_aei_attribute10                     => r_extra_info_tab(g_records_fetched).attribute10
           ,p_aei_attribute11                     => r_extra_info_tab(g_records_fetched).attribute11
           ,p_aei_attribute12                     => r_extra_info_tab(g_records_fetched).attribute12
           ,p_aei_attribute13                     => r_extra_info_tab(g_records_fetched).attribute13
           ,p_aei_attribute14                     => r_extra_info_tab(g_records_fetched).attribute14
           ,p_aei_attribute15                     => r_extra_info_tab(g_records_fetched).attribute15
           ,p_aei_attribute16                     => r_extra_info_tab(g_records_fetched).attribute16
           ,p_aei_attribute17                     => r_extra_info_tab(g_records_fetched).attribute17
           ,p_aei_attribute18                     => r_extra_info_tab(g_records_fetched).attribute18
           ,p_aei_attribute19                     => r_extra_info_tab(g_records_fetched).attribute19
           ,p_aei_attribute20                     => r_extra_info_tab(g_records_fetched).attribute20
           ,p_aei_information_category            => r_extra_info_tab(g_records_fetched).information_category
           ,p_aei_information1                    => r_extra_info_tab(g_records_fetched).information1
           ,p_aei_information2                    => r_extra_info_tab(g_records_fetched).information2
           ,p_aei_information3                    => r_extra_info_tab(g_records_fetched).information3
           ,p_aei_information4                    => r_extra_info_tab(g_records_fetched).information4
           ,p_aei_information5                    => r_extra_info_tab(g_records_fetched).information5
           ,p_aei_information6                    => r_extra_info_tab(g_records_fetched).information6
           ,p_aei_information7                    => r_extra_info_tab(g_records_fetched).information7
           ,p_aei_information8                    => r_extra_info_tab(g_records_fetched).information8
           ,p_aei_information9                    => r_extra_info_tab(g_records_fetched).information9
           ,p_aei_information10                   => r_extra_info_tab(g_records_fetched).information10
           ,p_aei_information11                   => r_extra_info_tab(g_records_fetched).information11
           ,p_aei_information12                   => r_extra_info_tab(g_records_fetched).information12
           ,p_aei_information13                   => r_extra_info_tab(g_records_fetched).information13
           ,p_aei_information14                   => r_extra_info_tab(g_records_fetched).information14
           ,p_aei_information15                   => r_extra_info_tab(g_records_fetched).information15
           ,p_aei_information16                   => r_extra_info_tab(g_records_fetched).information16
           ,p_aei_information17                   => r_extra_info_tab(g_records_fetched).information17
           ,p_aei_information18                   => r_extra_info_tab(g_records_fetched).information18
           ,p_aei_information19                   => r_extra_info_tab(g_records_fetched).information19
           ,p_aei_information20                   => r_extra_info_tab(g_records_fetched).information20
           ,p_aei_information21                   => r_extra_info_tab(g_records_fetched).information21
           ,p_aei_information22                   => r_extra_info_tab(g_records_fetched).information22
           ,p_aei_information23                   => r_extra_info_tab(g_records_fetched).information23
           ,p_aei_information24                   => r_extra_info_tab(g_records_fetched).information24
           ,p_aei_information25                   => r_extra_info_tab(g_records_fetched).information25
           ,p_aei_information26                   => r_extra_info_tab(g_records_fetched).information26
           ,p_aei_information27                   => r_extra_info_tab(g_records_fetched).information27
           ,p_aei_information28                   => r_extra_info_tab(g_records_fetched).information28
           ,p_aei_information29                   => r_extra_info_tab(g_records_fetched).information29
           ,p_aei_information30                   => r_extra_info_tab(g_records_fetched).information30
           ,p_object_version_number               => r_extra_info_tab(g_records_fetched).object_version_number
           ,p_last_update_date                    => r_extra_info_tab(g_records_fetched).last_update_date
           ,p_last_updated_by                     => r_extra_info_tab(g_records_fetched).last_updated_by
           ,p_last_update_login                   => r_extra_info_tab(g_records_fetched).last_update_login
           ,p_created_by                          => r_extra_info_tab(g_records_fetched).created_by
           ,p_creation_date                       => r_extra_info_tab(g_records_fetched).creation_date
           ,p_result_code                         => l_result_code
           );

         END IF;
         hr_utility.set_location('Back to  ' || l_proc, 30);

         hr_utility.set_location('Result Code :' || NVL(l_result_code, 'NULL'), 34);

         hr_utility.set_location('Current Record :' || to_char(g_current_record), 35);
         hr_utility.set_location('Records Fetched :' || to_char(g_records_fetched), 36);

         IF l_result_code IS NOT NULL THEN
              r_extra_info_tab(g_records_fetched).extra_info_id          := r_short_extra_info.extra_info_id;
              r_extra_info_tab(g_records_fetched).information_type       := r_short_extra_info.information_type;
              r_extra_info_tab(g_records_fetched).id                     := r_short_extra_info.id;
--              g_records_fetched := g_records_fetched - 1;
              hr_utility.set_location('Current Record :' || to_char(g_current_record), 37);
              hr_utility.set_location('Records Fetched :' || to_char(g_records_fetched), 38);
         END IF;
         r_extra_info_tab(g_records_fetched).object_version_number       :=   r_short_extra_info.object_version_number;
         r_extra_info_tab(g_records_fetched).last_update_date            :=   r_short_extra_info.last_update_date;
         r_extra_info_tab(g_records_fetched).last_updated_by             :=   r_short_extra_info.last_updated_by;
         r_extra_info_tab(g_records_fetched).last_update_login           :=   r_short_extra_info.last_update_login;
         r_extra_info_tab(g_records_fetched).created_by                  :=   r_short_extra_info.created_by;
         r_extra_info_tab(g_records_fetched).creation_date               :=   r_short_extra_info.creation_date;
      END LOOP;
      hr_utility.set_location('Leaving :' || l_proc, 40);
  END;
-- -----------------------
   FUNCTION FETCH_CURSOR(
-- -----------------------
    p_extra_info_id           out NOCOPY number
   ,p_id                      out NOCOPY number
   ,p_information_type        out NOCOPY varchar2
   ,p_request_id              out NOCOPY number
   ,p_program_application_id  out NOCOPY number
   ,p_program_id              out NOCOPY number
   ,p_program_update_date     out NOCOPY date
   ,p_attribute_category      out NOCOPY varchar2
   ,p_attribute1              out NOCOPY varchar2
   ,p_attribute2              out NOCOPY varchar2
   ,p_attribute3              out NOCOPY varchar2
   ,p_attribute4              out NOCOPY varchar2
   ,p_attribute5              out NOCOPY varchar2
   ,p_attribute6              out NOCOPY varchar2
   ,p_attribute7              out NOCOPY varchar2
   ,p_attribute8              out NOCOPY varchar2
   ,p_attribute9              out NOCOPY varchar2
   ,p_attribute10             out NOCOPY varchar2
   ,p_attribute11             out NOCOPY varchar2
   ,p_attribute12             out NOCOPY varchar2
   ,p_attribute13             out NOCOPY varchar2
   ,p_attribute14             out NOCOPY varchar2
   ,p_attribute15             out NOCOPY varchar2
   ,p_attribute16             out NOCOPY varchar2
   ,p_attribute17             out NOCOPY varchar2
   ,p_attribute18             out NOCOPY varchar2
   ,p_attribute19             out NOCOPY varchar2
   ,p_attribute20             out NOCOPY varchar2
   ,p_information_category    out NOCOPY varchar2
   ,p_information1            out NOCOPY varchar2
   ,p_information2            out NOCOPY varchar2
   ,p_information3            out NOCOPY varchar2
   ,p_information4            out NOCOPY varchar2
   ,p_information5            out NOCOPY varchar2
   ,p_information6            out NOCOPY varchar2
   ,p_information7            out NOCOPY varchar2
   ,p_information8            out NOCOPY varchar2
   ,p_information9            out NOCOPY varchar2
   ,p_information10           out NOCOPY varchar2
   ,p_information11           out NOCOPY varchar2
   ,p_information12           out NOCOPY varchar2
   ,p_information13           out NOCOPY varchar2
   ,p_information14           out NOCOPY varchar2
   ,p_information15           out NOCOPY varchar2
   ,p_information16           out NOCOPY varchar2
   ,p_information17           out NOCOPY varchar2
   ,p_information18           out NOCOPY varchar2
   ,p_information19           out NOCOPY varchar2
   ,p_information20           out NOCOPY varchar2
   ,p_information21           out NOCOPY varchar2
   ,p_information22           out NOCOPY varchar2
   ,p_information23           out NOCOPY varchar2
   ,p_information24           out NOCOPY varchar2

   ,p_information25           out NOCOPY varchar2
   ,p_information26           out NOCOPY varchar2
   ,p_information27           out NOCOPY varchar2
   ,p_information28           out NOCOPY varchar2
   ,p_information29           out NOCOPY varchar2
   ,p_information30           out NOCOPY varchar2
   ,p_object_version_number   out NOCOPY number
   ,p_last_update_date        out NOCOPY date
   ,p_last_updated_by         out NOCOPY number
   ,p_last_update_login       out NOCOPY number
   ,p_created_by              out NOCOPY number
   ,p_creation_date           out NOCOPY date
   )
   RETURN VARCHAR2
   IS
         l_proc   VARCHAR2(61)  := g_package || 'FETCH_CURSOR';
   BEGIN
         hr_utility.set_location('Entering :' || l_proc, 10);
         hr_utility.set_location('Current Record :' || to_char(g_current_record), 13);
         hr_utility.set_location('Records Fetched :' || to_char(g_records_fetched), 18);
         IF g_current_record > g_records_fetched THEN
              hr_utility.set_location('Leaving :' || l_proc, 20);
              RETURN 'FALSE';
         END IF;
         p_extra_info_id          :=   r_extra_info_tab(g_current_record).extra_info_id;
         p_id                     :=   r_extra_info_tab(g_current_record).id;
         p_information_type       :=   r_extra_info_tab(g_current_record).information_type;
         p_request_id             :=   r_extra_info_tab(g_current_record).request_id;
         p_program_application_id :=   r_extra_info_tab(g_current_record).program_application_id;
         p_program_id             :=   r_extra_info_tab(g_current_record).program_id;
         p_program_update_date    :=   r_extra_info_tab(g_current_record).program_update_date;
         p_attribute_category     :=   r_extra_info_tab(g_current_record).attribute_category;
         p_attribute1             :=   r_extra_info_tab(g_current_record).attribute1;
         p_attribute2             :=   r_extra_info_tab(g_current_record).attribute2;
         p_attribute3             :=   r_extra_info_tab(g_current_record).attribute3;
         p_attribute4             :=   r_extra_info_tab(g_current_record).attribute4;
         p_attribute5             :=   r_extra_info_tab(g_current_record).attribute5;
         p_attribute6             :=   r_extra_info_tab(g_current_record).attribute6;
         p_attribute7             :=   r_extra_info_tab(g_current_record).attribute7;
         p_attribute8             :=   r_extra_info_tab(g_current_record).attribute8;
         p_attribute9             :=   r_extra_info_tab(g_current_record).attribute9;
         p_attribute10            :=   r_extra_info_tab(g_current_record).attribute10;
         p_attribute11            :=   r_extra_info_tab(g_current_record).attribute11;
         p_attribute12            :=   r_extra_info_tab(g_current_record).attribute12;
         p_attribute13            :=   r_extra_info_tab(g_current_record).attribute13;
         p_attribute14            :=   r_extra_info_tab(g_current_record).attribute14;
         p_attribute15            :=   r_extra_info_tab(g_current_record).attribute15;
         p_attribute16            :=   r_extra_info_tab(g_current_record).attribute16;
         p_attribute17            :=   r_extra_info_tab(g_current_record).attribute17;
         p_attribute18            :=   r_extra_info_tab(g_current_record).attribute18;
         p_attribute19            :=   r_extra_info_tab(g_current_record).attribute19;
         p_attribute20            :=   r_extra_info_tab(g_current_record).attribute20;
         p_information_category   :=   r_extra_info_tab(g_current_record).information_category;
         p_information1           :=   r_extra_info_tab(g_current_record).information1;
         p_information2           :=   r_extra_info_tab(g_current_record).information2;
         p_information3           :=   r_extra_info_tab(g_current_record).information3;
         p_information4           :=   r_extra_info_tab(g_current_record).information4;
         p_information5           :=   r_extra_info_tab(g_current_record).information5;
         p_information6           :=   r_extra_info_tab(g_current_record).information6;
         p_information7           :=   r_extra_info_tab(g_current_record).information7;
         p_information8           :=   r_extra_info_tab(g_current_record).information8;
         p_information9           :=   r_extra_info_tab(g_current_record).information9;
         p_information10          :=   r_extra_info_tab(g_current_record).information10;
         p_information11          :=   r_extra_info_tab(g_current_record).information11;
         p_information12          :=   r_extra_info_tab(g_current_record).information12;
         p_information13          :=   r_extra_info_tab(g_current_record).information13;
         p_information14          :=   r_extra_info_tab(g_current_record).information14;
         p_information15          :=   r_extra_info_tab(g_current_record).information15;
         p_information16          :=   r_extra_info_tab(g_current_record).information16;
         p_information17          :=   r_extra_info_tab(g_current_record).information17;
         p_information18          :=   r_extra_info_tab(g_current_record).information18;
         p_information19          :=   r_extra_info_tab(g_current_record).information19;
         p_information20          :=   r_extra_info_tab(g_current_record).information20;
         p_information21          :=   r_extra_info_tab(g_current_record).information21;
         p_information22          :=   r_extra_info_tab(g_current_record).information22;
         p_information23          :=   r_extra_info_tab(g_current_record).information23;
         p_information24          :=   r_extra_info_tab(g_current_record).information24;
         p_information25          :=   r_extra_info_tab(g_current_record).information25;
         p_information26          :=   r_extra_info_tab(g_current_record).information26;
         p_information27          :=   r_extra_info_tab(g_current_record).information27;
         p_information28          :=   r_extra_info_tab(g_current_record).information28;
         p_information29          :=   r_extra_info_tab(g_current_record).information29;
         p_information30          :=   r_extra_info_tab(g_current_record).information30;
         p_object_version_number  :=   r_extra_info_tab(g_current_record).object_version_number;
         p_last_update_date       :=   r_extra_info_tab(g_current_record).last_update_date;
         p_last_updated_by        :=   r_extra_info_tab(g_current_record).last_updated_by;
         p_last_update_login      :=   r_extra_info_tab(g_current_record).last_update_login;
         p_created_by             :=   r_extra_info_tab(g_current_record).created_by;
         p_creation_date          :=   r_extra_info_tab(g_current_record).creation_date;


         hr_utility.set_location('Current Record ' || to_char(g_current_record)|| l_proc, 15);
         hr_utility.set_location('extra_info_id  :' || r_extra_info_tab(g_current_record).extra_info_id || l_proc, 20);
         hr_utility.set_location('Information1 :' || r_extra_info_tab(g_current_record).information1|| l_proc, 30);
         hr_utility.set_location('Information2 :' || r_extra_info_tab(g_current_record).information2|| l_proc, 40);
         hr_utility.set_location('Information3 :' || r_extra_info_tab(g_current_record).information3|| l_proc, 50);
         hr_utility.set_location('Information4 :' || r_extra_info_tab(g_current_record).information4|| l_proc, 60);
         hr_utility.set_location('Information5 :' || r_extra_info_tab(g_current_record).information5|| l_proc, 70);
         hr_utility.set_location('Information6 :' || r_extra_info_tab(g_current_record).information6|| l_proc, 80);

         g_current_record         := g_current_record + 1;
         hr_utility.set_location('Leaving :' || l_proc, 90);
         RETURN 'TRUE';
   END;
END;

/
