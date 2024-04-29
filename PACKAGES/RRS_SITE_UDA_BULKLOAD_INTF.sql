--------------------------------------------------------
--  DDL for Package RRS_SITE_UDA_BULKLOAD_INTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_SITE_UDA_BULKLOAD_INTF" AUTHID DEFINER  AS
/* $Header: RRSIMPUS.pls 120.0.12010000.3 2009/07/27 23:13:37 sunarang noship $ */


PROCEDURE Open_Debug_Session ;
PROCEDURE open_debug_session_internal ;
PROCEDURE Developer_Debug (p_msg  IN  VARCHAR2);
PROCEDURE Close_Debug_Session ;
PROCEDURE Write_Conclog (p_msg  IN  VARCHAR2) ;

PROCEDURE LOAD_USERATTR_DATA(ERRBUF  OUT NOCOPY VARCHAR2,
            		      	RETCODE OUT NOCOPY VARCHAR2,
						    p_batch_id IN Number,
						    p_data_set_id IN Number,
						    p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE);

/*
 * commented by Sushil. We don't need this.
FUNCTION RETURN_PROCESS_STATUS RETURN VARCHAR2;
*/

END RRS_SITE_UDA_BULKLOAD_INTF;

/
