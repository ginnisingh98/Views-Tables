--------------------------------------------------------
--  DDL for Package IEU_UWQM_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQM_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: IEUUWQMS.pls 120.0 2005/06/02 15:48:28 appldev noship $ */

procedure INSERT_ROW
( p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_number          IN VARCHAR2,
  p_title		      IN VARCHAR2,
  p_party_id    	      IN NUMBER,
  p_priority_id        	      IN NUMBER,
  p_priority_level            IN NUMBER,
  p_due_date		      IN DATE,
  p_status_id                 IN NUMBER,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_owner_type_actual         IN VARCHAR2,
  p_assignee_type_actual      IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_ieu_enum_type_uuid        IN VARCHAR2,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_work_item_id	      OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2
) ;

procedure UPDATE_ROW
( p_WORKITEM_OBJ_CODE  	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_title		      IN VARCHAR2,
  p_party_id    	      IN NUMBER,
  p_priority_id        	      IN NUMBER,
  p_priority_level            IN NUMBER,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_owner_type_actual         IN VARCHAR2,
  p_assignee_type_actual      IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
--  p_ieu_enum_type_uuid        IN VARCHAR2,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2

);

PROCEDURE LOAD_ROW
( p_workitem_obj_code  	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_number          IN VARCHAR2,
  p_title		      IN VARCHAR2,
  p_party_id    	      IN NUMBER,
  p_priority_id        	      IN NUMBER,
  p_priority_level            IN NUMBER,
  p_due_date		      IN DATE,
  p_owner_id                  IN NUMBER,
  p_owner_type     	      IN VARCHAR2,
  p_assignee_id               IN NUMBER,
  p_assignee_type             IN VARCHAR2,
  p_owner_type_actual         IN VARCHAR2,
  p_assignee_type_actual      IN VARCHAR2,
  p_source_object_id          IN NUMBER,
  p_source_object_type_code   IN VARCHAR2,
  p_application_id            IN NUMBER,
  p_ieu_enum_type_uuid        IN NUMBER,
  p_user_id                   IN NUMBER,
  p_login_id                  IN NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2

);

procedure DELETE_ROW
( p_work_item_id	      IN NUMBER,
  p_workitem_obj_code  	      IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2
);

procedure UPDATE_STATUS_FLAG
( p_workitem_obj_code         IN VARCHAR2,
  p_workitem_pk_id            IN NUMBER,
  p_work_item_id              IN NUMBER DEFAULT NULL,
  p_status_update_user_id     IN NUMBER,
  p_status_id                 IN NUMBER,
--  p_start_time                IN DATE    DEFAULT NULL,
  x_return_status             OUT NOCOPY VARCHAR2
);


end IEU_UWQM_ITEMS_PKG;


 

/
