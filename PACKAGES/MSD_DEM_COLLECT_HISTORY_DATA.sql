--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_HISTORY_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_HISTORY_DATA" AUTHID CURRENT_USER AS
/* $Header: msddemchds.pls 120.0.12010000.2 2010/01/14 11:49:34 sjagathe ship $ */

   /*** GLOBAL VARIABLES ***/
   G_YES 	NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_YES;
   G_NO		NUMBER	:= MSD_DEM_COMMON_UTILITIES.C_NO;



   /*** PROCEDURES ***/


      /*
       * This procedure analyzes the given table
       */
      PROCEDURE ANALYZE_TABLE (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_table_name			IN	   VARCHAR2);


      PROCEDURE COLLECT_HISTORY_DATA (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_sr_instance_id		IN         NUMBER,
      			p_collection_group      	IN         VARCHAR2,
      			p_collection_method     	IN         NUMBER,
      			p_hidden_param1			IN	   VARCHAR2,
      			p_date_range_type		IN	   NUMBER,
      			p_collection_window		IN	   NUMBER,
      			p_from_date			IN	   VARCHAR2,
      			p_to_date			IN	   VARCHAR2,
      			p_bh_bi_bd			IN	   NUMBER,
      			p_bh_bi_rd			IN	   NUMBER,
      			p_bh_ri_bd			IN	   NUMBER,
      			p_bh_ri_rd			IN	   NUMBER,
      			p_sh_si_sd			IN	   NUMBER,
      			p_sh_si_rd			IN	   NUMBER,
      			p_sh_ri_sd			IN	   NUMBER,
      			p_sh_ri_rd			IN	   NUMBER,
      			p_collect_iso			IN	   NUMBER   DEFAULT G_NO,
      			p_collect_all_order_types	IN	   NUMBER   DEFAULT G_YES,
      			p_include_order_types		IN	   VARCHAR2 DEFAULT NULL,
      			p_exclude_order_types		IN	   VARCHAR2 DEFAULT NULL,
      			p_auto_run_download     	IN 	   NUMBER );


      PROCEDURE RUN_LOAD (
      			errbuf				OUT NOCOPY VARCHAR2,
      			retcode				OUT NOCOPY VARCHAR2,
      			p_auto_run_download     	IN 	   NUMBER );



      /*
       * This procedure inserts dummy rows into the sales staging tables for new items
       */
      PROCEDURE INSERT_DUMMY_ROWS (
      			errbuf				OUT NOCOPY 	VARCHAR2,
      			retcode				OUT NOCOPY 	VARCHAR2,
      			p_dest_table        IN	   		VARCHAR2,
      			p_sr_instance_id	IN         	NUMBER);

END MSD_DEM_COLLECT_HISTORY_DATA;

/
