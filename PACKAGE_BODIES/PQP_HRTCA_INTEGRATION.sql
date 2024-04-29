--------------------------------------------------------
--  DDL for Package Body PQP_HRTCA_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_HRTCA_INTEGRATION" AS
/* $Header: pqphrtcaintg.pkb 120.3 2007/07/27 12:29:18 dbansal noship $ */

-- =============================================================================
-- ~ Global variables:
-- =============================================================================
   g_pkg       CONSTANT Varchar2(150) := 'PQP_HRTCA_Integration.';
   g_adddt_sql CONSTANT Varchar2(1000) :=
               'SELECT ihs.start_date ' ||
               '      ,ihs.end_date ' ||
               '      ,hps.identifying_address_flag ' ||
               '  FROM hz_party_sites      hps ' ||
               '      ,igs_pe_hz_pty_sites ihs ' ||
               ' WHERE ihs.party_site_id(+) = hps.party_site_id ' ||
               '   AND hps.party_id         = :c_party_id ' ||
               '   AND hps.location_id      = :c_location_id ' ||
               '   AND hps.identifying_address_flag = '||'''Y''';


    -- Cursor to get the existing address details to update
    g_hz_add_sql CONSTANT Varchar2(1000) :=
    '  SELECT hzl.location_id
          ,hps.party_site_id
          ,hzl.last_update_date
          ,hps.object_version_number
          ,hzl.object_version_number
          ,hzl.ROWID
    FROM  hz_party_sites      hps
         ,hz_locations        hzl
    WHERE hps.party_id(+)                 = :c_party_id
      AND hzl.location_id(+)              = hps.location_id
      AND hps.identifying_address_flag(+) = '||'''Y''';

   g_business_group_id  Number;
   g_leg_code           Varchar2(5);
   g_effective_date     Date;

-- =============================================================================
-- ~ SQL Cursor's and variables:
-- =============================================================================
   -- Get the mapping value based on the info. category
   CURSOR csr_TCA_Map (c_info_category   IN Varchar2
                      ,c_bg_grp_id       IN Number
                      ,c_bg_grp_leg_code IN Varchar2) IS
   SELECT *
     FROM pqp_configuration_values pcv
    WHERE pcv.pcv_information_category = c_info_category
      AND ((pcv.business_group_id = c_bg_grp_id) OR
           (pcv.legislation_code  = c_bg_grp_leg_code AND
            pcv.business_group_id IS NULL)       OR
           (pcv.business_group_id IS NULL AND
            pcv.legislation_code  IS NULL)
          );

   -- Get the meaning and code for a lookup type
   CURSOR csr_meaning_code (c_lookup_type    IN Varchar2
                           ,c_meaning        IN Varchar2
                           ,c_effective_date IN Date) IS
   SELECT hrl.meaning
         ,hrl.lookup_code
     FROM hr_lookups hrl
    WHERE hrl.lookup_type         = c_lookup_type
      AND (Upper(hrl.meaning)     = Upper(c_meaning)
           OR
           Upper(hrl.lookup_code) = Upper(c_meaning)
           )
      AND Trunc(g_effective_date)
          BETWEEN Nvl(hrl.start_date_active,Trunc(g_effective_date))
              AND Nvl(hrl.end_date_active,  Trunc(g_effective_date));
   -- Cursor to get the country codes mapping
   CURSOR csr_cntry_code
          (c_country_code IN Varchar2
          ,c_map_to       IN Varchar2) IS
   SELECT hrl.lookup_code ins_code
         ,hrl.meaning     ins_mapping
         ,irs.lookup_code irs_code
         ,irs.meaning     irs_meaning
     FROM hr_lookups hrl,
          hr_lookups irs
    WHERE hrl.lookup_type = 'PQP_US_COUNTRY_TRANSLATE'
      AND hrl.enabled_flag = 'Y'
      AND irs.lookup_type  = 'PER_US_COUNTRY_CODE'
      AND irs.enabled_flag = 'Y'
      AND irs.lookup_code = substrb(hrl.meaning,-2)
      AND ( (c_map_to = 'HR_TO_OSS' AND
             hrl.lookup_code = c_country_code)
             OR
            (c_map_to = 'OSS_TO_HR' AND
             irs.lookup_code = c_country_code)
          );

   -- Cursor to get the leg. code
   CURSOR csr_bg_code (c_bg_grp_id IN Number) IS
   SELECT pbg.legislation_code
     FROM per_business_groups pbg
    WHERE pbg.business_group_id = c_bg_grp_id;

   -- Cursor to get the TCA location
   CURSOR csr_hz_loc (c_location_id IN Number) IS
   SELECT *
     FROM hz_locations hzl
    WHERE hzl.location_id = c_location_id;

   -- Cursor to get the party site id
   CURSOR csr_site_id (c_party_id     IN Number
                      ,c_primary_flag IN Varchar2) IS
   SELECT *
     FROM hz_party_sites hps
    WHERE hps.party_id                 = c_party_id
      AND hps.identifying_address_flag = c_primary_flag
      AND hps.status = 'A';

   -- Cursor to check if the Address Style context exists
   CURSOR csr_style (c_context_code IN Varchar2) IS
   SELECT dfc.descriptive_flex_context_code
     FROM fnd_descr_flex_contexts dfc
    WHERE dfc.application_id             = 800
      AND dfc.Descriptive_flexfield_name = 'Address Structure'
      AND dfc.enabled_flag ='Y';

   -- Cursor to check if local legislation is installed for a leg code
   CURSOR csr_chk_prod (c_leg_code       IN Varchar2
                       ,c_app_short_name IN Varchar2) IS
   SELECT hli.status
         ,hli.pi_steps_exist
     FROM hr_legislation_installations hli
    WHERE hli.legislation_code       = c_leg_code
      AND hli.application_short_name = c_app_short_name;

-- =============================================================================
-- ~ Chk_OSS_Install: Check to see if the OSS product is installed or not. This
-- ~ check is req. before launching the student search page.
-- =============================================================================
Function Chk_OSS_Install
         Return Varchar2 Is

  Cursor csr_install Is
  select fpi.product_version
        ,fpi.status
        ,fpi.db_status
        ,fpi.patch_level
        ,substr(fpi.patch_level,9,1) level_char -- fix for bug 5162947.
    from fnd_product_installations fpi
        ,fnd_application         app
   where fpi.application_id = app.application_id
     and app.application_short_name ='IGS';
  l_prd_dtls  csr_install%ROWTYPE;
  l_return_value Varchar2(5);

Begin
  l_return_value := 'N';
  Open csr_install;
  Fetch csr_install Into l_prd_dtls;
  If csr_install%FOUND Then
     If l_prd_dtls.db_status <> 'I' and
        l_prd_dtls.status <> 'I' Then
        Return l_return_value;
     Else
     /* The check has been modified based on the product version. The earlier code
      was catering only the need for 11i. As of current only version A of R12 has been
      released, we are avoiding writing any check based on level_char.
      At a later point, we should add similar check for R12 level version as is being
      currently done for 11i */
        If substr(l_prd_dtls.product_version,1,2)='11' and l_prd_dtls.level_char < 'L' Then
           l_return_value := 'N';
           Return l_return_value;
        End If;
        l_return_value := 'Y';
     End If;
  End If;
  Close csr_install;
  Return l_return_value;

Exception
  When Others Then
   Return l_return_value;
End Chk_OSS_Install;


-- =============================================================================
-- ~ InsUpd_Per_Extra_info: Insert, Update or Delete Person Extra Information
-- =============================================================================
PROCEDURE InsUpd_Per_Extra_info
          (p_person_id         IN Number
          ,p_business_group_id IN Number
          ,p_validate          IN Boolean DEFAULT FALSE
          ,p_action            IN Varchar2
          ,p_extra_info_rec    IN OUT NOCOPY per_people_extra_info%ROWTYPE
           ) IS

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'InsUpd_Per_Extra_info';
  l_error_msg              Varchar2(2000);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  IF p_action = 'CREATE' THEN
   Hr_Person_Extra_Info_Api.Create_Person_Extra_Info
   (p_validate                 => p_validate
   ,p_person_id                => p_person_id
   -- DDF Segments
   ,p_information_type         => p_extra_info_rec.information_type
   ,p_pei_information_category => p_extra_info_rec.pei_information_category
   ,p_pei_information1         => p_extra_info_rec.pei_information1
   ,p_pei_information2         => p_extra_info_rec.pei_information2
   ,p_pei_information3         => p_extra_info_rec.pei_information3
   ,p_pei_information4         => p_extra_info_rec.pei_information4
   ,p_pei_information5         => p_extra_info_rec.pei_information5
   ,p_pei_information6         => p_extra_info_rec.pei_information6
   ,p_pei_information7         => p_extra_info_rec.pei_information7
   ,p_pei_information8         => p_extra_info_rec.pei_information8
   ,p_pei_information9         => p_extra_info_rec.pei_information9
   ,p_pei_information10        => p_extra_info_rec.pei_information10
   ,p_pei_information11        => p_extra_info_rec.pei_information11
   ,p_pei_information12        => p_extra_info_rec.pei_information12
   ,p_pei_information13        => p_extra_info_rec.pei_information13
   ,p_pei_information14        => p_extra_info_rec.pei_information14
   ,p_pei_information15        => p_extra_info_rec.pei_information15
   ,p_pei_information16        => p_extra_info_rec.pei_information16
   ,p_pei_information17        => p_extra_info_rec.pei_information17
   ,p_pei_information18        => p_extra_info_rec.pei_information18
   ,p_pei_information19        => p_extra_info_rec.pei_information19
   ,p_pei_information20        => p_extra_info_rec.pei_information20
   ,p_pei_information21        => p_extra_info_rec.pei_information21
   ,p_pei_information22        => p_extra_info_rec.pei_information22
   ,p_pei_information23        => p_extra_info_rec.pei_information23
   ,p_pei_information24        => p_extra_info_rec.pei_information24
   ,p_pei_information25        => p_extra_info_rec.pei_information25
   ,p_pei_information26        => p_extra_info_rec.pei_information26
   ,p_pei_information27        => p_extra_info_rec.pei_information27
   ,p_pei_information28        => p_extra_info_rec.pei_information28
   ,p_pei_information29        => p_extra_info_rec.pei_information29
   ,p_pei_information30        => p_extra_info_rec.pei_information30
   -- DF Segments
   ,p_pei_attribute_category   => p_extra_info_rec.pei_attribute_category
   ,p_pei_attribute1           => p_extra_info_rec.pei_attribute1
   ,p_pei_attribute2           => p_extra_info_rec.pei_attribute2
   ,p_pei_attribute3           => p_extra_info_rec.pei_attribute3
   ,p_pei_attribute4           => p_extra_info_rec.pei_attribute4
   ,p_pei_attribute5           => p_extra_info_rec.pei_attribute5
   ,p_pei_attribute6           => p_extra_info_rec.pei_attribute6
   ,p_pei_attribute7           => p_extra_info_rec.pei_attribute7
   ,p_pei_attribute8           => p_extra_info_rec.pei_attribute8
   ,p_pei_attribute9           => p_extra_info_rec.pei_attribute9
   ,p_pei_attribute10          => p_extra_info_rec.pei_attribute10
   ,p_pei_attribute11          => p_extra_info_rec.pei_attribute11
   ,p_pei_attribute12          => p_extra_info_rec.pei_attribute12
   ,p_pei_attribute13          => p_extra_info_rec.pei_attribute13
   ,p_pei_attribute14          => p_extra_info_rec.pei_attribute14
   ,p_pei_attribute15          => p_extra_info_rec.pei_attribute15
   ,p_pei_attribute16          => p_extra_info_rec.pei_attribute16
   ,p_pei_attribute17          => p_extra_info_rec.pei_attribute17
   ,p_pei_attribute18          => p_extra_info_rec.pei_attribute18
   ,p_pei_attribute19          => p_extra_info_rec.pei_attribute19
   ,p_pei_attribute20          => p_extra_info_rec.pei_attribute20
    --
   ,p_person_extra_info_id     => p_extra_info_rec.person_extra_info_id
   ,p_object_version_number    => p_extra_info_rec.object_version_number
    );
  ELSIF p_action = 'UPDATE' THEN
   Hr_Person_Extra_Info_Api.Update_Person_Extra_Info
   (p_validate                 => p_validate
   ,p_person_extra_info_id     => p_extra_info_rec.person_extra_info_id
   ,p_object_version_number    => p_extra_info_rec.object_version_number
    --
   ,p_pei_information_category => p_extra_info_rec.pei_information_category
   ,p_pei_information1         => p_extra_info_rec.pei_information1
   ,p_pei_information2         => p_extra_info_rec.pei_information2
   ,p_pei_information3         => p_extra_info_rec.pei_information3
   ,p_pei_information4         => p_extra_info_rec.pei_information4
   ,p_pei_information5         => p_extra_info_rec.pei_information5
   ,p_pei_information6         => p_extra_info_rec.pei_information6
   ,p_pei_information7         => p_extra_info_rec.pei_information7
   ,p_pei_information8         => p_extra_info_rec.pei_information8
   ,p_pei_information9         => p_extra_info_rec.pei_information9
   ,p_pei_information10        => p_extra_info_rec.pei_information10
   ,p_pei_information11        => p_extra_info_rec.pei_information11
   ,p_pei_information12        => p_extra_info_rec.pei_information12
   ,p_pei_information13        => p_extra_info_rec.pei_information13
   ,p_pei_information14        => p_extra_info_rec.pei_information14
   ,p_pei_information15        => p_extra_info_rec.pei_information15
   ,p_pei_information16        => p_extra_info_rec.pei_information16
   ,p_pei_information17        => p_extra_info_rec.pei_information17
   ,p_pei_information18        => p_extra_info_rec.pei_information18
   ,p_pei_information19        => p_extra_info_rec.pei_information19
   ,p_pei_information20        => p_extra_info_rec.pei_information20
   ,p_pei_information21        => p_extra_info_rec.pei_information21
   ,p_pei_information22        => p_extra_info_rec.pei_information22
   ,p_pei_information23        => p_extra_info_rec.pei_information23
   ,p_pei_information24        => p_extra_info_rec.pei_information24
   ,p_pei_information25        => p_extra_info_rec.pei_information25
   ,p_pei_information26        => p_extra_info_rec.pei_information26
   ,p_pei_information27        => p_extra_info_rec.pei_information27
   ,p_pei_information28        => p_extra_info_rec.pei_information28
   ,p_pei_information29        => p_extra_info_rec.pei_information29
   ,p_pei_information30        => p_extra_info_rec.pei_information30
   -- DF Segments
   ,p_pei_attribute_category   => p_extra_info_rec.pei_attribute_category
   ,p_pei_attribute1           => p_extra_info_rec.pei_attribute1
   ,p_pei_attribute2           => p_extra_info_rec.pei_attribute2
   ,p_pei_attribute3           => p_extra_info_rec.pei_attribute3
   ,p_pei_attribute4           => p_extra_info_rec.pei_attribute4
   ,p_pei_attribute5           => p_extra_info_rec.pei_attribute5
   ,p_pei_attribute6           => p_extra_info_rec.pei_attribute6
   ,p_pei_attribute7           => p_extra_info_rec.pei_attribute7
   ,p_pei_attribute8           => p_extra_info_rec.pei_attribute8
   ,p_pei_attribute9           => p_extra_info_rec.pei_attribute9
   ,p_pei_attribute10          => p_extra_info_rec.pei_attribute10
   ,p_pei_attribute11          => p_extra_info_rec.pei_attribute11
   ,p_pei_attribute12          => p_extra_info_rec.pei_attribute12
   ,p_pei_attribute13          => p_extra_info_rec.pei_attribute13
   ,p_pei_attribute14          => p_extra_info_rec.pei_attribute14
   ,p_pei_attribute15          => p_extra_info_rec.pei_attribute15
   ,p_pei_attribute16          => p_extra_info_rec.pei_attribute16
   ,p_pei_attribute17          => p_extra_info_rec.pei_attribute17
   ,p_pei_attribute18          => p_extra_info_rec.pei_attribute18
   ,p_pei_attribute19          => p_extra_info_rec.pei_attribute19
   ,p_pei_attribute20          => p_extra_info_rec.pei_attribute20
   );
  ELSIF p_action ='DELETE' THEN
   Hr_Person_Extra_Info_Api.Delete_Person_Extra_Info
   (p_validate                 => p_validate
   ,p_person_extra_info_id     => p_extra_info_rec.person_extra_info_id
   ,p_object_version_number    => p_extra_info_rec.object_version_number
   );
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;

END InsUpd_Per_Extra_info;
-- =============================================================================
-- ~ InsUpd_SIT_info:
-- =============================================================================
PROCEDURE InsUpd_SIT_info
         (p_person_id             IN Number
         ,p_business_group_id     IN Number
         ,p_validate              IN Boolean
         ,p_effective_date        IN Date
         ,p_action                IN Varchar2
         ,p_analysis_criteria_rec IN OUT NOCOPY per_analysis_criteria%ROWTYPE
         ,p_analyses_rec          IN OUT NOCOPY per_person_analyses%ROWTYPE
          ) IS

  l_proc_name  CONSTANT    Varchar2(150):= g_pkg ||'InsUpd_SIT_info';
  l_error_msg              Varchar2(2000);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  IF p_action = 'CREATE' THEN
   Hr_SIT_Api.Create_SIT
   (p_validate                  => p_validate
   ,p_person_id                 => p_person_id
   ,p_business_group_id         => p_business_group_id
   ,p_effective_date            => p_effective_date
   ,p_id_flex_num               => p_analyses_rec.id_flex_num
   ,p_comments                  => Null
   ,p_date_from                 => p_analyses_rec.date_from
   ,p_date_to                   => p_analyses_rec.date_to
   --
   ,p_request_id                => p_analyses_rec.request_id
   ,p_program_application_id    => p_analyses_rec.program_application_id
   ,p_program_id                => p_analyses_rec.program_id
   ,p_program_update_date       => p_analyses_rec.program_update_date
   --
   ,p_attribute_category        => p_analyses_rec.attribute_category
   ,p_attribute1                => p_analyses_rec.attribute1
   ,p_attribute2                => p_analyses_rec.attribute2
   ,p_attribute3                => p_analyses_rec.attribute3
   ,p_attribute4                => p_analyses_rec.attribute4
   ,p_attribute5                => p_analyses_rec.attribute5
   ,p_attribute6                => p_analyses_rec.attribute6
   ,p_attribute7                => p_analyses_rec.attribute7
   ,p_attribute8                => p_analyses_rec.attribute8
   ,p_attribute9                => p_analyses_rec.attribute9
   ,p_attribute10               => p_analyses_rec.attribute10
   ,p_attribute11               => p_analyses_rec.attribute11
   ,p_attribute12               => p_analyses_rec.attribute12
   ,p_attribute13               => p_analyses_rec.attribute13
   ,p_attribute14               => p_analyses_rec.attribute14
   ,p_attribute15               => p_analyses_rec.attribute15
   ,p_attribute16               => p_analyses_rec.attribute16
   ,p_attribute17               => p_analyses_rec.attribute17
   ,p_attribute18               => p_analyses_rec.attribute18
   ,p_attribute19               => p_analyses_rec.attribute19
   ,p_attribute20               => p_analyses_rec.attribute20
   --
   ,p_segment1                  => p_analysis_criteria_rec.segment1
   ,p_segment2                  => p_analysis_criteria_rec.segment2
   ,p_segment3                  => p_analysis_criteria_rec.segment3
   ,p_segment4                  => p_analysis_criteria_rec.segment4
   ,p_segment5                  => p_analysis_criteria_rec.segment5
   ,p_segment6                  => p_analysis_criteria_rec.segment6
   ,p_segment7                  => p_analysis_criteria_rec.segment7
   ,p_segment8                  => p_analysis_criteria_rec.segment8
   ,p_segment9                  => p_analysis_criteria_rec.segment9
   ,p_segment10                 => p_analysis_criteria_rec.segment10
   ,p_segment11                 => p_analysis_criteria_rec.segment11
   ,p_segment12                 => p_analysis_criteria_rec.segment12
   ,p_segment13                 => p_analysis_criteria_rec.segment13
   ,p_segment14                 => p_analysis_criteria_rec.segment14
   ,p_segment15                 => p_analysis_criteria_rec.segment15
   ,p_segment16                 => p_analysis_criteria_rec.segment16
   ,p_segment17                 => p_analysis_criteria_rec.segment17
   ,p_segment18                 => p_analysis_criteria_rec.segment18
   ,p_segment19                 => p_analysis_criteria_rec.segment19
   ,p_segment20                 => p_analysis_criteria_rec.segment20
   ,p_segment21                 => p_analysis_criteria_rec.segment21
   ,p_segment22                 => p_analysis_criteria_rec.segment22
   ,p_segment23                 => p_analysis_criteria_rec.segment23
   ,p_segment24                 => p_analysis_criteria_rec.segment24
   ,p_segment25                 => p_analysis_criteria_rec.segment25
   ,p_segment26                 => p_analysis_criteria_rec.segment26
   ,p_segment27                 => p_analysis_criteria_rec.segment27
   ,p_segment28                 => p_analysis_criteria_rec.segment28
   ,p_segment29                 => p_analysis_criteria_rec.segment29
   ,p_segment30                 => p_analysis_criteria_rec.segment30
   --
   ,p_concat_segments           => Null
   ,p_analysis_criteria_id      => p_analysis_criteria_rec.analysis_criteria_id
   ,p_person_analysis_id        => p_analyses_rec.person_analysis_id
   ,p_pea_object_version_number => p_analyses_rec.object_version_number
   );
  ELSIF p_action = 'UPDATE' THEN

   Hr_SIT_Api.Update_SIT
   (p_validate                  => p_validate
   ,p_person_analysis_id        => p_analyses_rec.person_analysis_id
   ,p_pea_object_version_number => p_analyses_rec.object_version_number
   ,p_comments                  => NULL
   ,p_date_from                 => p_analyses_rec.date_from
   ,p_date_to                   => p_analyses_rec.date_to
   ,p_concat_segments           => Null
   --
   ,p_analysis_criteria_id      => p_analysis_criteria_rec.analysis_criteria_id
   --
   ,p_request_id                => p_analyses_rec.request_id
   ,p_program_application_id    => p_analyses_rec.program_application_id
   ,p_program_id                => p_analyses_rec.program_id
   ,p_program_update_date       => p_analyses_rec.program_update_date
   --
   ,p_attribute_category        => p_analyses_rec.attribute_category
   ,p_attribute1                => p_analyses_rec.attribute1
   ,p_attribute2                => p_analyses_rec.attribute2
   ,p_attribute3                => p_analyses_rec.attribute3
   ,p_attribute4                => p_analyses_rec.attribute4
   ,p_attribute5                => p_analyses_rec.attribute5
   ,p_attribute6                => p_analyses_rec.attribute6
   ,p_attribute7                => p_analyses_rec.attribute7
   ,p_attribute8                => p_analyses_rec.attribute8
   ,p_attribute9                => p_analyses_rec.attribute9
   ,p_attribute10               => p_analyses_rec.attribute10
   ,p_attribute11               => p_analyses_rec.attribute11
   ,p_attribute12               => p_analyses_rec.attribute12
   ,p_attribute13               => p_analyses_rec.attribute13
   ,p_attribute14               => p_analyses_rec.attribute14
   ,p_attribute15               => p_analyses_rec.attribute15
   ,p_attribute16               => p_analyses_rec.attribute16
   ,p_attribute17               => p_analyses_rec.attribute17
   ,p_attribute18               => p_analyses_rec.attribute18
   ,p_attribute19               => p_analyses_rec.attribute19
   ,p_attribute20               => p_analyses_rec.attribute20
   ,p_segment1                  => p_analysis_criteria_rec.segment1
   ,p_segment2                  => p_analysis_criteria_rec.segment2
   ,p_segment3                  => p_analysis_criteria_rec.segment3
   ,p_segment4                  => p_analysis_criteria_rec.segment4
   ,p_segment5                  => p_analysis_criteria_rec.segment5
   ,p_segment6                  => p_analysis_criteria_rec.segment6
   ,p_segment7                  => p_analysis_criteria_rec.segment7
   ,p_segment8                  => p_analysis_criteria_rec.segment8
   ,p_segment9                  => p_analysis_criteria_rec.segment9
   ,p_segment10                 => p_analysis_criteria_rec.segment10
   ,p_segment11                 => p_analysis_criteria_rec.segment11
   ,p_segment12                 => p_analysis_criteria_rec.segment12
   ,p_segment13                 => p_analysis_criteria_rec.segment13
   ,p_segment14                 => p_analysis_criteria_rec.segment14
   ,p_segment15                 => p_analysis_criteria_rec.segment15
   ,p_segment16                 => p_analysis_criteria_rec.segment16
   ,p_segment17                 => p_analysis_criteria_rec.segment17
   ,p_segment18                 => p_analysis_criteria_rec.segment18
   ,p_segment19                 => p_analysis_criteria_rec.segment19
   ,p_segment20                 => p_analysis_criteria_rec.segment20
   ,p_segment21                 => p_analysis_criteria_rec.segment21
   ,p_segment22                 => p_analysis_criteria_rec.segment22
   ,p_segment23                 => p_analysis_criteria_rec.segment23
   ,p_segment24                 => p_analysis_criteria_rec.segment24
   ,p_segment25                 => p_analysis_criteria_rec.segment25
   ,p_segment26                 => p_analysis_criteria_rec.segment26
   ,p_segment27                 => p_analysis_criteria_rec.segment27
   ,p_segment28                 => p_analysis_criteria_rec.segment28
   ,p_segment29                 => p_analysis_criteria_rec.segment29
   ,p_segment30                 => p_analysis_criteria_rec.segment30
   );
  ELSIF p_action ='DELETE' THEN
    Hr_SIT_Api.Delete_SIT
   (p_validate                  => p_validate
   ,p_person_analysis_id        => p_analyses_rec.person_analysis_id
   ,p_pea_object_version_number => p_analyses_rec.object_version_number
    );
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;

END InsUpd_SIT_info;
-- =============================================================================
-- ~ InsUpd_Asg_Extra_info: Insert, Update or Delete Assignment Extra Info.
-- =============================================================================
PROCEDURE InsUpd_Asg_Extra_info
          (p_assignment_id     IN Number
          ,p_business_group_id IN Number
          ,p_validate          IN Boolean DEFAULT FALSE
          ,p_action            IN Varchar2
          ,p_extra_info_rec    IN OUT NOCOPY per_assignment_extra_info%ROWTYPE
           ) IS
  l_proc_name  CONSTANT      Varchar2(150):= g_pkg ||'InsUpd_Asg_Extra_info';
  l_error_msg                Varchar2(2000);

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  IF p_action = 'CREATE' THEN
   Hr_Assignment_Extra_Info_Api.Create_Assignment_Extra_Info
   (p_validate                 => p_validate
   ,p_assignment_id            => p_assignment_id
   -- DDF segments
   ,p_information_type         => p_extra_info_rec.information_type
   ,p_aei_information_category => p_extra_info_rec.aei_information_category
   ,p_aei_information1         => p_extra_info_rec.aei_information1
   ,p_aei_information2         => p_extra_info_rec.aei_information2
   ,p_aei_information3         => p_extra_info_rec.aei_information3
   ,p_aei_information4         => p_extra_info_rec.aei_information4
   ,p_aei_information5         => p_extra_info_rec.aei_information5
   ,p_aei_information6         => p_extra_info_rec.aei_information6
   ,p_aei_information7         => p_extra_info_rec.aei_information7
   ,p_aei_information8         => p_extra_info_rec.aei_information8
   ,p_aei_information9         => p_extra_info_rec.aei_information9
   ,p_aei_information10        => p_extra_info_rec.aei_information10
   ,p_aei_information11        => p_extra_info_rec.aei_information11
   ,p_aei_information12        => p_extra_info_rec.aei_information12
   ,p_aei_information13        => p_extra_info_rec.aei_information13
   ,p_aei_information14        => p_extra_info_rec.aei_information14
   ,p_aei_information15        => p_extra_info_rec.aei_information15
   ,p_aei_information16        => p_extra_info_rec.aei_information16
   ,p_aei_information17        => p_extra_info_rec.aei_information17
   ,p_aei_information18        => p_extra_info_rec.aei_information18
   ,p_aei_information19        => p_extra_info_rec.aei_information19
   ,p_aei_information20        => p_extra_info_rec.aei_information20
   ,p_aei_information21        => p_extra_info_rec.aei_information21
   ,p_aei_information22        => p_extra_info_rec.aei_information22
   ,p_aei_information23        => p_extra_info_rec.aei_information23
   ,p_aei_information24        => p_extra_info_rec.aei_information24
   ,p_aei_information25        => p_extra_info_rec.aei_information25
   ,p_aei_information26        => p_extra_info_rec.aei_information26
   ,p_aei_information27        => p_extra_info_rec.aei_information27
   ,p_aei_information28        => p_extra_info_rec.aei_information28
   ,p_aei_information29        => p_extra_info_rec.aei_information29
   ,p_aei_information30        => p_extra_info_rec.aei_information30
    --
   ,p_aei_attribute_category   => p_extra_info_rec.aei_attribute_category
   ,p_aei_attribute1           => p_extra_info_rec.aei_attribute1
   ,p_aei_attribute2           => p_extra_info_rec.aei_attribute2
   ,p_aei_attribute3           => p_extra_info_rec.aei_attribute3
   ,p_aei_attribute4           => p_extra_info_rec.aei_attribute4
   ,p_aei_attribute5           => p_extra_info_rec.aei_attribute5
   ,p_aei_attribute6           => p_extra_info_rec.aei_attribute6
   ,p_aei_attribute7           => p_extra_info_rec.aei_attribute7
   ,p_aei_attribute8           => p_extra_info_rec.aei_attribute8
   ,p_aei_attribute9           => p_extra_info_rec.aei_attribute9
   ,p_aei_attribute10          => p_extra_info_rec.aei_attribute10
   ,p_aei_attribute11          => p_extra_info_rec.aei_attribute11
   ,p_aei_attribute12          => p_extra_info_rec.aei_attribute12
   ,p_aei_attribute13          => p_extra_info_rec.aei_attribute13
   ,p_aei_attribute14          => p_extra_info_rec.aei_attribute14
   ,p_aei_attribute15          => p_extra_info_rec.aei_attribute15
   ,p_aei_attribute16          => p_extra_info_rec.aei_attribute16
   ,p_aei_attribute17          => p_extra_info_rec.aei_attribute17
   ,p_aei_attribute18          => p_extra_info_rec.aei_attribute18
   ,p_aei_attribute19          => p_extra_info_rec.aei_attribute19
   ,p_aei_attribute20          => p_extra_info_rec.aei_attribute20
    --
   ,p_Assignment_extra_info_id => p_extra_info_rec.Assignment_extra_info_id
   ,p_object_version_number    => p_extra_info_rec.Object_Version_Number
    );
  ELSIF p_action = 'UPDATE' THEN

   Hr_Assignment_Extra_Info_Api.Update_Assignment_Extra_Info
   (p_validate                 => p_validate
   ,p_Assignment_extra_info_id => p_extra_info_rec.Assignment_extra_info_id
   ,p_object_version_number    => p_extra_info_rec.Object_Version_Number
    -- DDF Segments
   ,p_aei_information_category => p_extra_info_rec.aei_information_category
   ,p_aei_information1         => p_extra_info_rec.aei_information1
   ,p_aei_information2         => p_extra_info_rec.aei_information2
   ,p_aei_information3         => p_extra_info_rec.aei_information3
   ,p_aei_information4         => p_extra_info_rec.aei_information4
   ,p_aei_information5         => p_extra_info_rec.aei_information5
   ,p_aei_information6         => p_extra_info_rec.aei_information6
   ,p_aei_information7         => p_extra_info_rec.aei_information7
   ,p_aei_information8         => p_extra_info_rec.aei_information8
   ,p_aei_information9         => p_extra_info_rec.aei_information9
   ,p_aei_information10        => p_extra_info_rec.aei_information10
   ,p_aei_information11        => p_extra_info_rec.aei_information11
   ,p_aei_information12        => p_extra_info_rec.aei_information12
   ,p_aei_information13        => p_extra_info_rec.aei_information13
   ,p_aei_information14        => p_extra_info_rec.aei_information14
   ,p_aei_information15        => p_extra_info_rec.aei_information15
   ,p_aei_information16        => p_extra_info_rec.aei_information16
   ,p_aei_information17        => p_extra_info_rec.aei_information17
   ,p_aei_information18        => p_extra_info_rec.aei_information18
   ,p_aei_information19        => p_extra_info_rec.aei_information19
   ,p_aei_information20        => p_extra_info_rec.aei_information20
   ,p_aei_information21        => p_extra_info_rec.aei_information21
   ,p_aei_information22        => p_extra_info_rec.aei_information22
   ,p_aei_information23        => p_extra_info_rec.aei_information23
   ,p_aei_information24        => p_extra_info_rec.aei_information24
   ,p_aei_information25        => p_extra_info_rec.aei_information25
   ,p_aei_information26        => p_extra_info_rec.aei_information26
   ,p_aei_information27        => p_extra_info_rec.aei_information27
   ,p_aei_information28        => p_extra_info_rec.aei_information28
   ,p_aei_information29        => p_extra_info_rec.aei_information29
   ,p_aei_information30        => p_extra_info_rec.aei_information30
   -- DF segments
   ,p_aei_attribute_category   => p_extra_info_rec.aei_attribute_category
   ,p_aei_attribute1           => p_extra_info_rec.aei_attribute1
   ,p_aei_attribute2           => p_extra_info_rec.aei_attribute2
   ,p_aei_attribute3           => p_extra_info_rec.aei_attribute3
   ,p_aei_attribute4           => p_extra_info_rec.aei_attribute4
   ,p_aei_attribute5           => p_extra_info_rec.aei_attribute5
   ,p_aei_attribute6           => p_extra_info_rec.aei_attribute6
   ,p_aei_attribute7           => p_extra_info_rec.aei_attribute7
   ,p_aei_attribute8           => p_extra_info_rec.aei_attribute8
   ,p_aei_attribute9           => p_extra_info_rec.aei_attribute9
   ,p_aei_attribute10          => p_extra_info_rec.aei_attribute10
   ,p_aei_attribute11          => p_extra_info_rec.aei_attribute11
   ,p_aei_attribute12          => p_extra_info_rec.aei_attribute12
   ,p_aei_attribute13          => p_extra_info_rec.aei_attribute13
   ,p_aei_attribute14          => p_extra_info_rec.aei_attribute14
   ,p_aei_attribute15          => p_extra_info_rec.aei_attribute15
   ,p_aei_attribute16          => p_extra_info_rec.aei_attribute16
   ,p_aei_attribute17          => p_extra_info_rec.aei_attribute17
   ,p_aei_attribute18          => p_extra_info_rec.aei_attribute18
   ,p_aei_attribute19          => p_extra_info_rec.aei_attribute19
   ,p_aei_attribute20          => p_extra_info_rec.aei_attribute20
   );
  ELSIF p_action ='DELETE' THEN
   Hr_Assignment_Extra_Info_Api.Delete_Assignment_Extra_Info
   (p_validate                 => p_validate
   ,p_assignment_extra_info_id => p_extra_info_rec.Assignment_extra_info_id
   ,p_object_version_number    => p_extra_info_rec.object_version_number
   );
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
EXCEPTION
  WHEN Others THEN
   l_error_msg := Substrb(SQLERRM,1,2000);
   Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   Hr_Utility.raise_error;

END InsUpd_Asg_Extra_info;

-- =============================================================================
-- ~ InsUpd_OSS_PassPort:
-- =============================================================================
PROCEDURE InsUpd_OSS_PassPort
         (p_person_id        IN Number
         ,p_party_id         IN Number
         ,p_action           IN Varchar2
         ,p_pei_info_rec_old IN per_people_extra_info%ROWTYPE
         ,p_pei_info_rec_new IN per_people_extra_info%ROWTYPE
         ) AS

  TYPE csr_pp_t  IS REF CURSOR;
  csr_pp                csr_pp_t;
  SQLstmt               Varchar2(2000);
  PLSQL_Block           Varchar2(2000);
  l_oss_pp_rec_old      oss_pp_rec;
  l_oss_pp_rec          oss_pp_rec;
  l_Update_OSS_rec      Boolean;
  l_Insert_OSS_rec      Boolean;
  l_mode                Varchar2(5);

  l_return_status       Varchar2(10);
  l_msg_count           Number;
  l_msg_data            Varchar2(2000);
  l_passport_id         Number(15);
  e_passport_err        EXCEPTION;
  l_cntry_mapping       csr_cntry_code%ROWTYPE;
  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_OSS_PassPort';
  l_error_msg           Varchar2(2000);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  l_Update_OSS_Rec := FALSE; l_Insert_OSS_Rec := FALSE;

  SQLstmt := ' SELECT pap.rowid                '||
             '       ,pap.passport_id          '||
             '       ,pap.passport_cntry_code  '||
             '       ,pap.passport_number      '||
             '       ,pap.passport_expiry_date '||
             '       ,pap.attribute_category   '||
             '       ,pap.attribute1  '||
             '       ,pap.attribute2  '||
             '       ,pap.attribute3  '||
             '       ,pap.attribute4  '||
             '       ,pap.attribute5  '||
             '       ,pap.attribute6  '||
             '       ,pap.attribute7  '||
             '       ,pap.attribute8  '||
             '       ,pap.attribute9  '||
             '       ,pap.attribute10 '||
             '       ,pap.attribute11 '||
             '       ,pap.attribute12 '||
             '       ,pap.attribute13 '||
             '       ,pap.attribute14 '||
             '       ,pap.attribute15 '||
             '       ,pap.attribute16 '||
             '       ,pap.attribute17 '||
             '       ,pap.attribute18 '||
             '       ,pap.attribute19 '||
             '       ,pap.attribute20 '||
             '   FROM igs_pe_passport  pap '||
             '  WHERE pap.person_id       = :c_party_id '||
             '    AND pap.passport_number = :c_passport_number ';

  IF p_action = 'UPDATE' THEN

    IF (p_pei_info_rec_new.pei_information5 =
        p_pei_info_rec_old.pei_information5  AND
        p_pei_info_rec_new.pei_information6 =
        p_pei_info_rec_old.pei_information6  AND
        Fnd_Date.Canonical_To_Date
         (p_pei_info_rec_new.pei_information8) =
        Fnd_Date.Canonical_To_Date
         (p_pei_info_rec_old.pei_information8))
       THEN
       RETURN;
    END IF;

    IF ( p_pei_info_rec_old.pei_information8 is Null or
         p_pei_info_rec_new.pei_information8 is Null) THEN
        l_msg_data := 'Passport Expiry Date is required for a Student.';
        RAISE e_passport_err;
    END IF;

  ELSIF p_action ='INSERT' THEN

    IF (p_pei_info_rec_new.pei_information8 is Null) THEN
        l_msg_data := 'Passport Expiry Date is required for a Student.';
        RAISE e_passport_err;
    END IF;
  END IF;

  -- ===========================================================================
  -- Country (VS)-R    = pei_information5 = igs_pe_passport.passport_cntry_code
  -- Passport Number-R = pei_information6 = igs_pe_passport.passport_number
  -- Issue Date        = pei_information7 = default to null
  -- Expiry Date       = pei_information8 = igs_pe_passport.passport_expiry_date
  -- ===========================================================================
  IF p_action = 'INSERT' THEN
     l_oss_pp_rec.passport_cntry_code := p_pei_info_rec_new.pei_information5;
     l_oss_pp_rec.passport_number     := p_pei_info_rec_new.pei_information6;
     l_oss_pp_rec.passport_expiry_date:= Fnd_Date.Canonical_To_Date
                                         (p_pei_info_rec_new.pei_information8);
     l_Insert_OSS_Rec := TRUE;
     -- If expiry date is null then raise a warning that Passport was not
     -- created in OSS for the student employee as its a required field in OSS

  ELSIF p_action = 'UPDATE' THEN
    Hr_Utility.set_location('..p_action :'||p_action, 10);
    Hr_Utility.set_location('..Old PP No:'||p_pei_info_rec_old.pei_information6, 10);
    Hr_Utility.set_location('..New PP No:'||p_pei_info_rec_new.pei_information6, 10);
    IF (Trim(p_pei_info_rec_old.pei_information6) =
        Trim(p_pei_info_rec_new.pei_information6)) THEN
        OPEN csr_pp FOR SQLstmt
                  Using p_party_id
                       ,p_pei_info_rec_new.pei_information6;
        FETCH csr_pp INTO l_oss_pp_rec_old;
        Hr_Utility.set_location('..After Dynamic SQL cursor ', 11);
        IF csr_pp%FOUND AND
           (p_pei_info_rec_new.pei_information8 <>
            p_pei_info_rec_old.pei_information8)  OR
           (p_pei_info_rec_new.pei_information5 <>
            p_pei_info_rec_old.pei_information5)
            THEN
            l_update_OSS_rec := TRUE;
            l_oss_pp_rec     := l_oss_pp_rec_old;
        ELSE
            l_Insert_OSS_Rec := TRUE;
        END IF;
        CLOSE csr_pp;
    ELSIF (Trim(p_pei_info_rec_old.pei_information6) <>
           Trim(p_pei_info_rec_new.pei_information6)) THEN

        OPEN csr_pp FOR SQLstmt
                  Using p_party_id
                       ,p_pei_info_rec_new.pei_information6;
        FETCH csr_pp INTO l_oss_pp_rec_old;
        Hr_Utility.set_location('..After Dynamic SQL cursor ', 11);
        IF csr_pp%NOTFOUND THEN
           l_Insert_OSS_Rec := TRUE;
        ELSIF (p_pei_info_rec_new.pei_information8 <>
               p_pei_info_rec_old.pei_information8)
               OR
              (p_pei_info_rec_new.pei_information5 <>
               p_pei_info_rec_old.pei_information5)
               THEN
               l_update_OSS_rec := TRUE;
               l_oss_pp_rec     := l_oss_pp_rec_old;
        END IF;
        CLOSE csr_pp;
    END IF;

    l_oss_pp_rec.passport_cntry_code := p_pei_info_rec_new.pei_information5;
    l_oss_pp_rec.passport_number     := p_pei_info_rec_new.pei_information6;
    l_oss_pp_rec.passport_expiry_date:= Fnd_Date.Canonical_To_Date
                                        (p_pei_info_rec_new.pei_information8);

    -- If expiry date is null then raise a warning that Passport was not
    -- created in OSS for the student employee
  END IF;
  l_mode := 'R';
  OPEN csr_cntry_code
        (c_country_code => l_oss_pp_rec.passport_cntry_code
        ,c_map_to       => 'HR_TO_OSS');
  FETCH csr_cntry_code INTO l_cntry_mapping;
  CLOSE csr_cntry_code;
  l_oss_pp_rec.passport_cntry_code := NVL(l_cntry_mapping.irs_code
                                         ,l_oss_pp_rec.passport_cntry_code);

  -- Insert Into OSS
  IF l_Insert_OSS_Rec THEN
     Hr_Utility.set_location('Calling Dynamic PL/SQL Block: IGS_PE_Visapass_Pub.Create_Passport', 20);
     Hr_Utility.set_location('..passport_number: '||l_oss_pp_rec.passport_number, 20);
     Hr_Utility.set_location('..passport_expiry_date: '||l_oss_pp_rec.passport_expiry_date, 20);
     Hr_Utility.set_location('..passport_cntry_code: '||l_oss_pp_rec.passport_cntry_code, 20);
     Hr_Utility.set_location('..l_cntry_mapping.irs_code: '||l_cntry_mapping.irs_code, 20);

     PLSQL_Block :=
     'DECLARE
        l_passport_rec Igs_Pe_Visapass_Pub.Passport_Rec_TYPE;
      BEGIN
        l_passport_rec.passport_number      := :1;
        l_passport_rec.passport_cntry_code  := :2;
        l_passport_rec.passport_expiry_date := :3;
        l_passport_rec.person_id            := :4;

        Igs_Pe_Visapass_Pub.Create_Passport
        (p_api_version      => 1.0
        ,p_init_msg_list    => Fnd_Api.G_TRUE
        ,p_passport_rec     => l_passport_rec
        ,x_return_status    => :5
        ,x_msg_count        => :6
        ,x_msg_data         => :7
        ,x_passport_id      => :8
        );
      END;';
      EXECUTE IMMEDIATE PLSQL_Block
      Using l_oss_pp_rec.passport_number
           ,l_oss_pp_rec.passport_cntry_code
           ,l_oss_pp_rec.passport_expiry_date
           ,p_party_id
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data
           ,OUT l_passport_id;

  END IF;

  -- Update the existing OSS record
  IF l_update_OSS_rec THEN
     Hr_Utility.set_location('Calling Dynamic PL/SQL Block: Igs_Pe_Passport_Pkg.Update_Row', 21);
     Hr_Utility.set_location('..passport_number: '||l_oss_pp_rec.passport_number, 21);
     Hr_Utility.set_location('..passport_expiry_date: '||l_oss_pp_rec.passport_expiry_date, 21);
     Hr_Utility.set_location('..passport_cntry_code: '||l_oss_pp_rec.passport_cntry_code, 21);
     Hr_Utility.set_location('..passport_id: '||l_oss_pp_rec.passport_id, 21);
     Hr_Utility.set_location('..rowid: '||l_oss_pp_rec.pp_rowid, 21);

     PLSQL_Block :=
     'DECLARE
        l_passport_rec Igs_Pe_Visapass_Pub.Passport_Rec_TYPE;
      BEGIN
        l_passport_rec.passport_number      := :1;
        l_passport_rec.passport_cntry_code  := :2;
        l_passport_rec.passport_expiry_date := :3;
        l_passport_rec.person_id            := :4;
        l_passport_rec.passport_id          := :5;

        Igs_Pe_Visapass_Pub.Update_Passport
        (p_api_version      => 1.0
        ,p_init_msg_list    => Fnd_Api.G_TRUE
        ,p_passport_rec     => l_passport_rec
        ,x_return_status    => :6
        ,x_msg_count        => :7
        ,x_msg_data         => :8
        );
      END;';
      EXECUTE IMMEDIATE PLSQL_Block
      Using l_oss_pp_rec.passport_number
           ,l_oss_pp_rec.passport_cntry_code
           ,l_oss_pp_rec.passport_expiry_date
           ,p_party_id
           ,l_oss_pp_rec.passport_id
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data;

  END IF;
  Hr_Utility.set_location(' l_return_status: '||l_return_status, 45);
  Hr_Utility.set_location(' l_msg_data: '||l_msg_data, 45);
  IF l_return_status IN ('E','U') THEN
     RAISE e_passport_err;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
EXCEPTION
  WHEN e_passport_err THEN
    l_error_msg := Substrb(l_msg_data,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
END InsUpd_OSS_PassPort;
-- =============================================================================
-- ~ InsUpd_OSS_Visa:
-- =============================================================================
PROCEDURE InsUpd_OSS_Visa
         (p_person_id        IN Number
         ,p_party_id         IN Number
         ,p_action           IN Varchar2
         ,p_pei_info_rec_old IN per_people_extra_info%ROWTYPE
         ,p_pei_info_rec_new IN per_people_extra_info%ROWTYPE
          ) AS

    TYPE csr_visa_t  IS REF CURSOR;
    csr_visa              csr_visa_t;

    l_oss_visa_rec_old    oss_visa_rec;
    l_oss_visa_rec        oss_visa_rec;

    SQLstmt               Varchar2(2000);
    PLSQL_Block           Varchar2(2000);
    l_Update_OSS_rec      Boolean;
    l_Insert_OSS_rec      Boolean;
    l_return_status       Varchar2(10);
    l_msg_count           Number;
    l_msg_data            Varchar2(2000);
    l_error_msg           Varchar2(2000);
    l_visa_id             Number(15);
    e_visa_syn_err        EXCEPTION;
    l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_OSS_Visa';
    l_dft_date            Varchar2(150);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  l_dft_date := Fnd_Date.Date_To_Canonical(sysdate);
  Hr_Utility.set_location('..p_party_id: '||p_party_id, 5);
  l_Update_OSS_Rec := FALSE; l_Insert_OSS_Rec := FALSE;

  SQLstmt:='SELECT                     '||
           '     rowid                 '||
           '     ,visa_id              '||
           '     ,visa_type            '||
           '     ,visa_number          '||
           '     ,visa_issue_date      '||
           '     ,visa_expiry_date     '||
           '     ,visa_category        '||
           '     ,visa_issuing_post    '||
           '     ,passport_id          '||
           '     ,agent_org_unit_cd    '||
           '     ,agent_person_id      '||
           '     ,agent_contact_name   '||
           '     ,visa_issuing_country '||
           '     ,attribute_category   '||
           '     ,attribute1  '||
           '     ,attribute2  '||
           '     ,attribute3  '||
           '     ,attribute4  '||
           '     ,attribute5  '||
           '     ,attribute6  '||
           '     ,attribute7  '||
           '     ,attribute8  '||
           '     ,attribute9  '||
           '     ,attribute10 '||
           '     ,attribute11 '||
           '     ,attribute12 '||
           '     ,attribute13 '||
           '     ,attribute14 '||
           '     ,attribute15 '||
           '     ,attribute16 '||
           '     ,attribute17 '||
           '     ,attribute18 '||
           '     ,attribute19 '||
           '     ,attribute20 '||
           ' FROM igs_pe_visa '||
           'WHERE person_id   = :c_party_id  '||
           '  AND visa_number = :c_visa_number ';
  IF p_action = 'UPDATE' THEN
  IF (p_pei_info_rec_new.pei_information5 =
      p_pei_info_rec_old.pei_information5  AND
      p_pei_info_rec_new.pei_information6 =
      p_pei_info_rec_old.pei_information6  AND
      Fnd_Date.Canonical_To_Date
      (p_pei_info_rec_new.pei_information7) =
      Fnd_Date.Canonical_To_Date
      (p_pei_info_rec_old.pei_information7)  AND
      Fnd_Date.Canonical_To_Date
      (nvl(p_pei_info_rec_new.pei_information8,l_dft_date)) =
      Fnd_Date.Canonical_To_Date
      (nvl(p_pei_info_rec_old.pei_information8,l_dft_date))
      )
     THEN
     RETURN;
  END IF;
  IF (p_pei_info_rec_new.pei_information5 <>
      p_pei_info_rec_old.pei_information5) or
     (p_pei_info_rec_new.pei_information6 <>
      p_pei_info_rec_old.pei_information6)or
     (Fnd_Date.Canonical_To_Date
       (nvl(p_pei_info_rec_new.pei_information7,l_dft_date)) <>
      Fnd_Date.Canonical_To_Date
       (nvl(p_pei_info_rec_old.pei_information7,l_dft_date))
      )
      THEN
      l_msg_data := 'For a student you cannot update the unique combination of '||
                    'Visa Number, Visa Type and Issue Date';
      RAISE e_visa_syn_err;
  END IF;
  END IF;
  -- ===========================================================================
  -- Visa Type(VS)-R   = pei_information5  = igs_pe_visa.visa_type
  -- Visa Number-R     = pei_information6  = igs_pe_visa.visa_number
  -- Issue Date -R     = pei_information7  = igs_pe_visa.visa_issue_date
  -- Expiry Date -R    = pei_information8  = igs_pe_visa.visa_expiry_date
  -- J Visa Category   = pei_information9  = default to 99
  -- Pass To Interface = pei_information10 = N
  -- ===========================================================================
  Hr_Utility.set_location('..Visa Number: '||p_pei_info_rec_new.pei_information6, 6);
  IF p_action = 'INSERT' THEN
     l_oss_visa_rec.visa_type       := p_pei_info_rec_new.pei_information5;
     l_oss_visa_rec.visa_number     := p_pei_info_rec_new.pei_information6;
     l_oss_visa_rec.visa_issue_date := Fnd_Date.Canonical_To_Date
                                        (p_pei_info_rec_new.pei_information7);
     l_oss_visa_rec.visa_expiry_date:= Fnd_Date.Canonical_To_Date
                                        (p_pei_info_rec_new.pei_information8);
     l_Insert_OSS_Rec := TRUE;
     -- If expiry date is null then raise a warning that Passport was not
     -- created in OSS for the student employee
  ELSIF p_action = 'UPDATE' THEN

     IF (Trim(p_pei_info_rec_old.pei_information6) =
         Trim(p_pei_info_rec_new.pei_information6)) THEN
        OPEN csr_Visa FOR SQLstmt
                    Using p_party_id
                         ,p_pei_info_rec_old.pei_information6;
        FETCH csr_Visa INTO l_oss_visa_rec_old;
        Hr_Utility.set_location('..After Dynamic SQL cursor ', 11);
        IF csr_Visa%FOUND THEN
          IF (p_pei_info_rec_old.pei_information5 =
              p_pei_info_rec_new.pei_information5) AND
             (Fnd_Date.Canonical_To_Date
              (nvl(p_pei_info_rec_new.pei_information8,l_dft_date)) <>
              Fnd_Date.Canonical_To_Date
              (nvl(p_pei_info_rec_old.pei_information8,l_dft_date))
              )
          THEN
            Hr_Utility.set_location('..Visa Number found. ', 12);
            -- The Visa being updated exists in OSS
            l_update_OSS_rec := TRUE;
            l_oss_visa_rec   := l_oss_visa_rec_old;
          END IF;
        ELSE
            Hr_Utility.set_location('..Visa Number NOT found. ', 12);
         -- That means the visa that is being updated in HR is not there
         -- in OSS, so create it.
            l_update_OSS_rec := FALSE;
            l_insert_OSS_rec := TRUE;
        END IF;
        CLOSE csr_Visa;

     ELSIF (Trim(p_pei_info_rec_old.pei_information6) <>
            Trim(p_pei_info_rec_new.pei_information6)) THEN

        OPEN csr_Visa FOR SQLstmt
                    Using p_party_id
                         ,p_pei_info_rec_new.pei_information6;
        FETCH csr_Visa INTO l_oss_visa_rec_old;
        Hr_Utility.set_location('..After Dynamic SQL cursor ', 13);
        IF csr_Visa%NOTFOUND THEN
           Hr_Utility.set_location('..Visa Number NOT found. ', 14);
           l_Insert_OSS_Rec := TRUE;
        ELSIF (p_pei_info_rec_new.pei_information5 =
               p_pei_info_rec_old.pei_information5)  OR
              (Fnd_Date.Canonical_To_Date
               (nvl(p_pei_info_rec_new.pei_information8,l_dft_date)) <>
               Fnd_Date.Canonical_To_Date
               (nvl(p_pei_info_rec_old.pei_information8,l_dft_date))
               ) THEN
           Hr_Utility.set_location('..Visa Number found. ', 15);
           l_Update_OSS_Rec := TRUE;
           l_oss_visa_rec   := l_oss_visa_rec_old;
        END IF;
        CLOSE csr_Visa;
     END IF;

     l_oss_visa_rec.visa_type       := p_pei_info_rec_new.pei_information5;
     l_oss_visa_rec.visa_number     := p_pei_info_rec_new.pei_information6;
     l_oss_visa_rec.visa_issue_date := Fnd_Date.Canonical_To_Date
                                          (p_pei_info_rec_new.pei_information7);
     l_oss_visa_rec.visa_expiry_date:= Fnd_Date.Canonical_To_Date
                                          (p_pei_info_rec_new.pei_information8);

  END IF;

  -- Insert Into OSS
  Hr_Utility.set_location('..p_action: '||p_action, 19);
  IF l_insert_OSS_rec THEN
     Hr_Utility.set_location('..visa_type: '||l_oss_visa_rec.visa_type, 20);
     Hr_Utility.set_location('..visa_number: '||l_oss_visa_rec.visa_number,20);
     Hr_Utility.set_location('..visa_issue_date: '||l_oss_visa_rec.visa_issue_date, 20);
     Hr_Utility.set_location('..visa_expiry_date: '||l_oss_visa_rec.visa_expiry_date, 20);

     PLSQL_Block :=
     'DECLARE
        l_visa_rec Igs_Pe_Visapass_Pub.Visa_Rec_TYPE;
      BEGIN
        l_visa_rec.visa_type         := :1;
        l_visa_rec.visa_number       := :2;
        l_visa_rec.visa_issue_date   := :3;
        l_visa_rec.visa_expiry_date  := :4;
        l_visa_rec.person_id         := :5;

        Igs_Pe_Visapass_Pub.Create_Visa
        (p_api_version      => 1.0
        ,p_init_msg_list    => Fnd_Api.G_TRUE
        ,p_visa_rec         => l_visa_rec
        ,x_return_status    => :6
        ,x_msg_count        => :7
        ,x_msg_data         => :8
        ,x_visa_id          => :9
        );
      END;';
      EXECUTE IMMEDIATE PLSQL_Block
      Using l_oss_visa_rec.visa_type
           ,l_oss_visa_rec.visa_number
           ,l_oss_visa_rec.visa_issue_date
           ,l_oss_visa_rec.visa_expiry_date
           ,p_party_id
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data
           ,OUT l_visa_id;

  END IF;
  -- Update Into OSS
  IF l_update_OSS_rec THEN
     Hr_Utility.set_location('..visa_type: '||l_oss_visa_rec.visa_type, 21);
     Hr_Utility.set_location('..visa_number: '||l_oss_visa_rec.visa_number,21);
     Hr_Utility.set_location('..visa_issue_date: '||l_oss_visa_rec.visa_issue_date, 21);
     Hr_Utility.set_location('..visa_expiry_date: '||l_oss_visa_rec.visa_expiry_date, 21);

     PLSQL_Block :=
     'DECLARE
        l_visa_rec Igs_Pe_Visapass_Pub.Visa_Rec_TYPE;
      BEGIN
        l_visa_rec.visa_type         := :1;
        l_visa_rec.visa_number       := :2;
        l_visa_rec.visa_issue_date   := :3;
        l_visa_rec.visa_expiry_date  := :4;
        l_visa_rec.person_id         := :5;
        l_visa_rec.visa_id           := :6;

        Igs_Pe_Visapass_Pub.Update_Visa
        (p_api_version      => 1.0
        ,p_init_msg_list    => Fnd_Api.G_TRUE
        ,p_visa_rec         => l_visa_rec
        ,x_return_status    => :7
        ,x_msg_count        => :8
        ,x_msg_data         => :9
        );
      END;';
      EXECUTE IMMEDIATE PLSQL_Block
      Using l_oss_visa_rec.visa_type
           ,l_oss_visa_rec.visa_number
           ,l_oss_visa_rec.visa_issue_date
           ,l_oss_visa_rec.visa_expiry_date
           ,p_party_id
           ,l_oss_visa_rec.visa_id
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data;

  END IF;
  Hr_Utility.set_location(' l_return_status: '||l_return_status, 45);
  Hr_Utility.set_location(' l_msg_data: '||l_msg_data, 45);
  IF l_return_status IN ('E','U') THEN
     RAISE e_visa_syn_err;
  END IF;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
EXCEPTION
  WHEN e_visa_syn_err THEN
    l_error_msg := Substrb(l_msg_data,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
END InsUpd_OSS_Visa;

-- =============================================================================
-- ~ InsUpd_OSS_VistHistory:
-- =============================================================================
PROCEDURE InsUpd_OSS_VisitHistory
         (p_person_id        IN Number
         ,p_party_id         IN Number
         ,p_action           IN Varchar2
         ,p_pei_info_rec_old IN per_people_extra_info%ROWTYPE
         ,p_pei_info_rec_new IN per_people_extra_info%ROWTYPE
         ) AS

  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_OSS_VistHistory';
  l_oss_vvhist_rec_old  Visit_Hist_Rec;
  l_oss_vvhist_rec_new  Visit_Hist_Rec;
  --
  TYPE csr_oss_t  IS REF CURSOR;
  csr_visit             csr_oss_t;
  csr_visa              csr_oss_t;
  PLSQL_Block           Varchar2(2000);
  SQLstmt               Varchar2(2000);
  --
  l_oss_vvhist_cur_rec  Visit_Hist_Rec;
  l_visa_rec            oss_visa_rec;
  l_remarks             Varchar2(2000);
  l_visa_no             Varchar2(150);
  l_old_visa_id         Number(15);
  l_new_visa_id         Number(15);
  --
  l_return_status       Varchar2(10);
  l_msg_count           Number;
  l_msg_data            Varchar2(2000);
  l_error_msg           Varchar2(2000);
  e_visit_hstry_err     EXCEPTION;
  --
  l_Update_OSS_rec      Boolean;
  l_Insert_OSS_rec      Boolean;
  l_dft_date            Varchar2(150);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  l_dft_date := Fnd_Date.Date_To_Canonical(sysdate);
  l_Update_OSS_Rec := FALSE; l_Insert_OSS_Rec := FALSE;
  SQLstmt := ' SELECT row_id
                     ,port_of_entry
                     ,port_of_entry_m
                     ,cntry_entry_form_num
                     ,visa_id
                     ,visa_type
                     ,visa_number
                     ,visa_issue_date
                     ,visa_expiry_date
                     ,visa_category
                     ,visa_issuing_post
                     ,passport_id
                     ,visit_start_date
                     ,visit_end_date
                FROM igs_pe_visit_histry_v
               WHERE person_id   = :c_party_id
                 AND visa_number = :c_visa_number';

  IF p_action = 'UPDATE' THEN
    IF (nvl(p_pei_info_rec_new.pei_information11,'$$') =
        nvl(p_pei_info_rec_old.pei_information11,'$$') AND

        Fnd_Date.Canonical_To_Date
        (p_pei_info_rec_new.pei_information7) =
        Fnd_Date.Canonical_To_Date
        (p_pei_info_rec_old.pei_information7)          AND

        Fnd_Date.Canonical_To_Date
        (nvl(p_pei_info_rec_new.pei_information8,l_dft_date)) =
        Fnd_Date.Canonical_To_Date
        (nvl(p_pei_info_rec_old.pei_information8,l_dft_date))  AND

        nvl(p_pei_info_rec_new.pei_information12,'$$') =
        nvl(p_pei_info_rec_old.pei_information12,'$$') AND
        nvl(p_pei_info_rec_new.pei_information13,'$$') =
        nvl(p_pei_info_rec_old.pei_information13,'$$')
        )
       THEN
       RETURN;
    END IF;
    IF(nvl(p_pei_info_rec_new.pei_information12,'$$') <>
       nvl(p_pei_info_rec_old.pei_information12,'$$'))  or
      (nvl(p_pei_info_rec_new.pei_information13,'$$') <>
       nvl(p_pei_info_rec_old.pei_information13,'$$')) THEN
       l_msg_data := 'Port Of Entry and Entry Number cannot be changed for a student.';
       RAISE e_visit_hstry_err;
    END IF;
  ELSIF p_action = 'INSERT' THEN

    IF(p_pei_info_rec_new.pei_information12 Is Null or
       p_pei_info_rec_new.pei_information13 Is Null) THEN
       l_msg_data := 'Port Of Entry and Entry Number are required for student.';
       RAISE e_visit_hstry_err;
    END IF;
  END IF;
  -- =================================================================================
  -- Purpose (VS)-R            = pei_information5  = This is Specific to HRMS
  -- Visa Number               = pei_information11 = igs_pe_visit_histry_v.visa_number
  -- Start Date -R             = pei_information7  = igs_pe_visit_histry.visit_start_date
  -- End Date                  = pei_information8  = igs_pe_visit_histry.visit_end_date
  -- Spouse Accompanied (VS)-R = pei_information9  = This is Specific to HRMS
  -- Child Accompanied  (VS)-R = pei_information10 = This is Specific to HRMS
  -- Entry Number              = pei_information12 = igs_pe_visit_histry.cntry_entry_form_num
  -- Port Of Entry (VS)        = pei_information13 = igs_pe_visit_histry.port_of_entry
  -- ================================================================================
  IF p_action = 'INSERT' THEN
     Hr_Utility.set_location(' p_action: '||p_action, 10);
     l_oss_vvhist_rec_new.visit_start_date
       := Fnd_Date.Canonical_To_Date(p_pei_info_rec_new.pei_information7);
     l_oss_vvhist_rec_new.visit_end_date
       := Fnd_Date.Canonical_To_Date(p_pei_info_rec_new.pei_information8);
     l_oss_vvhist_rec_new.cntry_entry_form_num
       := p_pei_info_rec_new.pei_information12;
     l_oss_vvhist_rec_new.port_of_entry
       := p_pei_info_rec_new.pei_information13;

     l_Insert_OSS_Rec := TRUE;
     l_visa_no := p_pei_info_rec_new.pei_information11;

  ELSIF p_action = 'UPDATE' THEN
     Hr_Utility.set_location(' p_action: '||p_action, 10);
     Hr_Utility.set_location(' Old Visa Number: '||p_pei_info_rec_old.pei_information11, 10);
     Hr_Utility.set_location(' New Visa Number: '||p_pei_info_rec_new.pei_information11, 10);
     IF (Trim(p_pei_info_rec_old.pei_information11) =
         Trim(p_pei_info_rec_new.pei_information11)) THEN
        Hr_Utility.set_location(' Visa Number: '||p_pei_info_rec_new.pei_information11, 11);
        OPEN csr_visit FOR SQLstmt
                     Using p_party_id
                          ,p_pei_info_rec_new.pei_information11;
        FETCH csr_visit INTO l_oss_vvhist_rec_old ;
        IF csr_visit%FOUND THEN
          Hr_Utility.set_location(' Visit History record found in OSS ', 11);
          Hr_Utility.set_location(' Old End Date: '||p_pei_info_rec_old.pei_information8, 11);
          Hr_Utility.set_location(' New End Date: '||p_pei_info_rec_new.pei_information8, 11);
          IF Fnd_Date.Canonical_To_Date
             (NVL(p_pei_info_rec_old.pei_information8,l_dft_date)) <>
             Fnd_Date.Canonical_To_Date
             (NVL(p_pei_info_rec_new.pei_information8,l_dft_date))
             THEN
            Hr_Utility.set_location(' New End Date <> Old End Date  ', 11);
            -- The Visa Visit History being updated exists in OSS
            l_update_OSS_rec := TRUE;
            l_oss_vvhist_rec_new := l_oss_vvhist_rec_old;
          END IF;
        ELSE
        Hr_Utility.set_location(' Visit History record NOT found in OSS ', 11);
        -- That means the visa visit history that is being updated in
        -- HR is not there in OSS, so create it.
            l_update_OSS_rec := FALSE;
            l_insert_OSS_rec := TRUE;
            l_visa_no := p_pei_info_rec_new.pei_information11;
        END IF;
        CLOSE csr_visit;

     ELSIF (Trim(p_pei_info_rec_old.pei_information11) <>
            Trim(p_pei_info_rec_new.pei_information11)) THEN
        Hr_Utility.set_location(' Old Visa Number : '||p_pei_info_rec_old.pei_information11, 11);
        Hr_Utility.set_location(' New Visa Number : '||p_pei_info_rec_new.pei_information11, 11);
        OPEN csr_visit FOR SQLstmt
                    Using p_party_id
                         ,p_pei_info_rec_new.pei_information11;
        FETCH csr_visit INTO l_oss_vvhist_rec_old ;
        IF csr_visit%NOTFOUND THEN
           l_Insert_OSS_Rec := TRUE;
          IF Fnd_Date.Canonical_To_Date
             (NVL(p_pei_info_rec_old.pei_information8,l_dft_date)) <>
             Fnd_Date.Canonical_To_Date
             (NVL(p_pei_info_rec_new.pei_information8,l_dft_date))
             THEN
           l_Update_OSS_Rec := TRUE;
           l_oss_vvhist_rec_new := l_oss_vvhist_rec_old;
          END IF;
        END IF;
        CLOSE csr_visit;
     END IF;
     l_oss_vvhist_rec_new.visit_start_date    := Fnd_Date.Canonical_To_Date
                                                 (p_pei_info_rec_new.pei_information7);
     l_oss_vvhist_rec_new.visit_end_date      := Fnd_Date.Canonical_To_Date
                                                 (p_pei_info_rec_new.pei_information8);
     l_oss_vvhist_rec_new.cntry_entry_form_num:= p_pei_info_rec_new.pei_information12;
     l_oss_vvhist_rec_new.port_of_entry       := p_pei_info_rec_new.pei_information13;

  END IF;
  -- Insert Into OSS
  Hr_Utility.set_location(' Get the visa_id for : '||p_pei_info_rec_old.pei_information11, 12);
  SQLstmt:='SELECT visa_id
              FROM igs_pe_visa
             WHERE person_id   = :c_party_id
               AND visa_number = :c_visa_number';

   OPEN csr_visa FOR SQLstmt Using p_party_id
                                  ,p_pei_info_rec_old.pei_information11;
  FETCH csr_visa INTO l_old_visa_id;
  CLOSE csr_visa;
  Hr_Utility.set_location(' Old Visa Id: '||l_old_visa_id, 13);

   OPEN csr_visa FOR SQLstmt Using p_party_id
                                  ,p_pei_info_rec_new.pei_information11;
  FETCH csr_visa INTO l_new_visa_id;
  CLOSE csr_visa;
  Hr_Utility.set_location(' New Visa Id: '||l_new_visa_id, 13);

  Hr_Utility.set_location(' port_of_entry: '||l_oss_vvhist_rec_new.port_of_entry, 15);
  Hr_Utility.set_location(' cntry_entry_form_num: '||l_oss_vvhist_rec_new.cntry_entry_form_num, 15);
  Hr_Utility.set_location(' visit_start_date: '||l_oss_vvhist_rec_new.visit_start_date, 15);
  Hr_Utility.set_location(' visit_end_date: '||l_oss_vvhist_rec_new.visit_end_date, 15);

  IF l_insert_OSS_rec THEN
     l_oss_vvhist_rec_new.visa_id := l_new_visa_id;
     Hr_Utility.set_location(' visa_id: '||l_new_visa_id, 21);
     Hr_Utility.set_location(' Calling: IGS_PE_VisaPass_Pub.Create_VisitHistry', 21);
     PLSQL_Block :=
     'DECLARE
        l_visit_hstry_rec Igs_Pe_Visapass_Pub.Visit_Hstry_Rec_TYPE;
      BEGIN
        l_visit_hstry_rec.port_of_entry        := :1;
        l_visit_hstry_rec.cntry_entry_form_num := :2;
        l_visit_hstry_rec.visa_id              := :3;
        l_visit_hstry_rec.visit_start_date     := :4;
        l_visit_hstry_rec.visit_end_date       := :5;
        l_visit_hstry_rec.remarks              := NULL;

        Igs_Pe_Visapass_Pub.Create_VisitHistry
        (p_api_version      => 1.0
        ,p_init_msg_list    => Fnd_Api.G_TRUE
        ,p_visit_hstry_rec  => l_visit_hstry_rec
        ,x_return_status    => :6
        ,x_msg_count        => :7
        ,x_msg_data         => :8
        );
      END;';

      EXECUTE IMMEDIATE PLSQL_Block
      Using l_oss_vvhist_rec_new.port_of_entry
           ,l_oss_vvhist_rec_new.cntry_entry_form_num
           ,l_oss_vvhist_rec_new.visa_id
           ,l_oss_vvhist_rec_new.visit_start_date
           ,l_oss_vvhist_rec_new.visit_end_date
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data;
  END IF;
  -- Update Into OSS
  IF l_update_OSS_rec THEN
     l_oss_vvhist_rec_new.visa_id := l_new_visa_id;
     Hr_Utility.set_location(' visa_id: '||l_new_visa_id, 21);
     Hr_Utility.set_location(' Calling: IGS_PE_VisaPass_Pub.Update_VisitHistry', 21);

     PLSQL_Block :=
     'DECLARE
        l_visit_hstry_rec Igs_Pe_Visapass_Pub.Visit_Hstry_Rec_TYPE;
      BEGIN
        l_visit_hstry_rec.port_of_entry        := :1;
        l_visit_hstry_rec.cntry_entry_form_num := :2;
        l_visit_hstry_rec.visa_id              := :3;
        l_visit_hstry_rec.visit_start_date     := :4;
        l_visit_hstry_rec.visit_end_date       := :5;
        l_visit_hstry_rec.remarks              := NULL;

        Igs_Pe_Visapass_Pub.Update_VisitHistry
        (p_api_version      => 1.0
        ,p_init_msg_list    => Fnd_Api.G_TRUE
        ,p_visit_hstry_rec  => l_visit_hstry_rec
        ,x_return_status    => :6
        ,x_msg_count        => :7
        ,x_msg_data         => :8
        );
      END;';

      EXECUTE IMMEDIATE PLSQL_Block
      Using l_oss_vvhist_rec_new.port_of_entry
           ,l_oss_vvhist_rec_new.cntry_entry_form_num
           ,l_oss_vvhist_rec_new.visa_id
           ,l_oss_vvhist_rec_new.visit_start_date
           ,l_oss_vvhist_rec_new.visit_end_date
           ,OUT l_return_status
           ,OUT l_msg_count
           ,OUT l_msg_data;
  END IF;
  Hr_Utility.set_location(' l_return_status: '||l_return_status, 45);
  Hr_Utility.set_location(' l_msg_data: '||l_msg_data, 45);
  IF l_return_status IN ('E','U') THEN
     RAISE e_visit_hstry_err;
  END IF;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);

EXCEPTION
  WHEN e_visit_hstry_err THEN
    l_error_msg := Substrb(l_msg_data,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;
END InsUpd_OSS_VisitHistory;

-- =============================================================================
-- ~ InsUpd_InHR_PassPort:
-- =============================================================================
PROCEDURE InsUpd_InHR_PassPort
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_pp_error_code     OUT NOCOPY Varchar2
         ,p_passport_warning  OUT NOCOPY Boolean
          ) AS
   -- Existing Passport details in HRMS
     CURSOR csr_pe_pass (c_person_id     IN Number
                        ,c_pp_number     IN Varchar2
                        ,c_pp_cntry_code IN Varchar2) IS
     SELECT pei.pei_information5
           ,pei.pei_information6
           ,pei.pei_information7
           ,pei.pei_information8
           ,pei.object_version_number
           ,pei.person_extra_info_id
       FROM per_people_extra_info pei
      WHERE pei.person_id        = c_person_id
        AND pei.information_type ='PER_US_PASSPORT_DETAILS'
        AND pei.pei_information5 = c_pp_cntry_code
        AND pei.pei_information6 = c_pp_number ;
  l_hr_pe_pass             csr_pe_pass%ROWTYPE;

  TYPE csr_oss_t  IS REF CURSOR;
  SQLstmt                 Varchar2(2000);
  csr_pp                  csr_oss_t;
  l_oss_pp_rec            oss_pp_rec;
  l_action                Varchar2(50);
  l_passport_category     per_people_extra_info.information_type%TYPE;
  l_person_extra_info_rec per_people_extra_info%ROWTYPE;
  l_cntry_mapping         csr_cntry_code%ROWTYPE;
  --
  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_InHR_PassPort';
  --
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  SAVEPOINT oss_passport_dtls;
  l_passport_category := 'PER_US_PASSPORT_DETAILS';
  --
  SQLstmt := ' SELECT pap.rowid                '||
             '       ,pap.passport_id          '||
             '       ,pap.passport_cntry_code  '||
             '       ,pap.passport_number      '||
             '       ,pap.passport_expiry_date '||
             '       ,pap.attribute_category   '||
             '       ,pap.attribute1  '||
             '       ,pap.attribute2  '||
             '       ,pap.attribute3  '||
             '       ,pap.attribute4  '||
             '       ,pap.attribute5  '||
             '       ,pap.attribute6  '||
             '       ,pap.attribute7  '||
             '       ,pap.attribute8  '||
             '       ,pap.attribute9  '||
             '       ,pap.attribute10 '||
             '       ,pap.attribute11 '||
             '       ,pap.attribute12 '||
             '       ,pap.attribute13 '||
             '       ,pap.attribute14 '||
             '       ,pap.attribute15 '||
             '       ,pap.attribute16 '||
             '       ,pap.attribute17 '||
             '       ,pap.attribute18 '||
             '       ,pap.attribute19 '||
             '       ,pap.attribute20 '||
             '   FROM igs_pe_passport  pap '||
             '  WHERE pap.person_id = :c_party_id ';


  l_person_extra_info_rec := NULL;
  -- Create the Passport details in HRMS
  Hr_Utility.set_location(' Creating: '||l_passport_category, 8);
  l_person_extra_info_rec.information_type         := l_passport_category;
  l_person_extra_info_rec.pei_information_category := l_passport_category;
  -- ===========================================================================
  -- Country (VS)-R    = pei_information5 = igs_pe_passport.passport_cntry_code
  -- Passport Number-R = pei_information6 = igs_pe_passport.passport_number
  -- Issue Date        = pei_information7 = default to null
  -- Expiry Date       = pei_information8 = igs_pe_passport.passport_expiry_date
  -- ===========================================================================
  OPEN csr_pp FOR SQLstmt Using p_party_id;
  LOOP
      FETCH csr_pp INTO l_oss_pp_rec;
      EXIT WHEN csr_pp%NOTFOUND;
      OPEN csr_cntry_code
          (c_country_code => l_oss_pp_rec.passport_cntry_code
          ,c_map_to       => 'OSS_TO_HR');
      FETCH csr_cntry_code INTO l_cntry_mapping;
      CLOSE csr_cntry_code;

      l_person_extra_info_rec.pei_information5
        := nvl(l_cntry_mapping.ins_code,
               l_oss_pp_rec.passport_cntry_code);
      l_person_extra_info_rec.pei_information6
        := l_oss_pp_rec.passport_number;
      l_person_extra_info_rec.pei_information7  := NULL;
      l_person_extra_info_rec.pei_information8
         := Fnd_Date.date_to_canonical(l_oss_pp_rec.passport_expiry_date);
      -- Check if the passport no. already exists in HRMS, if yes the update
      -- that passport number.
      OPEN  csr_pe_pass (c_person_id     => p_person_id
                        ,c_pp_number     => l_oss_pp_rec.passport_number
                        ,c_pp_cntry_code => l_oss_pp_rec.passport_cntry_code);
      FETCH csr_pe_pass INTO l_hr_pe_pass;

      IF csr_pe_pass%NOTFOUND THEN
        l_action := 'CREATE';
      ELSE
        l_action := 'UPDATE';
        l_person_extra_info_rec.pei_information7      := l_hr_pe_pass.pei_information7;
        l_person_extra_info_rec.person_extra_info_id  := l_hr_pe_pass.person_extra_info_id;
        l_person_extra_info_rec.object_version_number := l_hr_pe_pass.object_version_number;
      END IF;
      InsUpd_Per_Extra_info
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_action            => l_action
      ,p_extra_info_rec    => l_person_extra_info_rec
       );

      CLOSE csr_pe_pass;
  END LOOP;
  CLOSE csr_pp;
  p_passport_warning := FALSE;
  p_pp_error_code := NULL;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
  WHEN Others THEN
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  IF csr_pp%ISOPEN THEN
     CLOSE csr_pp;
  END IF;
  IF csr_pe_pass%ISOPEN THEN
     CLOSE csr_pe_pass;
  END IF;

  ROLLBACK TO oss_passport_dtls;
  p_passport_warning := TRUE;
  p_pp_error_code := SQLCODE;
END InsUpd_InHR_PassPort;

-- =============================================================================
-- ~ InsUpd_InHR_Visa:
-- =============================================================================
PROCEDURE InsUpd_InHR_Visa
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_visa_error_code   OUT NOCOPY Varchar2
         ,p_visa_warning      OUT NOCOPY Boolean
          ) AS
  -- Existing Visa details in HRMS
  CURSOR csr_pe_visa (c_person_id    IN Number
                     ,c_visa_type    IN Varchar2
                     ,c_visa_number  IN Varchar2) IS
  SELECT pei.pei_information5
        ,pei.pei_information6
        ,pei.pei_information7
        ,pei.pei_information8
        ,pei.pei_information9
        ,pei.pei_information10
        ,pei.object_version_number
        ,pei.person_extra_info_id
    FROM per_people_extra_info pei
   WHERE pei.person_id        = c_person_id
     AND pei.information_type ='PER_US_VISA_DETAILS'
     AND pei.pei_information5 = c_visa_type
     AND pei.pei_information6 = c_visa_number;

  l_hr_pe_visa             csr_pe_visa%ROWTYPE;

  TYPE csr_oss_t  IS REF CURSOR;
  SQLstmt                 Varchar2(2000);
  csr_visa                csr_oss_t;
  l_visa_rec              oss_visa_rec;
  l_action                Varchar2(50);
  l_visa_category         per_people_extra_info.information_type%TYPE;
  l_person_extra_info_rec per_people_extra_info%ROWTYPE;
  --
  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_InHR_Visa';
  --
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  SAVEPOINT oss_visa_dtls;
  l_visa_category := 'PER_US_VISA_DETAILS';
  --
  SQLstmt:='SELECT                     '||
           '     rowid                 '||
           '     ,visa_id              '||
           '     ,visa_type            '||
           '     ,visa_number          '||
           '     ,visa_issue_date      '||
           '     ,visa_expiry_date     '||
           '     ,visa_category        '||
           '     ,visa_issuing_post    '||
           '     ,passport_id          '||
           '     ,agent_org_unit_cd    '||
           '     ,agent_person_id      '||
           '     ,agent_contact_name   '||
           '     ,visa_issuing_country '||
           '     ,attribute_category   '||
           '     ,attribute1  '||
           '     ,attribute2  '||
           '     ,attribute3  '||
           '     ,attribute4  '||
           '     ,attribute5  '||
           '     ,attribute6  '||
           '     ,attribute7  '||
           '     ,attribute8  '||
           '     ,attribute9  '||
           '     ,attribute10 '||
           '     ,attribute11 '||
           '     ,attribute12 '||
           '     ,attribute13 '||
           '     ,attribute14 '||
           '     ,attribute15 '||
           '     ,attribute16 '||
           '     ,attribute17 '||
           '     ,attribute18 '||
           '     ,attribute19 '||
           '     ,attribute20 '||
           ' FROM igs_pe_visa '||
           'WHERE person_id = :c_party_id ';


  l_person_extra_info_rec := NULL;
  -- Create the Passport details in HRMS
  Hr_Utility.set_location(' Creating: '||l_visa_category, 8);
  l_person_extra_info_rec.information_type         := l_visa_category;
  l_person_extra_info_rec.pei_information_category := l_visa_category;
  -- ===========================================================================
  -- Visa Type(VS)-R   = pei_information5  = igs_pe_visa.visa_type
  -- Visa Number-R     = pei_information6  = igs_pe_visa.visa_number
  -- Issue Date -R     = pei_information7  = igs_pe_visa.visa_issue_date
  -- Expiry Date -R    = pei_information8  = igs_pe_visa.visa_expiry_date
  -- J Visa Category   = pei_information9  = default to null
  -- Pass To Interface = pei_information10 = N
  -- ===========================================================================
  OPEN csr_visa FOR SQLstmt Using p_party_id;
  LOOP
      FETCH csr_visa INTO l_visa_rec;
      EXIT WHEN csr_visa%NOTFOUND;
      l_person_extra_info_rec.pei_information5  := l_visa_rec.visa_type;
      l_person_extra_info_rec.pei_information6  := l_visa_rec.visa_number;
      l_person_extra_info_rec.pei_information7
          := Fnd_Date.date_to_canonical(l_visa_rec.visa_issue_date);
      l_person_extra_info_rec.pei_information8
          := Fnd_Date.date_to_canonical(l_visa_rec.visa_expiry_date);
      l_person_extra_info_rec.pei_information9  := '99';
      l_person_extra_info_rec.pei_information10 := 'N';
      -- Check if the existing visa is already existing, if yes then update it.
      OPEN  csr_pe_visa (c_person_id    => p_person_id
                        ,c_visa_type    => l_visa_rec.visa_type
                        ,c_visa_number  => l_visa_rec.visa_number);
      FETCH csr_pe_visa INTO l_hr_pe_visa;
      IF csr_pe_visa%NOTFOUND THEN
        l_action := 'CREATE';
      ELSE
        l_action := 'UPDATE';
        l_person_extra_info_rec.pei_information9      := l_hr_pe_visa.pei_information9;
        l_person_extra_info_rec.pei_information10     := l_hr_pe_visa.pei_information10;
        l_person_extra_info_rec.person_extra_info_id  := l_hr_pe_visa.person_extra_info_id;
        l_person_extra_info_rec.object_version_number := l_hr_pe_visa.object_version_number;
      END IF;
      InsUpd_Per_Extra_info
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_action            => l_action
      ,p_extra_info_rec    => l_person_extra_info_rec
       );
      CLOSE csr_pe_visa;

  END LOOP;
  CLOSE csr_visa;
  p_visa_warning := FALSE;
  p_visa_error_code := NULL;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
  WHEN Others THEN
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  IF csr_visa%ISOPEN THEN
     CLOSE csr_visa;
  END IF;
  IF csr_pe_visa%ISOPEN THEN
     CLOSE csr_pe_visa;
  END IF;

  ROLLBACK TO oss_visa_dtls;
  p_visa_warning := TRUE;
  p_visa_error_code := SQLCODE;

END InsUpd_InHR_Visa;

-- =============================================================================
-- ~ InsUpd_InHR_Visit:
-- =============================================================================
PROCEDURE InsUpd_InHR_Visit
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_visit_error_code   OUT NOCOPY Varchar2
         ,p_visit_warning      OUT NOCOPY Boolean
          ) AS
  -- Existing Visa details in HRMS
  CURSOR csr_pe_visit (c_person_id    IN Number
                      ,c_visa_number  IN Varchar2) IS
  SELECT pei.pei_information5
        ,pei.pei_information11
        ,pei.pei_information7
        ,pei.pei_information8
        ,pei.pei_information9
        ,pei.pei_information10
        ,pei.object_version_number
        ,pei.person_extra_info_id
    FROM per_people_extra_info pei
   WHERE pei.person_id         = c_person_id
     AND pei.information_type  = 'PER_US_VISIT_HISTORY'
     AND pei.pei_information11 = c_visa_number;
  --
  l_hr_pe_visit           csr_pe_visit%ROWTYPE;
  --
  TYPE csr_oss_t  IS REF CURSOR;
  SQLstmt                 Varchar2(2000);
  csr_visit               csr_oss_t;
  l_vv_rec                Visit_Hist_Rec;
  l_visit_category        per_people_extra_info.information_type%TYPE;
  l_person_extra_info_rec per_people_extra_info%ROWTYPE;
  l_action                Varchar2(50);
  --
  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_InHR_Visit';
  --
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  SAVEPOINT oss_vv_dtls;
  l_visit_category := 'PER_US_VISIT_HISTORY';
  --
  SQLstmt:=' SELECT row_id                '||
           '       ,port_of_entry         '||
           '       ,port_of_entry_m       '||
           '       ,cntry_entry_form_num  '||
           '       ,visa_id               '||
           '       ,visa_type             '||
           '       ,visa_number           '||
           '       ,visa_issue_date       '||
           '       ,visa_expiry_date      '||
           '       ,visa_category         '||
           '       ,visa_issuing_post     '||
           '       ,passport_id           '||
           '       ,visit_start_date      '||
           '       ,visit_end_date        '||
           '   FROM igs_pe_visit_histry_v '||
           '  WHERE person_id = :c_party_id ';

  l_person_extra_info_rec := NULL;
  -- Create the Visa Visit History details in HRMS
  Hr_Utility.set_location(' Creating: '||l_visit_category, 8);
  l_person_extra_info_rec.information_type         := l_visit_category;
  l_person_extra_info_rec.pei_information_category := l_visit_category;
  -- =================================================================================
  -- Purpose (VS)-R            = pei_information5  = This is Specific to HRMS
  -- Visa Number               = pei_information11 = igs_pe_visit_histry.visa_number
  -- Start Date -R             = pei_information7  = igs_pe_visit_histry.visit_start_date
  -- End Date                  = pei_information8  = igs_pe_visit_histry.visit_end_date
  -- Spouse Accompanied (VS)-R = pei_information9  = Default to N
  -- Child Accompanied  (VS)-R = pei_information10 = Default to N
  -- ================================================================================
  OPEN csr_visit FOR SQLstmt Using p_party_id;
  LOOP
      FETCH csr_visit INTO l_vv_rec;
      EXIT WHEN csr_visit%NOTFOUND;
      l_person_extra_info_rec.pei_information5  := '01';
      l_person_extra_info_rec.pei_information11 := l_vv_rec.visa_number;
      l_person_extra_info_rec.pei_information7 :=
        Fnd_Date.date_to_canonical(l_vv_rec.visit_start_date);
      l_person_extra_info_rec.pei_information8 :=
        Fnd_Date.date_to_canonical(l_vv_rec.visit_end_date);
      l_person_extra_info_rec.pei_information9  := 'N';
      l_person_extra_info_rec.pei_information10 := 'N';
      l_person_extra_info_rec.pei_information12 := l_vv_rec.cntry_entry_form_num;
      l_person_extra_info_rec.pei_information13 := l_vv_rec.port_of_entry;
      -- The Visa Number value-set refers to the person_id profile value, hence
      -- setting the profile value to the current person_id passed.
      Fnd_Profile.put('PER_PERSON_ID',p_person_id);
      -- Check if the existing visa visit history is already existing,
      -- if yes then update it.
      OPEN  csr_pe_visit (c_person_id   => p_person_id
                         ,c_visa_number => l_vv_rec.visa_number);
      FETCH csr_pe_visit INTO l_hr_pe_visit;
      IF csr_pe_visit%NOTFOUND THEN
        l_action := 'CREATE';
      ELSE
        l_person_extra_info_rec.pei_information11     := l_hr_pe_visit.pei_information11;
        l_person_extra_info_rec.person_extra_info_id  := l_hr_pe_visit.person_extra_info_id;
        l_person_extra_info_rec.object_version_number := l_hr_pe_visit.object_version_number;
        l_action := 'UPDATE';
      END IF;
      CLOSE csr_pe_visit;
      InsUpd_Per_Extra_info
      (p_person_id         => p_person_id
      ,p_business_group_id => p_business_group_id
      ,p_action            => l_action
      ,p_extra_info_rec    => l_person_extra_info_rec
       );
  END LOOP;
  CLOSE csr_visit;
  p_visit_warning := FALSE;
  p_visit_error_code := NULL;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
  WHEN Others THEN
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  IF csr_visit%ISOPEN THEN
     CLOSE csr_visit;
  END IF;
  IF csr_pe_visit%ISOPEN THEN
     CLOSE csr_pe_visit;
  END IF;
  ROLLBACK TO oss_vv_dtls;
  p_visit_warning := TRUE;
  p_visit_error_code := SQLCODE;

END InsUpd_InHR_Visit;

-- =============================================================================
-- ~ InsUpd_InHR_OSSPerDtls:
-- =============================================================================
PROCEDURE InsUpd_InHR_OSSPerDtls
         (p_business_group_id IN Number
         ,p_person_id         IN Number
         ,p_party_id          IN Number
         ,p_effective_date    IN Date
         ,p_oss_error_code    OUT NOCOPY Varchar2
         ,p_ossDtls_warning   OUT NOCOPY Boolean
          ) AS
  -- Existing OSS Person Details
  CURSOR csr_OSS_pe (c_person_id         IN Number
                    ,c_information_type  IN Varchar2) IS
  SELECT pei.pei_information1
        ,pei.pei_information2
        ,pei.pei_information3
        ,pei.pei_information4
        ,pei.pei_information5
        ,pei.object_version_number
        ,pei.person_extra_info_id
    FROM per_people_extra_info pei
   WHERE pei.person_id        = c_person_id
     AND pei.information_type = c_information_type;
  l_OSS_pe             csr_oss_pe%ROWTYPE;
  TYPE oss_per_rec IS RECORD
   ( person_id_type      Varchar2(150)
    ,api_person_id       Varchar2(150)
    ,person_number       Varchar2(150)
    ,system_type         Varchar2(150)
    );
  TYPE csr_oss_t  IS REF CURSOR;
  SQLstmt                 Varchar2(2000);
  csr_igs                 csr_oss_t;
  l_oss_per_details       oss_per_rec;
  l_oss_person_details    per_people_extra_info.information_type%TYPE;
  l_person_extra_info_rec per_people_extra_info%ROWTYPE;
  --
  l_proc_name CONSTANT  Varchar2(150) := g_pkg ||'InsUpd_InHR_OSSPerDtls';
  --
  CURSOR hz_pe (c_party_id IN Number) IS
  SELECT hzp.party_number
    FROM hz_parties hzp
   WHERE hzp.party_id = c_party_id;
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  SAVEPOINT oss_per_dtls;
  l_oss_person_details := 'PQP_OSS_PERSON_DETAILS';
  --
  SQLstmt:=
  '   SELECT igp.person_id_type  ' ||
  '         ,igp.api_person_id   ' ||
  '         ,igp.person_number   ' ||
  '         ,ipt.system_type     ' ||
  '     FROM igs_pe_person_v igp ' ||
  '         ,igs_pe_typ_instances_all pti ' ||
  '         ,igs_pe_person_types      ipt ' ||
  '    WHERE igp.person_id = :c_party_id  ' ||
  '      AND pti.person_type_code = ipt.person_type_code ' ||
  '      AND pti.person_id = igp.person_id ' ||
  '      AND ipt.system_type IN ('||'''STUDENT'''||',' ||
                                '''FACULTY'''||','||'''OTHER''' ||')' ;

  l_person_extra_info_rec := NULL;
  -- Create the OSS Person EIT information
  Hr_Utility.set_location(' Creating: PQP_OSS_PERSON_DETAILS', 8);

  l_person_extra_info_rec.information_type         := l_oss_person_details;
  l_person_extra_info_rec.pei_information_category := l_oss_person_details;
  -- ===========================================================================
  -- OSS Person Type -(R)      = PEI_INFORMATION1
  -- OSS Person Number -(R)    = PEI_INFORMATION2
  -- Alternate Id Type         = PEI_INFORMATION3
  -- Alternate Id No           = PEI_INFORMATION4
  -- Synchronize OSS Data -(R) = PEI_INFORMATION5
  -- ===========================================================================
   OPEN csr_igs FOR SQLstmt Using p_party_id;
  FETCH csr_igs INTO l_oss_per_details;
  CLOSE csr_igs;
  Hr_Utility.set_location(' After Dyn SQL Ref Cursor', 8);
  l_person_extra_info_rec.pei_information1  := Nvl(l_oss_per_details.system_type
                                                  ,'STUDENT');
  l_person_extra_info_rec.pei_information2  := l_oss_per_details.person_number;
  IF l_oss_per_details.person_number IS NULL THEN
     OPEN hz_pe(c_party_id => p_party_id);
    FETCH hz_pe INTO l_oss_per_details.person_number;
    CLOSE hz_pe;
    l_person_extra_info_rec.pei_information2
      := l_oss_per_details.person_number;
  END IF;
   l_person_extra_info_rec.pei_information3  := Null;
   l_person_extra_info_rec.pei_information4  := Null;
   l_person_extra_info_rec.pei_information5  := 'Y';
  OPEN  csr_OSS_pe (c_person_id        => p_person_id
                   ,c_information_type => l_oss_person_details);
  FETCH csr_OSS_pe INTO l_OSS_pe;
  Hr_Utility.set_location(' After Cursor :csr_OSS_pe', 8);
  IF csr_OSS_pe%NOTFOUND THEN
    InsUpd_Per_Extra_info
    (p_person_id         => p_person_id
    ,p_business_group_id => p_business_group_id
    ,p_action            => 'CREATE'
    ,p_extra_info_rec    => l_person_extra_info_rec
     );
  ELSE
    l_person_extra_info_rec.person_extra_info_id  := l_OSS_pe.person_extra_info_id;
    l_person_extra_info_rec.object_version_number := l_OSS_pe.object_version_number;
    l_person_extra_info_rec.pei_information3      := l_OSS_pe.pei_information3;
    l_person_extra_info_rec.pei_information4      := l_OSS_pe.pei_information4;
    l_person_extra_info_rec.pei_information5      := 'Y';
    InsUpd_Per_Extra_info
    (p_person_id         => p_person_id
    ,p_business_group_id => p_business_group_id
    ,p_action            => 'UPDATE'
    ,p_extra_info_rec    => l_person_extra_info_rec
     );
  END IF;
  CLOSE csr_OSS_pe;
  p_oss_error_code := NULL;
  p_ossDtls_warning := FALSE;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);

EXCEPTION
  WHEN Others THEN
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  IF csr_OSS_pe%ISOPEN THEN
     CLOSE csr_OSS_pe;
  END IF;

  ROLLBACK TO oss_per_dtls;
  p_oss_error_code := SQLCODE;
  p_ossDtls_warning := TRUE;

END InsUpd_InHR_OSSPerDtls;

-- =============================================================================
-- ~ Person_Address_API:
-- =============================================================================
PROCEDURE Person_Address_API
         (p_HR_Address_Rec           IN OUT NOCOPY Per_Addresses%ROWTYPE
         ,p_validate                 IN Boolean
         ,p_action                   IN Varchar2
         ,p_effective_date           IN Date
         ,p_pradd_ovlapval_override  IN Boolean
         ,p_validate_county          IN Boolean
         ,p_primary_flag             IN Varchar2
         ,p_HR_address_id            OUT NOCOPY Number
         ,p_HR_object_version_number OUT NOCOPY Number) AS

  l_proc_name  CONSTANT Varchar2(150) := g_pkg ||'Person_Address_API';
  l_error_msg           Varchar2(2000);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  IF Nvl(p_action,'CREATE') = 'CREATE' THEN
  Hr_Utility.set_location('..Creating primary address: '||p_HR_Address_Rec.Style, 6);
  Hr_Person_Address_Api.Create_Person_Address
  (p_validate                => Nvl(p_validate,FALSE)
  ,p_effective_date          => p_effective_date
  ,p_pradd_ovlapval_override => Nvl(p_pradd_ovlapval_override,FALSE)
  ,p_validate_county         => Nvl(p_validate_county,TRUE)
  ,p_person_id               => p_HR_Address_Rec.person_id
  ,p_primary_flag            => Nvl(p_primary_flag,'Y')
  ,p_style                   => p_HR_Address_Rec.Style
  ,p_date_from               => p_HR_Address_Rec.date_from
  ,p_date_to                 => p_HR_Address_Rec.date_to
  ,p_address_type            => p_HR_Address_Rec.address_type
  ,p_comments                => p_HR_Address_Rec.comments  -- NULL , By Dbansal
  ,p_address_line1           => p_HR_Address_Rec.address_line1
  ,p_address_line2           => p_HR_Address_Rec.address_line2
  ,p_address_line3           => p_HR_Address_Rec.address_line3
  ,p_town_or_city            => p_HR_Address_Rec.town_or_city
  ,p_region_1                => p_HR_Address_Rec.region_1
  ,p_region_2                => p_HR_Address_Rec.region_2
  ,p_region_3                => p_HR_Address_Rec.region_3
  ,p_postal_code             => p_HR_Address_Rec.postal_code
  ,p_country                 => p_HR_Address_Rec.country
  ,p_telephone_number_1      => p_HR_Address_Rec.telephone_number_1
  ,p_telephone_number_2      => p_HR_Address_Rec.telephone_number_2
  ,p_telephone_number_3      => p_HR_Address_Rec.telephone_number_3
  ,p_addr_attribute_category => p_HR_Address_Rec.addr_attribute_category
  ,p_addr_attribute1         => p_HR_Address_Rec.addr_attribute1
  ,p_addr_attribute2         => p_HR_Address_Rec.addr_attribute2
  ,p_addr_attribute3         => p_HR_Address_Rec.addr_attribute3
  ,p_addr_attribute4         => p_HR_Address_Rec.addr_attribute4
  ,p_addr_attribute5         => p_HR_Address_Rec.addr_attribute5
  ,p_addr_attribute6         => p_HR_Address_Rec.addr_attribute6
  ,p_addr_attribute7         => p_HR_Address_Rec.addr_attribute7
  ,p_addr_attribute8         => p_HR_Address_Rec.addr_attribute8
  ,p_addr_attribute9         => p_HR_Address_Rec.addr_attribute9
  ,p_addr_attribute10        => p_HR_Address_Rec.addr_attribute10
  ,p_addr_attribute11        => p_HR_Address_Rec.addr_attribute11
  ,p_addr_attribute12        => p_HR_Address_Rec.addr_attribute12
  ,p_addr_attribute13        => p_HR_Address_Rec.addr_attribute13
  ,p_addr_attribute14        => p_HR_Address_Rec.addr_attribute14
  ,p_addr_attribute15        => p_HR_Address_Rec.addr_attribute15
  ,p_addr_attribute16        => p_HR_Address_Rec.addr_attribute16
  ,p_addr_attribute17        => p_HR_Address_Rec.addr_attribute17
  ,p_addr_attribute18        => p_HR_Address_Rec.addr_attribute18
  ,p_addr_attribute19        => p_HR_Address_Rec.addr_attribute19
  ,p_addr_attribute20        => p_HR_Address_Rec.addr_attribute20
  ,p_add_information13       => p_HR_Address_Rec.add_information13
  ,p_add_information14       => p_HR_Address_Rec.add_information14
  ,p_add_information15       => p_HR_Address_Rec.add_information15
  ,p_add_information16       => p_HR_Address_Rec.add_information16
  ,p_add_information17       => p_HR_Address_Rec.add_information17
  ,p_add_information18       => p_HR_Address_Rec.add_information18
  ,p_add_information19       => p_HR_Address_Rec.add_information19
  ,p_add_information20       => p_HR_Address_Rec.add_information20
  ,p_party_id                => p_HR_Address_Rec.party_id
  ,p_address_id              => p_HR_address_id
  ,p_object_version_number   => p_HR_object_version_number
  );
  ELSIF p_action ='UPDATE' THEN
  Hr_Utility.set_location('..Updating Primary Address: '||p_HR_Address_Rec.Style, 6);
  Hr_Person_Address_Api.Update_Person_Address
  (p_validate                 => Nvl(p_validate,FALSE)
  ,p_effective_date           => p_effective_date
  ,p_validate_county          => Nvl(p_validate_county,TRUE)
  ,p_address_id               => p_HR_Address_Rec.address_id
  ,p_object_version_number    => p_HR_Address_Rec.object_version_number
  ,p_date_from                => p_HR_Address_Rec.date_from
  ,p_date_to                  => p_HR_Address_Rec.date_to
  ,p_primary_flag             => p_HR_Address_Rec.primary_flag
  ,p_address_type             => p_HR_Address_Rec.address_type
  ,p_comments                 => p_HR_Address_Rec.comments -- NULL, By Dbansal
  ,p_address_line1            => p_HR_Address_Rec.address_line1
  ,p_address_line2            => p_HR_Address_Rec.address_line2
  ,p_address_line3            => p_HR_Address_Rec.address_line3
  ,p_town_or_city             => p_HR_Address_Rec.town_or_city
  ,p_region_1                 => p_HR_Address_Rec.region_1
  ,p_region_2                 => p_HR_Address_Rec.region_2
  ,p_region_3                 => p_HR_Address_Rec.region_3
  ,p_postal_code              => p_HR_Address_Rec.postal_code
  ,p_country                  => p_HR_Address_Rec.country
  ,p_telephone_number_1       => p_HR_Address_Rec.telephone_number_1
  ,p_telephone_number_2       => p_HR_Address_Rec.telephone_number_2
  ,p_telephone_number_3       => p_HR_Address_Rec.telephone_number_3
  ,p_addr_attribute_category  => p_HR_Address_Rec.addr_attribute_category
  ,p_addr_attribute1          => p_HR_Address_Rec.addr_attribute1
  ,p_addr_attribute2          => p_HR_Address_Rec.addr_attribute2
  ,p_addr_attribute3          => p_HR_Address_Rec.addr_attribute3
  ,p_addr_attribute4          => p_HR_Address_Rec.addr_attribute4
  ,p_addr_attribute5          => p_HR_Address_Rec.addr_attribute5
  ,p_addr_attribute6          => p_HR_Address_Rec.addr_attribute6
  ,p_addr_attribute7          => p_HR_Address_Rec.addr_attribute7
  ,p_addr_attribute8          => p_HR_Address_Rec.addr_attribute8
  ,p_addr_attribute9          => p_HR_Address_Rec.addr_attribute9
  ,p_addr_attribute10         => p_HR_Address_Rec.addr_attribute10
  ,p_addr_attribute11         => p_HR_Address_Rec.addr_attribute11
  ,p_addr_attribute12         => p_HR_Address_Rec.addr_attribute12
  ,p_addr_attribute13         => p_HR_Address_Rec.addr_attribute13
  ,p_addr_attribute14         => p_HR_Address_Rec.addr_attribute14
  ,p_addr_attribute15         => p_HR_Address_Rec.addr_attribute15
  ,p_addr_attribute16         => p_HR_Address_Rec.addr_attribute16
  ,p_addr_attribute17         => p_HR_Address_Rec.addr_attribute17
  ,p_addr_attribute18         => p_HR_Address_Rec.addr_attribute18
  ,p_addr_attribute19         => p_HR_Address_Rec.addr_attribute19
  ,p_addr_attribute20         => p_HR_Address_Rec.addr_attribute20
  ,p_add_information13        => p_HR_Address_Rec.add_information13
  ,p_add_information14        => p_HR_Address_Rec.add_information14
  ,p_add_information15        => p_HR_Address_Rec.add_information15
  ,p_add_information16        => p_HR_Address_Rec.add_information16
  ,p_add_information17        => p_HR_Address_Rec.add_information17
  ,p_add_information18        => p_HR_Address_Rec.add_information18
  ,p_add_information19        => p_HR_Address_Rec.add_information19
  ,p_add_information20        => p_HR_Address_Rec.add_information20
  ,p_party_id                 => p_HR_Address_Rec.party_id
  );
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
EXCEPTION
  WHEN Others THEN
   l_error_msg := Substrb(SQLERRM,1,2000);
   Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   Hr_Utility.raise_error;

END Person_Address_API;

-- =============================================================================
-- ~ Create_Address_TCA_To_HR
-- =============================================================================
PROCEDURE Create_Address_TCA_To_HR
         (p_validate                IN Boolean
         ,p_effective_date          IN Date
         ,p_party_id                IN Number
         ,p_business_group_id       IN Number
         ,p_party_site_id           IN Number
         ,p_style                   IN Varchar2
         ,p_location_id             IN Number
         ,p_pradd_ovlapval_override IN Boolean
         ,p_validate_county         IN Boolean
         ,p_primary_flag            IN Varchar2
         ,p_address_type            IN Varchar2
         ,p_overide_TCA_Mapping     IN Varchar2
         --,p_HZ_Location_Rec         IN Hz_Location_V2pub.Location_Rec_Type
         -- Out Variable from HR
         ,p_HR_address_id            OUT NOCOPY Number
         ,p_HR_object_version_number OUT NOCOPY Number
          ) AS

 l_party_site_rec     hz_party_sites%ROWTYPE;
 l_HR_Address_Rec     Per_Addresses%ROWTYPE;
 --l_HZ_Loc_Rec         Hz_Location_V2pub.Location_Rec_Type;
 --l_HZ_Loc_Row         Hz_Locations%ROWTYPE;
 l_proc_name CONSTANT Varchar2(150):= g_pkg ||'Create_Address_TCA_To_HR';
 l_map_info_category  Varchar2(150);
 l_error_msg          Varchar2(2000);
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
EXCEPTION
 WHEN Others THEN
   l_error_msg := Substrb(SQLERRM,1,2000);
   Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
   Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
   Hr_Utility.raise_error;

END Create_Address_TCA_To_HR;

-- =============================================================================
-- ~ Update_Address_TCA_To_HR:
-- =============================================================================
PROCEDURE Update_Address_TCA_To_HR
         (p_validate                IN Boolean
         ,p_effective_date          IN Date
         ,p_party_id                IN Number
         ,p_business_group_id       IN Number
         ,p_party_site_id           IN Number
         ,p_style                   IN Varchar2
         ,p_location_id             IN Number
         ,p_pradd_ovlapval_override IN Boolean
         ,p_validate_county         IN Boolean
         ,p_primary_flag            IN Varchar2
         ,p_address_type            IN Varchar2
         ,p_overide_TCA_Mapping     IN Varchar2
         --,p_HZ_Location_Rec         IN Hz_Location_V2pub.Location_Rec_Type
         -- Out Variable from HR
         ,p_HR_object_version_number IN OUT NOCOPY Number
          ) AS
  l_proc_name     Varchar2(150);
BEGIN
  l_proc_name := g_pkg ||'Create_Address_TCA_To_HR';
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);


  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
END Update_Address_TCA_To_HR;
-- =============================================================================
-- ~ Check_HR_Validations:
-- =============================================================================
PROCEDURE Check_HR_Validations
         (p_column_name     IN Varchar2
         ,p_column_value    IN Varchar2
         ,p_style           IN Varchar2
         ,p_col_lookup_type IN Varchar2
         ,p_valid_col_value OUT NOCOPY Varchar2) AS

   CURSOR csr_ff_val (c_context_code IN Varchar2
                     ,c_column_name  IN Varchar2) IS
   SELECT fcu.column_seq_num
         ,fcu.application_column_name
         ,fcu.end_user_column_name
         ,fcu.enabled_flag
         ,fcu.required_flag
         ,fvs.maximum_size
         ,fvs.uppercase_only_flag
         ,fvs.maximum_value
         ,fvs.minimum_value
         ,fvs.alphanumeric_allowed_flag
         ,fvs.validation_type
     FROM fnd_descr_flex_column_usages  fcu,
          fnd_flex_value_sets           fvs,
          fnd_flex_validation_tables    fvt
   WHERE fcu.descriptive_flexfield_name    = 'Address Structure'
     AND fcu.descriptive_flex_context_code = c_context_code
     AND fcu.application_column_name       = c_column_name
     AND fcu.application_id                = 800
     AND fcu.enabled_flag                  = 'Y'
     AND fvs.flex_value_set_id(+)          = fcu.flex_value_set_id
     AND fvt.flex_value_set_id(+)          = fvs.flex_value_set_id
     ORDER BY fcu.column_seq_num;

  l_proc_name           CONSTANT Varchar2(150) := g_pkg ||'Check_HR_Validations';
  l_dff_val             csr_ff_val%ROWTYPE;
  l_lookup_rec          csr_meaning_code%ROWTYPE;

BEGIN
  p_valid_col_value := p_column_value;
  --
   OPEN csr_ff_val (c_context_code  => p_style
                   ,c_column_name   => p_column_name);
  FETCH csr_ff_val INTO l_dff_val;
  CLOSE csr_ff_val;
  IF l_dff_val.uppercase_only_flag ='Y' THEN
     p_valid_col_value := Upper(p_column_value);
  END IF;
  IF l_dff_val.required_flag = 'Y' AND
     p_column_value IS NULL THEN
     -- Required Value cannot be null, Raise Error
     NULL;
  END IF;
  IF Nvl(l_dff_val.maximum_size,0) > 0   THEN
     IF Lengthb(p_column_value) > l_dff_val.maximum_size THEN
        -- Value exceeds the max. length
        NULL;
     END IF;
  END IF;
  IF p_col_lookup_type IS NOT NULL THEN
     -- Check if the meaning is being passed
     OPEN csr_meaning_code (c_lookup_type    => p_col_lookup_type
                            -- c_meaning could be code or meaning
                           ,c_meaning        => p_column_value
                           ,c_effective_date => Trunc(g_effective_date));

    FETCH csr_meaning_code INTO l_lookup_rec;
    IF csr_meaning_code%FOUND THEN
       CLOSE csr_meaning_code;
       p_valid_col_value :=  l_lookup_rec.lookup_code;
       RETURN;
    END IF;
    CLOSE csr_meaning_code;
    -- If column is not required then set it to Null
    IF l_dff_val.required_flag <> 'Y' THEN
       NULL;
       --p_valid_col_value := NULL;
    END IF;
  END IF;

EXCEPTION
  WHEN Others THEN
  RAISE;
END Check_HR_Validations;

-- =============================================================================
-- ~ Chk_GeoCodes_Installed:
-- =============================================================================
FUNCTION Chk_GeoCodes_Installed
         (p_leg_code IN Varchar2)
RETURN Varchar2 IS

  CURSOR csr_get_us_city_names
         (c_leg_code IN Varchar2) IS
  SELECT NULL
    FROM pay_us_city_names
   WHERE (c_leg_code = 'CA'AND
          state_code = 70)
          OR
         (c_leg_code ='US' AND
          state_code < 52);
  l_exists           Varchar2(1);
BEGIN
  --  Check if any rows exist in the pay_us_city_names
   OPEN csr_get_us_city_names(p_leg_code);
  FETCH csr_get_us_city_names INTO l_exists;
  IF csr_get_us_city_names%FOUND THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
  CLOSE csr_get_us_city_names;
END Chk_GeoCodes_Installed;

-- =============================================================================
-- ~ Chk_Address_Style:
-- =============================================================================
FUNCTION Chk_Address_Style
        (p_party_id    IN Number
        ,p_bus_grp_id  IN Number
         ) RETURN Varchar2 AS
  -- Cursor to get the party site id
  CURSOR csr_site_id (c_party_id     IN Number
                     ,c_primary_flag IN Varchar2) IS
  SELECT hzl.country
    FROM hz_party_sites hps,
         hz_locations   hzl
   WHERE hps.location_id = hzl.location_id
     AND hps.status = 'A'
     AND hps.party_id = c_party_id
     AND hps.identifying_address_flag = c_primary_flag;

  l_leg_code      Varchar2(5);
  l_HZ_code       Varchar2(5);
  l_return_value  Varchar2(25);
BEGIN
 OPEN csr_bg_code (c_bg_grp_id => p_bus_grp_id);
 FETCH csr_bg_code INTO l_leg_code;
 CLOSE csr_bg_code;
 OPEN csr_site_id (c_party_id     => p_party_id
                  ,c_primary_flag => p_bus_grp_id);
 FETCH csr_site_id INTO l_HZ_code;
 CLOSE csr_site_id;
 l_return_value:= Chk_Address_Style
                  (p_leg_code    => l_leg_code
                  ,p_HZ_country  => l_HZ_code);
 RETURN l_return_value;
END Chk_Address_Style;

-- =============================================================================
-- ~ Chk_Address_Style:
-- =============================================================================
FUNCTION Chk_Address_Style
        (p_leg_code    IN Varchar2
        ,p_HZ_country  IN Varchar2) RETURN Varchar2 IS

  l_Style              per_addresses.style%TYPE;
  l_Style_Code         per_addresses.style%TYPE;
  l_leg_inst_rec       csr_chk_prod%ROWTYPE;

BEGIN
  IF p_leg_code = p_HZ_Country THEN
     l_Style := p_leg_code;
  ELSIF p_HZ_Country IS NULL THEN
     l_Style := p_leg_code;
  ELSIF p_leg_code <> p_HZ_Country THEN
     l_Style := p_HZ_Country;
  END IF;

   OPEN csr_chk_prod (c_leg_code       => l_Style
                     ,c_app_short_name => 'PER');
  FETCH csr_chk_prod INTO l_leg_inst_rec;
  IF csr_chk_prod%NOTFOUND THEN
     l_Style := l_Style||'_GLB';
  END IF;
  CLOSE csr_chk_prod;
  -- Check if the Global address style for the country is
  -- available if not then default to GENERIC style.
   OPEN csr_style(l_Style);
  FETCH csr_style INTO l_Style_Code;
  IF csr_style%NOTFOUND THEN
     l_Style := 'GENERIC';
  END IF;
  CLOSE csr_style;
  --
  IF l_Style = 'US' AND
     Chk_GeoCodes_Installed(p_leg_code ) = 'N' THEN
     l_Style := 'US_GLB';
  ELSIF l_Style = 'CA' THEN
      OPEN csr_chk_prod (c_leg_code       => p_HZ_Country
                        ,c_app_short_name => 'PAY');
     FETCH csr_chk_prod INTO l_leg_inst_rec;
     IF csr_chk_prod%NOTFOUND THEN
        l_Style := 'CA_GLB';
     END IF;
     CLOSE csr_chk_prod;
  ELSIF l_Style ='GB_GLB' THEN
     l_Style := 'GB';
  END IF;

  RETURN l_Style;

END  Chk_Address_Style ;


-- =============================================================================
-- ~ Chk_Address_Style:Used by Web ADI in download query.
-- ~ returns NULL if Address doesn't exist.
-- =============================================================================
FUNCTION Chk_Address_Style
        (p_leg_code          IN Varchar2
        ,p_HZ_country        IN Varchar2
        ,p_location_id       IN Number
        ,p_party_id          IN Number
        ,p_effective_date    IN Date
        ,p_business_group_id IN Number
        ,p_primary_flag      IN Varchar2
        ,p_party_site_id     IN Number) RETURN Varchar2 IS

  l_Style              per_addresses.style%TYPE;
  l_Style_Code         per_addresses.style%TYPE;
  l_leg_inst_rec       csr_chk_prod%ROWTYPE;

BEGIN
  IF p_leg_code = p_HZ_Country THEN
     l_Style := p_leg_code;
  ELSIF p_HZ_Country IS NULL THEN
     l_Style := p_leg_code;
  ELSIF p_leg_code <> p_HZ_Country THEN
     l_Style := p_HZ_Country;
  END IF;

   OPEN csr_chk_prod (c_leg_code       => l_Style
                     ,c_app_short_name => 'PER');
  FETCH csr_chk_prod INTO l_leg_inst_rec;
  IF csr_chk_prod%NOTFOUND THEN
     l_Style := l_Style||'_GLB';
  END IF;
  CLOSE csr_chk_prod;
  -- Check if the Global address style for the country is
  -- available if not then default to GENERIC style.
   OPEN csr_style(l_Style);
  FETCH csr_style INTO l_Style_Code;
  IF csr_style%NOTFOUND THEN
     l_Style := 'GENERIC';
  END IF;
  CLOSE csr_style;
  --
  IF l_Style = 'US' AND
     Chk_GeoCodes_Installed(p_leg_code ) = 'N' THEN
     l_Style := 'US_GLB';
  ELSIF l_Style = 'CA' THEN
      OPEN csr_chk_prod (c_leg_code       => p_HZ_Country
                        ,c_app_short_name => 'PAY');
     FETCH csr_chk_prod INTO l_leg_inst_rec;
     IF csr_chk_prod%NOTFOUND THEN
        l_Style := 'CA_GLB';
     END IF;
     CLOSE csr_chk_prod;
  ELSIF l_Style ='GB_GLB' THEN
     l_Style := 'GB';
  END IF;

  -- Check if Address Exists or Not. If function returns NULL, then it means
  -- address doesn't exist and return NULL
  IF Get_Concat_HR_Address(p_location_id
                          ,p_party_id
                          ,p_effective_date
                          ,p_business_group_id
                          ,p_primary_flag
                          ,p_party_site_id
                          ) IS NULL THEN
      RETURN NULL;
  ELSE
      RETURN l_Style;
  END IF;

END  Chk_Address_Style ;

-- =============================================================================
-- ~ Map_To_HR_Address:
-- =============================================================================
PROCEDURE Map_To_HR_Address
          (p_column_name     IN Varchar2
          ,p_column_value    IN Varchar2
          ,p_col_lookup_type IN Varchar2
          ,p_HR_Address_Rec  IN OUT NOCOPY Per_addresses%ROWTYPE
          ) AS

  l_proc_name          Varchar2(150);
  l_valid_col_value    Varchar2(150);

BEGIN
  IF p_column_name = 'ADDRESS_LINE1' THEN
      Check_HR_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_style           => p_HR_Address_Rec.Style
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HR_Address_Rec.Address_Line1 := l_valid_col_value;

  ELSIF p_column_name = 'ADDRESS_LINE2' THEN
      Check_HR_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_style           => p_HR_Address_Rec.Style
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Address_Line2 := l_valid_col_value;

  ELSIF p_column_name = 'ADDRESS_LINE3' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Address_Line3 := l_valid_col_value;

  ELSIF p_column_name = 'REGION_1' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Region_1 := l_valid_col_value;

  ELSIF p_column_name = 'REGION_2' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Region_2 := l_valid_col_value;

  ELSIF p_column_name = 'REGION_3' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Region_3 := l_valid_col_value;

  ELSIF p_column_name = 'TOWN_OR_CITY' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Town_or_City := l_valid_col_value;

  ELSIF p_column_name = 'POSTAL_CODE' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Postal_Code := l_valid_col_value;

  ELSIF p_column_name = 'COUNTRY' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.COUNTRY := l_valid_col_value;

  ELSIF p_column_name = 'POSTAL_CODE' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Postal_Code := l_valid_col_value;

  ELSIF p_column_name = 'DATE_FROM' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Date_From := Fnd_Date.Canonical_To_Date(l_valid_col_value);

  ELSIF p_column_name = 'DATE_TO' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Date_To := Fnd_Date.Canonical_To_Date(l_valid_col_value);

  ELSIF p_column_name = 'TELEPHONE_NUMBER_1' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Telephone_Number_1 := l_valid_col_value;

  ELSIF p_column_name = 'TELEPHONE_NUMBER_2' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Telephone_Number_2 := l_valid_col_value;

  ELSIF p_column_name = 'TELEPHONE_NUMBER_3' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.Telephone_Number_3 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION13' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information13 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION14' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information14 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION15' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information15 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION16' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information16 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION17' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information17 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION18' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information18 := l_valid_col_value;

  ELSIF p_column_name = 'ADD_INFORMATION19' THEN
     Check_HR_Validations
     (p_column_name     => p_column_name
     ,p_column_value    => p_column_value
     ,p_style           => p_HR_Address_Rec.Style
     ,p_col_lookup_type => p_col_lookup_type
     ,p_valid_col_value => l_valid_col_value);

     p_HR_Address_Rec.add_information19 := l_valid_col_value;

  END IF;

END Map_To_HR_Address;

-- =============================================================================
-- ~ Map_HR_Row_Values:
-- =============================================================================
PROCEDURE Map_HR_Row_Values
         (p_HR_Address_Rec  IN OUT NOCOPY Per_addresses%ROWTYPE
         ,p_HZ_Location_Row IN Hz_Locations%ROWTYPE
         ,p_add_map         IN Varchar2
         ,p_lookup_map      IN Varchar2
         ,p_leg_code        IN Varchar2
          ) AS
  CURSOR csr_phones (c_party_id IN Number) IS
  SELECT hcp.phone_country_code
        ,hcp.phone_area_code
        ,hcp.phone_number
        ,hcp.phone_extension
        ,hcp.primary_flag
        ,hcp.phone_line_type
    FROM hz_contact_points hcp
   WHERE hcp.contact_point_type = 'PHONE'
     AND hcp.status             = 'A'
     AND hcp.owner_table_name   = 'HZ_PARTIES'
     AND hcp.owner_table_id     = c_party_id;

  TYPE t_Phones IS TABLE OF hz_contact_points.phone_number%TYPE
     INDEX BY Binary_Integer;
  l_phone_rec              t_Phones;
  l_phone_no               hz_contact_points.phone_number%TYPE;
  l_Address_Mapping        pqp_configuration_values%ROWTYPE;
  l_LookUp_Mapping         pqp_configuration_values%ROWTYPE;
  ph_count                 Number(5);

BEGIN
   FOR i IN 1..3 LOOP
      l_phone_rec(i) := NULL;
   END LOOP;
   ph_count := 2;
   FOR ph_rec IN csr_phones(p_HR_Address_Rec.party_id)
   LOOP
     IF ph_rec.phone_country_code IS NOT NULL THEN
        l_phone_no := '+'|| ph_rec.phone_country_code;
     END IF;
     IF ph_rec.phone_area_code IS NOT NULL THEN
        l_phone_no := l_phone_no || ' ('||
                      ph_rec.phone_area_code ||')';
     END IF;
     IF ph_rec.phone_number IS NOT NULL THEN
        l_phone_no := l_phone_no || ' '||
                      ph_rec.phone_number;
     END IF;
     IF ph_rec.phone_extension IS NOT NULL THEN
        l_phone_no := l_phone_no || ' x '||
                      ph_rec.phone_extension;
     END IF;

     IF ph_rec.primary_flag ='Y' THEN
        l_phone_rec(1) := l_phone_no;
     ELSE
        l_phone_rec(ph_count) := l_phone_no;
        ph_count := ph_count + 1 ;
     END IF;
     l_phone_no := NULL;
     EXIT WHEN ph_count > 3;
   END LOOP;

   OPEN csr_TCA_Map (c_info_category   => p_add_map
                    ,c_bg_grp_id       => p_HR_Address_Rec.business_group_id
                    ,c_bg_grp_leg_code => p_HR_Address_Rec.Style);

  FETCH csr_TCA_Map INTO  l_Address_Mapping;
  CLOSE csr_TCA_Map;

  -- Get column Lookup mapping record from pqp_configuration_values table
   OPEN csr_TCA_Map (c_info_category   => p_lookup_map
                    ,c_bg_grp_id       => p_HR_Address_Rec.business_group_id
                    ,c_bg_grp_leg_code => p_HR_Address_Rec.Style);

  FETCH csr_TCA_Map INTO  l_LookUp_Mapping;
  CLOSE csr_TCA_Map;
  --Address1
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information1
  ,p_column_value    => p_HZ_Location_Row.Address1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information1
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Address2
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information2
  ,p_column_value    => p_HZ_Location_Row.Address2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information2
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Address3
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information3
  ,p_column_value    => p_HZ_Location_Row.Address3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information3
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Address4
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information4
  ,p_column_value    => p_HZ_Location_Row.Address4
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information4
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- City
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information5
  ,p_column_value    => p_HZ_Location_Row.City
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information5
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- State
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information6
  ,p_column_value    => p_HZ_Location_Row.State
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information6
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Province
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information7
  ,p_column_value    => p_HZ_Location_Row.Province
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information7
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- County
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information8
  ,p_column_value    => p_HZ_Location_Row.County
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information8
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Postal Code
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information9
  ,p_column_value    => p_HZ_Location_Row.Postal_Code
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information9
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Country
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information10
  ,p_column_value    => p_HZ_Location_Row.Country
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information10
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Primary Phone
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information18
  ,p_column_value    => l_phone_rec(1)
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information18
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Secondary Phone one
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information19
  ,p_column_value    => l_phone_rec(2)
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information19
  ,p_HR_Address_Rec  => p_HR_Address_Rec);
  -- Secondary Phone two
  Map_To_HR_Address
  (p_column_name     => l_Address_Mapping.pcv_information20
  ,p_column_value    => l_phone_rec(3)
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information20
  ,p_HR_Address_Rec  => p_HR_Address_Rec);

END Map_HR_Row_Values;

-- =============================================================================
-- ~ TCA_To_HR_Address:
-- =============================================================================
PROCEDURE  TCA_To_HR_Address
          (p_HZ_Location_Row   IN Hz_Locations%ROWTYPE
          ,p_Mapping_Type      IN Varchar2 DEFAULT 'TCA_TO_HR'
          ,p_HR_Address_Rec    IN OUT NOCOPY Per_addresses%ROWTYPE
           ) AS
  l_address_style   per_addresses.style%TYPE;
  l_add_map         Varchar2(150);
  l_lookup_map      Varchar2(150);
  l_leg_code        Varchar2(5);
BEGIN
  OPEN  csr_bg_code(p_HR_Address_Rec.Business_group_id);
  FETCH csr_bg_code INTO l_leg_code;
  CLOSE csr_bg_code;
  -- Get the appropiate HR Add. Style based on HZ country and bus. grp
  -- leg. code.
  l_address_style :=
   Chk_Address_Style
   (p_leg_code       => l_leg_code
   ,p_HZ_country     => p_HZ_Location_Row.Country);

  p_HR_Address_Rec.Style := l_address_style;

  l_add_map    := 'PQP_HRTCA_PERADD_'|| Trim(l_address_style);
  l_lookup_map := l_add_map||'_LOOKUP';

  Map_HR_Row_Values
  (p_HR_Address_Rec  => p_HR_Address_Rec
  ,p_HZ_Location_Row => p_HZ_Location_Row
  ,p_add_map         => l_add_map
  ,p_lookup_map      => l_lookup_map
  ,p_leg_code        => l_leg_code);

END TCA_To_HR_Address;

-- ===========================================================================
-- ~ ConCat_Segments:
-- ===========================================================================

PROCEDURE ConCat_Segments
          (p_HR_Address_Rec IN Per_addresses%ROWTYPE
          ,p_concat_string  OUT NOCOPY Varchar2
          ) AS

  CURSOR csr_delim IS
  SELECT concatenated_segment_delimiter
    FROM fnd_descriptive_flexs
   WHERE descriptive_flexfield_name = 'Address Structure'
     AND application_table_name     = 'PER_ADDRESSES'
     AND application_id             = 800;

  CURSOR csr_add_cols (c_context IN Varchar) IS
  SELECT fcu.column_seq_num
        ,fcu.application_column_name
        ,fcu.end_user_column_name
    FROM fnd_descr_flex_column_usages  fcu
   WHERE fcu.descriptive_flexfield_name    = 'Address Structure'
     AND fcu.descriptive_flex_context_code = c_context
     AND fcu.application_id                = 800
     AND fcu.enabled_flag                  = 'Y'
     ORDER BY fcu.column_seq_num;

  l_delimiter       Varchar2(15);
  l_rep_delimiter   Varchar2(15);

BEGIN
   -- Get the flexfield DDF's delimilter
    OPEN csr_delim;
   FETCH csr_delim INTO l_delimiter;
   CLOSE csr_delim;
   l_rep_delimiter := '\'||l_delimiter;

   -- First Seg. would be the DDF context i.e. Address style
   p_concat_string :=  REPLACE(p_HR_Address_Rec.Style
                                  ,l_delimiter
                                  ,l_rep_delimiter)|| l_delimiter;

   FOR add_rec IN csr_add_cols (p_HR_Address_Rec.style)
   LOOP

     IF add_rec.application_column_name = 'ADDRESS_LINE1' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Address_Line1
                                  ,l_delimiter
                                  ,l_rep_delimiter)|| l_delimiter;
     ELSIF add_rec.application_column_name = 'ADDRESS_LINE2' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Address_Line2
                                  ,l_delimiter
                                  ,l_rep_delimiter)|| l_delimiter;
     ELSIF add_rec.application_column_name = 'ADDRESS_LINE3' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Address_Line3
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;
     ELSIF add_rec.application_column_name = 'REGION_1' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Region_1
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;

     ELSIF add_rec.application_column_name = 'REGION_2' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Region_2
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;

     ELSIF add_rec.application_column_name = 'REGION_3' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Region_3
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;

     ELSIF add_rec.application_column_name = 'TOWN_OR_CITY' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Town_Or_City
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;
     ELSIF add_rec.application_column_name = 'POSTAL_CODE' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Postal_Code
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;

     ELSIF add_rec.application_column_name = 'COUNTRY' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Country
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;
     ELSIF add_rec.application_column_name = 'TELEPHONE_NUMBER_1' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Telephone_Number_1
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;
     ELSIF add_rec.application_column_name = 'TELEPHONE_NUMBER_2' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Telephone_Number_2
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;
     ELSIF add_rec.application_column_name = 'TELEPHONE_NUMBER_3' THEN
        p_concat_string := p_concat_string ||
                           REPLACE(p_HR_Address_Rec.Telephone_Number_3
                                  ,l_delimiter
                                  ,l_rep_delimiter) || l_delimiter;
     END IF;
   --
   END LOOP;


END ConCat_Segments;

-- =============================================================================
-- ~ Get_Concat_HR_Address:
-- =============================================================================
FUNCTION Get_Concat_HR_Address
        (p_location_id       IN Number
        ,p_party_id          IN Number
        ,p_effective_date    IN Date
        ,p_business_group_id IN Number
        ,p_primary_flag      IN Varchar2
        ,p_party_site_id     IN Number
         ) RETURN Varchar2 IS

  CURSOR csr_sd IS
  SELECT effective_date FROM fnd_sessions
   WHERE session_id = (SELECT Userenv('SESSIONID')
                         FROM dual);
  TYPE csr_oss_t  IS REF CURSOR;
  csr_dt             csr_oss_t;
  l_concat_add_string  Varchar2(1000);
  l_HZ_Loc_Row         Hz_Locations%ROWTYPE;
  l_HR_Address_Rec     Per_addresses%ROWTYPE;
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  l_effective_date     Date;
BEGIN
  -- Get the HZ Locations details based on the id
   OPEN csr_hz_loc (c_location_id => p_location_id);
  FETCH csr_hz_loc INTO l_HZ_Loc_Row;
  CLOSE csr_hz_loc;

  -- Assign the party id and bus. grp id to the address record.
  l_HR_Address_Rec.business_group_id := p_business_group_id;
  l_HR_Address_Rec.primary_flag      := Nvl(p_primary_flag,'Y');
  l_HR_Address_Rec.party_id          := p_party_id;
  g_effective_date                   := p_effective_date;

  -- Map the Address from TCA to HR
  TCA_To_HR_Address
   (p_HZ_Location_Row   => l_HZ_Loc_Row
   ,p_HR_Address_Rec    => l_HR_Address_Rec
   ,p_Mapping_Type      => 'TCA_TO_HR');

   OPEN csr_dt FOR g_adddt_sql
               Using p_party_id
                    ,p_location_id;
  FETCH csr_dt INTO l_HR_Address_Rec.Date_From,
                    l_HR_Address_Rec.Date_To,
                    l_HR_Address_Rec.Primary_Flag;

  -- If no address exists then function should return NULL
  IF csr_dt%NOTFOUND THEN
     CLOSE csr_dt;
     RETURN NULL;
  END IF;

  CLOSE csr_dt;

  -- Return the concat. string
  ConCat_Segments
   (p_HR_Address_Rec => l_HR_Address_Rec
   ,p_concat_string  => l_concat_add_string
    );

  RETURN l_concat_add_string;

EXCEPTION
  WHEN Others THEN
  l_concat_add_string := NULL;
  RETURN l_concat_add_string;

END Get_Concat_HR_Address;
-- =============================================================================
-- ~ Get_Segment:
-- =============================================================================
FUNCTION Get_Segment
        (p_hzlocation_id      IN Number
        ,p_party_id           IN Number
        ,p_business_group_id  IN Number
        ,p_seg_name           IN Varchar2
        ) RETURN Varchar2 AS

  TYPE csr_oss_t  IS REF CURSOR;
  csr_dt               csr_oss_t;
  l_HZ_Loc_Row         Hz_Locations%ROWTYPE;
  l_HR_Address_Rec     Per_addresses%ROWTYPE;
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  l_effective_date     Date;
  l_return_value       Varchar2(150);

BEGIN
    OPEN csr_hz_loc (c_location_id => p_hzlocation_id);
   FETCH csr_hz_loc INTO l_HZ_Loc_Row;
   CLOSE csr_hz_loc;

   -- Assign the party id and bus. grp id to the address record.
   l_HR_Address_Rec.business_group_id := p_business_group_id;
   l_HR_Address_Rec.party_id          := p_party_id;
   g_effective_date                   := Sysdate;

   -- Map the Address from TCA to HR
   TCA_To_HR_Address
    (p_HZ_Location_Row   => l_HZ_Loc_Row
    ,p_HR_Address_Rec    => l_HR_Address_Rec
    ,p_Mapping_Type      => 'TCA_TO_HR');

   OPEN csr_dt FOR g_adddt_sql
               Using p_party_id
                    ,p_hzlocation_id;
  FETCH csr_dt INTO l_HR_Address_Rec.Date_From,
                    l_HR_Address_Rec.Date_To,
                    l_HR_Address_Rec.Primary_Flag;
  CLOSE csr_dt;

  IF p_seg_name = 'PRIMARY_FLAG' THEN
     l_return_value := l_HR_Address_Rec.Primary_Flag;
  ELSIF p_seg_name = 'STYLE' THEN
     l_return_value := l_HR_Address_Rec.Style;
  ELSIF p_seg_name = 'ADDRESS_LINE1' THEN
     l_return_value := l_HR_Address_Rec.Address_Line1;
  ELSIF p_seg_name = 'ADDRESS_LINE2' THEN
     l_return_value := l_HR_Address_Rec.Address_Line2;
  ELSIF p_seg_name = 'ADDRESS_LINE3' THEN
     l_return_value := l_HR_Address_Rec.Address_Line3;
  ELSIF p_seg_name = 'REGION_1' THEN
     l_return_value := l_HR_Address_Rec.Region_1;
  ELSIF p_seg_name = 'REGION_2' THEN
     l_return_value := l_HR_Address_Rec.Region_2;
  ELSIF p_seg_name = 'REGION_3' THEN
     l_return_value := l_HR_Address_Rec.Region_3;
  ELSIF p_seg_name = 'TOWN_OR_CITY' THEN
     l_return_value := l_HR_Address_Rec.Town_Or_City;
  ELSIF p_seg_name = 'POSTAL_CODE' THEN
     l_return_value := l_HR_Address_Rec.Postal_Code;
  ELSIF p_seg_name = 'COUNTRY' THEN
     l_return_value := l_HR_Address_Rec.Country;
  ELSIF p_seg_name = 'TELEPHONE_NUMBER_1' THEN
     l_return_value := l_HR_Address_Rec.Telephone_Number_1;
  ELSIF p_seg_name = 'TELEPHONE_NUMBER_2' THEN
     l_return_value := l_HR_Address_Rec.Telephone_Number_2;
  ELSIF p_seg_name = 'TELEPHONE_NUMBER_3' THEN
     l_return_value := l_HR_Address_Rec.Telephone_Number_3;
  ELSIF p_seg_name = 'DATE_FROM' THEN
     l_return_value := l_HR_Address_Rec.Date_From;
  ELSIF p_seg_name = 'DATE_TO' THEN
     l_return_value := l_HR_Address_Rec.Date_To;
  END IF;

  RETURN l_return_value;
EXCEPTION
   WHEN OTHERS THEN
   l_return_value := NULL;
   RETURN l_return_value;
END Get_Segment;
-- =============================================================================
-- ~ Check_TCA_Validations:
-- =============================================================================
PROCEDURE Check_TCA_Validations
         (p_column_name     IN Varchar2
         ,p_column_value    IN Varchar2
         ,p_col_lookup_type IN Varchar2
         ,p_valid_col_value OUT NOCOPY Varchar2) AS


  l_proc_name     CONSTANT Varchar2(150) := g_pkg ||'Check_TCA_Validations';
  l_lookup_rec    csr_meaning_code%ROWTYPE;

BEGIN
  p_valid_col_value := p_column_value;
  --
  IF p_col_lookup_type IS NOT NULL THEN
     -- Check if the meaning is being passed
     OPEN csr_meaning_code
          (c_lookup_type    => p_col_lookup_type
          ,c_meaning        => p_column_value
          ,c_effective_date => g_effective_date);

    FETCH csr_meaning_code INTO l_lookup_rec;
    IF csr_meaning_code%FOUND THEN
       CLOSE csr_meaning_code;
       p_valid_col_value :=  l_lookup_rec.meaning;
       RETURN;
    END IF;
    CLOSE csr_meaning_code;
  END IF;

EXCEPTION
  WHEN Others THEN
  RAISE;
END Check_TCA_Validations;

-- =============================================================================
-- ~ Map_To_TCA_Address:
-- =============================================================================
PROCEDURE Map_To_TCA_Address
         (p_column_name     IN Varchar2
         ,p_column_value    IN Varchar2
         ,p_col_lookup_type IN Varchar2
         ,p_HZ_Location_Row IN OUT NOCOPY Hz_Locations%ROWTYPE
         ) AS

  l_valid_col_value    Varchar2(150);
  l_proc_name CONSTANT   Varchar2(150) := g_pkg ||'Map_To_TCA_Address';
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  Hr_Utility.set_location('..p_column_name    : '||p_column_name, 6);
  Hr_Utility.set_location('..p_column_value   : '||p_column_value, 6);
  Hr_Utility.set_location('..p_col_lookup_type: '||p_col_lookup_type, 6);

  IF p_column_name IS NULL THEN
     RETURN;
  ELSIF p_column_name = 'ADDRESS1' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Address1 := l_valid_col_value;

  ELSIF p_column_name = 'ADDRESS2' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Address2 := l_valid_col_value;

  ELSIF p_column_name = 'ADDRESS3' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Address3 := l_valid_col_value;

  ELSIF p_column_name = 'ADDRESS4' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Address4 := l_valid_col_value;

  ELSIF p_column_name = 'CITY' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.City := l_valid_col_value;

  ELSIF p_column_name = 'POSTAL_CODE' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Postal_Code := l_valid_col_value;

  ELSIF p_column_name = 'STATE' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.State := l_valid_col_value;

  ELSIF p_column_name = 'PROVINCE' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Province := l_valid_col_value;

  ELSIF p_column_name = 'COUNTY' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.County := l_valid_col_value;

  ELSIF p_column_name = 'COUNTRY' THEN
      Check_TCA_Validations
      (p_column_name     => p_column_name
      ,p_column_value    => p_column_value
      ,p_col_lookup_type => p_col_lookup_type
      ,p_valid_col_value => l_valid_col_value);

       p_HZ_Location_Row.Country := l_valid_col_value;

  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
END Map_To_TCA_Address;

-- =============================================================================
-- Create_Address_HR_To_TCA:
-- =============================================================================
PROCEDURE Create_Address_HR_To_TCA
         (p_business_group_id      IN Number
         ,p_person_id              IN Number
         ,p_party_id               IN Number
         ,p_address_id             IN Number
         ,p_effective_date         IN Date
         ,p_per_addr_rec_new       IN per_addresses%ROWTYPE
         -- TCA
         ,p_party_type             IN Varchar2
         ,p_action                 IN Varchar2
         ,p_status                 IN hz_party_sites.status%TYPE
         -- In Out Variables
         ,p_location_id            IN OUT NOCOPY Number
         ,p_party_site_id          IN OUT NOCOPY Number
         ,p_last_update_date       IN OUT NOCOPY Date
         ,p_party_site_ovn         IN OUT NOCOPY Number
         ,p_location_ovn           IN OUT NOCOPY Number
         ,p_rowid                  IN OUT NOCOPY Varchar2
         -- Out Variables
         ,p_return_status          OUT NOCOPY Varchar2
         ,p_msg_data               OUT NOCOPY Varchar2
         ) AS

  l_proc_name  CONSTANT  Varchar2(150):= g_pkg ||'Create_Address_HR_To_TCA';
  l_HZ_Location_Row      Hz_Locations%ROWTYPE;
  l_HR_Address_Rec       Per_addresses%ROWTYPE;
  l_address_style        per_addresses.style%TYPE;
  l_Address_Mapping      pqp_configuration_values%ROWTYPE;
  l_LookUp_Mapping       pqp_configuration_values%ROWTYPE;
  l_add_map              Varchar2(150);
  l_lookup_map           Varchar2(150);
  l_leg_code             Varchar2(5);

  PLSQL_Block            Varchar2(2500);
  l_HZ_style             Varchar2(50);
  l_other_details_1      Varchar2(150);
  l_other_details_2      Varchar2(150);
  l_other_details_3      Varchar2(150);
  e_oss_add_failure      EXCEPTION;
  l_error_msg            Varchar2(2000);
  --
BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  -- Get the Person HR Address
  l_HR_Address_Rec := p_per_addr_rec_new;

  -- Get the business group's Leg. Code
  OPEN  csr_bg_code(l_HR_Address_Rec.Business_group_id);
  FETCH csr_bg_code INTO l_leg_code;
  CLOSE csr_bg_code;
  Hr_Utility.set_location('..l_leg_code : '||l_leg_code, 5);
  --
  l_add_map    := 'PQP_HRTCA_TCAADD_'|| l_HR_Address_Rec.Style;
  l_lookup_map := l_add_map||'_LOOKUP';
  Hr_Utility.set_location('..l_add_map    : '||l_add_map, 5);
  Hr_Utility.set_location('..l_lookup_map : '||l_lookup_map, 5);
  -- Get the Address Column mappings for context: PER_TCA_ADD_[XX]
   OPEN csr_TCA_Map
        (c_info_category   => l_add_map
        ,c_bg_grp_id       => l_HR_Address_Rec.business_group_id
        ,c_bg_grp_leg_code => l_HR_Address_Rec.Style);

  FETCH csr_TCA_Map INTO  l_Address_Mapping;
  IF csr_TCA_Map%NOTFOUND THEN
    Hr_Utility.set_location('..Mapping for rec not found for : '||l_add_map, 5);
  END IF;
  CLOSE csr_TCA_Map;

  -- Get Column Lookup mapping record for context: PER_TCA_ADD_[XX]_LOOKUP
   OPEN csr_TCA_Map
        (c_info_category   => l_lookup_map
        ,c_bg_grp_id       => l_HR_Address_Rec.business_group_id
        ,c_bg_grp_leg_code => l_HR_Address_Rec.Style);

  FETCH csr_TCA_Map INTO  l_LookUp_Mapping;
  IF csr_TCA_Map%NOTFOUND THEN
    Hr_Utility.set_location('..Mapping for rec not found for : '||l_lookup_map, 5);
  END IF;
  CLOSE csr_TCA_Map;
  -- HR: Address Line1
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information1
  ,p_column_value    => l_HR_Address_Rec.Address_Line1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information1
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Line2
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information2
  ,p_column_value    => l_HR_Address_Rec.Address_Line2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information2
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Line3
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information3
  ,p_column_value    => l_HR_Address_Rec.Address_Line3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information3
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Region 1
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information4
  ,p_column_value    => l_HR_Address_Rec.Region_1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information4
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Region 2
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information5
  ,p_column_value    => l_HR_Address_Rec.Region_2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information5
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Region 3
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information6
  ,p_column_value    => l_HR_Address_Rec.Region_3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information6
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Town Or City
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information7
  ,p_column_value    => l_HR_Address_Rec.town_or_city
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information7
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Postal Code
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information8
  ,p_column_value    => l_HR_Address_Rec.postal_code
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information8
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Country
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information9
  ,p_column_value    => l_HR_Address_Rec.Country
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information9
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Date From
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information10
  ,p_column_value    => l_HR_Address_Rec.Date_From
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information10
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Date To
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information11
  ,p_column_value    => l_HR_Address_Rec.Date_to
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information11
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information13
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information12
  ,p_column_value    => l_HR_Address_Rec.Add_Information13
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information12
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information14
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information13
  ,p_column_value    => l_HR_Address_Rec.Add_Information14
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information13
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information15
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information14
  ,p_column_value    => l_HR_Address_Rec.Add_Information15
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information14
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information16
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information15
  ,p_column_value    => l_HR_Address_Rec.Add_Information16
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information15
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information17
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information16
  ,p_column_value    => l_HR_Address_Rec.Add_Information17
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information16
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information18
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information17
  ,p_column_value    => l_HR_Address_Rec.Add_Information18
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information17
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Telephone Number 1
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information18
  ,p_column_value    => l_HR_Address_Rec.Telephone_Number_1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information18
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Telephone Number 2
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information19
  ,p_column_value    => l_HR_Address_Rec.Telephone_Number_2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information19
  ,p_HZ_Location_Row => l_HZ_Location_Row);
  -- HR: Telephone Number 3
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information20
  ,p_column_value    => l_HR_Address_Rec.Telephone_Number_3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information20
  ,p_HZ_Location_Row => l_HZ_Location_Row);
  Hr_Utility.set_location('..Call OSS Package : Igs_Pe_Person_Addr_Pkg.Insert_Row', 5);
  -- Call OSS API to create Student address in HZ
  PLSQL_Block :=
  'BEGIN  '||
  'Igs_Pe_Person_Addr_Pkg.Insert_Row   '||
  '(p_action                 => :p_action  '||
  ',p_party_type             => :p_party_type  '||
  ',p_party_id               => :p_party_Id  '||
  ',p_status                 => :p_status  '||
  ',p_start_dt               => :p_date_from  '||
  ',p_end_dt                 => :p_date_to  '||
  ',p_country                => :p_country  '||
  ',p_address_style          => :p_address_style  '||
  ',p_addr_line_1            => :p_Address1  '||
  ',p_addr_line_2            => :p_Address2  '||
  ',p_addr_line_3            => :p_Address3  '||
  ',p_addr_line_4            => :p_Address4  '||
  ',p_date_last_verified     => :p_effective_date  '||
  ',p_correspondence         => :p_correspondence  '||
  ',p_city                   => :p_city  '||
  ',p_state                  => :p_state  '||
  ',p_province               => :p_province  '||
  ',p_county                 => :p_county  '||
  ',p_postal_code            => :p_postal_code  '||
  ',p_address_lines_phonetic => :p_Address_Lines_Phonetic  '||
  ',p_delivery_point_code    => :p_Delivery_Point_Code  '||
  ',p_other_details_1        => :p_other_details_1  '||
  ',p_other_details_2        => :p_other_details_2  '||
  ',p_other_details_3        => :p_other_details_3  '||
   -- In Out
  ',p_party_site_id          => :p_party_site_id  '||
  ',p_last_update_date       => :p_last_update_date  '||
  ',p_party_site_ovn         => :p_party_site_ovn  '||
  ',p_location_ovn           => :p_location_ovn  '||
   -- Out
  ',p_rowid                  => :p_rowid  '||
  ',p_location_id            => :p_location_id  '||
  ',l_return_status          => :p_return_status  '||
  ',l_msg_data               => :p_msg_data  '||
  ' );  '||
  'END;';

  EXECUTE IMMEDIATE PLSQL_Block
          Using p_action
               ,p_party_type
               ,p_party_Id
               ,p_status
               ,l_HR_Address_Rec.Date_From
               ,l_HR_Address_Rec.Date_To
               ,l_HZ_Location_Row.Country
               ,l_HZ_style
               ,l_HZ_Location_Row.Address1
               ,l_HZ_Location_Row.Address2
               ,l_HZ_Location_Row.Address3
               ,l_HZ_Location_Row.Address4
               ,p_effective_date
               ,'Y'
               ,l_HZ_Location_Row.City
               ,l_HZ_Location_Row.State
               ,l_HZ_Location_Row.Province
               ,l_HZ_Location_Row.County
               ,l_HZ_Location_Row.Postal_Code
               ,l_HZ_Location_Row.Address_Lines_Phonetic
               ,l_HZ_Location_Row.Delivery_Point_Code
               ,l_other_details_1
               ,l_other_details_2
               ,l_other_details_3
                -- In Out
               ,IN OUT p_party_site_id
               ,IN OUT p_last_update_date
               ,IN OUT p_party_site_ovn
               ,IN OUT p_location_ovn
               ,IN OUT p_rowid
               ,IN OUT p_location_id
                -- Out
               ,OUT p_return_status
               ,OUT p_msg_data;
  IF p_return_status IN ('E','U') THEN
     RAISE e_oss_add_failure;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);

EXCEPTION
  WHEN e_oss_add_failure THEN
    l_error_msg := Substrb(p_msg_data,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;

  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;

END Create_Address_HR_To_TCA;
-- =============================================================================
-- ~ Update_Address_HR_To_TCA
-- =============================================================================
PROCEDURE Update_Address_HR_To_TCA
         (p_business_group_id      IN Number
         ,p_person_id              IN Number
         ,p_party_id               IN Number
         ,p_address_id             IN Number
         ,p_effective_date         IN Date
         ,p_per_addr_rec_new       IN per_addresses%ROWTYPE
         ,p_per_addr_rec_old       IN per_addresses%ROWTYPE
          -- TCA
         ,p_party_type             IN Varchar2
         ,p_action                 IN Varchar2
         ,p_status                 IN Varchar2
          -- In Out Variables
         ,p_location_id            IN OUT NOCOPY Number
         ,p_party_site_id          IN OUT NOCOPY  Number
         ,p_last_update_date       IN OUT NOCOPY Date
         ,p_party_site_ovn         IN OUT NOCOPY Number
         ,p_location_ovn           IN OUT NOCOPY Number
         ,p_rowid                  IN OUT NOCOPY Varchar2
          -- Out Variables
         ,p_return_status          OUT NOCOPY Varchar2
         ,p_msg_data               OUT NOCOPY Varchar2
         ) AS
   -- Cursor to get the current Primary Location
   CURSOR csr_hz_loc(c_hz_location_id IN Number) IS
   SELECT hzl.*
     FROM hz_locations hzl
    WHERE hzl.location_id = c_hz_location_id;

  l_proc_name CONSTANT   Varchar2(150) := g_pkg ||'Update_Address_HR_To_TCA';
  l_HZ_Location_Row      Hz_Locations%ROWTYPE;
  l_HZ_Location_Cur_Row  Hz_Locations%ROWTYPE;
  l_HR_Address_Rec       Per_addresses%ROWTYPE;
  l_address_style        per_addresses.style%TYPE;
  l_Address_Mapping      pqp_configuration_values%ROWTYPE;
  l_LookUp_Mapping       pqp_configuration_values%ROWTYPE;
  --
  l_add_map              Varchar2(150);
  l_lookup_map           Varchar2(150);
  l_leg_code             Varchar2(5);
  PLSQL_Block            Varchar2(2500);
  l_HZ_style             Varchar2(50);
  l_other_details_1      Varchar2(150);
  l_other_details_2      Varchar2(150);
  l_other_details_3      Varchar2(150);
  --
  l_OSS_Date_From        Date;
  l_OSS_Date_To          Date;
  l_OS_Primary_Flag      Varchar2(5);

  TYPE csr_party_addt  IS REF CURSOR;
   csr_party_add         csr_party_addt;

  TYPE csr_oss_t  IS REF CURSOR;
   csr_dt                 csr_oss_t;

  l_update_pri_add       Boolean;
  l_create_pri_add       Boolean;
  --
  e_oss_add_failure      EXCEPTION;
  l_error_msg            Varchar2(2000);

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  -- Get the Person HR Address
  l_HR_Address_Rec := p_per_addr_rec_new;
  g_effective_date := p_effective_date;
  --
  IF p_location_id IS NULL THEN
     Hr_Utility.set_location('..Dyn SQL to get ovn of location and site', 6);
     OPEN  csr_party_add FOR g_hz_add_sql
                         Using l_HR_Address_Rec.party_id;
     FETCH csr_party_add INTO
           p_location_id
          ,p_party_site_id
          ,p_last_update_date
          ,p_party_site_ovn
          ,p_location_ovn
          ,p_rowid;
     Hr_Utility.set_location('..After Fetch of Dyn SQL.', 6);
     IF csr_party_add%NOTFOUND THEN
        Hr_Utility.set_location('..Cannot find existing party primary address', 7);
        CLOSE csr_party_add;
     ELSE
        Hr_Utility.set_location('..Dyn SQL found loc record', 7);
        CLOSE csr_party_add;

         OPEN csr_hz_loc(c_hz_location_id => p_location_id);
        FETCH csr_hz_loc INTO l_HZ_Location_Cur_Row;
        CLOSE csr_hz_loc;
        Hr_Utility.set_location('..Dyn SQL against OSS to get start date', 8);
         OPEN csr_dt FOR g_adddt_sql
                     Using l_HR_Address_Rec.party_id
                          ,p_location_id;
        FETCH csr_dt INTO l_OSS_Date_From,
                          l_OSS_Date_To,
                          l_OS_Primary_Flag;
        CLOSE csr_dt;
        IF l_HR_Address_Rec.Date_From BETWEEN
           NVL(l_OSS_Date_From,l_HR_Address_Rec.Date_From) AND
           Nvl(l_OSS_Date_To,To_Date('31/12/4712','DD/MM/YYYY'))  THEN
           l_update_pri_add := TRUE;
        ELSE
           l_create_pri_add   := TRUE;
           p_location_id      := NULL;
           p_party_site_id    := NULL;
           p_last_update_date := NULL;
           p_party_site_ovn   := NULL;
           p_location_ovn     := NULL;
           p_rowid            := NULL;

        END IF;
     END IF;

  END IF;
  --
  Hr_Utility.set_location('..p_effective_date : '||p_effective_date, 8);
  -- Get the business group's Leg. Code
  OPEN  csr_bg_code(l_HR_Address_Rec.Business_group_id);
  FETCH csr_bg_code INTO l_leg_code;
  IF csr_bg_code%NOTFOUND THEN
     Hr_Utility.set_location('..Leg Code not found for Id : '||
                              l_HR_Address_Rec.Business_group_id,5);
  END IF;
  CLOSE csr_bg_code;
  --
  Hr_Utility.set_location('..Bus Grp Leg Code: '||l_leg_code, 6);
  l_add_map    := 'PQP_HRTCA_TCAADD_'|| l_HR_Address_Rec.Style;
  l_lookup_map := l_add_map||'_LOOKUP';

  Hr_Utility.set_location('..l_add_map   : '||l_add_map, 7);
  Hr_Utility.set_location('..l_lookup_map: '||l_lookup_map,7);
  -- Get the Address Column mappings for context: PQP_HRTCA_TCAADD_[XX]
  OPEN  csr_TCA_Map
        (c_info_category   => l_add_map
        ,c_bg_grp_id       => l_HR_Address_Rec.business_group_id
        ,c_bg_grp_leg_code => l_HR_Address_Rec.Style);

  FETCH csr_TCA_Map INTO  l_Address_Mapping;
  IF csr_TCA_Map%NOTFOUND THEN
     Hr_Utility.set_location('..Mapping rec. not found for : '||l_add_map,8);
  END IF;
  CLOSE csr_TCA_Map;

  -- Get Column Lookup mapping record for context: PQP_HRTCA_TCAADD_[XX]_LOOKUP
   OPEN csr_TCA_Map
        (c_info_category   => l_lookup_map
        ,c_bg_grp_id       => l_HR_Address_Rec.business_group_id
        ,c_bg_grp_leg_code => l_HR_Address_Rec.Style);

  FETCH csr_TCA_Map INTO  l_LookUp_Mapping;
  IF csr_TCA_Map%NOTFOUND THEN
     Hr_Utility.set_location('..Mapping rec. not found for : '||l_lookup_map,8);
  END IF;

  CLOSE csr_TCA_Map;
  -- HR: Address Line1
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information1
  ,p_column_value    => l_HR_Address_Rec.Address_Line1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information1
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Line2
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information2
  ,p_column_value    => l_HR_Address_Rec.Address_Line2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information2
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Line3
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information3
  ,p_column_value    => l_HR_Address_Rec.Address_Line3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information3
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Region 1
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information4
  ,p_column_value    => l_HR_Address_Rec.Region_1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information4
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Region 2
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information5
  ,p_column_value    => l_HR_Address_Rec.Region_2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information5
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Region 3
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information6
  ,p_column_value    => l_HR_Address_Rec.Region_3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information6
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Town Or City
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information7
  ,p_column_value    => l_HR_Address_Rec.town_or_city
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information7
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Postal Code
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information8
  ,p_column_value    => l_HR_Address_Rec.postal_code
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information8
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Country
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information9
  ,p_column_value    => l_HR_Address_Rec.Country
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information9
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Date From
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information10
  ,p_column_value    => l_HR_Address_Rec.Date_From
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information10
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Address Date To
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information11
  ,p_column_value    => l_HR_Address_Rec.Date_to
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information11
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information13
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information12
  ,p_column_value    => l_HR_Address_Rec.Add_Information13
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information12
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information14
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information13
  ,p_column_value    => l_HR_Address_Rec.Add_Information14
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information13
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information15
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information14
  ,p_column_value    => l_HR_Address_Rec.Add_Information15
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information14
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information16
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information15
  ,p_column_value    => l_HR_Address_Rec.Add_Information16
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information15
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information17
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information16
  ,p_column_value    => l_HR_Address_Rec.Add_Information17
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information16
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Add Information18
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information17
  ,p_column_value    => l_HR_Address_Rec.Add_Information18
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information17
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Telephone Number 1
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information18
  ,p_column_value    => l_HR_Address_Rec.Telephone_Number_1
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information18
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- HR: Telephone Number 2
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information19
  ,p_column_value    => l_HR_Address_Rec.Telephone_Number_2
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information19
  ,p_HZ_Location_Row => l_HZ_Location_Row);
  -- HR: Telephone Number 3
  Map_To_TCA_Address
  (p_column_name     => l_Address_Mapping.pcv_information20
  ,p_column_value    => l_HR_Address_Rec.Telephone_Number_3
  ,p_col_lookup_type => l_LookUp_Mapping.pcv_information20
  ,p_HZ_Location_Row => l_HZ_Location_Row);

  -- Call OSS API to update Student address in HZ
  Hr_Utility.set_location('..Calling OSS API : Igs_Pe_Person_Addr_Pkg.Update_Row',8);
  IF l_update_pri_add THEN
      PLSQL_Block :=
      'BEGIN  ' ||
      'Igs_Pe_Person_Addr_Pkg.Update_Row ' ||
      '(p_action                 => :p_action ' ||
      ',p_party_type             => :p_party_type ' ||
      ',p_party_id               => :p_party_id ' ||
      ',p_status                 => :p_status ' ||
      ',p_start_dt               => :p_Date_From ' ||
      ',p_end_dt                 => :p_Date_To ' ||
      ',p_country                => :p_Country ' ||
      ',p_address_style          => :p_hz_address_style ' ||
      ',p_addr_line_1            => :p_Address1 ' ||
      ',p_addr_line_2            => :p_Address2 ' ||
      ',p_addr_line_3            => :p_Address3 ' ||
      ',p_addr_line_4            => :p_Address4 ' ||
      ',p_date_last_verified     => :p_effective_date ' ||
      ',p_correspondence         => :p_correspondence ' ||
      ',p_city                   => :p_City ' ||
      ',p_state                  => :p_State ' ||
      ',p_province               => :p_Province ' ||
      ',p_county                 => :p_County ' ||
      ',p_postal_code            => :p_Postal_Code ' ||
      ',p_address_lines_phonetic => :p_Address_Lines_Phonetic ' ||
      ',p_delivery_point_code    => :p_Delivery_Point_Code ' ||
      ',p_other_details_1        => :p_other_details_1 ' ||
      ',p_other_details_2        => :p_other_details_2 ' ||
      ',p_other_details_3        => :p_other_details_3 ' ||
       -- In Out
      ',p_party_site_id          => :p_party_site_id ' ||
      ',p_last_update_date       => :p_last_update_date ' ||
      ',p_party_site_ovn         => :p_party_site_ovn ' ||
      ',p_location_ovn           => :p_location_ovn ' ||
      ',p_rowid                  => :p_rowid ' ||
      ',p_location_id            => :p_location_id ' ||
       -- Out
      ',l_return_status          => :p_return_status ' ||
      ',l_msg_data               => :p_msg_data ' ||
      '); ' ||
      'End;';
      EXECUTE IMMEDIATE PLSQL_Block
              Using p_action
                   ,p_party_type
                   ,p_party_Id
                   ,p_status
                   ,l_HR_Address_Rec.Date_From
                   ,l_HR_Address_Rec.Date_To
                   ,l_HZ_Location_Row.Country
                   ,l_HZ_style
                   ,l_HZ_Location_Row.Address1
                   ,l_HZ_Location_Row.Address2
                   ,l_HZ_Location_Row.Address3
                   ,l_HZ_Location_Row.Address4
                   ,p_effective_date
                   ,'Y'
                   ,l_HZ_Location_Row.City
                   ,l_HZ_Location_Row.State
                   ,l_HZ_Location_Row.Province
                   ,l_HZ_Location_Row.County
                   ,l_HZ_Location_Row.Postal_Code
                   ,l_HZ_Location_Row.Address_Lines_Phonetic
                   ,l_HZ_Location_Row.Delivery_Point_Code
                   ,l_other_details_1
                   ,l_other_details_2
                   ,l_other_details_3
                    -- In Out
                   ,IN OUT p_party_site_id
                   ,IN OUT p_last_update_date
                   ,IN OUT p_party_site_ovn
                   ,IN OUT p_location_ovn
                   ,IN OUT p_rowid
                   ,IN OUT p_location_id
                    -- Out
                   ,OUT p_return_status
                   ,OUT p_msg_data;
  END IF;
  IF l_create_pri_add THEN
      Hr_Utility.set_location('..Call OSS Package : Igs_Pe_Person_Addr_Pkg.Insert_Row', 8);
      -- Call OSS API to create Student address in HZ
      PLSQL_Block :=
      'BEGIN  '||
      'Igs_Pe_Person_Addr_Pkg.Insert_Row   '||
      '(p_action                 => :p_action  '||
      ',p_party_type             => :p_party_type  '||
      ',p_party_id               => :p_party_Id  '||
      ',p_status                 => :p_status  '||
      ',p_start_dt               => :p_date_from  '||
      ',p_end_dt                 => :p_date_to  '||
      ',p_country                => :p_country  '||
      ',p_address_style          => :p_address_style  '||
      ',p_addr_line_1            => :p_Address1  '||
      ',p_addr_line_2            => :p_Address2  '||
      ',p_addr_line_3            => :p_Address3  '||
      ',p_addr_line_4            => :p_Address4  '||
      ',p_date_last_verified     => :p_effective_date  '||
      ',p_correspondence         => :p_correspondence  '||
      ',p_city                   => :p_city  '||
      ',p_state                  => :p_state  '||
      ',p_province               => :p_province  '||
      ',p_county                 => :p_county  '||
      ',p_postal_code            => :p_postal_code  '||
      ',p_address_lines_phonetic => :p_Address_Lines_Phonetic  '||
      ',p_delivery_point_code    => :p_Delivery_Point_Code  '||
      ',p_other_details_1        => :p_other_details_1  '||
      ',p_other_details_2        => :p_other_details_2  '||
      ',p_other_details_3        => :p_other_details_3  '||
       -- In Out
      ',p_party_site_id          => :p_party_site_id  '||
      ',p_last_update_date       => :p_last_update_date  '||
      ',p_party_site_ovn         => :p_party_site_ovn  '||
      ',p_location_ovn           => :p_location_ovn  '||
       -- Out
      ',p_rowid                  => :p_rowid  '||
      ',p_location_id            => :p_location_id  '||
      ',l_return_status          => :p_return_status  '||
      ',l_msg_data               => :p_msg_data  '||
      ' );  '||
      'END;';

      EXECUTE IMMEDIATE PLSQL_Block
              Using p_action
                   ,p_party_type
                   ,p_party_Id
                   ,p_status
                   ,l_HR_Address_Rec.Date_From
                   ,l_HR_Address_Rec.Date_To
                   ,l_HZ_Location_Row.Country
                   ,l_HZ_style
                   ,l_HZ_Location_Row.Address1
                   ,l_HZ_Location_Row.Address2
                   ,l_HZ_Location_Row.Address3
                   ,l_HZ_Location_Row.Address4
                   ,p_effective_date
                   ,'Y'
                   ,l_HZ_Location_Row.City
                   ,l_HZ_Location_Row.State
                   ,l_HZ_Location_Row.Province
                   ,l_HZ_Location_Row.County
                   ,l_HZ_Location_Row.Postal_Code
                   ,l_HZ_Location_Row.Address_Lines_Phonetic
                   ,l_HZ_Location_Row.Delivery_Point_Code
                   ,l_other_details_1
                   ,l_other_details_2
                   ,l_other_details_3
                    -- In Out
                   ,IN OUT p_party_site_id
                   ,IN OUT p_last_update_date
                   ,IN OUT p_party_site_ovn
                   ,IN OUT p_location_ovn
                   ,IN OUT p_rowid
                   ,IN OUT p_location_id
                    -- Out
                   ,OUT p_return_status
                   ,OUT p_msg_data;
  END IF;
  IF p_return_status IN ('E','U') THEN
     RAISE e_oss_add_failure;
  END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);
EXCEPTION
  WHEN e_oss_add_failure THEN
    l_error_msg := Substrb(p_msg_data,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
    Hr_Utility.raise_error;

  WHEN Others THEN
    l_error_msg := Substrb(SQLERRM,1,2000);
    Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
    Hr_Utility.set_location('Leaving: '||l_proc_name, 91);
    Hr_Utility.raise_error;

END Update_Address_HR_To_TCA;

END PQP_HRTCA_Integration;

/
