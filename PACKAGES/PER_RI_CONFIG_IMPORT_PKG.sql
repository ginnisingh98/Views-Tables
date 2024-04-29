--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_IMPORT_PKG" AUTHID CURRENT_USER as
 /* $Header: perricnfimp.pkh 120.0 2005/06/01 00:48:19 appldev noship $ */

Procedure load_configuration( p_configuration_code            In  Varchar2
                             ,p_configuration_type            In  Varchar2
                             ,p_configuration_status          In  Varchar2
                             ,p_configuration_name            In  Varchar2
                             ,p_configuration_description     In  Varchar2
                             ,p_effective_date                In  Date
                             ,p_enterprise_shortname	      In  Varchar2
                            );

Procedure load_config_information
                             (p_configuration_code             In  Varchar2
                             ,p_config_information_category    In  Varchar2
                             ,p_config_sequence                In  Number
                             ,p_config_information1            In  Varchar2  Default Null
                             ,p_config_information2            In  Varchar2  Default Null
                             ,p_config_information3            In  Varchar2  Default Null
                             ,p_config_information4            In  Varchar2  Default Null
                             ,p_config_information5            In  Varchar2  Default Null
                             ,p_config_information6            In  Varchar2  Default Null
                             ,p_config_information7            In  Varchar2  Default Null
                             ,p_config_information8            In  Varchar2  Default Null
                             ,p_config_information9            In  Varchar2  Default Null
                             ,p_config_information10           In  Varchar2  Default Null
                             ,p_config_information11           In  Varchar2  Default Null
                             ,p_config_information12           In  Varchar2  Default Null
                             ,p_config_information13           In  Varchar2  Default Null
                             ,p_config_information14           In  Varchar2  Default Null
                             ,p_config_information15           In  Varchar2  Default Null
                             ,p_config_information16           In  Varchar2  Default Null
                             ,p_config_information17           In  Varchar2  Default Null
                             ,p_config_information18           In  Varchar2  Default Null
                             ,p_config_information19           In  Varchar2  Default Null
                             ,p_config_information20           In  Varchar2  Default Null
                             ,p_config_information21           In  Varchar2  Default Null
                             ,p_config_information22           In  Varchar2  Default Null
                             ,p_config_information23           In  Varchar2  Default Null
                             ,p_config_information24           In  Varchar2  Default Null
                             ,p_config_information25           In  Varchar2  Default Null
                             ,p_config_information26           In  Varchar2  Default Null
                             ,p_config_information27           In  Varchar2  Default Null
                             ,p_config_information28           In  Varchar2  Default Null
                             ,p_config_information29           In  Varchar2  Default Null
                             ,p_config_information30           In  Varchar2  Default Null
                             ,p_effective_date                 In  Date
                             );

Procedure load_config_location(p_configuration_code            In  Varchar2
                             ,p_configuration_context          In  Varchar2
                             ,p_location_code                  In  Varchar2
                             ,p_description                    In  Varchar2  Default Null
                             ,p_style                          In  Varchar2  Default Null
                             ,p_address_line_1                 In  Varchar2  Default Null
                             ,p_address_line_2                 In  Varchar2  Default Null
                             ,p_address_line_3                 In  Varchar2  Default Null
                             ,p_town_or_city                   In  Varchar2  Default Null
                             ,p_country                        In  Varchar2  Default Null
                             ,p_postal_code                    In  Varchar2  Default Null
                             ,p_region_1                       In  Varchar2  Default Null
                             ,p_region_2                       In  Varchar2  Default Null
                             ,p_region_3                       In  Varchar2  Default Null
                             ,p_telephone_number_1             In  Varchar2  Default Null
                             ,p_telephone_number_2             In  Varchar2  Default Null
                             ,p_telephone_number_3             In  Varchar2  Default Null
                             ,p_loc_information13              In  Varchar2  Default Null
                             ,p_loc_information14              In  Varchar2  Default Null
                             ,p_loc_information15              In  Varchar2  Default Null
                             ,p_loc_information16              In  Varchar2  Default Null
                             ,p_loc_information17              In  Varchar2  Default Null
                             ,p_loc_information18              In  Varchar2  Default Null
                             ,p_loc_information19              In  Varchar2  Default Null
                             ,p_loc_information20              In  Varchar2  Default Null
                             ,p_effective_date                 In  Date
                             );

end per_ri_config_import_pkg;

 

/
