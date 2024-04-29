--------------------------------------------------------
--  DDL for Package Body IEC_OCS_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_OCS_LOG_PVT" AS
/* $Header: IECOCLGB.pls 120.1 2006/03/28 07:42:28 minwang noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_OCS_LOG_PVT';

PROCEDURE Get_Module
   ( p_package       IN            VARCHAR2
   , p_method        IN            VARCHAR2
   , p_sub_method    IN            VARCHAR2
   , x_module           OUT NOCOPY VARCHAR2)
IS
   l_module VARCHAR2(4000);
BEGIN

   x_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);

END Get_Module;

PROCEDURE Log_Message
   ( p_module  IN VARCHAR2)
IS
BEGIN

   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN

       FND_LOG.MESSAGE( FND_LOG.LEVEL_UNEXPECTED
                      , p_module
                      , FALSE);
   END IF;

END Log_Message;

PROCEDURE Get_EncodedMessage
   ( x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   x_enc_message := FND_MESSAGE.GET_ENCODED;
   FND_MESSAGE.SET_ENCODED(x_enc_message);
   x_message := FND_MESSAGE.GET;
   FND_MESSAGE.SET_ENCODED(x_enc_message);

END Get_EncodedMessage;

PROCEDURE Init_SqlErrmMsg
   ( p_sqlerrm     IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_DESC_INTERNAL_PLSQL_ERROR');

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_SQL_MESSAGE'
                        , NVL(p_sqlerrm, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SqlErrmMsg;

PROCEDURE Init_ValidationSqlErrmMsg
   ( p_sqlerrm     IN            VARCHAR2
   , p_module      IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_SQLERRM');

   FND_MESSAGE.SET_TOKEN( 'MODULE'
                        , NVL(p_module, 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'SQL_ERRM'
                        , NVL(p_sqlerrm, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_ValidationSqlErrmMsg;

PROCEDURE Init_SourceTypeNotSupportedMsg
   ( p_source_type IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_SOURCE_TYPE_NOT_SUPP');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_TYPE_CODE'
                        , NVL(p_source_type, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SourceTypeNotSupportedMsg;

PROCEDURE Init_SourceTypeDoesNotExistMsg
   ( p_source_type IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_SOURCE_TYPE_VIEW_DNE');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_TYPE_CODE'
                        , NVL(p_source_type, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SourceTypeDoesNotExistMsg;

PROCEDURE Init_SourceTypeMissingColsMsg
   ( p_source_type     IN            VARCHAR2
   , p_missing_columns IN            VARCHAR2
   , x_message            OUT NOCOPY VARCHAR2
   , x_enc_message        OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_STV_MISSING_COLUMNS');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_TYPE_CODE'
                        , NVL(p_source_type, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'MISSING_COLUMNS'
                        , NVL(p_missing_columns, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SourceTypeMissingColsMsg;

PROCEDURE Init_TerritoryNotFoundMsg
   ( p_territory_code IN            VARCHAR2
   , p_table_name     IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_TERRITORY_NOT_FOUND');
   FND_MESSAGE.SET_TOKEN( 'TERRITORY_CODE'
                        , p_territory_code
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'TABLE_NAME'
                        , p_table_name
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_TerritoryNotFoundMsg;

PROCEDURE Init_TerritoryNotUniqueMsg
   ( p_territory_code IN            VARCHAR2
   , p_table_name     IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_TERRITORY_NOT_UNIQUE');
   FND_MESSAGE.SET_TOKEN( 'TERRITORY_CODE'
                        , p_territory_code
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'TABLE_NAME'
                        , p_table_name
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_TerritoryNotUniqueMsg;

PROCEDURE Init_SubsetViewInvalidMsg
   ( p_subset_name    IN            VARCHAR2
   , p_list_name      IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_SUBSET_VIEW_NOT_VALID');
   FND_MESSAGE.SET_TOKEN( 'SUBSET_NAME'
                        , p_subset_name
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'LIST_NAME'
                        , p_list_name
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SubsetViewInvalidMsg;

PROCEDURE Init_GetSubsetViewErrorMsg
   ( p_subset_name    IN            VARCHAR2
   , p_list_name      IN            VARCHAR2
   , p_procedure_name IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_GET_SUBSET_VIEW_ERROR');
   FND_MESSAGE.SET_TOKEN( 'SUBSET_NAME'
                        , p_subset_name
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'LIST_NAME'
                        , p_list_name
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'PROCEDURE_NAME'
                        , p_procedure_name
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_GetSubsetViewErrorMsg;

PROCEDURE Init_SubsetViewDoesNotExistMsg
   ( p_subset_name    IN         VARCHAR2
   , p_list_name      IN         VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_SUBSET_VIEW_DNE');
   FND_MESSAGE.SET_TOKEN( 'SUBSET_NAME'
                        , p_subset_name
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'LIST_NAME'
                        , p_list_name
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SubsetViewDoesNotExistMsg;

PROCEDURE Init_SourceTypeMismatchAllMsg
   ( p_source_type      IN            VARCHAR2
   , p_source_type_dist IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_ST_MISMATCH_ALL');
   FND_MESSAGE.SET_TOKEN( 'LIST_SOURCE_TYPE_CODE'
                        , NVL(p_source_type, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'SOURCE_TYPE_CODE_DIST'
                        , NVL(p_source_type_dist, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SourceTypeMismatchAllMsg;

PROCEDURE Init_SourceTypeMismatchSomeMsg
   ( p_source_type      IN            VARCHAR2
   , p_source_type_dist IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_ST_MISMATCH_SOME');
   FND_MESSAGE.SET_TOKEN( 'LIST_SOURCE_TYPE_CODE'
                        , NVL(p_source_type, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'SOURCE_TYPE_CODE_DIST'
                        , NVL(p_source_type_dist, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_SourceTypeMismatchSomeMsg;

PROCEDURE Init_NoEntriesFoundMsg
   ( x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_NO_ENTRIES_FOUND');

   Get_EncodedMessage(x_message, x_enc_message);

END Init_NoEntriesFoundMsg;

PROCEDURE Init_ValidationSuccessMsg
   ( p_total_count IN            VARCHAR2
   , p_valid_count IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_SUCCESS');
   FND_MESSAGE.SET_TOKEN( 'TOTAL_COUNT'
                        , NVL(p_total_count, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'VALID_COUNT'
                        , NVL(p_valid_count, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_ValidationSuccessMsg;

PROCEDURE Init_StatusUpdateErrorMsg
   ( p_list_name      IN            VARCHAR2
   , p_procedure_name IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_STATUS_UPDATE_ERROR');
   FND_MESSAGE.SET_TOKEN( 'LIST_NAME'
                        , NVL(p_list_name, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'PROCEDURE_NAME'
                        , NVL(p_procedure_name, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_StatusUpdateErrorMsg;

PROCEDURE Init_CopySrcListNotCCRMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_SRC_LIST_NOT_CCR');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopySrcListNotCCRMsg;

PROCEDURE Init_CopyDestListNotCCRMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_DEST_LIST_NOT_CCR');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopyDestListNotCCRMsg;

PROCEDURE Init_CopySrcListNotValMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_SRC_LIST_NOT_VAL');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopySrcListNotValMsg;

PROCEDURE Init_CopyDestListNotValMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_DEST_LIST_NOT_VAL');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopyDestListNotValMsg;

PROCEDURE Init_CopySrcListInvalidStatMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_SRC_LIST_INV_STAT');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopySrcListInvalidStatMsg;

PROCEDURE Init_CopyDestListInvalidStaMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_DEST_LIST_INV_STA');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopyDestListInvalidStaMsg;

PROCEDURE Init_CopySrcListNullMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_SRC_LIST_NULL');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopySrcListNullMsg;

PROCEDURE Init_CopyDestListNullMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_COPY_DEST_LIST_NULL');
   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(p_src_schedule_id, 'UNKNOWN')
                        , TRUE);
   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(p_dest_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CopyDestListNullMsg;

PROCEDURE Init_ListRtInfoDNEMsg
   ( p_schedule_id  IN            VARCHAR2
   , x_message         OUT NOCOPY VARCHAR2
   , x_enc_message     OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_LIST_RT_INFO_DNE');
   FND_MESSAGE.SET_TOKEN( 'SCHED'
                        , NVL(p_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_ListRtInfoDNEMsg;

PROCEDURE Init_PurgeListStatusInvMsg
   ( p_schedule_id  IN            VARCHAR2
   , x_message         OUT NOCOPY VARCHAR2
   , x_enc_message     OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_VAL_PURGE_SCHED_STATUS_INV');
   FND_MESSAGE.SET_TOKEN( 'SCHED'
                        , NVL(p_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_PurgeListStatusInvMsg;

PROCEDURE Init_CannotStopScheduleMsg
   ( p_schedule_id  IN            VARCHAR2
   , x_message         OUT NOCOPY VARCHAR2
   , x_enc_message     OUT NOCOPY VARCHAR2)
IS
BEGIN

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_STATUS_CANNOT_STOP_SCHED');
   FND_MESSAGE.SET_TOKEN( 'SCHED'
                        , NVL(p_schedule_id, 'UNKNOWN')
                        , TRUE);

   Get_EncodedMessage(x_message, x_enc_message);

END Init_CannotStopScheduleMsg;

PROCEDURE LOG_INTERNAL_PLSQL_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_ACTIVITY          IN            VARCHAR2
   , P_SQL_CODE          IN            NUMBER
   , P_SQL_MESSAGE       IN            VARCHAR2
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   )
IS
   l_module VARCHAR2(4000);
BEGIN

   l_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);
   x_error_message_str := l_module || ':' || p_sql_message;

   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN
       FND_MESSAGE.SET_NAME( 'IEC'
                           , 'IEC_DESC_INTERNAL_PLSQL_ERROR');

       FND_MESSAGE.SET_TOKEN( 'IEC_PRM_SQL_MESSAGE'
                            , NVL(p_sql_message, 'UNKNOWN')
                            , TRUE);

       FND_LOG.MESSAGE( FND_LOG.LEVEL_UNEXPECTED
                      , l_module
                      , FALSE
                      );
   END IF;

END LOG_INTERNAL_PLSQL_ERROR;

PROCEDURE LOG_INTERNAL_PLSQL_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_SQL_MESSAGE       IN            VARCHAR2
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   )
IS
   l_module VARCHAR2(4000);
BEGIN

   l_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);
   x_error_message_str := l_module || ':' || p_sql_message;

   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN
       FND_MESSAGE.SET_NAME( 'IEC'
                           , 'IEC_DESC_INTERNAL_PLSQL_ERROR');

       FND_MESSAGE.SET_TOKEN( 'IEC_PRM_SQL_MESSAGE'
                            , NVL(p_sql_message, 'UNKNOWN')
                            , TRUE);

       FND_LOG.MESSAGE( FND_LOG.LEVEL_UNEXPECTED
                      , l_module
                      , FALSE
                      );
   END IF;

END LOG_INTERNAL_PLSQL_ERROR;

PROCEDURE LOG_RECYCLE_MV_DUP_REC_STMT
   ( P_PACKAGE              IN            VARCHAR2
   , P_METHOD               IN            VARCHAR2
   , P_SUB_METHOD           IN            VARCHAR2
   , P_SOURCE_SCHED_ID      IN            NUMBER
   , P_SOURCE_LIST_ID       IN            NUMBER
   , P_SOURCE_LIST_ENTRY_ID IN            NUMBER
   , P_SOURCE_RETURNS_ID    IN            NUMBER
   , P_PARTY_ID             IN            NUMBER
   , P_DEST_SCHED_ID        IN            NUMBER
   , X_ERROR_MESSAGE_STR       OUT NOCOPY VARCHAR2
   )
IS
   l_module VARCHAR2(4000);
BEGIN

   l_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_DESC_RECYCLE_MV_DUP_REC');

   FND_MESSAGE.SET_TOKEN( 'SOURCE_SCHED'
                        , NVL(TO_CHAR(P_SOURCE_SCHED_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'DEST_SCHED'
                        , NVL(TO_CHAR(P_DEST_SCHED_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'LIST_ID'
                        , NVL(TO_CHAR(P_SOURCE_LIST_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'LIST_ENTRY_ID'
                        , NVL(TO_CHAR(P_SOURCE_LIST_ENTRY_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'PARTY_ID'
                        , NVL(TO_CHAR(P_PARTY_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'RETURN_ENTRY_ID'
                        , NVL(TO_CHAR(P_SOURCE_RETURNS_ID), 'UNKNOWN')
                        , TRUE);

   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN
       FND_LOG.MESSAGE( FND_LOG.LEVEL_EVENT
                      , l_module
                      , FALSE -- ensures that message isn't cleared
                      );
   END IF;

   x_error_message_str := l_module || ':' || FND_MESSAGE.GET;

END LOG_RECYCLE_MV_DUP_REC_STMT;

PROCEDURE LOG_LIST_STATUS_IEC_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_LIST_ID           IN            NUMBER
   , P_STATUS_ID         IN            NUMBER
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   )
IS
   l_module VARCHAR2(4000);
BEGIN

   l_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_DESC_LIST_STATUS_IEC_ERR');

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_LIST_ID'
                        , NVL(TO_CHAR(P_LIST_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_STATUS_ID'
                        , NVL(TO_CHAR(P_STATUS_ID), 'UNKNOWN')
                        , TRUE);

   IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN
      FND_LOG.MESSAGE( FND_LOG.LEVEL_ERROR
                     , l_module
                     , FALSE -- ensures that message isn't cleared
                     );
   END IF;

   x_error_message_str := l_module || ':' || FND_MESSAGE.GET;

END LOG_LIST_STATUS_IEC_ERROR;

PROCEDURE LOG_LIST_STATUS_AMS_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_LIST_ID           IN            NUMBER
   , P_STATUS_ID         IN            NUMBER
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   )
IS
   l_msg_data               VARCHAR2(4000);
   l_marketing_error        VARCHAR2(2000);
   l_module                 VARCHAR2(4000);
BEGIN

   BEGIN
      -- Get Marketing API Error Message
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
         l_msg_data := FND_MSG_PUB.GET(i, FND_API.G_FALSE);
         l_msg_data := LTRIM(RTRIM(l_msg_data));
         IF (NVL(LENGTH(l_marketing_error), 0) + NVL(LENGTH(l_msg_data), 0) < 1000)
         THEN
            l_marketing_error := l_marketing_error || l_msg_data;
         ELSE
            IF (NVL(LENGTH(l_marketing_error), 0) = 0)
            THEN
               l_marketing_error := SUBSTR(l_msg_data, 1000);
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         l_marketing_error := NULL;
   END;

   l_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_DESC_LIST_STATUS_AMS_ERR');

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_LIST_ID'
                        , NVL(TO_CHAR(P_LIST_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_STATUS_ID'
                        , NVL(TO_CHAR(P_STATUS_ID), 'UNKNOWN')
                        , TRUE);

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_API_MSG'
                        , NVL(l_marketing_error, 'UNKNOWN')
                        , TRUE);

   IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN
      FND_LOG.MESSAGE( FND_LOG.LEVEL_ERROR
                     , l_module
                     , FALSE -- ensures that message isn't cleared
                     );
   END IF;

   x_error_message_str := l_module || ':' || FND_MESSAGE.GET;

END LOG_LIST_STATUS_AMS_ERROR;

PROCEDURE LOG_LOCATE_LIST_DATA_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_LIST_ID           IN            NUMBER
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   )
IS
   l_module VARCHAR2(4000);
BEGIN

   l_module := 'iec.plsql.' || UPPER(P_PACKAGE) || '.' || UPPER(P_METHOD) || '.' || LOWER(P_SUB_METHOD);

   FND_MESSAGE.SET_NAME( 'IEC'
                       , 'IEC_DESC_LOCATE_LIST_DATA_ERR');

   FND_MESSAGE.SET_TOKEN( 'IEC_PRM_LIST_ID'
                        , NVL(TO_CHAR(P_LIST_ID), 'UNKNOWN')
                        , TRUE);

   IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
   THEN
       FND_LOG.MESSAGE( FND_LOG.LEVEL_ERROR
                     , l_module
                     , FALSE -- ensures that message isn't cleared
                     );
   END IF;

   x_error_message_str := l_module || ':' || FND_MESSAGE.GET;

END LOG_LOCATE_LIST_DATA_ERROR;

END IEC_OCS_LOG_PVT;

/
