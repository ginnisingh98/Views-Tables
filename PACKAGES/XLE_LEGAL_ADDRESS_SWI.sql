--------------------------------------------------------
--  DDL for Package XLE_LEGAL_ADDRESS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_LEGAL_ADDRESS_SWI" AUTHID CURRENT_USER AS
/* $Header: xleaddrs.pls 120.4.12010000.3 2010/01/19 10:28:08 srampure ship $ */

 PROCEDURE create_legal_address
  (p_validate                     in     number
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2
  ,p_location_code                in     varchar2
  ,p_description                  in     varchar2  default null
  ,p_address_line_1               in     varchar2  default null
  ,p_address_line_2               in     varchar2  default null
  ,p_address_line_3               in     varchar2  default null
  ,p_country                      in     varchar2  default null
  ,p_inactive_date                in     date      default null
  ,p_postal_code                  in     varchar2   default null
  ,p_region_1                     in     varchar2  default null
  ,p_region_2                     in     varchar2  default null
  ,p_region_3                     in     varchar2  default null
  ,p_style                        in     varchar2  default null
  ,p_town_or_city                 in     varchar2  default NULL
  ,p_telephone_number_1           in     varchar2  default null
  ,p_telephone_number_2           in     varchar2  default null
  ,p_telephone_number_3           in     varchar2  default null
  ,p_loc_information13            in     varchar2  default null
  ,p_loc_information14            in     varchar2  default null
  ,p_loc_information15            in     varchar2  default null
  ,p_loc_information16            in     varchar2  default null
  ,p_loc_information17            in     varchar2  default null
  ,p_loc_information18            in     varchar2  default null
  ,p_loc_information19            in     varchar2  default null
  ,p_loc_information20            in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_location_id                  out nocopy number
  ,p_object_version_number        out nocopy number
  );

  PROCEDURE update_legal_address
   (p_validate                    in     number
  ,p_effective_date               in     date
  ,p_location_id                  in     number
  ,p_description                  in     varchar2
  ,p_address_line_1               in     varchar2
  ,p_address_line_2               in     varchar2
  ,p_address_line_3               in     varchar2
  ,p_inactive_date                in     date
  ,p_postal_code                  in     varchar2
  ,p_region_1                     in     varchar2
  ,p_region_2                     in     varchar2
  ,p_region_3                     in     varchar2
  ,p_style                        in     varchar2
  ,p_town_or_city                 in     VARCHAR2
  ,p_telephone_number_1           in     varchar2
  ,p_telephone_number_2           in     varchar2
  ,p_telephone_number_3           in     varchar2
  ,p_loc_information13            in     varchar2
  ,p_loc_information14            in     varchar2
  ,p_loc_information15            in     varchar2
  ,p_loc_information16            in     varchar2
  ,p_loc_information17            in     varchar2
  ,p_loc_information18            in     varchar2
  ,p_loc_information19            in     varchar2
  ,p_loc_information20            in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_object_version_number        in out nocopy number
  );

PROCEDURE enable_legal_address_flag
  (p_location_id                     in     number
  );

END;

/
