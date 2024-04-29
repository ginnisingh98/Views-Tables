--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ATT" as
/* $Header: peperati.pkb 120.1 2005/06/15 05:39:23 bshukla noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_person_att.';
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person >------------------------------|
-- ----------------------------------------------------------------------------
procedure update_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_attribute_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_per_information1             in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy  date
  ,p_effective_end_date              out nocopy  date
  ,p_full_name                       out nocopy  varchar2
  ,p_comment_id                      out nocopy  number
  ,p_name_combination_warning        out nocopy  boolean
  ,p_assign_payroll_warning          out nocopy  boolean
  ,p_orig_hire_warning               out nocopy  boolean) is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_proc                     varchar2(72)  := g_package||'update_person';
  l_effective_date           date          := trunc(p_effective_date);
  l_constant_effective_date  constant date := l_effective_date;
  l_effective_date_row       boolean       := true;
  l_validation_start_date    date;
  l_validation_end_date      date;
  l_datetrack_update_mode    varchar2(30);
  l_correction               boolean;
  l_update                   boolean;
  l_update_override          boolean;
  l_update_change_insert     boolean;
  l_lck_start_date           date;
  -- --------------------------------------------------------------------------
  -- local cursor definitions
  -- --------------------------------------------------------------------------
  -- csr_per_lck  -> locks all the datetracked rows for the specified person
  --                 from the specified lock date. this enforces integrity.
  --                 if the datetrack operation is for an ATTRIBUTE_UPDATE
  --                 then only the current and future rows will be locked. if
  --                 the datetrack operation is a ATTRIBUTE_CORRECTION then
  --                 all person rows are locked as we cannot guarantee how
  --                 many rows will be changed.
  -- csr_per1     -> selects person details for the current and future rows
  -- csr_per2     -> selects person details in the past in a descending order
  --                 not including the current row as of the effective date.
  --
  -- note: the cursors csr_per1 nd csr_per2 are specifically not merged
  --       because of the of the order by clause
  --
  -- cursor to lock all rows for which the datetrack operation could
  -- operate over
  cursor csr_per_lck(c_lck_start_date date) is
    select 1
    from   per_people_f per
    where  per.person_id = p_person_id
    and    per.effective_end_date >= c_lck_start_date
    for    update nowait;
  -- select current and future rows
  cursor csr_per1 is
    select per.object_version_number
          ,per.person_type_id
          ,per.employee_number
          ,per.last_name
          ,per.applicant_number
          ,per.date_employee_data_verified
          ,per.date_of_birth
          ,per.email_address
          ,per.expense_check_send_to_address
          ,per.first_name
          ,per.known_as
          ,per.marital_status
          ,per.middle_names
          ,per.nationality
          ,per.national_identifier
          ,per.previous_last_name
          ,per.registered_disabled_flag
          ,per.sex
          ,per.title
          ,per.vendor_id
          ,per.work_telephone
          ,per.suffix
          ,per.attribute_category
          ,per.attribute1
          ,per.attribute2
          ,per.attribute3
          ,per.attribute4
          ,per.attribute5
          ,per.attribute6
          ,per.attribute7
          ,per.attribute8
          ,per.attribute9
          ,per.attribute10
          ,per.attribute11
          ,per.attribute12
          ,per.attribute13
          ,per.attribute14
          ,per.attribute15
          ,per.attribute16
          ,per.attribute17
          ,per.attribute18
          ,per.attribute19
          ,per.attribute20
          ,per.attribute21
          ,per.attribute22
          ,per.attribute23
          ,per.attribute24
          ,per.attribute25
          ,per.attribute26
          ,per.attribute27
          ,per.attribute28
          ,per.attribute29
          ,per.attribute30
          ,per.per_information_category
          ,per.per_information1
          ,per.per_information2
          ,per.per_information3
          ,per.per_information4
          ,per.per_information5
          ,per.per_information6
          ,per.per_information7
          ,per.per_information8
          ,per.per_information9
          ,per.per_information10
          ,per.per_information11
          ,per.per_information12
          ,per.per_information13
          ,per.per_information14
          ,per.per_information15
          ,per.per_information16
          ,per.per_information17
          ,per.per_information18
          ,per.per_information19
          ,per.per_information20
          ,per.per_information21
          ,per.per_information22
          ,per.per_information23
          ,per.per_information24
          ,per.per_information25
          ,per.per_information26
          ,per.per_information27
          ,per.per_information28
          ,per.per_information29
          ,per.per_information30
          ,per.date_of_death
          ,per.background_check_status
          ,per.background_date_check
          ,per.blood_type
          ,per.correspondence_language
          ,per.fast_path_employee
          ,per.fte_capacity
          ,per.hold_applicant_date_until
          ,per.honors
          ,per.internal_location
          ,per.last_medical_test_by
          ,per.last_medical_test_date
          ,per.mailstop
          ,per.office_number
          ,per.on_military_service
          ,per.pre_name_adjunct
          ,per.projected_start_date
          ,per.rehire_authorizor
          ,per.rehire_recommendation
          ,per.resume_exists
          ,per.resume_last_updated
          ,per.second_passport_exists
          ,per.student_status
          ,per.work_schedule
          ,per.rehire_reason
          ,per.benefit_group_id
          ,per.receipt_of_death_cert_date
          ,per.coord_ben_med_pln_no
          ,per.coord_ben_no_cvg_flag
          ,per.uses_tobacco_flag
          ,per.dpdnt_adoption_date
          ,per.dpdnt_vlntry_svce_flag
          ,per.original_date_of_hire
          ,per.town_of_birth
          ,per.region_of_birth
          ,per.country_of_birth
          ,per.global_person_id
          ,per.effective_start_date
          ,per.effective_end_date
          ,hc.comment_text
    from    hr_comments             hc
           ,per_all_people_f        per
    where   per.person_id           = p_person_id
    and     per.effective_end_date >= l_constant_effective_date
    and     hc.comment_id (+)       = per.comment_id
    order by per.effective_end_date asc;
    -- select past rows not including the current rows
    cursor csr_per2 is
    select per.object_version_number
          ,per.person_type_id
          ,per.employee_number
          ,per.last_name
          ,per.applicant_number
          ,per.date_employee_data_verified
          ,per.date_of_birth
          ,per.email_address
          ,per.expense_check_send_to_address
          ,per.first_name
          ,per.known_as
          ,per.marital_status
          ,per.middle_names
          ,per.nationality
          ,per.national_identifier
          ,per.previous_last_name
          ,per.registered_disabled_flag
          ,per.sex
          ,per.title
          ,per.vendor_id
          ,per.work_telephone
          ,per.suffix
          ,per.attribute_category
          ,per.attribute1
          ,per.attribute2
          ,per.attribute3
          ,per.attribute4
          ,per.attribute5
          ,per.attribute6
          ,per.attribute7
          ,per.attribute8
          ,per.attribute9
          ,per.attribute10
          ,per.attribute11
          ,per.attribute12
          ,per.attribute13
          ,per.attribute14
          ,per.attribute15
          ,per.attribute16
          ,per.attribute17
          ,per.attribute18
          ,per.attribute19
          ,per.attribute20
          ,per.attribute21
          ,per.attribute22
          ,per.attribute23
          ,per.attribute24
          ,per.attribute25
          ,per.attribute26
          ,per.attribute27
          ,per.attribute28
          ,per.attribute29
          ,per.attribute30
          ,per.per_information_category
          ,per.per_information1
          ,per.per_information2
          ,per.per_information3
          ,per.per_information4
          ,per.per_information5
          ,per.per_information6
          ,per.per_information7
          ,per.per_information8
          ,per.per_information9
          ,per.per_information10
          ,per.per_information11
          ,per.per_information12
          ,per.per_information13
          ,per.per_information14
          ,per.per_information15
          ,per.per_information16
          ,per.per_information17
          ,per.per_information18
          ,per.per_information19
          ,per.per_information20
          ,per.per_information21
          ,per.per_information22
          ,per.per_information23
          ,per.per_information24
          ,per.per_information25
          ,per.per_information26
          ,per.per_information27
          ,per.per_information28
          ,per.per_information29
          ,per.per_information30
          ,per.date_of_death
          ,per.background_check_status
          ,per.background_date_check
          ,per.blood_type
          ,per.correspondence_language
          ,per.fast_path_employee
          ,per.fte_capacity
          ,per.hold_applicant_date_until
          ,per.honors
          ,per.internal_location
          ,per.last_medical_test_by
          ,per.last_medical_test_date
          ,per.mailstop
          ,per.office_number
          ,per.on_military_service
          ,per.pre_name_adjunct
          ,per.projected_start_date
          ,per.rehire_authorizor
          ,per.rehire_recommendation
          ,per.resume_exists
          ,per.resume_last_updated
          ,per.second_passport_exists
          ,per.student_status
          ,per.work_schedule
          ,per.rehire_reason
          ,per.benefit_group_id
          ,per.receipt_of_death_cert_date
          ,per.coord_ben_med_pln_no
          ,per.coord_ben_no_cvg_flag
          ,per.uses_tobacco_flag
          ,per.dpdnt_adoption_date
          ,per.dpdnt_vlntry_svce_flag
          ,per.original_date_of_hire
          ,per.town_of_birth
          ,per.region_of_birth
          ,per.country_of_birth
          ,per.global_person_id
          ,per.effective_start_date
          ,per.effective_end_date
          ,hc.comment_text
    from    hr_comments            hc
           ,per_all_people_f       per
    where   per.person_id          = p_person_id
    and     per.effective_end_date < l_constant_effective_date
    and     hc.comment_id (+)      = per.comment_id
    order by per.effective_end_date desc;
  -- IN parameters for BP API
  l_last_name           per_people_f.last_name%type;
  l_date_of_birth       per_people_f.date_of_birth%type;
  l_email_address       per_people_f.email_address%type;
  l_first_name          per_people_f.first_name%type;
  l_known_as            per_people_f.known_as%type;
  l_marital_status      per_people_f.marital_status%type;
  l_middle_names        per_people_f.middle_names%type;
  l_nationality         per_people_f.nationality%type;
  l_previous_last_name  per_people_f.previous_last_name%type;
  l_sex                 per_people_f.sex%type;
  l_title               per_people_f.title%type;
  l_work_telephone      per_people_f.work_telephone%type;
  l_suffix              per_people_f.suffix%type;
  l_person_type_id      per_people_f.person_type_id%type;
  l_applicant_number    per_people_f.applicant_number%type;
  l_comments            hr_comments.comment_text%type;
  l_date_employee_data_verified  per_people_f.date_employee_data_verified%type;
  l_expense_check_send_to_addres per_people_f.expense_check_send_to_address%type;
  l_national_identifier per_people_f.national_identifier%type;
  l_registered_disabled_flag per_people_f.registered_disabled_flag%type;
  l_vendor_id           per_people_f.vendor_id%type;
  l_attribute_category  per_people_f.attribute_category%type;
  l_attribute1          per_people_f.attribute1%type;
  l_attribute2          per_people_f.attribute2%type;
  l_attribute3          per_people_f.attribute3%type;
  l_attribute4          per_people_f.attribute4%type;
  l_attribute5          per_people_f.attribute5%type;
  l_attribute6          per_people_f.attribute6%type;
  l_attribute7          per_people_f.attribute7%type;
  l_attribute8          per_people_f.attribute8%type;
  l_attribute9          per_people_f.attribute9%type;
  l_attribute10         per_people_f.attribute10%type;
  l_attribute11         per_people_f.attribute11%type;
  l_attribute12         per_people_f.attribute12%type;
  l_attribute13         per_people_f.attribute13%type;
  l_attribute14         per_people_f.attribute14%type;
  l_attribute15         per_people_f.attribute15%type;
  l_attribute16         per_people_f.attribute16%type;
  l_attribute17         per_people_f.attribute17%type;
  l_attribute18         per_people_f.attribute18%type;
  l_attribute19         per_people_f.attribute19%type;
  l_attribute20         per_people_f.attribute20%type;
  l_attribute21         per_people_f.attribute21%type;
  l_attribute22         per_people_f.attribute22%type;
  l_attribute23         per_people_f.attribute23%type;
  l_attribute24         per_people_f.attribute24%type;
  l_attribute25         per_people_f.attribute25%type;
  l_attribute26         per_people_f.attribute26%type;
  l_attribute27         per_people_f.attribute27%type;
  l_attribute28         per_people_f.attribute28%type;
  l_attribute29         per_people_f.attribute29%type;
  l_attribute30         per_people_f.attribute30%type;
  l_per_information_category per_people_f.per_information_category%type;
  l_per_information1    per_people_f.per_information1%type;
  l_per_information2    per_people_f.per_information2%type;
  l_per_information3    per_people_f.per_information3%type;
  l_per_information4    per_people_f.per_information4%type;
  l_per_information5    per_people_f.per_information5%type;
  l_per_information6    per_people_f.per_information6%type;
  l_per_information7    per_people_f.per_information7%type;
  l_per_information8    per_people_f.per_information8%type;
  l_per_information9    per_people_f.per_information9%type;
  l_per_information10   per_people_f.per_information10%type;
  l_per_information11   per_people_f.per_information11%type;
  l_per_information12   per_people_f.per_information12%type;
  l_per_information13   per_people_f.per_information13%type;
  l_per_information14   per_people_f.per_information14%type;
  l_per_information15   per_people_f.per_information15%type;
  l_per_information16   per_people_f.per_information16%type;
  l_per_information17   per_people_f.per_information17%type;
  l_per_information18   per_people_f.per_information18%type;
  l_per_information19   per_people_f.per_information19%type;
  l_per_information20   per_people_f.per_information20%type;

  l_per_information21   per_people_f.per_information21%type;
  l_per_information22   per_people_f.per_information22%type;
  l_per_information23   per_people_f.per_information23%type;
  l_per_information24   per_people_f.per_information24%type;
  l_per_information25   per_people_f.per_information25%type;
  l_per_information26   per_people_f.per_information26%type;
  l_per_information27   per_people_f.per_information27%type;
  l_per_information28   per_people_f.per_information28%type;
  l_per_information29   per_people_f.per_information29%type;
  l_per_information30   per_people_f.per_information30%type;
  l_date_of_death                  per_people_f.date_of_death%type;
  l_background_check_status        per_people_f.background_check_status%type;
  l_background_date_check          per_people_f.background_date_check%type;
  l_blood_type                     per_people_f.blood_type%type;
  l_correspondence_language        per_people_f.correspondence_language%type;
  l_fast_path_employee             per_people_f.fast_path_employee%type;
  l_fte_capacity                   per_people_f.fte_capacity%type;
  l_hold_applicant_date_until      per_people_f.hold_applicant_date_until%type;
  l_honors                         per_people_f.honors%type;
  l_internal_location              per_people_f.internal_location%type;
  l_last_medical_test_by           per_people_f.last_medical_test_by%type;
  l_last_medical_test_date         per_people_f.last_medical_test_date%type;
  l_mailstop                       per_people_f.mailstop%type;
  l_office_number                  per_people_f.office_number%type;
  l_on_military_service            per_people_f.on_military_service%type;
  l_pre_name_adjunct               per_people_f.pre_name_adjunct%type;
  l_projected_start_date           per_people_f.projected_start_date%type;
  l_rehire_authorizor              per_people_f.rehire_authorizor%type;
  l_rehire_recommendation          per_people_f.rehire_recommendation%type;
  l_resume_exists                  per_people_f.resume_exists%type;
  l_resume_last_updated            per_people_f.resume_last_updated%type;
  l_second_passport_exists         per_people_f.second_passport_exists%type;
  l_student_status                 per_people_f.student_status%type;
  l_work_schedule                  per_people_f.work_schedule%type;
  l_rehire_reason                  per_people_f.rehire_reason%type;
  l_benefit_group_id               per_people_f.benefit_group_id%type;
  l_receipt_of_death_cert_date     per_people_f.receipt_of_death_cert_date%type;
  l_coord_ben_med_pln_no           per_people_f.coord_ben_med_pln_no%type;
  l_coord_ben_no_cvg_flag          per_people_f.coord_ben_no_cvg_flag%type;
  l_uses_tobacco_flag              per_people_f.uses_tobacco_flag%type;
  l_dpdnt_adoption_date            per_people_f.dpdnt_adoption_date%type;
  l_dpdnt_vlntry_svce_flag         per_people_f.dpdnt_vlntry_svce_flag%type;
  l_original_date_of_hire          per_people_f.original_date_of_hire%type;
  l_town_of_birth                  per_people_f.town_of_birth%type;
  l_region_of_birth                per_people_f.region_of_birth%type;
  l_country_of_birth               per_people_f.country_of_birth%type;
  l_global_person_id               per_people_f.global_person_id%type;
  -- IN/OUT parameters for BP API and API
  l_employee_number                per_people_f.employee_number%type;
  l_object_version_number          per_people_f.object_version_number%type;
  -- OUT parameters for BP API
  l_full_name                per_people_f.full_name%type;
  l_comment_id               per_people_f.comment_id%type;
  l_name_combination_warning boolean;
  l_assign_payroll_warning   boolean;
  l_orig_hire_warning        boolean;
  l_effective_start_date     per_people_f.effective_start_date%type;
  l_effective_end_date       per_people_f.effective_end_date%type;
  -- OUT parameters for API
  l_api_name_combination_warning boolean := false;
  l_api_assign_payroll_warning   boolean := false;
  l_api_orig_hire_warning        boolean := false;
  -- --------------------------------------------------------------------------
  -- |---------------------------< process_row >------------------------------|
  -- --------------------------------------------------------------------------
  -- {Start Of Comments}
  --
  -- Description:
  --   This private function is used to determine the correct attribute values
  --   to pass to the BP API.
  --
  --   1. Determine the parameter value to be passed to the BP API
  --   2. If at least one parameter value is changing then call the BP API
  --      else exit function
  --   3. Set any parameters which have been supplied by the resulting call
  --      to the BP API
  --
  -- Pre Conditions:
  --   A row must be active from the cursor csr_per1 or csr_per2
  --
  -- In Arguments:
  --   All the IN arguments hold the current selected cursor row values.
  --
  -- Post Success:
  --   Ths function will return either TRUE or FALSE.
  --   If TRUE is returned, the row has been processed succesfully and
  --   attributes could possibly still be processed.
  --   If FALSE is returned, the row has been processed succesfully
  --   and all the attributes have been updated as far as possible.
  --
  -- Post Failure:
  --   Exceptions are not handled, just raised.
  --
  -- Developer Implementation Notes:
  --   None
  --
  -- Access Status:
  --   Internal to owning procedure.
  --
  -- {End Of Comments}
  -- --------------------------------------------------------------------------
  function process_row
    (c_effective_start_date         in      date
    ,c_object_version_number        in      number
    ,c_person_type_id               in      number   default hr_api.g_number
    ,c_last_name                    in      varchar2 default hr_api.g_varchar2
    ,c_applicant_number             in      varchar2 default hr_api.g_varchar2
    ,c_comments                     in      varchar2 default hr_api.g_varchar2
    ,c_date_employee_data_verified  in      date     default hr_api.g_date
    ,c_date_of_birth                in      date     default hr_api.g_date
    ,c_email_address                in      varchar2 default hr_api.g_varchar2
    ,c_employee_number              in      varchar2
    ,c_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
    ,c_first_name                   in      varchar2 default hr_api.g_varchar2
    ,c_known_as                     in      varchar2 default hr_api.g_varchar2
    ,c_marital_status               in      varchar2 default hr_api.g_varchar2
    ,c_middle_names                 in      varchar2 default hr_api.g_varchar2
    ,c_nationality                  in      varchar2 default hr_api.g_varchar2
    ,c_national_identifier          in      varchar2 default hr_api.g_varchar2
    ,c_previous_last_name           in      varchar2 default hr_api.g_varchar2
    ,c_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
    ,c_sex                          in      varchar2 default hr_api.g_varchar2
    ,c_title                        in      varchar2 default hr_api.g_varchar2
    ,c_vendor_id                    in      number   default hr_api.g_number
    ,c_work_telephone               in      varchar2 default hr_api.g_varchar2
    ,c_suffix                       in      varchar2 default hr_api.g_varchar2
    ,c_attribute_category           in      varchar2 default hr_api.g_varchar2
    ,c_attribute1                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute2                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute3                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute4                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute5                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute6                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute7                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute8                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute9                   in      varchar2 default hr_api.g_varchar2
    ,c_attribute10                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute11                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute12                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute13                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute14                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute15                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute16                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute17                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute18                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute19                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute20                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute21                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute22                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute23                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute24                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute25                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute26                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute27                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute28                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute29                  in      varchar2 default hr_api.g_varchar2
    ,c_attribute30                  in      varchar2 default hr_api.g_varchar2
    ,c_per_information_category     in      varchar2 default hr_api.g_varchar2
    ,c_per_information1             in      varchar2 default hr_api.g_varchar2
    ,c_per_information2             in      varchar2 default hr_api.g_varchar2
    ,c_per_information3             in      varchar2 default hr_api.g_varchar2
    ,c_per_information4             in      varchar2 default hr_api.g_varchar2
    ,c_per_information5             in      varchar2 default hr_api.g_varchar2
    ,c_per_information6             in      varchar2 default hr_api.g_varchar2
    ,c_per_information7             in      varchar2 default hr_api.g_varchar2
    ,c_per_information8             in      varchar2 default hr_api.g_varchar2
    ,c_per_information9             in      varchar2 default hr_api.g_varchar2
    ,c_per_information10            in      varchar2 default hr_api.g_varchar2
    ,c_per_information11            in      varchar2 default hr_api.g_varchar2
    ,c_per_information12            in      varchar2 default hr_api.g_varchar2
    ,c_per_information13            in      varchar2 default hr_api.g_varchar2
    ,c_per_information14            in      varchar2 default hr_api.g_varchar2
    ,c_per_information15            in      varchar2 default hr_api.g_varchar2
    ,c_per_information16            in      varchar2 default hr_api.g_varchar2
    ,c_per_information17            in      varchar2 default hr_api.g_varchar2
    ,c_per_information18            in      varchar2 default hr_api.g_varchar2
    ,c_per_information19            in      varchar2 default hr_api.g_varchar2
    ,c_per_information20            in      varchar2 default hr_api.g_varchar2
    ,c_per_information21            in      varchar2 default hr_api.g_varchar2
    ,c_per_information22            in      varchar2 default hr_api.g_varchar2
    ,c_per_information23            in      varchar2 default hr_api.g_varchar2
    ,c_per_information24            in      varchar2 default hr_api.g_varchar2
    ,c_per_information25            in      varchar2 default hr_api.g_varchar2
    ,c_per_information26            in      varchar2 default hr_api.g_varchar2
    ,c_per_information27            in      varchar2 default hr_api.g_varchar2
    ,c_per_information28            in      varchar2 default hr_api.g_varchar2
    ,c_per_information29            in      varchar2 default hr_api.g_varchar2
    ,c_per_information30            in      varchar2 default hr_api.g_varchar2
    ,c_date_of_death                in      date     default hr_api.g_date
    ,c_background_check_status      in      varchar2 default hr_api.g_varchar2
    ,c_background_date_check        in      date     default hr_api.g_date
    ,c_blood_type                   in      varchar2 default hr_api.g_varchar2
    ,c_correspondence_language      in      varchar2 default hr_api.g_varchar2
    ,c_fast_path_employee           in      varchar2 default hr_api.g_varchar2
    ,c_fte_capacity                 in      number   default hr_api.g_number
    ,c_hold_applicant_date_until    in      date     default hr_api.g_date
    ,c_honors                       in      varchar2 default hr_api.g_varchar2
    ,c_internal_location            in      varchar2 default hr_api.g_varchar2
    ,c_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
    ,c_last_medical_test_date       in      date     default hr_api.g_date
    ,c_mailstop                     in      varchar2 default hr_api.g_varchar2
    ,c_office_number                in      varchar2 default hr_api.g_varchar2
    ,c_on_military_service          in      varchar2 default hr_api.g_varchar2
    ,c_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
    ,c_projected_start_date         in      date     default hr_api.g_date
    ,c_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
    ,c_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
    ,c_resume_exists                in      varchar2 default hr_api.g_varchar2
    ,c_resume_last_updated          in      date     default hr_api.g_date
    ,c_second_passport_exists       in      varchar2 default hr_api.g_varchar2
    ,c_student_status               in      varchar2 default hr_api.g_varchar2
    ,c_work_schedule                in      varchar2 default hr_api.g_varchar2
    ,c_rehire_reason                in      varchar2 default hr_api.g_varchar2
    ,c_benefit_group_id             in      number   default hr_api.g_number
    ,c_receipt_of_death_cert_date   in      date     default hr_api.g_date
    ,c_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
    ,c_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
    ,c_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
    ,c_dpdnt_adoption_date          in      date     default hr_api.g_date
    ,c_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
    ,c_original_date_of_hire        in      date     default hr_api.g_date
    ,c_town_of_birth                in      varchar2 default hr_api.g_varchar2
    ,c_region_of_birth              in      varchar2 default hr_api.g_varchar2
    ,c_country_of_birth             in      varchar2 default hr_api.g_varchar2
    ,c_global_person_id             in      varchar2 default hr_api.g_varchar2 )
  return boolean is
    l_proc          varchar2(72)   := g_package||'process_row';
  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
    -- get the parameter values to pass to the BP API
    l_title              := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_TITLE'
                              ,p_new_value       => p_title
                              ,p_current_value   => c_title);
    l_marital_status     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_MARITAL_STATUS'
                              ,p_new_value       => p_marital_status
                              ,p_current_value   => c_marital_status);
    l_first_name         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_FIRST_NAME'
                              ,p_new_value       => p_first_name
                              ,p_current_value   => c_first_name);
    l_middle_names       := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_MIDDLE_NAMES'
                              ,p_new_value       => p_middle_names
                              ,p_current_value   => c_middle_names);
    l_last_name          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_LAST_NAME'
                              ,p_new_value       => p_last_name
                              ,p_current_value   => c_last_name);
    l_known_as           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_KNOWN_AS'
                              ,p_new_value       => p_known_as
                              ,p_current_value   => c_known_as);
    l_previous_last_name := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PREVIOUS_LAST_NAME'
                              ,p_new_value       => p_previous_last_name
                              ,p_current_value   => c_previous_last_name);
    l_date_of_birth      := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_DATE_OF_BIRTH'
                              ,p_new_value       => p_date_of_birth
                              ,p_current_value   => c_date_of_birth);
    l_email_address      := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_EMAIL_ADDRESS'
                              ,p_new_value       => p_email_address
                              ,p_current_value   => c_email_address);
    l_nationality        := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_NATIONALITY'
                              ,p_new_value       => p_nationality
                              ,p_current_value   => c_nationality);
    l_sex                := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_SEX'
                              ,p_new_value       => p_sex
                              ,p_current_value   => c_sex);
    l_work_telephone     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_WORK_TELEPHONE'
                              ,p_new_value       => p_work_telephone
                              ,p_current_value   => c_work_telephone);
    l_suffix             := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_SUFFIX'
                              ,p_new_value       => p_suffix
                              ,p_current_value   => c_suffix);
    l_person_type_id     := hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PERSON_TYPE_ID'
                              ,p_new_value       => p_person_type_id
                              ,p_current_value   => c_person_type_id);
    l_applicant_number   := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_APPLICANT_NUMBER'
                              ,p_new_value       => p_applicant_number
                              ,p_current_value   => c_applicant_number);
    l_comments           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_COMMENTS'
                              ,p_new_value       => p_comments
                              ,p_current_value   => c_comments);
    l_date_employee_data_verified
                         := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_DATE_EMPLOYEE_DATA_VERIFIED'
                              ,p_new_value       => p_date_employee_data_verified
                              ,p_current_value   => c_date_employee_data_verified);
    l_employee_number    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_EMPLOYEE_NUMBER'
                              ,p_new_value       => p_employee_number
                              ,p_current_value   => c_employee_number);
    l_expense_check_send_to_addres :=
                            hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_EXPENSE_CHECK_SEND_TO_ADDRES'
                              ,p_new_value       => p_expense_check_send_to_addres
                              ,p_current_value   => c_expense_check_send_to_addres);
    l_national_identifier := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_NATIONAL_IDENTIFIER'
                              ,p_new_value       => p_national_identifier
                              ,p_current_value   => c_national_identifier);
    l_registered_disabled_flag := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_REGISTERED_DISABLED_FLAG'
                              ,p_new_value       => p_registered_disabled_flag
                              ,p_current_value   => c_registered_disabled_flag);
    l_vendor_id           := hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_VENDOR_ID'
                              ,p_new_value       => p_vendor_id
                              ,p_current_value   => c_vendor_id);
    l_attribute_category  := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE_CATEGORY'
                              ,p_new_value       => p_attribute_category
                              ,p_current_value   => c_attribute_category);
    l_attribute1          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE1'
                              ,p_new_value       => p_attribute1
                              ,p_current_value   => c_attribute1);
    l_attribute2          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE2'
                              ,p_new_value       => p_attribute2
                              ,p_current_value   => c_attribute2);
    l_attribute3          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE3'
                              ,p_new_value       => p_attribute3
                              ,p_current_value   => c_attribute3);
    l_attribute4          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE4'
                              ,p_new_value       => p_attribute4
                              ,p_current_value   => c_attribute4);
    l_attribute5          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE5'
                              ,p_new_value       => p_attribute5
                              ,p_current_value   => c_attribute5);
    l_attribute6          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE6'
                              ,p_new_value       => p_attribute6
                              ,p_current_value   => c_attribute6);
    l_attribute7          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE7'
                              ,p_new_value       => p_attribute7
                              ,p_current_value   => c_attribute7);
    l_attribute8          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE8'
                              ,p_new_value       => p_attribute8
                              ,p_current_value   => c_attribute8);
    l_attribute9          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE9'
                              ,p_new_value       => p_attribute9
                              ,p_current_value   => c_attribute9);
    l_attribute10         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE10'
                              ,p_new_value       => p_attribute10
                              ,p_current_value   => c_attribute10);
    l_attribute11         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE11'
                              ,p_new_value       => p_attribute11
                              ,p_current_value   => c_attribute11);
    l_attribute12         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE12'
                              ,p_new_value       => p_attribute12
                              ,p_current_value   => c_attribute12);
    l_attribute13         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE13'
                              ,p_new_value       => p_attribute13
                              ,p_current_value   => c_attribute13);
    l_attribute14         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE14'
                              ,p_new_value       => p_attribute14
                              ,p_current_value   => c_attribute14);
    l_attribute15         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE15'
                              ,p_new_value       => p_attribute15
                              ,p_current_value   => c_attribute15);
    l_attribute16         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE16'
                              ,p_new_value       => p_attribute16
                              ,p_current_value   => c_attribute16);
    l_attribute17         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE17'
                              ,p_new_value       => p_attribute17
                              ,p_current_value   => c_attribute17);
    l_attribute18         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE18'
                              ,p_new_value       => p_attribute18
                              ,p_current_value   => c_attribute18);
    l_attribute19         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE19'
                              ,p_new_value       => p_attribute19
                              ,p_current_value   => c_attribute19);
    l_attribute20         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE20'
                              ,p_new_value       => p_attribute20
                              ,p_current_value   => c_attribute20);
    l_attribute21         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE21'
                              ,p_new_value       => p_attribute21
                              ,p_current_value   => c_attribute21);
    l_attribute22         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE22'
                              ,p_new_value       => p_attribute22
                              ,p_current_value   => c_attribute22);
    l_attribute23         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE23'
                              ,p_new_value       => p_attribute23
                              ,p_current_value   => c_attribute23);
    l_attribute24         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE24'
                              ,p_new_value       => p_attribute24
                              ,p_current_value   => c_attribute24);
    l_attribute25         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE5'
                              ,p_new_value       => p_attribute25
                              ,p_current_value   => c_attribute25);
    l_attribute26         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE26'
                              ,p_new_value       => p_attribute26
                              ,p_current_value   => c_attribute26);
    l_attribute27         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE27'
                              ,p_new_value       => p_attribute27
                              ,p_current_value   => c_attribute27);
    l_attribute28         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE28'
                              ,p_new_value       => p_attribute28
                              ,p_current_value   => c_attribute28);
    l_attribute29         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE29'
                              ,p_new_value       => p_attribute29
                              ,p_current_value   => c_attribute29);
    l_attribute30         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ATTRIBUTE30'
                              ,p_new_value       => p_attribute30
                              ,p_current_value   => c_attribute30);
    l_per_information_category  := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION_CATEGORY'
                              ,p_new_value       => p_per_information_category
                              ,p_current_value   => c_per_information_category);
    l_per_information1     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION1'
                              ,p_new_value       => p_per_information1
                              ,p_current_value   => c_per_information1);
    l_per_information2     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION2'
                              ,p_new_value       => p_per_information2
                              ,p_current_value   => c_per_information2);
    l_per_information3     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION3'
                              ,p_new_value       => p_per_information3
                              ,p_current_value   => c_per_information3);
    l_per_information4     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION4'
                              ,p_new_value       => p_per_information4
                              ,p_current_value   => c_per_information4);
    l_per_information5     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION5'
                              ,p_new_value       => p_per_information5
                              ,p_current_value   => c_per_information5);
    l_per_information6     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION6'
                              ,p_new_value       => p_per_information6
                              ,p_current_value   => c_per_information6);
    l_per_information7     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION7'
                              ,p_new_value       => p_per_information7
                              ,p_current_value   => c_per_information7);
    l_per_information8     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION8'
                              ,p_new_value       => p_per_information8
                              ,p_current_value   => c_per_information8);
    l_per_information9     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION9'
                              ,p_new_value       => p_per_information9
                              ,p_current_value   => c_per_information9);
    l_per_information10    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION10'
                              ,p_new_value       => p_per_information10
                              ,p_current_value   => c_per_information10);
    l_per_information11    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION11'
                              ,p_new_value       => p_per_information11
                              ,p_current_value   => c_per_information11);
    l_per_information12    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION12'
                              ,p_new_value       => p_per_information12
                              ,p_current_value   => c_per_information12);
    l_per_information13    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION13'
                              ,p_new_value       => p_per_information13
                              ,p_current_value   => c_per_information13);
    l_per_information14    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION14'
                              ,p_new_value       => p_per_information14
                              ,p_current_value   => c_per_information14);
    l_per_information15    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION15'
                              ,p_new_value       => p_per_information15
                              ,p_current_value   => c_per_information15);
    l_per_information16    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION16'
                              ,p_new_value       => p_per_information16
                              ,p_current_value   => c_per_information16);
    l_per_information17    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION17'
                              ,p_new_value       => p_per_information17
                              ,p_current_value   => c_per_information17);
    l_per_information18    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION18'
                              ,p_new_value       => p_per_information18
                              ,p_current_value   => c_per_information18);
    l_per_information19    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION19'
                              ,p_new_value       => p_per_information19
                              ,p_current_value   => c_per_information19);
    l_per_information20    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION20'
                              ,p_new_value       => p_per_information20
                              ,p_current_value   => c_per_information20);
    l_per_information21    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION21'
                              ,p_new_value       => p_per_information21
                              ,p_current_value   => c_per_information21);
    l_per_information22    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION22'
                              ,p_new_value       => p_per_information22
                              ,p_current_value   => c_per_information22);
    l_per_information23    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION23'
                              ,p_new_value       => p_per_information23
                              ,p_current_value   => c_per_information23);
    l_per_information24    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION24'
                              ,p_new_value       => p_per_information24
                              ,p_current_value   => c_per_information24);
    l_per_information25    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION25'
                              ,p_new_value       => p_per_information25
                              ,p_current_value   => c_per_information25);
    l_per_information26    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION26'
                              ,p_new_value       => p_per_information26
                              ,p_current_value   => c_per_information26);
    l_per_information27    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION27'
                              ,p_new_value       => p_per_information27
                              ,p_current_value   => c_per_information27);
    l_per_information28    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION28'
                              ,p_new_value       => p_per_information28
                              ,p_current_value   => c_per_information28);
    l_per_information29    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION29'
                              ,p_new_value       => p_per_information29
                              ,p_current_value   => c_per_information29);
    l_per_information30    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PER_INFORMATION30'
                              ,p_new_value       => p_per_information30
                              ,p_current_value   => c_per_information30);
    l_date_of_death        := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_DATE_OF_DEATH'
                              ,p_new_value       => p_date_of_death
                              ,p_current_value   => c_date_of_death);
  l_background_check_status := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_BACKGROUND_CHECK_STATUS'
                              ,p_new_value       => p_background_check_status
                              ,p_current_value   => c_background_check_status);
  l_background_date_check   := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_BACKGROUND_DATE_CHECK'
                              ,p_new_value       => p_background_date_check
                              ,p_current_value   => c_background_date_check);
  l_blood_type              := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_BLOOD_TYPE'
                              ,p_new_value       => p_blood_type
                              ,p_current_value   => c_blood_type);
  l_correspondence_language := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_CORRESPONDENCE_LANGUAGE'
                              ,p_new_value       => p_correspondence_language
                              ,p_current_value   => c_correspondence_language);
  l_fast_path_employee      := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_FAST_PATH_EMPLOYEE'
                              ,p_new_value       => p_fast_path_employee
                              ,p_current_value   => c_fast_path_employee);
  l_fte_capacity            := hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_FTE_CAPACITY'
                              ,p_new_value       => p_fte_capacity
                              ,p_current_value   => c_fte_capacity);
  l_hold_applicant_date_until
                            := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_HOLD_APPLICANT_DATE_UNTIL'
                              ,p_new_value       => p_hold_applicant_date_until
                              ,p_current_value   => c_hold_applicant_date_until);
  l_honors                  := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_HONORS'
                              ,p_new_value       => p_honors
                              ,p_current_value   => c_honors);
  l_internal_location       := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_INTERNAL_LOCATION'
                              ,p_new_value       => p_internal_location
                              ,p_current_value   => c_internal_location);
  l_last_medical_test_by    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_LAST_MEDICAL_TEST_BY'
                              ,p_new_value       => p_last_medical_test_by
                              ,p_current_value   => c_last_medical_test_by);
  l_last_medical_test_date := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_LAST_MEDICAL_TEST_DATE'
                              ,p_new_value       => p_last_medical_test_date
                              ,p_current_value   => c_last_medical_test_date);
  l_mailstop                := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_MAILSTOP'
                              ,p_new_value       => p_mailstop
                              ,p_current_value   => c_mailstop);
  l_office_number           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_OFFICE_NUMBER'
                              ,p_new_value       => p_office_number
                              ,p_current_value   => c_office_number);
  l_on_military_service     := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ON_MILITARY_SERVICE'
                              ,p_new_value       => p_on_military_service
                              ,p_current_value   => c_on_military_service);
  l_pre_name_adjunct        := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PRE_NAME_ADJUNCT'
                              ,p_new_value       => p_pre_name_adjunct
                              ,p_current_value   => c_pre_name_adjunct);
  l_projected_start_date    := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_PROJECTED_START_DATE'
                              ,p_new_value       => p_projected_start_date
                              ,p_current_value   => c_projected_start_date);
  l_rehire_authorizor       := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_REHIRE_AUTHORIZOR'
                              ,p_new_value       => p_rehire_authorizor
                              ,p_current_value   => c_rehire_authorizor);
  l_rehire_recommendation   := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_REHIRE_RECOMMENDATION'
                              ,p_new_value       => p_rehire_recommendation
                              ,p_current_value   => c_rehire_recommendation);
  l_resume_exists           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_RESUME_EXISTS'
                              ,p_new_value       => p_resume_exists
                              ,p_current_value   => c_resume_exists);
  l_resume_last_updated     := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_RESUME_LAST_UPDATED'
                              ,p_new_value       => p_resume_last_updated
                              ,p_current_value   => c_resume_last_updated);
  l_second_passport_exists  := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_SECOND_PASSPORT_EXISTS'
                              ,p_new_value       => p_second_passport_exists
                              ,p_current_value   => c_second_passport_exists);
  l_student_status          := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_STUDENT_STATUS'
                              ,p_new_value       => p_student_status
                              ,p_current_value   => c_student_status);
  l_work_schedule           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_WORK_SCHEDULE'
                              ,p_new_value       => p_work_schedule
                              ,p_current_value   => c_work_schedule);
  l_rehire_reason           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_REHIRE_REASON'
                              ,p_new_value       => p_rehire_reason
                              ,p_current_value   => c_rehire_reason);
  l_benefit_group_id        := hr_dt_attribute_support.get_parameter_number
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_BENEFIT_GROUP_ID'
                              ,p_new_value       => p_benefit_group_id
                              ,p_current_value   => c_benefit_group_id);
  l_receipt_of_death_cert_date    := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_RECEIPT_OF_DEATH_CERT_DATE'
                              ,p_new_value       => p_receipt_of_death_cert_date
                              ,p_current_value   => c_receipt_of_death_cert_date);
  l_coord_ben_med_pln_no    := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_COORD_BEN_MED_PLN_NO'
                              ,p_new_value       => p_coord_ben_med_pln_no
                              ,p_current_value   => c_coord_ben_med_pln_no);
  l_coord_ben_no_cvg_flag   := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_COORD_BEN_NO_CVG_FLAG'
                              ,p_new_value       => p_coord_ben_no_cvg_flag
                              ,p_current_value   => c_coord_ben_no_cvg_flag);
  l_uses_tobacco_flag       := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_USES_TOBACCO_FLAG'
                              ,p_new_value       => p_uses_tobacco_flag
                              ,p_current_value   => c_uses_tobacco_flag);
  l_dpdnt_adoption_date     := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_DPDNT_ADOPTION_DATE'
                              ,p_new_value       => p_dpdnt_adoption_date
                              ,p_current_value   => c_dpdnt_adoption_date);
  l_dpdnt_vlntry_svce_flag  := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_DPDNT_VLNTRY_SVCE_FLAG'
                              ,p_new_value       => p_dpdnt_vlntry_svce_flag
                              ,p_current_value   => c_dpdnt_vlntry_svce_flag);
  l_original_date_of_hire   := hr_dt_attribute_support.get_parameter_date
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_ORIGINAL_DATE_OF_HIRE'
                              ,p_new_value       => p_original_date_of_hire
                              ,p_current_value   => c_original_date_of_hire);
  l_town_of_birth           := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_TOWN_OF_BIRTH'
                              ,p_new_value       => p_town_of_birth
                              ,p_current_value   => c_town_of_birth);
  l_region_of_birth         := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_REGION_OF_BIRTH'
                              ,p_new_value       => p_region_of_birth
                              ,p_current_value   => c_region_of_birth);
  l_country_of_birth        := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_COUNTRY_OF_BIRTH'
                              ,p_new_value       => p_country_of_birth
                              ,p_current_value   => c_country_of_birth);
  l_global_person_id        := hr_dt_attribute_support.get_parameter_char
                              (p_effective_date_row => l_effective_date_row
                              ,p_parameter_name  => 'P_GLOBAL_PERSON_ID'
                              ,p_new_value       => p_global_person_id
                              ,p_current_value   => c_global_person_id);
    -- call the business process API if at least one attribute can be changed
    if hr_dt_attribute_support.is_current_row_changing then
      -- set the object version number and effective date
      if l_effective_date_row then
        -- as we are on the first row, the ovn and effective date should be
        -- set to the parameter specified by the caller
        l_object_version_number := p_object_version_number;
        l_effective_date        := l_constant_effective_date;
      else
        -- as we are not on the first row, set the ovn and effective date
        -- to the ovn and effective date for the row
        l_object_version_number := c_object_version_number;
        l_effective_date        := c_effective_start_date;
      end if;
      -- call BP API
      hr_person_api.update_person
        (p_effective_date           => l_effective_date
        ,p_datetrack_update_mode    => l_datetrack_update_mode
        ,p_person_id                => p_person_id
        ,p_object_version_number    => l_object_version_number
        ,p_person_type_id           => l_person_type_id
        ,p_applicant_number         => l_applicant_number
        ,p_comments                 => l_comments
        ,p_date_employee_data_verified => l_date_employee_data_verified
        ,p_expense_check_send_to_addres => l_expense_check_send_to_addres
        ,p_national_identifier      => l_national_identifier
        ,p_registered_disabled_flag => l_registered_disabled_flag
        ,p_vendor_id                => l_vendor_id
        ,p_employee_number          => l_employee_number
        ,p_title                    => l_title
        ,p_marital_status           => l_marital_status
        ,p_first_name               => l_first_name
        ,p_middle_names             => l_middle_names
        ,p_last_name                => l_last_name
        ,p_known_as                 => l_known_as
        ,p_previous_last_name       => l_previous_last_name
        ,p_date_of_birth            => l_date_of_birth
        ,p_email_address            => l_email_address
        ,p_nationality              => l_nationality
        ,p_sex                      => l_sex
        ,p_work_telephone           => l_work_telephone
        ,p_suffix                   => l_suffix
        ,p_attribute_category       => l_attribute_category
        ,p_attribute1               => l_attribute1
        ,p_attribute2               => l_attribute2
        ,p_attribute3               => l_attribute3
        ,p_attribute4               => l_attribute4
        ,p_attribute5               => l_attribute5
        ,p_attribute6               => l_attribute6
        ,p_attribute7               => l_attribute7
        ,p_attribute8               => l_attribute8
        ,p_attribute9               => l_attribute9
        ,p_attribute10              => l_attribute10
        ,p_attribute11              => l_attribute11
        ,p_attribute12              => l_attribute12
        ,p_attribute13              => l_attribute13
        ,p_attribute14              => l_attribute14
        ,p_attribute15              => l_attribute15
        ,p_attribute16              => l_attribute16
        ,p_attribute17              => l_attribute17
        ,p_attribute18              => l_attribute18
        ,p_attribute19              => l_attribute19
        ,p_attribute20              => l_attribute20
        ,p_attribute21              => l_attribute21
        ,p_attribute22              => l_attribute22
        ,p_attribute23              => l_attribute23
        ,p_attribute24              => l_attribute24
        ,p_attribute25              => l_attribute25
        ,p_attribute26              => l_attribute26
        ,p_attribute27              => l_attribute27
        ,p_attribute28              => l_attribute28
        ,p_attribute29              => l_attribute29
        ,p_attribute30              => l_attribute30
        ,p_per_information_category => l_per_information_category
        ,p_per_information1         => l_per_information1
        ,p_per_information2         => l_per_information2
        ,p_per_information3         => l_per_information3
        ,p_per_information4         => l_per_information4
        ,p_per_information5         => l_per_information5
        ,p_per_information6         => l_per_information6
        ,p_per_information7         => l_per_information7
        ,p_per_information8         => l_per_information8
        ,p_per_information9         => l_per_information9
        ,p_per_information10        => l_per_information10
        ,p_per_information11        => l_per_information11
        ,p_per_information12        => l_per_information12
        ,p_per_information13        => l_per_information13
        ,p_per_information14        => l_per_information14
        ,p_per_information15        => l_per_information15
        ,p_per_information16        => l_per_information16
        ,p_per_information17        => l_per_information17
        ,p_per_information18        => l_per_information18
        ,p_per_information19        => l_per_information19
        ,p_per_information20        => l_per_information20
        ,p_per_information21        => l_per_information21
        ,p_per_information22        => l_per_information22
        ,p_per_information23        => l_per_information23
        ,p_per_information24        => l_per_information24
        ,p_per_information25        => l_per_information25
        ,p_per_information26        => l_per_information26
        ,p_per_information27        => l_per_information27
        ,p_per_information28        => l_per_information28
        ,p_per_information29        => l_per_information29
        ,p_per_information30        => l_per_information30
        ,p_date_of_death            => l_date_of_death
        ,p_background_check_status  => l_background_check_status
        ,p_background_date_check    => l_background_date_check
        ,p_blood_type               => l_blood_type
        ,p_correspondence_language  => l_correspondence_language
        ,p_fast_path_employee       => l_fast_path_employee
        ,p_fte_capacity             => l_fte_capacity
        ,p_hold_applicant_date_until => l_hold_applicant_date_until
        ,p_honors                   => l_honors
        ,p_internal_location        => l_internal_location
        ,p_last_medical_test_by     => l_last_medical_test_by
        ,p_last_medical_test_date   => l_last_medical_test_date
        ,p_mailstop                 => l_mailstop
        ,p_office_number            => l_office_number
        ,p_on_military_service      => l_on_military_service
        ,p_pre_name_adjunct         => l_pre_name_adjunct
        ,p_projected_start_date     => l_projected_start_date
        ,p_rehire_authorizor        => l_rehire_authorizor
        ,p_rehire_recommendation    => l_rehire_recommendation
        ,p_resume_exists            => l_resume_exists
        ,p_resume_last_updated      => l_resume_last_updated
        ,p_second_passport_exists   => l_second_passport_exists
        ,p_student_status           => l_student_status
        ,p_work_schedule            => l_work_schedule
        ,p_rehire_reason            => l_rehire_reason
        ,p_benefit_group_id         => l_benefit_group_id
        ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
        ,p_coord_ben_med_pln_no     => l_coord_ben_med_pln_no
        ,p_coord_ben_no_cvg_flag    => l_coord_ben_no_cvg_flag
        ,p_uses_tobacco_flag        => l_uses_tobacco_flag
        ,p_dpdnt_adoption_date      => l_dpdnt_adoption_date
        ,p_dpdnt_vlntry_svce_flag   => l_dpdnt_vlntry_svce_flag
        ,p_original_date_of_hire    => l_original_date_of_hire
        ,p_town_of_birth            => l_town_of_birth
        ,p_region_of_birth          => l_region_of_birth
        ,p_country_of_birth         => l_country_of_birth
        ,p_global_person_id         => l_global_person_id
        ,p_effective_start_date     => l_effective_start_date
        ,p_effective_end_date       => l_effective_end_date
        ,p_full_name                => l_full_name
        ,p_comment_id               => l_comment_id
        ,p_name_combination_warning => l_name_combination_warning
        ,p_assign_payroll_warning   => l_assign_payroll_warning
        ,p_orig_hire_warning        => l_orig_hire_warning);
      --
      if l_effective_date_row then
        -- reset the first row flag
        l_effective_date_row := false;
        -- set all future row operations to a CORRECTION
        l_datetrack_update_mode := hr_api.g_correction;
        -- set the API out parameters for the first transaction
        p_object_version_number := l_object_version_number;
        p_full_name             := l_full_name;
        p_effective_start_date  := l_effective_start_date;
        p_effective_end_date    := l_effective_end_date;
        p_comment_id            := l_comment_id;
        p_employee_number       := l_employee_number;
      end if;
      -- determine if the warnings have been set at all
      if l_name_combination_warning and not l_api_name_combination_warning then
        l_api_name_combination_warning := l_name_combination_warning;
      end if;
      if l_assign_payroll_warning and not l_api_assign_payroll_warning then
        l_api_assign_payroll_warning := l_assign_payroll_warning;
      end if;
      if l_orig_hire_warning and not l_api_orig_hire_warning then
        l_api_orig_hire_warning := l_orig_hire_warning;
      end if;
      hr_utility.set_location(' Leaving:'|| l_proc, 10);
      -- we need to process the next row so return true
      return(true);
    else
      hr_utility.set_location(' Leaving:'|| l_proc, 15);
      -- processing has finished return false
      return(false);
    end if;
  end process_row;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- issue a savepoint if operating in validation only mode.
  --
  if p_validate then
    savepoint update_person;
  end if;
  -- lock the current row for the following two reasons:
  -- a) ensure that the current row exists for the person as of the
  --    specified effective date. we only lock the current row so the
  --    CORRECTION datetrack mode is used
  -- b) to populate the l_validation_start_date which is used
  --    in determining the correct datetrack mode on an update operation
  per_per_shd.lck
    (p_effective_date        => l_constant_effective_date
    ,p_datetrack_mode        => hr_api.g_correction
    ,p_person_id             => p_person_id
    ,p_object_version_number => p_object_version_number
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date);
  -- determine the datetrack mode to use
  if p_attribute_update_mode = 'ATTRIBUTE_UPDATE' then
    -- ------------------------------------------------------------------------
    -- step 1: as we are performing an ATTRIBUTE_UPDATE we must determine
    --         the initial datetrack mode to use (UPDATE, CORRECTION or
    --         UPDATE_CHANGE_INSERT)
    --
    --    1.1 - call the person datetrack find_dt_upd_modes to determine
    --          all possible allowed datetrack update modes
    --    1.2 - determine the actual datetrack mode to use
    --          the logic is as follows;
    --          if update allowed then select UPDATE as mode
    --          if change insert allowed then select UPDATE_CHANGE_INSERT as
    --          mode
    --          otherwise, select CORRECTION as the mode
    -- ------------------------------------------------------------------------
    -- step 1.1
    per_per_shd.find_dt_upd_modes
      (p_effective_date       => l_constant_effective_date
      ,p_base_key_value       => p_person_id
      ,p_correction           => l_correction
      ,p_update               => l_update
      ,p_update_override      => l_update_override
      ,p_update_change_insert => l_update_change_insert);
    -- step 1.2
    if l_update then
      -- we can do an update
      l_datetrack_update_mode := hr_api.g_update;
    elsif l_update_change_insert then
      -- we can do an update change insert
      l_datetrack_update_mode := hr_api.g_update_change_insert;
    elsif (l_validation_start_date = l_constant_effective_date) and
           l_correction then
      -- we can only perform a correction
      l_datetrack_update_mode := hr_api.g_correction;
    else
      -- we cannot perform an update due to a restriction within the APIs
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP','10');
      hr_utility.raise_error;
    end if;
    -- set lock start date to the effective date
    l_lck_start_date := l_constant_effective_date;
  elsif p_attribute_update_mode = 'ATTRIBUTE_CORRECTION' then
    -- set lock start date to start of time and the datetrack mode
    -- to CORRECTION
    l_lck_start_date := hr_api.g_sot;
    l_datetrack_update_mode := hr_api.g_correction;
  else
    -- the datetrack mode is not an ATTRIBUTE_UPDATE or ATTRIBUTE_CORRECTION
    -- so raise DT invalid mode error
    hr_utility.set_message(801, 'HR_7203_DT_UPD_MODE_INVALID');
    hr_utility.raise_error;
  end if;
  -- lock all person rows to ensure integrity. note: this will never fail.
  -- if the person doesn't exist (i.e. the person_id is invalid) then the
  -- business process will error with the correct error
  open csr_per_lck(l_lck_start_date);
  close csr_per_lck;
  -- ------------------------------------------------------------------------
  -- process the current and future row(s)
  -- ------------------------------------------------------------------------
  for csr_cur_fut in csr_per1 loop
    if not process_row
      (c_effective_start_date         => csr_cur_fut.effective_start_date
      ,c_object_version_number        => csr_cur_fut.object_version_number
      ,c_person_type_id               => csr_cur_fut.person_type_id
      ,c_last_name                    => csr_cur_fut.last_name
      ,c_applicant_number             => csr_cur_fut.applicant_number
      ,c_comments                     => csr_cur_fut.comment_text
      ,c_date_employee_data_verified  => csr_cur_fut.date_employee_data_verified
      ,c_date_of_birth                => csr_cur_fut.date_of_birth
      ,c_email_address                => csr_cur_fut.email_address
      ,c_employee_number              => csr_cur_fut.employee_number
      ,c_expense_check_send_to_addres => csr_cur_fut.expense_check_send_to_address
      ,c_first_name                   => csr_cur_fut.first_name
      ,c_known_as                     => csr_cur_fut.known_as
      ,c_marital_status               => csr_cur_fut.marital_status
      ,c_middle_names                 => csr_cur_fut.middle_names
      ,c_nationality                  => csr_cur_fut.nationality
      ,c_national_identifier          => csr_cur_fut.national_identifier
      ,c_previous_last_name           => csr_cur_fut.previous_last_name
      ,c_registered_disabled_flag     => csr_cur_fut.registered_disabled_flag
      ,c_sex                          => csr_cur_fut.sex
      ,c_title                        => csr_cur_fut.title
      ,c_vendor_id                    => csr_cur_fut.vendor_id
      ,c_work_telephone               => csr_cur_fut.work_telephone
      ,c_suffix                       => csr_cur_fut.suffix
      ,c_attribute_category           => csr_cur_fut.attribute_category
      ,c_attribute1                   => csr_cur_fut.attribute1
      ,c_attribute2                   => csr_cur_fut.attribute2
      ,c_attribute3                   => csr_cur_fut.attribute3
      ,c_attribute4                   => csr_cur_fut.attribute4
      ,c_attribute5                   => csr_cur_fut.attribute5
      ,c_attribute6                   => csr_cur_fut.attribute6
      ,c_attribute7                   => csr_cur_fut.attribute7
      ,c_attribute8                   => csr_cur_fut.attribute8
      ,c_attribute9                   => csr_cur_fut.attribute9
      ,c_attribute10                  => csr_cur_fut.attribute10
      ,c_attribute11                  => csr_cur_fut.attribute11
      ,c_attribute12                  => csr_cur_fut.attribute12
      ,c_attribute13                  => csr_cur_fut.attribute13
      ,c_attribute14                  => csr_cur_fut.attribute14
      ,c_attribute15                  => csr_cur_fut.attribute15
      ,c_attribute16                  => csr_cur_fut.attribute16
      ,c_attribute17                  => csr_cur_fut.attribute17
      ,c_attribute18                  => csr_cur_fut.attribute18
      ,c_attribute19                  => csr_cur_fut.attribute19
      ,c_attribute20                  => csr_cur_fut.attribute20
      ,c_attribute21                  => csr_cur_fut.attribute21
      ,c_attribute22                  => csr_cur_fut.attribute22
      ,c_attribute23                  => csr_cur_fut.attribute23
      ,c_attribute24                  => csr_cur_fut.attribute24
      ,c_attribute25                  => csr_cur_fut.attribute25
      ,c_attribute26                  => csr_cur_fut.attribute26
      ,c_attribute27                  => csr_cur_fut.attribute27
      ,c_attribute28                  => csr_cur_fut.attribute28
      ,c_attribute29                  => csr_cur_fut.attribute29
      ,c_attribute30                  => csr_cur_fut.attribute30
      ,c_per_information_category     => csr_cur_fut.per_information_category
      ,c_per_information1             => csr_cur_fut.per_information1
      ,c_per_information2             => csr_cur_fut.per_information2
      ,c_per_information3             => csr_cur_fut.per_information3
      ,c_per_information4             => csr_cur_fut.per_information4
      ,c_per_information5             => csr_cur_fut.per_information5
      ,c_per_information6             => csr_cur_fut.per_information6
      ,c_per_information7             => csr_cur_fut.per_information7
      ,c_per_information8             => csr_cur_fut.per_information8
      ,c_per_information9             => csr_cur_fut.per_information9
      ,c_per_information10            => csr_cur_fut.per_information10
      ,c_per_information11            => csr_cur_fut.per_information11
      ,c_per_information12            => csr_cur_fut.per_information12
      ,c_per_information13            => csr_cur_fut.per_information13
      ,c_per_information14            => csr_cur_fut.per_information14
      ,c_per_information15            => csr_cur_fut.per_information15
      ,c_per_information16            => csr_cur_fut.per_information16
      ,c_per_information17            => csr_cur_fut.per_information17
      ,c_per_information18            => csr_cur_fut.per_information18
      ,c_per_information19            => csr_cur_fut.per_information19
      ,c_per_information20            => csr_cur_fut.per_information20
      ,c_per_information21            => csr_cur_fut.per_information21
      ,c_per_information22            => csr_cur_fut.per_information22
      ,c_per_information23            => csr_cur_fut.per_information23
      ,c_per_information24            => csr_cur_fut.per_information24
      ,c_per_information25            => csr_cur_fut.per_information25
      ,c_per_information26            => csr_cur_fut.per_information26
      ,c_per_information27            => csr_cur_fut.per_information27
      ,c_per_information28            => csr_cur_fut.per_information28
      ,c_per_information29            => csr_cur_fut.per_information29
      ,c_per_information30            => csr_cur_fut.per_information30
      ,c_date_of_death                => csr_cur_fut.date_of_death
      ,c_background_check_status      => csr_cur_fut.background_check_status
      ,c_background_date_check        => csr_cur_fut.background_date_check
      ,c_blood_type                   => csr_cur_fut.blood_type
      ,c_correspondence_language      => csr_cur_fut.correspondence_language
      ,c_fast_path_employee           => csr_cur_fut.fast_path_employee
      ,c_fte_capacity                 => csr_cur_fut.fte_capacity
      ,c_hold_applicant_date_until    => csr_cur_fut.hold_applicant_date_until
      ,c_honors                       => csr_cur_fut.honors
      ,c_internal_location            => csr_cur_fut.internal_location
      ,c_last_medical_test_by         => csr_cur_fut.last_medical_test_by
      ,c_last_medical_test_date       => csr_cur_fut.last_medical_test_date
      ,c_mailstop                     => csr_cur_fut.mailstop
      ,c_office_number                => csr_cur_fut.office_number
      ,c_on_military_service          => csr_cur_fut.on_military_service
      ,c_pre_name_adjunct             => csr_cur_fut.pre_name_adjunct
      ,c_projected_start_date         => csr_cur_fut.projected_start_date
      ,c_rehire_authorizor            => csr_cur_fut.rehire_authorizor
      ,c_rehire_recommendation        => csr_cur_fut.rehire_recommendation
      ,c_resume_exists                => csr_cur_fut.resume_exists
      ,c_resume_last_updated          => csr_cur_fut.resume_last_updated
      ,c_second_passport_exists       => csr_cur_fut.second_passport_exists
      ,c_student_status               => csr_cur_fut.student_status
      ,c_work_schedule                => csr_cur_fut.work_schedule
      ,c_rehire_reason                => csr_cur_fut.rehire_reason
      ,c_benefit_group_id             => csr_cur_fut.benefit_group_id
      ,c_receipt_of_death_cert_date   => csr_cur_fut.receipt_of_death_cert_date
      ,c_coord_ben_med_pln_no         => csr_cur_fut.coord_ben_med_pln_no
      ,c_coord_ben_no_cvg_flag        => csr_cur_fut.coord_ben_no_cvg_flag
      ,c_uses_tobacco_flag            => csr_cur_fut.uses_tobacco_flag
      ,c_dpdnt_adoption_date          => csr_cur_fut.dpdnt_adoption_date
      ,c_dpdnt_vlntry_svce_flag       => csr_cur_fut.dpdnt_vlntry_svce_flag
      ,c_original_date_of_hire        => csr_cur_fut.original_date_of_hire
      ,c_town_of_birth                => csr_cur_fut.town_of_birth
      ,c_region_of_birth              => csr_cur_fut.region_of_birth
      ,c_country_of_birth             => csr_cur_fut.country_of_birth
      ,c_global_person_id             => csr_cur_fut.global_person_id
       ) then
      -- all the attributes have been processed, exit the loop
      exit;
    end if;
  end loop;
  -- ------------------------------------------------------------------------
  -- process any past row(s)
  if p_attribute_update_mode = 'ATTRIBUTE_CORRECTION' then
    -- reset the parameter statuses
    hr_dt_attribute_support.reset_parameter_statuses;
    for csr_past in csr_per2 loop
      if not process_row
        (c_effective_start_date         => csr_past.effective_start_date
        ,c_object_version_number        => csr_past.object_version_number
        ,c_person_type_id               => csr_past.person_type_id
        ,c_last_name                    => csr_past.last_name
        ,c_applicant_number             => csr_past.applicant_number
        ,c_comments                     => csr_past.comment_text
        ,c_date_employee_data_verified  => csr_past.date_employee_data_verified
        ,c_date_of_birth                => csr_past.date_of_birth
        ,c_email_address                => csr_past.email_address
        ,c_employee_number              => csr_past.employee_number
        ,c_expense_check_send_to_addres => csr_past.expense_check_send_to_address
        ,c_first_name                   => csr_past.first_name
        ,c_known_as                     => csr_past.known_as
        ,c_marital_status               => csr_past.marital_status
        ,c_middle_names                 => csr_past.middle_names
        ,c_nationality                  => csr_past.nationality
        ,c_national_identifier          => csr_past.national_identifier
        ,c_previous_last_name           => csr_past.previous_last_name
        ,c_registered_disabled_flag     => csr_past.registered_disabled_flag
        ,c_sex                          => csr_past.sex
        ,c_title                        => csr_past.title
        ,c_vendor_id                    => csr_past.vendor_id
        ,c_work_telephone               => csr_past.work_telephone
        ,c_suffix                       => csr_past.suffix
        ,c_attribute_category           => csr_past.attribute_category
        ,c_attribute1                   => csr_past.attribute1
        ,c_attribute2                   => csr_past.attribute2
        ,c_attribute3                   => csr_past.attribute3
        ,c_attribute4                   => csr_past.attribute4
        ,c_attribute5                   => csr_past.attribute5
        ,c_attribute6                   => csr_past.attribute6
        ,c_attribute7                   => csr_past.attribute7
        ,c_attribute8                   => csr_past.attribute8
        ,c_attribute9                   => csr_past.attribute9
        ,c_attribute10                  => csr_past.attribute10
        ,c_attribute11                  => csr_past.attribute11
        ,c_attribute12                  => csr_past.attribute12
        ,c_attribute13                  => csr_past.attribute13
        ,c_attribute14                  => csr_past.attribute14
        ,c_attribute15                  => csr_past.attribute15
        ,c_attribute16                  => csr_past.attribute16
        ,c_attribute17                  => csr_past.attribute17
        ,c_attribute18                  => csr_past.attribute18
        ,c_attribute19                  => csr_past.attribute19
        ,c_attribute20                  => csr_past.attribute20
        ,c_attribute21                  => csr_past.attribute21
        ,c_attribute22                  => csr_past.attribute22
        ,c_attribute23                  => csr_past.attribute23
        ,c_attribute24                  => csr_past.attribute24
        ,c_attribute25                  => csr_past.attribute25
        ,c_attribute26                  => csr_past.attribute26
        ,c_attribute27                  => csr_past.attribute27
        ,c_attribute28                  => csr_past.attribute28
        ,c_attribute29                  => csr_past.attribute29
        ,c_attribute30                  => csr_past.attribute30
        ,c_per_information_category     => csr_past.per_information_category
        ,c_per_information1             => csr_past.per_information1
        ,c_per_information2             => csr_past.per_information2
        ,c_per_information3             => csr_past.per_information3
        ,c_per_information4             => csr_past.per_information4
        ,c_per_information5             => csr_past.per_information5
        ,c_per_information6             => csr_past.per_information6
        ,c_per_information7             => csr_past.per_information7
        ,c_per_information8             => csr_past.per_information8
        ,c_per_information9             => csr_past.per_information9
        ,c_per_information10            => csr_past.per_information10
        ,c_per_information11            => csr_past.per_information11
        ,c_per_information12            => csr_past.per_information12
        ,c_per_information13            => csr_past.per_information13
        ,c_per_information14            => csr_past.per_information14
        ,c_per_information15            => csr_past.per_information15
        ,c_per_information16            => csr_past.per_information16
        ,c_per_information17            => csr_past.per_information17
        ,c_per_information18            => csr_past.per_information18
        ,c_per_information19            => csr_past.per_information19
        ,c_per_information20            => csr_past.per_information20
        ,c_per_information21            => csr_past.per_information21
        ,c_per_information22            => csr_past.per_information22
        ,c_per_information23            => csr_past.per_information23
        ,c_per_information24            => csr_past.per_information24
        ,c_per_information25            => csr_past.per_information25
        ,c_per_information26            => csr_past.per_information26
        ,c_per_information27            => csr_past.per_information27
        ,c_per_information28            => csr_past.per_information28
        ,c_per_information29            => csr_past.per_information29
        ,c_per_information30            => csr_past.per_information30
        ,c_date_of_death                => csr_past.date_of_death
        ,c_background_check_status      => csr_past.background_check_status
        ,c_background_date_check        => csr_past.background_date_check
        ,c_blood_type                   => csr_past.blood_type
        ,c_correspondence_language      => csr_past.correspondence_language
        ,c_fast_path_employee           => csr_past.fast_path_employee
        ,c_fte_capacity                 => csr_past.fte_capacity
        ,c_hold_applicant_date_until    => csr_past.hold_applicant_date_until
        ,c_honors                       => csr_past.honors
        ,c_internal_location            => csr_past.internal_location
        ,c_last_medical_test_by         => csr_past.last_medical_test_by
        ,c_last_medical_test_date       => csr_past.last_medical_test_date
        ,c_mailstop                     => csr_past.mailstop
        ,c_office_number                => csr_past.office_number
        ,c_on_military_service          => csr_past.on_military_service
        ,c_pre_name_adjunct             => csr_past.pre_name_adjunct
        ,c_projected_start_date         => csr_past.projected_start_date
        ,c_rehire_authorizor            => csr_past.rehire_authorizor
        ,c_rehire_recommendation        => csr_past.rehire_recommendation
        ,c_resume_exists                => csr_past.resume_exists
        ,c_resume_last_updated          => csr_past.resume_last_updated
        ,c_second_passport_exists       => csr_past.second_passport_exists
        ,c_student_status               => csr_past.student_status
        ,c_work_schedule                => csr_past.work_schedule
        ,c_rehire_reason                => csr_past.rehire_reason
        ,c_benefit_group_id             => csr_past.benefit_group_id
        ,c_receipt_of_death_cert_date   => csr_past.receipt_of_death_cert_date
        ,c_coord_ben_med_pln_no         => csr_past.coord_ben_med_pln_no
        ,c_coord_ben_no_cvg_flag        => csr_past.coord_ben_no_cvg_flag
        ,c_uses_tobacco_flag            => csr_past.uses_tobacco_flag
        ,c_dpdnt_adoption_date          => csr_past.dpdnt_adoption_date
        ,c_dpdnt_vlntry_svce_flag       => csr_past.dpdnt_vlntry_svce_flag
        ,c_original_date_of_hire        => csr_past.original_date_of_hire
        ,c_town_of_birth                => csr_past.town_of_birth
        ,c_region_of_birth              => csr_past.region_of_birth
        ,c_country_of_birth             => csr_past.country_of_birth
        ,c_global_person_id             => csr_past.global_person_id
      ) then
        -- all the attributes have been processed, exit the loop
        exit;
      end if;
    end loop;
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  -- set the warning OUT parameters
  p_name_combination_warning := l_api_name_combination_warning;
  p_assign_payroll_warning := l_api_assign_payroll_warning;
  p_orig_hire_warning  := l_api_orig_hire_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person;
    -- reset IN OUT parameters to original IN value
    p_object_version_number    := p_object_version_number;
    p_employee_number          := p_employee_number;
    -- reset non-warning OUT parameters to NULL
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_full_name                := null;
    p_comment_id               := null;
    -- set warning OUT parameters to REAL value
    p_name_combination_warning := l_api_name_combination_warning;
    p_assign_payroll_warning   := l_api_assign_payroll_warning;
    p_orig_hire_warning        := l_orig_hire_warning;
end update_person;
--
end hr_person_att;

/
