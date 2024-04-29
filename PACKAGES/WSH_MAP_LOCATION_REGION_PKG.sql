--------------------------------------------------------
--  DDL for Package WSH_MAP_LOCATION_REGION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_MAP_LOCATION_REGION_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHMLORS.pls 120.4.12010000.3 2009/04/01 08:30:36 ueshanka ship $ */

g_loc_commit    VARCHAR2(1) := 'Y';
--R12.1.1 Standalone Project
g_mode          VARCHAR2(10) := 'NORMAL';

TYPE loc_rec_type IS RECORD(
      WSH_LOCATION_ID         WSH_LOCATIONS.WSH_LOCATION_ID%TYPE,
      SOURCE_LOCATION_ID      WSH_LOCATIONS.SOURCE_LOCATION_ID%TYPE,
      LOCATION_SOURCE_CODE    WSH_LOCATIONS.LOCATION_SOURCE_CODE%TYPE,
      LOCATION_CODE           WSH_LOCATIONS.LOCATION_CODE%TYPE,
      UI_LOCATION_CODE        WSH_LOCATIONS.UI_LOCATION_CODE%TYPE,
      ADDRESS1                WSH_LOCATIONS.ADDRESS1%TYPE,
      ADDRESS2                WSH_LOCATIONS.ADDRESS2%TYPE,
      ADDRESS3                WSH_LOCATIONS.ADDRESS3%TYPE,
      ADDRESS4                WSH_LOCATIONS.ADDRESS4%TYPE,
      COUNTRY                 WSH_LOCATIONS.COUNTRY%TYPE,
      STATE                   WSH_LOCATIONS.STATE%TYPE,
      PROVINCE                WSH_LOCATIONS.PROVINCE%TYPE,
      COUNTY                  WSH_LOCATIONS.COUNTY%TYPE,
      CITY                    WSH_LOCATIONS.CITY%TYPE,
      POSTAL_CODE             WSH_LOCATIONS.POSTAL_CODE%TYPE,
      INACTIVE_DATE           WSH_LOCATIONS.INACTIVE_DATE%TYPE);

TYPE TableNumbers  is TABLE of NUMBER  INDEX BY BINARY_INTEGER; -- table number type
TYPE TableVarchar  is TABLE of VARCHAR2(120) INDEX BY BINARY_INTEGER; -- table varchar(120) type
TYPE TableDate     is TABLE of DATE INDEX BY BINARY_INTEGER; -- table date type
TYPE TableBoolean  is TABLE of BOOLEAN INDEX BY BINARY_INTEGER; -- table boolean type

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Map_Locations                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This procedure selects the minimum and maximum location id   |
 |              and fires the child concurrent program depending on the      |
 |              value of parameter p_num_of_instances                        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Map_Locations (
    p_errbuf              OUT NOCOPY   VARCHAR2,
    p_retcode             OUT NOCOPY   NUMBER,
    p_map_regions         IN   VARCHAR2,
    p_location_type       IN   VARCHAR2,
    p_num_of_instances    IN   NUMBER,
    p_start_date          IN   VARCHAR2,
    p_end_date            IN   VARCHAR2,
    p_fte_installed       IN   VARCHAR2 default NULL,
    p_create_facilities   IN   VARCHAR2 default NULL);

/*===========================================================================+
| PROCEDURE                                                                 |
|              Map_Location_Child_Program                                   |
|                                                                           |
| DESCRIPTION                                                               |
|              This is just a wrapper routine and call the main processing  |
|              API Mapping_Main. This procedure is also by the TCA Callout  |
|              API Rule_Location.                                           |
|                                                                           |
+===========================================================================*/

PROCEDURE Map_Locations_Child_Program (
    p_errbuf              OUT NOCOPY   VARCHAR2,
    p_retcode             OUT NOCOPY   NUMBER,
    p_location_type       IN   VARCHAR2,
    p_map_regions         IN   VARCHAR2,
    p_from_location       IN   NUMBER,
    p_to_location         IN   NUMBER,
    p_start_date          IN   VARCHAR2,
    p_end_date            IN   VARCHAR2,
    p_create_facilities	  IN   VARCHAR2 default NULL) ;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Mapping_Regions_Main                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API selects all the location data into PL/SQL table     |
 |              types and calls the Map_Location_To_Region by passing the    |
 |              location information                                         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Mapping_Regions_Main (
    p_location_type    IN   VARCHAR2,
    p_from_location    IN   NUMBER,
    p_to_location      IN   NUMBER,
    p_start_date       IN   VARCHAR2,
    p_end_date         IN   VARCHAR2,
    p_insert_flag      IN   BOOLEAN default TRUE, -- Bug 4722963
    x_return_status    OUT NOCOPY   VARCHAR2,
    x_sqlcode          OUT NOCOPY   NUMBER,
    x_sqlerr           OUT NOCOPY   VARCHAR2);

/*===========================================================================+
 | FUNCTION                                                                  |
 |              Insert_Record                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API inserts the record into intersection table     |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Insert_Record
  (
    p_location_id         IN   NUMBER,
    p_region_id           IN   NUMBER,
    p_region_type         IN   NUMBER,
    p_exception           IN   VARCHAR2,
    p_location_source     IN   VARCHAR2,
    p_parent_region       IN   VARCHAR2,
    x_return_status       OUT NOCOPY   VARCHAR2
   );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Map_Location_To_Region                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This API does the main mapping process. It calls the API     |
 |              WSH_REGIONS_SEARCH_PKG.Get_Region_Info which inturn returns  |
 |              the region id. For this particuar region, the parent regions |
 |              are also obtained and all these are inserted into the        |
 |              intersection table.                                          |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Map_Location_To_Region (
       p_country            IN   VARCHAR2,
       p_country_code       IN   VARCHAR2,
       p_state              IN   VARCHAR2,
       p_city               IN   VARCHAR2,
       p_postal_code        IN   VARCHAR2,
       p_location_id        IN   NUMBER,
       p_location_source    IN   VARCHAR2,
       p_inactive_date      IN   DATE,
       p_insert_flag        IN   BOOLEAN DEFAULT TRUE, -- Bug 4722963
       x_return_status      OUT NOCOPY   VARCHAR2,
       x_sqlcode            OUT NOCOPY   NUMBER,
       x_sqlerr             OUT NOCOPY   VARCHAR2);

/*===========================================================================+
 | FUNCTION                                                                  |
 |              Rule_Location                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the rule function for the following TCA events :     |
 |                   # oracle.apps.ar.hz.Location.create                     |
 |                   # oracle.apps.ar.hz.Location.update                     |
 |              This calls the Mapping_Main API to recreate the mapping once |
 |              a location gets created on a location gets updated.          |
 |                                                                           |
 +===========================================================================*/

FUNCTION Rule_Location(
               p_subscription_guid  in raw,
               p_event              in out NOCOPY  wf_event_t)
RETURN VARCHAR2;

PROCEDURE Transfer_Location (
  p_source_type           IN   VARCHAR2,
  p_source_location_id    IN   NUMBER,
  p_transfer_location     IN   BOOLEAN DEFAULT TRUE,
  p_online_region_mapping IN   BOOLEAN,
  p_caller                IN   VARCHAR2 DEFAULT NULL,
  x_loc_rec               OUT NOCOPY   loc_rec_type,
  x_return_status         OUT NOCOPY   VARCHAR2 );

PROCEDURE Location_User_Hook_API(
  p_location_id       IN      NUMBER);

  PROCEDURE Get_Transit_Time(p_ship_from_loc_id IN  NUMBER,
                           p_ship_to_site_id  IN  NUMBER,
                           p_ship_method_code IN  VARCHAR2 DEFAULT NULL,
                           p_carrier_id       IN  NUMBER,
                           p_service_code     IN  VARCHAR2,
                           p_mode_code        IN  VARCHAR2,
                           p_from             IN  VARCHAR2,
                           x_transit_time     OUT NOCOPY NUMBER,
                           x_return_status    OUT NOCOPY VARCHAR2);


-- will cache transit time given a ship method by maintaining ship method
-- and transit time with same index for corresponding ship method-transit time
-- combination
TYPE t_ship_from_loc_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_ship_to_site_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_ship_method_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_transit_time_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_ship_from_loc_tab   t_ship_from_loc_tab;
g_ship_to_site_tab    t_ship_to_site_tab;
g_ship_method_tab     t_ship_method_tab;
g_transit_time_tab    t_transit_time_tab;

  --==============================================================================
-- PROCEDURE   : PREDEL_LOC_VALIDATION   Added for bug Bug 6940375
--
-- PARAMETERS  : p_location_id              Input location id
-- DESCRIPTION : This procedure checks if an Internal location is eligible
-- 	         for deletion. Shipping raises error if the location exists
--               in shipping tables.
--===============================================================================
PROCEDURE PREDEL_LOC_VALIDATION (p_location_id IN NUMBER);

END WSH_MAP_LOCATION_REGION_PKG;


/
