--------------------------------------------------------
--  DDL for Package Body AMS_ADI_OBJECTS_EXPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADI_OBJECTS_EXPORT_PVT" AS
/* $Header: amsvadxb.pls 120.0 2005/07/01 03:56:04 appldev noship $ */


--========================================================================
-- PROCEDURE
--    Inserts_Schedules_Export
-- Purpose
--    Inserts Schedules in AMS_ADI_OBJECTS_EXPORT_LIST table
-- HISTORY
--
--========================================================================
PROCEDURE insert_export_schedules(
  P_SCHEDULE_IDS IN JTF_NUMBER_TABLE,
  P_COMMIT IN VARCHAR2   := FND_API.G_FALSE,
  X_EXPORT_BATCH_ID OUT NOCOPY NUMBER
)
IS
 l_export_batch_id NUMBER;
 CURSOR c_id IS
      SELECT AMS_ADI_OBJECTS_EXPORT_LIST_S.NEXTVAL
      FROM dual;
BEGIN

 --deletes all schedules previously exported by the same user
 delete
 from ams_adi_objects_export_list
 where created_by = FND_GLOBAL.user_id
 and creation_date < sysdate-1;

 OPEN c_id;
 FETCH c_id INTO l_export_batch_id;
 CLOSE c_id;

 IF (P_SCHEDULE_IDS is not null) THEN
    FORALL i IN 1..P_SCHEDULE_IDS.COUNT
      INSERT INTO AMS_ADI_OBJECTS_EXPORT_LIST
      VALUES (l_export_batch_id,'CSCH',P_SCHEDULE_IDS(i),sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.login_id);
 END IF;

 IF(P_COMMIT = FND_API.G_TRUE) THEN
   COMMIT;
 END IF;

 X_EXPORT_BATCH_ID := l_export_batch_id ;
END insert_export_schedules;



END AMS_ADI_OBJECTS_EXPORT_PVT;

/
