--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_API" as
/* $Header: irhzpapi.pkb 120.30.12010000.24 2010/05/17 08:33:06 vmummidi ship $ */
--Package Variables
--
g_package varchar2(33) := 'irc_party_api.';
--
-- -------------------------------------------------------------------------
-- |------------------------< create_candidate_internal >------------------|
-- -------------------------------------------------------------------------
--
procedure create_candidate_internal
   (p_validate                  IN     boolean  default false
   ,p_business_group_id         IN     number
   ,p_last_name                 IN     varchar2
   ,p_first_name                IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_title                     IN     varchar2 default null
   ,p_gender                    IN     varchar2 default null
   ,p_marital_status            IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_middle_name               IN     varchar2 default null
   ,p_name_suffix               IN     varchar2 default null
   ,p_known_as                  IN     varchar2 default null
   ,p_first_name_phonetic       IN     varchar2 default null
   ,p_last_name_phonetic        IN     varchar2 default null
   ,p_attribute_category        IN     varchar2 default null
   ,p_attribute1                IN     varchar2 default null
   ,p_attribute2                IN     varchar2 default null
   ,p_attribute3                IN     varchar2 default null
   ,p_attribute4                IN     varchar2 default null
   ,p_attribute5                IN     varchar2 default null
   ,p_attribute6                IN     varchar2 default null
   ,p_attribute7                IN     varchar2 default null
   ,p_attribute8                IN     varchar2 default null
   ,p_attribute9                IN     varchar2 default null
   ,p_attribute10               IN     varchar2 default null
   ,p_attribute11               IN     varchar2 default null
   ,p_attribute12               IN     varchar2 default null
   ,p_attribute13               IN     varchar2 default null
   ,p_attribute14               IN     varchar2 default null
   ,p_attribute15               IN     varchar2 default null
   ,p_attribute16               IN     varchar2 default null
   ,p_attribute17               IN     varchar2 default null
   ,p_attribute18               IN     varchar2 default null
   ,p_attribute19               IN     varchar2 default null
   ,p_attribute20               IN     varchar2 default null
   ,p_attribute21               IN     varchar2 default null
   ,p_attribute22               IN     varchar2 default null
   ,p_attribute23               IN     varchar2 default null
   ,p_attribute24               IN     varchar2 default null
   ,p_attribute25               IN     varchar2 default null
   ,p_attribute26               IN     varchar2 default null
   ,p_attribute27               IN     varchar2 default null
   ,p_attribute28               IN     varchar2 default null
   ,p_attribute29               IN     varchar2 default null
   ,p_attribute30               IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_nationality               IN     varchar2  default null
   ,p_national_identifier       IN     varchar2  default null
   ,p_town_of_birth             IN     varchar2  default null
   ,p_region_of_birth           IN     varchar2  default null
   ,p_country_of_birth          IN     varchar2  default null
   ,p_allow_access              IN     varchar2 default null
   ,p_party_id                  IN     number default null
   ,p_start_date                IN     date default null
   ,p_effective_start_date      OUT NOCOPY date
   ,p_effective_end_date        OUT NOCOPY date
   ,p_person_id                 OUT NOCOPY number) IS
--
l_proc          varchar2(72) := g_package||'create_candidate_internal';
l_person_id      PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
l_date_of_birth per_all_people_f.date_of_birth%type;
l_business_group_id per_all_people_f.business_group_id%type;
l_person_type_id per_all_people_f.person_type_id%type;
l_last_name_phonetic       hz_person_profiles.person_last_name_phonetic%type
                           := p_last_name_phonetic;
--
-- dummy variables
--
l_object_version_number    per_all_people_f.object_version_number%type;
l_effective_start_date     per_all_people_f.effective_start_date%type;
l_effective_end_date       per_all_people_f.effective_end_date%type;
l_full_name                per_all_people_f.full_name%type;
l_comment_id               per_all_people_f.comment_id%type;
l_name_combination_warning boolean;
l_orig_hire_warning        boolean;
l_assign_payroll_warning   boolean;
l_legislation_code         per_business_groups_perf.legislation_code%type;
l_ptu_person_type_id       number(15);
l_employee_number          per_all_people_f.employee_number%type := hr_api.g_varchar2;
--
-- for disabling the descriptive flex field
  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
--
-- cursor to select the legislation from per_business_groups_perf
-- corresponding to the business group
--
cursor csr_legislation_code(p_business_group_id number) is
select legislation_code
from per_business_groups_perf
where business_group_id = p_business_group_id;
--
-- cursor to select the person_type_id from hr_organization_inforamtion
-- corresponding to the recruiting flexfield on the business group
--
cursor csr_get_person_type_id(p_business_group_id number) is
select org_information8
from hr_organization_information
where organization_id=p_business_group_id
and ORG_INFORMATION_CONTEXT='BG Recruitment';
--
l_notification_preference_id number;
l_search_criteria_id number;
--
l_start_date date;
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CANDIDATE_INTERNAL;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_of_birth := trunc(p_date_of_birth);
  --
  -- if the input p_start_date is NULL then
  -- set the start date of the person record to two days in the past to allow the person to
  -- made an applicant today, and for them to be hired today, pushing the apply date one
  -- day in to the past if neccesary
  --
  if (p_start_date is NULL) then
    l_start_date:=trunc(sysdate-2);
  else
    l_start_date:=trunc(p_start_date-2);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PARTY_BK5.CREATE_CANDIDATE_INTERNAL_B
    (p_business_group_id                     => p_business_group_id
    ,p_last_name                             => p_last_name
    ,p_first_name                            => p_first_name
    ,p_email_address                         => p_email_address
    ,p_date_of_birth                         => l_date_of_birth
    ,p_title                                 => p_title
    ,p_gender                                => p_gender
    ,p_marital_status                        => p_marital_status
    ,p_previous_last_name                    => p_previous_last_name
    ,p_middle_name                           => p_middle_name
    ,p_name_suffix                           => p_name_suffix
    ,p_known_as                              => p_known_as
    ,p_first_name_phonetic                   => p_first_name_phonetic
    ,p_last_name_phonetic                    => p_last_name_phonetic
    ,p_attribute_category                    => p_attribute_category
    ,p_attribute1                            => p_attribute1
    ,p_attribute2                            => p_attribute2
    ,p_attribute3                            => p_attribute3
    ,p_attribute4                            => p_attribute4
    ,p_attribute5                            => p_attribute5
    ,p_attribute6                            => p_attribute6
    ,p_attribute7                            => p_attribute7
    ,p_attribute8                            => p_attribute8
    ,p_attribute9                            => p_attribute9
    ,p_attribute10                           => p_attribute10
    ,p_attribute11                           => p_attribute11
    ,p_attribute12                           => p_attribute12
    ,p_attribute13                           => p_attribute13
    ,p_attribute14                           => p_attribute14
    ,p_attribute15                           => p_attribute15
    ,p_attribute16                           => p_attribute16
    ,p_attribute17                           => p_attribute17
    ,p_attribute18                           => p_attribute18
    ,p_attribute19                           => p_attribute19
    ,p_attribute20                           => p_attribute20
    ,p_attribute21                           => p_attribute21
    ,p_attribute22                           => p_attribute22
    ,p_attribute23                           => p_attribute23
    ,p_attribute24                           => p_attribute24
    ,p_attribute25                           => p_attribute25
    ,p_attribute26                           => p_attribute26
    ,p_attribute27                           => p_attribute27
    ,p_attribute28                           => p_attribute28
    ,p_attribute29                           => p_attribute29
    ,p_attribute30                           => p_attribute30
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    ,p_nationality                           => p_nationality
    ,p_national_identifier                   => p_national_identifier
    ,p_town_of_birth                         => p_town_of_birth
    ,p_region_of_birth                       => p_region_of_birth
    ,p_country_of_birth                      => p_country_of_birth
    ,p_allow_access                          => p_allow_access
    ,p_start_date                            => l_start_date
    ,p_party_id                              => p_party_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CANDIDATE_INTERNAL'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  -- code for disabling the descriptive flex field
  --
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'IRC_SEARCH_CRITERIA';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'IRC_SEARCH_CRITERIA_DDF';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'IRC_NOTIFICATION_PREFERENCES';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_PEOPLE';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'Person Developer DF';
  --
  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
  --
  --
  --
  -- Get the legislation code corrsponding to the business group id
  --
  open csr_legislation_code(p_business_group_id);
  fetch csr_legislation_code into l_legislation_code;
  close csr_legislation_code;
  --
  -- Get the person type id
  --
  open csr_get_person_type_id(p_business_group_id);
  fetch csr_get_person_type_id into l_person_type_id;
  close csr_get_person_type_id;
  --
  if l_person_type_id is null then
    fnd_message.set_name('PER','IRC_412156_PERS_TYPE_NOT_SET');
    fnd_message.raise_error;
  end if;
  --
  -- get the PTU person type for iRecruitment Candidate
  --
  l_ptu_person_type_id:=hr_person_type_usage_info.get_default_person_type_id
                                         (p_business_group_id,
                                          'IRC_REG_USER');
  --
  -- Handle phonetic names for Japanese legislation
  --
  if (l_legislation_code = 'JP') then
      if (l_last_name_phonetic is null) then
        l_last_name_phonetic :=
          fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME');
      end if;
      hr_contact_api.create_person
      (p_validate                      => p_validate
      ,p_start_date                    => l_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => l_last_name_phonetic
      ,p_sex                           => p_gender
      ,p_person_type_id                => l_person_type_id
      ,p_date_of_birth                 => l_date_of_birth
      ,p_email_address                 => p_email_address
      ,p_first_name                    => p_first_name_phonetic
      ,p_known_as                      => p_known_as
      ,p_marital_status                => p_marital_status
      ,p_previous_last_name            => p_previous_last_name
      ,p_title                         => p_title
      ,p_middle_names                  => p_middle_name
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      ,p_per_information_category      => l_legislation_code
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_last_name
      ,p_per_information19             => p_first_name
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_nationality                   => p_nationality
      ,p_national_identifier           => p_national_identifier
      ,p_town_of_birth                 => p_town_of_birth
      ,p_region_of_birth               => p_region_of_birth
      ,p_country_of_birth              => p_country_of_birth
      ,p_suffix                        => p_name_suffix
      ,p_person_id                     => l_person_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_full_name                     => l_full_name
      ,p_comment_id                    => l_comment_id
      ,p_name_combination_warning      => l_name_combination_warning
      ,p_orig_hire_warning             => l_orig_hire_warning
      );
  --
  -- Handle phonetic names for Korean legislation
  --
  elsif (l_legislation_code = 'KR') then
    hr_contact_api.create_person
      (p_validate                      => p_validate
      ,p_start_date                    => l_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_sex                           => p_gender
      ,p_person_type_id                => l_person_type_id
      ,p_email_address                 => p_email_address
      ,p_date_of_birth                 => l_date_of_birth
      ,p_first_name                    => p_first_name
      ,p_known_as                      => p_known_as
      ,p_marital_status                => p_marital_status
      ,p_previous_last_name            => p_previous_last_name
      ,p_title                         => p_title
      ,p_middle_names                  => p_middle_name
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      ,p_per_information_category      => l_legislation_code
      ,p_per_information1              => l_last_name_phonetic
      ,p_per_information2              => p_first_name_phonetic
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_nationality                   => p_nationality
      ,p_national_identifier           => p_national_identifier
      ,p_town_of_birth                 => p_town_of_birth
      ,p_region_of_birth               => p_region_of_birth
      ,p_country_of_birth              => p_country_of_birth
      ,p_suffix                        => p_name_suffix
      ,p_person_id                     => l_person_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_full_name                     => l_full_name
      ,p_comment_id                    => l_comment_id
      ,p_name_combination_warning      => l_name_combination_warning
      ,p_orig_hire_warning             => l_orig_hire_warning
      );
  else
    hr_contact_api.create_person
      (p_validate                      => p_validate
      ,p_start_date                    => l_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_sex                           => p_gender
      ,p_person_type_id                => l_person_type_id
      ,p_email_address                 => p_email_address
      ,p_date_of_birth                 => l_date_of_birth
      ,p_first_name                    => p_first_name
      ,p_known_as                      => p_known_as
      ,p_marital_status                => p_marital_status
      ,p_previous_last_name            => p_previous_last_name
      ,p_title                         => p_title
      ,p_middle_names                  => p_middle_name
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      ,p_per_information_category      => l_legislation_code
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_nationality                   => p_nationality
      ,p_national_identifier           => p_national_identifier
      ,p_town_of_birth                 => p_town_of_birth
      ,p_region_of_birth               => p_region_of_birth
      ,p_country_of_birth              => p_country_of_birth
      ,p_suffix                        => p_name_suffix
      ,p_person_id                     => l_person_id
      ,p_object_version_number         => l_object_version_number
      ,p_effective_start_date          => l_effective_start_date
      ,p_effective_end_date            => l_effective_end_date
      ,p_full_name                     => l_full_name
      ,p_comment_id                    => l_comment_id
      ,p_name_combination_warning      => l_name_combination_warning
      ,p_orig_hire_warning             => l_orig_hire_warning
      );
  end if;
  hr_utility.set_location(l_proc, 40);

  -- calling this will associate the TCA party with the newly created Candidate and prevent PTU code from
  -- creating a new TCA record
  if p_party_id is not NULL then
     hr_person_api.update_person(p_effective_date           => l_start_date
                                ,p_datetrack_update_mode    => 'CORRECTION'
                                                                ,p_person_id                => l_person_id
                                                                ,p_party_id                 => p_party_id
                                                                ,p_employee_number          => l_employee_number /* CHECK THIS*/
                                                                ,p_object_version_number    => l_object_version_number
                                                                ,p_effective_start_date     => l_effective_start_date
                                ,p_effective_end_date       => l_effective_end_date
                                ,p_full_name                => l_full_name
                                ,p_comment_id               => l_comment_id
                                ,p_name_combination_warning => l_name_combination_warning
                                ,p_assign_payroll_warning   => l_assign_payroll_warning
                                ,p_orig_hire_warning        => l_orig_hire_warning
                                                                );
  end if;

  --
  -- create the extra PTU entry for iRecruitment Candidate
  --
  hr_per_type_usage_internal.maintain_person_type_usage
  (p_effective_date       => l_start_date
  ,p_person_id            => l_person_id
  ,p_person_type_id       => l_ptu_person_type_id
  );
  hr_utility.set_location(l_proc, 45);
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PARTY_BK5.CREATE_CANDIDATE_INTERNAL_A
      (p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_first_name                   => p_first_name
      ,p_email_address                => p_email_address
      ,p_date_of_birth                => l_date_of_birth
      ,p_title                        => p_title
      ,p_gender                       => p_gender
      ,p_marital_status               => p_marital_status
      ,p_previous_last_name           => p_previous_last_name
      ,p_middle_name                  => p_middle_name
      ,p_name_suffix                  => p_name_suffix
      ,p_known_as                     => p_known_as
      ,p_first_name_phonetic          => p_first_name_phonetic
      ,p_last_name_phonetic           => p_last_name_phonetic
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_per_information_category     => p_per_information_category
      ,p_per_information1             => p_per_information1
      ,p_per_information2             => p_per_information2
      ,p_per_information3             => p_per_information3
      ,p_per_information4             => p_per_information4
      ,p_per_information5             => p_per_information5
      ,p_per_information6             => p_per_information6
      ,p_per_information7             => p_per_information7
      ,p_per_information8             => p_per_information8
      ,p_per_information9             => p_per_information9
      ,p_per_information10            => p_per_information10
      ,p_per_information11            => p_per_information11
      ,p_per_information12            => p_per_information12
      ,p_per_information13            => p_per_information13
      ,p_per_information14            => p_per_information14
      ,p_per_information15            => p_per_information15
      ,p_per_information16            => p_per_information16
      ,p_per_information17            => p_per_information17
      ,p_per_information18            => p_per_information18
      ,p_per_information19            => p_per_information19
      ,p_per_information20            => p_per_information20
      ,p_per_information21            => p_per_information21
      ,p_per_information22            => p_per_information22
      ,p_per_information23            => p_per_information23
      ,p_per_information24            => p_per_information24
      ,p_per_information25            => p_per_information25
      ,p_per_information26            => p_per_information26
      ,p_per_information27            => p_per_information27
      ,p_per_information28            => p_per_information28
      ,p_per_information29            => p_per_information29
      ,p_per_information30            => p_per_information30
      ,p_nationality                  => p_nationality
      ,p_national_identifier          => p_national_identifier
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_person_id                    => l_person_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_allow_access                 => p_allow_access
      ,p_start_date                   => l_start_date
      ,p_party_id                     => p_party_id
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CANDIDATE_INTERNAL'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When IN validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_person_id                := l_person_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

  exception
  when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CANDIDATE_INTERNAL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is beINg used.)
    --
    p_person_id               := null;
    p_effective_start_date    := null;
    p_effective_start_date    := null;
   hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CANDIDATE_INTERNAL;
    --
    p_person_id               := null;
    p_effective_start_date    := null;
    p_effective_start_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_candidate_internal;
--
-- -------------------------------------------------------------------------
-- |------------------------< create_registered_user >----------------------|
-- -------------------------------------------------------------------------
--
procedure create_registered_user
   (p_validate                  IN     boolean  default false
   ,p_last_name                 IN     varchar2
   ,p_first_name                IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_title                     IN     varchar2 default null
   ,p_gender                    IN     varchar2 default null
   ,p_marital_status            IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_middle_name               IN     varchar2 default null
   ,p_name_suffix               IN     varchar2 default null
   ,p_known_as                  IN     varchar2 default null
   ,p_first_name_phonetic       IN     varchar2 default null
   ,p_last_name_phonetic        IN     varchar2 default null
   ,p_attribute_category        IN     varchar2 default null
   ,p_attribute1                IN     varchar2 default null
   ,p_attribute2                IN     varchar2 default null
   ,p_attribute3                IN     varchar2 default null
   ,p_attribute4                IN     varchar2 default null
   ,p_attribute5                IN     varchar2 default null
   ,p_attribute6                IN     varchar2 default null
   ,p_attribute7                IN     varchar2 default null
   ,p_attribute8                IN     varchar2 default null
   ,p_attribute9                IN     varchar2 default null
   ,p_attribute10               IN     varchar2 default null
   ,p_attribute11               IN     varchar2 default null
   ,p_attribute12               IN     varchar2 default null
   ,p_attribute13               IN     varchar2 default null
   ,p_attribute14               IN     varchar2 default null
   ,p_attribute15               IN     varchar2 default null
   ,p_attribute16               IN     varchar2 default null
   ,p_attribute17               IN     varchar2 default null
   ,p_attribute18               IN     varchar2 default null
   ,p_attribute19               IN     varchar2 default null
   ,p_attribute20               IN     varchar2 default null
   ,p_attribute21               IN     varchar2 default null
   ,p_attribute22               IN     varchar2 default null
   ,p_attribute23               IN     varchar2 default null
   ,p_attribute24               IN     varchar2 default null
   ,p_attribute25               IN     varchar2 default null
   ,p_attribute26               IN     varchar2 default null
   ,p_attribute27               IN     varchar2 default null
   ,p_attribute28               IN     varchar2 default null
   ,p_attribute29               IN     varchar2 default null
   ,p_attribute30               IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_start_date                IN     date     default null
   ,p_effective_start_date      OUT NOCOPY date
   ,p_effective_end_date        OUT NOCOPY date
   ,p_person_id                 OUT NOCOPY number) IS
--
l_proc          varchar2(72) := g_package||'create_registered_user';
l_person_id      PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
l_date_of_birth per_all_people_f.date_of_birth%type;
l_business_group_id per_all_people_f.business_group_id%type;
l_person_type_id per_all_people_f.person_type_id%type;
l_last_name_phonetic       hz_person_profiles.person_last_name_phonetic%type
                           := p_last_name_phonetic;
--
-- dummy variables
--
l_object_version_number    per_all_people_f.object_version_number%type;
l_effective_start_date     per_all_people_f.effective_start_date%type;
l_effective_end_date       per_all_people_f.effective_end_date%type;
l_full_name                per_all_people_f.full_name%type;
l_comment_id               per_all_people_f.comment_id%type;
l_name_combination_warning boolean;
l_orig_hire_warning        boolean;
l_legislation_code         per_business_groups_perf.legislation_code%type;
l_ptu_person_type_id       number(15);
--
-- for disabling the descriptive flex field
  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
--
-- cursor to select the legislation from per_business_groups_perf
-- corresponding to the business group
--
cursor csr_legislation_code(p_business_group_id number) is
select legislation_code
from per_business_groups_perf
where business_group_id = p_business_group_id;
--
-- cursor to select the person_type_id from hr_organization_inforamtion
-- corresponding to the recruiting flexfield on the business group
--
cursor csr_get_person_type_id(p_business_group_id number) is
select org_information8
from hr_organization_information
where organization_id=p_business_group_id
and ORG_INFORMATION_CONTEXT='BG Recruitment';
--
l_notification_preference_id number;
l_search_criteria_id number;
--
l_start_date date;
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_REGISTERED_USER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_of_birth := trunc(p_date_of_birth);
  --
  -- set the start date of the person record to two days in the past to allow the person to
  -- made an applicant today, and for them to be hired today, pushing the apply date one
  -- day in to the past if neccesary
  --
  l_start_date:=trunc(sysdate-2);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PARTY_BK1.CREATE_REGISTERED_USER_B
    (p_last_name                             => p_last_name
    ,p_first_name                            => p_first_name
    ,p_email_address                         => p_email_address
    ,p_date_of_birth                         => l_date_of_birth
    ,p_title                                 => p_title
    ,p_gender                                => p_gender
    ,p_marital_status                        => p_marital_status
    ,p_previous_last_name                    => p_previous_last_name
    ,p_middle_name                           => p_middle_name
    ,p_name_suffix                           => p_name_suffix
    ,p_known_as                              => p_known_as
    ,p_first_name_phonetic                   => p_first_name_phonetic
    ,p_last_name_phonetic                    => p_last_name_phonetic
    ,p_attribute_category                    => p_attribute_category
    ,p_attribute1                            => p_attribute1
    ,p_attribute2                            => p_attribute2
    ,p_attribute3                            => p_attribute3
    ,p_attribute4                            => p_attribute4
    ,p_attribute5                            => p_attribute5
    ,p_attribute6                            => p_attribute6
    ,p_attribute7                            => p_attribute7
    ,p_attribute8                            => p_attribute8
    ,p_attribute9                            => p_attribute9
    ,p_attribute10                           => p_attribute10
    ,p_attribute11                           => p_attribute11
    ,p_attribute12                           => p_attribute12
    ,p_attribute13                           => p_attribute13
    ,p_attribute14                           => p_attribute14
    ,p_attribute15                           => p_attribute15
    ,p_attribute16                           => p_attribute16
    ,p_attribute17                           => p_attribute17
    ,p_attribute18                           => p_attribute18
    ,p_attribute19                           => p_attribute19
    ,p_attribute20                           => p_attribute20
    ,p_attribute21                           => p_attribute21
    ,p_attribute22                           => p_attribute22
    ,p_attribute23                           => p_attribute23
    ,p_attribute24                           => p_attribute24
    ,p_attribute25                           => p_attribute25
    ,p_attribute26                           => p_attribute26
    ,p_attribute27                           => p_attribute27
    ,p_attribute28                           => p_attribute28
    ,p_attribute29                           => p_attribute29
    ,p_attribute30                           => p_attribute30
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    ,p_allow_access                          => p_allow_access
    ,p_start_date                            => p_start_date
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REGISTERED_USER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Process Logic
  -- code for disabling the descriptive flex field
  --
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'IRC_SEARCH_CRITERIA';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'IRC_SEARCH_CRITERIA_DDF';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'IRC_NOTIFICATION_PREFERENCES';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_PEOPLE';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'Person Developer DF';
  --
  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Get the business group id from profile
  --
  l_business_group_id := fnd_profile.value('IRC_REGISTRATION_BG_ID');
  --
  if l_business_group_id is null then
    fnd_message.set_name('PER','IRC_412155_REG_BG_NOT_SET');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  IRC_PARTY_API.CREATE_CANDIDATE_INTERNAL
    (p_business_group_id                     => l_business_group_id
    ,p_last_name                             => p_last_name
    ,p_first_name                            => p_first_name
    ,p_email_address                         => p_email_address
    ,p_date_of_birth                         => p_date_of_birth
    ,p_title                                 => p_title
    ,p_gender                                => p_gender
    ,p_marital_status                        => p_marital_status
    ,p_previous_last_name                    => p_previous_last_name
    ,p_middle_name                           => p_middle_name
    ,p_name_suffix                           => p_name_suffix
    ,p_known_as                              => p_known_as
    ,p_first_name_phonetic                   => p_first_name_phonetic
    ,p_last_name_phonetic                    => p_last_name_phonetic
    ,p_attribute_category                    => p_attribute_category
    ,p_attribute1                            => p_attribute1
    ,p_attribute2                            => p_attribute2
    ,p_attribute3                            => p_attribute3
    ,p_attribute4                            => p_attribute4
    ,p_attribute5                            => p_attribute5
    ,p_attribute6                            => p_attribute6
    ,p_attribute7                            => p_attribute7
    ,p_attribute8                            => p_attribute8
    ,p_attribute9                            => p_attribute9
    ,p_attribute10                           => p_attribute10
    ,p_attribute11                           => p_attribute11
    ,p_attribute12                           => p_attribute12
    ,p_attribute13                           => p_attribute13
    ,p_attribute14                           => p_attribute14
    ,p_attribute15                           => p_attribute15
    ,p_attribute16                           => p_attribute16
    ,p_attribute17                           => p_attribute17
    ,p_attribute18                           => p_attribute18
    ,p_attribute19                           => p_attribute19
    ,p_attribute20                           => p_attribute20
    ,p_attribute21                           => p_attribute21
    ,p_attribute22                           => p_attribute22
    ,p_attribute23                           => p_attribute23
    ,p_attribute24                           => p_attribute24
    ,p_attribute25                           => p_attribute25
    ,p_attribute26                           => p_attribute26
    ,p_attribute27                           => p_attribute27
    ,p_attribute28                           => p_attribute28
    ,p_attribute29                           => p_attribute29
    ,p_attribute30                           => p_attribute30
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    ,p_allow_access                          => p_allow_access
    ,p_start_date                            => p_start_date
    ,p_effective_start_date                  => l_effective_start_date
    ,p_effective_end_date                    => l_effective_end_date
    ,p_person_id                             => l_person_id
    );
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- create notification preferences
  --
  irc_notification_prefs_api.create_notification_prefs
  (p_validate=>p_validate
  ,p_person_id =>l_person_id
  ,p_effective_date=>trunc(sysdate)
  ,p_notification_preference_id=>l_notification_preference_id
  ,p_object_version_number =>l_object_version_number
  ,p_allow_access => p_allow_access);
  --
  --
  -- create a work preference row
  --
  irc_search_criteria_api.create_work_choices
  (p_validate=>p_validate
  ,p_effective_date=>trunc(sysdate)
  ,p_person_id =>l_person_id
  ,p_employee=>'Y'
  ,p_contractor=>'Y'
  ,p_object_version_number=>l_object_version_number
  ,p_search_criteria_id=>l_search_criteria_id);
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PARTY_BK1.CREATE_REGISTERED_USER_A
      (
       p_last_name                    => p_last_name
      ,p_first_name                   => p_first_name
      ,p_email_address                => p_email_address
      ,p_date_of_birth                => l_date_of_birth
      ,p_title                        => p_title
      ,p_gender                       => p_gender
      ,p_marital_status               => p_marital_status
      ,p_previous_last_name           => p_previous_last_name
      ,p_middle_name                  => p_middle_name
      ,p_name_suffix                  => p_name_suffix
      ,p_known_as                     => p_known_as
      ,p_first_name_phonetic          => p_first_name_phonetic
      ,p_last_name_phonetic           => p_last_name_phonetic
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_per_information_category     => p_per_information_category
      ,p_per_information1             => p_per_information1
      ,p_per_information2             => p_per_information2
      ,p_per_information3             => p_per_information3
      ,p_per_information4             => p_per_information4
      ,p_per_information5             => p_per_information5
      ,p_per_information6             => p_per_information6
      ,p_per_information7             => p_per_information7
      ,p_per_information8             => p_per_information8
      ,p_per_information9             => p_per_information9
      ,p_per_information10            => p_per_information10
      ,p_per_information11            => p_per_information11
      ,p_per_information12            => p_per_information12
      ,p_per_information13            => p_per_information13
      ,p_per_information14            => p_per_information14
      ,p_per_information15            => p_per_information15
      ,p_per_information16            => p_per_information16
      ,p_per_information17            => p_per_information17
      ,p_per_information18            => p_per_information18
      ,p_per_information19            => p_per_information19
      ,p_per_information20            => p_per_information20
      ,p_per_information21            => p_per_information21
      ,p_per_information22            => p_per_information22
      ,p_per_information23            => p_per_information23
      ,p_per_information24            => p_per_information24
      ,p_per_information25            => p_per_information25
      ,p_per_information26            => p_per_information26
      ,p_per_information27            => p_per_information27
      ,p_per_information28            => p_per_information28
      ,p_per_information29            => p_per_information29
      ,p_per_information30            => p_per_information30
      ,p_person_id                    => l_person_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_allow_access                 => p_allow_access
      ,p_start_date                   => p_start_date
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REGISTERED_USER'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When IN validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_person_id                := l_person_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  exception
  when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_REGISTERED_USER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is beINg used.)
    --
    p_person_id               := null;
    p_effective_start_date    := null;
    p_effective_start_date    := null;
   hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_REGISTERED_USER;
    --
    p_person_id               := null;
    p_effective_start_date    := null;
    p_effective_start_date    := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_registered_user;
--
-- -------------------------------------------------------------------------
-- |-----------------------< update_registered_user >----------------------|
-- -------------------------------------------------------------------------
--
procedure update_registered_user
   (p_validate                  IN     boolean  default false
   ,p_effective_date            IN     date
   ,p_person_id                 IN     number
   ,p_first_name                IN     varchar2 default hr_api.g_varchar2
   ,p_last_name                 IN     varchar2 default hr_api.g_varchar2
   ,p_date_of_birth             IN     date     default hr_api.g_date
   ,p_title                     IN     varchar2 default hr_api.g_varchar2
   ,p_gender                    IN     varchar2 default hr_api.g_varchar2
   ,p_marital_status            IN     varchar2 default hr_api.g_varchar2
   ,p_previous_last_name        IN     varchar2 default hr_api.g_varchar2
   ,p_middle_name               IN     varchar2 default hr_api.g_varchar2
   ,p_name_suffix               IN     varchar2 default hr_api.g_varchar2
   ,p_known_as                  IN     varchar2 default hr_api.g_varchar2
   ,p_first_name_phonetic       IN     varchar2 default hr_api.g_varchar2
   ,p_last_name_phonetic        IN     varchar2 default hr_api.g_varchar2
   ,p_attribute_category        IN     varchar2 default hr_api.g_varchar2
   ,p_attribute1                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute2                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute3                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute4                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute5                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute6                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute7                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute8                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute9                IN     varchar2 default hr_api.g_varchar2
   ,p_attribute10               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute11               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute12               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute13               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute14               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute15               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute16               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute17               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute18               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute19               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute20               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute21               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute22               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute23               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute24               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute25               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute26               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute27               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute28               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute29               IN     varchar2 default hr_api.g_varchar2
   ,p_attribute30               IN     varchar2 default hr_api.g_varchar2
   ,p_per_information_category  IN     varchar2 default hr_api.g_varchar2
   ,p_per_information1          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information2          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information3          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information4          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information5          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information6          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information7          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information8          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information9          IN     varchar2 default hr_api.g_varchar2
   ,p_per_information10         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information11         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information12         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information13         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information14         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information15         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information16         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information17         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information18         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information19         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information20         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information21         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information22         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information23         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information24         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information25         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information26         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information27         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information28         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information29         IN     varchar2 default hr_api.g_varchar2
   ,p_per_information30         IN     varchar2 default hr_api.g_varchar2
   ) IS
--
l_proc                     varchar2(72) := g_package||'update_registered_user';
l_object_version_number    per_all_people_f.object_version_number%TYPE;
l_employee_number          per_all_people_f.employee_number%TYPE;
l_effective_date           date;
l_legislation_code         per_business_groups.legislation_code%type;
-- sex is defaulted to null - it is set to the value of sex
-- on per_all_people_f if p_gender exists in hr_lookups
l_sex                      per_all_people_f.sex%TYPE := hr_api.g_varchar2;
l_last_name_phonetic       hz_person_profiles.person_last_name_phonetic%type
                           := p_last_name_phonetic;
--
-- dummy variables
--
l_profile_id               number;
l_effective_start_date     date;
l_effective_end_date       date;
l_full_name                per_all_people_f.full_name%type;
l_comment_id               number;
l_name_combination_warning boolean;
l_assign_payroll_warning   boolean;
l_orig_hire_warning        boolean;
l_date_of_birth            date;
l_marital_status           hz_person_profiles.marital_status%type;
--
-- for disabling the descriptive flex field
  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
-- for disabling the key flex field
  l_add_struct_k hr_kflex_utility.l_ignore_kfcode_varray :=
                           hr_kflex_utility.l_ignore_kfcode_varray();
--
--
-- cursor to select entries IN per_all_people_f
-- relating to registered user
--
cursor csr_person_id(p_person_id number,p_effective_date date) is
select effective_start_date,object_version_number,employee_number
from per_all_people_f
where person_id = p_person_id
and l_effective_date between effective_start_date and effective_end_date;
--
begin
  hr_utility.set_location(' Entering: ' || l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_REGISTERED_USER;
  --
  l_date_of_birth := trunc(p_date_of_birth);
  l_effective_date := trunc(p_effective_date);
  --
  --
  -- Call Before Process User Hook
  --
  begin
    irc_party_bk2.update_registered_user_b
    (
       p_effective_date                         => l_effective_date
      ,p_person_id                              => p_person_id
      ,p_first_name                             => p_first_name
      ,p_last_name                              => p_last_name
      ,p_date_of_birth                          => l_date_of_birth
      ,p_title                                  => p_title
      ,p_gender                                 => p_gender
      ,p_marital_status                         => p_marital_status
      ,p_previous_last_name                     => p_previous_last_name
      ,p_middle_name                            => p_middle_name
      ,p_name_suffix                            => p_name_suffix
      ,p_known_as                               => p_known_as
      ,p_first_name_phonetic                    => p_first_name_phonetic
      ,p_last_name_phonetic                     => p_last_name_phonetic
      ,p_attribute_category                     => p_attribute_category
      ,p_attribute1                             => p_attribute1
      ,p_attribute2                             => p_attribute2
      ,p_attribute3                             => p_attribute3
      ,p_attribute4                             => p_attribute4
      ,p_attribute5                             => p_attribute5
      ,p_attribute6                             => p_attribute6
      ,p_attribute7                             => p_attribute7
      ,p_attribute8                             => p_attribute8
      ,p_attribute9                             => p_attribute9
      ,p_attribute10                            => p_attribute10
      ,p_attribute11                            => p_attribute11
      ,p_attribute12                            => p_attribute12
      ,p_attribute13                            => p_attribute13
      ,p_attribute14                            => p_attribute14
      ,p_attribute15                            => p_attribute15
      ,p_attribute16                            => p_attribute16
      ,p_attribute17                            => p_attribute17
      ,p_attribute18                            => p_attribute18
      ,p_attribute19                            => p_attribute19
      ,p_attribute20                            => p_attribute20
      ,p_attribute21                            => p_attribute21
      ,p_attribute22                            => p_attribute22
      ,p_attribute23                            => p_attribute23
      ,p_attribute24                            => p_attribute24
      ,p_attribute25                            => p_attribute25
      ,p_attribute26                            => p_attribute26
      ,p_attribute27                            => p_attribute27
      ,p_attribute28                            => p_attribute28
      ,p_attribute29                            => p_attribute29
      ,p_attribute30                            => p_attribute30
      ,p_per_information_category               => p_per_information_category
      ,p_per_information1                       => p_per_information1
      ,p_per_information2                       => p_per_information2
      ,p_per_information3                       => p_per_information3
      ,p_per_information4                       => p_per_information4
      ,p_per_information5                       => p_per_information5
      ,p_per_information6                       => p_per_information6
      ,p_per_information7                       => p_per_information7
      ,p_per_information8                       => p_per_information8
      ,p_per_information9                       => p_per_information9
      ,p_per_information10                      => p_per_information10
      ,p_per_information11                      => p_per_information11
      ,p_per_information12                      => p_per_information12
      ,p_per_information13                      => p_per_information13
      ,p_per_information14                      => p_per_information14
      ,p_per_information15                      => p_per_information15
      ,p_per_information16                      => p_per_information16
      ,p_per_information17                      => p_per_information17
      ,p_per_information18                      => p_per_information18
      ,p_per_information19                      => p_per_information19
      ,p_per_information20                      => p_per_information20
      ,p_per_information21                      => p_per_information21
      ,p_per_information22                      => p_per_information22
      ,p_per_information23                      => p_per_information23
      ,p_per_information24                      => p_per_information24
      ,p_per_information25                      => p_per_information25
      ,p_per_information26                      => p_per_information26
      ,p_per_information27                      => p_per_information27
      ,p_per_information28                      => p_per_information28
      ,p_per_information29                      => p_per_information29
      ,p_per_information30                      => p_per_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REGISTERED_USER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  --
  -- Set profile option
  fnd_profile.put('HZ_CREATED_BY_MODULE','HR API');
  hr_utility.set_location(l_proc, 40);
  --
  -- Added for turn off key flex field validation
  --
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'GRP';
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'CAGR';
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'SCL';
  --
  hr_kflex_utility.create_ignore_kf_validation(p_rec => l_add_struct_k);
  --
  -- code for disabling the descriptive flex field
  --
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_ASSIGNMENTS';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'Person Developer DF';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_PEOPLE';
  --
  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

  open csr_person_id(p_person_id,p_effective_date);
  fetch csr_person_id into l_effective_start_date,l_object_version_number,l_employee_number;
  close csr_person_id;
  --
  l_legislation_code := per_per_bus.return_legislation_code(p_person_id);
  --
  if (l_legislation_code = 'JP') then
    if (l_last_name_phonetic is null) then
      l_last_name_phonetic :=
        fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME');
      end if;
      hr_person_api.update_person
        (p_validate                  => false
        ,p_effective_date            => l_effective_date
        ,p_datetrack_update_mode     => 'CORRECTION'
        ,p_person_id                 => p_person_id
        ,p_employee_number           => l_employee_number
        ,p_object_version_number     => l_object_version_number
        ,p_last_name                 => l_last_name_phonetic
        ,p_previous_last_name        => p_previous_last_name
        ,p_date_of_birth             => l_date_of_birth
        ,p_first_name                => p_first_name_phonetic
        ,p_known_as                  => p_known_as
        ,p_sex                       => p_gender
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => p_middle_name
        ,p_suffix                    => p_name_suffix
        ,p_attribute_category        => p_attribute_category
        ,p_attribute1                => p_attribute1
        ,p_attribute2                => p_attribute2
        ,p_attribute3                => p_attribute3
        ,p_attribute4                => p_attribute4
        ,p_attribute5                => p_attribute5
        ,p_attribute6                => p_attribute6
        ,p_attribute7                => p_attribute7
        ,p_attribute8                => p_attribute8
        ,p_attribute9                => p_attribute9
        ,p_attribute10               => p_attribute10
        ,p_attribute11               => p_attribute11
        ,p_attribute12               => p_attribute12
        ,p_attribute13               => p_attribute13
        ,p_attribute14               => p_attribute14
        ,p_attribute15               => p_attribute15
        ,p_attribute16               => p_attribute16
        ,p_attribute17               => p_attribute17
        ,p_attribute18               => p_attribute18
        ,p_attribute19               => p_attribute19
        ,p_attribute20               => p_attribute20
        ,p_attribute21               => p_attribute21
        ,p_attribute22               => p_attribute22
        ,p_attribute23               => p_attribute23
        ,p_attribute24               => p_attribute24
        ,p_attribute25               => p_attribute25
        ,p_attribute26               => p_attribute26
        ,p_attribute27               => p_attribute27
        ,p_attribute28               => p_attribute28
        ,p_attribute29               => p_attribute29
        ,p_attribute30               => p_attribute30
        ,p_per_information_category  => p_per_information_category
        ,p_per_information1          => p_per_information1
        ,p_per_information2          => p_per_information2
        ,p_per_information3          => p_per_information3
        ,p_per_information4          => p_per_information4
        ,p_per_information5          => p_per_information5
        ,p_per_information6          => p_per_information6
        ,p_per_information7          => p_per_information7
        ,p_per_information8          => p_per_information8
        ,p_per_information9          => p_per_information9
        ,p_per_information10         => p_per_information10
        ,p_per_information11         => p_per_information11
        ,p_per_information12         => p_per_information12
        ,p_per_information13         => p_per_information13
        ,p_per_information14         => p_per_information14
        ,p_per_information15         => p_per_information15
        ,p_per_information16         => p_per_information16
        ,p_per_information17         => p_per_information17
        ,p_per_information18         => p_last_name
        ,p_per_information19         => p_first_name
        ,p_per_information20         => p_per_information20
        ,p_per_information21         => p_per_information21
        ,p_per_information22         => p_per_information22
        ,p_per_information23         => p_per_information23
        ,p_per_information24         => p_per_information24
        ,p_per_information25         => p_per_information25
        ,p_per_information26         => p_per_information26
        ,p_per_information27         => p_per_information27
        ,p_per_information28         => p_per_information28
        ,p_per_information29         => p_per_information29
        ,p_per_information30         => p_per_information30
        ,p_effective_start_date      => l_effective_start_date
        ,p_effective_end_date        => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_comment_id                => l_comment_id
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_assign_payroll_warning    => l_assign_payroll_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        );
    elsif (l_legislation_code = 'KR') then
      hr_person_api.update_person
        (p_validate                  => false
        ,p_effective_date            => l_effective_date
        ,p_datetrack_update_mode     => 'CORRECTION'
        ,p_person_id                 => p_person_id
        ,p_employee_number           => l_employee_number
        ,p_object_version_number     => l_object_version_number
        ,p_last_name                 => p_last_name
        ,p_previous_last_name        => p_previous_last_name
        ,p_date_of_birth             => l_date_of_birth
        ,p_first_name                => p_first_name
        ,p_known_as                  => p_known_as
        ,p_sex                       => p_gender
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => p_middle_name
        ,p_suffix                    => p_name_suffix
        ,p_attribute_category        => p_attribute_category
        ,p_attribute1                => p_attribute1
        ,p_attribute2                => p_attribute2
        ,p_attribute3                => p_attribute3
        ,p_attribute4                => p_attribute4
        ,p_attribute5                => p_attribute5
        ,p_attribute6                => p_attribute6
        ,p_attribute7                => p_attribute7
        ,p_attribute8                => p_attribute8
        ,p_attribute9                => p_attribute9
        ,p_attribute10               => p_attribute10
        ,p_attribute11               => p_attribute11
        ,p_attribute12               => p_attribute12
        ,p_attribute13               => p_attribute13
        ,p_attribute14               => p_attribute14
        ,p_attribute15               => p_attribute15
        ,p_attribute16               => p_attribute16
        ,p_attribute17               => p_attribute17
        ,p_attribute18               => p_attribute18
        ,p_attribute19               => p_attribute19
        ,p_attribute20               => p_attribute20
        ,p_attribute21               => p_attribute21
        ,p_attribute22               => p_attribute22
        ,p_attribute23               => p_attribute23
        ,p_attribute24               => p_attribute24
        ,p_attribute25               => p_attribute25
        ,p_attribute26               => p_attribute26
        ,p_attribute27               => p_attribute27
        ,p_attribute28               => p_attribute28
        ,p_attribute29               => p_attribute29
        ,p_attribute30               => p_attribute30
        ,p_per_information_category  => p_per_information_category
        ,p_per_information1          => l_last_name_phonetic
        ,p_per_information2          => p_first_name_phonetic
        ,p_per_information3          => p_per_information3
        ,p_per_information4          => p_per_information4
        ,p_per_information5          => p_per_information5
        ,p_per_information6          => p_per_information6
        ,p_per_information7          => p_per_information7
        ,p_per_information8          => p_per_information8
        ,p_per_information9          => p_per_information9
        ,p_per_information10         => p_per_information10
        ,p_per_information11         => p_per_information11
        ,p_per_information12         => p_per_information12
        ,p_per_information13         => p_per_information13
        ,p_per_information14         => p_per_information14
        ,p_per_information15         => p_per_information15
        ,p_per_information16         => p_per_information16
        ,p_per_information17         => p_per_information17
        ,p_per_information18         => p_per_information18
        ,p_per_information19         => p_per_information19
        ,p_per_information20         => p_per_information20
        ,p_per_information21         => p_per_information21
        ,p_per_information22         => p_per_information22
        ,p_per_information23         => p_per_information23
        ,p_per_information24         => p_per_information24
        ,p_per_information25         => p_per_information25
        ,p_per_information26         => p_per_information26
        ,p_per_information27         => p_per_information27
        ,p_per_information28         => p_per_information28
        ,p_per_information29         => p_per_information29
        ,p_per_information30         => p_per_information30
        ,p_effective_start_date      => l_effective_start_date
        ,p_effective_end_date        => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_comment_id                => l_comment_id
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_assign_payroll_warning    => l_assign_payroll_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        );
    else
      hr_person_api.update_person
        (p_validate                  => false
        ,p_effective_date            => l_effective_date
        ,p_datetrack_update_mode     => 'CORRECTION'
        ,p_person_id                 => p_person_id
        ,p_employee_number           => l_employee_number
        ,p_object_version_number     => l_object_version_number
        ,p_last_name                 => p_last_name
        ,p_previous_last_name        => p_previous_last_name
        ,p_date_of_birth             => l_date_of_birth
        ,p_first_name                => p_first_name
        ,p_known_as                  => p_known_as
        ,p_sex                       => p_gender
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => p_middle_name
        ,p_suffix                    => p_name_suffix
        ,p_attribute_category        => p_attribute_category
        ,p_attribute1                => p_attribute1
        ,p_attribute2                => p_attribute2
        ,p_attribute3                => p_attribute3
        ,p_attribute4                => p_attribute4
        ,p_attribute5                => p_attribute5
        ,p_attribute6                => p_attribute6
        ,p_attribute7                => p_attribute7
        ,p_attribute8                => p_attribute8
        ,p_attribute9                => p_attribute9
        ,p_attribute10               => p_attribute10
        ,p_attribute11               => p_attribute11
        ,p_attribute12               => p_attribute12
        ,p_attribute13               => p_attribute13
        ,p_attribute14               => p_attribute14
        ,p_attribute15               => p_attribute15
        ,p_attribute16               => p_attribute16
        ,p_attribute17               => p_attribute17
        ,p_attribute18               => p_attribute18
        ,p_attribute19               => p_attribute19
        ,p_attribute20               => p_attribute20
        ,p_attribute21               => p_attribute21
        ,p_attribute22               => p_attribute22
        ,p_attribute23               => p_attribute23
        ,p_attribute24               => p_attribute24
        ,p_attribute25               => p_attribute25
        ,p_attribute26               => p_attribute26
        ,p_attribute27               => p_attribute27
        ,p_attribute28               => p_attribute28
        ,p_attribute29               => p_attribute29
        ,p_attribute30               => p_attribute30
        ,p_per_information_category  => p_per_information_category
        ,p_per_information1          => p_per_information1
        ,p_per_information2          => p_per_information2
        ,p_per_information3          => p_per_information3
        ,p_per_information4          => p_per_information4
        ,p_per_information5          => p_per_information5
        ,p_per_information6          => p_per_information6
        ,p_per_information7          => p_per_information7
        ,p_per_information8          => p_per_information8
        ,p_per_information9          => p_per_information9
        ,p_per_information10         => p_per_information10
        ,p_per_information11         => p_per_information11
        ,p_per_information12         => p_per_information12
        ,p_per_information13         => p_per_information13
        ,p_per_information14         => p_per_information14
        ,p_per_information15         => p_per_information15
        ,p_per_information16         => p_per_information16
        ,p_per_information17         => p_per_information17
        ,p_per_information18         => p_per_information18
        ,p_per_information19         => p_per_information19
        ,p_per_information20         => p_per_information20
        ,p_per_information21         => p_per_information21
        ,p_per_information22         => p_per_information22
        ,p_per_information23         => p_per_information23
        ,p_per_information24         => p_per_information24
        ,p_per_information25         => p_per_information25
        ,p_per_information26         => p_per_information26
        ,p_per_information27         => p_per_information27
        ,p_per_information28         => p_per_information28
        ,p_per_information29         => p_per_information29
        ,p_per_information30         => p_per_information30
        ,p_effective_start_date      => l_effective_start_date
        ,p_effective_end_date        => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_comment_id                => l_comment_id
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_assign_payroll_warning    => l_assign_payroll_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        );
    end if;
    hr_utility.set_Location(l_proc, 60);
    -- Save person ovn to global
    if ( p_person_id = g_person_id ) then
      g_ovn_for_person := l_object_version_number;
    end if;
  --
  -- Call After Process User Hook
  --
  begin
    irc_party_bk2.update_registered_user_a
    (
       p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_first_name                   => p_first_name
      ,p_last_name                    => p_last_name
      ,p_date_of_birth                => l_date_of_birth
      ,p_title                        => p_title
      ,p_gender                       => p_gender
      ,p_marital_status               => l_marital_status
      ,p_previous_last_name           => p_previous_last_name
      ,p_middle_name                  => p_middle_name
      ,p_name_suffix                  => p_name_suffix
      ,p_known_as                     => p_known_as
      ,p_first_name_phonetic          => p_first_name_phonetic
      ,p_last_name_phonetic           => p_last_name_phonetic
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_per_information_category     => p_per_information_category
      ,p_per_information1             => p_per_information1
      ,p_per_information2             => p_per_information2
      ,p_per_information3             => p_per_information3
      ,p_per_information4             => p_per_information4
      ,p_per_information5             => p_per_information5
      ,p_per_information6             => p_per_information6
      ,p_per_information7             => p_per_information7
      ,p_per_information8             => p_per_information8
      ,p_per_information9             => p_per_information9
      ,p_per_information10            => p_per_information10
      ,p_per_information11            => p_per_information11
      ,p_per_information12            => p_per_information12
      ,p_per_information13            => p_per_information13
      ,p_per_information14            => p_per_information14
      ,p_per_information15            => p_per_information15
      ,p_per_information16            => p_per_information16
      ,p_per_information17            => p_per_information17
      ,p_per_information18            => p_per_information18
      ,p_per_information19            => p_per_information19
      ,p_per_information20            => p_per_information20
      ,p_per_information21            => p_per_information21
      ,p_per_information22            => p_per_information22
      ,p_per_information23            => p_per_information23
      ,p_per_information24            => p_per_information24
      ,p_per_information25            => p_per_information25
      ,p_per_information26            => p_per_information26
      ,p_per_information27            => p_per_information27
      ,p_per_information28            => p_per_information28
      ,p_per_information29            => p_per_information29
      ,p_per_information30            => p_per_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REGISTERED_USER'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When IN validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

  exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_REGISTERED_USER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is beINg used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_REGISTERED_USER;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_registered_user;
--
-- -------------------------------------------------------------------------
-- |---------------------< chk_agency_application_limit >-------------------|
-- -------------------------------------------------------------------------
--
procedure chk_agency_application_limit
   (p_vacancy_id                IN     number   default null
   ,p_effective_date            IN     date) IS
  --
  cursor csr_application_count(p_vacancy_id number, p_effective_date date) is
  select count(*)
  from per_all_assignments_f paaf
  , IRC_AGENCY_VACANCIES AGV1
  ,per_all_people_f per1
  ,irc_notification_preferences prefs
  where paaf.vacancy_id = p_vacancy_id and paaf.assignment_type = 'A'
  and p_effective_date between PAAF.EFFECTIVE_START_DATE
  AND PAAF.EFFECTIVE_END_DATE
  and paaf.VACANCY_ID = AGV1.VACANCY_ID
  and AGV1.AGENCY_ID = FND_PROFILE.VALUE('IRC_AGENCY_NAME')
  and per1.person_id=paaf.person_id
  and p_effective_date between per1.effective_start_date and per1.effective_end_date
  and per1.party_id=prefs.party_id
  and prefs.agency_id=agv1.agency_id
  and p_effective_date between nvl(agv1.start_date,p_effective_date)
  and nvl(agv1.end_date,p_effective_date);
  --
  cursor csr_application_count_limit(p_vacancy_id number) is
  select AGV.MAX_ALLOWED_APPLICANTS
  from IRC_AGENCY_VACANCIES AGV
  where agv.vacancy_id = p_vacancy_id
        and AGV.AGENCY_ID = FND_PROFILE.VALUE('IRC_AGENCY_NAME');
  --
  l_application_count_limit IRC_AGENCY_VACANCIES.MAX_ALLOWED_APPLICANTS%TYPE;
  l_application_count Number;
  l_agency_id IRC_AGENCY_VACANCIES.AGENCY_ID%TYPE;
begin
  --
  -- only check if Agency profile is set
  --
  if ( FND_PROFILE.VALUE('IRC_AGENCY_NAME') is not null ) then
    --
    -- get the applicant count limit for the vacancy
    --
    open csr_application_count_limit(p_vacancy_id);
    fetch csr_application_count_limit into l_application_count_limit;
    --
    if ( csr_application_count_limit%found ) then
      if ( l_application_count_limit is null ) then
        l_application_count_limit := FND_PROFILE.VALUE('IRC_MAX_APPLICANTS_DFT');
      end if;
    end if;
    close csr_application_count_limit;
    --
    -- only do check if applicant count limit has been set
    --
    if ( l_application_count_limit is not null ) then
      open csr_application_count(p_vacancy_id, p_effective_date);
      fetch csr_application_count into l_application_count;
      if ( l_application_count >= l_application_count_limit ) then
        fnd_message.set_name('PER','IRC_MAX_APPLICATIONS_LIMIT');
        hr_multi_message.add();
        hr_multi_message.end_validation_set();
      end if;
      close csr_application_count;
    end if;
  end if;
end chk_agency_application_limit;

--
-- -------------------------------------------------------------------------
-- |---------------------< registered_user_application >-------------------|
-- -------------------------------------------------------------------------
--
procedure registered_user_application
   (p_validate                  IN     boolean  default false
   ,p_effective_date            IN     date
   ,p_recruitment_person_id     IN     number
   ,p_person_id                 IN     number
   ,p_assignment_id             IN     number
   ,p_application_received_date IN     date     default null
   ,p_vacancy_id                IN     number   default null
   ,p_posting_content_id        IN     number   default null
   ,p_per_information4          IN     per_all_people_f.per_information4%type default null
   ,p_per_object_version_number    OUT NOCOPY number
   ,p_asg_object_version_number    OUT NOCOPY number
   ,p_applicant_number             OUT NOCOPY varchar2) IS
  --
  l_proc                      varchar2(72) := g_package||'registered_user_application';
  l_per_object_version_number     per_all_people_f.object_version_number%TYPE;
  l_asg_object_version_number     per_all_assignments_f.object_version_number%TYPE;
  l_person_id                 per_all_people_f.person_id%TYPE;
  l_party_id                  per_all_people_f.party_id%TYPE;
  l_rec_person_id             per_all_people_f.person_id%TYPE;
  l_assignment_id             per_all_assignments_f.assignment_id%TYPE;
  l_effective_date            date;
  l_application_received_date date;
  l_party_last_update_date    date;
  l_return_status             varchar2(10);
  l_applicant_number          per_all_people_f.applicant_number%type;
  l_person_type_id            per_person_types.person_type_id%type;
  l_current_employee_flag     per_all_people_f.current_employee_flag%type;
  l_current_applicant_flag    per_all_people_f.current_applicant_flag%type;
  l_current_npw_flag          per_all_people_f.current_npw_flag%type;

  l_last_name per_all_people_f.last_name%type;
  l_first_name per_all_people_f.first_name%type;
  l_per_information1 per_all_people_f.per_information1%type;
  l_per_information2 per_all_people_f.per_information2%type;
  l_per_information18 per_all_people_f.per_information18%type;
  l_per_information19 per_all_people_f.per_information19%type;
  l_date_of_birth per_all_people_f.date_of_birth%type;
  l_title per_all_people_f.title%type;
  l_gender per_all_people_f.sex%type;
  l_marital_status per_all_people_f.marital_status%type;
  l_previous_last_name per_all_people_f.last_name%type;
  l_middle_name per_all_people_f.middle_names%type;
  l_name_suffix per_all_people_f.suffix%type;
  l_known_as per_all_people_f.known_as%type;
  l_business_group_id per_all_vacancies.business_group_id%type;
  l_organization_id per_all_vacancies.organization_id%type;
  l_job_id per_all_vacancies.job_id%type;
  l_position_id per_all_vacancies.position_id%type;
  l_manager_id per_all_vacancies.manager_id%type;
  l_grade_id per_all_vacancies.grade_id%type;
  l_location_id per_all_vacancies.location_id%type;
  l_recruiter_id per_all_vacancies.recruiter_id%type;
  l_people_group_id per_all_vacancies.people_group_id%type;
  l_legislation_code per_business_groups.legislation_code%type;
  --
  -- variables for hr_person_api.update_person
  --
  l_object_version_number    per_all_people_f.object_version_number%TYPE;
  l_employee_number          per_all_people_f.employee_number%TYPE;
  --
  -- dummy variables
  --
  l_msg_count                 number;
  l_msg_data                  varchar2(2000);
  l_var                       varchar2(1);
  l_party_number  hz_parties.party_number%type;
  l_profile_id                number;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_comment_id                number;
  l_name_combination_warning  boolean;
  l_assign_payroll_warning    boolean;
  l_orig_hire_warning         boolean;
  l_object_version_number_d   per_all_people_f.object_version_number%TYPE;
  -- those required for hr_assignment_api.create_secondary_apl_asg
  l_concatenated_segments    varchar2(2000);
  l_cagr_grade_def_id         number;
  l_cagr_concatenated_segments varchar2(2000);
  l_group_name                pay_people_groups.group_name%type;
  l_soft_coding_keyflex_id    number;
  l_assignment_sequence       per_all_assignments_f.assignment_sequence%type;
  -- those required for hr_applicant_api.create_applicant
  l_application_id            number;
  l_full_name                 per_all_people_f.full_name%type;
  l_person_type               per_person_types.system_person_type%type;
  l_ptu_person_type_id        number;
-- for disabling the descriptive flex field
  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
-- for disabling the key flex field
  l_add_struct_k hr_kflex_utility.l_ignore_kfcode_varray :=
                           hr_kflex_utility.l_ignore_kfcode_varray();
  --
  l_time_normal_finish     per_business_groups.default_end_time%TYPE;
  l_time_normal_start      per_business_groups.default_start_time%TYPE;
  l_normal_hours           number;
  l_frequency              per_business_groups.frequency%TYPE;
  --
  -- cursor to select entries IN per_all_people_f
  -- relating to registered user
  --
  cursor csr_person_id(p_party_id number
                      ,p_effective_date date
                      ,p_business_group_id number) is
  select per.person_id
        ,per.object_version_number
        ,per.current_employee_flag
        ,per.current_applicant_flag
        ,per.current_npw_flag
        ,per.applicant_number
  from per_all_people_f per
  where per.party_id = p_party_id
  and p_effective_date between per.effective_start_date and per.effective_end_date
  and business_group_id=p_business_group_id;
  --
  -- cursor to select entries IN per_all_people_f
  -- for a given person over all dates
  --
  cursor csr_person_all_dates(p_party_id number
                      ,p_business_group_id number) is
  select null
  from per_all_people_f per
  where per.party_id = p_party_id
  and business_group_id=p_business_group_id;
  --
  -- cursor to select person details for the registered user
  --
  cursor csr_party_details(p_person_id number,p_effective_date date) is
  select last_update_date
  ,party_id
  ,last_name
  ,first_name
  ,date_of_birth
  ,title
  ,sex
  ,marital_status
  ,previous_last_name
  ,middle_names
  ,suffix
  ,known_as
  ,per_information1
  ,per_information2
  ,per_information18
  ,per_information19
  from per_all_people_f
  where person_id = p_person_id
  and p_effective_date between effective_start_date and effective_end_date;
-- cursor to select business_group relating to a vacancy
cursor csr_get_vac(p_vacancy_id number) is
select business_group_id
,organization_id
,job_id
,position_id
,grade_id
,people_group_id
,location_id
,recruiter_id
,manager_id
from per_all_vacancies
where vacancy_id = p_vacancy_id;
--
cursor get_new_asg(p_person_id number, p_effective_date date) is
select assignment_id,object_version_number
from per_all_assignments_f
where person_id=p_person_id
and effective_start_date = p_effective_date
and assignment_type='A';
--
-- Cursors to get work schedule
--
CURSOR csr_pos_default_details(p_position_id Number) IS
  SELECT pos.TIME_NORMAL_START
       , pos.TIME_NORMAL_FINISH
       , pos.working_hours
       , pos.frequency
  FROM   hr_all_positions_f pos
  WHERE  pos.position_id = p_position_id
    AND  p_effective_date between effective_start_date and effective_end_date;
--
CURSOR csr_org_default_details(p_organization_id Number) IS
  SELECT org.org_information1
       , org.org_information2
       , fnd_number.canonical_to_number(org.org_information3) normal_hours
       , org.org_information4
  FROM   HR_ORGANIZATION_INFORMATION org
  WHERE  org.organization_id  = p_organization_id
    AND  org.org_information_context(+) = 'Work Day Information';
--
CURSOR csr_get_bg_default_details(p_business_group_id number) IS
  SELECT bus.default_start_time
       , bus.default_end_time
       , fnd_number.canonical_to_number(bus.working_hours)
       , bus.frequency
   FROM  per_business_groups bus
  WHERE  bus.business_group_id = p_business_group_id;
--
--
  begin
  hr_utility.set_location(' Entering: ' || l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint REGISTERED_USER_APPLICATION;
  --
  -- Truncate time portion from date
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- check if an agency is applying and if the application count is exceeded
  --
  irc_party_api.chk_agency_application_limit(p_vacancy_id => p_vacancy_id
                                            ,p_effective_date => l_effective_date);
  --
  -- If no application received date passed, then assume application received
  -- on effective_date
  --
  l_application_received_date:=trunc(nvl(p_application_received_date
                                  ,l_effective_date));
  --
  -- Added for turn off key flex field validation
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'GRP';
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'CAGR';
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'SCL';
  --
  hr_kflex_utility.create_ignore_kf_validation(p_rec => l_add_struct_k);
  --
  -- code for disabling the descriptive flex field
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_ASSIGNMENTS';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'Person Developer DF';
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_PEOPLE';
  --
  hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
  --
  -- Call Before Process User Hook
  --
  begin
    irc_party_bk3.registered_user_application_b
    (
       p_effective_date                         => l_effective_date
      ,p_person_id                              => p_person_id
      ,p_applicant_number                       => l_applicant_number
      ,p_application_received_date              => l_application_received_date
      ,p_vacancy_id                             => p_vacancy_id
      ,p_posting_content_id                     => p_posting_content_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'REGISTERED_USER_APPLICATION'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- get person info for recruitment person
  --
  open csr_party_details(p_recruitment_person_id,l_effective_date);
  fetch csr_party_details into l_party_last_update_date
  ,l_party_id
  ,l_last_name
  ,l_first_name
  ,l_date_of_birth
  ,l_title
  ,l_gender
  ,l_marital_status
  ,l_previous_last_name
  ,l_middle_name
  ,l_name_suffix
  ,l_known_as
  ,l_per_information1
  ,l_per_information2
  ,l_per_information18
  ,l_per_information19;
  close csr_party_details;
  --
  open csr_get_vac(p_vacancy_id);
  fetch csr_get_vac into l_business_group_id
  ,l_organization_id
  ,l_job_id
  ,l_position_id
  ,l_grade_id
  ,l_people_group_id
  ,l_location_id
  ,l_recruiter_id
  ,l_manager_id;
  close csr_get_vac;
  --
  open csr_person_id(l_party_id, l_effective_date,l_business_group_id);
  fetch csr_person_id into l_person_id
                          ,l_per_object_version_number
                          ,l_current_employee_flag
                          ,l_current_applicant_flag
                          ,l_current_npw_flag
                          ,l_applicant_number;
  --
  -- check if there is an out of date person
  --
  open csr_person_all_dates(l_party_id, l_business_group_id);
  fetch csr_person_all_dates into l_var;
  --
  if ( csr_person_id%notfound and csr_person_all_dates%found ) then
  --
    close csr_person_id;
    close csr_person_all_dates;
    fnd_message.set_name('PER','IRC_412099_CANNOT_APPLY');
    hr_multi_message.add();
  end if;
  close csr_person_all_dates;
  --
  -- Register Assignment ID
  --
  per_asg_ins.set_base_key_value
    (p_assignment_id => p_assignment_id
    );
  --
  -- Get the work schedule.
  --
  IF(l_position_id IS NOT NULL) THEN
  open csr_pos_default_details(l_position_id);
  fetch csr_pos_default_details into l_time_normal_start
                                   , l_time_normal_finish
                                   , l_normal_hours
                                   , l_frequency;
  close csr_pos_default_details;
  END IF;
  --
  IF (l_organization_id   IS NOT NULL AND
      l_time_normal_start IS NULL     AND l_time_normal_finish IS NULL AND
      l_normal_hours      IS NULL     AND l_frequency iS NULL) THEN
  open csr_org_default_details(l_organization_id);
  fetch csr_org_default_details into l_time_normal_start
                                   , l_time_normal_finish
                                   , l_normal_hours
                                   , l_frequency;
  close csr_org_default_details;
  END IF;
  --
  IF (l_time_normal_start IS NULL AND l_time_normal_finish IS NULL AND
      l_normal_hours      IS NULL AND l_frequency iS NULL) THEN
    open  csr_get_bg_default_details(l_business_group_id);
    fetch csr_get_bg_default_details into l_time_normal_start
                                        , l_time_normal_finish
                                        , l_normal_hours
                                        , l_frequency;
    if csr_get_bg_default_details%NOTFOUND then
    --
      close csr_get_bg_default_details;
    --
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_get_bg_default_details;
  END IF;
  --
  if csr_person_id%found then
  --
    if (l_current_applicant_flag = 'Y') then
      hr_assignment_api.create_secondary_apl_asg
        (p_validate                  => false
        ,p_effective_date            => l_effective_date
        ,p_person_id                 => l_person_id
        ,p_organization_id           => nvl(l_organization_id,l_business_group_id)
        ,p_job_id                    => l_job_id
        ,p_position_id               => l_position_id
        ,p_grade_id                  => l_grade_id
        ,p_people_group_id           => l_people_group_id
        ,p_frequency                 => l_frequency
        ,p_normal_hours              => l_normal_hours
        ,p_time_normal_finish        => l_time_normal_finish
        ,p_time_normal_start         => l_time_normal_start
        ,p_location_id               => l_location_id
        ,p_recruiter_id              => l_recruiter_id
        ,p_supervisor_id             => l_manager_id
        ,p_vacancy_id                => p_vacancy_id
        ,p_posting_content_id        => p_posting_content_id
        ,p_concatenated_segments     => l_concatenated_segments
        ,p_cagr_grade_def_id         => l_cagr_grade_def_id
        ,p_cagr_concatenated_segments=> l_cagr_concatenated_segments
        ,p_group_name                => l_group_name
        ,p_assignment_id             => l_assignment_id
        ,p_soft_coding_keyflex_id    => l_soft_coding_keyflex_id
        ,p_comment_id                => l_comment_id
        ,p_object_version_number     => l_asg_object_version_number
        ,p_effective_start_date      => l_effective_start_date
        ,p_effective_end_date        => l_effective_end_date
        ,p_assignment_sequence       => l_assignment_sequence
        );
    elsif (l_current_employee_flag = 'Y') then
      hr_utility.set_location(l_proc,20);
      --
      hr_employee_api.apply_for_internal_vacancy
        (p_validate                  => false
        ,p_effective_date            => l_effective_date
        ,p_person_id                 => l_person_id
        ,p_applicant_number          => l_applicant_number
        ,p_per_object_version_number => l_per_object_version_number
        ,p_vacancy_id                => p_vacancy_id
        ,p_application_id            => l_application_id
        ,p_assignment_id             => l_assignment_id
        ,p_apl_object_version_number => l_object_version_number_d
        ,p_asg_object_version_number => l_asg_object_version_number
        ,p_assignment_sequence       => l_assignment_sequence
        ,p_per_effective_start_date  => l_effective_start_date
        ,p_per_effective_end_date    => l_effective_end_date);
       --
       hr_assignment_api.update_apl_asg
      (p_effective_date            => l_effective_date
      ,p_datetrack_update_mode     => 'CORRECTION'
      ,p_assignment_id             => l_assignment_id
      ,p_object_version_number     => l_asg_object_version_number
      ,p_posting_content_id        => p_posting_content_id
      ,p_supervisor_id             => l_manager_id
      ,p_concatenated_segments     => l_concatenated_segments
      ,p_cagr_grade_def_id         => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments=> l_cagr_concatenated_segments
      ,p_group_name                => l_group_name
      ,p_comment_id                => l_comment_id
      ,p_soft_coding_keyflex_id    => l_soft_coding_keyflex_id
      ,p_people_group_id           => l_people_group_id
      ,p_frequency                 => l_frequency
      ,p_normal_hours              => l_normal_hours
      ,p_time_normal_finish        => l_time_normal_finish
      ,p_time_normal_start         => l_time_normal_start
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
    elsif (l_current_npw_flag = 'Y') then
      hr_utility.set_location(l_proc,25);
      --
      hr_contingent_worker_api.apply_for_job
      (p_validate                  => false
      ,p_effective_date            => l_effective_date
      ,p_person_id                 => l_person_id
      ,p_object_version_number     => l_per_object_version_number
      ,p_applicant_number          => l_applicant_number
      ,p_vacancy_id                => p_vacancy_id
      ,p_per_effective_start_date  => l_effective_start_date
      ,p_per_effective_end_date    => l_effective_end_date
      ,p_application_id            => l_application_id
      ,p_apl_object_version_number => l_object_version_number_d
      ,p_assignment_id             => l_assignment_id
      ,p_asg_object_version_number => l_asg_object_version_number
      ,p_assignment_sequence       => l_assignment_sequence
      );
      --
      hr_assignment_api.update_apl_asg
      (p_effective_date            => l_effective_date
      ,p_datetrack_update_mode     => 'CORRECTION'
      ,p_assignment_id             => l_assignment_id
      ,p_object_version_number     => l_asg_object_version_number
      ,p_posting_content_id        => p_posting_content_id
      ,p_supervisor_id             => l_manager_id
      ,p_concatenated_segments     => l_concatenated_segments
      ,p_cagr_grade_def_id         => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments=> l_cagr_concatenated_segments
      ,p_group_name                => l_group_name
      ,p_comment_id                => l_comment_id
      ,p_soft_coding_keyflex_id    => l_soft_coding_keyflex_id
      ,p_people_group_id           => l_people_group_id
      ,p_frequency                 => l_frequency
      ,p_normal_hours              => l_normal_hours
      ,p_time_normal_finish        => l_time_normal_finish
      ,p_time_normal_start         => l_time_normal_start
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
   else
      hr_utility.set_location(l_proc,30);
      --
      hr_applicant_api.convert_to_applicant
        (p_validate                  => false
        ,p_effective_date            => l_effective_date
        ,p_person_id                 => l_person_id
        ,p_object_version_number     => l_per_object_version_number
        ,p_applicant_number          => l_applicant_number
        ,p_person_type_id            => l_person_type_id
        ,p_effective_start_date      => l_effective_start_date
        ,p_effective_end_date        => l_effective_end_date);
       --
       open get_new_asg(l_person_id,l_effective_date);
       fetch get_new_asg into l_assignment_id,l_asg_object_version_number;
       close get_new_asg;
      --
      hr_assignment_api.update_apl_asg
      (p_effective_date            => l_effective_date
      ,p_datetrack_update_mode     => 'CORRECTION'
      ,p_assignment_id             => l_assignment_id
      ,p_object_version_number     => l_asg_object_version_number
      ,p_vacancy_id                => p_vacancy_id
      ,p_posting_content_id        => p_posting_content_id
      ,p_organization_id           => nvl(l_organization_id,l_business_group_id)
      ,p_job_id                    => l_job_id
      ,p_position_id               => l_position_id
      ,p_grade_id                  => l_grade_id
      ,p_people_group_id           => l_people_group_id
      ,p_location_id               => l_location_id
      ,p_recruiter_id              => l_recruiter_id
      ,p_supervisor_id             => l_manager_id
      ,p_concatenated_segments     => l_concatenated_segments
      ,p_cagr_grade_def_id         => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments=> l_cagr_concatenated_segments
      ,p_group_name                => l_group_name
      ,p_comment_id                => l_comment_id
      ,p_soft_coding_keyflex_id    => l_soft_coding_keyflex_id
      ,p_frequency                 => l_frequency
      ,p_normal_hours              => l_normal_hours
      ,p_time_normal_finish        => l_time_normal_finish
      ,p_time_normal_start         => l_time_normal_start
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
    end if;
  else
    hr_utility.set_location(l_proc, 40);
    --
    -- Register Person ID
    --
    per_per_ins.set_base_key_value
      (p_person_id => p_person_id);
    --
    l_legislation_code := per_vac_bus.return_legislation_code(p_vacancy_id);
    l_applicant_number:=null;
    if (l_legislation_code = 'JP') then
      hr_applicant_api.create_applicant
        (p_validate                  => false
        ,p_date_received             => l_application_received_date
        ,p_business_group_id         => l_business_group_id
        ,p_last_name                 => l_last_name
        ,p_first_name                => l_first_name
        ,p_per_information18         => l_per_information18
        ,p_per_information19         => l_per_information19
        ,p_date_of_birth             => l_date_of_birth
        ,p_applicant_number          => l_applicant_number
        ,p_previous_last_name        => l_previous_last_name
        ,p_known_as                  => l_known_as
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => l_middle_name
        ,p_suffix                    => l_name_suffix
        ,p_person_id                 => l_person_id
        ,p_assignment_id             => l_assignment_id
        ,p_application_id            => l_application_id
        ,p_per_object_version_number => l_per_object_version_number
        ,p_asg_object_version_number => l_asg_object_version_number
        ,p_apl_object_version_number => l_object_version_number_d
        ,p_per_effective_start_date  => l_effective_start_date
        ,p_per_effective_end_date    => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_per_comment_id            => l_comment_id
        ,p_assignment_sequence       => l_assignment_sequence
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        ,p_party_id                  => l_party_id
        );
    elsif (l_legislation_code = 'KR') then
      hr_applicant_api.create_applicant
        (p_validate                  => false
        ,p_date_received             => l_application_received_date
        ,p_business_group_id         => l_business_group_id
        ,p_last_name                 => l_last_name
        ,p_first_name                => l_first_name
        ,p_per_information1          => l_per_information1
        ,p_per_information2          => l_per_information2
        ,p_date_of_birth             => l_date_of_birth
        ,p_applicant_number          => l_applicant_number
        ,p_previous_last_name        => l_previous_last_name
        ,p_known_as                  => l_known_as
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => l_middle_name
        ,p_suffix                    => l_name_suffix
        ,p_person_id                 => l_person_id
        ,p_assignment_id             => l_assignment_id
        ,p_application_id            => l_application_id
        ,p_per_object_version_number => l_per_object_version_number
        ,p_asg_object_version_number => l_asg_object_version_number
        ,p_apl_object_version_number => l_object_version_number_d
        ,p_per_effective_start_date  => l_effective_start_date
        ,p_per_effective_end_date    => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_per_comment_id            => l_comment_id
        ,p_assignment_sequence       => l_assignment_sequence
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        ,p_party_id                  => l_party_id
        );
    elsif (l_legislation_code = 'ZA') then
      hr_applicant_api.create_applicant
        (p_validate                  => false
        ,p_date_received             => l_application_received_date
        ,p_business_group_id         => l_business_group_id
        ,p_last_name                 => l_last_name
        ,p_first_name                => l_first_name
        ,p_per_information4          => p_per_information4
        ,p_date_of_birth             => l_date_of_birth
        ,p_applicant_number          => l_applicant_number
        ,p_previous_last_name        => l_previous_last_name
        ,p_known_as                  => l_known_as
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => l_middle_name
        ,p_suffix                    => l_name_suffix
        ,p_person_id                 => l_person_id
        ,p_assignment_id             => l_assignment_id
        ,p_application_id            => l_application_id
        ,p_per_object_version_number => l_per_object_version_number
        ,p_asg_object_version_number => l_asg_object_version_number
        ,p_apl_object_version_number => l_object_version_number_d
        ,p_per_effective_start_date  => l_effective_start_date
        ,p_per_effective_end_date    => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_per_comment_id            => l_comment_id
        ,p_assignment_sequence       => l_assignment_sequence
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        ,p_party_id                  => l_party_id
        );
    else
      hr_applicant_api.create_applicant
        (p_validate                  => false
        ,p_date_received             => l_application_received_date
        ,p_business_group_id         => l_business_group_id
        ,p_last_name                 => l_last_name
        ,p_first_name                => l_first_name
        ,p_date_of_birth             => l_date_of_birth
        ,p_applicant_number          => l_applicant_number
        ,p_previous_last_name        => l_previous_last_name
        ,p_known_as                  => l_known_as
        ,p_marital_status            => l_marital_status
        ,p_middle_names              => l_middle_name
        ,p_suffix                    => l_name_suffix
        ,p_person_id                 => l_person_id
        ,p_assignment_id             => l_assignment_id
        ,p_application_id            => l_application_id
        ,p_per_object_version_number => l_per_object_version_number
        ,p_asg_object_version_number => l_asg_object_version_number
        ,p_apl_object_version_number => l_object_version_number_d
        ,p_per_effective_start_date  => l_effective_start_date
        ,p_per_effective_end_date    => l_effective_end_date
        ,p_full_name                 => l_full_name
        ,p_per_comment_id            => l_comment_id
        ,p_assignment_sequence       => l_assignment_sequence
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        ,p_party_id                  => l_party_id
        );
    end if;
    --
    -- get the PTU person type for iRecruitment Candidate
    --
    l_ptu_person_type_id:=hr_person_type_usage_info.get_default_person_type_id
                                           (l_business_group_id,
                                            'IRC_REG_USER');
    --
    -- create the extra PTU entry for iRecruitment Candidate
    --
    hr_per_type_usage_internal.maintain_person_type_usage
    (p_effective_date       => l_effective_start_date
    ,p_person_id            => l_person_id
    ,p_person_type_id       => l_ptu_person_type_id
    );
    hr_utility.set_location(l_proc, 45);
    --
    hr_assignment_api.update_apl_asg
      (p_effective_date            => l_application_received_date
      ,p_datetrack_update_mode     => 'CORRECTION'
      ,p_assignment_id             => l_assignment_id
      ,p_object_version_number     => l_asg_object_version_number
      ,p_vacancy_id                => p_vacancy_id
      ,p_posting_content_id        => p_posting_content_id
      ,p_organization_id           => nvl(l_organization_id,l_business_group_id)
      ,p_job_id                    => l_job_id
      ,p_position_id               => l_position_id
      ,p_grade_id                  => l_grade_id
      ,p_people_group_id           => l_people_group_id
      ,p_location_id               => l_location_id
      ,p_recruiter_id              => l_recruiter_id
      ,p_supervisor_id             => l_manager_id
      ,p_concatenated_segments     => l_concatenated_segments
      ,p_cagr_grade_def_id         => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments=> l_cagr_concatenated_segments
      ,p_group_name                => l_group_name
      ,p_comment_id                => l_comment_id
      ,p_soft_coding_keyflex_id    => l_soft_coding_keyflex_id
      ,p_frequency                 => l_frequency
      ,p_normal_hours              => l_normal_hours
      ,p_time_normal_finish        => l_time_normal_finish
      ,p_time_normal_start         => l_time_normal_start
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      );
  end if;
  close csr_person_id;
  --
  -- Call After Process User Hook
  --
  begin
    irc_party_bk3.registered_user_application_a
    (
       p_effective_date                        => l_effective_date
      ,p_person_id                             => p_person_id
      ,p_applicant_number                      => l_applicant_number
      ,p_application_received_date             => l_application_received_date
      ,p_vacancy_id                            => p_vacancy_id
      ,p_posting_content_id                    => p_posting_content_id
      ,p_assignment_id                         => l_assignment_id
      ,p_asg_object_version_number             => l_asg_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'REGISTERED_USER_APPLICATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When IN validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_object_version_number := l_asg_object_version_number;
  p_per_object_version_number := l_per_object_version_number;
  p_applicant_number := l_applicant_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

  exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to REGISTERED_USER_APPLICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is beINg used.)
    --
    p_asg_object_version_number := null;
    p_per_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --

    -- Check whether csr_person_id is open or not. If open, close it.

    if csr_person_id%isopen then
        close csr_person_id;
    end if;

    rollback to REGISTERED_USER_APPLICATION;
    --
    p_asg_object_version_number := null;
    p_per_object_version_number := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end registered_user_application;
-- -------------------------------------------------------------------------
-- |------------------------< grant_access >-------------------------------|
-- -------------------------------------------------------------------------
procedure grant_access
(p_user_name    IN varchar2
,p_user_id      IN number
,p_menu_id      IN number
,p_resp_id      IN number
,p_resp_appl_id IN number
,p_sec_group_id IN number
,p_grant_name   IN varchar2
,p_description  IN varchar2 default null
) is
srowId VARCHAR2(100);
l_guid raw(16);
begin
  select sys_guid() into l_guid from dual;
  fnd_grants_pkg.insert_row
  (
    X_ROWID        => srowId,
    X_GRANT_GUID   => l_guid,
    X_GRANTEE_TYPE => 'USER',
    X_GRANTEE_KEY  => upper(p_user_name),
    X_MENU_ID      => p_menu_id,
    X_START_DATE   => trunc(sysdate),
    X_END_DATE     => null,
    X_OBJECT_ID    => '-1',
    X_INSTANCE_TYPE => 'GLOBAL',
    X_INSTANCE_SET_ID => null,
    X_INSTANCE_PK1_VALUE => '*NULL*',
    X_INSTANCE_PK2_VALUE => '*NULL*',
    X_INSTANCE_PK3_VALUE => '*NULL*',
    X_INSTANCE_PK4_VALUE => '*NULL*',
    X_INSTANCE_PK5_VALUE => '*NULL*',
    X_PROGRAM_NAME       => 'IRC_API',
    X_PROGRAM_TAG        => null,
    X_CREATION_DATE      => sysdate,
    X_CREATED_BY         => p_user_id,
    X_LAST_UPDATE_DATE   => sysdate,
    X_LAST_UPDATED_BY    => p_user_id,
    X_LAST_UPDATE_LOGIN  => p_user_id,
    X_CTX_SECGRP_ID      => p_sec_group_id,
    X_CTX_RESP_ID        => p_resp_id,
    X_CTX_RESP_APPL_ID   => p_resp_appl_id,
    X_NAME               => p_grant_name,
    X_DESCRIPTION        => p_description
  );
end grant_access;
--
-- -------------------------------------------------------------------------
-- |------------------------< create_user_internal >-----------------------|
-- -------------------------------------------------------------------------
--
procedure create_user_internal
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_first_name                IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ) IS
--
PRAGMA autonomous_transaction;
l_proc          varchar2(72) := g_package||'create_user';
l_person_id     per_all_people_f.person_id%type;
l_user_id       number;
l_profile_check boolean;
l_user_name     fnd_user.user_name%type;
l_default_last_name per_all_people_f.last_name%type;
l_effective_start_date date;
l_effective_end_date date;
l_sec_profile_assignment_id number;
l_business_group_id number;
l_sec_profile_id number;
l_ovn number;
l_menu_name varchar2(30);
l_menu_id number;
l_grant_name varchar2(80);
--
cursor get_menu_id (p_menu_name varchar2) is
select menu_id from fnd_menus where menu_name=upper(p_menu_name);
--
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  -- Create Person
  l_default_last_name := nvl(p_last_name,fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME'));

  irc_party_api.create_registered_user
   (p_last_name              =>    l_default_last_name
   ,p_first_name             =>    p_first_name
   ,p_email_address          =>    p_email
   ,p_effective_start_date   =>    l_effective_start_date
   ,p_effective_end_date     =>    l_effective_end_date
   ,p_person_id              =>    l_person_id
   ,p_allow_access           =>    p_allow_access
   ,p_start_date             =>    p_start_date
   ,p_per_information_category              => p_per_information_category
   ,p_per_information1                      => p_per_information1
   ,p_per_information2                      => p_per_information2
   ,p_per_information3                      => p_per_information3
   ,p_per_information4                      => p_per_information4
   ,p_per_information5                      => p_per_information5
   ,p_per_information6                      => p_per_information6
   ,p_per_information7                      => p_per_information7
   ,p_per_information8                      => p_per_information8
   ,p_per_information9                      => p_per_information9
   ,p_per_information10                     => p_per_information10
   ,p_per_information11                     => p_per_information11
   ,p_per_information12                     => p_per_information12
   ,p_per_information13                     => p_per_information13
   ,p_per_information14                     => p_per_information14
   ,p_per_information15                     => p_per_information15
   ,p_per_information16                     => p_per_information16
   ,p_per_information17                     => p_per_information17
   ,p_per_information18                     => p_per_information18
   ,p_per_information19                     => p_per_information19
   ,p_per_information20                     => p_per_information20
   ,p_per_information21                     => p_per_information21
   ,p_per_information22                     => p_per_information22
   ,p_per_information23                     => p_per_information23
   ,p_per_information24                     => p_per_information24
   ,p_per_information25                     => p_per_information25
   ,p_per_information26                     => p_per_information26
   ,p_per_information27                     => p_per_information27
   ,p_per_information28                     => p_per_information28
   ,p_per_information29                     => p_per_information29
   ,p_per_information30                     => p_per_information30
   );

  --
  hr_utility.set_location(l_proc,20);
  --
  -- Create User and set person_id to employee_id
  --
  l_user_id := fnd_user_pkg.CreateUserId (
  x_user_name                  => p_user_name,
  x_owner                      => 'CUST',
  x_unencrypted_password       => p_password,
  x_email_address              => p_email,
  x_employee_id                => l_person_id,
  x_password_date              => trunc(sysdate));
  --
  hr_utility.set_location(l_proc,30);
  --
  -- set the language profile option
  --
  l_profile_check := fnd_profile.save (
  x_name                =>      'ICX_LANGUAGE',
  x_value               =>      p_language,
  x_level_name          =>      'USER',
  x_level_value         =>      l_user_id );
  --
  hr_utility.set_location(l_proc,40);
  --
  --
  -- add the appropriate responsibility
  --
  fnd_user_resp_groups_api.Insert_Assignment
  (user_id => l_user_id
  ,responsibility_id => p_responsibility_id
  ,responsibility_application_id => p_resp_appl_id
  ,security_group_id => p_security_group_id
  ,start_date => trunc(sysdate)
  ,end_date => null
  ,description => ' ' -- ### description was supposed to default
                            -- to null... but does not look like it has
  );
  hr_utility.set_location(l_proc,50);
  --
  -- look to see if we are using multiple security groups
  --
  if (fnd_profile.value('ENABLE_SECURITY_GROUPS')='Y') then
    hr_utility.set_location(l_proc,60);
    l_sec_profile_id:=fnd_profile.value_specific
    (name=>'PER_SECURITY_PROFILE_ID'
    ,user_id=>l_user_id
    ,responsibility_id=>p_responsibility_id
    ,application_id=>p_resp_appl_id);
    l_business_group_id:=fnd_profile.value_specific
    (name=>'PER_BUSINESS_GROUP_ID'
    ,user_id=>l_user_id
    ,responsibility_id=>p_responsibility_id
    ,application_id=>p_resp_appl_id);
    --
    hr_utility.set_location(l_proc,70);
    per_sec_profile_asg_api.create_security_profile_asg
    (p_sec_profile_assignment_id    => l_sec_profile_assignment_id
    ,p_user_id                      => l_user_id
    ,p_security_group_id            => p_security_group_id
    ,p_business_group_id            => l_business_group_id
    ,p_security_profile_id          => l_sec_profile_id
    ,p_responsibility_id            => p_responsibility_id
    ,p_responsibility_application_i => p_resp_appl_id
    ,p_start_date                   => trunc(sysdate)
    ,p_object_version_number        => l_ovn
    );
  end if;
  hr_utility.set_location(l_proc,90);
  --
  -- Assign the grant to the User
  --
  l_menu_name:=fnd_profile.value_specific
    (name=>'IRC_CANDIDATE_PSET'
    ,user_id=>l_user_id
    ,responsibility_id=>p_responsibility_id
    ,application_id=>p_resp_appl_id);

  open get_menu_id(l_menu_name);
  fetch get_menu_id into l_menu_id;
  close get_menu_id;

  if l_menu_id is not null then
    if length(p_user_name) > 65 then
      l_grant_name := 'IRC_'||substr(p_user_name,1,65)||'_CAND_GRANT';
    else
      l_grant_name := 'IRC_'||upper(p_user_name)||'_CAND_GRANT';
    end if;
    irc_party_api.grant_access(p_user_name=> p_user_name,
                             p_user_id=> l_user_id,
                             p_menu_id=> l_menu_id,
                             p_resp_id=> p_responsibility_id,
                             p_resp_appl_id=> p_resp_appl_id,
                             p_sec_group_id=> p_security_group_id,
                             p_grant_name=> l_grant_name,
                             p_description=>' ');
  end if;
  hr_utility.set_location(l_proc,100);
  --
  -- commit autonomous transaction
  --
  commit;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 110);
end create_user_internal;
--
-- -------------------------------------------------------------------------
-- |------------------------< create_user >--------------------------------|
-- -------------------------------------------------------------------------
--
procedure create_user
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_first_name                IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ) IS
--
l_password_check varchar2(1);
l_password_change_check varchar2(1);
l_allow_access irc_notification_preferences.allow_access%type;
l_start_date date;
cursor get_nls_language is
select nls_language
from fnd_languages
where language_code=p_language;
--
l_nls_language fnd_languages.nls_language%type;
--
begin
  --
  -- Truncate time portion from date
  --
  l_start_date := trunc(p_start_date);
  --
  -- default Allow Access if input value is NULL
  --
  l_allow_access := nvl(p_allow_access,nvl(fnd_profile.value('IRC_VISIBLE_PREF_DEFAULT'),'N'));
  --
  -- Call Before Process User Hook
  --
  begin
    irc_party_bk4.create_user_b
    (
       p_user_name             => p_user_name
      ,p_password              => p_password
      ,p_start_date            => l_start_date
      ,p_email                 => p_email
      ,p_language              => p_language
      ,p_last_name             => p_last_name
      ,p_first_name            => p_first_name
      ,p_allow_access          => l_allow_access
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- get NLS_LANGUAGE
  --
  open get_nls_language;
  fetch get_nls_language into l_nls_language;
  if get_nls_language%notfound then
    close get_nls_language;
    l_nls_language:=p_language;
  else
    close get_nls_language;
  end if;
  --
  -- Validate the password
  --
  l_password_check := fnd_web_sec.validate_password(username => p_user_name
                                                   ,password => p_password);

  if (l_password_check = 'N') then
    fnd_message.raise_error;
  end if;
  --
  -- create party and user
  --
  irc_party_api.create_user_internal(p_user_name => p_user_name
                                    ,p_password  => p_password
                                    ,p_start_date => l_start_date
                                    ,p_email => p_email
                                    ,p_responsibility_id => p_responsibility_id
                                    ,p_resp_appl_id => p_resp_appl_id
                                    ,p_security_group_id => p_security_group_id
                                    ,p_language => l_nls_language
                                    ,p_last_name => p_last_name
                                    ,p_first_name => p_first_name
                                    ,p_allow_access => l_allow_access
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_party_bk4.create_user_a
    (
       p_user_name             => p_user_name
      ,p_password              => p_password
      ,p_start_date            => l_start_date
      ,p_email                 => p_email
      ,p_language              => p_language
      ,p_last_name             => p_last_name
      ,p_first_name            => p_first_name
      ,p_allow_access          => l_allow_access
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER'
        ,p_hook_type   => 'AP'
        );
  end;
--
end create_user;
--
-- Function to encrypt a string using a specified key.
--
function encrypt
  (p_key   in varchar2,
   p_value in varchar2)
  return varchar2
  as language java name 'oracle.apps.fnd.security.WebSessionManagerProc.encrypt(java.lang.String,java.lang.String) return
 java.lang.String';
--
-- Function to decrypt an encrypted string using a specified key.
--
function decrypt
  (p_key in varchar2,
   p_value in varchar2)
  return varchar2
  as language java name 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return
 java.lang.String';
--
-- Returns the foundation password.
--
function get_foundation_password
  return varchar2
is
  guestUserPwd varchar2(200);
  guestUserName varchar2(100);
  guestUserPwdOnly varchar2(100);
  guestFndPwd varchar2(100);
  delim number;
  bad_guest_user exception;

  cursor get_pwd(p_guestUserName varchar2) is
  select encrypted_foundation_password
  from fnd_user
  where user_name = p_guestUserName
  and trunc(sysdate) between start_date and
  nvl(end_date,trunc(sysdate));
  --
  guestEncFndPwd fnd_user.encrypted_foundation_password%type;
  --
begin
  --
  guestUserPwd := upper(FND_WEB_SEC.GET_GUEST_USERNAME_PWD());
  --
  delim := instr(guestUserPwd,'/');
  --
  if(delim = 0) then
    raise bad_guest_user;
  else
    guestUserName := upper(substr(guestUserPwd,1,delim-1));
    guestUserPwdOnly := upper(substr(guestUserPwd,delim+1));
  end if;
  --
  if(fnd_web_sec.validate_login(guestUserName,guestUserPwdOnly) = 'N') then
    raise bad_guest_user;
  end if;
  --
  open get_pwd(guestUserName);
  fetch get_pwd into guestEncFndPwd;
  close get_pwd;
  --
  guestFndPwd := decrypt(guestUserPwd,guestEncFndPwd);
  --
  if(guestFndPwd is null) then
    raise bad_guest_user;
  end if;
  --
  return guestFndPwd;
  --
  exception
    when others then
      fnd_message.set_encoded('MRP'||fnd_global.local_chr(0)||
        'GEN-INVALID PROFILE'||fnd_global.local_chr(0)||
        'N'||fnd_global.local_chr(0)||
        'PROFILE'||fnd_global.local_chr(0)||
        'GUEST_USER_PWD'||fnd_global.local_chr(0)||
        'N'||fnd_global.local_chr(0)||
        'VALUE'||fnd_global.local_chr(0)||
        guestUserPwd||fnd_global.local_chr(0));
      return null;
end;
--
-- -------------------------------------------------------------------------
-- |------------------------< update_user >--------------------------------|
-- -------------------------------------------------------------------------
--
procedure update_user (
  p_user_name                  in varchar2,
  p_owner                      in varchar2,
  p_unencrypted_password       in varchar2 default null,
  p_encrypted_user_password    in varchar2 default null,
  p_session_number             in number default null,
  p_start_date                 in date default null,
  p_end_date                   in date default null,
  p_last_logon_date            in date default null,
  p_description                in varchar2 default null,
  p_password_date              in date default null,
  p_password_accesses_left     in number default null,
  p_password_lifespan_accesses in number default null,
  p_password_lifespan_days     in number default null,
  p_employee_id                in number default null,
  p_email_address              in varchar2 default null,
  p_fax                        in varchar2 default null,
  p_customer_id                in number default null,
  p_supplier_id                in number default null,
  p_old_password               in varchar2 default null) is
l_new_user_name fnd_user.user_name%type;
l_current_email_address fnd_user.email_address%type;
l_central_registration_url varchar2(4000);
--
cursor csr_get_email(p_user_name varchar2) is
select upper(email_address)
from fnd_user
where user_name = p_user_name;
--
begin
  -- get existing email address
  --
  open csr_get_email(p_user_name);
  fetch csr_get_email into l_current_email_address;
  close csr_get_email;
  --
  l_central_registration_url:=fnd_profile.value('APPS_CENTRAL_REGISTER_URL');
  --
 if l_central_registration_url is null then
  --
  fnd_user_pkg.UpdateUser (
  x_user_name                  => p_user_name,
  x_owner                      => p_owner,
  x_unencrypted_password       => p_unencrypted_password,
  x_session_number             => p_session_number,
  x_start_date                 => p_start_date,
  x_end_date                   => p_end_date,
  x_last_logon_date            => p_last_logon_date,
  x_description                => p_description,
  x_password_date              => p_password_date,
  x_password_accesses_left     => p_password_accesses_left,
  x_password_lifespan_accesses => p_password_lifespan_accesses,
  x_password_lifespan_days     => p_password_lifespan_days,
  x_employee_id                => p_employee_id,
  x_email_address              => p_email_address,
  x_fax                        => p_fax,
  x_customer_id                => p_customer_id,
  x_supplier_id                => p_supplier_id);
  --
 end if;
  --
  -- if email address is updated then update user_name
  -- if the existing user_name and email_address match
  --
  l_new_user_name := upper(p_email_address);
  if p_user_name <> l_new_user_name
   and l_current_email_address = p_user_name then
    fnd_user_pkg.change_user_name(p_user_name,l_new_user_name);
  end if;
end update_user;
-- -------------------------------------------------------------------------
-- |------------------------< self_register_user >-------------------------|
-- -------------------------------------------------------------------------
--
procedure self_register_user
   (p_validate                  IN     boolean  default false
   ,p_current_email_address     IN     varchar2
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_first_name                IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_middle_names              IN     varchar2 default null
   ,p_previous_last_name        IN     varchar2 default null
   ,p_employee_number           IN     varchar2 default null
   ,p_national_identifier       IN     varchar2 default null
   ,p_date_of_birth             IN     date     default null
   ,p_email_address             IN     varchar2 default null
   ,p_home_phone_number         IN     varchar2 default null
   ,p_work_phone_number         IN     varchar2 default null
   ,p_address_line_1            IN     varchar2 default null
   ,p_manager_last_name         IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_user_name                 IN     varchar2 default null
   ) is

  cursor email_exists is
  select 1 from fnd_user
  where user_name=upper(p_current_email_address);

  l_date_of_birth date;

  cursor get_prev_emp is
  select per1.party_id,count(*)
  from per_all_people_f per1
  where UPPER(per1.last_name)=UPPER(p_last_name)
  and ( UPPER(per1.first_name)=UPPER(nvl(p_first_name,per1.first_name))
       or (per1.first_name is null and p_first_name is null))
  and ( UPPER(per1.middle_names)= UPPER(nvl(p_middle_names,per1.middle_names))
       or (per1.middle_names is null and p_middle_names is null))
  and ( UPPER(per1.previous_last_name)= UPPER(nvl(p_previous_last_name,per1.previous_last_name))
       or (per1.previous_last_name is null and p_previous_last_name is null))
  and ( UPPER(per1.employee_number)= UPPER(nvl(p_employee_number,per1.employee_number))
       or (per1.employee_number is null and p_employee_number is null))
  and ( UPPER(per1.national_identifier)= UPPER(nvl(p_national_identifier,per1.national_identifier))
       or (per1.national_identifier is null and p_national_identifier is null))
  and (per1.date_of_birth=nvl(l_date_of_birth,per1.date_of_birth)
       or (per1.date_of_birth is null and p_date_of_birth is null))
  and ( UPPER(nvl(per1.email_address,p_email_address))= UPPER(nvl(p_email_address,per1.email_address))
       or (per1.email_address is null and p_email_address is null))
  and (p_home_phone_number is null
       or exists (select 1 from per_phones phns
       where phns.parent_id=per1.person_id
       and phns.parent_table='PER_ALL_PEOPLE_F'
       and phns.phone_type in ('H1','H2','H3')
       and phns.phone_number = p_home_phone_number))
  and (p_work_phone_number is null
       or exists (select 1 from per_phones phns
       where phns.parent_id=per1.person_id
       and phns.parent_table='PER_ALL_PEOPLE_F'
       and phns.phone_type in ('W1','W2','W3')
       and phns.phone_number = p_work_phone_number))
  and (p_address_line_1 is null
      or exists (select 1 from per_addresses addr
      where addr.person_id=per1.person_id
      and addr.address_type in ('H','REC','HOME')))
  and (p_manager_last_name is null
      or exists (select 1 from per_all_people_f per2
      ,per_all_assignments_f asg2
      where asg2.person_id=per1.person_id
      and asg2.assignment_type in ('E','C')
      and asg2.supervisor_id=per2.person_id
      and asg2.effective_start_date between per2.effective_start_date and per2.effective_end_date
      and UPPER(per2.last_name)=UPPER(p_manager_last_name)))
  and exists(SELECT  1
      FROM  per_person_types typ
           ,per_person_type_usages_f ptu
      WHERE typ.system_person_type = 'EX_EMP'
       AND  typ.person_type_id = ptu.person_type_id
       AND  sysdate BETWEEN ptu.effective_start_date
                                 AND ptu.effective_end_date
       AND  ptu.person_id = per1.person_id)
  group by per1.party_id;

l_party_id number;
l_count number;
l_party_id2 number;
l_count2 number;

cursor current_emp(p_party_id number) is
select 1
from per_all_people_f per1
where per1.party_id=p_party_id
and trunc(sysdate) between per1.effective_start_date and per1.effective_end_date
and current_employee_flag='Y';

l_dummy number;

cursor in_reg_bg(p_party_id number) is
select per1.person_id
from per_all_people_f per1
where per1.party_id=p_party_id
and trunc(sysdate) between per1.effective_start_date and per1.effective_end_date
and per1.business_group_id = fnd_profile.value('IRC_REGISTRATION_BG_ID');

l_person_id number;

cursor has_notification_prefs(p_party_id number) is
select notif.person_id
from irc_notification_preferences notif
where notif.party_id=p_party_id;

l_notif_person_id number;
l_object_version_number    number;
l_notification_preference_id number;
l_search_criteria_id number;

cursor has_work_prefs(p_person_id number) is
select prefs.object_id
from irc_search_criteria prefs
where prefs.object_id=p_person_id
and prefs.object_type='WPREF';

cursor get_last_emp_rec(p_party_id number) is
select per1.person_id
from per_all_people_f per1
where per1.party_id=p_party_id
and per1.current_employee_flag='Y'
and per1.effective_start_date<sysdate
order by per1.effective_end_date desc;

cursor get_last_per_rec(p_party_id number) is
select per1.person_id
from per_all_people_f per1
where per1.party_id=p_party_id
and per1.effective_start_date<sysdate
order by per1.effective_end_date desc;

cursor get_bg(p_person_id number) is
select per1.business_group_id
,per1.object_version_number
,per1.employee_number
,per1.effective_start_date
from per_all_people_f per1
where per1.person_id=p_person_id
and trunc(sysdate) between per1.effective_start_date and per1.effective_end_date;

l_person_ovn number;
l_employee_number varchar2(255);
l_business_group_id number;
l_ptu_person_type_id number;
l_person_start_date date;
l_dt_mode varchar2(30);

cursor ptu_exists(p_person_id number,p_person_type_id number) is
select 1 from per_person_type_usages_f ptuf
where ptuf.person_id=p_person_id
and   ptuf.person_type_id=p_person_type_id
and trunc(sysdate) between ptuf.effective_start_date and ptuf.effective_end_date;

cursor existing_emails(p_person_id number,p_party_id number) is
select fusr.user_name
from fnd_user fusr
where fusr.employee_id=p_person_id
and trunc(sysdate) between fusr.start_date and
  nvl(fusr.end_date,trunc(sysdate))
union
select fusr.user_name
from fnd_user fusr
where fusr.customer_id=p_party_id
and trunc(sysdate) between fusr.start_date and
  nvl(fusr.end_date,trunc(sysdate));

cursor user_association_exists(p_user_name varchar2) is
select 1
from fnd_user fusr
where fusr.user_name=p_user_name
and fusr.employee_id is not null;

cursor get_user_id(p_user_name varchar2) is
select fusr.user_id
from fnd_user fusr
where fusr.user_name=p_user_name;
--
cursor get_menu_id (p_menu_name varchar2)is
select menu_id from fnd_menus where menu_name=upper(p_menu_name);
--
cursor get_party_id(p_user_name varchar2) is
select fusr.person_party_id
from fnd_user fusr
where fusr.user_name=p_user_name;
--
l_user_id       number;
l_profile_check boolean;
l_sec_profile_assignment_id number;
l_business_group_id2 number;
l_sec_profile_id number;
l_password varchar2(30);
l_effective_start_date     date;
l_effective_end_date       date;
l_full_name                per_all_people_f.full_name%type;
l_comment_id               number;
l_name_combination_warning boolean;
l_assign_payroll_warning   boolean;
l_orig_hire_warning        boolean;
l_nid             number;
l_subject varchar2(32000);
l_html_body varchar2(32000);
l_text_body varchar2(32000);
l_passchar varchar2(1);
l_oldpasschar varchar2(1);
l_num number;
l_function_name varchar2(30);
l_func_check varchar2(1);
l_menu_name varchar2(30);
l_menu_id number;
l_grant_name varchar2(80);
l_resp_exists boolean;
l_allow_access irc_notification_preferences.allow_access%type;
l_sso_enabled varchar2(30);
l_central_registration_url varchar2(4000);
l_purge_party_id number;
--
cursor get_nls_language is
select nls_language
from fnd_languages
where language_code=p_language;
--
l_nls_language fnd_languages.nls_language%type;
--
l_proc          varchar2(72) := g_package||'self_register_user';
--
l_password_length number;
l_min_password_length number := 8;

begin

  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint SELF_REGISTER_USER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_of_birth := trunc(p_date_of_birth);
  --
  -- default Allow Access if input value is NULL
  --
  if p_allow_access is NULL then
    l_allow_access := nvl(fnd_profile.value_specific
                      (name=>'IRC_VISIBLE_PREF_DEFAULT'
                      ,responsibility_id=>p_responsibility_id
                      ,application_id=>p_resp_appl_id), 'N');
  else
    l_allow_access := p_allow_access;
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PARTY_BK6.SELF_REGISTER_USER_B
    (p_current_email_address                 => p_current_email_address
    ,p_responsibility_id                     => p_responsibility_id
    ,p_resp_appl_id                          => p_resp_appl_id
    ,p_security_group_id                     => p_security_group_id
    ,p_first_name                            => p_first_name
    ,p_last_name                             => p_last_name
    ,p_middle_names                          => p_middle_names
    ,p_previous_last_name                    => p_previous_last_name
    ,p_employee_number                       => p_employee_number
    ,p_national_identifier                   => p_national_identifier
    ,p_date_of_birth                         => l_date_of_birth
    ,p_email_address                         => p_email_address
    ,p_home_phone_number                     => p_home_phone_number
    ,p_work_phone_number                     => p_work_phone_number
    ,p_address_line_1                        => p_address_line_1
    ,p_manager_last_name                     => p_manager_last_name
    ,p_allow_access                          => l_allow_access
    ,p_language                              => p_language
    ,p_user_name                             => p_user_name
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'SELF_REGISTER_USER'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc,20);

  --
  -- Process Logic
  --
  if p_user_name is null then
    -- use the FND API to determine if a user exists with the same user name
    hr_utility.set_location(l_proc,23);
    l_num := TestUserName(p_user_name=>upper(p_current_email_address));
    if l_num = 2 or l_num = 4 then
      -- the e-mail address is already in use. Raise an error
      fnd_message.set_name('PER','IRC_EXEMP_EMAIL_IN_USE');
      fnd_message.raise_error;
    elsif l_num = 3 then
      fnd_message.set_name('PER','IRC_412220_USER_SYNCH_MSG');
      fnd_message.raise_error;
    elsif l_num = 1 then
      fnd_message.set_name('FND','INVALID_USER_NAME');
      fnd_message.set_token('UNAME',p_current_email_address);
      fnd_message.raise_error;
    end if;
  else
    hr_utility.set_location(l_proc,26);
    -- check if the user account is already associated to a person
    open user_association_exists(p_user_name);
    fetch user_association_exists into l_dummy;
    if user_association_exists%found then
      close user_association_exists;
      fnd_message.set_name('PER','IRC_EXEMP_PERSON_LINK_EXISTS');
      fnd_message.raise_error;
    else
      close user_association_exists;
    end if;
  end if;
  hr_utility.set_location(l_proc,30);

  open get_prev_emp;
  fetch get_prev_emp into l_party_id,l_count;
  if get_prev_emp%notfound then
    -- we have not found a match at all, so error out
    close get_prev_emp;
    fnd_message.set_name('PER','IRC_EXEMP_NO_RECORD_FOUND');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,40);

  fetch get_prev_emp into l_party_id2,l_count2;
  if get_prev_emp%found then
    -- we have found more than one match, so error out
    close get_prev_emp;
    fnd_message.set_name('PER','IRC_EXEMP_MANY_RECORDS_FOUND');
    fnd_message.raise_error;
  end if;
  close get_prev_emp;
    hr_utility.set_location(l_proc,50);

  -- we have only one match, so check their credentials.
  open current_emp(l_party_id);
  fetch current_emp into l_dummy;
  if current_emp%found then
    close current_emp;
    -- the person is a current employee, so error
    fnd_message.set_name('PER','IRC_EXEMP_CURRENT_EMP');
    fnd_message.raise_error;
  end if;
  close current_emp;
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(l_proc,60);

  -- the person is not a current employee, so good to go.
  -- look to see if they have any notification preferences already
  open has_notification_prefs(l_party_id);
  fetch has_notification_prefs into l_person_id;
  if has_notification_prefs%found then
    close has_notification_prefs;
    -- we have notification preferences already for this person, so use that as
    -- the primary person
  else
    close has_notification_prefs;
    hr_utility.set_location(l_proc,70);
    open in_reg_bg(l_party_id);
    fetch in_reg_bg into l_person_id;
    if in_reg_bg%found then
      close in_reg_bg;
      -- the person exists in the registration business group, so use that
      -- as the primary person record
    else
      close in_reg_bg;
       hr_utility.set_location(l_proc,80);

      -- the person is not in the registration business group, look to
      -- find their last employee record
      open get_last_emp_rec(l_party_id);
      fetch get_last_emp_rec into l_person_id;
      if get_last_emp_rec%notfound then
        --could not find an old employee record, so find the last record
        close get_last_emp_rec;
        hr_utility.set_location(l_proc,90);

        open get_last_per_rec(l_party_id);
        fetch get_last_per_rec into l_person_id;
        close get_last_per_rec;
      else
        close get_last_emp_rec;
      end if;
    end if;
    -- we have gone through all of the options, and found the best person_id
    -- for this person, so now create their notification preferences
    hr_utility.set_location(l_proc,100);

    irc_notification_prefs_api.create_notification_prefs
    (p_validate=>false
    ,p_person_id =>l_person_id
    ,p_effective_date=>trunc(sysdate)
    ,p_notification_preference_id=>l_notification_preference_id
    ,p_object_version_number =>l_object_version_number
    ,p_allow_access => l_allow_access);

  end if;
  hr_utility.set_location(l_proc,110);

  -- look for work preferences for the person
  open has_work_prefs(l_person_id);
  fetch has_work_prefs into l_dummy;
  if has_work_prefs%notfound then
    -- no work preferences, so create some
    close has_work_prefs;
    --
    hr_utility.set_location(l_proc,120);

    irc_search_criteria_api.create_work_choices
    (p_validate=>false
    ,p_effective_date=>trunc(sysdate)
    ,p_person_id =>l_person_id
    ,p_employee=>'Y'
    ,p_contractor=>'Y'
    ,p_object_version_number=>l_object_version_number
    ,p_search_criteria_id=>l_search_criteria_id);
  else
    close has_work_prefs;
  end if;

  -- get the PTU person type for iRecruitment Candidate
  --
    hr_utility.set_location(l_proc,130);
  --
  open get_bg(l_person_id);
  fetch get_bg into l_business_group_id
  ,l_person_ovn
  ,l_employee_number
  ,l_person_start_date;
  close get_bg;

  l_ptu_person_type_id:=hr_person_type_usage_info.get_default_person_type_id
                                         (l_business_group_id,
                                          'IRC_REG_USER');
  open ptu_exists(l_person_id,l_ptu_person_type_id);
  fetch ptu_exists into l_dummy;
  if ptu_exists%notfound then
    close ptu_exists;
    hr_utility.set_location(l_proc,140);

    hr_per_type_usage_internal.maintain_person_type_usage
    (p_effective_date       => trunc(sysdate)
    ,p_person_id            => l_person_id
    ,p_person_type_id       => l_ptu_person_type_id
    );
  else
    close ptu_exists;
  end if;
  --
  -- close off the old user accounts for this person
  --
    hr_utility.set_location(l_proc,150);

  for user_rec in existing_emails(l_person_id,l_party_id) loop
    fnd_user_pkg.disableUser(user_rec.user_name);
  end loop;
  --
  -- Get the Password Length from the profile
  --
  begin
       if fnd_profile.value('SIGNON_PASSWORD_LENGTH') is not null then
          l_password_length := fnd_profile.value('SIGNON_PASSWORD_LENGTH');
       else
          l_password_length := l_min_password_length;
       end if;
  exception
      when others then
          l_password_length := l_min_password_length;
  end;
  --
  -- Ensure password length is minumum of 8
  --
  if ( l_password_length < l_min_password_length ) then
      l_password_length := l_min_password_length;
  end if;
  --
  --
  -- create the new user account
  --
  if p_user_name is null then
    l_oldpasschar:='A';
    loop
      --l_passchar:=dbms_random.string('U',1);
  -- the following line has an ATG CU3 dependency. If you need to update and
  -- release the patch before that, comment it out and replace with the line above
  --
      l_passchar:=fnd_crypto.RandomString(len=>1);
      if (l_passchar<>l_oldpasschar) then
        l_password:=l_password||l_passchar;
        l_oldpasschar:=l_passchar;
      end if;
      if length(l_password)=l_password_length then
        exit;
      end if;
    end loop;
    --l_password:=l_password||floor(dbms_random.value(0,9));
  -- the following line has an ATG CU3 dependency. If you need to update and
  -- release the patch before that, comment it out and replace with the line above
  --
    l_password:=l_password||mod(fnd_crypto.randomnumber,10);

    hr_utility.set_location(l_proc,160);

    l_user_id := fnd_user_pkg.CreateUserId (
    x_user_name                  => upper(p_current_email_address),
    x_owner                      => 'CUST',
    x_unencrypted_password       => l_password,
    x_employee_id                => l_person_id);

  else
    -- associate the previous employee record to the fnd user
    hr_utility.set_location(l_proc,165);
    open get_party_id(p_user_name =>p_user_name) ;
    fetch get_party_id into l_purge_party_id;
    close get_party_id;
    hr_utility.set_location(l_proc,166);

    fnd_user_pkg.UpdateUserParty(
      x_user_name          => p_user_name,
      x_owner              => 'CUST',
      x_person_party_id    => l_party_id);

    hr_utility.set_location(l_proc,167);

    if l_purge_party_id is not null then
       hr_utility.set_location(l_proc,168);
       per_hrtca_merge.purge_person(p_person_id=>-1 ,p_party_id=>l_purge_party_id );
    end if;
    hr_utility.set_location(l_proc,169);
    -- get the user ID for the given user name
    open get_user_id(p_user_name);
    fetch get_user_id into l_user_id;
    close get_user_id;
  end if;
  --
  -- get NLS_LANGUAGE
  --
  open get_nls_language;
  fetch get_nls_language into l_nls_language;
  if get_nls_language%notfound then
    close get_nls_language;
    l_nls_language:=p_language;
  else
    close get_nls_language;
  end if;

  -- set the language prefs if required
  if (p_language is not null) then
    l_profile_check := fnd_profile.save (
    x_name                =>      'ICX_LANGUAGE',
    x_value               =>      l_nls_language,
    x_level_name          =>      'USER',
    x_level_value         =>      l_user_id );
  end if;
  hr_utility.set_location(l_proc,170);
  -- If this is an existing user, check if he has the required responsibility
  if p_user_name is null then
    l_resp_exists := false;
  else
    hr_utility.set_location(l_proc,175);
    l_resp_exists := fnd_user_resp_groups_api.Assignment_Exists(l_user_id,
                     p_responsibility_id, p_resp_appl_id, p_security_group_id);
  end if;
  -- if the User doesn't have the responsibility, assign it.
  if NOT l_resp_exists then
    --
    -- add the appropriate responsibility
    --
    fnd_user_resp_groups_api.Insert_Assignment
    (user_id => l_user_id
    ,responsibility_id => p_responsibility_id
    ,responsibility_application_id => p_resp_appl_id
    ,security_group_id => p_security_group_id
    ,start_date => trunc(sysdate)
    ,end_date => null
    ,description => ' ' -- ### description was supposed to default
                              -- to null... but does not look like it has
    );
    hr_utility.set_location(l_proc,180);
    --
    -- look to see if we are using multiple security groups
    --
    if (fnd_profile.value('ENABLE_SECURITY_GROUPS')='Y') then
      hr_utility.set_location(l_proc,190);
      l_sec_profile_id:=fnd_profile.value_specific
      (name=>'PER_SECURITY_PROFILE_ID'
      ,user_id=>l_user_id
      ,responsibility_id=>p_responsibility_id
      ,application_id=>p_resp_appl_id);
      l_business_group_id2:=fnd_profile.value_specific
      (name=>'PER_BUSINESS_GROUP_ID'
      ,user_id=>l_user_id
      ,responsibility_id=>p_responsibility_id
      ,application_id=>p_resp_appl_id);
      --
      hr_utility.set_location(l_proc,200);
      per_sec_profile_asg_api.create_security_profile_asg
      (p_sec_profile_assignment_id    => l_sec_profile_assignment_id
      ,p_user_id                      => l_user_id
      ,p_security_group_id            => p_security_group_id
      ,p_business_group_id            => l_business_group_id2
      ,p_security_profile_id          => l_sec_profile_id
      ,p_responsibility_id            => p_responsibility_id
      ,p_responsibility_application_i => p_resp_appl_id
      ,p_start_date                   => trunc(sysdate)
      ,p_object_version_number        => l_object_version_number
      );
    end if;
  else
    hr_utility.set_location(l_proc, 205);
    --
    -- reopen the candidate responsibility
    --
    fnd_user_resp_groups_api.Update_Assignment
    (user_id => l_user_id
    ,responsibility_id => p_responsibility_id
    ,responsibility_application_id => p_resp_appl_id
    ,security_group_id => p_security_group_id
    ,start_date => trunc(sysdate)
    ,end_date => null
    ,description => ' ' -- ### description was supposed to default
                        -- to null... but does not look like it has
    );
    -- REVISIT, what about Security Profile Assignment
  end if;
  --
  hr_utility.set_location(l_proc,210);

  if trunc(sysdate)=l_person_start_date then
    l_dt_mode:='CORRECTION';
  else
    l_dt_mode:='UPDATE';
  end if;
  -- now update the person record to set the e-mail address
  hr_person_api.update_person
  (p_validate                  => false
  ,p_effective_date            => trunc(sysdate)
  ,p_datetrack_update_mode     => l_dt_mode
  ,p_person_id                 => l_person_id
  ,p_employee_number           => l_employee_number
  ,p_email_address             => p_current_email_address
  ,p_object_version_number     => l_person_ovn
  ,p_effective_start_date      => l_effective_start_date
  ,p_effective_end_date        => l_effective_end_date
  ,p_full_name                 => l_full_name
  ,p_comment_id                => l_comment_id
  ,p_name_combination_warning  => l_name_combination_warning
  ,p_assign_payroll_warning    => l_assign_payroll_warning
  ,p_orig_hire_warning         => l_orig_hire_warning
  );
  --
  -- now send an e-mail to the user confirming that this has been done
  --
  hr_utility.set_location(l_proc,220);
  l_sso_enabled:=fnd_profile.value('APPS_SSO');

  l_central_registration_url:=fnd_profile.value('APPS_CENTRAL_REGISTER_URL');

  l_nid:=wf_notification.send(  upper(p_current_email_address)
                           ,  fnd_profile.value('IRC_WORKFLOW_ITEM_TYPE')
                           ,  'IRC_TEXT_HTML_MSG'
                           );
  --
  fnd_message.set_name('PER','IRC_EXEMP_SUBJECT');
  l_subject:=fnd_message.get;
  wf_notification.setAttrText ( l_nid , 'SUBJECT'   , l_subject);

  if p_user_name is null
  and (l_sso_enabled<>'SSWA_SSO' and l_sso_enabled<>'SSO_SDK') then
    fnd_message.set_name('PER','IRC_EXEMP_HTML');
  elsif l_central_registration_url is not null then
    fnd_message.set_name('PER','IRC_EXEMP_REGISTERED_HTML');
  else
    fnd_message.set_name('PER','IRC_412581_EXEMP_SSO_REG_HTML');
  end if;
  l_html_body:=fnd_message.get;

  if p_user_name is null
  and (l_sso_enabled<>'SSWA_SSO' and l_sso_enabled<>'SSO_SDK') then
    fnd_message.set_name('PER','IRC_EXEMP_HTML');
  elsif l_central_registration_url is not null then
    fnd_message.set_name('PER','IRC_EXEMP_REGISTERED_HTML');
  else
    fnd_message.set_name('PER','IRC_412581_EXEMP_SSO_REG_HTML');
  end if;

  if (instrb(l_html_body,'&'||'PASSWORD')>0) then
    fnd_message.set_token('PASSWORD', l_password);
  end if;
  if (instrb(l_html_body,'&'||'FIRST_NAME')>0) then
    fnd_message.set_token('FIRST_NAME', p_first_name);
  end if;
  if (instrb(l_html_body,'&'||'LAST_NAME')>0) then
    fnd_message.set_token('LAST_NAME', p_last_name);
  end if;
  if (instrb(l_html_body,'&'||'EMAIL')>0) then
    fnd_message.set_token('EMAIL', p_current_email_address);
  end if;
  if (instrb(l_html_body,'&'||'USER_NAME')>0) then
    fnd_message.set_token('USER_NAME', p_user_name);
  end if;
  l_html_body:=fnd_message.get;
  irc_notification_helper_pkg.set_v2_attributes
    (p_wf_attribute_value  => l_html_body
    ,p_wf_attribute_name   => 'HTML_BODY'
    ,p_nid                 => l_nid);


  if p_user_name is null
  and (l_sso_enabled<>'SSWA_SSO' and l_sso_enabled<>'SSO_SDK') then
    fnd_message.set_name('PER','IRC_EXEMP_TEXT');
  elsif l_central_registration_url is not null then
    fnd_message.set_name('PER','IRC_EXEMP_REGISTERED_TEXT');
  else
    fnd_message.set_name('PER','IRC_412582_EXEMP_SSO_REG_TEXT');
  end if;

  l_text_body:=fnd_message.get;

  if p_user_name is null
  and (l_sso_enabled<>'SSWA_SSO' and l_sso_enabled<>'SSO_SDK') then
    fnd_message.set_name('PER','IRC_EXEMP_TEXT');
  elsif l_central_registration_url is not null then
    fnd_message.set_name('PER','IRC_EXEMP_REGISTERED_TEXT');
  else
    fnd_message.set_name('PER','IRC_412582_EXEMP_SSO_REG_TEXT');
  end if;

  if (instrb(l_text_body,'&'||'PASSWORD')>0) then
    fnd_message.set_token('PASSWORD', l_password);
  end if;
  if (instrb(l_text_body,'&'||'FIRST_NAME')>0) then
    fnd_message.set_token('FIRST_NAME', p_first_name);
  end if;
  if (instrb(l_text_body,'&'||'LAST_NAME')>0) then
    fnd_message.set_token('LAST_NAME', p_last_name);
  end if;
  if (instrb(l_text_body,'&'||'EMAIL')>0) then
    fnd_message.set_token('EMAIL', p_current_email_address);
  end if;
  if (instrb(l_text_body,'&'||'USER_NAME')>0) then
    fnd_message.set_token('USER_NAME', p_user_name);
  end if;
  l_text_body:=fnd_message.get;
  irc_notification_helper_pkg.set_v2_attributes
    (p_wf_attribute_value  => l_text_body
    ,p_wf_attribute_name   => 'TEXT_BODY'
    ,p_nid                 => l_nid);
  wf_notification.denormalize_notification(l_nid);
  hr_utility.set_location(l_proc,230);
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PARTY_BK6.SELF_REGISTER_USER_A
    (p_current_email_address                 => p_current_email_address
    ,p_responsibility_id                     => p_responsibility_id
    ,p_resp_appl_id                          => p_resp_appl_id
    ,p_security_group_id                     => p_security_group_id
    ,p_first_name                            => p_first_name
    ,p_last_name                             => p_last_name
    ,p_middle_names                          => p_middle_names
    ,p_previous_last_name                    => p_previous_last_name
    ,p_employee_number                       => p_employee_number
    ,p_national_identifier                   => p_national_identifier
    ,p_date_of_birth                         => l_date_of_birth
    ,p_email_address                         => p_email_address
    ,p_home_phone_number                     => p_home_phone_number
    ,p_work_phone_number                     => p_work_phone_number
    ,p_address_line_1                        => p_address_line_1
    ,p_manager_last_name                     => p_manager_last_name
    ,p_allow_access                          => l_allow_access
    ,p_language                              => p_language
    ,p_user_name                             => p_user_name
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'SELF_REGISTER_USER'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When IN validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
    hr_utility.set_location(' Leaving:'||l_proc, 240);

  exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to SELF_REGISTER_USER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 250);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to SELF_REGISTER_USER;
    --
    --
    hr_utility.set_location(' Leaving:'||l_proc, 260);
    raise;

end self_register_user;

-- -------------------------------------------------------------------------
-- |------------------------< create_partial_user >-------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE create_partial_user
  (p_user_name                  IN      varchar2
  ,p_start_date                 IN      date     default null
  ,p_email                      IN      varchar2 default null
  ,p_language                   IN      varchar2 default null
  ,p_last_name                  IN      varchar2 default null
  ,p_first_name                 IN      varchar2 default null
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ,p_allow_access               IN      varchar2 default null
  )is
  --
  l_allow_access irc_notification_preferences.allow_access%type;
  l_start_date date;
  --
  cursor get_nls_language is
  select nls_language
  from fnd_languages
  where language_code=p_language;
  --
  l_user_id number;
  l_person_id number;
  l_person_party_id number;
  l_first_name per_all_people_f.first_name%type;
  l_last_name per_all_people_f.last_name%type;
  l_email_address per_all_people_f.email_address%type;
  l_default_last_name per_all_people_f.last_name%type;
  --
  cursor get_person_party_info is
  select user_id, employee_id, person_party_id
  from fnd_user
  where user_name=upper(p_user_name);
  --
  cursor get_email_address is
  select nvl(fu.email_address, hzp.email_address)
  from fnd_user fu, hz_parties hzp
  where user_name=upper(p_user_name)
  and fu.person_party_id=hzp.party_id(+);
  --
  cursor get_notif_prefs(p_party_id number) is
  select notification_preference_id
  from irc_notification_preferences
  where party_id=p_party_id;
  --
  cursor get_bg(p_person_id number) is
  select per1.business_group_id,per1.object_version_number,per1.employee_number
        ,per1.effective_start_date
  from per_all_people_f per1
  where per1.person_id=p_person_id
  and trunc(sysdate) between per1.effective_start_date and per1.effective_end_date;
  --
  cursor ptu_exists(p_person_id number,p_person_type_id number) is
  select 1 from per_person_type_usages_f ptuf
  where ptuf.person_id=p_person_id
  and   ptuf.person_type_id=p_person_type_id
  and trunc(sysdate) between ptuf.effective_start_date and ptuf.effective_end_date;
  --
  cursor get_menu_id (p_menu_name varchar2)is
  select menu_id from fnd_menus where menu_name=upper(p_menu_name);
  --
  l_nls_language fnd_languages.nls_language%type;
  --
  --
  -- dummy variables
  --
  l_tmp_resp_id number;
  l_object_version_number    per_all_people_f.object_version_number%type;
  l_effective_start_date     per_all_people_f.effective_start_date%type;
  l_effective_end_date       per_all_people_f.effective_end_date%type;
  l_new_person_id      PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
  l_profile_check boolean;
  l_search_criteria_id number;
  l_sc_ovn number;
  l_notif_preference_id number;
  l_notif_ovn number;
  l_per_type varchar2(100);
  l_sec_profile_assignment_id number;
  l_business_group_id number;
  l_sec_profile_id number;
  l_ovn number;
  l_ptu_person_type_id number;
  l_pers_business_group_id number;
  l_person_ovn number;
  l_employee_number varchar2(255);
  l_person_start_date date;
  l_dt_mode varchar2(30);
  l_full_name per_all_people_f.full_name%type;
  l_comment_id number;
  l_name_combination_warning boolean;
  l_assign_payroll_warning boolean;
  l_orig_hire_warning boolean;
  l_resp_exists boolean;
  l_dummy number;
  l_function_name varchar2(30);
  l_func_check varchar2(1);
  l_menu_name varchar2(30);
  l_menu_id number;
  l_grant_name varchar2(80);
  --
  l_proc varchar2(72) := g_package||'create_partial_user';
  --
  begin
    hr_utility.set_location(' Entering: '||l_proc, 10);
    --
    -- Truncate time portion from date
    --
    l_start_date := trunc(p_start_date);
    --
    -- get NLS_LANGUAGE
    --
    open get_nls_language;
    fetch get_nls_language into l_nls_language;
    if get_nls_language%notfound then
      close get_nls_language;
      l_nls_language:=p_language;
    else
      close get_nls_language;
    end if;
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- default Allow Access if input value is NULL
    --
    l_allow_access := nvl(p_allow_access,nvl(fnd_profile.value('IRC_VISIBLE_PREF_DEFAULT'),'N'));
    --
    open get_person_party_info;
    fetch get_person_party_info into l_user_id, l_person_id, l_person_party_id;
    close get_person_party_info;
    --
    -- if input email address is not null, use it rather than one from fnd_user
    --
    if p_email is not null then
      l_email_address := p_email;
    else
      -- if input email is NULL, try getting it from FND_USER
      -- and if it is NULL try getting it from HZ_PARTIES
      -- and if that is NULL, use the UserName
      open get_email_address;
      fetch get_email_address into l_email_address;
      close get_email_address;

      if l_email_address is null then
        l_email_address := p_user_name;
      end if;
    end if;
    --
    hr_utility.set_location(l_proc, 30);
    -- Disable Partial Registration for Employees
    -- we have to REVISIT after using UMX support for Registration
    if l_person_id is not null then
      l_per_type := irc_utilities_pkg.get_emp_spt_for_person(l_person_id, trunc(p_start_date));
      if (l_per_type = 'EMP') then
        fnd_message.set_name('PER','IRC_412224_EMP_PARTIAL_REG');
        fnd_message.raise_error;
      end if;
    end if;
    --
    hr_utility.set_location(l_proc, 40);
   --intialize the first name
    l_first_name := p_first_name;
        -- there is no person attached to this FND_USER. We need to create a new
    -- iRecruitment Candidate, update FND user with the person_id,
    -- set Language profile and Create Work Preferences
    if l_person_id is NULL then
      l_default_last_name := nvl(p_last_name,fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME'));

      IRC_PARTY_API.CREATE_CANDIDATE_INTERNAL
      (p_business_group_id     => p_reg_bg_id
      ,p_last_name             => l_default_last_name
      ,p_first_name            => l_first_name
      ,p_email_address         => l_email_address
      ,p_allow_access          => l_allow_access
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date
      ,p_person_id             => l_person_id
      ,p_party_id              => l_person_party_id
      ,p_start_date            => l_start_date
      );
      --
      hr_utility.set_location(l_proc, 50);
      --
      fnd_user_pkg.UpdateUser
      (x_user_name => p_user_name
      ,x_owner     => 'CUST'
      ,x_employee_id => l_person_id);
      --
      hr_utility.set_location(l_proc, 60);
      --
      l_profile_check := fnd_profile.save (
      x_name                =>      'ICX_LANGUAGE',
      x_value               =>      l_nls_language,
      x_level_name          =>      'USER',
      x_level_value         =>      l_user_id );
      --
      hr_utility.set_location(l_proc, 70);
      --
      -- create work preferences
      irc_search_criteria_api.create_work_choices
      (p_effective_date=>trunc(sysdate)
      ,p_person_id =>l_person_id
      ,p_employee=>'Y'
      ,p_contractor=>'Y'
      ,p_object_version_number=>l_sc_ovn
      ,p_search_criteria_id=>l_search_criteria_id);
      --
      hr_utility.set_location(l_proc, 80);
    else
      hr_utility.set_location(l_proc, 45);
      open get_bg(l_person_id);
      fetch get_bg into l_pers_business_group_id, l_person_ovn,
                        l_employee_number,l_person_start_date;
      close get_bg;
      if trunc(sysdate)=l_person_start_date then
        l_dt_mode:='CORRECTION';
      else
        l_dt_mode:='UPDATE';
      end if;
      -- update the person record with the email address
      hr_person_api.update_person
      (p_validate                  => false
      ,p_effective_date            => trunc(sysdate)
      ,p_datetrack_update_mode     => l_dt_mode
      ,p_person_id                 => l_person_id
      ,p_object_version_number     => l_person_ovn
      ,p_employee_number           => l_employee_number
      ,p_email_address             => l_email_address
      ,p_effective_start_date      => l_effective_start_date
      ,p_effective_end_date        => l_effective_end_date
      ,p_full_name                 => l_full_name
      ,p_comment_id                => l_comment_id
      ,p_name_combination_warning  => l_name_combination_warning
      ,p_assign_payroll_warning    => l_assign_payroll_warning
      ,p_orig_hire_warning         => l_orig_hire_warning
      );
      --
      l_ptu_person_type_id:=hr_person_type_usage_info.get_default_person_type_id
                            (l_pers_business_group_id, 'IRC_REG_USER');
      if l_ptu_person_type_id is not null then
        open ptu_exists(l_person_id,l_ptu_person_type_id);
        fetch ptu_exists into l_dummy;
        if ptu_exists%notfound then
          close ptu_exists;
          hr_utility.set_location(l_proc,140);
          hr_per_type_usage_internal.maintain_person_type_usage
          (p_effective_date       => trunc(sysdate)
          ,p_person_id            => l_person_id
          ,p_person_type_id       => l_ptu_person_type_id
          );
        else
          close ptu_exists;
        end if;
      end if;
      hr_utility.set_location(l_proc, 55);
    end if;

    -- check if the Party has Notification preferences
        open get_notif_prefs(l_person_party_id);
    fetch get_notif_prefs into l_notif_preference_id;
    close get_notif_prefs;

    -- create Notification Preferences if the Party doesn't have one
    if l_notif_preference_id is NULL then
      -- create doesn't take a party_id ?
      irc_notification_prefs_api.create_notification_prefs
      (p_person_id =>l_person_id
      ,p_effective_date=>trunc(sysdate)
      ,p_notification_preference_id=>l_notif_preference_id
      ,p_object_version_number =>l_notif_ovn
      ,p_allow_access => l_allow_access);
    end if;
    hr_utility.set_location(l_proc, 90);
        -- check if the User has the required responsibility
        l_resp_exists := fnd_user_resp_groups_api.Assignment_Exists(l_user_id,
              p_responsibility_id, p_resp_appl_id, p_security_group_id);
        -- if the User doesn't have the responsibility, assign it.
    if NOT l_resp_exists then
      --
      -- add the appropriate responsibility
      --
      fnd_user_resp_groups_api.Insert_Assignment
      (user_id => l_user_id
      ,responsibility_id => p_responsibility_id
      ,responsibility_application_id => p_resp_appl_id
      ,security_group_id => p_security_group_id
      ,start_date => trunc(sysdate)
      ,end_date => null
      ,description => ' ' -- ### description was supposed to default
                          -- to null... but does not look like it has
      );
      hr_utility.set_location(l_proc, 100);
      --
      -- look to see if we are using multiple security groups
      --
      if (fnd_profile.value('ENABLE_SECURITY_GROUPS')='Y') then
         l_sec_profile_id:=fnd_profile.value_specific
                          (name=>'PER_SECURITY_PROFILE_ID'
                          ,user_id=>l_user_id
                          ,responsibility_id=>p_responsibility_id
                          ,application_id=>p_resp_appl_id);
         l_business_group_id:=fnd_profile.value_specific
                          (name=>'PER_BUSINESS_GROUP_ID'
                          ,user_id=>l_user_id
                          ,responsibility_id=>p_responsibility_id
                          ,application_id=>p_resp_appl_id);
         --
         per_sec_profile_asg_api.create_security_profile_asg
         (p_sec_profile_assignment_id    => l_sec_profile_assignment_id
         ,p_user_id                      => l_user_id
         ,p_security_group_id            => p_security_group_id
         ,p_business_group_id            => l_business_group_id
         ,p_security_profile_id          => l_sec_profile_id
         ,p_responsibility_id            => p_responsibility_id
         ,p_responsibility_application_i => p_resp_appl_id
         ,p_start_date                   => trunc(sysdate)
         ,p_object_version_number        => l_ovn
         );
         hr_utility.set_location(l_proc, 110);
      end if;
    else
      hr_utility.set_location(l_proc, 95);
      --
      -- reopen the candidate responsibility
      --
      fnd_user_resp_groups_api.Update_Assignment
      (user_id => l_user_id
      ,responsibility_id => p_responsibility_id
      ,responsibility_application_id => p_resp_appl_id
      ,security_group_id => p_security_group_id
      ,start_date => trunc(sysdate)
      ,end_date => null
      ,description => ' ' -- ### description was supposed to default
                          -- to null... but does not look like it has
      );
      -- REVISIT, what about Security Profile Assignment
    end if;
    --
    -- check if User has access to Candidate Homepage function
    l_function_name:=fnd_profile.value_specific
                     (name=>'IRC_HOME_PAGE_FUNCTION'
                     ,user_id=>l_user_id
                     ,responsibility_id=>p_responsibility_id
                     ,application_id=>p_resp_appl_id);
    l_func_check := fnd_data_security.check_function(1.0,l_function_name,
                             'GLOBAL',null,null,null,null,null,upper(p_user_name));
    -- if user doesn't have the access, create the Grant
    if l_func_check <> 'T' then
      l_menu_name:=fnd_profile.value_specific
                     (name=>'IRC_CANDIDATE_PSET'
                     ,user_id=>l_user_id
                     ,responsibility_id=>p_responsibility_id
                     ,application_id=>p_resp_appl_id);
      open get_menu_id(l_menu_name);
      fetch get_menu_id into l_menu_id;
      close get_menu_id;

      if l_menu_id is not null then
        if length(p_user_name) > 65 then
          l_grant_name := 'IRC_'||substr(p_user_name,1,65)||'_CAND_GRANT';
        else
          l_grant_name := 'IRC_'||upper(p_user_name)||'_CAND_GRANT';
        end if;
        irc_party_api.grant_access(p_user_name=> p_user_name,
                                   p_user_id=> l_user_id,
                                   p_menu_id=> l_menu_id,
                                   p_resp_id=> p_responsibility_id,
                                   p_resp_appl_id=> p_resp_appl_id,
                                   p_sec_group_id=> p_security_group_id,
                                   p_grant_name=> l_grant_name,
                                   p_description=>' ');
      end if;
    end if;
    --
    hr_utility.set_location('Leaving'||l_proc, 120);
    --
end create_partial_user;
-- -------------------------------------------------------------------------
-- |------------------------< irec_profile_exists >-------------------------|
-- -------------------------------------------------------------------------
FUNCTION irec_profile_exists
  (p_user_name                  IN      varchar2
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ) return VARCHAR2
--
is
  --
  l_user_id number;
  l_person_id number;
  l_person_party_id number;
  l_notif_preference_id number;
  l_tmp_resp_id number;
  l_ptu_person_type_id number;
  l_pers_business_group_id number;
  l_dummy number;
  l_function_name varchar2(30);
  l_func_check varchar2(1);
  --
  cursor get_person_party_info is
  select user_id, employee_id, person_party_id
  from fnd_user
  where user_name=upper(p_user_name);
  --
  cursor get_bg(p_person_id number) is
  select per1.business_group_id
  from per_all_people_f per1
  where per1.person_id=p_person_id
  and trunc(sysdate) between per1.effective_start_date and per1.effective_end_date;
  --
  cursor ptu_exists(p_person_id number,p_person_type_id number) is
  select 1 from per_person_type_usages_f ptuf
  where ptuf.person_id=p_person_id
  and   ptuf.person_type_id=p_person_type_id
  and trunc(sysdate) between ptuf.effective_start_date and ptuf.effective_end_date;
  --
  cursor get_user_responsibility(p_user_id number, p_responsibility_id number,
                               p_resp_appl_id number, p_security_group_id number) is
  select responsibility_id
  from fnd_user_resp_groups
  where user_id=p_user_id and responsibility_id=p_responsibility_id
        and responsibility_application_id = p_resp_appl_id
        and security_group_id = p_security_group_id;
  --
  cursor get_notif_prefs(p_party_id number) is
  select notification_preference_id
  from irc_notification_preferences
  where party_id=p_party_id;
  --
  l_proc          varchar2(72) := g_package||'irec_profile_exists';
  --
begin
    --
    hr_utility.set_location(' Entering: '||l_proc, 10);
    --
    open get_person_party_info;
    fetch get_person_party_info into l_user_id, l_person_id, l_person_party_id;
    close get_person_party_info;

    if l_person_id is NULL then
      return 'NO_PROFILE';
    else
      if irc_utilities_pkg.is_internal_person(p_user_name,trunc(sysdate)) <> 'TRUE' then
        open get_bg(l_person_id);
        fetch get_bg into l_pers_business_group_id;
        close get_bg;
        l_ptu_person_type_id:=hr_person_type_usage_info.get_default_person_type_id
                            (l_pers_business_group_id, 'IRC_REG_USER');
        hr_utility.set_location(l_proc, 15);
        -- if the person's BG doesn't have the iRecruitment Candidate defined
        -- ignore??
        if l_ptu_person_type_id is not null then
          open ptu_exists(l_person_id,l_ptu_person_type_id);
          fetch ptu_exists into l_dummy;
          if ptu_exists%notfound then
            close ptu_exists;
            return 'NO_PROFILE';
          else
            close ptu_exists;
          end if;
        end if;
        --
        hr_utility.set_location(l_proc, 20);
        --
        if l_person_party_id IS NOT NULL then
          -- check if the Party has Notification preferences
          open get_notif_prefs(l_person_party_id);
          fetch get_notif_prefs into l_notif_preference_id;
          close get_notif_prefs;
          -- check if ID is NULL
          if l_notif_preference_id is NULL then
            return 'NO_PROFILE';
          end if;
        else
          return 'NO_PROFILE';
        end if;
      end if;
    end if;
    hr_utility.set_location(l_proc, 30);

    -- check if user has the Candidate Responsibility
    open get_user_responsibility(l_user_id, p_responsibility_id, p_resp_appl_id, p_security_group_id);
    fetch get_user_responsibility into l_tmp_resp_id;
    -- if the User doesn't have the responsibility, assign it.
    if get_user_responsibility%notfound then
      return 'NO_PROFILE';
    end if;
    close get_user_responsibility;
    -- check if User has access to Candidate Homepage function
    l_function_name:=fnd_profile.value_specific
                     (name=>'IRC_HOME_PAGE_FUNCTION'
                     ,user_id=>l_user_id
                     ,responsibility_id=>p_responsibility_id
                     ,application_id=>p_resp_appl_id);
    l_func_check := fnd_data_security.check_function(1.0,l_function_name,
                             'GLOBAL',null,null,null,null,null,upper(p_user_name));
    -- if user doesn't have the access, create the Grant
    if l_func_check <> 'T' then
      return 'NO_PROFILE';
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc, 40);

    return 'PROFILE_EXISTS';
end irec_profile_exists;
-- -------------------------------------------------------------------------
-- |------------------------< create_ha_processed_user >--------------------|
-- -------------------------------------------------------------------------
PROCEDURE create_ha_processed_user
  (p_user_name                  IN      varchar2
  ,p_password                   IN      varchar2
  ,p_email                      IN      varchar2
  ,p_start_date                 IN      date
  ,p_last_name                  IN      varchar2
  ,p_first_name                 IN      varchar2
  ,p_user_guid                  IN      RAW
  ,p_reg_bg_id                  IN      number
  ,p_responsibility_id          IN      number
  ,p_resp_appl_id               IN      number
  ,p_security_group_id          IN      number
  ,p_language                   IN      varchar2 default null
  ,p_allow_access               IN      varchar2 default null
  ,p_server_id                  IN      varchar2 default null
  ) is
l_user_id number;
l_decrypted_password varchar2(100) := null;
l_password_change_check varchar2(1);
l_num number;
l_bool boolean;
l_found boolean;
l_resp_exists boolean;
l_business_group_id number;
l_sec_profile_id number;
l_ovn number;
l_sec_profile_assignment_id number;
password_update_failed exception;
--
l_proc          varchar2(72) := g_package||'create_ha_processed_user';

begin
  --
  hr_utility.set_location(' Entering: '||l_proc, 10);

  l_num := TestUserName(p_user_name=>p_user_name);
  -- creating a brand new user. This happens when SSO is not enabled and user
  -- registered on HA instance
  if l_num = 0 then
    hr_utility.set_location(' Entering: '||l_proc, 20);
    -- create the iRecruitment user with standard password
    irc_party_api.create_user(p_user_name => p_user_name,
                              p_password => 'j3ke678to',
                              p_start_date => p_start_date,
                              p_responsibility_id => p_responsibility_id,
                              p_resp_appl_id => p_resp_appl_id,
                              p_security_group_id => p_security_group_id,
                              p_last_name => p_last_name,
                              p_first_name => p_first_name,
                              p_email => p_email,
                              p_allow_access => p_allow_access);
    hr_utility.set_location(' Entering: '||l_proc, 30);
    -- update the user password
    l_bool := fnd_user_pkg.setreencryptedpassword(username => p_user_name,
                                                reencpwd => p_password,
                                                newkey => 'LOADER');
    if NOT l_bool then
      raise PASSWORD_UPDATE_FAILED;
    end if;
    --
    hr_utility.set_location(l_proc, 40);
    --
    fnd_sso_manager.synch_user_from_LDAP(p_user_name);
    --
    hr_utility.set_location(l_proc, 50);
  --
  -- this case happens when user is present in SSO and applied for a job through
  -- HA and for this we have to create a local user who points to SSO user
  -- note that we are passing in FND_WEB_SEC.EXTERNAL_PWD which is checked by
  -- ATG routine and treats this as an SSO user
  elsif l_num = 3 then
    hr_utility.set_location(l_proc, 15);
    l_user_id := fnd_user_pkg.CreateUserId(
           x_user_name                  => p_user_name
          ,x_owner                      => 'CUST'
          ,x_unencrypted_password       => FND_WEB_SEC.EXTERNAL_PWD
          ,x_email_address              => p_email
          ,x_user_guid                  => p_user_guid
          );
    hr_utility.set_location(l_proc, 25);
    -- fix for bug 4765406
    -- set the profile to SSO
    l_found := fnd_profile.save(x_name => 'APPS_SSO_LOCAL_LOGIN'
                     , x_value => 'SSO'
                     , x_level_name => 'USER'
                     , x_level_value => l_user_id);

    hr_utility.set_location(l_proc, 30);
    --
    fnd_sso_manager.synch_user_from_LDAP(p_user_name);
    hr_utility.set_location(l_proc, 35);
    --
    -- check if User has Resp
    irc_party_api.process_ha_resp_check(p_user_id => l_user_id,
                                        p_responsibility_id => p_responsibility_id,
                                        p_resp_appl_id => p_resp_appl_id,
                                        p_security_group_id => p_security_group_id,
                                        p_start_date => p_start_date,
                                        p_server_id => p_server_id);
    -- complete the partial registration
    create_partial_user(p_user_name  => p_user_name
                   ,p_last_name           => p_last_name
                   ,p_first_name          => p_first_name
                   ,p_email               => p_email
                   ,p_start_date          => p_start_date
                   ,p_reg_bg_id           => p_reg_bg_id
                   ,p_responsibility_id   => p_responsibility_id
                   ,p_resp_appl_id        => p_resp_appl_id
                   ,p_security_group_id   => p_security_group_id
                   ,p_language            => p_language
                   ,p_allow_access        => p_allow_access
                   );
  end if;
  hr_utility.set_location('Leaving: '||l_proc, 60);
end create_ha_processed_user;
--
-- -------------------------------------------------------------------------
-- |------------------------< process_ha_resp_check >----------------------|
-- -------------------------------------------------------------------------
--
procedure process_ha_resp_check
(
p_user_id            IN number,
p_responsibility_id  IN number,
p_resp_appl_id       IN number,
p_security_group_id  IN number,
p_start_date         IN date,
p_server_id          IN number default null
)is
  --
  cursor get_person_party_info is
  select employee_id, person_party_id
  from fnd_user
  where user_id=p_user_id;

  l_person_id number;
  l_person_party_id number;
  l_per_type varchar2(100);
  l_num number;
  l_bool boolean;
  l_found       boolean;
  l_resp_exists boolean;
  l_business_group_id number;
  l_sec_profile_id number;
  l_ovn number;
  l_sec_profile_assignment_id number;
  --
  l_proc          varchar2(72) := g_package||'process_ha_resp_check';
begin
  --
  open get_person_party_info;
  fetch get_person_party_info into l_person_id, l_person_party_id;
  close get_person_party_info;
  -- Disable Partial Registration for Employees
  if l_person_id is not null then
    l_per_type := irc_utilities_pkg.get_emp_spt_for_person(l_person_id, trunc(p_start_date));
  end if;
  -- check if the User has the required responsibility
  l_resp_exists := fnd_user_resp_groups_api.Assignment_Exists(p_user_id,
              p_responsibility_id, p_resp_appl_id, p_security_group_id);
  -- if the User doesn't have the responsibility, assign it.
  if NOT l_resp_exists then
    if (l_per_type = 'EMP') then
      fnd_message.set_name('PER','IRC_412224_EMP_PARTIAL_REG');
      fnd_message.raise_error;
    end if;
    --
    -- add the appropriate responsibility
    --
    fnd_user_resp_groups_api.Insert_Assignment
    (user_id => p_user_id
    ,responsibility_id => p_responsibility_id
    ,responsibility_application_id => p_resp_appl_id
    ,security_group_id => p_security_group_id
    ,start_date => trunc(sysdate)
    ,end_date => null
    ,description => ' ' -- ### description was supposed to default
                        -- to null... but does not look like it has
    );
    hr_utility.set_location(l_proc, 100);
    --
    -- look to see if we are using multiple security groups
    --
    if (fnd_profile.value('ENABLE_SECURITY_GROUPS')='Y') then
       l_sec_profile_id:=fnd_profile.value_specific
                        (name=>'PER_SECURITY_PROFILE_ID'
                        ,user_id=>p_user_id
                        ,responsibility_id=>p_responsibility_id
                        ,application_id=>p_resp_appl_id);
       l_business_group_id:=fnd_profile.value_specific
                        (name=>'PER_BUSINESS_GROUP_ID'
                        ,user_id=>p_user_id
                        ,responsibility_id=>p_responsibility_id
                        ,application_id=>p_resp_appl_id);
       --
       per_sec_profile_asg_api.create_security_profile_asg
       (p_sec_profile_assignment_id    => l_sec_profile_assignment_id
       ,p_user_id                      => p_user_id
       ,p_security_group_id            => p_security_group_id
       ,p_business_group_id            => l_business_group_id
       ,p_security_profile_id          => l_sec_profile_id
       ,p_responsibility_id            => p_responsibility_id
       ,p_responsibility_application_i => p_resp_appl_id
       ,p_start_date                   => trunc(sysdate)
       ,p_object_version_number        => l_ovn
       );
       hr_utility.set_location(l_proc, 110);
    end if;
  else
    hr_utility.set_location(l_proc, 95);
    if (l_per_type <> 'EMP') then
      --
      -- reopen the candidate responsibility
      --
      fnd_user_resp_groups_api.Update_Assignment
      (user_id => p_user_id
      ,responsibility_id => p_responsibility_id
      ,responsibility_application_id => p_resp_appl_id
      ,security_group_id => p_security_group_id
      ,start_date => trunc(sysdate)
      ,end_date => null
      ,description => ' ' -- ### description was supposed to default
                          -- to null... but does not look like it has
      );
      -- REVISIT, what about Security Profile Assignment
    end if;
  end if;
  --
  if p_server_id is null then
    fnd_global.apps_initialize
    (user_id          => p_user_id
    ,resp_id          => p_responsibility_id
    ,resp_appl_id     => p_resp_appl_id
    ,security_group_id=> p_security_group_id);
  else
    fnd_global.apps_initialize
    (user_id          => p_user_id
    ,resp_id          => p_responsibility_id
    ,resp_appl_id     => p_resp_appl_id
    ,security_group_id=> p_security_group_id
    ,server_id        => p_server_id);
  end if;
end;
--
-- -------------------------------------------------------------------------
-- |------------------------< TestUserName >-------------------------------|
-- -------------------------------------------------------------------------
function TestUserName
(
  p_user_name IN varchar2
) return NUMBER
is
begin
  return fnd_user_pkg.testusername(x_user_name=>p_user_name);
end TestUserName;
--
-- -------------------------------------------------------------------------
-- |------------------------< assign_responsibility >----------------------|
-- -------------------------------------------------------------------------
procedure assign_responsibility
(p_user_id      IN number
,p_resp_id      IN number
,p_resp_appl_id IN number
,p_sec_group_id IN number
) is
--
PRAGMA autonomous_transaction;

l_resp_exists boolean;
l_sec_profile_assignment_id number;
l_business_group_id number;
l_sec_profile_id number;
l_ovn number;
--
l_proc          varchar2(72) := g_package||'assign_responsibility';

begin
 -- check if the User has the required responsibility
 l_resp_exists := fnd_user_resp_groups_api.Assignment_Exists(p_user_id,
              p_resp_id, p_resp_appl_id, p_sec_group_id);
 -- if the User doesn't have the responsibility, assign it.
 if NOT l_resp_exists then
   --
   -- add the appropriate responsibility
   --
   fnd_user_resp_groups_api.Insert_Assignment
   (user_id => p_user_id
   ,responsibility_id => p_resp_id
   ,responsibility_application_id => p_resp_appl_id
   ,security_group_id => p_sec_group_id
   ,start_date => trunc(sysdate)
   ,end_date => null
   ,description => ' ' -- ### description was supposed to default
                       -- to null... but does not look like it has
    );
    hr_utility.set_location(l_proc, 100);
    --
    -- look to see if we are using multiple security groups
    --
    if(fnd_profile.value('ENABLE_SECURITY_GROUPS')='Y') then
      l_sec_profile_id:=fnd_profile.value_specific
                        (name=>'PER_SECURITY_PROFILE_ID'
                        ,user_id=>p_user_id
                        ,responsibility_id=>p_resp_id
                        ,application_id=>p_resp_appl_id);
      l_business_group_id:=fnd_profile.value_specific
                        (name=>'PER_BUSINESS_GROUP_ID'
                        ,user_id=>p_user_id
                        ,responsibility_id=>p_resp_id
                        ,application_id=>p_resp_appl_id);
      --
      per_sec_profile_asg_api.create_security_profile_asg
      (p_sec_profile_assignment_id    => l_sec_profile_assignment_id
      ,p_user_id                      => p_user_id
      ,p_security_group_id            => p_sec_group_id
      ,p_business_group_id            => l_business_group_id
      ,p_security_profile_id          => l_sec_profile_id
      ,p_responsibility_id            => p_resp_id
      ,p_responsibility_application_i => p_resp_appl_id
      ,p_start_date                   => trunc(sysdate)
      ,p_object_version_number        => l_ovn
      );
      hr_utility.set_location(l_proc, 110);
    end if;
  else
    hr_utility.set_location(l_proc, 95);
    --
    -- reopen the candidate responsibility
    --
    fnd_user_resp_groups_api.Update_Assignment
    (user_id => p_user_id
    ,responsibility_id => p_resp_id
    ,responsibility_application_id => p_resp_appl_id
    ,security_group_id => p_sec_group_id
    ,start_date => trunc(sysdate)
    ,end_date => null
    ,description => ' ' -- ### description was supposed to default
                        -- to null... but does not look like it has
    );
    -- REVISIT, what about Security Profile Assignment
  end if;
  commit;
  hr_utility.set_location('Leaving:'||l_proc, 110);
end assign_responsibility;
--
--
--
-- -------------------------------------------------------------------------
-- |------------------------< create_user_internal_byRef >------------------|
-- -------------------------------------------------------------------------
--
procedure create_user_internal_byRef
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_first_name                IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_person_id                 IN     per_all_people_f.person_id%type default null
   ) IS
--
PRAGMA autonomous_transaction;
l_proc          varchar2(72) := g_package||'create_user_internal_byReferral';
l_person_id     per_all_people_f.person_id%type;
l_user_id       number;
l_profile_check boolean;
l_user_name     fnd_user.user_name%type;
l_default_last_name per_all_people_f.last_name%type;
l_effective_start_date date;
l_effective_end_date date;
l_sec_profile_assignment_id number;
l_business_group_id number;
l_sec_profile_id number;
l_ovn number;
l_menu_name varchar2(30);
l_menu_id number;
l_grant_name varchar2(80);
--
cursor get_menu_id (p_menu_name varchar2) is
select menu_id from fnd_menus where menu_name=upper(p_menu_name);
--
begin
  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  -- Create Person
  l_default_last_name := nvl(p_last_name,fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME'));

  l_person_id := p_person_id;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Create User and set person_id to employee_id
  --
  l_user_id := fnd_user_pkg.CreateUserId (
  x_user_name                  => p_user_name,
  x_owner                      => 'CUST',
  x_unencrypted_password       => p_password,
  x_email_address              => p_email,
  x_employee_id                => l_person_id,
  x_password_date              => trunc(sysdate));
  --
  hr_utility.set_location(l_proc,30);
  --
  -- set the language profile option
  --
  l_profile_check := fnd_profile.save (
  x_name                =>      'ICX_LANGUAGE',
  x_value               =>      p_language,
  x_level_name          =>      'USER',
  x_level_value         =>      l_user_id );
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Set the password date Column to Null for the created user
  -- As the password is system generated, it should be changed
  -- by candidate when he first logs in
    UPDATE fnd_user
           SET password_date=NULL
         WHERE user_name=upper(p_user_name);
  --
  -- commit autonomous transaction
  --
  --
  commit;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end create_user_internal_byRef;
--
--
-- -------------------------------------------------------------------------
-- |------------------------< create_user_byReferral >--------------------------------|
-- -------------------------------------------------------------------------
--
procedure create_user_byReferral
   (p_user_name                 IN     varchar2
   ,p_password                  IN     varchar2
   ,p_start_date                IN     date
   ,p_responsibility_id         IN     number
   ,p_resp_appl_id              IN     number
   ,p_security_group_id         IN     number
   ,p_email                     IN     varchar2 default null
   ,p_language                  IN     varchar2 default null
   ,p_last_name                 IN     varchar2 default null
   ,p_first_name                IN     varchar2 default null
   ,p_allow_access              IN     varchar2 default null
   ,p_per_information_category  IN     varchar2 default null
   ,p_per_information1          IN     varchar2 default null
   ,p_per_information2          IN     varchar2 default null
   ,p_per_information3          IN     varchar2 default null
   ,p_per_information4          IN     varchar2 default null
   ,p_per_information5          IN     varchar2 default null
   ,p_per_information6          IN     varchar2 default null
   ,p_per_information7          IN     varchar2 default null
   ,p_per_information8          IN     varchar2 default null
   ,p_per_information9          IN     varchar2 default null
   ,p_per_information10         IN     varchar2 default null
   ,p_per_information11         IN     varchar2 default null
   ,p_per_information12         IN     varchar2 default null
   ,p_per_information13         IN     varchar2 default null
   ,p_per_information14         IN     varchar2 default null
   ,p_per_information15         IN     varchar2 default null
   ,p_per_information16         IN     varchar2 default null
   ,p_per_information17         IN     varchar2 default null
   ,p_per_information18         IN     varchar2 default null
   ,p_per_information19         IN     varchar2 default null
   ,p_per_information20         IN     varchar2 default null
   ,p_per_information21         IN     varchar2 default null
   ,p_per_information22         IN     varchar2 default null
   ,p_per_information23         IN     varchar2 default null
   ,p_per_information24         IN     varchar2 default null
   ,p_per_information25         IN     varchar2 default null
   ,p_per_information26         IN     varchar2 default null
   ,p_per_information27         IN     varchar2 default null
   ,p_per_information28         IN     varchar2 default null
   ,p_per_information29         IN     varchar2 default null
   ,p_per_information30         IN     varchar2 default null
   ,p_person_id                 IN     number   default null
   ) IS
--
l_password_check varchar2(1);
l_password_change_check varchar2(1);
l_allow_access irc_notification_preferences.allow_access%type;
l_start_date date;
cursor get_nls_language is
select nls_language
from fnd_languages
where language_code=p_language;
--
l_nls_language fnd_languages.nls_language%type;
--
begin
  --
  -- Truncate time portion from date
  --
  l_start_date := trunc(p_start_date);
  --
  -- default Allow Access if input value is NULL
  --
  l_allow_access := nvl(p_allow_access,nvl(fnd_profile.value('IRC_VISIBLE_PREF_DEFAULT'),'N'));
  --
  -- Call Before Process User Hook
  --
  begin
    irc_party_bk4.create_user_b
    (
       p_user_name             => p_user_name
      ,p_password              => p_password
      ,p_start_date            => l_start_date
      ,p_email                 => p_email
      ,p_language              => p_language
      ,p_last_name             => p_last_name
      ,p_first_name            => p_first_name
      ,p_allow_access          => l_allow_access
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- get NLS_LANGUAGE
  --
  open get_nls_language;
  fetch get_nls_language into l_nls_language;
  if get_nls_language%notfound then
    close get_nls_language;
    l_nls_language:=p_language;
  else
    close get_nls_language;
  end if;
  --
  -- Validate the password
  --
  l_password_check := fnd_web_sec.validate_password(username => p_user_name
                                                   ,password => p_password);

  if (l_password_check = 'N') then
    fnd_message.raise_error;
  end if;
  --
  -- create party and user
  --
  irc_party_api.create_user_internal_byRef(p_user_name => p_user_name
                                    ,p_password  => p_password
                                    ,p_start_date => l_start_date
                                    ,p_email => p_email
                                    ,p_responsibility_id => p_responsibility_id
                                    ,p_resp_appl_id => p_resp_appl_id
                                    ,p_security_group_id => p_security_group_id
                                    ,p_language => l_nls_language
                                    ,p_last_name => p_last_name
                                    ,p_first_name => p_first_name
                                    ,p_allow_access => l_allow_access
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    ,p_person_id                             => p_person_id
    );
  --
  -- Call After Process User Hook
  --
  begin
    irc_party_bk4.create_user_a
    (
       p_user_name             => p_user_name
      ,p_password              => p_password
      ,p_start_date            => l_start_date
      ,p_email                 => p_email
      ,p_language              => p_language
      ,p_last_name             => p_last_name
      ,p_first_name            => p_first_name
      ,p_allow_access          => l_allow_access
    ,p_per_information_category              => p_per_information_category
    ,p_per_information1                      => p_per_information1
    ,p_per_information2                      => p_per_information2
    ,p_per_information3                      => p_per_information3
    ,p_per_information4                      => p_per_information4
    ,p_per_information5                      => p_per_information5
    ,p_per_information6                      => p_per_information6
    ,p_per_information7                      => p_per_information7
    ,p_per_information8                      => p_per_information8
    ,p_per_information9                      => p_per_information9
    ,p_per_information10                     => p_per_information10
    ,p_per_information11                     => p_per_information11
    ,p_per_information12                     => p_per_information12
    ,p_per_information13                     => p_per_information13
    ,p_per_information14                     => p_per_information14
    ,p_per_information15                     => p_per_information15
    ,p_per_information16                     => p_per_information16
    ,p_per_information17                     => p_per_information17
    ,p_per_information18                     => p_per_information18
    ,p_per_information19                     => p_per_information19
    ,p_per_information20                     => p_per_information20
    ,p_per_information21                     => p_per_information21
    ,p_per_information22                     => p_per_information22
    ,p_per_information23                     => p_per_information23
    ,p_per_information24                     => p_per_information24
    ,p_per_information25                     => p_per_information25
    ,p_per_information26                     => p_per_information26
    ,p_per_information27                     => p_per_information27
    ,p_per_information28                     => p_per_information28
    ,p_per_information29                     => p_per_information29
    ,p_per_information30                     => p_per_information30
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER'
        ,p_hook_type   => 'AP'
        );
  end;
--
end create_user_byReferral;
--
procedure merge_profile
   (p_validate                  IN     boolean  default false
   ,p_target_party_id           IN     number
   ,p_source_party_id           IN     number
   ,p_term_or_purge_s           IN     varchar2 default null
   ,p_disable_user_acc          IN     varchar2 default null
   ,p_create_new_application    IN     varchar2 default null
   )
is
l_proc          varchar2(72) := g_package||'merge_profile';
l_term_or_purge_s varchar2(10) := null;
--
-- Cursor declarations
cursor get_user_name(p_party_id number) is
select fu.user_name
from fnd_user fu
where fu.person_party_id=p_party_id
and trunc(sysdate) between fu.start_date and nvl(fu.end_date,trunc(sysdate));
--
begin
  --
  hr_utility.set_location(' Entering: '||l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint MERGE_PROFILE;
  --
  IF p_term_or_purge_s='Y' THEN
    l_term_or_purge_s := 'TERM';
  END IF;
  --
  hr_person_api.merge_party
    (p_validate                      =>   p_validate
    ,p_target_party_id               =>   p_target_party_id
    ,p_source_party_id               =>   p_source_party_id
    ,p_term_or_purge_s               =>   l_term_or_purge_s
    ,p_create_new_application        =>   p_create_new_application
   );
  --
  --
  if p_disable_user_acc='Y' then
    --
    -- close off the user accounts for the source party
    --
    hr_utility.set_location(l_proc,20);
    --
    for user_rec in get_user_name(p_source_party_id) loop
      fnd_user_pkg.disableUser(user_rec.user_name);
    end loop;
    --
    hr_utility.set_location(l_proc,30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving: '||l_proc, 40);
  --
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to MERGE_PROFILE;
    --
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    --
    raise;
end merge_profile;
end irc_party_api;

/
