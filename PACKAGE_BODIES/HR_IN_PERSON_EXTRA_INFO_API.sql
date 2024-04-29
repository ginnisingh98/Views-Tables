--------------------------------------------------------
--  DDL for Package Body HR_IN_PERSON_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_PERSON_EXTRA_INFO_API" AS
/* $Header: pepeiini.pkb 120.0 2005/05/31 13:20 appldev noship $ */
g_package  VARCHAR2(33) := 'hr_in_person_extra_info_api.';
g_trace BOOLEAN ;

-- ----------------------------------------------------------------------------
-- |-----------------------------< check_person >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_person (p_person_id         IN NUMBER
                       ,p_legislation_code  IN VARCHAR2
                        )
IS
   l_legislation_code    per_business_groups.legislation_code%type;
   --
  cursor check_legislation(p_person_id      per_people_f.person_id%TYPE) IS
          select business_group_id
            from per_people_f
           where person_id  = p_person_id;

BEGIN

  OPEN check_legislation(p_person_id);
  FETCH check_legislation into l_legislation_code;

  IF check_legislation%notfound THEN
    CLOSE check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;

  CLOSE check_legislation;

  IF  hr_general2.IS_BG(l_legislation_code ,p_legislation_code) = false THEN
    hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;

END check_person;

-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------

procedure create_in_person_extra_info
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_id                     IN     NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default null
  ,p_pei_attribute1                IN     VARCHAR2 default null
  ,p_pei_attribute2                IN     VARCHAR2 default null
  ,p_pei_attribute3                IN     VARCHAR2 default null
  ,p_pei_attribute4                IN     VARCHAR2 default null
  ,p_pei_attribute5                IN     VARCHAR2 default null
  ,p_pei_attribute6                IN     VARCHAR2 default null
  ,p_pei_attribute7                IN     VARCHAR2 default null
  ,p_pei_attribute8                IN     VARCHAR2 default null
  ,p_pei_attribute9                IN     VARCHAR2 default null
  ,p_pei_attribute10               IN     VARCHAR2 default null
  ,p_pei_attribute11               IN     VARCHAR2 default null
  ,p_pei_attribute12               IN     VARCHAR2 default null
  ,p_pei_attribute13               IN     VARCHAR2 default null
  ,p_pei_attribute14               IN     VARCHAR2 default null
  ,p_pei_attribute15               IN     VARCHAR2 default null
  ,p_pei_attribute16               IN     VARCHAR2 default null
  ,p_pei_attribute17               IN     VARCHAR2 default null
  ,p_pei_attribute18               IN     VARCHAR2 default null
  ,p_pei_attribute19               IN     VARCHAR2 default null
  ,p_pei_attribute20               IN     VARCHAR2 default null
  ,p_religion                      IN     VARCHAR2 default null
  ,p_community                     IN     VARCHAR2 default null
  ,p_caste_or_tribe                IN     VARCHAR2 default null
  ,p_height                        IN     VARCHAR2 default null
  ,p_weight                        IN     VARCHAR2 default null
  ,p_person_extra_info_id          OUT NOCOPY NUMBER
  ,p_object_version_number         OUT NOCOPY NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc   VARCHAR2(72);
  --
BEGIN

 l_proc  := g_package||'create_in_person_extra_info';
 g_trace := hr_utility.debug_enabled ;
  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 10);
  END IF;

   check_person (p_person_id, 'IN');

  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 20);
  END IF;

    hr_person_extra_info_api.create_person_extra_info
     (p_person_id                  => p_person_id,
      p_information_type           => 'IN_MISCELLANEOUS', --Bugfix 3762728
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11	           => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => 'IN_MISCELLANEOUS',
      p_pei_information1           => p_religion,
      p_pei_information2           => p_community,
      p_pei_information3           => p_caste_or_tribe,
      p_pei_information4           => p_height,
      p_pei_information5           => p_weight,
      p_object_version_number      => p_object_version_number,
      p_validate                   => p_validate,
      p_person_extra_info_id       => p_person_extra_info_id);

    IF g_trace THEN
      hr_utility.set_location('Leaving:'|| l_proc, 30);
    END IF;

END create_in_person_extra_info;

-- ----------------------------------------------------------------------------
-- |-----------------------< update_in_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------

procedure update_in_person_extra_info
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_extra_info_id          IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute1                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute2                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute3                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute4                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute5                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute6                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute7                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute8                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute9                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute10               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute11               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute12               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute13               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute14               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute15               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute16               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute17               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute18               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute19               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute20               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_religion                      IN     VARCHAR2 default hr_api.g_varchar2
  ,p_community                     IN     VARCHAR2 default hr_api.g_varchar2
  ,p_caste_or_tribe                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_height                        IN     VARCHAR2 default hr_api.g_varchar2
  ,p_weight                        IN     VARCHAR2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc   varchar2(72);

begin

  l_proc  := g_package||'update_person_extra_info';
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 10);
  END IF;

    hr_person_extra_info_api.update_person_extra_info
     (p_validate                   => p_validate,
      p_person_extra_info_id       => p_person_extra_info_id,
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11            => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => 'IN_MISCELLANEOUS',
      p_pei_information1           => p_religion,
      p_pei_information2           => p_community,
      p_pei_information3           => p_caste_or_tribe,
      p_pei_information4           => p_height,
      p_pei_information5           => p_weight,
      p_object_version_number      => p_object_version_number
      );

    IF g_trace THEN
      hr_utility.set_location('Leaving:'|| l_proc, 20);
    END IF;

END update_in_person_extra_info;

-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_passport_details >-----------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_in_passport_details
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_id                     IN     NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default null
  ,p_pei_attribute1                IN     VARCHAR2 default null
  ,p_pei_attribute2                IN     VARCHAR2 default null
  ,p_pei_attribute3                IN     VARCHAR2 default null
  ,p_pei_attribute4                IN     VARCHAR2 default null
  ,p_pei_attribute5                IN     VARCHAR2 default null
  ,p_pei_attribute6                IN     VARCHAR2 default null
  ,p_pei_attribute7                IN     VARCHAR2 default null
  ,p_pei_attribute8                IN     VARCHAR2 default null
  ,p_pei_attribute9                IN     VARCHAR2 default null
  ,p_pei_attribute10               IN     VARCHAR2 default null
  ,p_pei_attribute11               IN     VARCHAR2 default null
  ,p_pei_attribute12               IN     VARCHAR2 default null
  ,p_pei_attribute13               IN     VARCHAR2 default null
  ,p_pei_attribute14               IN     VARCHAR2 default null
  ,p_pei_attribute15               IN     VARCHAR2 default null
  ,p_pei_attribute16               IN     VARCHAR2 default null
  ,p_pei_attribute17               IN     VARCHAR2 default null
  ,p_pei_attribute18               IN     VARCHAR2 default null
  ,p_pei_attribute19               IN     VARCHAR2 default null
  ,p_pei_attribute20               IN     VARCHAR2 default null
  ,p_passport_name                 IN     VARCHAR2
  ,p_passport_number               IN     VARCHAR2
  ,p_place_of_issue                IN     VARCHAR2
  ,p_issue_date                    IN     VARCHAR2
  ,p_expiry_date                   IN     VARCHAR2
  ,p_ecnr_required                 IN     VARCHAR2
  ,p_issuing_country               IN     VARCHAR2
  ,p_person_extra_info_id          OUT NOCOPY NUMBER
  ,p_object_version_number         OUT NOCOPY NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc   VARCHAR2(72);
  --
BEGIN

 l_proc  := g_package||'create_in_passport_details';
 g_trace := hr_utility.debug_enabled ;
  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 10);
  END IF;

   check_person (p_person_id, 'IN');

  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 20);
  END IF;

    hr_person_extra_info_api.create_person_extra_info
     (p_person_id                  => p_person_id,
      p_information_type           => 'IN_PASSPORT_DETAILS', --Bugfix 3762728
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11	           => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => 'IN_PASSPORT_DETAILS',
      p_pei_information1           => p_passport_name,
      p_pei_information2           => p_passport_number,
      p_pei_information3           => p_place_of_issue,
      p_pei_information4           => p_issue_date,
      p_pei_information5           => p_expiry_date,
      p_pei_information6           => p_ecnr_required,
      p_pei_information7           => p_issuing_country,
      p_object_version_number      => p_object_version_number,
      p_validate                   => p_validate,
      p_person_extra_info_id       => p_person_extra_info_id);

    IF g_trace THEN
      hr_utility.set_location('Leaving:'|| l_proc, 30);
    END IF;
  END create_in_passport_details;

-- ----------------------------------------------------------------------------
-- |-----------------------< update_in_passport_details >------------------------|
-- ----------------------------------------------------------------------------

  PROCEDURE update_in_passport_details
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_extra_info_id          IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute1                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute2                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute3                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute4                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute5                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute6                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute7                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute8                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute9                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute10               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute11               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute12               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute13               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute14               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute15               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute16               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute17               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute18               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute19               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute20               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_passport_name                 IN     VARCHAR2 default hr_api.g_varchar2
  ,p_passport_number               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_place_of_issue                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_issue_date                    IN     VARCHAR2 default hr_api.g_varchar2
  ,p_expiry_date                   IN     VARCHAR2 default hr_api.g_varchar2
  ,p_ecnr_required                 IN     VARCHAR2 default hr_api.g_varchar2
  ,p_issuing_country               IN     VARCHAR2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc   varchar2(72);

begin

  l_proc  := g_package||'update_passport_details';
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering:'|| l_proc, 10);
  END IF;

    hr_person_extra_info_api.update_person_extra_info
     (p_validate                   => p_validate,
      p_person_extra_info_id       => p_person_extra_info_id,
      p_pei_attribute_category     => p_pei_attribute_category,
      p_pei_attribute1             => p_pei_attribute1,
      p_pei_attribute2             => p_pei_attribute2,
      p_pei_attribute3             => p_pei_attribute3,
      p_pei_attribute4             => p_pei_attribute4,
      p_pei_attribute5             => p_pei_attribute5,
      p_pei_attribute6             => p_pei_attribute6,
      p_pei_attribute7             => p_pei_attribute7,
      p_pei_attribute8             => p_pei_attribute8,
      p_pei_attribute9             => p_pei_attribute9,
      p_pei_attribute10            => p_pei_attribute10,
      p_pei_attribute11            => p_pei_attribute11,
      p_pei_attribute12            => p_pei_attribute12,
      p_pei_attribute13            => p_pei_attribute13,
      p_pei_attribute14            => p_pei_attribute14,
      p_pei_attribute15            => p_pei_attribute15,
      p_pei_attribute16            => p_pei_attribute16,
      p_pei_attribute17            => p_pei_attribute17,
      p_pei_attribute18            => p_pei_attribute18,
      p_pei_attribute19            => p_pei_attribute19,
      p_pei_attribute20            => p_pei_attribute20,
      p_pei_information_category   => 'IN_PASSPORT_DETAILS',
      p_pei_information1           => p_passport_name,
      p_pei_information2           => p_passport_number,
      p_pei_information3           => p_place_of_issue,
      p_pei_information4           => p_issue_date,
      p_pei_information5           => p_expiry_date,
      p_pei_information6           => p_ecnr_required,
      p_pei_information7           => p_issuing_country,
      p_object_version_number      => p_object_version_number
      );

    IF g_trace THEN
      hr_utility.set_location('Leaving:'|| l_proc, 20);
    END IF;
  END update_in_passport_details;
END hr_in_person_extra_info_api;

/
