--------------------------------------------------------
--  DDL for Package HR_KIOSK_ADDRESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KIOSK_ADDRESS_API" AUTHID CURRENT_USER as
/* $Header: pekadapi.pkh 115.1 2003/02/11 10:48:26 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_address >-------------------------|
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
--   Currently only GB, US and GENERIC address styles are supported by this API.
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
--   p_person_id                    Yes  number   Person for whom the address
--                                                applies.
--   p_primary_flag                 Yes  varchar2 Identifies the primary
--                                                address.
--   p_style                        Yes  varchar2 Identifies the style of
--                                                address (eg.'GB').
--   p_date_from                    Yes  date     The date from which the
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                     varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_address_line3                     varchar2 Line 3 of address.
--   p_town_or_city                      varchar2 Town/city.
--   p_region_1                          varchar2 Determined by p_style
--                                                (eg. County for GB and US).
--   p_region_2                          varchar2 Determined by p_style
--                                                (eg. State for US)
--   p_region_3                          varchar2 Determined by p_style.
--   p_postal_code                       varchar2 Determined by p_style
--                                                (eg. Postcode for GB or
--                                                     Zip code for US).
--   p_country                           varchar2 Country.
--   p_telephone_number_1                varchar2 Telephone number.
--   p_telephone_number_2                varchar2 Telephone number.
--   p_telephone_number_3                varchar2 Not currently implemented.
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
--
-- {End Of Comments}
--
procedure create_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_style                         in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2 default null
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_town_or_city                  in     varchar2 default null
  ,p_region_1                      in     varchar2 default null
  ,p_region_2                      in     varchar2 default null
  ,p_region_3                      in     varchar2 default null
  ,p_postal_code                   in     varchar2 default null
  ,p_country                       in     varchar2 default null
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
  ,p_telephone_number_3            in     varchar2 default null
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
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_gb_person_address >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates the GB style address as specified, for the person
--   identified by the in parameter p_person_id. This API calls the generic
--   API create_person_address, with the parameters set as
--   appropriate for a GB style address.
--
--   As this API is effectively an alternative to the API
--   create_person_address, see that API for further explanation.
--
-- Prerequisites:
--   See API create_person_address.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                address will be created in
--                                                the database.
--   p_effective_date               Yes  date     Effective date.
--   p_person_id                    Yes  number   Person for which the address
--                                                applies.
--   p_primary_flag                 Yes  varchar2 Indicates if this is a
--                                                primary or non-primary
--                                                address. Y or N.
--   p_date_from                    Yes  date     The date from which this
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                Yes  varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_address_line3                     varchar2 Line 3 of address.
--   p_town                              varchar2 Town.
--   p_county                            varchar2 County.
--   p_postcode                          varchar2 Postcode.
--   p_country                      Yes  varchar2 Country.
--   p_telephone_number                  varchar2 Telephone number.
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

-- Post Success:
--   When the address is valid the following out parameters are set.
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
--
-- {End Of Comments}
--
procedure create_gb_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_town                          in     varchar2 default null
  ,p_county                        in     varchar2 default null
  ,p_postcode                      in     varchar2 default null
  ,p_country                       in     varchar2
  ,p_telephone_number              in     varchar2 default null
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
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a US style address a person. This API calls the generic
--   API create_person_address  with the applicable parameters for a US address
--   style.
--
-- Prerequisites:
--   A valid person (p_person_id) must exist on the start date (p_date_from)
--   of the address.
--
--   The address_type attribute can only be used after QuickCodes have been
--   defined for the 'ADDRESS_TYPE' lookup type.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                address will be created in
--                                                the database.
--   p_effective_date               Yes  date     Effective date.
--   p_person_id                    Yes  number   Person for which the address
--                                                applies.
--   p_primary_flag                 Yes  varchar2 Indicates if this is a
--                                                primary or non-primary
--                                                address. Y or N.
--   p_date_from                    Yes  date     The date from which this
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                Yes  varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_address_line3                     varchar2 Line 3 of address.
--   p_city                              varchar2 City. The city is mandatory
--                                                if payroll is installed under
--                                                US legislation.
--   p_state                             varchar2 State. The state is mandatory
--                                                if payroll is installed under
--                                                US legislation.
--   p_zip_code                          varchar2 Zip code. The zip code is
--                                                mandatory if payroll is
--                                                installed under US
--                                                legislation.
--   p_county                            varchar2 County. The county is
--                                                mandatory if payroll is
--                                                installed under US
--                                                legislation.
--   p_country                      Yes  varchar2 Country.
--   p_telephone_number_1                varchar2 Telephone number 1.
--   p_telephone_number_2                varchar2 Telephone number 2.
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
--
-- Post Success:
--   When the address is valid the following out parameters are set.
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
--
-- {End Of Comments}
--
procedure create_us_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_primary_flag                  in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_address_type                  in     varchar2 default null
  ,p_comments                      in     long     default null
  ,p_address_line1                 in     varchar2
  ,p_address_line2                 in     varchar2 default null
  ,p_address_line3                 in     varchar2 default null
  ,p_city                          in     varchar2 default null
  ,p_state                         in     varchar2 default null
  ,p_zip_code                      in     varchar2 default null
  ,p_county                        in     varchar2 default null
  ,p_country                       in     varchar2
  ,p_telephone_number_1            in     varchar2 default null
  ,p_telephone_number_2            in     varchar2 default null
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
  ,p_address_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_address >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates the address as identified by the in
--   parameter p_address_id and the in out parameter p_object_version_number.
--
--   Currently only GB, US and GENERIC address styles are supported by this API.
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
--   p_address_id                   Yes  number   The primary key of the
--                                                address.
--   p_object_version_number        Yes  number   The current version of the
--                                                address to be updated.
--   p_date_from                    Yes  date     The date from which the
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_person_id                    Yes  number   Person for whom the address
--                                                applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                     varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_address_line3                     varchar2 Line 3 of address.
--   p_town_or_city                      varchar2 Town/city.
--   p_region_1                          varchar2 Determined by p_style
--                                                (eg. County for GB and US).
--   p_region_2                          varchar2 Determined by p_style
--                                                (eg. State for US).
--   p_region_3                          varchar2 Determined by p_style.
--   p_postal_code                       varchar2 Determined by p_style
--                                                (eg. Postcode for GB or
--                                                     zip code for US).
--   p_country                           varchar2 Country.
--   p_telephone_number_1                varchar2 Telephone number.
--   p_telephone_number_2                varchar2 Telephone number.
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
procedure update_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town_or_city                  in     varchar2 default hr_api.g_varchar2
  ,p_region_1                      in     varchar2 default hr_api.g_varchar2
  ,p_region_2                      in     varchar2 default hr_api.g_varchar2
  ,p_region_3                      in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_3            in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_gb_person_address >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates the GB style address as identified by the in
--   parameter p_address_id and the in out parameter p_object_version_number.
--   This API calls the generic API update_person_address,
--   with the parameters set as appropriate for a GB style address.
--
--   As this API is effectively an alternative to the API
--   update_person_address, see that API for further explanation.
--
-- Prerequisites:
--   The address to be updated must be in GB style. See API
--   update_person_address for further details.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the address is updated.
--   p_effective_date               Yes  date     Effective date.
--   p_address_id                   Yes  number   The primary key of the
--                                                address.
--   p_object_version_number        Yes  number   The current version of the
--                                                address to be updated.
--   p_date_from                         date     The date from which the
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                     varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_address_line3                     varchar2 Line 3 of address.
--   p_town                              varchar2 Town.
--   p_county                            varchar2 County.
--   p_postcode                          varchar2 Postcode.
--   p_country                           varchar2 Country.
--   p_telephone_number                  varchar2 Telephone number.
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
procedure update_gb_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town                          in     varchar2 default hr_api.g_varchar2
  ,p_county                        in     varchar2 default hr_api.g_varchar2
  ,p_postcode                      in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_us_person_address >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates the US style address as identified by the in
--   parameter p_address_id and the in out parameter p_object_version_number.
--   This API calls the generic API update_person_address with the
--   applicable parameters for a US address style.
--
-- Prerequisites:
--   The address to be updated must exist and is US style.
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
--   p_address_id                   Yes  number   The primary key of the
--                                                address.
--   p_object_version_number        Yes  number   The current version of the
--                                                address to be updated.
--   p_date_from                         date     The date from which the
--                                                address applies.
--   p_date_to                           date     The date on which the
--                                                address no longer applies.
--   p_address_type                      varchar2 Type of address.
--   p_comments                          long     Comments.
--   p_address_line1                     varchar2 Line 1 of address.
--   p_address_line2                     varchar2 Line 2 of address.
--   p_address_line3                     varchar2 Line 3 of address.
--   p_city                              varchar2 City. The city is mandatory
--                                                if payroll is installed under
--                                                US legislation.
--   p_state                             varchar2 State. The state is mandatory
--                                                if payroll is installed under
--                                                US legislation.
--   p_zip_code                          varchar2 Zip code. The zip code is
--                                                mandatory if payroll is
--                                                installed under US
--                                                legislation.
--   p_county                            varchar2 County. The county is
--                                                mandatory if payroll is
--                                                installed under US
--                                                legislation.
--   p_country                           varchar2 Country.
--   p_telephone_number_1                varchar2 Telephone number 1.
--   p_telephone_number_2                varchar2 Telephone number 2.
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
--
-- Post Success:
--   If the address is valid, the API sets the following out parameters.
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
procedure update_us_person_address
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_city                          in     varchar2 default hr_api.g_varchar2
  ,p_state                         in     varchar2 default hr_api.g_varchar2
  ,p_zip_code                      in     varchar2 default hr_api.g_varchar2
  ,p_county                        in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  );
--
end hr_kiosk_address_api;

 

/
