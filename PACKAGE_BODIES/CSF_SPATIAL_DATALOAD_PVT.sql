--------------------------------------------------------
--  DDL for Package Body CSF_SPATIAL_DATALOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_SPATIAL_DATALOAD_PVT" AS
/* $Header: CSFVSDLB.pls 120.1.12010000.4 2009/10/28 07:22:55 vpalle noship $ */

/*
The following procedure is used to print the log messages.
*/
PROCEDURE dbgl (p_msg_data VARCHAR2)
 IS
   i       PLS_INTEGER;
   l_msg   VARCHAR2 (300);
BEGIN
   i := 1;
   LOOP
      l_msg := SUBSTR (p_msg_data, i, 255);
       EXIT WHEN l_msg IS NULL;
       EXECUTE IMMEDIATE g_debug_p
                  USING l_msg;
   i := i + 255;
   END LOOP;
END dbgl;
/*
The following procedure is used to print the log messages.
*/
PROCEDURE put_stream (p_handle IN NUMBER, p_msg_data IN VARCHAR2)
  IS
BEGIN
   IF p_handle = 0
   THEN
       dbgl (p_msg_data);
   ELSIF p_handle = -1
   THEN
      IF g_debug
      THEN
         dbgl (p_msg_data);
      END IF;
   ELSE
      fnd_file.put_line (p_handle, p_msg_data);
   END IF;
END put_stream;

/*
The following procedure is used to print the log messages.
*/
/*PROCEDURE CSF_LOG( l_log IN VARCHAR2 )
 IS
BEGIN
  dbms_output.put_line( l_log );
EXCEPTION
 WHEN OTHERS THEN
        RETURN;
END CSF_LOG; */
/*
 The following procedure drops the index with the help of ad_ddl.do_ddl.
*/
PROCEDURE DROP_INDEX (
    p_applsys_schema in            VARCHAR2 ,
    p_app_short_name in            VARCHAR2 ,
    p_table          in            VARCHAR2 ,
    p_index          in            VARCHAR2 ,
    errbuf         OUT NOCOPY      VARCHAR2,
    retcode        OUT NOCOPY      VARCHAR2
 )
IS
BEGIN

    ad_ddl.do_ddl(
            applsys_schema          => p_applsys_schema,
            application_short_name  => p_app_short_name,
            statement_type          => AD_DDL.DROP_INDEX,
            statement               => 'DROP INDEX ' || p_index ,
            object_name             => p_table
        );

    --put_stream(g_output, 'Index '|| p_index || ' dropped successfully');
    put_stream(g_log,'Index '|| p_index || ' dropped successfully');
    --dbms_output.put_line('Index '|| p_index || ' dropped successfully');
    --dbms_output.put_line('Index '|| p_index || ' dropped successfully');


EXCEPTION
     WHEN OTHERS THEN
         IF SQLCODE = -01418 THEN
            retcode := 1;
            put_stream(g_log, 'Index ' || p_index || ' on table ' || p_table || ' does not exist');
            put_stream(g_output, 'Index ' || p_index || ' on table ' || p_table || ' does not exist');
            --dbms_output.put_line('Index ' || p_index || ' on table ' || p_table || ' does not exist');
         ELSE
            retcode := 1;
            errbuf := SQLERRM;
            put_stream(g_output, 'Dropping Index ' || p_index || ' failed : ' || SQLCODE||'-'||SQLERRM );
            put_stream(g_log, 'Dropping Index ' || p_index || ' failed : ' ||SQLCODE||'-'|| SQLERRM );
         END IF ;
END DROP_INDEX;

PROCEDURE CREATE_INDEX (
    p_applsys_schema in VARCHAR2 ,
    p_app_short_name in VARCHAR2 ,
    p_table          in VARCHAR2 ,
    p_index          in VARCHAR2 ,
    p_columns        in char30_arr ,
    p_create_sql     in VARCHAR2,
    errbuf         OUT NOCOPY      VARCHAR2,
    retcode        OUT NOCOPY      VARCHAR2
    )
IS
    l_create_index  BOOLEAN ;
    l_column_name   VARCHAR2(30);

    CURSOR index_col_cur
    IS
    SELECT  column_name
    FROM    user_ind_columns
    WHERE   table_name = p_table
      AND index_name = p_index
    ORDER BY column_position ;

BEGIN
    open index_col_cur ;
    FOR i IN p_columns.FIRST..p_columns.COUNT
    LOOP
        FETCH index_col_cur INTO l_column_name ;
        EXIT WHEN index_col_cur%NOTFOUND ;
        IF l_column_name <> UPPER( p_columns(i) ) THEN
           l_create_index := TRUE ;
           exit ;
        END IF;
    END LOOP;

    IF index_col_cur%ROWCOUNT = 0 THEN
        l_create_index := TRUE ;
    END IF;

    CLOSE index_col_cur ;

    IF l_create_index THEN
       DROP_INDEX ( p_applsys_schema, p_app_short_name, p_table, p_index, errbuf, retcode );
       ad_ddl.do_ddl(
                applsys_schema          => p_applsys_schema,
                application_short_name  => p_app_short_name,
                statement_type          => AD_DDL.CREATE_INDEX,
                statement               => p_create_sql,
                object_name             => p_table
                );

        --put_stream(g_output, 'Index '|| p_index || ' created successfully'  );
        put_stream(g_log, 'Index  '|| p_index || '  created successfully'  );
        --dbms_output.put_line('Index '|| p_index || ' created successfully'  );

    ELSE
        put_stream(g_log, 'Index ' || p_index || ' on table ' || p_table || ' exists' );
        --dbms_output.put_line('Index ' || p_index || ' on table ' || p_table || ' exists' );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -01408 THEN
            put_stream(g_log,  'Index ' || p_index || ' on table ' || p_table || ' already exists' );
            --dbms_output.put_line( 'Index ' || p_index || ' on table ' || p_table || ' already exists' );
        ELSIF SQLCODE = -00955 THEN
            put_stream(g_log, 'Index ' || p_index || ' on table ' || p_table || ' already exists');
            --dbms_output.put_line('Index ' || p_index || ' on table ' || p_table || ' already exists');
        ELSE
            retcode := 1;
            errbuf := SQLERRM;
            put_stream(g_log, 'Index Creation for ' || p_index || ' failed : ' ||SQLCODE||'-'|| SQLERRM );
            put_stream(g_output, 'Index Creation for ' || p_index || ' failed : ' ||SQLCODE||'-'|| SQLERRM );
            RAISE FND_API.G_EXC_ERROR;
            --dbms_output.put_line( 'Index Creation for ' || p_index || ' failed : ' || SQLERRM );
        END IF ;

END CREATE_INDEX;



PROCEDURE DROP_INDEXES(
      p_data_set_name IN          VARCHAR2,
      p_index_type    IN          VARCHAR2,
      errbuf          OUT NOCOPY  VARCHAR2,
      retcode         OUT NOCOPY  VARCHAR2 )
IS
    CURSOR CSF_GET_SPATIAL_INDEXES (p_index_type   in  VARCHAR2)
    IS
    SELECT INDEX_NAME,
          table_name
    FROM  CSF_SPATIAL_INDEX_STAT_M
    WHERE index_type = p_index_type;

    l_index_name        VARCHAR2(100);
    l_applsys_schema    VARCHAR2(10);
    l_app_short_name    VARCHAR2(20);
    l_table             VARCHAR2(60);
    l_data_set_name        VARCHAR2(40);

BEGIN

    l_applsys_schema := upper( 'APPS' ) ;
    l_data_set_name := p_data_set_name;

    OPEN CSF_GET_SPATIAL_INDEXES (p_index_type);
    LOOP
        FETCH CSF_GET_SPATIAL_INDEXES
        INTO l_index_name,
             l_table;
        EXIT WHEN CSF_GET_SPATIAL_INDEXES%NOTFOUND;
        -- Materialized view indexes are created in APPS schema.
        -- All other indexes are created in CSF schema
        IF p_index_type  = 'MAT' THEN
            l_app_short_name := upper( 'APPS' ) ;
        ELSE
            l_app_short_name := upper( 'CSF' ) ;
        END IF;

        IF p_index_type  <> 'WOM' THEN
          IF ( p_index_type =  'MAT'  AND l_table NOT LIKE 'CSF_WOM%' ) THEN
             l_index_name := l_index_name || l_data_set_name;
             l_table := l_table || l_data_set_name ||'_V';
          ELSIF l_table  NOT LIKE 'CSF_WOM%' THEN
             l_index_name := l_index_name || l_data_set_name;
             l_table := l_table || l_data_set_name;
          END IF;
        END IF;

            DROP_INDEX ( l_applsys_schema, l_app_short_name, l_table , l_index_name, errbuf, retcode );

    END LOOP;

    CLOSE CSF_GET_SPATIAL_INDEXES;

EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
       CLOSE CSF_GET_SPATIAL_INDEXES;
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'DROP_INDEXES PROCEDURE HAS FAILED FOR '|| p_index_type || 'TYPE INDEXES' ||  SQLERRM);
       put_stream(g_output,'DROP_INDEXES PROCEDURE HAS FAILED FOR '|| p_index_type || 'TYPE INDEXES' ||  SQLERRM);
       RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS
    THEN
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'DROP_INDEXES PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       CLOSE CSF_GET_SPATIAL_INDEXES;
       RAISE FND_API.G_EXC_ERROR;

END DROP_INDEXES;


PROCEDURE REFRESH_MAT_VIEW (
         p_mv_name      in              VARCHAR2 ,
         errbuf         OUT NOCOPY      VARCHAR2 ,
         retcode        OUT NOCOPY      VARCHAR2 )
IS
BEGIN
    DBMS_MVIEW.REFRESH(p_mv_name);
    put_stream(g_output, 'Refresh of ' || p_mv_name || ' is successfull ');
    put_stream(g_log, 'Refresh of ' || p_mv_name || ' is successfull ');

EXCEPTION
     WHEN OTHERS THEN
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_output, 'Refresh of ' || p_mv_name || ' failed : ' ||SQLCODE||'-'|| SQLERRM );
       put_stream(g_log, 'Refresh of ' || p_mv_name || ' failed : ' || SQLCODE||'-'||SQLERRM );
       RAISE FND_API.G_EXC_ERROR;
END REFRESH_MAT_VIEW;

PROCEDURE REFRESH_MAT_VIEWS(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS
    l_data_set_name        VARCHAR2(40);
BEGIN

    put_stream(g_log, '  ' );
    put_stream(g_log, 'Start of Procedure REFRESH_MAT_VIEWS ' );
    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

    REFRESH_MAT_VIEW('CSF_MD_ADM_BOUNDS_MAT' ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_HYDROS_MAT'     ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_LAND_USES_MAT'  ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_POIS_MAT'       ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_RAIL_SEGS_MAT'  ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_RD_SEGS_FUN0'   ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_RD_SEGS_FUN1'   ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_RD_SEGS_FUN2'   ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_RD_SEGS_FUN3'   ||l_data_set_name || '_V'   , errbuf, retcode);
    REFRESH_MAT_VIEW('CSF_MD_RD_SEGS_FUN4'   ||l_data_set_name || '_V'   , errbuf, retcode);
    -- WOM mat view is common for all the datasets.
    REFRESH_MAT_VIEW('CSF_WOM_ROAD_HIWAY_MAT_V' , errbuf, retcode);

    put_stream(g_log, 'The procedure REFRESH_MAT_VIEWS has completed successfully');
    put_stream(g_log, 'Materialized view refresh is successful');

  EXCEPTION
    WHEN OTHERS THEN
         put_stream(g_output,'REFRESH_MAT_VIEW PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM );
         put_stream(g_log, 'REFRESH_MAT_VIEW PROCEDURE HAS FAILED'  || SQLCODE||'-'||SQLERRM);
         retcode := 1;
         errbuf := SQLERRM;
         RAISE FND_API.G_EXC_ERROR;
         --RETURN ;
END REFRESH_MAT_VIEWS;

PROCEDURE COMPUTE_STATISTICS(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS
    l_data_set_name        VARCHAR2(40);
BEGIN

    put_stream(g_log, '  ' );
    put_stream(g_log, 'Start of Procedure COMPUTE_STATISTICS ' );
    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

    -- Delete the statistics on Map tables.
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_BLOCKS'               ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_NAMES'                ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_PLACES'               ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_PLACE_NAMES'          ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_PLACE_POSTCS'         ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_POIS'                 ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_POI_NAMES'            ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_POSTCODES'            ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGMENTS'         ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGM_NAMES'       ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGM_PLACES'      ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGM_POSTS'       ||l_data_set_name, 'DELETE');

    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_ADM_BOUNDS'           ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_HYDROS'               ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_LAND_USES'            ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_NAMES'                ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_POIS'                 ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_POI_NM_ASGNS'         ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_RAIL_SEGS'            ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_RDSEG_NM_ASGNS'       ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_RD_SEGS'              ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SDM_CTRY_PROFILES'       ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_STAT_M'          ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_STAT_TILES_M'    ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_STREET_TYPES_M'  ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_VER_M'           ||l_data_set_name, 'DELETE');

    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_BINARY_MAPS'         ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_BINARY_TILES'        ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_CONDITIONS'          ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_COND_SEGS'           ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_INTERVALS'           ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_NODES'               ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_RDBLCK_INTVLS'       ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_RDBLCK_SGMNTS'       ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_ROADBLOCKS'          ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_SEGMENTS'            ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_SEGM_NODES'          ||l_data_set_name, 'DELETE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_TILES'               ||l_data_set_name, 'DELETE');

    put_stream(g_log, 'Deleted the statistics on all spatial tables');

    -- Re-compute the statistics on Map tables.
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_BLOCKS'               ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_NAMES'                ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_PLACES'               ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_PLACE_NAMES'          ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_PLACE_POSTCS'         ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_POIS'                 ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_POI_NAMES'            ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_POSTCODES'            ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGMENTS'         ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGM_NAMES'       ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGM_PLACES'      ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_LF_ROADSEGM_POSTS'       ||l_data_set_name, 'COMPUTE');

    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_ADM_BOUNDS'           ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_HYDROS'               ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_LAND_USES'            ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_NAMES'                ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_POIS'                 ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_POI_NM_ASGNS'         ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_RAIL_SEGS'            ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_RDSEG_NM_ASGNS'       ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_MD_RD_SEGS'              ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SDM_CTRY_PROFILES'       ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_STAT_M'          ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_STAT_TILES_M'    ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_STREET_TYPES_M'  ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_SPATIAL_VER_M'           ||l_data_set_name, 'COMPUTE');

    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_BINARY_MAPS'         ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_BINARY_TILES'        ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_CONDITIONS'          ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_COND_SEGS'           ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_INTERVALS'           ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_NODES'               ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_RDBLCK_INTVLS'       ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_RDBLCK_SGMNTS'       ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_ROADBLOCKS'          ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_SEGMENTS'            ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_SEGM_NODES'          ||l_data_set_name, 'COMPUTE');
    DBMS_DDL.analyze_object('TABLE', 'CSF', 'CSF_TDS_TILES'               ||l_data_set_name, 'COMPUTE');

    put_stream(g_log, 'Re-computed the statistics on spatial tables');
    put_stream(g_output, 'Re-computed the statistics on spatial tables');
    put_stream(g_log, 'The procedure COMPUTE_STATISTICS has completed successfully');

EXCEPTION
        WHEN OTHERS THEN
        retcode := 1;
        errbuf := SQLERRM;
        put_stream(g_output, 'COMPUTE_STATISTICS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);
        put_stream(g_log, 'COMPUTE_STATISTICS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);
        RAISE FND_API.G_EXC_ERROR;

END COMPUTE_STATISTICS;

PROCEDURE CHECK_TABLE_ROW_COUNT(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS

   /* CURSOR csf_spatial_stat_m_cur
   IS
   SELECT table_name, num_records
   FROM csf_spatial_stat_m; */

   TYPE csf_spatial_stat_ref_cur IS REF CURSOR;
   csf_spatial_stat_m_cur csf_spatial_stat_ref_cur;

   CURSOR TAB_Cur (p_table_name TAB.TNAME%TYPE)
   IS
   SELECT COUNT(1)
   FROM TAB
   WHERE TNAME = p_table_name;

   TYPE row_count_refcur IS REF CURSOR;
   row_count_cur        row_count_refcur;
   v_table_name VARCHAR2 (100);
   v_record_count NUMBER (10);
   v_actual_record_count NUMBER (10);
   v_query VARCHAR2 (2000);
   v_table_exists NUMBER(10);
   flagCount NUMBER (10) DEFAULT 0;
   l_data_set_name        VARCHAR2(40);

BEGIN

    put_stream(g_log, '  ' );
    put_stream(g_log, 'Start of Procedure CHECK_TABLE_ROW_COUNT ' );
    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

   v_query := 'SELECT table_name, num_records FROM csf_spatial_stat_m' || l_data_set_name ;
   OPEN csf_spatial_stat_m_cur for v_query;
   LOOP
      FETCH csf_spatial_stat_m_cur
      INTO v_table_name, v_record_count;
      EXIT WHEN csf_spatial_stat_m_cur%NOTFOUND;

      v_table_name := v_table_name || l_data_set_name;

      OPEN TAB_Cur(v_table_name);
      FETCH TAB_Cur INTO v_table_exists;
      CLOSE TAB_Cur;

      IF v_table_exists = 0  THEN
         put_stream(g_log, 'TABLE ' || v_table_name || ' DOES NOT EXIST');
      ELSE
         v_query := 'SELECT COUNT(1) FROM ' || v_table_name;

         OPEN row_count_cur for v_query;
         FETCH row_count_cur INTO v_actual_record_count;
         CLOSE row_count_cur;
         --dbms_output.put_line(v_table_name || ' Actual Count: '|| v_actual_record_count|| 'Table Count: '|| v_record_count );
         IF v_actual_record_count <> v_record_count  THEN
            put_stream(g_log, v_table_name || ' is not having correct count. Actual Count: '|| v_actual_record_count|| 'Table Count: '|| v_record_count );
            --dbms_output.put_line(v_table_name || ' is not having correct count. Actual Count: '|| v_actual_record_count|| 'Table Count: '|| v_record_count );
            flagCount := flagCount + 1;
         END IF;
      END IF;
    END LOOP;
    CLOSE csf_spatial_stat_m_cur;

    IF flagCount = 0   THEN
       put_stream(g_log, 'NO MISMATCH IN TABLE ROW COUNT -- ALL THE TABLES HAVE BEEN LOADED PROPERLY ');
       put_stream(g_output, 'NO MISMATCH IN TABLE ROW COUNT -- ALL THE TABLES HAVE BEEN LOADED PROPERLY ');
       --dbms_output.put_line('NO MISMATCH IN TABLE ROW COUNT -- ALL THE TABLES HAVE BEEN LOADED PROPERLY ');
    ELSE
      put_stream(g_log, 'FOUND MISMATCH IN TABLE ROW COUNT');
      put_stream(g_output, 'FOUND MISMATCH IN TABLE ROW COUNT');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    put_stream(g_log, 'The procedure CHECK_TABLE_ROW_COUNT has completed successfully');
    --dbms_output.put_line('The procedure CHECK_TABLE_ROW_COUNT has completed successfully');
 EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      CLOSE csf_spatial_stat_m_cur;
      retcode := 1;
      errbuf := SQLERRM;
      put_stream(g_log,'CHECK_TABLE_ROW_COUNT PROCEDURE HAS FAILED '|| SQLCODE||'-'||SQLERRM);
      put_stream(g_output,'CHECK_TABLE_ROW_COUNT PROCEDURE HAS FAILED '|| SQLCODE||'-'||SQLERRM);
      RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS
   THEN
      CLOSE csf_spatial_stat_m_cur;
      retcode := 1;
      errbuf := SQLERRM;
      put_stream(g_log,'CHECK_TABLE_ROW_COUNT PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
      put_stream(g_output,'CHECK_TABLE_ROW_COUNT PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
      RAISE FND_API.G_EXC_ERROR;

END CHECK_TABLE_ROW_COUNT;

PROCEDURE VALIDATE_BLOB_SIZE(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS
    TYPE VALIDATE_BLOB_SIZE_CUR_REF IS REF CURSOR;
    VALIDATE_BLOB_SIZE_CUR VALIDATE_BLOB_SIZE_CUR_REF;

    TYPE CSF_SPATIAL_STAT_LENGTH_REF IS REF CURSOR;
    CSF_SPATIAL_STAT_LENGTH_CHECK CSF_SPATIAL_STAT_LENGTH_REF;

    v_query1 VARCHAR2 (2000);
    v_query2 VARCHAR2 (2000);

    v_binary_tile_id          NUMBER(10);
    v_segment_lob_size        NUMBER(10);
    v_node_lob_size           NUMBER(10);
    v_actual_segment_lob_size NUMBER(10);
    v_actual_node_lob_size    NUMBER(10);
    flagSegment               NUMBER(10) DEFAULT 0;
    flagNode                  NUMBER(10) DEFAULT 0;

    l_data_set_name        VARCHAR2(40);
BEGIN

    put_stream(g_log, '  ' );
    put_stream(g_log, 'Start of Procedure VALIDATE_BLOB_SIZE ' );
    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

    v_query1 := 'SELECT BINARY_TILE_ID, SEGMENT_LOB_SIZE, NODE_LOB_SIZE
                 FROM CSF_SPATIAL_STAT_TILES_M' || l_data_set_name;

    OPEN CSF_SPATIAL_STAT_LENGTH_CHECK FOR v_query1;
    LOOP
    FETCH CSF_SPATIAL_STAT_LENGTH_CHECK INTO v_binary_tile_id, v_segment_lob_size, v_node_lob_size;
      EXIT
      WHEN CSF_SPATIAL_STAT_LENGTH_CHECK%NOTFOUND;

      v_query2 := 'SELECT dbms_lob.getlength(SEGMENTS), dbms_lob.getlength(NODES)
                   FROM CSF_TDS_BINARY_TILES'|| l_data_set_name ||
                 ' WHERE BINARY_TILE_ID  = ' || v_binary_tile_id ;

      OPEN VALIDATE_BLOB_SIZE_CUR FOR v_query2;
      FETCH VALIDATE_BLOB_SIZE_CUR INTO v_actual_segment_lob_size, v_actual_node_lob_size;
      CLOSE VALIDATE_BLOB_SIZE_CUR;

      IF v_actual_segment_lob_size <> v_segment_lob_size THEN
        put_stream(g_log,' SEGMENT SIZE DOESNOT MATCH FOR BINARY TILE ID ' || v_binary_tile_id );
        put_stream(g_log,'Truncate CSF_TDS_BINARY_TILES table and reload it with Navteq import software using BLOBImport group');
        put_stream(g_output,' SEGMENT SIZE DOESNOT MATCH FOR BINARY TILE ID ' || v_binary_tile_id );
        put_stream(g_output,'Truncate CSF_TDS_BINARY_TILES table and reload it with Navteq import software using BLOBImport group');
        flagSegment := flagSegment + 1;
      END IF;

      IF v_actual_node_lob_size <> v_node_lob_size THEN
        put_stream(g_log,' NODE SIZE DOESNOT MATCH FOR BINARY TILE ID ' || v_binary_tile_id );
        put_stream(g_log,'Truncate CSF_TDS_BINARY_TILES table and reload it with Navteq import software using BLOBImport group');
        put_stream(g_output,' NODE SIZE DOESNOT MATCH FOR BINARY TILE ID ' || v_binary_tile_id );
        put_stream(g_output,'Truncate CSF_TDS_BINARY_TILES table and reload it with Navteq import software using BLOBImport group');
        flagNode := flagNode + 1;
      END IF;

    END LOOP;

    IF flagSegment = 0 THEN
      put_stream(g_log, ' NO MISMATCH FOR SEGMENT ');
      put_stream(g_output, ' NO MISMATCH FOR SEGMENT ');
      --dbms_output.put_line(' NO MISMATCH FOR SEGMENT ');
    ELSE
        put_stream(g_log, 'FOUND MISMATCH FOR SEGMENT ');
        put_stream(g_log, 'FOUND MISMATCH FOR SEGMENT ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF flagNode = 0 THEN
      put_stream(g_log, ' NO MISMATCH FOR NODE ');
      put_stream(g_output, ' NO MISMATCH FOR NODE ');
      --dbms_output.put_line(' NO MISMATCH FOR NODE ');
    ELSE
        put_stream(g_log, 'FOUND MISMATCH FOR NODE ');
        put_stream(g_log, 'FOUND MISMATCH FOR NODE ');
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   CLOSE CSF_SPATIAL_STAT_LENGTH_CHECK;

    put_stream(g_log, 'The procedure VALIDATE_BLOB_SIZE has completed successfully');

 EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      CLOSE CSF_SPATIAL_STAT_LENGTH_CHECK;
      CLOSE VALIDATE_BLOB_SIZE_CUR;
      retcode := 1;
      errbuf := SQLERRM;
      put_stream(g_log,'VALIDATE_BLOB_SIZE PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
      put_stream(g_output,'VALIDATE_BLOB_SIZE PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
      RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS
   THEN
      CLOSE CSF_SPATIAL_STAT_LENGTH_CHECK;
      CLOSE VALIDATE_BLOB_SIZE_CUR;
      retcode := 1;
      errbuf := SQLERRM;
      put_stream(g_log,'VALIDATE_BLOB_SIZE PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
      put_stream(g_output,'VALIDATE_BLOB_SIZE PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
      RAISE FND_API.G_EXC_ERROR;

END VALIDATE_BLOB_SIZE;

PROCEDURE CHECK_INDEX_VALIDITY(
      p_data_set_name IN             VARCHAR2,
      p_index_type   IN              VARCHAR2,
      p_status       OUT NOCOPY      VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS
  CURSOR csf_index_stat_validity_check (p_owner in VARCHAR2,
                                         p_index_name in VARCHAR2)
  IS
  SELECT status, domidx_opstatus
  FROM all_indexes
  WHERE owner = p_owner
    AND (index_name LIKE 'CSF_MD%' OR index_name LIKE 'CSF_LF%' OR index_name LIKE 'CSF_TDS%' OR INDEX_NAME like 'CSF_WOM%')
    AND index_name = p_index_name;

  CURSOR CSF_GET_SPATIAL_INDEXES (p_index_type   in  VARCHAR2)
  IS
  SELECT INDEX_NAME
  FROM CSF_SPATIAL_INDEX_STAT_M
  WHERE index_type = p_index_type;

  l_index_name        VARCHAR2(100);
  l_status            VARCHAR2(20);
  l_domidx_opstatus   VARCHAR2(20);
  l_app_short_name    VARCHAR2(20);
  l_flagInvalidCount  REAL DEFAULT 0;

  l_data_set_name        VARCHAR2(40);

BEGIN

    OPEN CSF_GET_SPATIAL_INDEXES (p_index_type);
    LOOP
        FETCH CSF_GET_SPATIAL_INDEXES INTO l_index_name;
        EXIT WHEN CSF_GET_SPATIAL_INDEXES%NOTFOUND;

        l_data_set_name  := p_data_set_name;

        IF l_index_name NOT LIKE  'CSF_WOM%' THEN
            l_index_name := l_index_name || l_data_set_name;
        END IF;


        IF l_index_name IS NOT NULL THEN

            -- Materialized view indexes are part of APPS schema and all other indexes are part of CSF schema.
            IF p_index_type  = 'MAT' THEN
                l_app_short_name := upper( 'APPS' ) ;
            ELSE
                l_app_short_name := upper( 'CSF' ) ;
            END IF;

            OPEN  csf_index_stat_validity_check(l_app_short_name,l_index_name);
            FETCH  csf_index_stat_validity_check INTO l_status, l_domidx_opstatus ;
                IF csf_index_stat_validity_check%NOTFOUND THEN
                   l_flagInvalidCount := l_flagInvalidCount + 1;
                   put_stream(g_log,' INDEX ' || l_index_name || ' NOT FOUND' );
               END IF;--IF csf_index_stat_validity_check%NOTFOUND

             --  IF l_status IS NOT NULL AND l_domidx_opstatus IS NOT NULL THEN
                   IF l_index_name LIKE 'CSF_MD_%' THEN
                      IF NOT(l_domidx_opstatus = NULL OR l_domidx_opstatus = 'VALID') THEN
                         l_flagInvalidCount := l_flagInvalidCount + 1;
                         put_stream(g_log,' DOMIDX_OPSTATUS: INVALID FOR INDEX: ' || l_index_name);
                       END IF;
                    END IF;

                    IF NOT(l_status = 'VALID') THEN
                         put_stream(g_log,' STATUS: INVALID FOR INDEX: ' || l_index_name);
                         l_flagInvalidCount := l_flagInvalidCount + 1;
                    END IF;
              -- END IF; -- l_status IS NOT NULL AND l_domidx_opstatus IS NOT NULL
        END IF; -- l_index_name IS NOT NULL AND l_index_type IS NOT NULL
        CLOSE csf_index_stat_validity_check;
    END LOOP;
    IF l_flagInvalidCount = 0 THEN
      put_stream(g_log,' ALL '|| p_index_type || ' INDEXES ARE VALID ');
      put_stream(g_output,' ALL '|| p_index_type || ' INDEXES ARE VALID ');
      p_status := 0;
    END IF;
    CLOSE CSF_GET_SPATIAL_INDEXES;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
       CLOSE CSF_INDEX_STAT_VALIDITY_CHECK;
       CLOSE CSF_GET_SPATIAL_INDEXES;
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'CHECK_INDEX_VALIDIDTY PROCEDURE HAS FAILED FOR ' || p_index_type || ' INDEXES' ||SQLCODE||'-'|| SQLERRM);
       RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS
   THEN
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'CHECK_INDEX_VALIDIDTY PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       CLOSE CSF_INDEX_STAT_VALIDITY_CHECK;
       CLOSE CSF_GET_SPATIAL_INDEXES;
       RAISE FND_API.G_EXC_ERROR;

END CHECK_INDEX_VALIDITY;

PROCEDURE RECREATE_INVALID_INDEXES(
      p_data_set_name IN             VARCHAR2,
      p_tablespace   IN              VARCHAR2,
      p_index_type   IN              VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS
  CURSOR csf_index_stat_validity_check (p_owner in VARCHAR2,
                                         p_index_name in VARCHAR2)
  IS
  SELECT status, domidx_opstatus
  FROM all_indexes
  WHERE owner = p_owner
    AND (index_name LIKE 'CSF_MD%' OR index_name LIKE 'CSF_LF%' OR index_name LIKE 'CSF_TDS%' OR INDEX_NAME like 'CSF_WOM%')
    AND index_name = p_index_name;

  CURSOR CSF_GET_SPATIAL_INDEXES (p_index_type   in  VARCHAR2)
  IS
  SELECT INDEX_NAME
  FROM CSF_SPATIAL_INDEX_STAT_M
  WHERE index_type = p_index_type;

  l_index_name        VARCHAR2(100);
  l_index_name_temp  VARCHAR2(100);
  l_status            VARCHAR2(20);
  l_domidx_opstatus   VARCHAR2(20);
  l_app_short_name    VARCHAR2(20);
  l_flagInvalidCount  REAL DEFAULT 0;
  l_data_set_name        VARCHAR2(40);
BEGIN

    OPEN CSF_GET_SPATIAL_INDEXES (p_index_type);
    LOOP
        FETCH CSF_GET_SPATIAL_INDEXES INTO l_index_name;
        EXIT WHEN CSF_GET_SPATIAL_INDEXES%NOTFOUND;

        l_data_set_name  := p_data_set_name;

        IF l_index_name NOT LIKE 'CSF_WOM%' THEN
           l_index_name_temp := l_index_name || l_data_set_name;
        END IF;

        IF l_index_name IS NOT NULL THEN

            -- Materialized view indexes are part of APPS schema and all other indexes are part of CSF schema.
            IF p_index_type  = 'MAT' THEN
                l_app_short_name := upper( 'APPS' ) ;
            ELSE
                l_app_short_name := upper( 'CSF' ) ;
            END IF;

            OPEN  csf_index_stat_validity_check(l_app_short_name,l_index_name_temp);
            FETCH  csf_index_stat_validity_check INTO l_status, l_domidx_opstatus ;
                IF csf_index_stat_validity_check%NOTFOUND THEN
                   l_flagInvalidCount := l_flagInvalidCount + 1;
                   put_stream(g_log,' INDEX ' || l_index_name_temp || ' NOT FOUND' );
                   put_stream(g_log,'Recreating the  INDEX ' || l_index_name_temp );
                   RECREATE_INDEX(l_data_set_name,l_index_name,p_tablespace,p_index_type, errbuf,retcode);
               END IF;--IF csf_index_stat_validity_check%NOTFOUND

               IF l_status IS NOT NULL AND l_domidx_opstatus IS NOT NULL THEN
                   IF l_index_name_temp LIKE 'CSF_MD_%' THEN
                      IF NOT(l_domidx_opstatus = NULL OR l_domidx_opstatus = 'VALID') THEN
                         l_flagInvalidCount := l_flagInvalidCount + 1;
                         put_stream(g_log,' DOMIDX_OPSTATUS: INVALID FOR INDEX: ' || l_index_name_temp);
                         put_stream(g_log,' Recreating the index : '  || l_index_name_temp);
                         RECREATE_INDEX(l_data_set_name,l_index_name,p_tablespace,p_index_type,errbuf,retcode);
                       END IF;
                    END IF;

                    IF NOT(l_status = 'VALID') THEN
                         put_stream(g_log,' STATUS: INVALID FOR INDEX: ' || l_index_name_temp);
                         l_flagInvalidCount := l_flagInvalidCount + 1;
                         put_stream(g_log,' Recreating the index : '  || l_index_name_temp);
                         RECREATE_INDEX(l_data_set_name,l_index_name,p_tablespace,p_index_type,errbuf,retcode);
                    END IF;
               END IF; -- l_status IS NOT NULL AND l_domidx_opstatus IS NOT NULL
        END IF; -- l_index_name IS NOT NULL AND l_index_type IS NOT NULL
        CLOSE csf_index_stat_validity_check;
    END LOOP;
    IF l_flagInvalidCount = 0 THEN
      put_stream(g_log,' ALL '|| p_index_type || ' INDEXES ARE VALID ');
    END IF;
    CLOSE CSF_GET_SPATIAL_INDEXES;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
       CLOSE CSF_INDEX_STAT_VALIDITY_CHECK;
       CLOSE CSF_GET_SPATIAL_INDEXES;
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'RECREATE_INVALID_INDEXES PROCEDURE HAS FAILED FOR ' || p_index_type || ' INDEXES' ||SQLCODE||'-'|| SQLERRM);
       put_stream(g_output,'RECREATE_INVALID_INDEXES PROCEDURE HAS FAILED FOR ' || p_index_type || ' INDEXES' ||SQLCODE||'-'|| SQLERRM);
       RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS
   THEN
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'RECREATE_INVALID_INDEXES PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       put_stream(g_output,'RECREATE_INVALID_INDEXES PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       CLOSE CSF_INDEX_STAT_VALIDITY_CHECK;
       CLOSE CSF_GET_SPATIAL_INDEXES;
       RAISE FND_API.G_EXC_ERROR;

END RECREATE_INVALID_INDEXES;


PROCEDURE CREATE_INDEXES(
      p_data_set_name IN             VARCHAR2,
      p_tablespace   in              VARCHAR2,
      p_index_type   in              VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS

   CURSOR CSF_GET_SPATIAL_INDEXES (p_index_type   in  VARCHAR2)
   IS
     SELECT INDEX_NAME,
            table_name ,
            index_columns,
            index_create_sql
     FROM  CSF_SPATIAL_INDEX_STAT_M
     WHERE index_type = p_index_type;

    l_index_name        VARCHAR2(100);
    l_applsys_schema    VARCHAR2(10);
    l_app_short_name    VARCHAR2(20);
    l_table             VARCHAR2(60);
    l_index             VARCHAR2(60);
    l_columns_arr       CHAR30_ARR;
    l_columns_str       VARCHAR2(200);
    l_column            VARCHAR2(60);
    l_tablespace        VARCHAR2(60);
    l_create_sql        VARCHAR2(4000);
    l_data_set_name     VARCHAR2(40);
    i                   NUMBER;

BEGIN

    l_applsys_schema := upper( 'APPS' ) ;

    -- Creating indexes in APPS schema as the Materialized views
    -- are created as part of APPS schema.
    IF p_index_type  = 'MAT' THEN
        l_app_short_name := upper( 'APPS' ) ;
    ELSE
        l_app_short_name := upper( 'CSF' ) ;
    END IF;

    l_tablespace     := upper ( p_tablespace );

    l_data_set_name  := p_data_set_name;

    OPEN CSF_GET_SPATIAL_INDEXES(p_index_type);
    LOOP
        FETCH CSF_GET_SPATIAL_INDEXES
        INTO l_index_name,
             l_table,
             l_columns_str,
             l_create_sql;
        EXIT WHEN CSF_GET_SPATIAL_INDEXES%NOTFOUND;

        IF p_index_type  <> 'WOM' THEN
          IF ( p_index_type =  'MAT'  AND l_table NOT LIKE 'CSF_WOM%' ) THEN
            l_index_name := l_index_name || l_data_set_name;
            l_table := l_table || l_data_set_name ||'_V';
          ELSIF l_table  NOT LIKE 'CSF_WOM%' THEN
            l_index_name := l_index_name || l_data_set_name;
            l_table := l_table || l_data_set_name;
          END IF;
        END IF;

        IF l_index_name IS NOT NULL THEN
            IF l_create_sql IS NOT NULL THEN
                select replace(l_create_sql,'l_tablespace',l_tablespace) into l_create_sql from dual;
                select replace(l_create_sql,'l_index',l_index_name) into l_create_sql from dual;
                select replace(l_create_sql,'l_table',l_table) into l_create_sql from dual;
             END IF;
             /* The following block converts the string of comma seperated
                index names to table of varchars.
             */
             BEGIN
                 l_columns_arr := CHAR30_ARR();
                 i := 1;
                 LOOP
                 EXIT WHEN INSTR(l_columns_str , ',') = 0 OR INSTR(l_columns_str , ',') is null;
                   SELECT SUBSTR(l_columns_str, 1, INSTR(l_columns_str , ',')-1) INTO l_column FROM dual;
                   SELECT SUBSTR(l_columns_str, INSTR(l_columns_str , ',')+1) INTO l_columns_str FROM dual;
                   l_columns_arr.extend(1);
                   l_columns_arr(i) := l_column;
                   i := i + 1 ;
                 END LOOP;
                 l_columns_arr.extend(1);
                 l_columns_arr(i) := l_columns_str;
              END;

             CREATE_INDEX ( l_applsys_schema, l_app_short_name, l_table, l_index_name, l_columns_arr, l_create_sql, errbuf, retcode );

        END IF; -- l_index_name IS NOT NULL
     END LOOP;

   CLOSE CSF_GET_SPATIAL_INDEXES;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
       CLOSE CSF_GET_SPATIAL_INDEXES;
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'CREATE_INDEX PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       put_stream(g_output,'CREATE_INDEX PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       RAISE FND_API.G_EXC_ERROR;

   WHEN OTHERS
   THEN
       retcode := 1;
       errbuf := SQLERRM;
       put_stream(g_log,'CREATE_INDEX PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       put_stream(g_output,'CREATE_INDEX PROCEDURE HAS FAILED '||SQLCODE||'-'|| SQLERRM);
       CLOSE CSF_GET_SPATIAL_INDEXES;
       RAISE FND_API.G_EXC_ERROR;

END CREATE_INDEXES;

PROCEDURE RECREATE_INDEX (
        p_data_set_name IN             VARCHAR2,
        p_index_name   IN              VARCHAR2,
        p_tablespace   IN              VARCHAR2,
        p_index_type   IN              VARCHAR2,
        errbuf         OUT NOCOPY      VARCHAR2,
        retcode        OUT NOCOPY      VARCHAR2 )
IS
   l_index_type        VARCHAR2(10);
   l_applsys_schema    VARCHAR2(10);
   l_app_short_name    VARCHAR2(20);
   l_table             VARCHAR2(60);
   l_index_name             VARCHAR2(100);
   l_columns_arr       CHAR30_ARR;
   l_columns_str       VARCHAR2(200);
   l_column            VARCHAR2(60);
   l_tablespace        VARCHAR2(60) ;
   l_create_sql        VARCHAR2(4000);
   i                   NUMBER;
   l_data_set_name     VARCHAR2(40);

BEGIN

    l_applsys_schema := upper( 'APPS' ) ;
    l_tablespace := UPPER ( p_tablespace );

    l_data_set_name  := p_data_set_name;

    IF p_index_name IS NOT NULL THEN

      SELECT table_name,
             index_columns,
             index_create_sql,
             index_type
      INTO   l_table,
             l_columns_str,
             l_create_sql,
             l_index_type
      FROM CSF_SPATIAL_INDEX_STAT_M where INDEX_NAME = p_index_name;

      -- Checking indexes in APPS schema as the Materialized views
      -- are created as part of APPS schema.
      IF l_index_type  = 'MAT' THEN
          l_app_short_name := upper( 'APPS' ) ;
       ELSE
          l_app_short_name := upper( 'CSF' ) ;
       END IF;

        IF p_index_type  <> 'WOM' THEN
          IF ( p_index_type =  'MAT'  AND l_table NOT LIKE 'CSF_WOM%' ) THEN
            l_index_name := l_index_name || l_data_set_name;
            l_table := l_table || l_data_set_name ||'_V';
          ELSIF l_table  NOT LIKE 'CSF_WOM%' THEN
            l_index_name := l_index_name || l_data_set_name;
            l_table := l_table || l_data_set_name;
          END IF;
        END IF;

      IF l_create_sql IS NOT NULL THEN
          SELECT replace(l_create_sql,'l_tablespace',l_tablespace) INTO l_create_sql FROM dual;
          SELECT replace(l_create_sql,'l_index',p_index_name) INTO l_create_sql FROM dual;
          SELECT replace(l_create_sql,'l_table',l_table) INTO l_create_sql FROM dual;
      END IF;

     /* The following block converts the string of comma seperated
        index names to table of varchars.
      */
       BEGIN
         l_columns_arr := CHAR30_ARR();
         i := 1;
         LOOP
         EXIT WHEN INSTR(l_columns_str , ',') = 0 OR INSTR(l_columns_str , ',') is null;
           SELECT SUBSTR(l_columns_str, 1, INSTR(l_columns_str , ',')-1) INTO l_column FROM dual;
           SELECT SUBSTR(l_columns_str, INSTR(l_columns_str , ',')+1) INTO l_columns_str FROM dual;
           l_columns_arr.extend(1);
           l_columns_arr(i) := l_column;
           i := i + 1 ;
         END LOOP;
         l_columns_arr.extend(1);
         l_columns_arr(i) := l_columns_str;
       END;

    CREATE_INDEX ( l_applsys_schema, l_app_short_name, l_table, l_index_name, l_columns_arr, l_create_sql, errbuf, retcode );

  END IF; --IF v_index_name IS NOT NULL

EXCEPTION
        WHEN OTHERS THEN
        retcode := 1;
        errbuf := SQLERRM;
        put_stream(g_output, 'RECREATE_INDEX PROCEDURE HAS FAILED' ||SQLCODE ||'-'|| SQLERRM);
        put_stream(g_log, 'RECREATE_INDEX PROCEDURE HAS FAILED' ||SQLCODE ||'-'|| SQLERRM);
        RAISE FND_API.G_EXC_ERROR;

END RECREATE_INDEX;

/*   Procedure to drop route cache table.  Fix for bug : 9019583

     When a route is calculated by Time Distance Server (TDS), the route information is stored in CSF_TDS_ROUTE_CACHE table.
     When the same route details are requested by Scheduler for the second time, TDS doesn't calculate the route again and
     it provides the route by referring the CSF_TDS_ROUTE_CACHE table. The route details are dataset specific and cannotbe
     used across the datasets. When a new dataset is loaded, this table data need to be cleared.
*/

PROCEDURE TRUNC_ROUTE_CAHCE_TABLE(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 )
IS
    l_data_set_name        VARCHAR2(40);
    l_sch                  VARCHAR2(10);
BEGIN

    put_stream(g_log, '  ' );
    put_stream(g_log, 'Start of Procedure TRUNC_ROUTE_CAHCE_TABLE ' );
    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;
    l_sch := 'CSF';

    EXECUTE IMMEDIATE  'TRUNCATE TABLE '|| l_sch  || '.CSF_TDS_ROUTE_CACHE' || p_data_set_name;

    put_stream(g_log, 'The procedure TRUNC_ROUTE_CAHCE_TABLE has completed successfully');
    put_stream(g_log, 'Truncating table CSF_TDS_ROUTE_CACHE' || p_data_set_name||'  is successful');

  EXCEPTION
    WHEN OTHERS THEN
         put_stream(g_output,'TRUNC_ROUTE_CAHCE_TABLE PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM );
         put_stream(g_log, 'TRUNC_ROUTE_CAHCE_TABLE PROCEDURE HAS FAILED'  || SQLCODE||'-'||SQLERRM);
         retcode := 1;
         errbuf := SQLERRM;
         RAISE FND_API.G_EXC_ERROR;
         --RETURN ;
END TRUNC_ROUTE_CAHCE_TABLE;

END CSF_SPATIAL_DATALOAD_PVT;

/
