--------------------------------------------------------
--  DDL for Package Body CSF_SPATIAL_TTSP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_SPATIAL_TTSP_PUB" AS
/* $Header: CSFPTTSPB.pls 120.0.12010000.3 2009/08/21 08:37:42 vpalle noship $ */

  /* This procedure is called from Spatial Dataset TTSP Plugin concurrent program.
     It plugins the TTSP containg the spatial data with the help of DATAPUMP. It also imports
     the table statistics of all spatial tables and initializes all spatial indexes in a tablespace
     that was transported (APPS user ).

     Note :
         Initialization  all spatial indexes in a tablespace that was transported for CSF user
         can be done as follows :

           Connect csf/csf pwd

           and run  " begin  SDO_UTIL.INITIALIZE_INDEXES_FOR_TTS; end; "

     Parameters :

            p_directory_path : Directory path where the dump file is located. A database directory
                               'TTS_NAVTEQ_2008' for the given path and log files created at the same location.

            p_dmp_file       : Name of the dump file.

            p_data_file_dir  : Transport data files directory

            p_data_file_str  : List of transport datafiles with absolute path separated by ','.

            p_data_set_name  : Spatial data set name.
  */
  PROCEDURE TTSP_PLUGIN(
      errbuf    OUT nocopy     VARCHAR2,
      retcode   OUT nocopy     VARCHAR2,
      p_directory_path     IN  VARCHAR2,
      p_dmp_file           IN  VARCHAR2,
      p_data_file_dir       IN VARCHAR2,
      p_data_file_str      IN  VARCHAR2,
      p_data_set_name      IN  VARCHAR2 )
  IS
    -- predefined error codes for concurrent programs
    l_rc_succ       CONSTANT NUMBER             := 0;
    l_rc_warn       CONSTANT NUMBER             := 1;
    l_rc_err        CONSTANT NUMBER             := 2;
    -- predefined error buffer output strings (replaced by translated messages)
    l_msg_succ               VARCHAR2 (80);
    l_msg_warn               VARCHAR2 (80);
    l_msg_err                VARCHAR2 (80);

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

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '  ' );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'Start of Procedure TTSP_PLUGIN for  ' || p_data_set_name );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '================================================ ' );

    -- Create a DB directory for the directory path provided.
    CSF_SPATIAL_TTSP_PVT.CREATE_DIRECTORY(
          p_directory_path => p_directory_path,
          errbuf           => errbuf,
          retcode          => retcode );

    -- Import the TTSP using DATA PUMP.
    CSF_SPATIAL_TTSP_PVT.DATAPUMP_IMPORT(
          p_dmp_file       => p_dmp_file,
          p_data_file_dir  => p_data_file_dir,
          p_data_file_str  => p_data_file_str,
          p_data_set_name  => p_data_set_name,
          errbuf           => errbuf,
          retcode          => retcode );

    -- Run the post TTSP import for Spatial Indexes of APPS schema.
    CSF_SPATIAL_TTSP_PVT.INITIALIZE_INDEXES_FOR_TTS(
          errbuf           => errbuf,
          retcode          => retcode );

    --Run the statistics import for TTSP objects.
    CSF_SPATIAL_TTSP_PVT.IMPORT_TABLE_STATS(
          p_data_set_name  => p_data_set_name,
          errbuf           => errbuf,
          retcode          => retcode );

    -- Run the recreate synonyms
    CSF_SPATIAL_TTSP_PVT.CREATE_SYNONYMS(
          p_data_set_name  => p_data_set_name,
          errbuf           => errbuf,
          retcode          => retcode );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '  ' );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'End of Procedure TTSP_PLUGIN for  ' || p_data_set_name );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '================================================ ' );

  END TTSP_PLUGIN;


  /* This procedure is called from Spatial Dataset TTSP Plugout concurrent program.
     It drops all the objects of TTSP being plugged out.
     Parameter :
            p_data_set_name  : Spatial data set name.
  */
  PROCEDURE TTSP_PLUGOUT(
          errbuf    OUT nocopy      VARCHAR2,
          retcode   OUT nocopy      VARCHAR2,
          p_data_set_name    IN     VARCHAR2 )
  IS
   -- predefined error codes for concurrent programs
    l_rc_succ       CONSTANT NUMBER             := 0;
    l_rc_warn       CONSTANT NUMBER             := 1;
    l_rc_err        CONSTANT NUMBER             := 2;
    -- predefined error buffer output strings (replaced by translated messages)
    l_msg_succ               VARCHAR2 (80);
    l_msg_warn               VARCHAR2 (80);
    l_msg_err                VARCHAR2 (80);

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

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '  ' );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'Start of Procedure TTSP_PLUGOUT for  ' || p_data_set_name );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '================================================ ' );

    CSF_SPATIAL_TTSP_PVT.DROP_SPATIAL_TABLES(
          p_data_set_name  => p_data_set_name,
          errbuf           => errbuf,
          retcode          => retcode );

    CSF_SPATIAL_TTSP_PVT.DROP_MATERIALIZED_VIEWS(
          p_data_set_name  => p_data_set_name,
          errbuf           => errbuf,
          retcode          => retcode );

    CSF_SPATIAL_TTSP_PVT.DROP_TTSP_STATS(
          p_data_set_name  => p_data_set_name,
          errbuf           => errbuf,
          retcode          => retcode );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '  ' );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'End of Procedure TTSP_PLUGOUT for  ' || p_data_set_name );

    CSF_SPATIAL_TTSP_PVT.put_stream(g_log, '================================================ ' );


  EXCEPTION
    WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        CSF_SPATIAL_TTSP_PVT.put_stream(g_output, 'TTSP_PLUGOUT PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'TTSP_PLUGOUT PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);

        RAISE FND_API.G_EXC_ERROR;

  END TTSP_PLUGOUT;

  PROCEDURE DATAPUMP_EXPORT(
      p_dmp_file       IN   VARCHAR2,
      p_table_space  IN   VARCHAR2,
      p_data_set_name  IN   VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2)
  IS
  BEGIN

    CSF_SPATIAL_TTSP_PVT.DATAPUMP_EXPORT(
            P_DMP_FILE => P_DMP_FILE,
            P_TABLE_SPACE => P_TABLE_SPACE,
            P_DATA_SET_NAME => P_DATA_SET_NAME,
            ERRBUF => ERRBUF,
            RETCODE => RETCODE );

  EXCEPTION

      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        CSF_SPATIAL_TTSP_PVT.put_stream(g_output, 'CSF_SPATIAL_TTSP_PUB.DATAPUMP_EXPORT PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'CSF_SPATIAL_TTSP_PUB.DATAPUMP_EXPORT PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);
  END DATAPUMP_EXPORT;

  PROCEDURE PREPARE_INDEXES_FOR_TTS(
      p_table_space  IN VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2)
  IS
  BEGIN

    CSF_SPATIAL_TTSP_PVT.PREPARE_INDEXES_FOR_TTS(
              p_table_space => p_table_space,
              ERRBUF => ERRBUF,
              RETCODE => RETCODE  );

    EXCEPTION

      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        CSF_SPATIAL_TTSP_PVT.put_stream(g_output, 'CSF_SPATIAL_TTSP_PUB.PREPARE_INDEXES_FOR_TTS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'CSF_SPATIAL_TTSP_PUB.PREPARE_INDEXES_FOR_TTS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);
  END PREPARE_INDEXES_FOR_TTS;

 /*  DBMS_STATS.EXPORT_TABLE_STATS Procedure
  ==================================
   This procedure retrieves statistics for all tables of table space being exported and stores them in the user stat table. */
  PROCEDURE EXPORT_TABLE_STATS(
     p_data_set_name IN             VARCHAR2,
     errbuf OUT nocopy VARCHAR2,
     retcode OUT nocopy VARCHAR2)
  IS
  BEGIN

    CSF_SPATIAL_TTSP_PVT.EXPORT_TABLE_STATS(
            P_DATA_SET_NAME => P_DATA_SET_NAME,
            ERRBUF => ERRBUF,
            RETCODE => RETCODE );

    EXCEPTION

      WHEN others THEN

        retcode := 1;

        errbuf := sqlerrm;

        CSF_SPATIAL_TTSP_PVT.put_stream(g_output, 'CSF_SPATIAL_TTSP_PUB.EXPORT_TABLE_STATS PROCEDURE HAS FAILED' ||SQLCODE||'-'|| SQLERRM);

        CSF_SPATIAL_TTSP_PVT.put_stream(g_log, 'CSF_SPATIAL_TTSP_PUB.EXPORT_TABLE_STATS PROCEDURE HAS FAILED' || SQLCODE||'-'||SQLERRM);
 END EXPORT_TABLE_STATS;


 END CSF_SPATIAL_TTSP_PUB;


/
