--------------------------------------------------------
--  DDL for Package CSL_CS_COUNTERS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CS_COUNTERS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslctacs.pls 115.6 2002/11/08 14:03:00 asiegers ship $ */

/***
  Function that checks if a counter group record should be replicated. Returns TRUE if it should
***/
FUNCTION Replicate_Record
  ( p_counter_group_id NUMBER
  )
RETURN BOOLEAN;

/***
  Public function that gets called when a customer product needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/
FUNCTION Post_Insert_Parent
  ( p_item_instance_id   IN NUMBER
   ,p_resource_id        IN NUMBER
  )
RETURN BOOLEAN;

/***
  Public procedure that gets called after a customer product needs to be deleted from ACC table.
***/
FUNCTION Pre_Delete_Parent
  ( p_item_instance_id   IN NUMBER
   ,p_resource_id        IN NUMBER
  ) RETURN BOOLEAN;

/* Called before counter group Insert */
PROCEDURE PRE_INSERT_COUNTER_GROUP ( x_return_status out NOCOPY varchar2);

/* Called after counter group Insert */
PROCEDURE POST_INSERT_COUNTER_GROUP ( p_api_version           IN  NUMBER
                                    , P_Init_Msg_List         IN  VARCHAR2
                                    , P_Commit                IN  VARCHAR2
                                    , X_Return_Status         OUT NOCOPY VARCHAR2
                                    , X_Msg_Count             OUT NOCOPY NUMBER
                                    , X_Msg_Data              OUT NOCOPY VARCHAR2
                                    , p_source_object_cd      IN  VARCHAR2
                                    , p_source_object_id      IN  NUMBER
                                    , x_ctr_grp_id            IN  NUMBER
                                    , x_object_version_number OUT NOCOPY NUMBER);


/* Called before counter group Update */
PROCEDURE PRE_UPDATE_COUNTER_GROUP ( x_return_status out NOCOPY varchar2);

/* Called after counter group Update */
PROCEDURE POST_UPDATE_COUNTER_GROUP( P_Api_Version              IN  NUMBER
                                   , P_Init_Msg_List            IN  VARCHAR2
                                   , P_Commit                   IN  VARCHAR2
                                   , X_Return_Status            OUT NOCOPY VARCHAR2
                                   , X_Msg_Count                OUT NOCOPY NUMBER
                                   , X_Msg_Data                 OUT NOCOPY VARCHAR2
                                   , p_ctr_grp_id               IN  NUMBER
                                   , p_object_version_number    IN  NUMBER
                                   , p_cascade_upd_to_instances IN  VARCHAR2
                                   , x_object_version_number    OUT NOCOPY NUMBER );


/* Called before counter group Delete */
PROCEDURE PRE_DELETE_COUNTER_GROUP ( x_return_status out NOCOPY varchar2);

/* Called after counter group Delete */
PROCEDURE POST_DELETE_COUNTER_GROUP (p_counter_group_id IN NUMBER
  , x_return_status out NOCOPY varchar2);


/* Called before counter Insert */
PROCEDURE PRE_INSERT_COUNTER ( x_return_status out NOCOPY varchar2);

/* Called after counter Insert */
PROCEDURE POST_INSERT_COUNTER ( p_api_version           IN  NUMBER
                              , P_Init_Msg_List         IN  VARCHAR2
                              , P_Commit                IN  VARCHAR2
                              , X_Return_Status         OUT NOCOPY VARCHAR2
                              , X_Msg_Count             OUT NOCOPY NUMBER
                              , X_Msg_Data              OUT NOCOPY VARCHAR2
                              , x_ctr_id                IN  NUMBER
                              , x_object_version_number OUT NOCOPY NUMBER);


/* Called before counter Update */
PROCEDURE PRE_UPDATE_COUNTER ( x_return_status out NOCOPY varchar2);

/* Called after counter Update */
PROCEDURE POST_UPDATE_COUNTER ( P_Api_Version              IN  NUMBER
                              , P_Init_Msg_List            IN  VARCHAR2
                              , P_Commit                   IN  VARCHAR2
                              , X_Return_Status            OUT NOCOPY VARCHAR2
                              , X_Msg_Count                OUT NOCOPY NUMBER
                              , X_Msg_Data                 OUT NOCOPY VARCHAR2
                              , p_ctr_id                   IN  NUMBER
                              , p_object_version_number    IN  NUMBER
                              , p_cascade_upd_to_instances IN  VARCHAR2
                              , x_object_version_number    OUT NOCOPY NUMBER );


/* Called before counter Delete */
PROCEDURE PRE_DELETE_COUNTER ( P_Api_Version   IN  NUMBER
                             , P_Init_Msg_List IN  VARCHAR2
                             , P_Commit        IN  VARCHAR2
                             , X_Return_Status OUT NOCOPY VARCHAR2
                             , X_Msg_Count     OUT NOCOPY NUMBER
                             , X_Msg_Data      OUT NOCOPY VARCHAR2
                             , p_ctr_id	       IN  NUMBER );

/* Called after counter Delete */
PROCEDURE POST_DELETE_COUNTER (  p_counter_id IN NUMBER
 , x_return_status out NOCOPY varchar2);


/* Called before counter property Insert */
PROCEDURE PRE_INSERT_COUNTER_PROPERTY (x_return_status out NOCOPY varchar2);

/* Called after counter property Insert */
PROCEDURE POST_INSERT_COUNTER_PROPERTY ( P_Api_Version           IN  NUMBER
                                       , P_Init_Msg_List         IN  VARCHAR2
                                       , P_Commit                IN  VARCHAR2
                                       , X_Return_Status         OUT NOCOPY VARCHAR2
                                       , X_Msg_Count             OUT NOCOPY NUMBER
                                       , X_Msg_Data              OUT NOCOPY VARCHAR2
                                       , x_ctr_prop_id           IN  NUMBER
                                       , x_object_version_number OUT NOCOPY NUMBER );


/* Called before counter property Update */
PROCEDURE PRE_UPDATE_COUNTER_PROPERTY ( x_return_status out NOCOPY varchar2);

/* Called after counter property Update */
PROCEDURE POST_UPDATE_COUNTER_PROPERTY ( P_Api_Version              IN  NUMBER
                                       , P_Init_Msg_List            IN  VARCHAR2
                                       , P_Commit                   IN  VARCHAR2
                                       , X_Return_Status            OUT NOCOPY VARCHAR2
                                       , X_Msg_Count                OUT NOCOPY NUMBER
                                       , X_Msg_Data                 OUT NOCOPY VARCHAR2
                                       , p_ctr_prop_id              IN  NUMBER
                                       , p_object_version_number    IN  NUMBER
                                       , p_cascade_upd_to_instances IN  VARCHAR2
                                       , x_object_version_number    OUT NOCOPY NUMBER );


/* Called before counter property Delete */
PROCEDURE PRE_DELETE_COUNTER_PROPERTY ( P_Api_Version   IN  NUMBER
                                      , P_Init_Msg_List IN  VARCHAR2
                                      , P_Commit        IN  VARCHAR2
                                      , X_Return_Status OUT NOCOPY VARCHAR2
                                      , X_Msg_Count     OUT NOCOPY NUMBER
                                      , X_Msg_Data      OUT NOCOPY VARCHAR2
                                      , p_ctr_prop_id	IN  NUMBER );


/* Called after counter property Delete */
PROCEDURE POST_DELETE_COUNTER_PROPERTY ( p_counter_prop_id IN NUMBER
 ,x_return_status out NOCOPY varchar2);


END CSL_CS_COUNTERS_ACC_PKG;

 

/
