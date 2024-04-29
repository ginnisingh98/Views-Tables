--------------------------------------------------------
--  DDL for Package PQP_ADDRESS_SYNCHRONIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ADDRESS_SYNCHRONIZATION" AUTHID CURRENT_USER AS
/* $Header: pqaddsyn.pkh 120.0 2005/05/29 01:41:52 appldev noship $ */

-- =============================================================================
-- ~ Addr_DDF_Ins:
-- =============================================================================
PROCEDURE Addr_DDF_Ins
         (p_address_id                   IN  Number
         ,p_business_group_id            IN  Number
         ,p_person_id                    IN  Number
         ,p_party_id                     IN  Number
         ,p_date_from                    IN  Date
         ,p_primary_flag                 IN  Varchar2
         ,p_style                        IN  Varchar2
         ,p_address_line1                IN  Varchar2
         ,p_address_line2                IN  Varchar2
         ,p_address_line3                IN  Varchar2
         ,p_address_type                 IN  Varchar2
         ,p_country                      IN  Varchar2
         ,p_date_to                      IN  Date
         ,p_postal_code                  IN  Varchar2
         ,p_region_1                     IN  Varchar2
         ,p_region_2                     IN  Varchar2
         ,p_region_3                     IN  Varchar2
         ,p_telephone_number_1           IN  Varchar2
         ,p_telephone_number_2           IN  Varchar2
         ,p_telephone_number_3           IN  Varchar2
         ,p_town_or_city                 IN  Varchar2
         ,p_add_information13            IN  Varchar2
         ,p_add_information14            IN  Varchar2
         ,p_add_information15            IN  Varchar2
         ,p_add_information16            IN  Varchar2
         ,p_add_information17            IN  Varchar2
         ,p_add_information18            IN  Varchar2
         ,p_add_information19            IN  Varchar2
         ,p_add_information20            IN  Varchar2
         ,p_object_version_number        IN  Number
         ,p_effective_date               IN  Date
         ,p_validate_county              IN  Boolean
         );
-- =============================================================================
-- ~ Addr_DDF_Upd:
-- =============================================================================
PROCEDURE Addr_DDF_Upd
         (p_address_id                   IN  Number
         ,p_business_group_id            IN  Number
         ,p_person_id                    IN  Number
         ,p_date_from                    IN  Date
         ,p_address_line1                IN  Varchar2
         ,p_address_line2                IN  Varchar2
         ,p_address_line3                IN  Varchar2
         ,p_address_type                 IN  Varchar2
         ,p_country                      IN  Varchar2
         ,p_date_to                      IN  Date
         ,p_postal_code                  IN  Varchar2
         ,p_region_1                     IN  Varchar2
         ,p_region_2                     IN  Varchar2
         ,p_region_3                     IN  Varchar2
         ,p_telephone_number_1           IN  Varchar2
         ,p_telephone_number_2           IN  Varchar2
         ,p_telephone_number_3           IN  Varchar2
         ,p_town_or_city                 IN  Varchar2
         ,p_add_information13            IN  Varchar2
         ,p_add_information14            IN  Varchar2
         ,p_add_information15            IN  Varchar2
         ,p_add_information16            IN  Varchar2
         ,p_add_information17            IN  Varchar2
         ,p_add_information18            IN  Varchar2
         ,p_add_information19            IN  Varchar2
         ,p_add_information20            IN  Varchar2
         ,p_object_version_number        IN  Number
         ,p_effective_date               IN  Date
         ,p_prflagval_override           IN  Boolean
         ,p_validate_county              IN  Boolean
         -- Old
         ,p_business_group_id_o          IN  Number
         ,p_person_id_o                  IN  Number
         ,p_date_from_o                  IN  Date
         ,p_primary_flag_o               IN  Varchar2
         ,p_style_o                      IN  Varchar2
         ,p_address_line1_o              IN  Varchar2
         ,p_address_line2_o              IN  Varchar2
         ,p_address_line3_o              IN  Varchar2
         ,p_address_type_o               IN  Varchar2
         ,p_country_o                    IN  Varchar2
         ,p_date_to_o                    IN  Date
         ,p_postal_code_o                IN  Varchar2
         ,p_region_1_o                   IN  Varchar2
         ,p_region_2_o                   IN  Varchar2
         ,p_region_3_o                   IN  Varchar2
         ,p_telephone_number_1_o         IN  Varchar2
         ,p_telephone_number_2_o         IN  Varchar2
         ,p_telephone_number_3_o         IN  Varchar2
         ,p_town_or_city_o               IN  Varchar2
         ,p_add_information13_o          IN  Varchar2
         ,p_add_information14_o          IN  Varchar2
         ,p_add_information15_o          IN  Varchar2
         ,p_add_information16_o          IN  Varchar2
         ,p_add_information17_o          IN  Varchar2
         ,p_add_information18_o          IN  Varchar2
         ,p_add_information19_o          IN  Varchar2
         ,p_add_information20_o          IN  Varchar2
         ,p_object_version_number_o      IN  Number
         ,p_party_id_o                   IN  Number
         );
-- =============================================================================
-- ~ Addr_DDF_Del:
-- =============================================================================
PROCEDURE Addr_DDF_Del
         (p_address_id                   IN  Number
         ,p_business_group_id_o          IN  Number
         ,p_date_from_o                  IN  Date
         ,p_address_line1_o              IN  Varchar2
         ,p_address_line2_o              IN  Varchar2
         ,p_address_line3_o              IN  Varchar2
         ,p_address_type_o               IN  Varchar2
         ,p_country_o                    IN  Varchar2
         ,p_date_to_o                    IN  Date
         ,p_postal_code_o                IN  Varchar2
         ,p_region_1_o                   IN  Varchar2
         ,p_region_2_o                   IN  Varchar2
         ,p_region_3_o                   IN  Varchar2
         ,p_telephone_number_1_o         IN  Varchar2
         ,p_telephone_number_2_o         IN  Varchar2
         ,p_telephone_number_3_o         IN  Varchar2
         ,p_town_or_city_o               IN  Varchar2
         ,p_add_information13_o          IN  Varchar2
         ,p_add_information14_o          IN  Varchar2
         ,p_add_information15_o          IN  Varchar2
         ,p_add_information16_o          IN  Varchar2
         ,p_add_information17_o          IN  Varchar2
         ,p_add_information18_o          IN  Varchar2
         ,p_add_information19_o          IN  Varchar2
         ,p_add_information20_o          IN  Varchar2
         ,p_object_version_number_o      IN  Number
         );

END PQP_Address_Synchronization;

 

/
