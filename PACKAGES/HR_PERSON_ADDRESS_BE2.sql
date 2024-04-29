--------------------------------------------------------
--  DDL for Package HR_PERSON_ADDRESS_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ADDRESS_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:15
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_person_address_a (
p_effective_date               date,
p_validate_county              boolean,
p_address_id                   number,
p_object_version_number        number,
p_date_from                    date,
p_date_to                      date,
p_address_type                 varchar2,
p_comments                     long,
p_address_line1                varchar2,
p_address_line2                varchar2,
p_address_line3                varchar2,
p_town_or_city                 varchar2,
p_region_1                     varchar2,
p_region_2                     varchar2,
p_region_3                     varchar2,
p_postal_code                  varchar2,
p_country                      varchar2,
p_telephone_number_1           varchar2,
p_telephone_number_2           varchar2,
p_telephone_number_3           varchar2,
p_addr_attribute_category      varchar2,
p_addr_attribute1              varchar2,
p_addr_attribute2              varchar2,
p_addr_attribute3              varchar2,
p_addr_attribute4              varchar2,
p_addr_attribute5              varchar2,
p_addr_attribute6              varchar2,
p_addr_attribute7              varchar2,
p_addr_attribute8              varchar2,
p_addr_attribute9              varchar2,
p_addr_attribute10             varchar2,
p_addr_attribute11             varchar2,
p_addr_attribute12             varchar2,
p_addr_attribute13             varchar2,
p_addr_attribute14             varchar2,
p_addr_attribute15             varchar2,
p_addr_attribute16             varchar2,
p_addr_attribute17             varchar2,
p_addr_attribute18             varchar2,
p_addr_attribute19             varchar2,
p_addr_attribute20             varchar2,
p_add_information13            varchar2,
p_add_information14            varchar2,
p_add_information15            varchar2,
p_add_information16            varchar2,
p_add_information17            varchar2,
p_add_information18            varchar2,
p_add_information19            varchar2,
p_add_information20            varchar2);
end hr_person_address_be2;

/
