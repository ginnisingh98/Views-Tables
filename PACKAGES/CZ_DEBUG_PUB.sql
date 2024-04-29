--------------------------------------------------------
--  DDL for Package CZ_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_DEBUG_PUB" AUTHID CURRENT_USER AS
/*	$Header: czdbpubs.pls 115.4 2002/11/27 16:58:00 askhacha ship $		*/

----------------------declarations
TYPE  t_messageRecord IS RECORD (
				msg_text	cz_db_logs.message%TYPE,
				called_proc cz_db_logs.caller%TYPE,
				sql_code	cz_db_logs.statuscode%TYPE
   					  );
TYPE msg_text_list IS TABLE OF t_messageRecord INDEX BY BINARY_INTEGER;
type VARCHAR_TBL_TYPE is table of VARCHAR2(2000);

--------------------
----procedure that populates debug messages
PROCEDURE populate_debug_message(p_msg     VARCHAR2,
				         p_caller  VARCHAR2,
				         p_code    NUMBER,
					   v_msg_tbl IN OUT NOCOPY msg_text_list);

-------------------
-----procedure that logs debug messages to cz_db_logs
PROCEDURE insert_into_logs(p_msg_tbl IN OUT NOCOPY msg_text_list);

----procedure that decodes the messages from batch validate
PROCEDURE get_batch_validate_message (msg_status IN  NUMBER,
						  msg_text   OUT NOCOPY VARCHAR2);

------------------------

END CZ_DEBUG_PUB;

 

/
