--------------------------------------------------------
--  DDL for Package HR_LOCATION_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_BE1" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:15
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_location_a (
p_effective_date               date,
p_language_code                varchar2,
p_location_code                varchar2,
p_description                  varchar2,
p_timezone_code                varchar2,
p_tp_header_id                 number,
p_ece_tp_location_code         varchar2,
p_address_line_1               varchar2,
p_address_line_2               varchar2,
p_address_line_3               varchar2,
p_bill_to_site_flag            varchar2,
p_country                      varchar2,
p_designated_receiver_id       number,
p_in_organization_flag         varchar2,
p_inactive_date                date,
p_operating_unit_id            number,
p_inventory_organization_id    number,
p_office_site_flag             varchar2,
p_postal_code                  varchar2,
p_receiving_site_flag          varchar2,
p_region_1                     varchar2,
p_region_2                     varchar2,
p_region_3                     varchar2,
p_ship_to_location_id          number,
p_ship_to_site_flag            varchar2,
p_style                        varchar2,
p_tax_name                     varchar2,
p_telephone_number_1           varchar2,
p_telephone_number_2           varchar2,
p_telephone_number_3           varchar2,
p_town_or_city                 varchar2,
p_loc_information13            varchar2,
p_loc_information14            varchar2,
p_loc_information15            varchar2,
p_loc_information16            varchar2,
p_loc_information17            varchar2,
p_loc_information18            varchar2,
p_loc_information19            varchar2,
p_loc_information20            varchar2,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_global_attribute_category    varchar2,
p_global_attribute1            varchar2,
p_global_attribute2            varchar2,
p_global_attribute3            varchar2,
p_global_attribute4            varchar2,
p_global_attribute5            varchar2,
p_global_attribute6            varchar2,
p_global_attribute7            varchar2,
p_global_attribute8            varchar2,
p_global_attribute9            varchar2,
p_global_attribute10           varchar2,
p_global_attribute11           varchar2,
p_global_attribute12           varchar2,
p_global_attribute13           varchar2,
p_global_attribute14           varchar2,
p_global_attribute15           varchar2,
p_global_attribute16           varchar2,
p_global_attribute17           varchar2,
p_global_attribute18           varchar2,
p_global_attribute19           varchar2,
p_global_attribute20           varchar2,
p_business_group_id            number,
p_location_id                  number,
p_object_version_number        number);
end hr_location_be1;

/
