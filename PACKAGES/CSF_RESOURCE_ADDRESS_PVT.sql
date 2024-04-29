--------------------------------------------------------
--  DDL for Package CSF_RESOURCE_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_RESOURCE_ADDRESS_PVT" AUTHID CURRENT_USER AS
  /* $Header: CSFVADRS.pls 120.4.12010000.9 2010/03/11 09:13:12 ppillai ship $ */

 g_pkg_name                 CONSTANT VARCHAR2(30) := 'CSF_RESOURCE_ADDRESS_PVT';

  g_st_party_fname   CONSTANT VARCHAR2(30) := 'Dep/Arr Party';

  /**
    * Address Record Structure to store the Address Information when retrieved
    * from HZ_LOCATIONS / PER_ADDRESSES tables.
    *
    * ***   Filled when address is retrieved from HZ_LOCATIONS Table   ***
    * *** Associated API that fills the records is GET_PARTY_ADDRESSES ***
    * PARTY_ID               Primary Key to HZ_PARTIES Table
    * PARTY_SITE_ID          Primary Key to HZ_PARTY_SITES Table
    * LOCATION               Primary Key to HZ_LOCATIONS Table
    * GEOMETRY               Spatial Geometry of the Address

    * ***   Filled when address is retrieved from PER_ADDRESSES Table  ***
    * *** Associated API that fills the records is GET_HOME_ADDRESSES  ***
    * ADDRESS_ID             Primray Key to PER_ADDRESS Table
    *
    * ***  Common fields between HZ_LOCATIONS and PER_ADDRESSES Tables ***
    * STREET                 Address Line 1 Information
    * CITY                   City Information
    * STATE                  State Information
    * POSTAL_CODE            Postal Code Information
    * COUNTRY                Country Information
    * TERRITORY_SHORT_NAME   Stores Country Code (FND_TERRITORIES_TL)
    * START_DATE_ACTIVE      Date from which the Party Site is active
    * END_DATE_ACTIVE        Date till which the Party Site is active
    */
  TYPE address_rec_type IS RECORD(
    party_id             hz_parties.party_id%TYPE
  , party_site_id        hz_party_sites.party_site_id%TYPE
  , location_id          hz_locations.location_id%TYPE
  , address_id           per_addresses.address_id%TYPE
  , street               hz_locations.address1%TYPE
  , postal_code          hz_locations.postal_code%TYPE
  , city                 hz_locations.city%TYPE
  , state                hz_locations.state%TYPE
  , country              hz_locations.country%TYPE
 -- , county              hz_locations.county%TYPE
 -- , province              hz_locations.province%TYPE
  , territory_short_name fnd_territories_vl.territory_short_name%TYPE
  , geometry             mdsys.sdo_geometry
  , start_date_active    DATE
  , end_date_active      DATE
  );

  /**
    * Table of Addresses where each record is of type ADDRESS_REC_TYPE.
    */
  TYPE address_tbl_type IS TABLE OF address_rec_type;

  TYPE address_rec_type1 IS RECORD(
    party_id             hz_parties.party_id%TYPE
  , party_site_id        hz_party_sites.party_site_id%TYPE
  , location_id          hz_locations.location_id%TYPE
  , address_id           per_addresses.address_id%TYPE
  , street               hz_locations.address1%TYPE
  , postal_code          hz_locations.postal_code%TYPE
  , city                 hz_locations.city%TYPE
  , state                hz_locations.state%TYPE
  , country              hz_locations.country%TYPE
  , county              hz_locations.county%TYPE
  , province              hz_locations.province%TYPE
  , territory_short_name fnd_territories_vl.territory_short_name%TYPE
  , geometry             mdsys.sdo_geometry
  , start_date_active    DATE
  , end_date_active      DATE
  );

  /**
    * Table of Addresses where each record is of type ADDRESS_REC_TYPE.
    */
  TYPE address_tbl_type1 IS TABLE OF address_rec_type1;

  /**
   * Gets the Resource's Party Information and if the Resource is not
   * tied to any Party, then creates a new set of Party, Site and Location
   * Information.
   *
   * <b> Resource's Home Address </b>
   *   This is applicable only for Employee Resource (RS_EMPLOYEE).
   *   Employee Resource is an employee defined in HRMS with an address.
   *   Resource's Home Address is nothing but the address as defined in HRMS
   *   PER_ADDRESSES. There can be only one Primary Address for a particular
   *   period of time.
   * <br>
   * <b> Resource's Party Information </b>
   *   Any Party created by this API will have CREATED_BY_MODULE as CSFDEAR.
   *
   *   RS_EMPLOYEE
   *      Party is already created by HRMS whenever an Employee is created.
   *      This API will take care of inserting Party Sites and copying
   *      the address in PER_ADDRESS in HRMS Module to HZ_LOCATIONS in TCA.
   *      Before, party 'Dep/Arr Party' were created even for Employee
   *      Resources. Now this API will reuse the Party Created by HRMS itself.
   *
   *   RS_PARTY
   *      Party Resources are those which are created in TCA itself by making
   *      use of Contact Person Functionality. Nothing is done as everything
   *      is already in-order.
   *
   *   Other Resources - RS_TEAM, RS_GROUP, Other Resource Types
   *      For all other resources, there exists no home address and no automatic
   *      Party Also. For these resources, a Party is created for the first time
   *      with the first name being 'Dep/Arr Party' and Last Name being the
   *      concantenation of Resource Type and Resource ID. A Dummy Address is
   *      inserted for its location.
   * <br>
   * <b> Sync between HRMS Address and CRM Location </b>
   *   Whenever the HRMS Address of the Resource is updated, the corresponding
   *   Location Record is updated to reflect the new changes.
   *   Whenever a HRMS Address is created by end-dating the existing HRMS Address,
   *   a new location is created and this location is returned to programs
   *   requesting the address of the Resource.
   * <br>
   * <b> Automatic Geocoding of the Address <b>
   *   If the Address corresponding to the determined Location is not yet Geocoded
   *   (GEOMETRY being NULL in HZ_LOCATIONS), the Address is Geocoded and stored
   *   in the table.
   * <br>
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commits the Work
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_resource_id           Resource Identifier
   * @param   p_resource_type         Resource Type of the above Resource
   * @param   p_date                  Date for which the Address is desired
   * @param   x_address_rec           Resource Complete Party Address Information
   */
  PROCEDURE get_resource_address(
    p_api_version         IN          NUMBER
  , p_init_msg_list       IN          VARCHAR2 DEFAULT NULL
  , p_commit              IN          VARCHAR2 DEFAULT NULL
  , x_return_status      OUT  NOCOPY  VARCHAR2
  , x_msg_count          OUT  NOCOPY  NUMBER
  , x_msg_data           OUT  NOCOPY  VARCHAR2
  , p_resource_id         IN          NUMBER
  , p_resource_type       IN          VARCHAR2
  , p_res_shift_add       IN           VARCHAR2 DEFAULT NULL
  , p_date                IN          DATE
  , x_address_rec        OUT  NOCOPY  address_rec_type
  );

  /**
   * This API is similar to that of GET_RESOURCE_ADDRESS but restricts
   * itself in providing only the Party ID, Party Site ID and Location ID.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commits the Work
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_resource_id           Resource Identifier
   * @param   p_resource_type         Resource Type of the above Resource
   * @param   p_date                  Date for which the Address is desired
   * @param   x_party_id              Party Identifier of the Party tied to Resource
   * @param   x_party_id_site         Party Site ID of the Active Party Site
   * @param   x_location_id           Location ID of the Active Location
   */
  PROCEDURE get_resource_party_info(
    p_api_version         IN          NUMBER
  , p_init_msg_list       IN          VARCHAR2 DEFAULT NULL
  , p_commit              IN          VARCHAR2 DEFAULT NULL
  , x_return_status      OUT  NOCOPY  VARCHAR2
  , x_msg_count          OUT  NOCOPY  NUMBER
  , x_msg_data           OUT  NOCOPY  VARCHAR2
  , p_resource_id         IN          NUMBER
  , p_resource_type       IN          VARCHAR2
  , p_date                IN          DATE
  , x_party_id           OUT  NOCOPY  NUMBER
  , x_party_site_id      OUT  NOCOPY  NUMBER
  , x_location_id        OUT  NOCOPY  NUMBER
  );

  /**
   * Resolves the passed address and updates the corresponding address in
   * HZ_LOCATIONS with the Geometry of the Address.
   *
   * The given address is resolved using Location Finder only when the
   * profiles "CSR: Create Location" and "CSF: Location Finder Installed"
   * are set to Yes. The geometry corresponding to the Location Specified
   * is updated if the Geocoding was successful.
   *
   * The given address is updated corresponding to the Location Specified
   * when the parameter P_UPDATE_ADDRESS is set to Yes.
   *
   * A single Address Line out of the four address lines is used depending
   * on which Line contains a valid Street Info with Building Number.
   * Preference is given to Address Line 4 to Address Line 1.
   *
   * @param   p_api_version           API Version (1.0)
   * @param   p_init_msg_list         Initialize Message List
   * @param   p_commit                Commits the work
   * @param   x_return_status         Return Status of the Procedure.
   * @param   x_msg_count             Number of Messages in the Stack.
   * @param   x_msg_data              Stack of Error Messages.
   * @param   p_location_id           Location ID of the Location to be updated.
   * @param   p_building_num          Building Number of the address (Optional)
   * @param   p_address1              Address Line 1
   * @param   p_address2              Address Line 2 (Optional)
   * @param   p_address3              Address Line 3 (Optional)
   * @param   p_address4              Address Line 4 (Optional)
   * @param   p_city                  City
   * @param   p_state                 State
   * @param   p_postalcode            Zip Code
   * @param   p_county                County (Optional)
   * @param   p_province              Province (Optional)
   * @param   p_country               Country (United States)
   * @param   p_country_code          Country Code (US)
   * @param   p_alternate             NOT USED
   * @param   p_update_address        Should the Location be updated with Address.
   * @param   x_geometry              Geometry of the Address resolved.
   */
  PROCEDURE resolve_address(
    p_api_version      IN        NUMBER
  , p_init_msg_list    IN        VARCHAR2 DEFAULT NULL
  , p_commit           IN        VARCHAR2 DEFAULT NULL
  , x_return_status   OUT NOCOPY VARCHAR2
  , x_msg_count       OUT NOCOPY NUMBER
  , x_msg_data        OUT NOCOPY VARCHAR2
  , p_location_id      IN        NUMBER
  , p_building_num     IN        VARCHAR2 DEFAULT NULL
  , p_address1         IN        VARCHAR2
  , p_address2         IN        VARCHAR2 DEFAULT NULL
  , p_address3         IN        VARCHAR2 DEFAULT NULL
  , p_address4         IN        VARCHAR2 DEFAULT NULL
  , p_city             IN        VARCHAR2
  , p_state            IN        VARCHAR2
  , p_postalcode       IN        VARCHAR2
  , p_county           IN        VARCHAR2 DEFAULT NULL
  , p_province         IN        VARCHAR2 DEFAULT NULL
  , p_country          IN        VARCHAR2
  , p_country_code     IN        VARCHAR2
  , p_alternate        IN        VARCHAR2 DEFAULT NULL
  , p_update_address   IN        VARCHAR2 DEFAULT 'F'
  , x_geometry        OUT NOCOPY mdsys.sdo_geometry
  );

  /**
   * Returns which address line to be considered among the four
   * address lines.
   *
   * @param   p_address1              Address Line 1
   * @param   p_address2              Address Line 2 (Optional)
   * @param   p_address3              Address Line 3 (Optional)
   * @param   p_address4              Address Line 4 (Optional)
   * @param   p_country_code          Country Code (For Eg. US)
   */
  FUNCTION choose_address_line(
    p_address1         IN        VARCHAR2
  , p_address2         IN        VARCHAR2 DEFAULT NULL
  , p_address3         IN        VARCHAR2 DEFAULT NULL
  , p_address4         IN        VARCHAR2 DEFAULT NULL
  , p_country_code     IN        VARCHAR2
  ) RETURN VARCHAR2;

  procedure create_location(p_api_version in number
                          , p_init_msg_list in varchar2
                          , p_commit in varchar2
                          , x_return_status out nocopy varchar2
                          , x_msg_data out nocopy varchar2
                          , x_msg_count out nocopy number
                          , p_resource_id in number
                          , p_resource_type in varchar2
                          , x_address_rec in  out nocopy csf_resource_address_pvt.address_rec_type1);

END csf_resource_address_pvt;


/
