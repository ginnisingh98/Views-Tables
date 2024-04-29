--------------------------------------------------------
--  DDL for Package Body CSF_SPATIAL_TTSP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_SPATIAL_TTSP_PVT" AS
/* $Header: CSFVTTSPB.pls 120.0.12010000.4 2009/08/21 11:52:06 vpalle noship $ */

  PROCEDURE ttsp_plugin(p_directory VARCHAR2) IS
    l_dir VARCHAR2(100) := 'TTS_NAVTEQ_2008';
  BEGIN
    EXECUTE IMMEDIATE 'CREATE  OR REPLACE directory ' || l_dir || ' as ' || p_directory;

  END;

  /*   The following procedure is used to print the log messages.*/
  PROCEDURE dbgl(p_msg_data VARCHAR2) IS
    i pls_integer;
    l_msg VARCHAR2(300);
  BEGIN
    i := 1;
    LOOP
      l_msg := SUBSTR(p_msg_data,   i,   255);
      EXIT  WHEN l_msg IS NULL;

      EXECUTE IMMEDIATE g_debug_p USING l_msg;
      i := i + 255;
    END LOOP;
  END dbgl;

  /*  The following procedure is used to print the log messages.  */
  PROCEDURE put_stream(p_handle IN NUMBER,
                       p_msg_data IN VARCHAR2)
  IS
  BEGIN

    IF p_handle = 0 THEN
      dbgl(p_msg_data);
      ELSIF p_handle = -1 THEN
        IF g_debug THEN
          dbgl(p_msg_data);
        END IF;
      ELSE
        fnd_file.PUT_LINE(p_handle, p_msg_data);
      END IF;
    --dbms_output.put_line(p_msg_data);
  END put_stream;

  /*The following procedure is used to print the log messages.*/

  /*PROCEDURE CSF_LOG( p_handle IN NUMBER,l_log IN VARCHAR2 )
  IS
  BEGIN
    dbms_output.put_line( l_log );
  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END CSF_LOG; */

   /*
    The following steps list the basic activities involved in using the Data Pump API.
    The steps are presented in the order in which the activities would generally be performed:
      1. Execute the DBMS_DATAPUMP.OPEN procedure to create a Data Pump job and its infrastructure.
      2. Define any parameters for the job.
      3. Start the job.
      4. Optionally, monitor the job until it completes.
      5. Optionally, detach from the job and reattach at a later time.
      6. Optionally, stop the job.
      7. Optionally, restart the job, if desired.
  */
  PROCEDURE DATAPUMP_EXPORT(
     p_dmp_file       IN   VARCHAR2,
     p_table_space  IN   VARCHAR2,
     p_data_set_name  IN   VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS
    l_dp_handle       NUMBER;                         -- Data Pump job handle
    l_dmp_file        VARCHAR2(100) ;                 -- The dump file name.
    l_log_file        VARCHAR2(100) ;                 -- The log file name.
    l_data_file_dir   VARCHAR2(240) ;                 -- Data files directory
    l_table_space   VARCHAR2(100);                 -- The data file name string.
    l_data_file        VARCHAR2(1000);                -- The data file name .
    l_job_state       VARCHAR2(30);                   -- To keep track of DATAPUMP job state.
    l_lerror          ku$_LogEntry;                   -- For WIP and error messages.
    l_job_status      ku$_JobStatus;                  -- The job status from get_status.
    l_job_desc        ku$_JobDesc;                    -- The job description from get_status.
    l_status          ku$_Status;                     -- The status object returned by get_status
    l_ind             NUMBER;                         -- Loop index
    l_percent_done    NUMBER;                         -- Percentage of job complete
    l_str_pos         NUMBER;                         -- String starting position
    l_str_len         NUMBER;                         -- String length for output
    i                 NUMBER;                         -- Loop index

    l_instance_name VARCHAR2(100);
    l_job_name VARCHAR2(100);
    l_date DATE;
    l_temp VARCHAR2(10);
  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure DATAPUMP_EXPORT ' );

    put_stream(g_log, '====================================' );

    l_dmp_file  := p_dmp_file;

    l_table_space := p_table_space;

    SELECT SYSDATE INTO l_date FROM dual;

    SELECT instance_name INTO l_instance_name from v$instance;

    l_job_name := 'EXPORT_JOB' || TO_CHAR(l_date,'MISS');

    l_log_file := 'EXPORT_' || TO_CHAR(l_date,'DDMMYY_HH24MISS') || '_' || l_instance_name|| '_'  || p_data_set_name || '.log';

    put_stream(g_log, 'DATAPUMP EXPORT JOB NAME : ' || l_job_name);

    put_stream(g_log, 'DATAPUMP EXPORT LOG FILE NAME : ' || l_log_file );

    --  1. Execute the DBMS_DATAPUMP.OPEN procedure to create a Data Pump job and its infrastructure.
    l_dp_handle := DBMS_DATAPUMP.open(
                            operation   => 'EXPORT',
                            job_mode    => 'TRANSPORTABLE',
                            remote_link => NULL,
                            job_name    => l_job_name,
                            version     => 'LATEST');

    put_stream(g_log,'   STEP 1 done - Create an handle for DATAPUMP TRANSPORTABLE EXPORT JOB');

    -- 2. Define any parameters for the job.
    -- 2.1 Add dump file parameter
    DBMS_DATAPUMP.add_file(
                            handle    => l_dp_handle,
                            filename  => l_dmp_file,
                            directory => g_directory_name,
                            filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);

    put_stream(g_log,'   STEP 2.1 done - Set the dump file parameter');

    --2.2 Add log file parameter.
    DBMS_DATAPUMP.add_file(
                            handle    => l_dp_handle,
                            filename  => l_log_file,
                            directory => g_directory_name,
                            filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

    put_stream(g_log,'   STEP 2.2 done - Set the log file parameter');

    -- 2.3 Add TTS_FULL_CHECK parameter
    DBMS_DATAPUMP.set_parameter(
                             handle => l_dp_handle,
                             name=>'TTS_FULL_CHECK',
                             value=>1);

    put_stream(g_log,'   STEP 2.3 done - Set TTS_FULL_CHECK parameter');

    DBMS_DATAPUMP.metadata_filter(
                             handle => l_dp_handle,
                             Name => 'TABLESPACE_EXPR',
                             value => 'IN (''' || l_table_space || ''')' );

    put_stream(g_log,'     STEP 2.4 - Set TABLESPACE_EXPR IN ('''|| l_table_space || ''')');
	-- 3 . Start the DATAPUMP job.
    DBMS_DATAPUMP.start_job(l_dp_handle);

    put_stream(g_log, '   STEP 3 done - Start the EXPORT Job');

    -- 4. Optionally wait for the job to complete.
    -- In the following loop, the job is monitored until it completes.
    l_percent_done := 0;

    l_job_state := 'UNDEFINED';

    while (l_job_state <> 'COMPLETED') and (l_job_state <> 'STOPPED') loop

      DBMS_DATAPUMP.GET_STATUS(
                          l_dp_handle,
                          dbms_datapump.ku$_status_job_error +
                          dbms_datapump.ku$_status_job_status +
                          dbms_datapump.ku$_status_wip,
                          -1,
                          l_job_state,
                          l_status);

      l_job_status := l_status.job_status;

      -- If the percentage done changed, display the new value.
      IF l_job_status.percent_done <> l_percent_done THEN

        put_stream(g_log,'            *** Job percent done = ' || to_char(l_job_status.percent_done));

        l_percent_done := l_job_status.percent_done;

     END IF;

    END LOOP;

    put_stream(g_log, '   STEP 4 done - wait for the job to complete.');

    put_stream(g_log,'  Final job state = ' || l_job_state );

    DBMS_DATAPUMP.detach(l_dp_handle);

    put_stream(g_log, '   STEP 5 done - Export job is done');

    put_stream(g_log, 'End of Procedure DATAPUMP_EXPORT : Export job is completed successfully ' );

    put_stream(g_log, 'Please view the datapump log file to view the list of datafiles. ' );

    put_stream(g_log, '======================================================================= ' );

  EXCEPTION

    WHEN OTHERS THEN

      put_stream(g_log,  'Exception in Data Pump export job . Exception Details : ');

      put_stream(g_output, 'Exception in Data Pump export job . Exception Details : ');

      dbms_datapump.get_status(
                              l_dp_handle,
                              dbms_datapump.ku$_status_job_error,
                              0,
                              l_job_state,
                              l_status);

      IF ( bitand(l_status.mask,dbms_datapump.ku$_status_job_error) <> 0 ) THEN

        l_lerror := l_status.error;

        IF l_lerror IS NOT NULL THEN

          l_ind := l_lerror.FIRST;

          WHILE l_ind IS NOT NULL LOOP

            l_str_pos := 1;

            l_str_len := LENGTH(l_lerror(l_ind).LogText);

            IF l_str_len > 255 THEN

              l_str_len := 255;

            END IF;

            WHILE l_str_len > 0 LOOP

              put_stream(g_log, substr(l_lerror(l_ind).LogText,l_str_pos,l_str_len));

              put_stream(g_output, substr(l_lerror(l_ind).LogText,l_str_pos,l_str_len));

              l_str_pos := l_str_pos + 255;

              l_str_len := LENGTH(l_lerror(l_ind).LogText) + 1 - l_str_pos;

            END LOOP; -- WHILE l_str_len > 0

            l_ind := l_lerror.NEXT(l_ind);

          END LOOP;  -- WHILE l_ind IS NOT NULL

        END IF;  -- IF l_lerror IS NOT NULL

      END IF; -- IF ( bitand(l_status.mask,dbms_datapump.ku$_status_job_error) <> 0 )

      -- Optionally STOP the job incase of exception.
      DBMS_DATAPUMP.stop_job(
                       handle => l_dp_handle,
                       immediate => 1,
                       keep_master => 0);

      DBMS_DATAPUMP.detach(l_dp_handle);

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'DATAPUMP_EXPORT PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_output, 'Please view the datapump log for more details');

      put_stream(g_log, 'DATAPUMP_EXPORT PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END DATAPUMP_EXPORT;

  /*
    The following steps list the basic activities involved in using the Data Pump API.
    The steps are presented in the order in which the activities would generally be performed:
      1. Execute the DBMS_DATAPUMP.OPEN procedure to create a Data Pump job and its infrastructure.
      2. Define any parameters for the job.
      3. Start the job.
      4. Optionally, monitor the job until it completes.
      5. Optionally, detach from the job and reattach at a later time.
      6. Optionally, stop the job.
      7. Optionally, restart the job, if desired.
  */
  PROCEDURE DATAPUMP_IMPORT(
     p_dmp_file       IN   VARCHAR2,
     p_data_file_dir  IN   VARCHAR2,
     p_data_file_str  IN   VARCHAR2,
     p_data_set_name  IN   VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS
    l_dp_handle       NUMBER;                         -- Data Pump job handle
    l_dmp_file        VARCHAR2(100) ;                 -- The dump file name.
    l_log_file        VARCHAR2(100) ;                 -- The log file name.
    l_data_file_dir   VARCHAR2(240) ;                 -- Data files directory
    l_data_file_str   VARCHAR2(1000);                 -- The data file name string.
    l_data_file        VARCHAR2(1000);                -- The data file name .
    l_job_state       VARCHAR2(30);                   -- To keep track of DATAPUMP job state.
    l_lerror          ku$_LogEntry;                   -- For WIP and error messages.
    l_job_status      ku$_JobStatus;                  -- The job status from get_status.
    l_job_desc        ku$_JobDesc;                    -- The job description from get_status.
    l_status          ku$_Status;                     -- The status object returned by get_status
    l_ind             NUMBER;                         -- Loop index
    l_percent_done    NUMBER;                         -- Percentage of job complete
    l_str_pos         NUMBER;                         -- String starting position
    l_str_len         NUMBER;                         -- String length for output
    i                 NUMBER;                         -- Loop index

    l_instance_name VARCHAR2(100);
    l_job_name VARCHAR2(100);
    l_date DATE;
    l_temp VARCHAR2(10);
  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure DATAPUMP_IMPORT ' );

    put_stream(g_log, '====================================' );

    l_dmp_file  := p_dmp_file;

    l_data_file_str := p_data_file_str;

    SELECT SYSDATE INTO l_date FROM dual;

    SELECT instance_name INTO l_instance_name from v$instance;

    l_job_name := 'IMPORT_JOB' || TO_CHAR(l_date,'MISS');

    l_log_file := 'IMPORT_' || TO_CHAR(l_date,'DDMMYY_HH24MISS') || '_' || l_instance_name|| '_'  || p_data_set_name || '.log';

    put_stream(g_log, 'DATAPUMP JOB NAME : ' || l_job_name);

    put_stream(g_log, 'DATAPUMP LOG FILE NAME : ' || l_log_file );

    --  1. Execute the DBMS_DATAPUMP.OPEN procedure to create a Data Pump job and its infrastructure.
    l_dp_handle := DBMS_DATAPUMP.open(
                            operation   => 'IMPORT',
                            job_mode    => 'TRANSPORTABLE',
                            remote_link => NULL,
                            job_name    => l_job_name,
                            version     => 'LATEST');

    put_stream(g_log,'   STEP 1 done - Create an handle for DATAPUMP TRANSPORTABLE IMPORT JOB');

    -- 2. Define any parameters for the job.
    -- 2.1 Add dump file parameter
    DBMS_DATAPUMP.add_file(
                            handle    => l_dp_handle,
                            filename  => l_dmp_file,
                            directory => g_directory_name,
                            filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);

    put_stream(g_log,'   STEP 2.1 done - Set the dump file parameter');

    --2.2 Add log file parameter.
    DBMS_DATAPUMP.add_file(
                            handle    => l_dp_handle,
                            filename  => l_log_file,
                            directory => g_directory_name,
                            filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

    put_stream(g_log,'   STEP 2.2 done - Set the log file parameter');

--    -- 2.3 Add TTS_FULL_CHECK parameter
--    DBMS_DATAPUMP.set_parameter(
--                            handle => l_dp_handle,
--                            name=>'TTS_FULL_CHECK',
--                            value=>1);
--
--    put_stream(g_log,'   STEP 2.3 done - Set the TTS_FULL_CHECK parameter');

    -- 2.4 Add data file parameter
    put_stream(g_log,'   STEP 2.3 - Set TABLESPACE_DATAFILE parameter');

    /* The following block converts the string of comma seperated data filenames to file names
       and sets the TABLESPACE_DATAFILE
    */
    BEGIN

      l_data_file_dir := p_data_file_dir;

      SELECT SUBSTR(l_data_file_dir, length(l_data_file_dir)) INTO l_temp  FROM dual;

      IF l_temp <> '/' THEN
        l_data_file_dir := l_data_file_dir || '/';
      END IF;

      i := 1;

      LOOP

        EXIT WHEN INSTR(l_data_file_str , ',') = 0 OR INSTR(l_data_file_str , ',') is null;

        SELECT SUBSTR(l_data_file_str, 1, INSTR(l_data_file_str , ',')-1) INTO l_data_file FROM dual;

        SELECT SUBSTR(l_data_file_str, INSTR(l_data_file_str , ',')+1) INTO l_data_file_str FROM dual;

        DBMS_DATAPUMP.SET_PARAMETER(
                                  handle => l_dp_handle,
                                  name=>'TABLESPACE_DATAFILE',
                                  value=> l_data_file_dir || l_data_file);

        put_stream(g_log,'     STEP 2.3.' || i ||' - Set TABLESPACE_DATAFILE = ' || l_data_file_dir ||l_data_file );

        i := i + 1 ;

      END LOOP;

      DBMS_DATAPUMP.SET_PARAMETER(
                                handle => l_dp_handle,
                                name=>'TABLESPACE_DATAFILE',
                                value=>l_data_file_dir || l_data_file_str);

      put_stream(g_log,'     STEP 2.3.' || i ||' - Set TABLESPACE_DATAFILE = '|| l_data_file_dir ||l_data_file_str );

    END;

    -- 3 . Start the DATAPUMP job.
    DBMS_DATAPUMP.start_job(l_dp_handle);

    put_stream(g_log, '   STEP 3 done - Start the Job');

    -- 4. Optionally wait for the job to complete.
    -- In the following loop, the job is monitored until it completes.
    l_percent_done := 0;

    l_job_state := 'UNDEFINED';

    while (l_job_state <> 'COMPLETED') and (l_job_state <> 'STOPPED') loop

      DBMS_DATAPUMP.GET_STATUS(
                          l_dp_handle,
                          dbms_datapump.ku$_status_job_error +
                          dbms_datapump.ku$_status_job_status +
                          dbms_datapump.ku$_status_wip,
                          -1,
                          l_job_state,
                          l_status);

      l_job_status := l_status.job_status;

      -- If the percentage done changed, display the new value.
      IF l_job_status.percent_done <> l_percent_done THEN
        put_stream(g_log,'           *** Job percent done = ' || to_char(l_job_status.percent_done));
        l_percent_done := l_job_status.percent_done;
      end if;
    end loop;

    put_stream(g_log, '   STEP 4 done - wait for the job to complete.');

    put_stream(g_log, 'Final job state = ' || l_job_state );

    DBMS_DATAPUMP.detach(l_dp_handle);

    put_stream(g_log, '   STEP 5 done - Export job is done');

    put_stream(g_log, 'End of Procedure DATAPUMP_IMPORT : Export job is completed successfully ' );
    put_stream(g_log, '======================================================================= ' );

  EXCEPTION

    WHEN OTHERS THEN

      put_stream(g_log,  'Exception in Data Pump job . Exception Details : ');

      put_stream(g_output, 'Exception in Data Pump job . Exception Details : ');

      dbms_datapump.get_status(
                              l_dp_handle,
                              dbms_datapump.ku$_status_job_error,
                              0,
                              l_job_state,
                              l_status);

      IF ( bitand(l_status.mask,dbms_datapump.ku$_status_job_error) <> 0 ) THEN

        l_lerror := l_status.error;

        IF l_lerror IS NOT NULL THEN

          l_ind := l_lerror.FIRST;

          WHILE l_ind IS NOT NULL LOOP

            l_str_pos := 1;

            l_str_len := LENGTH(l_lerror(l_ind).LogText);

            IF l_str_len > 255 THEN

              l_str_len := 255;

            END IF;

            WHILE l_str_len > 0 LOOP

              put_stream(g_log, substr(l_lerror(l_ind).LogText,l_str_pos,l_str_len));

              put_stream(g_output, substr(l_lerror(l_ind).LogText,l_str_pos,l_str_len));

              l_str_pos := l_str_pos + 255;

              l_str_len := LENGTH(l_lerror(l_ind).LogText) + 1 - l_str_pos;

            END LOOP; -- WHILE l_str_len > 0

            l_ind := l_lerror.NEXT(l_ind);

          END LOOP;  -- WHILE l_ind IS NOT NULL

        END IF;  -- IF l_lerror IS NOT NULL

      END IF; -- IF ( bitand(l_status.mask,dbms_datapump.ku$_status_job_error) <> 0 )

      -- Optionally STOP the job incase of exception.
      DBMS_DATAPUMP.stop_job(
                       handle => l_dp_handle,
                       immediate => 1,
                       keep_master => 0);

      DBMS_DATAPUMP.detach(l_dp_handle);

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'DATAPUMP_IMPORT PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_log, 'DATAPUMP_IMPORT PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END DATAPUMP_IMPORT;

 /* Creates a DATABASE DIRECOTRY*/
  PROCEDURE CREATE_DIRECTORY(
     p_directory_path VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS
  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure CREATE_DIRECTORY ' );

    put_stream(g_log, '====================================' );

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE directory ' || g_directory_name || ' as ''' || p_directory_path ||'''';

    --EXECUTE IMMEDIATE 'GRANT READ, WRITE ON DIRECTORY TTS_NAVTEQ_2008 TO CSF';

    IF (dbms_lob.fileexists(bfilename(g_directory_name, '.')) = 1 )  THEN

      put_stream(g_output, 'The specified file path exists');

    ELSE

      put_stream(g_log, ' The specified file path does not exist ');

      RAISE FND_API.G_EXC_ERROR;

    END IF;

    put_stream(g_log, 'End of Procedure CREATE_DIRECTORY : Directory created successfully ' );

    put_stream(g_log, '=================================+ ' );

  EXCEPTION
    WHEN others THEN

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'CREATE_DIRECTORY PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_log, 'CREATE_DIRECTORY PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END CREATE_DIRECTORY;

  /* Initializes all spatial indexes in a tablespace that was transported to another database.(For APPS user only.) */
  PROCEDURE INITIALIZE_INDEXES_FOR_TTS(
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS
  BEGIN
    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure INITIALIZE_INDEXES_FOR_TTS : Initializing Spatial Indexes for APPS user. ' );

    put_stream(g_log, '================================================ ' );

    SDO_UTIL.INITIALIZE_INDEXES_FOR_TTS;

    put_stream(g_log, 'End of Procedure INITIALIZE_INDEXES_FOR_TTS : Initialized Spatial Indexes for APPS user. ' );

    put_stream(g_log, '================================================ ' );

  EXCEPTION

    WHEN others THEN

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'INITIALIZE_INDEXES_FOR_TTS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_log, 'INITIALIZE_INDEXES_FOR_TTS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END INITIALIZE_INDEXES_FOR_TTS;

 /* Prepares a tablespace to be transported to another database, so that
    spatial indexes will be preserved during the transport operation.*/
 PROCEDURE PREPARE_INDEXES_FOR_TTS(
     p_table_space  IN VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS
  BEGIN
    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure PREPARE_INDEXES_FOR_TTS : Initializing Spatial Indexes for APPS user. ' );

    put_stream(g_log, '================================================ ' );

    SDO_UTIL.PREPARE_FOR_TTS(p_table_space);

    put_stream(g_log, 'End of Procedure PREPARE_INDEXES_FOR_TTS : Initialized Spatial Indexes for APPS user. ' );

    put_stream(g_log, '================================================ ' );

  EXCEPTION

    WHEN others THEN

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'PREPARE_INDEXES_FOR_TTS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_log, 'PREPARE_INDEXES_FOR_TTS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END PREPARE_INDEXES_FOR_TTS;

 /*  DBMS_STATS.EXPORT_TABLE_STATS Procedure
  ==================================
   This procedure retrieves statistics for all tables of table space being exported and stores them in the user stat table. */
  PROCEDURE EXPORT_TABLE_STATS(
     p_data_set_name IN             VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS

    l_data_set_name        VARCHAR2(40);

    l_table_suffix          VARCHAR2(40);

  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure EXPORT_TABLE_STATS ' );

    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

    IF l_data_set_name = 'NONE' THEN

      l_table_suffix := '_COMMON';
      l_data_set_name := '';

    ELSE

      l_table_suffix := '_' || l_data_set_name;

      l_data_set_name := '_' || l_data_set_name;

    END IF;


    /*  DBMS_STATS.EXPORT_TABLE_STATS Procedure
    ==================================
     This procedure retrieves statistics for a particular table and stores them in the user stat table.
    Cascade results in all index and column stats associated with the specified table being exported as well.   */

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_BLOCKS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_PLACES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_PLACE_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_PLACE_POSTCS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_POIS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_POI_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_POSTCODES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGMENTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGM_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGM_PLACES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGM_POSTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_ADM_BOUNDS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_HYDROS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_LAND_USES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_POIS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_POI_NM_ASGNS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_RAIL_SEGS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_RDSEG_NM_ASGNS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_RD_SEGS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_BINARY_MAPS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_BINARY_TILES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_CONDITIONS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_COND_SEGS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_INTERVALS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_NODES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_RDBLCK_INTVLS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_RDBLCK_SGMNTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_ROADBLOCKS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_SEGMENTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_SEGM_NODES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_TILES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SDM_CTRY_PROFILES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_STAT_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_VER_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_STAT_TILES_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_STREET_TYPES_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM');

    IF l_data_set_name = 'NONE' THEN

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_COUNTRY', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_LAKE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_OCEAN', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_STATE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_BOUNDARY_COUNTRY', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_BOUNDARY_STATE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_CITY_CAPITAL', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_CITY_METROPOLIS', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_CITY_SMALL', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_LANDUSE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_POI', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_ROAD_HIGHWAY', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

      DBMS_STATS.EXPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM__MD_META_BOUNDING_RECT', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM');

    END IF;

    put_stream(g_log, 'Imported Table Statistics for all the tables ' );

    put_stream(g_log, 'End of Procedure EXPORT_TABLE_STATS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

  EXCEPTION

    WHEN others THEN

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'EXPORT_TABLE_STATS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_log, 'EXPORT_TABLE_STATS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END EXPORT_TABLE_STATS;


  /*  DBMS_STATS.IMPORT_TABLE_STATS Procedure
  ==================================
  This procedure retrieves statistics for a all spatial tables from the user statistics table identified
  by stattab and stores them in the dictionary.  */
  PROCEDURE IMPORT_TABLE_STATS(
     p_data_set_name IN             VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS

    l_data_set_name        VARCHAR2(40);

    l_table_suffix          VARCHAR2(40);

  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure IMPORT_TABLE_STATS ' );

    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

    IF l_data_set_name = 'NONE' THEN

      l_table_suffix := '_COMMON';
      l_data_set_name := '';

    ELSE

      l_table_suffix := '_' || l_data_set_name;

      l_data_set_name := '_' || l_data_set_name;

    END IF;


    /*  DBMS_STATS.IMPORT_TABLE_STATS Procedure
    ==================================
     This procedure retrieves statistics for a particular table from the user statistics table identified
    by stattab and stores them in the dictionary. Cascade results in all index statistics associated with
    the specified table being imported as well.    */

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_BLOCKS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_PLACES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_PLACE_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_PLACE_POSTCS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_POIS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_POI_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_POSTCODES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGMENTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGM_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGM_PLACES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_LF_ROADSEGM_POSTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_ADM_BOUNDS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_HYDROS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_LAND_USES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_NAMES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_POIS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_POI_NM_ASGNS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_RAIL_SEGS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_RDSEG_NM_ASGNS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_MD_RD_SEGS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_BINARY_MAPS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_BINARY_TILES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_CONDITIONS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_COND_SEGS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_INTERVALS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_NODES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_RDBLCK_INTVLS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_RDBLCK_SGMNTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_ROADBLOCKS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_SEGMENTS' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_SEGM_NODES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_TDS_TILES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SDM_CTRY_PROFILES' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_STAT_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_VER_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_STAT_TILES_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_SPATIAL_STREET_TYPES_M' || l_data_set_name, STATTAB => 'TTSP_STATS' || l_table_suffix, CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    IF l_data_set_name = 'NONE' THEN

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_COUNTRY', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_LAKE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_OCEAN', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_STATE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_BOUNDARY_COUNTRY', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_BOUNDARY_STATE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_CITY_CAPITAL', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_CITY_METROPOLIS', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_CITY_SMALL', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_AREA_LANDUSE', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_POI', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM_ROAD_HIGHWAY', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

      DBMS_STATS.IMPORT_TABLE_STATS (OWNNAME => 'CSF',TABNAME => 'CSF_WOM__MD_META_BOUNDING_RECT', STATTAB => 'TTSP_STATS_COMMON', CASCADE => TRUE, STATOWN => 'SYSTEM',FORCE => TRUE);

    END IF;

    put_stream(g_log, 'Imported Table Statistics for all the tables ' );

    put_stream(g_log, 'End of Procedure IMPORT_TABLE_STATS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

  EXCEPTION

    WHEN others THEN

      retcode := 1;

      errbuf := sqlerrm;

      put_stream(g_output, 'IMPORT_TABLE_STATS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

      put_stream(g_log, 'IMPORT_TABLE_STATS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

      RAISE FND_API.G_EXC_ERROR;

  END IMPORT_TABLE_STATS;

  /* The following procedure Creates the synonyms for TTSP objects in APPS schema*/
  PROCEDURE CREATE_SYNONYMS(
     p_data_set_name IN             VARCHAR2,
     errbuf          OUT nocopy     VARCHAR2,
     retcode         OUT nocopy     VARCHAR2)
  IS

   l_data_set_name        VARCHAR2(40);

   l_schema    VARCHAR2(10);

  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure CREATE_SYNONYMS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    l_data_set_name  := p_data_set_name;

    l_schema  := 'CSF';

    IF l_data_set_name = 'NONE' THEN

      l_data_set_name := ' ';

    ELSE

      l_data_set_name := '_' || l_data_set_name;

    END IF;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_BLOCKS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_BLOCKS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_NAMES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_NAMES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_PLACES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_PLACES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_PLACE_NAMES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_PLACE_NAMES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_PLACE_POSTCS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_PLACE_POSTCS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_POIS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_POIS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_POI_NAMES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_POI_NAMES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_POSTCODES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_POSTCODES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_ROADSEGMENTS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_ROADSEGMENTS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_ROADSEGM_NAMES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_ROADSEGM_NAMES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_ROADSEGM_PLACES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_ROADSEGM_PLACES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_LF_ROADSEGM_POSTS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_LF_ROADSEGM_POSTS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_ADM_BOUNDS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_ADM_BOUNDS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_HYDROS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_HYDROS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_LAND_USES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_LAND_USES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_NAMES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_NAMES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_POIS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_POIS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_POI_NM_ASGNS' || l_data_set_name ||  ' FOR ' || l_schema || '.CSF_MD_POI_NM_ASGNS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_RAIL_SEGS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_RAIL_SEGS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_RDSEG_NM_ASGNS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_RDSEG_NM_ASGNS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_MD_RD_SEGS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_MD_RD_SEGS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_BINARY_MAPS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_BINARY_MAPS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_BINARY_TILES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_BINARY_TILES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_CONDITIONS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_CONDITIONS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_COND_SEGS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_COND_SEGS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_INTERVALS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_INTERVALS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_NODES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_NODES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_RDBLCK_INTVLS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_RDBLCK_INTVLS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_RDBLCK_SGMNTS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_RDBLCK_SGMNTS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_ROADBLOCKS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_ROADBLOCKS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_SEGMENTS' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_SEGMENTS' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_SEGM_NODES' || l_data_set_name||  ' FOR ' || l_schema || '.CSF_TDS_SEGM_NODES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_TDS_TILES' || l_data_set_name || ' FOR ' || l_schema || '.CSF_TDS_TILES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_SDM_CTRY_PROFILES' || l_data_set_name||  ' FOR ' || l_schema || '.CSF_SDM_CTRY_PROFILES' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_SPATIAL_STAT_M' || l_data_set_name || ' FOR ' || l_schema || '.CSF_SPATIAL_STAT_M' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_SPATIAL_VER_M' || l_data_set_name || ' FOR ' || l_schema || '.CSF_SPATIAL_VER_M' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_SPATIAL_STAT_TILES_M' || l_data_set_name || ' FOR ' || l_schema || '.CSF_SPATIAL_STAT_TILES_M' || l_data_set_name ;

    EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_SPATIAL_STREET_TYPES_M' || l_data_set_name || ' FOR ' || l_schema || '.CSF_SPATIAL_STREET_TYPES_M' || l_data_set_name ;

    IF (p_data_set_name = 'NONE' OR l_data_set_name = ' ') THEN

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_AREA_COUNTRY FOR ' || l_schema || '.CSF_WOM_AREA_COUNTRY' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_AREA_LAKE FOR ' || l_schema || '.CSF_WOM_AREA_LAKE' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_AREA_OCEAN FOR ' || l_schema || '.CSF_WOM_AREA_OCEAN' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_AREA_STATE FOR ' || l_schema || '.CSF_WOM_AREA_STATE' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_BOUNDARY_COUNTRY FOR ' || l_schema || '.CSF_WOM_BOUNDARY_COUNTRY' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_BOUNDARY_STATE FOR ' || l_schema || '.CSF_WOM_BOUNDARY_STATE' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_CITY_CAPITAL FOR ' || l_schema || '.CSF_WOM_CITY_CAPITAL' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_CITY_METROPOLIS FOR ' || l_schema || '.CSF_WOM_CITY_METROPOLIS' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_CITY_SMALL FOR ' || l_schema || '.CSF_WOM_CITY_SMALL' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_AREA_LANDUSE FOR ' || l_schema || '.CSF_WOM_AREA_LANDUSE' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_POI FOR ' || l_schema || '.CSF_WOM_POI' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM_ROAD_HIGHWAY FOR ' || l_schema || '.CSF_WOM_ROAD_HIGHWAY' ;

      EXECUTE IMMEDIATE 'CREATE  OR REPLACE SYNONYM CSF_WOM__MD_META_BOUNDING_RECT FOR ' || l_schema || '.CSF_WOM__MD_META_BOUNDING_RECT' ;

    END IF;

    put_stream(g_log, 'All the SYNONYMS are created. ' );

    put_stream(g_log, 'End of Procedure CREATE_SYNONYMS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    EXCEPTION
      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        put_stream(g_output, 'CREATE_SYNONYMS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        put_stream(g_log, 'CREATE_SYNONYMS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

  END CREATE_SYNONYMS;

  PROCEDURE DROP_TABLE( p_table_name IN VARCHAR2)
  IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || p_table_name;

    put_stream(g_log, p_table_name || ' dropped');

  EXCEPTION

    WHEN OTHERS THEN

      IF SQLCODE = -00942 THEN

        put_stream(g_log, p_table_name || ' does not exist');

      ELSE

        put_stream(g_output, 'DROP_TABLE PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        put_stream(g_log, 'DROP_TABLE PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

      END IF;

  END DROP_TABLE;

  PROCEDURE DROP_SPATIAL_TABLES( p_data_set_name IN VARCHAR2,
                                 errbuf    OUT nocopy     VARCHAR2,
                                 retcode   OUT nocopy     VARCHAR2 )
  IS
   l_data_set_name        VARCHAR2(40);

   l_schema    VARCHAR2(10);

  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure DROP_SPATIAL_TABLES for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    l_data_set_name    := p_data_set_name ;

    l_schema  := 'CSF';

    IF l_data_set_name = 'NONE' THEN

      l_data_set_name := '';

    ELSE

      l_data_set_name := '_' || l_data_set_name;

    END IF;

    DROP_TABLE( l_schema || '.CSF_LF_BLOCKS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_NAMES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_PLACES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_PLACE_NAMES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_PLACE_POSTCS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_POIS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_POI_NAMES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_POSTCODES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_ROADSEGMENTS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_ROADSEGM_NAMES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_ROADSEGM_PLACES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_LF_ROADSEGM_POSTS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_ADM_BOUNDS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_HYDROS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_LAND_USES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_NAMES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_POIS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_POI_NM_ASGNS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_RAIL_SEGS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_RDSEG_NM_ASGNS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_MD_RD_SEGS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_BINARY_MAPS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_BINARY_TILES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_CONDITIONS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_COND_SEGS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_INTERVALS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_NODES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_RDBLCK_INTVLS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_RDBLCK_SGMNTS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_ROADBLOCKS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_SEGMENTS' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_SEGM_NODES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_TDS_TILES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_SDM_CTRY_PROFILES' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_SPATIAL_STAT_M' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_SPATIAL_VER_M' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_SPATIAL_STAT_TILES_M' || l_data_set_name);

    DROP_TABLE( l_schema || '.CSF_SPATIAL_STREET_TYPES_M' || l_data_set_name);

    IF (p_data_set_name = 'NONE' OR l_data_set_name = '') THEN

      DROP_TABLE( l_schema || '.CSF_WOM_AREA_COUNTRY');

      DROP_TABLE( l_schema || '.CSF_WOM_AREA_LAKE');

      DROP_TABLE( l_schema || '.CSF_WOM_AREA_OCEAN');

      DROP_TABLE( l_schema || '.CSF_WOM_AREA_STATE');

      DROP_TABLE( l_schema || '.CSF_WOM_BOUNDARY_COUNTRY');

      DROP_TABLE( l_schema || '.CSF_WOM_BOUNDARY_STATE');

      DROP_TABLE( l_schema || '.CSF_WOM_CITY_CAPITAL');

      DROP_TABLE( l_schema || '.CSF_WOM_CITY_METROPOLIS');

      DROP_TABLE( l_schema || '.CSF_WOM_CITY_SMALL');

      DROP_TABLE( l_schema || '.CSF_WOM_AREA_LANDUSE');

      DROP_TABLE( l_schema || '.CSF_WOM_POI');

      DROP_TABLE( l_schema || '.CSF_WOM_ROAD_HIGHWAY');

      DROP_TABLE( l_schema || '.CSF_WOM__MD_META_BOUNDING_RECT');

    END IF;

    put_stream(g_log, 'All the spatial tables are dropped. ' );

    put_stream(g_log, 'End of Procedure DROP_SPATIAL_TABLES for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    EXCEPTION
      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        put_stream(g_output, 'DROP_SPATIAL_TABLES PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        put_stream(g_log, 'DROP_SPATIAL_TABLES PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

  END DROP_SPATIAL_TABLES;

  PROCEDURE DROP_MATERIALIZED_VIEW( p_mv_name IN VARCHAR2)
  IS
  BEGIN

    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || p_mv_name;

    put_stream(g_log, p_mv_name || ' dropped');

  EXCEPTION

    WHEN OTHERS THEN

      IF SQLCODE = -12003 THEN

        put_stream(g_log, p_mv_name || ' does not exist');

      ELSE

        put_stream(g_output, 'DROP_MATERIALIZED_VIEW PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        put_stream(g_log, 'DROP_MATERIALIZED_VIEW PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

      END IF;

  END DROP_MATERIALIZED_VIEW;

  PROCEDURE DROP_MATERIALIZED_VIEWS( p_data_set_name IN VARCHAR2,
                                     errbuf    OUT nocopy     VARCHAR2,
                                     retcode   OUT nocopy     VARCHAR)
  IS
    l_data_set_name        VARCHAR2(40);
	l_schema               VARCHAR2(10);
  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure DROP_MATERIALIZED_VIEWS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

	l_schema := 'APPS';

    l_data_set_name    := p_data_set_name ;

    IF l_data_set_name = 'NONE' THEN

      l_data_set_name := '';

    ELSE

      l_data_set_name := '_' || l_data_set_name;

    END IF;

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_RD_SEGS_FUN4'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_RD_SEGS_FUN3'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_HYDROS_MAT'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_ADM_BOUNDS_MAT'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_LAND_USES_MAT'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_POIS_MAT'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_RAIL_SEGS_MAT'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_RD_SEGS_FUN0'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_RD_SEGS_FUN1'|| l_data_set_name || '_V');

    DROP_MATERIALIZED_VIEW(l_schema || '.CSF_MD_RD_SEGS_FUN2'|| l_data_set_name || '_V');

    IF (p_data_set_name = 'NONE' OR l_data_set_name = '') THEN

       DROP_MATERIALIZED_VIEW(l_schema || '.CSF_WOM_ROAD_HIWAY_MAT_V');

    END IF;

    put_stream(g_log, 'All the MATERIALIZED VIEWS are dropped. ' );

    put_stream(g_log, 'End of Procedure DROP_MATERIALIZED_VIEWS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    EXCEPTION

      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        put_stream(g_output, 'DROP_MATERIALIZED_VIEWS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        put_stream(g_log, 'DROP_MATERIALIZED_VIEWS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

  END DROP_MATERIALIZED_VIEWS;

  PROCEDURE DROP_TTSP_STATS(   p_data_set_name    IN VARCHAR2,
                               errbuf    OUT nocopy     VARCHAR2,
                               retcode   OUT nocopy     VARCHAR)
  IS
	l_schema    VARCHAR2(10);
  BEGIN

    put_stream(g_log, '  ' );

    put_stream(g_log, 'Start of Procedure DROP_TTSP_STATS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    l_schema  := 'APPS';

    DROP_TABLE(l_schema || '.SDO_INDEX_TTS_METADATA$');

    l_schema  := 'CSF';

    DROP_TABLE(l_schema || '.SDO_INDEX_TTS_METADATA$');
    --EXECUTE IMMEDIATE 'DROP TABLESPACE '||p_tablespace ||' INCLUDING CONTENTS';

    put_stream(g_log, 'TTSP Statistical information tables dropped for APPS and CSF user' );

    put_stream(g_log, 'End of Procedure DROP_TTSP_STATS for  ' || p_data_set_name );

    put_stream(g_log, '================================================ ' );

    EXCEPTION
      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        put_stream(g_output, 'DROP_TTSP_STATS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        put_stream(g_log, 'DROP_TTSP_STATS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

  END DROP_TTSP_STATS;

 END CSF_SPATIAL_TTSP_PVT;


/
