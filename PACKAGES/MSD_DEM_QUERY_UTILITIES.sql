--------------------------------------------------------
--  DDL for Package MSD_DEM_QUERY_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_QUERY_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: msddemqutls.pls 120.2.12010000.2 2008/11/04 11:01:08 sjagathe ship $ */


   /* MSD DEM Debug Profile Value */
   C_MSD_DEM_DEBUG   		VARCHAR2(1)   := nvl( fnd_profile.value( 'MSD_DEM_DEBUG_MODE'), 'N');

procedure get_query(retcode             OUT NOCOPY NUMBER,
		    query               OUT NOCOPY VARCHAR2,
                    p_entity_name       IN  VARCHAR2,
                    p_instance_id       IN  NUMBER,
                    p_dest_table        IN VARCHAR2 DEFAULT NULL,
                    p_add_where_clause  IN VARCHAR2 DEFAULT NULL);

procedure get_query2(retcode             OUT NOCOPY NUMBER,
		    query               OUT NOCOPY VARCHAR2,
                    p_entity_name       IN  VARCHAR2,
                    p_instance_id       IN  NUMBER,
                    keys_values IN VARCHAR2,
                    flag IN NUMBER,
		    view_name VARCHAR2 default null
);


   PROCEDURE GET_QUERY3 (
   		retcode             	OUT NOCOPY 	NUMBER,
		query               	OUT NOCOPY 	VARCHAR2,
                p_entity_name       	IN  		VARCHAR2,
                p_instance_id       	IN  		NUMBER,
                p_key_values 		IN 		VARCHAR2,
                p_custom_view_flag	IN 		NUMBER,
		p_custom_view_name	IN 		VARCHAR2 DEFAULT NULL,
		p_series_type		IN		NUMBER	 DEFAULT 1,
		p_ps_view_name		IN		VARCHAR2 DEFAULT NULL );


   /*
    * Given an identifier for the query to be executed and a list of key value pairs.
    * This procedure generates the query, replaces the constants and executes the query.
    */
   PROCEDURE EXECUTE_QUERY (
                errbuf              	OUT NOCOPY 	VARCHAR2,
                retcode             	OUT NOCOPY 	VARCHAR2,
                p_entity_name       	IN  		VARCHAR2,
                p_sr_instance_id       	IN  		NUMBER,
                p_key_values 		IN 		VARCHAR2 );


   /*
    * Given a table name, location (MSD(2) or Demantra(1)), this procedure truncates(1) or deletes(2)
    * all data from the table.
    */
   PROCEDURE TRUNCATE_TABLE (
                errbuf              	OUT NOCOPY 	VARCHAR2,
                retcode             	OUT NOCOPY 	VARCHAR2,
                p_table_name		IN		VARCHAR2,
                p_owner			IN		NUMBER 	DEFAULT 1,
                p_truncate		IN		NUMBER 	DEFAULT 1 );

END MSD_DEM_QUERY_UTILITIES;


/
