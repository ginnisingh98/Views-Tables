--------------------------------------------------------
--  DDL for Package IEU_UWQM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQM_PUB" AUTHID CURRENT_USER AS
/* $Header: IEUPUMTS.pls 115.11 2003/11/13 22:34:46 ckurian ship $ */

/* PROGRAM OBSOLETED */

-- Status_id : 0 - open , 1 - Locked, 2 - WIP , 4 - Closed, 5 - Delete

g_pkg_name     CONSTANT VARCHAR2(30)  := 'IEU_UWQM_PUB';


PROCEDURE CREATE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER ,
  p_work_item_number          IN VARCHAR2,
  p_title		              IN VARCHAR2 ,
  p_party_id    	          IN NUMBER,
  p_priority_code             IN VARCHAR2,
  p_due_date		          IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	          IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_ieu_enum_type_uuid        IN VARCHAR2,
  p_work_status_flag          IN VARCHAR2,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_work_item_id	          OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code 	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_title		              IN VARCHAR2,
  p_party_id    	          IN NUMBER,
  p_priority_code             IN VARCHAR2,
  p_due_date		          IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	          IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
--  p_ieu_enum_type_uuid        IN NOCOPY VARCHAR2 DEFAULT fnd_api.g_miss_char,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE OPEN_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE USE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_work_item_id             OUT NOCOPY NUMBER,
  x_work_item_status         OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE RELEASE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code 	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE CLOSE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE DELETE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE RESCHEDULE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code 	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER,
  p_reschedule_time           IN DATE,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2) ;

PROCEDURE GET_UWQM_ITEM_WORK_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2,
  p_commit                    IN VARCHAR2,
  p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_work_item_status         OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);


END IEU_UWQM_PUB;

 

/
