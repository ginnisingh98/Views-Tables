--------------------------------------------------------
--  DDL for Package CSF_SPATIAL_DATALOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_SPATIAL_DATALOAD_PVT" AUTHID CURRENT_USER AS
/* $Header: CSFVSDLS.pls 120.1.12010000.2 2009/10/28 05:55:15 vpalle noship $ */

 TYPE CHAR30_ARR IS TABLE OF varchar2(30);
 g_debug_p             CONSTANT VARCHAR2 (100)
                          := 'begin dbms_' || 'output' || '.put_line(:1); end;';
 g_log                 CONSTANT NUMBER         := fnd_file.LOG;
 g_output              CONSTANT NUMBER         := fnd_file.output;
 g_debug                        BOOLEAN;

 PROCEDURE DROP_INDEXES (
      p_data_set_name IN             VARCHAR2,
      p_index_type   IN              VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 ) ;

 PROCEDURE CREATE_INDEXES(
      p_data_set_name IN             VARCHAR2,
      p_tablespace   IN              VARCHAR2,
      p_index_type   IN              VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

 PROCEDURE REFRESH_MAT_VIEWS(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

 PROCEDURE CHECK_TABLE_ROW_COUNT(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

 PROCEDURE VALIDATE_BLOB_SIZE(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

 PROCEDURE CHECK_INDEX_VALIDITY(
      p_data_set_name IN             VARCHAR2,
      p_index_type   IN              VARCHAR2,
      p_status       OUT NOCOPY      VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

 PROCEDURE COMPUTE_STATISTICS(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

  PROCEDURE RECREATE_INDEX (
        p_data_set_name IN             VARCHAR2,
        p_index_name   IN              VARCHAR2,
        p_tablespace   IN              VARCHAR2,
        p_index_type   IN              VARCHAR2,
        errbuf         OUT NOCOPY      VARCHAR2,
        retcode        OUT NOCOPY      VARCHAR2 );

  PROCEDURE RECREATE_INVALID_INDEXES(
      p_data_set_name IN             VARCHAR2,
      p_tablespace   IN              VARCHAR2,
      p_index_type   IN              VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );

/*   Procedure to drop route cache table.  Fix for bug : 9019583

     When a route is calculated by Time Distance Server (TDS), the route information is stored in CSF_TDS_ROUTE_CACHE table.
     When the same route details are requested by Scheduler for the second time, TDS doesn't calculate the route again and
     it provides the route by referring the CSF_TDS_ROUTE_CACHE table. The route details are dataset specific and cannotbe
     used across the datasets. When a new dataset is loaded, this table data need to be cleared.
*/
  PROCEDURE TRUNC_ROUTE_CAHCE_TABLE(
      p_data_set_name IN             VARCHAR2,
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2 );


 PROCEDURE put_stream (p_handle IN NUMBER, p_msg_data IN VARCHAR2);

 PROCEDURE dbgl (p_msg_data VARCHAR2);

End CSF_SPATIAL_DATALOAD_PVT;

/
