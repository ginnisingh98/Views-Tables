--------------------------------------------------------
--  DDL for Package Body HR_JPBP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JPBP_API" as
/* $Header: pejpapi.pkb 120.0 2005/05/30 21:10:57 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  HR_JPBP_API.';
--
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_school_id_school_name_comb  >----------------|
-- ----------------------------------------------------------------------------

procedure chk_school_id_school_name_comb(
  p_school_id         in out nocopy per_analysis_criteria.segment2%TYPE,
  p_school_name       in out nocopy per_analysis_criteria.segment3%TYPE,
  p_school_name_kana  in out nocopy per_analysis_criteria.segment4%TYPE,
  p_major             in out nocopy per_analysis_criteria.segment5%TYPE,
  p_major_kana        in out nocopy per_analysis_criteria.segment6%TYPE) is


  l_proc     varchar2(72) := g_package||'chk_school_id_name_comb';
  --
  cursor c1 is
    select * from per_jp_school_lookups
      where school_id = p_school_id;
  --
  cursor c2 is
    select * from per_jp_school_lookups
      where school_name = p_school_name
        and nvl(major,hr_api.g_varchar2)= nvl(p_major,hr_api.g_varchar2);
  --
  jp_school_rec per_jp_school_lookups%rowtype;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  --  If school_id is not null, get school info with school_id.
  --
  if p_school_id is not null then
    hr_utility.set_location(l_proc, 20);
    open c1;
    fetch c1 into jp_school_rec;
    if c1%notfound then
      close c1;
      hr_utility.set_message(801, 'HR_72011_API_INVALID_SCL_ID');
      hr_utility.raise_error;
    end if;
    close c1;

    --
    -- If p_school_name is null, set the school name.
    --
    if p_school_name is null then
      p_school_name := jp_school_rec.school_name;
    end if;

    --
    -- If p_major is null, set the major.
    --
    if p_major is null then
      p_major := jp_school_rec.major;
    end if;

  --
  --  If school_name is not null, get school info
  --  with p_school_name, p_major.
  --
  elsif p_school_name is not null then
    hr_utility.set_location(l_proc, 30);
    open c2;
    fetch c2 into jp_school_rec;
    if c2%notfound then
      close c2;
      hr_utility.set_message(801, 'HR_72014_API_INVALID_NAME_MAJR');
      hr_utility.raise_error;
    end if;
    --
    --  Check dupulication
    --
    fetch c2 into jp_school_rec;
    if c2%found then
      close c2;
      hr_utility.set_message(801, 'HR_72014_API_INVALID_NAME_MAJR');
      hr_utility.raise_error;
    end if;
    close c2;

    --
    --  Set the school_id since p_school_id is null.
    --
    p_school_id := jp_school_rec.school_id;

  --
  --  both school_id and school_name is null
  --
  else
    hr_utility.set_message(801, 'HR_72015_API_SCL_ID_NAME_NULL');
    hr_utility.raise_error;
  end if;

  --
  -- If p_school_name_kana is null, set the school name kana.
  --
  if p_school_name_kana is null then
    p_school_name_kana := jp_school_rec.school_name_kana;
  end if;

  --
  -- If p_major_kana is null, set the major kana.
  --
  if p_major_kana is null then
    p_major_kana := jp_school_rec.major_kana;
  end if;
  --
  --
  hr_utility.set_location('Leaving:'|| l_proc, 40);
end chk_school_id_school_name_comb;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_jp_educ_sit >-----------------------|
-- ----------------------------------------------------------------------------
procedure create_jp_educ_sit
 ( p_validate                  in    boolean  default false
  ,p_person_id                 in    number
  ,p_business_group_id         in    number
  ,p_effective_date            in    date
  ,p_comments                  in    varchar2 default null
  ,p_date_from                 in    date     default null
  ,p_date_to                   in    date     default null
  ,p_attribute_category        in    varchar2 default null
  ,p_attribute1                in    varchar2 default null
  ,p_attribute2                in    varchar2 default null
  ,p_attribute3                in    varchar2 default null
  ,p_attribute4                in    varchar2 default null
  ,p_attribute5                in    varchar2 default null
  ,p_attribute6                in    varchar2 default null
  ,p_attribute7                in    varchar2 default null
  ,p_attribute8                in    varchar2 default null
  ,p_attribute9                in    varchar2 default null
  ,p_attribute10               in    varchar2 default null
  ,p_attribute11               in    varchar2 default null
  ,p_attribute12               in    varchar2 default null
  ,p_attribute13               in    varchar2 default null
  ,p_attribute14               in    varchar2 default null
  ,p_attribute15               in    varchar2 default null
  ,p_attribute16               in    varchar2 default null
  ,p_attribute17               in    varchar2 default null
  ,p_attribute18               in    varchar2 default null
  ,p_attribute19               in    varchar2 default null
  ,p_attribute20               in    varchar2 default null
  ,p_segment1                  in    varchar2 default null
  ,p_segment2                  in    varchar2 default null
  ,p_segment3                  in    varchar2 default null
  ,p_segment4                  in    varchar2 default null
  ,p_segment5                  in    varchar2 default null
  ,p_segment6                  in    varchar2 default null
  ,p_segment7                  in    varchar2 default null
  ,p_segment8                  in    varchar2 default null
  ,p_segment9                  in    varchar2 default null
  ,p_segment10                 in    varchar2 default null
  ,p_segment11                 in    varchar2 default null
  ,p_segment12                 in    varchar2 default null
  ,p_segment13                 in    varchar2 default null
  ,p_segment14                 in    varchar2 default null
  ,p_segment15                 in    varchar2 default null
  ,p_segment16                 in    varchar2 default null
  ,p_segment17                 in    varchar2 default null
  ,p_segment18                 in    varchar2 default null
  ,p_segment19                 in    varchar2 default null
  ,p_segment20                 in    varchar2 default null
  ,p_segment21                 in    varchar2 default null
  ,p_segment22                 in    varchar2 default null
  ,p_segment23                 in    varchar2 default null
  ,p_segment24                 in    varchar2 default null
  ,p_segment25                 in    varchar2 default null
  ,p_segment26                 in    varchar2 default null
  ,p_segment27                 in    varchar2 default null
  ,p_segment28                 in    varchar2 default null
  ,p_segment29                 in    varchar2 default null
  ,p_segment30                 in    varchar2 default null
  ,p_analysis_criteria_id      out nocopy   number
  ,p_person_analysis_id        out nocopy   number
  ,p_pea_object_version_number out nocopy   number
 ) is
  --
  l_proc                    varchar2(72) := g_package||'create_jp_educ_sit';
  l_exists                  varchar2(2);
  l_id_flex_num             fnd_id_flex_structures.id_flex_num%TYPE := 1;
  l_legislation_code        per_business_groups.legislation_code%TYPE;
  l_segment2                per_analysis_criteria.segment2%TYPE := p_segment2;
  l_segment3                per_analysis_criteria.segment3%TYPE := p_segment3;
  l_segment4                per_analysis_criteria.segment4%TYPE := p_segment4;
  l_segment5                per_analysis_criteria.segment5%TYPE := p_segment5;
  l_segment6                per_analysis_criteria.segment6%TYPE := p_segment6;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check that the specified business group is valid.
  --
  hr_utility.set_location(l_proc, 10);
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  else
    if l_legislation_code <> 'JP' then
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','JP');
      hr_utility.raise_error;
    end if;
  end if;
  close csr_bg;

  --
  -- Check the validity of the combination for p_segment2 to p_segment6 and
  -- poplulate them.
  --
  if not (l_segment2 is null and l_segment3 is null and
          l_segment4 is null and l_segment5 is null and
          l_segment6 is null                           ) then
    --
    chk_school_id_school_name_comb
       (p_school_id                 => l_segment2
       ,p_school_name               => l_segment3
       ,p_school_name_kana          => l_segment4
       ,p_major                     => l_segment5
       ,p_major_kana                => l_segment6
       );
    --
  end if;

  hr_utility.set_location(l_proc, 40);
  --
  -- Call create_sit
  hr_sit_api.create_sit
   (p_validate                     => p_validate
   ,p_person_id                    => p_person_id
   ,p_business_group_id            => p_business_group_id
   ,p_id_flex_num                  => l_id_flex_num
   ,p_effective_date               => p_effective_date
   ,p_comments                     => p_comments
   ,p_date_from                    => p_date_from
   ,p_date_to                      => p_date_to
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
   ,p_segment1                     => p_segment1
   ,p_segment2                     => l_segment2
   ,p_segment3                     => l_segment3
   ,p_segment4                     => l_segment4
   ,p_segment5                     => l_segment5
   ,p_segment6                     => l_segment6
   ,p_segment7                     => p_segment7
   ,p_segment8                     => p_segment8
   ,p_segment9                     => p_segment9
   ,p_segment10                    => p_segment10
   ,p_segment11                    => p_segment11
   ,p_segment12                    => p_segment12
   ,p_segment13                    => p_segment13
   ,p_segment14                    => p_segment14
   ,p_segment15                    => p_segment15
   ,p_segment16                    => p_segment16
   ,p_segment17                    => p_segment17
   ,p_segment18                    => p_segment18
   ,p_segment19                    => p_segment19
   ,p_segment20                    => p_segment20
   ,p_segment21                    => p_segment21
   ,p_segment22                    => p_segment22
   ,p_segment23                    => p_segment23
   ,p_segment24                    => p_segment24
   ,p_segment25                    => p_segment25
   ,p_segment26                    => p_segment26
   ,p_segment27                    => p_segment27
   ,p_segment28                    => p_segment28
   ,p_segment29                    => p_segment29
   ,p_segment30                    => p_segment30
   ,p_analysis_criteria_id         => p_analysis_criteria_id
   ,p_person_analysis_id           => p_person_analysis_id
   ,p_pea_object_version_number    => p_pea_object_version_number
   );
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
end create_jp_educ_sit;
-- ----------------------------------------------------------------------------
-- |---------------------< create_jp_employee_with_sit >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_jp_employee_with_sit
  (
   -- for per_people_f
   --
   p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_assignment_number             out nocopy    varchar2
  ,p_name_combination_warning      out nocopy    boolean
  ,p_assign_payroll_warning        out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean
  --
  -- for special information
  --
  ,p_id_flex_num                   in     number
  ,p_pea_comments                  in     varchar2 default null
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number

/* Additional parameters for Bug:4161160 */

  ,p_english_last_name		   in    varchar2 default null
  ,p_english_first_name		   in    varchar2 default null
  ,p_per_information23	           in    varchar2 default null
  ,p_per_information24	           in    varchar2 default null
  ,p_per_information25	           in    varchar2 default null
  ,p_per_information26	           in    varchar2 default null
  ,p_per_information27	           in    varchar2 default null
  ,p_per_information28	           in    varchar2 default null
  ,p_per_information29	           in    varchar2 default null
  ,p_per_information30	           in    varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_person_id         number;
  l_employee_number   per_all_people_f.employee_number%TYPE;
  l_proc              varchar2(72) := g_package||'create_jp_employee_with_sit';
  l_legislation_code  varchar2(150);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_jp_employee_with_sit;

  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  hr_utility.set_location(l_proc, 20);
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  else
    if l_legislation_code <> 'JP' then
      close csr_bg;
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','JP');
      hr_utility.raise_error;
    end if;
  end if;
  close csr_bg;

  l_employee_number            := p_employee_number;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Process Logic
  --
  -- Call the person business process
  --
  hr_employee_api.create_employee
  (p_validate                     => false
  ,p_hire_date                    => p_hire_date
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name_kana
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_per_comments                 => p_per_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_employee_number              => p_employee_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name_kana
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_national_identifier
  ,p_previous_last_name           => p_previous_last_name_kana
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_vendor_id                    => p_vendor_id
  ,p_work_telephone               => p_work_telephone
  ,p_attribute_category           => p_per_attribute_category
  ,p_attribute1                   => p_per_attribute1
  ,p_attribute2                   => p_per_attribute2
  ,p_attribute3                   => p_per_attribute3
  ,p_attribute4                   => p_per_attribute4
  ,p_attribute5                   => p_per_attribute5
  ,p_attribute6                   => p_per_attribute6
  ,p_attribute7                   => p_per_attribute7
  ,p_attribute8                   => p_per_attribute8
  ,p_attribute9                   => p_per_attribute9
  ,p_attribute10                  => p_per_attribute10
  ,p_attribute11                  => p_per_attribute11
  ,p_attribute12                  => p_per_attribute12
  ,p_attribute13                  => p_per_attribute13
  ,p_attribute14                  => p_per_attribute14
  ,p_attribute15                  => p_per_attribute15
  ,p_attribute16                  => p_per_attribute16
  ,p_attribute17                  => p_per_attribute17
  ,p_attribute18                  => p_per_attribute18
  ,p_attribute19                  => p_per_attribute19
  ,p_attribute20                  => p_per_attribute20
  ,p_attribute21                  => p_per_attribute21
  ,p_attribute22                  => p_per_attribute22
  ,p_attribute23                  => p_per_attribute23
  ,p_attribute24                  => p_per_attribute24
  ,p_attribute25                  => p_per_attribute25
  ,p_attribute26                  => p_per_attribute26
  ,p_attribute27                  => p_per_attribute27
  ,p_attribute28                  => p_per_attribute28
  ,p_attribute29                  => p_per_attribute29
  ,p_attribute30                  => p_per_attribute30
  ,p_per_information_category     => 'JP'
  ,p_per_information1             => null
  ,p_per_information2             => null
  ,p_per_information3             => null
  ,p_per_information4             => null
  ,p_per_information5             => null
  ,p_per_information6             => null
  ,p_per_information7             => null
  ,p_per_information8             => null
  ,p_per_information9             => null
  ,p_per_information10            => null
  ,p_per_information11            => null
  ,p_per_information12            => null
  ,p_per_information13            => null
  ,p_per_information14            => null
  ,p_per_information15            => null
  ,p_per_information16            => null
  ,p_per_information17            => null
  ,p_per_information18            => p_last_name
  ,p_per_information19            => p_first_name
  ,p_per_information20            => p_previous_last_name
  ,p_date_of_death                => p_date_of_death
  ,p_blood_type                   => p_blood_type
  ,p_correspondence_language      => p_correspondence_language
  ,p_fte_capacity                 => p_fte_capacity
  ,p_honors                       => p_honors
  ,p_internal_location            => p_internal_location
  ,p_last_medical_test_by         => p_last_medical_test_by
  ,p_last_medical_test_date       => p_last_medical_test_date
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_second_passport_exists       => p_second_passport_exists
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_person_id                    => l_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_assignment_number            => p_assignment_number
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_assign_payroll_warning       => p_assign_payroll_warning
  ,p_orig_hire_warning            => p_orig_hire_warning

/* Additional parameters for Bug:4161160 */

  ,p_per_information21		  => p_english_last_name
  ,p_per_information22		  => p_english_first_name
  ,p_per_information23		  => p_per_information23
  ,p_per_information24	          => p_per_information24
  ,p_per_information25	          => p_per_information25
  ,p_per_information26	          => p_per_information26
  ,p_per_information27	          => p_per_information27
  ,p_per_information28	          => p_per_information28
  ,p_per_information29	          => p_per_information29
  ,p_per_information30	          => p_per_information30
 );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  -- Create SIT if not all params are set to null.
  --
  if not (p_id_flex_num                  is null
    and p_pea_comments                 is null
    and p_date_from                    is null
    and p_date_to                      is null
    and p_pea_attribute_category       is null
    and p_pea_attribute1               is null
    and p_pea_attribute2               is null
    and p_pea_attribute3               is null
    and p_pea_attribute4               is null
    and p_pea_attribute5               is null
    and p_pea_attribute6               is null
    and p_pea_attribute7               is null
    and p_pea_attribute8               is null
    and p_pea_attribute9               is null
    and p_pea_attribute10              is null
    and p_pea_attribute11              is null
    and p_pea_attribute12              is null
    and p_pea_attribute13              is null
    and p_pea_attribute14              is null
    and p_pea_attribute15              is null
    and p_pea_attribute16              is null
    and p_pea_attribute17              is null
    and p_pea_attribute18              is null
    and p_pea_attribute19              is null
    and p_pea_attribute20              is null
    and p_segment1                     is null
    and p_segment2                     is null
    and p_segment3                     is null
    and p_segment4                     is null
    and p_segment5                     is null
    and p_segment6                     is null
    and p_segment7                     is null
    and p_segment8                     is null
    and p_segment9                     is null
    and p_segment10                    is null
    and p_segment11                    is null
    and p_segment12                    is null
    and p_segment13                    is null
    and p_segment14                    is null
    and p_segment15                    is null
    and p_segment16                    is null
    and p_segment17                    is null
    and p_segment18                    is null
    and p_segment19                    is null
    and p_segment20                    is null
    and p_segment21                    is null
    and p_segment22                    is null
    and p_segment23                    is null
    and p_segment24                    is null
    and p_segment25                    is null
    and p_segment26                    is null
    and p_segment27                    is null
    and p_segment28                    is null
    and p_segment29                    is null
    and p_segment30                    is null
  ) then
    --
    hr_utility.set_location(l_proc, 50);
    --
    hr_sit_api.create_sit
     (p_validate                     => false
     ,p_person_id                    => l_person_id
     ,p_business_group_id            => p_business_group_id
     ,p_id_flex_num                  => p_id_flex_num
     ,p_effective_date               => p_hire_date
     ,p_comments                     => p_per_comments
     ,p_date_from                    => p_date_from
     ,p_date_to                      => p_date_to
     ,p_attribute_category           => p_pea_attribute_category
     ,p_attribute1                   => p_pea_attribute1
     ,p_attribute2                   => p_pea_attribute2
     ,p_attribute3                   => p_pea_attribute3
     ,p_attribute4                   => p_pea_attribute4
     ,p_attribute5                   => p_pea_attribute5
     ,p_attribute6                   => p_pea_attribute6
     ,p_attribute7                   => p_pea_attribute7
     ,p_attribute8                   => p_pea_attribute8
     ,p_attribute9                   => p_pea_attribute9
     ,p_attribute10                  => p_pea_attribute10
     ,p_attribute11                  => p_pea_attribute11
     ,p_attribute12                  => p_pea_attribute12
     ,p_attribute13                  => p_pea_attribute13
     ,p_attribute14                  => p_pea_attribute14
     ,p_attribute15                  => p_pea_attribute15
     ,p_attribute16                  => p_pea_attribute16
     ,p_attribute17                  => p_pea_attribute17
     ,p_attribute18                  => p_pea_attribute18
     ,p_attribute19                  => p_pea_attribute19
     ,p_attribute20                  => p_pea_attribute20
     ,p_segment1                     => p_segment1
     ,p_segment2                     => p_segment2
     ,p_segment3                     => p_segment3
     ,p_segment4                     => p_segment4
     ,p_segment5                     => p_segment5
     ,p_segment6                     => p_segment6
     ,p_segment7                     => p_segment7
     ,p_segment8                     => p_segment8
     ,p_segment9                     => p_segment9
     ,p_segment10                    => p_segment10
     ,p_segment11                    => p_segment11
     ,p_segment12                    => p_segment12
     ,p_segment13                    => p_segment13
     ,p_segment14                    => p_segment14
     ,p_segment15                    => p_segment15
     ,p_segment16                    => p_segment16
     ,p_segment17                    => p_segment17
     ,p_segment18                    => p_segment18
     ,p_segment19                    => p_segment19
     ,p_segment20                    => p_segment20
     ,p_segment21                    => p_segment21
     ,p_segment22                    => p_segment22
     ,p_segment23                    => p_segment23
     ,p_segment24                    => p_segment24
     ,p_segment25                    => p_segment25
     ,p_segment26                    => p_segment26
     ,p_segment27                    => p_segment27
     ,p_segment28                    => p_segment28
     ,p_segment29                    => p_segment29
     ,p_segment30                    => p_segment30
     ,p_analysis_criteria_id         => p_analysis_criteria_id
     ,p_person_analysis_id           => p_person_analysis_id
     ,p_pea_object_version_number    => p_pea_object_version_number
     );
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_person_id := l_person_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_jp_employee_with_sit;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_id                     := null;
    p_assignment_id                 := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;
    p_assignment_number             := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_jp_employee_with_sit;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_employee_number               := l_employee_number;

    p_person_id                     := null;
    p_assignment_id                 := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;
    p_assignment_number             := null;
    p_name_combination_warning      := null;
    p_assign_payroll_warning        := null;
    p_orig_hire_warning             := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;

    hr_utility.set_location(' Leaving:'||l_proc, 70);
    raise;
end create_jp_employee_with_sit;
--
-- ----------------------------------------------------------------------------
-- |------------------< create_jp_emp_with_educ_add >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_jp_emp_with_educ_add
  (
   -- for per_people_f
   --
   p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_assignment_number             out nocopy    varchar2
  ,p_name_combination_warning      out nocopy    boolean
  ,p_assign_payroll_warning        out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean
  --
  -- for special information
  --
  ,p_pea_comments                  in     varchar2 default null
  ,p_pea_date_from                 in     date     default null
  ,p_pea_date_to                   in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_school_type                   in     varchar2 default null
  ,p_school_id                     in     varchar2 default null
  ,p_school_name                   in     varchar2 default null
  ,p_school_name_kana              in     varchar2 default null
  ,p_major                         in     varchar2 default null
  ,p_major_kana                    in     varchar2 default null
  ,p_advisor                       in     varchar2 default null
  ,p_graduation_date               in     varchar2 default null
  ,p_note                          in     varchar2 default null
  ,p_last_flag                     in     varchar2 default null
--  ,p_school_flag                   in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number
  --
  -- for per_addresses
  --
--  ,p_primary_flag                  in     varchar2
  ,p_add_date_from                 in     date     default null
  ,p_add_date_to                   in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_add_comments                  in     varchar2 default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_district_code                 in     varchar2 default null
  ,p_address_line1_kana            in     varchar2 default null
  ,p_address_line2_kana            in     varchar2 default null
  ,p_address_line3_kana            in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_fax_number                    in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                    out nocopy number
  ,p_add_object_version_number     out nocopy number

/* Additional parameters for Bug:4161160 */

  ,p_english_last_name		   in    varchar2 default null
  ,p_english_first_name		   in    varchar2 default null
  ,p_per_information23	           in    varchar2 default null
  ,p_per_information24	           in    varchar2 default null
  ,p_per_information25	           in    varchar2 default null
  ,p_per_information26	           in    varchar2 default null
  ,p_per_information27	           in    varchar2 default null
  ,p_per_information28	           in    varchar2 default null
  ,p_per_information29	           in    varchar2 default null
  ,p_per_information30	           in    varchar2 default null
 ) is
  --
  l_person_id        number;
  l_employee_number  per_all_people_f.employee_number%TYPE;
  l_exists           varchar2(2);
  l_found            boolean := false;
  l_proc             varchar2(72) := g_package||'create_jp_emp_with_educ_add';
  l_legislation_code  varchar2(150);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_jp_emp_with_educ_add;
  --
  -- Check that the specified business group is valid.
  --
  hr_utility.set_location(l_proc, 10);
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  else
    if l_legislation_code <> 'JP' then
      close csr_bg;
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','JP');
      hr_utility.raise_error;
    end if;
  end if;
  close csr_bg;

  l_employee_number            := p_employee_number;
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_employee_api.create_employee
    ( p_validate                     => false
     ,p_hire_date                    => p_hire_date
     ,p_business_group_id            => p_business_group_id
     ,p_last_name                    => p_last_name_kana
     ,p_sex                          => p_sex
     ,p_person_type_id               => p_person_type_id
     ,p_per_comments                 => p_per_comments
     ,p_date_employee_data_verified  => p_date_employee_data_verified
     ,p_date_of_birth                => p_date_of_birth
     ,p_email_address                => p_email_address
     ,p_employee_number              => p_employee_number
     ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
     ,p_first_name                   => p_first_name_kana
     ,p_known_as                     => p_known_as
     ,p_marital_status               => p_marital_status
     ,p_middle_names                 => p_middle_names
     ,p_nationality                  => p_nationality
     ,p_national_identifier          => p_national_identifier
     ,p_previous_last_name           => p_previous_last_name_kana
     ,p_registered_disabled_flag     => p_registered_disabled_flag
     ,p_title                        => p_title
     ,p_vendor_id                    => p_vendor_id
     ,p_work_telephone               => p_work_telephone
     ,p_attribute_category           => p_per_attribute_category
     ,p_attribute1                   => p_per_attribute1
     ,p_attribute2                   => p_per_attribute2
     ,p_attribute3                   => p_per_attribute3
     ,p_attribute4                   => p_per_attribute4
     ,p_attribute5                   => p_per_attribute5
     ,p_attribute6                   => p_per_attribute6
     ,p_attribute7                   => p_per_attribute7
     ,p_attribute8                   => p_per_attribute8
     ,p_attribute9                   => p_per_attribute9
     ,p_attribute10                  => p_per_attribute10
     ,p_attribute11                  => p_per_attribute11
     ,p_attribute12                  => p_per_attribute12
     ,p_attribute13                  => p_per_attribute13
     ,p_attribute14                  => p_per_attribute14
     ,p_attribute15                  => p_per_attribute15
     ,p_attribute16                  => p_per_attribute16
     ,p_attribute17                  => p_per_attribute17
     ,p_attribute18                  => p_per_attribute18
     ,p_attribute19                  => p_per_attribute19
     ,p_attribute20                  => p_per_attribute20
     ,p_attribute21                  => p_per_attribute21
     ,p_attribute22                  => p_per_attribute22
     ,p_attribute23                  => p_per_attribute23
     ,p_attribute24                  => p_per_attribute24
     ,p_attribute25                  => p_per_attribute25
     ,p_attribute26                  => p_per_attribute26
     ,p_attribute27                  => p_per_attribute27
     ,p_attribute28                  => p_per_attribute28
     ,p_attribute29                  => p_per_attribute29
     ,p_attribute30                  => p_per_attribute30
     ,p_per_information_category     => 'JP'
     ,p_per_information1             => null
     ,p_per_information2             => null
     ,p_per_information3             => null
     ,p_per_information4             => null
     ,p_per_information5             => null
     ,p_per_information6             => null
     ,p_per_information7             => null
     ,p_per_information8             => null
     ,p_per_information9             => null
     ,p_per_information10            => null
     ,p_per_information11            => null
     ,p_per_information12            => null
     ,p_per_information13            => null
     ,p_per_information14            => null
     ,p_per_information15            => null
     ,p_per_information16            => null
     ,p_per_information17            => null
     ,p_per_information18            => p_last_name
     ,p_per_information19            => p_first_name
     ,p_per_information20            => p_previous_last_name
     ,p_date_of_death                => p_date_of_death
     ,p_blood_type                   => p_blood_type
     ,p_correspondence_language      => p_correspondence_language
     ,p_fte_capacity                 => p_fte_capacity
     ,p_honors                       => p_honors
     ,p_internal_location            => p_internal_location
     ,p_last_medical_test_by         => p_last_medical_test_by
     ,p_last_medical_test_date       => p_last_medical_test_date
     ,p_mailstop                     => p_mailstop
     ,p_office_number                => p_office_number
     ,p_on_military_service          => p_on_military_service
     ,p_resume_exists                => p_resume_exists
     ,p_resume_last_updated          => p_resume_last_updated
     ,p_second_passport_exists       => p_second_passport_exists
     ,p_student_status               => p_student_status
     ,p_work_schedule                => p_work_schedule
     ,p_original_date_of_hire        => p_original_date_of_hire
     ,p_person_id                    => l_person_id
     ,p_assignment_id                => p_assignment_id
     ,p_per_object_version_number    => p_per_object_version_number
     ,p_asg_object_version_number    => p_asg_object_version_number
     ,p_per_effective_start_date     => p_per_effective_start_date
     ,p_per_effective_end_date       => p_per_effective_end_date
     ,p_full_name                    => p_full_name
     ,p_per_comment_id               => p_per_comment_id
     ,p_assignment_sequence          => p_assignment_sequence
     ,p_assignment_number            => p_assignment_number
     ,p_name_combination_warning     => p_name_combination_warning
     ,p_assign_payroll_warning       => p_assign_payroll_warning
     ,p_orig_hire_warning            => p_orig_hire_warning

/* Additional parameters for Bug:4161160 */

  ,p_per_information21		  => p_english_last_name
  ,p_per_information22		  => p_english_first_name
  ,p_per_information23		  => p_per_information23
  ,p_per_information24	          => p_per_information24
  ,p_per_information25	          => p_per_information25
  ,p_per_information26	          => p_per_information26
  ,p_per_information27	          => p_per_information27
  ,p_per_information28	          => p_per_information28
  ,p_per_information29	          => p_per_information29
  ,p_per_information30	          => p_per_information30
 );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Create Educ Bkgrd if not all of the params are set to null.
  --
  if not (p_pea_comments                 is null
    and p_pea_date_from                is null
    and p_pea_date_to                  is null
    and p_pea_attribute_category       is null
    and p_pea_attribute1               is null
    and p_pea_attribute2               is null
    and p_pea_attribute3               is null
    and p_pea_attribute4               is null
    and p_pea_attribute5               is null
    and p_pea_attribute6               is null
    and p_pea_attribute7               is null
    and p_pea_attribute8               is null
    and p_pea_attribute9               is null
    and p_pea_attribute10              is null
    and p_pea_attribute11              is null
    and p_pea_attribute12              is null
    and p_pea_attribute13              is null
    and p_pea_attribute14              is null
    and p_pea_attribute15              is null
    and p_pea_attribute16              is null
    and p_pea_attribute17              is null
    and p_pea_attribute18              is null
    and p_pea_attribute19              is null
    and p_pea_attribute20              is null
    and p_school_type                  is null
    and p_school_id                    is null
    and p_school_name                  is null
    and p_school_name_kana             is null
    and p_major                        is null
    and p_major_kana                   is null
    and p_advisor                      is null
    and p_graduation_date              is null
    and p_note                         is null
    and p_last_flag                    is null
  ) then
    --
    hr_utility.set_location(l_proc, 40);
    --
    hr_jpbp_api.create_jp_educ_sit
      (p_validate                     => false
      ,p_person_id                    => l_person_id
      ,p_business_group_id            => p_business_group_id
      ,p_effective_date               => p_hire_date
      ,p_comments                     => p_pea_comments
      ,p_date_from                    => p_pea_date_from
      ,p_date_to                      => p_pea_date_to
      ,p_attribute_category           => p_pea_attribute_category
      ,p_attribute1                   => p_pea_attribute1
      ,p_attribute2                   => p_pea_attribute2
      ,p_attribute3                   => p_pea_attribute3
      ,p_attribute4                   => p_pea_attribute4
      ,p_attribute5                   => p_pea_attribute5
      ,p_attribute6                   => p_pea_attribute6
      ,p_attribute7                   => p_pea_attribute7
      ,p_attribute8                   => p_pea_attribute8
      ,p_attribute9                   => p_pea_attribute9
      ,p_attribute10                  => p_pea_attribute10
      ,p_attribute11                  => p_pea_attribute11
      ,p_attribute12                  => p_pea_attribute12
      ,p_attribute13                  => p_pea_attribute13
      ,p_attribute14                  => p_pea_attribute14
      ,p_attribute15                  => p_pea_attribute15
      ,p_attribute16                  => p_pea_attribute16
      ,p_attribute17                  => p_pea_attribute17
      ,p_attribute18                  => p_pea_attribute18
      ,p_attribute19                  => p_pea_attribute19
      ,p_attribute20                  => p_pea_attribute20
      ,p_segment1                     => p_school_type
      ,p_segment2                     => p_school_id
      ,p_segment3                     => p_school_name
      ,p_segment4                     => p_school_name_kana
      ,p_segment5                     => p_major
      ,p_segment6                     => p_major_kana
      ,p_segment7                     => p_advisor
      ,p_segment8                     => p_graduation_date
      ,p_segment9                     => p_note
      ,p_segment10                    => p_last_flag
      ,p_segment11                    => null
      ,p_segment12                    => null
      ,p_segment13                    => null
      ,p_segment14                    => null
      ,p_segment15                    => null
      ,p_segment16                    => null
      ,p_segment17                    => null
      ,p_segment18                    => null
      ,p_segment19                    => null
      ,p_segment20                    => null
      ,p_segment21                    => null
      ,p_segment22                    => null
      ,p_segment23                    => null
      ,p_segment24                    => null
      ,p_segment25                    => null
      ,p_segment26                    => null
      ,p_segment27                    => null
      ,p_segment28                    => null
      ,p_segment29                    => null
      ,p_segment30                    => null
      ,p_analysis_criteria_id         => p_analysis_criteria_id
      ,p_person_analysis_id           => p_person_analysis_id
      ,p_pea_object_version_number    => p_pea_object_version_number
      );
    --
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- call create_person_address if not all parameters are null.
  --
  if not
       (p_add_date_from             is null
    and p_add_date_to               is null
    and p_address_type              is null
    and p_add_comments              is null
    and p_address_line1             is null
    and p_address_line2             is null
    and p_address_line3             is null
    and p_district_code             is null
    and p_address_line1_kana        is null
    and p_address_line2_kana        is null
    and p_address_line3_kana        is null
    and p_postcode                  is null
    and p_country                   is null
    and p_telephone_number_1        is null
    and p_telephone_number_2        is null
    and p_fax_number                is null
    and p_addr_attribute_category   is null
    and p_addr_attribute1           is null
    and p_addr_attribute2           is null
    and p_addr_attribute3           is null
    and p_addr_attribute4           is null
    and p_addr_attribute5           is null
    and p_addr_attribute6           is null
    and p_addr_attribute7           is null
    and p_addr_attribute8           is null
    and p_addr_attribute9           is null
    and p_addr_attribute10          is null
    and p_addr_attribute11          is null
    and p_addr_attribute12          is null
    and p_addr_attribute13          is null
    and p_addr_attribute14          is null
    and p_addr_attribute15          is null
    and p_addr_attribute16          is null
    and p_addr_attribute17          is null
    and p_addr_attribute18          is null
    and p_addr_attribute19          is null
    and p_addr_attribute20          is null) then

    --
    hr_utility.set_location(l_proc, 60);
    --

    hr_person_address_api.create_person_address
      ( p_validate                      => false
       ,p_effective_date                => p_hire_date
       ,p_person_id                     => l_person_id
       ,p_primary_flag                  => 'Y'
       ,p_style                         => 'JP'
       ,p_date_from                     => p_add_date_from
       ,p_date_to                       => p_add_date_to
       ,p_address_type                  => p_address_type
       ,p_comments                      => p_add_comments
       ,p_address_line1                 => p_address_line1
       ,p_address_line2                 => p_address_line2
       ,p_address_line3                 => p_address_line3
       ,p_town_or_city                  => p_district_code
       ,p_region_1                      => p_address_line1_kana
       ,p_region_2                      => p_address_line2_kana
       ,p_region_3                      => p_address_line3_kana
       ,p_postal_code                   => p_postcode
       ,p_country                       => p_country
       ,p_telephone_number_1            => p_telephone_number_1
       ,p_telephone_number_2            => p_telephone_number_2
       ,p_telephone_number_3            => p_fax_number
       ,p_addr_attribute_category       => p_addr_attribute_category
       ,p_addr_attribute1               => p_addr_attribute1
       ,p_addr_attribute2               => p_addr_attribute2
       ,p_addr_attribute3               => p_addr_attribute3
       ,p_addr_attribute4               => p_addr_attribute4
       ,p_addr_attribute5               => p_addr_attribute5
       ,p_addr_attribute6               => p_addr_attribute6
       ,p_addr_attribute7               => p_addr_attribute7
       ,p_addr_attribute8               => p_addr_attribute8
       ,p_addr_attribute9               => p_addr_attribute9
       ,p_addr_attribute10              => p_addr_attribute10
       ,p_addr_attribute11              => p_addr_attribute11
       ,p_addr_attribute12              => p_addr_attribute12
       ,p_addr_attribute13              => p_addr_attribute13
       ,p_addr_attribute14              => p_addr_attribute14
       ,p_addr_attribute15              => p_addr_attribute15
       ,p_addr_attribute16              => p_addr_attribute16
       ,p_addr_attribute17              => p_addr_attribute17
       ,p_addr_attribute18              => p_addr_attribute18
       ,p_addr_attribute19              => p_addr_attribute19
       ,p_addr_attribute20              => p_addr_attribute20
       ,p_address_id                    => p_address_id
       ,p_object_version_number         => p_add_object_version_number
      );
  end if;
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_person_id := l_person_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_jp_emp_with_educ_add;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_id                     := null;
    p_assignment_id                 := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;
    p_assignment_number             := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;

    p_address_id                    := null;
    p_add_object_version_number     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);

  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_jp_emp_with_educ_add;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_employee_number            := l_employee_number;
    p_person_id                  := null;
    p_assignment_id              := null;
    p_per_object_version_number  := null;
    p_asg_object_version_number  := null;
    p_per_effective_start_date   := null;
    p_per_effective_end_date     := null;
    p_full_name                  := null;
    p_per_comment_id             := null;
    p_assignment_sequence        := null;
    p_assignment_number          := null;

    p_name_combination_warning   := null;
    p_assign_payroll_warning     := null;
    p_orig_hire_warning          := null;

    p_pea_object_version_number  := null;
    p_analysis_criteria_id       := null;
    p_person_analysis_id         := null;

    hr_utility.set_location(' Leaving:'||l_proc, 100);
    raise;
end create_jp_emp_with_educ_add;


-- ----------------------------------------------------------------------------
-- |---------------------< create_jp_applicant_with_sit >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_jp_applicant_with_sit
  (
   -- for per_people_f
   --
   p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2 default null
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_application_id                out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_apl_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_name_combination_warning      out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean

  /* for special information */

  ,p_id_flex_num                   in     number
  ,p_pea_comments                  in     varchar2 default null
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'create_jp_applicant_with_sit';
  l_legislation_code           varchar2(2);
  l_person_id                  per_people_f.person_id%TYPE;
  l_application_id             number;
  l_applicant_number           per_all_people_f.applicant_number%TYPE;
  l_apl_object_version_number  number;
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
 --
  -- Issue a savepoint
  --
  savepoint create_jp_applicant_with_sit;

  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'JP'.
  --
  if l_legislation_code <> 'JP' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','JP');
    hr_utility.raise_error;
  end if;

  l_applicant_number            := p_applicant_number;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Call the person business process
  --
  hr_applicant_api.create_applicant
  (p_validate                     => false
  ,p_date_received                => p_date_received
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name_kana
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_per_comments                 => p_per_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_applicant_number             => p_applicant_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name_kana
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_national_identifier
  ,p_previous_last_name           => p_previous_last_name_kana
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_work_telephone               => p_work_telephone
  ,p_attribute_category           => p_per_attribute_category
  ,p_attribute1                   => p_per_attribute1
  ,p_attribute2                   => p_per_attribute2
  ,p_attribute3                   => p_per_attribute3
  ,p_attribute4                   => p_per_attribute4
  ,p_attribute5                   => p_per_attribute5
  ,p_attribute6                   => p_per_attribute6
  ,p_attribute7                   => p_per_attribute7
  ,p_attribute8                   => p_per_attribute8
  ,p_attribute9                   => p_per_attribute9
  ,p_attribute10                  => p_per_attribute10
  ,p_attribute11                  => p_per_attribute11
  ,p_attribute12                  => p_per_attribute12
  ,p_attribute13                  => p_per_attribute13
  ,p_attribute14                  => p_per_attribute14
  ,p_attribute15                  => p_per_attribute15
  ,p_attribute16                  => p_per_attribute16
  ,p_attribute17                  => p_per_attribute17
  ,p_attribute18                  => p_per_attribute18
  ,p_attribute19                  => p_per_attribute19
  ,p_attribute20                  => p_per_attribute20
  ,p_attribute21                  => p_per_attribute21
  ,p_attribute22                  => p_per_attribute22
  ,p_attribute23                  => p_per_attribute23
  ,p_attribute24                  => p_per_attribute24
  ,p_attribute25                  => p_per_attribute25
  ,p_attribute26                  => p_per_attribute26
  ,p_attribute27                  => p_per_attribute27
  ,p_attribute28                  => p_per_attribute28
  ,p_attribute29                  => p_per_attribute29
  ,p_attribute30                  => p_per_attribute30
  ,p_per_information_category     => 'JP'
  ,p_per_information1             => null
  ,p_per_information2             => null
  ,p_per_information3             => null
  ,p_per_information4             => null
  ,p_per_information5             => null
  ,p_per_information6             => null
  ,p_per_information7             => null
  ,p_per_information8             => null
  ,p_per_information9             => null
  ,p_per_information10            => null
  ,p_per_information11            => null
  ,p_per_information12            => null
  ,p_per_information13            => null
  ,p_per_information14            => null
  ,p_per_information15            => null
  ,p_per_information16            => null
  ,p_per_information17            => null
  ,p_per_information18            => p_last_name
  ,p_per_information19            => p_first_name
  ,p_per_information20            => p_previous_last_name
  ,p_correspondence_language      => p_correspondence_language
  ,p_fte_capacity                 => p_fte_capacity
  ,p_hold_applicant_date_until    => p_hold_applicant_date_until
  ,p_honors                       => p_honors
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_date_of_death                => p_date_of_death
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_person_id                    => l_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_application_id               => p_application_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_apl_object_version_number    => p_apl_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Create SIT if not all params are set to null.
  --
  if not (p_id_flex_num                  is null
    and p_pea_comments                 is null
    and p_date_from                    is null
    and p_date_to                      is null
    and p_pea_attribute_category       is null
    and p_pea_attribute1               is null
    and p_pea_attribute2               is null
    and p_pea_attribute3               is null
    and p_pea_attribute4               is null
    and p_pea_attribute5               is null
    and p_pea_attribute6               is null
    and p_pea_attribute7               is null
    and p_pea_attribute8               is null
    and p_pea_attribute9               is null
    and p_pea_attribute10              is null
    and p_pea_attribute11              is null
    and p_pea_attribute12              is null
    and p_pea_attribute13              is null
    and p_pea_attribute14              is null
    and p_pea_attribute15              is null
    and p_pea_attribute16              is null
    and p_pea_attribute17              is null
    and p_pea_attribute18              is null
    and p_pea_attribute19              is null
    and p_pea_attribute20              is null
    and p_segment1                     is null
    and p_segment2                     is null
    and p_segment3                     is null
    and p_segment4                     is null
    and p_segment5                     is null
    and p_segment6                     is null
    and p_segment7                     is null
    and p_segment8                     is null
    and p_segment9                     is null
    and p_segment10                    is null
    and p_segment11                    is null
    and p_segment12                    is null
    and p_segment13                    is null
    and p_segment14                    is null
    and p_segment15                    is null
    and p_segment16                    is null
    and p_segment17                    is null
    and p_segment18                    is null
    and p_segment19                    is null
    and p_segment20                    is null
    and p_segment21                    is null
    and p_segment22                    is null
    and p_segment23                    is null
    and p_segment24                    is null
    and p_segment25                    is null
    and p_segment26                    is null
    and p_segment27                    is null
    and p_segment28                    is null
    and p_segment29                    is null
    and p_segment30                    is null
  ) then
    --
    hr_utility.set_location(l_proc, 30);
    --
    hr_sit_api.create_sit
     (p_validate                     => false
     ,p_person_id                    => l_person_id
     ,p_business_group_id            => p_business_group_id
     ,p_id_flex_num                  => p_id_flex_num
     ,p_effective_date               => p_date_received
     ,p_comments                     => p_per_comments
     ,p_date_from                    => p_date_from
     ,p_date_to                      => p_date_to
     ,p_attribute_category           => p_pea_attribute_category
     ,p_attribute1                   => p_pea_attribute1
     ,p_attribute2                   => p_pea_attribute2
     ,p_attribute3                   => p_pea_attribute3
     ,p_attribute4                   => p_pea_attribute4
     ,p_attribute5                   => p_pea_attribute5
     ,p_attribute6                   => p_pea_attribute6
     ,p_attribute7                   => p_pea_attribute7
     ,p_attribute8                   => p_pea_attribute8
     ,p_attribute9                   => p_pea_attribute9
     ,p_attribute10                  => p_pea_attribute10
     ,p_attribute11                  => p_pea_attribute11
     ,p_attribute12                  => p_pea_attribute12
     ,p_attribute13                  => p_pea_attribute13
     ,p_attribute14                  => p_pea_attribute14
     ,p_attribute15                  => p_pea_attribute15
     ,p_attribute16                  => p_pea_attribute16
     ,p_attribute17                  => p_pea_attribute17
     ,p_attribute18                  => p_pea_attribute18
     ,p_attribute19                  => p_pea_attribute19
     ,p_attribute20                  => p_pea_attribute20
     ,p_segment1                     => p_segment1
     ,p_segment2                     => p_segment2
     ,p_segment3                     => p_segment3
     ,p_segment4                     => p_segment4
     ,p_segment5                     => p_segment5
     ,p_segment6                     => p_segment6
     ,p_segment7                     => p_segment7
     ,p_segment8                     => p_segment8
     ,p_segment9                     => p_segment9
     ,p_segment10                    => p_segment10
     ,p_segment11                    => p_segment11
     ,p_segment12                    => p_segment12
     ,p_segment13                    => p_segment13
     ,p_segment14                    => p_segment14
     ,p_segment15                    => p_segment15
     ,p_segment16                    => p_segment16
     ,p_segment17                    => p_segment17
     ,p_segment18                    => p_segment18
     ,p_segment19                    => p_segment19
     ,p_segment20                    => p_segment20
     ,p_segment21                    => p_segment21
     ,p_segment22                    => p_segment22
     ,p_segment23                    => p_segment23
     ,p_segment24                    => p_segment24
     ,p_segment25                    => p_segment25
     ,p_segment26                    => p_segment26
     ,p_segment27                    => p_segment27
     ,p_segment28                    => p_segment28
     ,p_segment29                    => p_segment29
     ,p_segment30                    => p_segment30
     ,p_analysis_criteria_id         => p_analysis_criteria_id
     ,p_person_analysis_id           => p_person_analysis_id
     ,p_pea_object_version_number    => p_pea_object_version_number
     );
  end if;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_person_id := l_person_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_jp_applicant_with_sit;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_id                     := null;
    p_assignment_id                 := null;
    p_application_id                := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_apl_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;

  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_jp_applicant_with_sit;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    p_applicant_number              := l_applicant_number;

    p_person_id                     := null;
    p_assignment_id                 := null;
    p_application_id                := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_apl_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;
    p_name_combination_warning      := null;
    p_orig_hire_warning             := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;

    hr_utility.set_location(' Leaving:'||l_proc, 50);
    raise;
end create_jp_applicant_with_sit;
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_jp_appl_with_educ_add>------------------------|
-- ----------------------------------------------------------------------------
procedure create_jp_appl_with_educ_add
  (
   -- for per_people_f
   --
   p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_last_name_kana                in     varchar2
  ,p_sex                           in     varchar2 default null
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_first_name_kana               in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_previous_last_name_kana       in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_per_attribute_category        in     varchar2 default null
  ,p_per_attribute1                in     varchar2 default null
  ,p_per_attribute2                in     varchar2 default null
  ,p_per_attribute3                in     varchar2 default null
  ,p_per_attribute4                in     varchar2 default null
  ,p_per_attribute5                in     varchar2 default null
  ,p_per_attribute6                in     varchar2 default null
  ,p_per_attribute7                in     varchar2 default null
  ,p_per_attribute8                in     varchar2 default null
  ,p_per_attribute9                in     varchar2 default null
  ,p_per_attribute10               in     varchar2 default null
  ,p_per_attribute11               in     varchar2 default null
  ,p_per_attribute12               in     varchar2 default null
  ,p_per_attribute13               in     varchar2 default null
  ,p_per_attribute14               in     varchar2 default null
  ,p_per_attribute15               in     varchar2 default null
  ,p_per_attribute16               in     varchar2 default null
  ,p_per_attribute17               in     varchar2 default null
  ,p_per_attribute18               in     varchar2 default null
  ,p_per_attribute19               in     varchar2 default null
  ,p_per_attribute20               in     varchar2 default null
  ,p_per_attribute21               in     varchar2 default null
  ,p_per_attribute22               in     varchar2 default null
  ,p_per_attribute23               in     varchar2 default null
  ,p_per_attribute24               in     varchar2 default null
  ,p_per_attribute25               in     varchar2 default null
  ,p_per_attribute26               in     varchar2 default null
  ,p_per_attribute27               in     varchar2 default null
  ,p_per_attribute28               in     varchar2 default null
  ,p_per_attribute29               in     varchar2 default null
  ,p_per_attribute30               in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_original_date_of_hire         in     date     default null
  ,p_person_id                     out nocopy    number
  ,p_assignment_id                 out nocopy    number
  ,p_application_id                out nocopy    number
  ,p_per_object_version_number     out nocopy    number
  ,p_asg_object_version_number     out nocopy    number
  ,p_apl_object_version_number     out nocopy    number
  ,p_per_effective_start_date      out nocopy    date
  ,p_per_effective_end_date        out nocopy    date
  ,p_full_name                     out nocopy    varchar2
  ,p_per_comment_id                out nocopy    number
  ,p_assignment_sequence           out nocopy    number
  ,p_name_combination_warning      out nocopy    boolean
  ,p_orig_hire_warning             out nocopy    boolean
  --
  -- for special information
  --
  ,p_pea_comments                  in     varchar2 default null
  ,p_pea_date_from                 in     date     default null
  ,p_pea_date_to                   in     date     default null
  ,p_pea_attribute_category        in     varchar2 default null
  ,p_pea_attribute1                in     varchar2 default null
  ,p_pea_attribute2                in     varchar2 default null
  ,p_pea_attribute3                in     varchar2 default null
  ,p_pea_attribute4                in     varchar2 default null
  ,p_pea_attribute5                in     varchar2 default null
  ,p_pea_attribute6                in     varchar2 default null
  ,p_pea_attribute7                in     varchar2 default null
  ,p_pea_attribute8                in     varchar2 default null
  ,p_pea_attribute9                in     varchar2 default null
  ,p_pea_attribute10               in     varchar2 default null
  ,p_pea_attribute11               in     varchar2 default null
  ,p_pea_attribute12               in     varchar2 default null
  ,p_pea_attribute13               in     varchar2 default null
  ,p_pea_attribute14               in     varchar2 default null
  ,p_pea_attribute15               in     varchar2 default null
  ,p_pea_attribute16               in     varchar2 default null
  ,p_pea_attribute17               in     varchar2 default null
  ,p_pea_attribute18               in     varchar2 default null
  ,p_pea_attribute19               in     varchar2 default null
  ,p_pea_attribute20               in     varchar2 default null
  ,p_school_type                   in     varchar2 default null
  ,p_school_id                     in     varchar2 default null
  ,p_school_name                   in     varchar2 default null
  ,p_school_name_kana              in     varchar2 default null
  ,p_major                         in     varchar2 default null
  ,p_major_kana                    in     varchar2 default null
  ,p_advisor                       in     varchar2 default null
  ,p_graduation_date               in     varchar2 default null
  ,p_note                          in     varchar2 default null
  ,p_last_flag                     in     varchar2 default null
--  ,p_school_flag                   in     varchar2 default null
  ,p_pea_object_version_number     out nocopy    number
  ,p_analysis_criteria_id          out nocopy    number
  ,p_person_analysis_id            out nocopy    number
  --
  -- for per_addresses
  --
--  ,p_primary_flag                  in     varchar2
  ,p_add_date_from                 in     date     default null
  ,p_add_date_to                   in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_add_comments                  in     varchar2 default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_district_code                 in     varchar2 default null
  ,p_address_line1_kana            in     varchar2 default null
  ,p_address_line2_kana            in     varchar2 default null
  ,p_address_line3_kana            in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_fax_number                    in     varchar2 default null
  ,p_addr_attribute_category       in     varchar2 default null
  ,p_addr_attribute1               in     varchar2 default null
  ,p_addr_attribute2               in     varchar2 default null
  ,p_addr_attribute3               in     varchar2 default null
  ,p_addr_attribute4               in     varchar2 default null
  ,p_addr_attribute5               in     varchar2 default null
  ,p_addr_attribute6               in     varchar2 default null
  ,p_addr_attribute7               in     varchar2 default null
  ,p_addr_attribute8               in     varchar2 default null
  ,p_addr_attribute9               in     varchar2 default null
  ,p_addr_attribute10              in     varchar2 default null
  ,p_addr_attribute11              in     varchar2 default null
  ,p_addr_attribute12              in     varchar2 default null
  ,p_addr_attribute13              in     varchar2 default null
  ,p_addr_attribute14              in     varchar2 default null
  ,p_addr_attribute15              in     varchar2 default null
  ,p_addr_attribute16              in     varchar2 default null
  ,p_addr_attribute17              in     varchar2 default null
  ,p_addr_attribute18              in     varchar2 default null
  ,p_addr_attribute19              in     varchar2 default null
  ,p_addr_attribute20              in     varchar2 default null
  ,p_address_id                    out nocopy number
  ,p_add_object_version_number     out nocopy number
  )is
  --
  l_person_id         number;
  l_applicant_number  per_all_people_f.applicant_number%TYPE;
  l_exists            varchar2(2);
  l_found             boolean := false;
  l_proc              varchar2(72) := g_package||'create_jp_appl_with_educ_add';
  l_legislation_code  varchar2(150);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint create_jp_appl_with_educ_add;

  --
  -- Check that the specified business group is valid.
  --
  hr_utility.set_location(l_proc, 10);
  --
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  else
    if l_legislation_code <> 'JP' then
      close csr_bg;
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','JP');
      hr_utility.raise_error;
    end if;
  end if;
  close csr_bg;

  l_applicant_number            := p_applicant_number;
  --
  -- call create_person_address
  --
  hr_utility.set_location(l_proc, 20);
  --
  hr_applicant_api.create_applicant
    ( p_validate                     => false
     ,p_date_received                => p_date_received
     ,p_business_group_id            => p_business_group_id
     ,p_last_name                    => p_last_name_kana
     ,p_sex                          => p_sex
     ,p_person_type_id               => p_person_type_id
     ,p_per_comments                 => p_per_comments
     ,p_date_employee_data_verified  => p_date_employee_data_verified
     ,p_date_of_birth                => p_date_of_birth
     ,p_email_address                => p_email_address
     ,p_applicant_number             => p_applicant_number
     ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
     ,p_first_name                   => p_first_name_kana
     ,p_known_as                     => p_known_as
     ,p_marital_status               => p_marital_status
     ,p_middle_names                 => p_middle_names
     ,p_nationality                  => p_nationality
     ,p_national_identifier          => p_national_identifier
     ,p_previous_last_name           => p_previous_last_name_kana
     ,p_registered_disabled_flag     => p_registered_disabled_flag
     ,p_title                        => p_title
     ,p_work_telephone               => p_work_telephone
     ,p_attribute_category           => p_per_attribute_category
     ,p_attribute1                   => p_per_attribute1
     ,p_attribute2                   => p_per_attribute2
     ,p_attribute3                   => p_per_attribute3
     ,p_attribute4                   => p_per_attribute4
     ,p_attribute5                   => p_per_attribute5
     ,p_attribute6                   => p_per_attribute6
     ,p_attribute7                   => p_per_attribute7
     ,p_attribute8                   => p_per_attribute8
     ,p_attribute9                   => p_per_attribute9
     ,p_attribute10                  => p_per_attribute10
     ,p_attribute11                  => p_per_attribute11
     ,p_attribute12                  => p_per_attribute12
     ,p_attribute13                  => p_per_attribute13
     ,p_attribute14                  => p_per_attribute14
     ,p_attribute15                  => p_per_attribute15
     ,p_attribute16                  => p_per_attribute16
     ,p_attribute17                  => p_per_attribute17
     ,p_attribute18                  => p_per_attribute18
     ,p_attribute19                  => p_per_attribute19
     ,p_attribute20                  => p_per_attribute20
     ,p_attribute21                  => p_per_attribute21
     ,p_attribute22                  => p_per_attribute22
     ,p_attribute23                  => p_per_attribute23
     ,p_attribute24                  => p_per_attribute24
     ,p_attribute25                  => p_per_attribute25
     ,p_attribute26                  => p_per_attribute26
     ,p_attribute27                  => p_per_attribute27
     ,p_attribute28                  => p_per_attribute28
     ,p_attribute29                  => p_per_attribute29
     ,p_attribute30                  => p_per_attribute30
     ,p_per_information_category     => 'JP'
     ,p_per_information1             => null
     ,p_per_information2             => null
     ,p_per_information3             => null
     ,p_per_information4             => null
     ,p_per_information5             => null
     ,p_per_information6             => null
     ,p_per_information7             => null
     ,p_per_information8             => null
     ,p_per_information9             => null
     ,p_per_information10            => null
     ,p_per_information11            => null
     ,p_per_information12            => null
     ,p_per_information13            => null
     ,p_per_information14            => null
     ,p_per_information15            => null
     ,p_per_information16            => null
     ,p_per_information17            => null
     ,p_per_information18            => p_last_name
     ,p_per_information19            => p_first_name
     ,p_per_information20            => p_previous_last_name
     ,p_correspondence_language      => p_correspondence_language
     ,p_fte_capacity                 => p_fte_capacity
     ,p_hold_applicant_date_until    => p_hold_applicant_date_until
     ,p_honors                       => p_honors
     ,p_mailstop                     => p_mailstop
     ,p_office_number                => p_office_number
     ,p_on_military_service          => p_on_military_service
     ,p_resume_exists                => p_resume_exists
     ,p_resume_last_updated          => p_resume_last_updated
     ,p_student_status               => p_student_status
     ,p_work_schedule                => p_work_schedule
     ,p_date_of_death                => p_date_of_death
     ,p_original_date_of_hire        => p_original_date_of_hire
     ,p_person_id                    => l_person_id
     ,p_assignment_id                => p_assignment_id
     ,p_application_id               => p_application_id
     ,p_per_object_version_number    => p_per_object_version_number
     ,p_asg_object_version_number    => p_asg_object_version_number
     ,p_apl_object_version_number    => p_apl_object_version_number
     ,p_per_effective_start_date     => p_per_effective_start_date
     ,p_per_effective_end_date       => p_per_effective_end_date
     ,p_full_name                    => p_full_name
     ,p_per_comment_id               => p_per_comment_id
     ,p_assignment_sequence          => p_assignment_sequence
     ,p_name_combination_warning     => p_name_combination_warning
     ,p_orig_hire_warning            => p_orig_hire_warning
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Create Educ Bkgrd if not all of the params are set to null.
  --
  if not (p_pea_comments                 is null
    and p_pea_date_from                is null
    and p_pea_date_to                  is null
    and p_pea_attribute_category       is null
    and p_pea_attribute1               is null
    and p_pea_attribute2               is null
    and p_pea_attribute3               is null
    and p_pea_attribute4               is null
    and p_pea_attribute5               is null
    and p_pea_attribute6               is null
    and p_pea_attribute7               is null
    and p_pea_attribute8               is null
    and p_pea_attribute9               is null
    and p_pea_attribute10              is null
    and p_pea_attribute11              is null
    and p_pea_attribute12              is null
    and p_pea_attribute13              is null
    and p_pea_attribute14              is null
    and p_pea_attribute15              is null
    and p_pea_attribute16              is null
    and p_pea_attribute17              is null
    and p_pea_attribute18              is null
    and p_pea_attribute19              is null
    and p_pea_attribute20              is null
    and p_school_type                  is null
    and p_school_id                    is null
    and p_school_name                  is null
    and p_school_name_kana             is null
    and p_major                        is null
    and p_major_kana                   is null
    and p_advisor                      is null
    and p_graduation_date              is null
    and p_note                         is null
    and p_last_flag                    is null
  ) then
    --
    hr_utility.set_location(l_proc, 40);
    --
    hr_jpbp_api.create_jp_educ_sit
      (p_validate                     => false
      ,p_person_id                    => l_person_id
      ,p_business_group_id            => p_business_group_id
      ,p_effective_date               => p_date_received
      ,p_comments                     => p_pea_comments
      ,p_date_from                    => p_pea_date_from
      ,p_date_to                      => p_pea_date_to
      ,p_attribute_category           => p_pea_attribute_category
      ,p_attribute1                   => p_pea_attribute1
      ,p_attribute2                   => p_pea_attribute2
      ,p_attribute3                   => p_pea_attribute3
      ,p_attribute4                   => p_pea_attribute4
      ,p_attribute5                   => p_pea_attribute5
      ,p_attribute6                   => p_pea_attribute6
      ,p_attribute7                   => p_pea_attribute7
      ,p_attribute8                   => p_pea_attribute8
      ,p_attribute9                   => p_pea_attribute9
      ,p_attribute10                  => p_pea_attribute10
      ,p_attribute11                  => p_pea_attribute11
      ,p_attribute12                  => p_pea_attribute12
      ,p_attribute13                  => p_pea_attribute13
      ,p_attribute14                  => p_pea_attribute14
      ,p_attribute15                  => p_pea_attribute15
      ,p_attribute16                  => p_pea_attribute16
      ,p_attribute17                  => p_pea_attribute17
      ,p_attribute18                  => p_pea_attribute18
      ,p_attribute19                  => p_pea_attribute19
      ,p_attribute20                  => p_pea_attribute20
      ,p_segment1                     => p_school_type
      ,p_segment2                     => p_school_id
      ,p_segment3                     => p_school_name
      ,p_segment4                     => p_school_name_kana
      ,p_segment5                     => p_major
      ,p_segment6                     => p_major_kana
      ,p_segment8                     => p_graduation_date
      ,p_segment7                     => p_advisor
      ,p_segment9                     => p_note
      ,p_segment10                    => p_last_flag
      ,p_segment11                    => null
      ,p_segment12                    => null
      ,p_segment13                    => null
      ,p_segment14                    => null
      ,p_segment15                    => null
      ,p_segment16                    => null
      ,p_segment17                    => null
      ,p_segment18                    => null
      ,p_segment19                    => null
      ,p_segment20                    => null
      ,p_segment21                    => null
      ,p_segment22                    => null
      ,p_segment23                    => null
      ,p_segment24                    => null
      ,p_segment25                    => null
      ,p_segment26                    => null
      ,p_segment27                    => null
      ,p_segment28                    => null
      ,p_segment29                    => null
      ,p_segment30                    => null
      ,p_analysis_criteria_id         => p_analysis_criteria_id
      ,p_person_analysis_id           => p_person_analysis_id
      ,p_pea_object_version_number    => p_pea_object_version_number
      );
    --
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- call create_person_address if not all parameters are null.
  --
  if not
       (p_add_date_from             is null
    and p_add_date_to               is null
    and p_address_type              is null
    and p_add_comments              is null
    and p_address_line1             is null
    and p_address_line2             is null
    and p_address_line3             is null
    and p_district_code             is null
    and p_address_line1_kana        is null
    and p_address_line2_kana        is null
    and p_address_line3_kana        is null
    and p_postcode                  is null
    and p_country                   is null
    and p_telephone_number_1        is null
    and p_telephone_number_2        is null
    and p_fax_number                is null
    and p_addr_attribute_category   is null
    and p_addr_attribute1           is null
    and p_addr_attribute2           is null
    and p_addr_attribute3           is null
    and p_addr_attribute4           is null
    and p_addr_attribute5           is null
    and p_addr_attribute6           is null
    and p_addr_attribute7           is null
    and p_addr_attribute8           is null
    and p_addr_attribute9           is null
    and p_addr_attribute10          is null
    and p_addr_attribute11          is null
    and p_addr_attribute12          is null
    and p_addr_attribute13          is null
    and p_addr_attribute14          is null
    and p_addr_attribute15          is null
    and p_addr_attribute16          is null
    and p_addr_attribute17          is null
    and p_addr_attribute18          is null
    and p_addr_attribute19          is null
    and p_addr_attribute20          is null) then
    --
    hr_utility.set_location(l_proc, 60);
    --
    hr_person_address_api.create_person_address
      ( p_validate                      => false
       ,p_effective_date                => p_date_received
       ,p_person_id                     => l_person_id
       ,p_primary_flag                  => 'Y'
       ,p_style                         => 'JP'
       ,p_date_from                     => p_add_date_from
       ,p_date_to                       => p_add_date_to
       ,p_address_type                  => p_address_type
       ,p_comments                      => p_add_comments
       ,p_address_line1                 => p_address_line1
       ,p_address_line2                 => p_address_line2
       ,p_address_line3                 => p_address_line3
       ,p_town_or_city                  => p_district_code
       ,p_region_1                      => p_address_line1_kana
       ,p_region_2                      => p_address_line2_kana
       ,p_region_3                      => p_address_line3_kana
       ,p_postal_code                   => p_postcode
       ,p_country                       => p_country
       ,p_telephone_number_1            => p_telephone_number_1
       ,p_telephone_number_2            => p_telephone_number_2
       ,p_telephone_number_3            => p_fax_number
       ,p_addr_attribute_category       => p_addr_attribute_category
       ,p_addr_attribute1               => p_addr_attribute1
       ,p_addr_attribute2               => p_addr_attribute2
       ,p_addr_attribute3               => p_addr_attribute3
       ,p_addr_attribute4               => p_addr_attribute4
       ,p_addr_attribute5               => p_addr_attribute5
       ,p_addr_attribute6               => p_addr_attribute6
       ,p_addr_attribute7               => p_addr_attribute7
       ,p_addr_attribute8               => p_addr_attribute8
       ,p_addr_attribute9               => p_addr_attribute9
       ,p_addr_attribute10              => p_addr_attribute10
       ,p_addr_attribute11              => p_addr_attribute11
       ,p_addr_attribute12              => p_addr_attribute12
       ,p_addr_attribute13              => p_addr_attribute13
       ,p_addr_attribute14              => p_addr_attribute14
       ,p_addr_attribute15              => p_addr_attribute15
       ,p_addr_attribute16              => p_addr_attribute16
       ,p_addr_attribute17              => p_addr_attribute17
       ,p_addr_attribute18              => p_addr_attribute18
       ,p_addr_attribute19              => p_addr_attribute19
       ,p_addr_attribute20              => p_addr_attribute20
       ,p_address_id                    => p_address_id
       ,p_object_version_number         => p_add_object_version_number
      );
  end if;
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_person_id := l_person_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_jp_appl_with_educ_add;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_id                     := null;
    p_assignment_id                 := null;
    p_application_id                := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_apl_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;

    p_address_id                    := null;
    p_add_object_version_number     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);

  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_jp_appl_with_educ_add;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_applicant_number              := l_applicant_number;

    p_person_id                     := null;
    p_assignment_id                 := null;
    p_application_id                := null;
    p_per_object_version_number     := null;
    p_asg_object_version_number     := null;
    p_apl_object_version_number     := null;
    p_per_effective_start_date      := null;
    p_per_effective_end_date        := null;
    p_full_name                     := null;
    p_per_comment_id                := null;
    p_assignment_sequence           := null;
    p_name_combination_warning      := null;
    p_orig_hire_warning             := null;

    p_pea_object_version_number     := null;
    p_analysis_criteria_id          := null;
    p_person_analysis_id            := null;

    p_address_id                    := null;
    p_add_object_version_number     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 100);
    raise;
end create_jp_appl_with_educ_add;
--
end HR_JPBP_API;

/
