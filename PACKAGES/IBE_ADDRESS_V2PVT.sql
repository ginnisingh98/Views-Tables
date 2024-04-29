--------------------------------------------------------
--  DDL for Package IBE_ADDRESS_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_ADDRESS_V2PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVADS.pls 120.1 2005/11/23 04:59:14 mannamra noship $ */

  --
  -- Create an address by creating a location, a party site,
  -- a tax location assignment.
  --
  -- If p_primary_billto is true, a party site use whose
  -- site_use_type is 'BILL_TO' is created.  Same thing
  -- happens when p_primary_shipto is true.
  --
  -- If this is the first address for the party,
  -- the address will be the primary shipping and billing
  -- address.
  --
  -- If p_check_primary is true and there isn't any primary
  -- address, create the address as primary billing or shipping.
  --
  --
  -- Required:
  --   p_location.address1
  --   p_location.country
  --   p_party_site.party_id
  --

  PROCEDURE create_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_location           IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_party_site         IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_primary_billto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_primary_shipto     IN  VARCHAR2 := FND_API.G_FALSE,
  p_billto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_shipto             IN  VARCHAR2 := FND_API.G_FALSE,
  p_default_primary    IN  VARCHAR2 := FND_API.G_TRUE,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_location_id        OUT NOCOPY NUMBER,
  x_party_site_id      OUT NOCOPY NUMBER);


  --
  -- Update an address by end dating the party site and then
  -- creating a new location and party site.
  --
  -- This API also update the ibe_ord_oneclick table.
  --
  -- Required:
  --   p_location.address1
  --   p_location.country
  --   p_party_site.party_id
  --

PROCEDURE update_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_site_id      IN  NUMBER,
  p_ps_object_version_number  IN  NUMBER,
  p_bill_object_version_number  IN  NUMBER,
  p_ship_object_version_number  IN  NUMBER,
  p_location           IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  p_party_site         IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_primary_billto     IN  VARCHAR2 := NULL,
  p_primary_shipto     IN  VARCHAR2 := NULL,
  p_billto         IN  VARCHAR2 := NULL,
  p_shipto         IN  VARCHAR2 := NULL,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  x_location_id        OUT NOCOPY NUMBER,
  x_party_site_id      OUT NOCOPY NUMBER);

  --
  -- Delete an address by end dating a party site.
  -- Any party site use has foreign key to the party site
  -- is also end dated.
  --
  -- This API also set the bill_to_pty_site_id or
  -- ship_to_pty_site_id to null in table ibe_ord_oneclick.
  --
PROCEDURE delete_address(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_id           IN  NUMBER,
  p_party_site_id      IN  NUMBER,
  p_ps_object_version_number   IN  NUMBER,
  p_bill_object_version_number   IN  NUMBER,
  p_ship_object_version_number   IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2);

  --
  -- Set an address to primary or not.
  --
  -- Requried:
  --   p_site_use_type = 'SHIP_TO' or 'BILL_TO'
  --   p_primary = true if primary, otherwise false
  --

  procedure set_address_usage(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_party_site_id      IN  NUMBER,
    p_primary_flag	     IN  VARCHAR2 := FND_API.G_FALSE,
    p_site_use_type      IN  VARCHAR2,
    p_createdby          IN  VARCHAR2 := 'User Management',
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_party_site_use_id  OUT NOCOPY NUMBER
  );

  --
  -- Get the party site ID of the primary address
  -- whose site use type is the value of p_site_use_type.
  --

  procedure get_primary_address(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_party_id           IN  NUMBER,
    p_site_use_type      IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_party_site_id      OUT NOCOPY NUMBER,
    x_location_id        OUT NOCOPY NUMBER
  );

  --
  -- Get the party Site Id of the primary address
  -- whose site use type is the value of p_site_use_type
  -- In this query we are trying to address 2 possible scenarios
  -- 1. if nothing is defined for hz_organization_information,
  --    any country is allowed.
  -- 2. if country is defined for hz_organization_information,
  --    country from hz_party_sites_v needs to be defined in
  --    hz_organization_information
  --
  --    added by madesai 7/29/02
  --

  procedure get_primary_addr_id(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_party_id           IN  NUMBER,
    p_site_use_type      IN  VARCHAR2,
    p_org_id		 IN  NUMBER,
    p_get_org_prim_addr  IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_party_site_id      OUT NOCOPY NUMBER
    );

  procedure get_primary_addr_details(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
    p_party_id           IN  NUMBER,
    p_site_use_type      IN  VARCHAR2,
    p_org_id		 IN  NUMBER,
    p_alt_party_id       IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_party_site_id      OUT NOCOPY NUMBER,
    x_party_id           OUT NOCOPY NUMBER
    );

  procedure valid_usages (
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_party_site_id      IN NUMBER,
    p_operating_unit_id  IN NUMBER,
    p_usage_codes        IN JTF_VARCHAR2_TABLE_100,
    x_return_codes       OUT NOCOPY JTF_VARCHAR2_TABLE_100,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
  );

  PROCEDURE copy_party_site (
  p_api_version   IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
  p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
  p_party_site    IN  HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE,
  p_location      IN  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE,
  x_party_site_id OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2);




END IBE_ADDRESS_V2PVT;

 

/
