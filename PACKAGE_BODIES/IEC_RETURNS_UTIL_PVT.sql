--------------------------------------------------------
--  DDL for Package Body IEC_RETURNS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RETURNS_UTIL_PVT" AS
/* $Header: IECVRETB.pls 115.24 2004/05/11 13:35:32 jezhu ship $ */

-- Sub-Program Unit Declarations

PROCEDURE ADD_ENTRY
  (P_LIST_ENTRY_ID        IN NUMBER
  ,P_LIST_HEADER_ID       IN NUMBER
  ,P_SUBSET_ID            IN NUMBER
  ,P_CPN_SCHEDULE_ID      IN NUMBER
  ,P_OUTCOME_ID           IN NUMBER
  ,P_REASON_ID            IN NUMBER
  ,P_RESULT_ID            IN NUMBER
  ,P_CONTACT_POINT        IN VARCHAR2
  ,P_CONTACT_POINT_ID     IN NUMBER
  ,P_CALL_START_TIME      IN VARCHAR2
  ,P_CALL_END_TIME        IN VARCHAR2
  ,P_NEXT_CALL_TIME       IN VARCHAR2
  ,P_CALL_TYPE            IN VARCHAR2
  ,P_DELIVER_IH_FLAG      IN VARCHAR2
  ,P_LIST_VIEW_NAME       IN VARCHAR2
  ,P_RECYCLE_FLAG         IN VARCHAR2
  ,X_RETURNS_ID           OUT NOCOPY NUMBER
  )
  AS
BEGIN
  ADD_ENTRY( P_LIST_ENTRY_ID
            , P_LIST_HEADER_ID
            , P_SUBSET_ID
            , P_CPN_SCHEDULE_ID
            , P_OUTCOME_ID
            , P_REASON_ID
            , P_RESULT_ID
            , P_CONTACT_POINT
            , P_CONTACT_POINT_ID
            , to_date( P_CALL_START_TIME, 'YYYY-MM-DD HH24:MI:SS')
            , to_date( P_CALL_END_TIME, 'YYYY-MM-DD HH24:MI:SS')
            , to_date( P_NEXT_CALL_TIME, 'YYYY-MM-DD HH24:MI:SS')
            , P_CALL_TYPE
            , P_DELIVER_IH_FLAG
	    , P_LIST_VIEW_NAME
            , P_RECYCLE_FLAG
            , X_RETURNS_ID
            );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END ADD_ENTRY;

PROCEDURE ADD_ENTRY
  (P_LIST_ENTRY_ID    IN NUMBER
  ,P_LIST_HEADER_ID   IN NUMBER
  ,P_SUBSET_ID        IN NUMBER
  ,P_CPN_SCHEDULE_ID  IN NUMBER
  ,P_OUTCOME_ID       IN NUMBER
  ,P_REASON_ID        IN NUMBER
  ,P_RESULT_ID        IN NUMBER
  ,P_CONTACT_POINT    IN VARCHAR2
  ,P_CONTACT_POINT_ID IN NUMBER
  ,P_CALL_START_TIME  IN DATE
  ,P_CALL_END_TIME    IN DATE
  ,P_NEXT_CALL_TIME   IN DATE
  ,P_CALL_TYPE        IN VARCHAR2
  ,P_DELIVER_IH_FLAG  IN VARCHAR2
  ,P_LIST_VIEW_NAME   IN VARCHAR2
  ,P_RECYCLE_FLAG     IN VARCHAR2
  ,X_RETURNS_ID       OUT NOCOPY NUMBER
  )
  AS
 l_user_id NUMBER;
 l_login_id NUMBER;
BEGIN

 l_user_id := nvl( FND_GLOBAL.user_id, -1 );
 l_login_id := nvl( FND_GLOBAL.conc_login_id, -1 );
  IF( ( P_LIST_ENTRY_ID is null )
    OR( P_LIST_HEADER_ID is null )
    OR( P_CPN_SCHEDULE_ID is null ) )
  THEN
    raise_application_error
      ( -20000
       , 'P_LIST_ENTRY_ID , P_LIST_HEADER_ID,  P_CPN_SCHEDULE_ID'
         || ' cannot be null.'
         || 'Values sent are list entry id (' || P_LIST_ENTRY_ID || ')'
         || 'list header id (' || P_LIST_HEADER_ID || ')'
         || 'campaign schedule id (' || P_CPN_SCHEDULE_ID || ')'
       ,TRUE
      );
   END IF;

	insert into IEC_G_RETURN_ENTRIES
        		( RETURNS_ID
                        , LIST_ENTRY_ID
                        , LIST_HEADER_ID
                        , SUBSET_ID
                        , OUTCOME_ID
                        , RESULT_ID
                        , REASON_ID
                        , CONTACT_POINT
                        , CONTACT_POINT_ID
                        , CALL_START_TIME
                        , CALL_END_TIME
                        , NEXT_CALL_TIME
                        , DELIVER_IH_FLAG
                        , CALL_TYPE
                        , CAMPAIGN_SCHEDULE_ID
                        , LIST_VIEW_NAME
                        , RECYCLE_FLAG
                        , CREATED_BY
                        , CREATION_DATE
                        , LAST_UPDATED_BY
                        , LAST_UPDATE_DATE
                        , LAST_UPDATE_LOGIN )
                 values ( IEC_G_RETURN_ENTRIES_S.NEXTVAL
                        , P_LIST_ENTRY_ID
                        , P_LIST_HEADER_ID
                        , P_SUBSET_ID
                        , P_OUTCOME_ID
                        , P_RESULT_ID
                        , P_REASON_ID
                        , P_CONTACT_POINT
                        , P_CONTACT_POINT_ID
			, to_date( P_CALL_START_TIME, 'YYYY-MM-DD HH24:MI:SS')
		        , to_date( P_CALL_END_TIME, 'YYYY-MM-DD HH24:MI:SS')
		        , to_date( P_NEXT_CALL_TIME, 'YYYY-MM-DD HH24:MI:SS')
                        , nvl(P_DELIVER_IH_FLAG, 'N')
                        , P_CALL_TYPE
                        , P_CPN_SCHEDULE_ID
                        , P_LIST_VIEW_NAME
                        , NVL( P_RECYCLE_FLAG, 'N' )
                        , l_user_id
                        , sysdate
                        , l_login_id
                        , sysdate
                        , l_login_id
                        ) returning RETURNS_ID into X_RETURNS_ID;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END ADD_ENTRY;

-- Mainly used by AODS to return the entries.
PROCEDURE UPDATE_ENTRY
  (P_RETURNS_ID       IN NUMBER
  ,P_SUBSET_ID        IN NUMBER
  ,P_CALL_START_TIME  IN VARCHAR2
  ,P_CALL_END_TIME    IN VARCHAR2
  ,P_NEXT_CALL_TIME   IN VARCHAR2
  ,P_OUTCOME_ID       IN NUMBER
  ,P_REASON_ID        IN NUMBER
  ,P_RESULT_ID        IN NUMBER
  ,P_DELIVER_IH_FLAG  IN VARCHAR2
  )
  AS
  l_user_id NUMBER;
  l_callback_flag VARCHAR2(1);

BEGIN
  l_user_id := nvl( FND_GLOBAL.user_id, -1 );
  l_callback_flag := 'N';
  IF( ( P_RETURNS_ID is null ) )
  THEN
    raise_application_error
      ( -20000
       , 'P_RETURNS_ID cannot be null.'
       ,TRUE
      );
   END IF;

   IF (P_NEXT_CALL_TIME IS NOT NULL)
   THEN
     l_callback_flag := 'Y';

   END IF;

   IF (P_OUTCOME_ID = 37 AND P_RESULT_ID = 11)
   THEN

	update IEC_G_RETURN_ENTRIES
           set OUTCOME_ID = P_OUTCOME_ID
                , RESULT_ID = P_RESULT_ID
                , LAST_UPDATE_DATE = sysdate
                , RECORD_OUT_FLAG = 'N'
          where RETURNS_ID = P_RETURNS_ID;

   ELSIF (P_OUTCOME_ID = 31 OR P_OUTCOME_ID = 38)
   THEN

	update IEC_G_RETURN_ENTRIES
           set CALL_START_TIME = to_date(P_CALL_START_TIME, 'YYYY-MM-DD HH24:MI:SS')
                , CALL_END_TIME = to_date(P_CALL_END_TIME, 'YYYY-MM-DD HH24:MI:SS')
                , NEXT_CALL_TIME = to_date(P_NEXT_CALL_TIME, 'YYYY-MM-DD HH24:MI:SS')
                , CALLBACK_FLAG = l_callback_flag
                , OUTCOME_ID = P_OUTCOME_ID
                , RESULT_ID = P_RESULT_ID
                , REASON_ID = P_REASON_ID
                , DELIVER_IH_FLAG = nvl(P_DELIVER_IH_FLAG, 'N')
                , RECYCLE_FLAG = 'Y'
                , LAST_UPDATED_BY = l_user_id
                , LAST_UPDATE_DATE = sysdate
                , RECORD_OUT_FLAG = 'Y'
          where RETURNS_ID = P_RETURNS_ID;

   ELSE
	update IEC_G_RETURN_ENTRIES
           set CALL_START_TIME = to_date(P_CALL_START_TIME, 'YYYY-MM-DD HH24:MI:SS')
                , CALL_END_TIME = to_date(P_CALL_END_TIME, 'YYYY-MM-DD HH24:MI:SS')
                , NEXT_CALL_TIME = to_date(P_NEXT_CALL_TIME, 'YYYY-MM-DD HH24:MI:SS')
                , OUTCOME_ID = P_OUTCOME_ID
                , RESULT_ID = P_RESULT_ID
                , REASON_ID = P_REASON_ID
                , DELIVER_IH_FLAG = nvl(P_DELIVER_IH_FLAG, 'N')
                , RECYCLE_FLAG = 'Y'
                , LAST_UPDATED_BY = l_user_id
                , LAST_UPDATE_DATE = sysdate
                , CALLBACK_FLAG = l_callback_flag
          where RETURNS_ID = P_RETURNS_ID;

   END IF;


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END UPDATE_ENTRY;


PROCEDURE UPDATE_ENTRY
  (P_RETURNS_ID    IN NUMBER
  ,P_SUBSET_ID     IN NUMBER
  ,P_CALL_START_TIME  IN DATE
  ,P_CALL_END_TIME    IN DATE
  ,P_NEXT_CALL_TIME   IN DATE
  ,P_OUTCOME_ID       IN NUMBER
  ,P_REASON_ID        IN NUMBER
  ,P_RESULT_ID        IN NUMBER
  ,P_DELIVER_IH_FLAG  IN VARCHAR2
  )
  AS

BEGIN
  UPDATE_ENTRY( P_RETURNS_ID
            , P_SUBSET_ID
            , to_char( P_CALL_START_TIME, 'YYYY-MM-DD HH24:MI:SS')
            , to_char( P_CALL_END_TIME, 'YYYY-MM-DD HH24:MI:SS')
            , to_char( P_NEXT_CALL_TIME, 'YYYY-MM-DD HH24:MI:SS')
            , P_OUTCOME_ID
            , P_REASON_ID
            , P_RESULT_ID
            , P_DELIVER_IH_FLAG
            );

EXCEPTION
  WHEN OTHERS THEN
     RAISE;

END UPDATE_ENTRY;

PROCEDURE UPDATE_ENTRY
  (P_RETURNS_ID       		IN NUMBER
  ,P_SUBSET_ID        		IN NUMBER
  ,P_CALL_START_TIME  		IN DATE
  ,P_CALL_END_TIME    		IN DATE
  ,P_AGENT_RECYCLE_ACTION	IN VARCHAR2
  ,P_OUTCOME_ID       		IN NUMBER
  ,P_REASON_ID        		IN NUMBER
  ,P_RESULT_ID        		IN NUMBER
  ,P_DELIVER_IH_FLAG  		IN VARCHAR2
  )
  AS
  l_user_id NUMBER;

BEGIN
  l_user_id := nvl( FND_GLOBAL.user_id, -1 );
  IF( ( P_RETURNS_ID is null ) )
  THEN
    raise_application_error
      ( -20000
       , 'P_RETURNS_ID cannot be null.'
       ,TRUE
      );
   END IF;

   IF (P_OUTCOME_ID = 37 AND P_RESULT_ID = 11)
   THEN

	update IEC_G_RETURN_ENTRIES
           set OUTCOME_ID = P_OUTCOME_ID
                , RESULT_ID = P_RESULT_ID
                , LAST_UPDATE_DATE = sysdate
                , RECORD_OUT_FLAG = 'N'
          where RETURNS_ID = P_RETURNS_ID;

   ELSE

	update IEC_G_RETURN_ENTRIES
           set CALL_START_TIME = P_CALL_START_TIME
                , CALL_END_TIME = P_CALL_END_TIME
                , AGENT_RECYCLE_ACTION = P_AGENT_RECYCLE_ACTION
                , OUTCOME_ID = P_OUTCOME_ID
                , RESULT_ID = P_RESULT_ID
                , REASON_ID = P_REASON_ID
                , DELIVER_IH_FLAG = nvl(P_DELIVER_IH_FLAG, 'N')
                , RECYCLE_FLAG = 'Y'
                , LAST_UPDATED_BY = l_user_id
                , LAST_UPDATE_DATE = sysdate
                , RECORD_OUT_FLAG = 'Y'
          where RETURNS_ID = P_RETURNS_ID;

   END IF;


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END UPDATE_ENTRY;

-- used by OCS to update the subset_id
PROCEDURE UPDATE_ENTRY
  (P_LIST_ENTRY_ID      IN NUMBER
  ,P_LIST_HEADER_ID     IN NUMBER
  ,P_CPN_SCHEDULE_ID    IN NUMBER
  ,P_SUBSET_ID          IN NUMBER
  ,X_RETURNS_ID         OUT NOCOPY NUMBER
  )
  AS
  l_user_id NUMBER;
BEGIN
  l_user_id := nvl( FND_GLOBAL.user_id, -1 );

  IF( ( P_LIST_ENTRY_ID is null )
    OR( P_LIST_HEADER_ID is null )
    OR( P_CPN_SCHEDULE_ID is null ) )
  THEN
    raise_application_error
      ( -20000
       , 'P_LIST_ENTRY_ID , P_LIST_HEADER_ID,  P_CPN_SCHEDULE_ID'
         || ' cannot be null.'
         || 'Values sent are list entry id (' || P_LIST_ENTRY_ID || ')'
         || 'list header id (' || P_LIST_HEADER_ID || ')'
         || 'campaign schedule id (' || P_CPN_SCHEDULE_ID || ')'
       ,TRUE
      );
   END IF;

	update IEC_G_RETURN_ENTRIES
           set RECYCLE_FLAG = 'N'
               , LAST_UPDATED_BY = l_user_id
               , LAST_UPDATE_DATE = sysdate
         where LIST_ENTRY_ID = P_LIST_ENTRY_ID
           and LIST_HEADER_ID = P_LIST_HEADER_ID
           and CAMPAIGN_SCHEDULE_ID = P_CPN_SCHEDULE_ID
	returning RETURNS_ID into X_RETURNS_ID;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END UPDATE_ENTRY;

-- used by recycle to add call history
PROCEDURE ADD_CALL_HISTORY
  (P_RETURNS_ID       IN NUMBER
  ,P_CONTACT_POINT    IN VARCHAR2
  ,P_OUTCOME_ID       IN NUMBER
  ,P_TIME             IN DATE
  )
  AS
  l_user_id   NUMBER;
  l_login_id  NUMBER;
  l_call_attempt  NUMBER;
  l_outcome_ids   t_outcome;
  l_times         t_time;
BEGIN
  l_user_id  := nvl( FND_GLOBAL.user_id, -1 );
  l_login_id := nvl( FND_GLOBAL.conc_login_id, -1 );
  l_outcome_ids := t_outcome(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
  l_times := t_time(null,null,null,null,null,null,null,null,null,null,null,null,
  null,null,null,null,null,null,null,null,null);
  BEGIN
      SELECT /*+ index(iec_o_rcy_call_histories iec_o_rcy_call_histories_n1)*/ call_attempt,outcome_id_0,outcome_id_1,outcome_id_2,outcome_id_3,
      outcome_id_4,outcome_id_5,outcome_id_6,outcome_id_7,outcome_id_8,outcome_id_9,
      outcome_id_10,outcome_id_11,outcome_id_12,outcome_id_13,outcome_id_14,
      outcome_id_15,outcome_id_16,outcome_id_17,outcome_id_18,outcome_id_19,
      outcome_id_20,time_0,time_1,time_2,time_3,time_4,time_5,time_6,time_7,time_8,
      time_9,time_10,time_11,time_12,time_13,time_14,time_15,time_16,time_17,
      time_18,time_19,time_20
      INTO l_call_attempt,l_outcome_ids(1),l_outcome_ids(2),l_outcome_ids(3),
      l_outcome_ids(4),l_outcome_ids(5),l_outcome_ids(6),l_outcome_ids(7),l_outcome_ids(8),
      l_outcome_ids(9),l_outcome_ids(10),l_outcome_ids(11),l_outcome_ids(12),l_outcome_ids(13),
      l_outcome_ids(14),l_outcome_ids(15),l_outcome_ids(16),l_outcome_ids(17),l_outcome_ids(18),
      l_outcome_ids(19),l_outcome_ids(20),l_outcome_ids(21),l_times(1),l_times(2),l_times(3),l_times(4),
      l_times(5),l_times(6),l_times(7),l_times(8),l_times(9),l_times(10),l_times(11),
      l_times(12),l_times(13),l_times(14),l_times(15),l_times(16),l_times(17),
      l_times(18),l_times(19),l_times(20),l_times(21)
      FROM iec_o_rcy_call_histories
      WHERE returns_id = P_RETURNS_ID AND contact_point is null
      FOR UPDATE;

      IF l_call_attempt = 21 THEN
        UPDATE  iec_o_rcy_call_histories /*+ index(iec_o_rcy_call_histories iec_o_rcy_call_histories_n1) */
        SET call_attempt= 21,
            outcome_id_0 = l_outcome_ids(2),
            outcome_id_1 = l_outcome_ids(3),
            outcome_id_2 = l_outcome_ids(4),
            outcome_id_3 = l_outcome_ids(5),
            outcome_id_4 = l_outcome_ids(6),
            outcome_id_5 = l_outcome_ids(7),
            outcome_id_6 = l_outcome_ids(8),
            outcome_id_7 = l_outcome_ids(9),
            outcome_id_8 = l_outcome_ids(10),
            outcome_id_9 = l_outcome_ids(11),
            outcome_id_10 = l_outcome_ids(12),
            outcome_id_11 = l_outcome_ids(13),
            outcome_id_12 = l_outcome_ids(14),
            outcome_id_13 = l_outcome_ids(15),
            outcome_id_14 = l_outcome_ids(16),
            outcome_id_15 = l_outcome_ids(17),
            outcome_id_16 = l_outcome_ids(18),
            outcome_id_17 = l_outcome_ids(19),
            outcome_id_18 = l_outcome_ids(20),
            outcome_id_19 = l_outcome_ids(21),
            outcome_id_20 = P_OUTCOME_ID,
            time_0 = l_times(2),
            time_1 = l_times(3),
            time_2 = l_times(4),
            time_3 = l_times(5),
            time_4 = l_times(6),
            time_5 = l_times(7),
            time_6 = l_times(8),
            time_7 = l_times(9),
            time_8 = l_times(10),
            time_9 = l_times(11),
            time_10 = l_times(12),
            time_11 = l_times(13),
            time_12 = l_times(14),
            time_13 = l_times(15),
            time_14 = l_times(16),
            time_15 = l_times(17),
            time_16 = l_times(18),
            time_17 = l_times(19),
            time_18 = l_times(20),
            time_19 = l_times(21),
            time_20 = P_TIME,
            last_update_date = sysdate
        WHERE returns_id = P_RETURNS_ID AND contact_point is null;

      ELSIF l_call_attempt < 21 THEN

        EXECUTE IMMEDIATE 'update iec_o_rcy_call_histories /*+ index(iec_o_rcy_call_histories iec_o_rcy_call_histories_n1) */ ' ||
                    'set call_attempt = :1 ' ||
                    ',   outcome_id_'||l_call_attempt||' = :2 ' ||
                    ',   time_'||l_call_attempt||' = :3 ' ||
                    ',   last_update_date = SYSDATE ' ||
                    'where returns_id = :4 AND contact_point is null'
         USING l_call_attempt+1
         ,     P_OUTCOME_ID
         ,     P_TIME
         ,     P_RETURNS_ID;

      END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      BEGIN

        INSERT INTO iec_o_rcy_call_histories
          (
            call_history_id,
            returns_id,
            call_attempt,
            contact_point,
            outcome_id_0,
            time_0,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
          )
          VALUES
          (
            iec_o_rcy_call_histories_s.nextval,
            P_RETURNS_ID,
            1,
            null,
            P_OUTCOME_ID,
            P_TIME,
            nvl(FND_GLOBAL.USER_ID,-1),
            sysdate,
            nvl(FND_GLOBAL.USER_ID,-1),
            sysdate,
            nvl(FND_GLOBAL.CONC_LOGIN_ID,-1)
          );

        INSERT INTO iec_o_rcy_call_histories
          (
            call_history_id,
            returns_id,
            call_attempt,
            contact_point,
            outcome_id_0,
            time_0,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
          )
          VALUES
          (
            iec_o_rcy_call_histories_s.nextval,
            P_RETURNS_ID,
            1,
            P_CONTACT_POINT,
            P_OUTCOME_ID,
            P_TIME,
            nvl(FND_GLOBAL.USER_ID,-1),
            sysdate,
            nvl(FND_GLOBAL.USER_ID,-1),
            sysdate,
            nvl(FND_GLOBAL.CONC_LOGIN_ID,-1)
          );

      END; -- END INSERT BLOCK
      RETURN;

  END; -- END SELECT BLOCK

  l_call_attempt := 0; --re initial

  BEGIN
      SELECT /*+ index(iec_o_rcy_call_histories iec_o_rcy_call_histories_n1) */ call_attempt,outcome_id_0,outcome_id_1,outcome_id_2,outcome_id_3,
      outcome_id_4,outcome_id_5,outcome_id_6,outcome_id_7,outcome_id_8,outcome_id_9,
      outcome_id_10,outcome_id_11,outcome_id_12,outcome_id_13,outcome_id_14,
      outcome_id_15,outcome_id_16,outcome_id_17,outcome_id_18,outcome_id_19,
      outcome_id_20,time_0,time_1,time_2,time_3,time_4,time_5,time_6,time_7,time_8,
      time_9,time_10,time_11,time_12,time_13,time_14,time_15,time_16,time_17,
      time_18,time_19,time_20
      INTO l_call_attempt,l_outcome_ids(1),l_outcome_ids(2),l_outcome_ids(3),
      l_outcome_ids(4),l_outcome_ids(5),l_outcome_ids(6),l_outcome_ids(7),l_outcome_ids(8),
      l_outcome_ids(9),l_outcome_ids(10),l_outcome_ids(11),l_outcome_ids(12),l_outcome_ids(13),
      l_outcome_ids(14),l_outcome_ids(15),l_outcome_ids(16),l_outcome_ids(17),l_outcome_ids(18),
      l_outcome_ids(19),l_outcome_ids(20),l_outcome_ids(21),l_times(1),l_times(2),l_times(3),l_times(4),
      l_times(5),l_times(6),l_times(7),l_times(8),l_times(9),l_times(10),l_times(11),
      l_times(12),l_times(13),l_times(14),l_times(15),l_times(16),l_times(17),
      l_times(18),l_times(19),l_times(20),l_times(21)
      FROM iec_o_rcy_call_histories
      WHERE returns_id = P_RETURNS_ID AND contact_point = P_CONTACT_POINT
      FOR UPDATE;

      IF l_call_attempt = 21 THEN
        UPDATE  iec_o_rcy_call_histories /*+ index(iec_o_rcy_call_histories iec_o_rcy_call_histories_n1) */
        SET call_attempt= 21,
            outcome_id_0 = l_outcome_ids(2),
            outcome_id_1 = l_outcome_ids(3),
            outcome_id_2 = l_outcome_ids(4),
            outcome_id_3 = l_outcome_ids(5),
            outcome_id_4 = l_outcome_ids(6),
            outcome_id_5 = l_outcome_ids(7),
            outcome_id_6 = l_outcome_ids(8),
            outcome_id_7 = l_outcome_ids(9),
            outcome_id_8 = l_outcome_ids(10),
            outcome_id_9 = l_outcome_ids(11),
            outcome_id_10 = l_outcome_ids(12),
            outcome_id_11 = l_outcome_ids(13),
            outcome_id_12 = l_outcome_ids(14),
            outcome_id_13 = l_outcome_ids(15),
            outcome_id_14 = l_outcome_ids(16),
            outcome_id_15 = l_outcome_ids(17),
            outcome_id_16 = l_outcome_ids(18),
            outcome_id_17 = l_outcome_ids(19),
            outcome_id_18 = l_outcome_ids(20),
            outcome_id_19 = l_outcome_ids(21),
            outcome_id_20 = P_OUTCOME_ID,
            time_0 = l_times(2),
            time_1 = l_times(3),
            time_2 = l_times(4),
            time_3 = l_times(5),
            time_4 = l_times(6),
            time_5 = l_times(7),
            time_6 = l_times(8),
            time_7 = l_times(9),
            time_8 = l_times(10),
            time_9 = l_times(11),
            time_10 = l_times(12),
            time_11 = l_times(13),
            time_12 = l_times(14),
            time_13 = l_times(15),
            time_14 = l_times(16),
            time_15 = l_times(17),
            time_16 = l_times(18),
            time_17 = l_times(19),
            time_18 = l_times(20),
            time_19 = l_times(21),
            time_20 = P_TIME,
            last_update_date = sysdate
        WHERE returns_id = P_RETURNS_ID AND contact_point = P_CONTACT_POINT;

      ELSIF l_call_attempt < 21 THEN
        EXECUTE IMMEDIATE 'update iec_o_rcy_call_histories /*+ index(iec_o_rcy_call_histories iec_o_rcy_call_histories_n1) */ ' ||
                    'set call_attempt = :1 ' ||
                    ',   outcome_id_'||l_call_attempt||' = :2 ' ||
                    ',   time_'||l_call_attempt||' = :3 ' ||
                    ',   last_update_date = SYSDATE ' ||
                    'where returns_id = :4 AND contact_point = :5'
         USING l_call_attempt+1
         ,     P_OUTCOME_ID
         ,     P_TIME
         ,     P_RETURNS_ID
         ,     P_CONTACT_POINT;

      END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      BEGIN

        INSERT INTO iec_o_rcy_call_histories
          (
            call_history_id,
            returns_id,
            call_attempt,
            contact_point,
            outcome_id_0,
            time_0,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
          )
          VALUES
          (
            iec_o_rcy_call_histories_s.nextval,
            P_RETURNS_ID,
            1,
            P_CONTACT_POINT,
            P_OUTCOME_ID,
            P_TIME,
            nvl(FND_GLOBAL.USER_ID,-1),
            sysdate,
            nvl(FND_GLOBAL.USER_ID,-1),
            sysdate,
            nvl(FND_GLOBAL.CONC_LOGIN_ID,-1)
          );

      END; -- END INSERT BLOCK
      RETURN;

  END; -- END SELECT BLOCK

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END ADD_CALL_HISTORY;

END IEC_RETURNS_UTIL_PVT;

/
