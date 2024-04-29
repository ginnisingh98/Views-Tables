--------------------------------------------------------
--  DDL for Package HR_LOCATION_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_INTERNAL" AUTHID CURRENT_USER AS
/* $Header: hrlocbsi.pkh 120.0 2005/05/31 01:20:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_generic_location >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API creates a new location, which is called from,
--  hr_location_api.create_location or hr_location_api.create_location_legal_adr
--
--    Locations are stored on the HR_LOCATIONS_ALL table.  The translated
--    columns are stored on the HR_LOCATIONS_ALL_TL table.
--
--    The business_group_id of a location determines its scope:
--
--       If the business_group_id is NULL, the location's scope is global.
--       This means the location is visible to/can reference any entity
--       (within the scope of the current security group).
--
--       If the business_group_id is set, the location's scope is local.
--       This means the location is visible to/can reference any entity
--       within the same business_group or whose scope is global (within
--       the scope of the current security group).
--
--       Longitude and Latitude columns can hold the co-ordinates of a
--       location, using the decimal format.  For example, 10 degrees North
--       and 20 degrees West is stored as:
--                                           Latitude  = +10.0
--                                           Longitude = -20.0
--
--
-- Prerequisites:
--
--    Some fields require certain applications to have been installed.  See "In
--    Parameters" for full details.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the location will be
--                                                created on the database.
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation.
--   p_language_code                No   Varchar2 The language used for the
--                                                initial translation values
--   p_location_code                Yes  Varchar2 Location name (Translated)
--   p_description                  No   Varchar2 Location description (Translated)
--   p_timezone_code                No   Varchar2 Timezone for Location
--   p_tp_header_id                 No   Varchar2 Inventory Header Id
--   p_ece_tp_location_code         No   Varchar2 Inventory Organization
--   p_address_line_1               No   Varchar2 Address Flexfield
--   p_address_line_2               No   Varchar2 Address Flexfield
--   p_address_line_3               No   Varchar2 Address Flexfield
--   p_bill_to_site_flag            No   Varchar2 Bill-to-Site Flag
--                                                (YES/NO lookup value default 'Y')
--   p_country                      No   Varchar2 Address Flexfield
--   p_designated_receiver_id       No   Varchar2 Designated Receiver Person ID
--                                                Must be a valid employee within
--                                                the scope of the location.
--   p_in_organization_flag         No   Varchar2 Internal Organization Flag
--                                                (YES/NO lookup value default 'Y')
--   p_inactive_date                No   Date     Date on which location becomes
--                                                inactive.  Must be greater than
--                                                or equal to p_effective_date.
--   p_operating_unit_id            No   Date     Needs to be provided if
--                                                inventory_organization_id is provided.
--                                                See special notes below.  Not stored
--                                                on database.
--   p_inventory_organization_id    No   Date     Inventory Organization Id
--   p_office_site_flag             No   Varchar2 Office-Site Flag
--                                                (YES/NO lookup value default 'Y')
--   p_postal_code                  No   Varchar2 Address Flexfield
--   p_receiving_site_flag          No   Varchar2 Receiving-Site Flag
--                                                (YES/NO lookup value default 'Y')
--                                                If the current location is a "Ship-to"
--                                                site, receiving_site_flag must also
--                                                = 'Y'
--   p_region_1                     No   Varchar2 Address Flexfield
--   p_region_2                     No   Varchar2 Address Flexfield
--   p_region_3                     No   Varchar2 Address Flexfield
--   p_ship_to_location_id          No   Number   Ship-to Location Id.
--                                                Should never be NULL. IF it is
--                                                passed through as NULL, then it
--                                                will take the value of LOCATION_ID.
--
--                                                The following must be true for
--                                                validation to succeed:
--                                                1). INACTIVE_DATE (if set) >=
--                                                SESSION_DATE.
--                                                2). BUSINESS_GROUP_ID is null or
--                                                equal to the business group of the
--                                                location.
--                                                NOTE: if the business group of the
--                                                location is null do not enforce
--                                                this validation rule.
--
--   p_ship_to_site_flag            No   Varchar2 Ship-to-Site Flag.
--                                                Is a YES_NO column, whose value
--                                                must exist in FND_COMMON_LOOKUPS
--                                                as type YES_NO.
--                                                (i.e. must be 'Y' or 'N')
--
--                                                If SHIP_TO_LOCATION_ID is equal to
--                                                LOCATION_ID then the
--                                                SHIP_TO_SITE_FLAG must be 'Y'.
--                                                If the SHIP_TO_LOCATION_ID is
--                                                passed as NULL, then it takes on
--                                                the value of LOCATION_ID. If the
--                                                SHIP_TO_LOCATION_ID is some other
--                                                ID then the SHIP_TO_SITE_FLAG must
--                                                be 'N'.
--
--   p_style                        No   Varchar2 Address Flexfield
--   p_tax_name                     No   Varchar2 Tax Code
--   p_telephone_number_1           No   Varchar2 Address Flexfield
--   p_telephone_number_2           No   Varchar2 Address Flexfield
--   p_telephone_number_3           No   Varchar2 Address Flexfield
--   p_town_or_city                 No   Varchar2 Address Flexfield
--   p_loc_information13            No   Varchar2 Address Flexfield
--   p_loc_information14            No   Varchar2 Address Flexfield
--   p_loc_information15            No   Varchar2 Address Flexfield
--   p_loc_information16            No   Varchar2 Address Flexfield
--   p_loc_information17            No   Varchar2 Address Flexfield
--   p_attribute_category           No   Varchar2 Flexfield Category
--   p_attribute1                   No   Varchar2 Flexfield
--   ..
--   p_attribute20                  No   Varchar2 Flexfield
--   p_global_attribute_category    No   Varchar2 Flexfield Category
--   p_global_attribute1            No   Varchar2 Flexfield
--   ..
--   p_global_attribute20           No   Varchar2 Flexfield
--   p_legal_address_flag           No   Varchar2 default is set to 'N'. This
--                                                will state whether or not the
--                                                location is a legal entity
--   p_business_group_id            No   Number   Business group ID. A
--                                                NULL value indicates global
--                                                scope.  Any other value must
--                                                index a valid business group
--                                                and sets the scope of the
--                                                location to local.
--
-- Post Success:
--   When the location has been successfully inserted, the following OUT
--   parameters are set:
--
--   Name                                Type     Description
--
--   p_location_id                       Number   If p_validate is false, this
--                                                contains the ID assigned to
--                                                the location  (otherwise
--                                                contains NULL)
--   p_object_version_number             Number   If p_validate is false, this
--                                                contains the Object Version
--                                                Number of the newly created
--                                                row (otherwise contains NULL)
--
-- Post Failure:
--   The API does not create the location, and raises an error
--
-- Access Status:
--   Public.
--
-- Special Notes:
--
--   p_operating_unit_id is not stored on any table, merely used to
--   validate p_inventory_organization_id.  It is not mandatory because
--   HR users should not have to supply the parameter.
--
-- {End Of Comments}
--
PROCEDURE create_generic_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_code                  IN  VARCHAR2
     ,p_description                    IN  VARCHAR2  DEFAULT NULL
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT NULL
     ,p_tp_header_id                   IN  NUMBER    DEFAULT NULL
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT NULL
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT NULL
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_country                        IN  VARCHAR2  DEFAULT NULL
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT NULL
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT 'Y'
     ,p_inactive_date                  IN  DATE      DEFAULT NULL
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT NULL
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT 'Y'
     ,p_postal_code                    IN  VARCHAR2  DEFAULT NULL
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT 'Y'
     ,p_region_1                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_2                       IN  VARCHAR2  DEFAULT NULL
     ,p_region_3                       IN  VARCHAR2  DEFAULT NULL
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT NULL
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT 'Y'
     ,p_style                          IN  VARCHAR2  DEFAULT NULL
     ,p_tax_name                       IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT NULL
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT NULL
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information13              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information14              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information15              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information16              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information17              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information18              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information19              IN  VARCHAR2  DEFAULT NULL
     ,p_loc_information20              IN  VARCHAR2  DEFAULT NULL
     ,p_attribute_category             IN  VARCHAR2  DEFAULT NULL
     ,p_attribute1                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute2                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute3                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute4                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute5                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute6                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute7                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute8                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute9                     IN  VARCHAR2  DEFAULT NULL
     ,p_attribute10                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute11                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute12                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute13                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute14                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute15                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute16                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute17                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute18                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute19                    IN  VARCHAR2  DEFAULT NULL
     ,p_attribute20                    IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT NULL
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT NULL
     ,p_business_group_id              IN  NUMBER    DEFAULT NULL
     ,p_legal_address_flag             IN  VARCHAR2  DEFAULT NULL
     ,p_location_id                    OUT NOCOPY NUMBER
     ,p_object_version_number          OUT NOCOPY NUMBER
 );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_generic_location >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API creates a new location, which is called from,
--  hr_location_api.create_location or hr_location_api.create_location_legal_adr
--
--    Locations are stored on the HR_LOCATIONS_ALL table.  The translated
--    columns are stored on the HR_LOCATIONS_ALL_TL table.
--
--    The business_group_id of a location determines its scope:
--
--       If the business_group_id is NULL, the location's scope is global.
--       This means the location is visible to/can reference any entity
--       (within the scope of the current security group).
--
--       If the business_group_id is set, the location's scope is local.
--       This means the location is visible to/can reference any entity
--       within the same business_group or whose scope is global (within
--       the scope of the current security group).
--
--       Longitude and Latitude columns can hold the co-ordinates of a
--       location, using the decimal format.  For example, 10 degrees North
--       and 20 degrees West is stored as:
--                                           Latitude  = +10.0
--                                           Longitude = -20.0
--
-- Prerequisites:
--
--    Some fields require certain applications to have been installed.  See "In
--    Parameters" for full details.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   Boolean  If true, the database
--                                                remains unchanged.  If false
--                                                then the location will be
--                                                created on the database.
--   p_effective_date               Yes  Date     Used for date_track
--                                                validation.
--   p_language_code                No   Varchar2 Determines which translation(s)
--                                                are updated.
--   p_location_id                  Yes  Varchar2 Primary Key
--   p_location_code                No   Varchar2 Location name (Translated)
--   p_description                  No   Varchar2 Location description (Translated)
--   p_timezone_code                No   Varchar2 Timezone for Location
--   p_tp_header_id                 No   Varchar2 Inventory Header Id
--   p_ece_tp_location_code         No   Varchar2 Inventory Organization
--   p_address_line_1               No   Varchar2 Address Flexfield
--   p_address_line_2               No   Varchar2 Address Flexfield
--   p_address_line_3               No   Varchar2 Address Flexfield
--   p_bill_to_site_flag            No   Varchar2 Bill-to-Site Flag
--                                                (YES/NO lookup value default 'Y')
--   p_country                      No   Varchar2 Address Flexfield
--   p_designated_receiver_id       No   Varchar2 Designated Receiver Person ID
--                                                Must be a valid employee within
--                                                the scope of the location.
--   p_in_organization_flag         No   Varchar2 Internal Organization Flag
--                                                (YES/NO lookup value default 'Y')
--   p_inactive_date                No   Date     Date on which location becomes
--                                                inactive. Must be greater than
--                                                or equal to p_effective_date.
--   p_operating_unit_id            No   Date     Needs to be provided if
--                                                inventory_organization_id is provided.
--                                                See special notes below.  Not stored
--                                                on database.
--   p_inventory_organization_id    No   Date     Inventory Organization Id
--   p_office_site_flag             No   Varchar2 Office-Site Flag
--                                                (YES/NO lookup value default 'Y')
--   p_postal_code                  No   Varchar2 Address Flexfield
--   p_receiving_site_flag          No   Varchar2 Receiving-Site Flag
--                                                (YES/NO lookup value default 'Y')
--                                                If the current location is a "Ship-to"
--                                                site, receiving_site_flag must also
--                                                = 'Y'
--   p_region_1                     No   Varchar2 Address Flexfield
--   p_region_2                     No   Varchar2 Address Flexfield
--   p_region_3                     No   Varchar2 Address Flexfield
--   p_ship_to_location_id          No   Number   Ship-to Location Id.
--                                                Must be an active "Ship-to"
--                                                location within the scope
--                                                of the current location.
--   p_ship_to_site_flag            No   Varchar2 Ship-to-Site Flag
--                                                (YES/NO lookup value default 'Y')
--                                                If ship_to_location_id is NULL,
--                                                no further validation is performed.
--                                                If ship_to_location_id is not NULL,
--                                                ship_to_site_flag must be 'Y' if
--                                                the "Ship-to" location is the
--                                                current location, otherwise it
--                                                must be 'N'
--   p_style                        No   Varchar2 Address Flexfield
--   p_tax_name                     No   Varchar2 Tax Code
--   p_telephone_number_1           No   Varchar2 Address Flexfield
--   p_telephone_number_2           No   Varchar2 Address Flexfield
--   p_telephone_number_3           No   Varchar2 Address Flexfield
--   p_town_or_city                 No   Varchar2 Address Flexfield
--   p_loc_information13            No   Varchar2 Address Flexfield
--   p_loc_information14            No   Varchar2 Address Flexfield
--   p_loc_information15            No   Varchar2 Address Flexfield
--   p_loc_information16            No   Varchar2 Address Flexfield
--   p_loc_information17            No   Varchar2 Address Flexfield
--   p_attribute_category           No   Varchar2 Flexfield Category
--   p_attribute1                   No   Varchar2 Flexfield
--   ..
--   p_attribute20                  No   Varchar2 Flexfield
--   p_global_attribute_category    No   Varchar2 Flexfield Category
--   p_global_attribute1            No   Varchar2 Flexfield
--   ..
--   p_global_attribute20           No   Varchar2 Flexfield
--   p_legal_address_flag           No   Varchar2 default is set to NULL. This
--                                                will state whether or not the
--                                                location is a legal entity
--   p_object_version_number        Yes  Number   Object Version Number
--
-- Post Success:
--   When the location has been successfully inserted, the following OUT
--   parameters are set:
--
--   Name                                Type     Description
--
--   p_object_version_number             Number   If p_validate is false, this
--                                                contains the new Object
--                                                Version Number assigned to
--                                                the row (otherwise it is
--                                                left unchanged).
-- Post Failure:
--   The API does not update the location, and raises an error
--
-- Access Status:
--   Public.
--
--
-- Special Notes:
--
--   p_operating_unit_id defaults to NULL because it is not stored on any table,
--   merely used to validate p_inventory_organization_id.  It is not mandatory
--   because HR users should not have to supply the parameter.
--
-- {End Of Comments}
--
PROCEDURE update_generic_location
  (   p_validate                       IN  BOOLEAN   DEFAULT false
     ,p_effective_date                 IN  DATE
     ,p_language_code                  IN  VARCHAR2  DEFAULT hr_api.userenv_lang
     ,p_location_id                    IN  NUMBER
     ,p_location_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_description                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_timezone_code                  IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tp_header_id                   IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ece_tp_location_code           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_1                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_2                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_address_line_3                 IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_bill_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_country                        IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_designated_receiver_id         IN  NUMBER    DEFAULT hr_api.g_number
     ,p_in_organization_flag           IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_inactive_date                  IN  DATE      DEFAULT hr_api.g_date
     ,p_operating_unit_id              IN  NUMBER    DEFAULT NULL
     ,p_inventory_organization_id      IN  NUMBER    DEFAULT hr_api.g_number
     ,p_office_site_flag               IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_postal_code                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_receiving_site_flag            IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_1                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_2                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_region_3                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_ship_to_location_id            IN  NUMBER    DEFAULT hr_api.g_number
     ,p_ship_to_site_flag              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_style                          IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_tax_name                       IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_1             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_2             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_telephone_number_3             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_town_or_city                   IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information13              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information14              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information15              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information16              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information17              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information18              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information19              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_loc_information20              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute_category             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute1                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute2                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute3                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute4                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute5                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute6                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute7                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute8                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute9                     IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute10                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute11                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute12                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute13                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute14                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute15                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute16                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute17                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute18                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_attribute20                    IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute_category      IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute1              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute2              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute3              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute4              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute5              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute6              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute7              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute8              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute9              IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute10             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute11             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute12             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute13             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute14             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute15             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute16             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute17             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute18             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute19             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_global_attribute20             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_legal_address_flag             IN  VARCHAR2  DEFAULT hr_api.g_varchar2
     ,p_object_version_number          IN OUT NOCOPY NUMBER
  );
--
--------------------------------------------------------------------------------
END hr_location_internal;
--

 

/
