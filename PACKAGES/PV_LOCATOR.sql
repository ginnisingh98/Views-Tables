--------------------------------------------------------
--  DDL for Package PV_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_LOCATOR" AUTHID CURRENT_USER AS
/* $Header: pvxvlcrs.pls 115.15 2003/02/25 01:23:47 amaram ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='PV_LOCATOR';

TYPE party_address_rec_type IS RECORD
(
   PARTY_RELATION_ID	HZ_PARTIES.PARTY_ID%TYPE,
   PARTY_NAME		HZ_PARTIES.PARTY_NAME%TYPE,
   LOCATION_ID		HZ_LOCATIONS.LOCATION_ID%TYPE,
   ADDRESS_LINE1	HZ_LOCATIONS.ADDRESS1%TYPE,
   ADDRESS_LINE2	HZ_LOCATIONS.ADDRESS2%TYPE,
   ADDRESS_LINE3	HZ_LOCATIONS.ADDRESS3%TYPE,
   CITY			HZ_LOCATIONS.CITY%TYPE,
   STATE		HZ_LOCATIONS.STATE%TYPE,
   COUNTRY		HZ_LOCATIONS.COUNTRY%TYPE,
   POSTAL_CODE		HZ_LOCATIONS.POSTAL_CODE%TYPE,
   DISTANCE		NUMBER,
   DISTANCE_UNIT        VARCHAR2(10)
);


type party_address_rec_tbl is TABLE OF party_address_rec_type INDEX BY BINARY_INTEGER;

--getting some profile values related to tcp proticol like proxy, sontent types
g_input_content_type	CONSTANT VARCHAR2(100):= nvl(fnd_profile.value('PV_LOCATOR_XML_CONTENT_TYPE'), 'application/x-www-form-urlencoded');
--g_proxy_server		CONSTANT VARCHAR2(120):=nvl(fnd_profile.value('PV_LOCATOR_PROXY_SERVER'), 'www-proxy.us.oracle.com');
--g_proxy_port		CONSTANT NUMBER:=to_number(nvl(fnd_profile.value('PV_LOCATOR_PROXY_PORT'), '80'));


g_proxy_server		CONSTANT VARCHAR2(120):=fnd_profile.value('PV_LOCATOR_PROXY_SERVER');
g_proxy_port		CONSTANT NUMBER:=to_number(fnd_profile.value('PV_LOCATOR_PROXY_PORT'));

--g_route_url		CONSTANT VARCHAR2(128) := nvl(fnd_profile.value('PV_LOCATOR_URL_MULTI'), 'http://nh2p1.us.oracle.com:8888/servlet/routem');
g_geocode_url		CONSTANT VARCHAR2(128) := nvl(fnd_profile.value('PV_LOCATOR_URL'), 'http://elocation.us.oracle.com/servlets/lbs');
g_route_url		CONSTANT VARCHAR2(128) := nvl(fnd_profile.value('PV_LOCATOR_URL'), 'http://elocation.us.oracle.com/servlets/lbs');
--getting server related  profile values
g_skip_server		CONSTANT VARCHAR(1)	:=nvl(fnd_profile.value('PV_SKIP_ELOCATION_FOR_MATCHING'), 'N');

g_distance_unit_mile	CONSTANT VARCHAR2(30)	:='mile';
g_distance_unit_km	CONSTANT VARCHAR2(30)	:='km';
g_distance_unit_meter	CONSTANT VARCHAR2(30)	:='meter';

--g_distance_unit_mile	CONSTANT VARCHAR2(30)	:=nvl(fnd_profile.value('PV_LOCATOR_DISTANCE_UNIT_MILE'), 'mile');
--g_distance_unit_km	CONSTANT VARCHAR2(30)	:=nvl(fnd_profile.value('PV_LOCATOR_DISTANCE_UNIT_KM'), 'km');
--g_distance_unit_meter	CONSTANT VARCHAR2(30)	:=nvl(fnd_profile.value('PV_LOCATOR_DISTANCE_UNIT_METER'), 'meter');



--getting some geometry related profile values that will be used in making geometry object
g_geometry_param1	CONSTANT NUMBER	:=2001;
g_geometry_param2	CONSTANT NUMBER	:=8307;


g_miles_per_meter	CONSTANT NUMBER		:=0.000621;
g_meters_per_km		CONSTANT NUMBER		:=1000;

--getting some spatial related profile values that will be used in distance finding function
--g_pi_value		CONSTANT VARCHAR2(30)	:=3.1415926535897932;
--g_torad_degree		CONSTANT VARCHAR2(30)	:=180.0;
--g_earth_radious		CONSTANT VARCHAR2(30)	:=6371007.000;



---------------------------------------------------------------------
-- PROCEDURE
--    get_partners
--
-- PURPOSE
--    Based on the starting address, the API finds the all the partners
--    limited by the max number of partner returned within the distance provided
--    This API is used from the wrapper API for locator and opportunity matching
--
-- PARAMETERS
--    p_party_address_rec: the record to hold customer address.
--    p_partner_tbl: returns the list of partners sorted based on the distance
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE Get_Partners(
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2  := FND_API.g_false
  ,p_commit                 IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full

  ,p_customer_address       IN  party_address_rec_type
  ,p_partner_tbl            IN  JTF_NUMBER_TABLE
  ,p_max_no_partners        IN  NUMBER
  ,p_distance               IN  NUMBER
  ,p_distance_unit          IN  VARCHAR2
  ,p_sort_by_distance       IN  VARCHAR2 := 'T'
  ,x_partner_tbl            OUT  NOCOPY JTF_NUMBER_TABLE
  ,x_distance_tbl           OUT  NOCOPY JTF_NUMBER_TABLE
  ,x_distance_unit          OUT  NOCOPY VARCHAR2
  ,x_return_status          OUT  NOCOPY VARCHAR2
  ,x_msg_count              OUT  NOCOPY NUMBER
  ,x_msg_data               OUT  NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    get_locator_partners
--
-- PURPOSE
--    Based on the starting address, the API finds the all the partners
--    limited by the max number of partner returned within the distance provided
--    This API is used from the wrapper API for locator and opportunity matching
--
-- PARAMETERS
--    p_party_address_rec: the record to hold customer address.
--    p_partner_tbl: returns the list of partners sorted based on the distance
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE Get_Locator_Partners(
  p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2  := FND_API.g_false
  ,p_commit                 IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full
  ,p_customer_address1      IN  HZ_LOCATIONS.ADDRESS1%TYPE
  ,p_customer_address2      IN  HZ_LOCATIONS.ADDRESS2%TYPE
  ,p_customer_address3      IN  HZ_LOCATIONS.ADDRESS3%TYPE
  ,p_customer_city          IN  HZ_LOCATIONS.CITY%TYPE
  ,p_customer_state         IN  HZ_LOCATIONS.STATE%TYPE
  ,p_customer_country       IN  HZ_LOCATIONS.COUNTRY%TYPE
  ,p_customer_postalcode    IN  HZ_LOCATIONS.POSTAL_CODE%TYPE
  ,p_customer_lattitude	    IN  VARCHAR2
  ,p_customer_longitude     IN  VARCHAR2
  ,p_max_no_partners        IN  NUMBER
  ,p_distance               IN  NUMBER
  ,p_distance_unit          IN  VARCHAR2
  ,p_sql_query              IN  VARCHAR2
  ,p_attr_id_tbl	    IN  OUT NOCOPY JTF_NUMBER_TABLE
  ,p_attr_value_tbl	    IN  OUT NOCOPY JTF_VARCHAR2_TABLE_4000
  ,p_attr_operator_tbl	    IN  OUT NOCOPY JTF_VARCHAR2_TABLE_100
  ,p_attr_data_type_tbl     IN  OUT NOCOPY JTF_VARCHAR2_TABLE_100
  ,x_partner_tbl            OUT NOCOPY  JTF_NUMBER_TABLE
  ,x_distance_tbl           OUT NOCOPY  JTF_NUMBER_TABLE
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2

);
---------------------------------------------------------------------
-- PROCEDURE
--    get_partners_from_elocation
--
-- PURPOSE
--
--
-- PARAMETERS
--    p_party_address_rec: the record to hold customer address.
--    p_partner_tbl: returns the list of partners sorted based on the distance
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE Get_Partners_From_ELocation(
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2  := FND_API.g_false
  ,p_commit                 IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level       IN  NUMBER    := FND_API.g_valid_level_full

  ,p_customer_address       IN  party_address_rec_type
  ,p_partner_tbl            IN  party_address_rec_tbl
  ,p_max_no_partners        IN  NUMBER
  ,p_distance               IN  NUMBER
  ,p_distance_unit          IN  VARCHAR2
  ,p_sort_by_distance       IN  VARCHAR2 := 'T'
  ,x_partner_tbl            OUT  NOCOPY  party_address_rec_tbl
  ,x_return_status          OUT  NOCOPY VARCHAR2
  ,x_msg_count              OUT  NOCOPY NUMBER
  ,x_msg_data               OUT  NOCOPY VARCHAR2
);

 --------------------------------------------------------------------------------
  --
  -- This routine computes the distance between two point geometries
  --
  --             mdsys.sdo_geometry         geom1,  The first  geometry
  --             mdsys.sdo_geometry         geom2,  The second geometry
  --
  --------------------------------------------------------------------------------
FUNCTION geocode_distance (geom1      MDSYS.SDO_GEOMETRY,
                          geom2      MDSYS.SDO_GEOMETRY,
			  distance_unit	VARCHAR2   )
RETURN NUMBER  DETERMINISTIC;


FUNCTION address_to_geometry(	name     VARCHAR2,
				street   VARCHAR2,
				city     VARCHAR2,
				state    VARCHAR2,
				zip_code VARCHAR2)
RETURN MDSYS.SDO_GEOMETRY DETERMINISTIC;

END PV_LOCATOR;


 

/
