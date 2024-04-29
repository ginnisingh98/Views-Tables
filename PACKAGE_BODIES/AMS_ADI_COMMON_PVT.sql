--------------------------------------------------------
--  DDL for Package Body AMS_ADI_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ADI_COMMON_PVT" AS
/* $Header: amsvadcb.pls 120.0 2005/07/01 04:00:07 appldev noship $ */


-- package level count for success rows
g_success_row_count PLS_INTEGER := 0;

-- package level count for error rows
g_error_row_count PLS_INTEGER := 0;

TYPE ams_object_names_t IS TABLE OF VARCHAR2(240);
TYPE ams_error_messages_t IS TABLE OF VARCHAR2(4000);


AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);


--========================================================================
-- PROCEDURE
--    initializes for all operations
-- Purpose
--
-- HISTORY
--
--========================================================================
PROCEDURE init
IS
BEGIN
  -- initalizes error rec collections
  g_success_row_count := 0;
  g_error_row_count := 0;
END init;


--========================================================================
-- PROCEDURE
--    initializes for batch operations
-- Purpose
--    initializes error structure table
-- HISTORY
--
--========================================================================
PROCEDURE init_for_batch(
p_error_records IN OUT  NOCOPY ams_adi_error_rec_t
)
IS
BEGIN
  -- initializes error rec collections
  IF p_error_records IS NOT NULL THEN
    p_error_records.TRIM(p_error_records.COUNT);
  END IF;
END init_for_batch;


--========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
--========================================================================
PROCEDURE handle_success_row(
p_commit IN VARCHAR2 := FND_API.G_TRUE
)
IS
BEGIN
  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT; --commits the current row processed
  END IF;
  g_success_row_count := g_success_row_count+1;
END handle_success_row;


--========================================================================
-- PROCEDURE
--    handles ERROR in API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    does the following things
--    1. rollbacks current transaction
--    2. write conc log
--    3. adds error record in p_error_records
-- HISTORY
--
--========================================================================
PROCEDURE handle_error_row(
p_write_conc_log IN VARCHAR2 := FND_API.G_TRUE,
p_rollback IN VARCHAR2 := FND_API.G_TRUE,
p_error_code IN VARCHAR2 := NULL,
p_error_message IN VARCHAR2 := NULL,
p_object_id IN NUMBER,
p_object_name IN VARCHAR2,
p_parent_object_id IN NUMBER,
p_error_records IN OUT NOCOPY ams_adi_error_rec_t
)
IS
l_count PLS_INTEGER;
l_cum_length PLS_INTEGER;
l_cur_length PLS_INTEGER;
l_error_rec  ams_adi_error_rec;
l_error_message VARCHAR2(4000) := ' ';
l_temp_message VARCHAR2(4000);
BEGIN
  IF (p_rollback = FND_API.G_TRUE) THEN
    ROLLBACK;
  END IF;

  IF(p_write_conc_log = FND_API.G_TRUE) THEN
    AMS_Utility_PVT.Write_Conc_Log();
  END IF;

  g_error_row_count := g_error_row_count+1;

  IF (p_error_code IS NOT NULL OR p_error_message IS NOT NULL) THEN
    l_error_rec.error_code := p_error_code;
    l_error_rec.error_message := p_error_message;
    l_error_rec.object_id := p_object_id;
    l_error_rec.object_name := p_object_name;
    l_error_rec.parent_object_id:= p_parent_object_id;
  ELSE

   l_count := FND_MSG_PUB.count_msg;

   FOR l_cnt IN 1..l_count
   LOOP
     IF(l_cnt > g_max_error_messages) THEN
       EXIT; -- g_max_error_messages messages are enough, rest in concurrent log
     END IF;

     l_temp_message := FND_MSG_PUB.get(l_count-l_cnt+1, FND_API.g_false);

     l_cum_length := LENGTH(l_error_message);
     l_cur_length := LENGTH(l_temp_message)+10;

     IF((4000 - l_cur_length) > l_cum_length) THEN
       l_error_message := concat(concat(concat(l_error_message , '<br>'),l_temp_message),'</br> ');
     ELSE
       EXIT;
     END IF;
   END LOOP;

    l_error_rec.error_code := p_error_code;
    l_error_rec.error_message := l_error_message;
    l_error_rec.object_id := p_object_id;
    l_error_rec.object_name := p_object_name;
    l_error_rec.parent_object_id:= p_parent_object_id;
  END IF;

  p_error_records.EXTEND(1);
  p_error_records(p_error_records.COUNT) := l_error_rec;

END handle_error_row;



--========================================================================
-- PROCEDURE
--    handles FATAL ERROR in API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    ROLLBACK, log messages to conc log
-- HISTORY
--
--========================================================================
PROCEDURE handle_fatal_error(
p_write_conc_log IN VARCHAR2 := FND_API.G_TRUE,
p_rollback IN VARCHAR2 := FND_API.G_TRUE
)
IS
l_count PLS_INTEGER;
l_error_rec  ams_adi_error_rec;
l_error_message VARCHAR2(4000);
BEGIN
  IF (p_rollback = FND_API.G_TRUE) THEN
    ROLLBACK;
  END IF;

  IF(p_write_conc_log = FND_API.G_TRUE) THEN
    AMS_Utility_PVT.Write_Conc_Log();
  END IF;
END handle_fatal_error;




--========================================================================
-- PROCEDURE
--    updates all staging table rows with error information accumulated so far
-- Purpose
--    does the following things
--    1. updates error information in staging table using p_stmt (dynamic SQL using bind variables)
--    2. commits(so that the staging table gets updated)
-- HISTORY
--
--========================================================================
PROCEDURE complete_batch(
p_update_table_name IN VARCHAR2,
p_upload_batch_id IN NUMBER,
p_use_object_id_as_pk IN VARCHAR2 := FND_API.G_TRUE,
p_commit IN VARCHAR2 := FND_API.G_TRUE,
p_error_records IN OUT  NOCOPY ams_adi_error_rec_t
)
IS
l_count PLS_INTEGER := 0;
i PLS_INTEGER;
l_update_stmt VARCHAR2(4000);
l_error_messages ams_error_messages_t := ams_error_messages_t();
l_object_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_object_names ams_object_names_t := ams_object_names_t();
l_parent_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
BEGIN
  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT; --commits the current row processed
  END IF;

 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('Error records count '||p_error_records.COUNT);
 END IF;

 l_count := p_error_records.COUNT;

 IF(p_use_object_id_as_pk  = FND_API.G_TRUE) THEN
    -- use object id as primary key

    IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('Using Id primary key');
    END IF;

   FOR i IN 1 .. l_count
   LOOP
     l_object_ids.EXTEND;
     l_object_ids(i) := p_error_records(i).object_id;
     l_error_messages.EXTEND;
     l_error_messages(i) := p_error_records(i).error_message;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('object id : '||p_error_records(i).object_id);
     AMS_UTILITY_PVT.debug_message('error message : '||p_error_records(i).error_message);
   END IF;

   END LOOP;

    IF (l_count > 0) THEN
      IF(UPPER(p_update_table_name) = 'AMS_ADI_MEDIA_PLANNER') THEN
        FORALL i  in l_object_ids.first..l_object_ids.last
        update ams_adi_media_planner set operation_status = 'FAILED',error_message = l_error_messages(i)
        where upload_batch_id = p_upload_batch_id and object_id = l_object_ids(i);
      ELSE
        FORALL i  in l_object_ids.first..l_object_ids.last
        update ams_adi_campaigns_interface set operation_status = 'FAILED',error_message = l_error_messages(i)
        where upload_batch_id = p_upload_batch_id and object_id = l_object_ids(i);
      END IF;
    END IF;

  ELSE

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('Using name and parent id primary key');
   END IF;

    -- use object name and parent id as identifier
   FOR i IN 1 .. l_count
   LOOP
     l_object_names.EXTEND;
     l_object_names(i) := p_error_records(i).object_name;
     l_parent_ids .EXTEND;
     l_parent_ids(i) := p_error_records(i).parent_object_id;
     l_error_messages.EXTEND;
     l_error_messages(i) := p_error_records(i).error_message;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('object name : '||p_error_records(i).object_name);
     AMS_UTILITY_PVT.debug_message('parent object id : '||p_error_records(i).parent_object_id);
     AMS_UTILITY_PVT.debug_message('error message : '||p_error_records(i).error_message);
   END IF;

   END LOOP;

    IF (l_count > 0) THEN
      FORALL i  in l_object_names.first..l_object_names.last
      update ams_adi_campaigns_interface set operation_status = 'FAILED',error_message = l_error_messages(i)
      where upload_batch_id = p_upload_batch_id and object_name = l_object_names(i) and parent_object_id = l_parent_ids(i);
    END IF;
  END IF;
END complete_batch;


--========================================================================
-- PROCEDURE
--
-- Purpose
--    1. writes to conc output no. of success rows and failure rows
-- HISTORY
--
--========================================================================
PROCEDURE complete_all(
p_write_conc_out IN VARCHAR2 := FND_API.G_TRUE,
p_commit IN VARCHAR2 := FND_API.G_TRUE,
p_upload_batch_id IN NUMBER := 0
)
IS
BEGIN
  update ams_adi_campaigns_interface
  set operation_status = 'SUCCESS'
  where upload_batch_id = p_upload_batch_id
  and operation_status = 'NEW';

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT; -- commits all
  END IF;

  IF(p_write_conc_out = FND_API.G_TRUE) THEN
    AMS_Utility_PVT.Write_Conc_Log();
  END IF;
END complete_all;



END AMS_ADI_COMMON_PVT;

/
