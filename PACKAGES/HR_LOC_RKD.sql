--------------------------------------------------------
--  DDL for Package HR_LOC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_RKD" AUTHID CURRENT_USER AS
/* $Header: hrlocrhi.pkh 120.1 2005/07/18 06:20:20 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_delete >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE after_delete
     (  p_location_id                     IN NUMBER,
--
    p_location_code_o                 IN VARCHAR2,
    p_address_line_1_o                IN VARCHAR2,
    p_address_line_2_o                IN VARCHAR2,
    p_address_line_3_o                IN VARCHAR2,
    p_bill_to_site_flag_o             IN VARCHAR2,
    p_country_o                       IN VARCHAR2,
    p_description_o                   IN VARCHAR2,
    p_designated_receiver_id_o        IN NUMBER,
    p_in_organization_flag_o          IN VARCHAR2,
    p_inactive_date_o                 IN DATE,
    p_inventory_organization_id_o     IN NUMBER,
    p_office_site_flag_o              IN VARCHAR2,
    p_postal_code_o                   IN VARCHAR2,
    p_receiving_site_flag_o           IN VARCHAR2,
    p_region_1_o                      IN VARCHAR2,
    p_region_2_o                      IN VARCHAR2,
    p_region_3_o                      IN VARCHAR2,
    p_ship_to_location_id_o           IN NUMBER,
    p_ship_to_site_flag_o             IN VARCHAR2,
    p_style_o                         IN VARCHAR2,
    p_tax_name_o                      IN VARCHAR2,
    p_telephone_number_1_o            IN VARCHAR2,
    p_telephone_number_2_o            IN VARCHAR2,
    p_telephone_number_3_o            IN VARCHAR2,
    p_town_or_city_o                  IN VARCHAR2,
        p_loc_information13_o             IN VARCHAR2,
        p_loc_information14_o             IN VARCHAR2,
        p_loc_information15_o             IN VARCHAR2,
        p_loc_information16_o             IN VARCHAR2,
    p_loc_information17_o             IN VARCHAR2,
    p_loc_information18_o             IN VARCHAR2,
    p_loc_information19_o             IN VARCHAR2,
    p_loc_information20_o             IN VARCHAR2,
    p_attribute_category_o            IN VARCHAR2,
    p_attribute1_o                    IN VARCHAR2,
    p_attribute2_o                    IN VARCHAR2,
    p_attribute3_o                    IN VARCHAR2,
    p_attribute4_o                    IN VARCHAR2,
    p_attribute5_o                    IN VARCHAR2,
    p_attribute6_o                    IN VARCHAR2,
    p_attribute7_o                    IN VARCHAR2,
    p_attribute8_o                    IN VARCHAR2,
    p_attribute9_o                    IN VARCHAR2,
    p_attribute10_o                   IN VARCHAR2,
    p_attribute11_o                   IN VARCHAR2,
    p_attribute12_o                   IN VARCHAR2,
    p_attribute13_o                   IN VARCHAR2,
    p_attribute14_o                   IN VARCHAR2,
    p_attribute15_o                   IN VARCHAR2,
    p_attribute16_o                   IN VARCHAR2,
    p_attribute17_o                   IN VARCHAR2,
    p_attribute18_o                   IN VARCHAR2,
    p_attribute19_o                   IN VARCHAR2,
    p_attribute20_o                   IN VARCHAR2,
    p_global_attribute_category_o     IN VARCHAR2,
    p_global_attribute1_o             IN VARCHAR2,
    p_global_attribute2_o             IN VARCHAR2,
    p_global_attribute3_o             IN VARCHAR2,
    p_global_attribute4_o             IN VARCHAR2,
    p_global_attribute5_o             IN VARCHAR2,
    p_global_attribute6_o             IN VARCHAR2,
    p_global_attribute7_o             IN VARCHAR2,
    p_global_attribute8_o             IN VARCHAR2,
    p_global_attribute9_o             IN VARCHAR2,
    p_global_attribute10_o            IN VARCHAR2,
    p_global_attribute11_o            IN VARCHAR2,
    p_global_attribute12_o            IN VARCHAR2,
    p_global_attribute13_o            IN VARCHAR2,
    p_global_attribute14_o            IN VARCHAR2,
    p_global_attribute15_o            IN VARCHAR2,
    p_global_attribute16_o            IN VARCHAR2,
    p_global_attribute17_o            IN VARCHAR2,
    p_global_attribute18_o            IN VARCHAR2,
    p_global_attribute19_o            IN VARCHAR2,
    p_global_attribute20_o            IN VARCHAR2,
   p_legal_address_flag_o              IN VARCHAR2,
    p_tp_header_id_o                  IN NUMBER,
    p_ece_tp_location_code_o          IN VARCHAR2,
    p_object_version_number_o         IN NUMBER,
    p_business_group_id_o             IN NUMBER
     );
--
END hr_loc_rkd;

 

/
