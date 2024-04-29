--------------------------------------------------------
--  DDL for Package AMS_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TASK_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvtsks.pls 115.20 2002/11/22 02:26:49 jieli ship $ */

G_PKG_NAME      CONSTANT        VARCHAR2(30):='AMS_TASK_PVT';
G_USER          CONSTANT        VARCHAR2(30):=FND_GLOBAL.USER_ID;
G_FALSE         CONSTANT        VARCHAR2(30):=FND_API.G_FALSE;
G_TRUE          CONSTANT        VARCHAR2(30):=FND_API.G_TRUE;


    PROCEDURE create_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_name               IN       VARCHAR2,
        p_task_type_id            IN       NUMBER DEFAULT NULL,
	p_task_status_id          IN       NUMBER DEFAULT NULL,
	p_task_priority_id        IN       NUMBER DEFAULT NULL,
        p_owner_id                IN       NUMBER DEFAULT NULL,
	p_owner_type_code         IN       VARCHAR2 DEFAULT NULL,
	p_private_flag            IN       VARCHAR2 DEFAULT NULL,
	p_planned_start_date      IN       DATE DEFAULT NULL,
        p_planned_end_date        IN       DATE DEFAULT NULL,
        p_actual_start_date       IN       DATE DEFAULT NULL,
        p_actual_end_date         IN       DATE DEFAULT NULL,
        p_source_object_type_code IN       VARCHAR2 DEFAULT NULL,
        p_source_object_id        IN       NUMBER DEFAULT NULL,
        p_source_object_name      IN       VARCHAR2 DEFAULT NULL,
	x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_task_id                 OUT NOCOPY      NUMBER
    );

   PROCEDURE update_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN       NUMBER ,
        p_task_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_task_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
	p_task_type_id            IN       NUMBER DEFAULT NULL,
	p_task_status_id          IN       NUMBER DEFAULT NULL,
	p_task_priority_id        IN       NUMBER DEFAULT NULL,
        p_owner_id                IN       NUMBER DEFAULT NULL,
	p_private_flag            IN       VARCHAR2 DEFAULT NULL,
	p_planned_start_date      IN       DATE DEFAULT NULL,
        p_planned_end_date        IN       DATE DEFAULT NULL,
        p_actual_start_date       IN       DATE DEFAULT fnd_api.g_miss_date,
        p_actual_end_date         IN       DATE DEFAULT fnd_api.g_miss_date,
        p_source_object_type_code IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_source_object_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_source_object_name      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    );



   PROCEDURE delete_task (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN       NUMBER ,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    );


	Procedure  Create_Task_Assignment (
		 P_API_VERSION			IN NUMBER		,
		 P_INIT_MSG_LIST		IN VARCHAR2 	DEFAULT FND_API.G_FALSE ,
		 P_COMMIT                       IN VARCHAR2	DEFAULT FND_API.G_FALSE ,
		 P_TASK_ID			IN NUMBER		,
		 P_RESOURCE_TYPE_CODE           IN VARCHAR2	,
		 P_RESOURCE_ID                  IN NUMBER		,
		 P_ASSIGNMENT_STATUS_ID	        IN NUMBER ,
		 X_RETURN_STATUS	 OUT NOCOPY VARCHAR2	,
		 X_MSG_COUNT		 OUT NOCOPY NUMBER 		,
		 X_MSG_DATA		     OUT NOCOPY VARCHAR2	,
		 X_TASK_ASSIGNMENT_ID           OUT NOCOPY NUMBER ) ;


--Procedure to Delete Task Assignment


	Procedure  Delete_Task_Assignment
	   (P_API_VERSION			IN	NUMBER	,
		P_INIT_MSG_LIST			IN	VARCHAR2 ,
		P_COMMIT			IN	VARCHAR2 ,
		p_object_version_number		IN	NUMBER	,
		P_TASK_ASSIGNMENT_ID		IN	NUMBER 	,
		X_RETURN_STATUS		 OUT NOCOPY VARCHAR2,
		X_MSG_COUNT		        OUT NOCOPY NUMBER 	,
		X_MSG_DATA		 OUT NOCOPY VARCHAR2 ) ;



--Procedure to Update Task Assignment


	Procedure  Update_Task_Assignment(
           P_API_VERSION		IN NUMBER	,
           p_object_version_number IN NUMBER,
           P_INIT_MSG_LIST		IN VARCHAR2 DEFAULT G_FALSE,
           P_COMMIT		IN VARCHAR2 DEFAULT G_FALSE 		,
           P_TASK_ASSIGNMENT_ID    IN NUMBER ,
           P_TASK_ID               IN NUMBER   default fnd_api.g_miss_num,
           P_RESOURCE_TYPE_CODE    IN VARCHAR2 DEFAULT NULL,
           P_RESOURCE_ID           IN NUMBER,
           P_ASSIGNMENT_STATUS_ID	IN NUMBER ,
           X_RETURN_STATUS	 OUT NOCOPY VARCHAR2 ,
           X_MSG_COUNT	 OUT NOCOPY NUMBER ,
           X_MSG_DATA	 OUT NOCOPY VARCHAR2)  ;




--  Wrapper on JTF Workflow API

       PROCEDURE start_task_workflow (
	      p_api_version         IN       NUMBER,
	      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
	      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
	      p_task_id             IN       NUMBER,
	      p_old_assignee_code   IN       VARCHAR2 DEFAULT NULL,
	      p_old_assignee_id     IN       NUMBER DEFAULT NULL,
	      p_new_assignee_code   IN       VARCHAR2 DEFAULT NULL,
	      p_new_assignee_id     IN       NUMBER DEFAULT NULL,
	      p_old_owner_code      IN       VARCHAR2 DEFAULT NULL,
	      p_old_owner_id        IN       NUMBER DEFAULT NULL,
	      p_new_owner_code      IN       VARCHAR2 DEFAULT NULL,
	      p_new_owner_id        IN       NUMBER DEFAULT NULL,
	      p_task_attribute        IN        VARCHAR2 DEFAULT NULL,
	      p_old_value             IN        VARCHAR2 DEFAULT NULL,
	      p_new_value             IN        VARCHAR2 DEFAULT NULL,
	      p_event               IN       VARCHAR2,
	      p_wf_display_name     IN       VARCHAR2 DEFAULT NULL,
	      p_wf_process          IN       VARCHAR2
		    DEFAULT jtf_task_workflow_pkg.jtf_task_default_process,
	      p_wf_item_type        IN       VARCHAR2
		    DEFAULT jtf_task_workflow_pkg.jtf_task_item_type,
	      x_return_status       OUT NOCOPY      VARCHAR2,
	      x_msg_count           OUT NOCOPY      NUMBER,
	      x_msg_data            OUT NOCOPY      VARCHAR2  );

END ams_task_pvt;   -- Package spec

 

/
