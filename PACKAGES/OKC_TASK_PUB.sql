--------------------------------------------------------
--  DDL for Package OKC_TASK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TASK_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPTSKS.pls 120.0 2005/05/26 09:25:59 appldev noship $ */

   ---------------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------------------
 	G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_TASK_PUB';
 	G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
	G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  	G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  	G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

	--Procedure to create a task for resolved time value
	PROCEDURE create_task(p_api_version 		IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2 DEFAULT 'T'
			     ,p_resolved_time_id	IN NUMBER
			     ,p_timezone_id		IN NUMBER
			     ,p_timezone_name           IN VARCHAR2
			     ,p_tve_id			IN NUMBER
			     ,p_planned_end_date	IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER);

	--Procedure to create a task for condition occurence
	PROCEDURE create_condition_task(p_api_version 	IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2 DEFAULT 'T'
			     ,p_cond_occr_id		IN NUMBER
			     ,p_condition_name		IN VARCHAR2
			     ,p_task_owner_id		IN NUMBER
			     ,p_actual_end_date		IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER);

	--Procedure to create a task for contingent event
	PROCEDURE create_contingent_task(p_api_version 	IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2 DEFAULT 'T'
			     ,p_contract_id		IN NUMBER
			     ,p_contract_number		IN VARCHAR2
			     ,p_contingent_name		IN VARCHAR2
			     ,p_task_owner_id		IN NUMBER
			     ,p_actual_end_date		IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER);

	--Procedure to update a task
	PROCEDURE update_task(p_api_version 		IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
		             ,p_commit			IN VARCHAR2 DEFAULT 'T'
			     ,p_object_version_number   IN OUT NOCOPY NUMBER
			     ,p_task_id			IN NUMBER default null
			     ,p_task_number		IN NUMBER default null
			     ,p_workflow_process_id	IN NUMBER default null
			     ,p_actual_end_date       	IN DATE default null
			     ,p_alarm_fired_count       IN NUMBER default null
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2);


	--Procedure to delete a single or multiple tasks
	PROCEDURE delete_task(p_api_version 		IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2 DEFAULT 'T'
			     ,p_tve_id			IN NUMBER DEFAULT NULL
			     ,p_rtv_id			IN NUMBER DEFAULT NULL
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2);
END OKC_TASK_PUB;

 

/
