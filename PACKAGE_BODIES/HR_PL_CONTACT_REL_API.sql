--------------------------------------------------------
--  DDL for Package Body HR_PL_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PL_CONTACT_REL_API" as
-- $Header: pecrlpli.pkb 120.1 2005/09/27 03:05:21 mseshadr noship $
--
-- Package Variables

   g_package   VARCHAR2(33);

/*Old procedure,code replaced with call to new procedure*/
PROCEDURE create_pl_contact
  (p_validate                     in        boolean     default false
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
  ,Relationship_Info                in        varchar2    default null
  ,Address_Info                     in        varchar2    default null
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
  ,NIP                            in        varchar2    default null
  ,Insured_by_Employee            in        varchar2
  ,Inheritor                      in        varchar2
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
  ,p_orig_hire_warning            out nocopy boolean) IS

-- Declare cursors and local variables
  --
   l_proc                 varchar2(72);
begin

   g_package := 'hr_pl_contact_rel_api.';
   l_proc    := g_package||'create_pl_contact OLD';
/*
 Code replaced with call to new overloaded procedure
  --
  -- Validation in addition to Row Handlers
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
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

     hr_utility.set_location('Entering:'|| l_proc, 5);
  --


hr_contact_rel_api.create_contact

*/
hr_pl_contact_rel_api.create_pl_contact
 (p_validate                       => p_validate
 ,p_start_date                     =>p_start_date
 ,p_business_group_id              =>p_business_group_id
 ,p_person_id                      =>p_person_id
 ,p_contact_person_id              =>p_contact_person_id
 ,p_contact_type                   =>p_contact_type
 ,p_ctr_comments                   =>p_ctr_comments
 ,p_primary_contact_flag           =>p_primary_contact_flag
 ,p_date_start                     =>p_date_start
 ,p_start_life_reason_id           =>p_start_life_reason_id
 ,p_date_end                       =>p_date_end
 ,p_end_life_reason_id             =>p_end_life_reason_id
 ,p_rltd_per_rsds_w_dsgntr_flag    =>p_rltd_per_rsds_w_dsgntr_flag
 ,p_personal_flag                  =>p_personal_flag
 ,p_sequence_number                =>p_sequence_number
 ,p_cont_attribute_category        =>p_cont_attribute_category
 ,p_cont_attribute1                =>p_cont_attribute1
 ,p_cont_attribute2                =>p_cont_attribute2
 ,p_cont_attribute3                =>p_cont_attribute3
 ,p_cont_attribute4                =>p_cont_attribute4
 ,p_cont_attribute5                =>p_cont_attribute5
 ,p_cont_attribute6                =>p_cont_attribute6
 ,p_cont_attribute7                =>p_cont_attribute7
 ,p_cont_attribute8                =>p_cont_attribute8
 ,p_cont_attribute9                =>p_cont_attribute9
 ,p_cont_attribute10               =>p_cont_attribute10
 ,p_cont_attribute11               =>p_cont_attribute11
 ,p_cont_attribute12               =>p_cont_attribute12
 ,p_cont_attribute13               =>p_cont_attribute13
 ,p_cont_attribute14               =>p_cont_attribute14
 ,p_cont_attribute15               =>p_cont_attribute15
 ,p_cont_attribute16               =>p_cont_attribute16
 ,p_cont_attribute17               =>p_cont_attribute17
 ,p_cont_attribute18               =>p_cont_attribute18
 ,p_cont_attribute19               =>p_cont_attribute19
 ,p_cont_attribute20               =>p_cont_attribute20
 ,p_cont_information_category      =>p_cont_information_category
 ,Relationship_Info                =>Relationship_Info
 ,Address_Info                     =>Address_Info
 ,p_cont_information3              =>p_cont_information3
 ,p_cont_information4              =>p_cont_information4
 ,p_cont_information5              =>p_cont_information5
 ,p_cont_information6              =>p_cont_information6
 ,p_cont_information7              =>p_cont_information7
 ,p_cont_information8              =>p_cont_information8
 ,p_cont_information9              =>p_cont_information9
 ,p_cont_information10             =>p_cont_information10
 ,p_cont_information11             =>p_cont_information11
 ,p_cont_information12             =>p_cont_information12
 ,p_cont_information13             =>p_cont_information13
 ,p_cont_information14             =>p_cont_information14
 ,p_cont_information15             =>p_cont_information15
 ,p_cont_information16             =>p_cont_information16
 ,p_cont_information17             =>p_cont_information17
 ,p_cont_information18             =>p_cont_information18
 ,p_cont_information19             =>p_cont_information19
 ,p_cont_information20             =>p_cont_information20
 ,p_third_party_pay_flag           =>p_third_party_pay_flag
 ,p_bondholder_flag                =>p_bondholder_flag
 ,p_dependent_flag                 =>p_dependent_flag
 ,p_beneficiary_flag               =>p_beneficiary_flag
 ,p_last_name                      =>p_last_name
 ,p_sex                            =>p_sex
 ,p_person_type_id                 =>p_person_type_id
 ,p_per_comments                   =>p_per_comments
 ,p_date_of_birth                  =>p_date_of_birth
 ,p_email_address                  =>p_email_address
 ,p_first_name                     =>p_first_name
 ,p_known_as                       =>p_known_as
 ,p_marital_status                 =>p_marital_status
 ,p_middle_names                   =>p_middle_names
 ,p_nationality                    =>p_nationality
 ,p_pesel                          =>p_national_identifier
 ,p_previous_last_name             =>p_previous_last_name
 ,p_registered_disabled_flag       =>p_registered_disabled_flag
 ,p_title                          =>p_title
 ,p_work_telephone                 =>p_work_telephone
 ,p_attribute_category             =>p_attribute_category
 ,p_attribute1                     =>p_attribute1
 ,p_attribute2                     =>p_attribute2
 ,p_attribute3                     =>p_attribute3
 ,p_attribute4                     =>p_attribute4
 ,p_attribute5                     =>p_attribute5
 ,p_attribute6                     =>p_attribute6
 ,p_attribute7                     =>p_attribute7
 ,p_attribute8                     =>p_attribute8
 ,p_attribute9                     =>p_attribute9
 ,p_attribute10                    =>p_attribute10
 ,p_attribute11                    =>p_attribute11
 ,p_attribute12                    =>p_attribute12
 ,p_attribute13                    =>p_attribute13
 ,p_attribute14                    =>p_attribute14
 ,p_attribute15                    =>p_attribute15
 ,p_attribute16                    =>p_attribute16
 ,p_attribute17                    =>p_attribute17
 ,p_attribute18                    =>p_attribute18
 ,p_attribute19                    =>p_attribute19
 ,p_attribute20                    =>p_attribute20
 ,p_attribute21                    =>p_attribute21
 ,p_attribute22                    =>p_attribute22
 ,p_attribute23                    =>p_attribute23
 ,p_attribute24                    =>p_attribute24
 ,p_attribute25                    =>p_attribute25
 ,p_attribute26                    =>p_attribute26
 ,p_attribute27                    =>p_attribute27
 ,p_attribute28                    =>p_attribute28
 ,p_attribute29                    =>p_attribute29
 ,p_attribute30                    =>p_attribute30
 ,p_per_information_category       =>p_per_information_category
 ,p_nip                            =>NIP
 ,p_insured_by_employee            =>Insured_by_Employee
 ,p_inheritor                      =>Inheritor
 ,p_oldage_pension_rights          =>p_per_information4
 ,p_national_fund_of_health        =>p_per_information5
 ,p_tax_office                     =>p_per_information6
 ,p_legal_employer                 =>p_per_information7
 ,p_citizenship                    =>p_per_information8
 ,p_correspondence_language        =>p_correspondence_language
 ,p_honors                         =>p_honors
 ,p_pre_name_adjunct               =>p_pre_name_adjunct
 ,p_suffix                         =>p_suffix
 ,p_create_mirror_flag             =>p_create_mirror_flag
 ,p_mirror_type                    =>p_mirror_type
 ,p_mirror_cont_attribute_cat      =>p_mirror_cont_attribute_cat
 ,p_mirror_cont_attribute1         =>p_mirror_cont_attribute1
 ,p_mirror_cont_attribute2         =>p_mirror_cont_attribute2
 ,p_mirror_cont_attribute3         =>p_mirror_cont_attribute3
 ,p_mirror_cont_attribute4         =>p_mirror_cont_attribute4
 ,p_mirror_cont_attribute5         =>p_mirror_cont_attribute5
 ,p_mirror_cont_attribute6         =>p_mirror_cont_attribute6
 ,p_mirror_cont_attribute7         =>p_mirror_cont_attribute7
 ,p_mirror_cont_attribute8         =>p_mirror_cont_attribute8
 ,p_mirror_cont_attribute9         =>p_mirror_cont_attribute9
 ,p_mirror_cont_attribute10        =>p_mirror_cont_attribute10
 ,p_mirror_cont_attribute11        =>p_mirror_cont_attribute11
 ,p_mirror_cont_attribute12        =>p_mirror_cont_attribute12
 ,p_mirror_cont_attribute13        =>p_mirror_cont_attribute13
 ,p_mirror_cont_attribute14        =>p_mirror_cont_attribute14
 ,p_mirror_cont_attribute15        =>p_mirror_cont_attribute15
 ,p_mirror_cont_attribute16        =>p_mirror_cont_attribute16
 ,p_mirror_cont_attribute17        =>p_mirror_cont_attribute17
 ,p_mirror_cont_attribute18        =>p_mirror_cont_attribute18
 ,p_mirror_cont_attribute19        =>p_mirror_cont_attribute19
 ,p_mirror_cont_attribute20        =>p_mirror_cont_attribute20
 ,p_mirror_cont_information_cat    =>p_mirror_cont_information_cat
 ,p_mirror_cont_information1       =>p_mirror_cont_information1
 ,p_mirror_cont_information2       =>p_mirror_cont_information2
 ,p_mirror_cont_information3       =>p_mirror_cont_information3
 ,p_mirror_cont_information4       =>p_mirror_cont_information4
 ,p_mirror_cont_information5       =>p_mirror_cont_information5
 ,p_mirror_cont_information6       =>p_mirror_cont_information6
 ,p_mirror_cont_information7       =>p_mirror_cont_information7
 ,p_mirror_cont_information8       =>p_mirror_cont_information8
 ,p_mirror_cont_information9       =>p_mirror_cont_information9
 ,p_mirror_cont_information10      =>p_mirror_cont_information10
 ,p_mirror_cont_information11      =>p_mirror_cont_information11
 ,p_mirror_cont_information12      =>p_mirror_cont_information12
 ,p_mirror_cont_information13      =>p_mirror_cont_information13
 ,p_mirror_cont_information14      =>p_mirror_cont_information14
 ,p_mirror_cont_information15      =>p_mirror_cont_information15
 ,p_mirror_cont_information16      =>p_mirror_cont_information16
 ,p_mirror_cont_information17      =>p_mirror_cont_information17
 ,p_mirror_cont_information18      =>p_mirror_cont_information18
 ,p_mirror_cont_information19      =>p_mirror_cont_information19
 ,p_mirror_cont_information20      =>p_mirror_cont_information20
 ,p_contact_relationship_id        =>p_contact_relationship_id
 ,p_ctr_object_version_number      =>p_ctr_object_version_number
 ,p_per_person_id                  =>p_per_person_id
 ,p_per_object_version_number      =>p_per_object_version_number
 ,p_per_effective_start_date       =>p_per_effective_start_date
 ,p_per_effective_end_date         =>p_per_effective_end_date
 ,p_full_name                      =>p_full_name
 ,p_per_comment_id                 =>p_per_comment_id
 ,p_name_combination_warning       =>p_name_combination_warning
 ,p_orig_hire_warning              =>p_orig_hire_warning
 );



 END create_pl_contact;

/*New overloaded Procedure*/
PROCEDURE create_pl_contact
  (p_validate                     in        boolean     default false
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
  ,Relationship_Info                in        varchar2    default null
  ,Address_Info                     in        varchar2    default null
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
  ,p_last_name                    in        varchar2
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
  ,p_pesel                        in        varchar2    default null
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
  ,p_nip                          in        varchar2    default null
  ,p_insured_by_employee          in        varchar2    default null
  ,p_inheritor                    in        varchar2    default null
  ,p_oldage_pension_rights        in        varchar2    default null
  ,p_national_fund_of_health      in        varchar2    default null
  ,p_tax_office                   in        varchar2    default null
  ,p_legal_employer               in        varchar2    default null
  ,p_citizenship                  in        varchar2    default null
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
  ,p_orig_hire_warning            out nocopy boolean) IS

-- Declare cursors and local variables
  --
   l_proc                 varchar2(72);
   l_legislation_code     varchar2(2);

cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;

begin

   g_package := 'hr_pl_contact_rel_api.';
   l_proc    := g_package||'create_pl_contact';
  --
  -- Validation in addition to Row Handlers
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
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

     hr_utility.set_location('Entering:'|| l_proc, 5);
  --


hr_contact_rel_api.create_contact
(p_validate                             => p_validate
,p_start_date                           => p_start_date
,p_business_group_id                    => p_business_group_id
,p_person_id                            => p_person_id
,p_contact_person_id                    => p_contact_person_id
,p_contact_type                         => p_contact_type
,p_ctr_comments                         => p_ctr_comments
,p_primary_contact_flag                 => p_primary_contact_flag
,p_date_start                           => p_date_start
,p_start_life_reason_id                 => p_start_life_reason_id
,p_date_end                             => p_date_end
,p_end_life_reason_id                   => p_end_life_reason_id
,p_rltd_per_rsds_w_dsgntr_flag          => p_rltd_per_rsds_w_dsgntr_flag
,p_personal_flag                        => p_personal_flag
,p_sequence_number                      => p_sequence_number
,p_cont_attribute_category              => p_cont_attribute_category
,p_cont_attribute1                      => p_cont_attribute1
,p_cont_attribute2                      => p_cont_attribute2
,p_cont_attribute3                      => p_cont_attribute3
,p_cont_attribute4                      => p_cont_attribute4
,p_cont_attribute5                      => p_cont_attribute5
,p_cont_attribute6                      => p_cont_attribute6
,p_cont_attribute7                      => p_cont_attribute7
,p_cont_attribute8                      => p_cont_attribute8
,p_cont_attribute9                      => p_cont_attribute9
,p_cont_attribute10                     => p_cont_attribute10
,p_cont_attribute11                     => p_cont_attribute11
,p_cont_attribute12                     => p_cont_attribute12
,p_cont_attribute13                     => p_cont_attribute13
,p_cont_attribute14                     => p_cont_attribute14
,p_cont_attribute15                     => p_cont_attribute15
,p_cont_attribute16                     => p_cont_attribute16
,p_cont_attribute17                     => p_cont_attribute17
,p_cont_attribute18                     => p_cont_attribute18
,p_cont_attribute19                     => p_cont_attribute19
,p_cont_attribute20                     => p_cont_attribute20
,p_cont_information_category            => p_cont_information_category
,p_cont_information1                    => Relationship_Info
,p_cont_information2                    => Address_Info
,p_cont_information3                    => p_cont_information3
,p_cont_information4                    => p_cont_information4
,p_cont_information5                    => p_cont_information5
,p_cont_information6                    => p_cont_information6
,p_cont_information7                    => p_cont_information7
,p_cont_information8                    => p_cont_information8
,p_cont_information9                    => p_cont_information9
,p_cont_information10                   => p_cont_information10
,p_cont_information11                   => p_cont_information11
,p_cont_information12                   => p_cont_information12
,p_cont_information13                   => p_cont_information13
,p_cont_information14                   => p_cont_information14
,p_cont_information15                   => p_cont_information15
,p_cont_information16                   => p_cont_information16
,p_cont_information17                   => p_cont_information17
,p_cont_information18                   => p_cont_information18
,p_cont_information19                   => p_cont_information19
,p_cont_information20                   => p_cont_information20
,p_third_party_pay_flag                 =>p_third_party_pay_flag
,p_bondholder_flag                      => p_bondholder_flag
,p_dependent_flag                       => p_dependent_flag
,p_beneficiary_flag                     => p_beneficiary_flag
,p_last_name                            => p_last_name
,p_sex                                  => p_sex
,p_person_type_id                       => p_person_type_id
,p_per_comments                         => p_per_comments
,p_date_of_birth                        => p_date_of_birth
,p_email_address                        => p_email_address
,p_first_name                           => p_first_name
,p_known_as                             => p_known_as
,p_marital_status                       => p_marital_status
,p_middle_names                         => p_middle_names
,p_nationality                          => p_nationality
,p_national_identifier                  => p_pesel
,p_previous_last_name                   => p_previous_last_name
,p_registered_disabled_flag             => p_registered_disabled_flag
,p_title                                => p_title
,p_work_telephone                       => p_work_telephone
,p_attribute_category                   => p_attribute_category
,p_attribute1                           => p_attribute1
,p_attribute2                           => p_attribute2
,p_attribute3                           => p_attribute3
,p_attribute4                           => p_attribute4
,p_attribute5                           => p_attribute5
,p_attribute6                           => p_attribute6
,p_attribute7                           => p_attribute7
,p_attribute8                           => p_attribute8
,p_attribute9                           => p_attribute9
,p_attribute10                          => p_attribute10
,p_attribute11                          => p_attribute11
,p_attribute12                          => p_attribute12
,p_attribute13                          => p_attribute13
,p_attribute14                          => p_attribute14
,p_attribute15				=> p_attribute15
,p_attribute16				=> p_attribute16
,p_attribute17				=> p_attribute17
,p_attribute18				=> p_attribute18
,p_attribute19				=> p_attribute19
,p_attribute20				=> p_attribute20
,p_attribute21				=> p_attribute21
,p_attribute22				=> p_attribute22
,p_attribute23				=> p_attribute23
,p_attribute24				=> p_attribute24
,p_attribute25				=> p_attribute25
,p_attribute26				=> p_attribute26
,p_attribute27				=> p_attribute27
,p_attribute28				=> p_attribute28
,p_attribute29				=> p_attribute29
,p_attribute30				=> p_attribute30
,p_per_information_category		=> 'PL'
,p_per_information1			=> p_nip
,p_per_information2			=> p_insured_by_employee
,p_per_information3			=> p_inheritor
,p_per_information4			=> p_oldage_pension_rights
,p_per_information5			=> p_national_fund_of_health
,p_per_information6			=> p_tax_office
,p_per_information7			=> p_legal_employer
,p_per_information8			=> p_citizenship
,p_correspondence_language		=> p_correspondence_language
,p_honors				=> p_honors
,p_pre_name_adjunct			=> p_pre_name_adjunct
,p_suffix				=> p_suffix
,p_create_mirror_flag			=> p_create_mirror_flag
,p_mirror_type				=> p_mirror_type
,p_mirror_cont_attribute_cat		=> p_mirror_cont_attribute_cat
,p_mirror_cont_attribute1		=> p_mirror_cont_attribute1
,p_mirror_cont_attribute2		=> p_mirror_cont_attribute2
,p_mirror_cont_attribute3		=> p_mirror_cont_attribute3
,p_mirror_cont_attribute4		=> p_mirror_cont_attribute4
,p_mirror_cont_attribute5		=> p_mirror_cont_attribute5
,p_mirror_cont_attribute6		=> p_mirror_cont_attribute6
,p_mirror_cont_attribute7		=> p_mirror_cont_attribute7
,p_mirror_cont_attribute8		=> p_mirror_cont_attribute8
,p_mirror_cont_attribute9		=> p_mirror_cont_attribute9
,p_mirror_cont_attribute10		=> p_mirror_cont_attribute10
,p_mirror_cont_attribute11		=> p_mirror_cont_attribute11
,p_mirror_cont_attribute12		=> p_mirror_cont_attribute12
,p_mirror_cont_attribute13		=> p_mirror_cont_attribute13
,p_mirror_cont_attribute14		=> p_mirror_cont_attribute14
,p_mirror_cont_attribute15		=> p_mirror_cont_attribute15
,p_mirror_cont_attribute16		=> p_mirror_cont_attribute16
,p_mirror_cont_attribute17		=> p_mirror_cont_attribute17
,p_mirror_cont_attribute18		=> p_mirror_cont_attribute18
,p_mirror_cont_attribute19		=> p_mirror_cont_attribute19
,p_mirror_cont_attribute20		=> p_mirror_cont_attribute20
,p_mirror_cont_information_cat		=> p_mirror_cont_information_cat
,p_mirror_cont_information1		=> p_mirror_cont_information1
,p_mirror_cont_information2		=> p_mirror_cont_information2
,p_mirror_cont_information3		=> p_mirror_cont_information3
,p_mirror_cont_information4		=> p_mirror_cont_information4
,p_mirror_cont_information5		=> p_mirror_cont_information5
,p_mirror_cont_information6		=> p_mirror_cont_information6
,p_mirror_cont_information7		=> p_mirror_cont_information7
,p_mirror_cont_information8		=> p_mirror_cont_information8
,p_mirror_cont_information9		=> p_mirror_cont_information9
,p_mirror_cont_information10		=> p_mirror_cont_information10
,p_mirror_cont_information11		=> p_mirror_cont_information11
,p_mirror_cont_information12		=> p_mirror_cont_information12
,p_mirror_cont_information13		=> p_mirror_cont_information13
,p_mirror_cont_information14		=> p_mirror_cont_information14
,p_mirror_cont_information15		=> p_mirror_cont_information15
,p_mirror_cont_information16		=> p_mirror_cont_information16
,p_mirror_cont_information17		=> p_mirror_cont_information17
,p_mirror_cont_information18		=> p_mirror_cont_information18
,p_mirror_cont_information19		=> p_mirror_cont_information19
,p_mirror_cont_information20		=> p_mirror_cont_information20
,p_contact_relationship_id		=> p_contact_relationship_id
,p_ctr_object_version_number		=> p_ctr_object_version_number
,p_per_person_id			=> p_per_person_id
,p_per_object_version_number		=> p_per_object_version_number
,p_per_effective_start_date		=> p_per_effective_start_date
,p_per_effective_end_date		=> p_per_effective_end_date
,p_full_name				=> p_full_name
,p_per_comment_id			=> p_per_comment_id
,p_name_combination_warning		=> p_name_combination_warning
,p_orig_hire_warning			=> p_orig_hire_warning);

 END create_pl_contact;




PROCEDURE update_pl_contact_relationship
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
  ,Relationship_Info                     in        varchar2  default hr_api.g_varchar2
  ,Address_Info                          in        varchar2  default hr_api.g_varchar2
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
  ,p_object_version_number             in out nocopy    number) IS


-- Declare cursors and local variables
  --
  l_proc                 varchar2(72);
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id in (select pr.business_group_id
    from  per_contact_relationships pr
    where pr.contact_relationship_id = p_contact_relationship_id);
  --
begin

   g_package := 'hr_pl_contact_rel_api.';
   l_proc    := g_package||'update_pl_contact_relationship';

  --
  -- Validation in addition to Row Handlers
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
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location('Entering:'|| l_proc, 5);



hr_contact_rel_api.update_contact_relationship(
p_validate                             => p_validate
,p_effective_date                       => p_effective_date
,p_contact_relationship_id              => p_contact_relationship_id
,p_contact_type                         => p_contact_type
,p_comments                             => p_comments
,p_primary_contact_flag                 => p_primary_contact_flag
,p_third_party_pay_flag                 => p_third_party_pay_flag
,p_bondholder_flag 			=> p_bondholder_flag
,p_date_start				=> p_date_start
,p_start_life_reason_id                 => p_start_life_reason_id
,p_date_end                             => p_date_end
,p_end_life_reason_id                   => p_end_life_reason_id
,p_rltd_per_rsds_w_dsgntr_flag          => p_rltd_per_rsds_w_dsgntr_flag
,p_personal_flag                        => p_personal_flag
,p_sequence_number                      => p_sequence_number
,p_dependent_flag			=> p_dependent_flag
,p_beneficiary_flag			=> p_beneficiary_flag
,p_cont_attribute_category              => p_cont_attribute_category
,p_cont_attribute1                      => p_cont_attribute1
,p_cont_attribute2                      => p_cont_attribute2
,p_cont_attribute3                      => p_cont_attribute3
,p_cont_attribute4                      => p_cont_attribute4
,p_cont_attribute5                      => p_cont_attribute5
,p_cont_attribute6                      => p_cont_attribute6
,p_cont_attribute7                      => p_cont_attribute7
,p_cont_attribute8                      => p_cont_attribute8
,p_cont_attribute9                      => p_cont_attribute9
,p_cont_attribute10                     => p_cont_attribute10
,p_cont_attribute11                     => p_cont_attribute11
,p_cont_attribute12                     => p_cont_attribute12
,p_cont_attribute13                     => p_cont_attribute13
,p_cont_attribute14                     => p_cont_attribute14
,p_cont_attribute15                     => p_cont_attribute15
,p_cont_attribute16                     => p_cont_attribute16
,p_cont_attribute17                     => p_cont_attribute17
,p_cont_attribute18                     => p_cont_attribute18
,p_cont_attribute19                     => p_cont_attribute19
,p_cont_attribute20                     => p_cont_attribute20
,p_cont_information_category            => p_cont_information_category
,p_cont_information1                    => Relationship_Info
,p_cont_information2                    => Address_Info
,p_cont_information3                    => p_cont_information3
,p_cont_information4                    => p_cont_information4
,p_cont_information5                    => p_cont_information5
,p_cont_information6                    => p_cont_information6
,p_cont_information7                    => p_cont_information7
,p_cont_information8                    => p_cont_information8
,p_cont_information9                    => p_cont_information9
,p_cont_information10                   => p_cont_information10
,p_cont_information11                   => p_cont_information11
,p_cont_information12                   => p_cont_information12
,p_cont_information13                   => p_cont_information13
,p_cont_information14                   => p_cont_information14
,p_cont_information15                   => p_cont_information15
,p_cont_information16                   => p_cont_information16
,p_cont_information17                   => p_cont_information17
,p_cont_information18                   => p_cont_information18
,p_cont_information19                   => p_cont_information19
,p_cont_information20                   => p_cont_information20
,p_object_version_number		=> p_object_version_number);

END UPDATE_PL_CONTACT_RELATIONSHIP;

END HR_PL_CONTACT_REL_API;

/
