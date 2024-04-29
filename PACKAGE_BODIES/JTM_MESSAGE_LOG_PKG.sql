--------------------------------------------------------
--  DDL for Package Body JTM_MESSAGE_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_MESSAGE_LOG_PKG" AS
/* $Header: jtmmlpb.pls 120.2 2006/09/20 16:54:12 rsripada noship $ */

/* This procedure inserts a record into the FND_LOG_MESSAGES table
   FND uses an autonomous transaction so even when the hookinsert is
   rolled back because of an error the log messages still exists
*/
g_initialize_log BOOLEAN :=FALSE;
g_session_id     NUMBER :=0;

PROCEDURE LOG_MSG( v_object_id   IN VARCHAR2
                 , v_object_name IN VARCHAR2
	       	     , v_message     IN VARCHAR2
		         , v_level_id    IN NUMBER
                 , v_module      IN VARCHAR2)
IS
  l_log_level  NUMBER;
  l_module     VARCHAR2(64);
  l_message    VARCHAR2(4000);
BEGIN
  l_module := v_module;
  -- Convert to the FND_LOG LEVEL
  l_log_level := 5 - v_level_id;
  --Create the message text
  l_message := 'Object '||v_object_name||'-'||v_object_id||' : '||v_message;

--Bug 5532003
  IF g_initialize_log = TRUE THEN
     IF (l_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(l_log_level, l_module, l_message);
     END IF;
  ELSE
     fnd_log_repository.init();
     g_initialize_log := TRUE;
     IF (l_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(l_log_level, l_module, l_message);
     END IF;
  END IF;

EXCEPTION WHEN OTHERS THEN
  NULL;
END LOG_MSG;

/* This procedure deletes all records in the message table */
/* use truncate to prevent the database from running out of rollback segments*/
/* PWU: these queries are costly and there are issues with performance
        we take them out since we only provide for developer to conveniently
        remove the log records. */
/*
PROCEDURE PURGE
IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 DELETE FND_LOG_MESSAGES
 WHERE lower(MODULE) LIKE 'jtm%';
 COMMIT;

 DELETE FND_LOG_MESSAGES
 WHERE lower(MODULE) LIKE 'csl%';
 COMMIT;
EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
END PURGE;
*/

PROCEDURE INSERT_CONC_STATUS_LOG(v_package_name IN VARCHAR2
			 ,v_procedure_name IN VARCHAR2
			 ,v_con_query_id IN NUMBER
                         ,v_query_stmt IN VARCHAR2
                         ,v_start_time IN DATE
                         ,v_end_time IN DATE
                         ,v_status IN VARCHAR2
                         ,v_message IN VARCHAR2
                         ,x_log_id OUT NOCOPY NUMBER
                         ,x_status OUT NOCOPY VARCHAR2
                         ,x_msg_data OUT NOCOPY VARCHAR2)
 IS
      l_dml varchar2(2000);
    l_log_id number;
 BEGIN

       l_dml := 'INSERT INTO JTM_CONC_RUN_STATUS_LOG' ||
         '(LOG_ID,PACKAGE_NAME,PROCEDURE_NAME,CONC_QUERY_ID,QUERY_STMT, ' ||
          'CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,' ||
          'START_TIME,END_TIME,STATUS, MESSAGE)' ||
      'VALUES (JTM_CONC_RUN_STATUS_LOG_S.nextval, :1, :2, :3, :4,-1, sysdate, -1, sysdate, :5, :6, :7, :8) RETURNING LOG_ID INTO :9';
        EXECUTE IMMEDIATE l_dml using v_package_name, v_procedure_name, v_con_query_id, v_query_stmt, v_start_time,v_end_time, v_status, v_message RETURNING INTO l_log_id;
        commit;

    x_log_id := l_log_id;
    x_status := 'S';
    x_msg_data := 'Insert record into JTM_CONC_RUN_STATUS_LOG successfully';

  EXCEPTION
  WHEN OTHERS THEN
	x_status := 'E';
	x_log_id := -1;
	x_msg_data := 'Error:' || sqlerrm;
 RAISE;
 END INSERT_CONC_STATUS_LOG;


PROCEDURE UPDATE_CONC_STATUS_LOG(v_log_id IN NUMBER
                                ,v_query_stmt IN VARCHAR2
                                ,v_start_time IN DATE
                                ,v_end_time IN DATE
                                ,v_status  IN VARCHAR2
                                ,v_message  IN VARCHAR2
                                ,x_status   OUT NOCOPY VARCHAR2
                                ,x_msg_data OUT NOCOPY VARCHAR2
                                )
IS
l_dml varchar2(2000);
BEGIN
l_dml := 'UPDATE JTM_CONC_RUN_STATUS_LOG SET QUERY_STMT = :1, START_TIME = :2 ,END_TIME= :3' ||
          ',STATUS= :4 , MESSAGE= :5 WHERE LOG_ID = :5';
EXECUTE IMMEDIATE l_dml USING v_query_stmt, v_start_time, v_end_time, v_status, v_message, v_log_id;
commit;
x_status := 'S';
x_msg_data := 'UPDATE UPDATE_CONC_STATUS_LOG ' || v_log_id || ' successfully';

 EXCEPTION
  WHEN OTHERS THEN
	x_status := 'E';
	x_msg_data := 'Error:' || sqlerrm;
 RAISE;
END UPDATE_CONC_STATUS_LOG;

PROCEDURE DELETE_CONC_STATUS_LOG(v_log_id IN NUMBER)
IS
	l_dml varchar2(2000);
BEGIN
        /* Testing show that the code below does not work. comment out
	l_dml := 'DELETE FROM JTM_CONC_RUN_STATUS_LOG WHERE LOG_ID = :1';
	EXECUTE IMMEDIATE l_dml USING v_log_id;
        */
        DELETE FROM JTM_CONC_RUN_STATUS_LOG WHERE LOG_ID = v_log_id;

EXCEPTION
     WHEN OTHERS THEN
       RAISE;
END DELETE_CONC_STATUS_LOG;

END JTM_MESSAGE_LOG_PKG;

/
