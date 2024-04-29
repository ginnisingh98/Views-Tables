--------------------------------------------------------
--  DDL for Package Body CSF_SPATIAL_DATALOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_SPATIAL_DATALOAD_PUB" AS
/* $Header: CSFPSDLB.pls 120.1.12010000.4 2009/10/28 05:56:20 vpalle noship $ */

PROCEDURE PRE_INSTALLATION_STEPS (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_dataset_name IN              VARCHAR2,
      p_WOM_flag     IN              VARCHAR2)
IS
      -- predefined error codes for concurrent programs
      l_rc_succ       CONSTANT NUMBER             := 0;
      l_rc_warn       CONSTANT NUMBER             := 1;
      l_rc_err        CONSTANT NUMBER             := 2;
      -- predefined error buffer output strings (replaced by translated messages)
      l_msg_succ               VARCHAR2 (80);
      l_msg_warn               VARCHAR2 (80);
      l_msg_err                VARCHAR2 (80);
      l_data_set_name          VARCHAR2(40);
BEGIN
      -- Initialize message list
      fnd_msg_pub.initialize;
      -- get termination messages
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_SUCC');
      l_msg_succ := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_WARN');
      l_msg_warn := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_ERR');
      l_msg_err := fnd_message.get;
      -- Initialize API return status to success
      retcode := l_rc_succ;
      errbuf := l_msg_succ;
      -- Get the Spatial Data set profile value
      l_data_set_name := p_dataset_name;
      -- It was decided to use a CP parameter instead of profile for dataset name.
      --fnd_profile.value('CSF_SPATIAL_DATASET_NAME');

      IF (l_data_set_name IS NULL OR l_data_set_name = 'NONE' ) THEN
      -- Don't append suffix to the table names if the dataset name in none.
        l_data_set_name := '';
      ELSE
        l_data_set_name := '_' || l_data_set_name;
      END IF;

      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Data set name : ' || l_data_set_name) ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'') ;

      -- Drop Map Display related indexes.
      CSF_SPATIAL_DATALOAD_PVT.DROP_INDEXES(l_data_set_name, 'MD', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Dropped the MD indexes successfully') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Dropped the MD indexes successfully') ;

      -- Drop Location Finder related indexes.
      CSF_SPATIAL_DATALOAD_PVT.DROP_INDEXES(l_data_set_name, 'LF', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, 'Dropped the LF indexes successfully') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Dropped the LF indexes successfully') ;

      -- Drop Time Distance Server  related indexes.
      CSF_SPATIAL_DATALOAD_PVT.DROP_INDEXES(l_data_set_name, 'TDS', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Dropped the TDS indexes successfully') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Dropped the TDS indexes successfully') ;

      -- Drop World Overview Map  related indexes.
      IF ( p_WOM_flag IS NOT NULL AND p_WOM_flag = 'Y' ) THEN
        CSF_SPATIAL_DATALOAD_PVT.DROP_INDEXES(l_data_set_name, 'WOM', errbuf, retcode);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Dropped the WOM indexes successfully') ;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'') ;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Dropped the WOM indexes successfully') ;
      END IF;

      -- Drop Materialized view based indexes.
      CSF_SPATIAL_DATALOAD_PVT.DROP_INDEXES(l_data_set_name, 'MAT', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Dropped the MAT View indexes successfully') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'') ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Dropped the MAT indexes successfully') ;

      IF retcode = l_rc_succ THEN
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Pre installations steps completed successfully') ;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Pre installations steps completed successfully') ;
      END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        retcode := l_rc_err;
        errbuf := l_msg_err;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'CSF_SPATIAL_DATALOAD_PUB.PRE_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLCODE||'-'|| SQLERRM);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'CSF_SPATIAL_DATALOAD_PUB.PRE_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLCODE||'-'|| SQLERRM);

    WHEN OTHERS THEN
        retcode := l_rc_err;
        errbuf := l_msg_err;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'CSF_SPATIAL_DATALOAD_PUB.PRE_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLCODE||'-'|| SQLERRM);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'CSF_SPATIAL_DATALOAD_PUB.PRE_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLCODE||'-'|| SQLERRM);

END PRE_INSTALLATION_STEPS;

-- Navteq Spatial Dataset - Post Installation Steps
-- after installation of the spatial data.
PROCEDURE POST_INSTALLATION_STEPS (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_dataset_name IN              VARCHAR2,
      p_table_space  IN              VARCHAR2,
      p_WOM_flag     IN              VARCHAR2)
IS
      -- predefined error codes for concurrent programs
      l_rc_succ       CONSTANT NUMBER             := 0;
      l_rc_warn       CONSTANT NUMBER             := 1;
      l_rc_err        CONSTANT NUMBER             := 2;
      -- predefined error buffer output strings (replaced by translated messages)
      l_msg_succ               VARCHAR2 (80);
      l_msg_warn               VARCHAR2 (80);
      l_msg_err                VARCHAR2 (80);
      l_table_space            VARCHAR2 (100);
      l_status                 NUMBER := 1;
      l_data_set_name          VARCHAR2(40);
BEGIN
      -- Initialize message list
      fnd_msg_pub.initialize;
      -- get termination messages
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_SUCC');
      l_msg_succ := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_WARN');
      l_msg_warn := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_ERR');
      l_msg_err := fnd_message.get;
      -- Initialize API return status to success
      retcode := l_rc_succ;
      errbuf := l_msg_succ;

      l_table_space  := p_table_space;

      BEGIN
        EXECUTE IMMEDIATE 'SELECT 1
                           FROM SYS.DBA_DATA_FILES
                           WHERE tablespace_name = :1'
                  USING    l_table_space;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Table space ''' || l_table_space ||''' exists.') ;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Table space ''' || l_table_space ||''' does not exist.') ;
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Table space ''' || l_table_space ||''' does not exist.') ;
            RAISE FND_API.G_EXC_ERROR;

          WHEN OTHERS  THEN
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'SELECT FROM SYS.DBA_DATA_FILES is failed : '||SQLCODE||'-'|| SQLERRM) ;
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'SELECT FROM SYS.DBA_DATA_FILES is failed : '||SQLCODE||'-'|| SQLERRM) ;
            RAISE FND_API.G_EXC_ERROR;
      END;

      -- Get the Spatial Data set profile value
      l_data_set_name := p_dataset_name;
      -- It was decided to use a CP parameter instead of profile for dataset name.
      --fnd_profile.value('CSF_SPATIAL_DATASET_NAME');

      IF (l_data_set_name IS NULL OR l_data_set_name = 'NONE' ) THEN
      -- Don't append suffix to the table names if the dataset name in none.
        l_data_set_name := '';
      ELSE
        l_data_set_name := '_' || l_data_set_name;
      END IF;

      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Data set name : ' || l_data_set_name) ;
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,' ');

      --l_enable_spatial_cps := fnd_profile.vlaue('CSF_ENABLE_SPATIAL_CPS');

      /* Step 1: Updating HZ_LOCATIONS table
      Scheduler uses geometry details stored on hz_locations to calculate travel distance
      and time. Incorrect geometry details may lead to in-correct results. To avoid this,
      the geometry column on HZ_LOCATIONS table should be cleared to populate the new geometry
      calculated by Location Finder leveraging this newly installed Navteq dataset.
      */
      BEGIN

        IF (l_data_set_name IS NULL OR l_data_set_name = '' ) THEN
          EXECUTE IMMEDIATE 'UPDATE hz_locations SET geometry = NULL';
          COMMIT;
        ELSE
           EXECUTE IMMEDIATE 'UPDATE hz_locations l SET geometry = NULL
                              WHERE EXISTS   ( SELECT 1
                                                 FROM CSF_SPATIAL_CTRY_MAPPINGS sp
                                                WHERE l.country      = sp.hr_country_code
                                                  AND sp.spatial_dataset = :1 )'  USING l_data_set_name;
          COMMIT;
        END IF;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'UPDATE hz_locations is successfull') ;

      EXCEPTION
          WHEN OTHERS  THEN
          CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'UPDATE hz_locations is failed : ' || SQLERRM) ;
          CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'UPDATE hz_locations is failed: ' || SQLERRM) ;
          RAISE FND_API.G_EXC_ERROR;
      END;

      -- Truncate CSF_TDS_ROUTE_CACHE TABLE. Bug : 9019583
      CSF_SPATIAL_DATALOAD_PVT.TRUNC_ROUTE_CAHCE_TABLE(l_data_set_name,errbuf, retcode);

      -- Validate spatial tables row count
      CSF_SPATIAL_DATALOAD_PVT.CHECK_TABLE_ROW_COUNT(l_data_set_name,errbuf, retcode);

      --BLOB size validation
      CSF_SPATIAL_DATALOAD_PVT.VALIDATE_BLOB_SIZE(l_data_set_name,errbuf, retcode);

      -- Step 2: Create Spatial Indexes
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, '  ' );
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, 'Creating the INDEXES' );
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, '================================================ ' );

      CSF_SPATIAL_DATALOAD_PVT.CREATE_INDEXES(l_data_set_name,l_table_space, 'MD', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'========== Created the MD indexes successfully ==========') ;

      -- Create LF indexes
      CSF_SPATIAL_DATALOAD_PVT.CREATE_INDEXES(l_data_set_name,l_table_space, 'LF', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'========== Created the LF indexes successfully ==========') ;
      -- Create TDS indexes
      CSF_SPATIAL_DATALOAD_PVT.CREATE_INDEXES(l_data_set_name,l_table_space, 'TDS', errbuf, retcode);
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'========== Created the TDS indexes successfully ==========') ;

      -- Create WOM indexes
      IF ( p_WOM_flag IS NOT NULL AND p_WOM_flag = 'Y' ) THEN
        CSF_SPATIAL_DATALOAD_PVT.CREATE_INDEXES(l_data_set_name,l_table_space, 'WOM', errbuf, retcode);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'========== Created the WOM indexes successfully ==========') ;
      END IF;

      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, ' Index Creation is successfull ' );
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output, ' Index Creation is successfull ' );
      -- check the index status. Recreate if any index is invalid
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, '  ' );
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, 'checking the index status' );
      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, '================================================ ' );

      CSF_SPATIAL_DATALOAD_PVT.CHECK_INDEX_VALIDITY(l_data_set_name,'MD',l_status, errbuf, retcode);
      IF (l_status <> 0) THEN
        CSF_SPATIAL_DATALOAD_PVT.RECREATE_INVALID_INDEXES(l_data_set_name,l_table_space,'MD', errbuf, retcode);
      END IF;

      CSF_SPATIAL_DATALOAD_PVT.CHECK_INDEX_VALIDITY(l_data_set_name,'LF',l_status, errbuf, retcode);
      IF (l_status <> 0) THEN
       CSF_SPATIAL_DATALOAD_PVT.RECREATE_INVALID_INDEXES(l_data_set_name,l_table_space,'LF', errbuf, retcode);
      END IF;

      CSF_SPATIAL_DATALOAD_PVT.CHECK_INDEX_VALIDITY(l_data_set_name,'TDS', l_status, errbuf, retcode);
      IF (l_status <> 0) THEN
        CSF_SPATIAL_DATALOAD_PVT.RECREATE_INVALID_INDEXES(l_data_set_name,l_table_space,'TDS', errbuf, retcode);
      END IF;

      IF ( p_WOM_flag IS NOT NULL AND p_WOM_flag = 'Y' ) THEN
        CSF_SPATIAL_DATALOAD_PVT.CHECK_INDEX_VALIDITY(l_data_set_name,'WOM',l_status, errbuf, retcode);
        IF (l_status <> 0) THEN
          CSF_SPATIAL_DATALOAD_PVT.RECREATE_INVALID_INDEXES(l_data_set_name,l_table_space,'WOM', errbuf, retcode);
        END IF;
      END IF;

    CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log, '========== checking the index status is successful ==========' );

    CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Post installtaion steps is successfull');
    CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Post installtaion steps is successfull');
          -- Step 3:  Re-compute Statistics on the Spatial Tables
      --          Refresh Materialized views
      --          Loading Map Configuration data
      --          This step is included in the procedure POST_INST_REFRESH_MVS.
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        retcode := l_rc_err;
        errbuf := l_msg_err;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'CSF_SPATIAL_DATALOAD_PUB.POST_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLERRM);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'CSF_SPATIAL_DATALOAD_PUB.POST_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLERRM);
    WHEN OTHERS THEN
        retcode := l_rc_err;
        errbuf := l_msg_err;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'CSF_SPATIAL_DATALOAD_PUB.POST_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLERRM);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'CSF_SPATIAL_DATALOAD_PUB.POST_INSTALLATION_STEPS PROCEDURE HAS FAILED '|| SQLERRM);
END POST_INSTALLATION_STEPS;

-- Navteq Spatial Dataset - Post Installation Steps
-- Step 3:  Re-compute Statistics on the Spatial Tables
--          Refresh Materialized views
--          Loading Map Configuration data
PROCEDURE POST_INST_REFRESH_MVS (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_dataset_name IN              VARCHAR2,
      p_table_space  IN              VARCHAR2,
      p_referesh_mvs_flag IN         VARCHAR2,
      p_compute_statistics_flag IN   VARCHAR2)
IS
      -- predefined error codes for concurrent programs
      l_rc_succ       CONSTANT NUMBER             := 0;
      l_rc_warn       CONSTANT NUMBER             := 1;
      l_rc_err        CONSTANT NUMBER             := 2;
      -- predefined error buffer output strings (replaced by translated messages)
      l_msg_succ               VARCHAR2 (80);
      l_msg_warn               VARCHAR2 (80);
      l_msg_err                VARCHAR2 (80);
      l_table_space            VARCHAR2 (100);
      l_status                 NUMBER  := 1;
      l_data_set_name          VARCHAR2(40);
BEGIN
      -- Initialize message list
      fnd_msg_pub.initialize;
      -- get termination messages
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_SUCC');
      l_msg_succ := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_WARN');
      l_msg_warn := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_ERR');
      l_msg_err := fnd_message.get;
      -- Initialize API return status to success
      retcode := l_rc_succ;
      errbuf := l_msg_succ;
      l_table_space := p_table_space;

      -- Validate the table space name
      BEGIN
        EXECUTE IMMEDIATE 'SELECT 1
                           FROM SYS.DBA_DATA_FILES
                           WHERE tablespace_name = :1'
                  USING    l_table_space;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Table space ''' || l_table_space ||''' exists.') ;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Table space ''' || l_table_space ||''' does not exist.') ;
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Table space ''' || l_table_space ||''' does not exist.') ;
            RAISE FND_API.G_EXC_ERROR;

          WHEN OTHERS  THEN
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'SELECT FROM SYS.DBA_DATA_FILES is failed : '||SQLCODE||'-'|| SQLERRM) ;
            CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'SELECT FROM SYS.DBA_DATA_FILES is failed : '||SQLCODE||'-'|| SQLERRM) ;
            RAISE FND_API.G_EXC_ERROR;
      END;

      -- Get the Spatial Data set profile value
      l_data_set_name := p_dataset_name;
      -- It was decided to use a CP parameter instead of profile for dataset name.
      --fnd_profile.value('CSF_SPATIAL_DATASET_NAME');

      IF (l_data_set_name IS NULL OR l_data_set_name = 'NONE' ) THEN
      -- Don't append suffix to the table names if the dataset name in none.
        l_data_set_name := '';
      ELSE
        l_data_set_name := '_' || l_data_set_name;
      END IF;

      CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Data set : ' || l_data_set_name) ;

      -- Drop all the materialized view indexes before refreshing the MVs.
      IF p_referesh_mvs_flag = 'Y' THEN
        CSF_SPATIAL_DATALOAD_PVT.DROP_INDEXES(l_data_set_name,'MAT',  errbuf, retcode);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Dropped the MAT indexes successfully') ;
      END IF;

      -- Compute the statistics on Spatial tables.
      IF p_compute_statistics_flag = 'Y' THEN
        CSF_SPATIAL_DATALOAD_PVT.COMPUTE_STATISTICS(l_data_set_name,errbuf, retcode);
      END IF;

      IF p_referesh_mvs_flag = 'Y' THEN
        --  Refresh Materialized views
        CSF_SPATIAL_DATALOAD_PVT.REFRESH_MAT_VIEWS(l_data_set_name,errbuf, retcode);

        -- Create MAT indexes
        CSF_SPATIAL_DATALOAD_PVT.CREATE_INDEXES(l_data_set_name,l_table_space, 'MAT', errbuf, retcode);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'Created the MAT View indexes successfully') ;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'Created the MAT View indexes successfully') ;

        -- check the index status of Materialized view indexes. Raise an error if any index is invalid
        CSF_SPATIAL_DATALOAD_PVT.CHECK_INDEX_VALIDITY(l_data_set_name,'MAT', l_status, errbuf, retcode);

        IF (l_status <> 0) THEN
         CSF_SPATIAL_DATALOAD_PVT.RECREATE_INVALID_INDEXES(l_data_set_name,l_table_space,'MAT', errbuf, retcode);
        END IF;
       END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        retcode := l_rc_err;
        errbuf := l_msg_err;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'CSF_SPATIAL_DATALOAD_PUB.POST_INST_REFRESH_MVS PROCEDURE HAS FAILED '|| SQLERRM);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'CSF_SPATIAL_DATALOAD_PUB.POST_INST_REFRESH_MVS PROCEDURE HAS FAILED '|| SQLERRM);

      WHEN OTHERS THEN
        retcode := l_rc_err;
        errbuf := l_msg_err;
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_log,'CSF_SPATIAL_DATALOAD_PUB.POST_INST_REFRESH_MVS PROCEDURE HAS FAILED '|| SQLERRM);
        CSF_SPATIAL_DATALOAD_PVT.put_stream(g_output,'CSF_SPATIAL_DATALOAD_PUB.POST_INST_REFRESH_MVS PROCEDURE HAS FAILED '|| SQLERRM);

END POST_INST_REFRESH_MVS;


End CSF_SPATIAL_DATALOAD_PUB;


/
