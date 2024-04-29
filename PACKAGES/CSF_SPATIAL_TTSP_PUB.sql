--------------------------------------------------------
--  DDL for Package CSF_SPATIAL_TTSP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_SPATIAL_TTSP_PUB" AUTHID CURRENT_USER AS
/* $Header: CSFPTTSPS.pls 120.0.12010000.2 2009/08/21 06:31:51 vpalle noship $ */

  g_log                 CONSTANT NUMBER         := fnd_file.LOG;

  g_output              CONSTANT NUMBER         := fnd_file.output;

  /* This procedure is called from Spatial Dataset TTSP Plugout concurrent program.
     It drops all the objects of TTSP being plugged out.
     Parameter :
            p_data_set_name  : Spatial data set name.
  */
  PROCEDURE TTSP_PLUGOUT(
      errbuf    OUT nocopy     VARCHAR2,
      retcode   OUT nocopy     VARCHAR2,
      p_data_set_name       IN VARCHAR2 );

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

            p_data_file_str  : List of transport datafiles separated by ','.

            p_data_set_name  : Spatial data set name.
  */
  PROCEDURE TTSP_PLUGIN(
      errbuf    OUT nocopy     VARCHAR2,
      retcode   OUT nocopy     VARCHAR2,
      p_directory_path      IN VARCHAR2,
      p_dmp_file            IN VARCHAR2,
      p_data_file_dir       IN VARCHAR2,
      p_data_file_str       IN VARCHAR2,
      p_data_set_name       IN VARCHAR2 ) ;

  PROCEDURE DATAPUMP_EXPORT(
      p_dmp_file       IN   VARCHAR2,
      p_table_space  IN   VARCHAR2,
      p_data_set_name  IN   VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2);

  PROCEDURE PREPARE_INDEXES_FOR_TTS(
      p_table_space  IN VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2);

  PROCEDURE EXPORT_TABLE_STATS(
      p_data_set_name IN             VARCHAR2,
      errbuf OUT nocopy VARCHAR2,
      retcode OUT nocopy VARCHAR2) ;

END csf_spatial_ttsp_pub;


/
