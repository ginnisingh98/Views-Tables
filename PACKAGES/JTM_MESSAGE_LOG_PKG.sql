--------------------------------------------------------
--  DDL for Package JTM_MESSAGE_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_MESSAGE_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: jtmmlps.pls 120.2 2005/08/30 00:23:53 utekumal noship $ */

G_EXC_ERROR   EXCEPTION;

--Bug 4496299
PROCEDURE LOG_MSG( v_object_id   IN VARCHAR2
                 , v_object_name IN VARCHAR2
		 , v_message     IN VARCHAR2
		 , v_level_id    IN NUMBER DEFAULT JTM_HOOK_UTIL_PKG.g_debug_level_full
                 , v_module      IN VARCHAR2 DEFAULT 'jtm_message_log_pkg');
/* PWU: the queries n procedure PURGE are costly and there are issues with
        performance we take them out since we only provide for developer
        to conveniently remove the log records. */
/*
PROCEDURE PURGE;
*/

PROCEDURE INSERT_CONC_STATUS_LOG(v_package_name IN VARCHAR2
			 ,v_procedure_name IN VARCHAR2
			 ,v_con_query_id IN NUMBER
                         ,v_query_stmt IN VARCHAR2
                         ,v_start_time IN DATE
                         ,v_end_time IN DATE
                         ,v_status VARCHAR2
                         ,v_message IN VARCHAR2
                         ,x_log_id OUT NOCOPY NUMBER
                         ,x_status OUT NOCOPY VARCHAR2
                         ,x_msg_data OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_CONC_STATUS_LOG(v_log_id IN NUMBER
                                ,v_query_stmt IN VARCHAR2
                                ,v_start_time IN DATE
                                ,v_end_time IN DATE
                                ,v_status VARCHAR2
                                ,v_message  IN VARCHAR2
                                ,x_status   OUT NOCOPY VARCHAR2
                                ,x_msg_data OUT NOCOPY VARCHAR2
                                );

PROCEDURE DELETE_CONC_STATUS_LOG(v_log_id IN NUMBER);

END JTM_MESSAGE_LOG_PKG;

 

/
