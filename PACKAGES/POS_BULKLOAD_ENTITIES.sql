--------------------------------------------------------
--  DDL for Package POS_BULKLOAD_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_BULKLOAD_ENTITIES" 
/* $Header: POSSBLKS.pls 120.0.12010000.3 2011/01/12 03:27:20 atjen noship $ */
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
                 p_entity_name           IN         VARCHAR2,
                 p_batch_id              IN         NUMBER
                ) ;
PROCEDURE PROCESS_USER_ATTRS_DATA(
			   	ERRBUF                          OUT NOCOPY VARCHAR2
		       ,RETCODE                         OUT NOCOPY VARCHAR2
		       ,p_data_set_id                   IN   NUMBER
		       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE);

PROCEDURE BULKLOADENTITIES(
        ERRBUF                  OUT  NOCOPY   VARCHAR2,
        RETCODE                 OUT  NOCOPY   VARCHAR2,
        result_format_usage_id  IN      NUMBER,
        user_id                 IN      NUMBER,
        LANGAUGE                IN      VARCHAR2,
        resp_id                 IN      NUMBER,
        appl_id                 IN      NUMBER,
        batch_id                IN      NUMBER);


PROCEDURE LOAD_PARTY_INTF(
        ERRBUF                  OUT  NOCOPY   VARCHAR2,
        RETCODE                 OUT  NOCOPY   VARCHAR2,
        p_batch_id              IN      NUMBER,
        P_PARTY_ORIG_SYSTEM     IN      VARCHAR2,
        P_PARTY_ORIG_SYSTEM_REFERENCE IN VARCHAR2,
        P_INSERT_UPDATE_FLAG IN VARCHAR2,
        P_PARTY_TYPE IN VARCHAR2,
        P_ORGANIZATION_NAME IN VARCHAR2,
        P_PERSON_FIRST_NAME IN VARCHAR2,
        P_PERSON_LAST_NAME IN VARCHAR2
        );

END POS_BULKLOAD_ENTITIES;

/
