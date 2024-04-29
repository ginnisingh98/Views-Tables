--------------------------------------------------------
--  DDL for Package IEU_WR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WR_PUB" AUTHID CURRENT_USER AS
/* $Header: IEUPUWRS.pls 120.9 2006/08/18 05:09:13 msathyan noship $ */

-- *******
--
-- Status_id : 0 - open ,  3 - Closed,  4 - Delete, 5- Sleep
-- Distribution Status: 0 - Onhold/UnAvailable, 1 - Distributable, 2 - Distributing, 3 - Distributed
--
-- *******

g_pkg_name     CONSTANT VARCHAR2(30)  := 'IEU_WR_PUB';

 TYPE IEU_WR_ITEM_REC is RECORD
 (
   WORK_ITEM_ID              NUMBER(15),
   WORKITEM_OBJ_CODE         VARCHAR2(30),
   WORKITEM_PK_ID            NUMBER(15),
   PREV_PARENT_DIST_STATUS_ID   NUMBER,
   PREV_PARENT_WORKITEM_STATUS_ID  NUMBER
);

 TYPE IEU_WR_ITEM_LIST IS
 TABLE OF IEU_WR_ITEM_REC INDEX BY BINARY_INTEGER;

/******* Orig proc without audit log *********/

PROCEDURE CREATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_number          IN VARCHAR2 DEFAULT NULL,
  p_title		            IN VARCHAR2 DEFAULT NULL,
  p_party_id    	            IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_ieu_enum_type_uuid        IN VARCHAR2 DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_work_item_id	            OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code 	      IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_title		            IN VARCHAR2 DEFAULT NULL,
  p_party_id    	            IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER   DEFAULT NULL,
  p_owner_type     	      IN VARCHAR2 DEFAULT NULL,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

/***
PROCEDURE RESCHEDULE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code 	      IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_id              IN NUMBER   DEFAULT NULL,
  p_reschedule_time           IN DATE     DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);
**/

PROCEDURE SYNC_WS_DETAILS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE GET_NEXT_WORK_FOR_APPS
 ( p_api_version               IN  NUMBER,
   p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
   p_commit                    IN VARCHAR2 DEFAULT NULL,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE SYNC_DEPENDENT_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_wr_item_list              IN IEU_WR_PUB.IEU_WR_ITEM_LIST ,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

  /******** overloaded proc for Audit logging **********/

PROCEDURE CREATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_number          IN VARCHAR2 DEFAULT NULL,
  p_title                     IN VARCHAR2 DEFAULT NULL,
  p_party_id                  IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date                  IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type                IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_ieu_enum_type_uuid        IN VARCHAR2 DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_work_item_id              OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_WR_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_title                           IN VARCHAR2 DEFAULT NULL,
  p_party_id                        IN NUMBER,
  p_priority_code             IN VARCHAR2 DEFAULT NULL,
  p_due_date                  IN DATE,
  p_owner_id                  IN NUMBER   DEFAULT NULL,
  p_owner_type                IN VARCHAR2 DEFAULT NULL,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER   DEFAULT NULL,
  p_work_item_status          IN VARCHAR2 DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                 OUT NOCOPY  NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE RESCHEDULE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_id              IN NUMBER   DEFAULT NULL,
  p_reschedule_time           IN DATE     DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
 ---  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE SYNC_WS_DETAILS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                 OUT  NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE GET_NEXT_WORK_FOR_APPS
 ( p_api_version               IN  NUMBER,
   p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
   p_commit                    IN VARCHAR2 DEFAULT NULL,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
   p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE SYNC_DEPENDENT_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_wr_item_list              IN IEU_WR_PUB.IEU_WR_ITEM_LIST ,
  p_audit_trail_rec	      IN SYSTEM.WR_AUDIT_TRAIL_NST,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE ACTIVATE_WS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE CHECK_WS_ACTIVATION_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2,
  x_ws_activation_status      OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE PURGE_WR_ITEM
(
 P_API_VERSION_NUMBER	  	IN	NUMBER,
 P_INIT_MSG_LIST	      	IN	VARCHAR2,
 P_COMMIT	              	IN	VARCHAR2,
 P_PROCESSING_SET_ID	  	IN	NUMBER,
 P_OBJECT_TYPE	          	IN	VARCHAR2,
 X_RETURN_STATUS	      	OUT NOCOPY	VARCHAR2,
 X_MSG_COUNT	          	OUT NOCOPY	NUMBER,
 X_MSG_DATA	              	OUT NOCOPY	VARCHAR2
);

PROCEDURE PURGE_WR_ITEM
( p_api_version              IN NUMBER,
  p_init_msg_list            IN VARCHAR2 DEFAULT NULL,
  p_commit                   IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code        IN VARCHAR2,
  p_workitem_pk_id           IN NUMBER,
  p_application_id           IN NUMBER   DEFAULT NULL,
  p_audit_trail_rec	         IN SYSTEM.WR_AUDIT_TRAIL_NST DEFAULT NULL,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);

/**** Wrapper for RESCHEDULE_WORK_ITEM - ER# 4134808****/

PROCEDURE SNOOZE_UWQM_ITEM
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_workitem_obj_code         IN VARCHAR2 DEFAULT NULL,
  p_workitem_pk_id            IN NUMBER   DEFAULT NULL,
  p_work_item_id              IN NUMBER   DEFAULT NULL,
  p_reschedule_time           IN DATE     DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2);

PROCEDURE DEACTIVATE_WS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE SYNC_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_processing_set_id         IN NUMBER   DEFAULT NULL,
  p_user_id                   IN NUMBER   DEFAULT NULL,
  p_login_id                  IN NUMBER   DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE SYNC_ASSCT_TASK_WR_ITEMS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE IEU_DEF_TASKS_RULES_FUNC
( P_PROCESSING_SET_ID IN              NUMBER DEFAULT NULL,
  X_MSG_COUNT         OUT NOCOPY      NUMBER,
  X_MSG_DATA          OUT NOCOPY      VARCHAR2,
  X_RETURN_STATUS     OUT NOCOPY      VARCHAR2);

PROCEDURE GET_NEXT_WORK_ITEM
      ( p_ws_code               IN VARCHAR2,
        p_resource_id           IN NUMBER,
        x_workitem_pk_id        OUT nocopy NUMBER,
	x_workitem_obj_code	OUT NOCOPY VARCHAR2,
	x_source_obj_id		OUT NOCOPY NUMBER,
	x_source_obj_type_code  OUT NOCOPY VARCHAR2,
        x_msg_count             OUT nocopy NUMBER,
        x_return_status         OUT nocopy VARCHAR2,
        x_msg_data              OUT nocopy VARCHAR2);

PROCEDURE SYNC_WR_ITEM_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_processing_set_id         IN NUMBER   DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_WR_ITEM_STATUS
( p_api_version               IN NUMBER,
  p_init_msg_list             IN VARCHAR2 DEFAULT NULL,
  p_commit                    IN VARCHAR2 DEFAULT NULL,
  p_ws_code                   IN VARCHAR2 DEFAULT NULL,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2);

END IEU_WR_PUB;

 

/
