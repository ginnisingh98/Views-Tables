--------------------------------------------------------
--  DDL for Package CSF_LF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_LF_PUB" AUTHID CURRENT_USER AS
/*$Header: CSFPLFS.pls 120.4.12010000.6 2008/09/23 10:05:06 rajukum ship $*/

CITY_NOT_RESOLVED		CONSTANT NUMBER := 223601;
COUNTRY_NOT_RESOLVED		CONSTANT NUMBER := 223602;
STATE_NOT_FOUND			CONSTANT NUMBER := 223603;
MISSING_CITY_NAME		CONSTANT NUMBER := 223604;
RESOLVING_CITY_BEFORE_COUNTRY	CONSTANT NUMBER := 223605;
CITY_NOT_FOUND			CONSTANT NUMBER := 223606;
POSTAL_CODE_NOT_RESOLVED_YET	CONSTANT NUMBER := 233607;
MISSING_COUNTRY_NAME		CONSTANT NUMBER := 223608;
COUNTRY_NAME_AMBIGUITY		CONSTANT NUMBER := 223609;
COUNTRY_NAME_NOT_FOUND		CONSTANT NUMBER := 223610;
ROAD_AND_POI_MISSING		CONSTANT NUMBER := 223611;
MISSING_POSTAL_CODE		CONSTANT NUMBER := 223612;
RESOLVING_POST_BEFORE_COUNTRY	CONSTANT NUMBER := 223613;
POSTAL_CODE_AMBIGUITY		CONSTANT NUMBER := 223614;
POSTAL_CODE_NOT_FOUND		CONSTANT NUMBER := 223615;
MISSING_ROAD_NAME		CONSTANT NUMBER := 223616;
RESOLVING_ROAD_BEFORE_CITY	CONSTANT NUMBER := 223617;
MISSING_STATE_NAME		CONSTANT NUMBER	:= 223618;
STATE_NAME_NOT_FOUND		CONSTANT NUMBER	:= 223619;
MISSING_COMPONENT_NAME		CONSTANT NUMBER	:= 223620;
STATE_NAME_AMBIGUITY		CONSTANT NUMBER	:= 223621;
CITY_AND_POSTAL_MISSING		CONSTANT NUMBER	:= 223622;
CITY_AND_POSTAL_NOT_RESOLVED	CONSTANT NUMBER	:= 223623;
NO_LOCUS_ROAD_NOT_RESOLVED	CONSTANT NUMBER	:= 223624;
CANNOT_COMPUTE_ROAD_CENTROID	CONSTANT NUMBER	:= 223625;
CANNOT_COMPUTE_CITY_CENTROID	CONSTANT NUMBER	:= 223626;
CANNOT_COMPUTE_POSTAL_CENTROID	CONSTANT NUMBER	:= 223627;
/*Added for lf enhancement of forced accuracy*/
REQUIRED_ACCURACY_EXCEPTION      CONSTANT NUMBER    := 223629;

CSF_LF_LOCUS_NOT_SET_ERROR	EXCEPTION;
CSF_LF_POINT_NOT_SET_ERROR	EXCEPTION;
CSF_LF_VERSION_ERROR		EXCEPTION;
CSF_LF_COUNTRY_NOT_SET_ERROR	EXCEPTION;
CSF_LF_STATE_NOT_SET_ERROR	EXCEPTION; /*only for USA database */
CSF_LF_CITY_NOT_SET_ERROR	EXCEPTION;
CSF_LF_ROAD_NOT_SET_ERROR	EXCEPTION;
/*Added for lf enhancement of forced accuracy*/
CSF_LF_REQ_ACCURACY_NOT_GOT   EXCEPTION;

TYPE csf_lf_address IS RECORD (
      country       VARCHAR2 (60),
      state         VARCHAR2 (60),
      county        VARCHAR2 (60),
      province      VARCHAR2 (60),
      city          VARCHAR2 (60),
      postalcode    VARCHAR2 (60),
      road          VARCHAR2 (240),
      buildingnum   VARCHAR2 (50),
      alternate     VARCHAR2 (50),
      poi           VARCHAR2 (50)
   );

TYPE csf_lf_result IS RECORD (
      record_type       NUMBER,
      locus             MDSYS.SDO_GEOMETRY,
      segment_id        NUMBER,
      segment_side      NUMBER (1, 0),
      percentage        NUMBER (15, 0),
      accuracy_factor   NUMBER,
      country           VARCHAR2 (60),
      state             VARCHAR2 (60),
      county            VARCHAR2 (60),
      province          VARCHAR2 (60),
      city              VARCHAR2 (60),
      postalcode        VARCHAR2 (60),
      road              VARCHAR2 (240),
      buildingnum       VARCHAR2 (50),
      alternate         VARCHAR2 (50),
      poi               VARCHAR2 (50)
   );

TYPE CSF_LF_RESULTARRAY IS TABLE OF CSF_LF_RESULT;

PROCEDURE CSF_LF_ResolveAddress
          ( p_api_version   IN NUMBER
	  , p_init_msg_list IN VARCHAR2  default fnd_api.g_false
	  , x_return_status OUT NOCOPY VARCHAR2
	  , x_msg_count     OUT NOCOPY NUMBER
	  , x_msg_data      OUT NOCOPY VARCHAR2
	  , p_country       IN         VARCHAR2
	  , p_state         IN         VARCHAR2  default NULL
	  , p_county        IN         VARCHAR2  DEFAULT NULL
          , p_province      IN         VARCHAR2  DEFAULT NULL
          , p_city          IN         VARCHAR2
   	  , p_postalCode    IN         VARCHAR2  default NULL
	  , p_roadname      IN         VARCHAR2
	  , p_buildingnum   IN         VARCHAR2  default NULL
	  , p_alternate     IN         VARCHAR2  default NULL
	  , x_resultsArray  OUT NOCOPY CSF_LF_RESULTARRAY
	  );

PROCEDURE CSF_LocustoGeometry
          ( p_api_version   IN NUMBER
          , p_init_msg_list IN VARCHAR2  default fnd_api.g_false
          , x_return_status OUT NOCOPY VARCHAR2
          , x_msg_count     OUT NOCOPY NUMBER
          , x_msg_data      OUT NOCOPY VARCHAR2
          , p_locus         IN MDSYS.SDO_GEOMETRY
          , x_point         OUT NOCOPY MDSYS.SDO_GEOMETRY
          );

PROCEDURE CSF_GeometrytoLocus
          ( p_api_version   IN NUMBER
	  , p_init_msg_list IN VARCHAR2  default fnd_api.g_false
	  , x_return_status OUT NOCOPY VARCHAR2
	  , x_msg_count     OUT NOCOPY NUMBER
	  , x_msg_data      OUT NOCOPY VARCHAR2
	  , p_point         IN MDSYS.SDO_GEOMETRY
	  , x_locus         OUT NOCOPY MDSYS.SDO_GEOMETRY
	  );

PROCEDURE CSF_LocustoTimeZone
          ( p_api_version   IN NUMBER
	  , p_init_msg_list IN VARCHAR2  default fnd_api.g_false
	  , x_return_status OUT NOCOPY VARCHAR2
	  , x_msg_count     OUT NOCOPY NUMBER
	  , x_msg_data      OUT NOCOPY VARCHAR2
	  , p_locus         IN MDSYS.SDO_GEOMETRY
	  , x_timezone      OUT NOCOPY NUMBER
	  );

END CSF_LF_PUB;

/
