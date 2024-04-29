--------------------------------------------------------
--  DDL for Package WSH_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_LOCATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: WSHLOCMS.pls 120.1.12000000.1 2007/01/16 05:47:58 appldev ship $ */

  TYPE location_rec_type IS RECORD (
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
      INACTIVE_DATE           WSH_LOCATIONS.INACTIVE_DATE%TYPE,
      LONGITUDE               WSH_LOCATIONS.LONGITUDE%TYPE,
      LATITUDE                WSH_LOCATIONS.LATITUDE%TYPE,
      GEOMETRY                WSH_LOCATIONS.GEOMETRY%TYPE,
      TIMEZONE_CODE           WSH_LOCATIONS.TIMEZONE_CODE%TYPE
  );

  --
  -- Package: WSH_LOCATIONS_PKG
  --
  -- Purpose: To populate data in WSH_LOCATIONS with the data in
  --          HZ_LOCATIONS, HR_LOCATIONS
  --
  --
  /*===========================================================================+
   | PROCEDURE                                                                 |
   |              Process_Locations                                            |
   |                                                                           |
   | DESCRIPTION                                                               |
   |                                                                           |
   |           This procedure will populate the WSH_LOCATIONS table            |
   |           with the locations in HZ_LOCATIONS (whose usage is deliver_to   |
   |           or ship_to) and HR_LOCATIONS                                    |
   |                                                                           |
   +===========================================================================*/

    --
    -- Parameters
    --
    --   p_location_type         Location Type (EXTERNAL/INTERNAL/BOTH)
    --   p_from_location         From Location ID
    --   p_to_location           To Location ID
    --   p_start_date            Start Date
    --   p_end_date              End Date
    --   If the Start Date and End Date are not null then the locations which are updated
    --   in this date range will be considered.




PROCEDURE Process_Locations
(
  p_location_type        IN   VARCHAR2,
  p_from_location        IN   NUMBER ,
  p_to_location          IN   NUMBER ,
  p_start_date           IN   VARCHAR2,
  p_end_date             IN   VARCHAR2,
  p_create_facilities    IN   VARCHAR2 default NULL,
  p_caller               IN  VARCHAR2 default NULL,
  x_return_status        OUT NOCOPY   VARCHAR2,
  x_sqlcode              OUT NOCOPY   NUMBER,
  x_sqlerr               OUT NOCOPY   varchar2
);

TYPE ID_Tbl_Type           IS TABLE OF NUMBER index by BINARY_INTEGER;
TYPE Address_Tbl_Type      IS TABLE OF VARCHAR2(2000) index by BINARY_INTEGER;
TYPE LocationCode_Tbl_Type IS TABLE OF VARCHAR2(1000) index by BINARY_INTEGER;
TYPE Date_Tbl_Type         IS TABLE OF DATE index by BINARY_INTEGER;
--TYPE Geometry_Tbl_Type     IS TABLE OF MDSYS.SDO_GEOMETRY index by BINARY_INTEGER;

PROCEDURE get_site_number(pLocationIdTbl      IN     ID_Tbl_Type,
                          pLocationCodeTbl    IN OUT NOCOPY LocationCode_Tbl_Type,
                          pUILocationCodeTbl  IN OUT NOCOPY LocationCode_Tbl_Type);

PROCEDURE insert_locations(pInsertLocationIdTbl      IN ID_Tbl_Type,
                           p_location_source_code    IN VARCHAR2,
                           x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE update_locations(pUpdateLocationIdTbl      IN ID_Tbl_Type,
                           p_location_source_code    IN VARCHAR2,
                           x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE insert_location_owners(pLocationIdTbl          IN ID_Tbl_Type,
                                 p_location_source_code  IN VARCHAR2,
                                 x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE Create_Geometry (p_longitude        IN  NUMBER,
                           p_latitude         IN  NUMBER,
                           x_geometry         OUT NOCOPY MDSYS.SDO_GEOMETRY,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_error_msg        OUT NOCOPY VARCHAR2 );


PROCEDURE Convert_internal_cust_location(
               p_internal_cust_location_id   IN         NUMBER,
	       p_customer_id                 IN         NUMBER DEFAULT NULL,
               x_internal_org_location_id    OUT NOCOPY NUMBER,
               x_return_status               OUT NOCOPY VARCHAR2);

FUNCTION Convert_internal_cust_location(
               p_internal_cust_location_id   IN         NUMBER)
RETURN NUMBER;

pUpdateAddress1Tbl         Address_Tbl_Type;
pUpdateAddress2Tbl         Address_Tbl_Type;
pUpdateAddress3Tbl         Address_Tbl_Type;
pUpdateAddress4Tbl         Address_Tbl_Type;
pUpdateCountryTbl          Address_Tbl_Type;
pUpdateStateTbl            Address_Tbl_Type;
pUpdateProvinceTbl         Address_Tbl_Type;
pUpdateCountyTbl           Address_Tbl_Type;
pUpdateCityTbl             Address_Tbl_Type;
pUpdatePostalCodeTbl       Address_Tbl_Type;
pUpdateExpDateTbl          Date_Tbl_Type;
pUpdateLocCodeTbl          LocationCode_Tbl_Type;
pUpdateUILocCodeTbl        LocationCode_Tbl_Type;
pUpdateOwnerNameTbl        Address_Tbl_Type;

pInsertAddress1Tbl         Address_Tbl_Type;
pInsertAddress2Tbl         Address_Tbl_Type;
pInsertAddress3Tbl         Address_Tbl_Type;
pInsertAddress4Tbl         Address_Tbl_Type;
pInsertCountryTbl          Address_Tbl_Type;
pInsertStateTbl            Address_Tbl_Type;
pInsertProvinceTbl         Address_Tbl_Type;
pInsertCountyTbl           Address_Tbl_Type;
pInsertCityTbl             Address_Tbl_Type;
pInsertPostalCodeTbl       Address_Tbl_Type;
pInsertExpDateTbl          Date_Tbl_Type;
pInsertLocCodeTbl          LocationCode_Tbl_Type;
pInsertUILocCodeTbl        LocationCode_Tbl_Type;
pInsertOwnerNameTbl        Address_Tbl_Type;

pLocLocationIdTbl          ID_Tbl_Type;
pLocOwnerIdTbl             ID_Tbl_Type;
pLocOwnerTypeTbl           ID_Tbl_Type;

pLatitudeTbl               Id_Tbl_Type;
pLongitudeTbl              Id_Tbl_Type;
pTimezoneTbl               LocationCode_Tbl_Type;
--pGeometryTbl               Geometry_Tbl_Type;
pLastUpdateDateTbl         Date_Tbl_Type;

END WSH_LOCATIONS_PKG;

 

/
