--------------------------------------------------------
--  DDL for Package CSP_SHIP_TO_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_SHIP_TO_ADDRESS_PVT" AUTHID CURRENT_USER AS
/*$Header: cspvstas.pls 120.0.12010000.10 2013/06/21 05:54:09 rrajain ship $*/
--Start of comments
--
-- API name	: CSP_SHIP_TO_ADDRESS_PVT
-- Type		: Private
-- Purpose	: Add an inventory location.
--            Modify an inventory location.
--            Create site location, inventory location, party, party site, party site use, customer account,
--            customer profile, customer account site, customer account site use, location association
--            for a ship to address (customer address, engineer address, or a special ship to address).
--            It will create records in related tables so Order Entry can pick up the right ship to address and
--            customer at the later time.
-- Modification History
-- Person      Date         Comments
-- ---------   -----------  ------------------------------------------
-- iouyang     01-May-2001  New
--


-- Create locations, party, party site, party site use, customer, customer account site,
-- customer account site use, ... OE can utilize these records later for Spares Orders.
-- All calls should go through ship_to_address_handler.  It will create/modify inventory location
-- (ship to address) and create/modify customer profile, party site, site locationa, and site uses.

-- The address information passed in must be validated before passing in.  It will not create
-- an inventory location if the address is not valid.  Required fields are varied depends on
-- the country.  The country field is used to check if there is a address passed in.

g_rs_cust_relation_id   number;
g_inv_loc_id  number;

PROCEDURE ship_to_address_handler
   (p_task_assignment_id      IN NUMBER
   ,p_resource_type           IN VARCHAR2
   ,p_resource_id             IN NUMBER
   ,p_customer_id             OUT NOCOPY NUMBER
   ,p_location_id             IN OUT NOCOPY NUMBER
   ,p_style                   IN VARCHAR2
   ,p_address_line_1          IN VARCHAR2
   ,p_address_line_2          IN VARCHAR2
   ,p_address_line_3          IN VARCHAR2
   ,p_country                 IN VARCHAR2
   ,p_postal_code             IN VARCHAR2
   ,p_region_1                IN VARCHAR2
   ,p_region_2                IN VARCHAR2
   ,p_region_3                IN VARCHAR2
   ,p_town_or_city            IN VARCHAR2
   ,p_tax_name                IN VARCHAR2
   ,p_telephone_number_1      IN VARCHAR2
   ,p_telephone_number_2      IN VARCHAR2
   ,p_telephone_number_3      IN VARCHAR2
   ,p_loc_information13       IN VARCHAR2
   ,p_loc_information14       IN VARCHAR2
   ,p_loc_information15       IN VARCHAR2
   ,p_loc_information16       IN VARCHAR2
   ,p_loc_information17       IN VARCHAR2
   ,p_loc_information18       IN VARCHAR2
   ,p_loc_information19       IN VARCHAR2
   ,p_loc_information20       IN VARCHAR2
   ,p_timezone                IN VARCHAR2
   ,p_primary_flag            IN VARCHAR2
   ,p_status                  IN VARCHAR2
   ,p_object_version_number   IN OUT NOCOPY NUMBER
   ,p_api_version_number      IN NUMBER
   ,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
   ,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
   ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
   ,p_bill_to_create		  IN VARCHAR2 := 'Y'
   ,p_province                IN VARCHAR2 DEFAULT NULL
   ,p_address_lines_phonetic  IN VARCHAR2 DEFAULT NULL
   ,p_address_line_4          IN VARCHAR2 DEFAULT NULL
   ,P_HZ_LOCATION_ID          IN NUMBER DEFAULT NULL
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   );

PROCEDURE ship_to_address_handler
   (p_resource_type           IN VARCHAR2
   ,p_resource_id             IN NUMBER
   ,p_location_id             IN OUT NOCOPY NUMBER
   ,p_timezone                IN VARCHAR2
   ,p_primary_flag            IN VARCHAR2
   ,p_status                  IN VARCHAR2
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   );


-- Create a new inventory location as a ship to address.
PROCEDURE do_create_ship_to_location
   (p_location_id            OUT NOCOPY NUMBER
   ,p_style                  IN VARCHAR2
   ,p_address_line_1         IN VARCHAR2
   ,p_address_line_2         IN VARCHAR2
   ,p_address_line_3         IN VARCHAR2
   ,p_country                IN VARCHAR2
   ,p_postal_code            IN VARCHAR2
   ,p_region_1               IN VARCHAR2
   ,p_region_2               IN VARCHAR2
   ,p_region_3               IN VARCHAR2
   ,p_town_or_city           IN VARCHAR2
   ,p_tax_name               IN VARCHAR2
   ,p_telephone_number_1     IN VARCHAR2
   ,p_telephone_number_2     IN VARCHAR2
   ,p_telephone_number_3     IN VARCHAR2
   ,p_loc_information13      IN VARCHAR2
   ,p_loc_information14      IN VARCHAR2
   ,p_loc_information15      IN VARCHAR2
   ,p_loc_information16      IN VARCHAR2
   ,p_loc_information17      IN VARCHAR2
   ,p_loc_information18      IN VARCHAR2
   ,p_loc_information19      IN VARCHAR2
   ,p_loc_information20      IN VARCHAR2
   ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
   ,p_object_version_number  OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
   );


-- Update an existing inventory location.
PROCEDURE do_update_ship_to_location
   (p_location_id            IN NUMBER
   ,p_style                   IN VARCHAR2
   ,p_address_line_1         IN VARCHAR2
   ,p_address_line_2         IN VARCHAR2
   ,p_address_line_3         IN VARCHAR2
   ,p_country                IN VARCHAR2
   ,p_postal_code            IN VARCHAR2
   ,p_region_1               IN VARCHAR2
   ,p_region_2               IN VARCHAR2
   ,p_region_3               IN VARCHAR2
   ,p_town_or_city           IN VARCHAR2
   ,p_tax_name               IN VARCHAR2
   ,p_telephone_number_1     IN VARCHAR2
   ,p_telephone_number_2     IN VARCHAR2
   ,p_telephone_number_3     IN VARCHAR2
   ,p_loc_information13      IN VARCHAR2
   ,p_loc_information14      IN VARCHAR2
   ,p_loc_information15      IN VARCHAR2
   ,p_loc_information16      IN VARCHAR2
   ,p_loc_information17      IN VARCHAR2
   ,p_loc_information18      IN VARCHAR2
   ,p_loc_information19      IN VARCHAR2
   ,p_loc_information20      IN VARCHAR2
   ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
   ,p_object_version_number  IN OUT NOCOPY NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
   );


-- Create rsource and customer relationship
PROCEDURE do_rs_cust_relations
   (p_resource_type         IN VARCHAR2
   ,p_resource_id           IN NUMBER
   ,p_customer_id           IN NUMBER
   );



-- Create site use and link it to an inventory location.
PROCEDURE do_create_site_use
   (p_customer_id            IN NUMBER
   ,p_party_id               IN NUMBER
   ,p_address_id             IN NUMBER
   ,p_location_id            IN NUMBER
   ,p_inv_location_id        IN NUMBER
   ,p_primary_flag           IN VARCHAR2
   ,p_status                 IN VARCHAR2
   ,p_bill_to_create		  IN VARCHAR2 := 'Y'
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
   );


-- Update site use.
PROCEDURE do_update_site_use
   (p_site_use_id            IN NUMBER
   ,p_primary_flag           IN VARCHAR2
   ,p_status                 IN VARCHAR2
   ,p_customer_id            IN NUMBER
   ,p_inv_location_id        IN NUMBER
   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2 );


-- This procedure will create a new inventory location and link the
-- site use id passed in to the new inventory location.
-- Before calling this proceudre, make sure the site_use is not linked to
-- any inventory location yet.
--
PROCEDURE site_to_invloc_linkage
  (p_customer_id             IN NUMBER
  ,p_address_id              IN NUMBER
  ,p_site_use_id             IN NUMBER
  ,p_location_id             OUT NOCOPY NUMBER
  ,p_style                   IN VARCHAR2
  ,p_address_line_1          IN VARCHAR2
  ,p_address_line_2          IN VARCHAR2
  ,p_address_line_3          IN VARCHAR2
  ,p_country                 IN VARCHAR2
  ,p_postal_code             IN VARCHAR2
  ,p_region_1                IN VARCHAR2
  ,p_region_2                IN VARCHAR2
  ,p_region_3                IN VARCHAR2
  ,p_town_or_city            IN VARCHAR2
  ,p_tax_name                IN VARCHAR2
  ,p_telephone_number_1      IN VARCHAR2
  ,p_telephone_number_2      IN VARCHAR2
  ,p_telephone_number_3      IN VARCHAR2
  ,p_loc_information13       IN VARCHAR2
  ,p_loc_information14       IN VARCHAR2
  ,p_loc_information15       IN VARCHAR2
  ,p_loc_information16       IN VARCHAR2
  ,p_loc_information17       IN VARCHAR2
  ,p_loc_information18       IN VARCHAR2
  ,p_loc_information19       IN VARCHAR2
  ,p_loc_information20       IN VARCHAR2
  ,p_api_version_number      IN NUMBER
  ,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
  ,p_attribute_category     IN VARCHAR2
   ,p_attribute1             IN VARCHAR2
   ,p_attribute2             IN VARCHAR2
   ,p_attribute3             IN VARCHAR2
   ,p_attribute4             IN VARCHAR2
   ,p_attribute5             IN VARCHAR2
   ,p_attribute6             IN VARCHAR2
   ,p_attribute7             IN VARCHAR2
   ,p_attribute8             IN VARCHAR2
   ,p_attribute9             IN VARCHAR2
   ,p_attribute10             IN VARCHAR2
   ,p_attribute11             IN VARCHAR2
   ,p_attribute12             IN VARCHAR2
   ,p_attribute13            IN VARCHAR2
   ,p_attribute14             IN VARCHAR2
   ,p_attribute15             IN VARCHAR2
   ,p_attribute16             IN VARCHAR2
   ,p_attribute17             IN VARCHAR2
   ,p_attribute18             IN VARCHAR2
   ,p_attribute19             IN VARCHAR2
   ,p_attribute20             IN VARCHAR2
  ,x_return_status           OUT NOCOPY VARCHAR2
  ,x_msg_count               OUT NOCOPY NUMBER
  ,x_msg_data                OUT NOCOPY VARCHAR2
  );
   PROCEDURE call_internal_hook (
      p_package_name      IN       VARCHAR2,
      p_api_name          IN       VARCHAR2,
      p_processing_type   IN       VARCHAR2,
      x_return_status     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE cust_inv_loc_link
   (     p_api_version              IN NUMBER
        ,p_Init_Msg_List            IN VARCHAR2     := FND_API.G_FALSE
        ,p_commit                   IN VARCHAR2     := FND_API.G_FALSE
        ,px_location_id             IN OUT NOCOPY NUMBER
        ,p_party_site_id            IN NUMBER
        ,p_cust_account_id          IN NUMBER
        ,p_customer_id              IN NUMBER
		,p_org_id					IN NUMBER		:= NULL
        ,p_attribute_category       IN VARCHAR2
        ,p_attribute1               IN VARCHAR2
        ,p_attribute2               IN VARCHAR2
        ,p_attribute3               IN VARCHAR2
        ,p_attribute4               IN VARCHAR2
        ,p_attribute5               IN VARCHAR2
        ,p_attribute6               IN VARCHAR2
        ,p_attribute7               IN VARCHAR2
        ,p_attribute8               IN VARCHAR2
        ,p_attribute9               IN VARCHAR2
        ,p_attribute10              IN VARCHAR2
        ,p_attribute11              IN VARCHAR2
        ,p_attribute12              IN VARCHAR2
        ,p_attribute13              IN VARCHAR2
        ,p_attribute14              IN VARCHAR2
        ,p_attribute15              IN VARCHAR2
        ,p_attribute16              IN VARCHAR2
        ,p_attribute17              IN VARCHAR2
        ,p_attribute18              IN VARCHAR2
        ,p_attribute19              IN VARCHAR2
        ,p_attribute20              IN VARCHAR2
        ,x_return_status            OUT NOCOPY VARCHAR2
        ,x_msg_count                OUT NOCOPY NUMBER
        ,x_msg_data                 OUT NOCOPY VARCHAR2
    );

	-- bug # 8333969
   PROCEDURE rs_primary_ship_to_addr
	(
      p_api_version        IN NUMBER
      ,p_Init_Msg_List     IN VARCHAR2     := FND_API.G_FALSE
      ,p_commit            IN VARCHAR2     := FND_API.G_FALSE
      ,p_rs_type				IN	VARCHAR2
      ,p_rs_id					IN	NUMBER
      ,p_rs_site_use_id		IN	NUMBER
      ,x_return_status     OUT NOCOPY VARCHAR2
      ,x_msg_count         OUT NOCOPY NUMBER
      ,x_msg_data          OUT NOCOPY VARCHAR2
	);

   PROCEDURE rs_inactivate_ship_to
   (
      p_api_version        IN NUMBER
      ,p_Init_Msg_List     IN VARCHAR2     := FND_API.G_FALSE
      ,p_commit            IN VARCHAR2     := FND_API.G_FALSE
      ,p_rs_type				IN	VARCHAR2
      ,p_rs_id					IN	NUMBER
      ,p_rs_site_use_id		IN	NUMBER
      ,x_return_status     OUT NOCOPY VARCHAR2
      ,x_msg_count         OUT NOCOPY NUMBER
      ,x_msg_data          OUT NOCOPY VARCHAR2
   );

	procedure copy_hz_cust_site (
		p_src_org_id				IN NUMBER
		,p_dest_org_id				IN NUMBER
		,p_cust_site_id				IN NUMBER
		,p_hr_location_id			IN NUMBER
		,p_customer_id				IN NUMBER
		,x_return_status           OUT NOCOPY VARCHAR2
		,x_msg_count               OUT NOCOPY NUMBER
		,x_msg_data                OUT NOCOPY VARCHAR2
		);

END CSP_SHIP_TO_ADDRESS_PVT;

/
