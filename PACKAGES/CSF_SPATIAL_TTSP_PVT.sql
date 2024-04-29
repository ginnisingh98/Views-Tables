--------------------------------------------------------
--  DDL for Package CSF_SPATIAL_TTSP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_SPATIAL_TTSP_PVT" AUTHID CURRENT_USER AS
/* $Header: CSFVTTSPS.pls 120.0.12010000.2 2009/08/21 06:33:02 vpalle noship $ */

    g_debug_p             CONSTANT VARCHAR2 (100)
                          := 'begin dbms_' || 'output' || '.put_line(:1); end;';
    g_log                 CONSTANT NUMBER         := fnd_file.LOG;
    g_output              CONSTANT NUMBER         := fnd_file.output;
    g_debug                        BOOLEAN;
    g_directory_name       CONSTANT VARCHAR2(100) := 'TTS_NAVTEQ_2008';

  PROCEDURE DATAPUMP_EXPORT(
      p_dmp_file       IN   VARCHAR2,
      p_table_space  IN   VARCHAR2,
      p_data_set_name  IN   VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2);

  PROCEDURE DATAPUMP_IMPORT(
      p_dmp_file         IN VARCHAR2,
      p_data_file_dir    IN VARCHAR2,
      p_data_file_str    IN VARCHAR2,
      p_data_set_name    IN VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2) ;

  PROCEDURE CREATE_DIRECTORY(
      p_directory_path IN VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2);

  PROCEDURE INITIALIZE_INDEXES_FOR_TTS(
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2);

 PROCEDURE IMPORT_TABLE_STATS(
      p_data_set_name IN             VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2) ;

  PROCEDURE CREATE_SYNONYMS(
      p_data_set_name IN             VARCHAR2,
      errbuf          OUT nocopy     VARCHAR2,
      retcode         OUT nocopy     VARCHAR2) ;

  PROCEDURE DROP_TTSP_STATS(
      p_data_set_name    IN VARCHAR2,
      errbuf    OUT nocopy     VARCHAR2,
      retcode   OUT nocopy     VARCHAR);

  PROCEDURE DROP_MATERIALIZED_VIEWS(
      p_data_set_name IN VARCHAR2,
      errbuf    OUT nocopy     VARCHAR2,
      retcode   OUT nocopy     VARCHAR);

  PROCEDURE DROP_SPATIAL_TABLES(
      p_data_set_name IN VARCHAR2,
      errbuf    OUT nocopy     VARCHAR2,
      retcode   OUT nocopy     VARCHAR2 ) ;

  PROCEDURE PREPARE_INDEXES_FOR_TTS(
      p_table_space  IN VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2);

  PROCEDURE EXPORT_TABLE_STATS(
      p_data_set_name IN             VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2) ;

  /*  The following procedure is used to print the log messages.  */
  PROCEDURE put_stream(
      p_handle IN NUMBER,
      p_msg_data IN VARCHAR2) ;

END CSF_SPATIAL_TTSP_PVT;


/
