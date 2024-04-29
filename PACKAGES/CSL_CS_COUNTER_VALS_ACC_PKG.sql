--------------------------------------------------------
--  DDL for Package CSL_CS_COUNTER_VALS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CS_COUNTER_VALS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslcvacs.pls 115.5 2002/11/08 14:02:56 asiegers ship $ */

FUNCTION Replicate_Record
  ( p_counter_value_id IN NUMBER
  )
RETURN BOOLEAN;
/***
  Function that checks if counter value record should be replicated.
  Returns TRUE if it should
***/

FUNCTION Post_Insert_Parent
  ( p_counter_id  IN NUMBER
   ,p_resource_id IN NUMBER
  )
RETURN BOOLEAN;
/***
  Public function that gets called when an assignment needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

FUNCTION Pre_Delete_Parent
  ( p_counter_id  IN NUMBER
   ,p_resource_id IN NUMBER
  ) RETURN BOOLEAN;
/***
  DO NOTHING. Counter value will never be deleted.
***/

PROCEDURE PRE_INSERT_COUNTER_VALUE ( x_return_status OUT NOCOPY varchar2);
/* Called before counter value Insert */

PROCEDURE POST_INSERT_COUNTER_VALUE ( P_Api_Version_Number IN  NUMBER
                                    , P_Init_Msg_List      IN  VARCHAR2
                                    , P_Commit             IN  VARCHAR2
                                    , p_validation_level   IN  NUMBER
                                    , p_COUNTER_GRP_LOG_ID IN  NUMBER
                                    , X_Return_Status      OUT NOCOPY VARCHAR2
                                    , X_Msg_Count          OUT NOCOPY NUMBER
                                    , X_Msg_Data           OUT NOCOPY VARCHAR2 );
/* Called after counter value Insert */

PROCEDURE PRE_UPDATE_COUNTER_VALUE ( x_return_status OUT NOCOPY varchar2);
/* Called before counter value Update */

PROCEDURE POST_UPDATE_COUNTER_VALUE ( P_Api_Version_Number    IN  NUMBER
                                    , P_Init_Msg_List         IN  VARCHAR2
                                    , P_Commit                IN  VARCHAR2
                                    , p_validation_level      IN  NUMBER
                                    , p_COUNTER_GRP_LOG_ID    IN  NUMBER
                                    , p_object_version_number IN  NUMBER
                                    , X_Return_Status         OUT NOCOPY VARCHAR2
                                    , X_Msg_Count             OUT NOCOPY NUMBER
                                    , X_Msg_Data              OUT NOCOPY VARCHAR2 );
/* Called after counter value Update */

PROCEDURE PRE_DELETE_COUNTER_VALUE ( x_return_status OUT NOCOPY varchar2);
/* Called before counter value Update */

PROCEDURE POST_DELETE_COUNTER_VALUE (
  p_counter_value_id  in NUMBER
  , x_return_status OUT NOCOPY varchar2);
/* Called after counter value Update */



PROCEDURE PRE_INSERT_COUNTER_PROP_VAL ( x_return_status OUT NOCOPY varchar2);
/* Called before counter property value Insert */

PROCEDURE POST_INSERT_COUNTER_PROP_VAL ( P_Api_Version_Number IN  NUMBER
                                       , P_Init_Msg_List      IN  VARCHAR2
                                       , P_Commit             IN  VARCHAR2
                                       , p_validation_level   IN  NUMBER
                                       , p_COUNTER_GRP_LOG_ID IN  NUMBER
                                       , X_Return_Status      OUT NOCOPY VARCHAR2
                                       , X_Msg_Count          OUT NOCOPY NUMBER
                                       , X_Msg_Data           OUT NOCOPY VARCHAR2 );

/* Called after counter property value Insert */

PROCEDURE PRE_UPDATE_COUNTER_PROP_VAL ( x_return_status OUT NOCOPY varchar2);
/* Called before counter property value Update */

PROCEDURE POST_UPDATE_COUNTER_PROP_VAL ( P_Api_Version_Number    IN  NUMBER
                                       , P_Init_Msg_List         IN  VARCHAR2
                                       , P_Commit                IN  VARCHAR2
                                       , p_validation_level      IN  NUMBER
                                       , p_COUNTER_GRP_LOG_ID    IN  NUMBER
                                       , p_object_version_number IN  NUMBER
                                       , X_Return_Status         OUT NOCOPY VARCHAR2
                                       , X_Msg_Count             OUT NOCOPY NUMBER
                                       , X_Msg_Data              OUT NOCOPY VARCHAR2 );
/* Called after counter property value Update */

PROCEDURE PRE_DELETE_COUNTER_PROP_VAL ( x_return_status OUT NOCOPY varchar2);
/* Called before counter property value Update */

PROCEDURE POST_DELETE_COUNTER_PROP_VAL (
  p_counter_prop_val_id  in NUMBER
  , x_return_status OUT NOCOPY varchar2);
/* Called after counter property value Update */

END CSL_CS_COUNTER_VALS_ACC_PKG;

 

/
