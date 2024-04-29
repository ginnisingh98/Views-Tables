--------------------------------------------------------
--  DDL for Package Body CSF_LF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_LF_PUB" AS
/*$Header: CSFPLFB.pls 120.6.12010000.16 2010/04/06 08:41:03 rajukum ship $*/

  g_debug         VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_debug_level   NUMBER := NVL(fnd_profile.value('AFLOG_LEVEL'), fnd_log.level_event);

-- ----------------------------------------------------------------------------
-- register JSP
-- ----------------------------------------------------------------------------
   FUNCTION resolveaddress (
      p_country       VARCHAR2,
      p_state         VARCHAR2,
      p_province      VARCHAR2,
      p_county        VARCHAR2,
      p_city          VARCHAR2,
      p_postalcode    VARCHAR2,
      p_roadname      VARCHAR2,
      p_buildingnum   VARCHAR2,
      p_alternate     VARCHAR2,
      -- added for LF enhancement of forced accuracy
      p_requiredAccuracy VARCHAR2
   )
      RETURN csf_lf_resultarray_int
   AS
      LANGUAGE JAVA
      NAME 'oracle.apps.csf.lf.server.Address.resolveAddress(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String
, java.lang.String, java.lang.String, java.lang.String, java.lang.String,
java.lang.String) return oracle.sql.ARRAY';

-- ----------------------------------------------------------------------------
-- private types and constants
-- ----------------------------------------------------------------------------
TYPE POINT_COORD IS RECORD(LAT NUMBER, LONG NUMBER);

EARTH_RADIUS CONSTANT NUMBER := 6378137;
PI           CONSTANT NUMBER := 3.14159265359;

-- ----------------------------------------------------------------------------
-- forward declaration of private procedures
-- ----------------------------------------------------------------------------
-- duplicate of oracle.apps.csf.lf.server.LFCommon.deg2rad()
FUNCTION  DEG2RAD ( DEG NUMBER ) RETURN NUMBER;

FUNCTION  RAD2DEG ( DEG NUMBER ) RETURN NUMBER;

-- duplicate of oracle.apps.csf.lf.server.LFCommon.getDistance()
FUNCTION  GEODISTANCE ( POS1 IN POINT_COORD
                      , POS2 IN POINT_COORD ) RETURN NUMBER;

PROCEDURE NEW_COORD ( POS1     IN POINT_COORD
                    , DISTANCE IN NUMBER
                    , HEAD     IN NUMBER
                    , POS2     OUT NOCOPY POINT_COORD );

FUNCTION  HEADING ( POS1 IN POINT_COORD
                  , POS2 IN POINT_COORD ) RETURN NUMBER;

PROCEDURE GETCOORDONSEGMENT ( segmentLength   NUMBER
			    , segmentGeometry MDSYS.SDO_ORDINATE_ARRAY
			    , percentAlongSeg NUMBER
			    , coord           OUT NOCOPY POINT_COORD );

PROCEDURE GETSEGMENTLENGTH ( segmentGeometry IN MDSYS.SDO_ORDINATE_ARRAY
			   , segmentLength   OUT NOCOPY NUMBER );

  PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
  BEGIN
    IF g_debug = 'Y' AND p_level >= g_debug_level THEN
      IF fnd_file.log > 0 THEN
        IF p_message = ' ' THEN
          fnd_file.put_line(fnd_file.log, '');
        ELSE
          fnd_file.put_line(fnd_file.log, rpad(p_module, 20) || ': ' || p_message);
        END IF;
      ELSE
        fnd_log.string(p_level, 'csf.plsql.CSF_LF_PUB.' || p_module, p_message);
      END IF;
    END IF;
    --dbms_output.put_line(rpad(p_module, 20) || ': ' || p_message);
  END debug;

-- ----------------------------------------------------------------------------
-- public procedures
-- ----------------------------------------------------------------------------

-- Start of Comments
-- API Name	: CSF_LF_ResolveAddress
-- Type 	: Public
-- Pre-req	:
-- Function	: Return a locus from an input address specification
-- Parameters	:
--		p_api_version IN NUMBER,  required
--		p_init_msg_list IN VARCHAR2 := NULL optional
--		x_return_status OUT VARCHAR2,
--		x_msg_count OUT NUMBER,
--		x_msg_data OUT VARCHAR2,
--		p_country IN VARCHAR2 		required
--		p_state  IN VARCHAR2 		:= NULL optional
--      p_county IN VARCHAR2        := NULL optional
--      p_province IN VARCHAR2      := NULL optional
--		p_city IN  VARCHAR2 		required
--		p_postalCode IN  VARCHAR2 	:= NULL optional
--		p_roadname IN  VARCHAR2 	required
--		p_buildingnum IN VARCHAR 	:= NULL optioanl
--		p_alternate IN  VARCHAR2	:= NULL optional
-- Version: 1.0
-- History: 19-04-2000 L Mbekeani   Added lat long to locus
-- End Comments
PROCEDURE CSF_LF_ResolveAddress
( p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2 default FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_country       IN         VARCHAR2
, p_state         IN         VARCHAR2 default NULL
, p_county        IN         VARCHAR2 DEFAULT NULL
, p_province      IN         VARCHAR2 DEFAULT NULL
, p_city          IN         VARCHAR2
, p_postalCode    IN         VARCHAR2 default NULL
, p_roadname      IN         VARCHAR2
, p_buildingnum   IN         VARCHAR2  default NULL
, p_alternate     IN         VARCHAR2  default NULL
, x_resultsArray  OUT NOCOPY CSF_LF_RESULTARRAY
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'CSF_LF_ResolveAddress';
  l_api_version CONSTANT NUMBER       := 1.0;
  l_result_int  CSF_LF_RESULTARRAY_INT;
  l_retCode     NUMBER;
  l_numResults  NUMBER;
  J NUMBER;
  l_srid number;
  l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
  -- added for LF enhancement of forced accuracy
  l_requiredAccuracy  VARCHAR2(50);
   TYPE REF_SRID IS REF CURSOR;
   C_SRID   REF_SRID;
   TYPE country_refcur IS REF CURSOR;
   ref_cur     country_refcur;
   sql_stmt_str    VARCHAR2(2000);
   l_data_set_name        VARCHAR2(40);
   /*
   CURSOR C_SRID
   IS
   SELECT nvl(cscp.default_display_center.sdo_srid, 8307) srid
   FROM   csf_sdm_ctry_profiles cscp
   WHERE  cscp.default_display_center IS NOT NULL;
   */
   l_country VARCHAR2(100);
  CURSOR ctry_hr_to_spatial IS
   SELECT SPATIAL_COUNTRY_NAME
   FROM CSF_SPATIAL_CTRY_MAPPINGS
   WHERE HR_COUNTRY_NAME = p_country;
BEGIN

   IF l_debug THEN
      debug('  --> Inside  CSF_LF_ResolveAddress  ' , l_api_name, fnd_log.level_statement);
    END IF;

  if ( l_api_version <> p_api_version ) then
    raise csf_lf_version_error;
  end if;

  if ( p_init_msg_list = 'TRUE' ) then
    x_msg_count := 0; /* FND_MSG_PUB.initialize; */
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Validate parameters
  --

  if ( p_country = NULL ) then
    raise CSF_LF_COUNTRY_NOT_SET_ERROR;
  end if;

  if ( p_city = NULL ) then
    raise CSF_LF_CITY_NOT_SET_ERROR;
  end if;

  if ( (p_roadname = NULL) or (p_roadname = '') ) then
    raise CSF_LF_ROAD_NOT_SET_ERROR;
  end if;

  x_msg_count := 0;
  x_msg_data := 'Success';

  --l_result_int := RESOLVEADDRESS(p_country, p_state, p_city, p_postalCode, p_roadName, p_buildingnum, p_alternate);
  --l_result_int := RESOLVEADDRESS(p_country, p_state, p_city, p_postalCode, p_roadName, '_', p_alternate);

  -- added for LF enhancement of forced accuracy
  l_requiredAccuracy := NVL(fnd_profile.value('CSF_LOC_ACC_LEVELS'),''+0);

    /** Bug 7570463 **/
  open ctry_hr_to_spatial;
  fetch ctry_hr_to_spatial into l_country;
  close ctry_hr_to_spatial;

  IF (l_country is null) THEN
    l_country := p_country;
    END IF;

   IF l_debug THEN
      debug('  --> p_buildingnum =  ' || p_buildingnum, l_api_name, fnd_log.level_statement);
    END IF;

     IF ((p_buildingnum = NULL) OR (p_buildingnum = ''))
      THEN
         l_result_int :=
            resolveaddress (l_country,
                            p_state,
                            p_province,
                            p_county,
                            p_city,
                            p_postalcode,
                            p_roadname,
                            '_',
                            p_alternate,
                            -- added for LF enhancement of forced accuracy
                            l_requiredAccuracy
                           );
      ELSE
         l_result_int :=
            resolveaddress (l_country,
                            p_state,
                            p_province,
                            p_county,
                            p_city,
                            p_postalcode,
                            p_roadname,
                            p_buildingnum,
                            p_alternate,
                            -- added for LF enhancement of forced accuracy
                            l_requiredAccuracy
                           );
      END IF;

 l_retCode := l_result_int(1).record_type;

   IF l_debug THEN
      debug('  --> l_retCode     = ' || l_retCode, l_api_name, fnd_log.level_statement);
    END IF;

  --
  -- TODO: Perform Geometry to Locus conversion then load the result array back
  -- If the first record type is greater than 0 then  we havw a problem */
  --

  if ( l_retCode = MISSING_COUNTRY_NAME ) then

    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := l_result_int(1).msg_data;

    raise CSF_LF_COUNTRY_NOT_SET_ERROR;

  elsif ( l_retCode = MISSING_STATE_NAME ) then

    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := l_result_int(1).msg_data;

    raise CSF_LF_STATE_NOT_SET_ERROR;

  elsif ( l_retCode = MISSING_CITY_NAME ) then

    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := l_result_int(1).msg_data;

    raise CSF_LF_CITY_NOT_SET_ERROR;

  elsif ( l_retCode = MISSING_ROAD_NAME ) then

    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := l_result_int(1).msg_data;

    raise CSF_LF_ROAD_NOT_SET_ERROR;

 -- added for LF enhancement of forced accuracy
   elsif ( l_retCode = REQUIRED_ACCURACY_EXCEPTION ) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count     := 1;
         x_msg_data      := l_result_int(1).msg_data;
      RAISE CSF_LF_REQ_ACCURACY_NOT_GOT;

  elsif ( l_retCode > 0 ) then

    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := l_result_int(1).msg_data;

  else

    --
    -- Load the result items
    --
    l_numResults   := l_result_int.count();
    x_resultsArray := CSF_LF_RESULTARRAY();

    IF l_debug THEN
      debug('  --> l_numResults =  ' || l_numResults, l_api_name, fnd_log.level_statement);
    END IF;

      l_data_set_name  := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
      IF (l_data_set_name = 'N' OR l_data_set_name IS NULL ) THEN
       l_data_set_name := '';
      ELSE
        BEGIN
          l_data_set_name := '';
          sql_stmt_str := 'select spatial_dataset from csf_spatial_ctry_mappings
                         WHERE spatial_country_name = ''' || upper(l_country)|| '''';
          OPEN ref_cur FOR sql_stmt_str;
          FETCH ref_cur INTO l_data_set_name;
          CLOSE ref_cur;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_data_set_name := '';
        END;
      END IF;

     IF l_debug THEN
      debug('  --> l_data_set_name =  ' || l_data_set_name, l_api_name, fnd_log.level_statement);
    END IF;

    sql_stmt_str := 'SELECT nvl(cscp.default_display_center.sdo_srid, 8307) srid
                     FROM csf_sdm_ctry_profiles' || l_data_set_name || ' cscp
                     WHERE cscp.default_display_center IS NOT NULL';
    --OPEN  C_SRID;
    OPEN  C_SRID FOR sql_stmt_str;
    FETCH C_SRID INTO l_srid;
    CLOSE C_SRID;

    -- Fix for bug 9299548
    if((NVL(fnd_profile.VALUE('CSF_LF_INSTALLED'),'N') = 'N')) then
       l_srid := 8307;
    end if;

     IF l_debug THEN
      debug('  --> l_srid =  ' || l_srid, l_api_name, fnd_log.level_statement);
    END IF;

    for J in 1..l_numresults loop

      x_resultsArray.extend(1);

      IF l_debug THEN
        debug('  --> l_result_int(J).lon =  ' || l_result_int(J).lon, l_api_name, fnd_log.level_statement);
        debug('  --> l_result_int(J).lat =  ' || l_result_int(J).lat, l_api_name, fnd_log.level_statement);
        debug('  --> l_result_int(J).accuracy_fact =  ' || l_result_int(J).accuracy_fact, l_api_name, fnd_log.level_statement);
        debug('  --> l_result_int(J).segment_id =  ' || l_result_int(J).segment_id, l_api_name, fnd_log.level_statement);
      END IF;

      x_resultsArray(J).locus := mdsys.sdo_geometry(2001,l_srid,
                                    mdsys.sdo_point_type( l_result_int(J).lon
                                                        , l_result_int(J).lat
                                                        , 0),
                                    mdsys.sdo_elem_info_array(1,1,1,3,0,5),
                                    mdsys.sdo_ordinate_array( l_result_int(J).lon
                                                            , l_result_int(J).lat
                                                         -- added for LF enhancement of forced accuracy
                                                            , l_result_int(J).accuracy_fact
                                                            , -9999
                                                            , l_result_int(J).segment_id
                                                            , l_result_int(J).percentage
                                                            , l_result_int(J).segment_side
                                                            )
                                                          );
      x_resultsArray(J).record_type     := l_result_int(J).record_type;
      x_resultsArray(J).accuracy_factor := l_result_int(J).accuracy_fact;
      x_resultsArray(J).country         := l_result_int(J).country;
      x_resultsArray(J).state           := l_result_int(J).state;
      x_resultsarray (j).county         := l_result_int (j).county;
      x_resultsarray (j).province       := l_result_int (j).province;
      x_resultsArray(J).city            := l_result_int(J).city;
      x_resultsArray(J).postalcode      := l_result_int(J).postalcode;
      x_resultsArray(J).road            := l_result_int(J).road;
      x_resultsArray(J).buildingnum     := l_result_int(J).buildingnum;
      x_resultsArray(J).alternate       := l_result_int(J).alternate;

    end loop;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count     := l_numResults;
    x_msg_data      := 'Success';

     IF l_debug THEN
      debug('  --> End of  CSF_LF_ResolveAddress  ' , l_api_name, fnd_log.level_statement);
    END IF;

 end if;

EXCEPTION

  when CSF_LF_VERSION_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := 'Incompatibale version';

  when CSF_LF_REQ_ACCURACY_NOT_GOT then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := l_result_int(1).msg_data;

END CSF_LF_ResolveAddress;

-- Start of Comments
-- API Name	: CSF_LocustoGeometry
-- Type 	: Public
-- Pre-req	:
-- Function	: Converts a Locust to a geometry
-- Parameters	:
-- IN
--		p_api_version IN NUMBER required :=
--		p_init_msg_list IN VARCHAR2  = NULL optional :=
--		x_return_status OUT VARCHAR2 :=
--		x_msg_count OUT NUMBER :=
--		x_msg_data OUT VARCHAR2 :=
--		p_locus MDSYS.SDO_GEOMETRY  required :=
--		x_point OUT MDSYS.SDO_GEOMETRY
-- Version:
-- End Comments
PROCEDURE CSF_LocustoGeometry
( p_api_version   IN NUMBER
, p_init_msg_list IN VARCHAR2  default fnd_api.g_false
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_locus         IN MDSYS.SDO_GEOMETRY
, x_point         OUT NOCOPY MDSYS.SDO_GEOMETRY
)
IS
  x_geom          mdsys.sdo_geometry;
  segmentGeometry mdsys.sdo_geometry;
  segmentLength   number;
  coord           POINT_COORD;
  x_segid         number;
  x_offset        number;
  x_direction     number;
  l_msg_count     number;
  l_msg_data      varchar2(1000);
  l_api_name      CONSTANT VARCHAR2(30)  := 'CSF_LocustoGeometry';
  l_api_version   number := 1.0;
  TYPE REF_SEGID IS REF CURSOR;
  C_SEGID         REF_SEGID;
  sql_stmt_str    VARCHAR2(2000);
  l_data_set_name VARCHAR2(40);

BEGIN

  if ( l_api_version <> p_api_version ) then
    raise CSF_LF_VERSION_ERROR;
  end if;

  if ( p_init_msg_list = 'TRUE' ) then
    null; /* FND_MSG_PUB.initialize; */
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CSF_LOCUS_PUB.read_locus (
    p_api_version   => l_api_version
  , x_return_status => x_return_status
  , x_msg_count     => l_msg_count
  , x_msg_data      => l_msg_data
  , p_locus         => p_locus
  , x_geom          => x_geom
  , x_segid         => x_segid
  , x_offset        => x_offset
  , x_direction     => x_direction
  );

  if ( x_return_status <> CSF_LOCUS_PUB.G_RET_LOCUS_SUCCESS ) then
    return;
  else
    /* select roadsegment_geometry into segmentGeometry
    from csf_lf_roadsegments
    where roadSegment_id = x_segid; */

    l_data_set_name  := fnd_profile.value('CSF_SPATIAL_DATASET_NAME');
    IF (l_data_set_name = 'NONE' OR l_data_set_name IS NULL ) THEN
       l_data_set_name := '';
    END IF;

    sql_stmt_str := 'SELECT roadsegment_geometry into segmentGeometry
                     FROM csf_lf_roadsegments' || l_data_set_name||'
                     WHERE roadSegment_id = '|| x_segid;
    OPEN  C_SEGID FOR sql_stmt_str;
    FETCH C_SEGID INTO segmentGeometry;
    CLOSE C_SEGID;

    getSegmentLength(segmentGeometry.sdo_ordinates,segmentLength);
    getCoordonSegment(segmentLength, segmentGeometry.sdo_ordinates,x_offset,coord);

    x_point := mdsys.sdo_geometry(2001,8307,mdsys.sdo_point_type(coord.long,coord.lat,0),null,null);

    x_return_status  := FND_API.G_RET_STS_SUCCESS;
  end if;

  -- Get the segId
  -- Fetch The segment geometry
  -- call GetLocusPosition
  -- call create PointGeo.

EXCEPTION

  when CSF_LF_VERSION_ERROR then
    x_return_status  := FND_API.G_RET_STS_ERROR;

  when NO_DATA_FOUND then
    x_return_status := FND_API.G_RET_STS_ERROR;

END CSF_LocustoGeometry;

-- Start of Comments
-- API Name	: CSF_GeometrytoLocus
-- Type 	: Public
-- Pre-req	:
-- Functiom	: Converts a geomrty to a Locus
-- Parameters	:
-- IN
--		p_api_version IN NUMBER  required
--		p_init_msg_list IN VARCHAR2 : = NULL optional
--		x_return_status OUT VARCHAR2 :=
--		x_msg_count OUT NUMBER :=
--		x_msg_data OUT VARCHAR2 :=
--		p_point MDSYS.SDO_GEOMETRY :=  required
--		x_locus MDSYS.SDO_GEOMETRY
-- Version:
-- End Comments
PROCEDURE CSF_GeometrytoLocus
( p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2 default FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_point         IN         MDSYS.SDO_GEOMETRY
, x_locus         OUT NOCOPY MDSYS.SDO_GEOMETRY
)
IS

  l_api_name CONSTANT VARCHAR2(30) := 'CSF_GeometrytoLocus';
  l_api_version NUMBER := 1.0;

BEGIN

  if ( l_api_version <> p_api_version ) then
    raise CSF_LF_VERSION_ERROR;
  end if;

  if ( p_init_msg_list = 'TRUE' ) then
    null; /* FND_MSG_PUB.initialize; */
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  when CSF_LF_VERSION_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR;

END CSF_GeometrytoLocus;

-- Start of Comments
-- API Name	: CSF_LocustoTimeZone
-- Type 	: Public
-- Pre-req	:
-- Functiom	: Converts a Locus to a time zone
-- Parameters	:
-- IN
--		p_api_version   IN  NUMBER   required
--		p_init_msg_list IN  VARCHAR2 := NULL optional
--		x_return_status OUT VARCHAR2 :=
--		x_msg_count     OUT NUMBER   :=
--		x_msg_data      OUT VARCHAR2 :=
--		p_point             MDSYS.SDO_GEOMETRY := required
--		x_timezone      OUT NUMBER
-- Version:
-- End Comments

PROCEDURE CSF_LocustoTimeZone
( p_api_version   IN         NUMBER
, p_init_msg_list IN         VARCHAR2  default FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, p_locus         IN         MDSYS.SDO_GEOMETRY
, x_timezone      OUT NOCOPY NUMBER
)
IS

  l_api_name     CONSTANT VARCHAR2(30) := 'CSF_LocustoTimeZone';
  l_api_version  CONSTANT NUMBER := 1.0;
  l_result       varchar2(1000);
  TYPE REF_TIMEZONE IS REF CURSOR;
  C_TIMEZONE      REF_TIMEZONE;
  sql_stmt_str    VARCHAR2(2000);
  l_data_set_name VARCHAR2(40);
BEGIN

  if ( l_api_version <> p_api_version ) THEN
    raise CSF_LF_VERSION_ERROR;
  end if;

  if ( p_init_msg_list = 'TRUE' ) THEN
      x_msg_count := 0; /* FND_MSG_PUB.initialize; */
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CSF_LOCUS_PUB.VERIFY_LOCUS (
    p_api_version   => l_api_version
  , x_return_status => x_return_status
  , x_msg_count     => x_msg_count
  , x_msg_data      => x_msg_data
  , p_locus         => p_locus
  , x_result        => l_result
  );

  if ( l_result = 'TRUE' ) then
 /* select time_zone into x_timezone
    from csf_lf_roadsegments
    where roadsegment_id = p_locus.sdo_ordinates(6); */

    l_data_set_name  := fnd_profile.value('CSF_SPATIAL_DATASET_NAME');
    IF (l_data_set_name = 'NONE' OR l_data_set_name IS NULL ) THEN
       l_data_set_name := '';
    END IF;
    sql_stmt_str := 'SELECT time_zone into x_timezone
                       FROM csf_lf_roadsegments'|| l_data_set_name||'
                      WHERE roadsegment_id = '|| p_locus.sdo_ordinates(6);

    OPEN  C_TIMEZONE FOR sql_stmt_str;
    FETCH C_TIMEZONE INTO x_timezone;
    CLOSE C_TIMEZONE;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  else
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION

  when NO_DATA_FOUND then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data      := 'INVALID ROADSEGMENT_ID';

  when OTHERS then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data      := 'UNKNOWN ERROR';
END;

-- ----------------------------------------------------------------------------
-- private procedures
-- ----------------------------------------------------------------------------

PROCEDURE getSegmentLength
( segmentGeometry IN MDSYS.SDO_ORDINATE_ARRAY
, segmentLength   OUT NOCOPY NUMBER)
IS
  prevPos                    POINT_COORD;
  currPos                    POINT_COORD;
  distanceFromLastShapePoint NUMBER:= 0;
  numCoordinates             NUMBER := 0;

BEGIN
  segmentLength := 0;
  /* Starting from the first shape point which we know is the reference node....*/
  prevPos.Long := segmentGeometry(1);
  prevPos.lat  := segmentGeometry(2);
  numCoordinates := segmentGeometry.count / 2;

  /* ..take a walk along the shape points  until we have walked a distance greater
     than segmentLength * percentAlongSeg */
  FOR J IN 1..numCoordinates - 1
  LOOP
    currPos.LONG := segmentGeometry(J*2 + 1);
    currPos.LAT  := segmentGeometry(J*2 + 2);
    segmentLength := segmentLength + GEODISTANCE(prevPos, currPos);
    prevPos := currPos;
  END LOOP;
END getSegmentLength;

PROCEDURE getCoordOnSegment
( segmentLength   NUMBER
, segmentGeometry MDSYS.SDO_ORDINATE_ARRAY
, percentAlongSeg NUMBER
, coord           OUT NOCOPY POINT_COORD )
IS
  prevPos                    POINT_COORD;
  currPos                    POINT_COORD;
  lengthSoFar                NUMBER := 0;
  prevLengthSoFar            NUMBER := 0;
  vheading                   NUMBER;
  distanceFromLastShapePoint NUMBER:= 0;
  numCoordinates             NUMBER := 0;

BEGIN
  /* Starting from the fist shape point which we know is the reference node....*/
  prevPos.long := segmentGeometry(1);
  prevPos.lat  := segmentGeometry(2);
  numCoordinates := segmentGeometry.count / 2;

  /* ..take a walk along the shape points  until we have walked a distance greater than segmentLength * percentAlongSeg */
  FOR J IN 1..numCoordinates - 1
  LOOP
    currPos.LONG := segmentGeometry(J*2 + 1);
    currPos.LAT  := segmentGeometry(J*2 + 2);
    lengthSoFar  := lengthSoFar + GEODISTANCE(prevPos, currPos);
    IF lengthSoFar >= segmentLength * percentAlongSeg
    THEN
      /* distanceFromLastShapePoint is the distance from the last shape point to the  position */
      distanceFromLastShapePoint := segmentLength * percentAlongSeg  - prevLengthSoFar;
      vheading := HEADING(prevPos, currPos);

      /* Now use the heading, previous shape point and distance from last shape point to determine coord point */
      NEW_COORD( prevPos, distanceFromLastShapePoint, vheading, coord);
      EXIT;
    ELSE
      prevPos         := currPos;
      prevLengthSoFar := lengthSoFar;
    END IF;
  END LOOP;
END getCoordOnSegment;


-- DETERMINE NEW COORD FROM START COORD, DISTANCE BETWEEN POINTS AND HEADING (RADIANS);
PROCEDURE NEW_COORD( POS1 IN POINT_COORD, DISTANCE IN NUMBER, HEAD NUMBER, POS2 OUT NOCOPY POINT_COORD) IS
BEGIN
	POS2.LAT := RAD2DEG(((DISTANCE * SIN(HEAD)) / EARTH_RADIUS) + DEG2RAD(POS1.LAT));
	POS2.LONG := RAD2DEG(((DISTANCE * COS(HEAD)) / EARTH_RADIUS)  + DEG2RAD(POS1.LONG));
END NEW_COORD;
-- HEADING IN RADIANS WILL ALWAYS BE POSITIVE AND IS DEFINES AS RADIANS FROM NORTH;

-- COMPUTES HEADING ANGLE BETWEEN TWO POINTS IN RADIANS
FUNCTION HEADING(POS1 IN POINT_COORD,POS2 IN POINT_COORD) RETURN NUMBER IS
NORTH_DIST NUMBER;
EAST_DIST NUMBER;
HEAD NUMBER;
BEGIN
	NORTH_DIST := (DEG2RAD(POS2.LAT) - DEG2RAD(POS1.LAT)) * EARTH_RADIUS;
	EAST_DIST := (DEG2RAD(POS2.LONG) - DEG2RAD(POS1.LONG)) * COS(DEG2RAD(POS2.LAT)) * EARTH_RADIUS;
	IF (NORTH_DIST = 0) AND (EAST_DIST  = 0) THEN
		HEAD := 0;
	ELSE
		HEAD := ATAN2(EAST_DIST,NORTH_DIST);
		IF HEAD < 0 THEN
			HEAD := HEAD + 2* PI;
		END IF;
	END IF;
	RETURN HEAD;
END HEADING;

-- COMPUTES DISTANCE BETWEEN TWO COORD.
FUNCTION GEODISTANCE(POS1 IN POINT_COORD,POS2 IN POINT_COORD) RETURN NUMBER IS
NORTH_DIST NUMBER;
EAST_DIST NUMBER;
DISTANCE NUMBER;
BEGIN
	NORTH_DIST := (DEG2RAD(POS2.LAT) - DEG2RAD(POS1.LAT)) * EARTH_RADIUS;
	EAST_DIST := (DEG2RAD(POS2.LONG) - DEG2RAD(POS1.LONG)) * COS(DEG2RAD(POS2.LAT)) * EARTH_RADIUS;
	DISTANCE := SQRT((NORTH_DIST * NORTH_DIST) + (EAST_DIST *EAST_DIST));
	RETURN DISTANCE;
END GEODISTANCE;

-- CONVERTS DEGREES UNITS TO RADIANS
FUNCTION DEG2RAD(DEG NUMBER) RETURN NUMBER  IS
RADIANS NUMBER;
BEGIN
	RADIANS := DEG * PI/180.0;
RETURN RADIANS;
END DEG2RAD;

-- CONVERTS RADIANS TO DEGREES
FUNCTION RAD2DEG(DEG NUMBER) RETURN NUMBER IS
DEGREES NUMBER;
BEGIN
	DEGREES := ( 180.0/PI) * DEG;
	RETURN DEGREES;
END RAD2DEG;

END CSF_LF_PUB;

/
