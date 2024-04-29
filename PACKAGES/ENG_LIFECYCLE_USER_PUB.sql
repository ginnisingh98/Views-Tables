--------------------------------------------------------
--  DDL for Package ENG_LIFECYCLE_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_LIFECYCLE_USER_PUB" AUTHID CURRENT_USER AS
/* $Header: ENGPLCUS.pls 115.0 2003/02/06 00:22:19 hshou noship $ */

PROCEDURE Check_Delete_Project_OK
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      PA_PROJECTS.PROJECT_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Check_Delete_Task_OK
(
     p_api_version             IN      NUMBER
   , p_task_id                 IN      PA_TASKS.TASK_ID%TYPE
   , p_init_msg_list           IN      VARCHAR2   := fnd_api.g_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);
END ENG_LIFECYCLE_USER_PUB;


 

/
