--------------------------------------------------------
--  DDL for Package CSF_LOCUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_LOCUS_PUB" AUTHID CURRENT_USER AS
  /*$Header: CSFPLCSS.pls 120.7.12010000.4 2009/08/27 12:31:07 rajukum ship $*/
  g_ret_locus_success          CONSTANT NUMBER := 0;
  g_ret_locus_invalid_locus    CONSTANT NUMBER := -1;
  g_ret_locus_invalid_geometry CONSTANT NUMBER := -2;
  CSF_LF_LATITUDE_NOT_SET_ERROR	        EXCEPTION;
  CSF_LF_LONGITUDE_NOT_SET_ERROR	EXCEPTION;
  CSF_LF_COUNTRY_NOT_SET_ERROR	        EXCEPTION;
  CSF_LF_VERSION_ERROR		        EXCEPTION;


  /**
   * The API reads the locus and returns the Geometry (SDO_GEOMETRY),
   * Segment ID, Offset and Side of the Road.
   * <br>
   * The API has a PRAGMA Restriction to avoid reading the database or
   * modifying it.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_locus            Locus Object (SDO_GEOMETRY)
   * @param  x_geom             Geometry of the Locus (SDO_GEOMETRY)
   * @param  x_segid            Segment ID of the road pointed to by Locus
   * @param  x_offset           Offset of the Address in the road pointed to by Locus (0 .. 1)
   * @param  x_direction        Direction of the road pointed to by Locus
   */
  PROCEDURE read_locus(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_locus         IN            MDSYS.SDO_GEOMETRY
  , x_geom          OUT NOCOPY    MDSYS.SDO_GEOMETRY
  , x_segid         OUT NOCOPY    NUMBER
  , x_offset        OUT NOCOPY    NUMBER
  , x_direction     OUT NOCOPY    NUMBER
  );

  PRAGMA RESTRICT_REFERENCES(read_locus, RNDS, WNDS, WNPS);

  /**
   * The API returns the locus given the Geometry (SDO_GEOMETRY),
   * Segment ID, Offset and Side of the Road.
   * <br>
   * The API has a PRAGMA Restriction to avoid reading the database or
   * modifying it.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_geom             Road Geometry (SDO_GEOMETRY)
   * @param  p_segid            Segment ID of the road
   * @param  p_offset           Offset of the Address in the road (0 .. 1)
   * @param  p_direction        Direction of the road
   * @param  x_locus            Locus Object (SDO_GEOMETRY)
   */
  PROCEDURE write_locus(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  , p_segid         IN            NUMBER
  , p_offset        IN            NUMBER
  , p_direction     IN            NUMBER
  --added for LF enhancement of forced accuracy
  ,p_accuracyFactor IN            NUMBER
  , x_locus         OUT NOCOPY    MDSYS.SDO_GEOMETRY
  );

  PRAGMA RESTRICT_REFERENCES(write_locus, RNDS, WNDS, WNPS);

  /**
   * The API verifies whether the given locus follow the prescribed norms.
   * <br>
   * The API has a PRAGMA Restriction to avoid reading the database or
   * modifying it.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_locus            Locus to be verified (SDO_GEOMETRY)
   * @param  x_result           Status indicating validity of Locus.
   */
  PROCEDURE verify_locus(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_locus         IN            MDSYS.SDO_GEOMETRY
  , x_result        OUT NOCOPY    VARCHAR2
  );

  PRAGMA RESTRICT_REFERENCES(verify_locus, RNDS, WNDS, RNDS, WNPS);

  /**
   * Utility Function to get the Segment ID of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_segmentid(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER;

  /**
   * Utility Function to get the Segment ID of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   * <br>
   * This function can be used in SQL's where output variables cant be bound.
   *
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_segmentid(p_geom MDSYS.SDO_GEOMETRY)
    RETURN NUMBER;

  /**
   * Utility Function to get the Offset / Spot of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_spot(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER;

  /**
   * Utility Function to get the Offset / Spot of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   * <br>
   * This function can be used in SQL's where output variables cant be bound.
   *
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_spot(p_geom MDSYS.SDO_GEOMETRY)
    RETURN NUMBER;

  /**
   * Utility Function to get the Side of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_side(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER;

  /**
   * Utility Function to get the Side of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   * <br>
   * This function can be used in SQL's where output variables cant be bound.
   *
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_side(p_geom MDSYS.SDO_GEOMETRY)
    RETURN NUMBER;

  /**
   * Utility Function to get the Latitude of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_lat(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER;

  /**
   * Utility Function to get the Latitude of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   * <br>
   * This function can be used in SQL's where output variables cant be bound.
   *
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_lat(p_geom MDSYS.SDO_GEOMETRY)
    RETURN NUMBER;

  /**
   * Utility Function to get the Longitude of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   *
   * @param  p_api_version      API Version (1.0)
   * @param  x_return_status    Return Status of the Procedure.
   * @param  x_msg_count        Number of Messages in the Stack.
   * @param  x_msg_data         Stack of Error Messages.
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_lon(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER;

  /**
   * Utility Function to get the Longitude of the Road from the given
   * Locus / Geometry of the Road or -9999 in case of invalid Locus.
   * <br>
   * This function can be used in SQL's where output variables cant be bound.
   *
   * @param  p_geom             Geometry of the Road (SDO_GEOMETRY)
   */
  FUNCTION get_locus_lon(p_geom MDSYS.SDO_GEOMETRY)
    RETURN NUMBER;

  /**
   * Function name          : GET_LOCUS_SRID
   * Description            : Given a geometry,returns the Spatial Ref ID of
   *                          the locus; if invalid locus returns -9999
   * @param p_geom          : input point geometry object
   *
   */
  Function get_locus_srid (p_geom IN MDSYS.SDO_GEOMETRY)
    return NUMBER;

  /**
   * Checks whether the Geometry is proper or not and inturn indicates
   * whether to call Location Finder or not.
   *
   * @returns FND_API.G_TRUE/G_FALSE
   */
  FUNCTION should_call_lf(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN VARCHAR2;

  /**  This function is called with p_item = 'SDO_POINT' and p_index = 1 (X)
   *   or p_index = 2 (Y) to determine the coordinates of a point location
   *   such as a customer, resource or task.
   *   If the SDO_POINT item is null it is assumed that the geometry is a
   *   valid locus (see package CSF_LOCUS_PUB).  For performance reasons this
   *   will not be checked.  The X and Y values can then be obtained from the
   *   first two elements of the SDO_ORDINATES array.
   */

  FUNCTION get_geometry(
    p_geometry     MDSYS.SDO_GEOMETRY
  , p_item         VARCHAR2
  , p_index        NUMBER  DEFAULT NULL
  )
    RETURN NUMBER;


  /**  This function is used to get the x1, y1, x2 and y2 coordinates for
   *   the selected service area on Map
   */
  FUNCTION get_serv_area_coordinates(
    p_country_id   NUMBER
  , p_index        NUMBER
  )
    RETURN NUMBER;

 /**  This function is used to get the x1, y1, x2 and y2 coordinates for
   *   the selected service area on Map
   */
  FUNCTION get_serv_area_coordinates(
    p_country_id   NUMBER
  , p_dataset VARCHAR2
  , p_index        NUMBER
  )
    RETURN NUMBER;

  /**
   * Returns the Geometry as a String corresponding to the list of Segment IDs
   * given
   *
   * @param p_segment_id_tbl   Table of Segment IDs
   * @param p_sampling_level   Whats the Sampling Rate to be used on the Geometry
   */
  FUNCTION get_geometry_tbl(
    p_segment_id_tbl  jtf_number_table
  , p_sampling_level  VARCHAR2           DEFAULT NULL
  )
    RETURN jtf_varchar2_table_2000;

  /**
   * Computes the Geometry of the Route given as the Segment IDs
   * Table and then saves the Geometry of the Route in
   * CSF_TDS_ROUTE_CACHE to be used in future computations.
   *
   * p_api_version       API Version
   * p_init_msg_list     Initialize the Message List
   * p_commit            Commit the Transaction at the end
   * x_return_status     Return Status
   * x_msg_count         Message Count
   * x_msg_data          Message Data
   * p_segment_id_tbl    List of Segment IDs
   * p_start_side        Start Side
   * p_start_offset      Start Offset
   * p_end_side          End Side
   * p_end_offset        End Offset
   * p_cost_type         Type of Cost Calculator used
   * p_travel_time       Travel Time
   * p_travel_distance   Travel Distance
   *
   */
  PROCEDURE compute_and_save_route(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2           DEFAULT NULL
  , p_commit           IN            VARCHAR2           DEFAULT NULL
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_segment_id_tbl   IN            jtf_number_table
  , p_start_side       IN            NUMBER
  , p_start_offset     IN            NUMBER
  , p_end_side         IN            NUMBER
  , p_end_offset       IN            NUMBER
  , p_tds_calc_type    IN            NUMBER             DEFAULT NULL
  , p_travel_time      IN            NUMBER
  , p_travel_distance  IN            NUMBER
  );

  /**
   * For each Location given in the Location Table, the Location Record
   * in HZ_LOCATIONS will be updated with the Geometry containing the
   * Latitude and Longitude as given by the corresponding PLSQL Tables.
   *
   * p_api_version       API Version
   * p_init_msg_list     Initialize the Message List
   * p_commit            Commit the Transaction at the end
   * x_return_status     Return Status
   * x_msg_count         Message Count
   * x_msg_data          Message Data
   * p_location_id_tbl   List of Location IDs
   * p_latitude_tbl      List of Latitudes for the above Locations
   * p_longitude_tbl     List of Longitudes for the above Locations
   */
  PROCEDURE compute_and_save_locuses(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2           DEFAULT NULL
  , p_commit           IN            VARCHAR2           DEFAULT NULL
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_srid             IN            NUMBER             DEFAULT 8307
  , p_location_id_tbl  IN            jtf_number_table
  , p_latitude_tbl     IN            jtf_number_table
  , p_longitude_tbl    IN            jtf_number_table
  );

  /**
   * Returns the Given Geometry in String Representation with each attribute
   * separated by @. The sequence of the attributes are Longitude, Latitude,
   * Segment Id, Offset and Side.
   *
   * In case Soft Validation is sufficient, then VERIFY_LOCUS is not called.
   * Rather the most basic steps are performed for validation. Thus this
   * mode can return Locus of those Geometries where only Longitude and Latitude
   * are populated.
   *
   * @param  p_geom              Geometry whose String Representation is Required.
   * @param  p_soft_validation   To enable Soft Validation or not (T / N)
   * @return @ separated geometry attributes.
   */
  FUNCTION get_locus_string(
    p_geom            IN MDSYS.SDO_GEOMETRY
  , p_soft_validation IN VARCHAR2           DEFAULT NULL
  )
    RETURN VARCHAR2;

   /**
   * This API is for fetching street segment id based on the inputs passed as
   * latitude ,longitude and country .
   *
   * @param   p_latitude              Latitude
   * @param   p_longitude             Longitude
   * @param   p_country               Country of the address
   * @param   x_segment_id            Nearest Street Segment Id.
   */
   FUNCTION get_segment_id (
      p_api_version   IN         NUMBER    default 1.0
    , p_init_msg_list IN         VARCHAR2  default FND_API.G_FALSE
    , p_latitude      IN         NUMBER
    , p_longitude     IN         NUMBER
    , p_country       IN         VARCHAR2
    , x_segment_id    OUT NOCOPY NUMBER
    , x_msg_count     OUT NOCOPY NUMBER
    , x_msg_data      OUT NOCOPY VARCHAR2
    , x_return_status OUT NOCOPY VARCHAR2

   )
    RETURN NUMBER;

END csf_locus_pub;

/
