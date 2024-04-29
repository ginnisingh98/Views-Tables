--------------------------------------------------------
--  DDL for Package Body JTF_FM_AQ_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_AQ_WRAPPER_PVT" AS
/* $Header: jtfvaqb.pls 115.3 2003/09/23 17:39:18 sxkrishn ship $*/

---------------------------------------------------------------
-- PROCEDURE
--    Enqueue
--
-- HISTORY
--    12/10/99  xqin  Create.
---------------------------------------------------------------
PROCEDURE Enqueue
(
    queue_name     IN VARCHAR2,
    message_in     IN RAW,
    priority       IN NUMBER,
    message_handle OUT NOCOPY RAW
)
IS
    enqueue_options     dbms_aq.enqueue_options_t;
    message_properties  dbms_aq.message_properties_t;

BEGIN
    message_properties.priority := priority;

    DBMS_AQ.ENQUEUE(queue_name  => queue_name,
             enqueue_options    => enqueue_options,
             message_properties => message_properties,
                       payload  => message_in,
                        msgid   => message_handle);

    COMMIT;
END Enqueue;

---------------------------------------------------------------
-- PROCEDURE
--    Dequeue
--
-- HISTORY
--    12/10/99  xqin  Create.
---------------------------------------------------------------
PROCEDURE Dequeue
(
    queue_name     IN VARCHAR2,
    waiting_time   IN NUMBER,
    message_handle IN RAW,
    message_out    OUT NOCOPY RAW
)
IS
    dequeue_options     DBMS_AQ.dequeue_options_t;
    message_properties  DBMS_AQ.message_properties_t;
    message_handle2     RAW(16);

BEGIN
    dequeue_options.wait := waiting_time;
    dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;
    dequeue_options.msgid := message_handle;
    dequeue_options.dequeue_mode := DBMS_AQ.REMOVE;

    DBMS_AQ.DEQUEUE(queue_name => queue_name,
            dequeue_options    => dequeue_options,
            message_properties => message_properties,
            payload            => message_out,
            msgid              => message_handle2);


	DELETE FROM JTF_FM_REQUESTS_AQ where AQ_MSG_ID = message_handle2;

    COMMIT;
END Dequeue;

---------------------------------------------------------------
-- PROCEDURE
--    INSERT_JTF_FM_REQUEST_AQ
--
-- HISTORY
--    07/11/03 SK  Created.
---------------------------------------------------------------
PROCEDURE INSERT_JTF_FM_REQUEST_AQ
(p_request_id NUMBER,
 p_aq_msg_id  RAW,
 p_queue_type VARCHAR2)

IS

BEGIN
    INSERT INTO JTF_FM_REQUESTS_AQ (
    REQUEST_ID, AQ_MSG_ID, QUEUE_TYPE,
    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
    VALUES ( p_request_id,p_aq_msg_id ,p_queue_type ,
    FND_GLOBAL.USER_ID,SYSDATE ,FND_GLOBAL.USER_ID,
    SYSDATE,FND_GLOBAL.LOGIN_ID  );

END INSERT_JTF_FM_REQUEST_AQ;

---------------------------------------------------------------
-- PROCEDURE
--    Enqueue_Segment
--
-- HISTORY
--    07/10/03 SK  Created.
---------------------------------------------------------------
PROCEDURE Enqueue_Segment
(
    queue_name     IN VARCHAR2,
    message_in     IN RAW,
    priority       IN NUMBER,
    message_handle OUT NOCOPY RAW,
	request_id     IN NUMBER
)

IS

   CURSOR CSTATUS( request_id NUMBER) IS
     SELECT outcome_code, SERVER_ID
     FROM JTF_FM_REQUEST_HISTORY_ALL
     WHERE HIST_REQ_ID = request_id;



   CURSOR CQUEUE( server_id NUMBER) IS
     SELECT BATCH_PAUSE_Q
     FROM JTF_FM_SERVICE_ALL
     WHERE SERVER_ID = server_id;

     l_request_status VARCHAR2(50);
     l_server_id  NUMBER;
     l_queue_name VARCHAR2(50);


     enqueue_options     dbms_aq.enqueue_options_t;
     message_properties  dbms_aq.message_properties_t;

BEGIN
    message_properties.priority := priority;


	OPEN CSTATUS(request_id);
	FETCH  CSTATUS INTO l_request_status, l_server_id ;
    CLOSE CSTATUS;

	OPEN CQUEUE(l_server_id);
	FETCH  CQUEUE INTO l_queue_name ;
    CLOSE CQUEUE;

	IF l_request_status = 'PAUSED' THEN

    DBMS_AQ.ENQUEUE(queue_name  => l_queue_name,
             enqueue_options    => enqueue_options,
             message_properties => message_properties,
                       payload  => message_in,
                        msgid   => message_handle);

	INSERT_JTF_FM_REQUEST_AQ(request_id,message_handle ,'BP');



	ELSIF	l_request_status = 'CANCELED' THEN
	-- Don't bother to enqueue
	    NULL;
	ELSE
	    DBMS_AQ.ENQUEUE(queue_name  => queue_name,
                 enqueue_options    => enqueue_options,
                 message_properties => message_properties,
                           payload  => message_in,
                            msgid   => message_handle);

	INSERT_JTF_FM_REQUEST_AQ(request_id,message_handle ,'B');


	END IF;

    COMMIT;
END Enqueue_Segment;

END JTF_FM_AQ_WRAPPER_PVT;

/
