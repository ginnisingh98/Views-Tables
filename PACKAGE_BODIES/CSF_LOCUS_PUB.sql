--------------------------------------------------------
--  DDL for Package Body CSF_LOCUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_LOCUS_PUB" AS
  /* $Header: CSFPLCSB.pls 120.12.12010000.12 2010/02/28 11:03:52 sseshaiy ship $ */

  g_pkg_name    CONSTANT VARCHAR2(30) := 'CSF_LOCUS_PUB';

  -- message count must always equal ZERO or ONE.
  -- cannot use messgage list because of pragma

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
  ) AS
    l_i                 NUMBER;
    l_api_name CONSTANT VARCHAR2(30) := 'read_locus';
  BEGIN
    IF    (p_locus IS NOT NULL)
       AND (p_locus.sdo_gtype = 2001)
       AND (p_locus.sdo_elem_info IS NOT NULL)
       AND (p_locus.sdo_ordinates IS NOT NULL)
       AND (p_locus.sdo_elem_info.COUNT = 6)
       AND (p_locus.sdo_ordinates(p_locus.sdo_elem_info(4) + 1) = -9999) THEN

          x_segid          := p_locus.sdo_ordinates(p_locus.sdo_elem_info(4) + 2);
          x_offset         := p_locus.sdo_ordinates(p_locus.sdo_elem_info(4) + 3);
          x_direction      := p_locus.sdo_ordinates(p_locus.sdo_elem_info(4) + 4);
          x_geom           :=
            MDSYS.SDO_GEOMETRY(
              2001
            , NULL
            , MDSYS.sdo_point_type(p_locus.sdo_ordinates(1), p_locus.sdo_ordinates(2), NULL)
            , MDSYS.sdo_elem_info_array(1, 1, 1)
            , NULL
            );
          x_return_status  := g_ret_locus_success;

    ELSIF    (p_locus IS NOT NULL)
       AND (p_locus.sdo_gtype = 2001)
       AND (p_locus.sdo_point IS NOT NULL)
       AND (p_locus.sdo_elem_info IS NULL) THEN

          x_segid          := 9999;
          x_offset         := 9;
          x_direction      := 9;
          x_geom           :=
            MDSYS.SDO_GEOMETRY(
              2001
            , NULL
            , MDSYS.sdo_point_type(p_locus.sdo_point.x, p_locus.sdo_point.y, NULL)
            , MDSYS.sdo_elem_info_array(1, 1, 1)
            , NULL
            );
          x_return_status  := g_ret_locus_success;
    ELSE
      x_segid          := NULL;
      x_offset         := NULL;
      x_direction      := NULL;
      x_return_status  := g_ret_locus_invalid_locus;
    END IF;
  END read_locus;

  PROCEDURE write_locus(
    p_api_version    IN            NUMBER
  , x_return_status  OUT NOCOPY    VARCHAR2
  , x_msg_count      OUT NOCOPY    NUMBER
  , x_msg_data       OUT NOCOPY    VARCHAR2
  , p_geom           IN            MDSYS.SDO_GEOMETRY
  , p_segid          IN            NUMBER
  , p_offset         IN            NUMBER
  , p_direction      IN            NUMBER
  , p_accuracyFactor IN            NUMBER
  , x_locus         OUT NOCOPY    MDSYS.SDO_GEOMETRY
  ) AS
    l_ordinates         MDSYS.sdo_ordinate_array;
    i                   NUMBER;
    l_api_name CONSTANT VARCHAR2(30)             := 'WRITE_LOCUS';
  BEGIN
    IF    (p_geom.sdo_gtype <> 2001)
       OR (p_geom IS NULL)
       OR ((p_geom.sdo_elem_info.COUNT < 2) AND(p_geom.sdo_point IS NULL)) THEN
      x_locus          := NULL;
      x_return_status  := g_ret_locus_invalid_geometry;
      RETURN;
    END IF;

    IF (p_geom.sdo_point IS NULL) THEN
      l_ordinates  := p_geom.sdo_ordinates;
    ELSE
      l_ordinates  := MDSYS.sdo_ordinate_array(p_geom.sdo_point.x, p_geom.sdo_point.y);

      IF (p_geom.sdo_point.z IS NOT NULL) THEN
        l_ordinates.EXTEND;
        l_ordinates(3)  := p_geom.sdo_point.z;
      END IF;
    END IF;

    x_locus  :=
      MDSYS.SDO_GEOMETRY(
        2001
      , NULL
      , NULL
      , MDSYS.sdo_elem_info_array(1, 1, 1, l_ordinates.COUNT + 1, 0, 5)
      , l_ordinates
      );
    x_locus.sdo_ordinates.EXTEND(5);
    x_locus.sdo_ordinates(x_locus.sdo_elem_info(4))     := p_accuracyFactor;
    x_locus.sdo_ordinates(x_locus.sdo_elem_info(4) + 1) := -9999;
    x_locus.sdo_ordinates(x_locus.sdo_elem_info(4) + 2) := p_segid;
    x_locus.sdo_ordinates(x_locus.sdo_elem_info(4) + 3) := p_offset;
    x_locus.sdo_ordinates(x_locus.sdo_elem_info(4) + 4) := p_direction;
    x_return_status                                     := g_ret_locus_success;
  END write_locus;

  PROCEDURE verify_locus_local(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_locus         IN            MDSYS.SDO_GEOMETRY
  , x_result        OUT NOCOPY    VARCHAR2
  , x_geo_type      OUT NOCOPY    VARCHAR2
  ) AS
    l_api_name CONSTANT VARCHAR2(30) := 'VERIFY_LOCUS';
  BEGIN
    x_result        := 'FALSE';
    x_return_status := 'S';

    IF p_locus IS NULL THEN
      RETURN;
    END IF;

    IF p_locus.sdo_gtype <> 2001 THEN
      RETURN;
    END IF;

    -- added: a null check
    IF p_locus.sdo_elem_info IS NULL
       OR p_locus.sdo_elem_info.COUNT <> 6
       OR p_locus.sdo_ordinates IS NULL
       OR p_locus.sdo_ordinates.COUNT < p_locus.sdo_elem_info(4) + 4
       OR p_locus.sdo_ordinates(p_locus.sdo_elem_info(4) + 1) <> -9999 THEN

        IF p_locus.sdo_point IS NULL
        THEN
          RETURN;
        ELSE
          x_result   := 'TRUE';
          x_geo_type := 'TCA';
        END IF;
    ELSE
        x_result  := 'TRUE';
        x_geo_type := 'CSF';
    END IF;
  END verify_locus_local;

  PROCEDURE verify_locus(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_locus         IN            MDSYS.SDO_GEOMETRY
  , x_result        OUT NOCOPY    VARCHAR2
  ) AS
  l_geo_type      VARCHAR2(6);
  BEGIN

      verify_locus_local(
      p_api_version                => p_api_version
    , p_locus                      => p_locus
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_result                     => x_result
    , x_geo_type                   => l_geo_type
    , x_return_status              => x_return_status
    );

  END;

  FUNCTION get_locus_segmentid(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER IS
    RESULT     VARCHAR2(6);
    GEO_TYPE   VARCHAR2(6);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    verify_locus_local(
      p_api_version                => 1
    , p_locus                      => p_geom
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_result                     => RESULT
    , x_geo_type                   => GEO_TYPE
    , x_return_status              => x_return_status
    );

    IF (RESULT='TRUE') THEN
      IF (GEO_TYPE = 'CSF') THEN
        RETURN p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 2);
      ELSIF (GEO_TYPE = 'TCA') THEN
        RETURN 9999;
      END IF;
    ELSE
      RETURN -9999;
    END IF;
  END;

  FUNCTION get_locus_spot(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER IS
    RESULT     VARCHAR2(6);
    GEO_TYPE   VARCHAR2(6);
  BEGIN
    verify_locus_local(
      p_api_version                => 1
    , p_locus                      => p_geom
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_result                     => RESULT
    , x_geo_type                   => GEO_TYPE
    , x_return_status              => x_return_status
    );

    IF (RESULT='TRUE') THEN
      IF (GEO_TYPE = 'CSF') THEN
        RETURN p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 3);
      ELSIF (GEO_TYPE = 'TCA') THEN
        RETURN 9;
      END IF;
    ELSE
      RETURN -9999;
    END IF;
  END;

  FUNCTION get_locus_side(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER IS
    RESULT     VARCHAR2(6);
    GEO_TYPE   VARCHAR2(6);
  BEGIN
    verify_locus_local(
      p_api_version                => 1
    , p_locus                      => p_geom
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_result                     => RESULT
    , x_geo_type                   => GEO_TYPE
    , x_return_status              => x_return_status
    );

    IF (RESULT ='TRUE') THEN
      IF (GEO_TYPE = 'CSF') THEN
        RETURN p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 4);
      ELSIF (GEO_TYPE = 'TCA') THEN
        RETURN 9;
      END IF;
    ELSE
      RETURN -9999;
    END IF;
  END;

  FUNCTION get_locus_lat(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER IS
    RESULT     VARCHAR2(6);
    GEO_TYPE   VARCHAR2(6);
  BEGIN
    verify_locus_local(
      p_api_version                => 1
    , p_locus                      => p_geom
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_result                     => RESULT
    , x_geo_type                   => GEO_TYPE
    , x_return_status              => x_return_status
    );

    IF (RESULT='TRUE') THEN
      IF (GEO_TYPE = 'CSF') THEN
        RETURN p_geom.sdo_ordinates(2);
      ELSIF (GEO_TYPE = 'TCA') THEN
        RETURN p_geom.sdo_point.y;
      END IF;
    ELSE
      RETURN -9999;
    END IF;
  END;

  FUNCTION get_locus_lon(
    p_api_version   IN            NUMBER
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_geom          IN            MDSYS.SDO_GEOMETRY
  )
    RETURN NUMBER IS
    RESULT     VARCHAR2(6);
    GEO_TYPE   VARCHAR2(6);
  BEGIN
    verify_locus_local(
      p_api_version                => 1
    , p_locus                      => p_geom
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_result                     => RESULT
    , x_geo_type                   => GEO_TYPE
    , x_return_status              => x_return_status
    );

    IF (RESULT='TRUE') THEN
      IF (GEO_TYPE = 'CSF') THEN
        RETURN p_geom.sdo_ordinates(1);
      ELSIF (GEO_TYPE = 'TCA') THEN
        RETURN p_geom.sdo_point.x;
      END IF;
    ELSE
      RETURN -9999;
    END IF;
  END;

  FUNCTION get_locus_srid ( p_api_version   in number,
                            p_geom          in mdsys.sdo_geometry,
                            x_msg_count     out nocopy number,
                            x_msg_data      out nocopy varchar2,
                            x_return_status out nocopy varchar2) return NUMBER is
     result    VARCHAR2(6);
     geo_type  VARCHAR2(6);
   BEGIN
       verify_locus_local(
                     p_api_version   => 1,
                     p_locus         => p_geom,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     x_result        => result,
                     x_geo_type      => geo_type,
                     x_return_status => x_return_status);

     if (result = 'TRUE') then
       return p_geom.sdo_srid;
     else
       return -9999;
     end if;
   END;

  FUNCTION should_call_lf(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN VARCHAR2 AS
  BEGIN
    IF p_geom IS NULL THEN
      RETURN fnd_api.g_true;
    ELSE
      RETURN fnd_api.g_false;
    END IF;
  END should_call_lf;

  FUNCTION get_locus_segmentid(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN NUMBER AS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
  BEGIN
    RETURN get_locus_segmentid(
             p_api_version       => 1
           , p_geom              => p_geom
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data
           , x_return_status     => l_return_status
           );
  END;

  FUNCTION get_locus_side(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN NUMBER AS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
  BEGIN
    RETURN get_locus_side(
             p_api_version       => 1
           , p_geom              => p_geom
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data
           , x_return_status     => l_return_status
           );
  END;

  FUNCTION get_locus_spot(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN NUMBER AS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
  BEGIN
    RETURN get_locus_spot(
             p_api_version       => 1
           , p_geom              => p_geom
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data
           , x_return_status     => l_return_status
           );
  END;

  FUNCTION get_locus_lat(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN NUMBER AS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
  BEGIN
    RETURN get_locus_lat(
             p_api_version       => 1
           , p_geom              => p_geom
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data
           , x_return_status     => l_return_status
           );
  END;

  FUNCTION get_locus_lon(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN NUMBER AS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
  BEGIN
    RETURN get_locus_lon(
             p_api_version       => 1
           , p_geom              => p_geom
           , x_msg_count         => l_msg_count
           , x_msg_data          => l_msg_data
           , x_return_status     => l_return_status
           );
  END;


  FUNCTION get_locus_srid(p_geom IN MDSYS.SDO_GEOMETRY)
    RETURN NUMBER AS
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);
    l_srid          NUMBER;
  BEGIN
    l_srid := -9999;
    IF p_geom IS NOT NULL THEN
      l_srid  := get_locus_srid(p_api_version                => 1
                              , p_geom                       => p_geom
                              , x_msg_count                  => l_msg_count
                              , x_msg_data                   => l_msg_data
                              , x_return_status              => l_return_status
                              );

    END IF;

    RETURN l_srid;
  END;


  FUNCTION get_geometry (p_geometry MDSYS.SDO_GEOMETRY, p_item VARCHAR2, p_index NUMBER DEFAULT NULL)
     RETURN NUMBER
  AS
  -- Bug 1633731
  -- This function is called with p_item = 'SDO_POINT' and p_index = 1 (X)
  -- or p_index = 2 (Y) to determine the coordinates of a point location
  -- such as a customer, resource or task.
  -- If the SDO_POINT item is null it is assumed that the geometry is a
  -- valid locus (see package CSF_LOCUS_PUB).  For performance reasons this
  -- will not be checked.  The X and Y values can then be obtained from the
  -- first two elements of the SDO_ORDINATES array.
  BEGIN
     IF p_geometry IS NULL
     THEN
        RETURN NULL;
     END IF;

     IF p_item = 'SDO_GTYPE'
     THEN
        RETURN p_geometry.sdo_gtype;
     ELSIF p_item = 'SDO_SRID'
     THEN
        RETURN p_geometry.sdo_srid;
     ELSE
        -- for all other fields the index has to be defined
        IF p_index IS NULL
        THEN
           RETURN NULL;
        END IF;

        IF p_item = 'SDO_POINT'
        THEN
           IF p_geometry.sdo_point IS NULL AND p_index IN (1, 2)
           THEN
              RETURN get_geometry (p_geometry, 'SDO_ORDINATES', p_index);
           END IF;

           IF p_index = 1
           THEN
              RETURN p_geometry.sdo_point.x;
           ELSIF p_index = 2
           THEN
              RETURN p_geometry.sdo_point.y;
           ELSIF p_index = 3
           THEN
              RETURN p_geometry.sdo_point.z;
           END IF;
        ELSIF p_item = 'SDO_ELEM_INFO'
        THEN
           IF p_geometry.sdo_elem_info IS NOT NULL
           THEN
              IF p_geometry.sdo_elem_info.COUNT >= p_index
              THEN
                 RETURN p_geometry.sdo_elem_info (p_index);
              END IF;
           END IF;
        ELSIF p_item = 'SDO_ORDINATES'
        THEN
           IF p_geometry.sdo_ordinates IS NOT NULL
           THEN
              IF p_geometry.sdo_ordinates.COUNT >= p_index
              THEN
                 RETURN p_geometry.sdo_ordinates (p_index);
              END IF;
           END IF;
        END IF;
     END IF;

     -- in all other cases return null
     RETURN NULL;
  END get_geometry;

 /* FUNCTION get_serv_area_coordinates (p_country_id NUMBER, p_index NUMBER)
     RETURN NUMBER
  AS
     l_geom    MDSYS.SDO_GEOMETRY;
     l_coord   NUMBER             := NULL;

     CURSOR c1
     IS
         SELECT SDO_GEOM.SDO_MBR(default_display_center)
          FROM csf_sdm_ctry_profiles
         WHERE country_profile_id = p_country_id;
  BEGIN
     OPEN c1;
     FETCH c1 INTO l_geom;
     IF c1%FOUND
     THEN
        l_coord := get_geometry (l_geom, 'SDO_ORDINATES', p_index);
     END IF;
     CLOSE c1;

     RETURN l_coord;
  END get_serv_area_coordinates; */

  FUNCTION get_serv_area_coordinates (p_country_id NUMBER, p_index NUMBER)
     RETURN NUMBER
  AS
     l_geom            MDSYS.SDO_GEOMETRY;
     l_coord           NUMBER             := NULL;
     TYPE REF_DISPLAY IS REF CURSOR;
     c1                REF_DISPLAY;
     sql_stmt_str      VARCHAR2(2000);
	   l_data_set_name   VARCHAR2(40);
  BEGIN

    l_data_set_name := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
    IF (l_data_set_name = 'N' OR l_data_set_name IS NULL) THEN
      l_data_set_name := ' ';
    ELSE
      l_data_set_name := fnd_profile.VALUE('CSF_EMAP_DATASET_NAME') ;
      IF (l_data_set_name = 'NONE' OR l_data_set_name IS NULL) THEN
        l_data_set_name := ' ';
      END IF;
    END IF;

     sql_stmt_str := 'SELECT default_display_center
                        FROM csf_sdm_ctry_profiles'||l_data_set_name ||'
                       WHERE country_profile_id = '|| p_country_id;

     OPEN c1 FOR sql_stmt_str;
     FETCH c1 INTO l_geom;
     IF c1%FOUND THEN
        l_coord := get_geometry (l_geom, 'SDO_ORDINATES', p_index);
     END IF;
     CLOSE c1;

     RETURN l_coord;
  END get_serv_area_coordinates;

   FUNCTION get_serv_area_coordinates (p_country_id NUMBER,p_dataset VARCHAR2, p_index NUMBER)
     RETURN NUMBER
  AS
     l_geom            MDSYS.SDO_GEOMETRY;
     l_coord           NUMBER             := NULL;
     TYPE REF_DISPLAY IS REF CURSOR;
     c1                REF_DISPLAY;
     sql_stmt_str      VARCHAR2(2000);
	   l_data_set_name   VARCHAR2(40);
  BEGIN

    l_data_set_name := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
    IF (l_data_set_name = 'N' OR l_data_set_name IS NULL) THEN
      l_data_set_name := ' ';
    ELSE
      l_data_set_name := p_dataset;
      IF (l_data_set_name = 'NONE' OR l_data_set_name IS NULL) THEN
        l_data_set_name := ' ';
      END IF;
    END IF;

     sql_stmt_str := 'SELECT default_display_center
                        FROM csf_sdm_ctry_profiles'||l_data_set_name ||'
                       WHERE country_profile_id = '|| p_country_id;

     OPEN c1 FOR sql_stmt_str;
     FETCH c1 INTO l_geom;
     IF c1%FOUND THEN
        l_coord := get_geometry (l_geom, 'SDO_ORDINATES', p_index);
     END IF;
     CLOSE c1;

     RETURN l_coord;
  END get_serv_area_coordinates;

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
    RETURN jtf_varchar2_table_2000 IS

    TYPE geometry_tbl_type IS TABLE OF MDSYS.SDO_GEOMETRY;
    l_geometry_tbl       geometry_tbl_type;
    l_geometry_str_tbl   jtf_varchar2_table_2000;
    j                    PLS_INTEGER;

    CURSOR c_geometry IS
      SELECT /*+ cardinality(l, 1) */
             roadsegment_geometry
        FROM csf_lf_roadsegments
           , TABLE (CAST (p_segment_id_tbl AS jtf_number_table )) l
       WHERE roadsegment_id = l.COLUMN_VALUE;

    FUNCTION get_coord(p_tbl_index NUMBER, p_coord_index NUMBER) RETURN NUMBER IS
    BEGIN
      RETURN ROUND(l_geometry_tbl(p_tbl_index).sdo_ordinates(p_coord_index), 4);
    END get_coord;
  BEGIN
    OPEN c_geometry;
    FETCH c_geometry BULK COLLECT INTO l_geometry_tbl;
    CLOSE c_geometry;

    l_geometry_str_tbl := jtf_varchar2_table_2000();

    FOR i IN 1..l_geometry_tbl.COUNT LOOP
     l_geometry_str_tbl.extend(1);
     IF l_geometry_tbl(i) IS NULL OR l_geometry_tbl(i).sdo_ordinates IS NULL THEN
       l_geometry_str_tbl(i) := '';
     ELSE
       IF p_sampling_level IS NULL OR p_sampling_level = 'Y' THEN
         -- Number of Coordinate Pairs
         j := l_geometry_tbl(i).sdo_ordinates.COUNT/2;
         --
         -- We have just one Coordinate Pair. Return it as it is
         IF j = 1 THEN
           l_geometry_str_tbl(i) := get_coord(i, 2) || ',' || get_coord(i, 1);
         ELSE
           j := ROUND(j / 2); -- Center Coordinate Pair
           l_geometry_str_tbl(i)  :=  get_coord(i, 2*j) || ',' || get_coord(i, 2*j-1);
         END IF;
       ELSE
         l_geometry_str_tbl(i)  := get_coord(i, 2) || ',' || get_coord(i, 1);
         FOR j IN 2 .. l_geometry_tbl(i).sdo_ordinates.COUNT / 2 LOOP
           l_geometry_str_tbl(i)  :=  l_geometry_str_tbl(i) || ',' || get_coord(i, 2*j) || ',' || get_coord(i, 2*j-1);
         END LOOP;
       END IF;
     END IF;
    END LOOP;

    RETURN l_geometry_str_tbl;
  END get_geometry_tbl;


  /**
   * Computes the Geometry of the Route given as the Segment IDs
   * Table and then saves the Geometry of the Route in
   * CSF_TDS_ROUTE_CACHE to be used in future computations.
   */
  PROCEDURE compute_and_save_route(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2
  , p_commit           IN            VARCHAR2
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_segment_id_tbl   IN            jtf_number_table
  , p_start_side       IN            NUMBER
  , p_start_offset     IN            NUMBER
  , p_end_side         IN            NUMBER
  , p_end_offset       IN            NUMBER
  , p_tds_calc_type    IN            NUMBER
  , p_travel_time      IN            NUMBER
  , p_travel_distance  IN            NUMBER
  ) IS
    l_api_version       CONSTANT NUMBER        := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'COMPUTE_AND_SAVE_ROUTE';

    l_geometry_tbl      jtf_varchar2_table_2000;
    i                   PLS_INTEGER;
    l_route             clob;

    l_from_segment_id   NUMBER;
    l_to_segment_id     NUMBER;
  BEGIN
    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_from_segment_id := p_segment_id_tbl(p_segment_id_tbl.FIRST);
    l_to_segment_id   := p_segment_id_tbl(p_segment_id_tbl.LAST);

    INSERT INTO CSF_TDS_ROUTE_CACHE (
        ROUTE_CACHE_ID
      , SEGMENT_FROM
      , SIDE_FROM
      , SPOT_FROM
      , SEGMENT_TO
      , SIDE_TO
      , SPOT_TO
      , RESULTTIME
      , RESULTDISTANCE
      , ROUTE
      , DATETIME
      , HITCOUNT
      )
      VALUES (
        CSF_TDS_ROUTE_CACHE_S1.NEXTVAL
      , l_from_segment_id
      , p_start_side
      , p_start_offset
      , l_to_segment_id
      , p_end_side
      , p_end_offset
      , p_travel_time
      , p_travel_distance
      , empty_clob
      , SYSDATE
      , 1
      )
      RETURNING route INTO l_route;

    l_geometry_tbl := get_geometry_tbl(p_segment_id_tbl);

    -- Open the CLOB
    dbms_lob.OPEN(l_route, dbms_lob.lob_readwrite);

    -- Read from Geometry Table and write to the CLOB
    i := l_geometry_tbl.FIRST;
    WHILE i IS NOT NULL LOOP
      dbms_lob.writeappend(l_route, LENGTH(l_geometry_tbl(i)) + 1, l_geometry_tbl(i) || ',');
      i := l_geometry_tbl.NEXT(i);
    END LOOP;

    i := 1;
    IF dbms_lob.getlength(l_route) > 0 THEN
      dbms_lob.erase(l_route, i, dbms_lob.getlength(l_route));
    END IF;

    -- Close the CLOB
    dbms_lob.CLOSE(l_route);

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  END compute_and_save_route;

  /**
   * For each Location given in the Location Table, the Location Record
   * in HZ_LOCATIONS will be updated with the Geometry containing the
   * Latitude and Longitude as given by the corresponding PLSQL Tables.
   */
  PROCEDURE compute_and_save_locuses(
    p_api_version      IN            NUMBER
  , p_init_msg_list    IN            VARCHAR2           DEFAULT NULL
  , p_commit           IN            VARCHAR2           DEFAULT NULL
  , x_return_status    OUT NOCOPY    VARCHAR2
  , x_msg_count        OUT NOCOPY    NUMBER
  , x_msg_data         OUT NOCOPY    VARCHAR2
  , p_srid             IN            NUMBER
  , p_location_id_tbl  IN            jtf_number_table
  , p_latitude_tbl     IN            jtf_number_table
  , p_longitude_tbl    IN            jtf_number_table
  ) IS
    l_api_version       CONSTANT NUMBER        := 1.0;
    l_api_name          CONSTANT VARCHAR2(30) := 'COMPUTE_AND_SAVE_LOCUSES';

    l_srid              NUMBER;
  BEGIN
    SAVEPOINT csf_save_locuses;

    IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_srid := NVL(p_srid, 8307);

    FORALL i IN 1..p_location_id_tbl.COUNT
      UPDATE hz_locations
         SET geometry = mdsys.sdo_geometry(
                          2001
                        , l_srid
                        , mdsys.sdo_point_type( p_longitude_tbl(i), p_latitude_tbl(i), 0)
                        , mdsys.sdo_elem_info_array(1,1,1)
                        , mdsys.sdo_ordinate_array( p_longitude_tbl(i), p_latitude_tbl(i) )
                        )
       WHERE location_id = p_location_id_tbl(i);

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO csf_save_locuses;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
  END compute_and_save_locuses;

  /**
   * Returns the Given Geometry in String Representation with each attribute
   * separated by @. The sequence of the attributes are Longitude, Latitude,
   * Segment Id, Offset and Side.
   */
  FUNCTION get_locus_string(p_geom IN MDSYS.SDO_GEOMETRY, p_soft_validation VARCHAR2)
    RETURN VARCHAR2 AS
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);

    l_result          VARCHAR2(6);
    l_geometry        mdsys.sdo_geometry;
    l_locus_string    VARCHAR2(200);
    l_geo_type        VARCHAR2(6);
  BEGIN
    IF (p_soft_validation = fnd_api.g_true) THEN
      IF p_geom IS NULL
        OR p_geom.sdo_gtype <> 2001
        OR p_geom.sdo_elem_info IS NULL
        OR p_geom.sdo_ordinates IS NULL
      THEN
        l_result := 'FALSE';
      ELSE
        l_result := 'TRUE';
      END IF;
    ELSE
      verify_locus_local(
        p_api_version                => 1
      , p_locus                      => p_geom
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , x_result                     => l_result
      , x_geo_type                   => l_geo_type
      , x_return_status              => l_return_status
      );
    END IF;

    IF l_result <> 'TRUE' THEN
      RETURN NULL;
    END IF;

    l_geometry := p_geom;
    IF l_geometry.sdo_srid <> 8307 THEN
      l_geometry := sdo_cs.transform(p_geom, 8307);
    END IF;

    IF p_geom.sdo_elem_info IS NOT NULL
       AND p_geom.sdo_ordinates IS NOT NULL
    THEN
      l_locus_string :=     ROUND(p_geom.sdo_ordinates(1), 8)
                         || '@' || ROUND(p_geom.sdo_ordinates(2), 8);

      IF p_geom.sdo_elem_info.COUNT = 6
        AND p_geom.sdo_ordinates.COUNT >= p_geom.sdo_elem_info(4) + 4
        AND p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 1) = -9999
      THEN
        l_locus_string :=   l_locus_string
                         || '@' || p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 2)
                         || '@' || p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 3)
                         || '@' || p_geom.sdo_ordinates(p_geom.sdo_elem_info(4) + 4);
      END IF;
    ELSIF p_geom.sdo_point IS NOT NULL
    THEN
          l_locus_string :=     ROUND(p_geom.sdo_point.x, 8)
                         || '@' || ROUND(p_geom.sdo_point.y, 8)
                         || '@' || '9999'
                         || '@' || '9'
                         || '@' || '9';
    END IF;

    /* To convert as a float value when the Number Format is set as '10.000,00'*/
    SELECT REPLACE(l_locus_string, ',', '.') INTO l_locus_string FROM dual;

    RETURN l_locus_string;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

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
   RETURN NUMBER AS
    l_api_name    CONSTANT VARCHAR2(30) := 'csf_lf_get_segment_id';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_roadsegmentid   NUMBER := -1;
    l_tbl_sufx    VARCHAR2(10);
    l_dist            NUMBER := -1;
    l_sql_stmt        VARCHAR2(2000);

    TYPE ref_cursor_type IS REF CURSOR;

    --Cursor to find out the nearest geometry with in specified range from road segment table in case if not exist in poi table
    cursor_rdseg_dist_chk ref_cursor_type;
    cursor_rdseg ref_cursor_type;


   BEGIN

    if ( p_init_msg_list = 'TRUE' ) then
      x_msg_count := 0; /* FND_MSG_PUB.initialize; */
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Validate parameters
    --

    if ( l_api_version <> p_api_version ) then
      x_msg_data := ':p_api_version:' || p_api_version ;
      raise  CSF_LF_VERSION_ERROR;
    end if;

    if ( p_latitude is NULL or p_latitude < -90 or p_latitude > 90 ) then
      x_msg_data := ':p_latitude:' || p_latitude ;
      raise CSF_LF_LATITUDE_NOT_SET_ERROR;
    end if;

    if ( p_longitude is NULL or p_longitude < -180 or p_longitude > 180 ) then
      x_msg_data := ':p_longitude:' || p_longitude ;
      raise CSF_LF_LONGITUDE_NOT_SET_ERROR;
    end if;

    if ( p_country is NULL or p_country = '' ) then
      x_msg_data := ':p_country:' || p_country ;
      raise CSF_LF_COUNTRY_NOT_SET_ERROR;
    end if;

    --Initialize message count and mssage data. we will use var x_msg_data to store info which can be used for debug purpose
    x_msg_count := 0;
    x_msg_data := 'Success';

    --Fetch country specific data set to support muti dataset in single instance
    select spatial_dataset into l_tbl_sufx from CSF_SPATIAL_CTRY_MAPPINGS where spatial_country_name = p_country or spatial_country_code = p_country;

    l_sql_stmt := 'SELECT /*+ INDEX(r CSF_LF_RDSEGS_N2) */ ROADSEGMENT_ID, SDO_NN_DISTANCE(1) dist
                   FROM csf_lf_roadsegments' || l_tbl_sufx || '  r
                   WHERE SDO_NN(r.ROADSEGMENT_GEOMETRY, SDO_GEOMETRY(2002,8307,null,SDO_ELEM_INFO_ARRAY(1,2,1),
                   SDO_ORDINATE_ARRAY(:1, :2, :3, :4)), ''sdo_num_res=1'', 1) = ''TRUE''  ORDER BY dist';

    OPEN cursor_rdseg for l_sql_stmt USING p_longitude,p_latitude,p_longitude,p_latitude;
    LOOP
     FETCH cursor_rdseg INTO l_roadsegmentid, l_dist; -- fetch data into local variables
       EXIT WHEN cursor_rdseg%NOTFOUND;
     END LOOP;
    CLOSE cursor_rdseg;

    x_segment_id :=  l_roadsegmentid;
    x_msg_count := 1;
    x_msg_data := 'roadsegmentid:' || l_roadsegmentid || ':distance:' || l_dist;

     if (l_dist = -1) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
     END if;

     RETURN x_segment_id;

   END;

END csf_locus_pub;

/
