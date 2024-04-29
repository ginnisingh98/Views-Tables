--------------------------------------------------------
--  DDL for Package Body PQP_HRTCA_SYNCHRONIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_HRTCA_SYNCHRONIZATION" AS
/* $Header: pqphrtcasync.pkb 120.0 2005/05/29 02:22:06 appldev noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
   g_pkg       CONSTANT Varchar2(150) := 'PQP_HRTCA_Synchronization.';
-- =============================================================================
-- ~ Package Body Cursor variables:
-- =============================================================================
   -- Cursor to check if person is student
   CURSOR csr_stu (c_person_id IN Number) IS
    SELECT pei.pei_information5
      FROM per_people_extra_info  pei
     WHERE pei.information_type         = 'PQP_OSS_PERSON_DETAILS'
       AND pei.pei_information_category = 'PQP_OSS_PERSON_DETAILS'
       AND pei.person_id                = c_person_id;

   -- Get person party id
    CURSOR csr_partyid (c_person_id IN Number) IS
    SELECT ppf.party_id,pbg.legislation_code
      FROM per_all_people_f ppf
          ,per_business_groups_perf pbg
     WHERE ppf.person_id = c_person_id
       AND pbg.business_group_id = ppf.business_group_id;

   -- Cursor to get the leg. code
   CURSOR csr_bg_code (c_bg_grp_id IN Number) IS
   SELECT pbg.legislation_code
     FROM per_business_groups pbg
    WHERE pbg.business_group_id = c_bg_grp_id;

-- =============================================================================
-- ~ Pei_DDF_Ins:
-- =============================================================================
PROCEDURE Pei_DDF_Ins
         (p_person_extra_info_id     IN Number
         ,p_person_id                IN Number
         ,p_information_type         IN Varchar2
         -- DDF
         ,p_pei_information_category IN Varchar2
         ,p_pei_information1         IN Varchar2
         ,p_pei_information2         IN Varchar2
         ,p_pei_information3         IN Varchar2
         ,p_pei_information4         IN Varchar2
         ,p_pei_information5         IN Varchar2
         ,p_pei_information6         IN Varchar2
         ,p_pei_information7         IN Varchar2
         ,p_pei_information8         IN Varchar2
         ,p_pei_information9         IN Varchar2
         ,p_pei_information10        IN Varchar2
         ,p_pei_information11        IN Varchar2
         ,p_pei_information12        IN Varchar2
         ,p_pei_information13        IN Varchar2
         ,p_pei_information14        IN Varchar2
         ,p_pei_information15        IN Varchar2
         ,p_pei_information16        IN Varchar2
         ,p_pei_information17        IN Varchar2
         ,p_pei_information18        IN Varchar2
         ,p_pei_information19        IN Varchar2
         ,p_pei_information20        IN Varchar2
         ,p_pei_information21        IN Varchar2
         ,p_pei_information22        IN Varchar2
         ,p_pei_information23        IN Varchar2
         ,p_pei_information24        IN Varchar2
         ,p_pei_information25        IN Varchar2
         ,p_pei_information26        IN Varchar2
         ,p_pei_information27        IN Varchar2
         ,p_pei_information28        IN Varchar2
         ,p_pei_information29        IN Varchar2
         ,p_pei_information30        IN Varchar2
         ) AS
 l_return_flag         Boolean;
 l_party_id            per_all_people_f.party_id%TYPE;
 l_bg_code             per_business_groups.legislation_code%TYPE;
 l_Stu_OSSData_Sync    Varchar2(5);

 l_pei_rec             per_people_extra_info%ROWTYPE;
 l_proc_name  CONSTANT Varchar2(150):= g_pkg ||'Pei_DDF_Ins';

 BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  -- Check if the information type being created is for a student employee
  -- If yes, then check 1) if the data-sync flag is set to Y
  --                    2) profile option for Person info is Y
   OPEN csr_partyid (c_person_id => p_person_id);
  FETCH csr_partyid INTO l_party_id,l_bg_code;
  CLOSE csr_partyid;

   OPEN csr_stu (c_person_id => p_person_id);
  FETCH csr_stu INTO l_Stu_OSSData_Sync;
  CLOSE csr_stu;

  IF Nvl(l_Stu_OSSData_Sync,'-1') <> 'Y'  OR
     Nvl(l_bg_code,'-$') <> 'US' OR
     Nvl(Fnd_Profile.VALUE('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'N' OR
     l_party_id IS NULL
     THEN
     l_return_flag := TRUE;
  END IF;

  IF l_return_flag THEN
     RETURN;
  END IF;

  l_pei_rec.person_extra_info_id     := p_person_extra_info_id;
  l_pei_rec.person_id                := p_person_id;
  l_pei_rec.information_type         := p_information_type;
  -- DDF
  l_pei_rec.pei_information_category := p_pei_information_category;
  l_pei_rec.pei_information1         := p_pei_information1;
  l_pei_rec.pei_information2         := p_pei_information2;
  l_pei_rec.pei_information3         := p_pei_information3;
  l_pei_rec.pei_information4         := p_pei_information4;
  l_pei_rec.pei_information5         := p_pei_information5;
  l_pei_rec.pei_information6         := p_pei_information6;
  l_pei_rec.pei_information7         := p_pei_information7;
  l_pei_rec.pei_information8         := p_pei_information8;
  l_pei_rec.pei_information9         := p_pei_information9;
  l_pei_rec.pei_information10        := p_pei_information10;
  l_pei_rec.pei_information11        := p_pei_information11;
  l_pei_rec.pei_information12        := p_pei_information12;
  l_pei_rec.pei_information13        := p_pei_information13;
  l_pei_rec.pei_information14        := p_pei_information14;
  l_pei_rec.pei_information15        := p_pei_information15;
  l_pei_rec.pei_information16        := p_pei_information16;
  l_pei_rec.pei_information17        := p_pei_information17;
  l_pei_rec.pei_information18        := p_pei_information18;
  l_pei_rec.pei_information19        := p_pei_information19;
  l_pei_rec.pei_information20        := p_pei_information20;
  l_pei_rec.pei_information21        := p_pei_information21;
  l_pei_rec.pei_information22        := p_pei_information22;
  l_pei_rec.pei_information23        := p_pei_information23;
  l_pei_rec.pei_information24        := p_pei_information24;
  l_pei_rec.pei_information25        := p_pei_information25;
  l_pei_rec.pei_information26        := p_pei_information26;
  l_pei_rec.pei_information27        := p_pei_information27;
  l_pei_rec.pei_information28        := p_pei_information28;
  l_pei_rec.pei_information29        := p_pei_information29;
  l_pei_rec.pei_information30        := p_pei_information30;
  IF l_bg_code = 'US' THEN
     IF p_information_type = 'PER_US_PASSPORT_DETAILS' THEN
        -- Call the OSS Passport pkg
        Pqp_Hrtca_Integration.InsUpd_OSS_PassPort
        (p_person_id        => p_person_id
        ,p_party_id         => l_party_id
        ,p_action           => 'INSERT'
        ,p_pei_info_rec_old => NULL
        ,p_pei_info_rec_new => l_pei_rec
         );
     ELSIF p_information_type = 'PER_US_VISA_DETAILS' THEN
        -- Call the OSS Visa pkg
        Pqp_Hrtca_Integration.InsUpd_OSS_Visa
        (p_person_id        => p_person_id
        ,p_party_id         => l_party_id
        ,p_action           => 'INSERT'
        ,p_pei_info_rec_old => NULL
        ,p_pei_info_rec_new => l_pei_rec
         );
     ELSIF p_information_type = 'PER_US_VISIT_HISTORY' THEN
        -- Call the OSS Visa Visit History pkg
        Pqp_Hrtca_Integration.InsUpd_OSS_VisitHistory
        (p_person_id        => p_person_id
        ,p_party_id         => l_party_id
        ,p_action           => 'INSERT'
        ,p_pei_info_rec_old => NULL
        ,p_pei_info_rec_new => l_pei_rec
         );
     END IF;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);

END Pei_DDF_Ins;
-- =============================================================================
-- ~ Pei_DDF_Upd:
-- =============================================================================
PROCEDURE Pei_DDF_Upd
         (-- New PEI Information
          p_person_extra_info_id     IN Number
         ,p_person_id                IN Number
         ,p_information_type         IN Varchar2
          -- New DDF
         ,p_pei_information_category IN Varchar2
         ,p_pei_information1         IN Varchar2
         ,p_pei_information2         IN Varchar2
         ,p_pei_information3         IN Varchar2
         ,p_pei_information4         IN Varchar2
         ,p_pei_information5         IN Varchar2
         ,p_pei_information6         IN Varchar2
         ,p_pei_information7         IN Varchar2
         ,p_pei_information8         IN Varchar2
         ,p_pei_information9         IN Varchar2
         ,p_pei_information10        IN Varchar2
         ,p_pei_information11        IN Varchar2
         ,p_pei_information12        IN Varchar2
         ,p_pei_information13        IN Varchar2
         ,p_pei_information14        IN Varchar2
         ,p_pei_information15        IN Varchar2
         ,p_pei_information16        IN Varchar2
         ,p_pei_information17        IN Varchar2
         ,p_pei_information18        IN Varchar2
         ,p_pei_information19        IN Varchar2
         ,p_pei_information20        IN Varchar2
         ,p_pei_information21        IN Varchar2
         ,p_pei_information22        IN Varchar2
         ,p_pei_information23        IN Varchar2
         ,p_pei_information24        IN Varchar2
         ,p_pei_information25        IN Varchar2
         ,p_pei_information26        IN Varchar2
         ,p_pei_information27        IN Varchar2
         ,p_pei_information28        IN Varchar2
         ,p_pei_information29        IN Varchar2
         ,p_pei_information30        IN Varchar2
          -- Old PEI Information
         ,p_person_id_o              IN Number
         ,p_information_type_o       IN Varchar2
         ,p_pei_attribute_category_o IN Varchar2
          -- Old DDF
         ,p_pei_information_category_o IN Varchar2
         ,p_pei_information1_o       IN Varchar2
         ,p_pei_information2_o       IN Varchar2
         ,p_pei_information3_o       IN Varchar2
         ,p_pei_information4_o       IN Varchar2
         ,p_pei_information5_o       IN Varchar2
         ,p_pei_information6_o       IN Varchar2
         ,p_pei_information7_o       IN Varchar2
         ,p_pei_information8_o       IN Varchar2
         ,p_pei_information9_o       IN Varchar2
         ,p_pei_information10_o      IN Varchar2
         ,p_pei_information11_o      IN Varchar2
         ,p_pei_information12_o      IN Varchar2
         ,p_pei_information13_o      IN Varchar2
         ,p_pei_information14_o      IN Varchar2
         ,p_pei_information15_o      IN Varchar2
         ,p_pei_information16_o      IN Varchar2
         ,p_pei_information17_o      IN Varchar2
         ,p_pei_information18_o      IN Varchar2
         ,p_pei_information19_o      IN Varchar2
         ,p_pei_information20_o      IN Varchar2
         ,p_pei_information21_o      IN Varchar2
         ,p_pei_information22_o      IN Varchar2
         ,p_pei_information23_o      IN Varchar2
         ,p_pei_information24_o      IN Varchar2
         ,p_pei_information25_o      IN Varchar2
         ,p_pei_information26_o      IN Varchar2
         ,p_pei_information27_o      IN Varchar2
         ,p_pei_information28_o      IN Varchar2
         ,p_pei_information29_o      IN Varchar2
         ,p_pei_information30_o      IN Varchar2
         ) AS

 l_return_flag         Boolean;
 l_party_id            per_all_people_f.party_id%TYPE;
 l_Stu_OSSData_Sync    Varchar2(5);
 l_bg_code             per_business_groups.legislation_code%TYPE;
 l_pei_rec_new         per_people_extra_info%ROWTYPE;
 l_pei_rec_old         per_people_extra_info%ROWTYPE;
 l_proc_name  CONSTANT Varchar2(150):= g_pkg ||'Pei_DDF_Upd';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  -- Check if the information type being created is for a student employee
  -- If yes, then check 1) if the data-sync flag is set to N
  --                    2) profile option for Person info is Y
   OPEN csr_partyid (c_person_id => p_person_id);
  FETCH csr_partyid INTO l_party_id,l_bg_code;
  CLOSE csr_partyid;
   OPEN csr_stu (c_person_id => p_person_id);
  FETCH csr_stu INTO l_Stu_OSSData_Sync;
  CLOSE csr_stu;

  IF Nvl(l_Stu_OSSData_Sync,'-1') <> 'Y'  OR
     Nvl(l_bg_code,'-$') <> 'US' OR
     Nvl(Fnd_Profile.VALUE('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'N' OR
     l_party_id IS NULL
     THEN
     l_return_flag := TRUE;
  END IF;

  IF l_return_flag THEN
     RETURN;
  END IF;

  l_pei_rec_old.person_extra_info_id     := p_person_extra_info_id;
  l_pei_rec_old.person_id                := p_person_id_o;
  l_pei_rec_old.information_type         := p_information_type_o;
  -- DDF
  l_pei_rec_old.pei_information_category := p_pei_information_category_o;
  l_pei_rec_old.pei_information1         := p_pei_information1_o;
  l_pei_rec_old.pei_information2         := p_pei_information2_o;
  l_pei_rec_old.pei_information3         := p_pei_information3_o;
  l_pei_rec_old.pei_information4         := p_pei_information4_o;
  l_pei_rec_old.pei_information5         := p_pei_information5_o;
  l_pei_rec_old.pei_information6         := p_pei_information6_o;
  l_pei_rec_old.pei_information7         := p_pei_information7_o;
  l_pei_rec_old.pei_information8         := p_pei_information8_o;
  l_pei_rec_old.pei_information9         := p_pei_information9_o;
  l_pei_rec_old.pei_information10        := p_pei_information10_o;
  l_pei_rec_old.pei_information11        := p_pei_information11_o;
  l_pei_rec_old.pei_information12        := p_pei_information12_o;
  l_pei_rec_old.pei_information13        := p_pei_information13_o;
  l_pei_rec_old.pei_information14        := p_pei_information14_o;
  l_pei_rec_old.pei_information15        := p_pei_information15_o;
  l_pei_rec_old.pei_information16        := p_pei_information16_o;
  l_pei_rec_old.pei_information17        := p_pei_information17_o;
  l_pei_rec_old.pei_information18        := p_pei_information18_o;
  l_pei_rec_old.pei_information19        := p_pei_information19_o;
  l_pei_rec_old.pei_information20        := p_pei_information20_o;
  l_pei_rec_old.pei_information21        := p_pei_information21_o;
  l_pei_rec_old.pei_information22        := p_pei_information22_o;
  l_pei_rec_old.pei_information23        := p_pei_information23_o;
  l_pei_rec_old.pei_information24        := p_pei_information24_o;
  l_pei_rec_old.pei_information25        := p_pei_information25_o;
  l_pei_rec_old.pei_information26        := p_pei_information26_o;
  l_pei_rec_old.pei_information27        := p_pei_information27_o;
  l_pei_rec_old.pei_information28        := p_pei_information28_o;
  l_pei_rec_old.pei_information29        := p_pei_information29_o;
  l_pei_rec_old.pei_information30        := p_pei_information30_o;

  l_pei_rec_new.person_extra_info_id     := p_person_extra_info_id;
  l_pei_rec_new.person_id                := p_person_id;
  l_pei_rec_new.information_type         := p_information_type;
  -- DDF
  l_pei_rec_new.pei_information_category := p_pei_information_category;
  l_pei_rec_new.pei_information1         := p_pei_information1;
  l_pei_rec_new.pei_information2         := p_pei_information2;
  l_pei_rec_new.pei_information3         := p_pei_information3;
  l_pei_rec_new.pei_information4         := p_pei_information4;
  l_pei_rec_new.pei_information5         := p_pei_information5;
  l_pei_rec_new.pei_information6         := p_pei_information6;
  l_pei_rec_new.pei_information7         := p_pei_information7;
  l_pei_rec_new.pei_information8         := p_pei_information8;
  l_pei_rec_new.pei_information9         := p_pei_information9;
  l_pei_rec_new.pei_information10        := p_pei_information10;
  l_pei_rec_new.pei_information11        := p_pei_information11;
  l_pei_rec_new.pei_information12        := p_pei_information12;
  l_pei_rec_new.pei_information13        := p_pei_information13;
  l_pei_rec_new.pei_information14        := p_pei_information14;
  l_pei_rec_new.pei_information15        := p_pei_information15;
  l_pei_rec_new.pei_information16        := p_pei_information16;
  l_pei_rec_new.pei_information17        := p_pei_information17;
  l_pei_rec_new.pei_information18        := p_pei_information18;
  l_pei_rec_new.pei_information19        := p_pei_information19;
  l_pei_rec_new.pei_information20        := p_pei_information20;
  l_pei_rec_new.pei_information21        := p_pei_information21;
  l_pei_rec_new.pei_information22        := p_pei_information22;
  l_pei_rec_new.pei_information23        := p_pei_information23;
  l_pei_rec_new.pei_information24        := p_pei_information24;
  l_pei_rec_new.pei_information25        := p_pei_information25;
  l_pei_rec_new.pei_information26        := p_pei_information26;
  l_pei_rec_new.pei_information27        := p_pei_information27;
  l_pei_rec_new.pei_information28        := p_pei_information28;
  l_pei_rec_new.pei_information29        := p_pei_information29;
  l_pei_rec_new.pei_information30        := p_pei_information30;

  IF l_bg_code = 'US' THEN
     IF p_information_type = 'PER_US_PASSPORT_DETAILS' THEN
        -- Call the OSS Passport pkg
        Pqp_Hrtca_Integration.InsUpd_OSS_PassPort
        (p_person_id        => p_person_id
        ,p_party_id         => l_party_id
        ,p_action           => 'UPDATE'
        ,p_pei_info_rec_old => l_pei_rec_old
        ,p_pei_info_rec_new => l_pei_rec_new
         );
     ELSIF p_information_type = 'PER_US_VISA_DETAILS' THEN
        -- Call the OSS Visa pkg
        Pqp_Hrtca_Integration.InsUpd_OSS_Visa
        (p_person_id        => p_person_id
        ,p_party_id         => l_party_id
        ,p_action           => 'UPDATE'
        ,p_pei_info_rec_old => l_pei_rec_old
        ,p_pei_info_rec_new => l_pei_rec_new
         );
     ELSIF p_information_type = 'PER_US_VISIT_HISTORY' THEN
        Pqp_Hrtca_Integration.InsUpd_OSS_VisitHistory
        (p_person_id        => p_person_id
        ,p_party_id         => l_party_id
        ,p_action           => 'UPDATE'
        ,p_pei_info_rec_old => l_pei_rec_old
        ,p_pei_info_rec_new => l_pei_rec_new
         );
     END IF;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

END Pei_DDF_Upd;
-- =============================================================================
-- ~ Pei_DDF_Del:
-- =============================================================================
PROCEDURE Pei_DDF_Del
         (p_person_id_o              IN Number
         ,p_information_type_o       IN Varchar2
         ,p_pei_attribute_category_o IN Varchar2
         -- Old DDF
         ,p_pei_information_category_o IN Varchar2
         ,p_pei_information1_o       IN Varchar2
         ,p_pei_information2_o       IN Varchar2
         ,p_pei_information3_o       IN Varchar2
         ,p_pei_information4_o       IN Varchar2
         ,p_pei_information5_o       IN Varchar2
         ,p_pei_information6_o       IN Varchar2
         ,p_pei_information7_o       IN Varchar2
         ,p_pei_information8_o       IN Varchar2
         ,p_pei_information9_o       IN Varchar2
         ,p_pei_information10_o      IN Varchar2
         ,p_pei_information11_o      IN Varchar2
         ,p_pei_information12_o      IN Varchar2
         ,p_pei_information13_o      IN Varchar2
         ,p_pei_information14_o      IN Varchar2
         ,p_pei_information15_o      IN Varchar2
         ,p_pei_information16_o      IN Varchar2
         ,p_pei_information17_o      IN Varchar2
         ,p_pei_information18_o      IN Varchar2
         ,p_pei_information19_o      IN Varchar2
         ,p_pei_information20_o      IN Varchar2
         ,p_pei_information21_o      IN Varchar2
         ,p_pei_information22_o      IN Varchar2
         ,p_pei_information23_o      IN Varchar2
         ,p_pei_information24_o      IN Varchar2
         ,p_pei_information25_o      IN Varchar2
         ,p_pei_information26_o      IN Varchar2
         ,p_pei_information27_o      IN Varchar2
         ,p_pei_information28_o      IN Varchar2
         ,p_pei_information29_o      IN Varchar2
         ,p_pei_information30_o      IN Varchar2
         ) AS
 l_pei_rec             per_people_extra_info%ROWTYPE;
 l_proc_name  CONSTANT Varchar2(150):= g_pkg ||'Pei_DDF_Del';
 BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  NULL;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
END Pei_DDF_Del;

End PQP_HRTCA_Synchronization;

/
