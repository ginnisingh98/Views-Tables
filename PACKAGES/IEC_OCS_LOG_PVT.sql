--------------------------------------------------------
--  DDL for Package IEC_OCS_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_OCS_LOG_PVT" AUTHID CURRENT_USER AS
/* $Header: IECOCLGS.pls 120.1 2006/03/28 07:44:08 minwang noship $ */

   PROCEDURE LOG_LIST_STATUS_IEC_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_LIST_ID           IN            NUMBER
   , P_STATUS_ID         IN            NUMBER
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   );

   PROCEDURE LOG_LIST_STATUS_AMS_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_LIST_ID           IN            NUMBER
   , P_STATUS_ID         IN            NUMBER
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   );

   PROCEDURE LOG_LOCATE_LIST_DATA_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_LIST_ID           IN            NUMBER
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   );

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
   );

   PROCEDURE LOG_INTERNAL_PLSQL_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_ACTIVITY          IN            VARCHAR2
   , P_SQL_CODE          IN            NUMBER
   , P_SQL_MESSAGE       IN            VARCHAR2
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   );

   PROCEDURE LOG_INTERNAL_PLSQL_ERROR
   ( P_PACKAGE           IN            VARCHAR2
   , P_METHOD            IN            VARCHAR2
   , P_SUB_METHOD        IN            VARCHAR2
   , P_SQL_MESSAGE       IN            VARCHAR2
   , X_ERROR_MESSAGE_STR    OUT NOCOPY VARCHAR2
   );

-- New Logging Procedures

  PROCEDURE Get_EncodedMessage
   ( x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Log_Message
   ( p_module  IN VARCHAR2);

  PROCEDURE Get_Module
   ( p_package       IN            VARCHAR2
   , p_method        IN            VARCHAR2
   , p_sub_method    IN            VARCHAR2
   , x_module           OUT NOCOPY VARCHAR2);

  PROCEDURE Init_GetSubsetViewErrorMsg
   ( p_subset_name    IN            VARCHAR2
   , p_list_name      IN            VARCHAR2
   , p_procedure_name IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2);

  PROCEDURE Init_NoEntriesFoundMsg
   ( x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SourceTypeDoesNotExistMsg
   ( p_source_type IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SourceTypeMismatchAllMsg
   ( p_source_type      IN            VARCHAR2
   , p_source_type_dist IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SourceTypeMismatchSomeMsg
   ( p_source_type      IN            VARCHAR2
   , p_source_type_dist IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SourceTypeMissingColsMsg
   ( p_source_type     IN            VARCHAR2
   , p_missing_columns IN            VARCHAR2
   , x_message            OUT NOCOPY VARCHAR2
   , x_enc_message        OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SourceTypeNotSupportedMsg
   ( p_source_type IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SqlErrmMsg
   ( p_sqlerrm     IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_StatusUpdateErrorMsg
   ( p_list_name      IN            VARCHAR2
   , p_procedure_name IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SubsetViewDoesNotExistMsg
   ( p_subset_name    IN         VARCHAR2
   , p_list_name      IN         VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_TerritoryNotFoundMsg
   ( p_territory_code IN            VARCHAR2
   , p_table_name     IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2);

  PROCEDURE Init_TerritoryNotUniqueMsg
   ( p_territory_code IN            VARCHAR2
   , p_table_name     IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2);

  PROCEDURE Init_ValidationSuccessMsg
   ( p_total_count IN            VARCHAR2
   , p_valid_count IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_SubsetViewInvalidMsg
   ( p_subset_name    IN            VARCHAR2
   , p_list_name      IN            VARCHAR2
   , x_message           OUT NOCOPY VARCHAR2
   , x_enc_message       OUT NOCOPY VARCHAR2);

  PROCEDURE Init_ValidationSqlErrmMsg
   ( p_sqlerrm     IN            VARCHAR2
   , p_module      IN            VARCHAR2
   , x_message        OUT NOCOPY VARCHAR2
   , x_enc_message    OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopyDestListInvalidStaMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopyDestListNotCCRMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopyDestListNotValMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopyDestListNullMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopySrcListInvalidStatMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopySrcListNotCCRMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopySrcListNotValMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CopySrcListNullMsg
   ( p_src_schedule_id  IN            VARCHAR2
   , p_dest_schedule_id IN            VARCHAR2
   , x_message             OUT NOCOPY VARCHAR2
   , x_enc_message         OUT NOCOPY VARCHAR2);

  PROCEDURE Init_ListRtInfoDNEMsg
   ( p_schedule_id  IN            VARCHAR2
   , x_message         OUT NOCOPY VARCHAR2
   , x_enc_message     OUT NOCOPY VARCHAR2);

  PROCEDURE Init_PurgeListStatusInvMsg
   ( p_schedule_id  IN            VARCHAR2
   , x_message         OUT NOCOPY VARCHAR2
   , x_enc_message     OUT NOCOPY VARCHAR2);

  PROCEDURE Init_CannotStopScheduleMsg
   ( p_schedule_id  IN            VARCHAR2
   , x_message         OUT NOCOPY VARCHAR2
   , x_enc_message     OUT NOCOPY VARCHAR2);

END IEC_OCS_LOG_PVT;


 

/
