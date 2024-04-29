--------------------------------------------------------
--  DDL for Package Body HR_CN_PERSON_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CN_PERSON_ADDRESS_API" AS
/* $Header: hrcnwrpa.pkb 115.2 2003/04/09 13:24:02 bramajey noship $ */

    g_package  varchar2(33) := 'hr_cn_person_address_api.';


-- ----------------------------------------------------------------------------
-- |------------------------< create_cn_person_address >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a new address, for a particular person.
--
--   If creating the first address for the specified person, then it must be
--   the primary address. As one and only one primary address can exist at
--   any given time for a person, any subsequent addresses must not be
--   primary.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist on the start date (p_date_from)
--   of the address.
--
--   The address_type attribute can only be used after QuickCodes have been
--   defined for the 'ADDRESS_TYPE' lookup type.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the address is created.
--   p_effective_date               Yes  date     Effective date.
--   p_validate_county                   boolean  set to true.
--   p_person_id                         number   Person for whom the address
--                                                applies.
--   p_primary_flag                 Yes  varchar2 Identifies the primary
--                                                address.
--   p_date_from                    Yes  date     The date from which the
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                Yes  varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_province_city_sar            Yes  varchar2 province/city.
--   p_postal_code                       varchar2 Determined by p_style
--                                                (eg. Postcode for CN).
--   p_country                      Yes  varchar2 Country.
--   p_telephone                         varchar2 Telephone number.
--   p_fax                               varchar2 Fax number.
--   p_addr_attribute_category           varchar2 Determines context of the
--                                                addr_attribute Descriptive
--                                                flexfield in parameters.
--   p_addr_attribute1                   varchar2 Descriptive flexfield.
--   p_addr_attribute2                   varchar2 Descriptive flexfield.
--   p_addr_attribute3                   varchar2 Descriptive flexfield.
--   p_addr_attribute4                   varchar2 Descriptive flexfield.
--   p_addr_attribute5                   varchar2 Descriptive flexfield.
--   p_addr_attribute6                   varchar2 Descriptive flexfield.
--   p_addr_attribute7                   varchar2 Descriptive flexfield.
--   p_addr_attribute8                   varchar2 Descriptive flexfield.
--   p_addr_attribute9                   varchar2 Descriptive flexfield.
--   p_addr_attribute10                  varchar2 Descriptive flexfield.
--   p_addr_attribute11                  varchar2 Descriptive flexfield.
--   p_addr_attribute12                  varchar2 Descriptive flexfield.
--   p_addr_attribute13                  varchar2 Descriptive flexfield.
--   p_addr_attribute14                  varchar2 Descriptive flexfield.
--   p_addr_attribute15                  varchar2 Descriptive flexfield.
--   p_addr_attribute16                  varchar2 Descriptive flexfield.
--   p_addr_attribute17                  varchar2 Descriptive flexfield.
--   p_addr_attribute18                  varchar2 Descriptive flexfield.
--   p_addr_attribute19                  varchar2 Descriptive flexfield.
--   p_addr_attribute20                  varchar2 Descriptive flexfield.
--   p_add_information13                 varchar2 Descriptive flexfield.
--   p_add_information14                 varchar2 Descriptive flexfield.
--   p_add_information15                 varchar2 Descriptive flexfield.
--   p_add_information16                 varchar2 Descriptive flexfield.
--   p_add_information17                 varchar2 Tax Address State.
--   p_add_information18                 varchar2 Tax Address City.
--   p_add_information19                 varchar2 Tax Address County.
--   p_add_information20                 varchar2 Tax Address Zip.
--   p_party_id                          number   Party for whom the address --HR/TCA merge
--                                                applies.
--
-- Post Success:
--   When the address is valid, the API sets the following out parameters.
--
--   Name                           Type     Description
--   p_address_id                   number   If p_validate is false, uniquely
--                                           identifies the address created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           address. If p_validate is true,
--                                           set to null.
--
-- Post Failure:
--   The API does not create the address and raises an error.
--
-- Access Status:
--   Public.
-- {End Of Comments}
--

PROCEDURE create_cn_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT   false
  ,p_effective_date                IN     DATE
  ,p_pradd_ovlapval_override       IN     BOOLEAN  DEFAULT   false
  ,p_validate_county               IN     BOOLEAN  DEFAULT   true
  ,p_person_id                     IN     NUMBER   DEFAULT   null
  ,p_primary_flag                  IN     VARCHAR2
  ,p_date_from                     IN     DATE
  ,p_date_to                       IN     DATE     DEFAULT   null
  ,p_address_type                  IN     VARCHAR2 DEFAULT   null
  ,p_comments                      IN     LONG     DEFAULT   null
  ,p_address_line1                 IN     VARCHAR2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT   null
  ,p_province_city_sar             IN     VARCHAR2
  ,p_postal_code                   IN     VARCHAR2 DEFAULT   null
  ,p_country                       IN     VARCHAR2
  ,p_telephone                     IN     VARCHAR2 DEFAULT   null
  ,p_fax                           IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT   null
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT   null
  ,p_add_information13             IN     VARCHAR2 DEFAULT   null
  ,p_add_information14             IN     VARCHAR2 DEFAULT   null
  ,p_add_information15             IN     VARCHAR2 DEFAULT   null
  ,p_add_information16             IN     VARCHAR2 DEFAULT   null
  ,p_add_information17             IN     VARCHAR2 DEFAULT   null
  ,p_add_information18             IN     VARCHAR2 DEFAULT   null
  ,p_add_information19             IN     VARCHAR2 DEFAULT   null
  ,p_add_information20             IN     VARCHAR2 DEFAULT   null
  ,p_party_id                      IN     NUMBER   DEFAULT   null
  ,p_address_id                    OUT    NOCOPY   NUMBER
  ,p_object_version_number         OUT    NOCOPY   NUMBER  )
  IS

  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'create_cn_person_address';
  --
  BEGIN

  hr_cn_api.set_location(g_trace, 'Entering:'|| l_proc, 10);

  --
  -- Create Person Address details.
  --
  hr_cn_api.check_person (p_person_id, 'CN', trunc(p_effective_date));
  --
  hr_cn_api.set_location(g_trace, l_proc, 20);
  --
  hr_person_address_api.create_person_address
  (p_validate                      	=>	  p_validate
  ,p_effective_date               	=>	  p_effective_date
  ,p_pradd_ovlapval_override     	=>	  p_pradd_ovlapval_override
  ,p_validate_county               	=>	  p_validate_county
  ,p_person_id                    	=>	  p_person_id
  ,p_primary_flag                  	=>	  p_primary_flag
  ,p_style	        		=>	  'CN_GLB'
  ,p_date_from                     	=>	  p_date_from
  ,p_date_to                      	=>	  p_date_to
  ,p_address_type                  	=>	  p_address_type
  ,p_comments                      	=>	  p_comments
  ,p_address_line1                 	=>	  p_address_line1
  ,p_address_line2                 	=>	  p_address_line2
  ,p_town_or_city			=>	  p_province_city_sar
  ,p_postal_code                   	=>	  p_postal_code
  ,p_country                       	=>	  p_country
  ,p_telephone_number_1			=>	  p_telephone
  ,p_telephone_number_2 		=>	  p_fax
  ,p_addr_attribute_category       	=>	  p_addr_attribute_category
  ,p_addr_attribute1               	=>	  p_addr_attribute1
  ,p_addr_attribute2               	=>	  p_addr_attribute2
  ,p_addr_attribute3               	=>	  p_addr_attribute3
  ,p_addr_attribute4               	=>	  p_addr_attribute4
  ,p_addr_attribute5               	=>	  p_addr_attribute5
  ,p_addr_attribute6               	=>	  p_addr_attribute6
  ,p_addr_attribute7               	=>	  p_addr_attribute7
  ,p_addr_attribute8               	=>	  p_addr_attribute8
  ,p_addr_attribute9               	=>	  p_addr_attribute9
  ,p_addr_attribute10              	=>	  p_addr_attribute10
  ,p_addr_attribute11              	=>	  p_addr_attribute11
  ,p_addr_attribute12              	=>	  p_addr_attribute12
  ,p_addr_attribute13              	=>	  p_addr_attribute13
  ,p_addr_attribute14              	=>	  p_addr_attribute14
  ,p_addr_attribute15              	=>	  p_addr_attribute15
  ,p_addr_attribute16              	=>	  p_addr_attribute16
  ,p_addr_attribute17              	=>	  p_addr_attribute17
  ,p_addr_attribute18              	=>	  p_addr_attribute18
  ,p_addr_attribute19              	=>	  p_addr_attribute19
  ,p_addr_attribute20              	=>	  p_addr_attribute20
  ,p_add_information13             	=>	  p_add_information13
  ,p_add_information14             	=>	  p_add_information14
  ,p_add_information15             	=>	  p_add_information15
  ,p_add_information16             	=>	  p_add_information16
  ,p_add_information17             	=>	  p_add_information17
  ,p_add_information18             	=>	  p_add_information18
  ,p_add_information19             	=>	  p_add_information19
  ,p_add_information20             	=>	  p_add_information20
  ,p_party_id                      	=>	  p_party_id
  ,p_address_id                    	=>	  p_address_id
  ,p_object_version_number         	=>	  p_object_version_number
 );

  --
  hr_cn_api.set_location(g_trace, 'Leaving:'|| l_proc, 20);

 End create_cn_person_address;

-- ----------------------------------------------------------------------------
-- |------------------------< update_cn_person_address >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates the address as identified by the in
--   parameter p_address_id and the in out parameter p_object_version_number.
--
--   Please note. If you set the p_validate_county flag to FALSE and do not
--   enter a county then the address will not be valid for US payroll
--   processing.
--
-- Prerequisites:
--   The address as identified by the in parameter p_address_id and the in out
--   parameter p_object_version_number must already exist.
--
--   The address_type attribute can only be used after QuickCodes have been
--   defined for the 'ADDRESS_TYPE' lookup type.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the address is updated.
--   p_effective_date               Yes  date     Effective date.
--   p_validate_county                   boolean  set to true
--   p_address_id                   Yes  number   The primary key of the
--                                                address.
--   p_object_version_number        Yes  number   The current version of the
--                                                address to be updated.
--   p_date_from                    Yes  date     The date from which the
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_person_id                         number   Person for whom the address
--                                                applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long Comments.
--   p_address_line1                Yes  varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_province_city_sar            Yes  varchar2 Province/city.
--   p_postal_code                       varchar2 Determined by p_style
--                                                (eg. Postcode for CN).
--   p_country                      Yes  varchar2 Country.
--   p_telephone                         varchar2 Telephone number.
--   p_fax                               varchar2 Fax number.
--   p_addr_attribute_category           varchar2 Determines context of the
--                                                addr_attribute Descriptive
--                                                flexfield in parameters.
--   p_addr_attribute1                   varchar2 Descriptive flexfield.
--   p_addr_attribute2                   varchar2 Descriptive flexfield.
--   p_addr_attribute3                   varchar2 Descriptive flexfield.
--   p_addr_attribute4                   varchar2 Descriptive flexfield.
--   p_addr_attribute5                   varchar2 Descriptive flexfield.
--   p_addr_attribute6                   varchar2 Descriptive flexfield.
--   p_addr_attribute7                   varchar2 Descriptive flexfield.
--   p_addr_attribute8                   varchar2 Descriptive flexfield.
--   p_addr_attribute9                   varchar2 Descriptive flexfield.
--   p_addr_attribute10                  varchar2 Descriptive flexfield.
--   p_addr_attribute11                  varchar2 Descriptive flexfield.
--   p_addr_attribute12                  varchar2 Descriptive flexfield.
--   p_addr_attribute13                  varchar2 Descriptive flexfield.
--   p_addr_attribute14                  varchar2 Descriptive flexfield.
--   p_addr_attribute15                  varchar2 Descriptive flexfield.
--   p_addr_attribute16                  varchar2 Descriptive flexfield.
--   p_addr_attribute17                  varchar2 Descriptive flexfield.
--   p_addr_attribute18                  varchar2 Descriptive flexfield.
--   p_addr_attribute19                  varchar2 Descriptive flexfield.
--   p_addr_attribute20                  varchar2 Descriptive flexfield.
--   p_add_information13                 varchar2 Descriptive flexfield.
--   p_add_information14                 varchar2 Descriptive flexfield.
--   p_add_information15                 varchar2 Descriptive flexfield.
--   p_add_information16                 varchar2 Descriptive flexfield.
--   p_add_information17                 varchar2 Tax Address State.
--   p_add_information18                 varchar2 Tax Address City.
--   p_add_information19                 varchar2 Tax Address County.
--   p_add_information20                 varchar2 Tax Address Zip.
--   p_party_id                          number   Party for whom the address
--                                                applies.
--
-- Post Success:
--   When the address is valid, the API sets the following out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           address. If p_validate is true,
--                                           set to null.
--
-- Post Failure:
--   The API does not update the address and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

 PROCEDURE update_cn_person_address
  (p_validate                      IN     BOOLEAN  DEFAULT   false
  ,p_effective_date                IN     DATE
  ,p_validate_county               IN     BOOLEAN  DEFAULT   true
  ,p_address_id                    IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY   NUMBER
  ,p_date_from                     IN     DATE     DEFAULT   hr_api.g_date
  ,p_date_to                       IN     DATE     DEFAULT   hr_api.g_date
  ,p_primary_flag                  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_address_type                  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_comments                      IN     LONG     DEFAULT   null
  ,p_address_line1                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_address_line2                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_province_city_sar             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_postal_code                   IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_country                       IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_telephone                     IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_fax                           IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute_category       IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute1               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute2               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute3               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute4               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute5               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute6               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute7               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute8               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute9               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute10              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute11              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute12              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute13              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute14              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute15              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute16              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute17              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute18              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute19              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_addr_attribute20              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information13             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information14             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information15             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information16             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information17             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information18             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information19             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_add_information20             IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_party_id                      IN     NUMBER   DEFAULT   hr_api.g_number)
   IS

  --
  -- Declare cursors and local variables
  --
  l_proc                VARCHAR2(72) := g_package||'update_cn_person_address';
  l_style               per_addresses.style%TYPE;
  --
  CURSOR csr_add_style IS
    SELECT  style
    FROM    per_addresses
    WHERE   address_id = p_address_id;
  --
  BEGIN

  hr_cn_api.set_location(g_trace, 'Entering:'|| l_proc, 5);

  --
  -- Check that the address is CN_GLB style.
  --
  hr_cn_api.check_address (p_address_id  => p_address_id,
                 p_address_style => 'CN_GLB');
  --

  hr_cn_api.set_location(g_trace, l_proc, 5);

  --
  -- Update Person Address details.
  --
   hr_person_address_api.update_person_address
  (p_validate                      	=>	  p_validate
  ,p_effective_date                	=>	  p_effective_date
  ,p_validate_county              	=>	  p_validate_county
  ,p_address_id                   	=>	  p_address_id
  ,p_object_version_number         	=>	  p_object_version_number
  ,p_date_from                          =>	  p_date_from
  ,p_date_to                            =>	  p_date_to
  ,p_primary_flag                 	=>	  p_primary_flag
  ,p_address_type                 	=>	  p_address_type
  ,p_comments                      	=>	  p_comments
  ,p_address_line1                	=>	  p_address_line1
  ,p_address_line2                	=>	  p_address_line2
  ,p_town_or_city			=>	  p_province_city_sar
  ,p_postal_code                  	=>	  p_postal_code
  ,p_country                      	=>	  p_country
  ,p_telephone_number_1			=>	  p_telephone
  ,p_telephone_number_2 		=>	  p_fax
  ,p_addr_attribute_category      	=>	  p_addr_attribute_category
  ,p_addr_attribute1              	=>	  p_addr_attribute1
  ,p_addr_attribute2              	=>	  p_addr_attribute2
  ,p_addr_attribute3              	=>	  p_addr_attribute3
  ,p_addr_attribute4              	=>	  p_addr_attribute4
  ,p_addr_attribute5              	=>	  p_addr_attribute5
  ,p_addr_attribute6              	=>	  p_addr_attribute6
  ,p_addr_attribute7              	=>	  p_addr_attribute7
  ,p_addr_attribute8              	=>	  p_addr_attribute8
  ,p_addr_attribute9              	=>	  p_addr_attribute9
  ,p_addr_attribute10             	=>	  p_addr_attribute10
  ,p_addr_attribute11             	=>	  p_addr_attribute11
  ,p_addr_attribute12             	=>	  p_addr_attribute12
  ,p_addr_attribute13             	=>	  p_addr_attribute13
  ,p_addr_attribute14             	=>	  p_addr_attribute14
  ,p_addr_attribute15             	=>	  p_addr_attribute15
  ,p_addr_attribute16             	=>	  p_addr_attribute16
  ,p_addr_attribute17             	=>	  p_addr_attribute17
  ,p_addr_attribute18             	=>	  p_addr_attribute18
  ,p_addr_attribute19             	=>	  p_addr_attribute19
  ,p_addr_attribute20             	=>	  p_addr_attribute20
  ,p_add_information13            	=>	  p_add_information13
  ,p_add_information14            	=>	  p_add_information14
  ,p_add_information15            	=>	  p_add_information15
  ,p_add_information16            	=>	  p_add_information16
  ,p_add_information17            	=>	  p_add_information17
  ,p_add_information18            	=>	  p_add_information18
  ,p_add_information19            	=>	  p_add_information19
  ,p_add_information20            	=>	  p_add_information20
  ,p_party_id                       	=>	  p_party_id
 );

  hr_cn_api.set_location(g_trace, 'Leaving:'|| l_proc, 5);
--

End update_cn_person_address;

END hr_cn_person_address_api;

/
