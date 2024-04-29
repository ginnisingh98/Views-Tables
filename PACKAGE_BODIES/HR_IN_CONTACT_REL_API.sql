--------------------------------------------------------
--  DDL for Package Body HR_IN_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_CONTACT_REL_API" AS
/* $Header: pecrlini.pkb 120.0 2005/05/31 07:17 appldev noship $ */
g_package  VARCHAR2(33) := 'hr_in_contact_rel_api.';
g_trace boolean ;

-- ----------------------------------------------------------------------------------
-- |---------------------------< create_in_contact  >----------------------------------|
-- ----------------------------------------------------------------------------------
PROCEDURE create_in_contact
  (p_validate                     IN        BOOLEAN     default false
  ,p_start_date                   IN        date
  ,p_business_group_id            IN        NUMBER
  ,p_person_id                    IN        NUMBER
  ,p_contact_person_id            IN        NUMBER      default null
  ,p_contact_type                 IN        VARCHAR2
  ,p_ctr_comments                 IN        VARCHAR2    default null
  ,p_primary_contact_flag         IN        VARCHAR2    default 'N'
  ,p_date_start                   IN        date        default null
  ,p_start_life_reason_id         IN        NUMBER      default null
  ,p_date_end                     IN        date        default null
  ,p_end_life_reason_id           IN        NUMBER      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  IN        VARCHAR2    default 'N'
  ,p_personal_flag                IN        VARCHAR2    default 'N'
  ,p_sequence_number              IN        NUMBER      default null
  ,p_cont_attribute_category      IN        VARCHAR2    default null
  ,p_cont_attribute1              IN        VARCHAR2    default null
  ,p_cont_attribute2              IN        VARCHAR2    default null
  ,p_cont_attribute3              IN        VARCHAR2    default null
  ,p_cont_attribute4              IN        VARCHAR2    default null
  ,p_cont_attribute5              IN        VARCHAR2    default null
  ,p_cont_attribute6              IN        VARCHAR2    default null
  ,p_cont_attribute7              IN        VARCHAR2    default null
  ,p_cont_attribute8              IN        VARCHAR2    default null
  ,p_cont_attribute9              IN        VARCHAR2    default null
  ,p_cont_attribute10             IN        VARCHAR2    default null
  ,p_cont_attribute11             IN        VARCHAR2    default null
  ,p_cont_attribute12             IN        VARCHAR2    default null
  ,p_cont_attribute13             IN        VARCHAR2    default null
  ,p_cont_attribute14             IN        VARCHAR2    default null
  ,p_cont_attribute15             IN        VARCHAR2    default null
  ,p_cont_attribute16             IN        VARCHAR2    default null
  ,p_cont_attribute17             IN        VARCHAR2    default null
  ,p_cont_attribute18             IN        VARCHAR2    default null
  ,p_cont_attribute19             IN        VARCHAR2    default null
  ,p_cont_attribute20             IN        VARCHAR2    default null
  ,p_guardian_name                IN        VARCHAR2    default null
  ,p_guardian_birth_date          IN        VARCHAR2    default null
  ,p_guardian_address             IN        VARCHAR2    default null
  ,p_guardian_telephone           IN        VARCHAR2    default null
  ,p_third_party_pay_flag         IN        VARCHAR2    default 'N'
  ,p_bondholder_flag              IN        VARCHAR2    default 'N'
  ,p_dependent_flag               IN        VARCHAR2    default 'N'
  ,p_beneficiary_flag             IN        VARCHAR2    default 'N'
  ,p_last_name                    IN        VARCHAR2    default null
  ,p_sex                          IN        VARCHAR2    default null
  ,p_person_type_id               IN        NUMBER      default null
  ,p_per_comments                 IN        VARCHAR2    default null
  ,p_date_of_birth                IN        date        default null
  ,p_email_address                IN        VARCHAR2    default null
  ,p_first_name                   IN        VARCHAR2    default null
  ,p_alias_name                   IN        VARCHAR2    default null -- Bugfix 3762728
  ,p_marital_status               IN        VARCHAR2    default null
  ,p_middle_names                 IN        VARCHAR2    default null
  ,p_nationality                  IN        VARCHAR2    default null
  ,p_national_identifier          IN        VARCHAR2    default null
  ,p_previous_last_name           IN        VARCHAR2    default null
  ,p_registered_disabled_flag     IN        VARCHAR2    default null
  ,p_title                        IN        VARCHAR2    default null
  ,p_work_telephone               IN        VARCHAR2    default null
  ,p_attribute_category           IN        VARCHAR2    default null
  ,p_attribute1                   IN        VARCHAR2    default null
  ,p_attribute2                   IN        VARCHAR2    default null
  ,p_attribute3                   IN        VARCHAR2    default null
  ,p_attribute4                   IN        VARCHAR2    default null
  ,p_attribute5                   IN        VARCHAR2    default null
  ,p_attribute6                   IN        VARCHAR2    default null
  ,p_attribute7                   IN        VARCHAR2    default null
  ,p_attribute8                   IN        VARCHAR2    default null
  ,p_attribute9                   IN        VARCHAR2    default null
  ,p_attribute10                  IN        VARCHAR2    default null
  ,p_attribute11                  IN        VARCHAR2    default null
  ,p_attribute12                  IN        VARCHAR2    default null
  ,p_attribute13                  IN        VARCHAR2    default null
  ,p_attribute14                  IN        VARCHAR2    default null
  ,p_attribute15                  IN        VARCHAR2    default null
  ,p_attribute16                  IN        VARCHAR2    default null
  ,p_attribute17                  IN        VARCHAR2    default null
  ,p_attribute18                  IN        VARCHAR2    default null
  ,p_attribute19                  IN        VARCHAR2    default null
  ,p_attribute20                  IN        VARCHAR2    default null
  ,p_attribute21                  IN        VARCHAR2    default null
  ,p_attribute22                  IN        VARCHAR2    default null
  ,p_attribute23                  IN        VARCHAR2    default null
  ,p_attribute24                  IN        VARCHAR2    default null
  ,p_attribute25                  IN        VARCHAR2    default null
  ,p_attribute26                  IN        VARCHAR2    default null
  ,p_attribute27                  IN        VARCHAR2    default null
  ,p_attribute28                  IN        VARCHAR2    default null
  ,p_attribute29                  IN        VARCHAR2    default null
  ,p_attribute30                  IN        VARCHAR2    default null
  ,p_resident_status              IN        VARCHAR2    DEFAULT null
  ,p_correspondence_language      IN        VARCHAR2    default null
  ,p_honors                       IN        VARCHAR2    default null
  ,p_pre_name_adjunct             IN        VARCHAR2    default null
  ,p_suffix                       IN        VARCHAR2    default null
  ,p_create_mirror_flag           IN        VARCHAR2    default 'N'
  ,p_mirror_type                  IN        VARCHAR2    default null
  ,p_mirror_cont_attribute_cat    IN        VARCHAR2    default null
  ,p_mirror_cont_attribute1       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute2       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute3       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute4       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute5       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute6       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute7       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute8       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute9       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute10      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute11      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute12      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute13      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute14      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute15      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute16      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute17      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute18      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute19      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute20      IN        VARCHAR2    default null
  ,p_contact_relationship_id      OUT NOCOPY NUMBER
  ,p_ctr_object_version_number    OUT NOCOPY NUMBER
  ,p_per_person_id                OUT NOCOPY NUMBER
  ,p_per_object_version_number    OUT NOCOPY NUMBER
  ,p_per_effective_start_date     OUT NOCOPY DATE
  ,p_per_effective_end_date       OUT NOCOPY DATE
  ,p_full_name                    OUT NOCOPY VARCHAR2
  ,p_per_comment_id               OUT NOCOPY NUMBER
  ,p_name_combination_warning     OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning            OUT NOCOPY BOOLEAN
  )
AS
--
-- Declare cursors and local variables
--
  l_proc  VARCHAR2(72);
BEGIN
  l_proc := g_package||'create_in_contact';
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  IF  hr_general2.IS_BG(p_business_group_id, 'IN') = false THEN
   hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
   hr_utility.raise_error;
  END IF;

  IF g_trace THEN
    hr_utility.set_location(l_proc, 20);
  END IF ;
  --
  --
  --
   hr_contact_rel_api.create_contact
      (p_validate                     => p_validate
      ,p_person_id                    =>  p_person_id
      ,p_start_date	              =>  p_start_date
      ,p_business_group_id            =>  p_business_group_id
      ,p_contact_person_id            =>  p_contact_person_id
      ,p_contact_type                 =>  p_contact_type
      ,p_ctr_comments                 =>  p_ctr_comments
      ,p_primary_contact_flag         =>  p_primary_contact_flag
      ,p_date_start                   =>  p_date_start
      ,p_start_life_reason_id         =>  p_start_life_reason_id
      ,p_date_end                     =>  p_date_end
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
      ,p_cont_information_category    =>  'IN'
      ,p_cont_information13           =>  p_guardian_name
      ,p_cont_information14           =>  p_guardian_birth_date
      ,p_cont_information15           =>  p_guardian_address
      ,p_cont_information17           =>  p_guardian_telephone
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
      ,p_known_as                     =>  p_alias_name  -- Bugfix 3762728
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
      ,p_per_information_category     =>  'IN'
      ,p_per_information7             =>  p_resident_status
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
      ,p_contact_relationship_id        =>p_contact_relationship_id
      ,p_ctr_object_version_number      =>p_ctr_object_version_number
      ,p_per_person_id                  =>p_per_person_id
      ,p_per_object_version_number      =>p_per_object_version_number
      ,p_per_effective_start_date       =>p_per_effective_start_date
      ,p_per_effective_end_date         =>p_per_effective_end_date
      ,p_full_name                      =>p_full_name
      ,p_per_comment_id                 =>p_per_comment_id
      ,p_name_combination_warning       =>p_name_combination_warning
      ,p_orig_hire_warning              =>p_orig_hire_warning );
      if g_trace then
        hr_utility.set_location('Leaving: '||l_proc, 30);
      end if ;
    END create_in_contact;

-- ----------------------------------------------------------------------------------
-- |----------------------< update_in_contact_relationship  >--------------------------|
-- ----------------------------------------------------------------------------------

PROCEDURE update_in_contact_relationship
  (p_validate                          IN        BOOLEAN   default false
  ,p_effective_date                    IN        DATE
  ,p_contact_relationship_id           IN        NUMBER
  ,p_contact_type                      IN        VARCHAR2  default hr_api.g_varchar2
  ,p_comments                          IN        LONG      default hr_api.g_varchar2
  ,p_primary_contact_flag              IN        VARCHAR2  default hr_api.g_varchar2
  ,p_third_party_pay_flag              IN        VARCHAR2  default hr_api.g_varchar2
  ,p_bondholder_flag                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_date_start                        IN        DATE      default hr_api.g_date
  ,p_start_life_reason_id              IN        NUMBER    default hr_api.g_number
  ,p_date_end                          IN        DATE      default hr_api.g_date
  ,p_end_life_reason_id                IN        NUMBER    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag       IN        VARCHAR2  default hr_api.g_varchar2
  ,p_personal_flag                     IN        VARCHAR2  default hr_api.g_varchar2
  ,p_sequence_number                   IN        NUMBER    default hr_api.g_number
  ,p_dependent_flag                    IN        VARCHAR2  default hr_api.g_varchar2
  ,p_beneficiary_flag                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute_category           IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute1                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute2                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute3                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute4                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute5                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute6                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute7                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute8                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute9                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute10                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute11                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute12                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute13                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute14                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute15                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute16                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute17                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute18                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute19                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute20                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_name                     IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_birth_date               IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_address                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_telephone                IN        VARCHAR2  default hr_api.g_varchar2
  ,p_object_version_number             IN OUT NOCOPY    number
  )
AS
--
-- Declare cursors and local variables
--
  l_proc  VARCHAR2(72);
BEGIN
   l_proc := g_package||'update_in_contact_relationship';
  g_trace := hr_utility.debug_enabled ;
  if g_trace then
    hr_utility.set_location('Entering: '||l_proc, 10);
  end if ;
  --
  --
  --
   hr_contact_rel_api.update_contact_relationship(
       p_effective_date               =>  p_effective_date
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
      ,p_cont_information_category    =>  'IN'
      ,p_cont_information13           =>  p_guardian_name
      ,p_cont_information14           =>  p_guardian_birth_date
      ,p_cont_information15           =>  p_guardian_address
      ,p_cont_information17           =>  p_guardian_telephone
      ,p_object_version_number        =>  p_object_version_number
      );
      if g_trace then
        hr_utility.set_location('Leaving: '||l_proc, 20);
      end if ;
    END update_in_contact_relationship;
   --
    END hr_in_contact_rel_api;

/
