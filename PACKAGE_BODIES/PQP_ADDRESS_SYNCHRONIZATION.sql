--------------------------------------------------------
--  DDL for Package Body PQP_ADDRESS_SYNCHRONIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ADDRESS_SYNCHRONIZATION" AS
/* $Header: pqaddsyn.pkb 120.0 2005/05/29 01:41:47 appldev noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
   g_pkg       CONSTANT Varchar2(150) := 'PQP_Address_Synchronization.';
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

    -- Get the primary address from OSS
    g_hz_add_sql CONSTANT Varchar2(1000) :=
    'SELECT hps.party_site_id ' ||
    '      ,hzl.location_id   ' ||
    '      ,hzl.object_version_number ' ||
    '      ,hps.object_version_number ' ||
    '      ,hzl.Rowid ' ||
    '      ,hzl.last_update_date    ' ||
    '  FROM hz_party_sites      hps ' ||
    '      ,hz_locations        hzl ' ||
    ' WHERE hps.party_id        = :c_party_id     ' ||
    '   AND hzl.location_id(+)  = hps.location_id ' ||
    '   AND hps.status          = '||'''A'''||
    '   AND hps.identifying_address_flag(+) = '||'''Y''';

   -- Cursor to get the leg. code
   CURSOR csr_bg_code (c_bg_grp_id IN Number) IS
   SELECT pbg.legislation_code
     FROM per_business_groups pbg
    WHERE pbg.business_group_id = c_bg_grp_id;

-- =============================================================================
-- ~ Addr_DDF_Ins:
-- =============================================================================
PROCEDURE Addr_DDF_Ins
         (p_address_id                   IN  Number
         ,p_business_group_id            IN  Number
         ,p_person_id                    IN  Number
         ,p_party_id                     IN  Number
         ,p_date_from                    IN  Date
         ,p_primary_flag                 IN  Varchar2
         ,p_style                        IN  Varchar2
         ,p_address_line1                IN  Varchar2
         ,p_address_line2                IN  Varchar2
         ,p_address_line3                IN  Varchar2
         ,p_address_type                 IN  Varchar2
         ,p_country                      IN  Varchar2
         ,p_date_to                      IN  Date
         ,p_postal_code                  IN  Varchar2
         ,p_region_1                     IN  Varchar2
         ,p_region_2                     IN  Varchar2
         ,p_region_3                     IN  Varchar2
         ,p_telephone_number_1           IN  Varchar2
         ,p_telephone_number_2           IN  Varchar2
         ,p_telephone_number_3           IN  Varchar2
         ,p_town_or_city                 IN  Varchar2
         ,p_add_information13            IN  Varchar2
         ,p_add_information14            IN  Varchar2
         ,p_add_information15            IN  Varchar2
         ,p_add_information16            IN  Varchar2
         ,p_add_information17            IN  Varchar2
         ,p_add_information18            IN  Varchar2
         ,p_add_information19            IN  Varchar2
         ,p_add_information20            IN  Varchar2
         ,p_object_version_number        IN  Number
         ,p_effective_date               IN  Date
         ,p_validate_county              IN  Boolean
         ) AS

  TYPE csr_oss_t  IS REF CURSOR;
   csr_hz_loc             csr_oss_t;
  --
  l_proc_name  CONSTANT Varchar2(150):= g_pkg ||'Addr_DDF_Ins';
  l_Stu_OSSData_Sync    Varchar2(5);
  l_return_flag         Boolean;
  l_addr_rec            per_addresses%ROWTYPE;
  l_addr_rec_new        per_addresses%ROWTYPE;
  l_addr_rec_old        per_addresses%ROWTYPE;
  l_last_update_date    Date;
  l_rowid               ROWID;
  --
  l_party_site_id       Number;
  l_location_id         Number;
  l_location_ovn        Number;
  l_party_site_ovn      Number;
  l_hz_loc_rowid        Rowid;
  l_hz_loc_upd_dt       Date;
  --
  l_create_oss_addr     Boolean;
  l_update_oss_addr     Boolean;
  --
  l_msg_data            Varchar2(2000);
  l_return_status       Varchar2(5);
  --

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
   OPEN csr_stu (c_person_id => p_person_id);
  FETCH csr_stu INTO l_Stu_OSSData_Sync;
  CLOSE csr_stu;
  --
  IF Nvl(l_Stu_OSSData_Sync,'-1') <> 'Y'  OR
     Nvl(p_primary_flag,'-1')     <> 'Y'  OR
     Nvl(Fnd_Profile.VALUE('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'N' OR
     p_party_id IS NULL
     THEN
     l_return_flag := TRUE;
  END IF;
  --
  IF l_return_flag THEN
     RETURN;
  END IF;
  OPEN csr_hz_loc FOR g_hz_add_sql
            Using p_party_id;
  FETCH csr_hz_loc INTO
        l_party_site_id,
        l_location_id,
        l_location_ovn,
        l_party_site_ovn,
        l_hz_loc_rowid,
        l_hz_loc_upd_dt;
  --
  IF csr_hz_loc%NOTFOUND THEN
    l_create_oss_addr := TRUE;
  ELSE
    l_update_oss_addr := TRUE;
  END IF;
  CLOSE csr_hz_loc;
  --
  l_addr_rec.address_id            := p_address_id;
  l_addr_rec.business_group_id     := p_business_group_id;
  l_addr_rec.person_id             := p_person_id;
  l_addr_rec.party_id              := p_party_id;
  l_addr_rec.date_from             := p_date_from;
  l_addr_rec.primary_flag          := p_primary_flag;
  l_addr_rec.style                 := p_style;
  l_addr_rec.address_line1         := p_address_line1;
  l_addr_rec.address_line2         := p_address_line2;
  l_addr_rec.address_line3         := p_address_line3;
  l_addr_rec.address_type          := p_address_type;
  l_addr_rec.country               := p_country;
  l_addr_rec.date_to               := p_date_to;
  l_addr_rec.postal_code           := p_postal_code;
  l_addr_rec.region_1              := p_region_1;
  l_addr_rec.region_2              := p_region_2;
  l_addr_rec.region_3              := p_region_3;
  l_addr_rec.telephone_number_1    := p_telephone_number_1;
  l_addr_rec.telephone_number_2    := p_telephone_number_2;
  l_addr_rec.telephone_number_3    := p_telephone_number_3;
  l_addr_rec.town_or_city          := p_town_or_city;
  l_addr_rec.add_information13     := p_add_information13;
  l_addr_rec.add_information14     := p_add_information14;
  l_addr_rec.add_information15     := p_add_information15;
  l_addr_rec.add_information16     := p_add_information16;
  l_addr_rec.add_information17     := p_add_information17;
  l_addr_rec.add_information18     := p_add_information18;
  l_addr_rec.add_information19     := p_add_information19;
  l_addr_rec.add_information20     := p_add_information20;
  l_addr_rec.object_version_number := p_object_version_number;
  --
  IF l_create_oss_addr THEN
     PQP_HRTCA_Integration.Create_Address_HR_To_TCA
     (p_business_group_id      => p_business_group_id
     ,p_person_id              => p_person_id
     ,p_party_id               => p_party_id
     ,p_address_id             => p_address_id
     ,p_effective_date         => p_effective_date
     ,p_per_addr_rec_new       => l_addr_rec
      -- TCA
     ,p_party_type             => 'PERSON'
     ,p_action                 => 'INSERT'
     ,p_status                 => 'A'
      -- In Out Variables
     ,p_location_id            => l_location_id
     ,p_party_site_id          => l_party_site_id
     ,p_last_update_date       => l_last_update_date
     ,p_party_site_ovn         => l_party_site_ovn
     ,p_location_ovn           => l_location_ovn
     ,p_rowid                  => l_rowid
      -- Out Variables
     ,p_return_status          => l_return_status
     ,p_msg_data               => l_msg_data
     );
  END IF;

  IF l_update_oss_addr THEN
     l_addr_rec_new := l_addr_rec;
     l_addr_rec_old := l_addr_rec;
     PQP_HRTCA_Integration.Update_Address_HR_To_TCA
     (p_business_group_id      => p_business_group_id
     ,p_person_id              => p_person_id
     ,p_party_id               => p_party_id
     ,p_address_id             => p_address_id
     ,p_effective_date         => p_effective_date
     ,p_per_addr_rec_new       => l_addr_rec_new
     ,p_per_addr_rec_old       => l_addr_rec_old
      -- TCA
     ,p_party_type             => 'PERSON'
     ,p_action                 => 'UPDATE'
     ,p_status                 => 'A'
      -- In Out Variables
     ,p_location_id            => l_location_id
     ,p_party_site_id          => l_party_site_id
     ,p_last_update_date       => l_hz_loc_upd_dt
     ,p_party_site_ovn         => l_party_site_ovn
     ,p_location_ovn           => l_location_ovn
     ,p_rowid                  => l_hz_loc_rowid
      -- Out Variables
     ,p_return_status          => l_return_status
     ,p_msg_data               => l_msg_data
     );
  END IF;

  IF l_return_status IN ('E','U') THEN
     Hr_Utility.set_location('SQLCODE :'||SQLCODE,90);
     Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
     Hr_Utility.set_message_token('GENERIC_TOKEN',l_msg_data );
     Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
     Hr_Utility.raise_error;
  END IF;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

END Addr_DDF_Ins;
-- =============================================================================
-- ~ Addr_DDF_Upd:
-- =============================================================================
PROCEDURE Addr_DDF_Upd
         (p_address_id                   IN  Number
         ,p_business_group_id            IN  Number
         ,p_person_id                    IN  Number
         ,p_date_from                    IN  Date
         ,p_address_line1                IN  Varchar2
         ,p_address_line2                IN  Varchar2
         ,p_address_line3                IN  Varchar2
         ,p_address_type                 IN  Varchar2
         ,p_country                      IN  Varchar2
         ,p_date_to                      IN  Date
         ,p_postal_code                  IN  Varchar2
         ,p_region_1                     IN  Varchar2
         ,p_region_2                     IN  Varchar2
         ,p_region_3                     IN  Varchar2
         ,p_telephone_number_1           IN  Varchar2
         ,p_telephone_number_2           IN  Varchar2
         ,p_telephone_number_3           IN  Varchar2
         ,p_town_or_city                 IN  Varchar2
         ,p_add_information13            IN  Varchar2
         ,p_add_information14            IN  Varchar2
         ,p_add_information15            IN  Varchar2
         ,p_add_information16            IN  Varchar2
         ,p_add_information17            IN  Varchar2
         ,p_add_information18            IN  Varchar2
         ,p_add_information19            IN  Varchar2
         ,p_add_information20            IN  Varchar2
         ,p_object_version_number        IN  Number
         ,p_effective_date               IN  Date
         ,p_prflagval_override           IN  Boolean
         ,p_validate_county              IN  Boolean
         -- Old
         ,p_business_group_id_o          IN  Number
         ,p_person_id_o                  IN  Number
         ,p_date_from_o                  IN  Date
         ,p_primary_flag_o               IN  Varchar2
         ,p_style_o                      IN  Varchar2
         ,p_address_line1_o              IN  Varchar2
         ,p_address_line2_o              IN  Varchar2
         ,p_address_line3_o              IN  Varchar2
         ,p_address_type_o               IN  Varchar2
         ,p_country_o                    IN  Varchar2
         ,p_date_to_o                    IN  Date
         ,p_postal_code_o                IN  Varchar2
         ,p_region_1_o                   IN  Varchar2
         ,p_region_2_o                   IN  Varchar2
         ,p_region_3_o                   IN  Varchar2
         ,p_telephone_number_1_o         IN  Varchar2
         ,p_telephone_number_2_o         IN  Varchar2
         ,p_telephone_number_3_o         IN  Varchar2
         ,p_town_or_city_o               IN  Varchar2
         ,p_add_information13_o          IN  Varchar2
         ,p_add_information14_o          IN  Varchar2
         ,p_add_information15_o          IN  Varchar2
         ,p_add_information16_o          IN  Varchar2
         ,p_add_information17_o          IN  Varchar2
         ,p_add_information18_o          IN  Varchar2
         ,p_add_information19_o          IN  Varchar2
         ,p_add_information20_o          IN  Varchar2
         ,p_object_version_number_o      IN  Number
         ,p_party_id_o                   IN  Number
         ) AS
  TYPE csr_oss_t  IS REF CURSOR;
   csr_hz_loc             csr_oss_t;
  --
  l_proc_name  CONSTANT Varchar2(150):= g_pkg ||'Addr_DDF_Upd';
  l_Stu_OSSData_Sync    Varchar2(5);
  l_return_flag         Boolean;
  l_addr_rec_new        per_addresses%ROWTYPE;
  l_addr_rec_old        per_addresses%ROWTYPE;
  --
  l_party_site_id       Number;
  l_location_id         Number;
  l_location_ovn        Number;
  l_party_site_ovn      Number;
  l_hz_loc_rowid        Rowid;
  l_hz_loc_upd_dt       Date;
  --
  l_msg_data            Varchar2(2000);
  l_return_status       Varchar2(5);
  l_create_oss_addr     Boolean;
  l_update_oss_addr     Boolean;
  --
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  OPEN csr_stu (c_person_id => p_person_id);
  FETCH csr_stu INTO l_Stu_OSSData_Sync;
  CLOSE csr_stu;
  --
  IF Nvl(l_Stu_OSSData_Sync,'-1') <> 'Y'  OR
     Nvl(p_primary_flag_o,'-1')   <> 'Y'  OR
     Nvl(Fnd_Profile.VALUE('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'N' OR
     p_party_id_o IS NULL
     THEN
     l_return_flag := TRUE;
  END IF;
  --
  IF l_return_flag THEN
     RETURN;
  END IF;
  OPEN csr_hz_loc FOR g_hz_add_sql
            Using p_party_id_o;
  FETCH csr_hz_loc INTO
        l_party_site_id,
        l_location_id,
        l_location_ovn,
        l_party_site_ovn,
        l_hz_loc_rowid,
        l_hz_loc_upd_dt;
  IF csr_hz_loc%NOTFOUND THEN
    l_create_oss_addr := TRUE;
  ELSE
    l_update_oss_addr := TRUE;
  END IF;
  CLOSE csr_hz_loc;

  l_addr_rec_old.address_id            := p_address_id;
  -- Old Values
  l_addr_rec_old.person_id             := p_person_id_o;
  l_addr_rec_old.business_group_id     := p_business_group_id_o;
  l_addr_rec_old.party_id              := p_party_id_o;
  l_addr_rec_old.primary_flag          := p_primary_flag_o;
  l_addr_rec_old.date_from             := p_date_from_o;
  l_addr_rec_old.date_to               := p_date_to_o;
  l_addr_rec_old.style                 := p_style_o;
  l_addr_rec_old.address_line1         := p_address_line1_o;
  l_addr_rec_old.address_line2         := p_address_line2_o;
  l_addr_rec_old.address_line3         := p_address_line3_o;
  l_addr_rec_old.address_type          := p_address_type_o;
  l_addr_rec_old.country               := p_country_o;
  l_addr_rec_old.postal_code           := p_postal_code_o;
  l_addr_rec_old.region_1              := p_region_1_o;
  l_addr_rec_old.region_2              := p_region_2_o;
  l_addr_rec_old.region_3              := p_region_3_o;
  l_addr_rec_old.telephone_number_1    := p_telephone_number_1_o;
  l_addr_rec_old.telephone_number_2    := p_telephone_number_2_o;
  l_addr_rec_old.telephone_number_3    := p_telephone_number_3_o;
  l_addr_rec_old.town_or_city          := p_town_or_city_o;
  l_addr_rec_old.add_information13     := p_add_information13_o;
  l_addr_rec_old.add_information14     := p_add_information14_o;
  l_addr_rec_old.add_information15     := p_add_information15_o;
  l_addr_rec_old.add_information16     := p_add_information16_o;
  l_addr_rec_old.add_information17     := p_add_information17_o;
  l_addr_rec_old.add_information18     := p_add_information18_o;
  l_addr_rec_old.add_information19     := p_add_information19_o;
  l_addr_rec_old.add_information20     := p_add_information20_o;
  l_addr_rec_old.object_version_number := p_object_version_number_o;
  --
  -- New Values
  --
  l_addr_rec_new.address_id            := p_address_id;
  l_addr_rec_new.business_group_id     := p_business_group_id;
  l_addr_rec_new.person_id             := p_person_id;
  l_addr_rec_new.date_from             := p_date_from;
  l_addr_rec_new.style                 := p_style_o;
  l_addr_rec_new.address_line1         := p_address_line1;
  l_addr_rec_new.address_line2         := p_address_line2;
  l_addr_rec_new.address_line3         := p_address_line3;
  l_addr_rec_new.address_type          := p_address_type;
  l_addr_rec_new.country               := p_country;
  l_addr_rec_new.date_to               := p_date_to;
  l_addr_rec_new.postal_code           := p_postal_code;
  l_addr_rec_new.region_1              := p_region_1;
  l_addr_rec_new.region_2              := p_region_2;
  l_addr_rec_new.region_3              := p_region_3;
  l_addr_rec_new.telephone_number_1    := p_telephone_number_1;
  l_addr_rec_new.telephone_number_2    := p_telephone_number_2;
  l_addr_rec_new.telephone_number_3    := p_telephone_number_3;
  l_addr_rec_new.town_or_city          := p_town_or_city;
  l_addr_rec_new.add_information13     := p_add_information13;
  l_addr_rec_new.add_information14     := p_add_information14;
  l_addr_rec_new.add_information15     := p_add_information15;
  l_addr_rec_new.add_information16     := p_add_information16;
  l_addr_rec_new.add_information17     := p_add_information17;
  l_addr_rec_new.add_information18     := p_add_information18;
  l_addr_rec_new.add_information19     := p_add_information19;
  l_addr_rec_new.add_information20     := p_add_information20;
  l_addr_rec_new.object_version_number := p_object_version_number;
  --
  IF l_create_oss_addr THEN
     Pqp_Hrtca_Integration.Create_Address_HR_To_TCA
     (p_business_group_id      => p_business_group_id
     ,p_person_id              => p_person_id
     ,p_party_id               => p_party_id_o
     ,p_address_id             => p_address_id
     ,p_effective_date         => p_effective_date
     ,p_per_addr_rec_new       => l_addr_rec_new
      -- TCA
     ,p_party_type             => 'PERSON'
     ,p_action                 => 'INSERT'
     ,p_status                 => 'A'
      -- In Out Variables
     ,p_location_id            => l_location_id
     ,p_party_site_id          => l_party_site_id
     ,p_last_update_date       => l_hz_loc_upd_dt
     ,p_party_site_ovn         => l_party_site_ovn
     ,p_location_ovn           => l_location_ovn
     ,p_rowid                  => l_hz_loc_rowid
      -- Out Variables
     ,p_return_status          => l_return_status
     ,p_msg_data               => l_msg_data
     );
  END IF;
  --
  IF l_update_oss_addr THEN
     Pqp_Hrtca_Integration.Update_Address_HR_To_TCA
     (p_business_group_id      => p_business_group_id
     ,p_person_id              => p_person_id
     ,p_party_id               => p_party_id_o
     ,p_address_id             => p_address_id
     ,p_effective_date         => p_effective_date
     ,p_per_addr_rec_new       => l_addr_rec_new
     ,p_per_addr_rec_old       => l_addr_rec_old
      -- TCA
     ,p_party_type             => 'PERSON'
     ,p_action                 => 'UPDATE'
     ,p_status                 => 'A'
      -- In Out Variables
     ,p_location_id            => l_location_id
     ,p_party_site_id          => l_party_site_id
     ,p_last_update_date       => l_hz_loc_upd_dt
     ,p_party_site_ovn         => l_party_site_ovn
     ,p_location_ovn           => l_location_ovn
     ,p_rowid                  => l_hz_loc_rowid
      -- Out Variables
     ,p_return_status          => l_return_status
     ,p_msg_data               => l_msg_data
     );
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  IF l_return_status IN ('E','U') THEN
     Hr_Utility.set_location('SQLCODE :'||SQLCODE,90);
     Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
     Hr_Utility.set_message_token('GENERIC_TOKEN',l_msg_data );
     Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
     Hr_Utility.raise_error;
  END IF;

END Addr_DDF_Upd;
-- =============================================================================
-- ~ Addr_DDF_Del:
-- =============================================================================
PROCEDURE Addr_DDF_Del
         (p_address_id                   IN  Number
         ,p_business_group_id_o          IN  Number
         ,p_date_from_o                  IN  Date
         ,p_address_line1_o              IN  Varchar2
         ,p_address_line2_o              IN  Varchar2
         ,p_address_line3_o              IN  Varchar2
         ,p_address_type_o               IN  Varchar2
         ,p_country_o                    IN  Varchar2
         ,p_date_to_o                    IN  Date
         ,p_postal_code_o                IN  Varchar2
         ,p_region_1_o                   IN  Varchar2
         ,p_region_2_o                   IN  Varchar2
         ,p_region_3_o                   IN  Varchar2
         ,p_telephone_number_1_o         IN  Varchar2
         ,p_telephone_number_2_o         IN  Varchar2
         ,p_telephone_number_3_o         IN  Varchar2
         ,p_town_or_city_o               IN  Varchar2
         ,p_add_information13_o          IN  Varchar2
         ,p_add_information14_o          IN  Varchar2
         ,p_add_information15_o          IN  Varchar2
         ,p_add_information16_o          IN  Varchar2
         ,p_add_information17_o          IN  Varchar2
         ,p_add_information18_o          IN  Varchar2
         ,p_add_information19_o          IN  Varchar2
         ,p_add_information20_o          IN  Varchar2
         ,p_object_version_number_o      IN  Number
         ) AS

 l_proc_name  CONSTANT Varchar2(150):= g_pkg ||'Addr_DDF_Del';

BEGIN
 Hr_Utility.set_location('Entering: '||l_proc_name, 5);
 NULL;
 Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Addr_DDF_Del;

End PQP_Address_Synchronization;

/
