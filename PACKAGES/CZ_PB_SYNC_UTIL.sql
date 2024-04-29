--------------------------------------------------------
--  DDL for Package CZ_PB_SYNC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PB_SYNC_UTIL" AUTHID CURRENT_USER AS
/*	$Header: czclouts.pls 120.2 2005/11/30 08:43:49 qmao ship $	*/

TYPE  t_messageRecord IS RECORD (
						msg_text	cz_db_logs.message%TYPE,
						called_proc cz_db_logs.caller%TYPE,
						sql_code	cz_db_logs.statuscode%TYPE
     					   );

TYPE  t_ref	IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE  message_list IS TABLE OF t_messageRecord INDEX BY BINARY_INTEGER;
v_msg_tbl message_list;

----constant declarations used in resync package
RESYNC_SUCCESS CONSTANT	VARCHAR2(3) := 'ERR';
RESYNC_FAILURE CONSTANT	VARCHAR2(3) := 'OK';

FUNCTION get_run_id RETURN NUMBER;

PROCEDURE log_pb_sync_errors(p_msg_tbl IN  message_list,p_run_id  IN  NUMBER);

FUNCTION retrieve_link_name(p_tgt_server_id cz_servers.server_local_id%TYPE)
RETURN VARCHAR2;

FUNCTION get_target_instance_id(p_target_instance IN VARCHAR2)
RETURN NUMBER;

FUNCTION check_db_link(p_db_link_name IN cz_servers.fndnam_link_name%TYPE)
RETURN BOOLEAN;

FUNCTION validate_schema(target_server_id cz_servers.server_local_id%TYPE)
RETURN BOOLEAN;

-- Returns the process name if there is a pub sync or publishing process running
-- Returns null otherwise
FUNCTION check_process RETURN VARCHAR2;
PROCEDURE set_dbms_info(p_module_name IN VARCHAR2);

PROCEDURE reset_dbms_info;

PROCEDURE verify_tgt_server(p_link_name IN cz_servers.fndnam_link_name%TYPE,
				    x_status OUT NOCOPY VARCHAR2,
				    x_msg    OUT NOCOPY VARCHAR2);


PROCEDURE verify_mig_tgt_server(p_link_name IN cz_servers.fndnam_link_name%TYPE,
				    x_status OUT NOCOPY VARCHAR2,
				    x_msg    OUT NOCOPY VARCHAR2);
END cz_pb_sync_util;

 

/
