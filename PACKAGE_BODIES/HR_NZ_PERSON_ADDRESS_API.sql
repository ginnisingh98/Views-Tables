--------------------------------------------------------
--  DDL for Package Body HR_NZ_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_PERSON_ADDRESS_API" AS
  /* $Header: hrnzwrpa.pkb 120.2 2005/10/05 22:30:39 rpalli noship $ */

  -- Package Variables
  --
  g_package  VARCHAR2(33) := 'hr_nz_person_address_api.';

  --------------------------------------------------------------------------
  -- create_nz_person_address
  --------------------------------------------------------------------------
PROCEDURE create_nz_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  DEFAULT FALSE
  ,p_validate_county               IN     BOOLEAN  DEFAULT TRUE
  ,p_person_id                     IN     NUMBER
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     DEFAULT NULL
  ,p_address_type                  IN     VARCHAR2 DEFAULT NULL
  ,p_comments                      IN     LONG 	   DEFAULT NULL
  ,p_address_line1                 IN     VARCHAR2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT NULL
  ,p_address_line3                 IN     VARCHAR2 DEFAULT NULL
  ,p_town_or_city                  IN     VARCHAR2 DEFAULT NULL
  ,p_region_1                      IN     VARCHAR2 DEFAULT NULL
  ,p_region_2                      IN     VARCHAR2 DEFAULT NULL
  ,p_region_3                      IN     VARCHAR2 DEFAULT NULL
  ,p_postcode                      IN     VARCHAR2 DEFAULT NULL
  ,p_country                       IN     VARCHAR2
  ,p_telephone_number_1            IN     VARCHAR2 DEFAULT NULL
  ,p_telephone_number_2            IN     VARCHAR2 DEFAULT NULL
  ,p_telephone_number_3            IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT NULL
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT NULL
  ,p_add_information13             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information14             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information15             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information16             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information17             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information18             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information19             IN     VARCHAR2 DEFAULT NULL
  ,p_add_information20             IN     VARCHAR2 DEFAULT NULL
  ,p_party_id                      IN     NUMBER   DEFAULT NULL
  ,p_address_id                       OUT NOCOPY NUMBER
  ,p_object_version_number            OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'create_nz_person_address';
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Create Person Address details.
  --
  hr_person_address_api.create_person_address
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_pradd_ovlapval_override       => p_pradd_ovlapval_override
    ,p_validate_county               => p_validate_county
    ,p_person_id                     => p_person_id
    ,p_primary_flag                  => p_primary_flag
    ,p_style                         => 'NZ_GLB'
    ,p_date_from                     => p_date_from
    ,p_date_to                       => p_date_to
    ,p_address_type                  => p_address_type
    ,p_comments                      => p_comments
    ,p_address_line1                 => p_address_line1
    ,p_address_line2                 => p_address_line2
    ,p_address_line3                 => p_address_line3
    ,p_town_or_city                  => p_town_or_city
    ,p_region_1                      => p_region_1
    ,p_region_2                      => p_region_2
    ,p_region_3                      => p_region_3
    ,p_postal_code                   => p_postcode
    ,p_country                       => p_country
    ,p_telephone_number_1            => p_telephone_number_1
    ,p_telephone_number_2            => p_telephone_number_2
    ,p_telephone_number_3            => p_telephone_number_3
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
    ,p_add_information13             => p_add_information13
    ,p_add_information14             =>	p_add_information14
    ,p_add_information15             =>	p_add_information15
    ,p_add_information16             =>	p_add_information16
    ,p_add_information17             =>	p_add_information17
    ,p_add_information18             =>	p_add_information18
    ,p_add_information19             =>	p_add_information19
    ,p_add_information20             =>	p_add_information20
    ,p_party_id                      =>	p_party_id
    ,p_address_id                    => p_address_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END create_nz_person_address;
--

  --------------------------------------------------------------------------
  -- update_nz_person_address
  --------------------------------------------------------------------------
PROCEDURE update_nz_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_validate_county               IN     BOOLEAN  DEFAULT TRUE
  ,p_address_id                    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_date_from                     IN     DATE     DEFAULT hr_api.g_date
  ,p_date_to                       IN     DATE     DEFAULT hr_api.g_date
  ,p_primary_flag                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_address_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comments                      IN     LONG 	   DEFAULT hr_api.g_varchar2
  ,p_address_line1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_address_line3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_town_or_city                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_region_1                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_region_2                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_region_3                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_postcode                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_country                       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_telephone_number_1            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_telephone_number_2            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_telephone_number_3            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information13             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information14             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information15             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information16             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information17             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information18             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information19             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_add_information20             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_party_id                      IN     NUMBER   DEFAULT hr_api.g_number
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'update_nz_person_address';
  l_style               per_addresses.style%TYPE;
  --
  CURSOR csr_add_style IS
  SELECT addr.style
  FROM per_addresses addr
  WHERE addr.address_id = p_address_id;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check that the Address identified is NZ style.
  --
  OPEN  csr_add_style;
  FETCH csr_add_style INTO l_style;
  IF (csr_add_style%NOTFOUND)
  THEN
      CLOSE csr_add_style;
    --
    hr_utility.set_location(l_proc, 7);
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
    --
  ELSE
    --
    CLOSE csr_add_style;
    --
    IF (l_style <> 'NZ_GLB') THEN
      --
      hr_utility.set_location(l_proc, 8);
      --
      hr_utility.set_message(801, 'HR_7788_ADD_INV_NOT_NZ_STYLE');
      hr_utility.raise_error;
      --
    END IF;
  END IF;
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Update Person Address details.
  --
  hr_person_address_api.update_person_address
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_validate_county              => p_validate_county
    ,p_address_id                   => p_address_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_primary_flag                 => p_primary_flag
    ,p_address_type                 => p_address_type
    ,p_comments                     => p_comments
    ,p_address_line1                => p_address_line1
    ,p_address_line2                => p_address_line2
    ,p_address_line3                => p_address_line3
    ,p_town_or_city                 => p_town_or_city
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_postal_code                  => p_postcode
    ,p_country                      => p_country
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    ,p_add_information13            => p_add_information13
    ,p_add_information14            => p_add_information14
    ,p_add_information15            => p_add_information15
    ,p_add_information16            => p_add_information16
    ,p_add_information17            => p_add_information17
    ,p_add_information18            => p_add_information18
    ,p_add_information19            => p_add_information19
    ,p_add_information20            => p_add_information20
    ,p_party_id                     => p_party_id
    );
  hr_utility.set_location(' Leaving:'||l_proc, 11);
  END update_nz_person_address;

END hr_nz_person_address_api;

/
