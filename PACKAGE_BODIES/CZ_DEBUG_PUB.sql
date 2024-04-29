--------------------------------------------------------
--  DDL for Package Body CZ_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_DEBUG_PUB" AS
/*	$Header: czdbpubb.pls 115.5 2002/11/27 16:57:55 askhacha ship $		*/

v_msg_tbl msg_text_list;

--------------------------------------------------
------log debug messages
PROCEDURE populate_debug_message(p_msg     IN VARCHAR2,
				         p_caller  IN VARCHAR2,
				         p_code    IN NUMBER,
					   v_msg_tbl IN OUT NOCOPY msg_text_list)
AS

record_count	PLS_INTEGER := 0;

BEGIN
	record_count := v_msg_tbl.COUNT + 1;
	v_msg_tbl(record_count).msg_text    := LTRIM(RTRIM(substr(p_msg,1,2000)));
	v_msg_tbl(record_count).called_proc := p_caller;
	v_msg_tbl(record_count).SQL_CODE    := p_code;
EXCEPTION
WHEN OTHERS THEN
	RAISE;
END populate_debug_message;

------------------------------------------------------------------------------------------------------------
PROCEDURE insert_into_logs(p_msg_tbl IN OUT NOCOPY msg_text_list)
AS
PRAGMA AUTONOMOUS_TRANSACTION;
l_run_id  NUMBER;
l_user    VARCHAR2(15);
l_sid     NUMBER;
l_loguser VARCHAR2(40);

BEGIN
	-----get run id
	SELECT cz_xfr_run_infos_s.nextval INTO l_run_id FROM dual;

	-----get unique user
	l_loguser := 'NETWORK_API: '||to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss');

	IF (p_msg_tbl.COUNT > 0) THEN
		FOR I IN p_msg_tbl.FIRST..p_msg_tbl.LAST
		LOOP
			INSERT INTO cz_db_logs(logtime,
						     loguser,
						     caller,
						     statuscode,
						     message,
						     creation_date,
						     run_id)
					 values (sysdate,
						   l_loguser,
						   p_msg_tbl(i).called_proc,
						   p_msg_tbl(i).sql_code,
						   SUBSTR(p_msg_tbl(i).msg_text,1,2000),
						   sysdate,
						   l_run_id);
		END LOOP;
	END IF;
	p_msg_tbl.DELETE;
COMMIT;
EXCEPTION
WHEN OTHERS THEN
   v_msg_tbl.DELETE;
   RAISE;
   ROLLBACK;
END insert_into_logs;
-------------------------------------------------------
----procedure that decodes the messages from batch validate
PROCEDURE get_batch_validate_message (msg_status IN  NUMBER,
						  msg_text   OUT NOCOPY VARCHAR2)
IS

BEGIN
	IF (msg_status = 0) THEN
		msg_text := 'CONFIG_PROCESSED';
	ELSIF (msg_status = 1) THEN
		msg_text := 'CONFIG_PROCESSED_NO_TERMINATE';
	ELSIF (msg_status = 2) THEN
		msg_text := 'INIT_TOO_LONG';
	ELSIF (msg_status = 3) THEN
		msg_text := 'INVALID_OPTION_REQUEST';
	ELSIF (msg_status = 4) THEN
		msg_text := 'CONFIG_EXCEPTION';
	ELSIF (msg_status = 5) THEN
		msg_text := 'DATABASE_ERROR';
	ELSIF (msg_status = 6) THEN
		msg_text := 'UTL_HTTP_INIT_FAILED';
	ELSIF (msg_status = 7) THEN
		msg_text := 'UTL_HTTP_REQUEST_FAILED';
	ELSIF (msg_status = 8) THEN
		msg_text := 'INVALID_VALIDATION_TYPE';
	END IF;
END;

----------------------------------------------------------------------------------------------------------------

END CZ_DEBUG_PUB;

/
