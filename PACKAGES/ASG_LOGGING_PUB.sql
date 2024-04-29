--------------------------------------------------------
--  DDL for Package ASG_LOGGING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_LOGGING_PUB" AUTHID CURRENT_USER as
/* $Header: asgplogs.pls 120.1 2005/08/12 02:52:44 saradhak noship $ */

--
--  NAME
--    ASG_LOGGING_PUB
--
--  PURPOSE
--    Public API to ADD/DELETE/UPDATE/GET error or notification logs
-- HISTORY
--   02-JAN-2002  ytian        Removed the reference to security_group_id
--   28-jun-2001  vekrishn     New Api's to Log Error for Sales,
--                             added Security Group ID to RECORD TYPE.
--   11-apr-2000  wechin       Created.


TYPE LOG_ENTRY_REC_TYPE IS RECORD
( MOBILE_ERROR_ID        NUMBER,
  LAST_UPDATE_DATE       DATE ,
  LAST_UPDATED_BY        NUMBER ,
  CREATION_DATE          DATE ,
  CREATED_BY             NUMBER ,
  DEVICE_USER_ID	 NUMBER ,
  TYPE                   VARCHAR2(30) ,
  PRIORITY		 NUMBER ,
  STATUS                 VARCHAR2(1),
  APPLICATION_ID	 NUMBER ,
  RESPONSIBILITY_ID	 NUMBER ,
  SYNCHRONOUS_EVENT	 VARCHAR2(1),
  ERROR_DAYS_DEFAULT	 NUMBER ,
  ERROR_TIME_DEFAULT	 VARCHAR2(6),
  ERROR_DESCRIPTION	 VARCHAR2(2048)
);

TYPE LOG_ENTRY_TBL_TYPE IS TABLE OF LOG_ENTRY_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_LOG_ENTRY_REC LOG_ENTRY_REC_TYPE;

TYPE LOG_ENTRY_DESC_REC_TYPE IS RECORD
( MOBILE_ERROR_ID        NUMBER,
  MOBILE_USER_NAME  VARCHAR2(240),
  USER_NAME  VARCHAR2(240),
  GATEWAY_SERVER_NAME  VARCHAR2(240),
  MOBILE_APPLICATION_NAME  VARCHAR2(240)
);

TYPE LOG_ENTRY_DESC_TBL_TYPE IS TABLE OF LOG_ENTRY_DESC_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_LOG_ENTRY_DESC_REC LOG_ENTRY_DESC_REC_TYPE;

-- Detailed Error Record Type
TYPE DETAIL_LOG_ENTRY_REC_TYPE IS RECORD
( MOBILE_ERROR_ID        NUMBER ,
  ERROR_DETAIL_ID        NUMBER ,
  LAST_UPDATE_DATE       DATE ,
  LAST_UPDATED_BY        NUMBER ,
  CREATION_DATE          DATE ,
  CREATED_BY             NUMBER ,
  TYPE                   VARCHAR2(1),
  ERROR_DESCRIPTION	     VARCHAR2(2048)
);

PROCEDURE Create_Log_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_log_entry_rec           IN  LOG_ENTRY_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2,
  x_mobile_error_id         OUT nocopy NUMBER
);

PROCEDURE Update_Log_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_log_entry_rec           IN  LOG_ENTRY_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
);

PROCEDURE Delete_Log_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_log_entry_rec           IN  LOG_ENTRY_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
);

PROCEDURE Get_Log_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_user_name		    IN  VARCHAR2 ,
  p_mobile_application_id   IN  NUMBER   ,
  p_server_id		    IN  NUMBER   ,
  p_log_entry_rec           IN  LOG_ENTRY_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2,
  x_rec_count		    OUT nocopy NUMBER,
  x_log_entry_tbl	    OUT nocopy LOG_ENTRY_TBL_TYPE,
  x_log_entry_desc_tbl      OUT nocopy LOG_ENTRY_DESC_TBL_TYPE
);


-- Additions for Null Synch

TYPE CLIENT_REC_TYPE IS RECORD
(
  MOBILE_USER_NAME	 VARCHAR2(60) ,
  LAST_UPDATE_DATE       DATE ,
  LAST_UPDATED_BY        NUMBER ,
  CREATION_DATE          DATE ,
  CREATED_BY             NUMBER
);

TYPE CLIENT_TBL_TYPE IS TABLE OF CLIENT_REC_TYPE INDEX BY BINARY_INTEGER;

G_MISS_CLIENT_REC CLIENT_REC_TYPE;

PROCEDURE Make_Null_Synch_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_client_rec		    IN  CLIENT_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
);


  PROCEDURE Create_Master_Log_Entry
  (
     p_log_entry_rec    IN  LOG_ENTRY_REC_TYPE,
     x_mobile_error_id  OUT nocopy NUMBER,
     x_return_status    OUT nocopy NUMBER
  );

  PROCEDURE Create_Detail_Log_Entry (
     p_detail_log_entry_rec  IN  DETAIL_LOG_ENTRY_REC_TYPE,
     x_return_status         OUT nocopy NUMBER
  );

END ASG_LOGGING_PUB;

 

/
