--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_SCHEDULER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_SCHEDULER_PKG" AS
/* $Header: amsvtcsb.pls 120.0.12010000.2 2008/09/25 05:25:24 amlal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_SCHEDULER_PKG
-- Purpose
--
-- This package contains all the program units for traffic cop
-- Scheduler
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================





-- Start of Comments
-- Name
-- Enqueue
--
-- Purpose
-- This procedure adds a request to the Traffic Cop Processing Queue
--
PROCEDURE Enqueue(
          p_schedule_id NUMBER,
	  p_item_type   VARCHAR2,
	  p_item_id     VARCHAR2
          )
IS

cursor c_get_seq
is
select
AMS_TCOP_REQUESTS_S.nextval
from dual;

l_request_id number;
BEGIN

   -- Get the sequence value
   open c_get_seq;
   fetch c_get_seq into l_request_id;
   close c_get_seq;

   -- Insert the request with the request_status= 'NEW'
   INSERT INTO AMS_TCOP_REQUESTS
   (
   REQUEST_ID,
   SCHEDULE_ID,
   REQUEST_DATE,
   STATUS,
   COMPLETION_DATE,
   WF_ITEM_TYPE,
   WF_ITEM_ID,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   SECURITY_GROUP_ID
   )
   VALUES
   (
   l_request_id,
   p_schedule_id,
   sysdate,
   'NEW',
   null,
   p_item_type,
   p_item_id,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.USER_ID,
   FND_GLOBAL.USER_ID,
   null
   );


END Enqueue;


FUNCTION 	Is_This_Schedule_Ready_To_Run(
          	 p_schedule_id NUMBER
          	)
RETURN VARCHAR2
IS
   CURSOR C_GET_REQ_STATUS (p_schedule_id NUMBER)
   IS
   SELECT STATUS
   FROM AMS_TCOP_REQUESTS
   WHERE SCHEDULE_ID = p_schedule_id;

   l_status	VARCHAR2(30);

BEGIN

   OPEN C_GET_REQ_STATUS(p_schedule_id);
   FETCH C_GET_REQ_STATUS INTO l_status;
   CLOSE C_GET_REQ_STATUS;

   IF (l_status = 'SCHEDULED') THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

END Is_This_Schedule_Ready_To_Run;

PROCEDURE DEQUEUE (errbuf     OUT   NOCOPY   VARCHAR2,
                   retcode    OUT   NOCOPY   NUMBER
                  )
IS

   CURSOR C_GET_QUEUED_REQUESTS
   IS
   SELECT TCOP.WF_ITEM_TYPE WF_ITEM_TYPE,
          TCOP.WF_ITEM_ID WF_ITEM_ID,
          TCOP.SCHEDULE_ID SCHEDULE_ID
   FROM   AMS_TCOP_REQUESTS TCOP,WF_ITEMS WF
   WHERE TCOP.STATUS='NEW'
   and TCOP.WF_ITEM_ID=WF.ITEM_KEY
   ORDER BY TCOP.REQUEST_DATE; --first come,first serve



BEGIN
   AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_SCHEDULER_PKG.DEQUEUE ==> Entered DEQUEUE');

   FOR C1 IN C_GET_QUEUED_REQUESTS
   LOOP
      UPDATE_STATUS(C1.SCHEDULE_ID,'SCHEDULED');
      AMS_Utility_PVT.Write_Conc_Log('========= ' || C1.SCHEDULE_ID || ' =========');
      AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_SCHEDULER_PKG.DEQUEUE ==> Starting to apply Fatigue Rules for Schedule Id = ' || C1.SCHEDULE_ID);
      WF_ENGINE.COMPLETEACTIVITY(C1.WF_ITEM_TYPE,
                                 C1.WF_ITEM_ID,
                                 'AMS_TRAFFIC_COP:BLOCK1',
                                 wf_engine.eng_null);
      AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_SCHEDULER_PKG.DEQUEUE ==> Before Commiting Fatigue Rules for Schedule Id = ' || C1.SCHEDULE_ID);
      commit;
      AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_SCHEDULER_PKG.DEQUEUE ==> After Commiting Fatigue Rules for Schedule Id = ' || C1.SCHEDULE_ID);
      AMS_Utility_PVT.Write_Conc_Log('========= ' || C1.SCHEDULE_ID || ' =========');

   END LOOP;

   AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_SCHEDULER_PKG.DEQUEUE ==> Exiting DEQUEUE');


END DEQUEUE;

PROCEDURE      UPDATE_STATUS(p_schedule_id   NUMBER,
                             p_status        VARCHAR2
                            )
IS
BEGIN

   UPDATE AMS_TCOP_REQUESTS
   SET    STATUS = p_status
   WHERE  schedule_id=p_schedule_id;

END UPDATE_STATUS;

END AMS_TCOP_SCHEDULER_PKG;

/
