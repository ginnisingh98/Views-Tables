--------------------------------------------------------
--  DDL for Package Body HR_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTACT_REL_API" as
/* $Header: pecrlapi.pkb 120.0.12010000.4 2009/03/04 12:12:29 sudsahu ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_contact_rel_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_contact >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_contact
  (
   p_validate                     in        boolean     default false
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_cont_information_category      in        varchar2    default null
  ,p_cont_information1              in        varchar2    default null
  ,p_cont_information2              in        varchar2    default null
  ,p_cont_information3              in        varchar2    default null
  ,p_cont_information4              in        varchar2    default null
  ,p_cont_information5              in        varchar2    default null
  ,p_cont_information6              in        varchar2    default null
  ,p_cont_information7              in        varchar2    default null
  ,p_cont_information8              in        varchar2    default null
  ,p_cont_information9              in        varchar2    default null
  ,p_cont_information10             in        varchar2    default null
  ,p_cont_information11             in        varchar2    default null
  ,p_cont_information12             in        varchar2    default null
  ,p_cont_information13             in        varchar2    default null
  ,p_cont_information14             in        varchar2    default null
  ,p_cont_information15             in        varchar2    default null
  ,p_cont_information16             in        varchar2    default null
  ,p_cont_information17             in        varchar2    default null
  ,p_cont_information18             in        varchar2    default null
  ,p_cont_information19             in        varchar2    default null
  ,p_cont_information20             in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2    default null
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_national_identifier          in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,p_per_information1             in        varchar2    default null
  ,p_per_information2             in        varchar2    default null
  ,p_per_information3             in        varchar2    default null
  ,p_per_information4             in        varchar2    default null
  ,p_per_information5             in        varchar2    default null
  ,p_per_information6             in        varchar2    default null
  ,p_per_information7             in        varchar2    default null
  ,p_per_information8             in        varchar2    default null
  ,p_per_information9             in        varchar2    default null
  ,p_per_information10            in        varchar2    default null
  ,p_per_information11            in        varchar2    default null
  ,p_per_information12            in        varchar2    default null
  ,p_per_information13            in        varchar2    default null
  ,p_per_information14            in        varchar2    default null
  ,p_per_information15            in        varchar2    default null
  ,p_per_information16            in        varchar2    default null
  ,p_per_information17            in        varchar2    default null
  ,p_per_information18            in        varchar2    default null
  ,p_per_information19            in        varchar2    default null
  ,p_per_information20            in        varchar2    default null
  ,p_per_information21            in        varchar2    default null
  ,p_per_information22            in        varchar2    default null
  ,p_per_information23            in        varchar2    default null
  ,p_per_information24            in        varchar2    default null
  ,p_per_information25            in        varchar2    default null
  ,p_per_information26            in        varchar2    default null
  ,p_per_information27            in        varchar2    default null
  ,p_per_information28            in        varchar2    default null
  ,p_per_information29            in        varchar2    default null
  ,p_per_information30            in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_mirror_cont_information_cat    in        varchar2    default null
  ,p_mirror_cont_information1       in        varchar2    default null
  ,p_mirror_cont_information2       in        varchar2    default null
  ,p_mirror_cont_information3       in        varchar2    default null
  ,p_mirror_cont_information4       in        varchar2    default null
  ,p_mirror_cont_information5       in        varchar2    default null
  ,p_mirror_cont_information6       in        varchar2    default null
  ,p_mirror_cont_information7       in        varchar2    default null
  ,p_mirror_cont_information8       in        varchar2    default null
  ,p_mirror_cont_information9       in        varchar2    default null
  ,p_mirror_cont_information10      in        varchar2    default null
  ,p_mirror_cont_information11      in        varchar2    default null
  ,p_mirror_cont_information12      in        varchar2    default null
  ,p_mirror_cont_information13      in        varchar2    default null
  ,p_mirror_cont_information14      in        varchar2    default null
  ,p_mirror_cont_information15      in        varchar2    default null
  ,p_mirror_cont_information16      in        varchar2    default null
  ,p_mirror_cont_information17      in        varchar2    default null
  ,p_mirror_cont_information18      in        varchar2    default null
  ,p_mirror_cont_information19      in        varchar2    default null
  ,p_mirror_cont_information20      in        varchar2    default null
  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_name_combination_warning     out nocopy boolean
  ,p_orig_hire_warning            out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'create_contact';
  l_contact_relationship_id
    per_contact_relationships.contact_relationship_id%TYPE;
  l_per_object_version_number  number(9);
  l_ctr_object_version_number  number(9);
  l_name_combination_warning   boolean;
  l_orig_hire_warning          boolean;
  l_start_date                 date;
  l_date_start                 date;
  l_date_end                   date;
  --
  -- dummy variables for rh outs
  --
  l_date_employee_data_verified    date;
  l_employee_number                varchar2(30);
  l_contact_person_id              per_contact_relationships.contact_person_id%TYPE;
  l_contact_person_id_save         per_contact_relationships.contact_person_id%TYPE;
  l_person_id                      per_contact_relationships.person_id%TYPE;
  l_contact_type                   varchar2(30);
  l_third_party_pay_flag           varchar2(1);
  l_primary_contact_flag           varchar2(1);
  l_bondholder_flag                varchar2(1);
  l_dependent_flag                 varchar2(1);
  l_beneficiary_flag               varchar2(1);
  l_sequence_number                number;
  l_mirror_ovn                     number;
  l_mirror_contact_rel_id          number;
  --
  -- Extra dummy vars for rh outs. Created due to User Hook.
  --
  l_per_effective_start_date       date;
  l_per_effective_end_date         date;
  l_full_name                      varchar2(240);
  l_per_comment_id                 number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  l_start_date := trunc(p_start_date);
  l_date_start := trunc(p_date_start);
  l_date_end   := trunc(p_date_end);
  --
  savepoint create_contact;
  hr_utility.set_location(l_proc, 6);
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_contact
    --
     hr_contact_rel_bk1.create_contact_b
      (p_start_date                   =>  l_start_date
      ,p_person_id                    =>  p_person_id
      ,p_business_group_id            =>  p_business_group_id
      ,p_contact_person_id            =>  p_contact_person_id
      ,p_contact_type                 =>  p_contact_type
      ,p_ctr_comments                 =>  p_ctr_comments
      ,p_primary_contact_flag         =>  p_primary_contact_flag
      ,p_date_start                   =>  l_date_start
      ,p_start_life_reason_id         =>  p_start_life_reason_id
      ,p_date_end                     =>  l_date_end
      ,p_end_life_reason_id           =>  p_end_life_reason_id
      ,p_rltd_per_rsds_w_dsgntr_flag  =>  p_rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag                =>  p_personal_flag
      ,p_sequence_number              =>  p_sequence_number
      ,p_cont_attribute_category      =>  p_cont_attribute_category
      ,p_cont_attribute1              =>  p_cont_attribute1
      ,p_cont_attribute2              =>  p_cont_attribute2
      ,p_cont_attribute3              =>  p_cont_attribute3
      ,p_cont_attribute4              =>  p_cont_attribute4
      ,p_cont_attribute5              =>  p_cont_attribute5
      ,p_cont_attribute6              =>  p_cont_attribute6
      ,p_cont_attribute7              =>  p_cont_attribute7
      ,p_cont_attribute8              =>  p_cont_attribute8
      ,p_cont_attribute9              =>  p_cont_attribute9
      ,p_cont_attribute10             =>  p_cont_attribute10
      ,p_cont_attribute11             =>  p_cont_attribute11
      ,p_cont_attribute12             =>  p_cont_attribute12
      ,p_cont_attribute13             =>  p_cont_attribute13
      ,p_cont_attribute14             =>  p_cont_attribute14
      ,p_cont_attribute15             =>  p_cont_attribute15
      ,p_cont_attribute16             =>  p_cont_attribute16
      ,p_cont_attribute17             =>  p_cont_attribute17
      ,p_cont_attribute18             =>  p_cont_attribute18
      ,p_cont_attribute19             =>  p_cont_attribute19
      ,p_cont_attribute20             =>  p_cont_attribute20
      ,p_cont_information_category      =>  p_cont_information_category
      ,p_cont_information1              =>  p_cont_information1
      ,p_cont_information2              =>  p_cont_information2
      ,p_cont_information3              =>  p_cont_information3
      ,p_cont_information4              =>  p_cont_information4
      ,p_cont_information5              =>  p_cont_information5
      ,p_cont_information6              =>  p_cont_information6
      ,p_cont_information7              =>  p_cont_information7
      ,p_cont_information8              =>  p_cont_information8
      ,p_cont_information9              =>  p_cont_information9
      ,p_cont_information10             =>  p_cont_information10
      ,p_cont_information11             =>  p_cont_information11
      ,p_cont_information12             =>  p_cont_information12
      ,p_cont_information13             =>  p_cont_information13
      ,p_cont_information14             =>  p_cont_information14
      ,p_cont_information15             =>  p_cont_information15
      ,p_cont_information16             =>  p_cont_information16
      ,p_cont_information17             =>  p_cont_information17
      ,p_cont_information18             =>  p_cont_information18
      ,p_cont_information19             =>  p_cont_information19
      ,p_cont_information20             =>  p_cont_information20
      ,p_third_party_pay_flag         =>  p_third_party_pay_flag
      ,p_bondholder_flag              =>  p_bondholder_flag
      ,p_dependent_flag               =>  p_dependent_flag
      ,p_beneficiary_flag             =>  p_beneficiary_flag
      ,p_sex                          =>  p_sex
      ,p_last_name                    =>  p_last_name
      ,p_person_type_id               =>  p_person_type_id
      ,p_per_comments                 =>  p_per_comments
      ,p_date_of_birth                =>  p_date_of_birth
      ,p_email_address                =>  p_email_address
      ,p_first_name                   =>  p_first_name
      ,p_known_as                     =>  p_known_as
      ,p_marital_status               =>  p_marital_status
      ,p_middle_names                 =>  p_middle_names
      ,p_nationality                  =>  p_nationality
      ,p_national_identifier          =>  p_national_identifier
      ,p_previous_last_name           =>  p_previous_last_name
      ,p_registered_disabled_flag     =>  p_registered_disabled_flag
      ,p_title                        =>  p_title
      ,p_work_telephone               =>  p_work_telephone
      ,p_attribute_category           =>  p_attribute_category
      ,p_attribute1                   =>  p_attribute1
      ,p_attribute2                   =>  p_attribute2
      ,p_attribute3                   =>  p_attribute3
      ,p_attribute4                   =>  p_attribute4
      ,p_attribute5                   =>  p_attribute5
      ,p_attribute6                   =>  p_attribute6
      ,p_attribute7                   =>  p_attribute7
      ,p_attribute8                   =>  p_attribute8
      ,p_attribute9                   =>  p_attribute9
      ,p_attribute10                  =>  p_attribute10
      ,p_attribute11                  =>  p_attribute11
      ,p_attribute12                  =>  p_attribute12
      ,p_attribute13                  =>  p_attribute13
      ,p_attribute14                  =>  p_attribute14
      ,p_attribute15                  =>  p_attribute15
      ,p_attribute16                  =>  p_attribute16
      ,p_attribute17                  =>  p_attribute17
      ,p_attribute18                  =>  p_attribute18
      ,p_attribute19                  =>  p_attribute19
      ,p_attribute20                  =>  p_attribute20
      ,p_attribute21                  =>  p_attribute21
      ,p_attribute22                  =>  p_attribute22
      ,p_attribute23                  =>  p_attribute23
      ,p_attribute24                  =>  p_attribute24
      ,p_attribute25                  =>  p_attribute25
      ,p_attribute26                  =>  p_attribute26
      ,p_attribute27                  =>  p_attribute27
      ,p_attribute28                  =>  p_attribute28
      ,p_attribute29                  =>  p_attribute29
      ,p_attribute30                  =>  p_attribute30
      ,p_per_information_category     =>  p_per_information_category
      ,p_per_information1             =>  p_per_information1
      ,p_per_information2             =>  p_per_information2
      ,p_per_information3             =>  p_per_information3
      ,p_per_information4             =>  p_per_information4
      ,p_per_information5             =>  p_per_information5
      ,p_per_information6             =>  p_per_information6
      ,p_per_information7             =>  p_per_information7
      ,p_per_information8             =>  p_per_information8
      ,p_per_information9             =>  p_per_information9
      ,p_per_information10            =>  p_per_information10
      ,p_per_information11            =>  p_per_information11
      ,p_per_information12            =>  p_per_information12
      ,p_per_information13            =>  p_per_information13
      ,p_per_information14            =>  p_per_information14
      ,p_per_information15            =>  p_per_information15
      ,p_per_information16            =>  p_per_information16
      ,p_per_information17            =>  p_per_information17
      ,p_per_information18            =>  p_per_information18
      ,p_per_information19            =>  p_per_information19
      ,p_per_information20            =>  p_per_information20
      ,p_per_information21            =>  p_per_information21
      ,p_per_information22            =>  p_per_information22
      ,p_per_information23            =>  p_per_information23
      ,p_per_information24            =>  p_per_information24
      ,p_per_information25            =>  p_per_information25
      ,p_per_information26            =>  p_per_information26
      ,p_per_information27            =>  p_per_information27
      ,p_per_information28            =>  p_per_information28
      ,p_per_information29            =>  p_per_information29
      ,p_per_information30            =>  p_per_information30
      ,p_correspondence_language      =>  p_correspondence_language
      ,p_honors                       =>  p_honors
      ,p_pre_name_adjunct             =>  p_pre_name_adjunct
      ,p_suffix                       =>  p_suffix
      ,p_create_mirror_flag           =>  p_create_mirror_flag
      ,p_mirror_type                  =>  p_mirror_type
      ,p_mirror_cont_attribute_cat    =>  p_mirror_cont_attribute_cat
      ,p_mirror_cont_attribute1       =>  p_mirror_cont_attribute1
      ,p_mirror_cont_attribute2       =>  p_mirror_cont_attribute2
      ,p_mirror_cont_attribute3       =>  p_mirror_cont_attribute3
      ,p_mirror_cont_attribute4       =>  p_mirror_cont_attribute4
      ,p_mirror_cont_attribute5       =>  p_mirror_cont_attribute5
      ,p_mirror_cont_attribute6       =>  p_mirror_cont_attribute6
      ,p_mirror_cont_attribute7       =>  p_mirror_cont_attribute7
      ,p_mirror_cont_attribute8       =>  p_mirror_cont_attribute8
      ,p_mirror_cont_attribute9       =>  p_mirror_cont_attribute9
      ,p_mirror_cont_attribute10      =>  p_mirror_cont_attribute10
      ,p_mirror_cont_attribute11      =>  p_mirror_cont_attribute11
      ,p_mirror_cont_attribute12      =>  p_mirror_cont_attribute12
      ,p_mirror_cont_attribute13      =>  p_mirror_cont_attribute13
      ,p_mirror_cont_attribute14      =>  p_mirror_cont_attribute14
      ,p_mirror_cont_attribute15      =>  p_mirror_cont_attribute15
      ,p_mirror_cont_attribute16      =>  p_mirror_cont_attribute16
      ,p_mirror_cont_attribute17      =>  p_mirror_cont_attribute17
      ,p_mirror_cont_attribute18      =>  p_mirror_cont_attribute18
      ,p_mirror_cont_attribute19      =>  p_mirror_cont_attribute19
      ,p_mirror_cont_attribute20      =>  p_mirror_cont_attribute20
      ,p_mirror_cont_information_cat    =>  p_mirror_cont_information_cat
      ,p_mirror_cont_information1       =>  p_mirror_cont_information1
      ,p_mirror_cont_information2       =>  p_mirror_cont_information2
      ,p_mirror_cont_information3       =>  p_mirror_cont_information3
      ,p_mirror_cont_information4       =>  p_mirror_cont_information4
      ,p_mirror_cont_information5       =>  p_mirror_cont_information5
      ,p_mirror_cont_information6       =>  p_mirror_cont_information6
      ,p_mirror_cont_information7       =>  p_mirror_cont_information7
      ,p_mirror_cont_information8       =>  p_mirror_cont_information8
      ,p_mirror_cont_information9       =>  p_mirror_cont_information9
      ,p_mirror_cont_information10      =>  p_mirror_cont_information10
      ,p_mirror_cont_information11      =>  p_mirror_cont_information11
      ,p_mirror_cont_information12      =>  p_mirror_cont_information12
      ,p_mirror_cont_information13      =>  p_mirror_cont_information13
      ,p_mirror_cont_information14      =>  p_mirror_cont_information14
      ,p_mirror_cont_information15      =>  p_mirror_cont_information15
      ,p_mirror_cont_information16      =>  p_mirror_cont_information16
      ,p_mirror_cont_information17      =>  p_mirror_cont_information17
      ,p_mirror_cont_information18      =>  p_mirror_cont_information18
      ,p_mirror_cont_information19      =>  p_mirror_cont_information19
      ,p_mirror_cont_information20      =>  p_mirror_cont_information20
      );
 exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_contact'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_contact
    --
  end;
  --
  -- Process Logic
  -- Check that the contact person is not null. If not, go straight to
  -- entering the details into per_contact_relationships. If it is null,
  -- call hr_contact_api.create_person
  --
 if p_contact_person_id is null then
  --
  hr_contact_api.create_person
  (p_validate                     =>  false
  ,p_start_date                   =>  l_start_date
  ,p_person_id                    =>  l_contact_person_id
  ,p_business_group_id            =>  p_business_group_id
  ,p_sex                          =>  p_sex
  ,p_last_name                    =>  p_last_name
  ,p_person_type_id               =>  p_person_type_id
  --
  ,p_comments                     =>  p_per_comments
  ,p_date_employee_data_verified  =>  l_date_employee_data_verified
  ,p_date_of_birth                =>  p_date_of_birth
  ,p_email_address                =>  p_email_address
  ,p_first_name                   =>  p_first_name
  ,p_known_as                     =>  p_known_as
  ,p_marital_status               =>  p_marital_status
  ,p_middle_names                 =>  p_middle_names
  ,p_nationality                  =>  p_nationality
  ,p_national_identifier          =>  p_national_identifier
  ,p_previous_last_name           =>  p_previous_last_name
  ,p_registered_disabled_flag     =>  p_registered_disabled_flag
  ,p_title                        =>  p_title
  ,p_work_telephone               =>  p_work_telephone
  ,p_attribute_category           =>  p_attribute_category
  ,p_attribute1                   =>  p_attribute1
  ,p_attribute2                   =>  p_attribute2
  ,p_attribute3                   =>  p_attribute3
  ,p_attribute4                   =>  p_attribute4
  ,p_attribute5                   =>  p_attribute5
  ,p_attribute6                   =>  p_attribute6
  ,p_attribute7                   =>  p_attribute7
  ,p_attribute8                   =>  p_attribute8
  ,p_attribute9                   =>  p_attribute9
  ,p_attribute10                  =>  p_attribute10
  ,p_attribute11                  =>  p_attribute11
  ,p_attribute12                  =>  p_attribute12
  ,p_attribute13                  =>  p_attribute13
  ,p_attribute14                  =>  p_attribute14
  ,p_attribute15                  =>  p_attribute15
  ,p_attribute16                  =>  p_attribute16
  ,p_attribute17                  =>  p_attribute17
  ,p_attribute18                  =>  p_attribute18
  ,p_attribute19                  =>  p_attribute19
  ,p_attribute20                  =>  p_attribute20
  ,p_attribute21                  =>  p_attribute21
  ,p_attribute22                  =>  p_attribute22
  ,p_attribute23                  =>  p_attribute23
  ,p_attribute24                  =>  p_attribute24
  ,p_attribute25                  =>  p_attribute25
  ,p_attribute26                  =>  p_attribute26
  ,p_attribute27                  =>  p_attribute27
  ,p_attribute28                  =>  p_attribute28
  ,p_attribute29                  =>  p_attribute29
  ,p_attribute30                  =>  p_attribute30
  ,p_per_information_category     =>  p_per_information_category
  ,p_per_information1             =>  p_per_information1
  ,p_per_information2             =>  p_per_information2
  ,p_per_information3             =>  p_per_information3
  ,p_per_information4             =>  p_per_information4
  ,p_per_information5             =>  p_per_information5
  ,p_per_information6             =>  p_per_information6
  ,p_per_information7             =>  p_per_information7
  ,p_per_information8             =>  p_per_information8
  ,p_per_information9             =>  p_per_information9
  ,p_per_information10            =>  p_per_information10
  ,p_per_information11            =>  p_per_information11
  ,p_per_information12            =>  p_per_information12
  ,p_per_information13            =>  p_per_information13
  ,p_per_information14            =>  p_per_information14
  ,p_per_information15            =>  p_per_information15
  ,p_per_information16            =>  p_per_information16
  ,p_per_information17            =>  p_per_information17
  ,p_per_information18            =>  p_per_information18
  ,p_per_information19            =>  p_per_information19
  ,p_per_information20            =>  p_per_information20
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
  ,p_correspondence_language      => p_correspondence_language
  ,p_honors                       => p_honors
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_suffix                       =>  p_suffix
  --
  ,p_object_version_number        =>  l_per_object_version_number
  ,p_effective_start_date         =>  l_per_effective_start_date
  ,p_effective_end_date           =>  l_per_effective_end_date
  ,p_full_name                    =>  l_full_name
  ,p_comment_id                   =>  l_per_comment_id
  ,p_name_combination_warning     =>  l_name_combination_warning
  ,p_orig_hire_warning            =>  l_orig_hire_warning
  );
  --
  l_contact_person_id_save :=  l_contact_person_id;
  --
  else
    l_contact_person_id := p_contact_person_id;
    l_contact_person_id_save := l_contact_person_id;
  --
  end if;
  --
  -- Now we are sure of having a person_id for a contact, insert the
  -- details by calling the per_contact_relationships row handler.
  --
  hr_utility.set_location(l_proc, 40);
  --
 per_ctr_ins.ins(p_contact_relationship_id =>  l_contact_relationship_id
                ,p_business_group_id       =>  p_business_group_id
                ,p_person_id               =>  p_person_id
                ,p_contact_person_id       =>  l_contact_person_id
                ,p_contact_type            =>  p_contact_type
                ,p_comments                =>  p_ctr_comments
                ,p_primary_contact_flag    =>  p_primary_contact_flag
                ,p_date_start              =>  l_date_start
                ,p_start_life_reason_id    =>  p_start_life_reason_id
                ,p_date_end                =>  l_date_end
                ,p_end_life_reason_id      =>  p_end_life_reason_id
                ,p_rltd_per_rsds_w_dsgntr_flag =>  p_rltd_per_rsds_w_dsgntr_flag
                ,p_personal_flag           =>  p_personal_flag
		,p_sequence_number         =>  p_sequence_number
                ,p_cont_attribute_category =>  p_cont_attribute_category
                ,p_cont_attribute1         =>  p_cont_attribute1
                ,p_cont_attribute2         =>  p_cont_attribute2
                ,p_cont_attribute3         =>  p_cont_attribute3
                ,p_cont_attribute4         =>  p_cont_attribute4
                ,p_cont_attribute5         =>  p_cont_attribute5
                ,p_cont_attribute6         =>  p_cont_attribute6
                ,p_cont_attribute7         =>  p_cont_attribute7
                ,p_cont_attribute8         =>  p_cont_attribute8
                ,p_cont_attribute9         =>  p_cont_attribute9
                ,p_cont_attribute10        =>  p_cont_attribute10
                ,p_cont_attribute11        =>  p_cont_attribute11
                ,p_cont_attribute12        =>  p_cont_attribute12
                ,p_cont_attribute13        =>  p_cont_attribute13
                ,p_cont_attribute14        =>  p_cont_attribute14
                ,p_cont_attribute15        =>  p_cont_attribute15
                ,p_cont_attribute16        =>  p_cont_attribute16
                ,p_cont_attribute17        =>  p_cont_attribute17
                ,p_cont_attribute18        =>  p_cont_attribute18
                ,p_cont_attribute19        =>  p_cont_attribute19
                ,p_cont_attribute20        =>  p_cont_attribute20
                ,p_cont_information_category =>  p_cont_information_category
                ,p_cont_information1         =>  p_cont_information1
                ,p_cont_information2         =>  p_cont_information2
                ,p_cont_information3         =>  p_cont_information3
                ,p_cont_information4         =>  p_cont_information4
                ,p_cont_information5         =>  p_cont_information5
                ,p_cont_information6         =>  p_cont_information6
                ,p_cont_information7         =>  p_cont_information7
                ,p_cont_information8         =>  p_cont_information8
                ,p_cont_information9         =>  p_cont_information9
                ,p_cont_information10        =>  p_cont_information10
                ,p_cont_information11        =>  p_cont_information11
                ,p_cont_information12        =>  p_cont_information12
                ,p_cont_information13        =>  p_cont_information13
                ,p_cont_information14        =>  p_cont_information14
                ,p_cont_information15        =>  p_cont_information15
                ,p_cont_information16        =>  p_cont_information16
                ,p_cont_information17        =>  p_cont_information17
                ,p_cont_information18        =>  p_cont_information18
                ,p_cont_information19        =>  p_cont_information19
                ,p_cont_information20        =>  p_cont_information20
                ,p_third_party_pay_flag    =>  p_third_party_pay_flag
                ,p_bondholder_flag         =>  p_bondholder_flag
                ,p_dependent_flag          =>  p_dependent_flag
                ,p_beneficiary_flag        =>  p_beneficiary_flag
                ,p_object_version_number   =>  l_ctr_object_version_number
                ,p_effective_date          =>  l_start_date
                );
  --
  -- Set pipe on for Debug output
  --
  hr_utility.set_location(l_proc||'First contact created with id: ',l_contact_relationship_id);
  hr_utility.set_location(l_proc||'                     and type: '||p_contact_type, 0);
  hr_utility.set_location(l_proc||'                and person_id: ',p_person_id);
  hr_utility.set_location(l_proc||'        and contact_person_id: ',l_contact_person_id);
  --
  -- start of code for bug 2678841
    if p_contact_type in ('P','C','S') and
         p_personal_flag <> 'Y' then
       hr_utility.set_message(800,'PER_6994_PERSONAL_FLAG');
       hr_utility.raise_error;
     end if;
   -- end of code for bug 2678841

  if p_create_mirror_flag = 'Y' then

  -- Set the mirror person ids for the new contact relationship
  --
  l_person_id := l_contact_person_id;
  l_contact_person_id := p_person_id;
  --
  -- Set flags to 'N', these have to be set with the update API.
  --
  l_third_party_pay_flag := 'N';
  l_primary_contact_flag := 'N';
  l_bondholder_flag := 'N';
  l_dependent_flag  := 'N';
  l_beneficiary_flag := 'N';
  --
  -- Set mirror sequence number to null
  l_sequence_number := null;
  --
  -- Validation in addition to Row Handlers.
  --
   if p_contact_type = 'P' and p_mirror_type <> 'C'
     or p_contact_type = 'C' and p_mirror_type <> 'P'
     or p_contact_type = 'S' and p_mirror_type <> 'S' then
     hr_utility.set_message(801, 'PER_6995_MIRR_CON_REL_TYPES');
     hr_utility.raise_error;
   end if;
  --
   if (p_date_start is not null
       and p_date_of_birth is not null
       and p_date_start < p_date_of_birth) then
     fnd_message.set_name('PER','PER_50386_CON_SDT_LES_EMP_BDT');
     fnd_message.raise_error;
   end if;
  --
  -- Insert the mirror contact relationship
  --
  hr_utility.set_location(l_proc, 45);
  --
  per_ctr_ins.ins(p_contact_relationship_id =>  l_mirror_contact_rel_id
                 ,p_business_group_id       =>  p_business_group_id
                 ,p_person_id               =>  l_person_id
                 ,p_contact_person_id       =>  l_contact_person_id
                 ,p_contact_type            =>  p_mirror_type
                 ,p_comments                =>  null
                 ,p_primary_contact_flag    =>  l_primary_contact_flag
                 ,p_date_start              =>  l_date_start
                 ,p_start_life_reason_id    =>  p_start_life_reason_id
                 ,p_date_end                =>  l_date_end
                 ,p_end_life_reason_id      =>  p_end_life_reason_id
                 ,p_rltd_per_rsds_w_dsgntr_flag => p_rltd_per_rsds_w_dsgntr_flag
                 ,p_personal_flag           =>  p_personal_flag
		 ,p_sequence_number         =>  l_sequence_number
                 ,p_cont_attribute_category =>  p_mirror_cont_attribute_cat
                 ,p_cont_attribute1         =>  p_mirror_cont_attribute1
                 ,p_cont_attribute2         =>  p_mirror_cont_attribute2
                 ,p_cont_attribute3         =>  p_mirror_cont_attribute3
                 ,p_cont_attribute4         =>  p_mirror_cont_attribute4
                 ,p_cont_attribute5         =>  p_mirror_cont_attribute5
                 ,p_cont_attribute6         =>  p_mirror_cont_attribute6
                 ,p_cont_attribute7         =>  p_mirror_cont_attribute7
                 ,p_cont_attribute8         =>  p_mirror_cont_attribute8
                 ,p_cont_attribute9         =>  p_mirror_cont_attribute9
                 ,p_cont_attribute10        =>  p_mirror_cont_attribute10
                 ,p_cont_attribute11        =>  p_mirror_cont_attribute11
                 ,p_cont_attribute12        =>  p_mirror_cont_attribute12
                 ,p_cont_attribute13        =>  p_mirror_cont_attribute13
                 ,p_cont_attribute14        =>  p_mirror_cont_attribute14
                 ,p_cont_attribute15        =>  p_mirror_cont_attribute15
                 ,p_cont_attribute16        =>  p_mirror_cont_attribute16
                 ,p_cont_attribute17        =>  p_mirror_cont_attribute17
                 ,p_cont_attribute18        =>  p_mirror_cont_attribute18
                 ,p_cont_attribute19        =>  p_mirror_cont_attribute19
                 ,p_cont_attribute20        =>  p_mirror_cont_attribute20
                 ,p_cont_information_category =>  p_mirror_cont_information_cat
                 ,p_cont_information1         =>  p_mirror_cont_information1
                 ,p_cont_information2         =>  p_mirror_cont_information2
                 ,p_cont_information3         =>  p_mirror_cont_information3
                 ,p_cont_information4         =>  p_mirror_cont_information4
                 ,p_cont_information5         =>  p_mirror_cont_information5
                 ,p_cont_information6         =>  p_mirror_cont_information6
                 ,p_cont_information7         =>  p_mirror_cont_information7
                 ,p_cont_information8         =>  p_mirror_cont_information8
                 ,p_cont_information9         =>  p_mirror_cont_information9
                 ,p_cont_information10        =>  p_mirror_cont_information10
                 ,p_cont_information11        =>  p_mirror_cont_information11
                 ,p_cont_information12        =>  p_mirror_cont_information12
                 ,p_cont_information13        =>  p_mirror_cont_information13
                 ,p_cont_information14        =>  p_mirror_cont_information14
                 ,p_cont_information15        =>  p_mirror_cont_information15
                 ,p_cont_information16        =>  p_mirror_cont_information16
                 ,p_cont_information17        =>  p_mirror_cont_information17
                 ,p_cont_information18        =>  p_mirror_cont_information18
                 ,p_cont_information19        =>  p_mirror_cont_information19
                 ,p_cont_information20        =>  p_mirror_cont_information20
                 ,p_third_party_pay_flag    =>  l_third_party_pay_flag
                 ,p_bondholder_flag         =>  l_bondholder_flag
                 ,p_dependent_flag          =>  l_dependent_flag
                 ,p_beneficiary_flag        =>  l_beneficiary_flag
                 ,p_object_version_number   =>  l_mirror_ovn
                 ,p_effective_date          =>  l_start_date
                 );
  --
  -- Set pipe on for Debug output
  --
  hr_utility.set_location(l_proc||'Mirror contact created with id: ',l_mirror_contact_rel_id);
  hr_utility.set_location(l_proc||'                      and type: '||l_contact_type, 0);
  hr_utility.set_location(l_proc||'                 and person_id: ',l_person_id);
  hr_utility.set_location(l_proc||'         and contact_person_id: ',l_contact_person_id);
  --
  end if;
  --
  -- 1766066: added call for contact start date enh.
  --
  per_people12_pkg.maintain_coverage(p_person_id      => l_contact_person_id_save
                                    ,p_type           => 'CONT'
                                    );
  -- 1766066 end.
  -- 2410386 start
      select per.object_version_number into l_per_object_version_number
      from per_all_people_f per
      where per.person_id=l_contact_person_id_save
      and p_start_date between per.effective_start_date and per.effective_end_date;
  -- 2410386 end
  --
  -- Set all output arguments
  --
  p_per_person_id                :=  l_contact_person_id_save;
  p_contact_relationship_id      :=  l_contact_relationship_id;
  --
  p_ctr_object_version_number    := l_ctr_object_version_number;
  p_per_object_version_number    := l_per_object_version_number;
  p_per_effective_start_date     := l_per_effective_start_date;
  p_per_effective_end_date       := l_per_effective_end_date;
  p_full_name                    := l_full_name;
  p_per_comment_id               := l_per_comment_id;
  p_name_combination_warning     := l_name_combination_warning;
  p_orig_hire_warning            := l_orig_hire_warning;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_contact
    --
    hr_contact_rel_bk1.create_contact_a
      (p_start_date                   =>  l_start_date
      ,p_person_id                    =>  p_person_id
      ,p_business_group_id            =>  p_business_group_id
      ,p_contact_person_id            =>  p_contact_person_id
      ,p_contact_type                 =>  p_contact_type
      ,p_ctr_comments                 =>  p_ctr_comments
      ,p_primary_contact_flag         =>  p_primary_contact_flag
      ,p_date_start                   =>  l_date_start
      ,p_start_life_reason_id         =>  p_start_life_reason_id
      ,p_date_end                     =>  l_date_end
      ,p_end_life_reason_id           =>  p_end_life_reason_id
      ,p_rltd_per_rsds_w_dsgntr_flag  =>  p_rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag                =>  p_personal_flag
      ,p_sequence_number              =>  p_sequence_number
      ,p_cont_attribute_category      =>  p_cont_attribute_category
      ,p_cont_attribute1              =>  p_cont_attribute1
      ,p_cont_attribute2              =>  p_cont_attribute2
      ,p_cont_attribute3              =>  p_cont_attribute3
      ,p_cont_attribute4              =>  p_cont_attribute4
      ,p_cont_attribute5              =>  p_cont_attribute5
      ,p_cont_attribute6              =>  p_cont_attribute6
      ,p_cont_attribute7              =>  p_cont_attribute7
      ,p_cont_attribute8              =>  p_cont_attribute8
      ,p_cont_attribute9              =>  p_cont_attribute9
      ,p_cont_attribute10             =>  p_cont_attribute10
      ,p_cont_attribute11             =>  p_cont_attribute11
      ,p_cont_attribute12             =>  p_cont_attribute12
      ,p_cont_attribute13             =>  p_cont_attribute13
      ,p_cont_attribute14             =>  p_cont_attribute14
      ,p_cont_attribute15             =>  p_cont_attribute15
      ,p_cont_attribute16             =>  p_cont_attribute16
      ,p_cont_attribute17             =>  p_cont_attribute17
      ,p_cont_attribute18             =>  p_cont_attribute18
      ,p_cont_attribute19             =>  p_cont_attribute19
      ,p_cont_attribute20             =>  p_cont_attribute20
      ,p_cont_information_category      =>  p_cont_information_category
      ,p_cont_information1              =>  p_cont_information1
      ,p_cont_information2              =>  p_cont_information2
      ,p_cont_information3              =>  p_cont_information3
      ,p_cont_information4              =>  p_cont_information4
      ,p_cont_information5              =>  p_cont_information5
      ,p_cont_information6              =>  p_cont_information6
      ,p_cont_information7              =>  p_cont_information7
      ,p_cont_information8              =>  p_cont_information8
      ,p_cont_information9              =>  p_cont_information9
      ,p_cont_information10             =>  p_cont_information10
      ,p_cont_information11             =>  p_cont_information11
      ,p_cont_information12             =>  p_cont_information12
      ,p_cont_information13             =>  p_cont_information13
      ,p_cont_information14             =>  p_cont_information14
      ,p_cont_information15             =>  p_cont_information15
      ,p_cont_information16             =>  p_cont_information16
      ,p_cont_information17             =>  p_cont_information17
      ,p_cont_information18             =>  p_cont_information18
      ,p_cont_information19             =>  p_cont_information19
      ,p_cont_information20             =>  p_cont_information20
      ,p_third_party_pay_flag         =>  p_third_party_pay_flag
      ,p_bondholder_flag              =>  p_bondholder_flag
      ,p_dependent_flag               =>  p_dependent_flag
      ,p_beneficiary_flag             =>  p_beneficiary_flag
      ,p_sex                          =>  p_sex
      ,p_last_name                    =>  p_last_name
      ,p_person_type_id               =>  p_person_type_id
      ,p_per_comments                 =>  p_per_comments
      ,p_date_of_birth                =>  p_date_of_birth
      ,p_email_address                =>  p_email_address
      ,p_first_name                   =>  p_first_name
      ,p_known_as                     =>  p_known_as
      ,p_marital_status               =>  p_marital_status
      ,p_middle_names                 =>  p_middle_names
      ,p_nationality                  =>  p_nationality
      ,p_national_identifier          =>  p_national_identifier
      ,p_previous_last_name           =>  p_previous_last_name
      ,p_registered_disabled_flag     =>  p_registered_disabled_flag
      ,p_title                        =>  p_title
      ,p_work_telephone               =>  p_work_telephone
      ,p_attribute_category           =>  p_attribute_category
      ,p_attribute1                   =>  p_attribute1
      ,p_attribute2                   =>  p_attribute2
      ,p_attribute3                   =>  p_attribute3
      ,p_attribute4                   =>  p_attribute4
      ,p_attribute5                   =>  p_attribute5
      ,p_attribute6                   =>  p_attribute6
      ,p_attribute7                   =>  p_attribute7
      ,p_attribute8                   =>  p_attribute8
      ,p_attribute9                   =>  p_attribute9
      ,p_attribute10                  =>  p_attribute10
      ,p_attribute11                  =>  p_attribute11
      ,p_attribute12                  =>  p_attribute12
      ,p_attribute13                  =>  p_attribute13
      ,p_attribute14                  =>  p_attribute14
      ,p_attribute15                  =>  p_attribute15
      ,p_attribute16                  =>  p_attribute16
      ,p_attribute17                  =>  p_attribute17
      ,p_attribute18                  =>  p_attribute18
      ,p_attribute19                  =>  p_attribute19
      ,p_attribute20                  =>  p_attribute20
      ,p_attribute21                  =>  p_attribute21
      ,p_attribute22                  =>  p_attribute22
      ,p_attribute23                  =>  p_attribute23
      ,p_attribute24                  =>  p_attribute24
      ,p_attribute25                  =>  p_attribute25
      ,p_attribute26                  =>  p_attribute26
      ,p_attribute27                  =>  p_attribute27
      ,p_attribute28                  =>  p_attribute28
      ,p_attribute29                  =>  p_attribute29
      ,p_attribute30                  =>  p_attribute30
      ,p_per_information_category     =>  p_per_information_category
      ,p_per_information1             =>  p_per_information1
      ,p_per_information2             =>  p_per_information2
      ,p_per_information3             =>  p_per_information3
      ,p_per_information4             =>  p_per_information4
      ,p_per_information5             =>  p_per_information5
      ,p_per_information6             =>  p_per_information6
      ,p_per_information7             =>  p_per_information7
      ,p_per_information8             =>  p_per_information8
      ,p_per_information9             =>  p_per_information9
      ,p_per_information10            =>  p_per_information10
      ,p_per_information11            =>  p_per_information11
      ,p_per_information12            =>  p_per_information12
      ,p_per_information13            =>  p_per_information13
      ,p_per_information14            =>  p_per_information14
      ,p_per_information15            =>  p_per_information15
      ,p_per_information16            =>  p_per_information16
      ,p_per_information17            =>  p_per_information17
      ,p_per_information18            =>  p_per_information18
      ,p_per_information19            =>  p_per_information19
      ,p_per_information20            =>  p_per_information20
      ,p_per_information21            =>  p_per_information21
      ,p_per_information22            =>  p_per_information22
      ,p_per_information23            =>  p_per_information23
      ,p_per_information24            =>  p_per_information24
      ,p_per_information25            =>  p_per_information25
      ,p_per_information26            =>  p_per_information26
      ,p_per_information27            =>  p_per_information27
      ,p_per_information28            =>  p_per_information28
      ,p_per_information29            =>  p_per_information29
      ,p_per_information30            =>  p_per_information30
      ,p_correspondence_language      =>  p_correspondence_language
      ,p_honors                       =>  p_honors
      ,p_pre_name_adjunct             =>  p_pre_name_adjunct
      ,p_suffix                       =>  p_suffix
      ,p_create_mirror_flag           =>  p_create_mirror_flag
      ,p_mirror_type                  =>  p_mirror_type
      ,p_mirror_cont_attribute_cat    =>  p_mirror_cont_attribute_cat
      ,p_mirror_cont_attribute1       =>  p_mirror_cont_attribute1
      ,p_mirror_cont_attribute2       =>  p_mirror_cont_attribute2
      ,p_mirror_cont_attribute3       =>  p_mirror_cont_attribute3
      ,p_mirror_cont_attribute4       =>  p_mirror_cont_attribute4
      ,p_mirror_cont_attribute5       =>  p_mirror_cont_attribute5
      ,p_mirror_cont_attribute6       =>  p_mirror_cont_attribute6
      ,p_mirror_cont_attribute7       =>  p_mirror_cont_attribute7
      ,p_mirror_cont_attribute8       =>  p_mirror_cont_attribute8
      ,p_mirror_cont_attribute9       =>  p_mirror_cont_attribute9
      ,p_mirror_cont_attribute10      =>  p_mirror_cont_attribute10
      ,p_mirror_cont_attribute11      =>  p_mirror_cont_attribute11
      ,p_mirror_cont_attribute12      =>  p_mirror_cont_attribute12
      ,p_mirror_cont_attribute13      =>  p_mirror_cont_attribute13
      ,p_mirror_cont_attribute14      =>  p_mirror_cont_attribute14
      ,p_mirror_cont_attribute15      =>  p_mirror_cont_attribute15
      ,p_mirror_cont_attribute16      =>  p_mirror_cont_attribute16
      ,p_mirror_cont_attribute17      =>  p_mirror_cont_attribute17
      ,p_mirror_cont_attribute18      =>  p_mirror_cont_attribute18
      ,p_mirror_cont_attribute19      =>  p_mirror_cont_attribute19
      ,p_mirror_cont_attribute20      =>  p_mirror_cont_attribute20
      ,p_mirror_cont_information_cat    =>  p_mirror_cont_information_cat
      ,p_mirror_cont_information1       =>  p_mirror_cont_information1
      ,p_mirror_cont_information2       =>  p_mirror_cont_information2
      ,p_mirror_cont_information3       =>  p_mirror_cont_information3
      ,p_mirror_cont_information4       =>  p_mirror_cont_information4
      ,p_mirror_cont_information5       =>  p_mirror_cont_information5
      ,p_mirror_cont_information6       =>  p_mirror_cont_information6
      ,p_mirror_cont_information7       =>  p_mirror_cont_information7
      ,p_mirror_cont_information8       =>  p_mirror_cont_information8
      ,p_mirror_cont_information9       =>  p_mirror_cont_information9
      ,p_mirror_cont_information10      =>  p_mirror_cont_information10
      ,p_mirror_cont_information11      =>  p_mirror_cont_information11
      ,p_mirror_cont_information12      =>  p_mirror_cont_information12
      ,p_mirror_cont_information13      =>  p_mirror_cont_information13
      ,p_mirror_cont_information14      =>  p_mirror_cont_information14
      ,p_mirror_cont_information15      =>  p_mirror_cont_information15
      ,p_mirror_cont_information16      =>  p_mirror_cont_information16
      ,p_mirror_cont_information17      =>  p_mirror_cont_information17
      ,p_mirror_cont_information18      =>  p_mirror_cont_information18
      ,p_mirror_cont_information19      =>  p_mirror_cont_information19
      ,p_mirror_cont_information20      =>  p_mirror_cont_information20
      ,p_contact_relationship_id      =>  l_contact_relationship_id
      ,p_ctr_object_version_number    =>  l_ctr_object_version_number
      ,p_per_person_id                =>  l_contact_person_id
      ,p_per_object_version_number    =>  l_per_object_version_number
      ,p_per_effective_start_date     =>  l_per_effective_start_date
      ,p_per_effective_end_date       =>  l_per_effective_end_date
      ,p_full_name                    =>  l_full_name
      ,p_per_comment_id               =>  l_per_comment_id
      ,p_name_combination_warning     =>  l_name_combination_warning
      ,p_orig_hire_warning            =>  l_orig_hire_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_contact'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_contact
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_contact;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_per_object_version_number  :=  null;
  p_ctr_object_version_number  :=  null;
  p_name_combination_warning   :=  null;
  p_orig_hire_warning          :=  null;
  p_per_person_id              :=  null;
  p_per_effective_start_date   :=  null;
  p_per_effective_end_date     :=  null;
  p_full_name                  :=  null;
  p_per_comment_id             :=  null;
  p_contact_relationship_id    :=  null;

    hr_utility.set_location(' Leaving:'||l_proc, 50);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_contact;
        --
    -- set in out parameters and set out parameters
    --
  p_per_object_version_number  :=  null;
  p_ctr_object_version_number  :=  null;
  p_name_combination_warning   :=  null;
  p_orig_hire_warning          :=  null;
  p_per_person_id              :=  null;
  p_per_effective_start_date   :=  null;
  p_per_effective_end_date     :=  null;
  p_full_name                  :=  null;
  p_per_comment_id             :=  null;
  p_contact_relationship_id    :=  null;
    raise;
    --
    -- End of fix.
    --
end create_contact;
--
-- ----------------------------------------------------------------------------------
-- |----------------------< update_contact_relationship  >--------------------------|
-- ----------------------------------------------------------------------------------
--
procedure update_contact_relationship
  (p_validate                          in        boolean   default false
  ,p_effective_date                    in        date
  ,p_contact_relationship_id           in        number
  ,p_contact_type                      in        varchar2  default hr_api.g_varchar2
  ,p_comments                          in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag              in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag              in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag                   in        varchar2  default hr_api.g_varchar2
  ,p_date_start                        in        date      default hr_api.g_date
  ,p_start_life_reason_id              in        number    default hr_api.g_number
  ,p_date_end                          in        date      default hr_api.g_date
  ,p_end_life_reason_id                in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag       in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                     in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number                   in        number    default hr_api.g_number
  ,p_dependent_flag                    in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category           in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information_category           in        varchar2  default hr_api.g_varchar2
  ,p_cont_information1                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information2                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information3                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information4                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information5                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information6                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information7                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information8                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information9                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information10                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information11                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information12                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information13                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information14                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information15                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information16                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information17                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information18                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information19                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information20                  in        varchar2  default hr_api.g_varchar2
  ,p_object_version_number             in out nocopy    number
  )
is
  --
  -- Declare all out local variables and cursors
  --
  l_proc                            varchar2(72) := g_package||'update_contact';
  --
  l_object_version_number
  per_contact_relationships.object_version_number%TYPE;
  l_ovn 		  	    number;
  l_effective_date                  date;
  l_date_start                      date;
  l_date_end                        date;
  --
  l_mirror_contact_type          varchar2(30);
  l_contact_type                 varchar2(30);
  --
  -- Declare cursor to check that there is a mirror contact
  -- adhunter: 2425534: added extra check on date_start
  --
  cursor check_mirror is
    select pcr2.contact_relationship_id,
           pcr2.object_version_number
    from   per_contact_relationships pcr1,
           per_contact_relationships pcr2
    where pcr2.contact_person_id = pcr1.person_id
      and pcr2.person_id = pcr1.contact_person_id
      and (pcr2.date_start = pcr1.date_start
       or (pcr2.date_start is null and pcr1.date_start is null))
      and pcr1.contact_relationship_id = p_contact_relationship_id
      and pcr2.contact_type = l_mirror_contact_type;
  --
  l_mirror_rec            check_mirror%ROWTYPE;
  --
  cursor get_contact_type is
     select pcr.contact_type,
            pcr.date_start,
            pcr.start_life_reason_id,
            pcr.date_end,
            pcr.end_life_reason_id,
            pcr.rltd_per_rsds_w_dsgntr_flag,
            pcr.personal_flag,
            pcr.contact_person_id
     from   per_contact_relationships pcr
     where  pcr.contact_relationship_id = p_contact_relationship_id;
  --
  l_start_life_reason_id         number;
  l_end_life_reason_id           number;
  l_rltd_per_rsds_w_dsgntr_flag  varchar2(1);
  l_personal_flag                varchar2(1);
  l_contact_person_id            number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  l_ovn := p_object_version_number;
  --
  -- Truncate all date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Issue a savepoint.
  --
  savepoint update_contact_relationship;
  --
  hr_utility.set_location(l_proc, 20);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_contact_relationship
    --
    hr_contact_rel_bk2.update_contact_relationship_b
      (p_effective_date               =>  l_effective_date
      ,p_contact_relationship_id      =>  p_contact_relationship_id
      ,p_contact_type                 =>  p_contact_type
      ,p_comments                     =>  p_comments
      ,p_primary_contact_flag         =>  p_primary_contact_flag
      ,p_third_party_pay_flag         =>  p_third_party_pay_flag
      ,p_bondholder_flag              =>  p_bondholder_flag
      ,p_date_start                   =>  trunc(p_date_start)
      ,p_start_life_reason_id         =>  p_start_life_reason_id
      ,p_date_end                     =>  trunc(p_date_end)
      ,p_end_life_reason_id           =>  p_end_life_reason_id
      ,p_rltd_per_rsds_w_dsgntr_flag  =>  p_rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag                =>  p_personal_flag
      ,p_sequence_number              =>  p_sequence_number
      ,p_dependent_flag               =>  p_dependent_flag
      ,p_beneficiary_flag             =>  p_beneficiary_flag
      ,p_cont_attribute_category      =>  p_cont_attribute_category
      ,p_cont_attribute1              =>  p_cont_attribute1
      ,p_cont_attribute2              =>  p_cont_attribute2
      ,p_cont_attribute3              =>  p_cont_attribute3
      ,p_cont_attribute4              =>  p_cont_attribute4
      ,p_cont_attribute5              =>  p_cont_attribute5
      ,p_cont_attribute6              =>  p_cont_attribute6
      ,p_cont_attribute7              =>  p_cont_attribute7
      ,p_cont_attribute8              =>  p_cont_attribute8
      ,p_cont_attribute9              =>  p_cont_attribute9
      ,p_cont_attribute10             =>  p_cont_attribute10
      ,p_cont_attribute11             =>  p_cont_attribute11
      ,p_cont_attribute12             =>  p_cont_attribute12
      ,p_cont_attribute13             =>  p_cont_attribute13
      ,p_cont_attribute14             =>  p_cont_attribute14
      ,p_cont_attribute15             =>  p_cont_attribute15
      ,p_cont_attribute16             =>  p_cont_attribute16
      ,p_cont_attribute17             =>  p_cont_attribute17
      ,p_cont_attribute18             =>  p_cont_attribute18
      ,p_cont_attribute19             =>  p_cont_attribute19
      ,p_cont_attribute20             =>  p_cont_attribute20
      ,p_cont_information_category      =>  p_cont_information_category
      ,p_cont_information1              =>  p_cont_information1
      ,p_cont_information2              =>  p_cont_information2
      ,p_cont_information3              =>  p_cont_information3
      ,p_cont_information4              =>  p_cont_information4
      ,p_cont_information5              =>  p_cont_information5
      ,p_cont_information6              =>  p_cont_information6
      ,p_cont_information7              =>  p_cont_information7
      ,p_cont_information8              =>  p_cont_information8
      ,p_cont_information9              =>  p_cont_information9
      ,p_cont_information10             =>  p_cont_information10
      ,p_cont_information11             =>  p_cont_information11
      ,p_cont_information12             =>  p_cont_information12
      ,p_cont_information13             =>  p_cont_information13
      ,p_cont_information14             =>  p_cont_information14
      ,p_cont_information15             =>  p_cont_information15
      ,p_cont_information16             =>  p_cont_information16
      ,p_cont_information17             =>  p_cont_information17
      ,p_cont_information18             =>  p_cont_information18
      ,p_cont_information19             =>  p_cont_information19
      ,p_cont_information20             =>  p_cont_information20
      ,p_object_version_number        =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_contact_relationship'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_contact_relationship
    --
  end;
  --
  open get_contact_type;
  fetch get_contact_type into l_contact_type,
                              l_date_start,
                              l_start_life_reason_id,
                              l_date_end,
                              l_end_life_reason_id,
                              l_rltd_per_rsds_w_dsgntr_flag,
                              l_personal_flag,
                              l_contact_person_id;
  close get_contact_type;
  --
  -- Call the update contact relationship row handler
  --
  per_ctr_upd.upd
    (p_validate                    =>  FALSE
    ,p_effective_date              =>  l_effective_date
    ,p_contact_relationship_id     =>  p_contact_relationship_id
    ,p_contact_type                =>  p_contact_type
    ,p_comments                    =>  p_comments
    ,p_primary_contact_flag        =>  p_primary_contact_flag
    ,p_third_party_pay_flag        =>  p_third_party_pay_flag
    ,p_bondholder_flag             =>  p_bondholder_flag
    ,p_date_start                  =>  trunc(p_date_start)
    ,p_start_life_reason_id        =>  p_start_life_reason_id
    ,p_date_end                    =>  trunc(p_date_end)
    ,p_end_life_reason_id          =>  p_end_life_reason_id
    ,p_rltd_per_rsds_w_dsgntr_flag =>  p_rltd_per_rsds_w_dsgntr_flag
    ,p_personal_flag               =>  p_personal_flag
    ,p_sequence_number             =>  p_sequence_number
    ,p_dependent_flag              =>  p_dependent_flag
    ,p_beneficiary_flag            =>  p_beneficiary_flag
    ,p_cont_attribute_category     =>  p_cont_attribute_category
    ,p_cont_attribute1             =>  p_cont_attribute1
    ,p_cont_attribute2             =>  p_cont_attribute2
    ,p_cont_attribute3             =>  p_cont_attribute3
    ,p_cont_attribute4             =>  p_cont_attribute4
    ,p_cont_attribute5             =>  p_cont_attribute5
    ,p_cont_attribute6             =>  p_cont_attribute6
    ,p_cont_attribute7             =>  p_cont_attribute7
    ,p_cont_attribute8             =>  p_cont_attribute8
    ,p_cont_attribute9             =>  p_cont_attribute9
    ,p_cont_attribute10            =>  p_cont_attribute10
    ,p_cont_attribute11            =>  p_cont_attribute11
    ,p_cont_attribute12            =>  p_cont_attribute12
    ,p_cont_attribute13            =>  p_cont_attribute13
    ,p_cont_attribute14            =>  p_cont_attribute14
    ,p_cont_attribute15            =>  p_cont_attribute15
    ,p_cont_attribute16            =>  p_cont_attribute16
    ,p_cont_attribute17            =>  p_cont_attribute17
    ,p_cont_attribute18            =>  p_cont_attribute18
    ,p_cont_attribute19            =>  p_cont_attribute19
    ,p_cont_attribute20            =>  p_cont_attribute20
    ,p_cont_information_category     =>  p_cont_information_category
    ,p_cont_information1             =>  p_cont_information1
    ,p_cont_information2             =>  p_cont_information2
    ,p_cont_information3             =>  p_cont_information3
    ,p_cont_information4             =>  p_cont_information4
    ,p_cont_information5             =>  p_cont_information5
    ,p_cont_information6             =>  p_cont_information6
    ,p_cont_information7             =>  p_cont_information7
    ,p_cont_information8             =>  p_cont_information8
    ,p_cont_information9             =>  p_cont_information9
    ,p_cont_information10            =>  p_cont_information10
    ,p_cont_information11            =>  p_cont_information11
    ,p_cont_information12            =>  p_cont_information12
    ,p_cont_information13            =>  p_cont_information13
    ,p_cont_information14            =>  p_cont_information14
    ,p_cont_information15            =>  p_cont_information15
    ,p_cont_information16            =>  p_cont_information16
    ,p_cont_information17            =>  p_cont_information17
    ,p_cont_information18            =>  p_cont_information18
    ,p_cont_information19            =>  p_cont_information19
    ,p_cont_information20            =>  p_cont_information20
    ,p_object_version_number       =>  p_object_version_number
    );

  hr_utility.set_location(l_proc, 30);
  --
  if ((p_date_start <> hr_api.g_date
    and p_date_start <> nvl(l_date_start,hr_api.g_date))
  or (p_start_life_reason_id <>  hr_api.g_number
    and p_start_life_reason_id <> nvl(l_start_life_reason_id,hr_api.g_number))
  or ((p_date_end <> hr_api.g_date
    and p_date_end <> nvl(l_date_end,hr_api.g_date))
        or p_date_end is null )  --Fix for Bug#8220360
  or (p_end_life_reason_id <> hr_api.g_number
    and p_end_life_reason_id <> nvl(l_end_life_reason_id,hr_api.g_number))
  or (p_rltd_per_rsds_w_dsgntr_flag <> hr_api.g_varchar2
    and p_rltd_per_rsds_w_dsgntr_flag <> nvl(l_rltd_per_rsds_w_dsgntr_flag,hr_api.g_varchar2))
  or (p_personal_flag <> hr_api.g_varchar2
    and p_personal_flag <> nvl(l_personal_flag,hr_api.g_varchar2)))
      and (p_contact_type = hr_api.g_varchar2
      or p_contact_type = l_contact_type)
then
    --
l_mirror_contact_type := per_contact_relationships_pkg.get_mirror_contact_type
                                                           (l_contact_type);
    --
    open check_mirror;
    fetch check_mirror into l_mirror_rec;
    if check_mirror%found then
  --
hr_utility.set_location('id '||l_mirror_rec.contact_relationship_id, 7);
      --
      -- Now update the Mirror Contact by calling the Row Handler.
      --
      per_ctr_upd.upd
        (p_validate                    =>  FALSE
        ,p_effective_date              =>  l_effective_date
        ,p_contact_relationship_id     =>  l_mirror_rec.contact_relationship_id
        ,p_contact_type                =>  l_mirror_contact_type
        ,p_date_start                  =>  p_date_start
        ,p_start_life_reason_id        =>  p_start_life_reason_id
        ,p_date_end                    =>  p_date_end
        ,p_end_life_reason_id          =>  p_end_life_reason_id
        ,p_rltd_per_rsds_w_dsgntr_flag =>  p_rltd_per_rsds_w_dsgntr_flag
        ,p_personal_flag               =>  p_personal_flag
        ,p_object_version_number       =>  l_mirror_rec.object_version_number
        );
    end if;
    close check_mirror;
  end if;
  --
  -- start of code for bug 2678841
  if p_personal_flag <> hr_api.g_varchar2 then
   if p_contact_type=hr_api.g_varchar2 then
    if l_contact_type in ('P','C','S') and
         p_personal_flag <> 'Y' then
           hr_utility.set_message(800,'PER_6994_PERSONAL_FLAG');
           hr_utility.raise_error;
    end if;
   else
     if p_contact_type in ('P','C','S') and
         p_personal_flag <> 'Y' then
       hr_utility.set_message(800,'PER_6994_PERSONAL_FLAG');
       hr_utility.raise_error;
     end if;
   end if;
  end if;
  -- end of code for bug2678841

  -- 1766066: added call for contact start date enh.
  --
  if (p_date_start <> hr_api.g_date
      and p_date_start < l_date_start) then
    per_people12_pkg.maintain_coverage(p_person_id      => l_contact_person_id
                                      ,p_type           => 'CONT'
                                      );
  end if;
  -- 1766066 end.
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_contact_relationship
    --
    hr_contact_rel_bk2.update_contact_relationship_a
      (p_effective_date               =>  l_effective_date
      ,p_contact_relationship_id      =>  p_contact_relationship_id
      ,p_contact_type                 =>  p_contact_type
      ,p_comments                     =>  p_comments
      ,p_primary_contact_flag         =>  p_primary_contact_flag
      ,p_third_party_pay_flag         =>  p_third_party_pay_flag
      ,p_bondholder_flag              =>  p_bondholder_flag
      ,p_date_start                   =>  trunc(p_date_start)
      ,p_start_life_reason_id         =>  p_start_life_reason_id
      ,p_date_end                     =>  trunc(p_date_end)
      ,p_end_life_reason_id           =>  p_end_life_reason_id
      ,p_rltd_per_rsds_w_dsgntr_flag  =>  p_rltd_per_rsds_w_dsgntr_flag
      ,p_personal_flag                =>  p_personal_flag
      ,p_sequence_number              =>  p_sequence_number
      ,p_dependent_flag               =>  p_dependent_flag
      ,p_beneficiary_flag             =>  p_beneficiary_flag
      ,p_cont_attribute_category      =>  p_cont_attribute_category
      ,p_cont_attribute1              =>  p_cont_attribute1
      ,p_cont_attribute2              =>  p_cont_attribute2
      ,p_cont_attribute3              =>  p_cont_attribute3
      ,p_cont_attribute4              =>  p_cont_attribute4
      ,p_cont_attribute5              =>  p_cont_attribute5
      ,p_cont_attribute6              =>  p_cont_attribute6
      ,p_cont_attribute7              =>  p_cont_attribute7
      ,p_cont_attribute8              =>  p_cont_attribute8
      ,p_cont_attribute9              =>  p_cont_attribute9
      ,p_cont_attribute10             =>  p_cont_attribute10
      ,p_cont_attribute11             =>  p_cont_attribute11
      ,p_cont_attribute12             =>  p_cont_attribute12
      ,p_cont_attribute13             =>  p_cont_attribute13
      ,p_cont_attribute14             =>  p_cont_attribute14
      ,p_cont_attribute15             =>  p_cont_attribute15
      ,p_cont_attribute16             =>  p_cont_attribute16
      ,p_cont_attribute17             =>  p_cont_attribute17
      ,p_cont_attribute18             =>  p_cont_attribute18
      ,p_cont_attribute19             =>  p_cont_attribute19
      ,p_cont_attribute20             =>  p_cont_attribute20
      ,p_cont_information_category      =>  p_cont_information_category
      ,p_cont_information1              =>  p_cont_information1
      ,p_cont_information2              =>  p_cont_information2
      ,p_cont_information3              =>  p_cont_information3
      ,p_cont_information4              =>  p_cont_information4
      ,p_cont_information5              =>  p_cont_information5
      ,p_cont_information6              =>  p_cont_information6
      ,p_cont_information7              =>  p_cont_information7
      ,p_cont_information8              =>  p_cont_information8
      ,p_cont_information9              =>  p_cont_information9
      ,p_cont_information10             =>  p_cont_information10
      ,p_cont_information11             =>  p_cont_information11
      ,p_cont_information12             =>  p_cont_information12
      ,p_cont_information13             =>  p_cont_information13
      ,p_cont_information14             =>  p_cont_information14
      ,p_cont_information15             =>  p_cont_information15
      ,p_cont_information16             =>  p_cont_information16
      ,p_cont_information17             =>  p_cont_information17
      ,p_cont_information18             =>  p_cont_information18
      ,p_cont_information19             =>  p_cont_information19
      ,p_cont_information20             =>  p_cont_information20
      ,p_object_version_number        =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_contact_relationship'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the afer hook of update_contact_relationship
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_contact_relationship;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO update_contact_relationship;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
    -- End of fix.
    --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
  --
end update_contact_relationship;
--
--
-- ----------------------------------------------------------------------------------
-- |----------------------< delete_contact_relationship  >--------------------------|
-- ----------------------------------------------------------------------------------
--
procedure delete_contact_relationship
  (p_validate                          in        boolean   default false
  ,p_contact_relationship_id           in        number
  ,p_object_version_number             in        number
  )
is
  --
  -- Declare all out local variables and cursors
  --
  l_proc                            varchar2(72) := g_package||'delete_contact';
  --
  l_object_version_number           number;
  l_mirror_contact_type             varchar2(30);
  -- Declare cursor to check that there is a mirror contact
  --
  cursor check_mirror is
    select pcr2.contact_relationship_id,
           pcr2.object_version_number
    from   per_contact_relationships pcr1,
           per_contact_relationships pcr2
    where pcr2.contact_person_id = pcr1.person_id
      and pcr2.person_id = pcr1.contact_person_id
      and pcr1.contact_relationship_id = p_contact_relationship_id
      and pcr2.contact_type = l_mirror_contact_type   -- bug# 2742210
	--Start bug#8285006
      and (pcr2.date_start = pcr1.date_start
       or (pcr2.date_start is null and pcr1.date_start is null));
	--End bug#8285006


  --
  cursor csr_person_details(p_person_id number) is
	select object_version_number
	      ,effective_start_date
	from  per_all_people_f
	where person_id = p_person_id
	and   effective_end_date = hr_general.end_of_time;
  --
  cursor csr_contact_person is
    select contact_person_id,contact_type
    from per_contact_relationships
    where contact_relationship_id = p_contact_relationship_id;
  --
  l_mirror_rec            check_mirror%ROWTYPE;
  l_effective_start_date date;
  l_effective_end_date date;
  l_per_object_version_number number;
  l_effective_date date;
  l_contact_person_id number;
  l_contact_type      varchar2(30);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Issue a savepoint.
  --
    savepoint delete_contact_relationship;
  --
  hr_utility.set_location(l_proc, 20);
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_contact_relationship
    --
    hr_contact_rel_bk3.delete_contact_relationship_b
      (p_contact_relationship_id           => p_contact_relationship_id
      ,p_object_version_number             => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_contact_relationship'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_contact_relationship
    --
  end;
  -- Derive contact_person_id before row is deleted
  --
  open csr_contact_person;
  fetch csr_contact_person into l_contact_person_id,l_contact_type;
  close csr_contact_person;
     hr_utility.set_location('Contact person id is: ',l_contact_person_id);
  --
  -- If Relationship has a mirror row then then we have to delete the mirror rel.
  -- Have to do this first otherwise the cursor will always fail.
  -- start of code for bug 2742210
  l_mirror_contact_type := per_contact_relationships_pkg.get_mirror_contact_type
                                                           (l_contact_type);
  -- end of code for bug 2742210
  open check_mirror;
  fetch check_mirror into l_mirror_rec;
  if check_mirror%found then
    --
    -- Delete the Mirror Contact by calling the Row Handler.
    --
    per_ctr_del.del
      (p_validate                    =>  FALSE
      ,p_contact_relationship_id     =>  l_mirror_rec.contact_relationship_id
      ,p_object_version_number       =>  l_mirror_rec.object_version_number
      );
    close check_mirror;
  else
    close check_mirror;
  end if;
  --
  -- Call the delete contact relationship row handler
  --
  per_ctr_del.del
    (p_validate                    =>  FALSE
    ,p_contact_relationship_id     =>  p_contact_relationship_id
    ,p_object_version_number       =>  p_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  --Added following for bug 2017198
  --
  --
  if (hr_contact_relationships.contact_only(l_contact_person_id) = 'Y'
     and hr_contact_relationships.multiple_contacts(l_contact_person_id) = 'N') then
     --
     hr_utility.set_location(l_proc, 31);
     --
     per_contact_relationships_pkg.delete_validation
             (l_contact_person_id
             ,p_contact_relationship_id
             );
     -- delete the person
     --
     open csr_person_details(l_contact_person_id);
     fetch csr_person_details
        into  l_per_object_version_number
	      ,l_effective_date;
     close csr_person_details;
     --
     hr_utility.set_location(l_proc, 32);
     --
     per_per_del.del(p_person_id	      => l_contact_person_id
                    ,p_effective_start_date   => l_effective_start_date
                    ,p_effective_end_date     => l_effective_end_date
                    ,p_object_version_number  => l_per_object_version_number
                    ,p_effective_date         => l_effective_date
                    ,p_datetrack_mode         => 'ZAP'
                    ,p_validate               => FALSE
                    );
  end if;
  -- 2017198 end
  --
  hr_utility.set_location(l_proc, 35);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_contact_relationship
    --
    hr_contact_rel_bk3.delete_contact_relationship_a
      (p_contact_relationship_id           => p_contact_relationship_id
      ,p_object_version_number             => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_contact_relationship'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_contact_relationship
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_contact_relationship;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO delete_contact_relationship;
    raise;
    --
    -- End of fix.
    --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
end delete_contact_relationship;
--
end hr_contact_rel_api;

/
