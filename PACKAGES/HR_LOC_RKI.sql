--------------------------------------------------------
--  DDL for Package HR_LOC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_RKI" AUTHID CURRENT_USER AS
/* $Header: hrlocrhi.pkh 120.1 2005/07/18 06:20:20 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< after_insert >-------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE after_insert
  (
   p_effective_date                IN DATE,
   p_location_id                   IN NUMBER,
   p_location_code                 IN VARCHAR2,
   p_timezone_code                 IN VARCHAR2,
   p_address_line_1                IN VARCHAR2,
   p_address_line_2                IN VARCHAR2,
   p_address_line_3                IN VARCHAR2,
   p_bill_to_site_flag             IN VARCHAR2,
   p_country                       IN VARCHAR2,
   p_description                   IN VARCHAR2,
   p_designated_receiver_id        IN NUMBER,
   p_in_organization_flag          IN VARCHAR2,
   p_inactive_date                 IN DATE,
   p_inventory_organization_id     IN NUMBER,
   p_office_site_flag              IN VARCHAR2,
   p_postal_code                   IN VARCHAR2,
   p_receiving_site_flag           IN VARCHAR2,
   p_region_1                      IN VARCHAR2,
   p_region_2                      IN VARCHAR2,
   p_region_3                      IN VARCHAR2,
   p_ship_to_location_id           IN NUMBER,
   p_ship_to_site_flag             IN VARCHAR2,
   p_style                         IN VARCHAR2,
   p_tax_name                      IN VARCHAR2,
   p_telephone_number_1            IN VARCHAR2,
   p_telephone_number_2            IN VARCHAR2,
   p_telephone_number_3            IN VARCHAR2,
   p_town_or_city                  IN VARCHAR2,
   p_loc_information13             IN VARCHAR2,
   p_loc_information14             IN VARCHAR2,
   p_loc_information15             IN VARCHAR2,
   p_loc_information16             IN VARCHAR2,
   p_loc_information17             IN VARCHAR2,
   p_loc_information18             IN VARCHAR2,
   p_loc_information19             IN VARCHAR2,
   p_loc_information20             IN VARCHAR2,
   p_attribute_category            IN VARCHAR2,
   p_attribute1                    IN VARCHAR2,
   p_attribute2                    IN VARCHAR2,
   p_attribute3                    IN VARCHAR2,
   p_attribute4                    IN VARCHAR2,
   p_attribute5                    IN VARCHAR2,
   p_attribute6                    IN VARCHAR2,
   p_attribute7                    IN VARCHAR2,
   p_attribute8                    IN VARCHAR2,
   p_attribute9                    IN VARCHAR2,
   p_attribute10                   IN VARCHAR2,
   p_attribute11                   IN VARCHAR2,
   p_attribute12                   IN VARCHAR2,
   p_attribute13                   IN VARCHAR2,
   p_attribute14                   IN VARCHAR2,
   p_attribute15                   IN VARCHAR2,
   p_attribute16                   IN VARCHAR2,
   p_attribute17                   IN VARCHAR2,
   p_attribute18                   IN VARCHAR2,
   p_attribute19                   IN VARCHAR2,
   p_attribute20                   IN VARCHAR2,
   p_global_attribute_category     IN VARCHAR2,
   p_global_attribute1             IN VARCHAR2,
   p_global_attribute2             IN VARCHAR2,
   p_global_attribute3             IN VARCHAR2,
   p_global_attribute4             IN VARCHAR2,
   p_global_attribute5             IN VARCHAR2,
   p_global_attribute6             IN VARCHAR2,
   p_global_attribute7             IN VARCHAR2,
   p_global_attribute8             IN VARCHAR2,
   p_global_attribute9             IN VARCHAR2,
   p_global_attribute10            IN VARCHAR2,
   p_global_attribute11            IN VARCHAR2,
   p_global_attribute12            IN VARCHAR2,
   p_global_attribute13            IN VARCHAR2,
   p_global_attribute14            IN VARCHAR2,
   p_global_attribute15            IN VARCHAR2,
   p_global_attribute16            IN VARCHAR2,
   p_global_attribute17            IN VARCHAR2,
   p_global_attribute18            IN VARCHAR2,
   p_global_attribute19            IN VARCHAR2,
   p_global_attribute20            IN VARCHAR2,
   p_legal_address_flag             IN VARCHAR2,
   p_tp_header_id                  IN NUMBER,
   p_ece_tp_location_code          IN VARCHAR2,
   p_object_version_number         IN NUMBER,
   p_business_group_id             IN NUMBER
  );
--
end hr_loc_rki;

 

/
