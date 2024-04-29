--------------------------------------------------------
--  DDL for Package Body ASG_LOGGING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_LOGGING_PUB" as
/* $Header: asgplogb.pls 120.1 2005/08/12 02:52:23 saradhak noship $ */

--
--  NAME
--    ASG_LOGGING_PUB
--
--  PURPOSE
--    Public API to ADD/DELETE/UPDATE/RETRIEVE error and notification logs

--
--  Add a log entry to the log table
--
-- HISTORY
--   02-JAN-2002  ytian        Removed the reference to security_group_id
--   28-jun-2001  vekrishn     New Api's to Log Error for Sales
--   11-apr-2000  wechin       Created.
--

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
) IS

BEGIN
  null;
END Create_Log_Entry;

PROCEDURE Update_Log_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_log_entry_rec           IN  LOG_ENTRY_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
) IS

BEGIN
  null;
END Update_Log_Entry;


PROCEDURE Delete_Log_Entry
( p_api_version             IN  NUMBER ,
  p_init_msg_list           IN  VARCHAR2,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER  ,
  p_log_entry_rec           IN  LOG_ENTRY_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
) IS
BEGIN
   null;
END Delete_Log_Entry;


PROCEDURE Get_Log_Entry
( p_api_version             IN  NUMBER  ,
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
) IS
BEGIN
   null;
END Get_Log_Entry;

PROCEDURE Make_Null_Synch_Entry
( p_api_version             IN  NUMBER   ,
  p_init_msg_list           IN  VARCHAR2 ,
  p_commit                  IN  VARCHAR2 ,
  p_validation_level        IN  NUMBER   ,
  p_client_rec		    IN  CLIENT_REC_TYPE ,
  x_return_status           OUT nocopy VARCHAR2,
  x_msg_count               OUT nocopy NUMBER,
  x_msg_data                OUT nocopy VARCHAR2
) IS

BEGIN
  null;
END Make_Null_Synch_Entry;

  PROCEDURE Create_Master_Log_Entry (
            p_log_entry_rec    IN  LOG_ENTRY_REC_TYPE,
            x_mobile_error_id  OUT nocopy NUMBER,
		  x_return_status    OUT nocopy NUMBER
          ) IS
  BEGIN
    null;
  END Create_Master_Log_Entry;

  PROCEDURE Create_Detail_Log_Entry (
            p_detail_log_entry_rec  IN  DETAIL_LOG_ENTRY_REC_TYPE,
            x_return_status         OUT nocopy NUMBER
          ) IS
  BEGIN
     null;
  END Create_Detail_Log_Entry;

END ASG_LOGGING_PUB;

/
