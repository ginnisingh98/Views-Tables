--------------------------------------------------------
--  DDL for Package RRS_BULKLOAD_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_BULKLOAD_ENTITIES" 
/* $Header: RRSSBLKS.pls 120.3 2005/10/26 07:38:27 pgopalar noship $ */
AUTHID CURRENT_USER AS
PROCEDURE SETUP_BULKLOAD_INTF(ERRBUF  OUT NOCOPY VARCHAR2,
            		      RETCODE OUT NOCOPY VARCHAR2,
	   		      ERROR_FILE OUT NOCOPY VARCHAR2,
			      p_result_format_usage_id IN Number);
PROCEDURE Open_Debug_Session ;
PROCEDURE open_debug_session_internal ;
PROCEDURE Developer_Debug (p_msg  IN  VARCHAR2);
PROCEDURE Close_Debug_Session ;
PROCEDURE Write_Conclog (p_msg  IN  VARCHAR2) ;
PROCEDURE LOAD_USERATTR_INTF(
	   	  		 p_resultfmt_usage_id    IN         NUMBER,
                 p_data_set_id           IN         NUMBER,
                 x_errbuff               OUT NOCOPY VARCHAR2,
                 x_retcode               OUT NOCOPY VARCHAR2,
                 p_entity_name           IN         VARCHAR2
                ) ;
PROCEDURE PROCESS_USER_ATTRS_DATA(
			   	ERRBUF                          OUT NOCOPY VARCHAR2
		       ,RETCODE                         OUT NOCOPY VARCHAR2
		       ,p_data_set_id                   IN   NUMBER
		       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE);

PROCEDURE BulkLoadEntities(
        ERRBUF                  OUT  NOCOPY   VARCHAR2,
        RETCODE                 OUT  NOCOPY   VARCHAR2,
        result_format_usage_id  IN      NUMBER,
        user_id                 IN      NUMBER,
        LANGAUGE                IN      VARCHAR2,
        resp_id                 IN      NUMBER,
        appl_id                 IN      NUMBER);

END RRS_BULKLOAD_ENTITIES;

/
