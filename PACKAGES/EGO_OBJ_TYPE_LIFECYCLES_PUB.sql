--------------------------------------------------------
--  DDL for Package EGO_OBJ_TYPE_LIFECYCLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_OBJ_TYPE_LIFECYCLES_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPOTLS.pls 115.1 2002/12/13 19:19:58 jflannic noship $ */

PROCEDURE Create_Obj_Type_Lifecycle(
          p_api_version                 IN   NUMBER
        , p_object_id                   IN   NUMBER
        , p_object_classification_code  IN   VARCHAR2
        , p_lifecycle_id                IN   NUMBER
        , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
        , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
        , x_return_status               OUT  NOCOPY VARCHAR2
        , x_errorcode                   OUT  NOCOPY NUMBER
        , x_msg_count                   OUT  NOCOPY NUMBER
        , x_msg_data                    OUT  NOCOPY VARCHAR2
);

PROCEDURE Delete_Obj_Type_Lifecycle(
          p_api_version                 IN   NUMBER
        , p_object_id                   IN   NUMBER
        , p_object_classification_code  IN   VARCHAR2
        , p_lifecycle_id                IN   NUMBER
        , p_init_msg_list               IN   VARCHAR2   := fnd_api.g_FALSE
        , p_commit                      IN   VARCHAR2   := fnd_api.g_FALSE
        , x_return_status               OUT  NOCOPY VARCHAR2
        , x_errorcode                   OUT  NOCOPY NUMBER
        , x_msg_count                   OUT  NOCOPY NUMBER
        , x_msg_data                    OUT  NOCOPY VARCHAR2
);

END EGO_OBJ_TYPE_LIFECYCLES_PUB;

 

/
