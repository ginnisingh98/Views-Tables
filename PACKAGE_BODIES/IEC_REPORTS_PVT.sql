--------------------------------------------------------
--  DDL for Package Body IEC_REPORTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_REPORTS_PVT" AS
/* $Header: IECREPB.pls 115.33 2003/07/16 16:53:33 alromero ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_REPORTS_PVT';

G_SOURCE_ID NUMBER(15);

PROCEDURE Log ( p_activity_desc IN VARCHAR2
              , p_method_name   IN VARCHAR2
              , p_sub_method    IN VARCHAR2
              , p_sql_code      IN NUMBER
              , p_sql_errm      IN VARCHAR2)
IS
   l_error_msg VARCHAR2(2048);
BEGIN

   IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
                      ( 'IEC_REPORTS_PVT'
                      , p_method_name
                      , p_sub_method
                      , p_activity_desc
                      , p_sql_code
                      , p_sql_errm
                      , l_error_msg
                      );

END Log;


/* Reset record counts for subsets in IEC_G_REP_SUBSET_COUNTS and IEC_G_MKTG_ITEM_CC_TZS
   Three entry points - Reset_AllRecordCounts
                      - Reset_CampaignRecordCounts
                      - Reset_ListRecordCounts
*/

PROCEDURE Calculate_SubsetCounts
   ( p_schedule_id              IN            NUMBER
   , p_list_id                  IN            NUMBER
   , p_subset_id_col            IN            SYSTEM.number_tbl_type
   , x_subset_record_loaded_col IN OUT NOCOPY SYSTEM.number_tbl_type
   , x_subset_record_called_col IN OUT NOCOPY SYSTEM.number_tbl_type)
IS
BEGIN

   x_subset_record_loaded_col := SYSTEM.number_tbl_type();
   x_subset_record_called_col := SYSTEM.number_tbl_type();

   IF p_subset_id_col IS NOT NULL AND p_subset_id_col.COUNT > 0 THEN

      FOR i IN 1..p_subset_id_col.LAST LOOP

         x_subset_record_loaded_col.EXTEND(1);
         x_subset_record_called_col.EXTEND(1);

         -- RECORDS LOADED
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT COUNT(*)
                FROM IEC_G_RETURN_ENTRIES
                WHERE SUBSET_ID = :subset_id'
            INTO x_subset_record_loaded_col(x_subset_record_loaded_col.LAST)
            USING p_subset_id_col(i);
         EXCEPTION
            WHEN OTHERS THEN
               Log( 'Generation of number of loaded records for subset ' || p_subset_id_col(i)
                   , 'Calculate_SubsetCounts'
                   , 'GET_RECORDS_LOADED_COUNT'
                   , SQLCODE
                   , SQLERRM
                  );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

         -- RECORDS CALLED ONCE
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT NVL(SUM(DECODE(NVL(B.CALL_ATTEMPT, 0), 0, 0, 1)), 0)
                FROM IEC_G_RETURN_ENTRIES A, IEC_O_RCY_CALL_HISTORIES B
                WHERE A.RETURNS_ID = B.RETURNS_ID
                AND A.SUBSET_ID = :subset_id'
            INTO x_subset_record_called_col(x_subset_record_called_col.LAST)
            USING p_subset_id_col(i);

         EXCEPTION
            WHEN OTHERS THEN
               Log( 'Generation of number of records called once for subset ' || p_subset_id_col(i)
                  , 'Calculate_SubsetCounts'
                  , 'GET_RECORDS_CALLED_ONCE_COUNT'
                  , SQLCODE
                  , SQLERRM
                  );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

      END LOOP;

   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      RAISE;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      RAISE;
   WHEN OTHERS THEN
      Log( 'Reset of report counts for subsets belonging to list ' || p_list_id
         , 'Calculate_SubsetCounts'
         , 'MAIN'
         , SQLCODE
         , SQLERRM
         );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Calculate_SubsetCounts;

PROCEDURE Update_SubsetCounts
   ( p_schedule_id              IN NUMBER
   , p_list_id                  IN NUMBER
   , p_subset_id_col            IN SYSTEM.number_tbl_type
   , p_subset_record_loaded_col IN SYSTEM.number_tbl_type
   , p_subset_record_called_col IN SYSTEM.number_tbl_type)

IS
BEGIN

   EXECUTE IMMEDIATE
      'DELETE FROM IEC_G_REP_SUBSET_COUNTS
       WHERE LIST_HEADER_ID = :list_id'
   USING p_list_id;

   IF p_subset_id_col IS NOT NULL AND p_subset_id_col.COUNT > 0 THEN

      FORALL i IN 1..p_subset_id_col.LAST
         INSERT INTO IEC_G_REP_SUBSET_COUNTS
                ( SUBSET_COUNT_ID
                , SCHEDULE_ID
                , LIST_HEADER_ID
                , SUBSET_ID
                , RECORD_LOADED
                , RECORD_CALLED_ONCE
                , RECORD_CALLED_AND_REMOVED
                , RECORD_CALLED_AND_REMOVED_COPY
                , LAST_COPY_TIME
                , CREATED_BY
                , CREATION_DATE
                , LAST_UPDATE_LOGIN
                , LAST_UPDATE_DATE
                , LAST_UPDATED_BY
                , OBJECT_VERSION_NUMBER
                )
          VALUES
                (IEC_G_REP_SUBSET_COUNTS_S.NEXTVAL
                , p_schedule_id
                , p_list_id
                , p_subset_id_col(i)
                , p_subset_record_loaded_col(i)
                , p_subset_record_called_col(i)
                , 0
                , 0
                , SYSDATE
                , 1
                , SYSDATE
                , 1
                , SYSDATE
                , 0
                , 0);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      Log( 'Reset of report counts in IEC_G_REP_SUBSET_COUNTS for subsets belonging to list ' || p_list_id
         , 'Update_SubsetCounts'
         , 'MAIN'
         , SQLCODE
         , SQLERRM
         );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_SubsetCounts;

PROCEDURE Reset_ListRecordCounts
   ( p_schedule_id IN            NUMBER
   , p_list_id     IN            NUMBER
   , p_source_id   IN            NUMBER
   , x_return_code IN OUT NOCOPY VARCHAR2)
IS

   l_subset_id_col            SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();
   l_subset_record_loaded_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();
   l_subset_record_called_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

   l_cc_tz_id_col             SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();
   l_cc_tz_count_col          SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();

BEGIN

   x_return_code := 'S';
   g_source_id   := p_source_id;

   SAVEPOINT reset_counts_list;

   BEGIN
      EXECUTE IMMEDIATE
         'BEGIN
          SELECT LIST_SUBSET_ID
          BULK COLLECT INTO :l_subset_id_col
          FROM IEC_G_LIST_SUBSETS
          WHERE LIST_HEADER_ID = :list_id
          AND STATUS_CODE = ''ACTIVE'';
          END;'
      USING OUT l_subset_id_col
          , p_list_id;

   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Retrieval of subsets for list ' || p_list_id
            , 'Reset_ListRecordCounts'
            , 'GET_LIST_SUBSETS'
            , SQLCODE
            , SQLERRM
            );
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   Calculate_SubsetCounts( p_schedule_id
                         , p_list_id
                         , l_subset_id_col
                         , l_subset_record_loaded_col
                         , l_subset_record_called_col);

   Update_SubsetCounts( p_schedule_id
                      , p_list_id
                      , l_subset_id_col
                      , l_subset_record_loaded_col
                      , l_subset_record_called_col);

   --Update Record Counts by CC_TZ_ID in IEC_G_MKTG_ITEM_CC_TZS (Used to derive available and unavailable record counts)
   BEGIN

      EXECUTE IMMEDIATE
         'BEGIN
          SELECT ITM_CC_TZ_ID, COUNT(*)
          BULK COLLECT INTO :cc_tz_id_col, :cc_tz_count_col
          FROM IEC_G_RETURN_ENTRIES
          WHERE LIST_HEADER_ID = :list_id
          AND DO_NOT_USE_FLAG = ''N''
          GROUP BY ITM_CC_TZ_ID;
          END;'
      USING OUT l_cc_tz_id_col
          , OUT l_cc_tz_count_col
          , p_list_id;

      EXECUTE IMMEDIATE
         'UPDATE IEC_G_MKTG_ITEM_CC_TZS
          SET RECORD_COUNT = 0
            , LAST_UPDATE_DATE = SYSDATE
          WHERE LIST_HEADER_ID = :list_id'
      USING p_list_id;

      IF l_cc_tz_id_col IS NOT NULL AND l_cc_tz_id_col.COUNT > 0 THEN
         FORALL i IN 1..l_cc_tz_id_col.LAST
            UPDATE IEC_G_MKTG_ITEM_CC_TZS
            SET RECORD_COUNT = l_cc_tz_count_col(i)
              , LAST_UPDATE_DATE = SYSDATE
            WHERE ITM_CC_TZ_ID = l_cc_tz_id_col(i);

      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Reset of record counts in IEC_G_MKTG_ITEM_CC_TZS for list ' || p_list_id
            , 'Reset_ListRecordCounts'
            , 'UPDATE_CALLABLE_ZONE_COUNTS'
            , SQLCODE
            , SQLERRM
            );
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_code := 'E';
      ROLLBACK TO reset_counts_list;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_code := 'U';
      ROLLBACK TO reset_counts_list;
   WHEN OTHERS THEN
      Log( 'Reset of record counts for list' || p_list_id
         , 'Reset_ListRecordCounts'
         , 'MAIN'
         , SQLCODE
         , SQLERRM
         );
      x_return_code := 'E';
      ROLLBACK TO reset_counts_list;

END Reset_ListRecordCounts;

PROCEDURE Reset_CampaignRecordCounts
   ( p_schedule_id IN            NUMBER
   , p_source_id   IN            NUMBER
   , x_return_code IN OUT NOCOPY VARCHAR2)
IS

   l_list_id_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();
   l_return_code VARCHAR2(1);

BEGIN

   x_return_code := 'S';
   g_source_id   := p_source_id;

   SAVEPOINT reset_counts_campaign;

   BEGIN
      EXECUTE IMMEDIATE
         'BEGIN
          SELECT LIST_HEADER_ID
          BULK COLLECT INTO :list_id_col
          FROM AMS_ACT_LISTS
          WHERE LIST_USED_BY_ID = :schedule_id
          AND LIST_ACT_TYPE = ''TARGET''
          AND LIST_USED_BY = ''CSCH'';
          END;'
      USING OUT l_list_id_col
          , p_schedule_id;
   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Retrieval of lists for campaign schedule ' || p_schedule_id
            , 'Reset_CampaignRecordCounts'
            , 'GET_SCHEDULE_LISTS'
            , SQLCODE
            , SQLERRM
            );
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_list_id_col IS NOT NULL AND l_list_id_col.COUNT > 0 THEN

      FOR i IN 1..l_list_id_col.LAST LOOP

         Reset_ListRecordCounts ( p_schedule_id
                                , l_list_id_col(i)
                                , p_source_id
                                , l_return_code);

         IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

      END LOOP;

   END IF;

   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_code := 'E';
      ROLLBACK TO reset_counts_campaign;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_code := 'U';
      ROLLBACK TO reset_counts_campaign;
   WHEN OTHERS THEN
      Log( 'Reset of record counts for campaign schedule ' || p_schedule_id
         , 'Reset_CampaignRecordCounts'
         , 'MAIN'
         , SQLCODE
         , SQLERRM
         );
      x_return_code := 'E';
      ROLLBACK TO reset_counts_campaign;

END Reset_CampaignRecordCounts;

PROCEDURE Reset_AllRecordCounts
   ( p_source_id   IN            NUMBER
   , x_return_code IN OUT NOCOPY VARCHAR2)
IS

   l_schedule_id_col SYSTEM.number_tbl_type := SYSTEM.number_tbl_type();
   l_return_code     VARCHAR2(1);

BEGIN

   x_return_code := 'S';
   g_source_id   := p_source_id;

   SAVEPOINT reset_counts_all;

   BEGIN
      EXECUTE IMMEDIATE
         'BEGIN
          SELECT SCHEDULE_ID
          BULK COLLECT INTO :schedule_id_col
          FROM IEC_G_EXECUTING_SCHEDULES_V;
          END;'
      USING OUT l_schedule_id_col;
   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Retrieval of all executing campaign schedules'
            , 'Reset_AllRecordCounts'
            , 'GET_EXECUTING_SCHEDULES'
            , SQLCODE
            , SQLERRM
            );
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF l_schedule_id_col IS NOT NULL AND l_schedule_id_col.COUNT > 0 THEN

      FOR i IN 1..l_schedule_id_col.LAST LOOP

         Reset_CampaignRecordCounts ( l_schedule_id_col(i)
                                    , p_source_id
                                    , l_return_code);

         IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

      END LOOP;

   END IF;

   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_code := 'E';
      ROLLBACK TO reset_counts_all;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_code := 'U';
      ROLLBACK TO reset_counts_all;
   WHEN OTHERS THEN
      Log( 'Reset of record counts for all campaign schedules'
         , 'Reset_AllRecordCounts'
         , 'MAIN'
         , SQLCODE
         , SQLERRM
         );
      x_return_code := 'E';
      ROLLBACK TO reset_counts_all;

END Reset_AllRecordCounts;

END IEC_REPORTS_PVT;

/
